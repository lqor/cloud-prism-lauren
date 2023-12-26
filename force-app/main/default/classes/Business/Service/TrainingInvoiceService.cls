public with sharing class TrainingInvoiceService {

    /**
     * This method is part of the Training invoice management process. It is invoked from the afterInsert method 
     * on the trigger handler class, "TrainingInvoiceTriggerHandler." It creates invoice line items from the 
     * corresponding training line items.
     * 
     * @param newlist   List of training invoices
     * @param oldMap    Old map of training invoices, always null
     */
    public void createInvoiceLineItemsFromTrainingLineItems(
        List<TrainingInvoice__c> newList, 
        Map<Id, TrainingInvoice__c> oldMap
    ) {
        Set<Id> trainingIds = new Set<Id>();

        for(TrainingInvoice__c trainingInvoice : newList) {
            trainingIds.add(trainingInvoice.Training__c);
        }

        Map<Id, Training__c> trainingsWithLineItems = new Map<Id, Training__c>(
            TrainingQueries.queryTrainingsWithLineItemsById(trainingIds)
        );

        List<TrainingInvoiceLineItem__c> invoiceLineItems = new List<TrainingInvoiceLineItem__c>();

        for(TrainingInvoice__c invoice : newList) {
            Training__c training = trainingsWithLineItems.get(invoice.Training__c);
            List<TrainingLineItem__c> trainingLineItems = training.TrainingLineItems__r;

            for(TrainingLineItem__c trainingLineItem : trainingLineItems) {
                invoiceLineItems.add(createTrainingInvoiceLineItem(trainingLineItem, invoice.Id));
            }
        }

        try {
            insert invoiceLineItems;
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }
    }

    private TrainingInvoiceLineItem__c createTrainingInvoiceLineItem(TrainingLineItem__c trainingLineItem, Id invoiceId) {
        TrainingInvoiceLineItem__c invoiceLineItem = new TrainingInvoiceLineItem__c();

        invoiceLineItem.Invoice__c = invoiceId;
        invoiceLineItem.TrainingProduct__c = trainingLineItem.TrainingProduct__c;
        invoiceLineItem.LineDescription__c = trainingLineItem.LineDescription__c;
        invoiceLineItem.ProductCode__c = trainingLineItem.ProductCode__c;
        invoiceLineItem.Price__c = trainingLineItem.Price__c;
        invoiceLineItem.Tax__c = trainingLineItem.Tax__c;

        return invoiceLineItem;
    }

}