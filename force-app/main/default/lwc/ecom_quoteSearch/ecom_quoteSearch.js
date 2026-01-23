import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LightningModal from 'lightning/modal';

export default class Ecom_quoteSearch extends NavigationMixin(LightningElement) {
 
    @api allQuotes = [];
 
    searchTerm = '';
    filteredQuotes = [];
 
    get hasResults() {
        return this.filteredQuotes.length > 0;
    }
 
    get showNoResults() {
        return this.searchTerm && this.filteredQuotes.length === 0;
    }
 
    connectedCallback() {
        console.log('[ecom_quoteSearch] Component loaded');
        console.log('[ecom_quoteSearch] Received quotes from parent:', this.allQuotes?.length || 0);
        if (this.allQuotes?.length > 0) {
            console.log('[ecom_quoteSearch] First quote example:', {
                id: this.allQuotes[0].Id,
                name: this.allQuotes[0].Name
            });
        }
    }

    handleInputChange(event) {
        this.searchTerm = event.target.value.trim();
        console.log('[ecom_quoteSearch] User typed:', this.searchTerm);

        if (!this.searchTerm) {
            this.filteredQuotes = [];
            console.log('[ecom_quoteSearch] Cleared results');
            return;
        }

        const term = this.searchTerm.toLowerCase();
        this.filteredQuotes = this.allQuotes
            .filter(q => {
                const name = q.Name ? q.Name.toLowerCase() : '';
                const matches = name.includes(term);
                return matches;
            })
            .slice(0, 12);

        console.log('[ecom_quoteSearch] Found matches:', this.filteredQuotes.length);
        if (this.filteredQuotes.length > 0) {
            console.log('[ecom_quoteSearch] First match:', this.filteredQuotes[0].Name);
        }
    }
 
    handleSelectQuote(event) {
        const quoteId = event.currentTarget.dataset.quoteId;
 
        console.log('[ecom_quoteSearch] Selected quote ID:', quoteId);                
        console.log('[ecom_quoteSearch] Navigating to: /quote-detail?id=' + quoteId);
 
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/quote-detail?id=${quoteId}`
            }
        });
 
        this.dispatchEvent(new CustomEvent('close'));
    }
 
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}