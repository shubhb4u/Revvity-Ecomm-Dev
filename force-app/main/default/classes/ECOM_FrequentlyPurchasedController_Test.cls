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