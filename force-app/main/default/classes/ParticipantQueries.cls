public with sharing class ParticipantQueries {

    public static List<Participant__c> queryParticipantsById(List<Id> participantIds) {
        return [SELECT Id, Name, Status__c FROM Participant__c WHERE Id IN :participantIds];
    }

    public static List<Contact> queryContactsOfParticipantsById(Set<Id> contactIds) {
        return [SELECT Id, CanBookForOthers__c FROM Contact WHERE Id IN :contactIds];
    }

    public static List<Training__c> queryTrainingsForNewParticipantsById(Set<Id> trainingIds, Set<Id> participantIds) {
        return [
            SELECT Id, Name, StartDate__c, EndDate__c, TrainerContact__r.FirstName, TrainerContact__r.LastName, 
                   TrainerContact__r.Email, TrainingCourse__r.Name,
                   (SELECT Id, PaymentLink__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
                   FROM Participants__r
                   WHERE Id IN :participantIds)
            FROM Training__c 
            WHERE Id IN :trainingIds
        ];
    }

}