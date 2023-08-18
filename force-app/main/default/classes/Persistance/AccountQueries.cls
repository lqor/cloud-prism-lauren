public with sharing class AccountQueries {

    public static List<Account> queryAccounts() {
        return [SELECT Id, Description FROM Account];
    }

}