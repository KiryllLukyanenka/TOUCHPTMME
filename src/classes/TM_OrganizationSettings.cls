public class TM_OrganizationSettings
{
    public static final Set<String> SYSTEM_PROFILE_NAMES = new Set<String>{'System Administrator'};
    public static final String namespace = [select NamespacePrefix from ApexClass where Name = 'TM_ConfigController'].NamespacePrefix;
    
    public static Boolean isSystemAdmin()
    {
        String userProfileName = [select Profile.Name from User where Id = :UserInfo.getUserId()].Profile.Name;
        return SYSTEM_PROFILE_NAMES.contains(userProfileName);    
    }         
    public static List<String> getShippingOrBillingAddresses()
    {        
        List<Territory_Config__c> configs = [select Billing_Shipping_Address__c from Territory_Config__c order by LastModifiedDate desc limit 1];
        if(configs.size() > 0)
        {
            if(configs[0].Billing_Shipping_Address__c == 'Shipping')
            {
                return new List<String>{'ShippingCountry', 'ShippingState', 'ShippingPostalCode', 'ShippingCity'};               
            }
            else
            {
                return new List<String>{'BillingCountry', 'BillingState', 'BillingPostalCode', 'BillingCity'};
            }
        }
        else
        {
            return null;
        }
    }

    public static Territory_Config__c getTerritoryConfig()
    {
        Territory_Config__c config = new Territory_Config__c();
        List<Territory_Config__c> configs = [select Id, Approver__c, Approver__r.Name, Billing_Shipping_Address__c, Catch_All_Territory_Name__c, Catch_All_Territory_Owner__c, Catch_All_Territory_Owner__r.Name, Include_Contacts__c, Include_Open_Activities__c, Include_Open_Opps__c, Schedule_Job_Id__c, Territory_Snapshots__c, Use_Approval_Process__c from Territory_Config__c order by LastModifiedDate desc limit 1];
        if(!configs.isEmpty())
        {
            config = configs[0];
        }
        return config;
    }
    
    public static String getCatchAllRecordTypeId()
    {
        String objectName = String.isNotBlank(namespace) ? namespace + '__Territory__c' : 'Territory__c';
        List<RecordType> recordTypes = [select Id, sObjectType from RecordType where sObjectType = :objectName and  Name = 'Catch All' limit 1];
        if(recordTypes.size() > 0)
        {
            return recordTypes[0].Id;
        }
        return null;
    }

    public static Territory__c getCatchAllTerritory()
    {
        String recordTypeId = getCatchAllRecordTypeId();
        List<Territory__c> catchAllTerritory = [select Id, RecordTypeId, Current_Owner__c from Territory__c where Territory_Type__c = 'Catch All' and RecordTypeId = :recordTypeId];
        if(!catchAllTerritory.isEmpty())
        {
            return catchAllTerritory[0];
        }
        return null;
    }
}