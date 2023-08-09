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
    static void requestPaymentLink_UnitTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Training__c training = [SELECT Id FROM Training__c LIMIT 1];

        Participant__c participant = new Participant__c(Contact__c = contact.Id, Training__c = training.Id);
        List<Participant__c> participants = new List<Participant__c> {participant};
        insert participants;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        PaymentLinkCallout.isHttpCalloutMockTest = true;
        List<HttpResponse> responses = PaymentLinkCallout.requestPaymentLink(participants);

        for(HttpResponse response : responses) {
            Assert.areEqual(PaymentLinkCallout.RESPONSE_STATUS_CODE_200, response.getStatusCode());
            Assert.areEqual('application/json', response.getHeader('Content-Type'));

            String actualBody = response.getBody();
            String expectedBody = '{"payer":{"link":"https://pry.me/p/1688117280"}}';
            Assert.areEqual(expectedBody, actualBody);
        }

        Map<String, Object> paymentObject = (Map<String, Object>) JSON.deserializeUntyped(responses.get(0).getBody());
        Map<String, Object> payer = (Map<String, Object>) paymentObject.get('payer');

        String expectedPaymentLink = 'https://pry.me/p/1688117280';
        Assert.areEqual(expectedPaymentLink, (String) payer.get('link'));
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, PaymentLink__c FROM Participant__c LIMIT 1];
        Assert.areEqual(expectedPaymentLink, updatedParticipant.PaymentLink__c);
    }

    @IsTest
    static void sendPaymentEmail_UnitTest() { 
    }

}