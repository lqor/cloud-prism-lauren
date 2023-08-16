global with sharing class ParticipantSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private String objName;

    global ParticipantSyncBatch(String objName) {
        this.objName = objName;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Status__c, ErpId__c FROM ' + objName +' WHERE ErpId__c = null');
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the scheduled class,
     * "ParticipantSyncScheduled." It sends the API request to add the participants in the batch to the ERP 
     * system and updates each participant record with their ERP Id.
     */
    global void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        for(Participant__c participant : participants) {
            String participantJSON = JSON.serialize(participant);
            participant.ErpId__c = SendParticipantToERP.parseErpId(ERPCallout.doERPCalloutForParticipant(participantJSON));
            participantsToUpdate.add(participant);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {}

}