import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import savePdfToContentVersion from '@salesforce/apex/TrainingFlyerController.savePdfToContentVersion';

export default class SaveTrainingPdf extends LightningElement {

    @api recordId;

    showSpinner = false;
    hasRecordId = false;

    renderedCallback() {
        if (!this.hasRecordId && this.recordId) {
            this.hasRecordId = true;
            this.savePdf();
            this.showSpinner = true;
        }
    }

    savePdf() {
        savePdfToContentVersion({ trainingId: this.recordId })
            .then(result => {
                this.closeAction();
                this.showSpinner = false;
                this.showToast('Success', 'File was created.', 'success');
                this.reloadPage();
            })
            .catch(error => {
                this.closeAction();
                this.showSpinner = false;
                this.showToast('Error', 'Error occurred while trying to create file.', 'error');
            });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
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

    reloadPage() {
        setTimeout(() => {
            window.location.reload();
        }, 500);
    }

}