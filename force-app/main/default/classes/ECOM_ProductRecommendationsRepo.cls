/**************************************************************
* 1. Jira Ticket(s) that relates to this class
*    RWPS-4437
*
* 2. Description - This class contains the repository layer for Product Recommendations
*
* 3. Objects referenced
*
* 4. Callouts to additional Components (including their methods) or None:
*    None
*
* 5. Dependant Class(es):
*
* 6. Test Class Name:
*    - ECOM_ProductRecommendationsUtil_Test
*
* 7. Is @Invocable: No
*
* 8. Author Name(s):
*    - Abhishek Joshi 2025.09.15 - Created the class - RWPS-4437
*************************************************************/

public without sharing class ECOM_ProductRecommendationsRepo {

    /**
    * @description get cached Recommendations
    * @author Abhishek Joshi
    * @param recommendationType | String
    * @param productIds | List<String>
    * @return List<Product_Recommendation__c>
    **/
    public static List<Product_Recommendation__c> getCachedECOMRecommendation(String recommendationType, List<String> productIds, List<String> excludedProductIds) {
        return [
            SELECT
                Active__c, LastModifiedDate, ExternalId__c, Group__c, Product_Main__c, Product_Suggested__c, Rank__c, Suggest_Type__c, Use_Case_Type__c,
                Product_Suggested__r.Id, Product_Suggested__r.Name, Product_Suggested__r.Part_Number__c, Product_Suggested__r.Dangerous_Goods_Indicator_Profile__c, Product_Suggested__r.Product_Model_Identifier__c, Product_Suggested__r.Product_Model_Name__c, Product_Suggested__r.DisplayUrl, Product_Suggested__r.ECOM_Product_Media_URI__c, Product_Suggested__r.Product_Display_Name__c
            FROM Product_Recommendation__c
            WHERE
                Product_Main__c IN :productIds AND
                Suggest_Type__c = :recommendationType AND
                Use_Case_Type__c = 'Web' AND
                Product_Suggested__c NOT IN :excludedProductIds
            ORDER BY Rank__c DESC
            LIMIT 300
        ];
    }

    /**
     * @description This method returns the order items in a particular time period which belong to a list of part numbers
     * @author Abhishek Joshi 2025.09.15
     * @param partNumbers | List<String>
     * @param startDate | Date
     * @param endDate | Date
     * @return List<SAP_Order_Items__c>
     */
    public static List<SAP_Order_Items__c> fetchSAPOrderItemsByDateAndPartNumber(List<String> partNumbers, Date startDate, Date endDate){
        return [
            SELECT PKI_Order_Summary__r.Sold_To_Customer_Id__c, PKI_Order_Summary__r.Bill_To_Customer_Id__c, PKI_Order_Summary__r.Contact_Email__c, PKI_Order_Summary__r.ShipTo_Email__c, PKI_Order_Summary__r.Name, Material_Number__c
            FROM SAP_Order_Items__c
            WHERE
                Material_Number__c IN :partNumbers AND
                PKI_Order_Summary__r.Sold_To_Customer_Id__c != null AND
                PKI_Order_Summary__r.fxStatusB2B__c != 'Cancelled' AND
                (
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c >= :startDate AND
                        PKI_Order_Summary__r.Actual_Order_Date__c <= :endDate
                    )
                    OR
                    (
                        PKI_Order_Summary__r.Actual_Order_Date__c = null AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) >= :startDate AND
                        DAY_ONLY(PKI_Order_Summary__r.CreatedDate) <= :endDate
                    )
                )
            ORDER BY PKI_Order_Summary__r.Actual_Order_Date__c DESC, PKI_Order_Summary__r.CreatedDate DESC
            LIMIT 50000
        ];
    }
}