trigger trg_OpportunityLineItem on OpportunityLineItem (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
       // OpportunityLineItemTriggerHandler.updateProdLinesOnOpp(Trigger.New);
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
       // OpportunityLineItemTriggerHandler.updateProdLinesOnOpp(Trigger.Old);
    }    
}