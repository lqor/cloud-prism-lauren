trigger TrainingTrigger on Training__c (before insert, after insert, before update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            TrainingTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            TrainingTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_UPDATE {
            TrainingTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            // TrainingTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            // TrainingTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_DELETE {
            // TrainingTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            // TrainingTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }

}