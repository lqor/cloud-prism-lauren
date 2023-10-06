public with sharing class PdfGeneratorController {

    @AuraEnabled
    public static List<Participant__c> participants { get; set; }

    @AuraEnabled
    public static void saveCertificates(Id recordId) {
        List<ContentVersion> files = new List<ContentVersion>();
        participants = ParticipantQueries.queryParticipantsByTrainingId(recordId);

        for(Participant__c participant : participants) {
            PageReference pdfPage = Page.ParticipantCertificate;
            pdfPage.getParameters().put('id', participant.Id);

            Blob content;

            if(Test.isRunningTest()) {
                content = Blob.valueOf('Test Content');
            } else {
                content = pdfPage.getContent();
            }

            ContentVersion version = new ContentVersion();

            version.ContentLocation = 'S';
            version.Title = 'Cert' + 
                participant.Name + '_' + 
                participant.Contact__r.FirstName + 
                participant.Contact__r.LastName + '_' + 
                DateTime.now().formatGMT('yyyyMMdd');
            version.PathOnClient = 'Certificate.pdf';
            version.VersionData = content;
            version.FirstPublishLocationId = participant.Id;

            files.add(version);
        }

        if(!files.isEmpty()) {
            insert files;
        }
    }

}