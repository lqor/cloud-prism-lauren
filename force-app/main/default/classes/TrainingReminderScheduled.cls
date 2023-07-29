public class TrainingReminderScheduled implements Schedulable {

    /**
     * This method is part of the Training communication process. It is called from the scheduled class,
     * "TrainingReminderScheduled." 
     */
    public void execute(SchedulableContext sc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Date threeDaysFromToday = System.today().addDays(3);

        List<Training__c> trainings = queryTrainingsWithParticipantsByIdAndDate(threeDaysFromToday);

        for(Training__c training : trainings) {
            Messaging.SingleEmailMessage trainerEmail = EmailService.createTrainerReminderEmail(training);

            for(Participant__c participant : training.Participants__r) {
                Messaging.SingleEmailMessage participantEmail = EmailService.createParticipantReminderEmail(
                    training, 
                    participant
                );

                emails.add(participantEmail);
            }

            emails.add(trainerEmail);
        }

        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public List<Training__c> queryTrainingsWithParticipantsByIdAndDate(Date threeDaysFromToday) {
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

}