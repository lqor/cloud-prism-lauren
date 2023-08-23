@IsTest
public with sharing class ParticipantSyncBatchTest {

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
    static void executeBatch_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new ERPCalloutHttpCalloutMock());

        Test.startTest();
        Database.executeBatch(new ParticipantSyncBatch('Participant__c'));
        Test.stopTest();

        List<Participant__c> syncedParticipants = [SELECT Id, Name, ErpId__c FROM Participant__c WHERE ErpId__c != null];
        Assert.areEqual(1, syncedParticipants.size());

        for(Participant__c participant : syncedParticipants) {
            Assert.areEqual('99', participant.ErpId__c);
        }
    }

}