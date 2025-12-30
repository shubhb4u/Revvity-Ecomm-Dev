({  modelopenonload  : function (component, event, helper) {
     component.set("v.isOpen", true);
    },
	newButtonhelper  : function (component, event, helper) {
      
      var RecTypeID = component.get("v.selectedValue");
      //  console.log('RecTypeID=='+RecTypeID);
       var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
               "entityApiName": 'Account',
               "recordTypeId": RecTypeID
            });
            createRecordEvent.fire();
         
        
}
    
})