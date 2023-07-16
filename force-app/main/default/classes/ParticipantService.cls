public with sharing class ParticipantService {

    public void recalculateCommissionOnTrainings(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        TrainingService trainingService = new TrainingService();
        Set<Id> trainingIds = new Set<Id>();
        
        for(Participant__c participant : newList) {
            trainingIds.add(participant.Training__c);
        }

        List<Training__c> trainingsWithParticipants = queryTrainingsWithParticipantsById(trainingIds);
        trainingService.setRestaurantCommissionOnTrainings(trainingsWithParticipants, null);

        if(!trainingsWithParticipants.isEmpty()) {
            update trainingsWithParticipants;
        }
    }

    public List<Training__c> queryTrainingsWithParticipantsById(Set<Id> ids) {
        return [
            SELECT Id, Restaurant__c, StartDate__c, EndDate__c, 
                   (SELECT Id FROM Participants__r)
            FROM Training__c 
            WHERE Id IN :ids
        ];
    }

}