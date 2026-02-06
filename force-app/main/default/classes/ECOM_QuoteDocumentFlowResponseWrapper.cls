/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    ECOM-5261,ECOM-5262,ECOM-5263
*
* 2. Description - This class is used as a Wrapper for Quote Document Response to be called from UI.
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
public class ECOM_QuoteDocumentFlowResponseWrapper {
    @auraEnabled
    public String fileName;
    @auraEnabled
    public String contentType;
    @auraEnabled
    public String quoteDocumentBody;
}