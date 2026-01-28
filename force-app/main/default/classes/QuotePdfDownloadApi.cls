public without sharing class QuotePdfDownloadApi {

    public class DownloadResult {
        @AuraEnabled public String downloadUrl;  
        @AuraEnabled public String attachmentId;
        @AuraEnabled public String message;
    }

    @AuraEnabled(cacheable=true)
    public static String getbaseUrl(){
        String orgBaseUrl = URL.getOrgDomainUrl().toExternalForm();
        System.debug('Org Base URL: ' + orgBaseUrl);
        return orgBaseUrl;
    }

   
    @AuraEnabled(cacheable=true)
    public static Boolean getStatus(Id quoteId) {
        if (quoteId == null) {
            return false;
        }
        try {
            SBQQ__Quote__c qd = [
                SELECT SBQQ__Status__c
                FROM SBQQ__Quote__c
                WHERE Id = :quoteId
                LIMIT 1
            ];

            String status = qd.SBQQ__Status__c;
            if (String.isBlank(status)) {
                return false;
            }

            status = status.trim();
            Set<String> showStatuses = new Set<String>{ 'Draft', 'Active' };

            for (String s : showStatuses) {
                if (status.equalsIgnoreCase(s)) {
                    return true;
                }
            }
            return false;
        } catch (QueryException qe) {
            return false;
        } catch (Exception e) {
            return false;
        }
    }


    @AuraEnabled(cacheable=true)
    public static DownloadResult getQuotePdfDownloadUrl(String quoteId) {
        DownloadResult res = new DownloadResult();

        if (String.isBlank(quoteId)) {
            res.message = 'Quote Id is required.';
            return res;
        }

        try {
            SBQQ__QuoteDocument__c qd = [
                SELECT Id, SBQQ__AttachmentId__c, SBQQ__DocumentId__c
                FROM SBQQ__QuoteDocument__c
                WHERE SBQQ__Quote__c = :quoteId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (qd.SBQQ__AttachmentId__c == null) {
                res.message = 'No Attachment found on the latest Quote Document.';
                return res;
            }

            res.attachmentId = qd.SBQQ__DocumentId__c;
            res.downloadUrl  = '/servlet/servlet.FileDownload?file=' + String.valueOf(qd.SBQQ__DocumentId__c);
            res.message      = 'Success';
            return res;


        } catch (QueryException qe) {
            res.message = 'No Quote Document found for the given Quote.' + quoteId + 'and attachment id ' +res.attachmentId;
            return res;
        } catch (Exception e) {
            res.message = 'Unexpected error: ' + e.getMessage();
            return res;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkPdf(Id quoteId) {
        if (quoteId == null) {
            return false;
        }
        try {
            SBQQ__QuoteDocument__c qd = [
                SELECT Id, SBQQ__AttachmentId__c, SBQQ__DocumentId__c
                FROM SBQQ__QuoteDocument__c
                WHERE SBQQ__Quote__c = :quoteId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (qd.SBQQ__DocumentId__c == null) {
                return false;
            }else{
                return true;
            }
        } catch (QueryException qe) {
            return false;
        } catch (Exception e) {
            return false;
        }
    }
}