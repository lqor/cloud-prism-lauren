public with sharing class ParticipantSyncScheduled implements Schedulable {

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the UI as a scheduled job.
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ParticipantSyncBatch('Participant__c'), 200);
    }

}