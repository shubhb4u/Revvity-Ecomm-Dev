/**
 * 2025-02-19  Kaustav Chanda(SFS IT Team) created for JIRA SFS-4, Service Report
 */
import { LightningElement, api, track, wire} from 'lwc';
import saveSignatureWithRole from '@salesforce/apex/FS_SignatureController.saveSignatureWithRole';
import getWorkOrderData from '@salesforce/apex/FS_WorkOrderController.getWorkOrderData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import ORG_TIMEZONE from '@salesforce/i18n/timeZone';

export default class ESignature extends LightningElement {
    @api recordId;
    @api selectedRole;

    @track isDrawing = false;
    @track signatureDataUrl = null;
    @track name = '';
    @track email = '';
    lastX = 0;
    lastY = 0;
    canvas;
    ctx;
    @track isSignatureNotDone = true;
    @track isNameBlank = true;
    technicianName;
    customerName;
    isCustomer = false;
    isTechnician = false;

    connectedCallback(){
        this.handleRole();
    }
    renderedCallback(){
        this.canvas = this.template.querySelector('canvas');
        console.log('Canvas State: ' + this.canvas.toDataURL('image/png'));
        this.ctx = this.canvas.getContext('2d');
        this.ctx.strokeStyle = 'black';
        this.ctx.lineWidth = 2;
        //add watermark
        this.addWatermark();
    }

    // get roleOptions() {
    //     return [
    //         { label: 'Customer', value: 'Customer__c' },
    //         { label: 'Technician', value: 'Technician__c' }
    //     ];
    // }

    // handleRoleChange(event) {
    //     this.selectedRole = event.target.value;
    // }
    handleRole(){
        if(this.selectedRole === 'Customer__c'){
            this.isCustomer = true;
        }else if(this.selectedRole === 'Technician__c'){
            this.isTechnician = true;
        }
    }
    @wire(getWorkOrderData , {workOrderId : '$recordId'})
    workOrderData({data,error}){
        if(data){
            this.technicianName = data.serviceRepresentativeName;
            this.customerName = data.contactName;
        }else{
            console.error(error);
        }
    }
    nameHandler(event){
        this.name = event.target.value;
        this.validateName();
    }

    validateName(){
        this.isNameBlank = this.name.trim() !== '';
    }
    emailHandler(event){
        this.email= event.target.value;
    }

    handleMouseDown(event) {
        this.isDrawing = true;
        const rect = event.target.getBoundingClientRect();
        this.lastX = event.clientX - rect.left;
        this.lastY = event.clientY - rect.top;
    }

    handleTouchStart(event) {
        this.isDrawing = true;
        const rect = event.target.getBoundingClientRect();
        const touch = event.touches[0];
        this.lastX = touch.clientX - rect.left;
        this.lastY = touch.clientY - rect.top;
        event.preventDefault(); // Prevent scrolling
    }

    handleMouseUp() {
        this.isDrawing = false;
    }

    handleTouchEnd(event) {
        this.isDrawing = false;
        event.preventDefault(); // Prevent scrolling
    }

    addWatermark(){
        //Get current date/time
        const now = new Date();
        console.log('<<<now>>>', now);

        const options = {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false,
            timeZone: ORG_TIMEZONE
        };

        const formattedDateTime = new Intl.DateTimeFormat(LOCALE, options);

        const parts = formattedDateTime.formatToParts(now);

        const year = this.getPartValue(parts,'year');
        const month = this.getPartValue(parts,'month');
        const day = this.getPartValue(parts,'day');
        const hours = this.getPartValue(parts,'hour');
        const minutes = this.getPartValue(parts,'minute');

        const finalDateTime = `${year}-${month}-${day}, ${hours}:${minutes}`;

        //Watermark part
        this.ctx.font = '20px Arial';
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
        this.ctx.fillText(finalDateTime, this.canvas.width - 210, this.canvas.height - 85);
    }

    getPartValue(parts, type){
        const part = parts.find(part => part.type === type);
        return part?part.value : '';
    }

    handleMouseMove(event) {
        if (!this.isDrawing) return;
        const rect = this.canvas.getBoundingClientRect();
        const x = event.clientX - rect.left;
        const y = event.clientY - rect.top;
        this.draw(this.ctx, x, y);
        this.lastX = x;
        this.lastY = y;
    }

    handleTouchMove(event) {
        if (!this.isDrawing) return;
        const rect = this.canvas.getBoundingClientRect();
        const touch = event.touches[0];
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;
        this.draw(this.ctx, x, y);
        this.lastX = x;
        this.lastY = y;
        event.preventDefault(); // Prevent scrolling
    }

    draw(ctx1, x, y) {
        ctx1.beginPath();
        ctx1.moveTo(this.lastX, this.lastY);
        ctx1.lineTo(x, y);
        ctx1.stroke();
        ctx1.closePath();
        this.isSignatureNotDone = false;
    }

    clearCanvas() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.signatureDataUrl = null;
        this.lastX = 0;
        this.lastY = 0;
        this.addWatermark();
        this.isSignatureNotDone = true;
    }

    saveSignature() {
        if (!this.selectedRole) {
            this.showToast('Error', 'Please select a role before saving the signature.', 'error');
            return;
        }
        this.signatureDataUrl = this.canvas.toDataURL('image/png');

        console.log('validate input', this.isNameBlank);
        
        if(this.isSignatureNotDone){
            this.showToast('Error', 'Please sign before proceed ahead!', 'error');
        }else if(!this.isNameBlank){
            this.showToast('Error', 'Please enter your name', 'error');
        }else{
            saveSignatureWithRole({
                recordId: this.recordId,
                fieldName: this.selectedRole,
                signatureData: this.signatureDataUrl,
                name: this.name,
                email: this.email,
                custName: this.customerName,
                techName: this.technicianName
            })
            .then((data) => {
                    this.showToast('Success', 'Signature saved successfully!', 'success');
                    //this.clearCanvas();
                        console.log('<<<data>>>'+data);
                        this.dispatchEvent(new CustomEvent('signaturecomplete', {
                            detail: data //this.signatureDataUrl
                        }))
            }).catch((error) => {
                console.error('Error saving signature:', error);
                this.showToast('Error', 'Error saving signature: ' + error.body.message, 'error');
            });
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}