/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description -UTIL_ChangeFieldSummary this Apex class used to return the field Changes after comparing two sobject
  * 3. Objects referenced
  *    -None
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None 
  *   
  *
  * 5. Dependant Class(es):
  * 6. Invocable: Yes
  *
  * 7. Test Class Name: 
  *
  * 8. Author Name(s): 
  *    - Vishwas 19-01-2025 
  *
*************************************************************/ 
public class UTIL_ChangeFieldSummary {
    @InvocableMethod
    public static List<FlowOutputs> flowcalled(List<FlowInputs> requests) {
        List<FlowOutputs> fOutlist = new List<FlowOutputs>();
        
        if (requests != null && !requests.isEmpty()) {
            for (FlowInputs flowIn : requests) {
                FlowOutputs flowout = new FlowOutputs();
                String summary = '';
                
                // Assuming NewMap and OldMap are single SObject instances
                SObject newRecord = flowIn.NewSobject;
                SObject oldRecord = flowIn.Oldsobject;
                // Get the object Id and its type
                Id objectId = newRecord.Id;
                String sObjName = objectId.getSObjectType().getDescribe().getName();
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();// FS_Utility.getFields(sObjName);

                // Compare fields between the new and old record
                for (String fieldName : fieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldInfo = fieldMap.get(fieldName).getDescribe();

                    // Check if field values have changed
                    if ((newRecord.isSet(fieldName) || oldRecord.isSet(fieldName)) && newRecord.get(fieldName) != oldRecord.get(fieldName)) {
                            
                        summary += '\nChanged ' + fieldInfo.getLabel() + ' from ' + oldRecord.get(fieldName) + ' to ' + newRecord.get(fieldName) + '.';
                    }
                }

                flowout.varString = summary;
                fOutlist.add(flowout);
            }
        }
        return fOutlist;
    }

    public class FlowInputs { 
        @InvocableVariable public SObject NewSobject;
        @InvocableVariable public SObject OldSobject; 
    }

    public class FlowOutputs {         
        @InvocableVariable public String varString;         
    }
}