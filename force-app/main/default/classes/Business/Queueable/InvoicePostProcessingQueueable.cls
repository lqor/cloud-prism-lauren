public with sharing class InvoicePostProcessingQueueable implements Queueable {

    public static final String INVOICE_STATUS_CREATED = 'Created';
    public static final String INVOICE_STATUS_PAID = 'Paid';
    public static final String INVOICE_STATUS_FAILED = 'Failed';
    public static final String INVOICE_STATUS_REFUNDED = 'Refunded';
    public static final String PARTICIPANT_STATUS_ACTIVE = 'Active';

    private InvoiceRestService.InvoiceRequestBody parsedInvoice;
    
    public InvoicePostProcessingQueueable(InvoiceRestService.InvoiceRequestBody parsedInvoice) {
        this.parsedInvoice = parsedInvoice;
    }

    public void execute(QueueableContext context) {
        TrainingInvoice__c invoice = new TrainingInvoice__c();
        Participant__c participant = new Participant__c();

        if(parsedInvoice.status == INVOICE_STATUS_CREATED) {
            Id participantId = parsedInvoice.participant_id;

            Training__c training = TrainingQueries.queryTrainingByParticipantId(participantId);

            invoice.InvoiceDate__c = System.today();
            invoice.InvoiceId__c = parsedInvoice.invoice_id;
            invoice.Participant__c = parsedInvoice.participant_id;
            invoice.PaymentId__c = parsedInvoice.payment_id;
            invoice.PaymentLink__c = parsedInvoice.payment_link;
            invoice.Status__c = parsedInvoice.status;
            invoice.GrandTotal__c = parsedInvoice.price;
            invoice.Tax__c = parsedInvoice.tax;
            invoice.Training__c = training.Id;

            participant = training.Participants__r[0];
            participant.PaymentLink__c = parsedInvoice.payment_link;

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            emails.add(EmailService.createParticipantPaymentEmail(training, participant));

            if(!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } else if(parsedInvoice.status == INVOICE_STATUS_PAID) {
            invoice.PaymentDate__c = System.today();
            invoice.InvoiceId__c = parsedInvoice.invoice_id;
            invoice.Status__c = parsedInvoice.status;

            participant = ParticipantQueries.queryParticipantByInvoiceId(parsedInvoice.invoice_id);
            participant.Status__c = PARTICIPANT_STATUS_ACTIVE;
        } 

        try {
            upsert invoice InvoiceId__c;

            update participant;
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }
    }

}