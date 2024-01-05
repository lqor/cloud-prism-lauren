public with sharing class Logger {

    /**
     * This method is part of the general logging process. It is called from the
     * sendParticipantToERP method in the "ParticipantService" class and the
     * execute method in the "RegistrationConfirmationQueueable" queueable class.
     * It accepts an exception and inserts the error log.
     */
    public void logException(Exception e) {
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

    /**
     * This method is part of the ERP callout logging process. It is called
     * from the sendParticipantToERP and getParticipantFromERP methods in the
     * "ParticipantService" class, which are invoked from both flow and batch
     * processes. It accepts an exception and inserts the
     * error log.
     */
    public void logERPCalloutException(Exception e) {
        ErrorLog__c log = createErrorLog(e);
        
        String commentPartOne = 'Participant JSON or ERP Id string was empty. ';
        String commentPartTwo = 'This logs an exception that is part of either a flow or batch. ';
        String commentPartThree = 'Check if flow submits the correct participant obj.';
        log.Comments__c = commentPartOne + commentPartTwo + commentPartThree;

        insert log;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * called from the execute method in the "RefundPostProcessingQueueable"
     * queueable class. It accepts an exception and inserts the error log.
     * 
     * @param refund        Refund details to create the log
     */
    public void logRefundOrderFailed(TrainingRefund__c refund) {
        ErrorLog__c log = createRefundFailureLog(refund);

        insert log;
    }

    private ErrorLog__c createRefundFailureLog(TrainingRefund__c refund) {
        ErrorLog__c log = new ErrorLog__c();

        log.ClassName__c = 'RefundPostProcessingQueueable';
        log.MethodName__c = 'execute';
        log.ExceptionType__c = 'Refund Order Failed';
        log.ExceptionMessage__c = 'Refund processing for ' + refund.Name + ' stalled after three attempts to poll the server.';
        log.Important__c = true;
        log.Comments__c = JSON.serialize(refund);

        return log;
    }

}