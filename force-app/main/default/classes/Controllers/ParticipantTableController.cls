public with sharing class ParticipantTableController {

    @AuraEnabled
    public static List<ParticipantWrapper> getParticipants(Id trainingId) {
        List<ParticipantWrapper> participantsToReturn = new List<ParticipantWrapper>();
        List<Participant__c> participants = [
            SELECT Id, Name, Status__c, GPA__c, Passed__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
            FROM Participant__c 
            WHERE Training__c = :trainingId
        ];
        if(participants.isEmpty()) {
            return null;
        }

        for(Participant__c participant : participants) {
            ParticipantWrapper participantWrapper = new ParticipantWrapper();

            participantWrapper.ParticipantId = participant.Id;
            participantWrapper.ParticipantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
            participantWrapper.ParticipantEmail = participant.Contact__r.Email;
            participantWrapper.ParticipantStatus = participant.Status__c;
            participantWrapper.ParticipantGPA = (Integer) participant.GPA__c;
            participantWrapper.ParticipantPassed = participant.Passed__c;

            participantsToReturn.add(participantWrapper);
        }

        return participantsToReturn;
    }

    @AuraEnabled
    public static String updateParticipants(List<Participant__c> participantsToUpdate) {
        try {
            upsert participantsToUpdate;
            return 'Participants Updated Successfully!!';
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
            return 'The following exception has occurred: ' + e.getMessage();
        }
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