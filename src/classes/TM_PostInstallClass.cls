global class TM_PostInstallClass implements InstallHandler
{
    global void onInstall(InstallContext context)
    {
        //Populates the Closed_Revenue_YTD__c field of accounts.
        String namespace = TM_OrganizationSettings.Namespace;
        String queryString = 'select Id, ' + namespace + '__Closed_Revenue_YTD__c, ' + namespace + '__No_Territory_Assignment__c, (select Id, CloseDate, Amount from Opportunities where IsClosed = true and IsWon = true) from Account where ' + namespace + '__Closed_Revenue_YTD__c = null';
        TM_CalculateClosedRevenueYTDbatch b = new TM_CalculateClosedRevenueYTDbatch(queryString); 
        Database.executeBatch(b);

        //run the territory realignment scheduler.
        List<CronTrigger> scheduledJobs = [select Id from CronTrigger where CronJobDetail.Name = 'Territory Realignment' limit 1];
        if(scheduledJobs.size() > 0){
            System.abortJob(scheduledJobs[0].Id);
        }
        String cronExp = '0 0 0 * * ?';
        system.schedule('Territory Realignment', cronExp, new TM_TerritoryRealignmentScheduler());
    }
}