@isTest
private class TM_CalculateTerritoryFieldsBatchTest 
{
    @isTest
    static void testCalculateTerritoryFieldsBatch()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        Set<String> modifiedTerritoryIds = new Set<String>();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        modifiedTerritoryIds.add(territory.Id);
        Territory__c territory1 = TM_TestDataPopulationUtil.createTerritory(null);
        modifiedTerritoryIds.add(territory1.Id);
        Territory__c territory2 = TM_TestDataPopulationUtil.createTerritory(null);
        modifiedTerritoryIds.add(territory2.Id);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Approved', true);
        Territory_Boundary__c boundary1 = TM_TestDataPopulationUtil.createTerritoryBoundary(territory1.Id, 'Approved', true);
        Territory_Boundary__c boundary2 = TM_TestDataPopulationUtil.createTerritoryBoundary(territory2.Id, 'Approved', true);
        Assignment_Detail__c detail = TM_TestDataPopulationUtil.createAssignment(boundary.Id, 'CN', '', '', '');
        Assignment_Detail__c detail1 = TM_TestDataPopulationUtil.createAssignment(boundary1.Id, 'USA', 'NY', '', '');
        Assignment_Detail__c detail2 = TM_TestDataPopulationUtil.createAssignment(boundary2.Id, 'USA', 'CA', '50000', '69999');
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme 001', 'USA', 'CA', '10005', null);
        Account acct1 = TM_TestDataPopulationUtil.createAccount('Acme 002', 'CN', '', '', null);
        Account acct2 = TM_TestDataPopulationUtil.createAccount('Acme 003', 'USA', 'NY', '', null);
        Account acct3 = TM_TestDataPopulationUtil.createAccount('Acme 004', 'USA', 'CA', '60000', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Opp Acme', acct.Id, Date.today().addDays(3), 'Qualification', 10, 1000);
        Opportunity opp1 = TM_TestDataPopulationUtil.createOpportunity('Opp Acme 001', acct1.Id, Date.today(), 'Closed Won', 100, 20000);
        Opportunity opp2 = TM_TestDataPopulationUtil.createOpportunity('Opp Acme 002', acct2.Id, Date.today().addDays(14), 'Prospecting', 30, 20000);
        Opportunity opp3 = TM_TestDataPopulationUtil.createOpportunity('Opp Acme 003', acct3.Id, Date.today().addDays(15), 'Prospecting', 30, 50000);
        Test.startTest();
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>([select Id, New_Number_Of_Accounts__c, New_Number_Of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Current_Owner__c from Territory__c where RecordTypeId != :recordTypeId and Territory_Type__c != 'Catch All']);
        system.assertEquals(territoryMap.size(), 3);
        Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        countryAssignmentMap.put('cn', new List<Assignment_Detail__c>());
        Assignment_Detail__c assignment = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Id = :detail.Id];
        countryAssignmentMap.get('cn').add(assignment);

        countryStateAssignmentMap.put('usa/ny', new List<Assignment_Detail__c>());
        Assignment_Detail__c assignment1 =  [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Id = :detail1.Id];
        countryStateAssignmentMap.get('usa/ny').add(assignment1);

        countryZipCodeAssignmentMap.put('usa/ca', new List<Assignment_Detail__c>());
        Assignment_Detail__c assignment2 = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Id = :detail2.Id];
        countryZipCodeAssignmentMap.get('usa/ca').add(assignment2);
        String[] addresses = new String[] { 'BillingCountry', 'BillingState', 'BillingPostalCode' };
        Map<String, Decimal> accountCountMap = new Map<String, Decimal>();
        Map<String, Decimal> openOppCountMap = new Map<String, Decimal>();
        Map<String, Decimal> contactCountMap = new Map<String, Decimal>();
        Map<String, Decimal> taskCountMap = new Map<String, Decimal>();
        Map<String, Decimal> eventCountMap = new Map<String, Decimal>(); 
        Map<String, Decimal> pipelineLT50Map = new Map<String, Decimal>();
        Map<String, Decimal> pipelineGT50Map = new Map<String, Decimal>();
        Map<String, Decimal> closedRevenueYTDMap = new Map<String, Decimal>();
        String queryString = 'select Id, Name, OwnerId, ' + addresses[0] + ',' + addresses[1] + ',' + addresses[2] + ', No_Territory_Assignment__c, Territory__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_LT_50__c, Pipeline_GL_50__c from Account where Territory_Boundary__c = null and No_Territory_Assignment__c = false'; 
        TM_CalculateTerritoryFieldsBatch b = new TM_CalculateTerritoryFieldsBatch(queryString, '', modifiedTerritoryIds, addresses, null, territoryMap, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap, accountCountMap, openOppCountMap, contactCountMap, taskCountMap, eventCountMap, pipelineLT50Map, pipelineGT50Map, closedRevenueYTDMap);
        Database.executeBatch(b);
        Test.stopTest();
    }
}