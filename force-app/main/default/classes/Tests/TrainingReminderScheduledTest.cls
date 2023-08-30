@IsTest
public class TrainingReminderScheduledTest {

    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());
        
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
        TrainingReminderScheduled reminder = new TrainingReminderScheduled();
        Test.startTest();
        reminder.execute(null);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.isTrue(invocations > 0);
    }

    @IsTest
    static void scheduler_UnitTest() {
        TrainingReminderScheduled reminder = new TrainingReminderScheduled();
        String cronExpression = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('Training Reminder Emails', cronExpression, reminder);
        Test.stopTest();

        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        Assert.areEqual(cronExpression, cronTrigger.CronExpression);
        Assert.areEqual(0, cronTrigger.TimesTriggered);
    }

    @IsTest
    static void queryTrainingsWithParticipantsByIdAndDate_UnitTest() {
        Integer daysToAdd = 3;
        Integer expectedSize = 1;

        Training__c training = new Training__c();
        training.Name = 'Unqualified Training';
        training.StartDate__c = System.now().addDays(daysToAdd * (-1));
        training.EndDate__c = System.today().addDays(daysToAdd * (-1));
        insert training;

        Date inThreeDays = System.today().addDays(daysToAdd);
        Test.startTest();
        List<Training__c> trainings = TrainingQueries.queryTrainingsWithParticipantsByIdAndDate(inThreeDays);
        Test.stopTest();

        Assert.areEqual(expectedSize, trainings.size());
        Assert.areNotEqual(training.Name, trainings.get(0).Name);
    }

}