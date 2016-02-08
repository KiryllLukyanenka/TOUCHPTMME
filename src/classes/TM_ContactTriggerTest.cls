@isTest
private class TM_ContactTriggerTest {
    @isTest
    static void testSetContactOwner()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Account acct = TM_TestDataPopulationUtil.createAccount('Acme', 'US', 'CA', '', null);
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        User user = new User(ProfileId = profile.Id, Username = 'TestUser@touchpointcrm.com.test', Email = 'aaron@touchpointcrm.com.test', IsActive = true, EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimezoneSidKey = 'America/Los_Angeles', Alias = 'cspu', LastName = 'acme');
        insert user;
        Contact contact = new Contact(LastName = 'Test', OwnerId = user.Id, AccountId = acct.Id);
        insert contact;
        Account accountResult = [select Id, OwnerId from Account where Id = :acct.Id];
        Contact contactResult = [select Id, OwnerId from Contact where Id = :contact.Id];
        system.assertEquals(accountResult.OwnerId, contactResult.OwnerId);
    }
}