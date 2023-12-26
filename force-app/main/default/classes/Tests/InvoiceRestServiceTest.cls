@IsTest
public class InvoiceRestServiceTest {

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
    static void doStartInvoiceProcessing_UnitTest() {
        Participant__c participant = [SELECT Id FROM Participant__c LIMIT 1];

        RestRequest request = new RestRequest();

        request.requestURI = '/services/apexrest/invoices/';
        request.httpMethod = 'POST';

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
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;

        Test.startTest();
        InvoiceRestService.doStartInvoiceProcessing();
        Test.stopTest();

        AsyncApexJob job = [
            SELECT Id, Status, JobType, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'InvoicePostProcessingQueueable'
        ];

        Assert.areEqual('Queueable', job.JobType);
        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('InvoicePostProcessingQueueable', job.ApexClass.Name);
    }

}