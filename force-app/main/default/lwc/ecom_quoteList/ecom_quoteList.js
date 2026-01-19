import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteData from '@salesforce/apex/ECOM_quoteListController.getQuotes';

export default class Ecom_quoteList extends NavigationMixin(LightningElement) {

    quotes = [];
    allQuotes = [];
    activeQuotes = [];
    expiredQuotes = [];
    myQuotes = [];
    defaultListSize = 5;
    nextLoadCount = 0;
    currentPageNumber = 1;
    fromRecords = 1;
    toRecords = this.defaultListSize;
    isLoadMore = false;
    quotesToDisplay = [];
    isQuoteHistoryPage = true;
    totalQuotes = 0;
    showQuotes = false;
    isActiveSelected = false;
    isExpiredSelected = false;
    sortValue = 'newest';

    allWiredData = [];
    error;

    @wire(getQuoteData)
    wiredQuotes(result) {
        this.allWiredData = result;
        if (result.data) {
            this.quotes = result.data;
            console.log('this.quotes', this.quotes);
            this.processQuotes();
        } else if (result.error) {
            this.error = result.error;
        }
    }

    processQuotes() {
        this.allQuotes = (this.quotes || []).map(q => {
            const s = (q.SBQQ__Status__c || '').toLowerCase();
            const expiresOn = this.formatDateForUI(q.SBQQ__ExpirationDate__c);
            return {
                ...q,
                _status: s,
                statusClass: this.getStatusClass(s),
                expiresOn: expiresOn,
                expiresOnClass: this.getExpiresOnClass(q.SBQQ__Status__c),
                hasExpiresOn: q.SBQQ__ExpirationDate__c !== null && q.SBQQ__ExpirationDate__c !== undefined && q.SBQQ__ExpirationDate__c !== '',
                hasQuoteNumber: q.Name !== null && q.Name !== undefined && q.Name !== '',
                hasTotalAmount: q.SBQQ__NetAmount__c !== null && q.SBQQ__NetAmount__c !== undefined && q.SBQQ__NetAmount__c !== '',
                hasItems: q.SBQQ__LineItemCount__c !== null && q.SBQQ__LineItemCount__c !== undefined && q.SBQQ__LineItemCount__c !== '',
                hasStatus: q.SBQQ__Status__c !== null && q.SBQQ__Status__c !== undefined && q.SBQQ__Status__c !== ''
            };
        });

        // Determine if quote is active (not expired) based on expiration date
        const today = new Date();
        this.activeQuotes = this.allQuotes.filter(q => {
            const expDate = new Date(q.SBQQ__ExpirationDate__c);
            return expDate >= today;
        });

        this.expiredQuotes = this.allQuotes.filter(q => {
            const expDate = new Date(q.SBQQ__ExpirationDate__c);
            return expDate < today;
        });

        this.applySegment('active');
    }

    get isLoadMoreEnabled() {
        return this.isLoadMore && this.isQuoteHistoryPage;
    }

    getStatusClass(status) {
        const s = (status || '').toLowerCase();
        return 'ecomm-value ' + (
            s === 'active' || s === 'draft' ? 'ecomm-status--active' :
                s === 'expired' ? 'ecomm-status--expired' :
                    'ecomm-status--neutral'
        );
    }

    getExpiresOnClass(status) {
        const s = (status || '').toLowerCase();
        return s === 'expired' ? 'ecomm-value ecomm-status--expired' : 'ecomm-value';
    }

