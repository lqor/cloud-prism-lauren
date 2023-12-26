@IsTest
private class PaymentLinkCalloutTest {

    @TestSetup
    static void setup() {
        Training__c training = new Training__c();
        training.Name = 'Test Callout Training';
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);
        insert training;

        Contact contact = new Contact(LastName = 'Participant', CanBookForOthers__c = true, Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact};
        insert contacts;
    }
    
    @IsTest
    static void doPaymentCalloutForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkCalloutHttpCalloutMock());

        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Training__c training = [SELECT Id FROM Training__c LIMIT 1];

        Participant__c participant = new Participant__c(Contact__c = contact.Id, Training__c = training.Id);
        insert participant;

        Test.startTest();
        String responseBody = PaymentLinkCallout.doPaymentCalloutForParticipant(participant);
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, PaymentLink__c FROM Participant__c LIMIT 1];
        Assert.isTrue(responseBody.contains(PaymentLinkCalloutHttpCalloutMock.PAYMENT_LINK));
        Assert.isTrue(responseBody.contains('payer'));
    }

    @IsTest
    static void doPaymentCalloutForParticipant_UnitTest_NullParticipant() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkCalloutHttpCalloutMock());

        try {
            Test.startTest();
            String responseBody = PaymentLinkCallout.doPaymentCalloutForParticipant(null);
            Test.stopTest();

            Assert.fail();
        } catch(PaymentLinkCallout.NullParticipantException e) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void parsePaymentLink_UnitTest() {
        String reponseBody = '{"payer":{"link":"' + PaymentLinkCalloutHttpCalloutMock.PAYMENT_LINK + '"}}';
        String expectedLink = PaymentLinkCalloutHttpCalloutMock.PAYMENT_LINK;

        Test.startTest();
        String actualLink = PaymentLinkCallout.parsePaymentLink(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedLink, actualLink);
    }

    @IsTest
    static void parsePaymentLink_UnitTest_noPayerKey() {
        String reponseBody = '{"payee":{"link":"' + PaymentLinkCalloutHttpCalloutMock.PAYMENT_LINK + '"}}';
        String expectedLink = '';

        Test.startTest();
        String actualLink = PaymentLinkCallout.parsePaymentLink(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedLink, actualLink);
    }

    @IsTest
    static void parsePaymentLink_UnitTest_noLinkKey() {
        String reponseBody = '{"payer":{"lnk":"' + PaymentLinkCalloutHttpCalloutMock.PAYMENT_LINK + '"}}';
        String expectedLink = '';

        Test.startTest();
        String actualLink = PaymentLinkCallout.parsePaymentLink(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedLink, actualLink);
    }

}