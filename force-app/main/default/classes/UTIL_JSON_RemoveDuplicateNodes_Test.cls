/**************************************************************
* 1. Jira Ticket(s)
*    - ATEAM-NNNN
*
* 2. Description - This test class is used to test the functionality of UTIL_JSON_RemoveDuplicateNodes class to ensure it correctly consolidates duplicate entries in child nodes based on customer number and address.
*
* 3. Objects referenced
*    - None
*
* 4. Callouts to additional Components (including their methods) or None: None
*    
* 5. Dependant Class(es):
*    - UTIL_JSON_RemoveDuplicateNodes    
*
* 6. Test Class Name: UTIL_JSON_RemoveDuplicateNodes_Test
* 
* 7. Is @Invocable (Yes or No): Yes
*
* 8. Author Name(s): 
*    - Brad 2025.01.22 Base
*************************************************************/
@IsTest
public class UTIL_JSON_RemoveDuplicateNodes_Test {
    @IsTest
    static void testRemoveDuplicates() {
        // Arrange
        String inputPayload = '{"soldTo": [{"customerNumber": "123", "addressFull": "123 Main St", "rank": 1}, {"customerNumber": "123", "addressFull": "123 Main St", "rank": 2}],'
                            + '"shipTo": [{"customerNumber": "456", "addressFull": "456 Elm St", "rank": 1}],'
                            + '"otherNode": [{"customerNumber": "789", "addressFull": "789 Oak St", "rank": 1}]}';
        
        UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput input = new UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput();
        input.payload = inputPayload;
        input.nodeNames = new List<String>{'soldTo', 'shipTo'};

        List<UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput> inputs = new List<UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput>{input};

        // Act
        Test.startTest();
        List<String> result = UTIL_JSON_RemoveDuplicateNodes.removeDuplicates(inputs);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain one payload');

        Map<String, Object> updatedPayload = (Map<String, Object>) JSON.deserializeUntyped(result[0]);

        List<Object> soldToNodes = (List<Object>) updatedPayload.get('soldTo');
        System.assertEquals(1, soldToNodes.size(), 'SoldTo should contain only one unique node');
        Map<String, Object> soldToNode = (Map<String, Object>) soldToNodes[0];
        System.assertEquals('123', soldToNode.get('customerNumber'), 'Customer number should match');
        System.assertEquals('123 Main St', soldToNode.get('addressFull'), 'Address should match');
        System.assertEquals(1, soldToNode.get('rank'), 'Rank should match the lower value');

        List<Object> shipToNodes = (List<Object>) updatedPayload.get('shipTo');
        System.assertEquals(1, shipToNodes.size(), 'ShipTo should remain unchanged');
    }

    @IsTest
    static void testEmptySoldToReplacedByShipTo() {
        // Arrange
        String inputPayload = '{"soldTo": [],'
                            + '"shipTo": [{"customerNumber": "456", "addressFull": "456 Elm St", "rank": 1}]}';
        
        UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput input = new UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput();
        input.payload = inputPayload;
        input.nodeNames = new List<String>{'soldTo', 'shipTo'};

        List<UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput> inputs = new List<UTIL_JSON_RemoveDuplicateNodes.RemoveDuplicatesInput>{input};

        // Act
        Test.startTest();
        List<String> result = UTIL_JSON_RemoveDuplicateNodes.removeDuplicates(inputs);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain one payload');

        Map<String, Object> updatedPayload = (Map<String, Object>) JSON.deserializeUntyped(result[0]);

        List<Object> soldToNodes = (List<Object>) updatedPayload.get('soldTo');
        System.assertEquals(1, soldToNodes.size(), 'SoldTo should be replaced by ShipTo nodes');
        Map<String, Object> soldToNode = (Map<String, Object>) soldToNodes[0];
        System.assertEquals('456', soldToNode.get('customerNumber'), 'Customer number should match ShipTo');
        System.assertEquals('456 Elm St', soldToNode.get('addressFull'), 'Address should match ShipTo');
    }
}