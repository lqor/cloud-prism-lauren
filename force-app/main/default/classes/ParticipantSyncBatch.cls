global with sharing class ParticipantSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global virtual class ParticipantSyncBatchException extends Exception {}
    global class ERPCalloutException extends ParticipantSyncBatchException {}

    private String objName;

    global ParticipantSyncBatch(String objName) {
        this.objName = objName;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Status__c, ErpId__c FROM ' +objName+ ' WHERE ErpId__c = null'
        );
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the scheduled class,
     * "ParticipantSyncScheduled." It sends the API request to add the participants in the batch to the ERP 
     * system and updates each participant record with their ERP Id.
     */
    global void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        for(Participant__c participant : participants) {
            Logger logger = new Logger();
            String participantJSON = JSON.serialize(participant);
            String responseBody = '';
            String erpId = '';

            try {
                responseBody = ERPCallout.doERPCalloutForParticipant(participantJSON);
                erpId = SendParticipantToERP.parseErpId(responseBody);
                
                if(responseBody == '') {
                    throw new ERPCalloutException();
                }
            } catch(ERPCalloutException c) {
                logger.logException(c);
            } catch(Exception e) {
                logger.logException(e);
            }

            participant.ErpId__c = erpId;
            participantsToUpdate.add(participant);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {}

}