@isTest
private class TM_CalculateClosedRevenueYTDBatchTest
{
    @isTest
    static void testCalculateClosedRevenueYTDBatch()
    {
        Account acct = TM_TestDataPopulationUtil.createAccount('Account Acme 01', 'CN', '', '', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Opp Acme 01', acct.Id, Date.today(), 'Closed Won', 100, 10000);
        String namespace = TM_OrganizationSettings.Namespace;
        String queryString = 'select Id,' + namespace + '__Closed_Revenue_YTD__c, (select Id, CloseDate, Amount from Opportunities where IsClosed = true and IsWon = true) from Account';
        TM_CalculateClosedRevenueYTDbatch b = new TM_CalculateClosedRevenueYTDbatch(queryString);
        Database.executeBatch(b);
        acct = [select Id, Closed_Revenue_YTD__c from Account where Id = :acct.Id];
        system.assertEquals(acct.Closed_Revenue_YTD__c, 10000);
    }
}