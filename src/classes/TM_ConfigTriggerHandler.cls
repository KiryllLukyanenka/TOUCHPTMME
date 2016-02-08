public class TM_ConfigTriggerHandler
{
    public static void scheduleSnapShotForInsert(List<Territory_Config__c> newConfigs)
    {    
        List<Territory_Config__c> configs = new List<Territory_Config__c>();
        for(Territory_Config__c config : newConfigs)
        {
            if(configs.isEmpty())
            {
                configs.add(config);
            } 
        }
        scheduleSnapShot(configs);
    }
    
    public static void resheduleSnapShotForUpdate(List<Territory_Config__c> newConfigs, Map<Id, Territory_Config__c> oldConfigMap)
    {
        List<Territory_Config__c> configs = new List<Territory_Config__c>();
        Set<String> scheduleJobIds = new Set<String>();
        for(Territory_Config__c config : newConfigs)
        {
            Territory_Config__c oldConfig = oldConfigMap.get(config.Id);
            if(config.Territory_Snapshots__c != oldConfig.Territory_Snapshots__c)
            {
                if(scheduleJobIds.isEmpty())
                {
                    scheduleJobIds.add(oldConfig.Schedule_Job_Id__c);
                }
                if(configs.isEmpty())
                {
                    configs.add(config);
                }
            }
        }
        abortJobs(scheduleJobIds);
        scheduleSnapShot(configs);
    }
    
    public static void aboutJobsForDelete(List<Territory_Config__c> configs)
    {
        Set<String> scheduleJobIds = new Set<String>();
        for(Territory_Config__c config : configs)
        {
            if(scheduleJobIds.isEmpty())
            {
                scheduleJobIds.add(config.Schedule_Job_Id__c);
            }
        }
        abortJobs(scheduleJobIds);
    }
    
    private static void abortJobs(Set<String> scheduleJobIds)
    {
        List<CronTrigger> jobs = [select Id from CronTrigger where Id in :scheduleJobIds];
        if(jobs.size() > 0)
        {
            system.abortJob(jobs[0].Id);
        }
    }
    
    private static void scheduleSnapShot(List<Territory_Config__c> configs)
    {
        if(configs.size() > 0)
        {
            TM_TerritorySnapshots scheduler = new TM_TerritorySnapshots();
            Territory_Config__c config = configs[0];
            String sch = '';
            if(config.Territory_Snapshots__c == 'Weekly')
            {
                sch = '0 0 0 ? * L';
            }
            else if(config.Territory_Snapshots__c == 'Monthly') 
            {
                sch = '0 0 0 L * ?';     
            }
            else if(config.Territory_Snapshots__c == 'Quarterly (Calendar)')
            {
                Integer month = Math.mod(Date.today().month(), 3) == 0 ? Date.today().month() : Date.today().month() + (3 - Math.mod(Date.today().month(), 3));
                sch = '0 0 0 L ' + month + ' ?';
            }
            else if(config.Territory_Snapshots__c == 'Yearly (Calendar)')
            {
                sch = '0 0 0 1 1 ? *';
            }
            else
            {}
            if(String.isNotBlank(config.Territory_Snapshots__c))
            {
                config.Schedule_Job_Id__c = system.schedule('Territory Snapshots', sch, scheduler);
            }
        }
    }       
}