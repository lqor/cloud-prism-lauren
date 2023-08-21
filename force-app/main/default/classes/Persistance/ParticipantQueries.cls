public with sharing class ParticipantQueries {

    public static List<Participant__c> queryParticipantsByTrainingAndStatus(List<Training__c> trainings) {
        return [
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :trainings AND Status__c != :ParticipantService.PARTICIPANT_STATUS_PARTICIPATED
        ];
    }

    public static List<Participant__c> queryParticipantsByIdAndNoErpId(List<Id> participantIds) {
        return [SELECT Id, Name, Status__c, ErpId__c FROM Participant__c WHERE Id IN :participantIds AND ErpId__c = null];
    }

}