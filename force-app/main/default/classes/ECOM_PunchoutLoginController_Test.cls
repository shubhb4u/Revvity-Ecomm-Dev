/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*  ECOM-1028
*
* 2. Description - Test class for ECOM_PunchoutLoginController
*
* 3. Objects referenced
*    - WebStore
*    - Account
*    - Network
*    - CartItem

* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
*    - ECOM_TestUtil
*  	 - ECOM_PunchoutLoginController

* 6. Test Class Name:
*
* 7. Is @Invocable : No
*
* 8. Author Name(s):
*    - Vasudev 2023.09.19
*/
@isTest
public class ECOM_PunchoutLoginController_Test {
    
        private final static String PASSWORD_CHARSET_ALPHABETS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    private final static String PASSWORD_CHARSET_NUMERIC = '0123456789';
    private final static String PASSWORD_CHARSET_ALPHANUMERIC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    private static final String CLASS_NAME = 'ECOM_PunchoutLoginController_Test';
    private static final String METHOD_NAME = 'TestAllMethods';
    private static final String MODULE_NAME = 'Test ECOM_ApplicationLogs';
    private static final String RESPONSE = 'RESPONSE';
    private static final String SUPPORT_DATA = 'suppport data';    
    
    public class ECOM_ApplicationLogsUtilException extends Exception{}

/*
* @description this method is used to create test data.
*/
    @TestSetup
    public static void testData(){
        //ECOM_TestUtil.testDataIntialSetup();
        //ECOM_TestUtil.initialStorefrontSetup();
        ECOM_TestUtil.createPunchoutLoginData();
        // RWPS-3528 - Start
        ERP_Address__c master = [SELECT Id,ECOM_Punchout_Default_Payer__c FROM ERP_Address__c where Address_Type__c='Master' LIMIT 1];
        ERP_Address__c payer = [SELECT Id, Target_Address__c,Target_Address__r.External_Id__c FROM ERP_Address__c where Address_Type__c='Payer' AND Master_Address__c=:master.Id LIMIT 1];
        master.ECOM_Punchout_Default_Payer__c = payer.Target_Address__r.External_Id__c;
        update master;
        // RWPS-3528 - End
    }
    
    //Test Method to test punchoutLogin() Method
    
    /*@isTest
    static void testpunchoutLogin() {
       User usr= [Select Id from User ORDER BY CREATEDDATE DESC LIMIT 1];
        Account testAcc= [Select Id from Account ORDER BY CREATEDDATE DESC LIMIT 1];
        Contact testCon= [Select Id from Contact ORDER BY CREATEDDATE DESC LIMIT 1];
        ERP_Address__c testErp= [Select Id,Master_Address__c,ECOM_Review_Status__c from ERP_Address__c WHERE Address_Type__c='Payer' ORDER BY CREATEDDATE DESC LIMIT 1];
        
        ERP_Address__c testErp2= [Select Id,Account__c,Master_Address__c,ECOM_isEnabled__c,Address_Type__c,Address_City__c,Address_Street_Line_1__c,apiCountry__c,apiState__c,Address_Postal_Code__c,ECOM_Review_Status__c,fxIsECOMenabled__c,ECOM_Punchout_Is_Enabled__c,ECOM_Punchout_Customer_Id__c from ERP_Address__c WHERE Id=:testErp.Master_Address__c ORDER BY CREATEDDATE DESC LIMIT 1];
        
        //erpAddress.ECOM_Punchout_Is_Enabled__c=true;
        ERP_Address__c testErpApproved=ECOM_TestUtil.createNewApprovedAddress(testErp2,'Ship To');
        testErpApproved.Account__c=  testAcc.Id;
        testErpApproved.Contact__c=  testCon.Id;
        //update testErpApproved;
        //ERP_Address__c testErpMass=ECOM_TestUtil.createPunchoutMasterErpaddress();
        //ERP_Address__c testErp1=ECOM_TestUtil.createPunchoutErpaddress(testAcc,testCon, testErpMass);
        
        System.debug('testErpApproved______________'+testErpApproved.Account__c);  
        System.debug('testErpApproved______________'+testErpApproved.Id);  
        
        System.debug('testErp2______________'+testErp2.Account__c); 
        System.debug('testErpMass______________'+testErp2.fxIsECOMenabled__c);  
        
        System.runAs(usr){
            Test.startTest();
            PageReference returnPageRef = ECOM_PunchoutLoginController.punchoutLogin();
            //Validating the result    
            System.assertNotEquals(null, returnPageRef, 'The returnURL should not be empty');
            Test.stopTest();
        }

     
    }*/
    
    
    //Test Method to test getUserInformation Method
    @isTest
    static void testgetModelFromString() {
        User usr = [Select Id,UserName from User ORDER BY CREATEDDATE DESC LIMIT 1];
        System.runAs(usr){
            Test.startTest();
            ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutLoginController.getModelFromString('firstName=Test&lastName=user&lang=EN');
            Test.stopTest(); 
            
            //Validating the result    
            System.assertEquals('user', returnWrapper.lastName, 'lastName should be user');

        }
    }
    
