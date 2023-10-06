import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import savePdfToContentVersion from '@salesforce/apex/TrainingFlyerController.savePdfToContentVersion';

export default class SaveTrainingPdf extends LightningElement {

    @api recordId;

    showSpinner = false;

    renderedCallback() {
        if (!this.showSpinner) {
            this.showSpinner = true;
            this.savePdf();
        }

    }

    savePdf() {
        savePdfToContentVersion({ trainingId: this.recordId })
            .then(result => {
                JSON.stringify(result);

                this.showSpinner = false;
                this.showToast('Success', 'File was created.', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
                this.reloadPage();
            }).catch(error => {
                JSON.stringify(error);

                this.showSpinner = false;
                this.showToast('Error', 'Error occurred while trying to create file.', 'error');
                this.dispatchEvent(new CloseActionScreenEvent());
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

    reloadPage() {
        window.location.reload();
    }

}