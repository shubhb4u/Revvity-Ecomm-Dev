public with sharing class ECOM_CPQQuoteWithLinesProxyController {
    /**
     * Returns quotes with lines for the current Experience Cloud user’s Account
     * by calling the CPQ REST via Named Credential (Integration User session).
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchMyQuotesWithLines(String quoteId) {
        // Resolve tenant isolation (Contact -> Account)
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (u.ContactId == null) return new List<Map<String, Object>>();
        String contactId = u.ContactId;

        // Build REST endpoint
        String endpoint = '/services/apexrest/cpq/quotesWithLines?contactId='
            + EncodingUtil.urlEncode(contactId, 'UTF-8')
            + '&limit=100&linesLimit=1000';

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:ECOM_B2B_Site_Integration_User_PROD' + endpoint);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res.getBody():::::'+res.getBody());
		List<Map<String, Object>> aDataResultObjectList = new List<Map<String, Object>>();
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            List<Object> dataResults = (List<Object>)JSON.deserializeUntyped(res.getBody());
            
            for (Object o : dataResults) {
                Map<String, object> aDataResultObject = (Map<String,Object>) o;
                
                // Filter logic
                if (quoteId != null) {
                    if (quoteId == String.valueOf(aDataResultObject.get('Id'))) {
                        aDataResultObjectList.add(aDataResultObject);
                        break;
                    }
                } else {
                    aDataResultObjectList.add(aDataResultObject);
                }
            }
            return aDataResultObjectList;

        } else {
            // Optionally log res.getStatus()/Body
            throw new AuraHandledException('Failed to fetch quotes and lines. Please try again later.');
        }
    }

    /**
    * @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
    * @author Shubham Mazumdar Feb 02, 2026 | Added logic to check or create cart if none exists | RWPS-5264
    * @param  communityId The Id of the community from which the call originated
    * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
    * @param activeCartOrId ID of the cart, active, or current.
    */
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(String communityId,String effectiveAccountId,String activeCartOrId) {
        return ECOM_CartController.getCartSummary(communityId, effectiveAccountId, activeCartOrId);
    }

    /**
     * @description Adds quote line items to cart, optionally replacing existing items
     * @author Shubham Mazumdar | Feb 04, 2026 | RWPS-5264
     * @param quoteId ID of the quote to add to cart
     * @param cartId ID of the cart
     * @param replaceExisting Whether to replace existing cart items
     * @return Map<String, Object> with success status and details
     */
    @AuraEnabled
    public static Map<String, Object> addOrReplaceQuoteItemsInCart(
        String quoteId, 
        String cartId, 
        Boolean replaceExisting,
        String communityId
    ) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            // Fetch quote with lines
            List<Map<String, Object>> quotes = fetchMyQuotesWithLines(quoteId);

            if (quotes.isEmpty()) {
                response.put('success', false);
                response.put('message', 'Quote not found');
                return response;
            }
            
            Map<String, Object> quoteData = quotes[0];
            
            // Validate quote status
            // String quoteStatus = String.valueOf(quoteData.get('Status'));
            // if (quoteStatus != 'Approved') {
            //     response.put('success', false);
            //     response.put('message', 'Quote must be approved to add to cart');
            //     return response;
            // }
            
            // Get quote lines
            List<Object> quoteLinesObj = (List<Object>) quoteData.get('Lines');
            System.debug('Quote Lines Object: ' + quoteLinesObj);
            if (quoteLinesObj == null || quoteLinesObj.isEmpty()) {
                response.put('success', false);
                response.put('message', 'Quote has no line items');
                return response;
            }
            
            // Convert to List<Map<String,Object>>
            List<Map<String, Object>> quoteLines = new List<Map<String, Object>>();
            for (Object lineObj : quoteLinesObj) {
                quoteLines.add((Map<String, Object>) lineObj);
            }
            
            // Call CartController to handle the business logic
            response = ECOM_CartService.addQuoteItemsToCart(
                quoteLines, 
                cartId, 
                replaceExisting,
                quoteData,
                communityId
            );
            
        } catch (Exception ex) {
            response.put('success', false);
            response.put('message', ex.getMessage());
            ECOM_ApplicationLogsUtil.logFailure(
                ex, 
                'Quote to Cart', 
                'ECOM_CPQQuoteWithLinesProxyController', 
                'addOrReplaceQuoteItemsInCart', 
                'QuoteId: ' + quoteId + ', CartId: ' + cartId
            );
        }
        
        return response;
    }
}