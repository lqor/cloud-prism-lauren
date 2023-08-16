public class TrainingReminderScheduled implements Schedulable {

    /**
     * This method is part of the Training communication process. It is called from the scheduled class,
     * "TrainingReminderScheduled." 
     */
    public void execute(SchedulableContext sc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Date threeDaysFromToday = System.today().addDays(3);

        List<Training__c> trainings = TrainingQueries.queryTrainingsWithParticipantsByIdAndDate(threeDaysFromToday);

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

}