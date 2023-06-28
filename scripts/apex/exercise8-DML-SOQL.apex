// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Id accountId = '0013t00002iRjHlAAK';
ContactService contactService = new ContactService();
contactService.updateContactsPhoneByAccount(accountId, '555-555-5555');

OpportunityService opportunityService = new OpportunityService();
opportunityService.updateOpportunityCloseDates('Id. Decision Makers', 10);

opportunityService.closeOldOpportunities(-13);

List<Id> ids = new List<Id> {'0013t00002VbdOyAAJ', '0013t00002VbdP0AAJ', '0013t00002VbdOxAAJ'};
opportunityService.addDaysToOpportunities(ids, 10);

opportunityService.changeProbablityBasedOnAmount(900000);