({
    handleClick : function(component, event, helper) {
        var action = component.get("c.saveCertificates");

        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");

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
        
        JSON.stringify(event);
        JSON.stringify(helper);
    }
})