import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipants from '@salesforce/apex/ParticipantTableController.getParticipants';
import updateParticipants from '@salesforce/apex/ParticipantTableController.updateParticipants';
import deleteParticipant from '@salesforce/apex/ParticipantTableController.deleteParticipant';

export default class StudentGradingTable extends LightningElement {

    @api recordId;
    @api showSearch;

    @track participants = [];
    @track draftValues = [];

    error;
    errorMessage;
    showSpinner = false;

    columns = [
        { 
            label: 'Name', 
            fieldName: 'participantUrl', 
            type: 'url', 
            editable: false, 
            displayReadOnlyIcon: true, 
            typeAttributes: { 
                label: { fieldName: 'participantName' }, 
                target: '_self' 
            } 
        },
        { label: 'Email', fieldName: 'participantEmail', type: 'email', editable: false, displayReadOnlyIcon: true },
        { label: 'Status', fieldName: 'participantStatus', type: 'text', editable: false, displayReadOnlyIcon: true },
        { label: 'GPA', fieldName: 'participantGPA', type: 'number', editable: true },
        { label: 'Passed', fieldName: 'participantPassed', type: 'boolean', editable: true },
        { 
            label: 'Delete', 
            type: 'button', 
            typeAttributes: {
                label: 'Delete', 
                iconName: 'utility:delete',
                title: 'Delete', 
                variant: 'destructive'
            }
        }
    ];

    connectedCallback() {
        this.loadParticipants();
    }

    loadParticipants() {
        getParticipants({ trainingId: this.recordId })
            .then(result => {
                this.participants = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSave(event) {
        this.copyDraftToParticipants(event.detail.draftValues);
        this.saveParticipants();
        this.draftValues = [];
    }

    copyDraftToParticipants(draftValues) {
        draftValues.forEach((draftElement) => {
            this.participants.forEach((participantElement) => {
                if(draftElement.participantId === participantElement.participantId) {
                    if(draftElement.participantGPA) {
                        participantElement.participantGPA = draftElement.participantGPA;
                    }

                    if(draftElement.participantPassed !== null) {
                        participantElement.participantPassed = draftElement.participantPassed;
                    }
                }
            });
        });
    }

    saveParticipants() {
        updateParticipants({ serializedParticipants: JSON.stringify(this.participants) })
            .then(result => {
                JSON.stringify(result);

                this.showToast('Success', 'Your changes are saved.', 'success');
                this.errorMessage = '';
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = this.error;

                this.showToast('Error', 'An error occurred while trying to save the changes.', 'error');
            });
    }

    handleRowAction(event) {
        this.deleteParticipant(event);
        this.showSpinner = true;
    }

    deleteParticipant(event) {
        deleteParticipant({ participantId: event.detail.row.participantId })
            .then(result => {
                const rowIndex = this.participants.findIndex(element => {
                    return element.participantId === result;
                });

                this.participants.splice(rowIndex, 1);
                this.participants = [...this.participants];

                this.showToast('Success', 'Participant "' + event.detail.row.participantName + '" was deleted.', 'success');
                this.showSpinner = !this.showSpinner;
                this.errorMessage = '';
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = 'Participant "' + event.detail.row.participantName + '" could not be deleted.';

                this.showToast('Error', 'An error occurred while trying to delete the Participant.', 'error');
                this.showSpinner = !this.showSpinner;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    handleAddParticipant(event) {
        this.participants = [...this.participants, event.detail];
        this.errorMessage = '';
    }

    handleAddParticipantError(event) {
        this.handleErrorMessage(event);
    }

    handleErrorMessage(error) {
        const errorBody = error.detail.body;
        const tryAgain = ' Please try again. If the problem continues, get in touch with your administrator.';
        let errorToast = 'An error occurred.';

        if(errorBody.isUserDefinedException) {
            const errorMessages = errorBody.message.split('.');
            this.errorMessage = errorMessages[1] + '.';
            errorToast = errorMessages[0] + '.';
        } else {
            errorToast = errorBody.exceptionType + '.';

            if(errorBody.exceptionType === 'System.JSONException') {
                this.errorMessage = 'The participant with this ERP ID could not be found.';
            } else if (errorBody.exceptionType === 'System.DmlException') {
                this.errorMessage = 'Please fill in all required fields before saving.'
            } else if (errorBody.exceptionType === 'System.NullPointerException') {
                this.errorMessage = 'System.NullPointerException.';
            } else if (errorBody.exceptionType === 'System.QueryException') {
                this.errorMessage = 'The participant is already booked for this training.';
                errorToast = 'Duplicate participant.';
            } else {
                this.errorMessage = 'Unfortunately, there was a problem.' + tryAgain;
            }
        }

        this.showToast('Error', errorToast, 'error');
    }

}