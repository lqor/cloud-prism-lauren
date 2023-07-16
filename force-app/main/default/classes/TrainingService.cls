public with sharing class TrainingService {

    public static final String TRAINING_STATUS_SCHEDULED = 'Scheduled';
    public static final String TRAINING_STATUS_FINISHED = 'Finished';
    public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Reminder: ';
    public static final String TASK_DESCRIPTION = 'This task is just a reminder that a new course is about to start.';

    public void setRestaurantCommissionOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        Map<Id, Restaurant__c> restaurants = trainingRestaurants(newList);
        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = queryRestaurantCommissionMetadata();        

        for(Training__c training : newList) {
            Decimal commission = calculateCommissionOnTraining(training, restaurants, restaurantCommissionMetadata);
            training.RestaurantCommission__c = commission;
        }
    }

    private Map<Id, Restaurant__c> trainingRestaurants(List<Training__c> trainings) {
        Set<Id> restaurantIds = new Set<Id>();
        
        for(Training__c training : trainings) {
            restaurantIds.add(training.Restaurant__c);
        }

        return new Map<Id, Restaurant__c>(queryTrainingRestaurantsById(restaurantIds));
    }

    private Decimal calculateCommissionOnTraining(
        Training__c training, 
        Map<Id, Restaurant__c> restaurants, 
        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata
    ) {
        Integer numberOfParticipants = training.Participants__r.isEmpty() ? 1 : training.Participants__r.size();
        Integer trainingDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal probabilityToBuy = restaurantCommissionMetadata.ProbabilityToBuyPerParticipant__c / 100;
        Restaurant__c restaurant = restaurants.get(training.Restaurant__c);
        Decimal commissionRate = 1.00;
        Decimal averageMealCost = 1.00;

        if(restaurant != null) {
            commissionRate = restaurant.CommissionRate__c / 100;
            averageMealCost = restaurant.AverageMealCost__c;
        }

        return numberOfParticipants * trainingDays * commissionRate * probabilityToBuy * averageMealCost;
    }

    public void insertTasksForTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        List<Task> tasksToInsert = new List<Task>();

        for(Training__c training : newList) {
            Task task = createTaskForTrainer(training);
            tasksToInsert.add(task);
        }

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    private Task createTaskForTrainer(Training__c training) {
        Task task = new Task();

        task.ActivityDate = System.today();
        task.Status = TASK_STATUS_NOT_STARTED;
        task.Priority = TASK_PRIORITY;
        task.Subject = TASK_SUBJECT + training.Name;
        task.Description = TASK_DESCRIPTION;
        task.WhoId = training.TrainerContact__c;
        task.WhatId = training.TrainingCourse__c;

        return task;
    }

    public void updateCompletedTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        List<Training__c> completedTrainings = new List<Training__c>();

        for(Training__c training : newList) {
            Boolean isJustCompleted = training.Status__c == TRAINING_STATUS_FINISHED && 
                                      oldMap.get(training.Id).Status__c != TRAINING_STATUS_FINISHED;

            if(isJustCompleted) {
                training.CompletionDate__c = System.today();
                completedTrainings.add(training);
            }
        }

        updateParticipantStatus(completedTrainings);
    }

    private void updateParticipantStatus(List<Training__c> trainings) {
        List<Participant__c> participantsToUpdate = new List<Participant__c>();
        List<Participant__c> participants = queryParticipantsByTrainingAndStatus(trainings);

        for(Participant__c participant : participants) {
            participant.Status__c = 'Participated';
            participantsToUpdate.add(participant);
        }

        if(!participantsToUpdate.isEmpty()) {
            update participantsToUpdate;
        }
    }

    public List<Restaurant__c> queryTrainingRestaurantsById(Set<Id> ids) {
        return [SELECT Id, Name, AverageMealCost__c, CommissionRate__c FROM Restaurant__c WHERE Id IN :ids];
    }

    public RestaurantCommissionMetadata__mdt queryRestaurantCommissionMetadata() {
       return [SELECT ProbabilityToBuyPerParticipant__c FROM RestaurantCommissionMetadata__mdt LIMIT 1];
    }

    public List<Participant__c> queryParticipantsByTrainingAndStatus(List<Training__c> trainings) {
        return [
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :trainings AND Status__c != 'Participated'
        ];
    }

}