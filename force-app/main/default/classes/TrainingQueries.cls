public with sharing class TrainingQueries {

    public static List<Restaurant__c> queryTrainingRestaurantsById(Set<Id> trainingIds) {
        return [SELECT Id, Name, AverageMealCost__c, CommissionRate__c FROM Restaurant__c WHERE Id IN :trainingIds];
    }

    public static RestaurantCommissionMetadata__mdt queryRestaurantCommissionMetadata() {
        return [SELECT ProbabilityToBuyPerParticipant__c FROM RestaurantCommissionMetadata__mdt LIMIT 1];
    }

    public static List<Training__c> queryTrainingsWithParticipantsById(Set<Id> trainingIds) {
        return [
            SELECT Id, Restaurant__c, StartDate__c, EndDate__c, 
                   (SELECT Id, Name, Training__c, Contact__c FROM Participants__r)
            FROM Training__c 
            WHERE Id IN :trainingIds
        ];
    }

    public static TrainingDurationMetadata__mdt queryTrainingDurationMetadata() {
        return [
            SELECT PreparationTime__c, ReviewTime__c, TrainingHoursPerDay__c 
            FROM TrainingDurationMetadata__mdt 
            LIMIT 1
        ];
    }
 
    public static List<Participant__c> queryParticipantsByTrainingAndStatus(List<Training__c> trainings) {
        return [
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :trainings AND Status__c != :ParticipantService.PARTICIPANT_STATUS_PARTICIPATED
        ];
    }

}