public class RegistrationConfirmationQueueable implements Queueable {

    private List<Training__c> trainings; 

    public RegistrationConfirmationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable."
     */
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                Messaging.SingleEmailMessage email = EmailService.createParticipantConfirmationEmail(
                    training, 
                    participant
                );

                emails.add(email);
            }
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

}