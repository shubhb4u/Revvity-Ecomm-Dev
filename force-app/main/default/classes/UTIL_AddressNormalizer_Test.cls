/**************************************************************
* 1. Jira Ticket(s)
*    ATEAM-2220
* 
* 2. Description - Test class for UTIL_AddressNormalizer
*
* 3. Objects referenced
*    - Info_Central__c
*
* 4. Callouts to additional Components or None: None
*    
* 5. Dependant Class(es):
*    - UTIL_AddressNormalizer
*
* 6. Test Class Name: UTIL_AddressNormalizer_Test
* 
* 7. Is @Invocable (Yes or No): No (Test Class)
*
* 8. Author Name(s): 
*    - BD 2024.03.28 Base
*    -    
*************************************************************/
@isTest
public class UTIL_AddressNormalizer_Test {

    @isTest static void testNormalizeAddress() {
        // Arrange (use existing metadata records in org)

        UTIL_AddressNormalizer.InputWrapper input = new UTIL_AddressNormalizer.InputWrapper();
        input.Input_Street = '123 Main Avenue';
        input.Input_City = 'Saint Louis';
        input.Input_State = 'Massachusetts';
        input.Input_Country = 'United States';
        input.Input_Postal = '02110';

        List<UTIL_AddressNormalizer.InputWrapper> inputs = new List<UTIL_AddressNormalizer.InputWrapper>{input};

        // Act
        Test.startTest();
        List<UTIL_AddressNormalizer.OutputWrapper> outputs = UTIL_AddressNormalizer.normalizeAddress(inputs);
        Test.stopTest();

        // Assert
        UTIL_AddressNormalizer.OutputWrapper result = outputs[0];

        System.assertEquals('123 MAIN AVE', result.Output_Street, 'Street normalization failed');
        System.assertEquals('ST LOUIS', result.Output_City, 'City normalization failed');
        System.assertEquals('MA', result.Output_State, 'State normalization failed');
        System.assertEquals('US', result.Output_Country, 'Country normalization failed');
        System.assertEquals('02110', result.Output_Postal, 'Postal normalization failed');
    }

    @isTest static void testBlankValues() {
        // Arrange
        UTIL_AddressNormalizer.InputWrapper input = new UTIL_AddressNormalizer.InputWrapper();
        input.Input_Street = '';
        input.Input_City = '';
        input.Input_State = '';
        input.Input_Country = '';
        input.Input_Postal = '';

        // Act
        Test.startTest();
        List<UTIL_AddressNormalizer.OutputWrapper> outputs = UTIL_AddressNormalizer.normalizeAddress(new List<UTIL_AddressNormalizer.InputWrapper>{input});
        Test.stopTest();

        // Assert
        UTIL_AddressNormalizer.OutputWrapper result = outputs[0];

        System.assertEquals('', result.Output_Street, 'Expected blank street');
        System.assertEquals('', result.Output_City, 'Expected blank city');
        System.assertEquals('', result.Output_State, 'Expected blank state');
        System.assertEquals('', result.Output_Country, 'Expected blank country');
        System.assertEquals('', result.Output_Postal, 'Expected blank postal');
    }
}