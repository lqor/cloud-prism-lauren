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
        console.log('this.reason: ' + this.reason);
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
                console.log('refund done:' + result);

                this.closeAction();
                this.showToast('Success', 'Refund order ' + result + ' was submitted.', 'success');
                this.reloadPage();
            })
            .catch(error => {
                console.log('refund issue: ' + error);

                this.closeAction();
                this.showToast('Error', 'Error occurred while trying to submit refund.', 'error');
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