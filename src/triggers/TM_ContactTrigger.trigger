/*
 ** Set Contact Owner to Account Owner if Config.Include_Contacts__c is checked.
 ** Written by Christine.
 ** Updated by Joyce, 2013/8/1.
 */
trigger TM_ContactTrigger on Contact (before insert) 
{
    if(Trigger.isInsert){
        TM_ContactTriggerHandler.setContactOwner(Trigger.New);
    }  
}