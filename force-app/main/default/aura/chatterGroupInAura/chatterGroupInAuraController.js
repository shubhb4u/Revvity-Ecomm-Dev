({
    doInit : function(component, event, helper) {
        helper.getTrendingGrps(component, event, helper);
    },
    
    // navigating to trending groups detail page
    navigateToTrendingGrpDtl : function(component, event, helper){
      var tgrprecordId = event.target.dataset.tgrpid;

      var sObectEvent1 = $A.get("e.force:navigateToSObject");
      sObectEvent1 .setParams({
          	"recordId": tgrprecordId,
			      "slideDevName": "detail"
        });
        sObectEvent1.fire();
    },
    
    
})