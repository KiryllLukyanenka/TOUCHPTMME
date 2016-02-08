public class TM_SubmitChangeBoxHelper
{
    public static Set<String> changeBoxIds { get; set; }
    private static Territory_Config__c config = TM_OrganizationSettings.getTerritoryConfig();
    
    public static void executeTerritoryBoundaryBatch(Set<String> modifiedTerritoryIds)
    {
        Map<String, Territory_Boundary__c> territoryBoundaryMap = new Map<String, Territory_Boundary__c>();
        for(Territory_Boundary__c territoryBoundary : [select Id, IsEffective__c, Territory__c, Territory__r.Current_Boundary__c from Territory_Boundary__c where Status__c = 'Approved' and IsEffective__c = true and Territory__c in :modifiedTerritoryIds])
        {
            territoryBoundaryMap.put(territoryBoundary.Territory__c, territoryBoundary);
        } 
        if (territoryBoundaryMap.size() > 0)
        {
            setTerritoryBoundaryForPrevExceptionAccount(territoryBoundaryMap.keySet());
            updateCurrentBoundaryForTerritory(territoryBoundaryMap.values());   
            updateFieldsForAccount(territoryBoundaryMap.values());
            executeTerritoryRealignmentBatch(territoryBoundaryMap);
        }
    }
    
    public static void executeTerritoryOwnerBatch(Set<String> modifiedTerritoryIds)
    {
        List<Territory__c> territoriesToUpdate = new List<Territory__c>();
        for(Territory_Owner__c territoryOwner : [select New_Owner__c, Territory__c, Territory__r.Current_Owner__c from Territory_Owner__c where Territory__c != null and New_Owner__c != null and Status__c = 'Approved' and IsEffective__c = true and Territory__c in :modifiedTerritoryIds])
        {
            if(territoryOwner.Territory__r.Current_Owner__c != territoryOwner.New_Owner__c)
            {
                territoryOwner.Territory__r.Current_Owner__c = territoryOwner.New_Owner__c;
                territoriesToUpdate.add(territoryOwner.Territory__r);                
            }
        }
        if(territoriesToUpdate.size() > 0)
        {
            update territoriesToUpdate;
        }
    }

    public static String convertNumberToCurrencyFormat(Decimal result)
    {
        String resultStr = String.valueOf(result);
        String convertedStr = resultStr.contains('.') ? resultStr.replace('.', ':') : resultStr;
        String[] splits = convertedStr.split(':', 0);
        List<String> parts = new List<String>();
        Integer mod = Math.mod(splits[0].length(), 3);
        Decimal count = Math.floor(splits[0].length() / 3);
        if(mod > 0)
        {
            parts.add(convertedStr.substring(0, mod));
        }
        for(Integer i = 0; i < count; i++)
        {
            String part = convertedStr.substring(i*3 + mod, (i + 1)*3 + mod);
            parts.add(part);
        }
        String currencyFormat = String.join(parts, ',');
        currencyFormat = resultStr.contains('.') ? currencyFormat + '.00' : currencyFormat;
        return currencyFormat;
    }
    
    private static void setTerritoryBoundaryForPrevExceptionAccount(Set<String> territoryIds)
    {
        List<Account> accts = new List<Account>();
        Map<String, String> oldAccountMap = new Map<String, String>();
        for(ExceptionAccount2TerritoryBoundary__c boundary : [select Exception_Account__c, Exception_Account__r.Territory_Boundary__c, Exception_Account__r.OwnerId from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__r.Territory__c in :territoryIds and Territory_Boundary__r.IsEffective__c = false])
        {
            if(boundary.Exception_Account__r.Territory_Boundary__c != null)
            {
                boundary.Exception_Account__r.Territory_Boundary__c = null;
                accts.add(boundary.Exception_Account__r);
                oldAccountMap.put(boundary.Exception_Account__c, boundary.Exception_Account__r.OwnerId);
            }    
        }
        if(accts.size() > 0)
        {
            update accts;
        }
        
        Map<String, Account> accountMap = new Map<String, Account>([select Id, OwnerId from Account where Id in :oldAccountMap.keySet()]);
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
            TM_TerritoryManagementHelper.syncActivitiesOwnerWithAccountOwner(accountMap, oldAccountMap);
        }
    }
    
    private static void executeTerritoryRealignmentBatch(Map<String, Territory_Boundary__c> territoryBoundaryMap)
    { 
        // Please do not set territoryIds with territoryBoundaryMap.keySet(), as in this way, the
        // teritoryIds will be read-only.
        Set<String> territoryIds = new Set<String>();
        for(String territoryId : territoryBoundaryMap.keySet())
        {
            territoryIds.add(territoryId);
        }
        Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, String> alternateCountryMap = TM_TerritoryManagementHelper.getAlternateCountryMap();
        Map<String, String> alternateStateMap = TM_TerritoryManagementHelper.getAlternateStateMap();
        Set<String> countries = constructCountriesWithApprovedBoundaries(territoryIds, alternateCountryMap);
        List<Assignment_Detail__c> assignments = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__c != null and  Territory_Assignment__r.Status__c = 'Approved' and Territory_Assignment__r.IsEffective__c = true and Country__c in :countries];
        TM_TerritoryManagementHelper.constructAssignmentMap(assignments, territoryIds, alternateCountryMap, alternateStateMap, countryZipCodeAssignmentMap, countryStateAssignmentMap, countryAssignmentMap);
        Set<String> accountQueryFields = new Set<String>();
        Map<String, Territory__c> territoryMap = getTerritoryMap(territoryIds, accountQueryFields);
        List<String> addresses = TM_OrganizationSettings.getShippingOrBillingAddresses();    
        if(addresses != null)
        {
            List<Territory_Change_Box__c> changeBoxes = [select Id from Territory_Change_Box__c where Status__c = 'Approved' and Job_Completion_Date_Time__c != null];
            String namespace = TM_OrganizationSettings.Namespace;
            String queryString = 'select Id, Name, OwnerId, ' + namespace + '__Territory__c, ' + addresses[0] + ', ' + addresses[1] + ', ' + addresses[2] + ', ' + namespace + '__Closed_Revenue_YTD__c, ' + namespace + '__Pipeline_LT_50__c, ' + namespace + '__Pipeline_GL_50__c';
            for(String field : accountQueryFields)
            {
                if(!queryString.contains(field)){
                    queryString += ', ' + field;
                }
            }
            queryString += ' from Account where (' + addresses[0] + ' in :countries or ' + addresses[0] + ' = null ) and ' + namespace + '__Territory_Boundary__c = null and ' + namespace + '__No_Territory_Assignment__c = false';
            if(changeBoxes.size() == 0)
            {
                queryString = 'select Id, Name, OwnerId, ' + namespace + '__Territory__c, ' + addresses[0] + ', ' + addresses[1] + ', ' + addresses[2] + ', ' + namespace + '__Closed_Revenue_YTD__c, ' + namespace + '__Pipeline_LT_50__c, ' + namespace + '__Pipeline_GL_50__c';
                for(String field : accountQueryFields)
                {   
                    if(!queryString.contains(field))
                    {
                        queryString += ', ' + field;
                    }
                }
                queryString += ' from Account where ' + namespace + '__Territory_Boundary__c = null and ' + namespace + '__No_Territory_Assignment__c = false';
            }
            
            TM_TerritoryRealignmentAndOwnerBatch b = new TM_TerritoryRealignmentAndOwnerBatch(queryString, countries, addresses, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap, changeBoxIds, territoryMap);
            Database.executeBatch(b, 20);
        }
    }
    
    public static Set<String> constructCountriesWithApprovedBoundaries(Set<String> territoryIds, Map<String, String> alternateCountryMap)
    {
        Set<String> countries = new Set<String>();
        for(Assignment_Detail__c detail : [select Id, Country__c from Assignment_Detail__c where Territory_Assignment__r.Territory__c in :territoryIds])
        {
            if(String.isNotBlank(detail.Country__c))
            {
                String country = detail.Country__c.toLowerCase();
                countries.add(country);
                if(alternateCountryMap.containsKey(country) && String.isNotBlank(alternateCountryMap.get(country)))
                {
                    countries.add(alternateCountryMap.get(country));
                }
            }
            
        }
        return countries;
    }
    
    private static void updateFieldsForAccount(List<Territory_Boundary__c> territoryBoundaries)
    {
        List<String> territoryBoundaryIds = new List<String>();
        for(Territory_Boundary__c territoryBoundary : territoryBoundaries)
        {
            territoryBoundaryIds.add(territoryBoundary.Id);
        }
        Map<String, ExceptionAccount2TerritoryBoundary__c> exceptionAccountMap = new Map<String, ExceptionAccount2TerritoryBoundary__c>();
        for(ExceptionAccount2TerritoryBoundary__c item : [select Exception_Account__c, Territory_Boundary__c, Territory_Boundary__r.Territory__r.New_Owner__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :territoryBoundaryIds])
        {
            exceptionAccountMap.put(item.Exception_Account__c, item);
        }
        if(exceptionAccountMap.size() > 0)
        {
            Map<String, String> oldAccountOwnerMap = new Map<String, String>();
            Map<String, Account> accountsToUpdateMap = new Map<String, Account> ();
            for(Account exceptionAccount : [select Id, Territory_Boundary__c, Territory__c, New_Territory__c, OwnerId from Account where Id in :exceptionAccountMap.keySet()])
            {
                oldAccountOwnerMap.put(exceptionAccount.Id, exceptionAccount.OwnerId);
                ExceptionAccount2TerritoryBoundary__c accountToBoundary = exceptionAccountMap.get(exceptionAccount.Id);
                exceptionAccount.Territory_Boundary__c = accountToBoundary.Territory_Boundary__c;
                exceptionAccount.Territory__c = exceptionAccount.New_Territory__c;
                exceptionAccount.OwnerId = accountToBoundary.Territory_Boundary__r.Territory__r.New_Owner__c;
                accountsToUpdateMap.put(exceptionAccount.Id, exceptionAccount);
            }
            if(accountsToUpdateMap.values().size() > 0)
            {
                update accountsToUpdateMap.values();
                if(config.Include_Contacts__c)
                {
                    TM_TerritoryManagementHelper.syncContactOwnerWithAccountOwner(accountsToUpdateMap);
                }
        
                if(config.Include_Open_Opps__c)
                {
                    TM_TerritoryManagementHelper.syncOppOwnerWithAccountOwner(accountsToUpdateMap);
                }
               
                if(config.Include_Open_Activities__c)
                {
                    TM_TerritoryManagementHelper.syncActivitiesOwnerWithAccountOwner(accountsToUpdateMap, oldAccountOwnerMap);
                }
            }
        }
    }
    
    private static void updateCurrentBoundaryForTerritory(List<Territory_Boundary__c> territoryBoundaries)
    {
        List<Territory__c> territoriesToUpdate = new List<Territory__c>();
        for(Territory_Boundary__c territoryBoundary : territoryBoundaries)
        {
            if(territoryBoundary.Territory__r.Current_Boundary__c != territoryBoundary.Id)
            {
                territoryBoundary.Territory__r.Current_Boundary__c = territoryBoundary.Id;
                territoriesToUpdate.add(territoryBoundary.Territory__r);
            }
        }          
        if(territoriesToUpdate.size() > 0)
        {
            update territoriesToUpdate;
        }
    }
    
    public static Map<String, Territory__c> getTerritoryMap(Set<String> modifiedTerritoryIds, Set<String> accountQueryFields)
    {
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
        for(Territory__c territory : [select Id, Name, Current_Owner__c, New_Owner__c, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r where Territory_Boundary__r.IsEffective__c = true) from Territory__c where Id in :modifiedTerritoryIds])
        {
            territoryMap.put(territory.Id, territory);
            for(AccountCriteria__c criteria : territory.AccountCriteria__r)
            {
                accountQueryFields.add(criteria.Field__c);
            }
        }
        return territoryMap;
    }

    public static Map<String, Territory__c> getTerritoryMap(Set<String> territoryIds)
    {
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
        for(Territory__c territory : [select Id, Name, Current_Owner__c, New_Owner__c, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r where Territory_Boundary__r.IsEffective__c = true) from Territory__c where Id in :territoryIds])
        {
            territoryMap.put(territory.Id, territory);
        }
        return territoryMap;
    }
}