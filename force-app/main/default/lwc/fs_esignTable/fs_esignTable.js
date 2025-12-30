/**
 * 2025-03-24  Kaustav Chanda(SFS IT Team) created for JIRA SFS-4, Service Report
 * 2025-07-28  Kaustav Chanda(SFS IT Team) updated for implementing trnaslation functionality (Source: RITM0200288)
 */
import { api, LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CUSTOMER_SIGNATURE_FIELD from '@salesforce/schema/WorkOrder.Customer__c';
import CUSTOMER_NAME_FIELD from '@salesforce/schema/WorkOrder.Logged_In_Customer_Name__c';
import CUSTOMER_EMAIL_FIELD from '@salesforce/schema/WorkOrder.Logged_In_Customer_Email__c';
import TECHNICIAN_NAME_FIELD from '@salesforce/schema/WorkOrder.Logged_In_Technician_Name__c';
import TECHNICIAN_EMAIL_FIELD from '@salesforce/schema/WorkOrder.Logged_In_Technician_Email__c';
import TECHNICIAN_SIGNATURE_FIELD from '@salesforce/schema/WorkOrder.Technician__c';
import getWorkOrderData from '@salesforce/apex/FS_WorkOrderController.getWorkOrderData';

const fields = [CUSTOMER_SIGNATURE_FIELD,CUSTOMER_NAME_FIELD,CUSTOMER_EMAIL_FIELD,
                TECHNICIAN_SIGNATURE_FIELD,TECHNICIAN_NAME_FIELD,TECHNICIAN_EMAIL_FIELD];
export default class Fs_esignTable extends LightningElement {
    @api recordId;
    // @api customerSignature;
    // @api technicianSignature;
    customerTechnicianDetails;
    @track translationRecord = [];

    @wire(getRecord, { recordId: '$recordId', fields })
    workOrderData({data,error}){
        if(data){
            this.customerTechnicianDetails = data.fields;
        }else{
            console.error('problem of fetching signature details', error);
        }
    }

    @wire(getWorkOrderData, { workOrderId: '$recordId' })
    wiredTranslationData({data,error}){
        if(data){
            this.translationRecord = [{
                customerSignature: data.tanslationData.Customer_Signature__c,
                customerName: data.tanslationData.Customer_Name__c,
                email: data.tanslationData.Email__c,
                technicianSignature: data.tanslationData.Technician_Signature__c,
                technicianName: data.tanslationData.Service_Representative_Name__c
            }];
        }else{
            console.error('problem of fetching translation details', error);
        }
    }
}