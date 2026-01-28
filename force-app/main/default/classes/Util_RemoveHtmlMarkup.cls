/**************************************************************
 * 1. Jira Ticket(s) that relates to this class
 *    - INC0456551-Interaction Selection from Opp creation changes and Set values fro Inetraction to opp.
 *
 * 2. Description - This class is used to remove complex HTML Markup in to Plain text 
 *
 * 3. Objects referenced
 *    -None
 *
 * 4. Callouts to additional Components (including their methods)- None
 *
 * 5. Dependant Class(es): None
 *
 * 6. Test Class Name: Util_RemoveHtmlMarkup_Test
 *
 * 7. Is @Invocable (Yes or No):  Yes
 *
 * 8. Author Name(s):
 *    - (PwC Avinash Kumar) (2025.03.10)
 *    - First Last & Updated Date(YYYY.MM.DD)
 *
 *************************************************************/
public class Util_RemoveHtmlMarkup {
	@InvocableMethod (Label='Removes HTML markup and returns plain text') 
	public static List<String> stripHtmlTags (List<String> htmlFormattedText) {
	
		List<String> plainText = new List<String>();
		for (string str: htmlFormattedText) 
			{
                if(str !=null)
                {
                    plaintext.add(str.stripHtmlTags());
                }	
			}
		
		return plaintext;
	}
}