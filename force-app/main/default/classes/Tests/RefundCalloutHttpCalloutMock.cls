@IsTest
public class RefundCalloutHttpCalloutMock implements HttpCalloutMock {

    public static final String REFUND_RESPONSE_ID = '6593d13bb051ac4daa1c39d0';
    public static final String REFUND_RESPONSE_STATUS = 'Refunded';
    public static final String VERIFICATION_RESPONSE_ID = '6583643bbf37a0d2e3cfe33e';
    @TestVisible
    private static Boolean IS_STATUS_REFUNDED = true;

    /**
     * This method is part of the Participant payment handling test process.
     * It is called from test classes and returns a mock API callout response.
     * 
     * @param request       HttpRequest JSON for refund creation and verification requests
     * @return HttpResponse JSON response containing access token or invoice job created message
     */
    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', InvoiceCallout.REQUEST_CONTENT_TYPE);
        response.setStatusCode(200);
        response.setStatus('OK');

        if(request.getEndpoint().endsWith(InvoiceCallout.REQUEST_ENDPOINT_AUTH)) {
            response.setBody('{"token":"' + InvoiceCalloutHttpCalloutMock.AUTH_RESPONSE_TOKEN + '"}');
        } else if(request.getEndpoint().endsWith(RefundCallout.REQUEST_ENDPOINT_REFUNDS)) {
            response.setBody(
                '{"refund_id":"' + REFUND_RESPONSE_ID + 
                '","status": "' + ParticipantService.REFUND_RESPONSE_STATUS_INITIATED + '"}'
            );
        } else if(request.getEndpoint().contains(RefundCallout.REQUEST_TOKEN_QUERY_PARAM)) {
            if(IS_STATUS_REFUNDED) {
                response.setBody('{"status": "' + REFUND_RESPONSE_STATUS + '"}');
            } else {
                response.setBody('{"status": "' + ParticipantService.REFUND_RESPONSE_STATUS_INITIATED + '"}');
            }
        } else if(request.getEndpoint().endsWith(RefundCallout.REQUEST_ENDPOINT_VERIFICATIONS)) {
            response.setBody('{"verification_id":"' + VERIFICATION_RESPONSE_ID + '"}');
        }

        return response;
    }

}