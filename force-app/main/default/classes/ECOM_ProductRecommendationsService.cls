/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    RWPS-4437
*
* 2. Description - This class is a service class for Product Recommendations
*
* 3. Objects referenced
*
* 4. Callouts to additional Components (including their methods) or None:
*    None
*
* 5. Dependant Class(es):
*    - ECOM_ProductRecommendationsController
*
* 6. Test Class Name:
*    - ECOM_ProductRecommendationsService_Test
*
* 7. Is @Invocable: No
*
* 8. Author Name(s):
*    - Abhishek Joshi 2025.09.15 - Created the class and added method getCustomersAlsoBought - RWPS-4437
*    - Abhishek Joshi 2025.10.29 - Updated method getCustomersAlsoBought - RWPS-5046
*************************************************************/

public without sharing class ECOM_ProductRecommendationsService {

    /**
     * @description This method fetches "Customers also bought" product recommendations for given productIdentifiers.
     * @author Abhishek Joshi 2025.09.15
     * @param productIdentifiers
     * @param configuration
     * @return Map<String, Object>
     */
    public static Map<String, Object> getCustomersAlsoBought(List<String> productIdentifiers, Map<String, Object> configuration) {
        Map<String,String> configMap = ECOM_CustomMetadataRepo.getRecommendationsConfig();

        Map<String, Object> parameters = (Map<String, Object>) JSON.deserializeUntyped(configMap.get('Recommendation_Parameters'));
        List<String> includedOrderTypes = configMap.get('Included_Order_Types').split(',');
        List<String> includedCountries = configMap.get('Included_Countries').split(',');
        List<String> excludedPayers = configMap.get('Excluded_Payers').split(',');
        List<String> excludedEmailDomains = configMap.get('Excluded_Email_Domains').split(',');

        Decimal recencyFactor =
            (Decimal) (
                configuration.containsKey('recencyFactor')
                    ? configuration.get('recencyFactor') : parameters.get('recencyFactor')
            );

        Decimal steepnessFactor =
            (Decimal) (
                configuration.containsKey('steepnessFactor')
                    ? configuration.get('steepnessFactor') : parameters.get('steepnessFactor')
            );

        Integer maxRecs =
            Integer.valueOf(
                configuration.containsKey('maxRecs')
                    ? configuration.get('maxRecs') : parameters.get('maxRecs')
            );

        Integer samplesetSize =
            configuration.containsKey('samplesetSize')
                ? Integer.valueOf(configuration.get('samplesetSize')) : maxRecs * 10;

        Integer maxRecsToReturn =
            Integer.valueOf(
                configuration.containsKey('maxRecsToReturn')
                    ? configuration.get('maxRecsToReturn') : parameters.get('maxRecsToReturn')
            );

        Decimal sameOrderBoost =
            (Decimal) (
                configuration.containsKey('sameOrderBoost')
                    ? configuration.get('sameOrderBoost') : parameters.get('sameOrderBoost')
            );

        Boolean disableMultiProductSOB =
            (Boolean) (
                configuration.containsKey('disableMultiProductSOB')
                    ? configuration.get('disableMultiProductSOB') : parameters.get('disableMultiProductSOB')
            );

        Date startDate =
            configuration.containsKey('startDate')
                ? Date.valueOf((String) configuration.get('startDate')) : Date.today().addMonths(-1 * Integer.valueOf(parameters.get('startDateMonthsDifference')));

        Date endDate =
            configuration.containsKey('endDate')
                ? Date.valueOf((String) configuration.get('endDate')) : Date.today().addMonths(-1 * Integer.valueOf(parameters.get('endDateMonthsDifference')));
        if(Test.isRunningTest()) {
            endDate = Date.today().addMonths(1);
        }

        Boolean debugMode = configuration.containsKey('debugMode')
            ? (Boolean) configuration.get('debugMode') : false;

        Map<String, Object> returnMap = new Map<String, Object>();

        List<Product2> baseProducts = ECOM_ProductRepo.getProductsByIds(new Set<String>(productIdentifiers));

        if(baseProducts.isEmpty()) { return returnMap; }

        List<String> baseProductPartNumbers = new List<String>();
        for(Product2 product : baseProducts) {
            baseProductPartNumbers.add(
                product.Part_Number__c
            );
        }

        Map<String,Product2> finalProductIdMap = new Map<String,Product2>();
        Map<String,Product2> finalProductMap = new Map<String,Product2>();
        for(Product2 product : baseProducts) {
            finalProductIdMap.put(product.Id, product);
            finalProductMap.put(product.Part_Number__c, product);
        }

        Map<String,Object> earlyReturnMap = new Map<String,Object>{
            'sortedProductIds' => new List<String>(),
            'productMap' => finalProductMap,
            'productIdMap' => finalProductIdMap,
            'recommendationsScoreMap' => new Map<String,Decimal>(),
            'sortedRecommendationDetails' => new List<Map<String,Object>>(),
            'recommendationOrders' => new Map<String,Set<String>>(),
            'debugMode' => debugMode,
            'baseProductIds' => productIdentifiers,
            'debugArray' => ''
        };

        Set<String> soldToNumbers = new Set<String>();
        Map<String, Set<String>> baseProductOrders = new Map<String, Set<String>>();

        for (
            SAP_Order_Items__c oi : ECOM_ProductRecommendationsRepo.fetchSAPOrderItemsByDateAndPartNumber(baseProductPartNumbers, startDate, endDate)
        ) {
            String billToCustomerId = oi.PKI_Order_Summary__r.Bill_To_Customer_Id__c;

            if(String.isNotBlank(billToCustomerId)) {
                billToCustomerId = billToCustomerId.replaceFirst('^0+', '');
                if(excludedPayers.contains(billToCustomerId)) { continue; }
            }

            List<String> emails = new List<String>{
                oi.PKI_Order_Summary__r.Contact_Email__c,
                oi.PKI_Order_Summary__r.ShipTo_Email__c
            };

            Boolean skipRecord = false;

            for (String email : emails) {
                if (String.isNotBlank(email)) {
                    Integer atIndex = email.indexOf('@');
                    if (atIndex > -1 && atIndex < email.length() - 1) {
                        String domain = email.substring(atIndex + 1).toUpperCase();
                        if (excludedEmailDomains.contains(domain)) {
                            skipRecord = true;
                            break;
                        }
                    }
                }
            }

            if (skipRecord) { continue; }

            soldToNumbers.add(oi.PKI_Order_Summary__r.Sold_To_Customer_Id__c);

            String orderNumber = oi.PKI_Order_Summary__r.Name;
            if(!baseProductOrders.containsKey(orderNumber)) {
                baseProductOrders.put(orderNumber, new Set<String>{oi.Material_Number__c});
            } else {
                baseProductOrders.get(orderNumber).add(oi.Material_Number__c);
            }
        }

        if(soldToNumbers.isEmpty()) { return earlyReturnMap; }

        List<String> excludedPartNumbers = new List<String>();
        if(configuration.containsKey('excludedPartNumbers')) {
            excludedPartNumbers = (List<String>) configuration.get('excludedPartNumbers');
        } else {
            excludedPartNumbers = baseProductPartNumbers;
        }

        List<AggregateResult> recommendations = [
            SELECT Material_Number__c prodPn, COUNT_DISTINCT(PKI_Order_Summary__r.Name) ct
            FROM SAP_Order_Items__c
            WHERE
                PKI_Order_Summary__r.Sold_To_Customer_Id__c IN :soldToNumbers
                AND Material_Number__c NOT IN :excludedPartNumbers
                AND Material_Number__c != null
                AND PKI_Order_Summary__r.fxStatusB2B__c != 'Cancelled'
                AND PKI_Order_Summary__r.Sold_To_Address_Country__c IN :includedCountries
                AND PKI_Order_Summary__r.Source_Type__c IN :includedOrderTypes
                AND
                (
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c >= :startDate AND
                        PKI_Order_Summary__r.Actual_Order_Date__c <= :endDate
                    )
                    OR
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c = null AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) >= :startDate AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) <= :endDate
                    )
                )
            GROUP BY Material_Number__c
            ORDER BY COUNT_DISTINCT(PKI_Order_Summary__r.Name) DESC, MAX(CreatedDate) DESC
            LIMIT :samplesetSize
        ];

        if(recommendations.isEmpty()) { return earlyReturnMap; }

        List<String> recommendationPartNumbers = new List<String>();
        for (AggregateResult ar : recommendations) {
            recommendationPartNumbers.add((String)ar.get('prodPn'));
        }

        Integer remainingLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();

        List<SAP_Order_Items__c> orderItems = [
            SELECT PKI_Order_Summary__r.Name, Material_Number__c, PKI_Order_Summary__r.CreatedDate, PKI_Order_Summary__r.Actual_Order_Date__c
            FROM SAP_Order_Items__c
            WHERE Material_Number__c IN :recommendationPartNumbers
                AND PKI_Order_Summary__r.Sold_To_Address_Country__c IN :includedCountries
                AND PKI_Order_Summary__r.Source_Type__c IN :includedOrderTypes
                AND PKI_Order_Summary__r.Sold_To_Customer_Id__c IN :soldToNumbers
                AND PKI_Order_Summary__r.fxStatusB2B__c != 'Cancelled'
                AND
                (
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c >= :startDate AND
                        PKI_Order_Summary__r.Actual_Order_Date__c <= :endDate
                    )
                    OR
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c = null AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) >= :startDate AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) <= :endDate
                    )
                )
            ORDER BY PKI_Order_Summary__r.Actual_Order_Date__c DESC, PKI_Order_Summary__r.CreatedDate DESC
            LIMIT :remainingLimit
        ];

        if(orderItems.isEmpty()) { return earlyReturnMap; }

        Decimal sameOrderBoostFactor = sameOrderBoost / 100;

        Map<String, Map<String, Object>> productParameterMap = new Map<String, Map<String, Object>>();
        Long currentTime = ((Datetime) endDate).getTime();

        Map<String, Set<String>> recommendationOrders = new Map<String, Set<String>>();

        for(SAP_Order_Items__c oi : orderItems) {
            String prodIdKey = oi.Material_Number__c;

            Datetime orderDate = oi.PKI_Order_Summary__r.Actual_Order_Date__c;
            if(orderDate == null) {
                orderDate = oi.PKI_Order_Summary__r.CreatedDate;
            }

            Decimal recencyValue =
                Decimal.valueOf(currentTime - orderDate.getTime()) / (1000 * 60 * 60 * 24);

            Decimal exponent = (recencyValue - recencyFactor) / steepnessFactor;
            Decimal score = 1 / (1 + Math.exp(exponent));

            String orderNumber = oi.PKI_Order_Summary__r.Name;

            if(debugMode) {
                if(!recommendationOrders.containsKey(prodIdKey)) {
                    recommendationOrders.put(prodIdKey, new Set<String>());
                }
                recommendationOrders.get(prodIdKey).add(orderNumber);
            }

            Integer sameOrderCount = 0;
            if(baseProductOrders.containsKey(orderNumber)) {
                if(disableMultiProductSOB) {
                    sameOrderCount = 1;
                } else {
                    sameOrderCount = baseProductOrders.get(orderNumber).size();
                }

                score += score * sameOrderBoostFactor * sameOrderCount;
            }

            if(!productParameterMap.containsKey(prodIdKey)) {
                productParameterMap.put(prodIdKey, new Map<String, Object>{
                    'recency' => recencyValue,
                    'count' => 1,
                    'score' => score,
                    'prodId' => prodIdKey,
                    'sameOrderCount' => sameOrderCount
                });
            } else {
                Map<String, Object> existingData = productParameterMap.get(prodIdKey);

                Integer oldCount = (Integer) existingData.get('count');
                Integer newCount = oldCount + 1;
                Decimal newRecency = ((Decimal) existingData.get('recency') * oldCount + recencyValue) / newCount;

                existingData.put('count', newCount);
                existingData.put('recency', newRecency);
                existingData.put('score', (Decimal) existingData.get('score') + score);
                existingData.put('sameOrderCount', (Integer) existingData.get('sameOrderCount') + sameOrderCount);
            }
        }

        List<ECOM_ProductRecommendationsSortWrapper> finalRecommendations = new List<ECOM_ProductRecommendationsSortWrapper>();
        Set<String> uniqueProductIds = new Set<String>();

        for(AggregateResult ar : recommendations) {
            String prodId = (String) ar.get('prodPn');

            if(!productParameterMap.containsKey(prodId)) { continue; }

            uniqueProductIds.add(prodId);
            finalRecommendations.add(new ECOM_ProductRecommendationsSortWrapper(productParameterMap.get(prodId)));
        }

        finalRecommendations.sort();
        List<Product2> finalProducts = ECOM_ProductRepo.getProductsForPartNumbers(uniqueProductIds);

        for(Product2 p : finalProducts) {
            finalProductMap.put(p.Part_Number__c, p);
            finalProductIdMap.put(p.Id, p);
        }

        List<String> sortedProductIds = new List<String>();
        Map<String, Decimal> recommendationsScoreMap = new Map<String, Decimal>();

        List<String> debugArray = new List<String>();
        String basePartNumbersString = String.join(baseProductPartNumbers, ', ');
        List<Map<String,Object>> recommendationDetails = new List<Map<String,Object>>();

        for(Integer i = 0; i < Math.min(maxRecsToReturn, finalRecommendations.size()); i++) {
            ECOM_ProductRecommendationsSortWrapper rec = finalRecommendations[i];

            String prodId = (String) rec.record.get('prodId');
            if(finalProductMap.containsKey(prodId)) {
                String tempId = finalProductMap.get(prodId).Id;
                sortedProductIds.add(tempId);
                recommendationsScoreMap.put(tempId, (Decimal) rec.record.get('score'));
                recommendationDetails.add(rec.record);

                if(debugMode) {
                    debugArray.add(String.join(new List<String>{
                        basePartNumbersString,
                        finalProductMap.get(prodId).Part_Number__c,
                        ((Decimal) rec.record.get('score')).setScale(2).format(),
                        String.valueOf(rec.record.get('sameOrderCount')),
                        String.valueOf(rec.record.get('count'))
                    }, '\t'));
                }

            }
        }

        return new Map<String,Object>{
            'sortedProductIds' => sortedProductIds,
            'productMap' => finalProductMap,
            'productIdMap' => finalProductIdMap,
            'recommendationsScoreMap' => recommendationsScoreMap,
            'sortedRecommendationDetails' => recommendationDetails,
            'recommendationOrders' => recommendationOrders,
            'debugMode' => debugMode,
            'baseProductIds' => productIdentifiers,
            'debugArray' => String.join(debugArray, '\n')
        };
    }
}