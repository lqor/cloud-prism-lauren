@RestResource(UrlMapping='/Trainings/*')
global with sharing class TrainingRestService implements SObjectServiceInterface {

    public virtual class TrainingRestServiceException extends Exception {}
    public class InvalidTrainingRecordDataException extends TrainingRestServiceException {}

    @HttpGet
    global static Training__c getTrainingById() {
        RestRequest request = RestContext.request;

        String trainingId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        String escapedTrainingId = String.escapeSingleQuotes(trainingId);
 
        String querySelect = 'SELECT Name, TrainingDuration__c, Status__c, TrainerContact__r.FirstName, ' + 
            'TrainerContact__r.LastName, StartDate__c, EndDate__c, NumberOfParticipants__c ';
        String queryFrom = 'FROM Training__c ';
        String queryWhere = '';

        if(trainingId.length() >= 18) {
            queryWhere = 'WHERE Id = :escapedTrainingId';
        } else {
            queryWhere = 'WHERE UniqueId__c = :escapedTrainingId';
        }

        String query = querySelect + queryFrom + queryWhere;

        return Database.query(query);
    }

    @HttpPost
    global static ID createTraining(
        String name, 
        String trainerContact, 
        String trainingCourse, 
        String restaurant, 
        Datetime startDate, 
        Datetime endDate
    ) {
        Training__c training = new Training__c();

        training.Name = name;
        training.TrainerContact__c = trainerContact;
        training.TrainingCourse__c = trainingCourse;
        training.Restaurant__c = restaurant;
        training.StartDate__c = startDate;
        training.EndDate__c = endDate;

        if(!validateObject(training)) {
            throw new InvalidTrainingRecordDataException();
        }

        formatRecord(training);
        insert training;
    
        return training.Id;
    }

    public static Boolean validateObject(SObject record) {
        if(record == null || !(record instanceof Training__c)) {
            return false;
        }

        return ((Training__c) record).Name != null && 
            ((Training__c) record).TrainerContact__c != null && 
            ((Training__c) record).TrainingCourse__c != null && 
            ((Training__c) record).Restaurant__c != null && 
            ((Training__c) record).StartDate__c != null && 
            ((Training__c) record).EndDate__c != null;
    }

    public static void formatRecord(SObject record) {
        if(record instanceof Training__c) {
            Training__c training = (Training__c) record;

            List<String> splitNames = training.Name.split(' ');
            String formattedName = '';

            for(String name : splitNames) {
                if(name != '') {
                    formattedName += name.trim().capitalize() + ' ';
                }
            }

            training.Name = formattedName.trim();
        }
    }

}