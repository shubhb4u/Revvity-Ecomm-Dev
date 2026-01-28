@isTest
public class ECOM_FrequentlyPurchasedController_Test {
    
    @TestSetup
    public static void testSetupData()
    {
        ECOM_TestUtil.initialStorefrontSetup();
    }
    /*@isTest
    static void getFrequentlyPurchasedProductForLoggedInUserTest(){
        User testUser = [Select Id,LastName From User ORDER BY CREATEDDATE DESC LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            Map<String, Object> result = ECOM_FrequentlyPurchasedController.getFrequentlyPurchasedProductForLoggedInUser();
            Test.stopTest();
            
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    
    @isTest
    static void removeWishListItemTest(){
        
        User testUser = [Select Id,LastName From User ORDER BY CREATEDDATE DESC LIMIT 1];
        WishlistItem wishlistitem = [Select Id,Name From WishlistItem ORDER BY CREATEDDATE DESC LIMIT 1];
        
        String wishListItemId = 'wishlistitem.Id';
        
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            Map<String, Object> result = ECOM_FrequentlyPurchasedController.removeWishListItem(wishListItemId);
            Test.stopTest();
            
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    @isTest
    static void getFrequentlyBoughtProductsForUserEmailTest(){
        User testUser = [Select Id,LastName From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Account ac = [SELECT Id FROM Account WHERE Name = 'TestClass Account'];
        String accountId = 'ac.Id';
        String userEmail = 'testUser.Email';
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            Set<String> result = ECOM_FrequentlyPurchasedController.getFrequentlyBoughtProductsForUserEmail(userEmail,accountId);
            Test.stopTest();
            
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    
      @isTest
    static void addWishListTest(){
        User testUser = [Select Id,LastName,accountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String accountId=testUser.accountId;
        Network comm = [SELECT Id, name FROM Network ORDER BY CREATEDDATE DESC limit 1]; 
        Wishlist wishlist =  [Select Id,Name from Wishlist ORDER BY CREATEDDATE DESC LIMIT 1];
        WishlistItem wishlistitem = [Select Id,Name,Product2Id From WishlistItem ORDER BY CREATEDDATE DESC LIMIT 1];
        String communityId = (String)comm.Id;
        string productId=wishlistitem.Product2Id;
        //ECOM_TestUtil.createWishlist(accountId,webStoreId, userId);
        String wishListId=wishlist.Id;
        Test.startTest();
        Map<String,Object> result= ECOM_FrequentlyPurchasedController.addWishListItem(communityId, wishListId,productId, accountId);
        Test.stopTest();
        System.assertnotEquals(null,result,'Expected result');
    }*/
    
    @isTest
    static void getFrequentlyPurchasedProductForLoggedInUserTest(){
        //RWPS-5507 - Start
        User testUser = [Select Id, Email, LastName, contactId, AccountId, ECOM_Is_Punchout_User__c From User ORDER BY CREATEDDATE DESC LIMIT 1];
        testUser.ECOM_Is_Punchout_User__c = true;
        update testUser;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<Contact> contactList = [SELECT Id, Default_Ship_to_ERP_Address__c, Default_Bill_to_ERP_Address__c FROM Contact WHERE Id =: testUser.ContactId LIMIT 1];
            if (contactList.isEmpty() == false) {
                List<ERP_Address__c> addressList = [SELECT Id, Master_Address__c FROM ERP_Address__c WHERE Id =: contactList[0].Default_Bill_to_ERP_Address__c LIMIT 1];
                if (addressList.isEmpty() == false && addressList[0].Master_Address__c != null) {
                    update new ERP_Address__c(Id = addressList[0].Master_Address__c, ECOM_Punchout_User_Email__c = ECOM_Constant.SHIP_TO_CONTACT_EMAIL_BOTH, Ecom_Punchout_Additional_Email_Address__c = testUser.Email);
                    update new Contact(Id = contactList[0].Id, Default_Ship_to_ERP_Address__c = contactList[0].Default_Bill_to_ERP_Address__c);
                }
            }
        }
        System.runAs(testUser) {
            SAP_Order_Summary__c orderSummary = new SAP_Order_Summary__c();
            orderSummary.Order_Number__c= 2243;
            orderSummary.typeOrder__c = 'SP';
            orderSummary.ShipTo_Email__c = testUser.Email;
            orderSummary.Contact_Email__c = testUser.Email;
            orderSummary.Source_Type__c = 'ZEDI';
            orderSummary.PO_Type__c = 'INET';
            insert orderSummary;
            SAP_Order_Items__c orderItem = new SAP_Order_Items__c();
            orderItem.Line_Item_Number_Web__c = '1';
            orderItem.PKI_Order_Summary__c = orderSummary.Id;
            orderItem.isRemoved__c = false;
            orderItem.Quantity_Ordered__c = 10.00;
        	insert orderItem;
            //RWPS-5507 - End
            Test.startTest();
            // Call the method to test
            Map<String, Object> result = ECOM_FrequentlyPurchasedController.getFrequentlyPurchasedProductForLoggedInUser();
            Test.stopTest();
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    
    @isTest
    static void removeWishListItemTest(){
        
        User testUser = [Select Id,LastName,accountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        WishlistItem wishlistitem = [Select Id,Name From WishlistItem ORDER BY CREATEDDATE DESC LIMIT 1];
        Network comm = [SELECT Id, name FROM Network ORDER BY CREATEDDATE DESC limit 1]; 
        String communityId = (String)comm.Id;
        String accountId=testUser.accountId;
        String wishListItemId = 'wishlistitem.Id';
        
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            Map<String, Object> result = ECOM_FrequentlyPurchasedController.removeWishListItem(wishListItemId);
            result.put('Test', ECOM_FrequentlyPurchasedController.addWishListItem(communityId, '','', accountId));
            Test.stopTest();
            
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    @isTest
    static void getFrequentlyBoughtProductsForUserEmailTest(){
        User testUser = [Select Id,LastName From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String userEmail = 'testUser.Email';
        Account ac = [SELECT Id FROM Account WHERE Name = 'TestClass Account'];
        String accountId = 'ac.Id';
        System.runAs(testUser) {
            Test.startTest();
            // Call the method to test
            Set<String> result = ECOM_FrequentlyPurchasedController.getFrequentlyBoughtProductsForUserEmail(userEmail,accountId);
            Test.stopTest();
            
            System.assertnotEquals(null,result,'expected order should not be null');
        }
    }
    @isTest
    static void addWishListTest(){
        User testUser = [Select Id,LastName,accountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String accountId=testUser.accountId;
        Network comm = [SELECT Id, name FROM Network ORDER BY CREATEDDATE DESC limit 1]; 
        Wishlist wishlist =  [Select Id,Name from Wishlist ORDER BY CREATEDDATE DESC LIMIT 1];
        WishlistItem wishlistitem = [Select Id,Name,Product2Id From WishlistItem ORDER BY CREATEDDATE DESC LIMIT 1];
        String communityId = (String)comm.Id;
        string productId=wishlistitem.Product2Id;
        //ECOM_TestUtil.createWishlist(accountId,webStoreId, userId);
        String wishListId=wishlist.Id;
        Test.startTest();
        Map<String,Object> result= ECOM_FrequentlyPurchasedController.addWishListItem(communityId, wishListId,productId, accountId);
        Test.stopTest();
        System.assertnotEquals(null,result,'Expected result');
    }
}