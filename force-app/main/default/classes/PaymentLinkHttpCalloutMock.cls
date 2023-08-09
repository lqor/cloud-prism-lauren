@IsTest
public class PaymentLinkHttpCalloutMock implements HttpCalloutMock {

    public static final String PAYMENT_LINK = 'https://pry.me/p/1688117280';

    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"payer":{"link":"' + PAYMENT_LINK + '"}}');

        return response; 
    }

}