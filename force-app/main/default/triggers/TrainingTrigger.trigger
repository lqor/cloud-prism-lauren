trigger TrainingTrigger on Training__c (before insert, after insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore) {
        List<Training__c> trainingsToInsert = new List<Training__c>();

        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = [
            SELECT ProbabilityToBuyPerParticipant__c 
            FROM RestaurantCommissionMetadata__mdt
            LIMIT 1 
        ];

        Set<Id> restaurauntIds = new Set<Id>();
        for(Training__c training : Trigger.new) {
            restaurauntIds.add(training.Restaurant__c);
        }
        Map<Id, Restaurant__c> trainingRestaurants = new Map<Id, Restaurant__c>([
            SELECT Id, Name, AverageMealCost__c, CommissionRate__c 
            FROM Restaurant__c
            WHERE Id IN :restaurauntIds
        ]);

        for(Training__c training : Trigger.new) {
            Restaurant__c trainingRestaurant = trainingRestaurants.get(training.Restaurant__c);
            Decimal probabilityToBuy = restaurantCommissionMetadata.ProbabilityToBuyPerParticipant__c / 100;
            Integer numberOfTrainingDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
            Integer numberOfParticipants = 1;
            Decimal commissionRate = 1.00;
            Decimal averageMealCost = 1;

            if(trainingRestaurant != null) {
                commissionRate = trainingRestaurant.CommissionRate__c / 100;
                averageMealCost = trainingRestaurant.AverageMealCost__c;
            }

            training.RestaurantCommissionForecast__c = (
                numberOfParticipants * 
                numberOfTrainingDays * 
                commissionRate *
                probabilityToBuy *
                averageMealCost
            );
        }
    } 
    
    if (Trigger.isInsert && Trigger.isAfter) {
        List<Task> tasksToInsert = new List<Task>();

        for(Training__c training : Trigger.new) {
            Task task = new Task();

            task.ActivityDate = System.today();
            task.Status = 'Not Started';
            task.Priority = 'Normal';
            task.Subject = 'Reminder: ' +  training.Name;
            task.Description = 'This task is just a reminder that a new course is about to start.';
            task.WhoId = training.TrainerContact__c;
            task.WhatId = training.TrainingCourse__c;

            tasksToInsert.add(task);
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Participant__c> trainingParticipants = [
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :Trigger.new
        ];

        for(Training__c training : Trigger.new) {
            if(training.Status__c == 'Finished' && Trigger.oldMap.get(training.Id).Status__c != 'Finished') {
                training.CompletionDate__c = System.today();

                for(Participant__c participant : trainingParticipants) {
                    if(participant.Training__c == training.Id) {
                            participant.Status__c = 'Participated';
                    }

                    participantsToUpdate.add(participant);
                }
            }
        }

        if(participantsToUpdate.size() > 0 && participantsToUpdate != null) {
            update participantsToUpdate;
        }

        /* more efficient approach that only iterates over relevant records and avoids nested for each loop
         * 
        Set<Id> trainingsToProcess = new Set<Id>();
        for(Training__c training : Trigger.New) {
            Boolean isRelevant = training.Status__c == 'Finished' && 
                                 oldTrainings.get(training.Id).Status__c != 'Finished';
            if(isRelevant) {
                training.CompletionDate__c = System.today();
                trainingsToProcess.add(training.Id);
            }
        }

        if(!trainingsToProcess.isEmpty()) {
            List<Participant__c> participantsToUpdate = [
                SELECT Id, Status__c 
                FROM Participant__c 
                WHERE Training__c IN :trainingsToProcess AND Status__c != 'Participated'
            ];

            for (Participant__c participant : participantsToUpdate) {
                participant.Status__c = 'Participated';
            }

            if(!participantsToUpdate.isEmpty()) {
                update participantsToUpdate;
            }
        } */
    }
}