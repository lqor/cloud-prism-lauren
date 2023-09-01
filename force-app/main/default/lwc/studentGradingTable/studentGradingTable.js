import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipants from '@salesforce/apex/ParticipantTableController.getParticipants';
import updateParticipants from '@salesforce/apex/ParticipantTableController.updateParticipants';

export default class StudentGradingTable extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'ParticipantName', type: 'text', editable: false },
        { label: 'Email', fieldName: 'ParticipantEmail', type: 'email', editable: false },
        { label: 'Status', fieldName: 'ParticipantStatus', type: 'text', editable: false },
        { label: 'GPA', fieldName: 'ParticipantGPA', type: 'number', editable: true },
        { label: 'Passed', fieldName: 'ParticipantPassed', type: 'boolean', editable: true },
    ];

    @api recordId;
    @track participants = [];
    @track error

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
        const saveDraftValues = event.detail.draftValues;

        const participantsToUpdate = saveDraftValues.filter(this.filterByID).map(draft => {
            const participant = { Id: this.participants[draft.id.substring(4)].ParticipantId };

            if('ParticipantGPA' in draft && draft.ParticipantGPA !== null) {
                participant.GPA__c = draft.ParticipantGPA;
            }
            if('ParticipantPassed' in draft && draft.ParticipantPassed !== null) {
                participant.Passed__c = draft.ParticipantPassed;
            }

            return participant;
        });

        this.saveParticipants(participantsToUpdate);
    }

    saveParticipants(participantsToUpdate) {
        updateParticipants({ participantsToUpdate })
            .then(result => {
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success'
                    })
                );

                this.loadParticipants();
            })
            .catch(error => {
                console.error('Error updating participants:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An Error Occurred!!',
                        variant: 'error'
                    })
                );
            });
    }

    filterByID(draft) {
        if ('id' in draft && draft.id !== null) {
          return true;
        }
        return false;
    }

}