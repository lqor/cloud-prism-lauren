import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class NewParticipantModal extends LightningModal {

    @api trainingId;

    objectApiName = 'Participant__c';
    statusDefault = 'In Queue';

    closePopup() {
        this.close('Closed');
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;

        this.dispatchEvent(new CustomEvent('newparticipant', { detail: fields }));
        this.closePopup();
    }

}