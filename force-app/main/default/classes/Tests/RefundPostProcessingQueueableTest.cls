@IsTest
public class RefundPostProcessingQueueableTest {

    @TestSetup
    static void setup() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);
        insert training;

        Contact contact1 = new Contact(LastName = 'Participant-One', CanBookForOthers__c = true, Email = 'e@mail.com');
        Contact contact2 = new Contact(LastName = 'Participant-Two', CanBookForOthers__c = false, Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        Participant__c participant1 = new Participant__c(Contact__c = contact1.Id, Training__c = training.Id);
        Participant__c participant2 = new Participant__c(Contact__c = contact2.Id, Training__c = training.Id);
        List<Participant__c> participants = new List<Participant__c> {participant1, participant2};
        insert participants;

        TrainingInvoice__c invoice = new TrainingInvoice__c();
        invoice.InvoiceDate__c = System.today();
        invoice.InvoiceId__c = '657c33e3c01b55ac1cfd6f59';
        invoice.Status__c = InvoicePostProcessingQueueable.INVOICE_STATUS_CREATED;
        invoice.Participant__c = participant1.Id;
        invoice.Training__c = participant1.Training__c;
        insert invoice;

        TrainingRefund__c refund = new TrainingRefund__c();
        refund.TrainingInvoice__r = new TrainingInvoice__c(InvoiceId__c = invoice.InvoiceId__c );
        refund.Amount__c = 190;
        refund.Participant__c = participant1.Id;
        refund.Reason__c = 'Technical Issues';
        refund.RefundDate__c = System.today();
        refund.Status__c = ParticipantService.REFUND_STATUS_PENDING;
        refund.RefundId__c = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        insert refund;
    }

    @IsTest
    static void enqueuePostProcessingRefundStatusRefunded_UnitTest() {
        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);
        String refundedStatus = RefundPostProcessingQueueable.REFUND_STATUS_REFUNDED;
        String token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;
        String invoiceId = refund.TrainingInvoice__r.InvoiceId__c;

        Test.startTest();
        Id jobId = System.enqueueJob(new RefundPostProcessingQueueable(refund, refundedStatus, token));
        Test.stopTest();
    
        TrainingInvoice__c updatedInvoice = TrainingInvoiceQueries.queryInvoiceByInvoiceId(invoiceId);

        Assert.isNotNull(updatedInvoice);
        Assert.areEqual(refundedStatus, updatedInvoice.Status__c);

        TrainingRefund__c updatedRefund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        Assert.isNotNull(updatedRefund);
        Assert.areEqual(refundedStatus, updatedRefund.Status__c);
    }

    @IsTest
    static void enqueuePostProcessingRefundStatusFailed_UnitTest() {
        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);
        String failedStatus = RefundPostProcessingQueueable.REFUND_STATUS_FAILED;
        String token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;
        String invoiceId = refund.TrainingInvoice__r.InvoiceId__c;

        Test.startTest();
        Id jobId = System.enqueueJob(new RefundPostProcessingQueueable(refund, failedStatus, token));
        Test.stopTest();

        TrainingRefund__c updatedRefund = TrainingRefundQueries.queryRefundByRefundId(refundId);
        
        Assert.isNotNull(updatedRefund);
        Assert.areEqual(failedStatus, updatedRefund.Status__c);

        List<ErrorLog__c> errorLogs = [
            SELECT Id, ClassName__c, ExceptionMessage__c 
            FROM ErrorLog__c 
            WHERE ExceptionType__c = 'Refund Order Failed'
        ];

        Assert.isNotNull(errorLogs);
        Assert.areEqual(1, errorLogs.size());

        ErrorLog__c resultLog = errorLogs.get(0);
        Assert.isTrue(resultLog.ExceptionMessage__c.contains(refund.Name));
        Assert.areEqual('RefundPostProcessingQueueable', resultLog.ClassName__c);
    }

}