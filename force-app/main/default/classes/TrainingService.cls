public with sharing class TrainingService {

    public static final String TRAINING_STATUS_SCHEDULED = 'Scheduled';
    public static final String TRAINING_STATUS_FINISHED = 'Finished';
    public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Reminder: ';
    public static final String TASK_DESCRIPTION = 'This task is just a reminder that a new course is about to start.';

    /**
     * This method is part of the Training restaurant commission calculation process. It is called from the 
     * trigger handler, "TrainingTriggerHandler," and the "ParticipantService" classes. It assigns the result 
     * to the Restaurant Commission field for each training in the list.
     * 
     * @param newlist   List of trainings, with or without Ids, with or without participants
     * @param oldMap    Old map of trainings, always null
     */
    public void setRestaurantCommissionOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        Map<Id, Restaurant__c> restaurants = trainingRestaurants(newList);
        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = queryRestaurantCommissionMetadata();     

        for(Training__c training : newList) {
            Decimal commission = calculateCommissionOnTraining(training, restaurants, restaurantCommissionMetadata);
            training.RestaurantCommission__c = commission;
        }
    }

    /**
     * This method contains the logic of the Training restaurant commission calculation process. It is 
     * called from the "TrainingService" class. It returns the Decimal value of the restaurant commission 
     * for a training.
     * 
     * @param training                      Training, with or without participants
     * @param restaurants                   List of restaurants related to the trainings to be processed
     * @param restaurantCommissionMetadata  Restaurant commission metadata
     */
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

    private Map<Id, Restaurant__c> trainingRestaurants(List<Training__c> trainings) {
        Set<Id> restaurantIds = new Set<Id>();

        for(Training__c training : trainings) {
            restaurantIds.add(training.Restaurant__c);
        }

        return new Map<Id, Restaurant__c>(queryTrainingRestaurantsById(restaurantIds));
    }

    /**
     * This method is part of the Training restaurant commission calculation process. It is called from the 
     * trigger handler class, "TrainingTriggerHandler." Because it is called from a before update trigger, it 
     * is necessary to set the Start Date and End Date of the queried trainings with the potentially newer 
     * values from the incoming list of trainings. It assigns the result to the Restaurant Commission field 
     * for each training in the list. Bug fix: filter for relevant trainings with updated start/end dates.
     * 
     * @param newlist   List of trainings, with Ids and without participants
     * @param oldMap    Old map of trainings, always null
     */
    public void updateRestaurantCommissionOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        List<Training__c> trainingsToProcess = new List<Training__c>();
        Set<Id> trainingIds = new Set<Id>();

        for(Training__c training : newList) {
            if(filterTrainingOnStartEndDateChanged(training, oldMap) != null) {
                trainingIds.add(training.Id);
                trainingsToProcess.add(training);
            }
        }

        if(trainingsToProcess.isEmpty()) {
            return;
        }

        List<Training__c> trainingsWithParticipants = queryTrainingsWithParticipantsById(trainingIds);
        Map<Id, Training__c> trainingsWithParticipantsMap = new Map<Id, Training__c>(trainingsWithParticipants);
        Map<Id, Restaurant__c> restaurants = trainingRestaurants(trainingsWithParticipants);
        RestaurantCommissionMetadata__mdt restaurantCommissionMetadata = queryRestaurantCommissionMetadata();     

        for(Training__c training : trainingsToProcess) {
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

    private Training__c filterTrainingOnStartEndDateChanged(Training__c training, Map<Id, Training__c> oldMap) {
        Boolean isStartDateChanged = training.StartDate__c != oldMap.get(training.Id).StartDate__c;
        Boolean isEndDateChanged = training.EndDate__c != oldMap.get(training.Id).EndDate__c;

        return (isStartDateChanged || isEndDateChanged) ? training : null;
    }

    /**
     * This method is part of the Training training duration calculation process. It is called from the 
     * trigger handler class, "TrainingTriggerHandler." It assigns the result to the Training Duration 
     * field for each training in the list.
     * 
     * @param newList   List of trainings, with or without participants
     * @param oldMap    Old map of trainings or null
     */
    public void setTrainingDurationOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        TrainingDurationMetadata__mdt trainingDurationMetadata = queryTrainingDurationMetadata();

        for(Training__c training : newList) {
            if(oldMap != null) {
                if(isTrainingStartEndDateUnchanged(training, oldMap)) {
                    break;
                }
            } 

            Integer trainingDuration = calculateTrainingDuration(training, trainingDurationMetadata);
            training.TrainingDuration__c = trainingDuration;
        }
    }

    private Boolean isTrainingStartEndDateUnchanged(Training__c training, Map<Id, Training__c> oldMap) {
        Boolean isStartDateSame = training.StartDate__c == oldMap.get(training.Id).StartDate__c;
        Boolean isEndDateSame = training.EndDate__c == oldMap.get(training.Id).EndDate__c;

        return isStartDateSame && isEndDateSame;
    }    

    /**
     * This method contains the logic of the Training training duration calculation process. It is called 
     * from the "TrainingService" class. It returns the Integer result of the training duration for a training 
     * session in hours.
     * 
     * @param training                  Training
     * @param trainingDurationMetadata  Training duration metadata
     */
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

    /**
     * This method is part of the Training unique id generation process. It is called from the trigger 
     * handler class, "TrainingTriggerHandler." It assigns the result to the Unique Id field for each 
     * training in the list.
     * 
     * @param newList   List of trainings, with or without participants
     * @param oldMap    Old map of trainings or null
     */
    public void setUniqueIdOnTrainings(List<Training__c> newList, Map<Id, Training__c> oldMap) {
        for(Training__c training : newList) {
            if(oldMap != null) {
                if(isTrainingNameStartDateUnchanged(training, oldMap)) {
                    break;
                }
            } 

            training.UniqueId__c = generateUniqueId(training);
        }
    }

    private Boolean isTrainingNameStartDateUnchanged(Training__c training, Map<Id, Training__c> oldMap) {
        Boolean isNameSame = training.Name == oldMap.get(training.Id).Name;
        Boolean isStartDateSame = training.StartDate__c == oldMap.get(training.Id).StartDate__c;

        return isNameSame && isStartDateSame;
    }  

    /**
     * This method contains the logic of the Training unique id generation process. It is called from the 
     * "TrainingService" class. It returns the String result of the unique id for a training.
     * 
     * @param training                  Training
     */
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

    /**
     * This method is part of the Training organization process. It is called from the trigger handler class, 
     * "TrainingTriggerHandler." It creates a task reminder associated with each training in the list.
     * 
     * @param newList   List of trainings
     * @param oldMap    Old map of trainings or null
     */
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

    /**
     * This method is part of the Training organization process. It is called from the trigger handler class, 
     * "TrainingTriggerHandler." It assigns today's date as the completion date and updates the participant 
     * statuses to match for each completed training in the list.
     * 
     * @param newList   List of trainings that have just been updated to finished status
     * @param oldMap    Old map of trainings, never null
     */
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