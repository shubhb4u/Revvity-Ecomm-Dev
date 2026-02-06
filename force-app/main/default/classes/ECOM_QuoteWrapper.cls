public class ECOM_QuoteWrapper {
        @auraEnabled
        public Id Id;
        @auraEnabled
        public String Name;
        @auraEnabled  
        public String Status;
        @auraEnabled
        public Boolean Primary;
        @auraEnabled
        public Date ValidUntil;
        @auraEnabled
        public Decimal NetAmount;
        @auraEnabled
        public Integer Items;
        @auraEnabled
        public DateTime CreatedDate;
        @auraEnabled
        public Decimal SubTotal;
        @auraEnabled
        public Decimal TotalFreight;
        @auraEnabled
        public Decimal TotalTax;
        @auraEnabled
        public Decimal TotalDiscount;
        @auraEnabled
        public Decimal GrandTotal;
        @auraEnabled
        public String SoldToAddress;
        @auraEnabled
        public String PayerAddress;
        @auraEnabled
        public List<ECOM_QuoteLineWrapper> Lines;

        public ECOM_QuoteWrapper() {}
        public ECOM_QuoteWrapper(SBQQ__Quote__c q) {
            
            Id         = q.Id;
            Name       = q.Name; 
            Status     = q.SBQQ__Status__c;
            Primary    = q.SBQQ__Primary__c;
            CreatedDate = q.CreatedDate;
            ValidUntil = q.SBQQ__ExpirationDate__c;
            NetAmount  = q.SBQQ__NetAmount__c;
            Items      = (q.SBQQ__LineItemCount__c == null) ? null : 
                            Integer.valueOf(q.SBQQ__LineItemCount__c);
            SubTotal = q.Country_List_Price_Total__c != null ? q.Country_List_Price_Total__c : 0;
            TotalFreight = q.fxFreightDisplayedAmount__c;
            TotalTax = q.TotalTax__c;
            TotalDiscount = q.Total_Discount__c;
            GrandTotal = q.fxGrand_Total__c;
            SoldToAddress = q.SBQQ__Opportunity2__r.Sold_To_ERP_Address__r.fxAddressFull__c;
            PayerAddress = q.SBQQ__Opportunity2__r.Payer_ERP_Address__r.fxAddressFull__c;
            Lines = new List<ECOM_QuoteLineWrapper>();
        }
}