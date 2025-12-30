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
* 6. Test Class Name: PlatformEventPublisher_FileSharing_Test
*
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s):
*    - SS 2025-01-02
*************************************************************/
public class PlatformEventPublisher_FileSharing {
    @InvocableMethod(label='Publish Platform Event - File Sharing' description='Publish a platform event called FileSharing')
    public static void publishEvent(List<String> CaseId) {
        FileSharing__e event = new FileSharing__e();
        event.caseId__c = CaseId[0];
        EventBus.publish(event);
    }
}