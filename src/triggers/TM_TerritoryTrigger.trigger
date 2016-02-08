/*
 ** This is used to reassign the accounts within the deleted territories.
 ** Written by Joyce. 2013/6/19.
 */
trigger TM_TerritoryTrigger on Territory__c (after delete, before delete) 
{
    if(Trigger.isAfter){
        TM_TerritoryTriggerHandler.reassignAccountsToCatchAll(Trigger.Old);
    }else{
        TM_TerritoryTriggerHandler.deleteRelatedAssignmentDetails(Trigger.Old);
    }
}