public class PaymentLinkCallout {

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_ENDPOINT = 'https://735ef563-176d-431c-85ce-2cc07056ef03.mock.pstmn.io/payments/link';
    public static final Integer RESPONSE_STATUS_CODE_200 = 200;

    public static HttpResponse doPaymentCalloutForParticipant(Participant__c participant) {
        HttpRequest request = new HttpRequest();
        request.setMethod(REQUEST_METHOD_GET);
        request.setEndpoint(REQUEST_ENDPOINT);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Id', participant.Id);
        Http http = new Http();

        return http.send(request);
    }


}