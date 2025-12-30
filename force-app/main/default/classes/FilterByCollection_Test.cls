/**************************************************************
  * 1. Jira Ticket(s) that relates to this class(FilterByCollection)
  *   SSE-112
  *
  * 2. Description -Test class for FilterByCollection
  *
  * 3. Test Class Name: FilterByCollection_Test
  *
  * 4. Author Name(s): 
  *    - Karthik Kumar Dabbiru 2025.02.04
  *    - First Last & Updated Date(YYYY.MM.DD)
 
*************************************************************/
@istest
public class FilterByCollection_Test {

static testmethod void myTestMethod1(){
    list<sObject> sObjLst = new list<sObject>();
     List<Contact> conlist = new list<contact>();
     contact con = new contact();
     con.lastname='test name';
     conlist.add(con);
        contact con1 = new contact();
     con1.lastname='test name';
     conlist.add(con1);
     insert conlist;
    List<Contact> errConlist = new list<contact>();
     contact con111 = new contact();
     con111.lastname='test name';
     errConlist.add(con111);
        contact con11 = new contact();
     con11.lastname='test name';
     errConlist.add(con11);
     insert errConlist;
    campaign cmpgn = new campaign();
        cmpgn.name = 'test';
    insert cmpgn;
    sObjLst.addAll(conlist);
    sObjLst.add(cmpgn);
         FilterByCollection.Requests varInputClass= new FilterByCollection.Requests();
        varInputClass.objectName='contact';
    	varInputClass.returnFields ='lastname';
        varInputClass.bindField = '';
    	varInputClass.containingCollection=sObjLst;
         //  varInputClass.fieldToDedupeOn = conlist[0].lastname;
        FilterByCollection.filter(new list<FilterByCollection.Requests>{varInputClass});
    	FilterByCollection.Results varInputquery = new FilterByCollection.Results();
    	varInputquery.errors='exception';
    	varInputquery.foundRecords = errConlist;
       // DedupeRecordCollection.getUniqueSObjectCollection()
    }

}