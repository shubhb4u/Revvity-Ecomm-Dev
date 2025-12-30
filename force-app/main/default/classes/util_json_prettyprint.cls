/**************************************************************
* 1. Jira Ticket(s)
*
* 2. Description - This test apex class is used to handle the JSON and process to prettyprint
     JSON
*
* 3. Objects referenced
*    - No
*
* 4. Callouts to additional Components (including their methods) or None:None
*    
* 5. Dependant Class(es):
*    - 
*    
*
* 6. Test Class Name: util_json_prettyprint_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    - Brad & Created Date(2024.12.03) Base
*    -Vishwas Updated date(2024.12.19) Updated header
*************************************************************/ 
public class util_json_prettyprint {
    /**
     * Invocable method to pretty-print JSON input strings.
     *
     * @param requests A list of JSON input strings.
     * @return A list of pretty-printed JSON strings.
     */
    @InvocableMethod(label='Pretty Print JSON' description='Takes JSON input and returns a pretty-printed version.')
    public static List<String> prettyPrintInvocable(List<String> requests) {
        List<String> results = new List<String>();
        
        for (String jsonString : requests) {
            try {
                // Parse the JSON string into an Object
                Object parsedJson = JSON.deserializeUntyped(jsonString);
                
                // Serialize the Object back into a pretty-printed JSON string
                results.add(JSON.serializePretty(parsedJson));
            } catch (System.JSONException ex) {
                results.add('Invalid JSON: ' + ex.getMessage());
            }
        }
        
        return results;
    }
}