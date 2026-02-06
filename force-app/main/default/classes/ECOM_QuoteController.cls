/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a controller which will be called from the Quote List 
*                   page as well Quote Detail Page
*
* 3. Objects referenced
*    - NA
*
* 4. Callouts to additional Components (including their methods) or None:
*    - ECOM_QuoteService.quoteWithLinesOperations - Method
*    - ECOM_QuoteService.quoteDocumentPdfOperations - Method
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
public with sharing class ECOM_QuoteController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchMyQuotesWithLines(Id userId){
        //Id currentLoggedInUserId = UserInfo.getUserId();
        //String contactId = ECOM_QuoteRepo.fetchContactIdOfLoggedInUser();
        String contactId = ECOM_QuoteRepo.fetchContactIdOfLoggedInUser(userId);
        System.debug('contactId::::'+contactId);
        Map<String, String> requestQuoteMap = new Map<String, String>();
        requestQuoteMap.put('varContactId', contactId);
        requestQuoteMap.put('varQuoteWorkflowType', ECOM_Constant.QUOTE_WITH_LINES);
        List<Map<String, Object>> responseWrapperList = new List<Map<String, Object>>();
        responseWrapperList = ECOM_QuoteService.quoteWithLinesOperations(requestQuoteMap);
        return responseWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchQuoteDocumentPdf(Map<String,String> requestQuoteMap){
        Map<String, Object> responseWrapperList = new Map<String, Object>();
        responseWrapperList = ECOM_QuoteService.quoteDocumentPdfOperations(requestQuoteMap);
        return responseWrapperList;
    }

    /**
    * @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
    * @author Shubham Mazumdar Feb 02, 2026 | Added logic to check or create cart if none exists | RWPS-5264
    * @param  communityId The Id of the community from which the call originated
    * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
    * @param activeCartOrId ID of the cart, active, or current.
    */
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(String communityId,String effectiveAccountId,String activeCartOrId) {
        return ECOM_CartController.getCartSummary(communityId, effectiveAccountId, activeCartOrId);
    }

    /**
     * @description Adds quote line items to cart, optionally replacing existing items
     * @author Shubham Mazumdar | Feb 04, 2026 | RWPS-5264
     * @param quoteId ID of the quote to add to cart
     * @param cartId ID of the cart
     * @param replaceExisting Whether to replace existing cart items
     * @param communityId Community/webstore ID
     * @return Map<String, Object> with success status and details
     */
    @AuraEnabled
    public static Map<String, Object> addOrReplaceQuoteItemsInCart(
        String quoteId, 
        String cartId, 
        Boolean replaceExisting,
        String communityId
    ) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            // Fetch single quote with lines via service
            Map<String, Object> requestDataMap = new Map<String, Object>();
            requestDataMap.put('varQuoteId', quoteId);
            requestDataMap.put('varQuoteWorkflowType', 'Single Quote With Lines');
            
            Map<String, Object> quoteResponse = ECOM_QuoteService.singleQuoteWithLinesOperations(requestDataMap);
            System.debug('Quote Response: ' + quoteResponse);
            
            // Extract quote data (the response itself is the quote data)
            Map<String, Object> quoteData = quoteResponse;
            
            // Validate quote status (optional - uncomment if needed)
            // String quoteStatus = String.valueOf(quoteData.get('Status'));
            // if (quoteStatus != 'Approved') {
            //     response.put('success', false);
            //     response.put('message', 'Quote must be approved to add to cart');
            //     return response;
            // }
            
            // Get quote lines
            Object quoteLinesObj = quoteData.get('Lines');
            System.debug('Quote Lines Object: ' + quoteLinesObj);
            
            if (quoteLinesObj == null) {
                response.put('success', false);
                response.put('message', 'Quote has no line items');
                return response;
            }
            
            // Convert to List<Map<String,Object>>
            List<Map<String, Object>> quoteLines = new List<Map<String, Object>>();
            
            if (quoteLinesObj instanceof List<Object>) {
                for (Object lineObj : (List<Object>) quoteLinesObj) {
                    if (lineObj instanceof Map<String, Object>) {
                        quoteLines.add((Map<String, Object>) lineObj);
                    }
                }
            }
            
            if (quoteLines.isEmpty()) {
                response.put('success', false);
                response.put('message', 'Quote has no valid line items');
                return response;
            }
            
            // Call CartService to handle the business logic
            response = ECOM_CartService.addQuoteItemsToCart(
                quoteLines, 
                cartId, 
                replaceExisting,
                quoteData,
                communityId
            );
            
        } catch (Exception ex) {
            response.put('success', false);
            response.put('message', ex.getMessage());
            ECOM_ApplicationLogsUtil.logFailure(
                ex, 
                'Quote to Cart', 
                'ECOM_QuoteController', 
                'addOrReplaceQuoteItemsInCart', 
                'QuoteId: ' + quoteId + ', CartId: ' + cartId
            );
        }
        
        return response;
    }
}