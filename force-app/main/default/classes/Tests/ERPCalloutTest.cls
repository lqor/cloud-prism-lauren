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

    @IsTest
    static void doERPCalloutForParticipant_UnitTest_EmptyParticipant() {
        Test.setMock(HttpCalloutMock.class, new ERPCalloutHttpCalloutMock());

        try {
            Test.startTest();
            String responseBody = ERPCallout.doERPCalloutForParticipant(null);
            Test.stopTest();

            Assert.fail();
        } catch(ERPCallout.EmptyParticipantException e) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void parseErpId_UnitTest() {
        String reponseBody = '{"erpId":"' + ERPCalloutHttpCalloutMock.ERP_ID + '"}';
        String expectedId = ERPCalloutHttpCalloutMock.ERP_ID;

        Test.startTest();
        String actualId = ERPCallout.parseErpId(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedId, actualId);
    }

    @IsTest
    static void parseErpId_UnitTest_noErpIdKey() {
        String reponseBody = '{"ErpsId":"' + ERPCalloutHttpCalloutMock.ERP_ID + '"}';
        String expectedId = '';

        Test.startTest();
        String actualId = ERPCallout.parseErpId(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedId, actualId);
    }

}