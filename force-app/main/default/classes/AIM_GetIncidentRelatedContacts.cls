public class AIM_GetIncidentRelatedContacts 
{
    @InvocableMethod(label='AIM - Get an Incidents Related Contacts')
    public static List<List<Contact>> getContacts(List<Id> requests)
    {
        List<List<Contact>> results = new List<List<Contact>>(); 
        for (Id request : requests)
        {
            //Get Incident Related Cases
            List<CaseRelatedIssue> cris = new List<CaseRelatedIssue>([SELECT Case.ContactId, Case.AccountId FROM CaseRelatedIssue WHERE RelatedIssueId =: request]);
            List<IncidentRelatedItem> iris = new List<IncidentRelatedItem>([SELECT Asset.ContactId, Asset.AccountId From IncidentRelatedItem WHERE IncidentId =: request]);
            
            List<ID> contactIds = new List<ID>();
            for (CaseRelatedIssue cri : cris)
            {
                if (string.isNotBlank(cri.case.contactId))
                {
                    contactIds.add(cri.case.contactId);
                }
            }
            for (IncidentRelatedItem iri : iris)
            {
                if (string.isNotBlank(iri.Asset.ContactId))
                {
                    contactIds.add(iri.Asset.ContactId);
                }
            }
            
            if (contactIds.size() > 0)
            {
                List<Contact> objContacts = new List<Contact>([SELECT Id, email, name, firstname, lastname FROM Contact WHERE ID IN: contactIds]);
                results.add(objContacts);
            }
        }
        return results;
    }
}