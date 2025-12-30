/**************************************************************
* 1. Jira Ticket(s)
*
* 2. Description - This test apex class for util_json_prettyprint_Test apex class, Which is used to handle the JSON and process to prettyprint
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
*    - Vishwas & Created Date(2024.12.19)
*    -
*************************************************************/ 
@isTest
public class util_json_prettyprint_Test {
 @isTest
    public static void testPrettyPrintValidJson() {
        // Arrange: Prepare test data with valid JSON strings
        List<String> requests = new List<String>{
            '{"name": "John", "age": 30, "city": "New York"}',
            '{"employeeId": 12345, "department": "Sales", "status": "Active"}'
        };

        // Act: Call the method to get pretty-printed JSON strings
        List<String> results = util_json_prettyprint.prettyPrintInvocable(requests);

        // Assert: Verify the results
        System.assertEquals(2, results.size(), 'There should be 2 results');
        
        // Verify that the JSON strings are pretty-printed (by checking the indentation)
        System.assert(results[0].contains('\n'), 'The first JSON string should be pretty-printed');
        System.assert(results[1].contains('\n'), 'The second JSON string should be pretty-printed');
    }

    @isTest
    public static void testPrettyPrintInvalidJson() {
        // Arrange: Prepare test data with invalid JSON strings
        List<String> requests = new List<String>{
            '{"name": "John", "age": 30, "city": "New York",}',  // Invalid JSON (extra comma)
            '{"employeeId": 12345, "department": "Sales", "status": "Active"'  // Missing closing brace
        };

        // Act: Call the method to get results
        List<String> results = util_json_prettyprint.prettyPrintInvocable(requests);

        // Assert: Verify that invalid JSON results in an error message
        System.assertEquals(2, results.size(), 'There should be 2 results');
        
        // Verify that the error messages are returned for invalid JSON
        System.assert(results[0].startsWith('Invalid JSON'), 'The first result should be an error message');
        System.assert(results[1].startsWith('Invalid JSON'), 'The second result should be an error message');
    }

    @isTest
    public static void testEmptyInput() {
        // Arrange: Prepare an empty list
        List<String> requests = new List<String>();

        // Act: Call the method with an empty input
        List<String> results = util_json_prettyprint.prettyPrintInvocable(requests);

        // Assert: Verify that the result is an empty list
        System.assertEquals(0, results.size(), 'The result should be an empty list');
    }
}