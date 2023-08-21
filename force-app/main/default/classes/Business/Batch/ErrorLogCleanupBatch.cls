public with sharing class ErrorLogCleanupBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        ErrorLogCleanupMetadata__mdt ErrorLogCleanupMdt = ErrorLogCleanupMetadataQueries.queryErrorLogCleanupMetadata();
        Date retentionDate = System.today().addDays(ErrorLogCleanupMdt.RetentionDays__c.intValue() * -1);

        String querySelect = 'SELECT Id, CreatedDate, Important__c ';
        String queryFrom = 'FROM ErrorLog__c ';
        String queryWhere = 'WHERE CreatedDate < :retentionDate AND Important__c = false';
        String query = querySelect + queryFrom + queryWhere;

        return Database.getQueryLocator(query);
    }

    /**
     * This method is part of the API call error logging cleanup process. It is called from the scheduled class,
     * "ErrorLogCleanupScheduled." It deletes all records older than the specified retention period.
     */
    public void execute(Database.BatchableContext bc, List<ErrorLog__c> errorLogs) {
        if(!errorLogs.isEmpty()) {
            delete errorLogs;
            DataBase.emptyRecycleBin(errorLogs);
        }
    }

    public void finish(Database.BatchableContext bc) {}

}