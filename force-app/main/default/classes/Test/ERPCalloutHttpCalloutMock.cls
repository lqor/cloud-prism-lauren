@IsTest
public class ERPCalloutHttpCalloutMock implements HttpCalloutMock {

    public static final String ERP_ID = '99';

    /**
     * This method is part of the Participant to ERP syncing test process. It is called from test classes and 
     * returns a mock API callout response with ERP Id.
     */
    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"erpId":"' + ERP_ID + '"}');

        return response;
    }

}