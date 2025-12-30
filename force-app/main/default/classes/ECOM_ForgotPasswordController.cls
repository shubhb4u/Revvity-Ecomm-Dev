/**************************************************************
* 1. Jira Ticket(s) that relates to this class 
*    - ECOM-2302
*
* 2. Description - This class is controller class for Forgot password page
*				 - Method <TBD>: handles the requests to register a new user   
*
*
* 3. Objects referenced
*    -
*
* 4. Callouts to additional Components (including their methods) or None:
*    - 
*
* 5. Dependant Class(es):
*    - ECOM_RegistrationWrapper
*
* 6. Test Class Name: 
*
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s):
*    - Vasudev R 2024-05-16 : Initial creation
*************************************************************/
public class ECOM_ForgotPasswordController {

    
    /**
     * @description This method calls out to reset the password for the user
     * @author vramachandran@rafter.one | 16 May 2024
     * @param emailId | String 
     * @returns Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> resetUserPassword(String emailString) {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(ECOM_Constant.PARAM_SUCCESS, false);
        
        try{
            
            Map<String, Object> requestBody = new Map<String, Object>();
            
            ECOM_RegistrationWrapper.UserEmailWrapper emailWrapper = new ECOM_RegistrationWrapper.UserEmailWrapper();
            emailWrapper.userEmail = emailString;
            emailWrapper.emailTemplate = System.Label.ECOM_CustomForgotPasswordTemplate;
            
            Map<String, String> requestMap = ECOM_RestService.prepareRequestMap(System.Label.ECOM_IntegrationUserNamedCredential,
                                                                                System.Label.ECOM_RegisteredUserPasswordResetEndpoint,
                                                                                '', 
                                                                                ECOM_Constant.HTTP_REQUEST_POST,
                                                                                false, 
                                                                                null,
                                                                                ECOM_Constant.HTTP_CONTENT_APP_JSON
                                                                               );
            requestMap.put(ECOM_Constant.HTTP_REQUEST_BODY, JSON.serialize(emailWrapper));
            
            System.debug('preparedMap :: '+ JSON.serialize(requestMap));
            HttpResponse response = ECOM_RestService.calloutAsIntegrationUser(requestMap);
			System.debug('RESPONSE:: '+ response.getBody());
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201)){

                String bodyValue = response.getBody().replace('\\', '').removeEnd('"').removeStart('"');
                System.debug('bodyValue:: ' + bodyValue);
                
            	Map<String, Object> calloutResponseMap = (Map<String, Object>) JSON.deserializeUntyped(bodyValue);
                String message = (null != calloutResponseMap && calloutResponseMap.containsKey(ECOM_Constant.PARAM_MESSAGE)) ? (String) calloutResponseMap.get(ECOM_Constant.PARAM_MESSAGE) : '';
                responseMap.put(ECOM_Constant.PARAM_RESPONSE_DATA, message);
                if(calloutResponseMap.containsKey('customerEmail')){
                    responseMap.put('customerEmail', (String)calloutResponseMap.get('customerEmail'));
                }
                Boolean isSuccess = (null != calloutResponseMap && calloutResponseMap.containsKey(ECOM_Constant.PARAM_SUCCESS)) ? (Boolean) calloutResponseMap.get(ECOM_Constant.PARAM_SUCCESS) : false;
                responseMap.put(ECOM_Constant.PARAM_SUCCESS, isSuccess);
                if(!isSuccess) logResult(message, emailString);//Added by VRa for logging Sep 16 24
            }
            
        }catch(Exception e){
            System.debug('Exception:: ' + e.getStackTraceString());
        }
        
        return responseMap;
    }
    
    @TestVisible //Added by VRa for logging Sep 16 24
    private static void logResult(String message, String userEmail) {
        try{
            throw new ECOM_SystemException(message);
        }catch(ECOM_SystemException e){
            ECOM_ApplicationLogsUtil.logFailure(e , 'Reset Password' , 'ECOM_ForgotPasswordController' , 'resetUserPassword', 'UserEmail:: '+ userEmail  + ' Stack:: '+ e.getStackTraceString(), userEmail);
        }
    }
}