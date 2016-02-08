@isTest
private class TM_TerritoryTriggerTest 
{
    @isTest
    static void testReassignAccountsToCatchAll()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'USA', 'CA', '10005', territory.Id);
        Territory__c territory2 = TM_TestDataPopulationUtil.createTerritory(null);
        Territory_Boundary__c territoryBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory2.Id, 'Approved', true);
        Assignment_Detail__c assignment = TM_TestDataPopulationUtil.createAssignment(territoryBoundary.Id);
        delete territory;
        Acct  = [select Id, Territory__c from Account where Id = :acct.Id];
        system.assertEquals(acct.Territory__c, catchAllTerritory.Id);
    }
}