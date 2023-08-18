public with sharing class RestaurantCommissionMetadataQueries {

    public static RestaurantCommissionMetadata__mdt queryRestaurantCommissionMetadata() {
        return [SELECT ProbabilityToBuyPerParticipant__c FROM RestaurantCommissionMetadata__mdt LIMIT 1];
    }

}