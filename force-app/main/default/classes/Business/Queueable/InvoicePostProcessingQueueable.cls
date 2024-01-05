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

    /**
     * This method is part of the Participant payment handling process and
     * contains the invoice processing logic. It is invoked from the method,
     * doStartInvoiceProcessing, on the "InvoiceRestService" REST resource
     * class. It receives the parsed invoice data and creates or updates
     * invoices and related participant records.
     */
    public void execute(QueueableContext context) {
        TrainingInvoice__c invoice = new TrainingInvoice__c();
        Participant__c participant = new Participant__c();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        if(parsedInvoice.status == INVOICE_STATUS_CREATED) {
            Id participantId = parsedInvoice.participant_id;

            Training__c training = TrainingQueries.queryTrainingByParticipantId(participantId);

            invoice = createInvoice(parsedInvoice, training);

            participant = training.Participants__r[0];
            participant.PaymentLink__c = parsedInvoice.payment_link;

            emails.add(EmailService.createParticipantPaymentEmail(training, participant));
        } else if(parsedInvoice.status == INVOICE_STATUS_PAID) {
            invoice = updateInvoice(parsedInvoice);

            participant = ParticipantQueries.queryParticipantByInvoiceId(parsedInvoice.invoice_id);
            participant.Status__c = PARTICIPANT_STATUS_ACTIVE;
        }

        try {
            upsert invoice InvoiceId__c;
            update participant;

            if(!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }
    }

    private TrainingInvoice__c createInvoice(InvoiceRestService.InvoiceRequestBody parsedInvoice, Training__c training) {
        TrainingInvoice__c invoiceToCreate = new TrainingInvoice__c();

        invoiceToCreate.InvoiceDate__c = System.today();
        invoiceToCreate.InvoiceId__c = parsedInvoice.invoice_id;
        invoiceToCreate.Participant__c = parsedInvoice.participant_id;
        invoiceToCreate.PaymentId__c = parsedInvoice.payment_id;
        invoiceToCreate.PaymentLink__c = parsedInvoice.payment_link;
        invoiceToCreate.Status__c = parsedInvoice.status;
        invoiceToCreate.GrandTotal__c = parsedInvoice.price;
        invoiceToCreate.Tax__c = parsedInvoice.tax;
        invoiceToCreate.Training__c = training.Id;

        return invoiceToCreate;
    }

    private TrainingInvoice__c updateInvoice(InvoiceRestService.InvoiceRequestBody parsedInvoice) {
        TrainingInvoice__c invoiceToUpdate = new TrainingInvoice__c();

        invoiceToUpdate.PaymentDate__c = System.today();
        invoiceToUpdate.InvoiceId__c = parsedInvoice.invoice_id;
        invoiceToUpdate.Status__c = parsedInvoice.status;

        return invoiceToUpdate;
    }

}