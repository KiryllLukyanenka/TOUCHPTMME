global class TM_TerritorySnapshots implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        Map<String, String> snapshotsMap = new Map<String, String>();
        snapshotsMap.put('Number_of_Accounts__c', 'Number_of_Accounts__c');
        snapshotsMap.put('of_Open_Opps__c', 'Number_of_Open_Opps__c');
        snapshotsMap.put('Closed_Revenue_YTD__c', 'Closed_Revenue_YTD__c');
        snapshotsMap.put('Pipeline_Less_Than_Percent50__c', 'Pipeline_Less_Than_Percent50__c');
        snapshotsMap.put('Pipeline_Greater_Than_Percent50__c', 'Pipeline_Greater_Than_Percent50__c');
        snapshotsMap.put('Territory_Name__c', 'Id');
        snapshotsMap.put('Territory_Name_Text__c', 'Name');
        snapshotsMap.put('Territory_Owner__c', 'OwnerId');
        
        List<Territory__c> territories = [select Id, Name, OwnerId, CreatedDate, Owner.Name, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Current_Boundary__c, Current_Owner__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Approver_Type__c, Territory_Description__c, Territory_Type__c from Territory__c limit 50000];
        List<Territory_Snapshot__c> tmSnapshots = new List<Territory_Snapshot__c>();
        for(Territory__c teeritory : territories)
        {
            Territory_Snapshot__c snap = new Territory_Snapshot__c();
            for(String key : snapshotsMap.keySet())
            {
                snap.put(key, teeritory.get(snapshotsMap.get(key)));
            }
            snap.put('Date__c',Datetime.ValueOf(teeritory.get('CreatedDate')).Date());
            snap.put('Territory_Owner_Text__c', teeritory.Owner.Name);
            tmSnapshots.add(snap);
        }
        insert tmSnapshots;
    }
    
    @isTest
   static void testController()
   {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Change_Box__c changeSet = TM_TestDataPopulationUtil.createChangeSet('Definition', Date.today());
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(changeSet.Id);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Definition', false);
        Assignment_Detail__c assignment = TM_TestDataPopulationUtil.createAssignment(boundary.Id);
        Territory_Owner__c owner = TM_TestDataPopulationUtil.createTerritoryOwner(territory.Id, 'Definition', false);
        Test.startTest();
        TM_TerritorySnapshots schedulable = new TM_TerritorySnapshots();
        String exp = '0 0 0 * * ?';
        String jobId = System.schedule('Territory Snapshots', exp, schedulable);
        CronTrigger ct = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        system.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();        
   }
}