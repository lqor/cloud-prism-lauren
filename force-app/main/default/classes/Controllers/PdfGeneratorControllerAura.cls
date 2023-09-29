public with sharing class PdfGeneratorControllerAura {

    @AuraEnabled
    public String vfUrl { get; set; }

    @AuraEnabled
    public static List<Participant__c> participants { get; set; }

    public PdfGeneratorControllerAura() {
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        SObjectType objType = recordId.getSObjectType();

        if(String.valueOf(objType) == 'Participant__c') {
            participants = ParticipantQueries.queryParticipantAndContactById(recordId);
        } else {
            participants = ParticipantQueries.queryParticipantsByTrainingId(recordId);
        }
    }

    @AuraEnabled
    public static void saveCertificates(Id recordId) {
        SObjectType objType = recordId.getSObjectType();

        if(String.valueOf(objType) == 'Participant__c') {
            participants = ParticipantQueries.queryParticipantAndContactById(recordId);
        } else {
            participants = ParticipantQueries.queryParticipantsByTrainingId(recordId);
        }

        List<ContentVersion> files = new List<ContentVersion>();

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

    @AuraEnabled
    public static String getVfUrl(Id trainingId) {
        return '/apex/ParticipantCertificate?Id=' + trainingId;
    }

}