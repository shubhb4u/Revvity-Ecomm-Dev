/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a utility class to be called from flow to generate 
*                   a response for downloading quote pdf.
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
public class ECOM_QuoteDocumentUtil {
    //this class is to accept Quote With Lines API request
    public class Request{
        @InvocableVariable
        public String varDocumentId;

    }
    
     //this class is to accept Quote With Lines API reponse
    public class Response{
        @InvocableVariable
        public ECOM_QuoteDocumentFlowResponseWrapper responseJSON;
    }

    /**
    * @description  - method is used to prepare wish list API response 
    * @author Tushar 26.01.2026
    * @param requestList
    * @return ECOM_QuoteWithLinesFlowResponseWrapper.QuoteWithLinesWrapper
    **/
    @InvocableMethod(Label='Get Quote Document PDF Details' Description='This is to retrieve Quote Document PDF')
    public static List<Response> getQuoteDocumentPdf(List<Request> requestList){
        Response quoteDocumentUtilResponse = new Response();
        Document documentObj = ECOM_QuoteRepo.fetchDocumentDetail(requestList[0].varDocumentId);
        if(!String.isBlank(documentObj.Name) && !String.isBlank(documentObj.ContentType) && documentObj.Body != null){
            ECOM_QuoteDocumentFlowResponseWrapper quoteDocFlowResponseWrapper = new ECOM_QuoteDocumentFlowResponseWrapper();
            quoteDocFlowResponseWrapper.fileName = documentObj.Name;
            quoteDocFlowResponseWrapper.contentType = documentObj.ContentType;
            quoteDocFlowResponseWrapper.quoteDocumentBody = EncodingUtil.base64Encode(documentObj.Body);
            quoteDocumentUtilResponse.responseJSON = quoteDocFlowResponseWrapper;
        }
        return new List<Response>{quoteDocumentUtilResponse};
    }
}