/*
 ** 1.Set Contact Owner to Account Owner if Config.Include_Contacts__c is checked.
 ** 2.Calculate Acct.ClosedRevenueYTD when opp.ExpectedRevenue changes. 
 ** Written by Joyce.
 */
trigger TM_OpportunityTrigger on Opportunity (before insert, after insert, after update, after delete) 
{
    if(Trigger.isBefore)
    {
        TM_OpportunityTriggerHandler.syncOpportunityOwner(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isInsert)
    {
        TM_OpportunityTriggerHandler.calculateAccountFieldsForInsertOrDelete(Trigger.newMap);
    }
    else if(Trigger.isAfter && Trigger.isDelete)
    {
        TM_OpportunityTriggerHandler.calculateAccountFieldsForInsertOrDelete(Trigger.oldMap);
    }
    else if(Trigger.isAfter && Trigger.isUpdate)
    {
        TM_OpportunityTriggerHandler.calculateAccountFieldForUpdate(Trigger.newMap, Trigger.oldMap);
    }
    else
    {
    }
}