@isTest
private class TM_TerritoryManagementHelperTest 
{
    @isTest 
    static void testTerritoryManagementHelper() 
    {
        TM_TestDataPopulationUtil.abortJobs();
        Account acct = new Account(Name = 'Acme', Site = 'www.test.salesforce.com', AnnualRevenue = 80000, BillingCountry = 'CN');
        insert acct;
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        AccountCriteria__c acctCriteria = TM_TestDataPopulationUtil.createAccountCriteria(territory.Id, 'Site', 'Account Site', 'not equal to', null);
        Territory__c matchedTerritory = [select Id, OwnerId, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r) from Territory__c where Id = :territory.Id];
        Boolean isValid = TM_TerritoryManagementHelper.isAccountQualified(matchedTerritory, acct);
        system.assertEquals(isValid, true);
    }   

    @isTest 
    static void testTerritoryManagementHelper2() 
    {
        TM_TestDataPopulationUtil.abortJobs();
        Account acct = new Account(Name = 'Acme', AnnualRevenue = 80000, BillingCountry = 'CN');
        insert acct;
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        AccountCriteria__c acctCriteria = TM_TestDataPopulationUtil.createAccountCriteria(territory.Id, 'AnnualRevenue', 'Annual Revenue', 'less or equal', '80000');
        Territory__c matchedTerritory = [select Id, OwnerId, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r) from Territory__c where Id = :territory.Id];
        Boolean isValid = TM_TerritoryManagementHelper.isAccountQualified(matchedTerritory, acct);
        system.assertEquals(isValid, true);
    }

    @isTest
    static void testTerritoryManagementHelper3()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Account acct = new Account(Name = 'Acme', AnnualRevenue = 80000, BillingCountry = 'CN');
        insert acct;
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        String criteriaDate = '1/1/2013';
        AccountCriteria__c acctCriteria = TM_TestDataPopulationUtil.createAccountCriteria(territory.Id, 'CreatedDate', 'Created Date', 'less or equal', criteriaDate);
        Territory__c matchedTerritory = [select Id, OwnerId, (select Id, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__r) from Territory__c where Id = :territory.Id];
        Boolean isValid = TM_TerritoryManagementHelper.isAccountQualified(matchedTerritory, acct);
        system.assertEquals(isValid, false);
    }

    @isTest
    static void testTerritoryManagementHelper4()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'definition', false);
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'CN'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA', Postal_Start__c = '10000', Postal_End__c = '50000'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', Postal_Start__c = '50001', Postal_End__c = '60000'));
        insert assignments;
        Set<String> territoryBoundaryIds = new Set<String> { boundary.Id };
        Map<String, String> alternateCountryMap = new Map<String, String>();
        Map<String, String> alternateStateMap = new Map<String, String>();
        Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        List<Assignment_Detail__c> details = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c];
        Set<String> territoryIds = new Set<String>();
        TM_TerritoryManagementHelper.constructAssignmentMap(details, territoryIds, alternateCountryMap, alternateStateMap, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap);
        system.assertEquals(countryAssignmentMap.containsKey('cn'), false);
        TM_TerritoryManagementHelper.getCatchAllRecordTypeId();
        Territory__c standardTerritory = TM_TestDataPopulationUtil.createTerritory(null);
        ApexPages.StandardController standardController = new ApexPages.StandardController(standardTerritory);
        TM_NewTerritoryRedirectController controller = new TM_NewTerritoryRedirectController(standardController);
        controller.redirect();
    }
}