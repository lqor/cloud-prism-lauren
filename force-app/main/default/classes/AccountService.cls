public class AccountService {
    
    public Account createAccount() {
        Account account = new Account();
        
        account.Name = 'Metropolitan Museum of Art';
        account.Industry = 'Not For Profit';
        account.BillingCity = 'New York';
        
        return account;
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
        // account.Name.contains('Test') || account.Name.contains('test') = true -> true
        // account.Name.contains('Test') || account.Name.contains('test') = false -> false
        return account.Name.contains('Test') || account.Name.contains('test');
    }

    public String printAccountTier(Account account) {
        String tier = 'VIP Tier';

        if(account.AnnualRevenue == 0) {
            tier = 'No Tier';
        } else if(account.AnnualRevenue < 50000) {
            tier = 'Silver Tier';
        } else if(account.AnnualRevenue < 300000) {
            tier = 'Golden Tier';
        } 

        System.debug(tier);
        return tier;
    }
    
    public void insertAccount(Account account) {
        insert account;
    }
    
}