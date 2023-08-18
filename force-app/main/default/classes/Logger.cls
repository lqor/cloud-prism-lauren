public with sharing class Logger {

    /**
     * This method is part of the API call error logging process. It is called from the "SendParticipantToERP" 
     * class, the "ParticipantSyncBatch" batchable class, and the "RegistrationConfirmationQueueable" queueable 
     * class. It accepts an exception and inserts the error log.
     */
    public void logException(Exception e) {
        ErrorLog__c log = new ErrorLog__c();

        log.ClassName__c = parseClassName(e.getStackTraceString());
        log.MethodName__c = parseMethodName(e.getStackTraceString());
        log.ExceptionType__c = e.getTypeName();
        log.ExceptionMessage__c = e.getMessage();
        log.LineNumber__c = e.getLineNumber();
        log.StackTrace__c = e.getStackTraceString();

        insert log;
    }

    private String parseClassName(String trace) {
        return trace.split('\n')[0].substringBetween('.', '.');
    }

    private String parseMethodName(String trace) {
        return trace.split('\n')[0].substringAfterLast('.').substringBefore(':');
    }

}