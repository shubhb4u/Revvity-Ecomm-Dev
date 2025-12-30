/**************************************************************

* 1. Jira Ticket(s) that relates to this class
*  
*
* 2. Description - This is a test class
*
* 3. Objects referenced
*    - SAP_Order_Summary__c
*	 

* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
*    - ECOM_SAPOrderSummaryRepo
 
* 6. Test Class Name:
*
* 7. Is @Invocable : No
*
* 8. Author Name(s):
*    - Sidak 2024.06.20 Updated testFindPunchoutSapOrderByOrderNumberAndZip parameter to contact email list, Added methods testFetchSAPOrderSummariesById, testFetchSAPOrderSummariesByEmail, testfFindSapOrderByOrderNumberAndZip, testGetSAPOrderItemTrackings, testGetProductsBasedOnPartnumber, testFetchSAPOrderByEmailAndSourceType
*    - Gaurav 2025.07.28 Added testFetchSAPOrdersByEmail to increase code coverage - RWPS-3741
*    - Sachin Vispute 2025.10.28 : Added methods : testFetchSAPOrderForWebUsers, testFetchSAPOrderForPunchoutUsers - RWPS-4881
*    - Sachin Vispute 2025.11.06 : Updated method : testFetchSAPOrderForPunchoutUsers, Created : testFetchSAPOrderForWebPunchoutUsers - RWPS-4881
*************************************************************/
@isTest
public class ECOM_SAPOrderSummaryRepo_Test {

    @TestSetup
    public static void testSetupData()
    {
        ECOM_TestUtil.initialStorefrontSetup();
    }
    


    @isTest
    static void testFindPunchoutSapOrderByOrderNumberAndZip() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.findPunchoutSapOrderByOrderNumberAndZip(contactEmailList, orderNumber, zipCode);

        // Assert the results
       /* System.assertEquals(1, result.size()); // Adjust based on the number of SAP_Order_Summary__c records in your test data
        SAP_Order_Summary__c orderSummary = result[0];
        System.assertEquals(contactEmail, orderSummary.Contact_Email__c);
        System.assertEquals(orderNumber, orderSummary.Customer_PO_Number__c);
        System.assertEquals(zipCode, orderSummary.Ship_To_Address_Postal_Code__c);*/
     
	}
    
    @isTest
    static void testFetchSAPOrderSummariesById() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        Set<String> summaryIds = new Set<String>{orderSummary1.Id};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderSummariesById(summaryIds);
     
	}
    
    @isTest
    static void testFetchSAPOrderSummariesByEmail() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderSummariesByEmail(contactEmailList,startDate,endDate);
     
	}
    
    @isTest
    static void testfFindSapOrderByOrderNumberAndZip() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.findSapOrderByOrderNumberAndZip(contactEmailList,orderNumber,zipCode);
     
	}
    
    @isTest
    static void testGetSAPOrderItemTrackings() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        Set<String> itemIds = new Set<String>{'Test'};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Item_Tracking__c> result = ECOM_SAPOrderSummaryRepo.getSAPOrderItemTrackings(itemIds);
     
	}
    
    @isTest
    static void testGetProductsBasedOnPartnumber() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        Set<String> partNumbers = new Set<String>{'Test'};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<Product2> result = ECOM_SAPOrderSummaryRepo.getProductsBasedOnPartnumber(partNumbers);
     
	}
    
    @isTest
    static void testFetchSAPOrderByEmailAndSourceType() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};
        List<String> sourceTypes = new List<String>{'Test'};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderByEmailAndSourceType(contactEmailList,sourceTypes,startDate,endDate);
     
	}

    @isTest
    static void testFetchSAPOrdersByEmail() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};
        List<String> sourceTypes = new List<String>{'Test'};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database
        String selectedEmailType='Contact Email';// 'Ship To Email', 'Contact Email', or 'BOTH'
        List<String> alternateEmailList=new List<String>(); //RWPS-4082
        

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrdersByEmail(contactEmailList,selectedEmailType,alternateEmailList,contactEmail);
     
	}

    /**
     * RWPS-4881
     * @description Test method to verify the method 'fetchSAPOrderForWebUsers' from 'ECOM_SAPOrderSummaryRepo'
     * @author Sachin Vispute 2025.10.28
     */
    @isTest
    static void testFetchSAPOrderForWebUsers() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        List<String> contactEmailList = new List<String>{contactEmail};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed
        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database
        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderForWebUsers(contactEmailList,'12');
	}

    /**
     * RWPS-4881
     * @description Test method to verify the method 'fetchSAPOrderForPunchoutUsers' from 'ECOM_SAPOrderSummaryRepo'
     * @author Sachin Vispute 2025.10.28
     */
    @isTest
    static void testFetchSAPOrderForPunchoutUsers() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};
        List<String> sourceTypes = new List<String>{'Test'};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
            // Set other required fields
        );
        // Add more SAP_Order_Summary__c records as needed

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database
        String selectedEmailType='Contact Email';// 'Ship To Email', 'Contact Email', or 'BOTH'
        List<String> alternateEmailList=new List<String>(); //RWPS-4082

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderForPunchoutUsers(contactEmailList,selectedEmailType,alternateEmailList,contactEmail,'12', new List<String>());
	}

    /**
     * RWPS-4881
     * @description Test method to verify the method 'fetchSAPOrderForPunchoutUsers' from 'ECOM_SAPOrderSummaryRepo'
     * @author Sachin Vispute 2025.11.06
     */
    @isTest
    static void testFetchSAPOrderForWebPunchoutUsers() {
        // Test data
        String contactEmail = 'test@example.com';
        String orderNumber = '123ABC';
        String zipCode = '12345';
        Date startDate = System.today();
        Date endDate = System.today();
        List<String> contactEmailList = new List<String>{contactEmail};
        List<String> sourceTypes = new List<String>{'Test'};

        // Create some sample SAP_Order_Summary__c records
        SAP_Order_Summary__c orderSummary1 = new SAP_Order_Summary__c(
            Contact_Email__c = contactEmail,
            Order_Number__c = 123,
            Customer_PO_Number__c = orderNumber,
            Ship_To_Address_Postal_Code__c = zipCode
        );

        insert new List<SAP_Order_Summary__c>{orderSummary1};
        // Insert more SAP_Order_Summary__c records into the database
        String selectedEmailType='Contact Email';// 'Ship To Email', 'Contact Email', or 'BOTH'
        List<String> alternateEmailList=new List<String>(); //RWPS-4082

        List<String> orderTypesList = System.Label.ECOM_OrderTypes_Punchout.split(',');

        // Call the method to test
        List<SAP_Order_Summary__c> result = ECOM_SAPOrderSummaryRepo.fetchSAPOrderForPunchoutUsers(contactEmailList,selectedEmailType,alternateEmailList,contactEmail,'12', orderTypesList);
	}
}