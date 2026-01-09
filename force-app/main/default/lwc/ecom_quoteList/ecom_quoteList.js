import { LightningElement, track, api } from 'lwc';

export default class Ecom_quoteList extends LightningElement {

    @track Quotes = [
        { expiresOn: '2026-06-31', quoteNumber: 'Q-1001', totalAmount: '$1,200.00', items: 5, status: 'Active', createdDate: '2026-06-31' },
        { expiresOn: '2026-01-15', quoteNumber: 'Q-1002', totalAmount: '$850.00', items: 3, status: 'Active', createdDate: '2026-01-15' },
        { expiresOn: '2026-02-28', quoteNumber: 'Q-1003', totalAmount: '$2,450.00', items: 8, status: 'Active', createdDate: '2026-02-28' },
        { expiresOn: '2026-03-31', quoteNumber: 'Q-1004', totalAmount: '$800.00', items: 6, status: 'Active', createdDate: '2026-03-31' },
        { expiresOn: '2026-04-30', quoteNumber: 'Q-1005', totalAmount: '$500.00', items: 4, status: 'Active', createdDate: '2026-04-30' },
        { expiresOn: '2026-05-31', quoteNumber: 'Q-1006', totalAmount: '$200.00', items: 5, status: 'Active', createdDate: '2026-05-31' },
        { expiresOn: '2024-06-30', quoteNumber: 'Q-1007', totalAmount: '$200.00', items: 5, status: 'Expired', createdDate: '2024-06-30' },
        { expiresOn: '2024-07-31', quoteNumber: 'Q-1008', totalAmount: '$1.00', items: 5, status: 'Expired', createdDate: '2024-07-31' },
        { expiresOn: '2024-08-31', quoteNumber: 'Q-1009', totalAmount: '23.00', items: 5, status: 'Expired', createdDate: '2024-08-31' },
        { expiresOn: '2024-09-30', quoteNumber: 'Q-1010', totalAmount: '123.00', items: 34, status: 'Expired', createdDate: '2024-09-30' },
        { expiresOn: '2024-10-31', quoteNumber: 'Q-1011', totalAmount: '111.00', items: 52, status: 'Expired', createdDate: '2024-10-31' },
        { expiresOn: '2024-11-30', quoteNumber: 'Q-1012', totalAmount: '1324.00', items: 45, status: 'Expired', createdDate: '2024-11-30' },
        { expiresOn: '2024-06-31', quoteNumber: 'Q-1013', totalAmount: '543.00', items: 23, status: 'Expired', createdDate: '2024-06-31' },
        { expiresOn: '2024-01-31', quoteNumber: 'Q-1014', totalAmount: '123.00', items: 5, status: 'Expired', createdDate: '2024-01-31' },
        { expiresOn: '2024-02-28', quoteNumber: 'Q-1015', totalAmount: '678.00', items: 12, status: 'Expired', createdDate: '2024-02-28' },
        { expiresOn: '2024-03-31', quoteNumber: 'Q-1016', totalAmount: '123.00', items: 5, status: 'Expired', createdDate: '2024-03-31' },
        { expiresOn: '2024-04-30', quoteNumber: 'Q-1017', totalAmount: '890.00', items: 7, status: 'Expired', createdDate: '2024-04-30' },
        { expiresOn: '2024-05-31', quoteNumber: 'Q-1018', totalAmount: '456.00', items: 9, status: 'Expired', createdDate: '2024-05-31' },
        { expiresOn: '2024-06-30', quoteNumber: 'Q-1019', totalAmount: '234.00', items: 11, status: 'Expired', createdDate: '2024-06-30' },
        { expiresOn: '2024-07-31', quoteNumber: 'Q-1020', totalAmount: '789.00', items: 15, status: 'Expired', createdDate: '2024-07-31' },
        { expiresOn: '2024-08-31', quoteNumber: 'Q-1021', totalAmount: '123.00', items: 5, status: 'Expired', createdDate: '2024-08-31' },
        { expiresOn: '2024-09-30', quoteNumber: 'Q-1022', totalAmount: '567.00', items: 8, status: 'Expired', createdDate: '2024-09-30' },
        { expiresOn: '2024-10-31', quoteNumber: 'Q-1023', totalAmount: '890.00', items: 10, status: 'Expired', createdDate: '2024-10-31' },
        { expiresOn: '2024-11-30', quoteNumber: 'Q-1024', totalAmount: '345.00', items: 6, status: 'Expired', createdDate: '2024-11-30' },
        { expiresOn: '2024-06-31', quoteNumber: 'Q-1025', totalAmount: '678.00', items: 14, status: 'Expired', createdDate: '2024-06-31' },
        { expiresOn: '2025-01-31', quoteNumber: 'Q-1026', totalAmount: '123.00', items: 5, status: 'Expired', createdDate: '2025-01-31' },
        { expiresOn: '2025-02-28', quoteNumber: 'Q-1027', totalAmount: '456.00', items: 9, status: 'Expired', createdDate: '2025-02-28' },
        { expiresOn: '2025-03-31', quoteNumber: 'Q-1028', totalAmount: '789.00', items: 13, status: 'Expired', createdDate: '2025-03-31' },
        { expiresOn: '2025-04-30', quoteNumber: 'Q-1029', totalAmount: '234.00', items: 7, status: 'Expired', createdDate: '2025-04-30' },
        { expiresOn: '2025-05-31', quoteNumber: 'Q-1030', totalAmount: '567.00', items: 10, status: 'Expired', createdDate: '2025-05-31' },
        { expiresOn: '2026-06-30', quoteNumber: 'Q-1031', totalAmount: '123.00', items: 5, status: 'Active', createdDate: '2026-06-30' },
        { expiresOn: '2026-07-31', quoteNumber: 'Q-1032', totalAmount: '890.00', items: 11, status: 'Active', createdDate: '2026-07-31' },
        { expiresOn: '2026-08-31', quoteNumber: 'Q-1033', totalAmount: '345.00', items: 6, status: 'Active', createdDate: '2026-08-31' },
        { expiresOn: '2026-09-30', quoteNumber: 'Q-1034', totalAmount: '678.00', items: 9, status: 'Active', createdDate: '2026-09-30' },
        { expiresOn: '2026-10-31', quoteNumber: 'Q-1035', totalAmount: '234.00', items: 8, status: 'Active', createdDate: '2026-10-31' },
        { expiresOn: '2026-11-30', quoteNumber: 'Q-1036', totalAmount: '567.00', items: 12, status: 'Active', createdDate: '2026-11-30' },
        { expiresOn: '2026-06-31', quoteNumber: 'Q-1037', totalAmount: '890.00', items: 15, status: 'Active', createdDate: '2026-06-31' },
        { expiresOn: '2025-06-30', quoteNumber: 'Q-1038', totalAmount: '123.00', items: 5, status: 'Active', createdDate: '2025-06-30' },
        { expiresOn: '2025-07-31', quoteNumber: 'Q-1039', totalAmount: '456.00', items: 8, status: 'Active', createdDate: '2025-07-31' },
        { expiresOn: '2025-08-31', quoteNumber: 'Q-1040', totalAmount: '789.00', items: 12, status: 'Active', createdDate: '2025-08-31' },
        { expiresOn: '2025-09-30', quoteNumber: 'Q-1041', totalAmount: '234.00', items: 6, status: 'Active', createdDate: '2025-09-30' },
        { expiresOn: '2025-10-31', quoteNumber: 'Q-1042', totalAmount: '567.00', items: 9, status: 'Active', createdDate: '2025-10-31' },
        { expiresOn: '2025-11-30', quoteNumber: 'Q-1043', totalAmount: '890.00', items: 14, status: 'Active', createdDate: '2025-11-30' },
        { expiresOn: '2025-06-31', quoteNumber: 'Q-1044', totalAmount: '345.00', items: 7, status: 'Active', createdDate: '2025-06-31' }
    ];

