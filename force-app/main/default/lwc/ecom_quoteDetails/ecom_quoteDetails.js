import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getQuoteById from '@salesforce/apex/ECOM_quoteListController.getQuoteById';


export default class Ecom_QuoteDetails extends LightningElement {
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

  // If your Optional Items "Total" card should show ONLY optional items:
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
  quoteDetails;
  error;

  @wire(CurrentPageReference)
  pageRef;

  connectedCallback() {
    // Extract quoteId from URL parameters
    if (this.pageRef && this.pageRef.state && this.pageRef.state.c__quoteId) {
      this.quoteId = this.pageRef.state.c__quoteId;
      this.loadQuoteDetails();
    }
  }

  loadQuoteDetails() {
    getQuoteById({ quoteId: this.quoteId })
      .then(result => {
        this.quoteDetails = result;
        console.log('Quote Details:', this.quoteDetails);
      })
      .catch(error => {
        this.error = error;
      });
  }
}
