public with sharing class InvoiceCallout {

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_METHOD_POST = 'POST';
    public static final String REQUEST_BASE_URL = 'callout:MockPaymentGateway';
    public static final String REQUEST_ENDPOINT_AUTH = '/auth';
    public static final String REQUEST_ENDPOINT_INVOICES = '/invoices/';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';

    public static String doAuthorizationCalloutForPayment() {
        AuthorizationMetadata__mdt authorizationMdt = [
            SELECT Password__c, SecurityToken__c, ClientId__c, ClientSecret__c, Disabled__c
            FROM AuthorizationMetadata__mdt
            WHERE DeveloperName = 'PaymentCredentials'
            LIMIT 1
        ];

        AuthRequestBody requestBodyToSerialize = new AuthRequestBody();

        requestBodyToSerialize.username = UserInfo.getUserName();
        requestBodyToSerialize.password = authorizationMdt.Password__c;
        requestBodyToSerialize.security_token = authorizationMdt.SecurityToken__c;
        requestBodyToSerialize.client_id = authorizationMdt.ClientId__c;
        requestBodyToSerialize.client_secret = authorizationMdt.ClientSecret__c;
        requestBodyToSerialize.email = UserInfo.getUserEmail();
        requestBodyToSerialize.full_name = UserInfo.getName();
        requestBodyToSerialize.disabled = authorizationMdt.Disabled__c;

        String requestBodyJSON = JSON.serialize(requestBodyToSerialize);
        System.debug('requestBodyJSON' + requestBodyJSON);

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_POST);
        request.setEndpoint(REQUEST_BASE_URL + REQUEST_ENDPOINT_AUTH);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setBody(requestBodyJSON);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response.getBody()' + response.getBody());

        return response.getBody();
    }

    public static String doInvoiceCalloutForPayment() {
        InvoiceRequestBody requestBodyToSerialize = new InvoiceRequestBody();

        String requestBodyJSON = JSON.serialize(requestBodyToSerialize);
        System.debug('requestBodyJSON' + requestBodyJSON);

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_POST);
        request.setEndpoint(REQUEST_BASE_URL + REQUEST_ENDPOINT_INVOICES);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setBody(requestBodyJSON);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response.getBody()' + response.getBody());

        return response.getBody();

    }

    public class AuthRequestBody {
        public String username;
        public String password;
        public String security_token;
        public String client_id;
        public String client_secret;
        public String email;
        public String full_name;
        public Boolean disabled;
    }

    public class InvoiceRequestBody {
        public String invoice_id;
        public String participant_id = 'PN-0055';
        public String payment_id;
        public String payment_link;
        public String status;
        public String item_name;
        public String description;
        public Double price = 250;
        public Double tax = 10;
        public String token = 'bzDn2N6khb6yVSz5AszjqE';
        public String callback_url;
        public String session_id;
    }
}