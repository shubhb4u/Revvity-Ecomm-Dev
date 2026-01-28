/**************************************************************
* 1. Jira Ticket(s)
*    - SFS-103
*
* 2. Description - 
*    - Test class for FS_workOrderCalculation. Validates that the business 
*      hours between Case CreatedDate and WorkOrder CloseDate are calculated correctly.
*
* 3. Objects referenced
*    - Case
*    - WorkOrder
*
* 4. Callouts to additional Components (including their methods) or None:
*    - FS_workOrderCalculation.calculate
*
* 5. Dependant Class(es):
*    - FS_workOrderCalculation
*
* 6. Test Class Name: FS_workOrderCalculation_Test
* 
* 7. Is @Invocable (Yes or No): No
*
* 8. Author Name(s): 
*    - KD 2025.07.28  - added standard Header
***************************************************************/

@isTest
private class FS_workOrderCalculation_Test {

    @isTest
    static void testCalculateBusinessHours() {
      
		Case testCase = new Case(Subject = 'Test Case', Status = 'New',Case_Path_Status__c='Open',Case_Path_Sub_Status__c='10.New');
        insert testCase;
        Product2 laborProd = FS_TestDataFactory.createTestProduct('TestLabor', 'LAB10010', 'ZZZ', 'Labor');
		Product2 travelProd = FS_TestDataFactory.createTestProduct('TestTravel', 'TRV10010', 'ZZZ', 'Travel');
		Product2 partsProd = FS_TestDataFactory.createTestProduct('TestParts', 'PRT10010', 'ZZZ', 'Service Parts');
       Schema.Location newLocation = new Schema.Location();
       newLocation.name ='test Loc';
       newLocation.LocationType='Warehouse';
        insert newLocation;

        DateTime created = DateTime.now();
        DateTime closed = created.addHours(3);

        WorkOrder wo = new WorkOrder(
            Subject = 'Test WO',
            Status = 'Closed',
            CaseId = testCase.Id,
            StartDate = created,
            EndDate = closed,
            record_type__c='Field Service',
            LocationId = newLocation.id,
            Product__c = laborProd.id
        );
        insert WO;

        FS_workOrderCalculation.Input input = new FS_workOrderCalculation.Input();
        input.caseId = testCase.Id;
        input.workOrderId = wo.Id;

        List<FS_workOrderCalculation.Input> inputList = new List<FS_workOrderCalculation.Input>{ input };

        Test.startTest();
        List<FS_workOrderCalculation.Output> resultList = FS_workOrderCalculation.calculate(inputList);
        Test.stopTest();

        System.assertEquals(1, resultList.size());
        System.assertNotEquals(null, resultList[0].businessHours);
        System.debug('Business Hours: ' + resultList[0].businessHours);
        System.assert(resultList[0].businessHours.contains('.'), 'Output should be in H.MM format');
    }
}