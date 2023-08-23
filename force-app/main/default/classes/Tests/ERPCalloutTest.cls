@IsTest
public with sharing class ERPCalloutTest {

    @IsTest
    static void doERPCalloutForParticipant_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new ERPCalloutHttpCalloutMock());

        Participant__c participant = new Participant__c();
        String participantJSON = JSON.serialize(participant);

        Test.startTest();
        String responseBody = ERPCallout.doERPCalloutForParticipant(participantJSON);
        Test.stopTest();

        Assert.isTrue(responseBody.contains('erpId'));
        Assert.isTrue(responseBody.contains(ERPCalloutHttpCalloutMock.ERP_ID));
    }

}