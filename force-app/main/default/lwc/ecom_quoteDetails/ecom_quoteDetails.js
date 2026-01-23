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
  // @api quoteId;
  res;
  isActive = true;
  isLoading = false;
  subtotal = 0.0;
  freight = 0.0;
  tax = 0.0;
  savings = 0.0;
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
      console.log('Base URL:', this.baseurl);
    } else if (result.error) {
      console.error('Base URL Error:', result.error);
    }
  }

  /* ========= Shipping / Billing mock values (unchanged) ========= */
  @track shipCompany = 'Lorem company name';
  @track shipStreet = '1900 Avenue of the Stars';
  @track shipCity = 'Lorem ipsum';
  @track shipState = 'Lorem 90067';
  @track shipPostal = '';
  @track shipCountry = 'Italy';

  @track recipient = 'Jane Doe';
  @track deliveryInstructions = 'Place on first floor lobby with receptionist. She must sign';
  @track accountNumber = '12345678';

  @track billCompany = 'Lorem company name';
  @track billStreet = '1900 Avenue of the Stars';
  @track billCity = 'Lorem ipsum';
  @track billState = 'Lorem 90067';
  @track billPostal = '';
  @track billCountry = 'Italy';

  @track invoiceEmail = 'lorem ipsum';
  @track vatNumberMasked = 'XXXXXXXXXX';
  @track projectCode = '0000000000';

  @track invoiceCompany = 'Lorem company name';
  @track invoiceStreet = '1900 Avenue of the Stars';
  @track invoiceCity = 'Lorem ipsum';
  @track invoiceState = 'Lorem 90067';
  @track invoicePostal = '';
  @track invoiceCountry = 'Italy';


  connectedCallback() {

    console.log('connectedCallback');
    this.loadStatus();
    const params = new URLSearchParams(window.location.search);
    this.quoteId = params.get('id') || params.get('c__id') || params.get('recordId');
    if (this.quoteId) this.loadQuoteDetails();
  }

  async handleDownload() {
    this.loading = true;
    try {
      const dto = await getCPQQuotesDocumentApi({ quoteId: this.quoteId });
      if (dto.message == 'Success') {
        console.log('Download URL:', this.baseurl + dto.downloadUrl);
        window.location.href = `${this.baseurl}${dto.downloadUrl}`;
      } else {
        this.toast('Download failed', dto?.message || 'Unable to get download URL', 'error');
      }
    } catch (e) {
      const msg = e?.body?.message || e?.message || 'Unexpected error';
      this.toast('Error', msg, 'error');
    } finally {
      this.loading = false;
    }
  }

  toast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  async loadStatus() {
    try {
      const url = new URL(window.location.href);
      this.quoteId = url.searchParams.get('id');
      console.log('quote id from url', this.quoteId);
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
    // Extract single quote from array (API returns single matching quote)
    const quote = (this.quotes && this.quotes.length > 0) ? this.quotes[0] : null;
    if (!quote) return;

    console.log('Processing quote:', quote);

    // Parse expiration as date-only to avoid timezone issues
    const exp = quote.ValidUntil ? new Date(quote.ValidUntil) : null;
    const isExpired = exp ? this.startOfDay(exp) < today : false; // No expiration = Active
    const displayStatus = isExpired ? 'Expired' : 'Active';

    // Set individual properties for template binding
    this.quoteNumber = quote.Name || '';
    this.status = displayStatus;
    this.expirationDate = quote.ValidUntil || '';

    console.log('Display status:', displayStatus, 'Expires on:', quote.ValidUntil);

    // Store processed quote with computed properties
    this.currentQuote = {
      ...quote,
      _status: displayStatus,
      statusClass: this.getStatusClass(displayStatus),
      expiresOnClass: this.getExpiresOnClass(displayStatus),
      expiresOn: this.formatDateForUI(quote.ValidUntil),
    };

    console.log('Current quote updated:', this.currentQuote);

    // Calculate subtotal from line items
    this.subtotal = (quote.Lines || []).reduce((sum, line) => {
      return sum + (line.LineTotal || 0);
    }, 0);
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