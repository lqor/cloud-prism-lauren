public with sharing class TrainingQueries {

    public static List<Training__c> queryTrainingsWithParticipantsById(Set<Id> trainingIds) {
        return [
            SELECT Id, Restaurant__c, StartDate__c, EndDate__c, NumberOfParticipants__c, 
                   (SELECT Id, Name, Training__c, Contact__c FROM Participants__r)
            FROM Training__c 
            WHERE Id IN :trainingIds
        ];
    }

    public static List<Training__c> queryTrainingsWithParticipantsByIdAndDate(Date threeDaysFromToday) {
        return [
            SELECT Id, Name, StartDate__c, EndDate__c, TrainerContact__r.FirstName, TrainerContact__r.LastName, 
                   TrainerContact__r.Email, TrainingCourse__r.Name,
                   (SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email FROM Participants__r)
            FROM Training__c 
            WHERE Id IN (SELECT Training__c FROM Participant__c) AND 
                  DAY_ONLY(convertTimezone(StartDate__c)) = :threeDaysFromToday AND
                  Status__c = :TrainingService.TRAINING_STATUS_SCHEDULED 
        ];
    }

    public static List<Training__c> queryTrainingsForNewParticipantsByParticipantIds(Set<Id> participantIds) {
        return [
            SELECT Id, Name, StartDate__c, EndDate__c, TrainerContact__r.FirstName, TrainerContact__r.LastName, 
                   TrainerContact__r.Email, TrainingCourse__r.Name, TotalPrice__c, TotalTax__c,
                   (SELECT Id, PaymentLink__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
                    FROM Participants__r
                    WHERE Id IN :participantIds)
            FROM Training__c 
            WHERE Id IN (SELECT Training__c FROM Participant__c WHERE Id = :participantIds)
        ];
    }

    public static Training__c queryTrainingByParticipantId(Id participantId) {
        return [
            SELECT Id, Name, StartDate__c, EndDate__c, TrainerContact__r.FirstName, TrainerContact__r.LastName, 
                   TrainerContact__r.Email, TrainingCourse__r.Name, TotalPrice__c, TotalTax__c,
                   (SELECT Id, PaymentLink__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
                    FROM Participants__r
                    WHERE Id = :participantId)
            FROM Training__c 
            WHERE Id IN (SELECT Training__c FROM Participant__c WHERE Id = :participantId)
            LIMIT 1
        ];
    }

    public static Training__c queryTrainingById(Id trainingId) {
        return [SELECT Name FROM Training__c WHERE Id = :trainingId];
    }

    public static List<Training__c> queryTrainingsWithLineItemsById(Set<Id> trainingIds) {
        return [
            SELECT Id, TotalPrice__c, TotalTax__c, 
                   (SELECT Id, Name, Training__c, TrainingProduct__c, ProductCode__c, LineDescription__c, Price__c, Tax__c 
                    FROM TrainingLineItems__r
                    ORDER BY Price__c DESC)
            FROM Training__c 
            WHERE Id IN :trainingIds
        ];
    }

}