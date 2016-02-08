@isTest
private class TM_OpportunityTriggerTest {
    @isTest
    static void testSetOpportunityOwner()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'US', 'CA', '', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Acme', acct.Id, Date.today().addDays(7), 'Qualification', 10, 10000);
        Account acctResult = [select Id, OwnerId from Account where Id = :acct.Id];
        Opportunity oppResult = [select Id, OwnerId from Opportunity where Id = :opp.Id];
        system.assertEquals(acctResult.OwnerId, oppResult.OwnerId);
    }
    
    @isTest
    static void testSetAccClosedReveneYTD()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'CN', '', '', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Acme 001', acct.Id, Date.today(),'Closed Won', 100, 10000);
        Account acctResult = [select Id, Closed_Revenue_YTD__c from Account where Id = :acct.Id];
        system.assertEquals(acctResult.Closed_Revenue_YTD__c, 10000);
        Opportunity opp2 = TM_TestDataPopulationUtil.createOpportunity('Acme 002', acct.Id, Date.today(), 'Qualification' , 10, 20000);
        opp2.StageName = 'Closed Won';
        opp2.Probability = 100;
        update opp2;
        Account acctResult2 = [select Id, Closed_Revenue_YTD__c from Account where Id = :acct.Id];
        system.assertEquals(acctResult2.Closed_Revenue_YTD__c, 30000);
        delete opp2;
        Account acctResult3 = [select Id, Closed_Revenue_YTD__c from Account where Id = :acct.Id];
        system.assertEquals(acctResult3.Closed_Revenue_YTD__c, 10000);
    }
}