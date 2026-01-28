({
	changeUserEntity : function(component, event, helper) {
		
       var action = component.get("c.checkInfInteractionUserPermisson");
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === "SUCCESS")
            {
                
                
                if(response.getReturnValue())
                {
                    helper.openCreateRcrdCmp(component, event, helper);
                }
                else
                {
                   helper.redirectToUrl(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
	}
})