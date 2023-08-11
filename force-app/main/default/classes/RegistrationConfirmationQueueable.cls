public class RegistrationConfirmationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Training__c> trainings;

    public RegistrationConfirmationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * "ParticipantService" class. It sends the confirmation emails and updates each participant with  
     * their unique payment link.
     */
    public void execute(QueueableContext context) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                String responseBody = PaymentLinkCallout.doPaymentCalloutForParticipant(participant);
                participant.PaymentLink__c = parsePaymentLink(responseBody);
                participantsToUpdate.add(participant);

                emails.add(EmailService.createParticipantConfirmationEmail(training, participant));
            }
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }

    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable." It returns the payment link or an empty 
     * string if the expected data is not found.
     * 
     * @param responseBody  JSON body of response from API call
     */
    @TestVisible 
    private String parsePaymentLink(String responseBody) {
        Map<String, Object> paymentObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(!paymentObject.containsKey('payer')) {
            return '';
        }

        Map<String, Object> payer = (Map<String, Object>) paymentObject.get('payer');
        if(!payer.containsKey('link')) {
            return '';
            
        }

        return (String) payer.get('link');
    }

}
