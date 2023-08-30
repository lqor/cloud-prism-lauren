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
                String responseBody = '';
                Logger logger = new Logger();

                try {
                    responseBody = PaymentLinkCallout.doPaymentCalloutForParticipant(participant);
                } catch(PaymentLinkCallout.NullParticipantException e) {
                    logger.logCalloutException(e);
                } catch(Exception e) {
                    logger.logException(e);
                }

                String link = PaymentLinkCallout.parsePaymentLink(responseBody);
                participant.PaymentLink__c = link;
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

}