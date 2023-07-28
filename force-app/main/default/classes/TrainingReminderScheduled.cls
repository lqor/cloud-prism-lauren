public class TrainingReminderScheduled implements Schedulable {
  /**
   * This method is part of the Training notification process. It is called from the scheduled class,
   * "TrainingReminderScheduled."
   */
  public void execute(SchedulableContext sc) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Date threeDaysFromToday = System.today().addDays(3);

    List<Training__c> trainings = queryTrainingsWithParticipantsByIdAndDate(
      threeDaysFromToday
    );

    for (Training__c training : trainings) {
      Messaging.SingleEmailMessage trainerEmail = createTrainerEmailFromTraining(
        training
      );

      for (Participant__c participant : training.Participants__r) {
        Messaging.SingleEmailMessage participantEmail = createParticipantEmailFromTraining(
          training,
          participant
        );

        emails.add(participantEmail);
      }

      emails.add(trainerEmail);
    }

    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails);
    }
  }

  private Messaging.SingleEmailMessage createTrainerEmailFromTraining(
    Training__c training
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String subject = 'Training Reminder: ' + training.Name;

    email.setToAddresses(new List<String>{ training.TrainerContact__r.Email });
    email.setSubject(subject);
    email.setHtmlBody(createHtmlBody(training));

    return email;
  }

  private Messaging.SingleEmailMessage createParticipantEmailFromTraining(
    Training__c training,
    Participant__c participant
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setTargetObjectId(participant.Contact__r.Id);
    email.setWhatId(participant.Id);
    email.setSaveAsActivity(false);

    EmailTemplate emailTemplate = queryEmailTemplateForParticipantTrainingReminder();
    email.setTemplateId(emailTemplate.Id);

    return email;
  }

  private String createHtmlBody(Training__c training) {
    String trainerName = training.TrainerContact__r.FirstName;
    String startDate = String.valueOf(
      training.StartDate__c.format('d MMM y, K:m a z')
    );
    String endDate = String.valueOf(
      training.EndDate__c.format('d MMM y, K:m a z')
    );
    Integer numberOfParticipants = training.Participants__r.size();

    String bodyGreeting = '<p>Dear ' + trainerName + ',</p>';
    String bodyCourse =
      '<p>This is an automatic reminder for the upcoming <b>' +
      training.Name +
      '</b> ';
    String bodyStartDate = 'training that will take place from ' + startDate;
    String bodyEndDate = ' until ' + endDate + '.</p>';
    String bodyParticipantNumber =
      '<p>There are a total of ' +
      numberOfParticipants +
      ' participants:</p>';
    String bodyParticipantList = createParticipantList(
      training.Participants__r
    );
    String bodySignature = '<p>Best regards,<br/><br/>Training Reminder</p>';

    return bodyGreeting +
      bodyCourse +
      bodyStartDate +
      bodyEndDate +
      bodyParticipantNumber +
      bodyParticipantList +
      bodySignature;
  }

  private String createParticipantList(List<Participant__c> participants) {
    String participantList = '<ul>';

    for (Participant__c participant : participants) {
      String participantName =
        participant.Contact__r.FirstName +
        ' ' +
        participant.Contact__r.LastName;
      participantList += '<li>' + participantName + '</li>';
    }

    return participantList += '</ul>';
  }

  public List<Training__c> queryTrainingsWithParticipantsByIdAndDate(
    Date threeDaysFromToday
  ) {
    return [
      SELECT
        Id,
        Name,
        StartDate__c,
        EndDate__c,
        TrainerContact__r.FirstName,
        TrainerContact__r.LastName,
        TrainerContact__r.Email,
        TrainingCourse__r.Name,
        (
          SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email
          FROM Participants__r
        )
      FROM Training__c
      WHERE
        Id IN (SELECT Training__c FROM Participant__c)
        AND DAY_ONLY(convertTimezone(StartDate__c)) = :threeDaysFromToday
        AND Status__c = :TrainingService.TRAINING_STATUS_SCHEDULED
    ];
  }

  public EmailTemplate queryEmailTemplateForParticipantTrainingReminder() {
    return [
      SELECT Id, Subject, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE Name = 'Participant Training Reminder Email'
      LIMIT 1
    ];
  }
}
