public with sharing class ParticipantTableController {

    @AuraEnabled
    public static List<ParticipantWrapper> getParticipants(Id trainingId) {
        List<Participant__c> participants = [
            SELECT Id, Name, Status__c, GPA__c, Passed__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
            FROM Participant__c 
            WHERE Training__c = :trainingId
        ];

        if(participants.isEmpty()) {
            return null;
        }

        List<ParticipantWrapper> participantWrappersToSend = convertParticipantsToWrappers(participants);

        return participantWrappersToSend;
    }

    @AuraEnabled
    public static String updateParticipants(String serializedParticipants) {
        List<ParticipantWrapper> wrappers = (List<ParticipantWrapper>) JSON.deserialize(
            serializedParticipants, 
            List<ParticipantWrapper>.class
        );

        List<Participant__c> participantsToUpdate = convertWrappersToParticipants(wrappers);

        if(participantsToUpdate.isEmpty()) {
            return 'No Participants to Update!!';
        }

        try {
            upsert participantsToUpdate;
            return 'Participants Updated Successfully!!';
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    private static List<ParticipantWrapper> convertParticipantsToWrappers(List<Participant__c> participants) {
        List<ParticipantWrapper> participantWrappersToSend = new List<ParticipantWrapper>();

        for(Participant__c participant : participants) {
            ParticipantWrapper participantWrapper = new ParticipantWrapper();

            participantWrapper.participantId = participant.Id;
            participantWrapper.participantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
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
        public String participantEmail;
        @AuraEnabled
        public String participantStatus;
        @AuraEnabled
        public Integer participantGPA;
        @AuraEnabled
        public Boolean participantPassed;
    }

}