/*
 ** Re-schedule the apex job once the 'Territory Snapshot' option is updated.
 ** Updated by Joyce, 2013/6/9.
 */
trigger TM_ConfigTrigger on Territory_Config__c (before insert, before update, before delete)
{
    if(Trigger.IsInsert)
    {
        TM_ConfigTriggerHandler.scheduleSnapShotForInsert(Trigger.New);
    }
    else if(Trigger.isUpdate)
    {
        TM_ConfigTriggerHandler.resheduleSnapShotForUpdate(Trigger.New, Trigger.OldMap);
    }
    else
    {
        TM_ConfigTriggerHandler.aboutJobsForDelete(Trigger.Old);
    }
}