@IsTest
public with sharing class OpportunityServiceTest {

    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Magic Mountain');
        insert account;

        Opportunity opportunity1 = new Opportunity();
        Opportunity opportunity2 = new Opportunity();
        Opportunity opportunity3 = new Opportunity();
        Opportunity opportunity4 = new Opportunity();
        
        opportunity1.AccountId = account.Id;
        opportunity1.Amount = 64000;
        opportunity1.CloseDate = System.today().addMonths(2);
        opportunity1.Name = 'Test Opportunity One';
        opportunity1.Probability = 50;
        opportunity1.StageName = 'Closed Won';

        opportunity2.AccountId = account.Id;
        opportunity2.Amount = 100000;
        opportunity2.CloseDate = System.today().addDays(15);
        opportunity2.Name = 'Test Opportunity Two';
        opportunity2.Probability = 15;
        opportunity2.StageName = 'Qualification';

        opportunity3.AccountId = account.Id;
        opportunity3.Amount = 3000;
        opportunity3.CloseDate = System.today().addDays(7);
        opportunity3.Name = 'Test Opportunity Three';
        opportunity3.Probability = 100;
        opportunity3.StageName = 'Closed Won';

        opportunity4.AccountId = account.Id;
        opportunity4.Amount = 17500;
        opportunity4.CloseDate = System.today().addMonths(-6);
        opportunity4.Name = 'Test Opportunity Four';
        opportunity4.Probability = 75;
        opportunity4.StageName = 'Proposal/Price Quote';

        insert new List<Opportunity>{opportunity1, opportunity2, opportunity3};
    }

    @IsTest 
    static void isOpen_ClosedOpportunity() {
        Opportunity opportunity = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        Boolean isOpen = opportunityService.isOpen(opportunity);

        Assert.isFalse(isOpen);
    }

    @IsTest 
    static void calculateAmount_UnitTest() {
        List<Opportunity> opportunities = [
            SELECT Amount 
            FROM Opportunity 
            WHERE Amount != null
            LIMIT 2
        ];

        Opportunity opportunity1 = opportunities.get(0);
        Opportunity opportunity2 = opportunities.get(1);
        Decimal expectedAmount = opportunity1.Amount + opportunity2.Amount;

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, opportunity2);

        Assert.areEqual(expectedAmount, amount);
    }

    @IsTest 
    static void calculateAmount_ZeroAmount() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, opportunityZero);

        Assert.areEqual(0.0, amount);
    }

    @IsTest 
    static void calculateAmount_NullOpportunities() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, null);

        Assert.areEqual(0.0, amount);
    }

    @IsTest 
    static void calculateProbability_UnitTest() {
        List<Opportunity> opportunities = [
            SELECT Probability 
            FROM Opportunity 
            WHERE Probability != null
            LIMIT 2
        ];

        Opportunity opportunity1 = opportunities.get(0);
        Opportunity opportunity2 = opportunities.get(1);
        Decimal expecetdProbability = (opportunity1.Probability + opportunity2.Probability) / 2.0;

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunity2);

        Assert.areEqual(expecetdProbability, probability);
    }

    @IsTest 
    static void calculateProbability_ZeroProbability() {
        Opportunity opportunity1 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunityZero);

        Assert.areEqual(0.0, probability);
    }

    @IsTest 
    static void calculateProbability_NullOpportunities() {
        Opportunity opportunity1 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunityNull);

        Assert.areEqual(0.0, probability);
    }

    @IsTest 
    static void doubleAmount_UnitTest() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunity1);

        Assert.areEqual(128000, opportunity1.Amount);
    }

    @IsTest 
    static void doubleAmount_NullAmount() {
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunityZero);

        Assert.areEqual(null, opportunityZero.Amount);
    }

    @IsTest 
    static void doubleAmount_NullOpportunity() {
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunityNull);

        Assert.areEqual(null, null);
    }
    
    @IsTest 
    static void getOpportunityDetails_UnitTest() {
        Opportunity opportunity = [SELECT Name, Amount, StageName FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        String result = opportunityService.getOpportunityDetails(opportunity);

        Assert.isTrue(result.contains(opportunity.Name));
        Assert.isTrue(result.contains(String.valueOf(opportunity.Amount)));
        Assert.isTrue(result.contains(opportunity.StageName));
    }
   
    @IsTest 
    static void getOpportunityDetails_NullOpportunity() {
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        String result = opportunityService.getOpportunityDetails(opportunityNull);

        Assert.areEqual('', result);
    }

    @IsTest 
    static void softMerge_UnitTest() {
        Opportunity opportunity1 = [
            SELECT AccountId, Amount, CloseDate 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity One'
        ];
        Opportunity opportunity2 = [
            SELECT Name, Probability, StageName 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity Two'
        ];

        Opportunity opportunityExpected = new Opportunity();
        opportunityExpected.AccountId = opportunity1.AccountId;
        opportunityExpected.Amount = opportunity1.Amount;
        opportunityExpected.CloseDate = opportunity1.CloseDate;
        opportunityExpected.Name = opportunity2.Name;
        opportunityExpected.Probability = opportunity2.Probability;
        opportunityExpected.StageName = opportunity2.StageName;

        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunityMerged = opportunityService.softMerge(opportunity1, opportunity2);

        Assert.areEqual(opportunityExpected.AccountId, opportunityMerged.AccountId);
        Assert.areEqual(opportunityExpected.Amount, opportunityMerged.Amount);
        Assert.areEqual(opportunityExpected.CloseDate, opportunityMerged.CloseDate);
        Assert.areEqual(opportunityExpected.Name, opportunityMerged.Name);
        Assert.areEqual(opportunityExpected.Probability, opportunityMerged.Probability);
        Assert.areEqual(opportunityExpected.StageName, opportunityMerged.StageName);
    }

    @IsTest 
    static void createNewOpportunity_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunityCreated = opportunityService.createNewOpportunity();

        Assert.areNotEqual(null, opportunityCreated);
    }

    @IsTest 
    static void createOpportunityWithParameters_UnitTest() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Magic Mountain'];
        Opportunity opportunityExpected = new Opportunity();
        opportunityExpected.AccountId = account.Id;
        opportunityExpected.Amount = 2500;
        opportunityExpected.CloseDate = System.today().addDays(14);
        opportunityExpected.Name = account.Name + ' Installations';
        opportunityExpected.StageName = 'Needs Analysis';

        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunityCreated = opportunityService.createNewOpportunity(
            account.Name + ' Installations',
            'Needs Analysis',
            System.today().addDays(14), 
            2500,
            account.Id
        );

        Assert.areEqual(opportunityExpected, opportunityCreated);
    }

    @isTest 
    static void createOpportunityWithAccount_UnitTest() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Magic Mountain'];
        Opportunity opportunityExpected = new Opportunity();
        opportunityExpected.AccountId = account.Id;
        opportunityExpected.Amount = 2500;
        opportunityExpected.CloseDate = System.today().addDays(14);
        opportunityExpected.Name = account.Name + ' Installations';
        opportunityExpected.Probability = 20;
        opportunityExpected.StageName = 'Needs Analysis';

        Test.startTest();
        Opportunity opportunityCreated = new OpportunityService().createOpportunityWithAccount(account);
        Test.stopTest();

        Assert.areEqual(opportunityExpected, opportunityCreated);
    }
    
    @IsTest 
    static void createOpportunities_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity> opportunitiesCreated = opportunityService.createOpportunities(5);

        Assert.areEqual(5, opportunitiesCreated.size());
    }

    @IsTest 
    static void filterOpportunitiesByStage_UnitTest() {
        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE Name LIKE 'Test Opportunity%'];
        List<Opportunity> expectedOpportunities = [SELECT StageName FROM Opportunity WHERE StageName = 'Qualification'];
        String stage = 'Qualification';

        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity>  filteredOpportunities = opportunityService.filterOpportunitiesByStage(opportunities, stage);

        Assert.areEqual(expectedOpportunities, filteredOpportunities);
    }

    @IsTest 
    static void filterClosedWonOpportunities_UnitTest() {
        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity];

        OpportunityService opportunityService = new OpportunityService();

        Test.startTest();
        List<Opportunity> filteredOpportunities = opportunityService.filterClosedWonOpportunities(opportunities);
        Test.stopTest();

        for(Opportunity opportunity : filteredOpportunities) {
            Assert.areEqual('Closed Won', opportunity.StageName);
        }
    }

    @IsTest 
    static void calculateTotalRevenue_UnitTest() {
        List<Opportunity> opportunities = [SELECT Amount FROM Opportunity];

        OpportunityService opportunityService = new OpportunityService();
        Double totalRevenue = opportunityService.calculateTotalRevenue(opportunities);

        Assert.areEqual(167000, totalRevenue);
    }

    @IsTest 
    static void changeProbablityBasedOnAmount_UnitTest() {
        Integer amount = 100000;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.changeProbablityBasedOnAmount(amount);

        List<Opportunity> opportunities = [SELECT Probability, Amount FROM Opportunity WHERE Amount = 100000];

        Assert.areEqual(8, opportunities.get(0).Probability);
    }

    @IsTest 
    static void updateOpportunityCloseDates_UnitTest() {
        String stage = 'Qualification';
        Integer daysToAdd = 5;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.updateOpportunityCloseDates(stage, daysToAdd);

        Opportunity changedOpp = [SELECT CloseDate FROM Opportunity WHERE StageName = 'Qualification' LIMIT 1];

        Assert.areEqual(System.today().addDays(20), changedOpp.CloseDate);
    }

    @IsTest 
    static void closeOldOpportunities_UnitTest() {
        Integer amountOfMonths = -5;
        Date pastDate = System.today().addMonths(-5);

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.closeOldOpportunities(amountOfMonths);

        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE CloseDate > :pastDate];

        Assert.areEqual('Closed Lost', opportunities.get(0).StageName);
    }
    
    @IsTest 
    static void addDaysToOpportunities_UnitTest() {
        List<Opportunity> opportunities = [
            SELECT AccountId, CloseDate 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity Two'
        ];
        List<Id> accountIds = new List<Id>();
        List<Date> expectedCloseDates = new List<Date>();
        List<Date> newCloseDates = new List<Date>();
        Integer amountOfDays = 15;

        for(Opportunity opportunity : opportunities) {
            accountIds.add(opportunity.AccountId);
        }

        for(Opportunity opportunity : opportunities) {
            expectedCloseDates.add(opportunity.CloseDate.addDays(amountOfDays));
        }

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.addDaysToOpportunities(accountIds, amountOfDays);

        List<Opportunity> adjustedOpportunities = [
            SELECT AccountId, CloseDate 
            FROM Opportunity 
            WHERE Name = 'Test Opportunity Two'
        ];
        for(Opportunity opportunity : adjustedOpportunities) {
            newCloseDates.add(opportunity.CloseDate);
        }

        Assert.areEqual(expectedCloseDates, newCloseDates);
    }
    
    /*
    // better way to write using sets and maps to avoid duplicate account Ids
    @IsTest 
    static void addDaysToOpportunities_UnitTest() {
        List<Opportunity> opportunities = [
            SELECT AccountId, CloseDate 
            FROM Opportunity 
        ];
        Integer amountOfDays = 15;
        List<Date> expectedCloseDates = new List<Date>();
        for(Opportunity opportunity : opportunities) {
            expectedCloseDates.add(opportunity.CloseDate.addDays(amountOfDays));
        }

        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accountIds = (new Map<Id, Account> (accounts)).keySet(); // Set<Id> idSet = (new Map<Id, SObject> (records)).keySet();
        
        OpportunityService opportunityService = new OpportunityService();
        opportunityService.addDaysToOpportunities(accountIds, amountOfDays);

        opportunities = [
            SELECT AccountId, CloseDate 
            FROM Opportunity 
        ];

        Assert.areEqual(expectedCloseDates.size(), opportunities.size());
        for(Opportunity opportunity : opportunities) {
            Assert.isTrue(expectedCloseDates.contains(opportunity.CloseDate));
        }
    }*/

    @IsTest 
    static void insertOpportunity_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunity = opportunityService.createNewOpportunity();
        opportunityService.insertOpportunity(opportunity);

        Opportunity opportunityInserted = [SELECT Id FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areNotEqual(null, opportunityInserted);
    }

    @IsTest 
    static void insertOpportunities_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity> opportunities = opportunityService.createOpportunities(5);
        opportunityService.insertOpportunities(opportunities);
        List<Id> opportunityIds = new List<Id>();

        for(Opportunity opportunity : opportunities) {
            opportunityIds.add(opportunity.Id);
        }

        List<Opportunity> opportunitiesInserted = [SELECT Id FROM Opportunity WHERE Id IN :opportunityIds];
        
        Assert.areEqual(5, opportunitiesInserted.size());
    }

}