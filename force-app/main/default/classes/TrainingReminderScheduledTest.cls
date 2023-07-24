@IsTest
public with sharing class TrainingReminderScheduledTest {

    @TestSetup
    static void setup() {
        Contact contact1 = new Contact(FirstName = 'Trainer', LastName = 'Name', Email = 'test@test.com');
        Contact contact2 = new Contact(FirstName = 'Participant', LastName = 'Name', Email = 'test@test.com');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        Training__c training = new Training__c();
        training.Name = 'Scheduled Training';
        training.TrainerContact__c = contact1.Id;
        training.StartDate__c = System.now().addDays(3);
        training.EndDate__c = System.now().addDays(3);
        training.Status__c = 'Scheduled';
        insert training;

        Participant__c participant = new Participant__c();
        participant.Contact__c = contact2.Id;
        participant.Status__c = ParticipantService.PARTICIPANT_STATUS_ACTIVE;
        participant.Training__c = training.Id;
        insert participant;
    }

    @IsTest
    static void execute_UnitTest() {
        Date threeDaysFromToday = System.today().addDays(3);

        Training__c training = [ 
            SELECT Id,
                   Name,
                   StartDate__c,
                   EndDate__c,
                   TrainerContact__r.FirstName,
                   TrainerContact__r.LastName,
                   TrainerContact__r.Email,
                   (SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email FROM Participants__r)
            FROM Training__c
            WHERE Id IN (SELECT Training__c FROM Participant__c) AND
                  DAY_ONLY(convertTimezone(StartDate__c)) = :threeDaysFromToday AND
                  Status__c = :TrainingService.TRAINING_STATUS_SCHEDULED 
            LIMIT 1
        ];
    
        TrainingReminderScheduled reminder = new TrainingReminderScheduled();
        Test.startTest();
        reminder.execute(null);
        Test.stopTest();

        // Assert.areEqual(expected, actual);
    }

    @IsTest
    static void scheduler_UnitTest() {
        TrainingReminderScheduled reminder = new TrainingReminderScheduled();
        String cronExpression = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('Training Reminder Emails', cronExpression, reminder);
        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        Assert.areEqual(cronExpression, cronTrigger.CronExpression);
        Assert.areEqual(0, cronTrigger.TimesTriggered);
        Test.stopTest();
    }
}