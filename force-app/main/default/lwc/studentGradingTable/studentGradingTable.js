import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipants from '@salesforce/apex/ParticipantTableController.getParticipants';
import updateParticipants from '@salesforce/apex/ParticipantTableController.updateParticipants';
import getParticipantByErpId from '@salesforce/apex/ParticipantTableController.getParticipantByErpId';

export default class StudentGradingTable extends LightningElement {

    @api recordId;
    @api showSearch;

    @track participants = [];
    @track draftValues = [];
    @track erpId;

    error;
    errorMessage;
    showSpinner = false;

    columns = [
        { label: 'Name', fieldName: 'participantName', type: 'text', editable: false },
        { label: 'Email', fieldName: 'participantEmail', type: 'email', editable: false },
        { label: 'Status', fieldName: 'participantStatus', type: 'text', editable: false },
        { label: 'GPA', fieldName: 'participantGPA', type: 'number', editable: true },
        { label: 'Passed', fieldName: 'participantPassed', type: 'boolean', editable: true },
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
                this.showToast('Success', 'Participant(s) successfully updated!', 'success');
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = this.error;
                this.showToast('Error', 'An error occurred while trying to save the Participant(s).', 'error');
            });
    }

    handleClickAddParticipant() {
        if(this.erpId && !isNaN(this.erpId)) {
            this.searchParticipant();
            this.showSpinner = true;
        } else {
            this.showToast('Error', 'Please enter a Participant Erp Id.', 'error');
        }
    }

    searchParticipant() {
        getParticipantByErpId({ trainingId: this.recordId, erpId: this.erpId })
            .then(result => {
                this.participants = [...this.participants, result];
                this.loadParticipants();
                this.showToast('Success', 'Participant successfully added!', 'success');
                this.showSpinner = !this.showSpinner;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = 'Participant with ERP ID "' + this.erpId + '" could not be found.';
                this.showToast('Error', 'An error occurred while trying to add the Participant.', 'error');
                this.showSpinner = !this.showSpinner;
            });
    }

    handleClickNewParticipant() {
        this.addNewParticipant();
    }

    addNewParticipant() {
        this.showToast('Notice', 'This feature will be shipped in the next release.', 'info');
    }

    handleInputChange(event) {
        this.erpId = event.target.value;
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

}