public with sharing class EmailService {

    public static final String FORMAT_DATE_TIME = 'd MMM y, K:mm a z';
    public static final String PARTICIPANT_EMAIL_TEMPLATE = 'Participant Training Reminder Email';

    /**
     * This method is part of the Training communication process. It is called
     * from the scheduled class, "TrainingReminderScheduled." It returns an
     * email to the trainer about their upcoming training.
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
     * This method is part of the Training communication process. It is called
     * from the scheduled class, "TrainingReminderScheduled." It returns an
     * email to the participant about their upcoming training.
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
     * This method is part of the Participant registration confirmation process.
     * It is invoked from the execute method on the queueable class,
     * "RegistrationConfirmationQueueable."
     * 
     * @param training                      Training course the new participant has registered for
     * @param participant                   Participant to be notified
     * @return Messaging.SingleEmailMessage Email confirming enrollment
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

        String bodyGreeting = '<p>Hello ' + participantName + ',</p>';
        String bodyCourse = '<p>Congrats! You\'re all signed up for your <b>' + courseName + '</b> course with ';
        String bodyTrainer = trainerName + ' on ';
        String bodyStartDate = startDate + ' through ';
        String bodyEndDate = endDate + '.</p>';
        String bodyClose = '<p>We look forward to seeing you at the training!</p>';
        String bodySignature = '<p>Best regards,<br/>Cloud Prism</p>';

        return bodyGreeting + 
               bodyCourse + 
               bodyTrainer + 
               bodyStartDate + 
               bodyEndDate + 
               bodyClose + 
               bodySignature;
    }

    /**
     * This method is part of the Participant payment handling process. It is
     * invoked from the execute method on the "InvoicePostProcessingQueueable"
     * queueable class.
     * 
     * @param training                      Training course the new participant has registered for
     * @param participant                   Participant to be notified
     * @return Messaging.SingleEmailMessage Email with payment link
     */
    public static Messaging.SingleEmailMessage createParticipantPaymentEmail(
        Training__c training, 
        Participant__c participant
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'Enrollment Confirmation: ' + training.TrainingCourse__r.Name;

        email.setToAddresses(new List<String> {participant.Contact__r.Email});
        email.setSubject(subject);
        email.setHtmlBody(createParticipantPaymentHtmlBody(training, participant));

        return email;
    }

    private static String createParticipantPaymentHtmlBody(Training__c training, Participant__c participant) {
        String participantName = participant.Contact__r.FirstName + ' ' + participant.Contact__r.LastName;
        String courseName = training.TrainingCourse__r.Name;
        String startDate = String.valueOf(training.StartDate__c.format(FORMAT_DATE_TIME));
        String endDate = String.valueOf(training.EndDate__c.format(FORMAT_DATE_TIME));
        String paymentLink = participant.PaymentLink__c;

        String bodyGreeting = '<p>Hello ' + participantName + ',</p>';
        String bodyCourse = '<p>To complete your registration for the <b>' + courseName + '</b> course on ';
        String bodyStartDate = startDate + ' through ';
        String bodyEndDate = endDate + ', please make a payment by clicking on the ';
        String bodyPaymentLink = '<a href="' + paymentLink + '" target="_blank">payment link here</a>.</p>';
        String bodyClose = '<p>We look forward to seeing you at the training!</p>';
        String bodySignature = '<p>Best regards,<br/>Cloud Prism</p>';

        return bodyGreeting + 
               bodyCourse + 
               bodyStartDate + 
               bodyEndDate + 
               bodyPaymentLink + 
               bodyClose + 
               bodySignature;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPostProcessingQueueable"
     * queueable class.
     * 
     * @param training                      Training course the new participant has registered for
     * @return Messaging.SingleEmailMessage Email to the participant confirming the refund was processed
     */
    public static Messaging.SingleEmailMessage createParticipantRefundProcessedEmail(TrainingInvoice__c invoice) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'Invoice Refund Confirmation: ' + invoice.Training__r.TrainingCourse__r.Name;

        email.setToAddresses(new List<String> {invoice.Participant__r.Contact__r.Email});
        email.setSubject(subject);
        email.setHtmlBody(createParticipantRefundHtmlBody(invoice));

        return email;
    }

    private static String createParticipantRefundHtmlBody(TrainingInvoice__c invoice) {
        String participantName = invoice.Participant__r.Contact__r.FirstName + ' ' + invoice.Participant__r.Contact__r.LastName;
        String courseName = invoice.Training__r.TrainingCourse__r.Name;
        String invoiceName = invoice.Name;
        Decimal invoiceAmount = invoice.GrandTotal__c;

        String bodyGreeting = '<p>Hello ' + participantName + ',</p>';
        String bodyInvoice = '<p>This is confirmation that a full refund has been processed for Invoice ' + invoiceName;
        String bodyAmount = ' in the amount of $' + invoiceAmount + '. ';
        String bodyRefund = 'The refund has been returned via the payment method you originally paid with.</p>';
        String bodyClose = '<p>If you have any further questions, please feel free to contact us.</p>';
        String bodySignature = '<p>Best regards,<br/>Cloud Prism</p>';

        return bodyGreeting + bodyInvoice + bodyAmount + bodyRefund + bodyClose + bodySignature;
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the execute method on the "RefundPostProcessingQueueable"
     * queueable class.
     * 
     * @param refund                        Refund that could not be processed
     * @return Messaging.SingleEmailMessage Email to the admin regarding refund processing issue
     */
    public static Messaging.SingleEmailMessage createRefundOrderFailedEmail(TrainingRefund__c refund) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String subject = 'Refund Processing Stalled: ' + refund.Id;

        //check if user is admin profile, or else designate admin email adress
        email.setToAddresses(new List<String> {UserInfo.getUserEmail()});
        email.setSubject(subject);
        email.setHtmlBody(createRefundOrderFailedHtmlBody(refund));

        return email;
    }

    private static String createRefundOrderFailedHtmlBody(TrainingRefund__c refund) {
        String refundName = refund.Name;
        String refundId = refund.Id;
        String recordLink = URL.getOrgDomainURL().toExternalForm() + '/' + refundId;

        String bodyRefundName = '<p>Refund processing for ' + refundName + ' has stalled after three attempts to poll ';
        String bodyNotify = 'the server. Please investigate and notify the participant to verify payment details.</p>';
        String bodyDetails = '<p>For more details, view the refund record: ';
        String bodyRecordLink = '<a href="' + recordLink + '" target="_blank">' + refundId + '</a>.</p>';
        String bodySignature = '<p>Thank you</p>';

        return bodyRefundName + bodyNotify + bodyDetails + bodyRecordLink + bodySignature;
    }

    public static EmailTemplate queryEmailTemplateForParticipantTrainingReminder() {
        return [
            SELECT Id, Subject, HtmlValue, DeveloperName, Body
            FROM EmailTemplate WHERE Name = :PARTICIPANT_EMAIL_TEMPLATE
            LIMIT 1
        ];
    }

}