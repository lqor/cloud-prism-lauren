@IsTest
public with sharing class ParticipantSyncTest {

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
        ParticipantSync.sendParticipantsToERP(participantIds);
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, ErpId__c FROM Participant__c LIMIT 1];
        Assert.areEqual(ERPCalloutHttpCalloutMock.ERP_ID, updatedParticipant.ErpId__c);
    }

    @IsTest
    static void sendParticipantsToERP_UnitTest_preventDuplicateParticipantSync() {
        Test.setMock(HttpCalloutMock.class, new ERPCalloutHttpCalloutMock());

        Participant__c participant = [SELECT Id, ErpId__c FROM Participant__c LIMIT 1];
        participant.ErpId__c = 'not-99';
        update participant;

        Participant__c syncedParticipant = [SELECT Id FROM Participant__c LIMIT 1];
        List<Id> syncedParticipantIds = new List<Id> {syncedParticipant.Id};

        try {
            Test.startTest();
            ParticipantSync.sendParticipantsToERP(syncedParticipantIds);
            Test.stopTest();

            Assert.fail();
        } catch(ParticipantSync.ParticipantSyncedException e) {
            Assert.isTrue(true);
        }
    }

}