    // PAGINATION changes---------------------------------------

    allQuotes = [];
    activeQuotes = [];
    expiredQuotes = [];
    myQuotes = [];

    defaultListSize = 5;
    nextLoadCount = 0;
    currentPageNumber = 1;
    fromRecords = 0;
    toRecords = this.defaultListSize;
    isLoadMore = false;
    quotesToDisplay = [];
    isQuoteHistoryPage = true;
    totalQuotes = 0;
    showQuotes = false;
    isActiveSelected = false;
    isExpiredSelected = false;

    connectedCallback() {

        this.allQuotes = (this.Quotes || []).map(q => {
            const s = (q.status || '').toLowerCase();
            const expiresOn = this.formatDateForUI(q.expiresOn);
            return {
                ...q,
                _status: s,
                statusClass: this.getStatusClass(s),
                expiresOn: expiresOn,
                expiresOnClass: this.getExpiresOnClass(q.status)
            };
        });

        // Precompute segments
        this.activeQuotes = this.allQuotes.filter(q => q._status === 'active');
        this.expiredQuotes = this.allQuotes.filter(q => q._status === 'expired');

        this.applySegment('active');
    }

    get isLoadMoreEnabled() {
        return this.isLoadMore && this.isQuoteHistoryPage;
    }

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
        this.sortData('createdDate', 'desc');

        this.totalQuotes = this.myQuotes.length;
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
        this.fromRecords = start == 0 ? start : start + 1;
        this.toRecords = end > this.totalQuotes ? this.totalQuotes : end;
        this.quotesToDisplay = this.myQuotes.slice(start, end);
    }

    get activeButtonClass() {
        return this.isActiveSelected ? 'seg-btn is-active' : 'seg-btn is-inactive';
    }

    get expiredButtonClass() {
        return this.isExpiredSelected ? 'seg-btn is-active' : 'seg-btn is-inactive';
    }

    // Sorting changes---------------------------------------

    sortValue = 'newest';

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
            this.sortData('createdDate', 'asc');
        }
        if (sortBy == 'newest') {
            this.sortData('createdDate', 'desc');
        }
        if (sortBy == 'items') {
            this.sortData('items', 'desc');
        }
        if (sortBy == 'totalAmount') {
            this.sortData('totalAmount', 'desc');
        }
        this.currentPageNumber = 1;
        this.fromRecords = 0;
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

}