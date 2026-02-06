public class ECOM_QuoteLineWrapper {
    @auraEnabled
    public Id Id;
    @auraEnabled
    public Id ProductId;
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
    public Decimal Discount;
    @auraEnabled
    public Decimal Freight;
    @auraEnabled
    public Decimal Tax;
    @auraEnabled
    public String CurrencyIsoCode;

    public ECOM_QuoteLineWrapper() {}
    public ECOM_QuoteLineWrapper(SBQQ__QuoteLine__c l) {
        Id          = l.Id;
        Name        = l.Name;
        ProductName = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Name : null;
        PartNumber  = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Part_Number__c : null;
        Description = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Description : null;
        Quantity    = l.SBQQ__Quantity__c;
        ListPrice   = l.SBQQ__ListPrice__c;
        UnitNetPrice = l.Net_Price__c != null ? l.Net_Price__c : l.SBQQ__NetPrice__c;
        Discount    = l.SBQQ__Discount__c;
        Freight    = l.Freight__c;
        Tax = l.Tax__c;
        ProductId = l.SBQQ__Product__c;
        CurrencyIsoCode = l.CurrencyIsoCode;
    }
}