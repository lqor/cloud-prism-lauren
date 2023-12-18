public class RegistrationConfirmationQueueable implements Queueable {

    private List<Training__c> trainings;

    public RegistrationConfirmationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant registration confirmation process.
     * It is invoked from the enqueueRegistrationConfirmationJob method on the
     * "ParticipantService" class. It processes a list of trainings and sends
     * confirmation emails to each registered participant.
     */
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                emails.add(EmailService.createParticipantConfirmationEmail(training, participant));
            }
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

}