({
    doInit : function(component, event, helper) {
	var action = component.get("c.fetchUserInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var sfdcBaseURL= window.location.href;//Fetched current page url.
                console.log('sfdcBaseURL '+sfdcBaseURL);
                var storeResponse = response.getReturnValue();
                console.log('storeResponse=='+JSON.stringify(storeResponse));
                component.set("v.userInfo", storeResponse.usr);
                component.set("v.options",storeResponse.recordtypelist);
                if(storeResponse.usr.Country__c != 'China'){
                if(sfdcBaseURL.includes('--')) {
                       window.open('https://uat.mdm4tst.com/ebx?branch=CustomerMasterDataSpace&instance=CustomerMasterDataSet&service=LaunchSingleCustomerWorkflow');
                    }
                    else {
                      window.open('https://mdm4tst.com/ebx?branch=CustomerMasterDataSpace&instance=CustomerMasterDataSet&service=LaunchSingleCustomerWorkflow');               
                    }
                   window.history.back();
                 }
                else{
                    //alert('inside else');
                    if(sfdcBaseURL.includes('--')) {
                     window.open('https://uat.mdm4tst.com/ebx?branch=CustomerMasterDataSpace&instance=CustomerMasterDataSet&service=LaunchSingleCustomerChinaWorkflow');
                       
                    }
                    else {
                       window.open('https://mdm4tst.com/ebx?branch=CustomerMasterDataSpace&instance=CustomerMasterDataSet&service=LaunchSingleCustomerChinaWorkflow');
                  }
                    window.history.back();
                }
            }
            else if (state === "INCOMPLETE") {
            
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    newButton : function(component, event, helper) {
      helper.newButtonhelper(component, event, helper);
    },
    closeModal: function(component, event, helper) {
      component.set("v.isOpen", false);
        window.history.back();
    
   },
 
   openModal: function(component, event, helper) {
      component.set("v.isOpen", true);
   },
   
	
})