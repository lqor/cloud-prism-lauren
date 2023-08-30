public with sharing class Logger {

    /**
     * This method is part of the general logging process. It is called from the sendParticipantToERP method 
     * in the "ParticipantService" class and the execute method in the "RegistrationConfirmationQueueable" 
     * queueable class. It accepts an exception and inserts the error log.
     */
    public void logException(Exception e) {
        ErrorLog__c log = createErrorLog(e);
        insert log;
    }

    /**
     * This method is part of the API callout logging process. It is called from the sendParticipantToERP 
     * method in the "ParticipantService" class and the execute method in the "RegistrationConfirmationQueueable" 
     * queueable class. It accepts an exception and inserts the error log.
     */
    public void logCalloutException(Exception e) {
        ErrorLog__c log = createErrorLog(e);
        insert log;
    }

    private ErrorLog__c createErrorLog(Exception e) {
        ErrorLog__c log = new ErrorLog__c();

        log.ClassName__c = parseClassName(e.getStackTraceString());
        log.MethodName__c = parseMethodName(e.getStackTraceString());
        log.ExceptionType__c = e.getTypeName();
        log.ExceptionMessage__c = e.getMessage();
        log.LineNumber__c = e.getLineNumber();
        log.StackTrace__c = e.getStackTraceString();

        return log;
    }

    private String parseClassName(String trace) {
        return trace.split('\n')[0].substringBetween('.', '.');
    }

    private String parseMethodName(String trace) {
        return trace.split('\n')[0].substringAfterLast('.').substringBefore(':');
    }

}