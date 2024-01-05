@IsTest
public class RefundCalloutTest {

    @IsTest
    static void doRefundCalloutForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        TrainingRefund__c refund = new TrainingRefund__c();

        refund.TrainingInvoice__r = new TrainingInvoice__c(InvoiceId__c = '659225a2702872fa2a7b59b7');
        refund.Amount__c = 190;
        refund.Participant__c = 'a038b00000XpnwpAAB';
        refund.Reason__c = 'Technical Issues';
        refund.RefundDate__c = System.today();

        Test.startTest();
        RefundCallout.RefundResponseBody responseBody = RefundCallout.doRefundCalloutForParticipant(refund);
        Test.stopTest();

        Assert.areEqual(InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN, responseBody.token);
        Assert.areEqual(RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID, responseBody.refund_id);
    }

    @IsTest
    static void doGetRefundCalloutForParticipantByRefundId_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());
        
        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        String token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        String responseStatus = RefundCallout.doGetRefundCalloutForParticipantByRefundId(refundId, token);
        Test.stopTest();

        Assert.areEqual(RefundCalloutHttpCalloutMock.REFUND_RESPONSE_STATUS, responseStatus);
    }

    @IsTest
    static void doRefundVerificationCalloutForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new RefundCalloutHttpCalloutMock());

        String refundId = RefundCalloutHttpCalloutMock.REFUND_RESPONSE_ID;
        String token = InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN;

        Test.startTest();
        String responseVerificationId = RefundCallout.doRefundVerificationCalloutForParticipant(refundId, token);
        Test.stopTest();

        Assert.areEqual(RefundCalloutHttpCalloutMock.VERIFICATION_RESPONSE_ID, responseVerificationId);
    }

}