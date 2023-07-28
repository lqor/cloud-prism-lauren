public with sharing class RegistrationConfirmationQueueable implements Queueable {
  private List<Training__c> trainings;

  public RegistrationConfirmationQueueable(List<Training__c> trainings) {
    this.trainings = trainings;
  }

  /**
   * This method is part of the Participant notification process. It is called from the queueable class,
   * "RegistrationConfirmationQueueable."
   */
  public void execute(QueueableContext context) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Training__c training : trainings) {
      for (Participant__c participant : training.Participants__r) {
        Messaging.SingleEmailMessage email = createParticipantRegistrationEmailForCourse(
          training,
          participant
        );

        emails.add(email);
      }
    }

    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails);
    }
  }

  /**
   * This method is part of the Participant notification process. It is called from the queueable class,
   * "RegistrationConfirmationQueueable." It returns an email prepared for the newly enrolled participant.
   *
   * @param training      Training the new participant has registered for
   * @param participant   Participant to be notified
   */
  public Messaging.SingleEmailMessage createParticipantRegistrationEmailForCourse(
    Training__c training,
    Participant__c participant
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String subject =
      'Enrollment Confirmation: ' + training.TrainingCourse__r.Name;

    email.setToAddresses(new List<String>{ participant.Contact__r.Email });
    email.setSubject(subject);
    email.setHtmlBody(createHtmlBody(training, participant));

    return email;
  }

  private String createHtmlBody(
    Training__c training,
    Participant__c participant
  ) {
    String participantName =
      participant.Contact__r.FirstName +
      ' ' +
      participant.Contact__r.LastName;
    String trainerName =
      training.TrainerContact__r.FirstName +
      ' ' +
      training.TrainerContact__r.LastName;
    String courseName = training.TrainingCourse__r.Name;
    String startDate = String.valueOf(
      training.StartDate__c.format('d MMM y, K:mm a z')
    );
    String endDate = String.valueOf(
      training.EndDate__c.format('d MMM y, K:mm a z')
    );

    String bodyGreeting = '<p>Dear ' + participantName + ',</p>';
    String bodyCourse =
      '<p>Congrats! You\'re all signed up for your <b>' +
      courseName +
      '</b> course with ';
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
}
