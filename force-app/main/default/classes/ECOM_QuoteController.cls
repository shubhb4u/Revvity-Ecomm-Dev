/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a controller which will be called from the Quote List 
*                   page as well Quote Detail Page
*
* 3. Objects referenced
*    - NA
*
* 4. Callouts to additional Components (including their methods) or None:
*    - ECOM_QuoteService.quoteWithLinesOperations - Method
*    - ECOM_QuoteService.quoteDocumentPdfOperations - Method
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
public with sharing class ECOM_QuoteController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchMyQuotesWithLines(Id userId){
        //Id currentLoggedInUserId = UserInfo.getUserId();
        //String contactId = ECOM_QuoteRepo.fetchContactIdOfLoggedInUser();
        String contactId = ECOM_QuoteRepo.fetchContactIdOfLoggedInUser(userId);
        System.debug('contactId::::'+contactId);
        Map<String, String> requestQuoteMap = new Map<String, String>();
        requestQuoteMap.put('varContactId', contactId);
        requestQuoteMap.put('varQuoteWorkflowType', ECOM_Constant.QUOTE_WITH_LINES);
        List<Map<String, Object>> responseWrapperList = new List<Map<String, Object>>();
        responseWrapperList = ECOM_QuoteService.quoteWithLinesOperations(requestQuoteMap);
        return responseWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchQuoteDocumentPdf(Map<String,String> requestQuoteMap){
        Map<String, Object> responseWrapperList = new Map<String, Object>();
        responseWrapperList = ECOM_QuoteService.quoteDocumentPdfOperations(requestQuoteMap);
        return responseWrapperList;
    }
}