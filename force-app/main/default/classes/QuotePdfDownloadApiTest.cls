/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : QuotePdfDownloadApiTest
 * Author          : <YourName>
 * Created Date    : Jan 19, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Jan 19, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jan 19, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */


@IsTest(SeeAllData=false)
private class QuotePdfDownloadApiTest {

    @testSetup
    static void setup() {
        // ---- Core CRM data ----
        Account acc = new Account(Name = 'Acme Corp');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // ---- Quotes for each branch ----
        SBQQ__Quote__c qSuccess = new SBQQ__Quote__c();
        insert qSuccess;

        SBQQ__Quote__c qNoDoc = new SBQQ__Quote__c(
            
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp.Id
        );
        insert qNoDoc;

        SBQQ__Quote__c qNoAttachment = new SBQQ__Quote__c(
            
            SBQQ__Account__c = acc.Id,
            SBQQ__Opportunity2__c = opp.Id
        );
        insert qNoAttachment;

        // ---- Create two classic Documents so we get real 015* Ids ----
        // If your org has Files-only: see the note below for ContentVersion alternative.
        // Folder fold = new Folder(
        //     Name = 'Test Docs',
        //     DeveloperName = 'Test_Docs',
        //     AccessType = 'Public',
        //     Type = 'Document'
        // );
        // insert fold;

        Document doc1 = new Document(
            Name = 'Doc1',
            
            IsPublic = true,
            Body = Blob.valueOf('file-1')
        );
        insert doc1;

        Document doc2 = new Document(
            Name = 'Doc2',
            
            IsPublic = true,
            Body = Blob.valueOf('file-2')
        );
        insert doc2;

        // ---- QuoteDocument for "No Attachment" branch ----
        SBQQ__QuoteDocument__c qdNoAtt = new SBQQ__QuoteDocument__c(
            SBQQ__Quote__c = qNoAttachment.Id,
            SBQQ__DocumentId__c = doc1.Id,
            SBQQ__AttachmentId__c = null
        );
        insert qdNoAtt;

        // ---- Two QuoteDocuments for Success branch to test "latest" pick ----
        SBQQ__QuoteDocument__c qdOld = new SBQQ__QuoteDocument__c(
            SBQQ__Quote__c = qSuccess.Id,
            SBQQ__DocumentId__c = doc1.Id,
            SBQQ__AttachmentId__c = doc1.Id // Non-null to pass attachment check
        );
        insert qdOld;

        SBQQ__QuoteDocument__c qdLatest = new SBQQ__QuoteDocument__c(
            SBQQ__Quote__c = qSuccess.Id,
            SBQQ__DocumentId__c = doc2.Id,
            SBQQ__AttachmentId__c = doc2.Id // Non-null to pass attachment check
        );
        insert qdLatest;

        // Make ordering deterministic for ORDER BY CreatedDate DESC
        Test.setCreatedDate(qdOld.Id,  System.now().addDays(-1));
        Test.setCreatedDate(qdLatest.Id, System.now());
    }

    @IsTest
    static void test_BlankQuoteId_ReturnsRequiredMessage() {
        Test.startTest();
        QuotePdfDownloadApi.DownloadResult resNull = QuotePdfDownloadApi.getQuotePdfDownloadUrl(null);
        QuotePdfDownloadApi.DownloadResult resEmpty = QuotePdfDownloadApi.getQuotePdfDownloadUrl('');
        Test.stopTest();

        System.assertEquals('Quote Id is required.', resNull.message, 'Null input should return required message.');
        System.assertEquals(null, resNull.downloadUrl);
        System.assertEquals(null, resNull.attachmentId);

        System.assertEquals('Quote Id is required.', resEmpty.message, 'Empty input should return required message.');
        System.assertEquals(null, resEmpty.downloadUrl);
        System.assertEquals(null, resEmpty.attachmentId);
    }

    @IsTest
    static void test_NoQuoteDocumentFound_ReturnsHandledMessage() {
        SBQQ__Quote__c qNoDoc = [
            SELECT Id FROM SBQQ__Quote__c WHERE Name = 'Q-NoDoc' LIMIT 1
        ];

        Test.startTest();
        QuotePdfDownloadApi.DownloadResult res = QuotePdfDownloadApi.getQuotePdfDownloadUrl(qNoDoc.Id);
        Test.stopTest();

        System.assert(
            res.message.startsWith('No Quote Document found for the given Quote.'),
            'Should inform that no Quote Document exists.'
        );
        System.assert(res.message.contains(qNoDoc.Id), 'Message should include the Quote Id.');
        System.assertEquals(null, res.downloadUrl, 'URL must not be set when no document is found.');
        System.assertEquals(null, res.attachmentId, 'AttachmentId must be null when no document is found.');
    }

    @IsTest
    static void test_LatestQuoteDocumentHasNoAttachment_ReturnsHandledMessage() {
        SBQQ__Quote__c qNoAttachment = [
            SELECT Id FROM SBQQ__Quote__c WHERE Name = 'Q-NoAttachment' LIMIT 1
        ];

        Test.startTest();
        QuotePdfDownloadApi.DownloadResult res = QuotePdfDownloadApi.getQuotePdfDownloadUrl(qNoAttachment.Id);
        Test.stopTest();

        System.assertEquals(
            'No Attachment found on the latest Quote Document.',
            res.message,
            'Should indicate missing attachment on latest quote document.'
        );
        System.assertEquals(null, res.downloadUrl, 'URL must be null if attachment is missing.');
        System.assertEquals(null, res.attachmentId, 'AttachmentId must be null if attachment is missing.');
    }

    @IsTest
    static void test_Success_ReturnsLatestDocumentUrl() {
        SBQQ__Quote__c qSuccess = [
            SELECT Id FROM SBQQ__Quote__c WHERE Name = 'Q-Success' LIMIT 1
        ];
        // Latest document we created is Doc2
        Document latestDoc = [SELECT Id FROM Document WHERE Name = 'Doc2' LIMIT 1];

        Test.startTest();
        QuotePdfDownloadApi.DownloadResult res = QuotePdfDownloadApi.getQuotePdfDownloadUrl(qSuccess.Id);
        Test.stopTest();

        System.assertEquals('Success', res.message, 'Message should be Success on happy path.');
        // Note: the implementation puts DocumentId into "attachmentId"
        System.assertEquals(latestDoc.Id, res.attachmentId, 'attachmentId (per current impl) equals DocumentId of latest QD.');
        System.assertEquals(
            '/servlet/servlet.FileDownload?file=' + latestDoc.Id,
            res.downloadUrl,
            'Download URL should be constructed using the latest DocumentId.'
        );
    }
}