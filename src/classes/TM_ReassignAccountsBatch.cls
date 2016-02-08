global class TM_ReassignAccountsBatch implements Database.Batchable<sObject>
{
    //Obsoleted
    //Start
    global Map<String, Territory__c> countryMap = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryStateMap = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryZipCodeMap = new Map<String, Territory__c>();

    global Map<String, Map<String, Territory__c>> newCountryMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryStateMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryZipCodeMap = new Map<String, Map<String, Territory__c>>();
    //End

    String query;
    List<String> addresses = new List<String>();
    List<Territory__c> catchAllTerritories = new List<Territory__c>();
    Territory_Config__c config = new Territory_Config__c();
    Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
    Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();

    global TM_ReassignAccountsBatch(String query, List<String> addresses, Map<String, Territory__c> countryMap, Map<String, Territory__c> countryStateMap, Map<String, Territory__c> countryZipCodeMap) 
    { 
    }

    global TM_ReassignAccountsBatch(String query, List<String> addresses, Map<String, Map<String, Territory__c>> countryMap, Map<String, Map<String, Territory__c>> countryStateMap, Map<String, Map<String, Territory__c>> countryZipCodeMap) 
    {
    }

    global TM_ReassignAccountsBatch(String query, List<String> addresses, Map<String, List<Assignment_Detail__c>> countryAssignmentMap, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, Map<String, Territory__c> territoryMap) 
    {
        this.query = query;
        this.addresses = addresses;
        this.countryAssignmentMap = countryAssignmentMap;
        this.countryStateAssignmentMap = countryStateAssignmentMap;
        this.countryZipCodeAssignmentMap = countryStateAssignmentMap; 
        catchAllTerritories = [select Id, Current_Owner__c, Current_Owner__r.IsActive from Territory__c where Territory_Type__c = 'Catch All' limit 1];  
        config = TM_OrganizationSettings.getTerritoryConfig(); 
        this.territoryMap = territoryMap;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Account> accts = (List<Account>)scope;
        List<Account> updatingAccounts = new List<Account>();
        List<Contact> updatingContacts = new List<Contact>();
        List<Opportunity> updatingOpps = new List<Opportunity>();
        List<Task> updatingTasks = new List<Task>();
        List<Event> updatingEvents = new List<Event>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, String> oldAccountOwnerMap = new Map<String, String>();
        for(Account acct : accts)
        {
            Boolean isFindTerritory = false;
            String country = acct.get(addresses[0]) != null ? ((String)acct.get(addresses[0])).toLowerCase() : '';
            String state = acct.get(addresses[1]) != null ? ((String)acct.get(addresses[1])).toLowerCase() : '';
            String postalCode = acct.get(addresses[2]) != null ? String.valueOf(acct.get(addresses[2])).toLowerCase() : '';
            String countryState = country + '/' + state;
            if(countryZipCodeAssignmentMap.containsKey(countryState))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritoryFromCountryZipCodeMap(updatingAccounts, countryZipCodeAssignmentMap, countryState, postalCode, territoryMap, acct);
            }
            if(!isFindTerritory && countryStateAssignmentMap.containsKey(countryState))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryStateAssignmentMap, countryState, territoryMap, acct);
            }
            if(!isFindTerritory && countryAssignmentMap.containsKey(country))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryAssignmentMap, country, territoryMap, acct);
            }
            if(!isFindTerritory)
            {
                Territory__c territory = catchAllTerritories[0];
                if(acct.OwnerId != territory.Current_Owner__c || acct.Territory__c != territory.Id){
                    acct.OwnerId = territory.Current_Owner__c;
                    acct.Territory__c = territory.Id;
                    updatingAccounts.add(acct);
                }
            }     
        }
        
        if(updatingAccounts.size() > 0)
        {    
            update updatingAccounts;
        }
        if(config.Include_Contacts__c)
        {
            TM_TerritoryManagementHelper.syncContactOwnerWithAccountOwner(accountMap);
        }
        if(config.Include_Open_Opps__c)
        {
            TM_TerritoryManagementHelper.syncOppOwnerWithAccountOwner(accountMap);
        }
        if(config.Include_Open_Activities__c)
        {
            TM_TerritoryManagementHelper.syncActivitiesOwnerWithAccountOwner(accountMap, oldAccountOwnerMap);
        }
    }

    global void finish(Database.BatchableContext bc)
    {

    }
}