public with sharing class RefundCallout {

    public virtual class RefundCalloutException extends Exception {}
    public class NullTrainingRefundObjectException extends RefundCalloutException {}
    public class NullRefundResponseException extends RefundCalloutException {}
    public class InvalidRefundResponseException extends RefundCalloutException {}
    public class InvalidRefundIdOrTokenException extends RefundCalloutException {}

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_ENDPOINT_REFUNDS = '/refunds/';
    public static final String REQUEST_ENDPOINT_VERIFICATIONS = '/refund_verifications/';
    public static final String REQUEST_TOKEN_QUERY_PARAM = '/?token=';

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the initiateRefundOrder method on the "ParticipantService"
     * class. It sends the API request for generating the refund.
     * 
     * @param refund                Refund details to send in the refund order request
     * @return RefundResponseBody   Parsed refund response body object including token
     */
    public static RefundResponseBody doRefundCalloutForParticipant(TrainingRefund__c refund) {     
        if(refund == null) {
            throw new NullTrainingRefundObjectException('Unable to initiate refund request: Training Refund object is null.');
        }

        String parsedToken = InvoiceCallout.doAuthenticationCalloutForPayment();
        String requestBodyJSON = serializeRefundRequestBody(refund, parsedToken);

        HttpRequest request = InvoiceCallout.generateHttpRequest(
            InvoiceCallout.REQUEST_METHOD_POST, 
            REQUEST_ENDPOINT_REFUNDS, 
            requestBodyJSON
        );
        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseRefundResponse(response.getBody(), parsedToken);
    }

    @TestVisible
    private static String serializeRefundRequestBody(TrainingRefund__c refund, String token) {
        RefundRequestBody requestBodyToSerialize = new RefundRequestBody();

        requestBodyToSerialize.amount = refund.Amount__c;
        requestBodyToSerialize.invoice_id = refund.TrainingInvoice__r.InvoiceId__c;
        requestBodyToSerialize.token = token;
        requestBodyToSerialize.participant_id = refund.Participant__c;
        requestBodyToSerialize.reason = refund.Reason__c;

        return JSON.serialize(requestBodyToSerialize);
    }

    private static RefundResponseBody parseRefundResponse(String responseBody, String token) {
        if(responseBody == null) {
            throw new NullRefundResponseException('Unable to process refund request: Response body is null.');
        }

        RefundResponseBody refundResponse = (RefundResponseBody) JSON.deserialize(responseBody, RefundResponseBody.class);

        if(refundResponse == null || refundResponse.refund_id == null || refundResponse.refund_id == '') {
            throw new InvalidRefundResponseException('Unable to process refund: Response refund id is invalid.');
        } 
        
        refundResponse.token = token;

        return refundResponse;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPollingQueueable" queueable
     * class. It sends the API request to check if the refund has been processed.
     * 
     * @param refundId      Id of refund order to check on
     * @param token         Access token from the payment server
     * @return String       Status of refund order
     */
    public static String doGetRefundCalloutForParticipantByRefundId(String refundId, String token) {
        if(refundId == null || refundId == '' || token == null || token == '') {
            throw new InvalidRefundIdOrTokenException('Unable to initiate refund status check: Refund id or token is invalid');
        }

        String endpoint = REQUEST_ENDPOINT_REFUNDS + refundId + REQUEST_TOKEN_QUERY_PARAM + token;

        HttpRequest request = InvoiceCallout.generateHttpRequest(REQUEST_METHOD_GET, endpoint, '');
        Http http = new Http();
        HttpResponse response = http.send(request);

        return parseRefundStatus(response.getBody());
    }

    private static String parseRefundStatus(String responseBody) {
        if(responseBody == null) {
            throw new NullRefundResponseException('Unable to process refund status check: Refund callout response is null.');
        }

        RefundResponseBody refundResponse = (RefundResponseBody) JSON.deserialize(responseBody, RefundResponseBody.class);

        if(refundResponse.status == null) {
            refundResponse.status = '';
        }

        return refundResponse.status;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPostProcessingQueueable"
     * queueable class. It sends the API request for the refund verification.
     * 
     * @param refundId      Id of refund order to check on
     * @param token         Access token from the payment server
     * @return String       Refund verification id as confirmation the order was verified
     */
    public static String doRefundVerificationCalloutForParticipant(String refundId, String token) {
        if(refundId == null || refundId == '' || token == null || token == '') {
            throw new InvalidRefundIdOrTokenException('Unable to initiate refund verification: Refund id or token is invalid');
        }

        String requestBodyJSON = serializeVerificationRequestBody(refundId, token);

        HttpRequest request = InvoiceCallout.generateHttpRequest(
            InvoiceCallout.REQUEST_METHOD_POST, 
            REQUEST_ENDPOINT_VERIFICATIONS, 
            requestBodyJSON
        );
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

    private static String parseRefundVerificationId(String responseBody) {
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
        public String token;
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