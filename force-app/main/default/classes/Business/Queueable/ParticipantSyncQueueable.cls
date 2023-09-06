public with sharing class ParticipantSyncQueueable implements Queueable, Database.AllowsCallouts {

    private List<Participant__c> participants;

    public ParticipantSyncQueueable(List<Participant__c> participants) {
        this.participants = participants;
    }

    /**
     * This method is part of the Participant from ERP import process. It is called from the getParticipantByErpId 
     * method in the controller class, "ParticipantTableController." It updates the participants after they have 
     * been successfully saved to the ERP system.
     */
    public void execute(QueueableContext context) {
        ParticipantService service = new ParticipantService();
        List<Participant__c> participantsToUpdate = service.sendParticipantToERP(participants);

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }
    }

}