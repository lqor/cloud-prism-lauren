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

    public static List<Participant__c> queryParticipantsByTrainingId(Id trainingId) {
        return [
            SELECT Id, Name, Status__c, GPA__c, Passed__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                   Training__r.Name, Training__r.StartDate__c, Training__r.EndDate__c
            FROM Participant__c 
            WHERE Training__c = :trainingId
        ];
    }

    public static Participant__c queryParticipantByName(String participantName) {
        return [SELECT Id, Name, Contact__c FROM Participant__c WHERE Name = :participantName LIMIT 1];
    }

    public static Participant__c queryParticipantById(Id participantId) {
        return [SELECT Id, Name, Status__c, ErpId__c FROM Participant__c WHERE Id = :participantId LIMIT 1];
    }

    public static List<Participant__c> queryParticipantAndContactById(Id participantId) {
        return [
            SELECT Id, Name, Status__c, GPA__c, Passed__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                   Training__r.Name, Training__r.StartDate__c, Training__r.EndDate__c
            FROM Participant__c 
            WHERE Id = :participantId
        ];
    }

    public static Participant__c queryParticipantByInvoiceId(String invoiceId) {
        return [
            SELECT Name, Status__c 
            FROM Participant__c 
            WHERE Id IN (SELECT Participant__c FROM TrainingInvoice__c WHERE InvoiceId__c = :invoiceId) 
            LIMIT 1
        ];
    }

}