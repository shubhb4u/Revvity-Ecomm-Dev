/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-110  
*
* 2. Description - This class is used to process SAP Order Summary and SAP order items.
*	- without sharing so the historical data loaded by integration user is presented on the storefront
* 	- and also tracking details loade by integration user are also presented on the store front - Approved by Brad
*
* 3. Objects referenced
*    - SAP Order Summary
*    - SAP Order Item
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*    
*
* 5. Dependant Class(es):
*    - 
*
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - Rani Thumma 2023.09.12
*    - Gaurang Arora - adding fxItemsQuantityTotal__c field to get total quantity in SAP order - 2024.05.02 - ECOM-3150
*    - Gaurang Arora - added invoice mailing fields - 2024.05.09 - ECOM-112
*    - Gaurang Arora - As boomi is populating sales org, we are going to refer sales org from ship to in order - 2024.06.04 - ECOM-1931
*    - Gaurang Arora - new field populated by Boomi - 24 June 2024 - ECOM-3304
*    - Sidak 2024.06.20 Updated parameter to contact email list in findSapOrderByOrderNumberAndZip, findPunchoutSapOrderByOrderNumberAndZip, fetchSAPOrderSummariesByEmail, fetchSAPOrderByEmailAndSourceType methods. Ticket - RWPS-313
*    - Manoj 2024.09.09 RWPS-1387 read image from Product2.ECOM_Product_Media_URI__c(DAM) instead product media
*    - Gaurav 2025.07.25 - fetchSAPOrdersByEmail created to return order based on email RWPS-3741
*    - Gaurav 2025.08.06 - findPunchoutSapOrderByOrderNumberAndZip updated to return all type of order RWPS-3741
*    - Manish Joshi 2025.08.21 Added method fetchSAPRecentOrdersByEmail RWPS-4147
*    - Prabhat 2025.09.23  Updated method fetchSAPOrdersByEmail to include email type in the query - RWPS-4131
*    - Poonam 2025.10.1 Update method fetchSAPOrdersByEmail to include alternateEmail list in the query - RWPS-4082
*    - Poonam 2025.10.7 Update method fetchSAPOrdersByEmail to include Contact email condition in the query - RWPS-4443
*    - Sachin Vispute 2025.10.28 - Created methods fetchSAPOrderForWebUsers & fetchSAPOrderForPunchoutUsers - RWPS-4881
*    - Sachin Vispute 2025.11.11 - Modified method fetchSAPOrderSummariesById - RWPS-5149

