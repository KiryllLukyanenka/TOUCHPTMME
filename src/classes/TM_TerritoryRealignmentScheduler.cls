global class TM_TerritoryRealignmentScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Set<String> effectiveTerritoryIds = new Set<String>();
        Set<String> changeBoxIds = new Set<String>();
        for(Territory__c territory : [select Id, Territory_Change_Box__c from Territory__c where Territory_Change_Box__r.Status__c = 'Approved' and Effective_Date__c = :Date.today()])
        {
            changeBoxIds.add(territory.Territory_Change_Box__c);
            effectiveTerritoryIds.add(territory.Id);
        }
        TM_SubmitChangeBoxHelper.changeBoxIds = changeBoxIds;
        TM_SubmitChangeBoxHelper.executeTerritoryOwnerBatch(effectiveTerritoryIds);
        TM_SubmitChangeBoxHelper.executeTerritoryBoundaryBatch(effectiveTerritoryIds);
    }
}