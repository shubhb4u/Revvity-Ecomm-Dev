@isTest
public class Test_Quote_Trigger_Handler {
    @isTest
    static void testUpdateOpportunityStatus() {
        // Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30)
        );
        insert opp;

        // Create a test Quote with required fields
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Primary__c = true,
            ApprovalStatus__c = 'Approved',
            SBQQ__Opportunity2__c = opp.Id
        );
        insert quote;

        // Set a known ApprovalStatus__c value to verify
        quote.ApprovalStatus__c = 'Pending';
        update quote;

        // Call the method under test
        Test.startTest();
        Quote_Trigger_Handler.updateOpportunityStatus(new List<SBQQ__Quote__c>{quote});
        Test.stopTest();

        // Verify the Opportunity's custom field was updated
        Opportunity updatedOpp = [SELECT Id, sbaa__ApprovalStatus__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Pending', updatedOpp.sbaa__ApprovalStatus__c, 'Opportunity approval status should be updated from Quote');
    }
    
  /*  @isTest
    public static void testRollupDiscounts(){
        Id opprtRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Informatics').getRecordTypeId();
        
        List<Product2> productLst = new List<Product2>();
        Product2 product = new Product2(
            Name = 'TestProduct',
            IsActive = true, 
            SBQQ__SubscriptionPricing__c = 'Fixed Price', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__SubscriptionType__c = 'Renewable'
            //License_Type_INF__c = 'Perpetual'
        );
        productLst.add(product);
        
        Product2 prod = new Product2(
            Name = 'TestProduct',
            IsActive = true, 
            SBQQ__SubscriptionPricing__c = 'Fixed Price', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__SubscriptionType__c = 'Renewable'
            //License_Type_INF__c = 'Services'
        );
        productLst.add(prod);
        
        Product2 pro = new Product2(
            Name = 'TestProduct',
            IsActive = true, 
            SBQQ__SubscriptionPricing__c = 'Fixed Price', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__SubscriptionType__c = 'Renewable'
            //License_Type_INF__c = 'Maintenance'
        );
        productLst.add(pro);
        
        Product2 prodt = new Product2(
            Name = 'TestProduct',
            IsActive = true, 
            SBQQ__SubscriptionPricing__c = 'Fixed Price', 
            SBQQ__SubscriptionTerm__c = 12, 
            SBQQ__SubscriptionType__c = 'Renewable'
            //License_Type_INF__c = 'Saas'
        );
        productLst.add(prodt);
        insert productLst;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 120.00,
            IsActive = true
        );
        insert pbEntry;
        
        Account acc= new Account();
        acc.Name='Test Account';
        insert acc;
        
       /* Opportunity opprt = new Opportunity(Name='TestOpprt',AccountId=acc.id,Strategic_Market_INF__c='Life Sciences Research', RecordTypeId = opprtRecTypeId
                                            ,Type='New Products',CloseDate=System.today() + 120,StageName='Stage 6 - Implement (Closed)',Pricebook2Id = Test.getStandardPricebookId(),
                                           Application__c = 'Virology', Application_Market__c = 'Clinical Diagnostics', Application_Segment__c = 'Diagnostics');*/
        
       /* Opportunity opprt = new Opportunity(Name='TestOpprt',AccountId=acc.id, RecordTypeId = opprtRecTypeId
                                            ,Type='New Products',CloseDate=System.today() + 120,StageName='Stage 6 - Implement (Closed)',Pricebook2Id = Test.getStandardPricebookId());
        
        insert opprt;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Quote_Name__c='TestQuote',SBQQ__StartDate__c=System.today() 
                                                  ,SBQQ__Opportunity2__c=opprt.Id,SBQQ__Account__c=acc.Id,
                                                  ApprovalStatus__c = 'Pending',SBQQ__Type__c = 'Renewal');
        insert quote;
        
        List<SBQQ__QuoteLine__C> quoteLineLst = new List<SBQQ__QuoteLine__C>();
         SBQQ__QuoteLine__C quoteline = new SBQQ__QuoteLine__C(
            SBQQ__Product__c = product.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__PricebookEntryId__c = pbEntry.Id,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__Quantity__c = 1,
            SBQQ__StartDate__c = System.today()-1
        );
        quoteLineLst.add(quoteline);
        
        SBQQ__QuoteLine__C quotelne = new SBQQ__QuoteLine__C(
            SBQQ__Product__c = prod.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__PricebookEntryId__c = pbEntry.Id,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__Quantity__c = 1
        );
        quoteLineLst.add(quotelne);
        
        SBQQ__QuoteLine__C quoline = new SBQQ__QuoteLine__C(
            SBQQ__Product__c = pro.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__PricebookEntryId__c = pbEntry.Id,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__Quantity__c = 1
        );
        quoteLineLst.add(quoline);
        
        SBQQ__QuoteLine__C qline = new SBQQ__QuoteLine__C(
            SBQQ__Product__c = prodt.Id,
            SBQQ__Quote__c = quote.Id,
            SBQQ__PricebookEntryId__c = pbEntry.Id,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__Quantity__c = 1
        );
        quoteLineLst.add(qline);

        insert quoteLineLst;
        
        test.startTest();
        quote.ApprovalStatus__c = 'Approved';
        update quote;
        test.stopTest();
    }*/
    
    
}