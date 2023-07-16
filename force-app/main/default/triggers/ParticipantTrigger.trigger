trigger ParticipantTrigger on Participant__c (after insert) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            // ParticipantTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            ParticipantTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_UPDATE {
            // ParticipantTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            // ParticipantTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            // ParticipantTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_DELETE {
            // ParticipantTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            // ParticipantTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }

}