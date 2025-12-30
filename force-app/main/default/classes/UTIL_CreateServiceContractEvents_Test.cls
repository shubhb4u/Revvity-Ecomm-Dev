/*************************************************************************
* 1. Jira Ticket(s) that relates to this class
*
* 2. Description - Test class for UTIL_CreateServiceContractEvents
* 3. Objects referenced
*    - None
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
* 5. Dependant Class(es):
* 6. Invocable: False
*
* 7. Test Class Name: 
*
* 8. Author Name(s): 
*    - Aakash 12-03-2025
*
*************************************************************************/
@isTest
public class UTIL_CreateServiceContractEvents_Test {
    
    @isTest static void testServiceContractEvents() {
        //test product
        Test.startTest();
        Product2 testProduct= New Product2();
        testProduct.Name='Test Product';
        Insert testProduct;
        
        //test standard PriceBook
        String stdPriceBook = Test.getStandardPricebookId();
        
        //test PriceBookEntry
        PricebookEntry testPBE=New PricebookEntry();
        testPBE.Pricebook2Id=stdPriceBook;
        testPBE.Product2Id=testProduct.Id;
        testPBE.UnitPrice=2;
        testPBE.isActive=true;
        Insert testPBE;
        
        //test Service Contract
        ServiceContract testContract = new ServiceContract(
            Name = 'Test Contract',
            External_ID__c = 'Ext123',
            Active__c = true,
            Pricebook2Id=stdPriceBook
        );
        insert testContract;
        
        //test Service Contract 2
        ServiceContract testContract2 = new ServiceContract(
            Name = 'Test Contract2',
            External_ID__c = 'Ext1234',
            Active__c = true,
            ParentServiceContractId=testContract.Id,
            Pricebook2Id=stdPriceBook
        );
        insert testContract2;
        
        //test Asset
        Asset testAsset = new Asset();
        insert testAsset;
        
        //test Contract Line Item
        ContractLineItem testCLI = new ContractLineItem(
            LastTxnNum__c ='tran1',
            ServiceContractId=testContract.Id,
            AssetId = testAsset.Id,
            Quantity=1,
            UnitPrice=20,
            StartDate=Date.today(),
            EndDate=Date.today(),
            PricebookEntryId=testPBE.Id,
            Parent_Contract__c = testContract.Id,
            SLA_Terms_Notes__c = 'Testing');
        insert testCLI;
        
        //test Account
        Account testAccount = new Account();
        testAccount.Name = 'test accountname';
        insert testAccount;
        
        //test Entitlement
        Entitlement testEntitlement = new Entitlement(Name = 'test',AccountId=testAccount.Id,LastTxnNum__c ='tran1');
        insert testEntitlement;
        //testEntitlement.ServiceContractId=testContract.Id;
        //update testEntitlement; 
        
        //test Entitlement Date
        FS_EntitlementDate__c testEntitlementDate = new FS_EntitlementDate__c(
            LastTxnNum__c ='tran1',
            Entitlement__c=testEntitlement.Id,
            CoveredProduct__c=testCLI.Id,
            ContractItem__c = testContract2.Id,
            PlannedDate__c = Date.today());
        insert testEntitlementDate;
        
        UTIL_CreateServiceContractEvents.FlowInputs varInputClass= new UTIL_CreateServiceContractEvents.FlowInputs();
        varInputClass.varSingleContract=testContract;
        UTIL_CreateServiceContractEvents.flowcalled(new list<UTIL_CreateServiceContractEvents.FlowInputs>{varInputClass});
        Test.stopTest();
    }
}