/**************************************************************
  * 1. Jira Ticket(s) that relates to this class(QueryWithLimit)
  *   SSE-112
  *
  * 2. Description -Test class for QueryWithLimit
  *
  * 3. Test Class Name: QueryWithLimit_test
  *
  * 4. Author Name(s): 
  *    - Karthik Kumar Dabbiru 2025.02.04
  *    - First Last & Updated Date(YYYY.MM.DD)
 
*************************************************************/
@istest
public class QueryWithLimit_test {
static testmethod void myTestMethod1(){
     List<Contact> conlist = new list<contact>();
     contact con = new contact();
     con.lastname='test name';
     conlist.add(con);
        contact con1 = new contact();
     con1.lastname='test name';
     conlist.add(con1);
     insert conlist;
         QueryWithLimit.QueryParameters varInputClass= new QueryWithLimit.QueryParameters();
        varInputClass.objectApiName='contact';
    	varInputClass.fieldsToQuery ='lastname';
    	varInputClass.numberOfRecords=1;
         //  varInputClass.fieldToDedupeOn = conlist[0].lastname;
        QueryWithLimit.getNrecords(new list<QueryWithLimit.QueryParameters>{varInputClass});
    	QueryWithLimit.QueryResults varInputquery = new QueryWithLimit.QueryResults();
    	varInputquery.records=conlist;
       // DedupeRecordCollection.getUniqueSObjectCollection()
    }
}