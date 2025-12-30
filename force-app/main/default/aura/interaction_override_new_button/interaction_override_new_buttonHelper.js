({
    openCreateRcrdCmp : function(component, event, helper) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Interaction__c"
        });
        createRecordEvent.fire();
        
    },
    
    redirectToUrl : function(component, event, helper) {
        var sfdcBaseURL= window.location.href;//Fetched current page url.
        var targetUrl;
        // Check if it's a sandbox / scratch org (they usually have "--" in the URL)
        if (sfdcBaseURL.includes('--')) {
            // Sandbox 
            targetUrl = "http://archive-revvity-com-1327051840.p04.elqsandbox.com/LP=13732";
        } else {
            // Production environment
            targetUrl = "https://info.revvity.com/LP=13732";
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": targetUrl });
        //urlEvent.setParams({ "url": "http://archive-revvity-com-1327051840.p04.elqsandbox.com/LP=13732" });
        urlEvent.fire();
    }
   
    
  
     
    
})