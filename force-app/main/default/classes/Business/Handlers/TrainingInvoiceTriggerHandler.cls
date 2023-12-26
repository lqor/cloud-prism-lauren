public with sharing class TrainingInvoiceTriggerHandler {

    public static void afterInsert(List<TrainingInvoice__c> newList, Map<Id, TrainingInvoice__c> oldMap) {
        TrainingInvoiceService trainingInvoiceService = new TrainingInvoiceService();
        TrainingInvoiceService.createInvoiceLineItemsFromTrainingLineItems(newList, oldMap);
    }

}