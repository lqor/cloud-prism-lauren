@isTest
public class InvoicePostProcessingQueueableTest {

    @TestSetup
    static void setup() {
        Contact contact1 = new Contact(FirstName = 'Trainer', LastName = 'Name', Email = 'e@mail.com');
        Contact contact2 = new Contact(FirstName = 'Participant', LastName = 'Name', Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        TrainingCourse__c course =  new TrainingCourse__c(Name = 'Queueable Apex');
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

    @isTest
    static void queueableCreated_UnitTest() {
        Participant__c participant = [SELECT Id, Training__c, Contact__c FROM Participant__c];

        String requestBody = '{"invoice_id": "657c33e3c01b55ac1cfd6f59", ' +
            '"participant_id": "' + participant.Id + '", "payment_id": "THRiS7dVr5XUD8DoVmLEse", ' + 
            '"payment_link": "https://leaflix-2-3e22d4a85a3a.herokuapp.com/payment/THRiS7dVr5XUD8DoVmLEse", ' + 
            '"status": "Created", "item_name": null, "description": null, "price": 290.0, "tax": 55.1, ' + 
            '"token": "XwFYzccwndV4sY7", "callback_url": null, "session_id": null}';
        InvoiceRestService.InvoiceRequestBody parsedInvoice = InvoiceRestService.parseInvoice(requestBody);

        Test.startTest();
        Id jobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        Test.stopTest();

        Assert.isNotNull(jobId);
        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
        Assert.areEqual('InvoicePostProcessingQueueable', job.ApexClass.Name);
    }

    @isTest
    static void queueablePaid_UnitTest() {
        Participant__c participant = [SELECT Id, Training__c, Contact__c FROM Participant__c];

        TrainingInvoice__c invoice = new TrainingInvoice__c();
        invoice.InvoiceDate__c = System.today();
        invoice.InvoiceId__c = '657c33e3c01b55ac1cfd6f59';
        invoice.Participant__c = participant.Id;
        invoice.Training__c = participant.Training__c;
        insert invoice;

        String requestBody = '{"invoice_id": "657c33e3c01b55ac1cfd6f59", "status": "Paid"}';
        InvoiceRestService.InvoiceRequestBody parsedInvoice = InvoiceRestService.parseInvoice(requestBody);

        Test.startTest();
        Id jobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        Test.stopTest();

        Assert.isNotNull(jobId);
        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
        Assert.areEqual('InvoicePostProcessingQueueable', job.ApexClass.Name);
    }

}