@isTest
private class TM_CatchAllFieldsCalculationBatchTest{
    @isTest
    static void testCatchAllFieldsCalculationBatch(){
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme 001', 'USA', 'CA', '10005', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Opp Acme', acct.Id, Date.today().addDays(3), 'Qualification', 10, 1000);
        Test.startTest();
        String queryStr = 'select Id, Name, Pipeline_LT_50__c, Pipeline_GL_50__c , Closed_Revenue_YTD__c  from Account where Territory__c = :territoryId';
        TM_CatchAllFieldsCalculationBatch b = new TM_CatchAllFieldsCalculationBatch(queryStr, catchAllTerritory.Id);
        Database.executeBatch(b, 1);
        Test.stopTest();
        Territory__c territory = [select Id, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, 
                                 Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c 
                                 where Territory_Type__c = 'Catch All' limit 1];
        system.assertEquals(territory.Number_of_Accounts__c, 1);
        system.assertEquals(territory.Number_of_Open_Opps__c, 1);
    }
}