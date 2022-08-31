public class AIM_EmailTemplateEditorController 
{
    @AuraEnabled 
    public static void sendTestMailMethod(String mMail, string mSender, String mSubject,String mbody, String templateId, String whatId, Boolean saveAsActivity)
    {
        List<Contact> objContacts = new List<Contact>([SELECT ID FROM Contact WHERE email =: mMail LIMIT 1]);
        
        //list<EmailTemplate> em = new list<EmailTemplate>();
        //em = [SELECT Id,Subject,Body,HtmlValue From EmailTemplate where id =: templateId limit 1];
        
        //List<EmailMessage> emailmessageList =  new List<EmailMessage>();
        //emailmessageList = [select id, Subject,TextBody from emailmessage where EmailTemplateId =: templateId order By createddate desc limit 1];
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        mail.setToAddresses(sendTo);
        
        
        mail.setOrgWideEmailAddressId(mSender);
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        mail.setSaveAsActivity(saveAsActivity);
        
        if (objContacts.size() > 0)
        {
            mail.setTargetObjectId(objContacts[0].Id);
        }
        
        mail.setWhatId(whatId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setTreatBodiesAsTemplate(true);
        //mail.setTemplateId(em.get(0).id);
        mails.add(mail);
        
        Messaging.sendEmail(mails);
    }   
    
    @AuraEnabled
    public static list<OrgWideEmailAddress> getSenderAddresses()
    {
        Return new List<OrgWideEmailAddress>([SELECT ID, Address, DisplayName FROM OrgWideEmailAddress]);
    }
    
    @AuraEnabled
    public static list<emailTemplateWrapper> getEmailTempaltes(){
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        List<Folder> folderObjs = new List<folder>([SELECT Id,Name FROM Folder where Type='EmailTemplate']);
        List<ID> folderIDs = new List<ID>();
        for (Folder f : folderObjs)
        {
            folderIds.add(f.id);
        }
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and FolderId IN: folderIDs ]){ 
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            
            return emailTemplateWrapperlist;
        }
        return null;
    }
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  
}