// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

System.debug(opportunityQueries.queryOpportunitiesByStage('Closed Won'));

System.debug(opportunityQueries.queryOpportunitiesByAmountAndStage(10000, 'Closed Won'));

Date startDate = Date.TODAY().addDays(-30);
Date endDate = Date.TODAY();
System.debug(opportunityQueries.queryOpportunitiesByCreatedDate(startDate, endDate));

System.debug(opportunityQueries.queryOpportunitiesByAmount(10000));

Date closeDate = Date.TODAY();
System.debug(opportunityQueries.queryOpportunitiesByCloseDate(closeDate));

opportunityQueries.changeProbablityBasedOnAmount(10000);