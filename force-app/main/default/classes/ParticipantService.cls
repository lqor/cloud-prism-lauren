public with sharing class ParticipantService {

    public static final String PARTICIPANT_STATUS_ACTIVE = 'Active';
    public static final String PARTICIPANT_STATUS_PARTICIPATED = 'Participated';
    public static final String ERROR_MESSAGE_DUPLICATE = 'This duplicate participant cannot be booked for the training';

    public void preventDuplicateParticipantOnTrainings(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for(Participant__c participant : newList) {
            trainingIds.add(participant.Training__c);
            contactIds.add(participant.Contact__c);
        }

        Map<Id, Training__c> trainings = new Map<Id, Training__c>(queryTrainingsWithParticipantsById(trainingIds));
        Map<Id, Contact> contacts = new Map<Id, Contact>(queryContactsOfParticipantsById(contactIds));

        for(Participant__c participant : newList) {
            List<Participant__c> existingParticipants = trainings.get(participant.Training__c).Participants__r;
            Boolean canBookForOthers = contacts.get(participant.Contact__c).CanBookForOthers__c;

            for(Participant__c existingParticipant : existingParticipants) {
                Boolean isDuplicate = participant.Contact__c == existingParticipant.Contact__c && !canBookForOthers;

                if(isDuplicate) {
                    participant.addError(ERROR_MESSAGE_DUPLICATE);
                }
            }
        }
    }

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
                   (SELECT Id, Name, Training__c, Contact__c FROM Participants__r)
            FROM Training__c 
            WHERE Id IN :ids
        ];
    }

    public List<Contact> queryContactsOfParticipantsById(Set<Id> ids) {
        return [SELECT Id, CanBookForOthers__c FROM Contact WHERE Id IN :ids];
    }

}