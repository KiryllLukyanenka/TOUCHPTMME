@isTest
private class TM_TerritoryRealignmentSchedulerTest 
{
    @isTest
    static void testTerritoryRealignmentScheduler()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory_Change_Box__c changeSet = TM_TestDataPopulationUtil.createChangeSet('Approved', Date.today());
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(changeSet.Id);
        Territory__c territory1 = TM_TestDataPopulationUtil.createTerritory(changeSet.Id);
        Territory__c territory2 = TM_TestDataPopulationUtil.createTerritory(changeSet.Id);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Approved', true);
        Test.startTest();
        String exp = '0 0 0 * * ?';
        String jobId = System.schedule('Territory Realignment', exp, new TM_TerritoryRealignmentScheduler());
        Test.stopTest();
        CronTrigger ct = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        system.assertEquals(exp, ct.CronExpression);
        system.assertEquals(0, ct.TimesTriggered);
    }
}