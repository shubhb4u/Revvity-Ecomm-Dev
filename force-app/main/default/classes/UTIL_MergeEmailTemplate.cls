/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description -Utillity class for Merging email template and give output body content and subject
  * 3. Objects referenced
  *    -EmailTemplate
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None
  *   
  *
  * 5. Dependant Class(es):
  * 6. Invocable: True
  *
  * 7. Test Class Name: UTIL_MergeEmailTemplate_Test
  *
  * 8. Author Name(s): 
  *    - Vishwas 12-03-2025
  *
*************************************************************/ 
public class UTIL_MergeEmailTemplate {
     @InvocableMethod
    public static List<FlowOutputs> flowcalled(List<FlowInputs> requests) {
        List<FlowOutputs> fOutlist = new List<FlowOutputs>();
        
        if (requests != null && !requests.isEmpty()) {
            for(FlowInputs req:requests){
                FlowOutputs output= new FlowOutputs();
                String WhoId=req.whoId != '' ? req.whoId : Null;
                String WhatId=req.whatId != '' ? req.whatId : Null;
             Messaging.SingleEmailMessage Email=Messaging.renderStoredEmailTemplate(req.templateId, WhoId, WhatId);
            output.HTMLBody=String.valueof(Email.getHtmlBody());
            output.TextBody=String.valueof(Email.getPlainTextBody());
            output.Subject=String.valueof(Email.getSubject());    
              fOutlist.add(output);  
            }
        }
	    return fOutlist;
        
    }
    
        public class FlowInputs { 
        @InvocableVariable(required=true) public String templateId;
        @InvocableVariable public String whoId;
        @InvocableVariable public String whatId;    
    }
        public class FlowOutputs {         
        @InvocableVariable public String HTMLBody;
        @InvocableVariable public String TextBody;
        @InvocableVariable public String Subject;    
    }
}