/**************************************************************
  * 1. Jira Ticket(s) that relates to this class(ers_FlowDatatableDescriptor)
  *   SSE-112
  *
  * 2. Description -Test class for ers_FlowDatatableDescriptor
  *
  * 3. Test Class Name: ers_FlowDatatableDescriptor_test
  *
  * 4. Author Name(s): 
  *    - Karthik Kumar Dabbiru 2025.02.04
  *    - First Last & Updated Date(YYYY.MM.DD)
 
*************************************************************/
@istest
public class ers_FlowDatatableDescriptor_test {
    static testmethod void myTestMethod(){
        String data = '2019-01-03T00:26:01.711-02:00';
		Datetime dt = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
	//String fieldValue = dt.format();
        ers_FlowDatatableDescriptor ersCons = new ers_FlowDatatableDescriptor(
            'String DurableId',
            'String Description',
            'String FlowDefinitionViewId',
            true,
            'String Label',
            dt,
            'String ProcessType',
            'String Status',
            2,
            'String ApiName',
            'String LastModifiedBy',
            'String TriggerType',
            'String WorkflowObject',
           ' String FlowTypeIcon',
            'String FlowStatusIcon',
           ' String RowShadeValue',
            'String Label_name',
            'String Label_lookup'
        ); 
        
	}
}