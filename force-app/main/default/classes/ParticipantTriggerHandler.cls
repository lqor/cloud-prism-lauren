public with sharing class ParticipantTriggerHandler {

    public static void afterInsert(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        ParticipantService participantService = new ParticipantService();
        participantService.recalculateCommissionOnTrainings(newList, oldMap);
    }
    
}