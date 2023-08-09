public class RegistrationConfirmationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Training__c> trainings;

    public RegistrationConfirmationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable," which is called from the "ParticipantService" 
     * class.
     */
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                HttpResponse response = PaymentLinkCallout.doPaymentCalloutForParticipant(participant);
                String paymentLink = parsePaymentLink(response);
                System.debug('paymentLink: ' + paymentLink);
                participant.PaymentLink__c = paymentLink;
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

    private String parsePaymentLink(HttpResponse response) {
        String paymentLink = '';

        Map<String, Object> paymentObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
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