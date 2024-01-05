public with sharing class RefundOrderController {

    public virtual class RefundOrderControllerException extends Exception {}
    public class NullParticipantIdException extends RefundOrderControllerException {}

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the RequestRefund quick action button.
     * 
     * @param participantId Id of participant requesting the refund
     * @param reason        Reason for refund, optional if provided
     * @return String       Name of the invoice being refunded
     */
    @AuraEnabled
    public static String submitRefundForParticipant(Id participantId, String reason) {
        if(participantId == null) {
            throw new NullParticipantIdException('Empty Participant Id. Please ensure this component is attached to a Participant record page');
        }

        return new ParticipantService().initiateRefundOrder(participantId, reason);
    }

}