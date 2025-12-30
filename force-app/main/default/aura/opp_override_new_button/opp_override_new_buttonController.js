({
	changeUsrEntity : function(component, event, helper) {
		
       var action = component.get("c.checkInfOppUsrPermisson");
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === "SUCCESS")
            {
                console.log(JSON.stringify(response.getReturnValue()));
                
                if(response.getReturnValue())
                {
                    helper.openCreateRcrdCmp(component, event, helper);
                }
                else
                {
                  component.set('v.legacyCreatePermission',true);  
                }
            }
        });
        $A.enqueueAction(action);
	}
})