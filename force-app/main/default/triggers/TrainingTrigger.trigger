trigger TrainingTrigger on Training__c (before insert, after insert, before update) {
    List<Training__c> trainings = new List<Training__c>();
    Map<Id, Training__c> oldTrainings = new Map<Id, Training__c>();
    trainings = Trigger.new;
    oldTrainings = Trigger.oldMap;

    if(Trigger.isInsert && Trigger.isBefore) {
        List<Training__c> trainingsToInsert = new List<Training__c>();

        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = [
            SELECT ProbabilityToBuyPerParticipant__c 
            FROM RestaurantCommissionMetadata__mdt
            LIMIT 1 
        ];

        Set<Id> restaurauntIds = new Set<Id>();
        for(Training__c training : trainings) {
            restaurauntIds.add(training.Restaurant__c);
        }
        Map<Id, Restaurant__c> trainingRestaurants = new Map<Id, Restaurant__c>([
            SELECT Id, Name, AverageMealCost__c, CommissionRate__c 
            FROM Restaurant__c
            WHERE Id IN :restaurauntIds
        ]);

        for(Training__c training : trainings) {
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

        for(Training__c training : trainings) {
            tasksToInsert.add(new Task(
                ActivityDate = System.today(),
                Status = 'Not Started',
                Priority = 'Normal',
                Subject = 'Reminder: ' +  training.Name,
                Description = 'This task is just a reminder that a new course is about to start.',
                WhoId = training.TrainerContact__c,
                WhatId = training.TrainingCourse__c
            ));
        }

        if(tasksToInsert.size() > 0 && tasksToInsert != null) {
            insert tasksToInsert;
        }
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Participant__c> trainingParticipants = new List<Participant__c>([
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :trainings
        ]);

        for(Training__c training : trainings) {
            if(training.Status__c == 'Finished' && oldTrainings.get(training.Id).Status__c != 'Finished') {
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
    }
}