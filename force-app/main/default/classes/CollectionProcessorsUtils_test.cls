/**************************************************************
  * 1. Jira Ticket(s) that relates to this class(CollectionProcessorsUtils)
  *   SSE-SSE-112
  *
  * 2. Description -Test class for CollectionProcessorsUtils
  *
  * 3. Test Class Name: CollectionProcessorsUtils_test
  *
  * 4. Author Name(s): 
  *    - Karthik Kumar Dabbiru 2025.02.04
  *    - First Last & Updated Date(YYYY.MM.DD)
 
*************************************************************/
@istest
public class CollectionProcessorsUtils_test {
    private static final String SOQL_DATE_TIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String DEFAULT_DATE_TIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
static testmethod void myTestMethod1(){
    List<Account> accountsList= new list<Account>();
    String data = '2019-01-03T00:26:01.711-02:00';
		Datetime dt = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
    string fieldType = 'date';
       //String fieldValue = dt.format('yyyy/MM/dd HH:mm:ss');
        String fieldValue ='';
	string sourceString='@';
    account acc = new account();
    acc.name='test@name';
    accountsList.add(acc);
    insert accountsList;
    sObject accsObj = accountsList[0];
        list<string> accFields = new list<string>();
        accFields.add('id');
    	accFields.add('name');
    	CollectionProcessorsUtils.replaceConstants(sourceString);
    	CollectionProcessorsUtils.getFieldTypes(accsObj,accFields);
    	CollectionProcessorsUtils.getFormattedValue(fieldValue, fieldType);
    	
       // DedupeRecordCollection.getUniqueSObjectCollection()
    }

}