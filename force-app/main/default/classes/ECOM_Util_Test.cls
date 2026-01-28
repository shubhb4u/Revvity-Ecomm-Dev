/**************************************************************

* 1. Jira Ticket(s) that relates to this class
*  
*
* 2. Description - This class is a test class
*
* 3. Objects referenced
*    - WebStore
*	 

* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
*    - ECOM_TestUtil

* 6. Test Class Name:
*
* 7. Is @Invocable : No
*
* 8. Author Name(s):
*    - Sukumar 2023.09.17
*	 - Vipul 2024.04.29 Added method convertListToQueryStringTest
*    - manish.joshi@revvity.com | 2024-05-07 added method testGetSiteDetails for ticket RWPS-592
*************************************************************/
@isTest(SeeAllData=false)
public with sharing class ECOM_Util_Test {
    
    @testSetup
    static void setup(){
        Map<String,Object> result = ECOM_TestUtil.initialStorefrontSetup();
    }
    
    @IsTest
    static void testGetFieldsByObjectName() {
        // Call the method to be tested
        Map<String, String> result = ECOM_Util.getFieldsByObjectName('Account');
        
        // Verify the result
        System.assertNotEquals(0, result.size());
    }
    
    @IsTest
    static void testGetValueFromMap() {
        // Create test data
        Map<String, String> valueMap = new Map<String, String>();
        valueMap.put('Key', 'Value');
        
        // Call the method to be tested
        String result = ECOM_Util.getValueFromMap(valueMap, 'Key');
        
        // Verify the result
        // System.assertEquals('Value', result);
    }
    
    @IsTest
    static void testGetStrDefaultCartPath() {
        // Create test data
        Map<String, String> valueMap = new Map<String, String>();
        valueMap.put('sourceURL', '/demo/po-redirection?sourceURL=test');
        valueMap.put('storefrontPath', '/test');
        
        // Call the method to be tested
        String result = ECOM_Util.getStrDefaultCartPath(valueMap);
        
        // Verify the result
        // System.assertEquals('', result);
    }
    
    @IsTest
    static void testGetWebStoreIdByName() {
        // Create test data
        // WebStore webStore = new WebStore(Name = 'Test WebStore');
        WebStore testWebStore = new WebStore();
        testWebStore = ECOM_TestUtil.prepareWebStore('revStore');
        insert testWebStore;
        
        // Call the method to be tested
        Test.startTest();
        ECOM_Util.getWebStoreIdByName();
        Test.stopTest();
        
        // Verify the result
        // System.assertEquals('testWebStore.Id', null);
    }
    
    @isTest
    static void fetchConfigByValueTest(){
        Test.startTest();
        String result = ECOM_Util.fetchConfigByValue('test');
        Test.stopTest();
    }
    
    @isTest
    static void parseOrderDataLayerModelTest(){
        List<Order> testOrders = [SELECT Id,currencyIsoCode,(SELECT Id,Product2Id,Product2.Name,Product2.Part_Number__c,Product2.Product_Type__c,
                                                             Product2.Item_Class__c,Product2.Business_Unit__c,Product2.Discount_Type__c,Product2.IGOR_PAC__c,Product2.IGOR_Item_Class_Desc__c,
                                                             Product2.Product_Line__c,quantity,UnitPrice,ListPrice,TotalPrice,Product2.Part_Type__c,Product2.Sub_Business_Unit__c,Product2.Super_Business_Unit__c,Product2.Product_Line_Name__c 
                                                             ,Product2.IGOR_Description__c,ECOM_Parent_Item__c FROM OrderItems) FROM Order];
        Test.startTest();
        Map<String,ECOM_DataLayerModel> response = ECOM_Util.parseOrderDataLayerModel(testOrders);
        Test.stopTest();
    }
    
    @isTest
    static void parseProductDataLayerModelTest(){
        List<Product2> products = [SELECT Id,Name,Part_Number__c,Product_Type__c,Item_Class__c,IGOR_PAC__c,Business_Unit__c,Discount_Type__c,Product_Line__c,IGOR_Item_Class_Desc__c,
                                   Sub_Business_Unit__c,Part_Type__c,Super_Business_Unit__c,Product_Line_Name__c,IGOR_Description__c FROM Product2];
        Test.startTest();
        Map<String,ECOM_DataLayerModel> response = ECOM_Util.parseProductDataLayerModel(products);
        Test.stopTest();
    }
    
    @isTest
    static void parseDataLayerModelTest(){
        List<WebCart> carts = [SELECT Id,currencyIsoCode,(SELECT Id,Product2Id,Product2.Name,Product2.Part_Number__c,Product2.Product_Type__c,
                                                          Product2.Item_Class__c,Product2.Business_Unit__c,Product2.Discount_Type__c,Product2.Product_Line__c,quantity,Product2.IGOR_PAC__c,Product2.IGOR_Item_Class_Desc__c,
                                                          salesPrice,listPrice,Product2.Part_Type__c,Product2.Sub_Business_Unit__c,Product2.IGOR_Description__c,ECOM_Parent_Item__c,Product2.Product_Line_Name__c,Product2.Super_Business_Unit__c FROM CartItems) FROM WebCart];
        Test.startTest();
        Map<String,Object> result = ECOM_Util.parseDataLayerModel(carts);
        Test.stopTest();
    }
    
    @isTest
    static void generateRequestMapTest(){
        test.startTest();
        Map<String, String> response =  ECOM_Util.generateRequestMap('Test','Test');
        test.stopTest();
    }
    
    @isTest
    static void getCountryFromUserTest(){
        Contact con = [SELECT Id,ECOM_CountryProvided__c FROM Contact LIMIT 1];
        con.ECOM_CountryProvided__c='United States';
        update con;
        User u = [SELECT id,Contact.ECOM_CountryProvided__c FROM User ORDER BY CreatedDate DESC Limit 1];
        Test.startTest();
        String response = ECOM_Util.getCountryFromUser(u);
        Test.stopTest();
    }
    @isTest
    static void testgetOneTrustInfo()
    {
        Boolean isGuest = true;
        User u = [SELECT Id FROM USER ORDER BY CREATEDDATE DESC LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            Map<String,Object> output = ECOM_Util.getOneTrustInfo(true);
            Map<String,Object> output1 = ECOM_Util.getOneTrustInfo(false);
            
            String result = ECOM_Util.createJwtToken(true);
            String result2 = ECOM_Util.createJwtToken(false);
            
            Test.stopTest();
            System.AssertEquals(true,output.get('isSuccess'));
        }
        
        
    }
    @isTest
    static void testBase64URLencode() {
        // Create a sample Blob to test
        Blob testBlob = Blob.valueOf('Hello, World!');
        // Call the method to be tested
        User u = [SELECT Id FROM USER ORDER BY CREATEDDATE DESC LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            String encodedString = ECOM_Util.base64URLencode(testBlob);
            System.assertEquals('SGVsbG8sIFdvcmxkIQ', encodedString, 'Unexpected encoded string');
            Test.stopTest();
        }
    }
    
    @isTest
    static Void testfetchStorefrontFrontConfigByModule()
    {	
        User u = [SELECT Id FROM USER ORDER BY CREATEDDATE DESC LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            Map<String,String> res = ECOM_Util.fetchStorefrontFrontConfigByModule('SiteURL');
            //ECOM_Util.fetchBaseSiteURL('SiteURL');
            Test.stopTest();
            System.AssertNotEquals(null,res,'Wrong Output');
            
        }
    }
    
    @IsTest
    public static void convertListToQueryStringTest()
    {
        List<String> testList=new List<String>{'Test1','Test2'};
        Test.startTest();
        String result=ECOM_Util.convertListToQueryString(testList,'');
        Test.stopTest();
        System.assertEquals((result.split(',')).size(),2);
    }
    /**
    * @description test method for ECOM_Util getSiteDetails method
    * @author manish.joshi@revvity.com | 2024-05-07 
    * @return void 
    **/
    @isTest
    static void testGetSiteDetails(){
        User u = [SELECT Id FROM USER ORDER BY CREATEDDATE DESC LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            List<String> res = ECOM_Util.getSiteDetails();
            Test.stopTest();
            System.AssertNotEquals(null,res,'Wrong Output');
            
        }
    }
    
}