/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    - SSE-43
* 2. Description 
*    - This Class takes two parameter current Case(Duplicate Case) and Existing Case (Master case)
*      and merges duplicate case in Master case.
* 3. Objects referenced 
*    - Case
* 4. Callouts to additional Components (including their methods) or None:
*    - None
* 5. Dependant Class(es):
* 6. Invocable: True
*
* 7. Test Class Name: CustomCaseMergeTest
*
* 8. Author Name(s): 
*      
*    - 2024.05.31 / SSE-43 / Sumit Sourav   BASE  
*************************************************************/
Public class CustomCaseMerge {
    @InvocableMethod(
        label = 'CustomCaseMerge'
        description = 'This method takes two parameters Master Case and Duplicate Case. Duplicate Case gets merged in the Master Case. Using the Apex merge operation, field values on the master record always supersede the corresponding field values on the records to be merged. To preserve a merged record field value, simply set this field value on the master sObject before performing the merge. '
    )
    public static void execute( List<Request> requests ) {
        if(requests.size()>0) {
            for(Request req:requests) {
                if(req!=null && !System.isFuture() && !System.isBatch()) {
                    System.debug('Master Record Id / Name '+req.masterRecord.Id+' / '+req.masterRecord.CaseNumber);
                    System.debug('Duplicate Record Id / Name '+req.duplicateRecord.Id+' / '+req.duplicateRecord.CaseNumber);
                    List<Id> CaseIdList=new List<Id>{req.masterRecord.Id,req.duplicateRecord.Id};
                    List<Case> MasterCaseList=[Select Id from Case where Id=:req.masterRecord.Id];
                    List<Case> DuplicateCaseList=[Select Id from Case where Id=:req.duplicateRecord.Id];
                    
                    If(MasterCaseList.Size()>0 && DuplicateCaseList.Size()>0) {
                        Database.MergeResult results= Database.merge(MasterCaseList[0],DuplicateCaseList[0], False);
                        String mergedIdString;
                        String errMsg;
                        String stepMsg;
                        String message;
                        If(results.getMergedRecordIds()!=null && !results.getMergedRecordIds().isEmpty()) {
                            mergedIdString = string.join(results.getMergedRecordIds(),',');  
                        }
                        If(results.getErrors()!=null && !results.getErrors().isEmpty()) {
                            errMsg=string.join(results.getErrors(),','); 
                        }
                        if(results.IsSuccess()) {
                            message='APEX CASE MERGE SUCCESS:Master Case Id is- '+results.getId()+' and Duplicate Case Id is- '+mergedIdString;
                            stepMsg='APEX CASE MERGE SUCCESS: '+req.duplicateRecord.CaseNumber+' --> '+req.masterRecord.CaseNumber;
                        }
                        else {
                            message='APEX CASE MERGE FAILED:'+errMsg;
                            stepMsg='APEX CASE MERGE FAILED: '+req.duplicateRecord.CaseNumber+' --> '+req.masterRecord.CaseNumber;
                        }
                        //Inserting Log for Case Merge Status.
                        SFDC_LOG__c log=new SFDC_LOG__c();
                        If(message.length()>255) {
                            log.Message_Long__c=message;
                            log.Message__c=message.substring(0, 254);
                        } else {
                            log.Message__c=message;
                        }
                        log.Source_Name__c='L.FLOW_2402: Case - After - (General)/CustomCaseMerge';
                        log.Source_Type__c='APEX';
                        log.Running_User__c=UserInfo.getUserName();
                        log.Source_Step__c=stepMsg;
                        insert log;
                        System.debug('Case merged successfully');
                    }
                }
            }
        }
    }
    Public class Request {
        @InvocableVariable(
            label = 'Master Record'
            description = 'After merge happens Duplicate Case gets merged in the Master Case.'
            required = false
        )
        public Case masterRecord;
        @InvocableVariable(
            label = 'Duplicate Record'
            description = 'Duplicate Case gets merged in the Master Case.'
            required = false
        )
        public Case duplicateRecord;
    }
}