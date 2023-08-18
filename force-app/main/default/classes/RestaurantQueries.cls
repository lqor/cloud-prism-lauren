public with sharing class RestaurantQueries {

    public static List<Restaurant__c> queryTrainingRestaurantsById(Set<Id> trainingIds) {
        return [SELECT Id, Name, AverageMealCost__c, CommissionRate__c FROM Restaurant__c WHERE Id IN :trainingIds];
    }

}