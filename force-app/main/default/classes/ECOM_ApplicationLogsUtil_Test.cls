/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*  
*
* 2. Description - This is a test class for ECOM_ApplicationLogsUtil
*
* 3. Objects referenced
*    - ECOM_ApplicationUtil

* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
* 	 - ECOM_TestUtil
*
* 6. Test Class Name:
*
* 7. Is @Invocable : No
*
* 8. Author Name(s):
*    - Vasudev R 08 Dec 2023
*    - Vipul Goyal 22 Jan 2024
*************************************************************/
@isTest
public class ECOM_ApplicationLogsUtil_Test {
    
    //custom exception class, since native exception cannot be thrown
    public class ECOM_ApplicationLogsUtilException extends Exception{}
    
    //Reused static String values
    private static final String CLASS_NAME = 'ECOM_ApplicationLogsUtil_Test';
    private static final String METHOD_NAME = 'TestAllMethods';
    private static final String MODULE_NAME = 'Test ECOM_ApplicationLogs';
    private static final String RESPONSE = 'RESPONSE';
    private static final String SUPPORT_DATA = 'suppport data';    
    private static final String ACTION_TYPE = 'action';
    
    
    //Setup data. insert new exception logs
    @testSetup
    static void testSetup(){
        ECOM_TestUtil.createPOSRPOOMData();
    }
    
    
    //test method for logFailure() method
    @isTest
    static void testLogFailure(){
        Test.startTest();
        try{
            throw new ECOM_ApplicationLogsUtilException();
        }catch(Exception e){
            ECOM_ApplicationLogsUtil.logFailure(e, MODULE_NAME, CLASS_NAME, METHOD_NAME, SUPPORT_DATA);
        }
       
        ECOM_ApplicationLogsUtil.logFailure(null, MODULE_NAME, CLASS_NAME, METHOD_NAME, SUPPORT_DATA);

        Test.stopTest();
        
    }

    
    //test method for setupApplicationRecord() method
    @isTest
    static void testSetupApplicationRecord(){
        ECOM_Application_Logs__c exc;
        Test.startTest();
        try{
            throw new ECOM_ApplicationLogsUtilException();
        }catch(Exception e){
            exc= ECOM_ApplicationLogsUtil.setupApplicationRecord(MODULE_NAME , CLASS_NAME , METHOD_NAME,SUPPORT_DATA,RESPONSE, ACTION_TYPE);
        }
        Test.stopTest();
        Assert.isInstanceOfType(exc, ECOM_Application_Logs__c.class);
    }
    
    //test method for getMappedList() method
    @isTest
    static void testGetMappedList(){
        List<String> logTypes = System.Label.ECOM_LogTypes.split(',');
		List<ECOM_Application_Logs__c> logs = ECOM_ApplicationLogsRepo.getLatestApplicationLogsForLogTypes(logTypes);
        Test.startTest();
        List<ECOM_ApplicationLogsWrapper> wrapperList = ECOM_ApplicationLogsUtil.getMappedList(logs);
        Test.stopTest();
        Assert.isNotNull(wrapperList,'Expected a non-empty/not null list');
        
    }
    
    @isTest
    static void testLogFailureWithCustomError() {
        Test.startTest();
        ECOM_ApplicationLogsUtil.logApplicationDataWithCustomException('Test','ECOM_ApplicationLogsUtil_Test','testLogFailureWithCustomError','Support Data','Test','Test Error');
        Test.stopTest();

       
        ECOM_Application_Logs__c[] logRecords = [SELECT Id,ModuleName__c FROM ECOM_Application_Logs__c WHERE ModuleName__c='Test' ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(1, logRecords.size());
    }
    
    @isTest
    static void testLogApplicationApiData() {
        Test.startTest();
        ECOM_ApplicationLogsUtil.logApplicationApiData('Test','ECOM_ApplicationLogsUtil_Test','logApplicationApiData','Support Data','Test');
        Test.stopTest();

        ECOM_Application_Logs__c[] logRecords = [SELECT Id,ModuleName__c FROM ECOM_Application_Logs__c WHERE ModuleName__c='Test' ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(1, logRecords.size());
    }
    
    @isTest
    static void testSetupApplicationRecord1() {
        Test.startTest();
        ECOM_ApplicationLogsUtil.setupApplicationRecord('Test','ECOM_ApplicationLogsUtil_Test','setupApplicationRecord','Support Data','Test','Test Error');
        Test.stopTest();

        ECOM_Application_Logs__c[] logRecords = [SELECT Id FROM ECOM_Application_Logs__c];
    }
    
}