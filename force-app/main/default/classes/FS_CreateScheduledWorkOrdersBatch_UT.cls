/*
 * 2025-06-26 SFS Team(Kaustav Chanda) Updated test class for increasing the coverage.
*/
@isTest(SeeAllData=false)
public class FS_CreateScheduledWorkOrdersBatch_UT {

    @TestSetup
	public static void setupTestData() {
		FS_TestDataFactory.createDefaultOperatingHours();
        String erpId = 'TESTXYZ0000001';
		//create account
        Account acct = FS_TestDataFactory.createTestErpAccount('RevvityTest', 999, erpId, 'GB');
		Contact cont = FS_TestDataFactory.createTestContact('Contact', 'Test', acct, 'TESTXYZ000001A');
		Product2 pd = FS_TestDataFactory.createTestProduct('TestProduct1', 'PRXYZ106','ZZZ');
        
        OperatingHours testOh = new OperatingHours();
        testOh.Name = 'TestOperatingHours';
        insert testOh;
        
        //create serviceterritory
        ServiceTerritory testST = FS_TestDataFactory.createTestGeography('LOC123',testOh);

        //create location
        Schema.Location loc = FS_TestDataFactory.createTestLocation(acct,'TestLocation', 'TESTXYZ121234','LOC123');

        Asset testAsset = FS_TestDataFactory.createIP('1234567',acct,loc,'5545333',pd);
		testAsset.External_ID__c = 'TESTXYZ00001I';
		update testAsset;
        
        Date testDate = System.today();
        Date stDate = System.today().addDays(-30);
        Date contractEndDate = System.today().addDays(90);
        Date plannedDate = System.today();
        
        //Data for Success Conditions
        //create contract
        ServiceContract testSC = FS_TestDataFactory.createSvcMaintContract('SC-00111111112',acct.Id,stDate,contractEndDate,'PH10');
        //create contract item
        ServiceContract testSCItem = FS_TestDataFactory.createContractItem(testSC,'SC-00111111112-000010',stDate,contractEndDate,pd);
        //create contract line item
        ContractLineItem testContLineItem = FS_TestDataFactory.createCoveredIP(testSCItem,stDate,contractEndDate,testAsset);
        //create entitlement
        Entitlement testEntitlement = FS_TestDataFactory.createEntitlement(testSCItem,'PM',1,2);
        //create entitlement date
        FS_EntitlementDate__c ed = FS_TestDataFactory.createEntitlementDate(testContLineItem,testEntitlement,plannedDate);
        //System.debug('ed:'+ed);
        List<FS_EntitlementDate__c> resED = [SELECT Id, Name, PlannedDate__c, EntitlementCondition__c FROM FS_EntitlementDate__c WHERE ServiceOrderNumber__c = NULL AND SAP_Notification_ID__c = NULL AND WorkOrder__c = NULL AND PlannedDate__c < :System.today().addDays(60) AND IsDeleted__c = FALSE AND ContractItem__r.ParentServiceContract.SalesOrg__c='PH10' AND ContractItem__r.ParentServiceContractId = :testSC.Id AND ContractItem__c = :testSCItem.Id];
        //system.debug('resEd:'+resED);
	}


    @isTest
    public static void testSuccessBatchWithContract(){
        ServiceContract parentContract = [SELECT Id,SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112' LIMIT 1];
        ServiceContract contractItem = [SELECT Id,ParentServiceContract.SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112-000010' LIMIT 1];
        Date endDate = System.today().addDays(90);
        Test.startTest();
        FS_CreateScheduledWorkOrdersBatch batchinstance = new FS_CreateScheduledWorkOrdersBatch(contractItem.Id, parentContract.Id, 60); 
        database.executeBatch (batchinstance);
        Test.stopTest();
    }
    
    @isTest
    public static void testSuccessBatch(){
        Date stDate = System.today().addDays(-30);
        Test.startTest();
        FS_CreateScheduledWorkOrdersBatch batchinstance = new FS_CreateScheduledWorkOrdersBatch(stDate, 60, null); 
        database.executeBatch (batchinstance);
        Test.stopTest();
    }
    @isTest
    public static void testScheduler(){
        FS_CreateScheduledWorkOrdersBatch scheduler = new FS_CreateScheduledWorkOrdersBatch();
        scheduler.START_DATE = System.today();
        scheduler.NUM_DAYS_OUT = 10;
        scheduler.SALES_ORGS = new Set<String>{'PH10'};

        // Mocking the SchedulableContext
        Test.startTest();
        scheduler.execute(null); // null is acceptable in test context
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchWithErrorOne(){
        ServiceContract parentContract = [SELECT Id,Name,SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112' LIMIT 1];
        ServiceContract contractItem = [SELECT Id,Name,ParentServiceContract.SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112-000010' LIMIT 1];
        ContractLineItem contractLineItem = [SELECT Id, ServiceContractId FROM ContractLineItem WHERE ServiceContractId = :contractItem.Id LIMIT 1];

        Date stDate = System.today().addDays(-30);
        Date contractEndDate = System.today().addDays(90);
        Date plannedDate = System.today();
       //create entitlement
        Entitlement testEntitlement2 = FS_TestDataFactory.createEntitlement(parentContract,'PM',1,2);
        //create entitlement date
        FS_EntitlementDate__c ed2 = FS_TestDataFactory.createEntitlementDate(contractLineItem,testEntitlement2,plannedDate);
        Test.startTest();
        FS_CreateScheduledWorkOrdersBatch batchinstance = new FS_CreateScheduledWorkOrdersBatch(stDate, 60, null); 
        database.executeBatch (batchinstance);
        Test.stopTest();
    }
    @isTest
    public static void testBatchWithErrorTwo(){
        ServiceContract parentContract = [SELECT Id,Name,SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112' LIMIT 1];
        ServiceContract contractItem = [SELECT Id,Name,ParentServiceContract.SalesOrg__c FROM ServiceContract WHERE Name='SC-00111111112-000010' LIMIT 1];
        ContractLineItem contractLineItem = [SELECT Id, ServiceContractId FROM ContractLineItem WHERE ServiceContractId = :contractItem.Id LIMIT 1];
        
        Date stDate = System.today().addDays(-30);
        Date contractEndDate = System.today().addDays(90);
        Date plannedDate = System.today();
        
         //create entitlement
        Entitlement testEntitlement = FS_TestDataFactory.createEntitlement(parentContract,null,1,2);
        testEntitlement.EntitlementTypeName__c = null;
        update testEntitlement;
        //create entitlement date
        FS_EntitlementDate__c ed = FS_TestDataFactory.createEntitlementDate(contractLineItem,testEntitlement,plannedDate);
        
        Test.startTest();
        FS_CreateScheduledWorkOrdersBatch batchinstance = new FS_CreateScheduledWorkOrdersBatch(stDate, 60, null); 
        database.executeBatch (batchinstance);
        Test.stopTest();
    }
}