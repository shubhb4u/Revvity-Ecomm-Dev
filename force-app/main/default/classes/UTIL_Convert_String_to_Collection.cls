/**************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description -Utillity class for conversion of String to Collection
  * 3. Objects referenced
  *    -None
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None
  *   
  *
  * 5. Dependant Class(es):
  * 6. Invocable: True
  *
  * 7. Test Class Name: UTIL_Convert_String_to_Collection_Test
  *
  * 8. Author Name(s): 
  *    -AP/VG 202.09.22 Base
  *    -BD 2024.04.30 Added Dedupe parameter (True is default)/Added Sort Parameter (True is Default/False=Original Order)
  *    -BD 2024.04.30 Added 2nd output option as string
  *    -
*************************************************************/ 
public class UTIL_Convert_String_to_Collection {

    @InvocableMethod
    public static List<FlowOutputs> flowcalled(List<FlowInputs> requests) {
        List<FlowOutputs> fOutlist = new List<FlowOutputs>();

        // 1. Loop through each input record passed from Flow
        if (requests != null && !requests.isEmpty()) {
            for (FlowInputs finpt : requests) {
                FlowOutputs fout = new FlowOutputs();
                List<String> outputList = new List<String>();
                Set<String> seen = new Set<String>();

                // 2. Check that input string isn't blank
                if (String.isNotBlank(finpt.varString)) {
                    List<String> rawList;

                    // 3. Choose delimiter: prefer semicolon, fallback to comma
                    if (finpt.varString.containsIgnoreCase(';')) {
                        rawList = finpt.varString.split(';');
                    } else {
                        rawList = finpt.varString.split(',');
                    }

                    // 4. Trim and dedupe based on flags
                    for (String str : rawList) {
                        String trimmed = str?.trim();
                        if (trimmed == null) continue;

                        if (finpt.dedupe == false) {
                            outputList.add(trimmed);
                        } else if (!seen.contains(trimmed)) {
                            outputList.add(trimmed);
                            seen.add(trimmed);
                        }
                    }

                    // 5. Sort list if requested (default = true)
                    if (finpt.sortValues == null || finpt.sortValues == true) {
                        outputList.sort();
                    }
                }

                // 6. Set outputs: cleaned list + re-joined string
                fout.liststring = outputList;
                fout.varString = String.join(outputList, ';');
                fOutlist.add(fout);
            }
        }

        return fOutlist;
    }

    public class FlowInputs {
        @InvocableVariable public String varString;            // Input string (semicolon- or comma-separated)
        @InvocableVariable public Boolean dedupe;              // Optional: remove duplicates (default = true)
        @InvocableVariable public Boolean sortValues;          // Optional: sort alphabetically (default = true)
    }

    public class FlowOutputs {
        @InvocableVariable public List<String> liststring;     // Output collection
        @InvocableVariable public String varString;            // Output string (cleaned and joined with semicolons)
    }
}