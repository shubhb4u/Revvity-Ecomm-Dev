public with sharing class ECOM_QuoteWithLinesFlowWrapper {
     //this class is to accept Quote With Lines API request
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
        public String responseJSON;
    }
}