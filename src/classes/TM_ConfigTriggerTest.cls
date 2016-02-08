@isTest
private class TM_ConfigTriggerTest {
    @isTest
    static void rescheduleSnapshot()
    {
        for(CronTrigger job : [select Id from CronTrigger])
        {
            system.abortJob(job.Id);
        }
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        Territory_Config__c configResult = [select Id, Schedule_Job_Id__c from Territory_Config__c where Id = :config.Id];
        List<CronTrigger> jobs = [select Id from CronTrigger where Id = :configResult.Schedule_Job_Id__c];
        system.assertEquals(jobs.size(), 1);
        config.Territory_Snapshots__c = 'Monthly';
        update config;
        config.Territory_Snapshots__c = 'Quarterly (Calendar)';
        update config;
        config.Territory_Snapshots__c = 'Yearly (Calendar)';
        update config;
        delete config;
        List<CronTrigger> jobResults = [select Id from CronTrigger];
        system.assertEquals(jobResults.size(), 0);

    }
}