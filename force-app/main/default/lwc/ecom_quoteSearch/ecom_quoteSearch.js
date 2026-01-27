import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

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
        
        if (this.allQuotes?.length > 0) {
            console.log('[ecom_quoteSearch] First quote example:', {
                id: this.allQuotes[0].Id,
                name: this.allQuotes[0].Name
            });
        }
    }

    handleInputChange(event) {
        this.searchTerm = event.target.value.trim();

        if (!this.searchTerm) {
            this.filteredQuotes = [];
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
        if (this.filteredQuotes.length > 0) {
            
        }
    }
 
    handleSelectQuote(event) {
        const quoteId = event.currentTarget.dataset.quoteId;
 
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