/**************************************************************
* 1. Jira Ticket(s) that relates to this class - RWPS-5263

* 2. Description - This REST API exposes operations for retrieving CPQ Quote Document details. It provides:
*       - Latest Quote Document lookup for a given Quote Id
*       - Status-only check to verify if a Quote PDF exists
*       - Download URL generation for the Quote PDF

* 3. Objects referenced
*    - Cpq Quote
     - Quote Document

* 4. Callouts to additional Components (including their methods) or None:
*    - None (acts as the REST provider)

* 5. Dependant Class(es):
*    - ECOM_CPQQuoteDocumentsController (consumer class)

* 6. Test Class Name:
*    - 

* 8. Author Name(s):
*    - Devanshi Agrawal
*************************************************************/

@RestResource(urlMapping='/cpq/quoteDocument')
global with sharing class ECOM_CPQQuotesDocumentApi {
 
    global class QuoteDocDownloadDto {
        public String downloadUrl;
        public String documentId;
        public String message;
        public Boolean success;
    }
 
    @HttpGet
    global static QuoteDocDownloadDto getQuoteDocument() {
        RestRequest req = RestContext.request;
        QuoteDocDownloadDto res = new QuoteDocDownloadDto();
 
        String quoteId = req.params.get('quoteId');
        String checkStatus = req.params.get('checkStatus');
        Boolean statusOnly = checkStatus != null && checkStatus.equalsIgnoreCase('true');
 
        if (String.isBlank(quoteId)) {
            res.success = false;
            res.message = 'Missing quoteId';
            return res;
        }
 
        // Quote Document
        List<SBQQ__QuoteDocument__c> qd = [
            SELECT SBQQ__DocumentId__c
            FROM SBQQ__QuoteDocument__c
            WHERE SBQQ__Quote__c = :quoteId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        Boolean hasPdf = !qd.isEmpty() && !String.isBlank(qd[0].SBQQ__DocumentId__c);
 
        // ---- Status-only mode ----
        if (statusOnly) {
            res.success = (hasPdf);
            return res;
        }
 
        if (!hasPdf) {
            res.success = false;
            res.message = 'No PDF found for this quote.';
            return res;
        }
 
        String fileId = qd[0].SBQQ__DocumentId__c;
        res.documentId = fileId;
        res.downloadUrl = '/servlet/servlet.FileDownload?file=' + EncodingUtil.urlEncode(fileId, 'UTF-8');
        res.message = 'Success';
        res.success = true;
        return res;
    }
}