*************************************************************/
public without sharing class ECOM_SAPOrderSummaryRepo {
    
    public static List<SAP_Order_Summary__c> fetchSAPOrderSummariesById(Set<String> summaryIds){
        return [SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, 
                Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, Account_Ship_To__r.Name, Account_Ship_To__r.SAP_Customer_Number_Formatted__c, 
                Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, 
                Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, 
                Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, 
                Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, 
                Handling_Charges__c, OwnerId, Customer_PO_Number__c, Order_Level_Tax__c, Special_Handling_Instructions__c, Order_Net_Currency__c,
                Order_Net_Value__c,
                fxItemsQuantityTotal__c, //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024
                Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, Invoice_Mailing_Address_Postal_Code__c,
                Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, //ECOM-112 - garora@rafter.one - adding this field to get invoice mailing fields - 2024.05.09
                Sales_Org__c, Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, //ECOM-1931 - garora@rafter.one - As boomi is populating sales org, we are going to refer sales org from ship to in order - 4 June 2024
                Order__c, Total_Tariff_Surcharge__c, //RWPS-5149
                (SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, 
                Line_Item_Status__c, Expected_Ship_Date__c, Scheduled_Delivery_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Description__c, 
                Extended_Price__c, Material_Number__c, Customer_Specific_Price__c, Adjusted_Unit_Price__c FROM SAP_Order_Items__r)
                FROM SAP_Order_Summary__c WHERE Id IN :summaryIds];
    }
    
    public static List<SAP_Order_Summary__c> fetchSAPOrderSummariesByEmail(List<String> contactEmailList, Date sapOrderStartDate, Date sapOrderEndDate){
        return [SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c,
                Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, 
                Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, 
                Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, 
                Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, 
                Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, 
                OwnerId, Customer_PO_Number__c, Order_Level_Tax__c,CreatedDate,Handling_Charges__c, Special_Handling_Instructions__c, Order_Net_Currency__c,
                Order_Net_Value__c,
fxItemsQuantityTotal__c, //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024,
                Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, Invoice_Mailing_Address_Postal_Code__c,
                Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, //ECOM-112 - garora@rafter.one - adding this field to get invoice mailing fields - 2024.05.09
                Sales_Org__c, Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, //ECOM-1931 - garora@rafter.one - As boomi is populating sales org, we are going to refer sales org from ship to in order - 4 June 2024
                Total_Tariff_Surcharge__c, //RWPS-5149
                (SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, 
                 Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c,Adjusted_Unit_Price__c,Material_Description__c, Scheduled_Delivery_Date__c,
                 Customer_Specific_Price__c, Extended_Price__c FROM SAP_Order_Items__r),
                (SELECT Id,Name,CurrencyIsoCode,ECOM_Invoice_Date__c,ECOM_Total__c,ECOM_Total_Items__c,ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) //ECOM-95 - garora@rafter.one - 30 April 2024 - Additional query for related invoices, ECOM-3304 - garora@rafter.one - new field populated by Boomi - 24 June 2024
                FROM SAP_Order_Summary__c WHERE Contact_Email__c =: contactEmailList AND ( Source_Type__c='ZWEB' OR Source_Type__c='ZWCC') AND Actual_Order_Date__c <: sapOrderEndDate AND Actual_Order_Date__c >=: sapOrderStartDate];
    }

    /**
     * RWPS-4881
     * @description This method returns the offline/SAP orders details for a Web User
     * @author Sachin V | 2025-10-28
     * @param searchString | String
     * @return List<SAP_Order_Summary__c>
    */
    public static List<SAP_Order_Summary__c> fetchSAPOrderForWebUsers(List<String> contactEmailList, String searchString){
        String query = 'SELECT Id, Name, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c, Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, OwnerId, Customer_PO_Number__c, Order_Level_Tax__c,CreatedDate,Handling_Charges__c, Special_Handling_Instructions__c, Order_Net_Currency__c, Order_Net_Value__c, fxItemsQuantityTotal__c,'; //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024
        query += ' Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, Invoice_Mailing_Address_Postal_Code__c, Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c,'; //ECOM-112 - garora@rafter.one - adding this field to get invoice mailing fields - 2024.05.09
        query += ' Sales_Org__c, Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, Total_Tariff_Surcharge__c,'; //ECOM-1931 - garora@rafter.one - As boomi is populating sales org, we are going to refer sales org from ship to in order - 4 June 2024' , //RWPS-5149 Added Total_Tariff_Surcharge__c
        query += ' (SELECT Id, PKI_Order_Summary__c, PKI_Order_Summary__r.Customer_PO_Number__c, PKI_Order_Summary__r.Order_Number__c, fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c,Adjusted_Unit_Price__c,Material_Description__c, Scheduled_Delivery_Date__c,Customer_Specific_Price__c, Extended_Price__c, Order_Product__r.Product2.Part_Number__c  FROM SAP_Order_Items__r), (SELECT Id,Name,CurrencyIsoCode,ECOM_Invoice_Date__c,ECOM_Total__c,ECOM_Total_Items__c,ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC)'; //ECOM-95 - garora@rafter.one - 30 April 2024 - Additional query for related invoices, ECOM-3304 - garora@rafter.one - new field populated by Boomi - 24 June 2024
        query += 'FROM SAP_Order_Summary__c WHERE Contact_Email__c =: contactEmailList';
        //RWPS-4881
        if (String.isNotBlank(searchString)) {
            String finalSearchString = '%' +searchString + '%';
            query += ' AND Id IN (SELECT PKI_Order_Summary__c FROM SAP_Order_Items__c WHERE (PKI_Order_Summary__r.Customer_PO_Number__c LIKE :finalSearchString OR Order_Product__r.Product2.Part_Number__c LIKE :finalSearchString OR Material_Number__c LIKE : finalSearchString OR PKI_Order_Summary__r.Order_Number__c != null))';
        }
        query += ' LIMIT 49999';
        //RWPS-4881
        return Database.query(String.escapeSingleQuotes(query));
    }

    /**
     * RWPS-4881
     * @description This method returns the offline/SAP orders details for a Web User
     * @author Sachin V | 2025-10-28
     * @param searchString | String
     * @return List<SAP_Order_Summary__c>
    */
    public static List<SAP_Order_Summary__c> fetchSAPOrderForPunchoutUsers(
        List<String> contactEmailList,
        String selectedEmailType, // 'Ship To Email', 'Contact Email', or 'BOTH'
        List<String> alternateEmailList, //RWPS-4082
        String contactEmail,//RWPS-4443
        String searchString,
        List<String> orderTypesList //RWPS-4881
    ) {
        //RWPS-4443 added Order__r.CustomerAuthorizedBy.Email
        String altEmailCond  = '(Contact_Email__c IN :alternateEmailList OR ShipTo_Email__c IN :alternateEmailList)';

        String query = 'SELECT Id, Name, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c, ' +
            'Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, ' +
            'Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, ' +
            'Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, ' +
            'Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, ' +
            'Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, ' +
            'OwnerId, Customer_PO_Number__c, Order_Level_Tax__c, CreatedDate, Handling_Charges__c, Special_Handling_Instructions__c, Order_Net_Currency__c, ' +
            'Order_Net_Value__c, fxItemsQuantityTotal__c, Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, ' +
            'Invoice_Mailing_Address_Postal_Code__c, Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, Sales_Org__c, ' +
            'Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, Order__r.CustomerAuthorizedBy.Email, Total_Tariff_Surcharge__c, ' + //RWPS-5149 Added Total_Tariff_Surcharge__c
            '(SELECT Id, PKI_Order_Summary__c , PKI_Order_Summary__r.Customer_PO_Number__c, PKI_Order_Summary__r.Order_Number__c, fxItemStatus__c, ext_item_id__c, Line_Item_Number_SAP__c, Line_Item_Number_Web__c, ' +
            'Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c, Adjusted_Unit_Price__c, ' +
            'Customer_Specific_Price__c, Extended_Price__c, Material_Description__c, Scheduled_Delivery_Date__c, Order_Product__r.Product2.Part_Number__c  FROM SAP_Order_Items__r), ' +
            '(SELECT Id, Name, CurrencyIsoCode, ECOM_Invoice_Date__c, ECOM_Total__c, ECOM_Total_Items__c, ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) ' +
            'FROM SAP_Order_Summary__c WHERE';

        //RWPS-4881
        if (orderTypesList.isEmpty() == false) {
            query += ' Source_Type__c IN :orderTypesList AND ';
        }
        //RWPS-4881

        //RWPS-4881
        if (String.isNotBlank(searchString)) {
            String finalSearchString = '%' + searchString + '%';
            query += ' Id IN (SELECT PKI_Order_Summary__c FROM SAP_Order_Items__c WHERE (PKI_Order_Summary__r.Customer_PO_Number__c LIKE :finalSearchString OR Order_Product__r.Product2.Part_Number__c LIKE :finalSearchString OR Material_Number__c LIKE : finalSearchString OR PKI_Order_Summary__r.Order_Number__c != null)) AND';
        }
        //RWPS-4881

        //Logged-in user group
        query += '((';//RWPS-4443
        if (selectedEmailType == ECOM_Constant.SHIP_TO_EMAIL) {
            query += 'ShipTo_Email__c IN :contactEmailList';
        } else if (selectedEmailType == ECOM_Constant.CONTACT_EMAIL || selectedEmailType == null) {
            query += 'Contact_Email__c IN :contactEmailList';
        } else if (selectedEmailType == ECOM_Constant.SHIP_TO_CONTACT_EMAIL_BOTH) {
            query += '(Contact_Email__c IN :contactEmailList OR ShipTo_Email__c IN :contactEmailList)';
        }

        //RWPS-4443
        query += ')'; // close logged-in user group

        // RWPS-4082 start
        if (!alternateEmailList.isEmpty()) {
            query += ' OR ' + altEmailCond;
        }// RWPS-4082 end
        query += ')'; //RWPS-4443 close main WHERE parentheses*/
        query += ' ORDER BY Actual_Order_Date__c DESC LIMIT 49999';
        return Database.query(query);
    }

    public static List<SAP_Order_Summary__c> findSapOrderByOrderNumberAndZip(List<String> contactEmailList, String orderNumber, String zipCode) {
        List<SAP_Order_Summary__c> orderSummaryList = [SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c,
                Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, 
                Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, 
                Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, 
                Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, 
                Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, 
                OwnerId, Customer_PO_Number__c, Order_Level_Tax__c,CreatedDate,Handling_Charges__c, Special_Handling_Instructions__c,
                Order_Net_Currency__c,Order_Net_Value__c,fxItemsQuantityTotal__c, //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024
                Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, Invoice_Mailing_Address_Postal_Code__c,
                Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, //ECOM-112 - garora@rafter.one - adding this field to get invoice mailing fields - 2024.05.09
                Sales_Org__c, Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, //ECOM-1931 - garora@rafter.one - As boomi is populating sales org, we are going to refer sales org from ship to in order - 4 June 2024
                Total_Tariff_Surcharge__c, //RWPS-5149
                (SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, 
                 Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c,Adjusted_Unit_Price__c,
                 Customer_Specific_Price__c, Extended_Price__c FROM SAP_Order_Items__r),
                 (SELECT Id,Name,CurrencyIsoCode,ECOM_Invoice_Date__c,ECOM_Total__c,ECOM_Total_Items__c,ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) //ECOM-95 - garora@rafter.one - 2 May 2024 - Additional query for related invoices, ECOM-3304 - garora@rafter.one - new field populated by Boomi - 24 June 2024
                FROM SAP_Order_Summary__c WHERE Contact_Email__c =: contactEmailList AND (Source_Type__c='ZWEB' OR Source_Type__c='ZEDI' OR Source_Type__c='ZWCC')
                AND (Name =: orderNumber OR Customer_PO_Number__c =: orderNumber)
                AND (Ship_To_Address_Postal_Code__c =: zipCode)];
        return orderSummaryList;
    }
    
    public static List<SAP_Order_Item_Tracking__c> getSAPOrderItemTrackings(Set<string> itemIds){
        return [SELECT ID, Name, TrackingNumber__c,TrackingURL__c, Tracking_Date__c,CarrierName__c,Quantity_Shipped__c, PKIOrderItems__c , PKIOrderSummary__c,
                fxMaterialDescription__c, fxMaterialNumber__c, PKIOrderItems__r.Quantity_Ordered__c, PKIOrderItems__r.Order_Product__c
                  FROM SAP_Order_Item_Tracking__c WHERE PKIOrderItems__c  IN :itemIds AND isRemoved__c = false ORDER BY Tracking_Date__c DESC];
    }

    public static List<Product2> getProductsBasedOnPartnumber(Set<String> partNumbers){
        return [Select Id, Name, Part_Number__c,DisplayUrl FROM Product2 WHERE Part_Number__c IN: partNumbers];
    }
    
    /**
     * @description This method returns the order summary and items based on contact email and order source type
     * @author vramachandran@rafter.one | 14 Dec 2023
     * @param contactEmail | String 
     * @param sourceTypes | List<String>
     * @param sapOrderStartDate | Date
     * @param sapOrderEndDate | Date
     * @return List<SAP_Order_Summary__c>
     */
    public static List<SAP_Order_Summary__c> fetchSAPOrderByEmailAndSourceType(List<String> contactEmailList, List<String> sourceTypes, Date sapOrderStartDate, Date sapOrderEndDate){
        return [SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c,
                Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, 
                Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, 
                Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, 
                Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, 
                Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, 
                OwnerId, Customer_PO_Number__c, Order_Level_Tax__c,CreatedDate,Handling_Charges__c, Special_Handling_Instructions__c, Order_Net_Currency__c,
                Order_Net_Value__c,
fxItemsQuantityTotal__c, //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024
                Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, Invoice_Mailing_Address_Postal_Code__c,
                Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, //ECOM-112 - garora@rafter.one - adding this field to get invoice mailing fields - 2024.05.09
                Sales_Org__c, Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, //ECOM-1931 - garora@rafter.one - As boomi is populating sales org, we are going to refer sales org from ship to in order - 4 June 2024
                Total_Tariff_Surcharge__c, //RWPS-5149
                (SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, 
                 Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c,Adjusted_Unit_Price__c,
                 Customer_Specific_Price__c, Extended_Price__c, Material_Description__c, Scheduled_Delivery_Date__c FROM SAP_Order_Items__r),
                (SELECT Id,Name,CurrencyIsoCode,ECOM_Invoice_Date__c,ECOM_Total__c,ECOM_Total_Items__c,ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) //ECOM-95 - garora@rafter.one - 30 April 2024 - Additional query for related invoices, ECOM-3304 - garora@rafter.one - new field populated by Boomi - 24 June 2024
                FROM SAP_Order_Summary__c WHERE Contact_Email__c =: contactEmailList AND Source_Type__c IN : sourceTypes AND Actual_Order_Date__c <: sapOrderEndDate AND Actual_Order_Date__c >=: sapOrderStartDate LIMIT 49999];
    }
    
    /**
     * @description This method returns the products for given part numbers
     * @author vramachandran@rafter.one | 14 Dec 2023 
     * @param partNumbers | Set<String>
     * @return List<SAP_Order_Summary__c>
     */
    public static List<Product2> getProductDetailsForPartNumbers(Set<String> partNumbers){
        return [Select Id, Name, Part_Number__c,DisplayUrl, ProductClass, Business_Unit__c, CurrencyIsoCode, Product_Line__c,ECOM_Product_Media_URI__c //RWPS-1387
                FROM Product2 
                WHERE Part_Number__c IN: partNumbers LIMIT 49999];
    }
    
    /**
     * @description This method returns list of sap orders for punchout order type(s)
     * @author vramachandran@rafter.one | 24 Jan 2024
     * @param contactEmail | String
     * @param orderNumber | String 
     * @param zipCode | String 
     * @returns List<SAP_Order_Summary__c>
     */
    public static List<SAP_Order_Summary__c> findPunchoutSapOrderByOrderNumberAndZip(List<String> contactEmailList, String orderNumber, String zipCode) {
        String dynamicQuery = 'SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c, '+
                'Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, '+
                'Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, ' +
                'Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, '+
                'Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, '+
                'Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, '+
                'OwnerId, Customer_PO_Number__c, Order_Level_Tax__c,CreatedDate,Handling_Charges__c, Special_Handling_Instructions__c, '+
                'Order_Net_Currency__c,Order_Net_Value__c, fxItemsQuantityTotal__c, Total_Tariff_Surcharge__c, '+ //ECOM-3150 - garora@rafter.one - adding this field to get total quantity in SAP order - 2 May 2024 , //RWPS-5149 Added Total_Tariff_Surcharge__c
                '(SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c,Line_Item_Number_SAP__c, Line_Item_Number_Web__c, '+
                'Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c,Adjusted_Unit_Price__c, '+
                'Customer_Specific_Price__c, Extended_Price__c FROM SAP_Order_Items__r), '+
            	'(SELECT Id,Name,CurrencyIsoCode,ECOM_Invoice_Date__c,ECOM_Total__c,ECOM_Total_Items__c,ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) '+ //ECOM-95 - garora@rafter.one - 30 April 2024 - Additional query for related invoices, ECOM-3304 - garora@rafter.one - new field populated by Boomi - 24 June 2024
            	'FROM SAP_Order_Summary__c WHERE Contact_Email__c =: contactEmailList '; //RWPS-3741
        
        	//check if order numer is alphanumeric, else search with ordernumber and po number
            if(!orderNumber.isNumeric()){
                dynamicQuery += 'AND Customer_PO_Number__c =: orderNumber ';
            } else {
                Integer intOrderNumber = Integer.valueOf(orderNumber);
                dynamicQuery += ' AND (Order_Number__c =: intOrderNumber OR Customer_PO_Number__c =: orderNumber) ';
            }
        	dynamicQuery += 'AND Ship_To_Address_Postal_Code__c =: zipCode ';
        List<SAP_Order_Summary__c> orderSummaryList = Database.query(dynamicQuery);
        return orderSummaryList;
    }

     /**
     * @description This method returns the order summary and items based on contact email 
     * @author Gaurav | RWPS-3741
     * @param contactEmailList | List<String> 
     * @return List<SAP_Order_Summary__c>
     */
    //RWPS-4131 - START
    public static List<SAP_Order_Summary__c> fetchSAPOrdersByEmail(
        List<String> contactEmailList,
        String selectedEmailType, // 'Ship To Email', 'Contact Email', or 'BOTH'
        List<String> alternateEmailList, //RWPS-4082
        String contactEmail//RWPS-4443
    ) {
        //RWPS-4443 added Order__r.CustomerAuthorizedBy.Email
        String altEmailCond  = '(Contact_Email__c IN :alternateEmailList OR ShipTo_Email__c IN :alternateEmailList)';

        String query = 'SELECT Id, Order_Number__c, Actual_Order_Date__c, fxStatusB2B__c, typeOrder__c, Source_Type__c, Order_Total_Price__c, Order_Path__c, ' +
            'Count_of_Items__c, Account__r.Name, Account__r.SAP_Customer_Number_Formatted__c, Ship_To_Attention__c, Account_Ship_To__c, ' +
            'Ship_To_Address_City__c, Ship_To_Address_Country__c, Ship_To_Address_Postal_Code__c, Ship_To_Address_Region__c, ' +
            'Ship_To_Address_Street__c, Ship_To_Customer__c, Ship_To_Customer_Id__c, Ship_To_Customer_Name__c, Account_Bill_To__c, ' +
            'Bill_To_Address_City__c, Bill_To_Address_Country__c, Bill_To_Address_Postal_Code__c, Bill_To_Address_Region__c, ' +
            'Bill_To_Address_Street__c, Bill_to_Customer__c, Bill_To_Customer_Id__c, Bill_To_Customer_Name__c, Account__c, Quote_Number__c, ' +
            'OwnerId, Customer_PO_Number__c, Order_Level_Tax__c, CreatedDate, Handling_Charges__c, Special_Handling_Instructions__c, Order_Net_Currency__c, ' +
            'Order_Net_Value__c, fxItemsQuantityTotal__c, Invoice_Mailing_Address_Street__c, Invoice_Mailing_Address_City__c, Invoice_Mailing_Address_Country__c, ' +
            'Invoice_Mailing_Address_Postal_Code__c, Invoice_Mailing_Address_Region__c, Invoice_Mailing_Customer_Name__c, Sales_Org__c, ' +
            'Order__r.Default_Ship_to_ERP_Address__r.ERP_Sales_Org__c, Order__r.CustomerAuthorizedBy.Email, Total_Tariff_Surcharge__c, ' + //RWPS-5149
            '(SELECT Id, PKI_Order_Summary__c , fxItemStatus__c, ext_item_id__c, Line_Item_Number_SAP__c, Line_Item_Number_Web__c, ' +
            'Line_Item_Status__c, Expected_Ship_Date__c, Quantity_Ordered__c, Net_Price__c, Material_Number__c, Adjusted_Unit_Price__c, ' +
            'Customer_Specific_Price__c, Extended_Price__c, Material_Description__c, Scheduled_Delivery_Date__c FROM SAP_Order_Items__r), ' +
            '(SELECT Id, Name, CurrencyIsoCode, ECOM_Invoice_Date__c, ECOM_Total__c, ECOM_Total_Items__c, ERP_Invoice_Number__c FROM Invoices__r ORDER BY Name ASC) ' +
            'FROM SAP_Order_Summary__c WHERE (';

        //Logged-in user group 
        query += '(';//RWPS-4443
        if (selectedEmailType == ECOM_Constant.SHIP_TO_EMAIL) {
            query += 'ShipTo_Email__c IN :contactEmailList';
        } else if (selectedEmailType == ECOM_Constant.CONTACT_EMAIL || selectedEmailType == null) {
            query += 'Contact_Email__c IN :contactEmailList';
        } else if (selectedEmailType == ECOM_Constant.SHIP_TO_CONTACT_EMAIL_BOTH) {
            query += '(Contact_Email__c IN :contactEmailList OR ShipTo_Email__c IN :contactEmailList)';
        }

        //RWPS-4443
        query += ' AND (Order__c = null OR (Order__c != null AND Order__r.CustomerAuthorizedBy.Email = :contactEmail))';
        query += ')'; // close logged-in user group

        // RWPS-4082 start 
        if (!alternateEmailList.isEmpty()) {
            query += ' OR ' + altEmailCond; 
        }// RWPS-4082 end 

        query += ')'; //RWPS-4443 close main WHERE parentheses
        query += ' ORDER BY Actual_Order_Date__c DESC LIMIT 49999';
        return Database.query(query);
    }
    //RWPS-4131 - END

    /**
     * @description This method returns the Latest 10 order summary and its items based on contact email 
     * @author Manish Joshi | RWPS-4147
     * @param contactEmailList | List<String>
     * @return List<SAP_Order_Summary__c>
     */
    public static List<SAP_Order_Summary__c> fetchSAPRecentOrdersByEmail(List<String> contactEmailList){
        return [SELECT Id, (SELECT Id,CreatedDate, Material_Number__c FROM SAP_Order_Items__r)
                FROM SAP_Order_Summary__c WHERE Contact_Email__c IN :contactEmailList order by actual_Order_Date__c desc LIMIT 10];
    }
}