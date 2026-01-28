public with sharing class ECOM_CartModelDetail {
     public class CartWrapper {
        @AuraEnabled public String user_id {get; set;}
        @AuraEnabled public String cart_id {get; set;}
        @AuraEnabled public Integer items_count {get; set;}
        @AuraEnabled public List<CartItemWrapper> cart_items {get; set;}
    }

    // Structure for individual items within the cart
    public class CartItemWrapper {
        @AuraEnabled public String cart_item_id {get; set;}
        @AuraEnabled public String sf_product_id {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}
        @AuraEnabled public String product_image {get; set;}
    }
}