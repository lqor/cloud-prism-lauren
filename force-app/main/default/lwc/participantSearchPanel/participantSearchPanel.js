import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParticipantByErpId from '@salesforce/apex/ParticipantTableController.getParticipantByErpId';
import addNewParticipant from '@salesforce/apex/ParticipantTableController.addNewParticipant';
import newParticipantModal from 'c/newParticipantModal';

export default class ParticipantSearchPanel extends LightningElement {

    @api recordId;
    @api showSearch;
    @api errorMessage;

    @track erpId;

    handleInputChange(event) {
        this.erpId = event.target.value;
    }

    handleClickAddParticipant() {
            this.searchParticipant();
            this.showSpinner = true;
    }

    searchParticipant() {
        getParticipantByErpId({ trainingId: this.recordId, erpId: this.erpId })
            .then(result => {
                this.dispatchEvent(new CustomEvent('addrow', { detail: result[0] }));

                this.showToast('Success', 'Participant "' + result[0].participantName + '" was added.', 'success');
                this.template.querySelector('lightning-input').value = '';
                this.showSpinner = !this.showSpinner;
            })
            .catch(error => {
                this.dispatchEvent(new CustomEvent('addrowerror', { detail: error }));

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
                this.dispatchEvent(new CustomEvent('addrow', { detail: result[0] }));

                this.showToast('Success', 'Participant "' + result[0].participantName + '" was created.', 'success');
            })
            .catch(error => {
                this.dispatchEvent(new CustomEvent('addrowerror', { detail: error }));
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