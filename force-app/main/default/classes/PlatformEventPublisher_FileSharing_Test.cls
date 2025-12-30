/**************************************************************
* 1. Jira Ticket(s) that relates to this class
     
*
* 2. Description - This class helps in Publishing FileSharing__e Event.
*
*
*
* 3. Objects referenced
*    -FileSharing__e
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
     - None
*
* 6. Test Class Name:
*
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s):
*    - SS 2025-01-02
*************************************************************/
@isTest
public class PlatformEventPublisher_FileSharing_Test {
    @isTest static void testMethod1() {
        test.startTest();
		Case c=new Case();
        c.subject='FileSharing';
        insert c;
        List<String> cidlist=new List<String>();
        cidlist.add(c.Id);
        PlatformEventPublisher_FileSharing.publishEvent(cidlist);
        test.stopTest();
     }

}