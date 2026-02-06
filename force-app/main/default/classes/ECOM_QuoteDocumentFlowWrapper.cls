public class ECOM_QuoteDocumentFlowWrapper {
    //this class is to accept Quote With Lines API request
    public class Request{
        @InvocableVariable
        public String varFileName;
        @InvocableVariable
        public String varContentType;
        @InvocableVariable
        public String quoteDocumentPdf;

    }
    
     //this class is to accept Quote With Lines API reponse
    public class Response{
        @InvocableVariable
        public String responseJSON;
    }
}