    applySegment(segment) {
        this.quotesToDisplay = [];
        if (segment === 'active') {
            this.isActiveSelected = true;
            this.isExpiredSelected = false;
            this.myQuotes = this.activeQuotes;
        } else if (segment === 'expired') {
            this.isActiveSelected = false;
            this.isExpiredSelected = true;
            this.myQuotes = this.expiredQuotes;
        }

        this.sortValue = 'newest';
        this.sortData('CreatedDate', 'desc');

        this.totalQuotes = this.myQuotes.length;
        this.fromRecords = 1; // Reset to 1 when changing segments
        this.toRecords = this.defaultListSize > this.totalQuotes ? this.totalQuotes : this.defaultListSize;
        //update default size
        this.nextLoadCount = this.defaultListSize;
        if (this.defaultListSize > this.totalQuotes) {
            this.nextLoadCount = this.totalQuotes;
            this.toRecords = this.totalQuotes;
        }
        for (let i = 0; i < this.defaultListSize; i++) {
            this.quotesToDisplay.push(this.myQuotes[i]);
        }
        if (this.totalQuotes > this.defaultListSize) {
            this.isLoadMore = true;
        }
    }

    pageChanged(event) {
        let pageNumber = JSON.parse(JSON.stringify(event.detail.pageNumber));
        this.currentPageNumber = parseInt(pageNumber);
        const start = (this.currentPageNumber - 1) * this.defaultListSize;
        const end = this.defaultListSize * this.currentPageNumber;
        // this.fromRecords = start == 0 ? start : start + 1;
    this.fromRecords = start === 0 ? 1 : start + 1;

        this.toRecords = end > this.totalQuotes ? this.totalQuotes : end;
        this.quotesToDisplay = this.myQuotes.slice(start, end);
    }

    get activeButtonClass() {
        return this.isActiveSelected ? 'seg-btn is-active' : 'seg-btn is-inactive';
    }

    get expiredButtonClass() {
        return this.isExpiredSelected ? 'seg-btn is-active' : 'seg-btn is-inactive';
    }

    get sortOption() {
        return [
            { label: 'Sort by: Oldest', value: 'oldest' },
            { label: 'Sort by: Newest', value: 'newest' },
            { label: 'Sort by: Number of Items', value: 'items' },
            { label: 'Sort by: Quote Total', value: 'totalAmount' }
        ];
    }

    handleSortChange(event) {
        let sortBy = event.detail.value;
        this.sortValue = event.detail.value;

        if (sortBy == 'oldest') {
            this.sortData('CreatedDate', 'asc');
        }
        if (sortBy == 'newest') {
            this.sortData('CreatedDate', 'desc');
        }
        if (sortBy == 'items') {
            this.sortData('SBQQ__LineItemCount__c', 'desc');
        }
        if (sortBy == 'totalAmount') {
            this.sortData('SBQQ__NetAmount__c', 'desc');
        }
        this.currentPageNumber = 1;
        this.fromRecords = 1;
        this.toRecords = this.defaultListSize;
        this.quotesToDisplay = [];
        //update default size
        this.nextLoadCount = this.defaultListSize;
        if (this.defaultListSize > this.totalQuotes) {
            this.nextLoadCount = this.totalQuotes;
            this.toRecords = this.totalQuotes;
        }

        for (let i = 0; i < this.nextLoadCount; i++) {
            this.quotesToDisplay.push(this.myQuotes[i]);
        }
        if (this.totalQuotes > this.defaultListSize) {
            this.isLoadMore = true;
        }
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.myQuotes));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.myQuotes = parseData;
    }

    // Segmented button changes---------------------------------------
    handleActiveQuotes(event) {
        this.applySegment('active');
    }

    handleExpiredQuotes(event) {
        this.applySegment('expired');
    }

    // Format a value like "2025-06-12" or Date into "June 12, 2025"
    formatDateForUI(value) {
        if (!value) return '';
        const d = value instanceof Date ? value : new Date(value);
        if (isNaN(d.getTime())) return '';

        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];

        const monthFull = monthNames[d.getMonth()];
        // Trim only if month name is longer than 4 characters
        const monthDisplay = monthFull.length > 4 ? monthFull.slice(0, 3) : monthFull;

        const day = d.getDate();
        const year = d.getFullYear();

        return `${monthDisplay} ${day}, ${year}`;
    }


    handleViewQuoteDetails(event) {

        let quoteId = event.currentTarget.dataset.quoteId;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/quote-detail?id=` + quoteId
            }
        });
    }
}