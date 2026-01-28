/*
 * Controller class for fs_eSignature LWC component 
 * 2025-02-19  Kaustav Chanda(SFS IT Team) created for JIRA SFS-4, Service Report
 * Test Class: FS_SignatureControllerTest
*/
public with sharing class FS_SignatureController {
    @AuraEnabled
    public static string saveSignatureWithRole(Id recordId, String fieldName, String signatureData, String name, String email, String custName, String techName) {

        if (String.isEmpty(signatureData) || String.isEmpty(fieldName)) {
            throw new AuraHandledException('Signature or field name is missing.');
        }

        // Decode base64 signature data
        String base64Data = signatureData.split(',')[1];
        String signatureHtml ='<img src="data:image/png;base64,' + base64Data + '" alt="Signature" style="max-width: 100%;"/>';
        
        

        try {
            // Query the Work Order
            WorkOrder workOrder = [
                SELECT Id, Customer__c, Technician__c,Logged_In_Customer_Name__c,
                Logged_In_Customer_Email__c,Logged_In_Technician_Name__c,Logged_In_Technician_Email__c
                FROM WorkOrder 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            // Update the appropriate Rich Text Field
            if (fieldName == 'Customer__c') {
                workOrder.Customer__c = signatureHtml;
                if(String.isBlank(name) && custName != null){
                    workOrder.Logged_In_Customer_Name__c = custName;
                }else{
                    workOrder.Logged_In_Customer_Name__c = name;
                }
                if(String.isNotBlank(email)){
                    workOrder.Logged_In_Customer_Email__c = email;
                }
            } else if (fieldName == 'Technician__c') {
                workOrder.Technician__c = signatureHtml;
                if(String.isBlank(name) && techName != null){
                    workOrder.Logged_In_Technician_Name__c = techName;
                }else{
                    workOrder.Logged_In_Technician_Name__c = name;
                }
                if(String.isNotBlank(email)){
                workOrder.Logged_In_Technician_Email__c = email;
                }
            } else {
                throw new AuraHandledException('Invalid field name.');
            }

            update workOrder;
            return signatureHtml;
        } catch (QueryException e) {
            throw new AuraHandledException('No WorkOrder found for the given ID.');
        } catch (Exception e) {
            throw new AuraHandledException('Error saving signature: ' + e.getMessage());
        }
    }
}