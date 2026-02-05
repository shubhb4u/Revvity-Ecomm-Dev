@RestResource(urlMapping='/cpq/quotesWithLines')
global with sharing class ECOM_CPQQuoteWithLinesApi {
    /**
     * GET /services/apexrest/cpq/quotesWithLines?accountId=001...&limit=100&linesLimit=500
     * Returns a list of Quote DTOs, each with a nested list of Line DTOs.
     *
     * Query runs under the Integration User (CPQ-licensed).
     */
    @HttpGet
    global static List<QuoteWithLinesDto> getQuotesWithLines() {
        RestRequest req = RestContext.request;

        // Inputs
        String contactId = req.params.get('contactId');
        Integer limitSize   = parseIntOrDefault(req.params.get('limit'), 100, 1, 500);
        Integer linesLimit  = parseIntOrDefault(req.params.get('linesLimit'), 500, 1, 2000);

        if (String.isBlank(contactId)) {
            throw new AuraHandledException('Missing contactId');
        }

        // --- Query quotes (curated fields) ---
        Date today = Date.today();
        Date twelveMonthsAgo = today.addMonths(-12);

        List<SBQQ__Quote__c> quotes = [
            SELECT Id, Name, SBQQ__ExpirationDate__c, SBQQ__Primary__c, SBQQ__NetAmount__c, SBQQ__LineItemCount__c, SBQQ__Status__c, CreatedDate, fxFreightDisplayedAmount__c, TotalTax__c, fxGrand_Total__c, Total_Discount__c, Country_List_Price_Total__c, SBQQ__Opportunity2__r.Sold_To_ERP_Address__r.fxAddressFull__c, SBQQ__Opportunity2__r.Payer_ERP_Address__r.fxAddressFull__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__PrimaryContact__c = :contactId 
            AND SBQQ__PrimaryContact__r.Email != null
            AND SAPQuoteID__c != null
            AND (
                (
                    SBQQ__Primary__c = true
                    AND SBQQ__ExpirationDate__c >= :today
                )
                OR
                (
                    SBQQ__Primary__c = false
                    AND SBQQ__ExpirationDate__c >= :today
                )
                OR
                (
                    SBQQ__Primary__c = true
                    AND SBQQ__ExpirationDate__c < :today
                    AND SBQQ__ExpirationDate__c >= :twelveMonthsAgo
                )
            )
            LIMIT :limitSize
        ];
        if (quotes.isEmpty()) return new List<QuoteWithLinesDto>();

        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c q : quotes) quoteIds.add(q.Id);

        // --- Query lines once and group by Quote ---
        List<SBQQ__QuoteLine__c> lines = [
            SELECT Id,
                   Name,
                   SBQQ__Quote__c,
                   SBQQ__Product__c,
                   SBQQ__Product__r.Name,
                   SBQQ__Product__r.Part_Number__c,
                   SBQQ__Product__r.Description,
                   SBQQ__Quantity__c,
                   SBQQ__ListPrice__c,
                   Net_Price__c,
                   SBQQ__NetPrice__c,
                   SBQQ__NetTotal__c,
                   SBQQ__Optional__c,
                   SBQQ__Discount__c,
                   SBQQ__ListTotal__c,
                   SBQQ__CustomerTotal__c,
                   SBQQ__TotalDiscountAmount__c,
                   SBQQ__AdditionalDiscountAmount__c,
                   Tax__c,
                   fxEffectiveTax__c,
                   Freight__c,
                   CurrencyIsoCode
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c IN :quoteIds
            ORDER BY SBQQ__Quote__c, CreatedDate ASC
            LIMIT :linesLimit
        ];

        Map<Id, List<QuoteLineDto>> byQuote = new Map<Id, List<QuoteLineDto>>();
        for (SBQQ__QuoteLine__c l : lines) {
            Id qId = l.SBQQ__Quote__c;
            List<QuoteLineDto> bucket = byQuote.get(qId);
            if (bucket == null) {
                bucket = new List<QuoteLineDto>();
                byQuote.put(qId, bucket);
            }
            bucket.add(new QuoteLineDto(l));
        }

        // --- Compose DTOs (Quote + lines) ---
        List<QuoteWithLinesDto> payload = new List<QuoteWithLinesDto>();
        for (SBQQ__Quote__c q : quotes) {
            QuoteWithLinesDto dto = new QuoteWithLinesDto(q);
            dto.Lines = byQuote.get(q.Id);
            if (dto.Lines == null) dto.Lines = new List<QuoteLineDto>();
            payload.add(dto);
        }
        return payload;
    }

    // DTOs
    global class QuoteWithLinesDto {
        
        public Id Id;
        public String Name;  
        public String Status;
        public Boolean Primary;
        public Date ValidUntil;
        public Decimal NetAmount;
        public Integer Items;
        public DateTime CreatedDate;
        public Decimal SubTotal;
        public Decimal TotalFreight;
        public Decimal TotalTax;
        public Decimal TotalDiscount;
        public Decimal GrandTotal;
        public String SoldToAddress;
        public String PayerAddress;
        public List<QuoteLineDto> Lines;

        public QuoteWithLinesDto() {}
        public QuoteWithLinesDto(SBQQ__Quote__c q) {
            
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
            Lines = new List<QuoteLineDto>();
        }
    }

    global class QuoteLineDto {
        public Id Id;
        public String Name;
        public Id ProductId;
        public String ProductName;
        public String PartNumber;
        public String Description;
        public Decimal Quantity;
        public Decimal ListPrice;
        public Decimal UnitNetPrice;
        public Decimal LineTotal;
        public Boolean IsOptional;
        public Decimal Discount;
        public Decimal ListTotal;
        public Decimal CustomerTotal;
        public Decimal TotalDiscountAmount;
        public Decimal AdditionalDiscountAmount;
        public Decimal Tax;
        public Decimal EffectiveTax;
        public Decimal Freight;
        public String CurrencyIsoCode;

        public QuoteLineDto() {}
        public QuoteLineDto(SBQQ__QuoteLine__c l) {
            Id          = l.Id;
            Name        = l.Name;
            ProductId   = l.SBQQ__Product__c;
            ProductName = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Name : null;
            PartNumber  = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Part_Number__c : null;
            Description = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Description : null;
            Quantity    = l.SBQQ__Quantity__c;
            ListPrice   = l.SBQQ__ListPrice__c;
            UnitNetPrice = l.Net_Price__c != null ? l.Net_Price__c : l.SBQQ__NetPrice__c;
            LineTotal    = l.SBQQ__NetTotal__c;
            IsOptional  = l.SBQQ__Optional__c;
            Discount    = l.SBQQ__Discount__c;
            ListTotal   = l.SBQQ__ListTotal__c;
            CustomerTotal = l.SBQQ__CustomerTotal__c;
            TotalDiscountAmount = l.SBQQ__TotalDiscountAmount__c;
            AdditionalDiscountAmount = l.SBQQ__AdditionalDiscountAmount__c;
            Tax = l.Tax__c;
            EffectiveTax = l.fxEffectiveTax__c;
            Freight = l.Freight__c;
            CurrencyIsoCode = l.CurrencyIsoCode;
        }
    }

    // Helpers
    private static Integer parseIntOrDefault(String s, Integer defVal, Integer min, Integer max) {
        Integer out;
        try { out = Integer.valueOf(s); } catch (Exception e) { out = defVal; }
        if (out == null) out = defVal;
        if (min != null && out < min) out = min;
        if (max != null && out > max) out = max;
        return out;
    }
}