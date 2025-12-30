public class Quote_Trigger_Handler {

    public static Boolean isExecuted = false;

    public static void updateOpportunityStatus(List<SBQQ__Quote__c> quotes){
        List<ID> oppIds = new List<ID>();
        for(SBQQ__Quote__c o:quotes){
            if(o.SBQQ__Primary__c==true && o.ApprovalStatus__c!=null && o.SBQQ__Opportunity2__c!=null){
                oppIds.add(o.SBQQ__Opportunity2__c);
            }
        }

        List<Opportunity> lstOpps = [Select Id,sbaa__ApprovalStatus__c FROM Opportunity WHERE Id=:oppIds];
        Map<ID,Opportunity> mapIO = new Map<ID,Opportunity>();
        for(Opportunity o: lstOpps){mapIO.put(o.Id,o);}
        for(SBQQ__Quote__c o:quotes){
            if(o.SBQQ__Primary__c==true && o.ApprovalStatus__c!=null && o.SBQQ__Opportunity2__c!=null){
                Opportunity T = mapIO.get(o.SBQQ__Opportunity2__c);
                T.sbaa__ApprovalStatus__c = o.ApprovalStatus__c;
            }
        }

        if(lstOpps.size()>0){
            update lstOpps;
        }
    }

   /* public static void rollingUpDiscounts(List<SBQQ__Quote__c> lstNewQuotes, Map<Id,SBQQ__Quote__c> mapOldQuotes){ 
        Set<Id> setofQuoteId = new Set<Id>();
        List<SBQQ__QuoteLine__c> listofQuoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id, Date> mapofQuoteIdToStartDate = new Map<Id, Date>();
        Map<Id, Decimal> mapofQuoteIdToLicenseDisc = new Map<Id, Decimal>();
        Map<Id, Decimal> mapofQuoteIdToCloudDisc = new Map<Id, Decimal>();
        Map<Id, Decimal> mapofQuoteIdToServiceDisc = new Map<Id, Decimal>();
        Map<Id, Decimal> mapofQuoteIdToMaintainDisc = new Map<Id, Decimal>();

        
        for(SBQQ__Quote__c iQuote : lstNewQuotes){
            setofQuoteId.add(iQuote.Id);
        }
        if(setofQuoteId.size() > 0){
            for(SBQQ__QuoteLine__c iQuoteLine : [SELECT Id,Name, SBQQ__AdditionalDiscount__c, CPQ_License_Type__c, SBQQ__Quote__r.SBQQ__CustomerDiscount__c, SBQQ__StartDate__c, SBQQ__EndDate__c,
                                                 SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c, SBQQ__Quote__r.ApprovalStatus__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.DeveloperName 
                                                 FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: setofQuoteId]){
                if(iQuoteLine.SBQQ__AdditionalDiscount__c != null){
                    //Service Discount
                    if(iQuoteLine.CPQ_License_Type__c == 'Perpetual' || iQuoteLine.CPQ_License_Type__c == 'Term' || iQuoteLine.CPQ_License_Type__c == 'Subscription'){                        
                        if(mapofQuoteIdToLicenseDisc.containskey(iQuoteLine.SBQQ__Quote__c)){
                            mapofQuoteIdToLicenseDisc.put(iQuoteLine.SBQQ__Quote__c,mapofQuoteIdToLicenseDisc.get(iQuoteLine.SBQQ__Quote__c) + iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }else{
                            mapofQuoteIdToLicenseDisc.put(iQuoteLine.SBQQ__Quote__c,iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }
                    } 
                    //Cloud Discount
                    else if(iQuoteLine.CPQ_License_Type__c == 'Saas' || iQuoteLine.CPQ_License_Type__c == 'Paas'){
                        if(mapofQuoteIdToCloudDisc.containskey(iQuoteLine.SBQQ__Quote__c)){
                            mapofQuoteIdToCloudDisc.put(iQuoteLine.SBQQ__Quote__c,mapofQuoteIdToCloudDisc.get(iQuoteLine.SBQQ__Quote__c)+ iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }else{
                            mapofQuoteIdToCloudDisc.put(iQuoteLine.SBQQ__Quote__c,iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }
                    } 
                    //Service Discount
                    else if(iQuoteLine.CPQ_License_Type__c == 'Services' || iQuoteLine.CPQ_License_Type__c == 'Training'){
                        if(mapofQuoteIdToServiceDisc.containskey(iQuoteLine.SBQQ__Quote__c)){
                            mapofQuoteIdToServiceDisc.put(iQuoteLine.SBQQ__Quote__c,mapofQuoteIdToServiceDisc.get(iQuoteLine.SBQQ__Quote__c) + iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }else{
                            mapofQuoteIdToServiceDisc.put(iQuoteLine.SBQQ__Quote__c,iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }
                    } 
                    //Maintaneance Discount
                    else if(iQuoteLine.CPQ_License_Type__c == 'Maintenance' || iQuoteLine.CPQ_License_Type__c == 'Term Maintenance' || iQuoteLine.CPQ_License_Type__c == 'Perpetual Maintenance'){
                        if(mapofQuoteIdToMaintainDisc.containskey(iQuoteLine.SBQQ__Quote__c)){
                            mapofQuoteIdToMaintainDisc.put(iQuoteLine.SBQQ__Quote__c,mapofQuoteIdToMaintainDisc.get(iQuoteLine.SBQQ__Quote__c) + iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }else{
                            mapofQuoteIdToMaintainDisc.put(iQuoteLine.SBQQ__Quote__c,iQuoteLine.SBQQ__AdditionalDiscount__c);
                        }
                    }
                }
                //Start Date Mismatch
                if(iQuoteLine.SBQQ__Quote__r.ApprovalStatus__c == 'Approved' && iQuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.DeveloperName == 'Informatics'){
                    if(iQuoteLine.SBQQ__StartDate__c < iQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c){
                        mapofQuoteIdToStartDate.put(iQuoteLine.SBQQ__Quote__c, iQuoteLine.SBQQ__StartDate__c);
                    }
                    if(iQuoteLine.SBQQ__StartDate__c == null){
                        iQuoteLine.SBQQ__StartDate__c = iQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c;
                        listofQuoteLinesToUpdate.add(iQuoteLine);
                    }
                }
            }
        }
            
        for(SBQQ__Quote__c iQuote : lstNewQuotes){
            if(mapofQuoteIdToLicenseDisc != null && mapofQuoteIdToLicenseDisc.containsKey(iQuote.Id)){
                iQuote.CPQ_License_Discount__c = mapofQuoteIdToLicenseDisc.get(iQuote.Id);
            } else {
                iQuote.CPQ_License_Discount__c = 0;
            }
            if(mapofQuoteIdToCloudDisc != null && mapofQuoteIdToCloudDisc.containsKey(iQuote.Id)){
                iQuote.CPQ_Cloud_Discount__c = mapofQuoteIdToCloudDisc.get(iQuote.Id);
            } else {
                iQuote.CPQ_Cloud_Discount__c = 0;
            }
            if(mapofQuoteIdToServiceDisc != null && mapofQuoteIdToServiceDisc.containsKey(iQuote.Id)){
                iQuote.CPQ_Services_Discount__c = mapofQuoteIdToServiceDisc.get(iQuote.Id);
            } else {
                iQuote.CPQ_Services_Discount__c = 0;
            }
            if(mapofQuoteIdToMaintainDisc != null && mapofQuoteIdToMaintainDisc.containsKey(iQuote.Id)){
                iQuote.CPQ_Maintenance_Discount__c = mapofQuoteIdToMaintainDisc.get(iQuote.Id);
            } else {
                iQuote.CPQ_Maintenance_Discount__c = 0;
            }
            if(mapofQuoteIdToStartDate != null && mapofQuoteIdToStartDate.containsKey(iQuote.Id)){
                iQuote.SBQQ__StartDate__c = mapofQuoteIdToStartDate.get(iQuote.Id);
            }
        }
        if(listofQuoteLinesToUpdate.size() > 0){
            update listofQuoteLinesToUpdate;
        }
    } */

    /*public static void autoPopulateRequiredBy(list<SBQQ__Quote__c> quotes){
        
        Map<String, String> quoteLineBySubscription = new Map<String, String>();
        Map<String, String> requiredByQuoteLine = new Map<String, String>();
        Map<String, SBQQ__QuoteLine__c> quoteLineById = new Map<String, SBQQ__QuoteLine__c>();
        Map<Id, Date> ealiestStartDateByQuoteId = new Map<Id, Date>();

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__EffectiveStartDate__c, SBQQ__Discount__c, SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c, SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__AdditionalDiscountAmount__c, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Discount__c, SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE  SBQQ__Quote__c IN: quotes AND SBQQ__Quote__r.SBQQ__Type__c='Renewal'];
        system.debug('@@quoteLines- '+quoteLines);

        if(!quoteLines.isEmpty()){
            For(SBQQ__QuoteLine__c quoteLine:quoteLines){
                if(quoteLine.SBQQ__RenewedSubscription__c != null){
                    if(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null){
                        quoteLineBySubscription.put(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                    }
                    quoteLineById.put(quoteLine.Id, quoteLine);
                }            
    
                //Here we are preparing the map to get the earliest start date for quote
                if(ealiestStartDateByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)){
                    Date quoteStartDate = ealiestStartDateByQuoteId.get(quoteLine.SBQQ__Quote__c);
                    if(quoteLine.SBQQ__EffectiveStartDate__c < quoteStartDate){
                        ealiestStartDateByQuoteId.put(quoteLine.SBQQ__Quote__c, quoteLine.SBQQ__EffectiveStartDate__c);
                    }
                } else {
                    ealiestStartDateByQuoteId.put(quoteLine.SBQQ__Quote__c, quoteLine.SBQQ__EffectiveStartDate__c);
                }
            }
            
            For(SBQQ__QuoteLine__c quoteLine:quoteLines){
                if(quoteLineBySubscription.containsKey(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c)){
                    requiredByQuoteLine.put(quoteLineBySubscription.get(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c),quoteLine.Id);
                }
            }
    
            system.debug('@@quoteLineBySubscription- '+quoteLineBySubscription);
            Set<Id> quoteLineIds = new Set<Id>();
            For(SBQQ__QuoteLine__c quoteLine:quoteLines){
                if(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && requiredByQuoteLine.containsKey(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                    system.debug('@@QuoteLineId= '+quoteLine.Id);
                    system.debug('@@output= '+requiredByQuoteLine.get(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c));
                    quoteLine.SBQQ__RequiredBy__c = requiredByQuoteLine.get(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                    if(quoteline.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__AdditionalDiscountAmount__c == null){
                        quoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                    } else if(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Discount__c == null){
                        quoteLine.SBQQ__Discount__c = null;
                    }
                    quoteLinesToUpdate.add(quoteLine);
                    //Adding quoteline id to set of quote line ids to prevent duplicate entries.
                    quoteLineIds.add(requiredByQuoteLine.get(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c));                
                }
            }
    
            if(!quoteLinesToUpdate.isEmpty()){
                update quoteLinesToUpdate;
            }
        }
        
        system.debug('@@ealiestStartDateByQuoteId= '+ealiestStartDateByQuoteId);
        //Here we are setting earliest start date for quote
        for(SBQQ__Quote__c quoteRecord : quotes){
            Date quoteStartDate = ealiestStartDateByQuoteId.get(quoteRecord.Id);

            quoteRecord.Earliest_Start_Date__c = quoteStartDate;
            if(quoteStartDate == null || quoteRecord.SBQQ__StartDate__c < quoteStartDate){
                quoteRecord.Earliest_Start_Date__c = quoteRecord.SBQQ__StartDate__c;
            } 
        }   
    }*/
}