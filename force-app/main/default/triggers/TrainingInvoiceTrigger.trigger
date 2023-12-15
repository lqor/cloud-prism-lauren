trigger TrainingInvoiceTrigger on TrainingInvoice__c (after insert) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            // TrainingInvoiceTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            TrainingInvoiceTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_UPDATE {
            // TrainingInvoiceTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            // TrainingInvoiceTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            // TrainingInvoiceTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_DELETE {
            // TrainingInvoiceTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            // TrainingInvoiceTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }

}