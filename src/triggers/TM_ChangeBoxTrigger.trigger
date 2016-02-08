/*
 ** Set Change Set owner to Config Approver.
 ** Written by Chrinstine.
 */
trigger TM_ChangeBoxTrigger on Territory_Change_Box__c (before insert)
{
    TM_ChangeBoxTriggerHandler.setChangeBoxDefaultApprover(Trigger.New);
}