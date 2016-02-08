global class TM_CatchAllFieldsCalculationBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global String query = '';
    global String territoryId;
    Decimal numberOfAccounts = 0;
    Decimal numberOfOpenOpps = 0;
    Decimal closedRevenueYTD = 0;
    Decimal pipelineLT50 = 0;
    Decimal pipelineGT50 = 0;
    
    global TM_CatchAllFieldsCalculationBatch(String query, String territoryId){
        this.query = query;
        this.territoryId = territoryId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Account> accts = (List<Account>)scope;
        numberOfAccounts += accts.size();
        Set<Id> acctIds = new Set<Id>();
        for(Account acct : accts){
            pipelineLT50 += acct.Pipeline_LT_50__c != null ? acct.Pipeline_LT_50__c : 0;
            pipelineGT50 += acct.Pipeline_GL_50__c != null ? acct.Pipeline_GL_50__c : 0;
            closedRevenueYTD += acct.Closed_Revenue_YTD__c != null ? acct.Closed_Revenue_YTD__c : 0;
            acctIds.add(acct.Id);
        }    
        numberOfOpenOpps += getOpenOpportunities(acctIds);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        Territory__c territory = [select Id, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, 
                                 Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c 
                                 where Territory_Type__c = 'Catch All' limit 1];
        if(territory != null){
            territory.Number_of_Accounts__c = numberOfAccounts;
            territory.Number_of_Open_Opps__c = numberOfOpenOpps;
            territory.Closed_Revenue_YTD__c = closedRevenueYTD;
            territory.Pipeline_Less_Than_Percent50__c = pipelineLT50;
            territory.Pipeline_Greater_Than_Percent50__c  = pipelineGT50;
            update territory;
        }                   
    }
    
    private static Integer getOpenOpportunities(Set<Id> acctIds){
        return [select count() from Opportunity where AccountId in :acctIds and IsClosed = false];
    }
}