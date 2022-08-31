({
    sendHelper: function (component, getSender, getEmail, getSubject, getbody, getwhatId, getSaveAsActivity) {
        // call the server side controller method 	
        var action = component.get("c.sendTestMailMethod");
        var templateId = component.get("v.templateIDs");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'mMail': getEmail,
            'mSender': getSender,
            'mSubject': getSubject,
            'mbody': getbody,
            'templateId': component.get("v.templateIDs"),
            'whatId': getwhatId,
            'saveAsActivity': getSaveAsActivity
        });
        action.setCallback(this, function (response) 
        {
            component.set("v.mailStatus", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                component.set("v.mailStatus", true);
            }

        });
        $A.enqueueAction(action);
    },

    getEmailTemplateHelper: function (component, event) {

        var action = component.get("c.getEmailTempaltes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.emailfolderVSTemplateList", response.getReturnValue());
                component.set('v.loaded', !component.get('v.loaded'));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },
    
    getSenderAddresses: function (component, event) {

        var action = component.get("c.getSenderAddresses");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.senderList", response.getReturnValue());
                component.set("v.orgWideEmailAddressId", response.getReturnValue()[0].Id);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },
})