public with sharing class TrainingDurationMetadataQueries {

    public static TrainingDurationMetadata__mdt queryTrainingDurationMetadata() {
        return [
            SELECT PreparationTime__c, ReviewTime__c, TrainingHoursPerDay__c 
            FROM TrainingDurationMetadata__mdt 
            LIMIT 1
        ];
    }

}