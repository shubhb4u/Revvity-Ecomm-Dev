@RestResource(urlMapping='/cpq/quotesWithLines')
global with sharing class CPQQuoteWithLinesApi {
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
            SELECT Id, Name, SBQQ__ExpirationDate__c,SBQQ__Primary__c, SBQQ__NetAmount__c, SBQQ__LineItemCount__c, SBQQ__Status__c, CreatedDate, Total_Freight__c, TotalTax__c, fxGrand_Total__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__PrimaryContact__c = :contactId
            // AND 
            // (
            //     (
            //         SBQQ__Primary__c = true
            //         AND SBQQ__ExpirationDate__c >= :today
            //         AND SAPQuoteID__c != null
            //     )
            // )
            // OR
            // (
            //     SBQQ__Primary__c = false
            //     AND SBQQ__ExpirationDate__c >= :today
            //     AND Publish_To_Site__c = true
            //     AND SAPQuoteID__c != null
            // )
            // OR
            // (
            //     AND SBQQ__Primary__c = true
            //     AND SBQQ__ExpirationDate__c < :today
            //     AND SBQQ__ExpirationDate__c >= :twelveMonthsAgo
            //     AND SAPQuoteID__c != null
            // )
            // ORDER BY CreatedDate DESC
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
                   SBQQ__Product__r.Name,
                   SBQQ__Product__r.Part_Number__c,
                   SBQQ__Quantity__c,
                   SBQQ__ListPrice__c,
                   Net_Price__c,
                   SBQQ__Discount__c
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
            Lines = new List<QuoteLineDto>();
        }
    }

    global class QuoteLineDto {
        public Id Id;
        public String Name;
        public String ProductName;
        public Decimal Quantity;
        public Decimal ListPrice;
        public Decimal NetPrice;
        public Decimal Discount;

        public QuoteLineDto() {}
        public QuoteLineDto(SBQQ__QuoteLine__c l) {
            Id          = l.Id;
            Name        = l.Name;
            ProductName = l.SBQQ__Product__r != null ? l.SBQQ__Product__r.Name : null;
            Quantity    = l.SBQQ__Quantity__c;
            ListPrice   = l.SBQQ__ListPrice__c;
            NetPrice    = l.Net_Price__c;
            Discount    = l.SBQQ__Discount__c;
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