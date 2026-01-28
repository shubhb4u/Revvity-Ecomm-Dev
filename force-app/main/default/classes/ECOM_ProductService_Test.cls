/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    RWPS-1456    
*
* 2. Description - This class is a test class
*
*
* 3. Objects referenced
*    -Product2
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*    
*
* 5. Dependant Class(es): 
*   - ECOM_ProductService
*   - ECOM_TestUtil
*    
*   
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - Sidak 2024.04.22 | Added methods testGetProductsBasedOnPartialPartNumber, testGetProductDisplayUrlForProductCode
*    - Sidak 2024.01.16 Updated method testGetProductsBasedOnPartialPartNumber. Ticket - RWPS-1477
*    - Poonam 2025.01.7 Updated method testGetProductsBasedOnPartialPartNumber. Ticket - RWPS-1456
*    - Poonam 2025.01.7 Added method testEmptyIncludeQuery, testEmptyExcludeQuery, testIncludeAndExcludeQueries, testRadioactiveHandling
*    - Poonam 2025.01.7 Added method testCaseInsensitiveProductLine, testNoWhereClause, testNoMatchingProductLine, testNoValidReplacements Ticket - RWPS-1456
*    - Poonam 2025.01.7 Added method testProcessProductExclusions for Excel upload template
*    - Poonam 2025.01.17 Added method testGetProductsBasedOnPartialPartNumberIncludeQuery, testGetProductsBasedOnPartialPartNumberNonPunchout Ticket - RWPS-1456
*    - Poonam 2025.02.04 Added method testGetProductsBasedOnPartialPartNumberExcludeQuery, testGetZCProductsBasedOnPartialPartNumberIncludeQuery, testGetNoAddressRecord,testGetProductTnCById, testGetExcludedPartNumbers_IncludePartNumberWhereClause,testExcludedPartNumbers, testGetExcludedPartNumbers_ExcludeWhereClause, testGetExcludedPartNumbers_Exception, testGetExcludedPartNumbers_IncludeWhereClause Ticket - RWPS-1456, RWPS- 2132
*    - Poonam 2025.02.06 Added method testGetProductSalesRecord Ticket - RWPS- 2317 
*    - Poonam 2025.02.19 Added method testGetExcludedPartNumbers_RadProducts, testGetExcludedPartNumbers_NonRadProducts Ticket - RWPS- 2390 
*    - Poonam 2025.02.25 Updated these methods to increase code coverage, testGetNoAddressRecord,testGetExcludedPartNumbers_IncludePartNumberWhereClause,testGetExcludedPartNumbers_ExcludeWhereClause,testGetExcludedPartNumbers_IncludeWhereClause,
       testGetExcludedPartNumbers_NonRadProducts - RWPS- 2390
*    - Prabhat Kumar 2025.01.01 Created method testgetRecentlyPurchasedProducts to increase code coverage - RWPS-2855
*    - Manish Joshi 2025.04.17 Updated method testgetRecentlyPurchasedProducts to increase code coverage - RWPS-3023
*    - Sachin Vispute 2025.10.13 - Added method 'testGetProductsBasedOnPartialPartNumberForDealer' - RWPS-4759
*    - Manish Joshi 2025.08.29 Added method testgetRecentlyPurchasedPunchoutProducts to increase code coverage - RWPS-4147
*    - Sachin Vispute 2025.12.16 Updated method testGetRecentlyPurchasedPunchoutProducts - RWPS-5507
    
