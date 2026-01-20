public without sharing class ECOM_quoteListController {

    @AuraEnabled(cacheable=true)
    public static List<SBQQ__Quote__c> getQuotes(){

        try {
            String contactEmail = UserInfo.getUserEmail();
            Date today = Date.today();
            Date twelveMonthsAgo = today.addMonths(-12);

            return [SELECT Id, Name, SBQQ__ExpirationDate__c,SBQQ__Primary__c, SBQQ__NetAmount__c, SBQQ__LineItemCount__c, SBQQ__Status__c, CreatedDate FROM SBQQ__Quote__c where 
            SBQQ__PrimaryContact__c != null AND 
            SBQQ__PrimaryContact__r.Email = :contactEmail
            AND 
            (
                (
                    SBQQ__Primary__c = true
                    AND SBQQ__ExpirationDate__c >= :today
                    AND SAPQuoteID__c != null
                )
            )
            OR
            (
                SBQQ__Primary__c = false
                AND SBQQ__ExpirationDate__c >= :today
                AND Publish_To_Site__c = true
                AND SAPQuoteID__c != null
            )
            OR
            (
                AND SBQQ__Primary__c = true
                AND SBQQ__ExpirationDate__c < :today
                AND SBQQ__ExpirationDate__c >= :twelveMonthsAgo
                AND SAPQuoteID__c != null
            )
        ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static SBQQ__Quote__c getQuoteById(String quoteId) {
        try {
            return [
                SELECT Id, Name, SBQQ__ExpirationDate__c, SBQQ__Primary__c, 
                       SBQQ__NetAmount__c, SBQQ__LineItemCount__c, SBQQ__Status__c, 
                       CreatedDate 
                FROM SBQQ__Quote__c 
                WHERE Id = :quoteId 
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}