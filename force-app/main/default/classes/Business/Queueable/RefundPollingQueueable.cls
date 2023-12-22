public with sharing class RefundPollingQueueable implements Queueable, Database.AllowsCallouts {

    private static final Integer MAX_RETRY_ATTEMPTS = 3;
    public static final String REFUND_STATUS_REFUNDED = 'Refunded';
    public static final String REFUND_STATUS_FAILED = 'Failed';


    private String refundId;

    public RefundPollingQueueable(String refundId) {
        this.refundId = refundId;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the initiateRefundOrder method on the "ParticipantService"
     * class. It accepts a refund id sends a callout to the payment server to
     * generate an refund for the participant.
     */
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Integer retryCount = AsyncInfo.getCurrentQueueableStackDepth();
        Integer delayInMinutes;
        String responseStatus = '';

        TrainingRefund__c refund = [
            SELECT Id, Status__c, VerificationId__c, Participant__c 
            FROM TrainingRefund__c 
            WHERE RefundId__c = :refundId
        ];

        if(retryCount == 1) {
            delayInMinutes = 3;
        } else {
            delayInMinutes = 10;
        }

        try {
            responseStatus = RefundCallout.doGetRefundCalloutForParticipantByRefundId(refundId);
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
            refund.Status__c = REFUND_STATUS_FAILED;
        }

        if(retryCount < MAX_RETRY_ATTEMPTS && responseStatus == '') {
            System.enqueueJob(new RefundPollingQueueable(refundId), delayInMinutes);
            
            retryCount++;
        } else if (responseStatus == REFUND_STATUS_REFUNDED) {
            refund.Status__c = REFUND_STATUS_REFUNDED;
            refund.verificationId__c = RefundCallout.doRefundVerificationCalloutForParticipant(refundId);

            // set Invoice record Status to Refunded

            Training__c training = TrainingQueries.queryTrainingByParticipantId(refund.Participant__c);
            Participant__c participant = new Participant__c();
            participant = training.Participants__r[0];

            emails.add(EmailService.createParticipantRefundProcessedEmail(training, participant));
        } else {
            refund.Status__c = REFUND_STATUS_FAILED;

            // set Invoice record Status to Failed
            // EmailService.cls - createRefundOrderFailureEmail()
            // Notify admin, Refund could not be refunded, include record link
            // Logger.cls - log failure, use new method to differentiate between system exceptions and refund notification
        }

        update refund;

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    } 

}