public with sharing class PdfGeneratorController {

    @AuraEnabled
    public static List<Participant__c> participants { get; set; }

    public PdfGeneratorController() {
        Id participantId = ApexPages.CurrentPage().getparameters().get('participantId');
        Id trainingId = ApexPages.CurrentPage().getparameters().get('trainingId');

        System.debug('participantId: ' + participantId);
        System.debug('trainingId: ' + trainingId);

        if(participantId != null) {
            participants = ParticipantQueries.queryParticipantAndContactById(participantId);
        } else {
            participants = ParticipantQueries.queryParticipantsByTrainingId(trainingId);
        }
    }
}