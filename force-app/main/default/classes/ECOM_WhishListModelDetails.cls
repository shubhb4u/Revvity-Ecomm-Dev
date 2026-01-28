public with sharing class ECOM_WhishListModelDetails {
    
     public class WishListWrapper {
        @AuraEnabled public String user_id {get; set;}
        @AuraEnabled public String wishlist_id {get; set;}
        @AuraEnabled public List<String> sf_product_ids {get; set;}
    }
}