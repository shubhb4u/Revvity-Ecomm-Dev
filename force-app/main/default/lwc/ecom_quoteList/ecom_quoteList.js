import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteData from '@salesforce/apex/ECOM_CPQQuoteWithLinesProxyController.fetchMyQuotesWithLines';

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
    @track isLoading = false;
    allWiredData = [];
    error;

    @wire(getQuoteData)
    wiredQuotes(result) {
        this.isLoading = true;
        this.allWiredData = result;
        if (result.data) {
            this.quotes = result.data;
            console.log('this.quotes from integration User', this.quotes);
            this.processQuotes();
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.isLoading = false;
        }
    }


    processQuotes() {
        const today = this.startOfDay(new Date());

        this.allQuotes = (this.quotes || []).map(q => {
            const exp = q.ValidUntil ? new Date(q.ValidUntil) : null;
            const isExpired = exp ? this.startOfDay(exp) < today : false; // No expiration = Active
            const displayStatus = isExpired ? 'Expired' : 'Active';

            return {
                ...q,
                _status: displayStatus,
                // Classes driven by the computed display status
                statusClass: this.getStatusClass(displayStatus),
                expiresOnClass: this.getExpiresOnClass(displayStatus),
                expiresOn: this.formatDateForUI(q.ValidUntil),
                hasExpiresOn: !!q.ValidUntil,
                hasQuoteNumber: !!q.Name,
                hasTotalAmount: q.NetAmount !== null && q.NetAmount !== undefined,
                hasItems: q.Items !== null && q.Items !== undefined,
            };
        });

        // Segment just once, based on the computed display status
        this.activeQuotes = this.allQuotes.filter(q => q._status === 'Active');
        this.expiredQuotes = this.allQuotes.filter(q => q._status === 'Expired');

        this.applySegment('active');
    }

    /** Normalize to start of day to avoid time component causing off-by-one */
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

    get isLoadMoreEnabled() {
        return this.isQuoteHistoryPage && this.isLoadMore && this.totalQuotes > this.defaultListSize;
    }
    
    
    get hasQuotesToDisplay() {
        return Array.isArray(this.quotesToDisplay) && this.quotesToDisplay.some(Boolean);
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
        this.fromRecords = 1; 
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
            this.sortData('Items', 'desc');
        }
        if (sortBy == 'totalAmount') {
            this.sortData('NetAmount', 'desc');
        }
        this.currentPageNumber = 1;
        this.fromRecords = 1;
        this.toRecords = this.defaultListSize;
        this.quotesToDisplay = [];
        this.nextLoadCount = this.defaultListSize;
        if (this.defaultListSize > this.totalQuotes) {
            this.nextLoadCount = this.totalQuotes;
            this.toRecords = this.totalQuotes;
        }

        for (let i = 0; i < this.nextLoadCount; i++) {
            if (this.myQuotes[i]) {
                this.quotesToDisplay.push(this.myQuotes[i]);
            }
        }
        if (this.totalQuotes > this.defaultListSize) {
            this.isLoadMore = true;
        }
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.myQuotes));

        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.myQuotes = parseData;
    }

    // Segmented button changes-
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

    //sahithi changes
    @track showSearchModal = false;

    handleOpenSearchModal() {
        this.showSearchModal = true;
    }

    handleCloseSearchModal() {
        this.showSearchModal = false;
    }
}