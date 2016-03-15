/*
 ** Because the relationship between territory and territory boundary is master-detail. So after a territory is deleted, we can't 
 ** find assignments any more. So we need to reassign all accounts.
 */
public class TM_TerritoryTriggerHandler
{
    private static String catchAllRecordTypeId = TM_OrganizationSettings.getCatchAllRecordTypeId();
    
    public static void deleteRelatedAssignmentDetails(List<Territory__c> territories){
        delete [select Id from Assignment_Detail__c where Territory_Assignment__r.Territory__c in :territories];
    }
    
    public static void reassignAccountsToCatchAll(List<Territory__c> territories)
    {
        Set<String> catchAllTerritoryIds = new Set<String>();
        for(Territory__c territory : territories)
        {
            if(territory.RecordTypeId == catchAllRecordTypeId && territory.Territory_Type__c == 'Catch All')
            {
                catchAllTerritoryIds.add(territory.Id);
            } 
        }
        
        if(catchAllTerritoryIds.size() == 0)
        {
            Set<String> accountQueryFields = new Set<String>();
            Set<String> territoryIds = new Set<String>();
            Map<String, Territory__c> territoryMap = getTerritoryMap(accountQueryFields, territoryIds);
            Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
            Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
            Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
            Map<String, String> alternateCountryMap = TM_TerritoryManagementHelper.getAlternateCountryMap();
            Map<String, String> alternateStateMap = TM_TerritoryManagementHelper.getAlternateStateMap();
            Set<String> countries = TM_SubmitChangeBoxHelper.constructCountriesWithApprovedBoundaries(territoryIds, alternateCountryMap);
            List<Assignment_Detail__c> assignments = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__c != null and  Territory_Assignment__r.Status__c = 'Approved' and Territory_Assignment__r.IsEffective__c = true and Country__c in :countries];
            TM_TerritoryManagementHelper.constructAssignmentMap(assignments, territoryIds, alternateCountryMap, alternateStateMap, countryZipCodeAssignmentMap, countryStateAssignmentMap, countryAssignmentMap);
            List<String> addresses = TM_OrganizationSettings.getShippingOrBillingAddresses();
            if(addresses != null)
            {
                String namespace = TM_OrganizationSettings.Namespace;
                String queryString = 'select Id, Name, OwnerId, ' + namespace + '__Territory__c, ' + addresses[0] + ', ' + addresses[1] + ', ' + addresses[2] + ', ' + namespace + '__Closed_Revenue_YTD__c, ' + namespace + '__Pipeline_LT_50__c, ' + namespace + '__Pipeline_GL_50__c';
                for(String field : accountQueryFields)
                {
                    queryString += ', ' + field;
                }
                queryString += ' from Account where ' + namespace + '__Territory_Boundary__c = null and ' + namespace + '__No_Territory_Assignment__c = false';
                TM_ReassignAccountsBatch b = new TM_ReassignAccountsBatch(queryString, addresses, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap, territoryMap);
                Database.executeBatch(b, 20);
            } 
        }
    }

    public static Map<String, Territory__c> getTerritoryMap(Set<String> accountQueryFields, Set<String> territoryIds)
    {
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
        for(Territory__c territory : [select Id, Name, Current_Owner__c, New_Owner__c, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r where Territory_Boundary__r.IsEffective__c = true) from Territory__c where Territory_Type__c != 'Catch All' and RecordTypeId != :catchAllRecordTypeId])
        {
            territoryMap.put(territory.Id, territory);
            territoryIds.add(territory.Id);
            for(AccountCriteria__c criteria : territory.AccountCriteria__r)
            {
                accountQueryFields.add(criteria.Field__c);
            }
        }
        return territoryMap;
    }

    public static void getTerritoryColor(List<Territory__c> newRecords) {
        for (Territory__c ter :newRecords) {
            ter.Color__c = addColor();
        }
    }

    public static String addColor() {
        List<String> characters = new List<String>{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        String returnColor = '';
        for (Integer i = 0; i < 6; i++) {
            returnColor += characters.get(Math.mod(Integer.valueOf(Math.random() * 50000), 16));
        }
        return returnColor;
    }

    public static void calculateAccountsNumber(List<Territory__c> newRecords) {
        Map<Id, Territory__c> updatedTerritories = new Map<Id, Territory__c>([
            SELECT Id, 
            (
                SELECT Id, TerrMgmt__Number_of_Open_Opps__c
                FROM Accounts__r
            ) 
            FROM Territory__c 
            WHERE Id IN: newRecords
            LIMIT 50000
        ]);
        for (Territory__c territory : newRecords) {
            if (updatedTerritories.containsKey(territory.Id)) {
                territory.TerrMgmt__Number_of_Accounts__c = updatedTerritories.get(territory.Id).Accounts__r.size(); 
                Decimal numberOfOpenOps = 0;
                for (Account acc : updatedTerritories.get(territory.Id).Accounts__r) {
                    numberOfOpenOps += acc.TerrMgmt__Number_of_Open_Opps__c;
                }
                territory.TerrMgmt__Number_of_Open_Opps__c = numberOfOpenOps;
            }

           
        }


    }
}