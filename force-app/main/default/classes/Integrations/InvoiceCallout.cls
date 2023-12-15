public with sharing class InvoiceCallout {

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_METHOD_POST = 'POST';
    public static final String REQUEST_BASE_URL = 'callout:MockPaymentGateway';
    public static final String REQUEST_ENDPOINT_AUTH = '/auth';
    public static final String REQUEST_ENDPOINT_INVOICES = '/invoices/';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';

    public static String doInvoiceCalloutForParticipant(Training__c training, Participant__c participant) {
        String parsedToken = doAuthorizationCalloutForPayment();

        String requestBodyJSON = serializeInvoiceRequestBody(training, participant.Id, parsedToken);

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_POST);
        request.setEndpoint(REQUEST_BASE_URL + REQUEST_ENDPOINT_INVOICES);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setBody(requestBodyJSON);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getBody();
    }

    public static String doAuthorizationCalloutForPayment() {
        String requestBodyJSON = serializeAuthRequestBody();

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_POST);
        request.setEndpoint(REQUEST_BASE_URL + REQUEST_ENDPOINT_AUTH);
        request.setBody(requestBodyJSON);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);

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

    private static String parseAuthToken(String responseBody) {
        AuthResponseBody authResponse = (AuthResponseBody) JSON.deserialize(responseBody, AuthResponseBody.class);

        if(authResponse.token == null) {
            return '';
        }

        return authResponse.token;
    }

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