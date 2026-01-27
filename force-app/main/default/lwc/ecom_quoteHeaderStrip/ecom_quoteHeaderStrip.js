import { wire, LightningElement } from 'lwc';
import getQuotePdfDownloadUrl from '@salesforce/apex/QuotePdfDownloadRestApi.getQuotePdfDownloadUrl';

export default class Ecom_quoteHeaderStrip extends LightningElement {
    QUOTE_ID = 'a5AO5000003G7OnMAK';
    res;
    async handleDownload() {
        try { 
            console.log('handleDownload');
            this.res = await getQuotePdfDownloadUrl({ quoteId: this.QUOTE_ID });
            console.log('response' , this.res);
            if (!this.res || !this.res.downloadUrl) {
                alert(this.res?.message || 'Unable to locate Quote PDF.');
                return;
            }
            
            window.open(this.res.downloadUrl, '_blank');
        } catch (e) {

            console.error(e.message);
            alert('Error downloading quote PDF.');
        }
    }
}