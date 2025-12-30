/**
 *  Apex Class for Work Order One-Click Complete / Submit Logic
 *  Code Coverage for this class can be found in: FS_WorkOrder_UT
 *
 *  2018-05-09       Frank VanLoon             Initial copy of One-Click Complete
 * 2021-11-03  ITSVMX-351 Allow CRC Profile user to cancel the estimate with consumption lines give error message to all other profiles
 * Created meta data type Service Max profile to maintain profile which require skipping validation
 * 2021-11-09 Tony ITSVMX-606 Scheduled Duration Redesign - we want to remove any calendar events even if the Technician is not set
 * CONVERTED to SFS by frankvanloon on 4/23/24.
 * 2025-02-12 As part of SUN-247, allowing reopen fault lines to submit for SAP
 */
public with sharing class FS_WorkOrderDebriefManager {

	public static String WORK_COMPLETE = 'Work Complete';
	public static String WORK_COMPLETE_PENDING = 'Work Complete - Pending';
	public static String WORK_COMPLETE_ERROR = 'Work Complete - Error';
	public static String WORK_COMPLETE_MATERIAL_FOLLOW_UP = 'Work Complete - Material Follow Up';
	public static String CANCELED = 'Canceled';
	public static Set<String> NON_PRICED_WO_TYPES = new Set<String> { 'Installation', 'Internal' };

	public static Boolean IS_PROCESSING_DEBRIEF_RESPONSE = false;
	public static void submitCompleteAll(List<WorkOrder> woNewList, Map<Id, WorkOrder> woOldMap)
	{
		if (!FS_Utility.isActive('Work Order Submit Complete All', 'Update the child WOLI Status to "Submitted" on "One-Click Complete" OR "Submit All Lines"')) {
			return;
		}

		if (IS_PROCESSING_DEBRIEF_RESPONSE) {
			return;
		}
		Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
		Set<Id> submitIds = new Set<Id>();
		Set<Id> completeIds = new Set<Id>();
		for (WorkOrder workOrder : woNewList)
		{
			WorkOrder old = (woOldMap == null) ? null : woOldMap.get(workOrder.Id);
			if ( old != null && old.SubmitAllLines__c != workOrder.SubmitAllLines__c && workOrder.SubmitAllLines__c == true)
			{
				woMap.put(workOrder.Id, workOrder);
				workOrder.SubmitAllLines__c=false;
				submitIds.add(workOrder.Id);
			}
			if ( old != null && old.Status != workOrder.Status && workOrder.Status == WORK_COMPLETE)
			{
				woMap.put(workOrder.Id, workOrder);
				completeIds.add(workOrder.Id);
			}
		}

		if (woMap.isEmpty()) {
			return;
		}

		String txnId = String.valueOf(Datetime.now().formatGmt('yyyy-MM-dd HH:mm:ss.SSS'));
		System.debug('SUBMIT-COMPLETE ALL Starting: ' + txnId);
		List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>([SELECT Id, LineItemNumber,
				Status, Line_Type__c, WorkOrderId, SubmitTxnId__c,
				Part__c, Discount_Type__c, ContractPercentDiscount__c, IntegrationStatus__c,
				Consumed_From_Location__r.fxNon_Consumable_Location__c
			FROM WorkOrderLineItem WHERE WorkOrderId IN :woMap.keySet() AND Status!='Canceled'
				AND Line_Type__c != 'Calibrated Tool']);
		System.debug('woliList: ' + woliList);
		Map<Id, DebriefDetails> debriefMap = new Map<Id, DebriefDetails>();
		for (WorkOrderLineItem woli : woliList) {
			if(!debriefMap.containsKey(woli.WorkOrderId)) {
				debriefMap.put(woli.WorkOrderId, new DebriefDetails());
			}
			DebriefDetails details = debriefMap.get(woli.WorkOrderId);
			details.allLines.add(woli);
			if (woli.Line_Type__c == 'Fault Code') {
				details.faultCodeLines++;
			} else {
				details.debriefLines++;
			}
			if (woli.Status == 'Submitted' && woli.IntegrationStatus__c != 'Error') {
				details.stuckLines++;
			}
		
		}

		for (Id woId : completeIds)
		{
			WorkOrder wo = woMap.get(woId);
			wo.Completion_Errors__c = null;
			List<String> errorMsgs = new List<String>();
			DebriefDetails details = (debriefMap.containsKey(wo.Id)) ? debriefMap.get(wo.Id) : new DebriefDetails();
			if (details.faultCodeLines == 0)
			{				if (details.debriefLines == 0 || wo.fxIs_TPV__c == true) // || wo.Is_Remote_Support_Hours__c == true) // wo.Is_Install__c == TRUE ||
				{
					System.debug('SKIPPING Fault Code Validation because NO Lines OR TPV'); // OR REMOTE SUPPORT');
				}
				else
				{
					errorMsgs.add('At least one Fault Code line must be entered when other Debrief lines are entered.');
				}
			}

			if (details.stuckLines > 0)
			{
				errorMsgs.add('Wait for the ' + details.stuckLines + ' Submitted Line(s) to finish processing.');
			}

			if (!errorMsgs.isEmpty())
			{
				String errorMsg = 'For a Work Order to transition to "Work Complete", the following must be corrected: ' + errorMsgs;
				wo.Completion_Errors__c = errorMsg;
				wo.Status = 'Work Complete - Error';
				woMap.remove(wo.Id);
			}
		}
		Map<Id, List<WorkOrderLineItem>> linesToDiscount = new Map<Id, List<WorkOrderLineItem>>();
		Set<Id> woIdsWithLinesToSend = new Set<Id>();
		Map<Id, List<String>> woProblems = new Map<Id, List<String>>();
		List<WorkOrderLineItem> wdToUpdate = new List<WorkOrderLineItem>();
		for (Id woId : woMap.keySet())
		{
			WorkOrder wo = woMap.get(woId);
			DebriefDetails details = (debriefMap.containsKey(woId)) ? debriefMap.get(woId) : new DebriefDetails();
			for ( WorkOrderLineItem woli : details.allLines )
			{
				System.debug('SUBMIT-COMPLETE ALL WO: ' + wo);
				if (woli.Consumed_From_Location__r != null &&
						woli.Consumed_From_Location__r.fxNon_Consumable_Location__c == true)
				{
					if (!woProblems.containsKey(woId))
					{
						woProblems.put(woId, new List<String>());
					}
					woProblems.get(woId).add('Parts from Non-Consumable Location is not able to be Submitted: ' + woli.LineItemNumber);
				}
				
				else if (woli.Status == 'Priced'
						// SVMXINT-469 Complaints: Fault Code Integration Changes (Send Fault Codes only if not Confirmed)
						|| (woli.Line_Type__c == 'Fault Code' && (woli.Status == 'Open' || woli.Status == 'Reopen')) //SUN-247
						// JIRA #392 - Internal / Installation - Skip Priced
						|| (NON_PRICED_WO_TYPES.contains(wo.Billing_Type__c) && woli.Status == 'Open') )
				{
					woli.Status='Submitted';
					woli.SubmitTxnId__c = txnId;
					wdToUpdate.add(woli);
					woIdsWithLinesToSend.add(woId);
				}
				else if (woli.Status == 'Submitted' && woli.IntegrationStatus__c == 'Error')
				{
					woli.IntegrationStatus__c = 'Pending';
					woli.SubmitTxnId__c = txnId;
					wdToUpdate.add(woli);
					woIdsWithLinesToSend.add(woId);
				}
				else if (wo.ContractEntitlement__c != null && woli.Status == 'Open'
						&& woli.ContractPercentDiscount__c == null)
				{
					if (!linesToDiscount.containsKey(wo.Id)) {
						linesToDiscount.put(wo.Id, new List<WorkOrderLineItem>());
					}
					linesToDiscount.get(wo.Id).add(woli);
				}
				else if (woli.Status != 'Confirmed')
				{
					if (!woProblems.containsKey(woId)) {
						woProblems.put(woId, new List<String>());
					}
					woProblems.get(woId).add('Non-Confirmed line is not able to be Submitted: ' + woli.LineItemNumber);
				}
			}
		}

		for (Id woId : linesToDiscount.keySet())
		{
			WorkOrder wo = woMap.get(woId);
			List<WorkOrderLineItem> lines = linesToDiscount.get(woId);
			FS_WorkOrderPricingAction.applyContractDiscounts(wo, lines);

			for (WorkOrderLineItem wd : lines)
			{
				if (wd.ContractPercentDiscount__c == 100.00)
				{
					wd.Status = 'Submitted';
					wd.SubmitTxnId__c = txnId;
					wdToUpdate.add(wd);
					woIdsWithLinesToSend.add(woId);
				}
				else
				{
					if (!woProblems.containsKey(woId)) {
						woProblems.put(woId, new List<String>());
					}
					woProblems.get(woId).add('Non-Confirmed line is not able to be Submitted: ' + wd.LineItemNumber);
				}
			}
		}

		if (!wdToUpdate.isEmpty()) {
			update wdToUpdate;
		}

		List<FS_WorkOrder_Event__e> events = new List<FS_WorkOrder_Event__e>();
		for (Id woId : woMap.keySet())
		{
			WorkOrder wo = woMap.get(woId);
			Boolean anyLinesToSend = woIdsWithLinesToSend.contains(woId);
			List<String> problems = woProblems.get(woId);
			if (completeIds.contains(woId))
			{
				if (problems != null && !problems.isEmpty())
				{
					String errorMsg = 'For a Work Order to transition to "Work Complete", the following must be corrected: ' + problems;
					wo.Completion_Errors__c = errorMsg;
					wo.Status = WORK_COMPLETE_ERROR;
					if (errorMsg.contains('Non-Consumable Location'))
					{
						wo.Status = WORK_COMPLETE_MATERIAL_FOLLOW_UP;
					}
					submitIds.add(woId);
				}
				else if (anyLinesToSend)
				{
					wo.Status = WORK_COMPLETE_PENDING;

					FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
					iEvent.Action__c = 'SUBMIT-COMPLETE';
					iEvent.WorkOrderId__c = woId;
					iEvent.SubmitTxnId__c = txnId;
					events.add(iEvent);
				}
				else if (wo.SAP_SystemStatus__c != 'TECO')
				{
					FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
					iEvent.Action__c = 'COMPLETE';
					iEvent.WorkOrderId__c = woId;
					events.add(iEvent);
				}
				else
				{
					if (FS_WorkOrderManager.isBillable(wo))
					{
						FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
						iEvent.Action__c = 'BILLING REQUEST';
						iEvent.WorkOrderId__c = wo.Id;
						events.add(iEvent);
					}
					else
					{
						// WHAT NOW.. do we go straight to Closed?!?
					}
				}
			}
			if (anyLinesToSend && submitIds.contains(woId))
			{
				FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
				iEvent.Action__c = 'SUBMIT';
				iEvent.WorkOrderId__c = woId;
				iEvent.SubmitTxnId__c = txnId;
				events.add(iEvent);
			}
		}
		FS_WorkOrderManager.sendWorkOrderEvents(events);
	}

	public class DebriefDetails
	{
		public Integer debriefLines { get; set; }
		public Integer faultCodeLines { get; set; }
		public Integer stuckLines { get; set; }
		public List<WorkOrderLineItem> allLines = new List<WorkOrderLineItem>();

		public DebriefDetails()
		{
			this.debriefLines = 0;
			this.faultCodeLines = 0;
			this.stuckLines = 0;
		}
	}
	public static void cancelWorkOrders(List<WorkOrder> woNewList, Map<Id, WorkOrder> woOldMap)
	{
		if (!FS_Utility.isActive('Work Order Cancel', 'Cancel a Work Order and send a TECO to SAP')) {
			return;
		}
		Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
		Set<Id> cancelledIds = new Set<Id>();
		for (WorkOrder workOrder : woNewList)
		{
			WorkOrder old = (woOldMap == null) ? null : woOldMap.get(workOrder.Id);
			if ( old != null && old.Status != workOrder.Status && workOrder.Status == CANCELED)
			{
				workOrder.Original_Work_Order_Order_Type__c = old.Order_Type__c;
				woMap.put(workOrder.Id, workOrder);
				cancelledIds.add(workOrder.Id);
			}
		}

		if (woMap.isEmpty()) {
			return;
		}

		System.debug('WO Cancel Starting');
		List<WorkOrderLineItem> lineList = new List<WorkOrderLineItem>([SELECT Id, LineItemNumber,
				Status, Line_Type__c, WorkOrderId,
				Product2Id, ContractPercentDiscount__c, IntegrationStatus__c
			FROM WorkOrderLineItem WHERE WorkOrderId IN :woMap.keySet()
				AND Status != 'Canceled' AND Line_Type__c != 'Fault Code']);

		Map<Id, List<WorkOrderLineItem>> lineMap = new Map<Id, List<WorkOrderLineItem>>();
		for (WorkOrderLineItem line : lineList)
		{
			if (!lineMap.containsKey(line.WorkOrderId)) {
				lineMap.put(line.WorkOrderId, new List<WorkOrderLineItem>());
			}
			lineMap.get(line.WorkOrderId).add(line);
		}
		// Send the appropriate Events.. (or throw an error)
		Set<Id> whatIds = new Set<Id>();
		List<FS_WorkOrder_Event__e> events = new List<FS_WorkOrder_Event__e>();
		for (WorkOrder wo : woMap.values())
		{
			List<WorkOrderLineItem> lines = lineMap.get(wo.Id);
			Boolean doValidation = (wo.Record_Type__c != 'Estimate');
			if (lines != null && lines.size() > 0 && doValidation) {
				List<String> lineNames = new List<String>();
				for (WorkOrderLineItem line : lines) {
					lineNames.add(line.LineItemNumber);
				}
				wo.addError('Work Order cannot be Canceled because there are Non-Cancelled Work Detail lines: ' + lineNames);
			} else {
				if (wo.SAP_SystemStatus__c != 'TECO' && wo.External_ID__c != null) {
					FS_WorkOrder_Event__e iEvent = new FS_WorkOrder_Event__e();
					iEvent.Action__c = 'COMPLETE';
					iEvent.WorkOrderId__c = wo.Id;
					events.add(iEvent);
				}
				whatIds.add(wo.Id);
			}
		}

		FS_WorkOrderManager.sendWorkOrderEvents(events);
	}
}