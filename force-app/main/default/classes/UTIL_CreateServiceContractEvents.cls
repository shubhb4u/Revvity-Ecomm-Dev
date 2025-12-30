/*************************************************************************
  * 1. Jira Ticket(s) that relates to this class
  *
  * 2. Description - Utility class for creating Service Contract Events
  * 3. Objects referenced
  *    - None
  *
  * 4. Callouts to additional Components (including their methods) or None:
  *    - None
  * 5. Dependant Class(es):
  * 6. Invocable: True
  *
  * 7. Test Class Name: UTIL_CreateServiceContractEvents_Test
  *
  * 8. Author Name(s): 
  *    - Aakash 12-03-2025
  *
*************************************************************************/
public class UTIL_CreateServiceContractEvents {
    @InvocableMethod
    public static void flowcalled(List<FlowInputs> requests){
        list<FlowOutputs> fOutlist = new list<FlowOutputs>();
        if(requests != null && !requests.isEmpty()){
            for(FlowInputs finpt: requests){
                if (!FS_Utility.isActive('Create ServiceContract Events', 'Create Service Contract Events to send to SAP when a Service Contract Txn is Completed.')) {
                    return;
                }
                
                Map<Id, FS_ServiceContract_Event__e> eventMap = new Map<Id, FS_ServiceContract_Event__e>();
                if(finpt.varSingleContract.Id != NULL) {
                    FS_ServiceContract_Event__e varSingleContractEvent = new FS_ServiceContract_Event__e();
                    varSingleContractEvent.ServiceContractId__c = finpt.varSingleContract.Id;
                    varSingleContractEvent.Action__c = 'STATUS';
                    varSingleContractEvent.SAP_ServiceContractNumber__c = finpt.varSingleContract.External_ID__c;
                    varSingleContractEvent.CreditOkay__c = finpt.varSingleContract.Active__c;
                    eventMap.put(finpt.varSingleContract.Id, varSingleContractEvent);
                }
                
                AggregateResult[] itemCounts = [SELECT ParentServiceContractId, IsDeleted__c, COUNT(Id) numItems
                                                FROM ServiceContract
                                                WHERE ParentServiceContractId = :finpt.varSingleContract.Id
                                                GROUP BY ParentServiceContractId, IsDeleted__c];
                for (AggregateResult result : itemCounts)
                {
                    Id contractId = (Id) result.get('ParentServiceContractId');
                    FS_ServiceContract_Event__e varSingleContractEvent = eventMap.get(contractId);
                    if (varSingleContractEvent != null)
                    {
                        Integer count = (Integer) result.get('numItems');
                        Boolean isDeleted = (Boolean) result.get('IsDeleted__c');
                        if (isDeleted) {
                            varSingleContractEvent.Count_InactiveItems__c = count;
                        } else {
                            varSingleContractEvent.Count_ActiveItems__c = count;
                        }
                    }
                }
                
                AggregateResult[] cpCounts = [SELECT Parent_Contract__c, IsDeleted__c, COUNT(Id) numCPs
                                              FROM ContractLineItem
                                              WHERE Parent_Contract__c = :finpt.varSingleContract.Id
                                              AND AssetId != NULL
                                              GROUP BY Parent_Contract__c, IsDeleted__c];
                for (AggregateResult result : cpCounts)
                {
                    Id contractId = (Id) result.get('Parent_Contract__c');
                    FS_ServiceContract_Event__e varSingleContractEvent = eventMap.get(contractId);
                    if (varSingleContractEvent != null)
                    {
                        Integer count = (Integer) result.get('numCPs');
                        Boolean isDeleted = (Boolean) result.get('IsDeleted__c');
                        if (isDeleted) {
                            varSingleContractEvent.Count_InactiveCPs__c = count;
                        } else {
                            varSingleContractEvent.Count_ActiveCPs__c = count;
                        }
                    }
                }
                
                AggregateResult[] edCounts = [SELECT ContractItem__r.ParentServiceContractId contractId, fxIs_Open__c,
                                              IsDeleted__c, COUNT(Id) numDates
                                              FROM FS_EntitlementDate__c
                                              WHERE ContractItem__r.ParentServiceContractId = :finpt.varSingleContract.Id
                                              AND PlannedDate__c != NULL
                                              GROUP BY ContractItem__r.ParentServiceContractId, fxIs_Open__c, IsDeleted__c];
                for (AggregateResult result : edCounts)
                {
                    Id contractId = (Id) result.get('contractId');
                    FS_ServiceContract_Event__e varSingleContractEvent = eventMap.get(contractId);
                    if (varSingleContractEvent != null)
                    {
                        Integer count = (Integer) result.get('numDates');
                        Boolean isOpen = (Boolean) result.get('fxIs_Open__c');
                        Boolean isDeleted = (Boolean) result.get('IsDeleted__c');
                        if (isOpen) {
                            if (isDeleted) {
                                varSingleContractEvent.Count_InactiveOpenEntDates__c = count;
                            } else {
                                varSingleContractEvent.Count_ActiveOpenEntDates__c = count;
                            }
                        }
                        else if (isDeleted) {
                            varSingleContractEvent.Count_InactiveUsedEntDates__c = count;
                        } else {
                            varSingleContractEvent.Count_ActiveUsedEntDates__c = count;
                        }
                    }
                }
                
                System.debug('SVC CONTRACT EVENTS = ' + eventMap.values());
                
                if (eventMap.values() != NULL)
                {
                    List<FS_PlatformEventLog__c> logs = new List<FS_PlatformEventLog__c>();
                    Database.SaveResult[] results = EventBus.publish(eventMap.values());
                    for (Integer i = 0; i < results.size(); i++)
                    {
                        Database.SaveResult result = results[i];
                        if (!result.isSuccess() || Test.isRunningTest())
                        {
                            SObject iEvent = eventMap.values()[i];
                            FS_PlatformEventLog__c log = new FS_PlatformEventLog__c();
                            log.Error_Message__c = 'Error publishing Event: ' + result.getErrors();
                            if (log.Error_Message__c.length() > 255) {
                                log.Error_Message__c = log.Error_Message__c.substring(0, 250) + '...';
                            }
                            log.Event_JSON__c = JSON.serialize(iEvent);
                            log.Platform_Event_Type__c = iEvent.getSObjectType().getDescribe().getName();
                            log.Related_Element_Id__c = (String)iEvent.get('ServiceContractId__c');
                            log.Action__c = (String) iEvent.get('Action__c');
                            logs.add(log);
                        }
                    }
                    if (!logs.isEmpty()) {
                        insert logs;
                    }
                }
            }
            
        }
        //return fOutlist;
    }
    Public class FlowInputs {         
        @InvocableVariable(required=true) public ServiceContract varSingleContract;
    }
    Public class FlowOutputs {         
        //@InvocableVariable public List<AggregateResult> varAggregateResult;         
    }
}