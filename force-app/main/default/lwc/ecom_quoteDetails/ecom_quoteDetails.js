import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteById from '@salesforce/apex/CPQQuoteWithLinesProxyController.fetchMyQuotesWithLines';


export default class Ecom_QuoteDetails extends NavigationMixin(LightningElement) {
  @api recordId = '0Q0STATICQUOTE00001';
  @track quoteNumber = '123456789';
  @track status = 'Active';
  @track currencyCode = 'USD';

  // UI-only static date
  @track expirationDate = '2025-06-06T00:00:00.000Z';

  /* ========= Main lines (already present) ========= */
  @track lines = [
    {
      Id: 'QLI-1',
      ProductName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
      ProductCode: 'HHCUSHTSMISC',
      ProductFamily: 'Miscellaneous',
      ListPrice: 120.0,
      UnitNetPrice: 120.0,
      Quantity: 1,
      LineTotal: 120.0,
      Optional: false
    },
    {
      Id: 'QLI-2',
      ProductName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
      ProductCode: 'HHCUSHTSMISC',
      ProductFamily: 'Miscellaneous',
      ListPrice: 120.0,
      UnitNetPrice: 120.0,
      Quantity: 1,
      LineTotal: 120.0,
      Optional: false
    },
    {
      Id: 'QLI-3',
      ProductName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
      ProductCode: 'HHCUSHTSMISC',
      ProductFamily: 'Miscellaneous',
      ListPrice: 120.0,
      UnitNetPrice: 120.0,
      Quantity: 1,
      LineTotal: 120.0,
      Optional: false
    }
  ];

  /* ========= NEW: Optional Items (used by the Optional Items table) ========= */
  @track optionalLines = [
    {
      Id: 'OLI-1',
      ProductName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
      ProductCode: 'HHCUSHTSMISC',
      ProductFamily: 'Miscellaneous',
      ListPrice: 120.0,
      UnitNetPrice: 120.0,
      Quantity: 1,
      LineTotal: 120.0,
      Optional: true
    },
    {
      Id: 'OLI-2',
      ProductName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
      ProductCode: 'HHCUSHTSMISC',
      ProductFamily: 'Miscellaneous',
      ListPrice: 120.0,
      UnitNetPrice: 120.0,
      Quantity: 1,
      LineTotal: 120.0,
      Optional: true
    }
  ];

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

  /* ========= Totals (UI-only) ========= */
  get itemsCount() {
    return (this.lines?.length || 0) + (this.optionalLines?.length || 0);
  }

  get subtotal() {
    return (this.lines || []).reduce((sum, l) => sum + (l.LineTotal || 0), 0);
  }

  // You can adjust these as needed for your mock
  @track freight = 0.0;
  @track tax = 0.0;
  @track savings = 0.0;

  // Grand total for the main Items block
  get grandTotal() {
    return (this.subtotal + this.freight + this.tax) - this.savings;
  }

  /* ========= NEW: Optional totals ========= */

  // Sum of optional lines only
  get optionalSubtotal() {
    return (this.optionalLines || []).reduce((sum, l) => sum + (l.LineTotal || 0), 0);
  }

  // If your Optional Items 'Total' card should show ONLY optional items:
  get optionalGrandTotal() {
    return this.optionalSubtotal;
  }

  get grandTotalWithOptional() {
    return this.grandTotal + this.optionalSubtotal;
  }

  @track isLoading = false;
  @track error = null;


  //Wire changes for backend -----------------------------------------
  quoteId;
  quotes;
  error;
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

  connectedCallback() {

    const params = new URLSearchParams(window.location.search);
    this.quoteId = params.get('id') || params.get('c__id') || params.get('recordId');
    if (this.quoteId) this.loadQuoteDetails();

  }

  loadQuoteDetails() {
    getQuoteById({ quoteId: this.quoteId })
      .then(result => {
        this.quotes = result;
        console.log('Quote Details from integration class:', this.quotes);
        this.processQuotes();
      })
      .catch(error => {
        this.error = error;
      });
  }

  processQuotes() {
    const today = this.startOfDay(new Date());

    // Extract single quote from array (API returns single matching quote)
    const quote = (this.quotes && this.quotes.length > 0) ? this.quotes[0] : null;
    if (!quote) return;

    // Parse expiration as date-only to avoid timezone issues
    const exp = quote.SBQQ__ExpirationDate__c ? new Date(quote.SBQQ__ExpirationDate__c) : null;
    const isExpired = exp ? this.startOfDay(exp) < today : false; // No expiration = Active
    const displayStatus = isExpired ? 'Expired' : 'Active';

    // Set individual properties for template binding
    this.quoteNumber = quote.Name || '';
    this.status = displayStatus;
    this.expirationDate = quote.SBQQ__ExpirationDate__c || '';

    // Store processed quote with computed properties
    this.currentQuote = {
      ...quote,
      _status: displayStatus,
      statusClass: this.getStatusClass(displayStatus),
      expiresOnClass: this.getExpiresOnClass(displayStatus),
      expiresOn: this.formatDateForUI(quote.SBQQ__ExpirationDate__c),
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
