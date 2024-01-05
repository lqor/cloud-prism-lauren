public with sharing class TrainingLineItemService {

    /**
     * This method is part of the Training product management process. It is
     * invoked from the beforeInsert method on the trigger handler class,
     * "TrainingLineItemTriggerHandler." It copies product info to the
     * corresponding line item fields.
     * 
     * @param newlist   List of training line items
     * @param oldMap    Old map of training line items, always null
     */
    public void synchronizeLineItemsWithProducts(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        Set<Id> productIds = new Set<Id>();

        for(TrainingLineItem__c trainingLineItem : newList) {
            productIds.add(trainingLineItem.TrainingProduct__c);
        }

        Map<Id, TrainingProduct__c> trainingProducts = new Map<Id, TrainingProduct__c>(
            TrainingProductQueries.queryTrainingProductsById(productIds)
        );

        for(TrainingLineItem__c lineItem : newList) {
            TrainingProduct__c trainingProduct = trainingProducts.get(lineItem.TrainingProduct__c);
            lineItem = setNewLineItemsWithProductData(lineItem, trainingProduct);
        }
    }

    private TrainingLineItem__c setNewLineItemsWithProductData(TrainingLineItem__c lineItem, TrainingProduct__c product) {
        lineItem.Name = product.Name;
        lineItem.ProductCode__c = product.ProductCode__c;
        lineItem.LineDescription__c = product.ProductDescription__c;

        if(lineItem.Price__c == null) {
            lineItem.Price__c = product.ProductPrice__c;
        }

        return lineItem;
    }

    /**
     * This method is part of the Training product management process. It is
     * invoked from the beforeUpdate method on the trigger handler class,
     * "TrainingLineItemTriggerHandler." If the selected product is changed, it
     * updates the corresponding line item fields.
     * 
     * @param newlist   List of training line items
     * @param oldMap    Old map of training line items, never null
     */
    public void updateLineItemsWithProductChange(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        List<TrainingLineItem__c> lineItemsToProcess = new List<TrainingLineItem__c>();

        Set<Id> productIds = new Set<Id>();

        for(TrainingLineItem__c trainingLineItem : newList) {
            if(filterLineItemsOnProductChanged(trainingLineItem, oldMap) != null) {
                productIds.add(trainingLineItem.TrainingProduct__c);
                lineItemsToProcess.add(trainingLineItem);
            }
        }

        Map<Id, TrainingProduct__c> trainingProducts = new Map<Id, TrainingProduct__c>(
            TrainingProductQueries.queryTrainingProductsById(productIds)
        );

        for(TrainingLineItem__c lineItem : lineItemsToProcess) {
            TrainingProduct__c trainingProduct = trainingProducts.get(lineItem.TrainingProduct__c);
            lineItem = updateLineItemsWithNewProductData(lineItem, trainingProduct);
        }
    }

    private TrainingLineItem__c filterLineItemsOnProductChanged(
        TrainingLineItem__c lineItem, 
        Map<Id, TrainingLineItem__c> oldMap
    ) {
        Boolean isProductChanged = lineItem.TrainingProduct__c != oldMap.get(lineItem.Id).TrainingProduct__c;

        return (isProductChanged) ? lineItem : null;
    }

    private TrainingLineItem__c updateLineItemsWithNewProductData(TrainingLineItem__c lineItem, TrainingProduct__c product) {
        lineItem.Name = product.Name;
        lineItem.ProductCode__c = product.ProductCode__c;
        lineItem.LineDescription__c = product.ProductDescription__c;
        lineItem.Price__c = product.ProductPrice__c;

        return lineItem;
    }

    /**
     * This method is part of the Training price calculation process. It is
     * invoked from the afterInsert method on the trigger handler class,
     * "TrainingLineItemTriggerHandler." It adds product line item prices and
     * taxes and updates the respective fields on trainings.
     * 
     * @param newlist   List of training line items
     * @param oldMap    Old map of training line items, always null
     */
    public void calculateTotalPriceAndTaxOnTrainings(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();

        for(TrainingLineItem__c trainingLineItem : newList) {
            trainingIds.add(trainingLineItem.Training__c);
        }

        List<Training__c> trainingsWithLineItems = TrainingQueries.queryTrainingsWithLineItemsById(trainingIds);

        for(Training__c training : trainingsWithLineItems) {
            training.TotalPrice__c = 0.0;
            training.TotalTax__c = 0.0;

            for(TrainingLineItem__c trainingLineItem : training.TrainingLineItems__r) {
                training.TotalPrice__c += trainingLineItem.Price__c;
                training.TotalTax__c += trainingLineItem.Tax__c;
            }
        }

        if(!trainingsWithLineItems.isEmpty()) {
            update trainingsWithLineItems;
        }
    }

    /**
     * This method is part of the Training price calculation process. It is
     * invoked from the afterUpdate method on the trigger handler class,
     * "TrainingLineItemTriggerHandler." If line item prices and taxes are updated, 
     * it recalculates the sums and and updates the respective fields on trainings.
     * 
     * @param newlist   List of training line items
     * @param oldMap    Old map of training line items, never null
     */
    public void updateTotalPriceAndTaxOnTrainings(List<TrainingLineItem__c> newList, Map<Id, TrainingLineItem__c> oldMap) {
        List<TrainingLineItem__c> lineItemsToProcess = new List<TrainingLineItem__c>();

        Set<Id> trainingIds = new Set<Id>();

        for(TrainingLineItem__c trainingLineItem : newList) {
            if(filterLineItemsOnPriceChanged(trainingLineItem, oldMap) != null) {
                trainingIds.add(trainingLineItem.Training__c);
            }
        }

        if(trainingIds.isEmpty()) {
            return;
        }

        List<Training__c> trainingsWithLineItems = TrainingQueries.queryTrainingsWithLineItemsById(trainingIds);

        for(Training__c training : trainingsWithLineItems) {
            training.TotalPrice__c = 0.0;
            training.TotalTax__c = 0.0;

            for(TrainingLineItem__c trainingLineItem : training.TrainingLineItems__r) {
                training.TotalPrice__c += trainingLineItem.Price__c;
                training.TotalTax__c += trainingLineItem.Tax__c;
            }
        }

        if(!trainingsWithLineItems.isEmpty()) {
            update trainingsWithLineItems;
        }
    }

    private TrainingLineItem__c filterLineItemsOnPriceChanged(
        TrainingLineItem__c lineItem, 
        Map<Id, TrainingLineItem__c> oldMap
    ) {
        Boolean isPriceChanged = lineItem.Price__c != oldMap.get(lineItem.Id).Price__c;

        return (isPriceChanged) ? lineItem : null;
    }

}
