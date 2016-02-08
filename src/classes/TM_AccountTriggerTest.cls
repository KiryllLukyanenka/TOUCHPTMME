@isTest
private class TM_AccountTriggerTest 
{
    @isTest
    static void testUnsyncRelatedObjectOwner()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'US', 'CA', '', null);
        Contact contact = TM_TestDataPopulationUtil.createContact('Acme', acct.Id);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Acme', acct.Id, Date.today().addDays(7), 'Qualification', 10, 10000);
        Event event = TM_TestDataPopulationUtil.createEvent(acct.Id);
        Task task = TM_TestDataPopulationUtil.createTask(acct.Id);
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        User user = new User(ProfileId = profile.Id, Username = 'TestUser@touchpointcrm.com.test', Email = 'aaron@touchpointcrm.com.test', IsActive = true, EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimezoneSidKey = 'America/Los_Angeles', Alias = 'cspu', LastName = 'acme');
        insert user;
        acct.OwnerId = user.Id;
        update acct;

        Contact contactResult = [select Id, OwnerId from Contact where Id = :contact.Id];
        Opportunity oppResult = [select Id, OwnerId from Opportunity where Id = :opp.Id];
        Event eventResult = [select Id, OwnerId from Event where Id = :event.Id];
        Task taskResult = [select Id, OwnerId from Task where Id = :task.Id];
        Account acctResult = [select Id, OwnerId from Account where Id = :acct.Id];
        system.assertEquals(acctResult.OwnerId, contactResult.OwnerId);
        system.assertEquals(acctResult.OwnerId, oppResult.OwnerId);
    }

    @isTest
    static void testUnsyncRelatedObjectOwner2()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = new Territory_Config__c(Catch_All_Territory_Name__c = 'Catch All', Catch_All_Territory_Owner__c = UserInfo.getUserId(), Include_Contacts__c = false, Include_Open_Opps__c = false, Include_Open_Activities__c = false, Use_Approval_Process__c = 'Yes', Approver__c = UserInfo.getUserId(), Billing_Shipping_Address__c = 'Billing', Territory_Snapshots__c = 'Weekly');
        insert config;
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'US', 'CA', '', null);
        Contact contact = TM_TestDataPopulationUtil.createContact('Acme', acct.Id);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Acme', acct.Id, Date.today().addDays(7), 'Qualification', 10, 10000);
        Event event = TM_TestDataPopulationUtil.createEvent(acct.Id);
        Task task = TM_TestDataPopulationUtil.createTask(acct.Id);
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        User user = new User(ProfileId = profile.Id, Username = 'TestUser@touchpointcrm.com.test', Email = 'aaron@touchpointcrm.com.test', IsActive = true, EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimezoneSidKey = 'America/Los_Angeles', Alias = 'cspu', LastName = 'acme');
        insert user;
        acct.OwnerId = user.Id;
        update acct;

        Contact contactResult = [select Id, OwnerId from Contact where Id = :contact.Id];
        Opportunity oppResult = [select Id, OwnerId from Opportunity where Id = :opp.Id];
        Event eventResult = [select Id, OwnerId from Event where Id = :event.Id];
        Task taskResult = [select Id, OwnerId from Task where Id = :task.Id];
        Account acctResult = [select Id, OwnerId from Account where Id = :acct.Id];
        //system.assertNotEquals(acctResult.OwnerId, contactResult.OwnerId);
        system.assertNotEquals(acctResult.OwnerId, oppResult.OwnerId);
    }
    
    @isTest
    static void testCalculateTerritoryFields()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme 001', 'US', 'CA', null, territory.Id);
        Territory__c territoryResult = [select Id, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Id = :territory.Id];
        system.assertEquals(territoryResult.Number_of_Accounts__c, 1);
        system.assertEquals(territoryResult.Number_of_Open_Opps__c, 0);
        Date closeDate = Date.today().addDays(3);
        Opportunity opp = TM_TestDataPopulationUtil.createOpportunity('Acme 001', acct.Id, closeDate, 'Qualification', 0.1, 10000);
        Territory__c territory2 = TM_TestDataPopulationUtil.createTerritory(null);
        acct.Territory__c = territory2.Id;
        update acct;
        Territory__c territoryResult2 = [select Id, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Id = :territory2.Id];
        system.assertEquals(territoryResult2.Number_of_Accounts__c, 1);
        system.assertEquals(territoryResult2.Number_of_Open_Opps__c, 1);
        delete acct;
        Territory__c territoryResult3 = [select Id, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Id = :territory2.Id];
        system.assertEquals(territoryResult3.Number_of_Accounts__c, 0);
        system.assertEquals(territoryResult3.Number_of_Open_Opps__c, 0);
    }

    @isTest
    static void testSetSalesTerritory()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Approved', true);
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'CN'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA', Postal_Start__c = '10000', Postal_End__c = '50000'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', Postal_Start__c = '50001', Postal_End__c = '60000'));
        insert assignments;
        Account acct = TM_TestDataPopulationUtil.createAccount('Test', 'USA', 'CA', '10009', null);
        Account acctResult = [select Id, Territory__c from Account where Id = :acct.Id];
        system.assertEquals(acctResult.Territory__c, territory.Id);
        Account searchAccount = [select Id, Territory_Boundary__c from Account where Id = :acct.Id];
        searchAccount.Territory_Boundary__c = boundary.Id;
        update searchAccount;
        Account acct2 = TM_TestDataPopulationUtil.createAccount('Test 002', 'CN', null, null, null);
        Account acct3 = TM_TestDataPopulationUtil.createAccount('Test 003', 'FR', null, null, null);
    }
    
    @isTest
    static void testShareAccountWithTerritoryMembers()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Approved', true);
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'CN'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', State__c = 'CA', Postal_Start__c = '10000', Postal_End__c = '50000'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = 'USA', Postal_Start__c = '50001', Postal_End__c = '60000'));
        insert assignments;
        //User user = [select Id, Name from User where Profile.Name = 'System Administrator' and Active = true and Id != :UserInfo.getUserId()];
        Territory_Member__c member = new Territory_Member__c(Account_Access__c = 'Edit', Opportunity_Access__c = 'Read', Territory__c = territory.Id, Territory_Boundary__c = boundary.Id, Territory_Member__c = UserInfo.getUserId());
        insert member;
        Account acct = TM_TestDataPopulationUtil.createAccount('Test', 'USA', 'CA', '10009', null);
        Account acctResult = [select Id, Territory__c from Account where Id = :acct.Id];
        system.assertEquals(acctResult.Territory__c, territory.Id);
        Account searchAccount = [select Id, Territory_Boundary__c from Account where Id = :acct.Id];
        searchAccount.Territory_Boundary__c = boundary.Id;
        update searchAccount;
        Account acct2 = TM_TestDataPopulationUtil.createAccount('Test 002', 'CN', null, null, null);
        Account acct3 = TM_TestDataPopulationUtil.createAccount('Test 003', 'FR', null, null, null);
    }
}