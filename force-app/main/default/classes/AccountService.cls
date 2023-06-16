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
    
    public void insertAccount(Account account) {
        insert account;
    }
    
}