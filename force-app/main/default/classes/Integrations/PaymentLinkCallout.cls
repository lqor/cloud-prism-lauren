public class PaymentLinkCallout {

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_ENDPOINT = 'https://735ef563-176d-431c-85ce-2cc07056ef03.mock.pstmn.io/payments/link';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable." It sends the API request for generating the 
     * payment link and returns the JSON response body.
     * 
     * @param participant  Participant that has registered for training
     */
    public static String doPaymentCalloutForParticipant(Participant__c participant) {
        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_GET);
        request.setEndpoint(REQUEST_ENDPOINT);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setHeader('Id', participant.Id);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getBody();
    }

}