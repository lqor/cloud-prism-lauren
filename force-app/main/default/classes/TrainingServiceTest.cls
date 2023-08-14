@IsTest
public with sharing class TrainingServiceTest {

    @TestSetup
    static void setup() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Contact contact = new Contact(LastName = 'Trainer-One');
        insert contact;

        TrainingCourse__c trainingCourse = new TrainingCourse__c(Name = 'Test Trigger Course');
        insert(trainingCourse);
    }

    @IsTest
    static void beforeInsertTrigger_UnitTest() {
        Restaurant__c restaurant = [SELECT Id FROM Restaurant__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TrainingCourse__c trainingCourse = [SELECT Id FROM TrainingCourse__c LIMIT 1];

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

        List<Training__c> trainingsInserted = [SELECT Id, RestaurantCommission__c FROM Training__c WHERE Id IN :trainings];

        Assert.areEqual(trainings.size(), trainingsInserted.size());
        for(Training__c result : trainingsInserted) {
            Assert.areEqual(6.60, result.RestaurantCommission__c);
        }
    }

    @IsTest
    static void beforeInsertTrigger_lazy() {
        Restaurant__c restaurant = [SELECT Id FROM Restaurant__c LIMIT 1];

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);

        Test.startTest();
        insert training;
        Test.stopTest();

        Training__c result = [SELECT Id, RestaurantCommission__c FROM Training__c WHERE Id = :training.Id LIMIT 1];

        Assert.areEqual(6.60, result.RestaurantCommission__c);
    }

    @IsTest
    static void setRestaurantCommissionOnTrainings_UnitTest() {
        Restaurant__c restaurant = [SELECT Id, CommissionRate__c, AverageMealCost__c FROM Restaurant__c LIMIT 1];

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        List<Training__c> trainings = new List<Training__c> {training};

        RestaurantCommissionMetadata__mdt restaurantCommissionMdt = TrainingQueries.queryRestaurantCommissionMetadata();

        Integer numberOfParticipants = training.Participants__r.isEmpty() ? 1 : training.Participants__r.size();
        Integer numberOfDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal probabilityToBuy = restaurantCommissionMdt.ProbabilityToBuyPerParticipant__c / 100;
        Decimal commissionRate = restaurant.CommissionRate__c / 100;
        Decimal averageMealCost = restaurant.AverageMealCost__c;

        Decimal expectedRestaurantCommission = numberOfParticipants * 
                                               numberOfDays * 
                                               commissionRate * 
                                               probabilityToBuy * 
                                               averageMealCost;

        TrainingService service = new TrainingService();
        Test.startTest();
        service.setRestaurantCommissionOnTrainings(trainings, null);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedRestaurantCommission, result.RestaurantCommission__c);
    }

    @IsTest
    static void updateRestaurantCommissionOnTrainings_UnitTest() {
        Restaurant__c restaurant = [SELECT Id, CommissionRate__c, AverageMealCost__c FROM Restaurant__c LIMIT 1];

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        insert training;

        List<Training__c> trainings = new List<Training__c> {training};
        Map<Id, Training__c> oldMap = new Map<Id, Training__c>(trainings.deepClone(true));

        trainings.get(0).EndDate__c = System.today().addDays(3);
        update training;

        RestaurantCommissionMetadata__mdt restaurantCommissionMdt = TrainingQueries.queryRestaurantCommissionMetadata();

        Integer numberOfParticipants = training.Participants__r.isEmpty() ? 1 : training.Participants__r.size();
        Integer numberOfDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal probabilityToBuy = restaurantCommissionMdt.ProbabilityToBuyPerParticipant__c / 100;
        Decimal commissionRate = restaurant.CommissionRate__c / 100;
        Decimal averageMealCost = restaurant.AverageMealCost__c;

        Decimal expectedRestaurantCommission = numberOfParticipants * 
                                               numberOfDays * 
                                               commissionRate * 
                                               probabilityToBuy * 
                                               averageMealCost;

        TrainingService service = new TrainingService();
        Test.startTest();
        service.setRestaurantCommissionOnTrainings(trainings, null);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedRestaurantCommission, result.RestaurantCommission__c);
    }

    @IsTest
    static void setTrainingDurationOnTrainings_UnitTest() {
        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.StartDate__c = System.today();
        training.EndDate__c = System.today().addDays(1);
        List<Training__c> trainings = new List<Training__c> {training};

        TrainingDurationMetadata__mdt trainingDurationMdt = TrainingQueries.queryTrainingDurationMetadata();

        Integer numberOfDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal trainingHoursPerDay = trainingDurationMdt.TrainingHoursPerDay__c;
        Decimal preparationTime = trainingDurationMdt.PreparationTime__c;
        Decimal reviewTime = trainingDurationMdt.ReviewTime__c;

        Integer expectedTrainingDuration = numberOfDays * 
                                           (Integer) trainingHoursPerDay + 
                                           (Integer) preparationTime + 
                                           (Integer) reviewTime;

        TrainingService service = new TrainingService();
        Test.startTest();
        service.setTrainingDurationOnTrainings(trainings, null);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedTrainingDuration, result.TrainingDuration__c);
    }

    @IsTest
    static void setUniqueIdOnTrainings_UnitTest() {
        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training ';
        training.StartDate__c = System.today().addmonths(3).addDays(-15);
        training.EndDate__c = System.today().addmonths(3);
        List<Training__c> trainings = new List<Training__c> {training};

        String pad0 = '0';
        String startDay = String.valueOf(training.StartDate__c.day()).length() == 1 ? 
                          String.valueOf(training.StartDate__c.day()).leftPad(2, pad0) : 
                          String.valueOf(training.StartDate__c.day());
        String startMonth = String.valueOf(training.StartDate__c.month()).length() == 1 ?
                            String.valueOf(training.StartDate__c.month()).leftPad(2, pad0) :
                            String.valueOf(training.StartDate__c.month());
        String startYear = String.valueOf(training.StartDate__c.year()).right(2);
        String startDate = startDay + startMonth + startYear;

        String nameInitials = '';
        List<String> nameParts = training.Name.toUpperCase().split(' ');
        for(String name : nameParts) {
            nameInitials += name.left(1);
        }
        String expectedUniqueId = nameInitials + startDate;

        TrainingService service = new TrainingService();
        Test.startTest();
        service.setUniqueIdOnTrainings(trainings, null);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedUniqueId, result.UniqueId__c);
    }

    @IsTest
    static void updateCompletedTrainings_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());
        
        Restaurant__c restaurant = [SELECT Id FROM Restaurant__c LIMIT 1];

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        training.Status__c = TrainingService.TRAINING_STATUS_SCHEDULED;
        insert training;

        Contact contact = new Contact(LastName = 'Participant-One', Email = 'e@mail.com');
        insert contact;

        Participant__c participant = new Participant__c();
        participant.Contact__c = contact.Id;
        participant.Status__c = ParticipantService.PARTICIPANT_STATUS_ACTIVE;
        participant.Training__c = training.Id;
        insert participant;

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
        Restaurant__c restaurant = [SELECT Id FROM Restaurant__c LIMIT 1];

        Training__c training = new Training__c();
        training.Name = 'UniqueName Training';
        training.Restaurant__c = restaurant.Id;
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