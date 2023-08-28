public with sharing class ParticipantSync {

    public virtual class ParticipantSyncException extends Exception {}
    public class ParticipantSyncedException extends ParticipantSyncException {}

    /**
     * This method is part of the Participant to ERP syncing process. It is called from an invocable action 
     * in the "Send Participant to ERP" flow. It updates the participants that have been successfully saved 
     * to the ERP system and returns a string list with a success confirmation message.
     * 
     * @param participantIds    List of ids for participants to save to ERP system
     */
    @InvocableMethod
    public static List<String> sendParticipantsToERP(List<Id> participantIds){
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByIdAndNoErpId(participantIds);

        if(participants.isEmpty()) {
            throw new ParticipantSyncedException('This participant is already synced to the ERP system.');
        }

        ParticipantService service = new ParticipantService();
        List<Participant__c> participantsToUpdate = service.sendParticipantToERP(participants);

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }

        return new List<String>{'You\'re all set! The participant is saved to the ERP system.'};
    }

}