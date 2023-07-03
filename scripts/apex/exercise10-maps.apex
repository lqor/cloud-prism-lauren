// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// MapsService
//---------------------------------------------------------------------
MapsService mapsService = new MapsService();

Map<String, Integer> map1 = new Map<String, Integer> {'one' => 1, 'two' => 2, 'three' => 3, 'four' => 4, 'five' => 5};
Map<String, Integer> map2 = new Map<String, Integer> {'six' => 6, 'seven' => 7, 'eight' => 8, 'nine' => 9, 'one' => 100};
System.debug('mergeMaps: ' + mapsService.mergeMaps(map1, map2));

System.debug('intersectKeys: ' + mapsService.intersectKeys(map1, map2));

Map<String, Integer> map3 = new Map<String, Integer> {
    'ten' => 10, 
    'twenty' => 20, 
    'thirty' => 30, 
    'forty' => 40, 
    'fifty' => 50
};
System.debug('filterByValue: ' + mapsService.filterByValue(map3, 30));

Map<String, String> map4 = new Map<String, String>();    
map4.put('100', 'one hundred');
map4.put('20', 'twenty');
map4.put('30', 'thirty');
map4.put('40', 'forty');
map4.put('50', 'fifty');
map4.put('60', 'sixty');
map4.put('70', 'seventy');
map4.put('80', 'eighty');
map4.put('90', 'ninety');
List<String> keys = new List<String> {'100', '90', '80', '70', '60', '50', '40', '30', '20', '10'};
System.debug('getValuesByKey: ' + mapsService.getValuesByKey(map4, keys));

String sentence = 'The method finds the most common word from the map of word counts';
List<String> words = new List<String> (sentence.split(' '));
System.debug('findMostCommon: ' + mapsService.findMostCommon(words));

System.debug('countWords: ' + mapsService.countWords(words));

System.debug('findKeyByValue: ' + mapsService.findKeyByValue(map3, 20));
System.debug('findKeyByValue: ' + mapsService.findKeyByValue(map3, 99));

List<String> keysToRemove = new List<String> {'twenty', 'forty', 'sixty'};
System.debug('removeEntriesByKey: ' + mapsService.removeEntriesByKey(map3, keysToRemove));


// OpportunityService
//---------------------------------------------------------------------
OpportunityService opportunityService = new OpportunityService();
List<Opportunity> opportunitiesByStage = opportunityService.createOpportunities(20);

for(Opportunity opportunity : opportunitiesByStage) {
    System.debug(opportunity.StageName);
}
System.debug(opportunityService.summarizeOpportunityStages(opportunitiesByStage));


List<Opportunity> opportunitiesPerAccount = [
    SELECT AccountId, Name 
    FROM Opportunity 
    WHERE Name LIKE 'United%' OR Name LIKE 'Edge%'
];
for(Opportunity opportunity : opportunitiesPerAccount) {
    System.debug(opportunity.AccountId + ' & ' + opportunity.Name);
}

System.debug(opportunityService.countOpportunitiesPerAccount(opportunitiesPerAccount));


// AccountService
//---------------------------------------------------------------------
AccountService accountService = new AccountService();
List<Account> allAccounts = new List<Account>();

for(Integer i = 0; i < 5; i++) {
    List<Account> twoAccounts = accountService.createTwoAccounts();
    allAccounts.addAll(twoAccounts);
}
for(Account account : allAccounts) {
  	account.Industry = accountService.getRandomIndustry();
}

Map<String, List<Account>> accountsByIndustry = accountService.createIndustryMap(allAccounts);
System.debug(accountsByIndustry.keySet());

List<String> industries = new List<String> {
    'Chemicals', 
	'Entertainment',
	'Government', 
	'Media', 
	'Not For Profit', 
	'Technology', 
	'Utilities'
};
    
for(String industry : industries) {
  	System.debug('Industry: ' + industry + ': ' + accountsByIndustry.get(industry));
}

AccountService accountService = new AccountService();
List<Account> allAccounts = [
    SELECT Id, Description 
    FROM Account 
    WHERE (BillingCity = 'Osaka' OR BillingCity = 'Tokyo') OR Name LIKE 'Burlington%'
];
System.debug(allAccounts);

Set<Id> accountIds = (new Map<Id, Account> (allAccounts)).keySet();
//Set<Id> accountIds = (new Map<Id, Account> (accounts)).keySet()
System.debug(accountIds);

List<Contact> relatedContacts = [SELECT Name, AccountId FROM Contact WHERE AccountId IN :accountIds];
System.debug(relatedContacts);
List<Contact> contacts0 = new List<Contact>{relatedContacts.get(0), relatedContacts.get(1)};
List<Contact> contacts1 = new List<Contact>{relatedContacts.get(2), relatedContacts.get(3)};
List<Contact> contacts2 = new List<Contact>{relatedContacts.get(4)};

Map<String, List<Contact>> contactMap = new Map<String,List<Contact>>();
contactMap.put(relatedContacts.get(0).AccountId, contacts0);
contactMap.put(relatedContacts.get(2).AccountId, contacts1);
contactMap.put(relatedContacts.get(4).AccountId, contacts2);
System.debug(contactMap);

AccountService accountService = new AccountService();
accountService.updateAccountsWithContacts();
