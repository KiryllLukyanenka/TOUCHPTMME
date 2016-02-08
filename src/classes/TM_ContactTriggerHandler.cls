public class TM_ContactTriggerHandler
{
    public static void setContactOwner(List<Contact> contacts)
    {
        Territory_Config__c config = TM_OrganizationSettings.getTerritoryConfig();
        for(Contact contact : contacts)
        {
            if(!contact.No_Territory_Assignment__c && config.Include_Contacts__c && contact.AccountId != null && contact.OwnerId != contact.AccountOwnerId__c)
            {
                contact.OwnerId = contact.AccountOwnerId__c;
            }
        }
    }
}