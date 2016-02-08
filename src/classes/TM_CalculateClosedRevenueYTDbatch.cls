global class TM_CalculateClosedRevenueYTDbatch implements Database.Batchable<sObject>
{
    String query = '';
    global TM_CalculateClosedRevenueYTDBatch(String query)
    {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Account> updatingAccounts = new List<Account>();
        List<Account> accts = (List<Account>)scope;
        for(Account acct : accts)
        {
            Decimal amount = 0;
            Integer year = Date.today().year();
            for(Opportunity opp : acct.Opportunities)
            {
                if(opp.CloseDate != null && opp.CloseDate.year() == year && opp.Amount > 0)
                {  
                    amount += opp.Amount;
                }
            }
            acct.Closed_Revenue_YTD__c = amount;
            updatingAccounts.add(acct);
        }
        
        if(updatingAccounts.size() > 0)
        {
            update updatingAccounts;
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
}