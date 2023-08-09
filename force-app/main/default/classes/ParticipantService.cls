public with sharing class ParticipantService {

    public static final String PARTICIPANT_STATUS_ACTIVE = 'Active';
    public static final String PARTICIPANT_STATUS_PARTICIPATED = 'Participated';
    public static final String ERROR_MESSAGE_DUPLICATE = 'This duplicate participant cannot be booked for the training';

    /**
     * This method is part of the Participant organization process. It is called from the trigger handler class, 
     * "ParticipantTriggerHandler." The result is an error message indicating the duplicate participant cannot 
     * be saved.
     * 
     * @param newlist   List of participants
     * @param oldMap    Old map of participants, always null
     */
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

    /**
     * This method is part of the Training restaurant commission calculation process. It is called from 
     * the trigger handler class, "ParticipantTriggerHandler." It recalculates the result of the restaurant 
     * commission when a participant is added or deleted and updates the trainings.
     * 
     * @param newlist   List of participants
     * @param oldMap    Old map of participants
     */
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

    /**
     * This method is part of the Participant registration confirmation process. It is called from the trigger 
     * handler class, "ParticipantTriggerHandler." It submits the queueable class, "RegistrationConfirmationQueueable," 
     * as a job on the queue.
     * 
     * @param newlist   List of participants
     * @param oldMap    Old map of participants, always null
     */
    public void sendRegistrationConfirmationEmail(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();

        for(Participant__c participant : newList) {
            participantIds.add(participant.Id);
            trainingIds.add(participant.Training__c);
        }

        List<Training__c> trainingsWithParticipants = queryTrainingsForNewParticipantsById(trainingIds, participantIds);

        Id jobId = System.enqueueJob(new RegistrationConfirmationQueueable(trainingsWithParticipants));
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

    public List<Training__c> queryTrainingsForNewParticipantsById(Set<Id> trainingIds, Set<Id> participantIds) {
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