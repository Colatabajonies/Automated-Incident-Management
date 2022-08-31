({
    doInit: function (component, event, helper) 
    {
        helper.getSenderAddresses(component, event);
        helper.getEmailTemplateHelper(component, event);
    },

    sendMail: function (component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.emailbody");
        var getSender = component.find("select-Sender").getElement().value;
        var getwhatId = component.get('v.whatId');
        var getSaveAsActivity = component.get('v.saveactivity');
        
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@") || $A.util.isEmpty(getSender)) {
            alert('Invalid selection. Please select a sender address and enter a valid email address to test.');
        } else {
            helper.sendHelper(component, getSender, getEmail, getSubject, getbody, getwhatId, getSaveAsActivity);
        }
    },

    onSelectEmailFolder: function (component, event, helper) {
        var folderId = event.target.value;
        component.set("v.folderId1", folderId);
        if (folderId != null && folderId != '' && folderId != 'undefined') {
            var emailfolderVSTemplateList = component.get("v.emailfolderVSTemplateList");
            emailfolderVSTemplateList.forEach(function (element) {
                if (element.folderId == folderId) {
                    component.set("v.emailTemplateList", element.emailtemplatelist);
                }
            });
        } else {
            var temp = [];
            component.set("v.emailTemplateList", temp);
        }
    },

    
    onSelectSender: function (component, event, helper) {
        component.set("v.orgWideEmailAddressId", event.target.value);
    },
    
    onSelectEmailTemplate: function (component, event, helper) {
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.templateIDs", emailTempId);
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                    emailbody = element.emailbody;
                    emailSubject = element.emailSubject;
                }
            });
        }
        component.set("v.emailbody", emailbody);
        component.set("v.subject", emailSubject);

    },

})