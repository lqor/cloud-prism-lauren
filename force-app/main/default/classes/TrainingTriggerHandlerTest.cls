@IsTest
public with sharing class TrainingTriggerHandlerTest {

    @TestSetup
    static void setup() {
        TrainingCourse__c trainingCourse = new TrainingCourse__c(Name = 'Test Trigger Training');
        insert(trainingCourse);

        Restaurant__c restaurant1 = new Restaurant__c();
        Restaurant__c restaurant2 = new Restaurant__c();

        restaurant1.Name = 'Tam O\'Shanter';
        restaurant1.CommissionRate__c = 15;
        restaurant1.AverageMealCost__c = 55;

        restaurant2.Name = 'The Apple Pan';
        restaurant2.CommissionRate__c = 20;
        restaurant2.AverageMealCost__c = 30;

        insert new List<Restaurant__c> {restaurant1, restaurant2};

        Contact contact1 = new Contact(LastName = 'Trainer-One');
        Contact contact2 = new Contact(LastName = 'Trainer-Two');
        insert new List<Contact> {contact1, contact2};

        Training__c training1 = new Training__c();
        Training__c training2 = new Training__c();
        Training__c training3 = new Training__c();
        Training__c training4 = new Training__c();
        Training__c training5 = new Training__c();
        
        training1.Name = 'Brand New Training One';
        training1.Restaurant__c = restaurant1.Id;
        training1.StartDate__c = System.today();
        training1.EndDate__c = System.today();
        training1.TrainerContact__c = contact1.Id;
        training1.TrainingCourse__c = trainingCourse.Id;

        training2.Name = 'Brand New Training Two';
        training2.Restaurant__c = restaurant1.Id;
        training2.StartDate__c = System.today();
        training2.EndDate__c = System.today().addDays(9);
        training2.TrainerContact__c = contact1.Id;
        training2.TrainingCourse__c = trainingCourse.Id;
        
        training3.Name = 'Brand New Training Three';
        training3.Restaurant__c = restaurant1.Id;
        training3.StartDate__c = System.today().addMonths(1);
        training3.EndDate__c = System.today().addMonths(1);
        training3.TrainerContact__c = contact1.Id;
        training3.TrainingCourse__c = trainingCourse.Id;

        training4.Name = 'Chocolate Training Four';
        training4.Restaurant__c = restaurant2.Id;
        training4.StartDate__c = System.today();
        training4.EndDate__c = System.today();
        training4.TrainerContact__c = contact1.Id;
        training4.TrainingCourse__c = trainingCourse.Id;

        training5.Name = 'Chocolate Training Five';
        training5.Restaurant__c = restaurant2.Id;
        training5.StartDate__c = System.today();
        training5.EndDate__c = System.today();
        training5.TrainerContact__c = contact1.Id;
        training5.TrainingCourse__c = trainingCourse.Id;

        insert new List<Training__c>{training1, training2, training3, training4, training5};
    }

    @IsTest
    static void beforeInsertTrigger_UnitTest() {
        List<Training__c> trainings = new List<Training__c>();

        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Restaurant__c restaurant = [SELECT Id, Name FROM Restaurant__c WHERE Name LIKE 'Tam%'];
        trainingCourse__c trainingCourse = [SELECT Id, Name FROM trainingCourse__c WHERE Name = 'Test Trigger Training'];


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

        List<Training__c> trainingsInserted; // = [
        //     SELECT Id, RestaurantCommissionForecast__c 
        //     FROM Training__c 
        //     WHERE Id IN :trainings
        // ];

        Assert.areEqual(trainings.size(), trainingsInserted.size());
        for(Training__c training : trainingsInserted) {
            // Assert.areEqual(6.60, training.RestaurantCommissionForecast__c);
        }
    }

    @IsTest
    static void beforeInsertTrigger_lazy() {
        Restaurant__c restaurant1 = new Restaurant__c();
        restaurant1.Name = 'Tam O\'Shanter';
        restaurant1.CommissionRate__c = 15;
        restaurant1.AverageMealCost__c = 55;
        insert restaurant1;

        Training__c training = new Training__c(Restaurant__c = restaurant1.Id);

        Test.startTest();
        insert training;
        Test.stopTest();

        // Training__c result = [
        //     SELECT Id, RestaurantCommissionForecast__c 
        //     FROM Training__c 
        //     WHERE Id = :training.Id
        //     LIMIT 1
        // ];

        // Assert.areEqual(6.60, result.RestaurantCommissionForecast__c);
    }

    static void insertTasksForTrainings_lazy() {
        List<Training__c> newList = new List<Training__c> {new Training__c(Name = 'uniqueName')};
        String subject = '';
        insert newList;
        TrainingService trainingService = new TrainingService();
        Test.startTest();
        trainingService.insertTasksForTrainings(newList, null);
        Test.stopTest();

        List<Task> tasks = [SELECT ActivityDate, Status FROM Task WHERE Subject = :subject];
        Assert.areEqual(1, tasks.size());

        Task task = tasks.get(0);
        Assert.areEqual(System.today(), task.ActivityDate);
        Assert.areEqual('Not started', task.Status);
    }

    @IsTest
    static void afterInsertTrigger_UnitTest() {
        List<Training__c> trainings = new List<Training__c>();

        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Restaurant__c restaurant = [SELECT Id, Name FROM Restaurant__c WHERE Name LIKE 'The%'];
        trainingCourse__c trainingCourse = [SELECT Id, Name FROM trainingCourse__c WHERE Name = 'Test Trigger Training'];

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

        insert trainings;

        Test.startTest();
        TrainingTriggerHandler.afterInsert(trainings, null);
        Test.stopTest();

        // List<Task> tasksInserted = [
        //     SELECT Id, RestaurantCommissionForecast__c  
        //     FROM Task 
        //     WHERE Subject IN :trainings.Name
        // ];

        // Assert.areEqual(trainings.size(), trainingsInserted.size());
        // Assert.areEqual(6.60, trainingsInserted.get(0).RestaurantCommissionForecast__c);
    }
}