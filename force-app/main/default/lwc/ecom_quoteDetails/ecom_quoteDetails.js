/**************************************************************
* 1. Jira Ticket(s) that relates to this class :
*    - RWPS-5262
*    - RWPS-5263
 
* 2. Description :
*    LWC component used to display CPQ Quote details including:
*       - Fetching Quote details with line items
*       - Checking PDF generation status for the Quote
*       - Downloading the Quote PDF document
*       - Rendering quote totals, expiration status, and UI formatting
*
* 3. Apex Classes referenced :
*    - ECOM_CPQQuoteWithLinesProxyController.fetchMyQuotesWithLines
*    - ECOM_CPQQuoteDocumentsController.getCPQQuotesDocumentApi
*    - ECOM_CPQQuoteDocumentsController.getCPQQuoteStatusApi
*    - ECOM_CPQQuoteDocumentsController.getbaseUrl
*
* 4. Callouts to additional Components (including their methods):
*    - NavigationMixin (for navigation)
*    - ShowToastEvent (for toast notifications)
*
* 5. Dependant Component(s):
*    - LWC HTML & CSS templates for layout and styling
*
* 6. Test Coverage (LWC Jest Test File):
*    - <Add LWC Test File Here>
*
* 8. Author Name(s):
*    - Devanshi Agrawal
**************************************************************/

import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteById from '@salesforce/apex/ECOM_CPQQuoteWithLinesProxyController.fetchMyQuotesWithLines';
import getCPQQuotesDocumentApi from '@salesforce/apex/ECOM_CPQQuoteDocumentsController.getCPQQuotesDocumentApi';
import getCPQQuoteStatusApi from '@salesforce/apex/ECOM_CPQQuoteDocumentsController.getCPQQuoteStatusApi';
import getbaseUrl from '@salesforce/apex/ECOM_CPQQuoteDocumentsController.getbaseUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ecom_QuoteDetails extends NavigationMixin(LightningElement) {

  quoteNumber;
  status = 'Active';
  currencyCode = 'USD';
  expirationDate;
  baseurl = '';
  res;
  isActive = true;
  isLoading = false;
  error = null;
  quoteId;
  quotes;
  @track currentQuote = {
    SBQQ__ExpirationDate__c: null,
    SBQQ__NetAmount__c: 0,
    SBQQ__LineItemCount__c: 0,
    Lines: [],
    _status: 'Active',
    statusClass: 'ecomm-value ecomm-status--active',
    expiresOnClass: 'ecomm-value',
    expiresOn: ''
  };

  @wire(getbaseUrl)
  wiredata(result) {
    if (result.data) {
      this.baseurl = result.data;
    } else if (result.error) {
      console.error('Base URL Error:', result.error);
    }
  }


  connectedCallback() {

    this.loadStatus();
    const params = new URLSearchParams(window.location.search);
    this.quoteId = params.get('id') || params.get('c__id') || params.get('recordId');
    if (this.quoteId) this.loadQuoteDetails();
  }

  async handleDownload() {
    this.isLoading = true;
    try {
      const dto = await getCPQQuotesDocumentApi({ quoteId: this.quoteId });
      if (dto.message == 'Success') {
        window.location.href = `${this.baseurl}${dto.downloadUrl}`;
      } else {
        this.toast('Download failed', dto?.message || 'Unable to get download URL', 'error');
      }
    } catch (e) {
      const msg = e?.body?.message || e?.message || 'Unexpected error';
      this.toast('Error', msg, 'error');
    } finally {
      this.isLoading = false;
    }
  }

  toast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  async loadStatus() {
    try {
      const url = new URL(window.location.href);
      this.quoteId = url.searchParams.get('id');
      const dto = await getCPQQuoteStatusApi({ quoteId: this.quoteId });
      if (dto.success) {
        this.isActive = dto.success;
      } else {
        this.isActive = false;
      }
    } catch (e) {
      console.error(e);
      alert('Error fetching status of quote pdf.');
    }
  }

  async loadQuoteDetails() {
    this.isLoading = true;
    this.error = null;

    try {
      const result = await getQuoteById({ quoteId: this.quoteId });
      this.quotes = result;
      this.processQuotes();
    } catch (e) {
      this.error = e;
      console.error('Error fetching quote details:', e);
    } finally {
      this.isLoading = false;
    }
  }


  processQuotes() {

    const today = this.startOfDay(new Date());
    const quote = (this.quotes && this.quotes.length > 0) ? this.quotes[0] : null;
    if (!quote) return;

    console.log('Processing quote:', quote);

    const exp = quote.ValidUntil ? new Date(quote.ValidUntil) : null;
    const isExpired = exp ? this.startOfDay(exp) < today : false; 
    const displayStatus = isExpired ? 'Expired' : 'Active';
    this.quoteNumber = quote.Name || '';
    this.status = displayStatus;
    this.expirationDate = quote.ValidUntil || '';

    console.log('Display status:', displayStatus, 'Expires on:', quote.ValidUntil);

    this.currentQuote = {
      ...quote,
      _status: displayStatus,
      statusClass: this.getStatusClass(displayStatus),
      expiresOnClass: this.getExpiresOnClass(displayStatus),
      expiresOn: this.formatDateForUI(quote.ValidUntil),
    };

  }

  startOfDay(d) { const x = new Date(d); x.setHours(0, 0, 0, 0); return x; }

  getStatusClass(status) {
    const s = (status || '').toLowerCase();
    return 'ecomm-value ' + (
      s === 'active' ? 'ecomm-status--active' :
        s === 'expired' ? 'ecomm-status--expired' :
          'ecomm-status--neutral'
    );
  }

  getExpiresOnClass(status) {
    const s = (status || '').toLowerCase();
    return s === 'expired' ? 'ecomm-value ecomm-status--expired' : 'ecomm-value';
  }

  formatDateForUI(value) {
    if (!value) return '';
    const d = value instanceof Date ? value : new Date(value);
    if (isNaN(d.getTime())) return '';

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const monthFull = monthNames[d.getMonth()];
    const monthDisplay = monthFull.length > 4 ? monthFull.slice(0, 3) : monthFull;

    const day = d.getDate();
    const year = d.getFullYear();

    return `${monthDisplay} ${day}, ${year}`;
  }

  handleBackClick(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: `/my-quotes`
      }
    });
  }
}