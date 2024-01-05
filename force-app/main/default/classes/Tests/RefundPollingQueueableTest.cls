@IsTest
private class RefundPollingQueueableTest {

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

        Contact contact = new Contact(LastName = 'Participant-One', CanBookForOthers__c = true, Email = 'e@mail.com');
        insert contact;

        Participant__c participant = new Participant__c(Contact__c = contact.Id, Training__c = training.Id);
        insert participant;

        TrainingInvoice__c invoice = new TrainingInvoice__c();
        invoice.InvoiceDate__c = System.today();
        invoice.InvoiceId__c = '657c33e3c01b55ac1cfd6f59';
        invoice.Status__c = InvoicePostProcessingQueueable.INVOICE_STATUS_CREATED;
        invoice.Participant__c = participant.Id;
        invoice.Training__c = participant.Training__c;
        insert invoice;

        TrainingRefund__c refund = new TrainingRefund__c();
        refund.TrainingInvoice__r = new TrainingInvoice__c(InvoiceId__c = invoice.InvoiceId__c );
        refund.Amount__c = 190;
        refund.Participant__c = participant.Id;
        refund.Reason__c = 'Technical Issues';
        refund.RefundDate__c = System.today();
        refund.Status__c = ParticipantService.REFUND_STATUS_PENDING;
        refund.RefundId__c = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        insert refund;
    }

    @IsTest
    static void enqueuePollingStatusRefundedFirstTry_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        RefundCallout.RefundResponseBody refundResponse = new RefundCallout.RefundResponseBody();
        refundResponse.status = ParticipantService.REFUND_RESPONSE_STATUS_INITIATED;
        refundResponse.refund_id = refundId;
        refundResponse.token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        RefundPollingQueueable.DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT = false;
        Id jobId = System.enqueueJob(new RefundPollingQueueable(refundResponse));
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.isNotNull(job);
        Assert.areEqual('RefundPollingQueueable', job.ApexClass.Name);
        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
    }

    @IsTest
    static void enqueuePollingStatusFailedFirstTry_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        RefundCallout.RefundResponseBody refundResponse = new RefundCallout.RefundResponseBody();
        refundResponse.status = ParticipantService.REFUND_RESPONSE_STATUS_INITIATED;
        refundResponse.refund_id = refundId;
        refundResponse.token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        RefundPollingQueueable.DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT = false;
        RefundCalloutHttpCalloutMock.IS_STATUS_REFUNDED = false;
        Id jobId = System.enqueueJob(new RefundPollingQueueable(refundResponse));
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.isNotNull(job);
        Assert.areEqual('RefundPollingQueueable', job.ApexClass.Name);
        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
    }

    @IsTest
    static void enqueuePollingStatusFailedThirdTry_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        RefundCallout.RefundResponseBody refundResponse = new RefundCallout.RefundResponseBody();
        refundResponse.status = ParticipantService.REFUND_RESPONSE_STATUS_INITIATED;
        refundResponse.refund_id = refundId;
        refundResponse.token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        RefundPollingQueueable.DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT = false;
        RefundPollingQueueable.SET_RETRY_COUNT_3_FOR_TEST = true;
        RefundCalloutHttpCalloutMock.IS_STATUS_REFUNDED = false;
        Id jobId = System.enqueueJob(new RefundPollingQueueable(refundResponse));
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE Id = :jobId];

        Assert.isNotNull(job);
        Assert.areEqual('RefundPollingQueueable', job.ApexClass.Name);
        Assert.areEqual('Completed', job.Status);
        Assert.areEqual('Queueable', job.JobType);
    }

    @IsTest
    static void enqueuePollingStatusException_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        RefundCallout.RefundResponseBody refundResponse = new RefundCallout.RefundResponseBody();
        refundResponse.status = ParticipantService.REFUND_RESPONSE_STATUS_INITIATED;
        refundResponse.refund_id = refundId;
        refundResponse.token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        Id jobId = System.enqueueJob(new RefundPollingQueueable(refundResponse));
        Test.stopTest();

        TrainingRefund__c updatedRefund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        Assert.isNotNull(updatedRefund);
        Assert.areEqual(RefundPostProcessingQueueable.REFUND_STATUS_FAILED, updatedRefund.Status__c);

        List<ErrorLog__c> errorLogs = [
            SELECT Id, ClassName__c, MethodName__c, ExceptionMessage__c 
            FROM ErrorLog__c 
            WHERE ClassName__c = 'RefundPollingQueueable'
        ];

        Assert.isNotNull(errorLogs);
        Assert.areEqual(1, errorLogs.size());

        ErrorLog__c resultLog = errorLogs.get(0);
        Assert.isTrue(resultLog.MethodName__c.contains('execute'));
    }

}