@RestResource(urlMapping='/invoices/*') 
global with sharing class InvoiceRestService {

    public virtual class InvoiceRestServiceException extends Exception {}
    public class InvoiceProcessingErrorException extends InvoiceRestServiceException {}



    /**
     * Part of the Participant payment handling process, this method is invoked
     * via an HTTP POST request. It receives invoice data as a JSON payload from
     * the payment server and submits the queueable Apex job,
     * "InvoicePostProcessingQueueable."
     */
    @HttpPost
    global static void doStartInvoiceProcessing() {
        String requestBody = RestContext.request.requestBody.toString();
        InvoiceRequestBody parsedInvoice = parseInvoice(requestBody);

        try {
            Id invJobId = System.enqueueJob(new InvoicePostProcessingQueueable(parsedInvoice));
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }
    }

    @TestVisible 
    private static InvoiceRequestBody parseInvoice(String requestBody) {
        if(requestBody == null || requestBody == '') {
            throw new InvoiceProcessingErrorException('Unable to process invoice: Request body is null');
        }

        InvoiceRequestBody invoiceRequest = (InvoiceRequestBody) JSON.deserialize(requestBody, InvoiceRequestBody.class);

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