import { LightningElement } from 'lwc';

export default class Ecom_shoppingQuoteCart extends LightningElement {

    quoteNumber = '0821849';
    quoteTotal = '1,008.00 USD';
    savings = 'USD 40.00 (10%)';

    lineItems = [];

    connectedCallback() {
        const rawItems = [
            {
                id: '1',
                productName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
                partNumber: 'HHCUSHTSMISC',
                description: 'Miscellaneous',
                unitListPrice: 'USD 120.00',
                unitNetPrice: 'USD 120.00',
                quantity: 1,
                lineTotal: 'USD 120.00'
            },
            {
                id: '2',
                productName: 'Liconic BCX44 IC SA (33.50C, max. 95% RH) (91183596)',
                partNumber: 'HHCUSHTSMISC',
                description: 'Miscellaneous',
                unitListPrice: 'USD 120.00',
                unitNetPrice: 'USD 120.00',
                quantity: 1,
                lineTotal: 'USD 120.00'
            },
            {
                id: '3',
                productName: 'Liconic BCX4411212111 IC SA (33.50C, max. 95% RH) (91183596)',
                partNumber: 'HHCUSHTSMISC001',
                description: 'Miscellaneous',
                unitListPrice: 'USD 10.00',
                unitNetPrice: 'USD 10.00',
                quantity: 6,
                lineTotal: 'USD 10.00'
            },
            {
                id: '2',
                productName: 'Liconic BCX441212112 IC SA (33.50C, max. 95% RH) (91183596)',
                partNumber: 'HHCUSHTSMISC',
                description: 'Miscellaneous',
                unitListPrice: 'USD 1201.00',
                unitNetPrice: 'USD 1201.00',
                quantity: 5,
                lineTotal: 'USD 1201.00'
            }
        ];

        // Add serial number here
        this.lineItems = rawItems.map((item, index) => {
            return {
                ...item,
                serialNumber: index + 1
            };
        });
    }
}