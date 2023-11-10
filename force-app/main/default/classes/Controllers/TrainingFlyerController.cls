public with sharing class TrainingFlyerController {

    public virtual class TrainingFlyerControllerException extends Exception {}
    public class EmptyTrainingIdException extends TrainingFlyerControllerException {}

    @AuraEnabled
    public static Id savePdfToContentVersion(Id trainingId) {
        if(trainingId == null) {
            return null;
        }

        PageReference pdfPage = Page.TrainingFlyer;
        pdfPage.getParameters().put('id', trainingId);
        Blob content;

        if(Test.isRunningTest()) {
            content = Blob.valueOf('Test Content');
        } else {
            content = pdfPage.getContent();
        }

        Training__c training = TrainingQueries.queryTrainingById(trainingId);
        ContentVersion version = new ContentVersion();

        version.ContentLocation = 'S';
        version.Title = 'Training Flyer: ' + training.Name;
        version.PathOnClient = 'TrainingFlyer.pdf';
        version.VersionData = content;
        version.FirstPublishLocationId = trainingId;

        insert version;

        return version.Id;
    }

}