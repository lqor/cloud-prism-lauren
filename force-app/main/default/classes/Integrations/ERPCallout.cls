public with sharing class ERPCallout {

    public virtual class ERPCalloutException extends Exception {}
    public class EmptyParticipantException extends ERPCalloutException {}

    public static final String REQUEST_METHOD_POST = 'POST';
    public static final String REQUEST_ENDPOINT = 'https://64aa815a0c6d844abede843a.mockapi.io/api/v1/participants';
    public static final String REQUEST_CONTENT_TYPE = 'application/json';

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the "ParticipantService" 
     * class. It sends the API request to add the participant to the ERP system and returns the JSON response body.
     * 
     * @param participant  Participant to send to ERP system
     */
    public static String doERPCalloutForParticipant(String participantJSON) {
        if(participantJSON == null || participantJSON == '') {
            throw new EmptyParticipantException('Participant JSON is empty');
        }

        HttpRequest request = new HttpRequest();

        request.setMethod(REQUEST_METHOD_POST);
        request.setEndpoint(REQUEST_ENDPOINT);
        request.setHeader('Content-Type', REQUEST_CONTENT_TYPE);
        request.setBody(participantJSON);

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response.getBody();
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the "ParticipantService" 
     * class. It returns the ERP Id if the response was successful or an empty string if the expected data is 
     * not found.
     * 
     * @param responseBody  JSON body of response from API call
     */
    public static String parseErpId(String responseBody) {
        ErpResponse erpResponse = (ErpResponse) JSON.deserialize(responseBody, ErpResponse.class);

        if(erpResponse.erpId == null) {
            erpResponse.erpId = '';
        }

        return erpResponse.erpId;
    }

    public class ErpResponse {
        public String erpId;
    }

}