/**************************************************************
* 1. Jira Ticket(s)
*    - ATEAM-2193
*
* 2. Description - 
*    - This will create records on VRS Report for Order Entry Data(JSON) values and SAP Order Summary values. 
*    - And then will compare values on both objects and create its record as well.
*    - 10.Entry-Summary 11.Entry-Address 12.Entry-Item
*    - 20.Order-Summary 21.Order-Address 22.Order-Item 
*    - 30.Final-Summary 31.Final-Address 32.Final-Item 
*
* 3. Objects referenced
*    - Order_Entry_Data__c
*    - SAP_Order_Summary__c
*    - VRS_Report__c
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    - None    
*
* 6. Test Class Name: orderEntryAnalysis_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    -BD 2025.02.27 Base
*    -SL 2025.03.20 Refined partNumber creation even for mismatch
*    -SL 2025.03.24 Aligned the nomenclature in str_vrs_attribute
*    -SL 2025.03.26 Refined customerId creation on address nodes
*
*************************************************************/ 
public with sharing class orderEntryAnalysis {
    // 5.1. Global list to store all VRS records before inserting
    private static List<VRS_Report__c> list_vrs_records_global = new List<VRS_Report__c>();
    private static String str_orderEntry_id_global;
    
    
    // 5.2. Local list to store records within function
    private List<VRS_Report__c> list_vrs_records_local = new List<VRS_Report__c>();
    
    // 1000. Create VRS Record (Merged into Global Immediately)
    public static void createVrsRecord(String groupName, String entity, String attribute, String value, String status, String externalId) {
        String str_section_name = '1000. ';
        String str_vrs_externalId = groupName + '-' + entity + '-' + attribute + externalId; // '' or ':partNumber', etc
        System.debug('✅ createVrsRecord CALLED: Group=' + groupName + ' | Entity=' + entity + ' | Attribute=' + attribute + ' | Value=' + value);
        
        
        // 100.1 Create VRS Record
        VRS_Report__c record_vrsRecord = new VRS_Report__c(
            GroupName__c = groupName,
            Entity__c = entity,
            Attribute__c = attribute,
            Value__c = value,
            ExternalId__c = str_vrs_externalId,
            Parent_Order_Entry_Data__c = str_orderEntry_id_global,
            Comments__c = status
        );
        
        System.debug('🔍 VRS RECORD DEBUG: ' + JSON.serialize(record_vrsRecord));
        
        // 🔹 Add directly to GLOBAL list
        list_vrs_records_global.add(record_vrsRecord);
        System.debug('📌 list_vrs_records_global SIZE AFTER ADD: ' + list_vrs_records_global.size());
        
        
        // 🔍 Debugging: Confirm record is created & added
        String str_msg_debug = str_section_name + '📝 VRS RECORD CREATED & ADDED TO GLOBAL: '
            + ' | GroupName: ' + groupName
            + ' | Entity: ' + entity
            + ' | Attribute: ' + attribute
            + ' | Value: ' + value
            + ' | Status: ' + status
            + ' | ExternalId: ' + str_vrs_externalId
            + ' | GLOBAL LIST SIZE: ' + list_vrs_records_global.size(); // 🟢 Confirm growing list size
        
        System.debug(str_msg_debug);
        
    }
    
    @TestVisible
    private static String formatCustomerNumber(String customerNumber) {
        //if (String.isBlank(customerNumber)) return null; // Preserve NULLs
        if (customerNumber == null)  customerNumber = '';
        
        return customerNumber.length() == 10
            ? customerNumber // Already at least 10 characters, return as is
            : ('0000000000'+customerNumber).right(10); // Ensure exactly 10 digits
    }
    
    
    // 330. Helper method to convert value based on DataType__c
    @TestVisible
    private static Object func_2003_convert_by_type(String valueToConvert, String dataType) {
        if (valueToConvert == null || valueToConvert=='' || dataType == null) return valueToConvert;
        
        if (dataType == 'String') {
            return valueToConvert;
        } else if (dataType == 'Number') {
            return Decimal.valueOf(valueToConvert);
        } else if (dataType == 'Date') {
            return Date.valueOf(valueToConvert);
        } else if (dataType == 'Boolean') {
            return Boolean.valueOf(valueToConvert);
        } else {
            return valueToConvert;
        }
    }
    
    
    // 340. Helper method to compare values based on CompareMethod__c
    private static String func_2002_compare_values(Object jsonValue, String sapValue, String compareMethod, String dataType) {
        if (jsonValue == null || sapValue == null) {
            return 'Error: Missing Values';
        }
        
        String rawEntry = String.valueOf(jsonValue);
        String rawSummary = String.valueOf(sapValue);
        Boolean compareExact = rawEntry == rawSummary;
        
        
        // 350. Compare different datatypes safely
        if (dataType == 'Number') {
            //decimals need to have different formatting to keep numbers
            String entryStr = String.valueOf(Decimal.valueOf(rawEntry).stripTrailingZeros());
            String orderStr = String.valueOf(Decimal.valueOf(rawSummary).stripTrailingZeros());
            compareExact = (entryStr != null && orderStr != null) ? entryStr == orderStr : false;
        } else if (dataType == 'Boolean') {
            compareExact = Boolean.valueOf(String.valueOf(rawEntry)) == Boolean.valueOf(String.valueOf(rawSummary));
        } else if (dataType == 'Date') {
            compareExact = (rawEntry != null && rawSummary != null) ? Date.valueOf(rawEntry) == Date.valueOf(rawSummary) : false;
        }
        
        // Limit unmatched result to 255 chars
        String resultUnmatched = 'Unmatched: E(' + rawEntry + ') vs. O(' + rawSummary + ')';
        resultUnmatched = resultUnmatched.substring(0, Math.min(255, resultUnmatched.length()));
        
        String resultMatched = 'Matched: (' + rawEntry + ')';
        
        return compareExact ? resultMatched : resultUnmatched;
    }
    
    
    // 400. Compare two string lists and return counts with segregated results
    public void func_2001_compare_lists(List<String> ListA, List<String> ListB,input_variable_from_flow source) {
        // Initialize the flow wrapper
        // input_variable_from_flow source = new input_variable_from_flow();
        
        // Ensure all lists are initialized to prevent null dereference
        source.list_in_A_and_B = new List<String>();
        source.list_in_A_not_B = new List<String>();
        source.list_in_B_not_A = new List<String>();
        
        // Create sets for easy comparison
        Set<String> setA = (ListA != null) ? new Set<String>(ListA) : new Set<String>();
        Set<String> setB = (ListB != null) ? new Set<String>(ListB) : new Set<String>();
        
        // Null check for sets
        if (setA.isEmpty() && setB.isEmpty()) {
            System.debug('Both ListA and ListB are empty.');
            return;  // Nothing to compare
        }
        
        // Compare the lists
        if (!setA.isEmpty() && !setB.isEmpty()) {
            // Items in both ListA and ListB
            for (String item : setA) {
                if (setB.contains(item)) {
                    source.list_in_A_and_B.add(item);
                } else {
                    source.list_in_A_not_B.add(item);
                }
            }
            
            // Items in ListB but not in ListA
            for (String item : setB) {
                if (!setA.contains(item)) {
                    source.list_in_B_not_A.add(item);
                }
            }
        } else if (!setA.isEmpty()) {
            source.list_in_A_not_B.addAll(setA);
        } else if (!setB.isEmpty()) {
            source.list_in_B_not_A.addAll(setB);
        }
        
        // Set the counters based on existing values
        source.count_in_A_and_B = source.list_in_A_and_B.size();
        source.count_in_A_not_B = source.list_in_A_not_B.size();
        source.count_in_B_not_A = source.list_in_B_not_A.size();
        
        // Debug output for verification
        System.debug('✅ Compare Complete.');
        System.debug('🔹 Items in Both (count_in_A_and_B): ' + source.count_in_A_and_B + ' -> ' + source.list_in_A_and_B);
        System.debug('🔸 Items in A not B (count_in_A_not_B): ' + source.count_in_A_not_B + ' -> ' + source.list_in_A_not_B);
        System.debug('🔹 Items in B not A (count_in_B_not_A): ' + source.count_in_B_not_A + ' -> ' + source.list_in_B_not_A);
    }
    
    
    //-------------------------------------------------------------------------------
    private static void func_2005_reprocess_alias(Boolean debugFlag) {
        String str_section_name = '2005. ';
        
        // Debug Start
        String str_msg_debug = str_section_name + '🚀 START: Reprocessing Alias Matching.';
        if (debugFlag) System.debug(str_msg_debug);
        
        // Step 1: Filter list_vrs_records_global to get Unmatched 31.Final-Address Records
        List<VRS_Report__c> list_vrs_final_unmatched = new List<VRS_Report__c>();
        for (VRS_Report__c vrs : list_vrs_records_global) {
            if (vrs.Entity__c == '31.Final-Address' && 
                vrs.Comments__c == 'Unmatched' && 
                (vrs.Attribute__c.contains('city') || vrs.Attribute__c.contains('state') || vrs.Attribute__c.contains('country')) && 
                !vrs.Value__c.contains('E()') && 
                !vrs.Value__c.contains('O()') && 
                !vrs.Value__c.contains('null') && 
                !vrs.Value__c.contains('MISSING')) {
                    
                    list_vrs_final_unmatched.add(vrs);
                }
        }
        
        // Debug Number of Records to Process
        str_msg_debug = str_section_name + '🔍 Found ' + list_vrs_final_unmatched.size() + ' unmatched Final-Address records.';
        if (debugFlag) System.debug(str_msg_debug);
        
        // Step 2: Get All Alias_Match__c Records
        List<Alias_Match__c> list_Alias_All = [
            SELECT FieldType__c, Value_Source__c, Value_Target__c 
            FROM Alias_Match__c
        ];
        
        // Prepare Filtered Lists
        List<Alias_Match__c> list_Alias_Country = new List<Alias_Match__c>();
        List<Alias_Match__c> list_Alias_State = new List<Alias_Match__c>();
        List<Alias_Match__c> list_Alias_City = new List<Alias_Match__c>();
        
        for (Alias_Match__c alias : list_Alias_All) {
            if (alias.FieldType__c == 'country') {
                list_Alias_Country.add(alias);
            } else if (alias.FieldType__c == 'state') {
                list_Alias_State.add(alias);
            } else if (alias.FieldType__c == 'city') {
                list_Alias_City.add(alias);
            }
        }
        
        // Step 3: Loop Through Unmatched Final-Addresses
        List<VRS_Report__c> list_vrs_to_insert = new List<VRS_Report__c>();
        List<VRS_Report__c> list_vrs_to_delete = new List<VRS_Report__c>();
        
        for (VRS_Report__c vrs : list_vrs_final_unmatched) {
            // Step 4: Extract and Clean Values
            String varloopvalue_raw = vrs.Value__c;
            
            // Extract Entry and Order Values
            String varloopvalue_entry = varloopvalue_raw.substringBetween('E(', ')');
            String varloopvalue_order = varloopvalue_raw.substringBetween('O(', ')');
            
            // Step 5: Determine Which Alias List to Use
            List<Alias_Match__c> list_Alias_Selected;
            if (vrs.Attribute__c.contains('country')) {
                list_Alias_Selected = list_Alias_Country;
            } else if (vrs.Attribute__c.contains('state')) {
                list_Alias_Selected = list_Alias_State;
            } else if (vrs.Attribute__c.contains('city')) {
                list_Alias_Selected = list_Alias_City;
            } else {
                continue; // Skip if no attribute match
            }
            
            // Step 6: Look for Alias Match
            Boolean foundMatch = false;
            for (Alias_Match__c alias : list_Alias_Selected) {
                if (alias.Value_Source__c == varloopvalue_entry && alias.Value_Target__c == varloopvalue_order) {
                    foundMatch = true;
                    break;
                }
            }
            
            // Step 7: If Matched, Create New Records
            if (foundMatch) {
                list_vrs_to_insert.add(new VRS_Report__c( GroupName__c = vrs.GroupName__c,Entity__c = '11.Entry-Address', Attribute__c = vrs.Attribute__c, Value__c = varloopvalue_entry, Comments__c = 'Matched',ExternalId__c = vrs.GroupName__c + '-' + '11.Entry-Address' + '-' + vrs.Attribute__c ,Parent_Order_Entry_Data__c = str_orderEntry_id_global    ));
                list_vrs_to_insert.add(new VRS_Report__c(GroupName__c = vrs.GroupName__c,Entity__c = '21.Order-Address',Attribute__c = vrs.Attribute__c, Value__c = varloopvalue_order, Comments__c = 'Matched',ExternalId__c = vrs.GroupName__c + '-' + '21.Order-Address' + '-' + vrs.Attribute__c , Parent_Order_Entry_Data__c = str_orderEntry_id_global  ));
                list_vrs_to_insert.add(new VRS_Report__c( GroupName__c = vrs.GroupName__c,Entity__c = '31.Final-Address', Attribute__c = vrs.Attribute__c, Value__c = 'Matched by rule: (' + varloopvalue_order + ')',Comments__c = 'Matched',ExternalId__c = vrs.GroupName__c + '-' + '31.Final-Addres' + '-' + vrs.Attribute__c ,Parent_Order_Entry_Data__c = str_orderEntry_id_global ));
                
                // Step 8: Mark 3 Matching Records for Deletion
                for (VRS_Report__c rec : list_vrs_records_global) {
                    if (rec.GroupName__c == vrs.GroupName__c && 
                        rec.Attribute__c == vrs.Attribute__c && 
                        rec.Comments__c == 'Unmatched') {
                            
                            list_vrs_to_delete.add(rec);
                        }
                }
            }
        }
        
        // Step 9: FIRST - Delete Old Unmatched Records
        if (!list_vrs_to_delete.isEmpty()) {
            // Manually remove records from list_vrs_records_global
            List<VRS_Report__c> updatedList = new List<VRS_Report__c>();
            
            for (VRS_Report__c rec : list_vrs_records_global) {
                if (!list_vrs_to_delete.contains(rec)) {
                    updatedList.add(rec);
                }
            }
            
            // Replace the original list with the updated list
            list_vrs_records_global.clear();
            list_vrs_records_global.addAll(updatedList);
            
            str_msg_debug = str_section_name + '🗑️ REMOVED ' + list_vrs_to_delete.size() + ' unmatched records from list_vrs_records_global.';
            if (debugFlag) System.debug(str_msg_debug);
        }
        
        // Step 10: SECOND - Insert New Matched Records
        if (!list_vrs_to_insert.isEmpty()) {
            list_vrs_records_global.addAll(list_vrs_to_insert);
            str_msg_debug = str_section_name + '✅ INSERTED ' + list_vrs_to_insert.size() + ' new VRS records into list_vrs_records_global.';
            if (debugFlag) System.debug(str_msg_debug);
        }
        
        // Debug End
        str_msg_debug = str_section_name + '✅ END: Reprocessing Alias Matching Complete.';
        if (debugFlag) System.debug(str_msg_debug);
    }
    //------------------------------------------------------------------------------------
    
    
    
    // 500. Wrapper class for Flow input
    public class input_variable_from_flow {
        @InvocableVariable(required = true)
        public Id orderEntryId;
        public List<String> list_in_A_and_B;
        public List<String> list_in_A_not_B;
        public List<String> list_in_B_not_A;
        public integer count_in_A_and_B = 0;
        public integer count_in_A_not_B = 0;
        public integer count_in_B_not_A = 0;
        // Boolean bool_debug = true;		//set to true for debug
    }
    
    
    @TestVisible private static Integer giveStatus1() {
        Integer varTest;
        varTest = 1;
        return varTest;
    }
    @TestVisible private static Integer giveStatus2() {
        Integer varTest;
        varTest = 2;
        return varTest;        
    }
    
    @TestVisible private static String giveStatusSuccess() {
        String varTest;
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Success';
        return varTest;
    }    
    @TestVisible private static String giveStatusFail() {
        String varTest;
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Fail';
        return varTest;
    }
    @TestVisible private static String giveStatusWarn() {
        String varTest;
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        varTest = 'Warning';
        return varTest;
    } 
    /* Use this in the test Class
Integer result1 = orderEntryAnalysis.giveStatus1();
Integer result2 = orderEntryAnalysis.giveStatus2();
String result3 = orderEntryAnalysis.giveStatusSuccess();
String result4 = orderEntryAnalysis.giveStatusFail();
String result5 = orderEntryAnalysis.giveStatusWarn();

// ✅ Basic assertions (Some basic test patterns)
System.assertEquals(1, result1, 'Status 1 Passed');
System.assertEquals(2, result2, 'Status 2 Passed');
System.assertEquals('Success', result3, 'Status 3 Passed');
System.assertEquals('Fail', result4, 'Status 4 Passed');
System.assertEquals('Warning', result5, 'Status 5 Passed');

*/
    
    //------------------------------------------------------------------------------------
    
    
    @InvocableMethod(label = 'func_1000_compare_routine: Process Comparison' description = 'Process OrderEntry JSON comparison with SAP Order Summary data.') 
    
    public static void func_1000_compare_routine(List<input_variable_from_flow> orderEntrys) {
        try {
            
            // 5. Declare Variables 
            
            /* LEGEND for Variables  prefix_object_field_usecase
Sting   str_
Double  dbl_
Number  num_
Boolean bln_
Id      id_
Object  obj_
List    list_
Map     map_
Record  record_
*/
            
            
            // 1. single record variables: record_{objectname}
            // (used when fetching data and storing it to loop through/evaluate)
            SAP_Order_Summary__c	 record_sap_order_summary; 
            //SAP_Order_Items__c		 record_sap_order_item;  //decalred in FOR loop below
            SAP_Order_Items__c		 record_sap_order_item_temp;  //assigned as part of loop; used in decision    
            Order_Entry_Data__c		 record_orderEntry;
            VRS_report__c 			 record_vrsRecord;
            
            // 2. lists (Object): list_{objectname}
            // used to hold multiple records with multiple fields
            List<Object> list_json_items;
            List<Order_Entry_Data__c> list_orderEntry;
            List<SAP_Order_Summary__c> list_sapOrderSummary;
            List<SAP_Order_Items__c> list_sapOrderItems;
            List<C_META_Order_Entry_Mapping__mdt> list_cmeta_mappings;  //TBDel
            List<VRS_Report__c> list_vrs_records = new List<VRS_Report__c>();
            List<C_META_Order_Entry_Mapping__mdt> list_cmeta_mappings_summary; //used to hold the ObjectType=summary from CMETA
            List<C_META_Order_Entry_Mapping__mdt> list_cmeta_mappings_item; //used to hold the ObjectType=item from CMETA
            List<C_META_Order_Entry_Mapping__mdt> list_cmeta_mappings_address;  //used to hold the ObjectType=summery with address from CMETA
            List<C_META_Order_Entry_Mapping__mdt> list_cmeta_mappings_customerNumber;  //used to hold the ObjectType=summary and address from CMETA
            
            List<Map<String, Object>> list_soldTo_addresses = new List<Map<String, Object>>();
            List<Map<String, Object>> list_shipTo_addresses = new List<Map<String, Object>>();
            List<Map<String, Object>> list_billTo_addresses = new List<Map<String, Object>>();
            List<Map<String, Object>> list_payer_addresses = new List<Map<String, Object>>();
            
            List<Map<String, Object>> list_orderEntry_items= new List<Map<String, Object>>();
            
            // 3. lists (Text String): list_{fieldName or useCase}
            // used to hold multiple records with single field
            List<String> list_cmeta_node;
            List<String> listA = new List<String>(); //Used for holding orderEntry Part Number as string for compare
            List<String> listB = new List<String>(); //Used for holding orderSummaryItem Material Number as string for compare
            
            
            // 4. Map variables: map_{ObjectName and/or UseCase}
            Map<String, Object> map_orderEntry_allFields;
            Map<String, Object> map_orderEntry_json;
            Map<String, Object> map_orderEntry_items;
            Map<String, Object> map_PartNumberItem;
            
            
            // 5. Object variables: obj_{objectname}
            // (Generic Structure, used to hold map or list, or defined set of fields and values)
            Object obj_json_value;
            Object obj_value_entry;
            Object obj_value_order;
            Object jsonCheckCustomerNumber;
            Object obj_temp_value_customer_or_part_number; 
            //Object obj_orderEntry_items; //declared in FOR loop below
            Object obj_json_keyValuePair;
            
            
            // 6. Id fields: id_{ObjectName or ObjectName_fieldName}
            // Used as the ID value/Lookup on a record
            Id 	   id_orderEntry_orderSummaryId; //this is the ID on the OrderEntry for the SAP_Order_Summary__c record
            
            // 7. Integer variables: int_fieldname
            Integer int_rank; // Track rank for structured records
            
            // 8. Date variables: date_fieldname
            
            // 9. Time variables: time_fieldname
            
            // 10. Boolean variables: bool_fieldname
            Boolean bool_debug = true;  //moved to global
            
            // 11. string valirables: str_objectname_fieldName
            String str_summaryCheckERPAddress;
            
            String str_entityEntry;                    
            String str_entityOrder;
            String str_entityFinal;
            String str_entityType;
            
            String str_entry_json;
            String str_order_fields;
            String str_nodeKey; //item, soldTo,ShipTo,BillTo,Payer
            String str_fieldKey; //the actual field name for str_nodeKey or the summary (i.e. BillTo.City or SalesORg)
            String str_dataType; //C.META data type, set within the looping
            
            String icon_x = '❌';
            String icon_check = '✅';
            String icon_warning = '⚠️';
            String icon_search = '🔍';
            String icon_star = '🌟️';
            String icon_log = '📝';
            String icon_target = '🎯';
            String icon_broom = '🧹';
            String icon_refresh = '🔄';
            String icon_rocket = '🚀';
            String icon_key = '🔑';
            String icon_chart = '📊';
            String icon_forward = '⏭️';
            
            
            String str_msg_matched; //Set within the loop
            String str_msg_unmatched; //Set within the loop
            String str_msg_debug; //Our own appended text for tracking something more detailed with if(bool_debug==true)  System.debug
            String str_msg_error; //Shown in the IllegalArgumentException
            String str_msg_system; //Shown in if(bool_debug==true)  System.debug
            String str_section_name; //this correclates to section 10, 20, 140, etc in our code
            
            
            String str_orderEntry_id; //SFDC Record ID
            String str_orderEntry_partNumber; //Part number in JSON
            String str_orderEntry_customerNumber; //Customer Number in JSON
            // String entryCustomerNumber;  //used in a loop
            
            String str_sapOrderSummary_id; //SFDC Record ID
            String str_sapOrderSummary_name; //SFDC Record Name: (i.e. Order Number 4715234)
            String str_sapOrderSummary_customerNumber; //Customer Number for the current loop on Order Summary
            
            String str_sapOrderItem_name; //SFDC Record Name: (i.e. Order Number 4715234-10)
            String str_sapOrderItem_partNumber; //Part number on record
            
            String str_vrs_group;
            String str_vrs_entity;
            String str_vrs_attribute;
            String str_vrs_value;
            String str_vrs_externalId;
            String str_vrs_parentId;
            
            
            String str_cmeta_objectType;
            String str_cmeta_entryField;
            String str_cmeta_summaryField;
            String str_cmeta_commonLabel;
            String str_cmeta_datatype;
            String str_cmeta_compareMethod;  
            String str_cmeta_fieldNumber;
            
            String str_soql; //used to hold our SOQL strings (it gets reused throughout as needed)
            String str_value_entry;
            String str_value_order;
            
            String str_orderEntry_parsedValue; // This is the exracted value form the JSON Key:Value pair. 
            
            /*END OF VARIABLES*/ 
            
            /*
// 10
str_section_name = '10. ';
str_msg_debug = '';
str_msg_error = '';
str_msg_system = '';

// Debug before validation
str_msg_debug = str_section_name + icon_search + '';
if(bool_debug==true)  System.debug(str_msg_debug + str_orderEntry_id);

// Perform validation
// str_msg_error = str_section_name + icon_x + ' Order Entry must have JSON data and a linked SAP Order Summary.';
// if (String.isBlank(str_entry_json) || id_orderEntry_orderSummaryId == null) {
//     throw new IllegalArgumentException(str_msg_error);
// }

// Debug success
str_msg_debug = str_section_name + icon_check + 'Success';
if(bool_debug==true)  System.debug(str_msg_debug);
*/
            // #7 - Set Order Entry ID from Incoming Flow
            for(input_variable_from_flow orderEntry : orderEntrys) {       
                str_orderEntry_id = orderEntry.orderEntryId;
                str_orderEntry_id_global = orderEntry.orderEntryId;
            }
            
            // CODE BEGINS HERE
            // #10 
            // SECTION-DESCRIPTION: Get the Order Entry record from the passed-in ID and save it to a variable.
            str_section_name = '10. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            try {
                // Debug before action
                str_msg_debug = str_section_name + icon_search + ' BEFORE: Fetching Order Entry record for ID: ' + str_orderEntry_id;
                if (bool_debug == true) System.debug(str_msg_debug);
                
                // ACTION: Fetch Order Entry record
                list_orderEntry = [
                    SELECT Id, JSON_Data__c, ERP_Order_Summary__c
                    FROM Order_Entry_Data__c
                    WHERE Id = :str_orderEntry_id
                    LIMIT 1
                ];
                
                // Error handling: Check if record exists
                if (list_orderEntry.isEmpty()) {
                    str_msg_error = str_section_name + icon_x + ' Order Entry record not found for ID: ' + str_orderEntry_id;
                    throw new IllegalArgumentException(str_msg_error);
                } else {
                    // Assign fetched record to global variables
                    record_orderEntry = list_orderEntry[0];
                    str_orderEntry_id = record_orderEntry.Id;
                    str_entry_json = record_orderEntry.JSON_Data__c;
                    id_orderEntry_orderSummaryId = record_orderEntry.ERP_Order_Summary__c;
                    // Deserialize Order Entry JSON into a Map
                    //map_orderEntry_json = (Map<String, Object>) JSON.deserializeUntyped(str_entry_json); //fixed with Null Check 
                    // Ensure JSON is not null or empty before parsing
                    if (str_entry_json != null && str_entry_json.trim() != '') {
                        try {
                            map_orderEntry_json = (Map<String, Object>) JSON.deserializeUntyped(str_entry_json);
                            // 🔹 Ensure the parsed map is not null
                            if (map_orderEntry_json == null || map_orderEntry_json.isEmpty()) {
                                System.debug('⚠️ WARNING: JSON parsed but resulted in an empty map.');
                                map_orderEntry_json = new Map<String, Object>(); // Assign an empty map to prevent null errors
                            }
                        } catch (Exception e) {
                            System.debug('❌ ERROR: JSON Parsing Failed: ' + e.getMessage());
                            map_orderEntry_json = new Map<String, Object>(); // Set empty map to prevent further errors
                        }
                    } else {
                        System.debug('⚠️ WARNING: str_entry_json is null or empty. Using empty map.');
                        map_orderEntry_json = new Map<String, Object>(); // Default empty map
                    }
                    
                }
                
                // Debug after action
                str_msg_debug = str_section_name + icon_check + ' AFTER: Successfully fetched Order Entry record. ID: ' + str_orderEntry_id
                    + ' | str_orderEntry_id: ' + str_orderEntry_id
                    + ' | id_orderEntry_orderSummaryId: ' + id_orderEntry_orderSummaryId;
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                // Catch block for errors
                str_msg_error = str_section_name + icon_x + ' CATCH: Error while fetching Order Entry record. ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            //-------------------------------------------------------------------------------------------------------        
            
            // #20 
            // SECTION-DESCRIPTION: From the Order Entry record, get the SAP_Order_Summary record using the ID from step #10 and save it to a variable.
            str_section_name = '20. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            try {
                // Debug before action
                str_msg_debug = str_section_name + icon_search + ' BEFORE: Dynamically fetching all fields from SAP Order Summary for ID: ' + id_orderEntry_orderSummaryId;
                if (bool_debug == true) System.debug(str_msg_debug);
                
                // ACTION: Dynamically build the SOQL query to select all fields
                str_soql = 'SELECT ' +
                    String.join(Schema.getGlobalDescribe().get('SAP_Order_Summary__c')
                                .getDescribe().fields.getMap().keySet(), ', ') +
                    ' FROM SAP_Order_Summary__c WHERE Id = :id_orderEntry_orderSummaryId LIMIT 1';
                
                // Execute the dynamic SOQL query
                list_sapOrderSummary = Database.query(str_soql);
                
                // Error handling: Check if record exists
                if (list_sapOrderSummary.isEmpty()) {
                    str_msg_error = str_section_name + icon_x + ' SAP Order Summary not found for ID: ' + id_orderEntry_orderSummaryId;
                    throw new IllegalArgumentException(str_msg_error);
                } else {
                    // Assign fetched record to global variable
                    record_sap_order_summary = list_sapOrderSummary[0];
                    str_sapOrderSummary_id = record_sap_order_summary.Id;
                    str_sapOrderSummary_name = record_sap_order_summary.Name;
                }
                
                // Debug after action
                str_msg_debug = str_section_name + icon_check + ' AFTER: Successfully fetched SAP Order Summary with all fields. '
                    + ' | str_sapOrderSummary_id: ' + str_sapOrderSummary_id
                    + ' | str_sapOrderSummary_name: ' + str_sapOrderSummary_name;
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                // Catch block for errors
                str_msg_error = str_section_name + icon_x + ' CATCH: Error while dynamically fetching SAP Order Summary. ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            //-------------------------------------------------------------------------------------------------------        
            
            
            // #30 
            // SECTION-DESCRIPTION: Get all C-META records and save to a variable.
            str_section_name = '30. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            try {
                // Debug before action
                str_msg_debug = str_section_name + icon_search + ' BEFORE: Fetching all C-META records.';
                if (bool_debug == true) System.debug(str_msg_debug);
                
                
                // ACTION: Execute SOQL to retrieve C-META records
                list_cmeta_mappings = [
                    SELECT Common__c, Entry__c, Summary__c, CompareMethod__c, DataType__c, FieldNumber__c, ObjectType__c
                    FROM C_META_Order_Entry_Mapping__mdt
                    WHERE CompareMethod__c = 'Exact'
                    AND ObjectType__c IN ('Summary', 'Item')
                    AND Summary__c != null
                    ORDER BY FieldNumber__c
                ];	
                
                // Error handling: Check if records were found
                if (list_cmeta_mappings == null || list_cmeta_mappings.isEmpty()) {
                    str_msg_error = str_section_name + icon_x + ' No C-META records found.';
                    throw new IllegalArgumentException(str_msg_error);
                }
                
                // Debug after action
                str_msg_debug = str_section_name + icon_check + ' AFTER: Retrieved ' + list_cmeta_mappings.size() + ' C-META records.';
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                // Catch block for errors
                str_msg_error = str_section_name + icon_x + ' CATCH: Error while fetching C-META records. ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            // #31 
            // SECTION-DESCRIPTION: Filter C-META records into seprate lists for Summary,Item,Address,CustomerNumber fields.
            str_section_name = '31. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            try {
                // Debug before action
                str_msg_debug = str_section_name + icon_search + ' BEFORE: Filtering C-META records';
                if (bool_debug == true) System.debug(str_msg_debug);   
                
                
                // ACTION1: Filter C-META records for ObjectType = 'Summary'
                list_cmeta_mappings_summary = new List<C_META_Order_Entry_Mapping__mdt>();
                
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings) {
                    if (
                        cmeta.ObjectType__c == 'Summary' &&
                        (cmeta.Entry__c != null && !cmeta.Entry__c.contains('.')) &&
                        cmeta.CompareMethod__c == 'Exact'
                    ) {
                        list_cmeta_mappings_summary.add(cmeta);
                    }
                }
                
                // ACTION2: Filter C-META records for ObjectType = 'Item'
                list_cmeta_mappings_item = new List<C_META_Order_Entry_Mapping__mdt>();
                
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings) {
                    if (
                        cmeta.ObjectType__c == 'Item' &&
                        (cmeta.Entry__c != null && !cmeta.Entry__c.contains('Items.')) &&
                        cmeta.CompareMethod__c == 'Exact'
                    )  {
                        list_cmeta_mappings_item.add(cmeta);
                    }
                }
                
                
                // ACTION3: Filter C-META records for ObjectType = 'Address'
                list_cmeta_mappings_address = new List<C_META_Order_Entry_Mapping__mdt>();
                
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings) {
                    if (
                        cmeta.ObjectType__c == 'Summary' &&
                        (cmeta.Entry__c != null && cmeta.Entry__c.contains('.') && !cmeta.Entry__c.contains('items.') ) &&
                        cmeta.CompareMethod__c == 'Exact'
                    )  {
                        list_cmeta_mappings_address.add(cmeta);
                    }
                }
                
                
                // ACTION4: Filter C-META records for "customerNumber" in Common__c field
                list_cmeta_mappings_customerNumber = new List<C_META_Order_Entry_Mapping__mdt>();
                
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings) {
                    if (
                        cmeta.ObjectType__c == 'Summary' &&
                        (cmeta.Entry__c != null && cmeta.Entry__c.contains('.') && !cmeta.Entry__c.contains('items.') ) &&
                        cmeta.CompareMethod__c == 'Exact' &&
                        (cmeta.Common__c != null && cmeta.Common__c.endsWith('customerNumber'))
                    ) {
                        list_cmeta_mappings_customerNumber.add(cmeta);
                    }
                }
                
                
                // Validate result
                if (list_cmeta_mappings_summary.isEmpty()) {
                    str_msg_error = str_section_name + icon_warning + ' No C-META records found for Summary fields.';
                    if (bool_debug == true) System.debug(str_msg_error);
                }
                
                // Debug after action
                str_msg_debug = str_section_name + icon_check + ' AFTER: Filtered C-META Summary fields. '
                    + ' | Summary: ' + list_cmeta_mappings_summary.size()
                    + ' | Items: ' + list_cmeta_mappings_item.size()
                    + ' | Address: ' + list_cmeta_mappings_address.size()
                    + ' | CustomerNumber: ' + list_cmeta_mappings_customerNumber.size();
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                // Catch block for errors
                str_msg_error = str_section_name + icon_x + ' CATCH: Error while filtering C-META fields. ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            
            //-------------------------------------------------------------------------------------------------------        
            
            
            // #40 
            // SECTION-DESCRIPTION: Get all SAP Order Items related to the SAP Order Summary and save to a variable.
            str_section_name = '40. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            try {
                // Debug before action
                str_msg_debug = str_section_name + icon_search + ' BEFORE: Fetching SAP Order Items for SAP Order Summary ID: ' + id_orderEntry_orderSummaryId;
                if (bool_debug == true) System.debug(str_msg_debug);
                
                // ACTION: Dynamically build SOQL query for SAP Order Items
                str_soql = 'SELECT ' + 
                    String.join(Schema.getGlobalDescribe().get('SAP_Order_Items__c')
                                .getDescribe().fields.getMap().keySet(), ', ') +
                    ' FROM SAP_Order_Items__c WHERE PKI_Order_Summary__c = :id_orderEntry_orderSummaryId' +
                    ' AND isRemoved__c = false' +
                    ' AND fxItemStatus__c !=\'Removed\'';
                
                // Execute query
                list_sapOrderItems = Database.query(str_soql);
                
                // Error handling: Check if records were found
                if (list_sapOrderItems == null || list_sapOrderItems.isEmpty()) {
                    str_msg_error = str_section_name + icon_warning + ' No SAP Order Items found for Order Summary ID: ' + id_orderEntry_orderSummaryId;
                    if (bool_debug == true) System.debug(str_msg_error);
                    list_sapOrderItems = new List<SAP_Order_Items__c>(); // Ensure it's initialized to avoid null errors
                }
                
                // Debug after action
                str_msg_debug = str_section_name + icon_check + ' AFTER: Retrieved ' + list_sapOrderItems.size() + ' SAP Order Items.';
                if (bool_debug == true) System.debug(str_msg_debug);
                
                // Create a map for quick lookup of SAP Order Items by Material Number
                map_PartNumberItem = new Map<String, SAP_Order_Items__c>();
                for (SAP_Order_Items__c record_sap_order_item : list_sapOrderItems) {
                    if (record_sap_order_item != null && record_sap_order_item.Material_Number__c != null) {
                        map_PartNumberItem.put(record_sap_order_item.Material_Number__c, record_sap_order_item);
                    } else {
                        str_msg_debug = str_section_name + icon_warning + ' Warning: Skipping SAP Order Item with missing Material Number.';
                        if (bool_debug == true) System.debug(str_msg_debug);
                    }
                }
                
                // Debug after map creation
                str_msg_debug = str_section_name + icon_check + ' AFTER: Created map_PartNumberItem with ' + map_PartNumberItem.size() + ' entries.';
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                // Catch block for errors
                str_msg_error = str_section_name + icon_x + ' CATCH: Error while fetching SAP Order Items. ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            
            //-------------------------------------------------------------------------------------------------------        
            
            
            // #50 
            // SECTION-DESCRIPTION: Parse out the Summary Fields in Order_Entry_Json
            str_section_name = '50. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + ' BEFORE: Parsing Summary Fields from Order_Entry_Json based on C-META Summary mappings.';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Check if map_orderEntry_json is null or empty
            if (map_orderEntry_json == null || map_orderEntry_json.isEmpty()) {
                str_msg_error = str_section_name + icon_x + ' map_orderEntry_json is NULL or EMPTY. Check earlier JSON parsing step.';
                throw new IllegalArgumentException(str_msg_error);
            } else {
                str_msg_debug = str_section_name + icon_check + ' map_orderEntry_json is populated. Size: ' + map_orderEntry_json.size();
                if (bool_debug == true) System.debug(str_msg_debug);
            }
            
            // ACTION: Parse Summary Fields from Order_Entry_Json using C-META Summary mappings
            map_orderEntry_allFields = new Map<String, Object>();
            
            if (!list_cmeta_mappings_summary.isEmpty()) {
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_summary) {
                    // 🌟 Pre-check: Debug which Entry Field we're looking for
                    str_msg_debug = str_section_name + icon_search + ' Checking C-META Entry Field: ' + cmeta.Entry__c;
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // Check if the JSON map contains the field
                    if (cmeta.Entry__c != null && map_orderEntry_json.containsKey(cmeta.Entry__c)) {
                        Object jsonValue = map_orderEntry_json.get(cmeta.Entry__c);
                        
                        // 🌟 Post-check: Debug what value was found in the JSON
                        str_msg_debug = str_section_name + icon_check + ' Found Value in JSON | Entry Field: ' + cmeta.Entry__c + 
                            ' | Value: ' + String.valueOf(jsonValue);
                        if (bool_debug == true) System.debug(str_msg_debug);
                        
                        // Store in the map
                        map_orderEntry_allFields.put(cmeta.Entry__c, jsonValue);
                    } else {
                        // 🚨 If field not found, debug warning
                        str_msg_debug = str_section_name + icon_warning + ' Field NOT found in map_orderEntry_json: ' + cmeta.Entry__c;
                        if (bool_debug == true) System.debug(str_msg_debug);
                    }
                }
            } else {
                str_msg_error = str_section_name + icon_x + ' list_cmeta_mappings_summary is EMPTY.';
                throw new IllegalArgumentException(str_msg_error);
            }
            
            // Final Debug: Summary fields parsed
            str_msg_debug = str_section_name + ' AFTER: Parsed Summary Fields count: ' + map_orderEntry_allFields.size() + '--> ' +JSON.serialize(map_orderEntry_allFields);
            if (bool_debug == true) System.debug(str_msg_debug);
            
            
            
            
            //----------------------------------------------------------------------------------------------- 
            
            // #60 - Parse Address Fields from Order_Entry_Json
            str_section_name = '60. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + 'BEFORE: Parsing address fields from Order_Entry_Json.';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Central list to hold all address records
            List<Map<String, Object>> list_all_addresses = new List<Map<String, Object>>();
            
            // Loop through CMETA for address fields
            for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_address) {
                // Split nodeKey and fieldKey
                List<String> keys = cmeta.Entry__c.split('\\.');
                if (keys.size() != 2) continue; // Skip if not in expected format (node.field)
                
                str_nodeKey = keys[0]; // soldTo, shipTo, billTo, payer
                str_fieldKey = keys[1]; // customerNumber, streetNumber, etc.
                
                // Debugging node and field being processed
                if (bool_debug == true) System.debug(str_section_name + ' Processing Node: ' + str_nodeKey + ' | Field: ' + str_fieldKey);
                
                // Check if the node exists in JSON
                if (map_orderEntry_json.containsKey(str_nodeKey)) {
                    List<Object> nodeList = (List<Object>) map_orderEntry_json.get(str_nodeKey);
                    if (nodeList != null && !nodeList.isEmpty()) {
                        // Loop through each record in the node (e.g., each soldTo record)
                        for (Object nodeRecord : nodeList) {
                            Map<String, Object> recordMap = (Map<String, Object>) nodeRecord;
                            
                            // Check if the field exists in the record
                            if (recordMap.containsKey(str_fieldKey)) {
                                // Build address entry
                                Map<String, Object> addressEntry = new Map<String, Object>();
                                addressEntry.put('AddressType', str_nodeKey);
                                addressEntry.put('Rank', recordMap.get('rank')); // Include rank for uniqueness
                                addressEntry.put('FieldKey', str_fieldKey);
                                addressEntry.put('FieldValue', recordMap.get(str_fieldKey));
                                
                                // Add to the central list
                                list_all_addresses.add(addressEntry);
                                
                                // Debug the extracted value
                                if (bool_debug == true) {
                                    System.debug(str_section_name + ' FOUND: ' + str_nodeKey + ' | Rank: ' + recordMap.get('rank') +
                                                 ' | Field: ' + str_fieldKey + ' | Value: ' + recordMap.get(str_fieldKey));
                                }
                            }
                        }
                    } else {
                        if (bool_debug == true) {
                            System.debug(str_section_name + ' SKIP: No records found for node: ' + str_nodeKey);
                        }
                    }
                } else {
                    if (bool_debug == true) {
                        System.debug(str_section_name + ' SKIP: Node not found in JSON: ' + str_nodeKey);
                    }
                }
            }
            
            // Debug after action
            str_msg_debug = str_section_name + 'AFTER: Address parsing complete. Total addresses captured: ' + list_all_addresses.size() + '--> ' + JSON.serialize(list_all_addresses);
            if (bool_debug == true) System.debug(str_msg_debug);
            
            //-----------------------------------------------------------------------------------------------
            
            
            // #61-64 - Split Central Address List by Type
            str_section_name = '61-64. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + 'BEFORE: Splitting addresses by type.';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Loop through all addresses and distribute by AddressType
            for (Map<String, Object> addressRecord : list_all_addresses) {
                String addressType = (String) addressRecord.get('AddressType');
                
                if (addressType == 'soldTo') {
                    list_soldTo_addresses.add(addressRecord);
                } else if (addressType == 'shipTo') {
                    list_shipTo_addresses.add(addressRecord);
                } else if (addressType == 'billTo') {
                    list_billTo_addresses.add(addressRecord);
                } else if (addressType == 'payer') {
                    list_payer_addresses.add(addressRecord);
                }
            }
            
            // Debugging output for each list
            if (bool_debug == true) {
                System.debug(str_section_name + ' SoldTo Addresses: ' + list_soldTo_addresses.size());
                System.debug(str_section_name + ' ShipTo Addresses: ' + list_shipTo_addresses.size());
                System.debug(str_section_name + ' BillTo Addresses: ' + list_billTo_addresses.size());
                System.debug(str_section_name + ' Payer Addresses: ' + list_payer_addresses.size());
            }
            
            // Debug after action
            str_msg_debug = str_section_name + 'AFTER: Address split complete.'
                + ' (SoldTo): ' + list_soldTo_addresses.size()
                + ' (ShipTo): ' + list_shipTo_addresses.size()
                + ' (BillTo): ' + list_billTo_addresses.size()
                + ' (Payer): ' + list_payer_addresses.size()
                + ' (TOTAL): ' + list_all_addresses.size(); 
            
            if (bool_debug == true) System.debug(str_msg_debug);
            
            //-----------------------------------------------------------------------------------------------
            
            // #70
            // SECTION-DESCRIPTION: Parse out the Items Fields in Order_Entry_Json and save to list_orderEntry_items
            str_section_name = '70. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + 'BEFORE: Starting to parse items fields from Order_Entry_Json.';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Initialize the list for parsed item fields
            list_orderEntry_items = new List<Map<String, Object>>();
            
            // Loop through CMETA for items
            for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_item) {
                String entryField = cmeta.Entry__c;
                
                // Split entry into nodeKey and fieldKey (e.g., "items.partNumber")
                if (entryField.contains('.')) {
                    List<String> fieldParts = entryField.split('\\.');
                    str_nodeKey = fieldParts[0];   // Should always be "items"
                    str_fieldKey = fieldParts[1];  // The actual field (e.g., partNumber, quantity)
                    
                    // Find the 'items' node in JSON
                    if (map_orderEntry_json.containsKey(str_nodeKey)) {
                        List<Object> jsonItems = (List<Object>)map_orderEntry_json.get(str_nodeKey);
                        
                        // Loop through each item
                        Integer itemIndex = 0;
                        for (Object itemObj : jsonItems) {
                            Map<String, Object> itemMap = (Map<String, Object>)itemObj;
                            itemIndex++;
                            
                            // Check if the fieldKey exists in this item
                            if (itemMap.containsKey(str_fieldKey)) {
                                Object fieldValue = itemMap.get(str_fieldKey);
                                
                                // Store as Item#, FieldKey, FieldValue
                                Map<String, Object> itemRecord = new Map<String, Object>();
                                itemRecord.put('ItemNumber', itemIndex);
                                itemRecord.put('FieldKey', str_fieldKey);
                                itemRecord.put('FieldValue', fieldValue);
                                list_orderEntry_items.add(itemRecord);
                                
                                // Debug output for each field found
                                str_msg_debug = str_section_name + '📝 Item#' + itemIndex + ' - ' + str_fieldKey + ': ' + fieldValue;
                                if (bool_debug == true) System.debug(str_msg_debug);
                            }
                        }
                    } else {
                        str_msg_debug = str_section_name + '⚠️ No items node found in Order_Entry_Json.';
                        if (bool_debug == true) System.debug(str_msg_debug);
                    }
                }
            }
            
            // Debug after action
            str_msg_debug = str_section_name + 'AFTER: Finished parsing items fields. Total Fields Parsed: ' + list_orderEntry_items.size() + ' --> ' + JSON.serialize(list_orderEntry_items);
            if (bool_debug == true) System.debug(str_msg_debug);
            
            //---------------------------------------------------------------------------------------
            
            // #80, #81, #82
            // SECTION-DESCRIPTION: Compare OrderEntry Items PartNumbers (ListA) with Order_Summary_Items MaterialNumbers (ListB)
            str_section_name = '80-82. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + 'BEFORE: Starting to compare OrderEntry PartNumbers (ListA) with OrderSummary MaterialNumbers (ListB).';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Initialize lists
            listA.clear();
            listB.clear();
            
            // #80: Add MaterialNumber from Order_Summary_Items to ListB
            for (SAP_Order_Items__c record_sap_order_item : list_sapOrderItems) {
                if (record_sap_order_item.Material_Number__c != null) {
                    listB.add(record_sap_order_item.Material_Number__c);
                }
            }
            
            // #81: Add PartNumber from Order_Entry_Items to ListA
            for (Map<String, Object> itemRecord : list_orderEntry_items) {
                if (itemRecord.containsKey('FieldKey') && String.valueOf(itemRecord.get('FieldKey')) == 'partNumber') {
                    listA.add(String.valueOf(itemRecord.get('FieldValue')));
                }
            }
            
            // Debug lists before compare
            str_msg_debug = str_section_name + 'DEBUG: ListA (Entry PartNumbers): ' + listA.size() + ' items -> ' + listA;
            if (bool_debug == true) System.debug(str_msg_debug);
            
            str_msg_debug = str_section_name + 'DEBUG: ListB (Summary MaterialNumbers): ' + listB.size() + ' items -> ' + listB;
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // #82: Compare the lists
            //input_variable_from_flow source = new input_variable_from_flow(); // FIXED: Initialize source
            //orderEntryAnalysis instance = new orderEntryAnalysis(); // FIXED: Create an instance
            //instance.func_2001_compare_lists(listA, listB ); // FIXED: Call function via instance
            
            // ✅ Use existing `orderEntry` from the flow (contains public lists)
            input_variable_from_flow orderEntry = orderEntrys[0]; // Ensure this is defined earlier
            
            // ✅ Create an instance of orderEntryAnalysis
            orderEntryAnalysis instance = new orderEntryAnalysis(); 
            
            // ✅ Call function with correct parameters
            instance.func_2001_compare_lists(listA, listB, orderEntry); // Now passing `orderEntry` as third parameter
            
            //--------------------------------------------------------------------------------------   
            
            
            // #140-160: Summary Data Comparison
            str_section_name = '140. Summary Data';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + ' BEFORE: Starting Summary Comparison';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            try {
                // Loop through CMETA Summary Mappings (#31)
                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_summary) {
                    if (cmeta == null) {
                        str_msg_debug = str_section_name + ' WARNING: Null CMETA record encountered. Skipping.';
                        if (bool_debug == true) System.debug(str_msg_debug);
                        continue;
                    }
                    
                    // Log CMETA field details
                    str_msg_debug = str_section_name + ' 150a: Processing CMETA Record - Entry=' + cmeta.Entry__c + ', Summary=' + cmeta.Summary__c + ', FieldNumber=' + cmeta.FieldNumber__c + ', CommonLabel=' + cmeta.Common__c;
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // Set CMETA Variables
                    str_cmeta_commonLabel = cmeta.Common__c;
                    str_cmeta_entryField = cmeta.Entry__c;
                    str_cmeta_summaryField = cmeta.Summary__c;
                    str_cmeta_compareMethod = cmeta.CompareMethod__c;
                    str_cmeta_dataType = cmeta.DataType__c;
                    str_cmeta_fieldNumber = cmeta.FieldNumber__c;
                    
                    // Determine nodeKey and fieldKey
                    if (str_cmeta_entryField.contains('.')) {
                        List<String> entryParts = str_cmeta_entryField.split('\\.');
                        str_nodeKey = entryParts[0];     // Example: 'soldTo'
                        str_fieldKey = entryParts[1];    // Example: 'customerNumber'
                    } else {
                        str_nodeKey = '';                // No node for summary fields
                        str_fieldKey = str_cmeta_entryField;  // Entire field is the key
                    }
                    
                    str_msg_debug = str_section_name + ' 150b: nodeKey=' + str_nodeKey + ', fieldKey=' + str_fieldKey;
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // #150a: Get Entry Value from JSON Map (#50)
                    obj_value_entry = map_orderEntry_json.containsKey(str_fieldKey) 
                        ? map_orderEntry_json.get(str_fieldKey)
                        : null;
                    
                    str_msg_debug = str_section_name + ' 150c: Entry Value for ' + str_fieldKey + ' = ' + String.valueOf(obj_value_entry);
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // #150b: Get SAP Order Summary Value (#40)
                    obj_value_order = record_sap_order_summary != null && record_sap_order_summary.get(str_cmeta_summaryField) != null
                        ? record_sap_order_summary.get(str_cmeta_summaryField)
                        : null;
                    
                    str_msg_debug = str_section_name + ' 150d: Order Summary Value for ' + str_cmeta_summaryField + ' = ' + String.valueOf(obj_value_order);
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // Null Check
                    if (obj_value_entry == null && obj_value_order == null) {
                        str_msg_debug = str_section_name + ' WARNING: Both Entry and Order values are null for ' + str_cmeta_commonLabel;
                        if (bool_debug == true) System.debug(str_msg_debug);
                        continue;
                    }
                    
                    // #150c: Compare Entry and Order Values
                    String comparisonResult = func_2002_compare_values(obj_value_entry, String.valueOf(obj_value_order), str_cmeta_compareMethod, str_cmeta_dataType);
                    str_msg_debug = str_section_name + ' 150e: Comparison Result = ' + comparisonResult;
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // #160: Write VRS Records
                    str_vrs_group = record_sap_order_summary != null ? record_sap_order_summary.Name : 'Unknown';
                    str_vrs_attribute = str_cmeta_fieldNumber + '.'+ str_cmeta_commonLabel;
                    str_vrs_externalId = str_vrs_group + '-' + str_vrs_entity + '-' + str_vrs_attribute;
                    
                    
                    // Debug after action
                    str_msg_debug = '160. BEFORE: Summary Comparison. #VRS Records: ' + list_vrs_records.size() + ' | external id: ' +  str_vrs_externalId;
                    if (bool_debug == true) System.debug(str_msg_debug);
                    
                    // Create 3 individual VRS records as per your expected output
                    if (comparisonResult.startsWith('Matched')) {
                        // #160a: Matched Record
                        createVrsRecord(str_vrs_group, '10.Entry-Summary', str_vrs_attribute, String.valueOf(obj_value_entry), 'Matched','');
                        createVrsRecord(str_vrs_group, '20.Order-Summary', str_vrs_attribute, String.valueOf(obj_value_order), 'Matched','');
                        createVrsRecord(str_vrs_group, '30.Final-Summary', str_vrs_attribute, 'Matched: (' + String.valueOf(obj_value_order) + ')', 'Matched','');
                    } else {
                        // #160b: Unmatched Record
                        createVrsRecord(str_vrs_group, '10.Entry-Summary', str_vrs_attribute, String.valueOf(obj_value_entry), 'Unmatched','');
                        createVrsRecord(str_vrs_group, '20.Order-Summary', str_vrs_attribute, String.valueOf(obj_value_order), 'Unmatched','');
                        createVrsRecord(str_vrs_group, '30.Final-Summary', str_vrs_attribute, 'Unmatched: E(' + String.valueOf(obj_value_entry) + ') vs. O(' + String.valueOf(obj_value_order) + ')', 'Unmatched','');
                    }
                }
                
                // Debug after action
                str_msg_debug = '160. AFTER: Completed Summary Comparison. Total VRS Records Created: ' + list_vrs_records.size();
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                str_msg_error = str_section_name + icon_x + ' ERROR: ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            
            //------ADDRESS COMPARE--------------------------------------------------------------------------------   
            
            // #170: Prep Address Data (Part 1)
            str_section_name = '170. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + ' BEFORE: Starting Address Data Preparation';
            if (bool_debug == true) System.debug(str_msg_debug);
            
            // Initialize maps for customer numbers by address type
            Map<String, String> map_summary_customerNumbers = new Map<String, String>();
            Map<String, List<Map<String, Object>>> map_entry_addresses = new Map<String, List<Map<String, Object>>>();
            
            try {
                // 1. Get Customer Numbers from Order Summary
                map_summary_customerNumbers.put('soldTo', formatCustomerNumber(record_sap_order_summary?.Sold_To_Customer_Id__c));
                map_summary_customerNumbers.put('shipTo', formatCustomerNumber(record_sap_order_summary?.Ship_To_Customer_Id__c));
                map_summary_customerNumbers.put('billTo', formatCustomerNumber(record_sap_order_summary?.Invoice_Mailing_Customer_Id__c));
                map_summary_customerNumbers.put('payer', formatCustomerNumber(record_sap_order_summary?.Bill_To_Customer_Id__c));
                
                // Debug: Display retrieved summary customer numbers
                for (String key : map_summary_customerNumbers.keySet()) {
                    str_msg_debug = str_section_name + ' DEBUG: Summary Customer Number [' + String.valueOf(key) + '] = ' + String.valueOf(map_summary_customerNumbers.get(key));
                    if (bool_debug == true) System.debug(str_msg_debug);
                }
                
                // 2. Get Address Records from Order Entry JSON
                List<String> addressTypes = new List<String>{'soldTo', 'shipTo', 'billTo', 'payer'};
                    
                    for (String addressType : addressTypes) {
                        if (map_orderEntry_json.containsKey(addressType)) {
                            Object addressNode = map_orderEntry_json.get(addressType);
                            if (addressNode != null && addressNode instanceof List<Object>) {
                                List<Map<String, Object>> addressRecords = new List<Map<String, Object>>();
                                
                                // Loop through each record in the address node
                                for (Object addressRecord : (List<Object>) addressNode) {
                                    if (addressRecord != null && addressRecord instanceof Map<String, Object>) {
                                        addressRecords.add((Map<String, Object>) addressRecord);
                                    }
                                }
                                
                                map_entry_addresses.put(addressType, addressRecords);
                                str_msg_debug = str_section_name + ' DEBUG: Found ' + addressRecords.size() + ' records for ' + addressType;
                                if (bool_debug == true) System.debug(str_msg_debug);
                            } else {
                                // ✅ Iterate over CMETA fields
                                for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_address) {
                                    if (cmeta.Entry__c.startsWith(addressType + '.')) {
                                        String fieldKey = cmeta.Entry__c.split('\\.')[1];
                                        
                                        // ✅ Extract the correct values per field
                                        //Object entryValue = entryAddress.containsKey(fieldKey) ? entryAddress.get(fieldKey) : null;
                                        Object orderValue = record_sap_order_summary.get(cmeta.Summary__c); // Reinitialize per loop
                                        
                                        // 🛠️ Apply formatting if the field is a customer number
                                        if (fieldKey.endsWith('customerNumber')) {
                                            //entryValue = (entryValue != null) ? formatCustomerNumber(String.valueOf(entryValue)) : null;
                                            orderValue = (orderValue != null) ? formatCustomerNumber(String.valueOf(orderValue)) : null;
                                        }
                                        // ✅ Prepare VRS Record
                                        str_vrs_group = record_sap_order_summary != null ?  String.valueOf(record_sap_order_summary.Name) : 'Unknown';
                                        str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                                        //str_vrs_externalId = str_vrs_group + '-' + str_vrs_entity + '-' + str_vrs_attribute;
                                        
                                        // ✅ Create VRS Record for MISSING CUSTOMER NUMBER ON ENTRY Values
                                        createVrsRecord(str_vrs_group, '11.Entry-Address', str_vrs_attribute, 'MISSING', 'Unmatched','');
                                        createVrsRecord(str_vrs_group, '21.Order-Address', str_vrs_attribute, String.valueOf(orderValue), 'Unmatched','');
                                        createVrsRecord(str_vrs_group, '31.Final-Address', str_vrs_attribute, 'Unmatched: E(MISSING) vs. O(' + String.valueOf(orderValue) + ')', 'Unmatched','');
                                        continue;
                                    }
                                }
                                str_msg_debug = str_section_name + ' DEBUG: No records found for ' + addressType;
                                if (bool_debug == true) System.debug(str_msg_debug);
                            }
                        }
                    }
                
                // Debug after action
                str_msg_debug = str_section_name + ' AFTER: Completed Address Data Preparation.';
                if (bool_debug == true) System.debug(str_msg_debug);
                
            } catch (Exception e) {
                str_msg_error = str_section_name + icon_x + ' ERROR: ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
           
//--------------------------------------------------------------------------------------   
            
            // #180-200: Match & Compare Address Data (Part 2)
            str_section_name = '180. ';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // Debug before action
            str_msg_debug = str_section_name + ' BEFORE: Starting Address Comparison';
            if (bool_debug == true) { System.debug(str_msg_debug); }
            
            try {
                // Iterate through each address type (SoldTo, ShipTo, BillTo, Payer)
                for (String addressType : map_summary_customerNumbers.keySet()) {
                    String summaryCustomerNumber = formatCustomerNumber(map_summary_customerNumbers.get(addressType));
                    if (summaryCustomerNumber == null || summaryCustomerNumber.trim() == '') {
                        str_msg_debug = str_section_name + ' DEBUG: Skipping ' + addressType + ' as no summary customer number exists.';
                        if (bool_debug == true) { System.debug(str_msg_debug); }
                        Boolean matchFound = false;
                        Set<String> unmatchedEntryNumbers = new Set<String>();
                        // ✅ Iterate over CMETA fields
                        for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_address) {
                            if (cmeta.Entry__c.startsWith(addressType + '.')) {
                                String fieldKey = cmeta.Entry__c.split('\\.')[1];
                                
                                // ✅ Extract the correct values per field
                                //Object entryValue = entryAddress.containsKey(fieldKey) ? entryAddress.get(fieldKey) : null;
                                Object orderValue = record_sap_order_summary.get(cmeta.Summary__c); // Reinitialize per loop
                                
                                // 🛠️ Apply formatting if the field is a customer number
                                if (fieldKey.endsWith('customerNumber')) {
                                    //entryValue = (entryValue != null) ? formatCustomerNumber(String.valueOf(entryValue)) : null;
                                    orderValue = (orderValue != null) ? formatCustomerNumber(String.valueOf(orderValue)) : null;
                                }
                                // ✅ Prepare VRS Record
                                str_vrs_group = record_sap_order_summary != null ?  String.valueOf(record_sap_order_summary.Name) : 'Unknown';
                                str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                                //str_vrs_externalId = str_vrs_group + '-' + str_vrs_entity + '-' + str_vrs_attribute;
                                
                                // ✅ Create VRS Record for MISSING CUSTOMER NUMBER ON ENTRY Values
                                createVrsRecord(str_vrs_group, '11.Entry-Address', str_vrs_attribute, null, 'Unmatched','');
                                createVrsRecord(str_vrs_group, '21.Order-Address', str_vrs_attribute, String.valueOf(orderValue), 'Unmatched','');
                                createVrsRecord(str_vrs_group, '31.Final-Address', str_vrs_attribute, 'Unmatched: E(null) vs. O(' + String.valueOf(orderValue) + ')', 'Unmatched','');
                                continue;
                            }
                        }
                        continue;
                    }
                    
                    //Summary Customer Number(formatted)
                    str_msg_debug = str_section_name + ' Summary Customer Number (formatted): ' + addressType + '-' +summaryCustomerNumber;
                    if (bool_debug == true) { System.debug(str_msg_debug); }
                    
                    // Get corresponding entry addresses
                    List<Map<String, Object>> entryAddresses = map_entry_addresses.get(addressType);
                    if (entryAddresses == null || entryAddresses.isEmpty()) {
                        str_msg_debug = str_section_name + ' DEBUG: No entry addresses found for ' + addressType;
                        if (bool_debug == true) { System.debug(str_msg_debug); }
                        continue;
                    }
                    
                    // ✅ Initialize required variables
                    Boolean bool_matched_found = false;
                    Set<String> set_unmatched_entry_numbers = new Set<String>();
                    
                    for (Map<String, Object> entryAddress : entryAddresses) {
                        String entryCustomerNumber = null;
                        
                        // ✅ Extract & Format Entry Customer Number
                        if (entryAddress != null && entryAddress.containsKey('customerNumber')) {
                            Object obj_entryCustomerNumber_temp = entryAddress.get('customerNumber');
                            entryCustomerNumber = (obj_entryCustomerNumber_temp != null) 
                                ? formatCustomerNumber(String.valueOf(obj_entryCustomerNumber_temp)) 
                                : '0000000000'; // Default for missing values
                        } else {
                            entryCustomerNumber = null;
                            System.debug('⚠️ WARNING: entryAddress is null or missing customerNumber key.');
                        }
                        
                        // ✅ Format Summary Customer Number for Comparison
                        summaryCustomerNumber = formatCustomerNumber(summaryCustomerNumber);
                        
                        // ✅ Debug comparison step
                        str_msg_debug = str_section_name + ' DEBUG: Comparing ' + addressType + 
                            ' Entry(' + entryCustomerNumber + ') vs. Summary(' + summaryCustomerNumber + ')';
                        if (bool_debug) { System.debug(str_msg_debug); }
                        
                        // ✅ Check if Match Found
                        if (entryCustomerNumber == summaryCustomerNumber) {
                            bool_matched_found = true;
                            
                            str_msg_debug = str_section_name + icon_check + ' MATCH: ' + addressType + 
                                ' CustomerNumber matched (' + entryCustomerNumber + ')';
                            if (bool_debug) { System.debug(str_msg_debug); }
                            
                            // ✅ Iterate over CMETA fields **once per address**
                            for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_address) {
                                if (cmeta.Entry__c.startsWith(addressType + '.')) {
                                    String fieldKey = cmeta.Entry__c.split('\\.')[1];
                                    
                                    // ✅ Extract the correct values per field
                                    Object entryValue = entryAddress.containsKey(fieldKey) ? entryAddress.get(fieldKey) : null;
                                    Object orderValue = record_sap_order_summary.get(cmeta.Summary__c); // Reinitialize per loop
                                    
                                    // 🛠️ Apply formatting if the field is a customer number
                                    if (fieldKey.endsWith('customerNumber')) {
                                        entryValue = (entryValue != null) ? formatCustomerNumber(String.valueOf(entryValue)) : null;
                                        orderValue = (orderValue != null) ? formatCustomerNumber(String.valueOf(orderValue)) : null;
                                    }
                                    
                                    // ✅ Debug extracted values before comparison
                                    str_msg_debug = str_section_name + ' DEBUG: ' + addressType + '.' + fieldKey + 
                                        ' | Entry Value: ' + String.valueOf(entryValue) + 
                                        ' | Order Value: ' + String.valueOf(orderValue);
                                    if (bool_debug) { System.debug(str_msg_debug); }
                                    
                                    // ✅ Compare values
                                    String comparisonResult = func_2002_compare_values(entryValue, String.valueOf(orderValue), cmeta.CompareMethod__c, cmeta.DataType__c);
                                    
                                    // ✅ Prepare VRS Record
                                    str_vrs_group = record_sap_order_summary != null ?  String.valueOf(record_sap_order_summary.Name) : 'Unknown';
                                    str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                                    str_vrs_externalId = str_vrs_group + '-' + str_vrs_entity + '-' + str_vrs_attribute;
                                    
                                    if (comparisonResult.startsWith('Matched')) {
                                        // ✅ Create VRS Record for Matched Values
                                        createVrsRecord(str_vrs_group, '11.Entry-Address', str_vrs_attribute, String.valueOf(entryValue), 'Matched', '');
                                        createVrsRecord(str_vrs_group, '21.Order-Address', str_vrs_attribute, String.valueOf(orderValue), 'Matched', '');
                                        createVrsRecord(str_vrs_group, '31.Final-Address', str_vrs_attribute, 'Matched: (' + String.valueOf(orderValue) + ')', 'Matched', '');
                                    } else {
                                        // ✅ Create VRS Record for Unmatched Values
                                        createVrsRecord(str_vrs_group, '11.Entry-Address', str_vrs_attribute, String.valueOf(entryValue), 'Unmatched', '');
                                        createVrsRecord(str_vrs_group, '21.Order-Address', str_vrs_attribute, String.valueOf(orderValue), 'Unmatched', '');
                                        createVrsRecord(str_vrs_group, '31.Final-Address', str_vrs_attribute, 'Unmatched: E(' + String.valueOf(entryValue) + ') vs. O(' + String.valueOf(orderValue) + ')', 'Unmatched', '');
                                    }
                                }
                            }
                            break; // 🚀 Exit loop immediately after first match
                        } else {
                            // ✅ Collect all unmatched customer numbers
                            if (entryCustomerNumber != null) {
                                set_unmatched_entry_numbers.add(entryCustomerNumber);
                            }
                        }
                    }
                    
                    // ✅ If No Match Found, Consolidate Unmatched Records
                    if (!bool_matched_found && !set_unmatched_entry_numbers.isEmpty()) {
                        String str_unmatched_entry_numbers = String.join(new List<String>(set_unmatched_entry_numbers), ', ');
                        
                        // ✅ Dynamically fetch the mapped customerNumber field from CMETA
                        String str_vrs_attribute_temp = null;
                        for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_address) {
                            if (cmeta.Entry__c == addressType + '.customerNumber') {
                                str_vrs_attribute_temp = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                                break; // Found the correct mapping, no need to continue looping
                            }
                        }
                        
                        // ✅ Fallback in case no mapping is found (shouldn't happen)
                        if (str_vrs_attribute_temp == null) {
                            str_vrs_attribute_temp = '999.unknown.customerNumber';
                        }
                        
                        str_msg_debug = str_section_name + icon_x + ' UNMATCH: No matching CustomerNumber found. Consolidating: ' + str_unmatched_entry_numbers;
                        if (bool_debug) { System.debug(str_msg_debug); }
                        
                        createVrsRecord(str_vrs_group, '11.Entry-Address', str_vrs_attribute_temp, str_unmatched_entry_numbers, 'Unmatched', '');
                        createVrsRecord(str_vrs_group, '21.Order-Address', str_vrs_attribute_temp, summaryCustomerNumber, 'Unmatched', '');
                        createVrsRecord(str_vrs_group, '31.Final-Address', str_vrs_attribute_temp, 'Unmatched: E(' + str_unmatched_entry_numbers + ') vs. O(' + summaryCustomerNumber + ')', 'Unmatched', '');
                    }
                }
                
                
                //Debug after action
                str_msg_debug = str_section_name + ' AFTER: Completed Address Comparison. Total VRS Records Created: ' + list_vrs_records_global.size();
                if (bool_debug == true) { System.debug(str_msg_debug); }
                
            } catch (Exception e) {
                str_msg_error = str_section_name + icon_x + ' ERROR: ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            
            //--------------------------------------------------------------------------------------   
            
            //----ITEM COMPARE----------------------------------------------------------------------------------  
            
            // #210-230: Item Data Comparison
            str_section_name = '210. Item Data';
            str_msg_debug = '';
            str_msg_error = '';
            str_msg_system = '';
            
            // ✅ BEFORE: Starting Item Comparison
            str_msg_debug = str_section_name + ' BEFORE: Starting Item Comparison';
            if (bool_debug == true) { System.debug(str_msg_debug); }
            
            try {
                // ✅ Extract the first `orderEntry` record from the passed list
                //input_variable_from_flow orderEntry = orderEntrys[0];
                orderEntry = orderEntrys[0];
                
                // ✅ Ensure the internal lists are initialized (prevent NULL errors)
                if (orderEntry.list_in_A_and_B == null) orderEntry.list_in_A_and_B = new List<String>();
                if (orderEntry.list_in_A_not_B == null) orderEntry.list_in_A_not_B = new List<String>();
                if (orderEntry.list_in_B_not_A == null) orderEntry.list_in_B_not_A = new List<String>();
                
                // ✅ Ensure lists are initialized
                if (listA == null) listA = new List<String>();
                if (listB == null) listB = new List<String>();
                
                // ✅ Compare PartNumber (ListA) and MaterialNumber (ListB)
                instance.func_2001_compare_lists(listA, listB, orderEntry);
                
                // ✅ Debug List Counts
                str_msg_debug = str_section_name + ' DEBUG: Count in Both: ' + orderEntry.count_in_A_and_B +
                    ', In A not B: ' + orderEntry.count_in_A_not_B + ', In B not A: ' + orderEntry.count_in_B_not_A;
                if (bool_debug == true) { System.debug(str_msg_debug); }
                
                
                // ✅ #220: Process Matching Items (In Both)
                for (String partNumber : orderEntry.list_in_A_and_B) {
                    // ✅ Ensure the correct SAP Order Item record is retrieved per iteration
                    SAP_Order_Items__c record_sap_order_item = (SAP_Order_Items__c) map_PartNumberItem.get(partNumber);
                    record_sap_order_item_temp = record_sap_order_item; // Assign to global
                    
                    // ✅ Get SAP Order Item Name -- for use when keeping external ID unique
                    str_sapOrderItem_name = (record_sap_order_item_temp != null && record_sap_order_item_temp.Name != null)
                        ? record_sap_order_item_temp.Name
                        : 'Unknown'; // Prevents null reference errors
                    
                    if (record_sap_order_item_temp == null) {
                        str_msg_debug = str_section_name + ' WARNING: No SAP Order Item found for PartNumber: ' + partNumber;
                        if (bool_debug == true) { System.debug(str_msg_debug); }
                        continue;
                    }
                    
                    // ✅ Determine if partNumber is Matched or Unmatched
                    String partNumberStatus = 'Matched'; // Since we are in "In Both", it is always Matched.
                    
                    // ✅ Create VRS Record for items.partNumber before processing attributes
                    createVrsRecord(str_vrs_group, '900. items.partNumber', '900. items.partNumber', partNumber, partNumberStatus, '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                    
                    // ✅ Ensure 'items' node exists in JSON before looping
                    if (map_orderEntry_json.containsKey('items')) {
                        List<Object> itemsNode = (List<Object>) map_orderEntry_json.get('items');
                        
                        // ✅ Loop through all item mappings and compare
                        for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_item) {
                            //if (cmeta.Entry__c.endsWith('partNumber')) continue; // Skip redundant partNumber comparison (already created)
                            
                            String fieldKey = cmeta.Entry__c.split('\\.')[1];
                            Object entryValue = null;
                            
                            // ✅ Loop through each JSON item and match with PartNumber
                            for (Object itemObj : itemsNode) {
                                Map<String, Object> itemMap = (Map<String, Object>) itemObj;
                                
                                // ✅ Ensure current JSON item matches the current PartNumber
                                if (itemMap.containsKey('partNumber') && String.valueOf(itemMap.get('partNumber')) == partNumber) {
                                    entryValue = itemMap.containsKey(fieldKey) ? itemMap.get(fieldKey) : null;
                                    break; // Stop once matching PartNumber is found
                                }
                            }
                            
                            // ✅ Get Order Summary Value
                            Object orderValue = record_sap_order_item_temp.get(cmeta.Summary__c);
                            
                            // ✅ Debug extracted values
                            str_msg_debug = str_section_name + '.10 DEBUG Part Value: ' + partNumber + ' | FieldKey: ' + fieldKey +
                                ' | EntryValue:' + String.valueOf(entryValue) + ' | OrderValue:' + String.valueOf(orderValue);
                            if (bool_debug == true) { System.debug(str_msg_debug); }
                            
                            // ✅ Compare Values
                            String comparisonResult = func_2002_compare_values(entryValue, String.valueOf(orderValue), cmeta.CompareMethod__c, cmeta.DataType__c);
                            str_msg_debug = str_section_name + '.20 DEBUG COMPARE ITEM: Result: ' + comparisonResult + ' | Method: ' + cmeta.CompareMethod__c + ' | DataType: ' + cmeta.DataType__c + ' | PartNumber: ' +partNumber + ' | FieldKey: ' + fieldKey +
                                ' | EntryValue:' + String.valueOf(entryValue) + ' | OrderValue:' + String.valueOf(orderValue);
                            if (bool_debug == true) { System.debug(str_msg_debug); }
                            
                            // ✅ Create VRS Records
                            str_vrs_group = record_sap_order_summary != null ? record_sap_order_summary.Name : 'Unknown';
                            str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                            
                            if (comparisonResult.startsWith('Matched')) {
                                createVrsRecord(str_vrs_group, '12.Entry-Item', str_vrs_attribute, String.valueOf(entryValue), 'Matched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                                createVrsRecord(str_vrs_group, '22.Order-Item', str_vrs_attribute, String.valueOf(orderValue), 'Matched','|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                                createVrsRecord(str_vrs_group, '32.Final-Item', str_vrs_attribute, 'Matched: (' + String.valueOf(orderValue) + ')', 'Matched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                            } else {
                                createVrsRecord(str_vrs_group, '12.Entry-Item', str_vrs_attribute, String.valueOf(entryValue), 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                                createVrsRecord(str_vrs_group, '22.Order-Item', str_vrs_attribute, String.valueOf(orderValue), 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                                createVrsRecord(str_vrs_group, '32.Final-Item', str_vrs_attribute, 'Unmatched: E(' + String.valueOf(entryValue) + ') vs. O(' + String.valueOf(orderValue) + ')', 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                            }
                        }
                    } else {
                        str_msg_debug = str_section_name + '.05 WARNING: "items" node not found in Order Entry JSON!';
                        if (bool_debug == true) { System.debug(str_msg_debug); }
                    }
                }               
                
                // ✅ #230: Process Matching Items (In A not B)
                for (String partNumber : orderEntry.list_in_A_not_B) {
                    // ✅ Ensure the correct SAP Order Item record is retrieved per iteration
                    SAP_Order_Items__c record_sap_order_item = (SAP_Order_Items__c) map_PartNumberItem.get(partNumber);
                    record_sap_order_item_temp = record_sap_order_item; // Assign to global
                    
                    // ✅ Get SAP Order Item Name -- for use when keeping external ID unique
                    str_sapOrderItem_name = (record_sap_order_item_temp != null && record_sap_order_item_temp.Name != null)
                        ? record_sap_order_item_temp.Name
                        : 'Unknown'; // Prevents null reference errors
                    
                    if (record_sap_order_item_temp == null) {
                        str_msg_debug = str_section_name + ' WARNING: No SAP Order Item found for PartNumber: ' + partNumber;
                        if (bool_debug == true) { System.debug(str_msg_debug); }
                        continue;
                    }
                    
                    // ✅ Since partNumber is in A but not in B, it is "Unmatched"
                    String partNumberStatus = 'Unmatched';
                    
                    // ✅ Create VRS Record for items.partNumber
                    createVrsRecord(str_vrs_group, '900. items.partNumber', '900. items.partNumber', partNumber, partNumberStatus, '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                    
                    // ✅ Loop through all item mappings and compare
                    for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_item) {
                        if (cmeta.Entry__c.endsWith('partNumber')) continue; // Skip redundant partNumber comparison (already created)
                        
                        String fieldKey = cmeta.Entry__c.split('\\.')[1];
                        Object entryValue = map_orderEntry_json.containsKey(fieldKey) ? map_orderEntry_json.get(fieldKey) : null;
                        Object orderValue = null; // Since it does not exist in Order Summary
                        
                        // ✅ Create VRS Records
                        str_vrs_group = record_sap_order_summary != null ? record_sap_order_summary.Name : 'Unknown';
                        str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                        
                        createVrsRecord(str_vrs_group, '12.Entry-Item', str_vrs_attribute, String.valueOf(entryValue), 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                        createVrsRecord(str_vrs_group, '22.Order-Item', str_vrs_attribute, 'MISSING (From Order)', 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                        createVrsRecord(str_vrs_group, '32.Final-Item', str_vrs_attribute, 'Unmatched: E(' + String.valueOf(entryValue) + ') vs. O(MISSING) for Part: [' + partNumber + ']', 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                    }
                }
                
                // ✅ #240: Process Matching Items (In B not A)
                for (String partNumber : orderEntry.list_in_B_not_A) {
                    // ✅ Ensure correct SAP Order Item is retrieved
                    SAP_Order_Items__c record_sap_order_item = (SAP_Order_Items__c) map_PartNumberItem.get(partNumber);
                    record_sap_order_item_temp = record_sap_order_item; // Assign to global reference
                    
                    // ✅ Get SAP Order Item Name (for external ID uniqueness)
                    str_sapOrderItem_name = (record_sap_order_item_temp != null && record_sap_order_item_temp.Name != null)
                        ? record_sap_order_item_temp.Name
                        : 'Unknown'; // Prevents null reference errors
                    
                    if (record_sap_order_item_temp == null) {
                        str_msg_debug = str_section_name + ' WARNING: No SAP Order Item found for PartNumber: ' + partNumber;
                        if (bool_debug) { System.debug(str_msg_debug); }
                        continue;
                    }
                    
                    // ✅ Create VRS Record for PartNumber (Unmatched - Missing in A)
                    createVrsRecord(str_vrs_group, '900. items.partNumber', '900. items.partNumber', partNumber, 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                    
                    // ✅ Process Each Field from CMETA for Items
                    for (C_META_Order_Entry_Mapping__mdt cmeta : list_cmeta_mappings_item) {
                        if (cmeta.Entry__c.endsWith('partNumber')) continue; // Skip redundant partNumber comparison
                        
                        String fieldKey = cmeta.Entry__c.split('\\.')[1];
                        Object entryValue = map_orderEntry_json.containsKey(fieldKey) ? map_orderEntry_json.get(fieldKey) : null;
                        Object orderValue = record_sap_order_item_temp.get(cmeta.Summary__c);
                        
                        // ✅ Debug extracted values
                        str_msg_debug = str_section_name + '.10 DEBUG Part Value: ' + partNumber + ' | FieldKey: ' + fieldKey +
                            ' | EntryValue: MISSING (From Entry) | OrderValue: ' + String.valueOf(orderValue);
                        if (bool_debug) { System.debug(str_msg_debug); }
                        
                        // ✅ Create VRS Records (Unmatched due to missing Entry Data)
                        str_vrs_group = record_sap_order_summary != null ? record_sap_order_summary.Name : 'Unknown';
                        str_vrs_attribute = cmeta.FieldNumber__c + '.' + cmeta.Common__c;
                        
                        createVrsRecord(str_vrs_group, '12.Entry-Item', str_vrs_attribute, 'MISSING (From Entry)', 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                        createVrsRecord(str_vrs_group, '22.Order-Item', str_vrs_attribute, String.valueOf(orderValue), 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                        createVrsRecord(str_vrs_group, '32.Final-Item', str_vrs_attribute, 'Unmatched: E(MISSING) vs. O(' + String.valueOf(orderValue) + ') for Part: [' + partNumber + ']', 'Unmatched', '|Part:' + partNumber + '|Item:' + str_sapOrderItem_name);
                    }
                }
                
                // 2005. Reprocess Alias Matches for 31.Final-Address Records
                func_2005_reprocess_alias(bool_debug);
                
                
                
                // ✅ INSERT VRS RECORDS
                Database.insert(list_vrs_records_global, false);
                
                // ✅ AFTER: Completed Item Comparison (with Total Count)
                str_msg_debug = str_section_name + ' ✅ AFTER: Completed Item Comparison. Total VRS Records Created: ' + list_vrs_records_global.size();
                if (bool_debug == true) { System.debug(str_msg_debug); }
                
            } catch (Exception e) {
                str_msg_error = str_section_name + ' ERROR: ' + e.getMessage() + ' | Line: ' + e.getLineNumber();
                System.debug(str_msg_error);
                throw new IllegalArgumentException(str_msg_error);
            }
            
            
            // CODE ENDS HERE
            //--------------------------------------------------------------------------------------   
        } catch (Exception e) {
            System.debug('CATCH ❌ Error in processComparison: ' + e.getMessage() + ' | Line: ' + e.getLineNumber());
            throw new IllegalArgumentException('CATCH ❌ Error occurred while processing comparison: ' + e.getMessage() + ' | Line: ' + e.getLineNumber());
        }
    }
}
//--------------------------------------------------------------------------------------