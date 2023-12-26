trigger TrainingLineItemTrigger on TrainingLineItem__c (before insert, after insert, before update, after update, after delete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            TrainingLineItemTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            TrainingLineItemTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_UPDATE {
            TrainingLineItemTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            TrainingLineItemTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            // TrainingLineItemTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_DELETE {
            TrainingLineItemTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            // TrainingLineItemTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }

}