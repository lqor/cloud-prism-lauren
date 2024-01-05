import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import submitRefundForParticipant from '@salesforce/apex/RefundOrderController.submitRefundForParticipant';

export default class StartRefundOrder extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track options = [
        { label: 'Schedule Change', value: 'Schedule Change' },
        { label: 'Course Cancellation', value: 'Course Cancellation' },
        { label: 'Participant Withdrawal', value: 'Participant Withdrawal' },
        { label: 'Technical Issues', value: 'Technical Issues' },
        { label: 'Billing Error', value: 'Billing Error' },
        { label: 'Other (Specify in Comments)', value: 'Other (Specify in Comments)' }
    ];

    get options() {
        return this.options;
    }

    handleChange(event) {
        this.reason = event.detail.value;
    }

    handleCancel(event) {
        this.closeAction();
    }

    handleSubmit(e) {
        this.submitRefundOrder();
    }

    submitRefundOrder() {
        submitRefundForParticipant({ participantId: this.recordId, reason: this.reason })
            .then(result => {
                this.closeAction();
                this.showToast('Success', 'Training Refund for Invoice "' + result + '" was submitted.', 'success');
                // this.reloadPage();
            })
            .catch(error => {
                this.closeAction();
                this.handleErrorMessage(error)
            });
    }

    handleErrorMessage(error) {
        const errorBody = error.body;

        this.showToast('Error', errorBody.message, 'error');
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
        }, 3000);
    }

}