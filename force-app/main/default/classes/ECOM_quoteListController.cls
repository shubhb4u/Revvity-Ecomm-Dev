public without sharing class ECOM_quoteListController {

    @AuraEnabled(cacheable=true)
    public static List<SBQQ__Quote__c> getQuotes(){

        try {
            String contactEmail = UserInfo.getUserEmail();
            return [SELECT Id, Name, SBQQ__ExpirationDate__c,SBQQ__Primary__c, SBQQ__NetAmount__c, SBQQ__LineItemCount__c, SBQQ__Status__c, CreatedDate FROM SBQQ__Quote__c where SBQQ__Opportunity2__r.fxPrimaryContactEmail__c = :contactEmail ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}