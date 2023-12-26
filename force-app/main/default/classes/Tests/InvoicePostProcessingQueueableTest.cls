@IsTest
public class InvoicePostProcessingQueueableTest {

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
        training.TotalPrice__c = 120.00;
        training.TotalTax__c = 22.80;
        insert training;

        Participant__c participant = new Participant__c();
        participant.Contact__c = contact2.Id;
        participant.Status__c = ParticipantService.PARTICIPANT_STATUS_ACTIVE;
        participant.Training__c = training.Id;
        insert participant;
    }

    @IsTest
    static void queueableInvoiceCreatedStatus_UnitTest() {
        Participant__c participant = [SELECT Id FROM Participant__c LIMIT 1];

        String requestBody = '{' +
            '"invoice_id": "657c33e3c01b55ac1cfd6f59", ' +
            '"participant_id": "' + participant.Id + '", ' +
            '"payment_id": "RiS7dDoVmLEse", ' +
            '"payment_link": "https://paymentlink.com/RiS7dDoVmLEse", ' +
            '"status": "Created", ' +
            '"item_name": null, ' +
            '"description": null, ' +
            '"price": 120.00, ' +
            '"tax": 22.80, ' +
            '"token": "XwFYzccwndV4sY7", ' +
            '"callback_url": null, ' +
            '"session_id": null' +
        '}';
        InvoiceRestService.InvoiceRequestBody parsedInvoice = InvoiceRestService.parseInvoice(requestBody);

        Test.startTest();
        Id jobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        Test.stopTest();

        List<TrainingInvoice__c> invoices = [SELECT Id, InvoiceDate__c, PaymentLink__c, Status__c FROM TrainingInvoice__c];
        Assert.areNotEqual(null, invoices);
        Assert.areEqual(1, invoices.size());

        Assert.areEqual(System.today(), invoices[0].InvoiceDate__c);
        Assert.areEqual('https://paymentlink.com/RiS7dDoVmLEse', invoices[0].PaymentLink__c);
        Assert.areEqual(InvoicePostProcessingQueueable.INVOICE_STATUS_CREATED, invoices[0].Status__c);
    }

    @IsTest
    static void queueableInvoicePaidStatus_UnitTest() {
        Participant__c participant = [SELECT Id, Training__c, Contact__c FROM Participant__c];

        TrainingInvoice__c invoice = new TrainingInvoice__c();
        invoice.InvoiceDate__c = System.today();
        invoice.InvoiceId__c = '657c33e3c01b55ac1cfd6f59';
        invoice.Status__c = InvoicePostProcessingQueueable.INVOICE_STATUS_CREATED;
        invoice.Participant__c = participant.Id;
        invoice.Training__c = participant.Training__c;
        insert invoice;

        String requestBody = '{"invoice_id": "657c33e3c01b55ac1cfd6f59", "status": "Paid"}';
        InvoiceRestService.InvoiceRequestBody parsedInvoice = InvoiceRestService.parseInvoice(requestBody);

        Test.startTest();
        Id jobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        Test.stopTest();

        List<TrainingInvoice__c> invoices = [SELECT Id, PaymentDate__c, Status__c FROM TrainingInvoice__c];
        Assert.areNotEqual(null, invoices);
        Assert.areEqual(1, invoices.size());

        Assert.areEqual(System.today(), invoices[0].PaymentDate__c);
        Assert.areEqual(InvoicePostProcessingQueueable.INVOICE_STATUS_PAID, invoices[0].Status__c);
    }

}