public with sharing class TrainingInvoiceQueries {

    public static TrainingInvoice__c queryInvoiceByParticipantId(Id participantId) {
        return [
            SELECT Id, Name, InvoiceId__c, Participant__c, GrandTotal__c 
            FROM TrainingInvoice__c
            WHERE Participant__c = :participantId
        ];
    }

    public static TrainingInvoice__c queryInvoiceByInvoiceId(String invoiceId) {
        return [
            SELECT Id, Name, InvoiceId__c, GrandTotal__c, Status__c, Training__c, Training__r.TrainingCourse__r.Name,
                   Participant__c, Participant__r.Contact__r.FirstName, Participant__r.Contact__r.LastName, 
                   Participant__r.Contact__r.Email
            FROM TrainingInvoice__c
            WHERE InvoiceId__c = :invoiceId
        ];
    }

}