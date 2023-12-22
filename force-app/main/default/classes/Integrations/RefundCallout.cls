public with sharing class RefundCallout {

    public virtual class RefundCalloutException extends Exception {}
    public class EmptyRefundException extends RefundCalloutException {}
    public class EmptyRefundIdException extends RefundCalloutException {}

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';
    public static final String REQUEST_BASE_URL = 'callout:MockPaymentGateway';
    public static final String REQUEST_ENDPOINT_REFUNDS = '/refunds/';
    public static final String REQUEST_ENDPOINT_VERIFICATIONS = '/refund_verifications/';
    public static final String REQUEST_TOKEN_QUERY_PARAM = '/?token=';

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the initiateRefundOrder method on the "ParticipantService"
     * class. It sends the API request for generating the refund.
     * 
     * @param refund        Refund details to send in the refund order
     * @return String       Refund id confirmation that the order was received
     */
    public static String doRefundCalloutForParticipant(TrainingRefund__c refund) {
        if(refund == null) {
            throw new EmptyRefundException('Training Refund is null');
        }

        String parsedToken = InvoiceCallout.doAuthenticationCalloutForPayment();

        String requestBodyJSON = serializeRefundRequestBody(refund, parsedToken);

        HttpRequest request = InvoiceCallout.generateHttpRequest(REQUEST_ENDPOINT_REFUNDS, requestBodyJSON);
        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseRefundId(response.getBody());
    }

    @TestVisible
    private static String serializeRefundRequestBody(TrainingRefund__c refund, String token) {
        RefundRequestBody requestBodyToSerialize = new RefundRequestBody();

        requestBodyToSerialize.amount = refund.Amount__c;
        requestBodyToSerialize.invoice_id = refund.InvoiceId__c;
        requestBodyToSerialize.token = token;
        requestBodyToSerialize.participant_id = refund.Participant__c;
        requestBodyToSerialize.reason = refund.Reason__c;

        return JSON.serialize(requestBodyToSerialize);
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the queueable class, 
     * "RefundPollingQueueable." It sends the API request to check if the
     * refund has been processed.
     * 
     * @param refundId      Id of refund order to check on
     * @return String       Status of refund order 
     */
    public static String doGetRefundCalloutForParticipantByRefundId(String refundId) {
        if(refundId == null || refundId == '') {
            throw new EmptyRefundIdException('Refund ID is empty');
        }

        String tokenParameter = REQUEST_TOKEN_QUERY_PARAM + InvoiceCallout.doAuthenticationCalloutForPayment();

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_GET);
        request.setEndpoint(REQUEST_BASE_URL + REQUEST_ENDPOINT_REFUNDS + refundId + tokenParameter);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        System.debug('request.getEndpoint: ' + request.getEndpoint());

        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseRefundStatus(response.getBody());
    }

    public static String parseRefundId(String responseBody) {
        RefundResponseBody refundResponse = (RefundResponseBody) JSON.deserialize(responseBody, RefundResponseBody.class);

        if(refundResponse.refund_id == null) {
            refundResponse.refund_id = '';
        }

        return refundResponse.refund_id;
    }

    public static String parseRefundStatus(String responseBody) {
        RefundResponseBody refundResponse = (RefundResponseBody) JSON.deserialize(responseBody, RefundResponseBody.class);

        if(refundResponse.status == null || refundResponse.status == 'initiated') {
            refundResponse.status = '';
        }

        return refundResponse.status;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPollingQueueable" queueable 
     * class. It sends the API request for the refund verification.
     * 
     * @param refundId      Id of refund order to check on
     * @return String       Refund verification id confirmation that the order was verified
     */
    public static String doRefundVerificationCalloutForParticipant(String refundId) {
        if(refundId == null || refundId == '') {
            throw new EmptyRefundIdException('Refund ID is empty');
        }

        String parsedToken = InvoiceCallout.doAuthenticationCalloutForPayment();

        String requestBodyJSON = serializeVerificationRequestBody(refundId, parsedToken);

        HttpRequest request = InvoiceCallout.generateHttpRequest(REQUEST_ENDPOINT_VERIFICATIONS, requestBodyJSON);
        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseRefundVerificationId(response.getBody());
    }

    @TestVisible
    private static String serializeVerificationRequestBody(String refundId, String token) {
        VerificationRequestBody requestBodyToSerialize = new VerificationRequestBody();

        requestBodyToSerialize.token = token;
        requestBodyToSerialize.refund_id = refundId;

        return JSON.serialize(requestBodyToSerialize);
    }

    public static String parseRefundVerificationId(String responseBody) {
        VerificationResponseBody verificationResponse = (VerificationResponseBody) JSON.deserialize(
            responseBody, 
            VerificationResponseBody.class
        );

        if(verificationResponse.verification_id == null) {
            verificationResponse.verification_id  = '';
        }

        return verificationResponse.verification_id;
    }

    private class RefundRequestBody {
        public String refund_id;
        public Double amount;
        public String invoice_id;
        public String token;
        public String participant_id;
        public String reason;
        public String status;
    }

    public class RefundResponseBody {
        public string message;
        public String status;
        public String refund_id;
    }

    private class VerificationRequestBody {
        public String token;
        public String verification_id;
        public String refund_id;
        public String status;
    }

    public class VerificationResponseBody {
        public string message;
        public String status;
        public String verification_id;
    }

}