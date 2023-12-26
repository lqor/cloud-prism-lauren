public with sharing class ParticipantTriggerHandler {

    public static void beforeInsert(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        ParticipantService participantService = new ParticipantService();
        participantService.preventDuplicateParticipantOnTrainings(newList, oldMap);
    }

    public static void afterInsert(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        ParticipantService participantService = new ParticipantService();
        participantService.recalculateCommissionOnTrainings(newList, oldMap);
        participantService.enqueueRegistrationConfirmationJob(newList, oldMap);
        participantService.enqueueInvoiceCreationJob(newList, oldMap);
        participantService.countNumberOfParticipantsInTrainings(newList, oldMap);
    }

    public static void afterDelete(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        ParticipantService participantService = new ParticipantService();
        participantService.recalculateCommissionOnTrainings(newList, oldMap);
        participantService.countNumberOfParticipantsInTrainings(newList, oldMap);
    }

}