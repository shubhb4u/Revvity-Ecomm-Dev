/**************************************************************

* 1. Jira Ticket(s) that relates to this class

*  SFS-4

*

* 2. Description - This class is a test class for FS_WorkOrderController
					- Created seperate test data and test each method functionality by calling the main class.
					- Used System Assertion to Confirm the functionalities.

*

* 3. Objects referenced

*    - Account
*    - Contact
*    - location
*    - asset
*    - Product
*    - Pricebook
*    - PricebookEntry
*    - Service Contract
*    - Contract Line Item
*    - FS_Translation__c
*    - WorkOrder
*    - WorkOrderLineItem

* 4. Callouts to additional Components (including their methods) or None:

*    - None

* 5. Dependant Class(es): None

* 6. Test Class Name:
* 7. Is @Invocable : No

* 8. Author Name(s):

*    - Kaustav Chanda 2025.03.27
*    - Kaustav Chanda 2025.07.28 updated for implementing trnaslation functionality (Source: RITM0200288)
*************************************************************/
@isTest(SeeAllData=false)
public class FS_WorkOrderControllerTest {
    @isTest
    static void testGetWorkOrderData() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(LastName = 'Test Contact', AccountId = account.Id);
        insert contact;

        Schema.Location location = new Schema.Location(Name = 'Test Location', LocationType = 'Building');
        insert location;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = account.Id);
        insert asset;
        
        Product2 pro= New Product2();
        pro.Name='Test Product';
        Insert pro;
        
        Pricebook2 pr = new Pricebook2();
        pr.Name='Test PriceBook';
        pr.IsActive=True;
        Insert pr;

        String prID2 = Test.getStandardPricebookId(); 

        PricebookEntry pre=New PricebookEntry();
        pre.Pricebook2Id=prID2;
        pre.Product2Id=pro.Id;
        pre.UnitPrice=2;
        pre.isActive=true;
        Insert pre;

        ServiceContract contract = new ServiceContract(Name= 'Test Contract', 
                                                       AccountId = account.Id, 
                                                       StartDate = Date.today(), 
                                                       EndDate = Date.today().addYears(1), 
                                                       Active__c = true, 
                                                       SalesOrg__c = 'PH10',
                                                       Pricebook2Id = prID2);
        insert contract;

        ContractLineItem contractLineItem = new ContractLineItem(ServiceContractId = contract.Id,
                                                                 Parent_Contract__c = contract.Id,
                                                                 AssetId = asset.Id, 
                                                                 StartDate = Date.today(), 
                                                                 EndDate = Date.today().addYears(1),
                                                                 Quantity = 1,
                                                                 UnitPrice = 0,
                                                                 PricebookEntryId = pre.Id);
        insert contractLineItem;
        
        FS_Translation__c trRecord = new FS_Translation__c(Name = 'Test transaltion', Logo_Image__c = 'CN');
        insert trRecord;

        WorkOrder workOrder = new WorkOrder(Work_Performed__c = 'Test WorkOrder', ContactId = contact.Id, AssetId = asset.Id, LocationId = location.Id,Translation__c = trRecord.Id ,Record_Type__c = 'Field Service');
        insert workOrder;

        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(WorkOrderId = workOrder.Id, Description = 'Test Line Item', Status = 'Confirmed');
        insert workOrderLineItem;

        // Call the method
        Test.startTest();
        FS_WorkOrderController.WorkOrderData data = FS_WorkOrderController.getWorkOrderData(workOrder.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, data);
        System.assertEquals('Test WorkOrder', data.description);
    }
}