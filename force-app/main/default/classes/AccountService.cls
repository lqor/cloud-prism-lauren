public class AccountService extends SObjectService implements SObjectServiceInterface {
    
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
        update accounts;
    }
    
    public Boolean validateObject(SObject record) {
        if(record instanceof Account) {
            Account account = (Account) record;
            return account.Name != null;
        }
        
        return false;
    }
    
    public void formatRecord(SObject record) {
        if(record instanceof Account) {
            Account account = (Account) record;
            
            List<String> splitNames = new List<String>(account.Name.split(' '));
            String formattedName = '';
            String firstLetter = '';
            String trimmedName = '';
            
            for(String name : splitNames) {
                trimmedName = name.trim();
                
                if(trimmedName.length() > 1) {
                    firstLetter = trimmedName.substring(0,1);
                } else if(trimmedName.length() == 1) {
                    firstLetter = trimmedName;
                } else {
                    continue;
                }
                
                if(firstLetter.isAllLowerCase()) {
                    formattedName += trimmedName.capitalize() + ' ';
                } else {
                    formattedName += trimmedName + ' ';
                }
            }
            
            account.Name = formattedName.trim();
        }
    }
    
    public override void updateObject(SObject record) {
        if(record == null || !(record instanceof Account)) {
            return;
        }
        
        if(validateObject(record)) {
            update record;
        }
    }
    
    public override void insertObject(SObject record) {
        if(record == null || !(record instanceof Account)) {
            return;
        }
        
        if(validateObject(record)) {
            insert record;
        }
    }
    
}