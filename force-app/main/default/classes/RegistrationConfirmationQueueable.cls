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

        for(Training__c training : trainings) {
            PaymentLinkCallout.requestPaymentLink(training.Participants__r);

            for(Participant__c participant : training.Participants__r) {
                Messaging.SingleEmailMessage email = PaymentLinkCallout.sendPaymentEmail(training, participant);
                emails.add(email);
            }
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

}