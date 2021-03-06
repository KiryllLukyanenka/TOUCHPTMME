trigger TM_AccountTriggger on Account (before update, after insert, after update, after delete) 
{
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		if(TM_AccountTriggerHandler.triggerExecuted == 0) {
			TM_AccountTriggerHandler.triggerExecuted = 1;
			TM_AccountTriggerHandler.setSalesTerritoryForUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
	else if(Trigger.isAfter && Trigger.isUpdate)
	{
		TM_AccountTriggerHandler.fireUpdateTrigger(false, Trigger.newMap, Trigger.oldMap);
		TM_AccountTriggerHandler.unsyncAccountRelatedObjectOwner(Trigger.newMap, Trigger.oldMap);
		TM_AccountTriggerHandler.calculateTerritoryFieldsForUpdate(Trigger.newMap, Trigger.oldMap);
		TM_AccountTriggerHandler.shareAccountWithTerritoryMembersForUpdate(Trigger.new, Trigger.oldMap);

		system.debug('>>>>>>>>> In after update, TM_AccountTriggerHandler.triggerExecuted = ' + TM_AccountTriggerHandler.triggerExecuted);
		if(! System.isFuture() && ! System.isBatch() && TM_AccountTriggerHandler.triggerExecuted == 1) {
			TM_AccountTriggerHandler.triggerExecuted = 0;
			TM_AccountTriggerHandler.callBatch(Trigger.newMap.keySet());
			system.debug('>>>>>>>>> triger in callBatch');
		}
	}
	else if(Trigger.isAfter && Trigger.isInsert)
	{
		TM_AccountTriggerHandler.fireUpdateTrigger(true, Trigger.newMap, null);
		TM_AccountTriggerHandler.calculateTerritoryFieldsForInsert(Trigger.newMap);
		TM_AccountTriggerHandler.callBatch(Trigger.newMap.keySet());
		//TM_AccountTriggerHandler.shareAccountWithTerritoryMembersForInsert(Trigger.new);
	}
	else if(Trigger.isAfter && Trigger.isDelete)
	{
		Tm_AccountTriggerHandler.calculateTerritoryFieldsForDelete(Trigger.oldMap);
	}

}