@IsTest
public class RegistrationConfirmationQueueableTest {

    @TestSetup
    static void setup() {
        Contact contact1 = new Contact(FirstName = 'Trainer', LastName = 'Name', Email = 'e@mail.com');
        Contact contact2 = new Contact(FirstName = 'Participant', LastName = 'Name', Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        TrainingCourse__c course = new TrainingCourse__c(Name = 'Queueable Apex');
        insert course;

        Training__c training = new Training__c();
        training.Name = 'Queueable Training';
        training.TrainerContact__c = contact1.Id;
        training.TrainingCourse__c = course.Id;
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
    static void queueable_UnitTest() {
        Participant__c participant = [SELECT Id, Training__c, Contact__c FROM Participant__c];

        Set<Id> trainingIds = new Set<Id>();
        trainingIds.add(participant.Training__c);

        Set<Id> participantIds = new Set<Id>();
        participantIds.add(participant.Contact__c);

        List<Training__c> trainings = TrainingQueries.queryTrainingsForNewParticipantsByParticipantIds(participantIds);

        Test.startTest();
        Id jobId = System.enqueueJob(new RegistrationConfirmationQueueable(trainings));
        Test.stopTest();

        Assert.isNotNull(jobId);
        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
        Assert.areEqual('RegistrationConfirmationQueueable', job.ApexClass.Name);
    }

}