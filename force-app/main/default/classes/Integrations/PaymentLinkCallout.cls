public class PaymentLinkCallout {

    public virtual class PaymentLinkCalloutException extends Exception {}
    public class NullParticipantException extends PaymentLinkCalloutException {}

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_ENDPOINT = 'callout:MockPaymentProvider';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';

    /**
     * This method is part of the Participant registration confirmation process
     * (deprecated). It is invoked from the execute method on the queueable 
     * class, "RegistrationConfirmationQueueable." It sends the API request for 
     * generating the payment link.
     * 
     * @param participant   Participant that has registered for training
     * @return String       JSON response body             
     */
    public static String doPaymentCalloutForParticipant(Participant__c participant) {
        if(participant == null) {
            throw new NullParticipantException('Participant is null');
        }

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_GET);
        request.setEndpoint(REQUEST_ENDPOINT);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setHeader('Id', participant.Id);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getBody();
    }

    /**
     * This method is part of the Participant registration confirmation process
     * (deprecated). It is invoked from the execute method on the queueable 
     * class, "RegistrationConfirmationQueueable." 
     * 
     * @param responseBody  JSON body of response from API call
     * @return String       Parsed payment link or empty string if the expected data is not found
     */
    public static String parsePaymentLink(String responseBody) {
        PaymentResponse paymentResponse = (PaymentResponse) JSON.deserialize(responseBody, PaymentResponse.class);

        if(paymentResponse.payer == null || paymentResponse.payer.link == null) {
            return '';
        }

        return paymentResponse.payer.link;
    }

    public class PaymentResponse {
        public Payer payer;
    }

    public class Payer {
        public String link;
    }

}