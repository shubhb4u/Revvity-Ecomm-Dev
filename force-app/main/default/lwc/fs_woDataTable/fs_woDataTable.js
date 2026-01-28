/**
 * 2025-02-19  Kaustav Chanda(SFS IT Team) created for JIRA SFS-4, Service Report
 * 2025-05-20  Kaustav Chanda(SFS IT Team) updated (FSR font Size, description Pattern and logic for Contract PM WO) for JIRA SFS-4
 * 2025-06-05  Kaustav Chanda(SFS IT Team) updated of showacsing the pricing details (unit price, discounts) as per the request RITM0199555
 * 2025-07-28  Kaustav Chanda(SFS IT Team) updated for implementing trnaslation functionality (Source: RITM0200288)
 */
import { LightningElement, api, wire, track} from 'lwc';
import getWorkOrderData from '@salesforce/apex/FS_WorkOrderController.getWorkOrderData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import ORG_TIMEZONE from '@salesforce/i18n/timeZone';

export default class WoDataTable extends LightningElement {
    @api recordId;
    @track workOrderData;
    //workPerfomed = []; //array to store parsed description data
    @track calibratedWoliList = [];
    @track partsWoliList = [];
    @track laborTravelWoliList = [];
    @track serviceDocuments = [];
    @track translationRecord = [];
    totalListPriceWO;
    withPricingTemplate = 'Field_Service_Report_Pricing_Tools';
    isWithPricing = false;

