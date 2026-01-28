public with sharing class ECOM_fetchQuoteDetails {

    @AuraEnabled(cacheable=true)
    public static SBQQ__Quote__c  fetchQuoteDetails(String quoteId){
        SBQQ__Quote__c rows =[SELECT id, Quote_Name__c, Address__c, CreatedDate FROM SBQQ__Quote__c 
            WHERE Id = :quoteId
        ];
        return rows;
    }
}