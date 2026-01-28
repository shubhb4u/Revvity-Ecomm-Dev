@isTest
public class UTIL_MergeEmailTemplate_Test {


    @isTest static void testFlowCalled() {
     // Step:1 Create test data 
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        insert validEmailTemplate;
        // Step 2: Prepare flow inputs
        UTIL_MergeEmailTemplate.FlowInputs flowInput = new UTIL_MergeEmailTemplate.FlowInputs();
        flowInput.templateId = validEmailTemplate.Id;  // Pass the templateId
        flowInput.whoId =null;  // Pass the contact Id as whoId
        flowInput.whatId =userinfo.getUserId();//   // Pass the account Id as whatId
        
        List<UTIL_MergeEmailTemplate.FlowInputs> inputs = new List<UTIL_MergeEmailTemplate.FlowInputs>{flowInput};

        // Step 3: Call the method to test
        Test.startTest();
        List<UTIL_MergeEmailTemplate.FlowOutputs> outputs = UTIL_MergeEmailTemplate.flowcalled(inputs);
        Test.stopTest();
}
}