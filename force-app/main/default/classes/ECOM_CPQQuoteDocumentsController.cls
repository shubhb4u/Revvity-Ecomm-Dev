/**************************************************************
* 1. Jira Ticket(s) that relates to this class :
*    - RWPS-5263
*
* 2. Description :
*    This controller handles CPQ Quote Document–related operations, including:
*       - Fetching Quote Document download details via REST callout
*       - Checking Quote PDF generation status
*       - Returning org base URL for constructing full download paths
*
* 3. Objects referenced :
*    - SBQQ__Quote__c
*    - SBQQ__QuoteDocument__c
*
* 4. Callouts to additional Components (including their methods):
*    - Apex REST API: /services/apexrest/cpq/quoteDocument
*
* 5. Dependant Class(es):
*    - ECOM_CPQQuotesDocumentApi (REST endpoint provider)
*
* 6. Test Class Name:
*    - <Add Test Class Name Here>
*
* 8. Author Name(s):
*    - Devanshi Agrawal
***************************************************************/

public with sharing class ECOM_CPQQuoteDocumentsController{

    
 public class QuoteDocDownloadDto {
        @AuraEnabled public String downloadUrl;
        @AuraEnabled public String documentId;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;
    }


    @AuraEnabled(cacheable=true)
    public static QuoteDocDownloadDto getCPQQuotesDocumentApi(String quoteId) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Missing quoteId');
        }

        String endpoint = '/services/apexrest/cpq/quoteDocument?quoteId=' + EncodingUtil.urlEncode(quoteId, 'UTF-8')+'&checkStatus=false';


        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:ECOM_B2B_Site_Integration_User_PROD' + endpoint);
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return (QuoteDocDownloadDto) JSON.deserialize(res.getBody(), QuoteDocDownloadDto.class);
        }
        throw new AuraHandledException('Failed to download quote document. Please try again later.');
    }

    
    @AuraEnabled(cacheable=true)
    public static QuoteDocDownloadDto getCPQQuoteStatusApi(String quoteId) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Missing quoteId');
        }
        String endpoint = '/services/apexrest/cpq/quoteDocument?quoteId=' + EncodingUtil.urlEncode(quoteId, 'UTF-8')+'&checkStatus=true';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:ECOM_B2B_Site_Integration_User_PROD' + endpoint);
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return (QuoteDocDownloadDto) JSON.deserialize(res.getBody(), QuoteDocDownloadDto.class);
        }
        throw new AuraHandledException('Failed to check quote status. Please try again later.');
    }

    @AuraEnabled(cacheable=true)
    public static String getbaseUrl(){
        String orgBaseUrl = URL.getOrgDomainUrl().toExternalForm();
        return orgBaseUrl;
    }
}