/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description -UTIL_SerializeSobject this Apex class used to serialize sobject and return stirng of it
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
  * 7. Test Class Name:UTIL_SerializeSobject_Test 
  *
  * 8. Author Name(s): 
  *    - Vishwas 04-02-2025 
  *
*************************************************************/ 
public class UTIL_SerializeSobject {
 @InvocableMethod
    public static List<FlowOutputs> flowcalled(List<FlowInputs> requests) {
        List<FlowOutputs> fOutlist = new List<FlowOutputs>();
        
        if (requests != null && !requests.isEmpty()) {
            for (FlowInputs flowIn : requests) {
                FlowOutputs flowout = new FlowOutputs();
                String summary = '';
                if(flowIn.NewSobject != null){
                flowout.varString=JSON.serialize(flowIn.NewSobject);
                  fOutlist.add(flowout);  
                }    
            }
        }
        return fOutlist;
    }
        public class FlowInputs { 
        @InvocableVariable public SObject NewSobject;
    }
        public class FlowOutputs {         
        @InvocableVariable public String varString;         
    }
}