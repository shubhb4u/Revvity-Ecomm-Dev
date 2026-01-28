/**************************************************************
  * 1. Jira Ticket(s) that relates to this class(DedupeRecordCollection)
  *   SSE-112
  *
  * 2. Description -Test class for DedupeRecordCollection
  *
  * 3. Test Class Name: DedupeRecordCollection_Test
  *
  * 4. Author Name(s): 
  *    - Karthik Kumar Dabbiru 2025.02.04
  *    - First Last & Updated Date(YYYY.MM.DD)
 
*************************************************************/
@istest
public class DedupeRecordCollection_Test {

    static testmethod void myTestMethod1(){
     List<Contact> conlist = new list<contact>();
     contact con = new contact();
     con.lastname='test name';
     conlist.add(con);
        contact con1 = new contact();
     con1.lastname='test name';
     conlist.add(con1);
     insert conlist;
         DedupeRecordCollection.FlowRequest varInputClass= new DedupeRecordCollection.FlowRequest();
        varInputClass.inputRecordCollection=conlist;
           varInputClass.fieldToDedupeOn = conlist[0].lastname;
        DedupeRecordCollection.dedupe(new list<DedupeRecordCollection.FlowRequest>{varInputClass});
       // DedupeRecordCollection.getUniqueSObjectCollection()
    }
}