    @isTest
    static void getSalesOrgForCountry(){
        Test.startTest();
        ECOM_PunchoutLoginController.getSalesOrgForCountry('United States');
        ECOM_PunchoutUserCreation.getSalesOrgForCountry('United States');
        Map<String,String> params = new Map<String,String>();
        params.put('test','test');
        ECOM_PunchoutUserCreation.fetchValueForProperty(params,'test');
        Test.stopTest();
    }
    
    @isTest
    static void testGetPunchoutUserForUserName(){
        Account newAccount = [SELECT id, Name FROM Account WHERE Name = :ECOM_TestUtil.REVVITY_ACCOUNT LIMIT 1];
        Contact newContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE accountId =: newAccount.Id LIMIT 1];
        User newUser = [SELECT Id, Firstname, LastName, Email, UserName FROM User WHERE contactId = :newContact.Id AND accountId =: newAccount.Id LIMIT 1];
        
        Test.startTest();
        ECOM_PunchoutLoginController.getPunchoutUserForUserName(newUser.Username);
        Test.stopTest();
    }
  

    @isTest
    static void testPunchoutLogin1(){
        //covwer normal user flow(user updated to punchout)
        //Create mock response headers
            Map<String, String> responseHeaders = new Map<String, String>();
            responseHeaders.put('Content-Type', 'application/json');
            Test.startTest();
            // Create mock HTTP response using Generic mock class ECOM_MockHttpResponseGenerator
            ECOM_MockHttpResponseGenerator mockResponse = new ECOM_MockHttpResponseGenerator(200, 'OK', '{"storefrontURL": "/login","USERNAME":"test@test.com","PASSWORD":"test@123","COOKIE":""}', responseHeaders);
            // Set the mock response for the HTTP callout
            Test.setMock(HttpCalloutMock.class, mockResponse);
            ECOM_PunchoutLoginController.punchoutLogin();
            Test.stopTest();
        //cover punchout flow
        //ECOM_PunchoutLoginController.punchoutLogin();
    }
       @isTest
    static void testPunchoutLogin2(){
        //covwer normal user flow(user updated to punchout)
        //Create mock response headers
            Map<String,Object> reqData = new Map<String,Object>();
            reqData.put('encryptedToken', '');
            Map<String, String> responseHeaders = new Map<String, String>();
            responseHeaders.put('Content-Type', 'application/json');
        	RestRequest req = new RestRequest(); 
           	RestResponse res = new RestResponse();
        
            req.requestURI = '/PunchoutUserCreation/';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSON.serialize(reqData));
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
            // Create mock HTTP response using Generic mock class ECOM_MockHttpResponseGenerator
            ECOM_MockHttpResponseGenerator mockResponse = new ECOM_MockHttpResponseGenerator(200, 'OK', '{"storefrontURL": "/login","USERNAME":"test@test.com","PASSWORD":"test@123","COOKIE":""}', responseHeaders);
            // Set the mock response for the HTTP callout
            Test.setMock(HttpCalloutMock.class, mockResponse);
            ECOM_PunchoutUserCreation.validatePunchoutUser();
        	ECOM_PunchoutUserCreation.loginUserToSite('test@test.com','test@123','');
            Test.stopTest();
        //cover punchout flow
        //ECOM_PunchoutLoginController.punchoutLogin();
    }
    


     @isTest
    static void testGetEncryptedStoreUrl(){
        String userNameString = '%@noemail.com';
        User userRecord = [SELECT Id, Email FROM User WHERE UserName LIKE : userNameString LIMIT 1];
        
        userRecord = ECOM_PunchoutLoginController.getPunchoutUserInformationByUserNameForLogin(userRecord.Email);
        ECOM_PunchoutWrapper.PunchoutServiceRequest request = ECOM_TestUtil.createPOSRModelForRevvityPunchoutForExistingUser();
        ECOM_PunchoutLoginController.getEncryptedStoreUrl(ECOM_Constant.POTYPE_PUNCHOUT_USER, userRecord, 'TestLoginUrl', request, false);
        
    }
    
    @isTest
    static void testValidateAndCreateContact(){

        ECOM_PunchoutWrapper.PunchoutServiceRequest request = ECOM_TestUtil.createPOSRModelForRevvityPunchoutForExistingUser();
        request.userEmail = 'test@test.com';
        ERP_AddressModel addressModel = ERP_AddressUtil.getPunchoutAddressesForERPAddressModel('RVTYPNCHOUT');
        Test.startTest();
        ECOM_PunchoutLoginController.validateAndCreateContact(request, addressModel);
        Test.stopTest();
    }
	//commented
    /*@isTest
    static void testGetUserServiceInstance(){
        Test.startTest();
        ECOM_PunchoutLoginController.getCartServiceInstance();
        Test.stopTest();
    }*/

	@isTest
    static void testGetRequestModelForTestUser(){
        Test.startTest();
        ECOM_PunchoutLoginController.getRequestModelForTestUser();
        Test.stopTest();
    }
   
    @isTest
    static void testResetPassword(){
        User userRecord = [SELECT Id, FirstName, LastName, Email, UserName 
                           FROM User 
                           ORDER BY CREATEDDATE DESC
                           LIMIT 1];
        ECOM_MockHttpResponseGenerator mockResponse = new ECOM_MockHttpResponseGenerator(200, 'OK', '{"result": "success"}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Test.startTest();
        String resetPassword = ECOM_PunchoutLoginController.getNewPassword();
        ECOM_PunchoutLoginController.resetPassword(userRecord.Id, resetPassword);
        Test.stopTest();
    }
    
    @isTest 
    static void testGetPunchoutUserInformationByUserName(){
        User userRecord = [SELECT Id, FirstName, LastName, Email, UserName 
                           FROM User 
                           ORDER BY CREATEDDATE DESC 
                           LIMIT 1];
        
        Test.startTest();
        ECOM_PunchoutLoginController.getPunchoutUserInformationByUserName(userRecord.UserName);
        Test.stopTest();
    }
    
    @isTest
    static void testValidateTestUserForAccountId(){
        Account newAccount = [SELECT Id FROM Account WHERE Name = 'Test Revvity Account' LIMIT 1];
        
        Test.startTest();
        ECOM_PunchoutLoginController.validateTestUserForAccountId(newAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCalloutToLoginTestUser(){
        User userRecord = [SELECT Id, FirstName, LastName, Email, UserName 
                           FROM User 
                            ORDER BY CREATEDDATE DESC
                           LIMIT 1];
        Map<String,String> responseMap = new Map<String,String>();
        responseMap.put(ECOM_Constant.PARAM_STOREFRONT_URL, 'TestLoginUrl');
        ECOM_MockHttpResponseGenerator mockResponse = new ECOM_MockHttpResponseGenerator(200, 'OK', JSON.serialize(responseMap), new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Test.startTest();
        
        Map<String,Object> requestObjectMap = new Map<String,Object>();
        
        //List<User> userRecords = ECOM_PunchoutLoginController.getPunchoutUserInformationByUserName(userRecord.UserName);
        //userRecord = userRecords[0];
        requestObjectMap.put(ECOM_Constant.PARAM_USER_RECORD, JSON.serialize(userRecord));
        ECOM_PunchoutWrapper.PunchoutServiceRequest requestModel = ECOM_TestUtil.createPOSRModelForRevvityPunchoutForExistingUser();
        requestObjectMap.put(ECOM_Constant.PARAM_REQUEST_MODEL, JSON.serialize(requestModel));
        ECOM_PunchoutLoginController.calloutToLoginTestUser(requestObjectMap);
        Test.stopTest();
    }

    @isTest
    static void updateUserAsPunchoutUserTest(){
        List<User> userRecord = [SELECT Id,Email, ContactId FROM User ORDER BY CreatedDate DESC LIMIT 1];
        Test.startTest();
        ECOM_PunchoutLoginController.updateUserAsPunchoutUserOrContact(userRecord[0].Id, 'User');
        ECOM_PunchoutLoginController.loginUserToSite('test@test.com','test@123','');
        ECOM_PunchoutLoginController.validateContactAndContactAddress(userRecord[0], new ERP_AddressModel());
        Test.stopTest();
        
    }
    
    @isTest
    static void getParametersMap(){
        Test.startTest();
        ECOM_PunchoutLoginController.getParamsMap();
        Test.stopTest();
    }
    
    //test method for logFailure() method
    @isTest
    static void logFailureTest(){
        Test.startTest();
        try{
            throw new ECOM_ApplicationLogsUtilException();
        }catch(Exception e){
            ECOM_PunchoutLoginController.logFailure(e, MODULE_NAME, CLASS_NAME, METHOD_NAME, SUPPORT_DATA);
        }
        ECOM_PunchoutLoginController.logFailure(null, MODULE_NAME, CLASS_NAME, METHOD_NAME, SUPPORT_DATA);

        Test.stopTest();
        
    }
    
    @isTest
    public static void validateContactAndContactAddress(){
        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];
        User user = [SELECT Id, Email, ContactId FROM User WHERE ContactId =: con.Id LIMIT 1];
        Test.startTest();         
        ERP_AddressModel addressModel = ERP_AddressUtil.getPunchoutAddressesForERPAddressModel('RVTYPNCHOUT');
		ECOM_PunchoutLoginController.validateContactAndContactAddress(user,addressModel);
        Test.stopTest();
    }
    
    @isTest
    public static void checkAndProvisionNewContactAndUser1(){
        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];
        Test.startTest();         
        ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutLoginController.getModelFromString('firstName=Test&lastName=user&lang=EN');
		ECOM_PunchoutUserCreation.checkAndProvisionNewContactAndUser(returnWrapper);
        Test.stopTest();
    }
    @isTest
    public static void checkAndProvisionNewContactAndUser2(){
        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];
        Test.startTest();         
        ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN');
        Test.stopTest();
    }
    
    @isTest
    static void getSystemLimits(){
        Test.startTest();
        List<String> limits = ECOM_PunchoutLoginController.getSystemLimits();
        Test.stopTest();
    }
    
    @isTest
    static void getParamsMapTest(){
        Test.startTest();
        Map<String,String> response = ECOM_PunchoutLoginController.getParamsMap();
        ECOM_PunchoutLoginService.createPOSRModelForRevvityPunchoutForNewUser();
        ECOM_PunchoutLoginService.getProductSales('AL555s','US10');
        ECOM_PunchoutLoginService.decryptWithAES256('test');
        ECOM_PunchoutLoginService.getAccount(123456534);
        Map<String,ERP_Address__c> addressMap = ECOM_PunchoutLoginService.gePunchoutAddress('UTOR');
        ECOM_PunchoutLoginService.validatePunchoutPartnerFunctions(addressMap);
        Test.stopTest();
    }

    /** RWPS-3528 Start */
    @isTest
    public static void getSalesOrgForCountryNegativeTest() {
        String salesOrgRecieved;
        Test.startTest();
            salesOrgRecieved = ECOM_PunchoutUserCreation.getSalesOrgForCountry('Test');
        Test.stopTest();
        System.assert(salesOrgRecieved == null);
    }  

    @isTest
    public static void checkAndProvisionNewContactAndUser3(){
        Test.startTest();         
        ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
		ECOM_PunchoutUserCreation.checkAndProvisionNewContactAndUser(returnWrapper);
        Map<String,ERP_Address__c> addressMap = new Map<String,ERP_Address__c>();
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_PAYER, null);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_MASTER, null);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_SHIP_TO, null);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_SOLD_TO, null);

        ECOM_PunchoutUserCreation.validateAndCreateContact1(returnWrapper, addressMap);
        Test.stopTest();
    }

    @isTest
    public static void checkAndProvisionNewContactAndUser4(){

        Test.startTest();         
        ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
		returnWrapper.userEmail = 'test@test.com';
        ECOM_PunchoutUserCreation.checkAndProvisionNewContactAndUser(returnWrapper);
        Map<String,ERP_Address__c> addressMap = new Map<String,ERP_Address__c>();
        ERP_Address__c master = [SELECT Id,ECOM_Punchout_Default_Payer__c FROM ERP_Address__c where Address_Type__c='Master' LIMIT 1];
        ERP_Address__c payer = [SELECT Id, Target_Address__c,Target_Address__r.External_Id__c FROM ERP_Address__c where Address_Type__c='Payer' AND Master_Address__c=:master.Id LIMIT 1];
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_PAYER, payer);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_MASTER, master);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_SHIP_TO, null);
        addressMap.put(ECOM_Constant.ERP_ADDRESS_TYPE_SOLD_TO, null);
        ECOM_PunchoutUserCreation.validateAndCreateContact1(returnWrapper, addressMap);
        Test.stopTest();
    }

    @isTest
    public static void testEmptyEmailPunchoutLogin() {
        Test.startTest();         
        ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
       	returnWrapper.userEmail = '';
        returnWrapper.fromCredentialIdentity = 'RVTYPNCHOUT';
        ECOM_PunchoutUserCreation.punchoutLogin(returnWrapper);
        Test.stopTest();
    }

    @isTest
    public static void testGetPunchoutUserInformationByUserNameForLogin() {
        Test.startTest();
            Contact contact = [SELECT Id, Email FROM Contact LIMIT 1];
            List<User> lstUser = [select id,username from user where contactId =: contact.Id];
            ECOM_PunchoutUserCreation.getPunchoutUserInformationByUserNameForLogin(lstUser[0].username);

            ERP_Address__c master = [SELECT Id,ECOM_Punchout_Default_Payer__c FROM ERP_Address__c where Address_Type__c='Master' LIMIT 1];
            master.Default_Domain__c = 'test';
            update master;

            ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
            returnWrapper.userEmail = '';
            returnWrapper.fromCredentialIdentity = 'RVTYPNCHOUT';
            ECOM_PunchoutUserCreation.punchoutLogin(returnWrapper);
        Test.stopTest();
    }

    @isTest
    public static void testPunchoutLoginWithUserPresent() {
        Contact contact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<User> lstUser = [select id,username from user where contactId =: contact.Id];

        Test.startTest();
            ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
            returnWrapper.userEmail = lstUser[0].username;
            returnWrapper.fromCredentialIdentity = 'RVTYPNCHOUT';
            ECOM_PunchoutUserCreation.punchoutLogin(returnWrapper);
        Test.stopTest();
    }

    @isTest
    public static void testPunchoutLoginWithUserPresentAndNoMasterERP() {
        Contact contact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<User> lstUser = [select id,username from user where contactId =: contact.Id];

        Test.startTest();
            ECOM_PunchoutWrapper.PunchoutServiceRequest returnWrapper = ECOM_PunchoutUserCreation.getModelFromString('firstName=Test&lastName=user&lang=EN&buyerCookie={test}&emailEncodingKey=test');
            returnWrapper.userEmail = lstUser[0].username;
            returnWrapper.fromCredentialIdentity = 'TEST';
            ECOM_PunchoutUserCreation.punchoutLogin(returnWrapper);
        Test.stopTest();
    }
    /** RWPS-3528 End */
}