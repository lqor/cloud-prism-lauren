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

    public void updateRestaurantCommissionOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();

        for(Training__c training : newList) {
            trainingIds.add(training.Id);
        }

        List<Training__c> trainingsWithParticipants = queryTrainingsWithParticipantsById(trainingIds);
        Map<Id, Training__c> trainingsWithParticipantsMap = new Map<Id, Training__c>(trainingsWithParticipants);
        Map<Id, Restaurant__c> restaurants = trainingRestaurants(trainingsWithParticipants);
        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = queryRestaurantCommissionMetadata();     

        for(Training__c training : newList) {
            Training__c trainingWithParticipants = trainingsWithParticipantsMap.get(training.Id);
            trainingWithParticipants.StartDate__c = training.StartDate__c;
            trainingWithParticipants.EndDate__c = training.EndDate__c;

            Decimal commission = calculateCommissionOnTraining(
                trainingWithParticipants, 
                restaurants, 
                restaurantCommissionMetadata
            );
            
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
        Integer numberOfDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal probabilityToBuy = restaurantCommissionMetadata.ProbabilityToBuyPerParticipant__c / 100;
        Restaurant__c restaurant = restaurants.get(training.Restaurant__c);
        Decimal commissionRate = 1.00;
        Decimal averageMealCost = 1.00;

        if(restaurant != null) {
            commissionRate = restaurant.CommissionRate__c / 100;
            averageMealCost = restaurant.AverageMealCost__c;
        }

        return numberOfParticipants * numberOfDays * commissionRate * probabilityToBuy * averageMealCost;
    }

    public void setTrainingDurationOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        TrainingDurationMetadata__mdt trainingDurationMetadata = queryTrainingDurationMetadata();

        for(Training__c training : newList) {
            if(oldMap != null) {
                Training__c oldTraining = oldMap.get(training.Id);
                Boolean ifUpdate = training.StartDate__c != oldTraining.StartDate__c ||
                                    training.EndDate__c != oldTraining.EndDate__c;

                if(!ifUpdate) {
                    break;
                }
            } 

            Integer trainingDuration = calculateTrainingDuration(training, trainingDurationMetadata);
            training.TrainingDuration__c = trainingDuration;
        }
    }

    private Integer calculateTrainingDuration(
        Training__c training, 
        TrainingDurationMetadata__mdt trainingDurationMetadata
    ) {
        Integer numberOfDays = training.StartDate__c.Date().daysBetween(training.EndDate__c.Date()) + 1;
        Decimal trainingHoursPerDay = trainingDurationMetadata.TrainingHoursPerDay__c;
        Decimal preparationTime = trainingDurationMetadata.PreparationTime__c;
        Decimal reviewTime = trainingDurationMetadata.ReviewTime__c;

        return numberOfDays * (Integer) trainingHoursPerDay + (Integer) preparationTime + (Integer) reviewTime;
    } 

    public void setUniqueIdOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        for(Training__c training : newList) {
            if(oldMap != null) {
                Training__c oldTraining = oldMap.get(training.Id);
                Boolean ifUpdate = training.Name != oldTraining.Name || 
                                   training.StartDate__c != oldTraining.StartDate__c;

                if(!ifUpdate) {
                    break;
                }
            } 

            training.UniqueId__c = generateUniqueId(training);
        }
    }

    private String generateUniqueId(Training__c training) {
        String pad0 = '0';
        String startDay = String.valueOf(training.StartDate__c.day()).length() == 1 ? 
                          String.valueOf(training.StartDate__c.day()).leftPad(2, pad0) : 
                          String.valueOf(training.StartDate__c.day());
        String startMonth = String.valueOf(training.StartDate__c.month()).length() == 1 ?
                            String.valueOf(training.StartDate__c.month()).leftPad(2, pad0) :
                            String.valueOf(training.StartDate__c.month());
        String startYear = String.valueOf(training.StartDate__c.year()).right(2);
        String startDate = startDay + startMonth + startYear;

        String nameInitials = '';
        List<String> nameParts = training.Name.toUpperCase().split(' ');
        for(String name : nameParts) {
            nameInitials += name.left(1);
        }

        return nameInitials + startDate;
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
            participant.Status__c = ParticipantService.PARTICIPANT_STATUS_PARTICIPATED;
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

    public List<Training__c> queryTrainingsWithParticipantsById(Set<Id> ids) {
        return [
            SELECT Id, Restaurant__c, StartDate__c, EndDate__c, 
                   (SELECT Id, Name, Training__c, Contact__c FROM Participants__r)
            FROM Training__c 
            WHERE Id IN :ids
        ];
    }

    public TrainingDurationMetadata__mdt queryTrainingDurationMetadata() {
        return [
            SELECT PreparationTime__c, ReviewTime__c, TrainingHoursPerDay__c 
            FROM TrainingDurationMetadata__mdt 
            LIMIT 1
        ];
     }
 
     public List<Participant__c> queryParticipantsByTrainingAndStatus(List<Training__c> trainings) {
        return [
            SELECT Id, Name, Status__c, Training__c
            FROM Participant__c
            WHERE Training__c IN :trainings AND Status__c != :ParticipantService.PARTICIPANT_STATUS_PARTICIPATED
        ];
    }

}