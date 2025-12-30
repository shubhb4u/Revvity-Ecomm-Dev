/**************************************************************
* 1. Jira Ticket(s) that relates to this class
     
*
* 2. Description - It tests the class WorkOrderEventProcessor
*
*
*
* 3. Objects referenced
*    -WorkOrder, FS_WorkOrder_Event__e
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
     - None
*
* 6. Test Class Name: none
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - SS 2025.05.14 INC0467088, INC0466796, INC0466997
*************************************************************/
@isTest
public class WorkOrderEventProcessorTest {
    @isTest
    static void testProcessEvents() {
        
        WorkOrder wo = new WorkOrder();
        wo.CurrencyIsoCode='INR';
        wo.Record_Type__c='Estimate';
        insert wo;
        // Create input wrapper
        WorkOrderEventProcessor.WorkOrderEventWrapper input = new WorkOrderEventProcessor.WorkOrderEventWrapper();
        input.workOrderId = wo.id; // Sample WorkOrder ID

        List<WorkOrderEventProcessor.WorkOrderEventWrapper> inputList = new List<WorkOrderEventProcessor.WorkOrderEventWrapper>{ input };

        // Call the method
        Test.startTest();
        List<WorkOrderEventProcessor.ResponseWrapper> responseList = WorkOrderEventProcessor.processEvents(inputList);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, responseList, 'Response list should not be null');
        System.assertEquals(1, responseList.size(), 'Response list should contain one item');
        System.assertNotEquals(null, responseList[0].TranscationId, 'Transaction ID should not be null');
    }

}