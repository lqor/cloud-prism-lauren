public class PaymentLinkCallout {

    public static final String REQUEST_METHOD_GET = 'GET';
    public static final String REQUEST_ENDPOINT = 'https://735ef563-176d-431c-85ce-2cc07056ef03.mock.pstmn.io' + 
        '/payments/link';
    public static final Integer RESPONSE_STATUS_CODE_200 = 200;

    public static Boolean isHttpCalloutMockTest = false;

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable." It makes the API request for generating the 
     * payment link and updating participant records.
     * 
     * @param participants  List of participants that have registered for training
     */
    public static List<HttpResponse> requestPaymentLink(List<Participant__c> participants) {
        List<HttpResponse> responses = new List<HttpResponse>();
        List<Participant__c> participantsToUpdate = new List<Participant__c>();

        for(Participant__c participant : participants) {
            HttpRequest request = new HttpRequest();
            request.setMethod(REQUEST_METHOD_GET);
            request.setEndpoint(REQUEST_ENDPOINT);

            HttpResponse response = new HttpResponse();
            Http http = new Http();

            if (!Test.isRunningTest() || isHttpCalloutMockTest) {
                try {
                    response = http.send(request);
                } catch(Exception e) {
                    System.debug('Error occurred: ' + e.getMessage());
                } finally {

                }
            } else {
                response = PaymentLinkHttpCalloutMock.respond(request);
            }

            if(response.getStatusCode() == RESPONSE_STATUS_CODE_200) {
                Map<String, Object> paymentObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> payer = (Map<String, Object>) paymentObject.get('payer');

                participant.PaymentLink__c = (String) payer.get('link');
            }

            participantsToUpdate.add(participant);
            responses.add(response);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }

        return responses;
    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable." It returns an email confirming enrollment, 
     * including payment details.
     * 
     * @param training      Training course the new participant has registered for
     * @param participant   Participant to be notified
     */
    public static Messaging.SingleEmailMessage sendPaymentEmail(Training__c training, Participant__c participant) {
        return EmailService.createParticipantConfirmationEmail(training, participant);
    }

}