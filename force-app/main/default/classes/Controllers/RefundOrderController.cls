public with sharing class RefundOrderController {

    public virtual class RefundOrderControllerException extends Exception {}
    public class EmptyParticipantIdException extends RefundOrderControllerException {}

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the RequestRefund quick action button
     * 
     * @param participantId Id of participant requesting the refund
     * @param reason        Reason for refund, if provided
     * @return String       Refund id as confirmation the order was received
     */
    @AuraEnabled
    public static String submitRefundForParticipant(Id participantId, String reason) {
        if(participantId == null) {
            throw new EmptyParticipantIdException('Empty Participant Id.Please ensure this component is attached to a Participant record page');
        }

        ParticipantService participantService = new ParticipantService();
        String refundId = participantService.initiateRefundOrder(participantId, reason);

        return refundId;
    }

}