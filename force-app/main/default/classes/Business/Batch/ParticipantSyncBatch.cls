global with sharing class ParticipantSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private String objName;

    global ParticipantSyncBatch(String objName) {
        this.objName = objName;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Status__c, ErpId__c FROM ' + objName + ' WHERE ErpId__c = null');
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the scheduled class,
     * "ParticipantSyncScheduled." It updates the participants that have been successfully saved to the ERP system.
     */
    global void execute(Database.BatchableContext bc, List<Participant__c> participants) {
        ParticipantService service = new ParticipantService();
        List<Participant__c> participantsToUpdate = service.sendParticipantToERP(participants);

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {}

}