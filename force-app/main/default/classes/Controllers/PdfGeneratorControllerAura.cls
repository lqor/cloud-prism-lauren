public with sharing class PdfGeneratorControllerAura {

    @AuraEnabled
    public String vfUrl { get; set; }

    @AuraEnabled
    public static String getVfUrl(Id trainingId) {
        return '/apex/ParticipantCertificate?trainingId=' + trainingId;
    }

    @AuraEnabled
    public static void saveCertificates(Id trainingId) {
        List<ContentVersion> files = new List<ContentVersion>();
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByTrainingId(trainingId);

        for(Participant__c participant : participants) {
            PageReference pdfPage = Page.ParticipantCertificate;
            pdfPage.getParameters().put('participantId', participant.Id);

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