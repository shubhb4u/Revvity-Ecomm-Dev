({
    openCreateRcrdCmp : function(component, event, helper) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity"
        });
        createRecordEvent.fire();
    }
})