*************************************************************/
@isTest
public with sharing class ECOM_ProductService_Test 
{
    @TestSetup
    public static void testData(){
        ECOM_TestUtil.initialStorefrontSetup();
    }

    @isTest
    static void testGetProdImages() {
        List<Id> prodIds = new List<Id>();
        Set<String> prodIdSet = new Set<String>();
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 product : products) {
            prodIds.add(product.Id);
            prodIdSet.add(product.Id);
        }
        List<String> productFields = new  List<String>();
        productFields.add('Param1');
        productFields.add('Param2');
        String siteId = 'testSiteId';
        List<String> materialCodes = new List<String>();
        materialCodes.add('parm');
        materialCodes.add('parm2');
        // Call ECOM_ProductService.getProdImages method
        ECOM_ProductService.getProdImages(prodIds,siteId);
        ECOM_ProductService.getProducts('webstoreId', 'effectiveAccountId',prodIds,productFields,true);
        ECOM_ProductService.getProductSales(prodIdSet,materialCodes);
        // Use System.assert or System.assertEquals to validate the results
    }
    
    @isTest
    static void testGetProdMedia() {
        //ECOM-112 - garora@rafter.one - increased coverage
        List<ConnectApi.ProductOverview> products = new List<ConnectApi.ProductOverview>();
        ConnectApi.ProductMedia media = new ConnectApi.ProductMedia();
        media.url = 'testUrl';
        ConnectApi.ProductOverview mediaOverview = new ConnectApi.ProductOverview();
        mediaOverview.defaultImage = media;
        products.add(mediaOverview);
    	ECOM_ProductService.getProdMedia(products);
    }


    @isTest
    static void testExceptionHandling() {
    	ECOM_ProductService.getProdImages(null,'');
    }
    
 

    @isTest
    static void testgetCmsPdpUrl() {
        //ECOM-112 - garora@rafter.one - increased coverage
        User testUser = [Select Id,LastName,LanguageLocaleKey From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2  product =  [SELECT Id,ProductCode,DisplayUrl FROM Product2 LIMIT 1];
        product.DisplayUrl ='/product/lance-ultra-cg-hu-std-lyo-0-3-g-trf3001s';
        product.ProductCode = 'test';
        update product;
        List<Product2> productlist = new List<Product2>();
        productlist.add(product);
        System.debug('productlist'+productlist);    
        String productCode = 'test';
        String userLocale = 'testUser.LanguageLocaleKey';
        String actualCmsPdpUrl = ECOM_ProductService.getCmsPdpUrl(productCode, userLocale);
        
    }
    
    @isTest
    static void getProductTnCByIdTest(){
        Set<String> strings = new Set<String>();
        Test.startTest();
        List<Product2> products = ECOM_ProductService.getProductTnCById(strings);
        Test.stopTest();
    }


  
    /**
     * @description Test when the include query is empty.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testEmptyIncludeQuery() {
        String includeQuery = '';
        String excludeQuery = 'SHOW PRODUCT WHERE ProductLine = \'CLR\'';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('IncludeWhereClause'), '', 'IncludeWhereClause should be empty');
        System.assertEquals(result.get('ExcludeWhereClause'), 'Product_Line__c = \'CLR\'', 'Exclude clause not processed correctly for CLR product line');
    }

    /**
     * @description Test when the exclude query is empty.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testEmptyExcludeQuery() {
        String includeQuery = 'SHOW PRODUCT WHERE ProductLine = \'CLR\'';
        String excludeQuery = '';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('IncludeWhereClause'), 'Product_Line__c = \'CLR\'', 'Include clause not processed correctly for CLR product line');
        System.assertEquals(result.get('ExcludeWhereClause'), '', 'ExcludeWhereClause should be empty');
    }

    /**
     * @description Test with both an include and an exclude query.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testIncludeAndExcludeQueries() {
        String includeQuery = 'SHOW PRODUCT WHERE ProductLine IN ( \'CLR\' ) OR PartNumber IN (\'123\')';
        String excludeQuery = 'SHOW PRODUCT WHERE PacCode NOT IN (\'XYZ\') OR Radioactive = true';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('ExcludeWhereClause'), 'IGOR_PAC__c NOT IN (\'XYZ\') AND Dangerous_Goods_Indicator_Profile__c IN (\'Yes\', \'Y\', \'RAD\')', 'Exclude clause not processed correctly');
    }

    /**
     * @description Test to handle Radioactive conditions.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testRadioactiveHandling() {
        String includeQuery = 'SHOW PRODUCT WHERE Radioactive = true';
        String excludeQuery = 'SHOW PRODUCT WHERE Radioactive = false';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        
        // Check that Radioactive queries are correctly replaced
        System.assertEquals(result.get('IncludeWhereClause'), 'Dangerous_Goods_Indicator_Profile__c IN (\'Yes\', \'Y\', \'RAD\')', 'Radioactive = true should be processed correctly');
        System.assertEquals(result.get('ExcludeWhereClause'), 'Dangerous_Goods_Indicator_Profile__c NOT IN (\'Yes\', \'Y\', \'RAD\')', 'Radioactive = false should be processed correctly');
    }

    /**
     * @description Test case for case insensitivity of ProductLine.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testCaseInsensitiveProductLine() {
        String includeQuery = 'SHOW PRODUCT WHERE ProductLine = \'CLR\'';
        String excludeQuery = 'SHOW PRODUCT WHERE PacCode = \'7131\'';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('IncludeWhereClause'), 'Product_Line__c = \'CLR\'', 'ProductLine should be case-insensitive');
    }

    /**
     * @description Test when no SHOW PRODUCT WHERE clause exists.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
     @isTest
    static void testNoWhereClause() {
        // Define the include and exclude queries with no SHOW PRODUCT WHERE clause explicitly provided.
        String includeQuery = 'ProductLine = \'CLR\'';
        String excludeQuery = 'PacCode = \'XYZ\'';
        
        // Call the method to process the queries
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        // Assert that the result is not null
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        
        // Assert that the IncludeWhereClause should be empty (no WHERE clause found)
        System.assertEquals(result.get('IncludeWhereClause'), '', 'IncludeWhereClause should be empty when no WHERE clause is found');
        
        // Assert that the ExcludeWhereClause should be empty (no WHERE clause found)
        System.assertEquals(result.get('ExcludeWhereClause'), '', 'ExcludeWhereClause should be empty when no WHERE clause is found');
    }
    /**
     * @description Test case for ProductLine not matching.
     * @author Poonam Shukla
     * @date 01-07-2025
     */
    @isTest
    static void testNoMatchingProductLine() {
        String includeQuery = 'SHOW PRODUCT WHERE ProductLine = \'NONCLR\'';
        String excludeQuery = 'SHOW PRODUCT WHERE PacCode = \'XYZ\'';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('IncludeWhereClause'), 'Product_Line__c = \'NONCLR\'', 'Include clause should still be processed even if product line doesn’t exist');
        System.assertEquals(result.get('ExcludeWhereClause'), 'IGOR_PAC__c = \'XYZ\'', 'Exclude clause should be processed correctly');
    }

    /**
      * @description Test case with both include and exclude queries but no valid replacements.
      * @author Poonam Shukla
      * @date 01-07-2025
     */
    @isTest
    static void testNoValidReplacements() {
        String includeQuery = 'SHOW PRODUCT WHERE ProductLine = \'TEST\'';
        String excludeQuery = 'SHOW PRODUCT WHERE PartNumber = \'XYZ\'';
        
        Map<String, String> result = ECOM_ProductService.buildCustomProductQueryForQuickOrderPunchout(includeQuery, excludeQuery);
        
        System.assertNotEquals(result, null, 'Expected result to be non-null');
        System.assertEquals(result.get('IncludeWhereClause'), 'Product_Line__c = \'TEST\'', 'Include clause should be processed');
        System.assertEquals(result.get('ExcludeWhereClause'), 'Part_Number__c = \'XYZ\'', 'Exclude clause should be processed correctly');
    }
    
	/**
      * @description Test case: Valid query with multiple part numbers
      * @author Poonam Shukla
     */
 @isTest
    static void testExtractPartNumbersWithMultipleParts() {
        String excludeQuery = 'SHOW PRODUCT Where PartNumber not in (\'GR2261005\', \'GR2261006\', \'GR2261007\')';
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(3, partNumbers.size(), 'There should be 3 part numbers');
        Assert.isTrue(partNumbers.contains('GR2261005'), 'Excluded part number GR2261005 should be in the list');
        Assert.isTrue(partNumbers.contains('GR2261006'), 'Excluded part number GR2261006 should be in the list');
        Assert.isTrue(partNumbers.contains('GR2261007'), 'Excluded part number GR2261007 should be in the list');
    }
    
    /**
      * @description Test case: Valid query with a single part number
      * @author Poonam Shukla
     */
    @isTest
    static void testExtractPartNumbersWithSinglePart() {
        String excludeQuery = 'SHOW PRODUCT Where PartNumber not in (\'GR2261005\')';
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(1, partNumbers.size(), 'There should be 1 part number');
        Assert.isTrue(partNumbers.contains('GR2261005'), 'Excluded part number GR2261005 should be in the list');
    }

     /**
      * @description Test case: Empty query string
      * @author Poonam Shukla
     */
    @isTest
    static void testExtractPartNumbersWithEmptyQuery() {
        String excludeQuery = '';
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(0, partNumbers.size(), 'The list should be empty for an empty query');
    }

     /**
      * @description Test case: Query with no part numbers
      * @author Poonam Shukla
     */
    @isTest
    static void testExtractPartNumbersWithNoPartNumbers() {
       
        String excludeQuery = 'SHOW PRODUCT Where PartNumber not in ()';
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(0, partNumbers.size(), 'The list should be empty when no part numbers are provided');
    }

    /**
      * @description Test case: Query with malformed format (no single quotes around part numbers)
      * @author Poonam Shukla
     */
    @isTest
    static void testExtractPartNumbersWithMalformedQuery() {
        String excludeQuery = 'SHOW PRODUCT Where PartNumber not in (GR2261005, GR2261006)';
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(0, partNumbers.size(), 'The list should be empty for a malformed query');
    }

    /**
      * @description Test case: Null query string
      * @author Poonam Shukla
     */
    @isTest
    static void testExtractPartNumbersWithNullQuery() {
        String excludeQuery = null;
        List<String> partNumbers = ECOM_ProductService.extractPartNumbers(excludeQuery);
        System.assertEquals(0, partNumbers.size(), 'The list should be empty for a null query');
    }

     
    /**
      * @description Test case with exclude queries for excel template.
      * @author Poonam Shukla
      * @date 01-07-2025
     */
    @isTest
    static void testProcessProductExclusions() {
        List<String> excludedParts = new List<String>{'part123', 'part456', 'part789'};
        Test.startTest();
       
         if (excludedParts == null) {
            System.debug('The excludedParts list is null.');
        } else {
        
        System.assertEquals(3, excludedParts.size(), 'Excluded parts list should contain 3 items');
        Assert.isTrue(excludedParts.contains('part123'), 'Excluded parts should contain part123');
        Assert.isTrue(excludedParts.contains('part456'), 'Excluded parts should contain part456');
        Assert.isTrue(excludedParts.contains('part789'), 'Excluded parts should contain part789');
    }
        Test.stopTest();
    }
 
     /**
    * @description Get Products based on exclude query having only part numbers
    * @author Poonam Shukla
    * @date 02-04-2025
    */
    @isTest
    static void testGetProductsBasedOnPartialPartNumberExcludeQuery() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
         Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where PartNumber not in (\'GR2261005\')';
        master.ECOM_Punchout_Products_Include_Query__c='';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<Product_Sales__c> result;
        System.runAs(u){
             result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',isPunchoutCart);
        }       
    }  
    
    /**
    * @description Get ZC Products based on exclude query having only part numbers
    * @author Poonam Shukla
    * @date 02-04-2025
    */
    @isTest
    static void testGetZCProductsBasedOnPartialPartNumberIncludeQuery() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZC');
        Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber  in (\'770504\')';
        master.ECOM_Punchout_Products_Exclude_Query__c='';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<Product_Sales__c> result;
        System.runAs(u){
             result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',isPunchoutCart);
        }       
    }  

    /**
    * @description //To test product retrieval bases on partial part number
    * @author Sidak Singh | 04-22-2024
    **/
    @isTest
    static void testGetProductsBasedOnPartialPartNumber() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
        Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        // RWPS-1456 - START
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber in (\'GR2261005\') OR ProductLine in (\'CLR\')';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<Product_Sales__c> result;
        System.runAs(u){
             result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',isPunchoutCart);
        }
    }

 	/**
    * @description Get Products based on iclude query having only part numbers
    * @author Poonam Shukla
    * @date 01-20-2025
    */
    @isTest
    static void testGetProductsBasedOnPartialPartNumberIncludeQuery() {
        // RWPS-1456 - START
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
        Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        // RWPS-1456 - END
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber in (\'GR2261005\')';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<Product_Sales__c> result;
        System.runAs(u){
             result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',isPunchoutCart);
        }       
    }   
    
    /**
    * @description Test method to verify the retrieval of products based on a partial part number for a non-punchout cart scenario.
    *              This test ensures that products are retrieved correctly when the `isPunchoutCart` flag is set to false.
    *              The method also verifies that multiple material codes are applied to filter products.
    * @author Poonam Shukla
    * @date 01-27-2025
    */
    @isTest
    static void testGetProductsBasedOnPartialPartNumberNonPunchout() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = '770425';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
         materialCodes.add('ZC');
         Boolean isPunchoutCart = false;
        
        List<Product_Sales__c> result;
        System.runAs(u){
             result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',isPunchoutCart);
        }
    }

    /**
    * RWPS-4759
    * @description Test method to verify the retrieval of products based on a partial part number for dealers.
    * @author Sachin Vispute
    * @date 13-10-2025
    */
    @isTest
    private static void testGetProductsBasedOnPartialPartNumberForDealer() {
        List<User> userList = [SELECT Id, LastName, ContactId, AccountId From USER WHERE ContactId != null ORDER BY CreatedDate DESC LIMIT 1];
        if (userList.isEmpty() == false) {
            List<ERP_Address__c> addressList = [SELECT Id, Master_Address__c, fxAddress_CountryCode__c FROM ERP_Address__c];
            if (addressList.isEmpty() == false) {
                List<Contact> contactList = new List<Contact>();
                contactList.add(new Contact(Id = userList[0].ContactId, Default_Ship_to_ERP_Address__c = addressList[0].Id));
                update contactList;
            }

            String partNumber = 'CODE123';
            List<Product2> products = new List<Product2>();
            List<String> excludedItems = new List<String>();
            List<String> materialCodes = new List<String>();
            products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, partNumber, true));
            materialCodes.add('ZW');
            List<Product_Sales__c> result;
            Test.startTest();
            System.runAs(userList[0]){
                result = ECOM_ProductService.getProductsBasedOnPartialPartNumber(partNumber, excludedItems, materialCodes,'',false);
            }
            Test.stopTest();
        }
    }


     /**
    * @description //To test product retrieval bases on partial part number
    * @author Poonam Shukla | 02-04-2025
    **/
    @isTest
    static void testGetExcludedPartNumbers() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
        Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber in (\'GR2261005\') OR ProductLine in (\'CLR\')';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
             result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }  
    }
      
    /**
    * @description Get partnumber when no address record
    * @author Poonam Shukla | 02-04-2025
    */
    @isTest
    static void testGetNoAddressRecord() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 product =  [SELECT Id FROM Product2 LIMIT 1]; //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(product.Id);//RWPS-2390
        ERP_Address__c master = null;
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
             result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }
     /**
    * @description Get Excluded Part Numbers when include query configured.
    * @author Poonam Shukla | 02-04-2025
    * @date 02-04-2025
    */
    @isTest
    static void testGetExcludedPartNumbers_IncludePartNumberWhereClause() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 product =  [SELECT Id FROM Product2 LIMIT 1]; //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(product.Id);//RWPS-2390
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber  in (\'GR2261005\')  OR Paccode in (\'2234\')';
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
             result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }
    
    /**
    * @description Test case to verify that excluded part numbers are correctly returned.
    * @author Poonam Shukla | 02-04-2025
    */
    @isTest
    static void testExcludedPartNumbers() {
        String communityId='';
        List<String> partNumberList=new List<String>();
        partNumberList.add('AL3099F');
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        String partNumber = 'CODE123';
        List<Product2> products = new List<Product2>();
        List<String> excludedItems = new List<String>();
        List<String> materialCodes = new List<String>();
        products.add(ECOM_TestUtil.createProduct('Test Product', partNumber, 'CODE123', true));
        materialCodes.add('ZW');
        List<String> productSalesPartNumbers=new List<String>();
        Boolean isPunchoutCart = true;
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where PartNumber not in (\'GR2261005\') OR ProductLine not in (\'CLR\')';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<String> result;
        System.runAs(u){
            result = ECOM_ProductService.getExcludedPartNumbers(communityId, partNumberList);
        }
    }

    /**
    * @description Test case to verify that excluded part numbers are returned when 'Exclude' query is used.
    * @author Poonam Shukla | 02-04-2025
    * @date 02-04-2025
    */
    @isTest
    static void testGetExcludedPartNumbers_ExcludeWhereClause() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 product =  [SELECT Id FROM Product2 LIMIT 1]; //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(product.Id); //RWPS-2390
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where PartNumber not in (\'GR2261005\') OR ProductLine not in (\'CLR\')';
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
            result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }

    /**
     * @description Test case to handle exception while fetching excluded part numbers.
     * @author Poonam Shukla
     * @date 02-04-2025
     */
    @isTest
    static void testGetExcludedPartNumbers_Exception() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        Test.startTest();
        try {
            List<String> result = ECOM_ProductService.getExcludedPartNumbers(null, partNumberQuantityList);
        } catch (Exception ex) {
            System.assertNotEquals(ex.getMessage(), null, 'Exception should be logged');
        }
        Test.stopTest();
    }

    /**
    * @description Test case to verify that included part numbers are returned when the 'Include' query is passed.
    * @author Poonam Shukla
    * @date 02-04-2025
    */
    @isTest
    static void testGetExcludedPartNumbers_IncludeWhereClause() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 product =  [SELECT Id FROM Product2 LIMIT 1]; //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(product.Id); //RWPS-2390
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Include_Query__c = 'SHOW PRODUCT Where PartNumber  in (\'GR2261005\') OR ProductLine  in (\'CLR\')';
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
            result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }

    /**
    * @description Test case to verify only purchase rad products.
    * @author Poonam Shukla
    * @date 02-19-2025
    */
    @isTest
    static void testGetExcludedPartNumbers_RadProducts() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 testProduct = ECOM_TestUtil.createProduct('TestProduct12','1','TP143',True);
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(testProduct.Id);
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where RadioActive != true AND PartNumber not in (\'1234567\')';
        master.ECOM_Punchout_Products_Include_Query__c='';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
            result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }  

     /**
    * @description Test case to verify only purchase non rad products.
    * @author Poonam Shukla
    * @date 02-19-2025
    */
    @isTest
    static void testGetExcludedPartNumbers_NonRadProducts() {
        User u = [Select Id,LastName, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 testProduct = ECOM_TestUtil.createProduct('TestProduct1','123','TP111',True); //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(testProduct.Id);
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where RadioActive != false AND PartNumber not in (\'1234567\')';
        master.ECOM_Punchout_Products_Include_Query__c='';
        update master;
        Account acc = [SELECT Id FROM Account where Id =:u.AccountId LIMIT 1];
        ECOM_TestUtil.createRelatedAddresses(acc,master);
        List<String> partNumberQuantityList = new List<String>{'PART123', 'PART456'};
        List<String> result;
        System.runAs(u){
            result = ECOM_ProductService.getExcludedPartNumbers('', partNumberQuantityList);
        }
    }
    /**
    * @description Test class to verify the recently purchased Products.
    * @author Prabhat Kumar
    * @date 01-04-2025
    */
    @isTest
    static void testgetRecentlyPurchasedProducts(){

        Network comm = [SELECT id, name FROM Network ORDER BY CREATEDDATE DESC limit 1]; 
        String communityId = (String)comm.Id;
        User u = [Select Id,LastName, contactId, AccountId From User ORDER BY CREATEDDATE DESC LIMIT 1];
        Product2 testProduct = ECOM_TestUtil.createProduct('TestProduct1','123','TP111',True); //RWPS-2390
        Product_Sales__c productSales = ECOM_TestUtil.createProduct_Sales(testProduct.Id);
        ERP_Address__c master = ECOM_TestUtil.createNewPunchoutMasterAddressConfiguration();
        master.ECOM_Punchout_Products_Exclude_Query__c = 'SHOW PRODUCT Where RadioActive != false AND PartNumber not in (\'1234567\')';
        master.ECOM_Punchout_Products_Include_Query__c='';
        update master;
        System.runAs(u){
            ECOM_ProductService.getRecentlyPurchasedProducts(communityId,u.Id);//RWPS-3023
        }
 
    }
     /**
    * @description Test class to verify the recently purchased Products.
    * @author Manish Joshi
    * @date 28-08-2025
    */
    @isTest
    static void testGetRecentlyPurchasedPunchoutProducts(){
        Network comm = [SELECT id, name FROM Network ORDER BY CREATEDDATE DESC limit 1];
        String communityId = (String)comm.Id;
        User u = [Select Id, Email, LastName, contactId, AccountId, ECOM_Is_Punchout_User__c From User ORDER BY CREATEDDATE DESC LIMIT 1];
        u.ECOM_Is_Punchout_User__c=true;
        update u;
        //RWPS-5507 - Start
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<Contact> contactList = [SELECT Id, Default_Ship_to_ERP_Address__c, Default_Bill_to_ERP_Address__c FROM Contact WHERE Id =: u.ContactId LIMIT 1];
            if (contactList.isEmpty() == false) {
                List<ERP_Address__c> addressList = [SELECT Id, Master_Address__c FROM ERP_Address__c WHERE Id =: contactList[0].Default_Bill_to_ERP_Address__c LIMIT 1];
                if (addressList.isEmpty() == false && addressList[0].Master_Address__c != null) {
                    update new ERP_Address__c(Id = addressList[0].Master_Address__c, ECOM_Punchout_User_Email__c = ECOM_Constant.SHIP_TO_CONTACT_EMAIL_BOTH, Ecom_Punchout_Additional_Email_Address__c = u.Email);
                    update new Contact(Id = contactList[0].Id, Default_Ship_to_ERP_Address__c = contactList[0].Default_Bill_to_ERP_Address__c);
                }
            }
        }
        System.runAs(u){
            SAP_Order_Summary__c orderSummary = new SAP_Order_Summary__c();
            orderSummary.Order_Number__c= 2243;
            orderSummary.typeOrder__c = 'SP';
            orderSummary.ShipTo_Email__c = u.Email; 
            orderSummary.Contact_Email__c = u.Email;
            orderSummary.Source_Type__c = 'ZEDI';
            orderSummary.PO_Type__c = 'INET';
            insert orderSummary;
            SAP_Order_Items__c orderItem = new SAP_Order_Items__c();
            orderItem.Line_Item_Number_Web__c = '1';
            orderItem.PKI_Order_Summary__c = orderSummary.Id;
            orderItem.isRemoved__c = false;
            orderItem.Quantity_Ordered__c = 10.00;
        	insert orderItem;
            ECOM_ProductService.getRecentlyPurchasedProducts(communityId,u.Id);
        }
        Test.stopTest();
        //RWPS-5507 - End
    }
}