@IsTest
public class InvoiceCalloutTest {

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
        training.TotalPrice__c = 120.0;
        training.TotalTax__c = 22.80;
        insert training;

        Participant__c participant = new Participant__c();
        participant.Contact__c = contact2.Id;
        participant.Status__c = ParticipantService.PARTICIPANT_STATUS_IN_QUEUE;
        participant.Training__c = training.Id;
        insert participant;
    }

    @IsTest
    static void doAuthenticationCalloutForPayment_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new InvoiceCalloutHttpCalloutMock());

        Test.startTest();
        String responseToken = InvoiceCallout.doAuthenticationCalloutForPayment();
        Test.stopTest();

        Assert.areEqual(InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN, responseToken);
    }

    @IsTest
    static void doInvoiceCalloutForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new InvoiceCalloutHttpCalloutMock());

        Training__c training = [SELECT Id, TotalPrice__c, TotalTax__c FROM Training__c LIMIT 1];
        Participant__c participant = [SELECT Id FROM Participant__c LIMIT 1];

        Test.startTest();
        String responseMessage = InvoiceCallout.doInvoiceCalloutForParticipant(participant, training);
        Test.stopTest();

        Assert.isTrue(responseMessage.contains(InvoiceCalloutHttpCalloutMock.INVOICE_RESPONSE_MESSAGE));
        Assert.isTrue(responseMessage.contains('message'));
    }

}