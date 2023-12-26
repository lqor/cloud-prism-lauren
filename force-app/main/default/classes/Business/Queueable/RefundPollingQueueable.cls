public with sharing class RefundPollingQueueable implements Queueable, Database.AllowsCallouts {

    private static final Integer MAX_RETRY_ATTEMPTS = 3;

    private RefundCallout.RefundResponseBody refundResponse;
    private String refundId;
    private String token;

    public RefundPollingQueueable(RefundCallout.RefundResponseBody refundResponse) {
        this.refundResponse = refundResponse;
        this.refundId = refundResponse.refund_id;
        this.token = refundResponse.token;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the initiateRefundOrder method on the "ParticipantService"
     * class. It accepts a refund id sends a callout to the payment server to
     * generate an refund for the participant.
     */
    public void execute(QueueableContext context) {
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);
        Integer retryCount = AsyncInfo.getCurrentQueueableStackDepth();
        Integer delayInMinutes;
        String refundStatus = '';

        if(retryCount == 1) {
            delayInMinutes = 3;
        } else {
            delayInMinutes = 10;
        }

        try {
            refundStatus = RefundCallout.doGetRefundCalloutForParticipantByRefundId(refundId, token);
        } catch(Exception e) {
            refund.Status__c = RefundPostProcessingQueueable.REFUND_STATUS_FAILED;

            Logger logger = new Logger();
            logger.logException(e);
        }

        if(retryCount < MAX_RETRY_ATTEMPTS && refundStatus != RefundPostProcessingQueueable.REFUND_STATUS_REFUNDED) {
            System.enqueueJob(new RefundPollingQueueable(refundResponse), delayInMinutes);

            retryCount++;
        } else {
            System.enqueueJob(new RefundPostProcessingQueueable(refund, refundStatus, token));
        }
    } 

}