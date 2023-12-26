@RestResource(urlMapping='/invoices/*') 
global with sharing class InvoiceRestService {

    /**
     * Part of the Participant payment handling process, this method is invoked
     * via an HTTP POST request. It receives invoice data as a JSON payload
     * from the payment server and submits the queueable Apex job,
     * "InvoicePostProcessingQueueable."
     */
    @HttpPost
    global static void doStartInvoiceProcessing() {
        try {
            String requestBody = RestContext.request.requestBody.toString();
            InvoiceRequestBody parsedInvoice = parseInvoice(requestBody);

            Id invJobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }
    }

    @TestVisible 
    private static InvoiceRequestBody parseInvoice(String requestBody) {
        InvoiceRequestBody invoiceRequest = new InvoiceRequestBody();

        try {
            invoiceRequest = (InvoiceRequestBody) JSON.deserialize(requestBody, InvoiceRequestBody.class);
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }

        return invoiceRequest;
    }

    public class InvoiceRequestBody {
        public String invoice_id;
        public String participant_id;
        public String payment_id;
        public String payment_link;
        public String status;
        public String item_name;
        public String description;
        public Double price;
        public Double tax;
        public String token;
        public String callback_url;
        public String session_id;
    }

}