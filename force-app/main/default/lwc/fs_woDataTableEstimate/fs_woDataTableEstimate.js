/**
 * 2025-06-05  Kaustav Chanda(SFS IT Team) created for RITM0199554, Service Report for estimate
 * 2025-07-30  Kaustav Chanda(SFS IT Team) updated for implementing trnaslation functionality (Source: RITM0200288)
 * 2035-08-19  Kaustav Chanda(SFS IT Team) updated for showing total discount table (Source: RITM0197458)
 */
import { LightningElement,api,track,wire } from 'lwc';
import getWorkOrderData from '@salesforce/apex/FS_WorkOrderController.getWorkOrderData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import ORG_TIMEZONE from '@salesforce/i18n/timeZone';

export default class Fs_woDataTableEstimate extends LightningElement {
    @api recordId;
    @track workOrderData;
    //workPerfomed = []; //array to store parsed description data
    @track partsWoliList = [];
    @track laborTravelWoliList = [];
    @track serviceDocuments = [];
    @track translationRecord = [];
    totalListPriceWO;
    totalDiscount;
    isWithPricing = false;
    isDiscount = false;

    @wire(getWorkOrderData, { workOrderId: '$recordId' })
    wiredWorkOrder({ error, data }) {
        if (data) {
            this.workOrderData = data;
            // console.log('<<work performed>>', data.description);
            //this.workPerformedSentences(data.description);
            //console.log('callibrated tools are empty', data.calibratedWorkOrderLineItems);
            this.totalListPriceWO = data.totalListPrice;
            this.totalDiscount = data.totalDiscount;

            console.log('template name: ', data.documentDeveloperName);
            // this.isWithPricing = this.withPricingTemplates.some(template => data.documentDeveloperName.includes(template));
            this.isWithPricing = this.checkTemplateName(data.documentDeveloperName);
            console.log('isWithPricing', this.isWithPricing);
            this.isDiscount = this.checkTemplateWithDiscout(data.documentDeveloperName);
            

            console.log('billing=>', data.billingType);
            console.log('order=>', data.activityCode);

            if(data.partWorkOrderLineItems.length > 0){
            this.partsWoliList = data.partWorkOrderLineItems.map(item =>{
                return {
                    PartNumber: (item.Part_Number__c != null || item.Part_Number__c != undefined)?item.Part_Number__c:'N/A',
                    MaterialPartDesc: (item.Material_Part_Description__c != null || item.Material_Part_Description__c != undefined)?item.Material_Part_Description__c:'N/A',
                    WorkDescription: (item.Work_Description__c != null || item.Work_Description__c != undefined)?item.Work_Description__c:'N/A',
                    MaterialSerialNum: (item.fxSerialNumber__c != null || item.fxSerialNumber__c != undefined)?item.fxSerialNumber__c:'N/A',
                    MaterialQty: (item.Quantity__c != null || item.Quantity__c != undefined)?Number(item.Quantity__c).toFixed(2):'N/A',
                    UnitPrice: (item.ReplacementBasePrice__c != null || item.ReplacementBasePrice__c != undefined)?Number(item.ReplacementBasePrice__c).toFixed(2):
                               (item.Unit_Price__c != null || item.Unit_Price__c != undefined)?Number(item.Unit_Price__c).toFixed(2):'N/A',
                    Discount: (item.ServiceAmountAdjustment__c != null || item.ServiceAmountAdjustment__c != undefined)?item.fxCalculated_Discount_Currency__c:
                              (item.fxCalculated_Discount__c === 0)?'':
                              (item.fxCalculated_Discount__c != null || item.fxCalculated_Discount__c != undefined)?Number(item.fxCalculated_Discount__c).toFixed(2)+'%':'',
                    IsFullContractDiscoutParts: (item.ContractPercentDiscount__c === 100 && this.isContractPM(data.billingType, data.activityCode))?true:false,
                    Totalprice: (item.fxCalculatedLinePrice__c != null || item.fxCalculatedLinePrice__c != undefined)?Number(item.fxCalculatedLinePrice__c).toFixed(2):''
                }
            });
        }
            if(data.filteredworkOrderLineItems.length > 0){
                this.laborTravelWoliList = data.filteredworkOrderLineItems.map(item =>{
                console.log('Description', item.Description);
                console.log('Discount', item.ContractPercentDiscount__c);
                return {
                     PartNumber: (item.Part_Number__c != null || item.Part_Number__c != undefined)?item.Part_Number__c:'N/A',
                     MaterialPartDesc: (item.Material_Part_Description__c != null || item.Material_Part_Description__c != undefined)?item.Material_Part_Description__c:'N/A',
                     LaborTravelStartDate: this.formateDateTime(item.StartDate),
                     LaborTravelEndDate: this.formateDateTime(item.EndDate),
                     LaborDescription: (item.Work_Description__c === undefined)?'N/A':item.Work_Description__c,
                     LaborTravelQty: (item.Quantity__c != null || item.Quantity__c != undefined)?Number(item.Quantity__c).toFixed(2):'N/A',
                     LaborUnitPrice: (item.ReplacementBasePrice__c != null || item.ReplacementBasePrice__c != undefined)?Number(item.ReplacementBasePrice__c).toFixed(2):
                                     (item.Unit_Price__c != null || item.Unit_Price__c != undefined)?Number(item.Unit_Price__c).toFixed(2):'N/A',
                     LaborDiscount: (item.ServiceAmountAdjustment__c != null || item.ServiceAmountAdjustment__c != undefined)?item.fxCalculated_Discount_Currency__c:
                                    (item.fxCalculated_Discount__c === 0)?'':    
                                    (item.fxCalculated_Discount__c != null || item.fxCalculated_Discount__c != undefined)?Number(item.fxCalculated_Discount__c).toFixed(2)+'%':'',
                     IsFullLaborTravelDiscounts: (item.ContractPercentDiscount__c === 100 && this.isContractPM(data.billingType, data.activityCode))?true:false,
                     LaborTotalprice: (item.fxCalculatedLinePrice__c != null || item.fxCalculatedLinePrice__c != undefined)?Number(item.fxCalculatedLinePrice__c).toFixed(2):'N/A'
                }
              });
            }

            if (data.tanslationData != null || data.tanslationData != undefined) {
                this.translationRecord = [{
                    estimateNumber: data.tanslationData.Service_Estimate__c,
                    activityCode: data.tanslationData.Activity_Code__c,
                    billingType: data.tanslationData.Billing_Type__c,
                    requiredStartDate: data.tanslationData.Requested_Start_Date__c,
                    model: data.tanslationData.Model__c,
                    serialNumber: data.tanslationData.Serial_Number__c,
                    resourceName: data.tanslationData.Service_Representative_Name__c,
                    contractNumber: data.tanslationData.Contract_Number__c,
                    contractExpiryDate: data.tanslationData.Contract_End_Date__c,
                    eqipomentNumber: data.tanslationData.Equipment__c,
                    systemId: data.tanslationData.System_ID__c,
                    udiNumber: data.tanslationData.UDI_Number__c,
                    estimateExpiryDate: data.tanslationData.Expiry_Date__c,
                    equipmentLoc: data.tanslationData.Equipment_Location__c,
                    billToName: data.tanslationData.Bill_To_Name__c,
                    customerName: data.tanslationData.Customer_Name__c,
                    phoneNumber: data.tanslationData.Phone_Number__c,
                    faxNumber: data.tanslationData.Fax_Number__c,
                    email: data.tanslationData.Email__c,
                    purchaseOrder: data.tanslationData.Purchase_Order__c,
                    workDesc: data.tanslationData.Work_Description__c,
                    laborTravelDetails: data.tanslationData.Labor_Details__c,
                    partNumber: data.tanslationData.Part_Number__c,
                    partDesc: data.tanslationData.Part_Description__c,
                    startDate: data.tanslationData.Start_Date__c,
                    endDate: data.tanslationData.End_Date__c,
                    quantity: data.tanslationData.Quantity__c,
                    unitPrice: data.tanslationData.Unit_Price__c,
                    discount: data.tanslationData.Discount__c,
                    totalAmountBeforeTax: data.tanslationData.Total_Amount_before_taxes__c,
                    totalDiscount: data.tanslationData.Total_Discount__c,
                    totalPrice: data.tanslationData.Total_Price__c
                }];
            }
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    showErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading Work Order',
                message: error.body.message,
                variant: 'error'
            })
        );
    }
    get formattedTotalAmount(){
        const formatted = new Intl.NumberFormat('en-US', {style: 'currency', currency: this.workOrderData.currencyCode}).format(this.totalListPriceWO);
        return formatted.replace('$','$\u00A0'); //inset a non-breaking space after $
    }
    get formattedTotalDiscount(){
         const formattedDiscount = new Intl.NumberFormat('en-US', {style: 'currency', currency: this.workOrderData.currencyCode}).format(this.totalDiscount);
        return formattedDiscount.replace('$','$\u00A0'); //inset a non-breaking space after $
    }
    formateDateTime(dateTimeStandard){
        if(!dateTimeStandard) return '';

        const date = new Date(dateTimeStandard);

        //Based on LOCALE and Org's Timezone
        const options = {
            timeZone: ORG_TIMEZONE,
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        };
        console.log('locale', LOCALE);
        const formatter =  new Intl.DateTimeFormat(LOCALE, options);
        const parts = formatter.formatToParts(date);

        const year = this.getPartValue(parts, 'year');
        const month = this.getPartValue(parts, 'month');
        const formattedDate = this.getPartValue(parts,'day');
        const hours = this.getPartValue(parts,'hour');
        const minutes = this.getPartValue(parts,'minute');

        return `${year}-${month}-${formattedDate}, ${hours}:${minutes}`;
    }

    getPartValue(parts, type){
        const part = parts.find(part => part.type === type);
        return part?part.value : '';
    }
    isContractPM(billingType, orderType){
        console.log('getContractPM Calling')
        if(billingType === 'Contract' && orderType === 'Planned Maintenance'){
            console.log('billing=>', billingType);
            console.log('order=>', orderType);
            return true;
        }else{
            return false;
        }
    }
    checkTemplateName(data){
        if(data === 'Estimate_Report_With_Pricing'){
            return true;
        }else{
            return false;
        }
    }
    checkTemplateWithDiscout(docName){
        if(docName === 'Estimate_Report_With_Pricing' && this.totalDiscount !== 0){
            return true;
        }else{
            return false;
        }
    }
}