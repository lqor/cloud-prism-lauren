@IsTest
private class RefundOrderControllerTest {

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
    }

    @IsTest
    static void submitRefundForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        Participant__c participant = [SELECT Id, Training__c, Contact__c FROM Participant__c LIMIT 1];

        TrainingInvoice__c invoice = new TrainingInvoice__c();
        invoice.InvoiceDate__c = System.today();
        invoice.InvoiceId__c = '657c33e3c01b55ac1cfd6f59';
        invoice.Status__c = InvoicePostProcessingQueueable.INVOICE_STATUS_CREATED;
        invoice.Participant__c = participant.Id;
        invoice.Training__c = participant.Training__c;
        insert invoice;

        Id participantId = participant.Id;
        String reason = 'Billing Error';

        Test.startTest();
        String invoiceName = RefundOrderController.submitRefundForParticipant(participantId, reason);
        Test.stopTest();

        Assert.isNotNull(invoiceName);

        List<TrainingRefund__c> refunds = [SELECT Status__c, RefundId__c FROM TrainingRefund__c];

        Assert.isNotNull(refunds);
        Assert.areEqual(1, refunds.size());

        TrainingRefund__c refund = refunds.get(0);
        Assert.areEqual(RefundPostProcessingQueueable.REFUND_STATUS_FAILED, refund.Status__c);
        Assert.isNotNull(refund.RefundId__c);
    }

    @IsTest
    public static void submitRefundForParticipantNullId_UnitTest() {
        Id participantId = null;
        String reason = 'Billing Error';

        try {
            Test.startTest();
            RefundOrderController.submitRefundForParticipant(participantId, reason);
            Test.stopTest();

            Assert.fail();
        } catch (RefundOrderController.NullParticipantIdException e) {
            Assert.isTrue(true);
        }
    }

}