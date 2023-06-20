// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// Task #3 - Anonymous Window
//---------------------------------------------------------------
AccountService accountService = new AccountService();
Account account = accountService.createNewAccount('Metropolitan Museum of Toast', 'Prospect', 'MMT-0054973');
accountService.insertAccount(account);
System.debug(account);

System.debug(accountservice.getAccountSummary(account));

Boolean isTestAccount = accountservice.isTestAccount(account);
System.debug(account.Name + ' is a test account: ' +  isTestAccount);//false
account.Name = 'Metropolitan Museum of Test';
isTestAccount = accountservice.isTestAccount(account);
System.debug(account.Name + ' is a test account: ' +  isTestAccount);//true

account.AnnualRevenue = 0;
String tier = accountservice.printAccountTier(account);
System.debug('With $0 in annual revenue, the account is in: ' + tier);//no tier
account.AnnualRevenue = 25000;
tier = accountservice.printAccountTier(account);
System.debug('With $25000 in annual revenue, the account is in: ' + tier);//silver tier
account.AnnualRevenue = 50000;
tier = accountservice.printAccountTier(account);
System.debug('With $50000 in annual revenue, the account is in: ' + tier);//golden tier
account.AnnualRevenue = 150000;
tier = accountservice.printAccountTier(account);
System.debug('With $100000 in annual revenue, the account is in: ' + tier);//golden tier
account.AnnualRevenue = 300000;
tier = accountservice.printAccountTier(account);
System.debug('With $300000 in annual revenue, the account is in: ' + tier);//VIP tier
account.AnnualRevenue = 350000;
tier = accountservice.printAccountTier(account);
System.debug('With $350000 in annual revenue, the account is in: ' + tier);//VIP tier

//---------------------------------------------------------------

OpportunityService opportunityService = new OpportunityService();
Opportunity opportunity1 = opportunityService.createNewOpportunity(account.Name + ' Opportunity', 'Closed Won', System.today(), 10000, account.Id);
Opportunity opportunity2 = opportunityService.createNewOpportunity();
opportunityService.insertOpportunity(opportunity1);
opportunityService.insertOpportunity(opportunity2);
System.debug(opportunity1);
System.debug(opportunity2);

opportunity2.Amount = 60000;
Decimal amount = opportunityService.calculateAmount(opportunity1, opportunity2);
System.debug('The combined amount of $' + opportunity1.Amount + ' + $' + opportunity2.Amount + ' is $' + amount);

opportunityService.doubleAmount(opportunity1);
opportunityService.doubleAmount(opportunity2);
System.debug('Double the amount field of ' + opportunity1.Name + ' is $' + opportunity1.Amount);
System.debug('Double the amount field of ' + opportunity2.Name + ' is $' + opportunity2.Amount);

opportunity1.Probability = 80;
opportunity2.Probability = 40;
Decimal probability = opportunityService.calculateProbability(opportunity1, opportunity2);
System.debug('The average probability of ' + opportunity1.Probability + '% + ' + opportunity2.Probability + '% is ' + probability + '%');

System.debug(opportunityService.getOpportunityDetails(opportunity1));
System.debug(opportunityService.getOpportunityDetails(opportunity2));

Boolean isOpportunity1Open = opportunityService.isOpen(opportunity1);
Boolean isOpportunity2Open = opportunityService.isOpen(opportunity2);
System.debug(opportunity1.Name + ' is open: ' + isOpportunity1Open);
System.debug(opportunity2.Name + ' is open: ' + isOpportunity2Open);

Opportunity opportunity3 = new Opportunity();
opportunity3 = opportunityService.softmerge(opportunity2, opportunity1);
System.debug(opportunityService.getOpportunityDetails(opportunity1));
System.debug(opportunityService.getOpportunityDetails(opportunity2));
System.debug(opportunityService.getOpportunityDetails(opportunity3));
