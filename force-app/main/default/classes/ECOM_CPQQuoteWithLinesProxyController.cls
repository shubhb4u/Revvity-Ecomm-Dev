public with sharing class ECOM_CPQQuoteWithLinesProxyController {
    /**
     * Returns quotes with lines for the current Experience Cloud user’s Account
     * by calling the CPQ REST via Named Credential (Integration User session).
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchMyQuotesWithLines(String quoteId) {
        // Resolve tenant isolation (Contact -> Account)
        //User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        User u = [SELECT Id, ContactId FROM User WHERE Id = : '005O500000Y5I41IAF'];
        if (u.ContactId == null) return new List<Map<String, Object>>();
        String contactId = u.ContactId;

        // Build REST endpoint
        String endpoint = '/services/apexrest/cpq/quotesWithLines?contactId='
            + EncodingUtil.urlEncode(contactId, 'UTF-8')
            + '&limit=100&linesLimit=1000';

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:ECOM_B2B_Site_Integration_User_PROD' + endpoint);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res.getBody():::::'+res.getBody());
		List<Map<String, Object>> aDataResultObjectList = new List<Map<String, Object>>();
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            List<Object> dataResults = (List<Object>)JSON.deserializeUntyped(res.getBody());
            
            for (Object o : dataResults) {
                Map<String, object> aDataResultObject = (Map<String,Object>) o;
                
                // Filter logic
                if (quoteId != null) {
                    if (quoteId == String.valueOf(aDataResultObject.get('Id'))) {
                        aDataResultObjectList.add(aDataResultObject);
                        break;
                    }
                } else {
                    aDataResultObjectList.add(aDataResultObject);
                }
            }
            System.debug('aDataResultObjectList::::'+aDataResultObjectList);
            return aDataResultObjectList;

        } else {
            // Optionally log res.getStatus()/Body
            throw new AuraHandledException('Failed to fetch quotes and lines. Please try again later.');
        }
    }
}