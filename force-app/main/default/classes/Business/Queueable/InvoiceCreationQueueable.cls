public with sharing class InvoiceCreationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Training__c> trainings;

    public InvoiceCreationQueueable(List<Training__c> trainings) {
        this.trainings = trainings;
    }

    /**
     * This method is part of the Participant payment handling process. It is
     * invoked from the enqueueInvoiceCreationJob method on the "ParticipantService"
     * class. It processes a list of trainings and sends a callout to the payment
     * server to generate an invoice for each registered participant.
     */
    public void execute(QueueableContext context) {
        for(Training__c training : trainings) {
            for(Participant__c participant : training.Participants__r) {
                try {
                    String responseBody = InvoiceCallout.doInvoiceCalloutForParticipant(participant, training);
                } catch(Exception e) {
                    Logger logger = new Logger();
                    logger.logException(e);
                }
            }
        }
    }

}