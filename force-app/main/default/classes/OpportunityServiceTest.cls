@IsTest
public with sharing class OpportunityServiceTest {

    @TestSetup
    static void setup(){
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

    @isTest 
    static void isOpen_ClosedOpportunity() {
        Opportunity opportunity = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        Boolean isOpen = opportunityService.isOpen(opportunity);

        Assert.areEqual(false, isOpen);
    }

    @isTest 
    static void isOpen_OpenOpportunity() {
        Opportunity opportunity = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity Two'];

        OpportunityService opportunityService = new OpportunityService();
        Boolean isOpen = opportunityService.isOpen(opportunity);

        Assert.areEqual(true, isOpen);
    }

    @isTest 
    static void calculateAmount_UnitTest() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunity2 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity Two'];

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, opportunity2);

        Assert.areEqual(164000, amount);
    }

    @isTest 
    static void calculateAmount_ZeroAmount() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, opportunityZero);

        Assert.areEqual(0.0, amount);
    }

    @isTest 
    static void calculateAmount_NullOpportunities() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        Decimal amount = opportunityService.calculateAmount(opportunity1, opportunityNull);

        Assert.areEqual(0.0, amount);
    }

    @isTest 
    static void calculateProbability_UnitTest() {
        Opportunity opportunity1 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunity2 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity Two'];

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunity2);

        Assert.areEqual(32.5, probability);
    }

    @isTest 
    static void calculateProbability_ZeroProbability() {
        Opportunity opportunity1 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunityZero);

        Assert.areEqual(0.0, probability);
    }

    @isTest 
    static void calculateProbability_NullOpportunities() {
        Opportunity opportunity1 = [SELECT Probability FROM Opportunity WHERE Name = 'Test Opportunity One'];
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        Decimal probability = opportunityService.calculateProbability(opportunity1, opportunityNull);

        Assert.areEqual(0.0, probability);
    }

    @isTest 
    static void doubleAmount_UnitTest() {
        Opportunity opportunity1 = [SELECT Amount FROM Opportunity WHERE Name = 'Test Opportunity One'];

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunity1);

        Assert.areEqual(128000, opportunity1.Amount);
    }

    @isTest 
    static void doubleAmount_NullAmount() {
        Opportunity opportunityZero = new Opportunity();

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunityZero);

        Assert.areEqual(null, opportunityZero.Amount);
    }

    @isTest 
    static void doubleAmount_NullOpportunity() {
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.doubleAmount(opportunityNull);

        Assert.areEqual(null, null);
    }
    
    @isTest 
    static void getOpportunityDetails_UnitTest() {
        Opportunity opportunity = [SELECT Name, Amount, StageName FROM Opportunity WHERE Name = 'Test Opportunity One'];

        String name = 'The opportunity name is: ' + opportunity.Name;
        String amount = '. The opportunity amount is: ' + opportunity.Amount;
        String stage = '. The opportunity stage is: ' + opportunity.StageName + '.';
        String expected = name + amount + stage;

        OpportunityService opportunityService = new OpportunityService();
        String result = opportunityService.getOpportunityDetails(opportunity);

        Assert.areEqual(expected, result);
    }
   
    @isTest 
    static void getOpportunityDetails_NullOpportunity() {
        Opportunity opportunityNull;

        OpportunityService opportunityService = new OpportunityService();
        String result = opportunityService.getOpportunityDetails(opportunityNull);

        Assert.areEqual('', result);
    }

    @isTest 
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

        Assert.areEqual(opportunityExpected, opportunityMerged);
    }

    @isTest 
    static void createNewOpportunity_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunityCreated = opportunityService.createNewOpportunity();

        Assert.areNotEqual(null, opportunityCreated);
    }

    @isTest 
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

        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunityCreated = opportunityService.createOpportunityWithAccount(account);

        Assert.areEqual(opportunityExpected, opportunityCreated);
    }
    
    @isTest 
    static void createOpportunities_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity> opportunitiesCreated = opportunityService.createOpportunities(5);

        Assert.areEqual(5, opportunitiesCreated.size());
    }

    @isTest 
    static void filterOpportunitiesByStage_UnitTest() {
        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE Name LIKE 'Test Opportunity%'];
        List<Opportunity> expectedOpportunities = [SELECT StageName FROM Opportunity WHERE StageName = 'Qualification'];
        String stage = 'Qualification';

        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity>  filteredOpportunities = opportunityService.filterOpportunitiesByStage(opportunities, stage);

        Assert.areEqual(expectedOpportunities, filteredOpportunities);
    }

    @isTest 
    static void filterClosedWonOpportunities_UnitTest() {
        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE Name LIKE 'Test Opportunity%'];
        List<Opportunity> expectedOpportunities = [SELECT StageName FROM Opportunity WHERE StageName = 'Closed Won'];

        OpportunityService opportunityService = new OpportunityService();
        List<Opportunity>  filteredOpportunities = opportunityService.filterClosedWonOpportunities(opportunities);

        Assert.areEqual(expectedOpportunities, filteredOpportunities);
    }

    @isTest 
    static void calculateTotalRevenue_UnitTest() {
        List<Opportunity> opportunities = [SELECT Amount FROM Opportunity WHERE Name LIKE 'Test Opportunity%'];

        OpportunityService opportunityService = new OpportunityService();
        Double totalRevenue = opportunityService.calculateTotalRevenue(opportunities);

        Assert.areEqual(167000, totalRevenue);
    }

    @isTest 
    static void changeProbablityBasedOnAmount_UnitTest() {
        Integer amount = 100000;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.changeProbablityBasedOnAmount(amount);

        List<Opportunity> opportunities = [SELECT Probability, Amount FROM Opportunity WHERE Amount = 100000];

        Assert.areEqual(8, opportunities.get(0).Probability);
    }

    @isTest 
    static void updateOpportunityCloseDates_UnitTest() {
        String stage = 'Qualification';
        Integer daysToAdd = 5;

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.updateOpportunityCloseDates(stage, daysToAdd);

        List<Opportunity> opportunities = [SELECT CloseDate FROM Opportunity WHERE StageName = 'Qualification'];

        Assert.areEqual(System.today().addDays(20), opportunities.get(0).CloseDate);
    }

    @isTest 
    static void closeOldOpportunities_UnitTest() {
        Integer amountOfMonths = -5;
        Date pastDate = System.today().addMonths(-5);

        OpportunityService opportunityService = new OpportunityService();
        opportunityService.closeOldOpportunities(amountOfMonths);

        List<Opportunity> opportunities = [SELECT StageName FROM Opportunity WHERE CloseDate > :pastDate];

        Assert.areEqual('Closed Lost', opportunities.get(0).StageName);
    }
   
    @isTest 
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

    @isTest 
    static void insertOpportunity_UnitTest() {
        OpportunityService opportunityService = new OpportunityService();
        Opportunity opportunity = opportunityService.createNewOpportunity();
        opportunityService.insertOpportunity(opportunity);

        Opportunity opportunityInserted = [SELECT Id FROM Opportunity WHERE Id = :opportunity.Id];
        
        Assert.areNotEqual(null, opportunityInserted);
    }

    @isTest 
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