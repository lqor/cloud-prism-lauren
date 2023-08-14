public with sharing class SendParticipantToERP {

    /**
     * This method is part of the Participant to ERP syncing process. It is called from an invocable action 
     * in the "Send Participant to ERP" flow. It sends the API request to add the participant to the ERP 
     * system and updates each participant record with their ERP Id.
     * 
     * @param participantIds    List of ids for participants to save to ERP system
     */
    @InvocableMethod
    public static void sendParticipantsToERP(List<Id> participantIds){
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Participant__c> participants = ParticipantQueries.queryParticipantsById(participantIds);

        for(Participant__c participant : participants) {
            String participantJSON = JSON.serialize(participant);
            participant.ErpId__c = parseErpId(ERPCallout.doERPCalloutForParticipant(participantJSON));
            participantsToUpdate.add(participant);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the "SendParticipantToERP" 
     * class. It returns the ERP Id if the save was successful or an empty string if not.
     * 
     * @param responseBody  JSON body of response from API call
     */
    @TestVisible
    private static String parseErpId(String responseBody) {
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