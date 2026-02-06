/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a utility class to be called from flow to generate 
*                   a response for getting active and expired quotes.
*
* 3. Objects referenced
*    - Document
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    
*
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s):
*    - Tushar Arora | 26 Jan 2026
*************************************************************/
public class ECOM_QuoteUtil {

    public class Request{
        @InvocableVariable(required = true)
        public String varContactId;
        @InvocableVariable
        public String varQuoteId;
        @InvocableVariable
        public String varQuoteWorkflowType;
    }
    
     //this class is to accept Quote With Lines API reponse
    public class Response{
        @InvocableVariable
        public List<ECOM_QuoteWrapper> responseJSONList;
    }

    /**
    * @description  - method is used to prepare wish list API response 
    * @author Tushar 26.01.2026
    * @param quoteList
    * @return ECOM_QuoteWithLinesFlowResponseWrapper.QuoteWithLinesWrapper
    **/
    @InvocableMethod(Label='Get Active And Expired Quote With Lines' Category='Quotes API' Description='This is to retrieve Active and Expired Quote')
    public static List<Response> getActiveAndExpiredQuoteWithLinesList(List<Request> requestList){
        List<Response> quoteWithLinesFlowWrapperResponseList = new List<Response>();
        Response quoteWithLinesFlowWrapperResponse = new Response();
        List<ECOM_QuoteWrapper> quoteWithLinesWrapperList= new List<ECOM_QuoteWrapper>();
        //ECOM_QuoteWithLinesFlowResponseWrapper.QuoteWithLinesWrapper quoteWithLinesWrapper = new ECOM_QuoteWithLinesFlowResponseWrapper.QuoteWithLinesWrapperECOM_QuoteWithLinesFlowResponseWrapper();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        if(requestList[0].varQuoteWorkflowType == ECOM_Constant.QUOTE_WITH_LINES && !String.isBlank(requestList[0].varContactId)){
            quoteList = ECOM_QuoteRepo.fetchQuotesForLoggedInCustomer(requestList[0].varContactId);
        }
        // --- Query quotes (curated fields) ---
        Date today = Date.today();
        Date twelveMonthsAgo = today.addMonths(-12);
        Set<String> quoteIds = new Set<String>();
        for(SBQQ__Quote__c quote:quoteList){
            if((quote.SBQQ__PrimaryContact__r.Email != null && quote.SAPQuoteID__c != null && 
            ((quote.SBQQ__Primary__c == true && quote.SBQQ__ExpirationDate__c >= today) || 
            (quote.SBQQ__Primary__c == false && quote.SBQQ__ExpirationDate__c >= today) ||
            (quote.SBQQ__Primary__c == true && quote.SBQQ__ExpirationDate__c < today   && 
            quote.SBQQ__ExpirationDate__c >= today)))){
                quoteIds.add(quote.Id);
            }
        }

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        lines = ECOM_QuoteRepo.fetchQuoteLines (quoteIds);
        Map<Id, List<ECOM_QuoteLineWrapper>> quoteIdToQuoteLineWrapperList = new Map<Id, List<ECOM_QuoteLineWrapper>>();
        for (SBQQ__QuoteLine__c quoteline : lines) {
            Id quoteId = quoteline.SBQQ__Quote__c;
            List<ECOM_QuoteLineWrapper> quoteLineWrapperList = quoteIdToQuoteLineWrapperList.get(quoteId);
            if (quoteLineWrapperList == null) {
                quoteLineWrapperList = new List<ECOM_QuoteLineWrapper>();
                quoteIdToQuoteLineWrapperList.put(quoteId, quoteLineWrapperList);
            }
            quoteLineWrapperList.add(new ECOM_QuoteLineWrapper(quoteline));
        }

        for (SBQQ__Quote__c quote : quoteList) {
            ECOM_QuoteWrapper quoteWithLinesWrapper = new ECOM_QuoteWrapper(quote);
            quoteWithLinesWrapper.Lines = quoteIdToQuoteLineWrapperList.get(quote.Id);
            if (quoteWithLinesWrapper.Lines == null) quoteWithLinesWrapper.Lines = new List<ECOM_QuoteLineWrapper>();
            quoteWithLinesWrapperList.add(quoteWithLinesWrapper);
        }

        if(quoteWithLinesWrapperList.size() > 0){
            //System.debug('quoteWithLinesFlowWrapperResponse::::'+JSON.serialize(quoteWithLinesWrapperList));
            quoteWithLinesFlowWrapperResponse.responseJSONList = quoteWithLinesWrapperList;
        }
        System.debug('quoteWithLinesFlowWrapperResponse::::'+quoteWithLinesFlowWrapperResponse);
        return new List<Response>{quoteWithLinesFlowWrapperResponse};
    }
}