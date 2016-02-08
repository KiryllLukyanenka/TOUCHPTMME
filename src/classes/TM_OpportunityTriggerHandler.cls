public class TM_OpportunityTriggerHandler
{
    public static void syncOpportunityOwner(List<Opportunity> opps)
    {
        Territory_Config__c config = TM_OrganizationSettings.getTerritoryConfig();
        for(Opportunity opp : opps)
        {
            if(!opp.No_Territory_Assignment__c && config.Include_Open_Opps__c && opp.AccountId != null && opp.OwnerId != opp.AccountOwnerId__c && !opp.IsClosed)
            {
                opp.OwnerId = opp.AccountOwnerId__c;
            }
        }
    }
    
    public static void calculateAccountFieldsForInsertOrDelete(Map<Id, Opportunity> oppMap)
    {
        Set<String> acctIds = new Set<String>();
        List<Account> updatingAccounts = new List<Account>();
        for(Opportunity opp : oppMap.values())
        {
            if(String.isNotBlank(opp.AccountId) && opp.ExpectedRevenue > 0 && opp.IsClosed && opp.IsWon)
            {
                acctIds.add(opp.AccountId);
            }
        }
        calculateAccountFields(acctIds, updatingAccounts);   
    }
    
    public static void calculateAccountFieldForUpdate(Map<Id, Opportunity> oppMap, Map<Id, Opportunity> oldOppMap)
    {
        Set<String> acctIds = new Set<String>();
        List<Account> updatingAccounts = new List<Account>();
        for(Opportunity opp : oppMap.values())
        {
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            if(String.isNotBlank(opp.AccountId) && (opp.ExpectedRevenue != oldOpp.ExpectedRevenue || opp.IsClosed != oldOpp.IsClosed || opp.IsWon != oldOpp.IsWon || opp.CloseDate != oldOpp.CloseDate))
            {
                acctIds.add(opp.AccountId);
            }
        }
        calculateAccountFields(acctIds, updatingAccounts);
    }
    
    private static void calculateAccountFields(Set<String> acctIds, List<Account> updatingAccounts)
    {
        Map<Id, List<Opportunity>> acctOppsMap = new Map<Id, List<Opportunity>>();
        for(Opportunity opp : [select Id, ExpectedRevenue, CloseDate, AccountId from Opportunity where IsClosed = true and IsWon = true and AccountId in :acctIds limit 10000])
        {
            if(acctOppsMap.containsKey(opp.AccountId))
            {
                acctOppsMap.get(opp.AccountId).add(opp);
            }
            else
            {
                acctOppsMap.put(opp.AccountId, new List<Opportunity>{opp});
            }
        }
        for(Id acctId : acctOppsMap.keyset())
        {            
            List<Opportunity> thisOpps = acctOppsMap.get(acctId);
            if(thisOpps != null && thisOpps.size() > 0)
            {
                Account acct = new Account(Id = acctId);
                Decimal revenue = 0;
                Integer year = Date.today().year();
                for(Opportunity opp : thisOpps)
                {
                    if(opp.CloseDate.year() == year && opp.ExpectedRevenue > 0)
                    {
                        revenue += opp.ExpectedRevenue;
                    }   
                }
                acct.Closed_Revenue_YTD__c = revenue;
                updatingAccounts.add(acct);
            }
        }/*
        for(Account acct : [select Id, Closed_Revenue_YTD__c, (select Id, ExpectedRevenue, CloseDate from Opportunities where IsClosed = true and IsWon = true) from Account where Id in :acctIds])
        {
            Decimal revenue = 0;
            Integer year = Date.today().year();
            for(Opportunity opp : acct.Opportunities)
            {
                if(opp.CloseDate.year() == year && opp.ExpectedRevenue > 0)
                {
                    revenue += opp.ExpectedRevenue;
                }   
            }
            acct.Closed_Revenue_YTD__c = revenue;
            updatingAccounts.add(acct);
        }*/
        if(updatingAccounts.size() > 0)
        {
            update updatingAccounts;
        }
    }
}