public with sharing class ErrorLogCleanupMetadataQueries {

    public static ErrorLogCleanupMetadata__mdt queryErrorLogCleanupMetadata() {
        return [SELECT RetentionDays__c FROM ErrorLogCleanupMetadata__mdt LIMIT 1];
    }

}