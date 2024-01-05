public with sharing class InvoiceCallout {

    public virtual class InvoiceCalloutException extends Exception {}
    public class NullAuthenticationResponseException extends InvoiceCalloutException {}
    public class InvalidTokenResponseException extends InvoiceCalloutException {}
    public class InvalidParticipantOrTrainingException extends InvoiceCalloutException {}

    public static final String REQUEST_METHOD_POST = 'POST';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';
    public static final String REQUEST_BASE_URL = 'callout:MockPaymentGateway';
    public static final String REQUEST_ENDPOINT_AUTH = '/auth';
    public static final String REQUEST_ENDPOINT_INVOICES = '/invoices/';

    /**
     * This method is part of the Participant payment/refund handling process.
     * It is invoked from the doInvoiceCalloutForParticipant method of this
     * class and the doRefundCalloutForParticipant method of the RefundCallout
     * class. It sends the API request for authenticating to the payment server.
     * 
     * @return String       Parsed access token
     */
    public static String doAuthenticationCalloutForPayment() {
        String requestBodyJSON = serializeAuthRequestBody();

        HttpRequest request = generateHttpRequest(REQUEST_METHOD_POST, REQUEST_ENDPOINT_AUTH, requestBodyJSON);
        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseAuthToken(response.getBody());
    }

    private static String serializeAuthRequestBody() {
        AuthRequestBody requestBodyToSerialize = new AuthRequestBody();

        requestBodyToSerialize.username = '{!($Credential.CustomAuthProtocol.Username)}';
        requestBodyToSerialize.password = '{!($Credential.CustomAuthProtocol.Password)}';
        requestBodyToSerialize.security_token = '{!($Credential.CustomAuthProtocol.SecurityToken)}';
        requestBodyToSerialize.client_id = '{!($Credential.CustomAuthProtocol.ClientId)}';
        requestBodyToSerialize.client_secret = '{!($Credential.CustomAuthProtocol.ClientSecret)}';
        requestBodyToSerialize.email = '{!($Credential.CustomAuthProtocol.Email)}';
        requestBodyToSerialize.full_name = '{!($Credential.CustomAuthProtocol.FullName)}';
        requestBodyToSerialize.disabled = true;

        return JSON.serialize(requestBodyToSerialize);
    }

    /**
     * This method is part of the Participant payment and refund handling process.
     * It is invoked from following methods of this class: 
     * doAuthenticationCalloutForPayment and doInvoiceCalloutForParticipant,
     * and the following methods of the RefundCallout class:
     * doRefundCalloutForParticipant, doGetRefundCalloutForParticipantByRefundId,
     * and doRefundVerificationCalloutForParticipant.
     * 
     * @param method        Request method type
     * @param endpoint      Request endpoint
     * @param body          Request body JSON
     * @return String       Http request body
     */
    public static HttpRequest generateHttpRequest(String method, String endpoint, String body) {
        HttpRequest request = new HttpRequest();

        request.setMethod(method);
        request.setEndpoint(REQUEST_BASE_URL + endpoint);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);

        if(method == REQUEST_METHOD_POST) {
            request.setBody(body);
        }
    
        return request;
    }

    private static String parseAuthToken(String responseBody) {
        if(responseBody == null) {
            throw new NullAuthenticationResponseException('Unable to process authentication: Response body is null.');
        }

        AuthResponseBody authResponse = (AuthResponseBody) JSON.deserialize(responseBody, AuthResponseBody.class);

        if(authResponse == null || authResponse.token == null || authResponse.token == 'null') {
            throw new InvalidTokenResponseException('Unable to process authentication: Response token is invalid.');
        }

        return authResponse.token;
    }

    /**
     * This method is part of the Participant payment handling process. It is
     * invoked from the execute method on the "InvoiceCreationQueueable"
     * queueable class. It sends the API request for generating the invoice.
     * 
     * @param participant   Participant that has just registered
     * @param training      Training that a participant has registered for
     * @return String       JSON response body with successful message
     */
    public static String doInvoiceCalloutForParticipant(Participant__c participant, Training__c training) {
        if(participant == null || training == null ) {
            throw new InvalidParticipantOrTrainingException('Unable to initiate invoice request: Participant or training is invalid');
        }

        String parsedToken = doAuthenticationCalloutForPayment();
        String requestBodyJSON = serializeInvoiceRequestBody(training, participant.Id, parsedToken);

        HttpRequest request = generateHttpRequest(REQUEST_METHOD_POST, REQUEST_ENDPOINT_INVOICES, requestBodyJSON);
        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getBody();
    }

    @TestVisible
    private static String serializeInvoiceRequestBody(Training__c training, Id participantId, String token) {
        InvoiceRequestBody requestBodyToSerialize = new InvoiceRequestBody();

        requestBodyToSerialize.participant_id = participantId;
        requestBodyToSerialize.price = training.TotalPrice__c;
        requestBodyToSerialize.tax = training.TotalTax__c;
        requestBodyToSerialize.token = token;

        return JSON.serialize(requestBodyToSerialize);
    }

    private class AuthRequestBody {
        public String username;
        public String password;
        public String security_token;
        public String client_id;
        public String client_secret;
        public String email;
        public String full_name;
        public Boolean disabled;
    }

    private class AuthResponseBody {
        public string token;
    }

    private class InvoiceRequestBody {
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