@isTest
private class TM_PostInstallClassTest
{
    @isTest
    static void testTM_PostInstallClassTest()
    {
        Account acct = TM_TestDataPopulationUtil.createAccount('Account Acme 01', 'CN', '', '', null);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Opp Acme 01', acct.Id, Date.today(), 'Closed Won', 100, 10000);
        TM_PostInstallClass postInstall = new TM_PostInstallClass();
        Test.testInstall(postInstall, null);
        acct = [select Id, Closed_Revenue_YTD__c from Account where Id = :acct.Id];
        system.assertEquals(acct.Closed_Revenue_YTD__c, 10000);
    }
}