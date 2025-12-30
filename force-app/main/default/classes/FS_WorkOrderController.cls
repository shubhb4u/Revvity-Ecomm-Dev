/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    SFS-4    

* 2. Description - This class is worked as main controlles class
                   of fs_pdfGenerator and fs_pdfGeneratorEstimate
                   LWC component.
                 - Taking WorkOrderId as an Input and fetching WO data,
                   along with it's related object(Asset, Contact, Translation etc.).
                 - Returned workorder data.
*

* 3. Objects referenced
*    -WorkOrder

* 4. Callouts to additional Components (including their methods) or None:
*    - None

* 5. Dependant Class(es):
*    - None
	
* 6. Test Class Name: FS_WorkOrderControllerTest

* 7. Is @Invocable (Yes or No): Yes

* 8. Author Name(s):
*    - Kaustav Chanda 2025.02.19
*    - Kaustav Chanda 2025.06.05 updated for RITM0199554 & RITM0199555
*    - Kaustav Chanda 2025.07.28 updated for implementing trnaslation functionality (Source: RITM0200288)
*************************************************************/
public without sharing class FS_WorkOrderController {
    @AuraEnabled(cacheable=true)
    public static WorkOrderData getWorkOrderData(Id workOrderId) {
        WorkOrderData data = new WorkOrderData();
        WorkOrder workOrder = [SELECT WorkOrderNumber, SAP_ActivityType__c, Billing_Type__c, Order_Type__c, Customer_Required_Start_Date__c, ModelSeries__c, fxAsset_Serial_Number__c,
                               Assigned_Resource_Name__c, Equipment_ID__c, System_ID__c,CaseId,ContactId,Location.Name,Location.Street__c,
                               Location.City__c,Location.State__c,Location.Zip__c,Location.Country__c,ServiceDocumentTemplate,
                               BillTo__r.fxCustomerName_Target__c,BillTo__r.fxAddressFull__c, Customer_PO_Billable__c,Work_Performed__c,
                               Total_Calculated_Amount__c, CurrencyIsoCode, AssetId, fxEstimate_Expiry_Date__c, Description, Translation__c,Total_Discount__c
                               FROM WorkOrder WHERE Id = :workOrderId];
       FS_Translation__c transl = [SELECT Id, Work_Order_Number__c,Activity_Code__c,Billing_Type__c, 
                                   Requested_Start_Date__c, Model__c,Serial_Number__c,Service_Representative_Name__c,
                                   Contract_Number__c,Contract_End_Date__c,Equipment__c,System_ID__c,UDI_Number__c,
                                   Service_Estimate__c,Equipment_Location__c,Bill_To_Name__c,Customer_Name__c,Phone_Number__c,
                                   Fax_Number__c,Email__c,Purchase_Order__c,Work_Description__c,Labor_Details__c,Part_Number__c,Part_Description__c,
                                   Start_Date__c,End_Date__c,Quantity__c,Unit_Price__c,Discount__c,Total_Price__c,Tools_Used__c,Calibrated_Tool__c,
                                   Description__c,Last_Calibration_Date__c,Next_Calibration_Date__c,Material_Used__c,Expiry_Date__c,
                                   Lot_Serial_Number__c,Total_Amount_before_taxes__c,Customer_Signature__c,Technician_Signature__c,Total_Discount__c
                                   FROM FS_Translation__c
                                   WHERE Id = :workOrder.Translation__c];
        
        Id assetId = workOrder.AssetId;
        Asset assetRecord = [SELECT Id, UDI_Number__c, External_ID__c FROM Asset WHERE Id = :assetId];
        List<ContractLineItem> contractData = [SELECT Id, Parent_Contract__r.Name, EndDate FROM ContractLineItem WHERE AssetId =:assetId AND Status ='Active' LIMIT 1];
        List<Contact> con = [SELECT Id, Name, Phone, Email, Fax FROM Contact WHERE Id = :workOrder.ContactId LIMIT 1];
        C_META_FS_Service_Document__mdt serviceDocument = [SELECT Service_Document_Id__c, DeveloperName, MasterLabel, Object_Type__c, Document_Type__c
                                                           FROM C_META_FS_Service_Document__mdt
                                                           WHERE Service_Document_Id__c = :workOrder.ServiceDocumentTemplate];
        List<WorkOrderLineItem> filteredWOLI = [SELECT Id, StartDate, EndDate, Work_Description__c, Part_Number__c,
                                                Material_Part_Description__c,Quantity__c,Unit_Price__c,ReplacementBasePrice__c,
                                                fxCalculated_Discount__c,fxCalculated_Discount_Currency__c, fxCalculatedLinePrice__c,
                                                ServiceAmountAdjustment__c,ContractPercentDiscount__c
                                                FROM WorkOrderLineItem
                                                WHERE WorkOrderId = :workOrderId 
                                                AND Line_Type__c != 'Fault Code'
                                                AND (Line_Type__c = 'Labor' OR Line_Type__c = 'Travel')
                                                AND ((StartDate != null AND EndDate != null AND WorkOrder.Record_Type__c = 'Field Service') OR WorkOrder.Record_Type__c = 'Estimate')
                                                AND Status != 'Canceled'];
        List<WorkOrderLineItem> calibratedWOLI = [SELECT Id,Quantity__c,Calibrated_Tool__r.Name,fxCalibratedTool_Description__c,
                                                  fxCalibratedTool_SerialNumber__c,fxCalibratedTool_LastCalibrationDate__c,
                                                  fxCalibratedTool_NextCalibrationDate__c
                                                  FROM WorkOrderLineItem
                                                  WHERE WorkOrderId = :workOrderId 
                                                  AND Line_Type__c = 'Calibrated Tool'];
        List<WorkOrderLineItem> partsWOLI = [SELECT Id,Part_Number__c,Material_Part_Description__c,Work_Description__c,
                                             fxSerialNumber__c,Quantity__c,Unit_Price__c,fxCalculated_Discount__c,fxCalculated_Discount_Currency__c,
                                             fxCalculatedLinePrice__c,ReplacementBasePrice__c,ServiceAmountAdjustment__c,ContractPercentDiscount__c
                                             FROM WorkOrderLineItem
                                             WHERE WorkOrderId = :workOrderId 
                                             AND Line_Type__c = 'Parts' AND Status != 'Canceled'];
        data.workOrderNumber = workOrder.WorkOrderNumber;
        data.activityCode = workOrder.Order_Type__c!=null?workOrder.Order_Type__c:'N/A';
        data.billingType = workOrder.Billing_Type__c != null?workOrder.Billing_Type__c:'N/A';
        data.requestedStartDate = workOrder.Customer_Required_Start_Date__c;
        data.model = workOrder.ModelSeries__c!=null?workOrder.ModelSeries__c:'N/A';
        data.serialNumber = workOrder.fxAsset_Serial_Number__c!=null?workOrder.fxAsset_Serial_Number__c:'N/A';
        data.serviceRepresentativeName = workOrder.Assigned_Resource_Name__c!=null?workOrder.Assigned_Resource_Name__c:'N/A';
        if(contractData.size()==1){
           data.contractNumber = contractData[0].Parent_Contract__r.Name;
           data.expiryDate = contractData[0].EndDate;
        }else{
            data.contractNumber='N/A';
            data.expiryDate= null;
        }
        
        data.equipmentID = assetRecord.External_ID__c != null?assetRecord.External_ID__c:'N/A';
        data.systemID = workOrder.System_ID__c!=null?workOrder.System_ID__c:'N/A';
        data.equipmentLocationName = workOrder.Location.Name!=null?workOrder.Location.Name:'N/A';
        data.equipmentLocationStreet = workOrder.Location.Street__c;
        data.equipmentLocationCity = workOrder.Location.City__c;
        data.equipmentLocationState = workOrder.Location.State__c;
        data.equipmentLocationZip = workOrder.Location.Zip__c;
        data.equipmentLocationCountry = workOrder.Location.Country__c;
        data.billToCustomerName = workOrder.BillTo__r.fxCustomerName_Target__c!=null?workOrder.BillTo__r.fxCustomerName_Target__c:'N/A';
        data.billToCustomerAddress = workOrder.BillTo__r.fxAddressFull__c!=null?workOrder.BillTo__r.fxAddressFull__c:'N/A';
        if(con.size()==1){
            data.contactName = con[0].Name;
            data.contactPhone = con[0].Phone;
            data.contactFax = con[0].Fax;
            data.contactEmail = con[0].Email;
        }else{
            data.contactName ='N/A';
            data.contactPhone ='N/A';
            data.contactFax ='N/A';
            data.contactEmail ='N/A';
        }
        data.purchaseOrder = workOrder.Customer_PO_Billable__c != null? 
                             workOrder.Customer_PO_Billable__c: 'N/A';
        data.description = workOrder.Work_Performed__c!=null?workOrder.Work_Performed__c:'N/A';
        data.totalListPrice = workOrder.Total_Calculated_Amount__c;
        data.filteredworkOrderLineItems = filteredWOLI;
        data.assetUDINum = assetRecord.UDI_Number__c != null ? assetRecord.UDI_Number__c : 'N/A';
        data.calibratedWorkOrderLineItems = calibratedWOLI;
        data.partWorkOrderLineItems = partsWOLI;
        data.currencyCode = workOrder.CurrencyIsoCode;
        data.documentDeveloperName = serviceDocument.DeveloperName;
        data.estimateExpiryDate = workOrder.fxEstimate_Expiry_Date__c;
        data.estimateDescription = workOrder.Description!=null?workOrder.Description:'N/A';
        data.tanslationData = transl;
        data.totalDiscount = workOrder.Total_Discount__c;
        return data;
    }
    public class WorkOrderData {
        @AuraEnabled public String workOrderNumber;
        @AuraEnabled public String activityCode;
        @AuraEnabled public String billingType;
        @AuraEnabled public Date requestedStartDate;
        @AuraEnabled public String model;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String serviceRepresentativeName;
        @AuraEnabled public String contractNumber;
        @AuraEnabled public Date expiryDate;
        @AuraEnabled public String equipmentID;
        @AuraEnabled public String systemID;
        @AuraEnabled public String equipmentLocationName;
        @AuraEnabled public String equipmentLocationStreet;
        @AuraEnabled public String equipmentLocationCity;
        @AuraEnabled public String equipmentLocationState;
        @AuraEnabled public String equipmentLocationZip;
        @AuraEnabled public String equipmentLocationCountry;
        @AuraEnabled public String assetUDINum;
        @AuraEnabled public String billToCustomerName;
        @AuraEnabled public String billToCustomerAddress;
        @AuraEnabled public String purchaseOrder;
        @AuraEnabled public String contactName;
        @AuraEnabled public String contactPhone;
        @AuraEnabled public String contactFax;
        @AuraEnabled public String contactEmail;
        @AuraEnabled public String description;
        @AuraEnabled public decimal totalListPrice;
        @AuraEnabled public List<WorkOrderLineItem> filteredworkOrderLineItems;
        @AuraEnabled public List<WorkOrderLineItem> calibratedWorkOrderLineItems;
        @AuraEnabled public List<WorkOrderLineItem> partWorkOrderLineItems;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String documentDeveloperName;
        @AuraEnabled public Date estimateExpiryDate;
        @AuraEnabled public String estimateDescription;
        @AuraEnabled public FS_Translation__c tanslationData;
        @AuraEnabled public decimal totalDiscount;
    }
}