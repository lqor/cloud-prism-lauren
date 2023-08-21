public with sharing class ErrorLogCleanupScheduled implements Schedulable {

    /**
     * This method is part of the API call error logging cleanup process. It is called from the UI as a scheduled job.
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ErrorLogCleanupBatch(), 200);
    }

}