@IsTest
public with sharing class TrainingServiceTest {

    @TestSetup
    static void setup() {}

    @IsTest
    static void beforeInsertTrigger_UnitTest() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;
        
        Contact contact = new Contact(LastName = 'Trainer-One');
        insert contact;

        TrainingCourse__c trainingCourse = new TrainingCourse__c(Name = 'Test Trigger Training');
        insert(trainingCourse);

        List<Training__c> trainings = new List<Training__c>();
        for(Integer i = 1; i <= 5; i++) {
            Training__c training = new Training__c();

            training.Name = 'Test Trigger Training ' + i;
            training.Restaurant__c = restaurant.Id;
            training.StartDate__c = System.today().addMonths(1);
            training.EndDate__c = System.today().addMonths(1);
            training.TrainerContact__c = contact.Id;
            training.TrainingCourse__c = trainingCourse.Id;

            trainings.add(training);
        }

        Test.startTest();
        insert trainings;
        Test.stopTest();

        List<Training__c> trainingsInserted = [
            SELECT Id, RestaurantCommission__c 
            FROM Training__c 
            WHERE Id IN :trainings
        ];

        Assert.areEqual(trainings.size(), trainingsInserted.size());
        for(Training__c result : trainingsInserted) {
            Assert.areEqual(6.60, result.RestaurantCommission__c);
        }
    }

    @IsTest
    static void beforeInsertTrigger_lazy() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training ';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);

        Test.startTest();
        insert training;
        Test.stopTest();

        Training__c result = [
            SELECT Id, RestaurantCommission__c 
            FROM Training__c 
            WHERE Id = :training.Id
            LIMIT 1
        ];

        Assert.areEqual(6.60, result.RestaurantCommission__c);
    }

    @IsTest
    static void setRestaurantCommissionOnTrainings_UnitTest() {
    }

    @IsTest
    static void updateCompletedTrainings_UnitTest() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training ';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        training.Status__c = TrainingService.TRAINING_STATUS_SCHEDULED;
        insert training;

        List<Training__c> trainings = new List<Training__c> {training};
        Map<Id, Training__c> oldMap = new Map<Id, Training__c>(trainings.deepClone(true));

        TrainingService service = new TrainingService();
        trainings.get(0).Status__c = TrainingService.TRAINING_STATUS_FINISHED;
        update training;

        Test.startTest();
        service.updateCompletedTrainings(trainings, oldMap);
        Test.stopTest();

        Training__c trainingUpdated = trainings.get(0);
        Training__c result = [
            SELECT Name, Id, Status__c, CompletionDate__c 
            FROM Training__c 
            WHERE Id = :trainingUpdated.Id
            LIMIT 1
        ];

        Assert.areEqual(System.today(), result.CompletionDate__c);
        Assert.areEqual(TrainingService.TRAINING_STATUS_FINISHED, result.Status__c);
    }

    @IsTest
    static void insertTasksForTrainings_lazy() {
        Restaurant__c restaurant1 = new Restaurant__c();
        restaurant1.Name = 'Tam O\'Shanter';
        restaurant1.CommissionRate__c = 15;
        restaurant1.AverageMealCost__c = 55;
        insert restaurant1;

        Training__c training = new Training__c();
        training.Name = 'UniqueName Training';
        training.Restaurant__c = restaurant1.Id;
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        List<Training__c> trainings = new List<Training__c> {training};

        TrainingService service = new TrainingService();
        Test.startTest();
        service.insertTasksForTrainings(trainings, null);
        Test.stopTest();

        String subject = 'Reminder: ' + training.Name;
        List<Task> tasksInserted = [SELECT ActivityDate, Status FROM Task WHERE Subject = :subject];
        Assert.areEqual(trainings.size(), tasksInserted.size());

        Task result = tasksInserted.get(0);
        Assert.areEqual(System.today(), result.ActivityDate);
        Assert.areEqual(TrainingService.TASK_STATUS_NOT_STARTED, result.Status);
    }

}