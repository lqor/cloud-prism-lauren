public with sharing class RefundPostProcessingQueueable implements Queueable, Database.AllowsCallouts {

    public static final String REFUND_STATUS_FAILED = 'Failed';
    public static final String REFUND_STATUS_REFUNDED = 'Refunded';

    private TrainingRefund__c refund;
    private String refundId;
    private String refundStatus;
    private String token;
    private String invoiceId;

    public RefundPostProcessingQueueable(TrainingRefund__c refund, String refundStatus, String token) {
        this.refund = refund;
        this.refundId = refund.RefundId__c;
        this.refundStatus = refundStatus;
        this.token = token;
        this.invoiceId = refund.TrainingInvoice__r.InvoiceId__c;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPollingQueueable" queueable
     * class. It accepts a training refund object, refund status, and token to
     * process the refund and related tasks.
     */
    public void execute(QueueableContext context) {
        TrainingInvoice__c invoice = TrainingInvoiceQueries.queryInvoiceByInvoiceId(invoiceId);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Logger logger = new Logger();

        if(refundStatus == REFUND_STATUS_REFUNDED) {
            refund.Status__c = REFUND_STATUS_REFUNDED;
            invoice.Status__c = REFUND_STATUS_REFUNDED;

            emails.add(EmailService.createParticipantRefundProcessedEmail(invoice));

            try {
                refund.verificationId__c = RefundCallout.doRefundVerificationCalloutForParticipant(refundId, token);
            } catch(Exception e) {
                logger.logException(e);
            }
        } else {
            refund.Status__c = REFUND_STATUS_FAILED;

            emails.add(EmailService.createRefundOrderFailedEmail(refund));

            logger.logRefundOrderFailed(refund);
        }

        try {
            update refund;
            update invoice;

            if(!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } catch(Exception e) {
            logger.logException(e);
        }
    }

}