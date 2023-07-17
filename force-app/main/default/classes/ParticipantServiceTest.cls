@IsTest
public with sharing class ParticipantServiceTest {

    @TestSetup
    static void setup() {}

    @IsTest
    static void preventDuplicateParticipantOnTrainings_UnitTest() {
        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training ';
        training.StartDate__c = System.today();
        training.EndDate__c = System.today();
        insert training;

        Contact contact1 = new Contact(LastName = 'Participant-One', CanBookForOthers__c = true);
        Contact contact2 = new Contact(LastName = 'Participant-Two', CanBookForOthers__c = false);
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        Participant__c participant1 = new Participant__c(Contact__c = contact1.Id, Training__c = training.Id);
        Participant__c participant2 = new Participant__c(Contact__c = contact2.Id, Training__c = training.Id);
        List<Participant__c> participants = new List<Participant__c> {participant1, participant2};
        insert participants;

        Participant__c dupParticipant1 = new Participant__c(Contact__c = contact1.Id, Training__c = training.Id);
        Participant__c dupParticipant2 = new Participant__c(Contact__c = contact2.Id, Training__c = training.Id);
        List<Participant__c> dupParticipants = new List<Participant__c> {dupParticipant1, dupParticipant2};

        ParticipantService service = new ParticipantService();
        Test.startTest();
        List<Database.SaveResult> saveResults = Database.insert(dupParticipants, false);
        service.preventDuplicateParticipantOnTrainings(dupParticipants, null);
        Test.stopTest();

        List<Training__c> trainingsUpdated = [
            SELECT Id, (SELECT Id FROM Participants__r)
            FROM Training__c 
            WHERE Id = :training.Id
            LIMIT 1
        ];

        Training__c result = trainingsUpdated.get(0);
        Assert.areEqual(3, result.Participants__r.size());
        System.debug('result.Participants__r.size(): ' + result.Participants__r.size());

        Database.SaveResult duplicateParticipantWithCanBookForOthers = saveResults.get(0);
        Assert.isTrue(duplicateParticipantWithCanBookForOthers.isSuccess());
        Assert.areEqual(0, duplicateParticipantWithCanBookForOthers.getErrors().size());

        Database.SaveResult duplicateParticipantWithoutCanBookForOthers = saveResults.get(1);
        Assert.isFalse(duplicateParticipantWithoutCanBookForOthers.isSuccess());
        Assert.areEqual(1, duplicateParticipantWithoutCanBookForOthers.getErrors().size());

    }

    @IsTest
    static void recalculateRestaurantCommission_UnitTest() {
        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training ';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);
        insert training;

        Contact contact1 = new Contact(LastName = 'Participant-One');
        Contact contact2 = new Contact(LastName = 'Participant-Two');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        Participant__c participant1 = new Participant__c();
        Participant__c participant2 = new Participant__c();
        participant1.Contact__c = contacts.get(0).Id;
        participant2.Contact__c = contacts.get(1).Id;
        participant1.Training__c = training.Id;
        participant2.Training__c = training.Id;
        List<Participant__c> participants = new List<Participant__c> {participant1, participant2};
        insert participants;

        ParticipantService service = new ParticipantService();
        Test.startTest();
        service.recalculateCommissionOnTrainings(participants, null);
        Test.stopTest();

        List<Training__c> trainingsUpdated = [
            SELECT Id, Restaurant__c, RestaurantCommission__c, (SELECT Id FROM Participants__r)
            FROM Training__c 
            WHERE Id = :training.Id
            LIMIT 1
        ];

        Training__c result = trainingsUpdated.get(0);
        Assert.areEqual(participants.size(), result.Participants__r.size());
        Assert.areEqual(13.20, result.RestaurantCommission__c);
    }
}