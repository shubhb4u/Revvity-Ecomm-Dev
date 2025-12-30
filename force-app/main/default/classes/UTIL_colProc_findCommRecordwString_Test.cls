/**************************************************************
  * 1. Ticket(s) that relates to this class
  *    - OM-180
  *    - OM-215
  *    - SSE-112	
  *
  * 2. Description - Test class for UTIL_colProc_findCommRecordwString
  *
  * 3. Objects referenced
  *    - None
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None
  *
  * 5. Dependant Class(es):
  *    - None
  *
  * 6. Test Class Name: UTIL_colProc_findCommRecordwString_Test
  *
  * 7. Is @Invocable (Yes or No):  No
  *
  * 8. Author Name(s): 
  *    - Aakash Pal 2023.10.26
  *    - Karthik Kumar Dabbiru 2025.02.04	
  *
*************************************************************/

@isTest
public class UTIL_colProc_findCommRecordwString_Test { 
	@isTest
    static void compareRecordsWithStringsTest(){
       List<Contact> conlist = new list<contact>();
     contact con = new contact();
     con.lastname='test@ name';
     conlist.add(con);
        contact con1 = new contact();
     con1.lastname='test_name';
     conlist.add(con1);
     insert conlist;
        List<Contact> conlistdup = new list<contact>();
     contact con12 = new contact();
     con12.lastname='test name';
     conlistdup.add(con12);
        contact con11 = new contact();
     con11.lastname='test name';
     conlistdup.add(con11);
     insert conlistdup;
        List<String> jobTitles = new List<String>{'test','test'};
        List<String> jobTitles1 = new List<String>{'name','name', 'name'};
        List<String> jobTitles2 = new List<String>{};
        UTIL_colProc_findCommRecordwString.compareRecordsWithStrings(conlist, jobTitles, 'lastname');
        UTIL_colProc_findCommRecordwString.compareRecordsWithStrings(conlist, jobTitles1, 'lastname');
        UTIL_colProc_findCommRecordwString.compareRecordsWithStrings(conlist, jobTitles2, 'lastname');
        UTIL_colProc_findCommonRecords.compareRecords(conlist, conlistdup, 'lastname');
        UTIL_colProc_findCommonRecords.compareRecords(conlist, null, 'lastname');
        UTIL_colProc_findCommonRecords.compareRecords(conlist, conlistdup, 'lastname');
    }
}