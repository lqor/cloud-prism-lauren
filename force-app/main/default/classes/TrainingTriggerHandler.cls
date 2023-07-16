public with sharing class TrainingTriggerHandler {

    public static void beforeInsert(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        TrainingService trainingService = new TrainingService();
        trainingService.setRestaurantCommissionOnTrainings(newList, oldMap);
    }

    public static void afterInsert(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        TrainingService trainingService = new TrainingService();
        trainingService.insertTasksForTrainings(newList, oldMap);
    }

    public static void beforeUpdate(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        TrainingService trainingService = new TrainingService();
        trainingService.updateCompletedTrainings(newList, oldMap);
    }

}