/**************************************************************
* 1. Jira Ticket(s) that relates to this class
     
*
* 2. Description - Processes FS_WorkOrder_Event__e and returns TxnId
*
*
*
* 3. Objects referenced
*    -WorkOrderLineItem, FS_WorkOrder_Event__e
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
     - None
*
* 6. Test Class Name: WorkOrderEventProcessorTest
*
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s):
*    - SS 2025.05.14 INC0467088, INC0466796, INC0466997
*************************************************************/
public class WorkOrderEventProcessor {
 
    public class WorkOrderEventWrapper {
        @InvocableVariable(required=true)
        public String workOrderId;
    }
    public class ResponseWrapper {
        @InvocableVariable
        public String TranscationId;
    }
    @InvocableMethod(label='Process Work Order Event' description='Processes FS_WorkOrder_Event__e and returns TxnId')
    public static List<ResponseWrapper> processEvents(List<WorkOrderEventWrapper> WOevents) {
        ResponseWrapper res = new ResponseWrapper();
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        List<FS_WorkOrder_Event__e> events = new List<FS_WorkOrder_Event__e>();
        String txnId = String.valueOf(Datetime.now().formatGmt('yyyy-MM-dd HH:mm:ss.SSS'));
        for (WorkOrderEventWrapper event : WOevents) {
            FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
            iEvent.Action__c = 'CANCEL';
            iEvent.SubmitTxnId__c = txnId;
            iEvent.WorkOrderId__c = event.workOrderId;
            events.add(iEvent);
        }
        FS_PlatformEventUtility.publishEvents(events, 'WorkOrderId__c', 'Action__c');
        res.TranscationId=txnId;
        responses.add(res);
        return responses;
        
    }

}