/**************************************************************
* 1. Jira Ticket(s)
*
* 2. Description - This apex class for JsonDataController apex class, Which is used to handle the Order Entry data object JSON record and process to show data in
     table using LWC component
*
* 3. Objects referenced
*    - Order Entry data
*
* 4. Callouts to additional Components (including their methods) or None:None
*    
* 5. Dependant Class(es):JsonDataController
*    - 
*    
*
* 6. Test Class Name: JsonDataController_Test
* 
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s): 
*    - Vishwas & Created Date(2024.12.13)
*    -
*************************************************************/
@istest
public class jsonDataController_Test {
    @isTest static void fetchOrderEntrytest() {
        Order_Entry_Data__c obj=new Order_Entry_Data__c();
        obj.json_data__c ='';
        insert obj;
        JsonDataController.saveJsonData(obj.Id);
    }
    @isTest static void fetchOrderEntrytestnegative() {
        Order_Entry_Data__c obj=new Order_Entry_Data__c();
        obj.json_data__c ='';
        JsonDataController.saveJsonData(obj.Id);
    }
    @isTest static void fetchOrderEntrytestne2() {
        
        JsonDataController.saveJsonData('testtesttesttes');
    }
    @isTest static void testMethod2(){
        String name='Test Account'; 
        Integer clusterID=0012345678;
        String erpID='0012345678'; 
        String salesOrg='US10';
         Account acct = new Account();
        acct.Name = name;
        acct.MDM_Cluster_ID__c = clusterID;
        acct.Account_Domains__c='testDomain';
        insert acct;

        Country__c lkupCountry = new Country__c();
        lkupCountry.Name = 'United States';
        lkupCountry.SFDC_Country_Name__c = 'United States';
        lkupCountry.Country_ISO_Alpha_2__c = 'US';
        lkupCountry.Global_Territory__c = 'AMERICAS';
        lkupCountry.Sub_Territory__c = 'NORTH AMERICA';
        lkupCountry.Super_Territory__c = 'AMERICAS';
        lkupCountry.Territory__c = 'NORTH AMERICA';
        insert lkupCountry;

        State__c lkupState = new State__c();
        lkupState.Name = 'Florida';
        lkupState.SFDC_State_Name__c = 'Florida';
        lkupState.ISOCode__c = 'FL';
        lkupState.Country__c = lkupCountry.Id;
        insert lkupState;

        ERP_Address__c master = new ERP_Address__c();
        master.Address_Type__c = 'Ship To';
        master.ERP_Customer_Number__c = erpID;
        master.MDM_Cluster_Id__c = clusterID;
        master.Address_Street_Line_1__c = '123 Main St';
        master.Address_City__c = 'Tampa';
        master.Address_Postal_Code__c = '33626';
        master.LKUP_State__c = lkupState.Id;
        master.LKUP_Country__c = lkupCountry.Id;
        master.Account__c = acct.Id;
        insert master;
        JsonDataController.fetchRelatedAddress('testrecords0101');
    }
}