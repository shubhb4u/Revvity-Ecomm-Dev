/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a repository class for Querying Quote,Quote Lines 
*   as well as Document Records
*
* 3. Objects referenced
*    - SBQQ__Quote__c,SBQQ__QuoteLine__c,Document
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    
*
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - Tushar Arora | 26 Jan 2026
*************************************************************/
public without sharing class ECOM_QuoteRepo {
    /**
    * @description This method is used to Quotes for logged-in Customer
    * @author Tushar Arora| 26-01-2025 
    * @param contactId
    **/
    public static List<SBQQ__Quote__c> fetchQuotesForLoggedInCustomer(String contactId){
        List<SBQQ__Quote__c> quoteList =    [SELECT Id, Name, SBQQ__ExpirationDate__c, SBQQ__Primary__c, SBQQ__NetAmount__c, 
                                            SBQQ__LineItemCount__c, SBQQ__Status__c, CreatedDate, fxFreightDisplayedAmount__c, 
                                            TotalTax__c, fxGrand_Total__c, Total_Discount__c, Country_List_Price_Total__c, 
                                            SBQQ__Opportunity2__r.Sold_To_ERP_Address__r.fxAddressFull__c, 
                                            SBQQ__Opportunity2__r.Payer_ERP_Address__r.fxAddressFull__c,
                                            SBQQ__Quote__c.SBQQ__PrimaryContact__r.Email, SAPQuoteID__c
                                            FROM SBQQ__Quote__c
                                            WHERE SBQQ__PrimaryContact__c = :contactId];
        return quoteList;
    }

    /**
    * @description This method is used to Quotes lines for Quotes
    * @author Tushar Arora| 26-01-2025 
    * @param quoteIds
    **/
    public static List<SBQQ__QuoteLine__c> fetchQuoteLines(Set<String> quoteIds){
        List<SBQQ__QuoteLine__c> lines =    [SELECT Id, Name, SBQQ__Quote__c, SBQQ__Product__r.Name, SBQQ__Product__r.Part_Number__c,
                                            SBQQ__Product__r.Description, SBQQ__Quantity__c, SBQQ__ListPrice__c, Net_Price__c,
                                            SBQQ__NetPrice__c, SBQQ__NetTotal__c, SBQQ__Optional__c, SBQQ__Discount__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE SBQQ__Quote__c IN :quoteIds
                                            ORDER BY SBQQ__Quote__c, CreatedDate ASC
                                            ];
        return lines;
    }

    /**
    * @description This method is used to Quotes lines for Quotes
    * @author Tushar Arora| 26-01-2025 
    * @param quoteIds
    **/
    public static Document fetchDocumentDetail(String documentId){
        Document DocumentObj =    [SELECT Id, Name, ContentType, BodyLength, Body
                                             FROM Document
                                             WHERE Id =: documentId 
                                            ];
        return DocumentObj;
    }

    /**
    * @description This method is used to Quotes lines for Quotes
    * @author Tushar Arora| 26-01-2025 
    * @param quoteIds
    **/
    public static String fetchContactIdOfLoggedInUser(Id userId){
        User userObj =    [SELECT Id, contactId
                                             FROM User
                                             WHERE Id =: userId
                                            ];
        return String.valueof(userObj.contactId);
    }
}