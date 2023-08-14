@IsTest
public with sharing class SendParticipantToERPTest {

    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Training__c training = new Training__c();
        training.Name = 'Test Callout Training';
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);
        insert training;

        Contact contact = new Contact(LastName = 'Participant', CanBookForOthers__c = true, Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact};
        insert contacts;

        Participant__c participant = new Participant__c(Contact__c = contact.Id, Training__c = training.Id);
        insert participant;
    }

    @IsTest
    static void sendParticipantsToERP_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new ERPCalloutHttpCalloutMock());

        Participant__c participant = [SELECT Id FROM Participant__c LIMIT 1];
        List<Id> participantIds = new List<Id> {participant.Id};

        Test.startTest();
        SendParticipantToERP.sendParticipantsToERP(participantIds);
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, ErpId__c FROM Participant__c LIMIT 1];
        Assert.areEqual(ERPCalloutHttpCalloutMock.ERP_ID, updatedParticipant.ErpId__c);
    }

    @IsTest
    static void parseErpId_UnitTest() {
        String reponseBody = '{"erpId":"' + ERPCalloutHttpCalloutMock.ERP_ID + '"}';
        String expectedId = ERPCalloutHttpCalloutMock.ERP_ID;

        Test.startTest();
        String actualId = SendParticipantToERP.parseErpId(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedId, actualId);
    }

    @IsTest
    static void parseErpId_UnitTest_noErpIdKey() {
        String reponseBody = '{"ErpsId":"' + ERPCalloutHttpCalloutMock.ERP_ID + '"}';
        String expectedId = '';

        Test.startTest();
        String actualId = SendParticipantToERP.parseErpId(reponseBody);
        Test.stopTest();

        Assert.areEqual(expectedId, actualId);
    }

}