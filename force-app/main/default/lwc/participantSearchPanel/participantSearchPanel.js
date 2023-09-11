import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipantByErpId from '@salesforce/apex/ParticipantTableController.getParticipantByErpId';
import addNewParticipant from '@salesforce/apex/ParticipantTableController.addNewParticipant';
import newParticipantModal from 'c/newParticipantModal';

export default class ParticipantSearchPanel extends LightningElement {

    @api recordId;
    @api showSearch;

    @track erpId;

    error;
    errorMessage;

    handleInputChange(event) {
        this.erpId = event.target.value;
    }

    handleClickAddParticipant() {
        if(this.erpId) {
            this.searchParticipant();

            this.showSpinner = true;
        } else {
            this.showToast('Error', 'Please enter a Participant Erp Id.', 'error');
        }
    }

    searchParticipant() {
        getParticipantByErpId({ trainingId: this.recordId, erpId: this.erpId })
            .then(result => {
                this.dispatchEvent(new CustomEvent('addparticipantrow', { detail: result[0] }));

                this.showToast('Success', 'Participant successfully added!', 'success');
                this.template.querySelector('lightning-input').value = ''; 
                this.showSpinner = !this.showSpinner;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = 'Participant with ERP ID "' + this.erpId + '" could not be found.';

                this.showToast('Error', 'An error occurred while trying to add the Participant.', 'error');
                this.template.querySelector('lightning-input').value = ''; 
                this.showSpinner = !this.showSpinner;
            });
    }

    handleClickNewParticipant() {
        newParticipantModal.open({
            size: 'small',
            trainingId: this.recordId,
            onnewparticipant: (e) => {
                this.addParticipant(e);
            }
        });
    }

    addParticipant(event) {
        addNewParticipant({ trainingId: this.recordId, serializedParticipant: JSON.stringify(event.detail) })
            .then(result => {
                this.dispatchEvent(new CustomEvent('addparticipantrow', { detail: result[0] }));

                this.showToast('Success', 'Participant successfully added!', 'success');
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = 'Participant could not be created.';

                this.showToast('Error', 'An error occurred while trying to add the Participant.', 'error');
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

}