/**************************************************************
* 1. Jira Ticket(s)
*    - SFS-103
*
* 2. Description - 
*    - Calculates the business working hours (between 8 AM and 6 PM) in Brazil timezone 
*      from Case CreatedDate to WorkOrder CloseDate. Returns result in H.MM format.
*
* 3. Objects referenced
*    - Case
*    - WorkOrder
*
* 4. Callouts to additional Components (including their methods) or None:
*    - None
*
* 5. Dependant Class(es):
*    - None
*
* 6. Test Class Name: FS_workOrderCalculation_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    - KD 2025.07.28  - added standard Header
***************************************************************/
public with sharing class FS_workOrderCalculation {

    public class Input {
        @InvocableVariable(required=true)
        public Id caseId;

        @InvocableVariable(required=true)
        public Id workOrderId;
    }

    public class Output {
        @InvocableVariable
        public String businessHours; // Format: H.MM (e.g., "2.30")
    }

    @InvocableMethod(label='Calculate Business Hours H.MM Format')
    public static List<Output> calculate(List<Input> inputList) {
        List<Output> results = new List<Output>();

        // Collect all case and work order IDs
        Set<Id> caseIds = new Set<Id>();
        Set<Id> workOrderIds = new Set<Id>();
        for (Input inp : inputList) {
            caseIds.add(inp.caseId);
            workOrderIds.add(inp.workOrderId);
        }

        // Query all cases and work orders in bulk
        Map<Id, Case> caseMap = new Map<Id, Case>(
            [SELECT Id, CreatedDate FROM Case WHERE Id IN :caseIds]
        );

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
            [SELECT Id, LastModifieddate FROM WorkOrder WHERE Id IN :workOrderIds]
        );

        for (Input inp : inputList) {
            Output out = new Output();

            Case caseRec = caseMap.get(inp.caseId);
            WorkOrder wo = woMap.get(inp.workOrderId);

            if (caseRec != null && wo != null && caseRec.CreatedDate != null && wo.LastModifieddate != null) {
                String startStr = caseRec.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'America/Sao_Paulo');
                String endStr = DateTime.now().format('yyyy-MM-dd HH:mm:ss', 'America/Sao_Paulo');

                DateTime start = DateTime.valueOf(startStr);
                DateTime endDateTime = DateTime.valueOf(endStr);

                Integer totalMinutes = computeBusinessMinutes(start, endDateTime);
                Integer hours = totalMinutes / 60;
                Integer minutes = Math.mod(totalMinutes, 60);
                
                // Manually pad minutes to 2 digits
                String paddedMinutes = (minutes < 10) ? '0' + String.valueOf(minutes) : String.valueOf(minutes);
                
                // Format as H.MM (e.g., 2.05, 1.30)
                out.businessHours = String.valueOf(hours) + '.' + paddedMinutes;
             
            } else {
                out.businessHours = 'N/A';
            }

            results.add(out);
        }

        return results;
    }

    private static Integer computeBusinessMinutes(DateTime start, DateTime endDateTime) {
        if (endDateTime <= start) return 0;

        Integer totalMinutes = 0;
        DateTime current = DateTime.newInstance(start.date(), Time.newInstance(0, 0, 0, 0));
        Date endDate = endDateTime.date();

        while (current.date() <= endDate) {
           
                DateTime workStart = DateTime.newInstance(current.date(), Time.newInstance(8, 0, 0, 0));
                DateTime workEnd = DateTime.newInstance(current.date(), Time.newInstance(18, 0, 0, 0));

                DateTime fromDate = (start > workStart) ? start : workStart;
                DateTime toDate = (endDateTime < workEnd) ? endDateTime : workEnd;

                if (fromDate < toDate) {
                    Long diffMs = toDate.getTime() - fromDate.getTime();
                    totalMinutes += (Integer)(diffMs / (1000 * 60));
                }
            

            current = current.addDays(1);
        }

        return totalMinutes;
    }

    private static Boolean isWeekday(DateTime dt) {
        Integer dayOfWeek = Integer.valueOf(dt.format('u'));
        return dayOfWeek >= 1 && dayOfWeek <= 5;
    }
}