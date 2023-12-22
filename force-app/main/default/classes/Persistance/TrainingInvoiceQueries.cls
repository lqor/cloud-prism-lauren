public with sharing class TrainingInvoiceQueries {

    public static TrainingInvoice__c queryInvoiceByParticipantId(Id participantId) {
        return [
            SELECT Id, InvoiceId__c, Participant__c, GrandTotal__c 
            FROM TrainingInvoice__c
            WHERE Participant__c = :participantId
        ];
    }

}