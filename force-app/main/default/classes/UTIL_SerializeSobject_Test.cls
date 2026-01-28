@isTest
public class UTIL_SerializeSobject_Test {
	@isTest static void SerializeSobject() {
        UTIL_SerializeSobject.FlowInputs varInputClass= new UTIL_SerializeSobject.FlowInputs();
        contact con=New contact();
        con.lastName='test Name';
        con.FirstName='first Name';
        varInputClass.NewSobject=con;
     UTIL_SerializeSobject.flowcalled(new list<UTIL_SerializeSobject.FlowInputs>{varInputClass});
   }
}