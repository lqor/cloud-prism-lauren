import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import savePdfToContentVersion from '@salesforce/apex/TrainingFlyerController.savePdfToContentVersion';

export default class SaveTrainingPdfHeadless extends LightningElement {

    @api recordId;

    @api invoke() {
        this.savePdf()
    }

    savePdf() {
        savePdfToContentVersion({ trainingId: this.recordId })
            .then(result => {
                JSON.stringify(result);
                
                this.reloadPage();
                this.showToast();
            });
    }

    showToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'PDF saved successfully',
                variant: 'success'
            })
        );
    }

    reloadPage() {
        window.location.reload();
    }

}