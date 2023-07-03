public class AccountService {

    public static final String CHEMICALS_ACCT_INDUSTRY = 'Chemicals';
    public static final String ENTERTAINMENT_ACCT_INDUSTRY = 'Entertainment';
    public static final String GOVERNMENT_ACCT_INDUSTRY = 'Government';
    public static final String MEDIA_ACCT_INDUSTRY = 'Media';
    public static final String NOT_FOR_PROFIT_ACCT_INDUSTRY = 'Not For Profit';
    public static final String TECHNOLOGY_ACCT_INDUSTRY = 'Technology';
    public static final String UTILITY_ACCT_INDUSTRY = 'Utilities';
    public static final String OTHER_ACCT_INDUSTRY = 'Other';

    public Account createAccount() {
        Account account = new Account();
        
        account.Name = 'Metropolitan Museum of Art';
        account.Industry = 'Not For Profit';
        account.BillingCity = 'New York';
        
        return account;
    }

    // Lists & For Each Loops Exercises
    //--------------------------------------------------------------------------

    public List<Account> createTwoAccounts() {
        List<Account> twoAccounts = new List<Account>();
        Account firstAccount = new Account();
        Account secondAccount = new Account();

        firstAccount.Name = 'Tokyo Disneyland';
        firstAccount.Industry = 'Entertainment';
        firstAccount.BillingCity = 'Tokyo';

        secondAccount.Name = 'Universal Studios Japan';
        secondAccount.Industry = 'Entertainment';
        secondAccount.BillingCity = 'Osaka';

        twoAccounts.add(firstAccount);
        twoAccounts.add(secondAccount);

        return twoAccounts;
    }

    public Account createNewAccount(String name, String type, String accountNumber) {
        Account account = new Account();

        account.Name = name;
        account.Type = type;
        account.AccountNumber = accountNumber;
        
        return account;
    }

    public String getAccountSummary(Account account) {
        String name = 'The account name is: ' + account.Name;
        String type = '. The account type is: ' + account.Type;
        String annualRevenue = '. The account annual revenue is: $' + account.AnnualRevenue + '.';
        String accountValues = name + type + annualRevenue;

        return accountValues;
    }

    public Boolean isTestAccount(Account account) {
        if(account.Name.contains('Test') || account.Name.contains('test')) {
            return true;
        } else {
            return false;
        }
    }

    public String printAccountTier(Account account) {
        String tier = '';

        if(account.AnnualRevenue == 0) {
            tier = 'No Tier';
        } else if(account.AnnualRevenue < 50000) {
            tier = 'Silver Tier';
        } else if(account.AnnualRevenue >= 50000 && account.AnnualRevenue < 300000) {
            tier = 'Golden Tier';
        } else if(account.AnnualRevenue >= 300000) {
            tier = 'VIP Tier';
        }

        System.debug(tier);
        return tier;
    }

    public String getRandomIndustry() {
        ListsPractice listsPractice = new ListsPractice();
        List<String> industries = new List<String>();

        industries.add(CHEMICALS_ACCT_INDUSTRY);
        industries.add(ENTERTAINMENT_ACCT_INDUSTRY);
        industries.add(GOVERNMENT_ACCT_INDUSTRY);
        industries.add(MEDIA_ACCT_INDUSTRY);
        industries.add(NOT_FOR_PROFIT_ACCT_INDUSTRY);
        industries.add(TECHNOLOGY_ACCT_INDUSTRY);
        industries.add(UTILITY_ACCT_INDUSTRY);
        industries.add(OTHER_ACCT_INDUSTRY);

        return listsPractice.getRandomStringFromList(industries);
    }

    public Map<String, List<Account>> createIndustryMap(List<Account> accounts) {
        Map<String, List<Account>> accountsByIndustry = new Map<String, List<Account>>();

        for(Account account : accounts) {
            List<Account> updatedAccounts = new List<Account>();

            if(accountsByIndustry.containsKey(account.Industry)) {
                updatedAccounts = accountsByIndustry.get(account.Industry);
            }
            updatedAccounts.add(account);
            accountsByIndustry.put(account.Industry, updatedAccounts);
        }
        
        return accountsByIndustry;
    }

    public void fillDescriptionWithContacts(List<Account> accounts, Map<String, List<Contact>> contactMap) {
        Set<Id> accountIds = (new Map<Id, Account> (accounts)).keySet();
        Map<Id, Account> accountsById = new Map<Id, Account> (accounts);
        String label = '\n- Associated Contact: ';

        for(Id accountId : accountIds) {
            if(contactMap.containsKey(accountId) && accountsById.containsKey(accountId)) {
                List<Contact> contactValues = new List<Contact>();
                Account currentAccount = new Account();

                contactValues = contactMap.get(accountId);
                currentAccount = accountsById.get(accountId);

                for(Contact contact : contactValues) {
                    if(currentAccount.Description != null) {
                        currentAccount.Description += label + contact.Name;
                    } else {
                        currentAccount.Description = label + contact.Name; 
                    }
                }
            }
        }
    }

    public void updateAccountsWithContacts() {
        List<Account> accounts = [SELECT Id, Description FROM Account];
        Set<Id> accountIds = (new Map<Id, Account> (accounts)).keySet();

        List<Contact> relatedContacts = [SELECT Name, AccountId FROM Contact WHERE AccountId IN :accountIds];

        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();

        for(Contact relatedContact : relatedContacts) {
            List<Contact> updatedContacts = new List<Contact>();

            if(contactMap.containsKey(relatedContact.AccountId)) {
                updatedContacts = contactMap.get(relatedContact.AccountId);
            } 
            updatedContacts.add(relatedContact);
            contactMap.put(relatedContact.AccountId, updatedContacts);
        }

        fillDescriptionWithContacts(accounts, contactMap);
        updateAccounts(accounts);
    }
    
    public void insertAccount(Account account) {
        if(account.Name != null) {
            insert account;
        }
    }

    public void insertAccounts(List<Account> accounts) {
        List<Account> accountsToInsert = new List<Account>(); 

        for(Account account : accounts) {
            if(account.Name != null) {
                accountsToInsert.add(account);
            }
        }

        insert accounts;
    }

    public void updateAccounts(List<Account> accounts) {
        if(accounts != null && !accounts.isEmpty()){
            update accounts;
        }
    }
    
}