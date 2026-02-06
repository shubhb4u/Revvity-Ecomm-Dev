/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a model for Punchout requests and Poom responses
*
* 3. Objects referenced
*    - NA
*
* 4. Callouts to additional Components (including their methods) or None:
*    - ECOM_IQuoteService.quoteWithLinesOperations -Interface Method
*    - ECOM_IQuoteService.quoteDocumentPdfOperations - Interface Method
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
public with sharing class ECOM_QuoteService implements ECOM_IQuoteService{

    public static final String className = 'ECOM_QuoteService';
   /**
    * @description
    * @author Tushar | 01-29-2026
    * @param request
    * @return ECOM_QuoteWithLinesFlowResponseWrapper
    **/
    public static List<Map<String, Object>> quoteWithLinesOperations(Map<String, Object> quoteWithLineDataMap){
        String methodName = 'quoteWithLinesOperations';
        String supportData = '';
        List<Map<String, Object>> responseMapList = new List<Map<String, Object>>();
        Map<String, Object> responsemap = new Map<String, Object>();
        responseMap.put(ECOM_Constant.PARAM_SUCCESS, false);
        try{
           
            Map<String, String> requestMap = new Map<String, String>();

            //prepare the requestMap from the values provided
            requestMap = ECOM_RestService.prepareRequestMap(System.Label.ECOM_QuoteIntegrationUserNamedCredential,
                                                            System.Label.ECOM_QuoteFlowEndpoint,
                                                            '', 
                                                            ECOM_Constant.HTTP_REQUEST_POST,
                                                            true, 
                                                            quoteWithLineDataMap,
                                                            ECOM_Constant.HTTP_CONTENT_APP_JSON
                                                           );
            System.debug('quoteWithLinesOperations:requestMap:; '+ JSON.serialize(requestMap));

            //callout to Quote With Lines flow endpoint from Custom label ECOM_QuoteIntegrationUserNamedCredential 
            HttpResponse response = ECOM_RestService.calloutAsIntegrationUser(requestMap);
            System.debug('Response:: '+ response + ' Response result:: '+ response.getBody());

            //check HttpResponse and prepare response map
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){
                //parse the response and add to map 
                responseMapList.addAll(parseQuoteWithLinesResult(response)); 
            } else {
                
                responseMap.put(ECOM_Constant.PARAM_MESSAGE, 'Error message for callout failed');
                responseMapList.add(responseMap);
            }


        } catch(Exception e) {
            System.debug('Exception:: '+ e.getStackTraceString());
            ECOM_ApplicationLogsUtil.logFailure(e, ECOM_Constant.QUOTE_WITH_LINES, className, methodName, supportData);
            //TODO:: add Application Util to guest user and also provide access to the object
        }
        return responseMapList;
    }

    /**
    * @description
    * @author Tushar | 01-29-2026
    * @param request
    * @return ECOM_QuoteWithLinesFlowResponseWrapper
    **/
    public static Map<String, Object> quoteDocumentPdfOperations(Map<String, Object> quoteDocumentPDFMap){
        String methodName = 'quoteDocumentPdfOperations';
        String supportdata = '';
        Map<String, Object> responsemap = new Map<String, Object>();
        responseMap.put(ECOM_Constant.PARAM_SUCCESS, false);
        try{
           
            Map<String, String> requestMap = new Map<String, String>();

            //prepare the requestMap from the values provided
            requestMap = ECOM_RestService.prepareRequestMap(System.Label.ECOM_QuoteIntegrationUserNamedCredential,
                                                            System.Label.ECOM_QuoteFlowEndpoint,
                                                            '', 
                                                            ECOM_Constant.HTTP_REQUEST_POST,
                                                            true, 
                                                            quoteDocumentPDFMap,
                                                            ECOM_Constant.HTTP_CONTENT_APP_JSON
                                                           );
            System.debug('quoteWithLinesOperations:requestMap:; '+ JSON.serialize(requestMap));

            //callout to Quote With Lines flow endpoint from Custom label ECOM_QuoteIntegrationUserNamedCredential 
            HttpResponse response = ECOM_RestService.calloutAsIntegrationUser(requestMap);
            System.debug('Response:: '+ response + ' Response result:: '+ response.getBody());

            //check HttpResponse and prepare response map
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){
                //parse the response and add to map 
                responseMap.putAll(parseQuoteDocumentPDFResult(response)); 
            } else {
                
                responseMap.put(ECOM_Constant.PARAM_MESSAGE, 'Error message for callout failed');
                //responseMapList.add(responseMap);
            }


        } catch(Exception e) {
            ECOM_ApplicationLogsUtil.logFailure(e, ECOM_Constant.QUOTEDOCUMENT, className, methodName, supportData);
            System.debug('Exception:: '+ e.getStackTraceString());
            //TODO:: add Application Util to guest user and also provide access to the object
        }
        System.debug('responseMap::::'+responseMap);
        return responseMap;
    }

    /**
    * @description Fetches a single quote with its lines
    * @author Shubham | 02-06-2026
    * @param request Map containing varQuoteId and varQuoteWorkflowType
    * @return Map<String, Object> containing the quote data with lines
    **/
    public static Map<String, Object> singleQuoteWithLinesOperations(Map<String, Object> quoteWithLineDataMap){
        String methodName = 'singleQuoteWithLinesOperations';
        String supportData = '';
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(ECOM_Constant.PARAM_SUCCESS, false);
        
        try{
            Map<String, String> requestMap = new Map<String, String>();
    
            // Prepare the requestMap from the values provided
            requestMap = ECOM_RestService.prepareRequestMap(
                System.Label.ECOM_QuoteIntegrationUserNamedCredential,
                System.Label.ECOM_QuoteFlowEndpoint,
                '', 
                ECOM_Constant.HTTP_REQUEST_POST,
                true, 
                quoteWithLineDataMap,
                ECOM_Constant.HTTP_CONTENT_APP_JSON
            );
            
            System.debug('singleQuoteWithLinesOperations:requestMap: ' + JSON.serialize(requestMap));
    
            // Callout to Quote With Lines flow endpoint
            HttpResponse response = ECOM_RestService.calloutAsIntegrationUser(requestMap);
            System.debug('Response: ' + response + ' Response result: ' + response.getBody());
    
            // Check HttpResponse and prepare response map
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){
                // Parse the response using SINGLE QUOTE parser
                responseMap = parseSingleQuoteWithLinesResult(response); 
                
                if(!responseMap.isEmpty() && responseMap.get('Name') != null) {
                    responseMap.put(ECOM_Constant.PARAM_SUCCESS, true);
                } else {
                    responseMap.put(ECOM_Constant.PARAM_SUCCESS, false);
                    responseMap.put(ECOM_Constant.PARAM_MESSAGE, 'Quote not found');
                }
            } else {
                responseMap.put(ECOM_Constant.PARAM_MESSAGE, 'Error: Callout failed with status ' + response.getStatusCode());
            }
    
        } catch(Exception e) {
            System.debug('Exception: ' + e.getStackTraceString());
            responseMap.put(ECOM_Constant.PARAM_MESSAGE, e.getMessage());
            ECOM_ApplicationLogsUtil.logFailure(e, ECOM_Constant.QUOTE_WITH_LINES, className, methodName, supportData);
        }
        
        return responseMap;
    }


    /**
     * @description This method checks the HttpResponse object returned from Quote With Lines callback and parses the result
     * @author Tushar Arora | 2025 Jan 28 ECOM-5262
     * @param response | HttpResponse 
     * @returns Map<String, Object>
     */
    @TestVisible
    private static List<Map<String, Object>> parseQuoteWithLinesResult(HttpResponse responseObject) {
        List<Map<String, Object>> responseMapList = new List<Map<String, Object>>();
        
        String responseBody = responseObject.getBody();
        // 1) Parse outer array
        List<Object> outerObject = (List<Object>) JSON.deserializeUntyped(responseBody);
        // 2) First element is a Map with "outputValues"
        Map<String, Object> firstObject = (Map<String, Object>) outerObject.get(0);
        Map<String, Object> outputValues = (Map<String, Object>) firstObject.get('outputValues');
        
        Object qwr = ((Map<String, Object>) outputValues).get('quoteWrapperResponse');
        if (!(qwr instanceof List<Object>)) return responseMapList;

        for (Object o : (List<Object>) qwr) {
            if (o instanceof Map<String, Object>) {
                responseMapList.add((Map<String, Object>) o);
            }
        }

        
        System.debug('responseMapList::::'+responseMapList);
        return responseMapList;
    }

    /**
     * @description Parse single quote response (uses quoteWrapperRecord instead of quoteWrapperResponse)
     * @author Shubham | 02-06-2026
     * @param response | HttpResponse 
     * @returns Map<String, Object>
     */
    @TestVisible
    private static Map<String, Object> parseSingleQuoteWithLinesResult(HttpResponse responseObject) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            String responseBody = responseObject.getBody();
            
            // 1) Parse outer array
            List<Object> outerObject = (List<Object>) JSON.deserializeUntyped(responseBody);
            
            // 2) First element is a Map with "outputValues"
            Map<String, Object> firstObject = (Map<String, Object>) outerObject.get(0);
            Map<String, Object> outputValues = (Map<String, Object>) firstObject.get('outputValues');
            
            // 3) Get the single quote from quoteWrapperRecord (not quoteWrapperResponse!)
            Object quoteRecord = outputValues.get('quoteWrapperRecord');
            
            if (quoteRecord != null && quoteRecord instanceof Map<String, Object>) {
                responseMap = (Map<String, Object>) quoteRecord;
            }
            
        } catch (Exception e) {
            System.debug('Error parsing single quote response: ' + e.getMessage());
        }
        
        return responseMap;
    }

    /**
     * @description This method checks the HttpResponse object returned from Quote With Lines callback and parses the result
     * @author Tushar Arora | 2025 Jan 28 ECOM-5262
     * @param response | HttpResponse 
     * @returns Map<String, Object>
     */
    @TestVisible
    private static Map<String, Object> parseQuoteDocumentPDFResult(HttpResponse responseObject) {

        Map<String, Object> responseMap = new Map<String, Object>();
        String responseBody = responseObject.getBody();
        // 1) Parse outer array
        List<Object> outerObject = (List<Object>) JSON.deserializeUntyped(responseBody);
        // 2) First element is a Map with "outputValues"
        Map<String, Object> firstObject = (Map<String, Object>) outerObject.get(0);
        Map<String, Object> outputValues = (Map<String, Object>) firstObject.get('outputValues');
        if(outputValues.get('quoteDocumentResponse') != null){
            responseMap = (Map<String, Object>) outputValues.get('quoteDocumentResponse');
        } else if(outputValues.get('outputDocumentStatus') != null){
            responseMap = outputValues;
        }
        

        return responseMap;
    }
}