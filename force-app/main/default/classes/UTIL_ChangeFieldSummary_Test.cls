/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description -test class for UTIL_ChangeFieldSummary
  *  * 3. Objects referenced
  *    -None
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None 
  *   
  *
  * 5. Dependant Class(es):
  * 6. Invocable: Yes
  *
  * 7. Test Class Name: UTIL_ChangeFieldSummary_Test
  *
  * 8. Author Name(s): 
  *    - Vishwas 19-01-2025 
  *
*************************************************************/
@isTest
public class UTIL_ChangeFieldSummary_Test {
   @testSetup static void methodName() {
     Asset cs= new Asset();
       cs.Name='test Subject';
       Insert cs;
     }
    @isTest static void testChangesummary() {
        UTIL_ChangeFieldSummary.FlowInputs varInputClass= new UTIL_ChangeFieldSummary.FlowInputs();
        List<Asset> csList=[SELECT Id,Name From Asset limit 1];
        system.debug('csList'+csList);
        if(csList != null && !csList.isEmpty()){
          varInputClass.NewSobject=csList[0];
          varInputClass.OldSobject=csList[0]; 
        UTIL_ChangeFieldSummary.flowcalled(new list<UTIL_ChangeFieldSummary.FlowInputs>{varInputClass});    
        }
           
        
   }
}