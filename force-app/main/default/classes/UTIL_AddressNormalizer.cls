/**************************************************************
* 1. Jira Ticket(s)
*    ATEAM-2220
* 
* 2. Description - This test apex class is used to make address string normalized for comparison
*
* 3. Objects referenced
*    - Info_Central__c
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    - None
*
* 6. Test Class Name: UTIL_AddressNormalizer_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    -BD 2024.03.28 Base
*    -    
*    -
*************************************************************/ 
public class UTIL_AddressNormalizer {

    // Define a clear input structure
    public class InputWrapper {
        @InvocableVariable public String Input_Street;
        @InvocableVariable public String Input_City;
        @InvocableVariable public String Input_State;
        @InvocableVariable public String Input_Country;
        @InvocableVariable public String Input_Postal;

    }

    // Define a clear output structure
    public class OutputWrapper {
        @InvocableVariable public String Output_Street;
        @InvocableVariable public String Output_City;
        @InvocableVariable public String Output_State;
        @InvocableVariable public String Output_Country;
        @InvocableVariable public String Output_Postal;
    }

    @InvocableMethod(label='Normalize Address Fields' description='Normalize Street, City, State, Country, Postal fields')
    public static List<OutputWrapper> normalizeAddress(List<InputWrapper> inputs) {

        // Fetch all metadata entries once
        List<C_META_Address_Normalization__mdt> metaList = [SELECT BEFORE__c, AFTER__c, TYPE__c FROM C_META_Address_Normalization__mdt WHERE EXCLUDE__c = false];

        // Organize metadata into type-based maps for efficient lookup
        Map<String, Map<String, String>> metaMap = new Map<String, Map<String, String>>();
        for (C_META_Address_Normalization__mdt m : metaList) {
            if (!metaMap.containsKey(m.TYPE__c)) {
                metaMap.put(m.TYPE__c, new Map<String, String>());
            }
            metaMap.get(m.TYPE__c).put(m.BEFORE__c.toUpperCase(), m.AFTER__c.toUpperCase());
        }

        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputs) {
            OutputWrapper output = new OutputWrapper();

            output.Output_Street  = normalizeField(input.Input_Street,  metaMap.get('STREET'));
            output.Output_City    = normalizeField(input.Input_City,    metaMap.get('CITY'));
            output.Output_State   = normalizeField(input.Input_State,   metaMap.get('STATE'));
            output.Output_Country = normalizeField(input.Input_Country, metaMap.get('COUNTRY'));
            output.Output_Postal  = normalizeField(input.Input_Postal,  metaMap.get('POSTAL'));
            
            output.Output_Street   = String.isBlank(output.Output_Street) ? '' : output.Output_Street.toUpperCase();
            output.Output_City     = String.isBlank(output.Output_City) ? '' : output.Output_City.toUpperCase();
            output.Output_State    = String.isBlank(output.Output_State) ? '' : output.Output_State.toUpperCase();
            output.Output_Country  = String.isBlank(output.Output_Country) ? '' : output.Output_Country.toUpperCase();
            output.Output_Postal   = String.isBlank(output.Output_Postal) ? '' : output.Output_Postal.toUpperCase();
            

            results.add(output);
        }

        return results;
    }

    // Helper method for normalization
   private static String normalizeField(String value, Map<String, String> abbrevMap) {
    if (String.isBlank(value) || abbrevMap == null) return value;

    // First uppercase and remove punctuation
    String temp = value.toUpperCase().replaceAll('[^A-Z0-9 ]', ' ');

    // Explicit debug for quick check (remove later)
    System.debug('Before normalization: ' + temp);
    System.debug('Abbrev Map: ' + abbrevMap);

    // Loop carefully with word boundaries
    for (String before : abbrevMap.keySet()) {
        temp = temp.replaceAll('\\b' + Pattern.quote(before.toUpperCase()) + '\\b', abbrevMap.get(before));
    }
    
    temp = temp.toUpperCase().replaceAll('\\s+', ' ').trim();
    System.debug('After normalization: ' + temp);
    return temp;
  }

}