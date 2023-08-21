@IsTest
public with sharing class AccountServiceTest {
    @TestSetup
    static void setup() {

    }

    @IsTest 
    static void createIndustryMap_UnitTest() {

        AccountService accountService = new AccountService();

        Test.startTest();
        Test.stopTest();


    }

    @IsTest 
    static void fillDescriptionWithContacts_UnitTest() {

        AccountService accountService = new AccountService();

        Test.startTest();
        Test.stopTest();
        
    }

    @IsTest 
    static void updateAccountsWithContacts_UnitTest() {
        
    }

    @IsTest 
    static void insertAccount_UnitTest() {
        AccountService accountService = new AccountService();
        Account account = accountService.createNewAccount('Test Account', 'Prospect', 'TA-001593');

        Test.startTest();
        insert(account);
        Test.stopTest();

        Account accountInserted = [SELECT Id FROM Account WHERE Id = :account.Id];
        
        Assert.isNotNull(accountInserted);
    }

    @IsTest 
    static void insertAccounts_UnitTest() {
        AccountService accountService = new AccountService();
        List<Account> accounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Integer numberOfAccounts = 5;

        for(Integer i = 0; i < numberOfAccounts; i++) {
            accounts.add(accountService.createNewAccount('Test Account ' + i, 'Prospect', 'TA-00159' + i));
        }

        Test.startTest();
        insert(accounts);
        Test.stopTest();
        
        for(Account account : accounts) {
            accountIds.add(account.Id);
        }

        List<Account> accountsInserted = [SELECT Id FROM Account WHERE Id IN :accountIds];
        
        Assert.areEqual(numberOfAccounts, accountsInserted.size());
    }
    
    @IsTest 
    static void updateAccounts_UnitTest() {

        AccountService accountService = new AccountService();

        Test.startTest();
        Test.stopTest();
        
    }

}