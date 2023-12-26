public with sharing class TrainingProductQueries {

    public static List<TrainingProduct__c> queryTrainingProductsById(Set<Id> productIds) {
        return [
            SELECT Id, Name, ProductPrice__c, ProductTax__c, ProductDescription__c, ProductCode__c 
            FROM TrainingProduct__c
            WHERE Id IN :productIds
        ];
    }

}