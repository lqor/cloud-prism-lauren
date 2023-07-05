// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// OpportunityService Insert
//----------------------------------------------------------------------------
OpportunityService opportunityService = new OpportunityService();
Opportunity opportunityToInsert = new Opportunity();

opportunityToInsert.Name = 'Test opp inheritance 5.0'; 
opportunityToInsert.StageName = 'Prospecting'; 
opportunityToInsert.CloseDate = System.today().addDays(5);

opportunityService.formatRecord(opportunityToInsert);
opportunityService.insertObject(opportunityToInsert);

Contact conToInsert = new Contact();
opportunityService.formatRecord(conToInsert);
opportunityService.insertObject(conToInsert);
opportunityService.formatRecord(null);
opportunityService.insertObject(null);

// OpportunityService Update
//----------------------------------------------------------------------------
OpportunityService opportunityService = new OpportunityService();
Opportunity opportunityToUpdate = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name LIKE '%5.0'];

opportunityToUpdate.Name = 'test  opp - Inherit five-0 x'; 
opportunityToUpdate.StageName = 'Closed Won'; 
opportunityToUpdate.CloseDate = System.today().addDays(5);

opportunityService.formatRecord(opportunityToUpdate);
opportunityService.updateObject(opportunityToUpdate);

Contact conToUpdate = new Contact();
opportunityService.updateObject(conToUpdate);
opportunityService.updateObject(null);


// ContactService Insert
//----------------------------------------------------------------------------
ContactService contactService = new ContactService();
Contact contactToInsert = new Contact();

contactToInsert.FirstName = 'ron  cephas '; 
contactToInsert.LastName = ' Jones'; 
contactToInsert.Sign_Up_Date__c = System.today();

contactService.formatRecord(contactToInsert);
contactService.insertObject(contactToInsert);

Account accToInsert = new Account();
contactService.formatRecord(accToInsert);
contactService.insertObject(accToInsert);
contactService.formatRecord(null);
contactService.insertObject(null);

// ContactService Update
//----------------------------------------------------------------------------
ContactService contactService = new ContactService();

Contact contactToUpdate = [SELECT FirstName, LastName, Sign_Up_Date__c FROM Contact WHERE Name LIKE '%cephas%'];

contactToUpdate.FirstName = 'Jasmine  monica a. '; 
contactToUpdate.LastName = ' cephas  Jones'; 
contactToUpdate.Sign_Up_Date__c = System.today();

contactService.formatRecord(contactToUpdate);
contactService.updateObject(contactToUpdate);

Account accToUpdate = new Account();
contactService.updateObject(accToUpdate);
contactService.updateObject(null);


// AccountService Insert
//----------------------------------------------------------------------------
AccountService accountService = new AccountService();
Account accountToInsert = new Account();

accountToInsert.Name = 'e  corp '; 

accountService.formatRecord(accountToInsert);
accountService.insertObject(accountToInsert);

Opportunity oppToInsert = new Opportunity();
accountService.formatRecord(oppToInsert);
accountService.insertObject(oppToInsert);
accountService.formatRecord(null);
accountService.insertObject(null);

// AccountService Update
//----------------------------------------------------------------------------
AccountService accountService = new AccountService();
Account accountToUpdate = [SELECT FirstName, LastName, Sign_Up_Date__c FROM Contact WHERE Name LIKE '%cephas%'];

accountToUpdate.Name = ' evil  corp'; 

accountService.formatRecord(accountToUpdate);
accountService.updateObject(accountToUpdate);

Opportunity oppToUpdate = new Opportunity();
accountService.updateObject(oppToUpdate);
accountService.updateObject(null);


// SObjectService FilterRecords
//----------------------------------------------------------------------------
Account acc1 = new Account (Name = 'Acme Corp', Industry = 'Technology', AnnualRevenue = 5000000);
Account acc2 = new Account (Name = 'Beta Inc', Industry = 'Manufacturing', AnnualRevenue = 3000000);
Account acc3 = new Account (Name ='Gamma LLC', Industry = 'Technology', AnnualRevenue = 10000000);

List<Account> accounts = new List<Account> {acc1, acc2, acc3};
Map<String, Object> accFilters = new Map<String, Object> {'Industry' => 'Technology', 'AnnualRevenue' => 5000000};
        
AccountService accService = new AccountService();
List<Account> filteredAcctRecords = accService.filterRecords(accounts, accFilters);
System.debug(filteredAcctRecords);


Opportunity opp1 = new Opportunity (Name = 'Acme Corp Opp', StageName = 'Qualification', Amount = 55000);
Opportunity opp2 = new Opportunity (Name = 'Beta Inc Opp', StageName = 'Closed Won', Amount = 300000);
Opportunity opp3 = new Opportunity (Name ='Gamma LLC Opp', StageName = 'Closed Won', Amount = 100000);

List<Opportunity> opportunities = new List<Opportunity> {opp1, opp2, opp3};
Map<String, Object> oppFilters = new Map<String, Object> {'StageName' => 'Closed Won', 'Amount' => 100000};
        
OpportunityService oppService = new OpportunityService();
List<Opportunity> filteredOppRecords = oppService.filterRecords(opportunities, oppFilters);
System.debug(filteredOppRecords);