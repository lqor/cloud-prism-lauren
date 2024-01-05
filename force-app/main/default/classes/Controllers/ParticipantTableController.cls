public with sharing class ParticipantTableController {

    public virtual class ParticipantTableControllerException extends Exception {}
    public class EmptyTrainingIdException extends ParticipantTableControllerException {}
    public class EmptyErpIdException extends ParticipantTableControllerException {}
    public class IncompleteParticipantException extends ParticipantTableControllerException {}
    public class EmptyParticipantIdException extends ParticipantTableControllerException {}


    @AuraEnabled
    public static List<ParticipantWrapper> getParticipants(Id trainingId) {
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByTrainingId(trainingId);

        if(participants.isEmpty()) {
            return null;
        }

        return convertParticipantsToWrappers(participants);
    }

    @AuraEnabled
    public static String updateParticipants(String serializedParticipants) {
        List<ParticipantWrapper> wrappers = (List<ParticipantWrapper>) JSON.deserialize(
            serializedParticipants, 
            List<ParticipantWrapper>.class
        );

        List<Participant__c> participantsToUpdate = convertWrappersToParticipants(wrappers);

        if(participantsToUpdate.isEmpty()) {
            return 'No Participants to Update.';
        }

        try {
            upsert participantsToUpdate;
            return 'Participants were successfully updated.';
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static List<ParticipantWrapper> getParticipantByErpId(Id trainingId, String erpId) {
        if(trainingId == null) {
            throw new EmptyTrainingIdException('Empty Training Id. Please ensure this component is attached to a Training record page');
        }

        if(String.isblank(erpId) || !erpId.isNumeric()) {
            throw new EmptyErpIdException('Erp Id must be a valid number. Please check the Erp Id and try again');
        }

        ParticipantService service = new ParticipantService();
        String participantName = service.getParticipantFromERP(trainingId, erpId);
        Participant__c priorParticipant = ParticipantQueries.queryParticipantByName(participantName);
        Participant__c newParticipant = service.insertNewParticipantFromPrior(trainingId, priorParticipant);

        List<Participant__c> participants = new List<Participant__c> {newParticipant};
        Id jobId = System.enqueueJob(new ParticipantSyncQueueable(participants));

        List<Participant__c> participantToWrapper = ParticipantQueries.queryParticipantAndContactById(newParticipant.Id);

        return convertParticipantsToWrappers(participantToWrapper);
    }

    @AuraEnabled
    public static List<ParticipantWrapper> addNewParticipant(Id trainingId, String serializedParticipant) {
        if(trainingId == null) {
            throw new EmptyTrainingIdException('Empty Training Id. Please ensure this component is attached to a Training record page');
        }

        Participant__c participant = (Participant__c) JSON.deserialize(serializedParticipant, Participant__c.class);
        if(participant.Contact__c == null) {
            throw new IncompleteParticipantException('Incomplete Participant Form. Please select a Contact before saving');
        }

        ParticipantService service = new ParticipantService();
        Participant__c newParticipant = service.insertNewParticipant(trainingId, participant);

        List<Participant__c> participants = new List<Participant__c> {newParticipant};
        Id jobId = System.enqueueJob(new ParticipantSyncQueueable(participants));

        List<Participant__c> participantToWrapper = ParticipantQueries.queryParticipantAndContactById(newParticipant.Id);

        return convertParticipantsToWrappers(participantToWrapper);
    }

    @AuraEnabled
    public static Id deleteParticipant(Id participantId) {
        if(participantId == null) {
            throw new EmptyParticipantIdException('Participant could not be found. Please try refreshing the page.');
        }

        try {
            delete [SELECT Id FROM Participant__c WHERE Id = :participantId];
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
            return null;
        }

        return participantId;
    }

    private static List<ParticipantWrapper> convertParticipantsToWrappers(List<Participant__c> participants) {
        List<ParticipantWrapper> participantWrappersToSend = new List<ParticipantWrapper>();

        for(Participant__c participant : participants) {
            ParticipantWrapper participantWrapper = new ParticipantWrapper();

            participantWrapper.participantId = participant.Id;
            participantWrapper.participantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
            participantWrapper.participantUrl = '/' + participant.Id;
            participantWrapper.participantEmail = participant.Contact__r.Email;
            participantWrapper.participantStatus = participant.Status__c;
            participantWrapper.participantGPA = (Integer) participant.GPA__c;
            participantWrapper.participantPassed = participant.Passed__c;

            participantWrappersToSend.add(participantWrapper);
        }

        return participantWrappersToSend;
    }

    private static List<Participant__c> convertWrappersToParticipants(List<ParticipantWrapper> participantWrappers) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        for(ParticipantWrapper wrapper : participantWrappers) {
            Participant__c participant = new Participant__c();

            participant.Id = wrapper.participantId;
            participant.GPA__c = wrapper.participantGPA;
            participant.Passed__c = wrapper.participantPassed == null ? false : wrapper.participantPassed;

            participantsToUpdate.add(participant);
        }

        return participantsToUpdate;
    }

    public class ParticipantWrapper {
        @AuraEnabled
        public String participantId;
        @AuraEnabled
        public String participantName;
        @AuraEnabled
        public String participantUrl;
        @AuraEnabled
        public String participantEmail;
        @AuraEnabled
        public String participantStatus;
        @AuraEnabled
        public Integer participantGPA;
        @AuraEnabled
        public Boolean participantPassed;
    }

}