public with sharing class PdfGeneratorController {

    @AuraEnabled
    public static List<Participant__c> participants { get; set; }

    public PdfGeneratorController() {
        Id trainingId = ApexPages.currentPage().getParameters().get('trainingId');
        Id participantId = ApexPages.currentPage().getParameters().get('participantId');

        if(trainingId != null) {
            participants = ParticipantQueries.queryParticipantsByTrainingId(trainingId);
        } else {
            participants = ParticipantQueries.queryParticipantAndContactById(participantId);
        }
    }

}