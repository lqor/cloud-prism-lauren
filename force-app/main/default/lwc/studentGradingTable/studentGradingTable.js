import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipants from '@salesforce/apex/ParticipantTableController.getParticipants';
import updateParticipants from '@salesforce/apex/ParticipantTableController.updateParticipants';

export default class StudentGradingTable extends LightningElement {
    columns = [
        { label: 'Name', fieldName: 'participantName', type: 'text', editable: false },
        { label: 'Email', fieldName: 'participantEmail', type: 'email', editable: false },
        { label: 'Status', fieldName: 'participantStatus', type: 'text', editable: false },
        { label: 'GPA', fieldName: 'participantGPA', type: 'number', editable: true },
        { label: 'Passed', fieldName: 'participantPassed', type: 'boolean', editable: true },
    ];

    @api recordId;
    @track participants = [];
    @track error;
    @track draftValues = [];
    @track erpId;

    connectedCallback() {
        this.loadParticipants();
    }

    loadParticipants() {
        getParticipants({ trainingId: this.recordId })
            .then(result => {
                this.participants = result;
                console.log('this.participants', this.participants);
            })
            .catch(error => {
                this.error = error;
            });
    }

    /*
    handleSave(event) {
        const saveDraftValues = event.detail.draftValues;
        console.log('saveDraftValues', saveDraftValues);

        const participantsToUpdate = saveDraftValues.filter(this.filterByID).map(draft => {
            const participant = { Id: draft.participantId };

            if(draft.participantGPA) {
                participant.GPA__c = draft.participantGPA;
            }

            if('participantPassed' in draft && draft.participantPassed !== null) {
                participant.Passed__c = draft.participantPassed;
            }

            return participant;
        });

        this.saveParticipants(participantsToUpdate);
    } */

    handleSave(event) {
        this.copyDraftIntoStudents(event.detail.draftValues);
        this.saveParticipants();
        this.draftValues = [];
    }

    copyDraftIntoParticipants(draftValues) {
        for(let draftElement of draftValues) {
            for(let participantElement of this.participants) {
                if(draftElement.Id === participantElement.Id) {
                    if(draftElement.participantGPA) {
                        participantElement.GPA__c = draftElement.GPA__c;
                    }

                    if(draftElement.Passed__c !== null) {
                        participantElement.Passed__c = draftElement.Passed__c;
                    }
                }
            }
        }
    }

    saveParticipants() {
        updateParticipants({ participantsToUpdate: this.participants })
            .then(result => {
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                console.error('Error updating participants:', error);
                this.showToast('Error', 'An Error Occurred!!', 'error');
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

    filterByID(draft) {
        return 'participantId' in draft && draft.participantId !== null;
    }

    searchParticipant(event) {
        // Call apex method
        getParticipants({ trainingId: this.recordId, erpId: this.erpId })
    }

    handleInputChange(event) {
        this.erpId = event.target.value;
    }

}