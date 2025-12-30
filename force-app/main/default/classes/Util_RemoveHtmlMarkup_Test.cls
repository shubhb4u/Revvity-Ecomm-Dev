/**************************************************************
 * 1. Jira Ticket(s) that relates to this class
 *    - INC0456551-Interaction Conversion Process Existing Opp Selection and Interaction Selection from Opp creation changes
 *
 * 2. Description - This class is used to remove complex HTML Markup in to Plain text 
 *
 * 3. Objects referenced
 *    -None
 *
 * 4. Callouts to additional Components (including their methods)- None
 *
 * 5. Dependant Class(es): Util_RemoveHtmlMarkup
 *
 * 6. Test Class Name: Util_RemoveHtmlMarkup_Test
 *
 * 7. Is @Invocable (Yes or No):  Yes
 *
 * 8. Author Name(s):
 *    - (PwC Avinash Kumar) (2024.03.11)
 *    - First Last & Updated Date(YYYY.MM.DD)
 *
 *************************************************************/
@IsTest(SeeAllData=true)
public class Util_RemoveHtmlMarkup_Test {
    @isTest
    public static void testStripHtmlTags() {
        // Test data with HTML markup
        List<String> richText = new List<String>{
            '<p>Hello <b>World</b></p>',
            '<h1>This is a <i>Test</i></h1>',
            '<a href="https://example.com">Click Here</a>'
        };
        // Call the Invocable method (which would be invoked in your real use case)
        Test.startTest();
        List<String> result = Util_RemoveHtmlMarkup.stripHtmlTags(richText);
        Test.stopTest();
        // Assert that the HTML tags are removed, leaving only plain text
        System.assertEquals('Hello World', result[0]);
        System.assertEquals('This is a Test', result[1]);
        System.assertEquals('Click Here', result[2]);
    }
}