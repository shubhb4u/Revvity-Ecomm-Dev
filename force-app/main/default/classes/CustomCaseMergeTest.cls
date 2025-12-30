/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    - RWPS-678
* 2. Description 
*    - This Class is use to test CustomCaseMerge
*    
* 3. Objects referenced 
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
* 5. Dependant Class(es):CustomCaseMerge
* 6. Invocable: False
*
* 7. Test Class Name:
*
* 8. Author Name(s): 
*      
*    - 2024.06.04 / RWPS-678 / Sumit Sourav   BASE  
*************************************************************/
@isTest
public class CustomCaseMergeTest {
    private static testMethod void doMerge() {
        Test.startTest();
            Case m = new Case(Subject = 'Master',External_Email_Inbox__c='test@pki.com');
            Case d = new Case(Subject = 'Duplicate',External_Email_Inbox__c='test@pki.com');
            List<Case> caselist=new List<Case>{m,d};
            Insert caselist;
            CustomCaseMerge.Request req=new CustomCaseMerge.Request();
            req.masterRecord=m;
            req.duplicateRecord=d;
            List<CustomCaseMerge.Request> reqlist=new List<CustomCaseMerge.Request>();
            reqlist.add(req);
            CustomCaseMerge.execute(reqlist);
            CustomCaseMerge.Request req2=new CustomCaseMerge.Request();
            req2.masterRecord=m;
            req2.duplicateRecord=m;
            List<CustomCaseMerge.Request> reqlist2=new List<CustomCaseMerge.Request>();
            reqlist2.add(req2);
            CustomCaseMerge.execute(reqlist2);
        Test.stopTest();
    }
}