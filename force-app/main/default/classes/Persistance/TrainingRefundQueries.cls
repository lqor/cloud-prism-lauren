public with sharing class TrainingRefundQueries {

    public static TrainingRefund__c queryRefundByRefundId(String refundId) {
        return [
            SELECT Id, Name, RefundId__c, RefundDate__c, TrainingInvoice__c, TrainingInvoice__r.InvoiceId__c, 
                   Status__c, VerificationId__c, Participant__c 
            FROM TrainingRefund__c 
            WHERE RefundId__c = :refundId
        ];
    }

}