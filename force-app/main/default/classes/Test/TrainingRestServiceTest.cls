@IsTest
public with sharing class TrainingRestServiceTest {

    @TestSetup
    static void setup() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Contact contact = new Contact(LastName = 'Trainer-One');
        insert contact;

        TrainingCourse__c trainingCourse = new TrainingCourse__c(Name = 'Test Rest Resources Course');
        insert(trainingCourse);

        Training__c  training = new Training__c();
        training.Name = 'Rest Training Beginner';
        training.TrainerContact__c = contact.Id;
        training.TrainingCourse__c = trainingCourse.Id;
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addDays(1);
        training.EndDate__c = System.today().addDays(2);
        insert training;
    }

    @IsTest
    static void getTrainingById_UnitTest_TrainingId() {
        Id trainingId = getTestTrainingId();

        RestRequest request = new RestRequest();
        request.requestUri =
            'https://curious-hawk-3uzcps-dev-ed.trailblaze.my.salesforce.com/services/apexrest/Trainings/' + trainingId;
        request.httpMethod = 'GET';
        RestContext.request = request;

        Training__c training = TrainingRestService.getTrainingById();

        Assert.isNotNull(training);
        Assert.areEqual('Rest Training Beginner', training.Name);
    }

    @IsTest
    static void getTrainingById_UnitTest_UniqueId() {
        String trainingId = getTestTrainingUniqueId();

        RestRequest request = new RestRequest();
        request.requestUri =
            'https://curious-hawk-3uzcps-dev-ed.trailblaze.my.salesforce.com/services/apexrest/Trainings/' + trainingId;
        request.httpMethod = 'GET';
        RestContext.request = request;

        Training__c training = TrainingRestService.getTrainingById();

        Assert.isNotNull(training);
        Assert.areEqual('Rest Training Beginner', training.Name);
    }

    @IsTest
    static void createTraining_UnitTest() {
        Restaurant__c restaurant = [SELECT Id FROM Restaurant__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TrainingCourse__c trainingCourse = [SELECT Id FROM TrainingCourse__c LIMIT 1];

        ID trainingId = TrainingRestService.createTraining(
            'Rest Training Intermediate',
            String.valueOf(contact.Id),
            String.valueOf(trainingCourse.Id),
            String.valueOf(restaurant.Id),
            System.today(),
            System.today().addDays(1)
        );

        Assert.isNotNull(trainingId != null);

        Training__c insertedTraining = [SELECT Id, Name FROM Training__c WHERE Id = :trainingId];
        Assert.isNotNull(insertedTraining);
        Assert.areEqual('Rest Training Intermediate', insertedTraining.Name);
    }

    @IsTest
    static void createTraining_UnitTest_InvalidFields() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        try {
            ID trainingId = TrainingRestService.createTraining(
                'Rest Training Intermediate',
                String.valueOf(contact.Id),
                null,
                null,
                System.today(),
                System.today().addDays(1)
            );

            Assert.fail();
        } catch(Exception e) {
            Assert.isTrue(true);
        }
    }

    static Id getTestTrainingId() {
        Training__c training = [SELECT Id FROM Training__c LIMIT 1];

        return training.Id;
    }

    static String getTestTrainingUniqueId() {
        Training__c training = [SELECT UniqueId__c FROM Training__c LIMIT 1];

        return training.UniqueId__c;
    }

}