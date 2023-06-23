// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// Simple Lists: Task #1 - Preparation
//---------------------------------------------------------------
ListsPractice listsPractice = new ListsPractice();
System.debug(listsPractice.getRandomNumberInRange(1, 10));

// Simple Lists: Task #2 - Lists and Strings
//---------------------------------------------------------------
List<String> allColors = listsPractice.getAllColors();
System.debug(allColors);

List<String> allFruits = new List<String>();
allFruits.add('blueberry');
allFruits.add('peach');
allFruits.add('grapefruit'); 
allFruits.add('cranberry');
allFruits.add('orange');
allFruits.add('mango');
allFruits.add('kiwi');
System.debug(allFruits);

System.debug(listsPractice.getRandomStringFromList(allColors));
System.debug(listsPractice.getRandomStringFromList(allFruits));

System.debug(listsPractice.mergeTwoStringListsAndSort(allColors, allFruits));

System.debug(listsPractice.getFirstNCharacters('teststring', 20));
System.debug(listsPractice.getFirstNCharacters('teststring', 4));

// Simple Lists: Task #3 - Lists and Integers
//---------------------------------------------------------------
List<Integer> randomNumbers = listsPractice.getListWithFiveRandomNumbers();
System.debug(randomNumbers);
                
System.debug(listsPractice.isListSizeInRange(randomNumbers, 0, 10));
System.debug(listsPractice.isListSizeInRange(randomNumbers, 10, 5));
System.debug(listsPractice.isListSizeInRange(randomNumbers, 2, 2));
System.debug(listsPractice.isListSizeInRange(randomNumbers, -1, 5));
System.debug(listsPractice.isListSizeInRange(randomNumbers, 0, 6));

// Simple Lists: Task #4 - Lists and sObjects
//---------------------------------------------------------------
ContactService contactService = new ContactService();
List<Contact> twoContacts = contactService.insertTwoContactsWithAccounts();
System.debug(twoContacts);



// Lists & For Each Loops: Task #2 - Integer lists
//---------------------------------------------------------------
List<Integer> sumNumbers = new List<Integer> {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, -10};
System.debug(listsPractice.sumlist(sumNumbers));

List<Integer> smallestNumbers = new List<Integer> {10, 5, 32, 15, 1, 105, 20, 15, 3, 7};
System.debug(listsPractice.getSmallest(smallestNumbers));

// Lists & For Each Loops: Task #3 - Opportunties
//---------------------------------------------------------------
OpportunityService opportunityService = new OpportunityService();
System.debug(opportunityService.createOpportunities(5));

List<Opportunity> createdOpportunities = opportunityService.createOpportunities(20);
System.debug(createdOpportunities);
System.debug(opportunityService.filterOpportunitiesByStage(createdOpportunities, 'Prospecting'));

List<Opportunity> closedWonOpportunities = opportunityService.filterClosedWonOpportunities(createdOpportunities);
System.debug(closedWonOpportunities);

System.debug(opportunityService.calculateTotalRevenue(closedWonOpportunities));

// Lists & For Each Loops: Task #4 - Optional Task
//---------------------------------------------------------------
List<String> concatenateWords = new List<String> {'Convent', 'Thinly', 'Outfit', 'Drained', 'Retention', 'Obtain', 'Satchel', 'Abroad', 'Energy'};
System.debug(listsPractice.concatenateList(concatenateWords));

List<String> reverseWords = new List<String> {'igor', 'alex', 'john'};
System.debug(listsPractice.reverseWordsAndOrder(reverseWords));

System.debug(listsPractice.createNIntegers(10));
System.debug(listsPractice.createNIntegers(10));