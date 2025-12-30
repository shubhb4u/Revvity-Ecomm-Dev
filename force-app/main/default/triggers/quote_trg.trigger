trigger quote_trg on SBQQ__Quote__c (before update, before delete, after update) {
    if(trigger.isBefore && trigger.isUpdate){
        //Quote_Trigger_Handler.rollingUpDiscounts(Trigger.new, Trigger.oldMap);
        Quote_Trigger_Handler.updateOpportunityStatus(trigger.new);
        
        //Quote_Trigger_Handler.autoPopulateRequiredBy(Trigger.new);
        Quote_Trigger_Handler.isExecuted = true;
    }
}