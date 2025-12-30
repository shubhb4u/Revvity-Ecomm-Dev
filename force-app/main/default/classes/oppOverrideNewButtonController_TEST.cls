/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *    - ITSFDC-####
  *    - ITSFDC-####
  *
  * 2. Description - Put detailed description here of what this class is used for procedurally
  *
  *
  *
  * 3. Objects referenced
  *    -Object Name
  *    -Object Name
  *    -Object Name
  *    -Object Name 
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None
  *    - Component.Method  
  *    - Component.Method
  *
  * 5. Dependant Class(es):
  *    - ClassName
  *    - ClassName
  *    - ClassName
  *
  * 6. Test Class Name: Test_Class_Name
  *
  * 7. Is @Invocable (Yes or No):  No
  *
  * 8. Author Name(s): 
  *    - Amiya Das(PWC)
  *
*************************************************************/ 
@isTest
public class oppOverrideNewButtonController_TEST {
    
    public static testmethod void testcheckInfOppUsrPermisson(){
        
        test.startTest();
      //create test data for user object
  
       Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

       /*Start--User Creation */
        user userRecord = new User();
        userRecord.EmailEncodingKey = 'UTF-8';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.LocaleSidKey = 'en_GB';
        userRecord.Country = 'United Kingdom';
        userRecord.TimeZoneSidKey = 'Europe/London';
        userRecord.FirstName = 'Test FirstName';
        userRecord.LastName = 'Test LastName';
        userRecord.isActive = true;
        userRecord.ProfileId = profileId;
        userRecord.Email = 'test' +
        Math.random().format() +
        String.valueOf(Datetime.now())
          .replace('-', '')
          .replace(':', '')
          .replace(' ', '') +
        'user1@test.org';
        userRecord.UserName = 'test' +
        Math.random().format() +
        String.valueOf(Datetime.now())
          .replace('-', '')
          .replace(':', '')
          .replace(' ', '') +
        'user1@test.org';
        userRecord.Alias = 'testU';
        userRecord.CommunityNickname = ('testU' + Datetime.now().getTime()).left(40);
        insert userRecord;
        //Create Mock permissions
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;

        // Given custom permission associated to the mocked PermissionSet
        SetupEntityAccess sea = new SetupEntityAccess(
                                    ParentId = ps.Id,
                                    SetupEntityId = [SELECT Id FROM CustomPermission
                                    WHERE DeveloperName = 'C_PERM_8040_New_Opp_Legacy'][0].Id
                                    );
        insert sea;
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
                                            AssigneeId = userRecord.id,
                                            PermissionSetId = ps.Id
                                            );
        insert psa;
        system.runAs(userRecord){
            oppOverrideNewButtonController.checkInfOppUsrPermisson(); 
            
        }
        test.stopTest();
    }

}