public with sharing class InvoiceCreationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Training__c> trainings;

    public InvoiceCreationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant invoice creation process. It is invoked from the enqueueInvoiceCreationJob 
     * method on the "ParticipantService" class. It processes a list of trainings and sends a callout to the payment 
     * server to generate an invoice for each registered participant.
     */
    public void execute(QueueableContext context) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                String responseBody = '';
                Logger logger = new Logger();

                try {
                    responseBody = InvoiceCallout.doInvoiceCalloutForParticipant(training, participant);
                } catch(Exception e) {
                    logger.logException(e);
                }
            }
        }
    }

}