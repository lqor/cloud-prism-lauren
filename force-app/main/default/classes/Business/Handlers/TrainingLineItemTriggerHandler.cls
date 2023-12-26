public with sharing class TrainingLineItemTriggerHandler {

    public static void beforeInsert(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        TrainingLineItemService trainingLineItemService = new TrainingLineItemService();
        trainingLineItemService.synchronizeLineItemsWithProducts(newList, oldMap);
    }

    public static void afterInsert(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        TrainingLineItemService trainingLineItemService = new TrainingLineItemService();
        trainingLineItemService.calculateTotalPriceAndTaxOnTrainings(newList, oldMap);
    }

    public static void beforeUpdate(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        TrainingLineItemService trainingLineItemService = new TrainingLineItemService();
        trainingLineItemService.updateLineItemsWithProductChange(newList, oldMap);
    }

    public static void afterUpdate(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        TrainingLineItemService trainingLineItemService = new TrainingLineItemService();
        trainingLineItemService.updateTotalPriceAndTaxOnTrainings(newList, oldMap);
    }

    public static void afterDelete(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        TrainingLineItemService trainingLineItemService = new TrainingLineItemService();
        trainingLineItemService.calculateTotalPriceAndTaxOnTrainings(newList, oldMap);
    }

}