/**************************************************************
* 1. Jira Ticket(s)
*
* 2. Description - This apex class is used to to handle the Order Entry data object JSON record and process to show data in
     table using LWC component
*
* 3. Objects referenced
*    - Order Entry data
*
* 4. Callouts to additional Components (including their methods) or None:None
*    
* 5. Dependant Class(es):JsonDataController_Test
*    -     
*
* 6. Test Class Name: 
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    - Vishwas & Created Date(2024.12.04)
*    -
*************************************************************/
public class jsonDataController {
   @AuraEnabled
    public static string saveJsonData(string recId){
        if(recId != null && recId !=''){
        List<Order_Entry_Data__c> orderEntryDataList=[SELECT id,json_data__c from Order_Entry_Data__c where Id=:recId];
            if(orderEntryDataList != null && !orderEntryDataList.isEmpty()){
              return  orderEntryDataList[0].json_data__c; 
            }else
                return null;
             
        }else{
            return null;
        }
            
    }
    @AuraEnabled
    public static List<ERP_address__c> fetchRelatedAddress(string recId){
      List<ERP_address__c> ERPList=[SELECT Id,Name,Address_Type__c,ERP_Sales_Org__c,fxECOM_Target_VAT__c,fxERPName_full__c,fxCustomerNumber_Target__c,fxAddressFull__c from ERP_Address__c Where Address_Type__c IN ('Ship To','Bill To','Payer') AND Master_address__c=:recId];
     //   List<ERP_address__c> ERPList=[SELECT Id,Name,Address_Type__c,ERP_Sales_Org__c,fxECOM_Target_VAT__c,fxERPName_full__c,fxCustomerNumber_Target__c,fxAddressFull__c from ERP_Address__c Where  Master_address__c=:recId];
       return ERPList;
    }
   
}