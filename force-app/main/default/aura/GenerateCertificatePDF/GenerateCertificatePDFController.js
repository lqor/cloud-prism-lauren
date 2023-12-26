({
    doInit : function(component) {
        let action = component.get("c.getVfUrl");

        action.setParams({ trainingId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                component.set("v.vfUrl", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },
    handleClick : function(component, event, helper) {
        let action = component.get("c.saveCertificates");

        action.setParams({ trainingId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    title: "Success!",
                    message: "PDFs generated successfully.",
                    type: "success"
                });

                toastEvent.fire();

                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    }
})