    @wire(getWorkOrderData, { workOrderId: '$recordId' })
    wiredWorkOrder({ error, data }) {
        if (data) {
            this.workOrderData = data;
            // console.log('<<work performed>>', data.description);
            //this.workPerformedSentences(data.description);
            console.log('callibrated tools are empty', data.calibratedWorkOrderLineItems);
            this.totalListPriceWO = data.totalListPrice;

            this.isWithPricing = data.documentDeveloperName.includes(this.withPricingTemplate);
            console.log('isWithPricing', this.isWithPricing);

            console.log('billing=>', data.billingType);
            console.log('order=>', data.activityCode);

            this.calibratedWoliList = data.calibratedWorkOrderLineItems.map(item => {
                return {
                    Quantity:(item.Quantity__c != null || item.Quantity__c != undefined)?item.Quantity__c:'N/A',
                    CallibratedTool:(item.Calibrated_Tool__r.Name != null || item.Calibrated_Tool__r.Name != undefined)?item.Calibrated_Tool__r.Name:'N/A',
                    ToolsDescription:(item.fxCalibratedTool_Description__c != null || item.fxCalibratedTool_Description__c != undefined)?item.fxCalibratedTool_Description__c:'N/A',
                    ToolsSerialNum:(item.fxCalibratedTool_SerialNumber__c != null || item.fxCalibratedTool_SerialNumber__c != undefined)?item.fxCalibratedTool_SerialNumber__c :'N/A',
                    LastCallibratedTool: this.formateDateTime(item.fxCalibratedTool_LastCalibrationDate__c),
                    NextCallibratedTool:(item.fxCalibratedTool_NextCalibrationDate__c!=null||item.fxCalibratedTool_NextCalibrationDate__c!=undefined)?new Date(item.fxCalibratedTool_NextCalibrationDate__c).toISOString().split('T')[0]:'N/A'
                }
            });
            this.partsWoliList = data.partWorkOrderLineItems.map(item =>{
                return {
                    PartNumber: (item.Part_Number__c != null || item.Part_Number__c != undefined)?item.Part_Number__c:'N/A',
                    MaterialPartDesc: (item.Material_Part_Description__c != null || item.Material_Part_Description__c != undefined)?item.Material_Part_Description__c:'N/A',
                    WorkDescription: (item.Work_Description__c != null || item.Work_Description__c != undefined)?item.Work_Description__c:'N/A',
                    MaterialSerialNum: (item.fxSerialNumber__c != null || item.fxSerialNumber__c != undefined)?item.fxSerialNumber__c:'N/A',
                    MaterialQty: (item.Quantity__c != null || item.Quantity__c != undefined)?Number(item.Quantity__c).toFixed(2):'N/A',
                    UnitPrice: (item.ReplacementBasePrice__c != null || item.ReplacementBasePrice__c != undefined)?Number(item.ReplacementBasePrice__c).toFixed(2):
                               (item.Unit_Price__c != null || item.Unit_Price__c != undefined)?Number(item.Unit_Price__c).toFixed(2):'N/A',
                    Discount: (item.ServiceAmountAdjustment__c != null || item.ServiceAmountAdjustment__c != undefined)?this.formatCurrency(item.fxCalculated_Discount_Currency__c):
                              (item.fxCalculated_Discount__c != null || item.fxCalculated_Discount__c != undefined)?Number(item.fxCalculated_Discount__c).toFixed(2)+'%':'N/A',
                    IsFullContractDiscoutParts: (item.ContractPercentDiscount__c === 100 && this.isContractPM(data.billingType, data.activityCode))?true:false,
                    Totalprice: (item.fxCalculatedLinePrice__c != null || item.fxCalculatedLinePrice__c != undefined)?Number(item.fxCalculatedLinePrice__c).toFixed(2):'N/A'
                }
            });
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
                     LaborDiscount: (item.ServiceAmountAdjustment__c != null || item.ServiceAmountAdjustment__c != undefined)?this.formatCurrency(item.fxCalculated_Discount_Currency__c):
                                    (item.fxCalculated_Discount__c != null || item.fxCalculated_Discount__c != undefined)?Number(item.fxCalculated_Discount__c).toFixed(2)+'%':'N/A',
                     IsFullLaborTravelDiscounts: (item.ContractPercentDiscount__c === 100 && this.isContractPM(data.billingType, data.activityCode))?true:false,
                     LaborTotalprice: (item.fxCalculatedLinePrice__c != null || item.fxCalculatedLinePrice__c != undefined)?Number(item.fxCalculatedLinePrice__c).toFixed(2):'N/A'
                }
            });
        // this.translationRecord = data.tanslationData.map(tr =>{
        //     return {
        //         woNumber : tr.Work_Order_Number__c,
        //         activityCode: tr.Activity_Code__c,
        //         billingType: tr.Billing_Type__c,
        //         requiredStartDate: tr.Requested_Start_Date__c,
        //         model: tr.Model__c,
        //         serialNumber: tr.Serial_Number__c
        //     }
        // });
        this.translationRecord = [{
            woNumber : data.tanslationData.Work_Order_Number__c,
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
            estimateNumber: data.tanslationData.Service_Estimate__c,
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
            totalPrice: data.tanslationData.Total_Price__c,
            toolsUsed: data.tanslationData.Tools_Used__c,
            calibratedTool: data.tanslationData.Calibrated_Tool__c,
            toolsDesc: data.tanslationData.Description__c,
            lastCalibrationDate: data.tanslationData.Last_Calibration_Date__c,
            nextCalibrationDate: data.tanslationData.Next_Calibration_Date__c,
            materialsUsed: data.tanslationData.Material_Used__c,
            lotSerialNumber: data.tanslationData.Lot_Serial_Number__c,
            totalAmountBeforeTax: data.tanslationData.Total_Amount_before_taxes__c
        }];
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // @wire(getServiceDocuments)
    // wiredServiceDocuments({ error, data }) {
    //     if (data) {
    //         this.serviceDocuments = data.map(doc => doc.DeveloperName);
    //         console.log('service documents', this.serviceDocuments);

    //         this.isWithPricing = this.serviceDocuments.includes(this.withPricingTemplate);
    //         console.log('isWithPricing', this.isWithPricing);

    //         this.isNoPricing = this.serviceDocuments.includes(this.noPricingTemplate);
    //         console.log('isNoPricing', this.isNoPricing);
    //     } else {
    //         console.error(error);
    //     }
    // }

    // @api
    // getWorkOrderData() {
    //     return this.workOrderData;
    // }

    showErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading Work Order',
                message: error.body.message,
                variant: 'error'
            })
        );
    }

    get isDataEmpty(){
        console.log('getter called');
        if(this.calibratedWoliList.length === 0){
            return true;
        }else{
            console.log('getter else executed');
            return false;
        }
    }
    get formattedTotalAmount(){
        const formatted = new Intl.NumberFormat('en-US', {style: 'currency', currency: this.workOrderData.currencyCode}).format(this.totalListPriceWO);
        return formatted.replace('$','$\u00A0'); //inset a non-breaking space after $
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
    formatCurrency(value){
        let numericValue = parseFloat(value.replace('$', ''));
        return `$${numericValue.toFixed(2)}`;
    }
}