@IsTest
public with sharing class ParticipantServiceTest {

    @TestSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Restaurant__c restaurant = new Restaurant__c();
        restaurant.Name = 'Tam O\'Shanter';
        restaurant.CommissionRate__c = 15;
        restaurant.AverageMealCost__c = 55;
        insert restaurant;

        Training__c training = new Training__c();
        training.Name = 'Test Trigger Training';
        training.Restaurant__c = restaurant.Id;
        training.StartDate__c = System.today().addMonths(1);
        training.EndDate__c = System.today().addMonths(1);
        insert training;

        Contact contact1 = new Contact(LastName = 'Participant-One', CanBookForOthers__c = true, Email = 'e@mail.com');
        Contact contact2 = new Contact(LastName = 'Participant-Two', CanBookForOthers__c = false, Email = 'e@mail.com');
        List<Contact> contacts = new List<Contact> {contact1, contact2};
        insert contacts;

        Participant__c participant1 = new Participant__c(Contact__c = contact1.Id, Training__c = training.Id);
        Participant__c participant2 = new Participant__c(Contact__c = contact2.Id, Training__c = training.Id);
        List<Participant__c> participants = new List<Participant__c> {participant1, participant2};
        insert participants;
    }

    @IsTest
    static void preventDuplicateParticipantOnTrainings_lazy() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Training__c training = [SELECT Id, Name FROM Training__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, CanBookForOthers__c FROM Contact];
        Contact contact1 = contacts.get(0);
        Contact contact2 = contacts.get(1);

        Participant__c dupParticipant1 = new Participant__c(Contact__c = contact1.Id, Training__c = training.Id);
        Participant__c dupParticipant2 = new Participant__c(Contact__c = contact2.Id, Training__c = training.Id);
        List<Participant__c> dupParticipants = new List<Participant__c> {dupParticipant1, dupParticipant2};

        try {
            Test.startTest();
            insert dupParticipants;
            Test.stopTest();

            Assert.fail();
        } catch(System.DmlException e) {
            Assert.isTrue(true);
        }
    }

    @IsTest
    static void recalculateRestaurantCommission_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Integer expectedParticipantsSize = 4;
        Training__c training = [SELECT Id, Name FROM Training__c LIMIT 1];
        List<Contact> contacts = [SELECT Id, LastName, CanBookForOthers__c FROM Contact];
        contacts.get(0).CanBookForOthers__c = true;
        contacts.get(1).CanBookForOthers__c = true;
        update contacts;

        Participant__c participant1 = new Participant__c();
        participant1.Contact__c = contacts.get(0).Id;
        participant1.Training__c = training.Id;

        Participant__c participant2 = new Participant__c();
        participant2.Contact__c = contacts.get(1).Id;
        participant2.Training__c = training.Id;

        List<Participant__c> participants = new List<Participant__c> {participant1, participant2};
        insert participants;

        Test.startTest();
        new ParticipantService().recalculateCommissionOnTrainings(participants, null);
        Test.stopTest();

        List<Training__c> trainingsUpdated = [
            SELECT Id, Restaurant__c, RestaurantCommission__c, (SELECT Id FROM Participants__r)
            FROM Training__c 
            WHERE Id = :training.Id
            LIMIT 1
        ];

        Training__c result = trainingsUpdated.get(0);
        Assert.areEqual(expectedParticipantsSize, result.Participants__r.size());
        Assert.areEqual(26.40, result.RestaurantCommission__c);
    }

    @IsTest
    static void recalculateRestaurantCommissionOnDelete_UnitTest() {
        Integer expectedParticipantsSize = 1;
        List<Training__c> training = [SELECT Id, (SELECT Id FROM Participants__r) FROM Training__c];
        Participant__c participant = training.get(0).Participants__r.get(0);

        Test.startTest();
        delete participant;
        Test.stopTest();

        List<Training__c> trainingsUpdated = [
            SELECT Id, RestaurantCommission__c, (SELECT Id FROM Participants__r) 
            FROM Training__c
        ];

        Training__c result = trainingsUpdated.get(0);
        Assert.areEqual(expectedParticipantsSize, result.Participants__r.size());
        Assert.areEqual(6.6, result.RestaurantCommission__c);
    }

    @IsTest
    static void sendRegistrationConfirmationEmail_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());
        
        List<Participant__c> participants = [SELECT Id, Training__c, Contact__c FROM Participant__c];

        Test.startTest();
        new ParticipantService().sendRegistrationConfirmationEmail(participants, null);
        Test.stopTest();

        List<AsyncApexJob> job = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob];

        AsyncApexJob result = job.get(0);
        Assert.areEqual('Completed', result.Status);
        Assert.areEqual('Queueable', result.JobType);
        Assert.areEqual('RegistrationConfirmationQueueable', result.ApexClass.Name);
    }

    @IsTest
    static void updateParticipantPaymentLink_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Training__c training = [SELECT Id FROM Training__c LIMIT 1];

        Participant__c participant = new Participant__c(Contact__c = contact.Id, Training__c = training.Id);

        Test.startTest();
        insert participant;
        Test.stopTest();

        Participant__c updatedParticipant = [SELECT Id, PaymentLink__c FROM Participant__c LIMIT 1];
        Assert.areEqual(PaymentLinkHttpCalloutMock.PAYMENT_LINK, updatedParticipant.PaymentLink__c);
    }

    @IsTest
    static void queryTrainingsWithParticipantsById_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Integer expectedParticipantsSize = 3;
        Training__c training = [SELECT Id, Name FROM Training__c];

        Contact newContact = new Contact(LastName = 'New-Student', CanBookForOthers__c = true, Email = 'new@mail.com');
        insert newContact;

        Participant__c newParticipant = new Participant__c(Contact__c = newContact.Id, Training__c = training.Id);
        insert newParticipant;

        Set<Id> trainingIds = new Set<Id>();
        trainingIds.add(training.Id);

        Test.startTest();
        List<Training__c> trainings = TrainingQueries.queryTrainingsWithParticipantsById(trainingIds);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedParticipantsSize, result.Participants__r.size());
        for(Participant__c participant : result.Participants__r) {
            Assert.areEqual(training.Id, participant.Training__c);
        }
    }

    @IsTest
    static void queryContactsOfParticipantsById_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Training__c training = [SELECT Id, Name FROM Training__c];

        Contact newContact = new Contact(LastName = 'New-Student', CanBookForOthers__c = true, Email = 'new@mail.com');
        insert newContact;

        Participant__c newParticipant = new Participant__c(Contact__c = newContact.Id, Training__c = training.Id);
        insert newParticipant;

        Set<Id> contactIds = new Set<Id>();
        contactIds.add(newParticipant.Contact__c);

        Test.startTest();
        List<Contact> contacts = ContactQueries.queryContactsOfParticipantsById(contactIds);
        Test.stopTest();

        Contact result = contacts.get(0);
        Assert.areEqual(newContact.Id, result.Id);
        Assert.areEqual(newContact.CanBookForOthers__c, result.CanBookForOthers__c);
    }

    @IsTest
    static void queryTrainingsForNewParticipantsById_UnitTest() {
        Test.setMock(HttpCalloutMock.class, new PaymentLinkHttpCalloutMock());

        Integer expectedParticipantsSize = 1;
        Training__c training = [SELECT Id, Name FROM Training__c];

        Contact newContact = new Contact(LastName = 'New-Student', CanBookForOthers__c = true, Email = 'new@mail.com');
        insert newContact;

        Participant__c newParticipant = new Participant__c(Contact__c = newContact.Id, Training__c = training.Id);
        insert newParticipant;

        Set<Id> trainingIds = new Set<Id>();
        trainingIds.add(training.Id);

        Set<Id> participantIds = new Set<Id>();
        participantIds.add(newParticipant.Id);

        Test.startTest();
        List<Training__c> trainings = TrainingQueries.queryTrainingsForNewParticipantsById(trainingIds, participantIds);
        Test.stopTest();

        Training__c result = trainings.get(0);
        Assert.areEqual(expectedParticipantsSize, result.Participants__r.size());
        Assert.areEqual(newContact.LastName, result.Participants__r.get(0).Contact__r.LastName);
    }

}