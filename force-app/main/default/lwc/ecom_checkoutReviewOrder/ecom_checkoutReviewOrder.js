import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ssrc_ECOM_Theme from '@salesforce/resourceUrl/ssrc_ECOM_Theme';
import getEmailPreferences from '@salesforce/apex/ECOM_CheckoutController.getEmailPreferences';
import createOrUpdateEmailPreferences from '@salesforce/apex/ECOM_CheckoutController.createOrUpdateEmailPreferences';
import FORM_FACTOR from '@salesforce/client/formFactor';

import ECOM_EmailAddresses from '@salesforce/label/c.ECOM_EmailAddresses';
import ECOM_AdditionalEmailAddresses from '@salesforce/label/c.ECOM_AdditionalEmailAddresses';
import ECOM_Remove from '@salesforce/label/c.ECOM_Remove';
import ECOM_AddAnotherEmailAddress from '@salesforce/label/c.ECOM_AddAnotherEmailAddress';
import ECOM_SaveAndContinue from '@salesforce/label/c.ECOM_SaveAndContinue';

export default class Ecom_checkoutReviewOrder extends NavigationMixin(LightningElement) {
    labels = {
        ECOM_EmailAddresses,
        ECOM_AdditionalEmailAddresses,
        ECOM_Remove,
        ECOM_AddAnotherEmailAddress,
        ECOM_SaveAndContinue
    };

    @api effectiveAccountId;
    @api isReviewReadMode;
    @api isReviewEditMode;
    @api paymetDataMap;
    @api cartId;
    showSpinner = false;
    _newEmailPrefIndex = 0;
    @track
    images = {
        visaimg: ssrc_ECOM_Theme + '/img/visa.png',
        helpimg: ssrc_ECOM_Theme + '/img/checkouttooltip.png',
    }
    device = {
        isMobile : FORM_FACTOR==='Small',
        isDesktop : FORM_FACTOR==='Large',
        isTablet :FORM_FACTOR==='Medium'
    }
    @track isPlaceOrderBtnDisabled = true;
    @track isNewUserListAvailable = false;
    @track newEmailAddressRows = [];
    @track updatedEmailAddressRows = [];
    @track existingEmailAddressRows = [];
    @track accountLvlEmailAddressRows = [];
    @track emailPrefUpdate;
    @track isUpdate = false;
    @track isAdd = false;
    @track renderModal = false;
    @track formattedEmails = [];
    get emailIdList() {
        return this.accountLvlEmailAddressRows.map(emailRow => emailRow.ECOM_Email__c).join(', ');
    }

    connectedCallback(){
        if(this.effectiveAccountId){
            getEmailPreferences({
                effectiveAccountId: this.effectiveAccountId
            }).then((result) => {
                    if(result){
                        if(result.Status == 'Success'){
                            this.accountLvlEmailAddressRows = result?.ListEmailPrefAccountLvl;
                            this.existingEmailAddressRows = result?.ListEmailPrefContactLvl;
                            this.formatEmailRows(this.existingEmailAddressRows);
                        }
                    }  
                })
                .catch((error) => {
                    console.log('error =>'+JSON.stringify(error));
                });
        }
    }

    handleAddEmail(){
        this.template.querySelector('c-ecom_checkout-email-notification-modal')?.openModal();
    }

    handleEmailPreferencesAdded(event){
        let emailRowsToFormat = [];
        let addedEmailRows = event.detail.emailAddressRows;
        for(let key in addedEmailRows){
            let newEmailRow = addedEmailRows[key];
            newEmailRow['emailPrefRowindex'] = this._newEmailPrefIndex.toString();
            let stringifiedRow = JSON.stringify(newEmailRow);
            let parsedRow = JSON.parse(stringifiedRow);
            emailRowsToFormat.push(parsedRow);
            this.newEmailAddressRows.push(parsedRow);
            this.existingEmailAddressRows.push(parsedRow);
            this._newEmailPrefIndex++;
        }
        this.formatEmailRows(emailRowsToFormat);
    }

    formatEmailRows(emailAddressRows){
        for(let i in emailAddressRows){
            let notificationTypes = '';
            if(emailAddressRows[i].ECOM_Order_Confirmation__c){
                notificationTypes += 'Order Confirmation+';
            }
            if(emailAddressRows[i].ECOM_Shipment_Notification__c){
                notificationTypes += 'Shipment Notification';
            }
            notificationTypes = notificationTypes.replace(/\+$/, '');
            notificationTypes = notificationTypes.replaceAll('+', ' & ');
            let formattedEmailRecord = {'id':emailAddressRows[i].Id,'emailPrefRowindex':emailAddressRows[i].emailPrefRowindex,'email': emailAddressRows[i].ECOM_Email__c, 'notificationTypes': notificationTypes};
            if(this.isUpdate){
                let formattedEmailRows = [formattedEmailRecord];
                this.formattedEmails = this.formattedEmails.map(obj => formattedEmailRows.find(o => o.id === obj.id) || obj);
            }
            else{
                this.formattedEmails.push(formattedEmailRecord);
            }

            this.isNewUserListAvailable = this.formattedEmails.length > 0 ? true :false;
            this.isUpdate = false;
        }
    }

    removeEmailPrefList = [];
    handleRemoveEmailPref(event){
        let index = event.target.dataset.index;
        this.formattedEmails.splice(index, 1);
        this.formattedEmails = [...this.formattedEmails];

        let removeEmailPref = {Id: event.target.dataset.id};
        if(removeEmailPref.Id){
            this.removeEmailPrefList.push(removeEmailPref);
        }

        if(event.target.dataset.rowindex){
            let rowIndex = this.newEmailAddressRows.findIndex(item => item.emailPrefRowindex === event.target.dataset.rowindex);
            //delete this.newEmailAddressRows[rowIndex];
            this.newEmailAddressRows.splice(rowIndex, 1);
            this.newEmailAddressRows = [...this.newEmailAddressRows];
            let existingRowIndex = this.existingEmailAddressRows.findIndex(item => item.emailPrefRowindex === event.target.dataset.rowindex);
            this.existingEmailAddressRows.splice(existingRowIndex, 1);
            this.existingEmailAddressRows = [...this.existingEmailAddressRows];
        }
    }

    handleSaveEmailPref(){
        this.showSpinner = true;

        if(this.newEmailAddressRows.length || this.removeEmailPrefList.length){
            //validate first before saving
            createOrUpdateEmailPreferences({
                newEmailAddressRows: JSON.stringify(this.newEmailAddressRows),
                removeEmailPrefList: JSON.stringify(this.removeEmailPrefList)
            }).then((result) => {
                    if(result){
                        if(result.Status == 'Success'){
                            this.showSpinner = false;
                            this.newEmailAddressRows = [];
                        }
                    }
            })
            .catch((error) => {
            });
        }
        this.moveToNextSection();
    }
    moveToNextSection(){
        this.showSpinner = false;
        this.dispatchEvent(
            new CustomEvent('showinvoicesection', {
                detail: {
                    moveToNextSection: true
                }
            })
        );   
    }

}