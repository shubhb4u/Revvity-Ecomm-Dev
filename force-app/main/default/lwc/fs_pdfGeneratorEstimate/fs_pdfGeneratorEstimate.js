/**
 * 2025-06-05  Kaustav Chanda(SFS IT Team) created for JIRA RITM0199554, Service Report for estimate
 */
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CUSTOMER_SIGNATURE_FIELD from '@salesforce/schema/WorkOrder.Customer__c';
import TECHNICIAN_SIGNATURE_FIELD from '@salesforce/schema/WorkOrder.Technician__c';

const fields = [CUSTOMER_SIGNATURE_FIELD, TECHNICIAN_SIGNATURE_FIELD];

export default class Fs_pdfGeneratorEstimate extends LightningElement {
    @api recordId;
    @track isCustomerSignatureModalOpen = false;
    @track isTechnicianSignatureModalOpen = false;
    @track showCustomerSignature = false;
    @track showTechnicianSignature = false;
    @track customerSignatureUrl = '';
    @track technicianSignatureUrl = '';
    technicianSignUrl = '';
    workOrderData;
    workOrderDataAllDetails = [];
    hideCustomerSignatureButton = false;
    hideTechnicianSignatureButton = false;
    showCustomerSignatureButton = false;
    showTechnicianSignatureButton = false;

    connectedCallback(){
        console.log('In connected callback---------');
        setTimeout(()=>{
            this.showCustomerSignatureButton = true;
            this.showTechnicianSignatureButton = true;
        }, 5000);
        console.log('customer button', this.showCustomerSignatureButton);
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredWorkOrder(result) {
        this.workOrderData = result;
        if (result.data) {
            // Reset signatures
            this.customerSignatureUrl = '';
            this.technicianSignatureUrl = '';
            this.showCustomerSignature = false;
            this.showTechnicianSignature = false;
        } else if (result.error) {
            console.error('Error fetching Work Order data:', result.error);
        }
    }

    openCustomerSignatureModal() {
        this.isCustomerSignatureModalOpen = true;
    }

    openTechnicianSignatureModal() {
        this.isTechnicianSignatureModalOpen = true;
    }

    handleCustomerSignatureComplete(event) {
        this.customerSignatureUrl = event.detail;
        this.isCustomerSignatureModalOpen = false;
        this.showCustomerSignature = true;
        this.hideCustomerSignatureButton = true;
        this.showCustomerSignatureButton = false;
    }

    removeCustSignHandler(){
        if(this.customerSignatureUrl != null || this.customerSignatureUrl != ''){
        this.customerSignatureUrl = null;
        this.hideCustomerSignatureButton = false;
        this.showCustomerSignatureButton = true;
        }
    }

    handleTechnicianSignatureComplete(event) {
        this.technicianSignatureUrl = event.detail;
        this.isTechnicianSignatureModalOpen = false;
        this.showTechnicianSignature = true;
        this.hideTechnicianSignatureButton = true;
        this.showTechnicianSignatureButton = false;
        // refreshApex(this.workOrderData);
    }
    removeTechSignHandler(){
        if(this.technicianSignatureUrl != null || this.technicianSignatureUrl != ''){
            this.technicianSignatureUrl = null;
            this.hideTechnicianSignatureButton = false;
            this.showTechnicianSignatureButton = true;
        }
    }

    showSuccessMessage() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'PDF has been generated and saved successfully!',
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
}