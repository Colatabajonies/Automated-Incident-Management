public class AIM_SendEmails 
{
    @InvocableMethod(label='AIM - Send Emails')
    public static List<SendEmailResult> sendEmail(List<SendEmailRequest> requests)
    {
        List<SendEmailResult> results = new List<SendEmailResult>(); 
        for (SendEmailRequest request : requests)
        {
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            SendEmailResult result = new SendEmailResult();
            result.TotalSuccessEmails = 0;
            result.TotalFailedEmails = 0;
            result.failedContactIds = new List<Id>();
            result.failureMessages = new List<String>();
            
            for (Contact c : request.objContacts)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>{c.Email};
                mail.setToAddresses(sendTo);
                mail.setTargetObjectId(c.id);
                mail.setTreatTargetObjectAsRecipient(true);
                mail.setOrgWideEmailAddressId(request.orgWideEmailAddressId);
                if (String.isNotBlank(request.subject) && String.isNotBlank(request.body))
                {
                    mail.setSubject(request.subject);
                    mail.setHtmlBody(request.body);
                    mail.setTreatBodiesAsTemplate(true);
                }
                else if (string.isNotBlank(request.templateId))
                {
                    mail.setTemplateId(request.templateId);
                }
                mail.setSaveAsActivity(request.saveAsActivity);
                if (String.isNotBlank(request.whatId))
                {
                    mail.setWhatId(request.whatId);
                }
                mails.add(mail);
            }
            
            if (mails.size() > 0)
            {
                List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(mails, false);
                for (Messaging.SendEmailResult emailResult : emailResults)
                {
                    if (emailResult.isSuccess())
                    {
                        result.TotalSuccessEmails+=1;
                    }
                    else
                    {
                        result.TotalFailedEmails+=1;
                        result.failedContactIds.add(emailResult.getErrors()[0].getTargetObjectId());
                        result.failureMessages.add(emailResult.getErrors()[0].getMessage());
                    }
                }
            }
            results.add(result);
        }
        return results;
    }
    
    public class SendEmailResult
    {
        @InvocableVariable(label='Total Emails Successfully Sent')
        public Integer TotalSuccessEmails;
        
        @InvocableVariable(label='Total Emails Failed')
        public Integer TotalFailedEmails;
        
        @InvocableVariable(label='Failed ContactIDs')
        public List<Id> failedContactIds;
        
        @InvocableVariable(label='Failure Messages')
        public List<string> failureMessages;
    }
    
    public class SendEmailRequest
    {
        @InvocableVariable(label='Contact Object Collection' required=true)
        public List<Contact> objContacts;
        
        @InvocableVariable(label='Org Wide Email Address ID' required=true)
        public string orgWideEmailAddressId;

        @InvocableVariable(label='Email Template Id')
        public string templateId;
        
        @InvocableVariable(label='Email Subject')
        public string subject;
        
        @InvocableVariable(label='Email Body')
        public string body;
                
        @InvocableVariable(label='WhatId')
        public string whatId;
        
        @InvocableVariable(label='Save as Activity')
        public boolean saveAsActivity;
    }
}