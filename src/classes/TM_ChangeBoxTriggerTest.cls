@isTest
private class TM_ChangeBoxTriggerTest {
    @isTest
    static void setChangeBoxDefaultApprover()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        Territory_Change_Box__c changeSet = TM_TestDataPopulationUtil.createChangeSet('Definition', Date.today().addDays(7));
        Territory_Change_Box__c changeSetResult = [select Id, Approver__c from Territory_Change_Box__c where Id = :changeSet.Id];
        system.assertEquals(config.Approver__c, changeSetResult.Approver__c);
    }
}