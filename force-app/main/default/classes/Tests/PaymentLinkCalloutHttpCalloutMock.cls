@IsTest
public class PaymentLinkCalloutHttpCalloutMock implements HttpCalloutMock {

    public static final String PAYMENT_LINK = 'https://pry.me/p/1688117280';

    /**
     * This method is part of the Participant registration confirmation test 
     * process. It is called from test classes and returns a mock API callout 
     * response with payment link.
     */
    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"payer":{"link":"' + PAYMENT_LINK + '"}}');

        return response;
    }

}