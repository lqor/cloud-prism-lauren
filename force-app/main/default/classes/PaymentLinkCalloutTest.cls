@IsTest
private class PaymentLinkCalloutTest {
    @IsTest
    static void doPaymentCalloutForParticipant_UnitTest() { 
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());
        Test.startTest();
        HttpResponse res = PaymentLinkCallout.doPaymentCalloutForParticipant(new Participant__c(Id = 'a038b00000VBhXuAAL'));
        Test.stopTest();

        Assert.isTrue(res.getBody().contains(PaymentLinkHttpCalloutMock.PAYMENT_LINK));
        Assert.isTrue(res.getBody().contains('payer'));
        Assert.areEqual('OK', res.getStatus());
    }

}