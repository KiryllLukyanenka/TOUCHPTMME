/*
 ** This is used to reassign the accounts within the deleted territories.
 ** Written by Joyce. 2013/6/19.
 */
trigger TM_TerritoryTrigger on Territory__c (after delete, before delete, before insert, before update) 
{	
	if(Trigger.isBefore && Trigger.isInsert){
        TM_TerritoryTriggerHandler.getTerritoryColor(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate){
        TM_TerritoryTriggerHandler.calculateAccountsNumber(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isDelete){
        TM_TerritoryTriggerHandler.reassignAccountsToCatchAll(Trigger.Old);
    }else{
        TM_TerritoryTriggerHandler.deleteRelatedAssignmentDetails(Trigger.Old);
    }
}