public with sharing class ParticipantService {

    public virtual class ParticipantServiceException extends Exception {}
    public class RefundCreationErrorException extends ParticipantServiceException {}

    public static final String PARTICIPANT_STATUS_ACTIVE = 'Active';
    public static final String PARTICIPANT_STATUS_IN_QUEUE = 'In Queue';
    public static final String PARTICIPANT_STATUS_PARTICIPATED = 'Participated';
    public static final String ERROR_MESSAGE_DUPLICATE = 'This duplicate participant cannot be booked for the training';
    public static final String REFUND_STATUS_PENDING = 'Pending';
    public static final String REFUND_RESPONSE_STATUS_INITIATED = 'Initiated';

    /**
     * This method is part of the Participant organization process. It is
     * invoked from the beforeInsert method on the "ParticipantTriggerHandler"
     * trigger handler class. The result is an error message indicating the
     * duplicate participant cannot be saved.
     * 
     * @param newlist       List of participants
     * @param oldMap        Old map of participants, always null
     */
    public void preventDuplicateParticipantOnTrainings(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for(Participant__c participant : newList) {
            trainingIds.add(participant.Training__c);
            contactIds.add(participant.Contact__c);
        }

        Map<Id, Training__c> trainings = new Map<Id, Training__c>(
            TrainingQueries.queryTrainingsWithParticipantsById(trainingIds)
        );
        Map<Id, Contact> contacts = new Map<Id, Contact>(
            ContactQueries.queryContactsOfParticipantsById(contactIds)
        );

        for(Participant__c participant : newList) {
            List<Participant__c> existingParticipants = trainings.get(participant.Training__c).Participants__r;
            Boolean canBookForOthers = contacts.get(participant.Contact__c).CanBookForOthers__c;

            for(Participant__c existingParticipant : existingParticipants) {
                Boolean isDuplicate = participant.Contact__c == existingParticipant.Contact__c && !canBookForOthers;

                if(isDuplicate) {
                    participant.addError(ERROR_MESSAGE_DUPLICATE);
                }
            }
        }
    }

    /**
     * This method is part of the Training restaurant commission calculation
     * process. It is invoked from the afterInsert method on the trigger handler
     * class, "ParticipantTriggerHandler." It recalculates the result of the
     * restaurant commission when a participant is added or deleted and updates
     * the trainings.
     * 
     * @param newlist       List of participants
     * @param oldMap        Old map of participants
     */
    public void recalculateCommissionOnTrainings(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        TrainingService trainingService = new TrainingService();
        Set<Id> trainingIds = new Set<Id>();

        for(Participant__c participant : newList) {
            trainingIds.add(participant.Training__c);
        }

        List<Training__c> trainingsWithParticipants = TrainingQueries.queryTrainingsWithParticipantsById(trainingIds);
        trainingService.setRestaurantCommissionOnTrainings(trainingsWithParticipants, null);

        if(!trainingsWithParticipants.isEmpty()) {
            update trainingsWithParticipants;
        }
    }

    /**
     * This method is part of the Participant registration confirmation process.
     * It is invoked from the afterInsert method on the trigger handler class,
     * "ParticipantTriggerHandler." It submits the queueable class,
     * "RegistrationConfirmationQueueable," as a job on the queue.
     * 
     * @param newlist       List of participants
     * @param oldMap        Old map of participants, always null
     */
    public void enqueueRegistrationConfirmationJob(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> participantIds = new Set<Id>();

        for(Participant__c participant : newList) {
            participantIds.add(participant.Id);
        }

        List<Training__c> trainingsWithParticipants = TrainingQueries.queryTrainingsForNewParticipantsByParticipantIds(
            participantIds
        );

        Id registrationJobId = System.enqueueJob(new RegistrationConfirmationQueueable(trainingsWithParticipants));
    }

    /**
     * This method is part of the Participant payment handling process. It is
     * invoked from the afterInsert method on the trigger handler class, 
     * "ParticipantTriggerHandler." It submits the "InvoiceCreationQueueable"
     * queueable class, as a job on the queue.
     * 
     * @param newlist       List of participants
     * @param oldMap        Old map of participants, always null
     */
    public void enqueueInvoiceCreationJob(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> participantIds = new Set<Id>();

        for(Participant__c participant : newList) {
            participantIds.add(participant.Id);
        }

        List<Training__c> trainingsWithParticipants = TrainingQueries.queryTrainingsForNewParticipantsByParticipantIds(
            participantIds
        );

        Id invoiceJobId = System.enqueueJob(new InvoiceCreationQueueable(trainingsWithParticipants));
    }

    /**
     * This method is part of the Participant refund handling process. It is
     * invoked from the requestRefundAction method in the controller class,
     * "RequestRefundController." It sends a callout to the payment server to
     * generate a refund for a participant.
     * 
     * @param participantId Id of the participant requesting the refund
     * @param reason        Reason for requesting the refund
     * @return String       Name of the invoice being refunded
     */
    public String initiateRefundOrder(Id participantId, String reason) {
        TrainingInvoice__c invoice = TrainingInvoiceQueries.queryInvoiceByParticipantId(participantId);
        TrainingRefund__c refund = createTrainingRefundForParticipant(invoice, reason);
        RefundCallout.RefundResponseBody refundResponse = RefundCallout.doRefundCalloutForParticipant(refund);

        handleSucccessfulRefundCallout(refund, refundResponse);

        Id refundJobId = System.enqueueJob(new RefundPollingQueueable(refundResponse), 1);

        return invoice.Name;
    }
 
    private TrainingRefund__c createTrainingRefundForParticipant(TrainingInvoice__c invoice, String reason) {
        TrainingRefund__c refund = new TrainingRefund__c();

        refund.TrainingInvoice__r = new TrainingInvoice__c(InvoiceId__c = invoice.InvoiceId__c);
        refund.Amount__c = invoice.GrandTotal__c;
        refund.Participant__c = invoice.Participant__c;
        refund.Reason__c = reason;
        refund.RefundDate__c = System.today();

        return refund;
    }

    private void handleSucccessfulRefundCallout(TrainingRefund__c refund, RefundCallout.RefundResponseBody refundResponse) {
        if(refundResponse.status == ParticipantService.REFUND_RESPONSE_STATUS_INITIATED) {
            refund.Status__c = REFUND_STATUS_PENDING;
            refund.RefundId__c = refundResponse.refund_id;

            insert refund;
        }
    }

    /**
     * This method is part of the Training roll-up summary of participants. It
     * is invoked from the afterInsert method on the trigger handler class,
     * "ParticipantTriggerHandler." It counts participants and updates the field
     * on trainings.
     * 
     * @param newlist       List of participants
     * @param oldMap        Old map of participants, always null
     */
    public void countNumberOfParticipantsInTrainings(List<Participant__c> newList, Map<Id, Participant__c> oldMap) {
        Set<Id> trainingIds = new Set<Id>();

        for(Participant__c participant : newList) {
            trainingIds.add(participant.Training__c);
        }

        List<Training__c> trainingsWithParticipants = TrainingQueries.queryTrainingsWithParticipantsById(trainingIds);

        for(Training__c training : trainingsWithParticipants) {
            training.NumberOfParticipants__c = training.Participants__r.size();
        }

        if(!trainingsWithParticipants.isEmpty()) {
            update trainingsWithParticipants;
        }
    }

    /**
     * This method is part of the Participant to ERP syncing process. It is
     * called from the invocable method, sendParticipantsToERP, in the 
     * "ParticipantSync" class. It is also called from the execute method in
     * the batchable class, "ParticipantSyncBatch." It makes the ERP callout to
     * send participants to the ERP system, updates each record with the ERP Id,
     * and returns the list of participants.
     * 
     * @param participants          List of participants to send to the ERP system
     * @return List<Participant__c> List of participants returned from the ERP system
     */
    public List<Participant__c> sendParticipantToERP(List<Participant__c> participants) {
        List<Participant__c> participantsToReturn = new List<Participant__c>();

        for(Participant__c participant : participants) {
            String participantJSON = JSON.serialize(participant);
            String responseBody = '';
            Logger logger = new Logger();

            try {
                responseBody = ERPCallout.doERPCalloutForParticipant(participantJSON);
            } catch(ERPCallout.EmptyParticipantException e) {
                logger.logERPCalloutException(e);
            } catch(Exception e) {
                logger.logException(e);
            }

            String erpId = ERPCallout.parseErpId(responseBody);

            participant.ErpId__c = erpId;
            participantsToReturn.add(participant);
        }

        return participantsToReturn;
    }

    /**
     * This method is part of the Participant from ERP import process. It is
     * invoked from the getParticipantByErpId method in the controller class,
     * "ParticipantTableController." It makes the ERP callout to get a
     * participant from the ERP system.
     * 
     * @param trainingId    Id of the training to add the participant to
     * @param erpId         Erp id of the participant to look up
     * @return String       Participant name from the ERP system
     */
    public String getParticipantFromERP(Id trainingId, String erpId) {
        String responseBody = '';
        Logger logger = new Logger();

        try {
            responseBody = ERPCallout.doERPCalloutForParticipantByErpId(erpId);
        } catch(ERPCallout.EmptyErpIdException e) {
            logger.logERPCalloutException(e);
        } catch(Exception e) {
            logger.logException(e);
        }

        String participantName = ERPCallout.parseParticipantName(responseBody);

        return participantName;
    }

    /**
     * This method is part of the Participant from ERP import process. It is
     * invoked from the getParticipantByErpId method in the controller class,
     * "ParticipantTableController." It returns a new participant record added
     * to the new training.
     * 
     * @param trainingId        Id of the training to add the participant to
     * @param priorParticipant  Participant returned from the ERP system
     * @return Participant__c   Participant record added to the new training

     */
    public Participant__c insertNewParticipantFromPrior(Id trainingId, Participant__c priorParticipant) {
        Participant__c newParticipant = new Participant__c();

        newParticipant.Contact__c = priorParticipant.Contact__c;
        newParticipant.Training__c = trainingId;
        newParticipant.Status__c = PARTICIPANT_STATUS_ACTIVE;

        try {
            insert newParticipant;
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }

        Participant__c participantToReturn = ParticipantQueries.queryParticipantById(newParticipant.Id);

        return participantToReturn;
    }

    /**
     * This method is part of the Participant creation process. It is called
     * from the addNewParticipant method in the controller class, 
     * "ParticipantTableController."
     * 
     * @param trainingId        Id of the training to add the participant to
     * @param participant       Participant to be added
     * @return Participant__c   Participant record added to the new training
     */
    public Participant__c insertNewParticipant(Id trainingId, Participant__c participant) {
        participant.Training__c = trainingId;

        try {
            insert participant;
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }

        Participant__c participantToReturn = ParticipantQueries.queryParticipantById(participant.Id);

        return participantToReturn;
    }

}