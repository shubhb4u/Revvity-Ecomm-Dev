
import { LightningElement, track, api } from 'lwc';

export default class Ecomm_quoteList extends LightningElement {

    @track quotes = [
        { expiresOn: '2026-12-31', quoteNumber: 'Q-1001', totalAmount: '$1,200.00', items: 5, status: 'Active' },
        { expiresOn: '2026-01-15', quoteNumber: 'Q-1002', totalAmount: '$850.00', items: 3, status: 'Active' },
        { expiresOn: '2026-02-28', quoteNumber: 'Q-1003', totalAmount: '$2,450.00', items: 8, status: 'Active' },
        { expiresOn: '2026-03-31', quoteNumber: 'Q-1004', totalAmount: '$800.00', items: 6, status: 'Active' },
        { expiresOn: '2026-04-30', quoteNumber: 'Q-1005', totalAmount: '$500.00', items: 4, status: 'Active' },
        { expiresOn: '2026-05-31', quoteNumber: 'Q-1006', totalAmount: '$200.00', items: 5, status: 'Active' },
        { expiresOn: '2024-06-30', quoteNumber: 'Q-1007', totalAmount: '$200.00', items: 5, status: 'Expired' },
        { expiresOn: '2024-07-31', quoteNumber: 'Q-1008', totalAmount: '$1.00', items: 5, status: 'Expired' },
        { expiresOn: '2024-08-31', quoteNumber: 'Q-1009', totalAmount: '23.00', items: 5, status: 'Expired' },
        { expiresOn: '2024-09-30', quoteNumber: 'Q-1010', totalAmount: '123.00', items: 34, status: 'Expired' },
        { expiresOn: '2024-10-31', quoteNumber: 'Q-1011', totalAmount: '111.00', items: 52, status: 'Expired' },
        { expiresOn: '2024-11-30', quoteNumber: 'Q-1012', totalAmount: '1324.00', items: 45, status: 'Expired' },
        { expiresOn: '2024-12-31', quoteNumber: 'Q-1013', totalAmount: '543.00', items: 23, status: 'Expired' }
    ];

    get calculatedQuotes() {
        return this.quotes.map(q => {
            const s = (q.status || '').toLowerCase();
            const statusClass =
                'ecomm-value ' + (
                    s === 'active' ? 'ecomm-status--active' :
                        s === 'expired' ? 'ecomm-status--expired' :
                            'ecomm-status--neutral'
                );
            return { ...q, statusClass };
        });
    }

    // PAGINATION changes - ---------------------------------------

    @api pageSize = 20;
    @api pageNumber = 1;
    @api totalRecords = 0;
    @api isClientSidePagination = false;
    @api itemsPerPageOptions = [5, 10, 20, 50, 100];
    enablePagination = true;

    get hasRecords() {
        return this.records.length > 0;
    }

    // PAGINATION PROPERTY - CHECK WEATHER PAGINATION NEEDS TO SHOW OR NOT
    get showPaginator() {
        return this.enablePagination && this.hasRecords;
    }

    // WILL AUTOMATICALLY CALLED FROM PAGINATOR ON PAGE NUMBER OR SIZE CHANGE
    paginationChangeHandler(event) {
        if (event.detail) {
            this.pageNumber = event.detail.pageNumber;
            this.pageSize = event.detail.pageSize;
        }
    }
}