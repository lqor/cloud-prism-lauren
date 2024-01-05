@IsTest
public class InvoiceCalloutHttpCalloutMock implements HttpCalloutMock {

    public static final String AUTH_RESPONSE_TOKEN = 'ebQA5yRwVmkM5LBuuMYuYU';
    public static final String INVOICE_RESPONSE_MESSAGE = 'Invoice job created. Will send webhook to Salesforce shortly';

    /**
     * This method is part of the Participant payment handling test process.
     * It is called from test classes and returns a mock API callout response.
     * 
     * @param request       HttpRequest JSON for authentication or invoice creation requests
     * @return HttpResponse JSON response containing access token or invoice job created message
     */
    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', InvoiceCallout.REQUEST_CONTENT_TYPE);
        response.setStatusCode(200);
        response.setStatus('OK');

        if(request.getEndpoint().endsWith(InvoiceCallout.REQUEST_ENDPOINT_AUTH)) {
            response.setBody('{"token":"' + AUTH_RESPONSE_TOKEN + '"}');
        } else if(request.getEndpoint().endsWith(InvoiceCallout.REQUEST_ENDPOINT_INVOICES)) {
            response.setBody('{"message":"' + INVOICE_RESPONSE_MESSAGE + '"}');
        }

        return response;
    }

}