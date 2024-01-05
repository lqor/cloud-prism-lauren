public with sharing class RefundPollingQueueable implements Queueable, Database.AllowsCallouts {

    private static final Integer MAX_RETRY_ATTEMPTS = 3;
    @TestVisible
    private static Boolean DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT = true;
    @TestVisible
    private static Boolean SET_RETRY_COUNT_3_FOR_TEST = false;

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
     * class. It accepts a refund response body object and sends a callout to
     * the payment server to generate a refund for the participant.
     */
    public void execute(QueueableContext context) {
        Integer retryCount = SET_RETRY_COUNT_3_FOR_TEST ? 3 : AsyncInfo.getCurrentQueueableStackDepth();
        Integer delayInMinutes;
        String refundStatus = '';
        String statusRefunded = RefundPostProcessingQueueable.REFUND_STATUS_REFUNDED;
        String statusFailed = RefundPostProcessingQueueable.REFUND_STATUS_FAILED;
        TrainingRefund__c refund = TrainingRefundQueries.queryRefundByRefundId(refundId);

        if(retryCount == 1) {
            delayInMinutes = 3;
        } else {
            delayInMinutes = 10;
        }

        try {
            refundStatus = RefundCallout.doGetRefundCalloutForParticipantByRefundId(refundId, token);

            if(retryCount < MAX_RETRY_ATTEMPTS && refundStatus != statusRefunded) {
                if(DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT) {
                    System.enqueueJob(new RefundPollingQueueable(refundResponse), delayInMinutes);
                }

                retryCount++;
            } else {
                if(DO_CHAIN_JOBS_FOR_NON_TEST_CONTEXT) {
                    System.enqueueJob(new RefundPostProcessingQueueable(refund, refundStatus, token));
                }
            }
        } catch(Exception e) {
            refund.Status__c = statusFailed;
            update refund;

            Logger logger = new Logger();
            logger.logException(e);
        }
    } 

}