/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a Wrapper class to be used for getting response on the UI
*
* 3. Objects referenced
*    - Document
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    
*
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - Tushar Arora | 26 Jan 2026
*************************************************************/
public class ECOM_QuoteWithLinesFlowResponseWrapper {
    //this class is to accept QuoteWithLines API reponse
    //@auraEnabled
    //public QuoteWithLinesWrapper quoteWithLinesWrapper;

    public class QuoteWithLinesWrapper {
        
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
        public List<QuoteLineWrapper> Lines;

        public QuoteWithLinesWrapper() {}
        public QuoteWithLinesWrapper(SBQQ__Quote__c q) {
            
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
            Lines = new List<QuoteLineWrapper>();
        }
    }

    public class QuoteLineWrapper {
        @auraEnabled
        public Id Id;
        @auraEnabled
        public String Name;
        @auraEnabled
        public String ProductName;
        @auraEnabled
        public String PartNumber;
        @auraEnabled
        public String Description;
        @auraEnabled
        public Decimal Quantity;
        @auraEnabled
        public Decimal ListPrice;
        @auraEnabled
        public Decimal UnitNetPrice;
        @auraEnabled
        public Decimal LineTotal;
        @auraEnabled
        public Boolean IsOptional;
        @auraEnabled
        public Decimal Discount;

        public QuoteLineWrapper() {}
        public QuoteLineWrapper(SBQQ__QuoteLine__c l) {
            Id          = l.Id;
            Name        = l.Name;
            ProductName = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Name : null;
            PartNumber  = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Part_Number__c : null;
            Description = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Description : null;
            Quantity    = l.SBQQ__Quantity__c;
            ListPrice   = l.SBQQ__ListPrice__c;
            UnitNetPrice = l.Net_Price__c != null ? l.Net_Price__c : l.SBQQ__NetPrice__c;
            LineTotal    = l.SBQQ__NetTotal__c;
            IsOptional  = l.SBQQ__Optional__c;
            Discount    = l.SBQQ__Discount__c;
        }
    }
}