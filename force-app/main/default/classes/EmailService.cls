public with sharing class EmailService {

    public static final String FORMAT_DATE_TIME = 'd MMM y, K:mm a z';
    public static final String PARTICIPANT_EMAIL_TEMPLATE = 'Participant Training Reminder Email';

    /**
     * This method is part of the Training communication process. It is called from the scheduled class,
     * "TrainingReminderScheduled." It returns an email to the trainer about their upcoming training.
     * 
     * @param training      Training that is scheduled to start in 3 days
     */
    public static Messaging.SingleEmailMessage createTrainerReminderEmail(Training__c training) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();       
        String subject = 'Training Reminder: ' + training.Name;

        email.setToAddresses(new List<String> {training.TrainerContact__r.Email});
        email.setSubject(subject);
        email.setHtmlBody(createTrainerReminderHtmlBody(training));

        return email;
    }

    private static String createTrainerReminderHtmlBody(Training__c training) {
        String trainerName = training.TrainerContact__r.FirstName;
        String startDate = String.valueOf(training.StartDate__c.format(FORMAT_DATE_TIME));
        String endDate = String.valueOf(training.EndDate__c.format(FORMAT_DATE_TIME));
        Integer numberOfParticipants = training.Participants__r.size();

        String bodyGreeting = '<p>Dear ' + trainerName + ',</p>';
        String bodyCourse = '<p>This is an automatic reminder for the upcoming <b>' + training.Name + '</b> training';
        String bodyStartDate = ' on ' + startDate;
        String bodyEndDate = ' through ' + endDate + '.</p>';
        String bodyParticipantNumber = '<p>There are a total of ' + numberOfParticipants + ' participants:</p>';
        String bodyParticipantList = createParticipantList(training.Participants__r);
        String bodySignature = '<p>Best regards,<br/><br/>Training Reminder</p>';
        
        return bodyGreeting + 
               bodyCourse + 
               bodyStartDate + 
               bodyEndDate + 
               bodyParticipantNumber + 
               bodyParticipantList +
               bodySignature; 
    }

    private static String createParticipantList(List<Participant__c> participants) {
        String participantList = '<ul>';

        for(Participant__c participant : participants) {
            String participantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
            participantList += '<li>' + participantName + '</li>';
        }

        return participantList += '</ul>';
    }

    /**
     * This method is part of the Training communication process. It is called from the scheduled class,
     * "TrainingReminderScheduled."  It returns an email to the participant about their upcoming training.
     * 
     * @param training      Training that is scheduled to start in 3 days
     * @param participant   Participant to be notified
     */
    public static Messaging.SingleEmailMessage createParticipantReminderEmail(
        Training__c training, 
        Participant__c participant
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();       

        email.setTargetObjectId(participant.Contact__r.Id);
        email.setWhatId(participant.Id);
        email.setSaveAsActivity(false);

        email.setTemplateId(queryEmailTemplateForParticipantTrainingReminder().Id);

        return email;
    }

    /**
     * This method is part of the Participant registration confirmation process. It is called from the 
     * queueable class, "RegistrationConfirmationQueueable." It returns an email confirming enrollment.
     * 
     * @param training      Training course the new participant has registered for
     * @param participant   Participant to be notified
     */
    public static Messaging.SingleEmailMessage createParticipantConfirmationEmail(
        Training__c training, 
        Participant__c participant
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'Enrollment Confirmation: ' + training.TrainingCourse__r.Name;

        email.setToAddresses(new List<String> {participant.Contact__r.Email});
        email.setSubject(subject);
        email.setHtmlBody(createParticipantConfirmationHtmlBody(training, participant));

        return email;
    }

    private static String createParticipantConfirmationHtmlBody(Training__c training, Participant__c participant) {
        String participantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
        String trainerName = training.TrainerContact__r.FirstName + ' ' + training.TrainerContact__r.LastName;
        String courseName = training.TrainingCourse__r.Name;
        String startDate = String.valueOf(training.StartDate__c.format(FORMAT_DATE_TIME));
        String endDate = String.valueOf(training.EndDate__c.format(FORMAT_DATE_TIME));

        String bodyGreeting = '<p>Dear ' + participantName + ',</p>';
        String bodyCourse = '<p>Congrats! You\'re all signed up for your <b>' + courseName + '</b> course with ';
        String bodyTrainer = trainerName + ' on ';
        String bodyStartDate = startDate + ' through ';
        String bodyEndDate = endDate + '.</p>';
        String bodyClose = '<p>We look forward to seeing you at the training!</p>';
        String bodySignature = '<p>Best regards,<br/><br/>Cloud Prism</p>';
        
        return bodyGreeting + 
               bodyCourse + 
               bodyTrainer + 
               bodyStartDate + 
               bodyEndDate + 
               bodyClose + 
               bodySignature;
    }

    public static EmailTemplate queryEmailTemplateForParticipantTrainingReminder() {
        return [
            SELECT Id, Subject, HtmlValue, DeveloperName, Body
            FROM EmailTemplate WHERE Name = :PARTICIPANT_EMAIL_TEMPLATE
            LIMIT 1
        ];
    }

}