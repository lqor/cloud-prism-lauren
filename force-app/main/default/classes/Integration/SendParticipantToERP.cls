public with sharing class SendParticipantToERP {

    public virtual class SendParticipantToERPException extends Exception {}
    public class ERPCalloutException extends SendParticipantToERPException {}

    /**
     * This method is part of the Participant to ERP syncing process. It is called from an invocable action 
     * in the "Send Participant to ERP" flow. It sends the API request to add the participant to the ERP 
     * system and updates each participant record with their ERP Id.
     * 
     * @param participantIds    List of ids for participants to save to ERP system
     */
    @InvocableMethod
    public static List<String> sendParticipantsToERP(List<Id> participantIds){
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Participant__c> participants = ParticipantQueries.queryParticipantsByIdAndNoErpId(participantIds);

        if(participants.isEmpty()) {
            return new List<String>{'This participant is already synced to the ERP system.'};
        }

        for(Participant__c participant : participants) {
            Logger logger = new Logger();
            String participantJSON = JSON.serialize(participant);
            String responseBody = '';
            String erpId = '';

            try {
                responseBody = ERPCallout.doERPCalloutForParticipant(participantJSON);
                erpId = parseErpId(responseBody);

                if(responseBody == '') {
                    throw new ERPCalloutException();
                }
            } catch(ERPCalloutException c) {
                logger.logException(c);
            } catch(Exception e) {
                logger.logException(e);
            }

            participant.ErpId__c = erpId;
            participantsToUpdate.add(participant);
        }

        if(!participantsToUpdate.isEmpty()){
            update participantsToUpdate;
        }

        return new List<String>{'You\'re all set! The participant is saved to the ERP system.'};
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is called from the "SendParticipantToERP" 
     * class and the batchable class, "ParticipantSyncBatch." It returns the ERP Id if the save was successful or 
     * an empty string if not.
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