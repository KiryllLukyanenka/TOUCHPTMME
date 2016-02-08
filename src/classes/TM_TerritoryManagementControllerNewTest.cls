@isTest
private class TM_TerritoryManagementControllerNewTest 
{
    @isTest
    static void testTerritoryManagementCongtroller()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        List<Account> accts = new List<Account>();
        accts.add(new Account(Name = 'Acme 1', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'Shanghai', ShippingState = 'Shanghai', No_Territory_Assignment__c = false));
        accts.add(new Account(Name = 'Acme 2', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'HeBei', ShippingState = 'HeBei', BillingPostalCode = '100006', ShippingPostalCode = '100006', No_Territory_Assignment__c = false));
        accts.add(new Account(Name = 'Acme 3', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'HeBei', ShippingState = 'HeBei', BillingPostalCode = '113456', ShippingPostalCode = '113456', No_Territory_Assignment__c = false));
        accts.add(new Account(Name = 'Acme 4', BillingCountry = 'USA', ShippingCountry = 'USA', BillingState = 'CA', ShippingState = 'CA', BillingPostalCode = '60000', ShippingPostalCode = '60000', No_Territory_Assignment__c = false));
        accts.add(new Account(Name = 'Acme 5', BillingCountry = 'USA', ShippingCountry = 'USA', BillingState = 'CA', ShippingState = 'CA', BillingPostalCode = '70000', ShippingPostalCode = '70000', No_Territory_Assignment__c = false));
        insert accts;
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        User user = new User(ProfileId = profile.Id, Username = 'aaron@touchpointcrm.com.test', Email = 'aaron@touchpointcrm.com.test', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimezoneSidKey = 'America/Los_Angeles', Alias = 'cspu', LastName = 'acme');
        insert user;
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(null);
        TM_TerritoryManagementControllerNew controller = new TM_TerritoryManagementControllerNew();
        controller.Territory.Name = 'Territory Acme';
        controller.Territory.New_Owner__c = user.Id;
        controller.saveTerritory();
        controller.createAssignment();
        controller.NewAssignments[0].Country__c = 'CN';
        controller.NewAssignments[0].State__c = 'HeBei';
        controller.NewAssignments[1].Country__c = 'CN';
        controller.NewAssignments[1].State__c = 'Guangdong';
        controller.addMoreAssignments();
        controller.saveCreateAssignment();
        Territory_Boundary__c boundary = [select Id, (select Id from Assignment_Details__r) from Territory_Boundary__c where Territory__c = :controller.Territory.Id and Status__c = 'Definition' order by LastModifiedDate desc limit 1];
        system.assertEquals(boundary.Assignment_Details__r.size(), 2);
        controller.createAssignment();
        controller.AssignmentType = 'Paste Assignments';
        controller.AssignmentsCSV = '\"CN\", \"SiChuan\",,';
        controller.saveCreateAssignment();
        boundary = [select Id, (select Id from Assignment_Details__r) from Territory_Boundary__c where Territory__c = :controller.Territory.Id and Status__c = 'Definition' order by LastModifiedDate desc limit 1];
        system.assertEquals(boundary.Assignment_Details__r.size(), 3);
        system.assertEquals(controller.Assignments.size(), 3);
        controller.AssignmentIndex = 0;
        controller.editAssignment();
        controller.Assignment.State__c = 'Shanghai';
        controller.saveEditAssignment();
        controller.AssignmentIndex = 0;
        controller.breakAssignment();
        controller.BrokenAssignments[0].Postal_Start__c = '100000';
        controller.BrokenAssignments[0].Postal_End__c = '150000';
        controller.BrokenAssignments[1].Postal_Start__c = '150001';
        controller.BrokenAssignments[1].Postal_End__c = '160000';
        controller.addBrokenAssignment();
        ApexPages.currentPage().getParameters().put('index', '2');
        controller.deleteBrokenAssignment();
        controller.saveBrokenAssignments();
        system.assertEquals(controller.Assignments.size(), 4);
        controller.AssignmentIndex = 3;
        controller.deleteAssignment();
        controller.addAccountCriteria();
        controller.addMoreCriteria();
        controller.NewCriteria.add(new AccountCriteria__c(Field__c = 'TerrMgmt__Active__c', Label__c = 'Active', Operator__c = 'equals', Value__c = 'Yes'));
        controller.AccountCriteriaIndex = 0;
        controller.deleteNewCriteria();
        controller.NewCriteria.add(new AccountCriteria__c(Field__c = 'TerrMgmt__Active__c', Label__c = 'Active', Operator__c = 'equals', Value__c = 'Yes'));
        controller.saveCreateCriteria();
        controller.AccountCriteriaIndex = 0;
        controller.editAccountCriteria();
        controller.saveEditAccountCriteria();
        controller.deleteAccountCriteria();
        controller.createNewTerritory();
        controller.Territory.Name = 'Territory Acme 2';
        controller.Territory.New_Owner__c = user.Id;
        controller.saveTerritory();
        controller.Index = 0;
        controller.editTerritories();
        controller.AssignmentIndex = 0;
        controller.TerritoryId = controller.AvailableTerritories[1].Id;
        controller.saveDragAssignment();
        controller.createExceptionAccount();
        controller.KeyWord = 'Acme';
        controller.CountryKeyWord = 'USA';
        controller.StateKeyWord = 'CA';
        controller.searchAccount();
        system.assertEquals(controller.AccountList.size() , 2);
        controller.AccountList[0].IsChecked = true;
        controller.AccountList[1].IsChecked = true;
        controller.saveExceptionAccount();
        controller.ExceptionAccountIndex = 1;
        controller.deleteExceptionAccount();
        controller.addExistingTerritories();
        controller.SelectedHidden = territory.Id;
        controller.addTerritories();
        system.assertEquals(controller.ChangedTerritories.size(), 2);
        controller.Territory.Territory_Description__c = 'Test Territory';
        controller.saveTerritory();
        controller.RemovedIndex = 0;
        controller.removeTerritory();
    }

    @isTest
    static void testTerritoryManagementController2()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        List<Account> accts = new List<Account>();
        accts.add(new Account(Name = 'Acme 1', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'Shanghai', ShippingState = 'Shanghai'));
        accts.add(new Account(Name = 'Acme 2', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'HeBei', ShippingState = 'HeBei', BillingPostalCode = '100006', ShippingPostalCode = '100006'));
        accts.add(new Account(Name = 'Acme 3', BillingCountry = 'CN', ShippingCountry = 'CN', BillingState = 'HeBei', ShippingState = 'HeBei', BillingPostalCode = '113456', ShippingPostalCode = '113456'));
        accts.add(new Account(Name = 'Acme 4', BillingCountry = 'USA', ShippingCountry = 'USA', BillingState = 'CA', ShippingState = 'CA', BillingPostalCode = '60000', ShippingPostalCode = '60000'));
        accts.add(new Account(Name = 'Acme 5', BillingCountry = 'USA', ShippingCountry = 'USA', BillingState = 'CA', ShippingState = 'CA', BillingPostalCode = '70000', ShippingPostalCode = '70000'));
        insert accts;
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        User user = new User(ProfileId = profile.Id, Username = 'aaron@touchpointcrm.com.test', Email = 'aaron@touchpointcrm.com.test', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', TimezoneSidKey = 'America/Los_Angeles', Alias = 'cspu', LastName = 'acme');
        insert user;
        Territory__c territory1 = TM_TestDataPopulationUtil.createTerritory(null);
        Territory__c territory2 = TM_TestDataPopulationUtil.createTerritory(null);
        Territory__c territory3 = TM_TestDataPopulationUtil.createTerritory(null);
        List<Territory_Boundary__c> boundaries = new List<Territory_Boundary__c>();
        boundaries.add(new Territory_Boundary__c(Territory__c = territory1.Id, Status__c = 'Definition', IsEffective__c = false));
        boundaries.add(new Territory_Boundary__c(Territory__c = territory2.Id, Status__c = 'Definition', IsEffective__c = false));
        boundaries.add(new Territory_Boundary__c(Territory__c = territory3.Id, Status__c = 'Definition', IsEffective__c = false));
        insert boundaries;
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundaries[0].Id, Country__c = 'CN', State__c = 'Sichuan'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundaries[0].Id, Country__c = 'CN', State__c = 'HeBei', Postal_Start__c = '100000', Postal_End__c = '150000'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundaries[0].Id, Country__c = 'CN', State__c = 'HeBei', Postal_Start__c = '150001', Postal_End__c = '160000'));
        assignments.add(new Assignment_Detail__c(Territory_Assignment__c = boundaries[1].Id, Country__c = 'CN', State__c = 'Shanghai'));
        TM_TerritoryManagementControllerNew controller = new TM_TerritoryManagementControllerNew();
        List<Territory__c> territories = [select Id, Name, Territory_Change_Box__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Current_Boundary__c, Current_Owner__c, Territory_Description__c from Territory__c order by Name];
        controller.AvailableTerritories.addAll(territories); 
        controller.Territory = controller.AvailableTerritories[0];
        controller.Territory.Name = 'Territory Acme 001';
        controller.saveTerritory();
        controller.Territory = controller.AvailableTerritories[1];
        controller.Territory.Name = 'Territory Acme 002';
        controller.saveTerritory();
        controller.addTerritoryMember();
        controller.addMoreTerritoryMember();
        controller.NewTerritoryMembers[0].Territory_Member__c = UserInfo.getUserId();
        controller.NewTerritoryMembers[0].Account_Access__c = 'Edit';
        controller.NewTerritoryMembers[0].Contact_Access__c = 'Edit';
        controller.NewTerritoryMembers[0].Opportunity_Access__c = 'Edit';
        controller.saveCreateTerritoryMembers();
        controller.TerritoryMemberIndex = 0;
        controller.editTerritoryMember();
        controller.TerritoryMember.Contact_Access__c = 'Read';
        controller.saveEditTerritoryMember();
        controller.TerritoryMemberIndex = 0;
        controller.deleteTerritoryMember();
        controller.checkAsisignmentWithSaveChangeBox();
        controller.checkAsisignmentWithSubmittedChangeBox();
        controller.Change.Name = 'CB 01';
        controller.EffectiveDate = '06/13/2015';
        controller.saveChangeBox();
        system.assertEquals(2, [select count() from Territory__c where Territory_Change_Box__c = :controller.Change.Id]);
        controller.calculateTerritoryFields();
        config.Use_Approval_Process__c = 'No';
        update config;
        controller.submit();
    }

    @isTest
    static void testTerritoryManagementController3()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory_Change_Box__c savedChangeBox = TM_TestDataPopulationUtil.createChangeSet('Definition', Date.today());
        Territory__c savedTerritory = TM_TestDataPopulationUtil.createTerritory(savedChangeBox.Id);
        Territory_Boundary__c savedBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(savedTerritory.Id, 'Definition', false);
        Assignment_Detail__c savedAssignment = new Assignment_Detail__c(Territory_Assignment__c = savedBoundary.Id, Country__c = 'CN');
        insert savedAssignment;
        Account savedAcct = TM_TestDataPopulationUtil.createAccount('Account Acme 0001', 'CN', null, null, null);
        ExceptionAccount2TerritoryBoundary__c savedAccountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Territory_Boundary__c = savedBoundary.Id, Exception_Account__c = savedAcct.Id);
        insert savedAccountToBoundary;

        Territory_Change_Box__c submittedChangeBox = TM_TestDataPopulationUtil.createChangeSet('Submitted', Date.today());
        Territory__c submittedTerritory = TM_TestDataPopulationUtil.createTerritory(submittedChangeBox.Id);
        Territory_Boundary__c submittedBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(submittedTerritory.Id, 'Submitted', false);
        Assignment_Detail__c submittedAssignment = new Assignment_Detail__c(Territory_Assignment__c = submittedBoundary.Id, Country__c = 'USA', State__c = 'CA');
        insert submittedAssignment;
        Account submittedAcct = TM_TestDataPopulationUtil.createAccount('Account Acme 0002', 'USA', 'CA', null, null);
        ExceptionAccount2TerritoryBoundary__c submittedAccountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Territory_Boundary__c = submittedBoundary.Id, Exception_Account__c = submittedAcct.Id);
        insert submittedAccountToBoundary;

        TM_TerritoryManagementControllerNew controller = new TM_TerritoryManagementControllerNew();
        system.assertEquals(controller.showPrevious, false);
        system.assertEquals(controller.showNext, false);
        controller.previous();
        controller.next();
        List<SelectOption> savedTerritoryChanges = controller.SavedTerritoryChanges;
        system.assertEquals(savedTerritoryChanges.size(), 2);
        List<SelectOption> submittedTerritoryChanges = controller.SubmittedTerritoryChanges;
        system.assertEquals(submittedTerritoryChanges.size(), 2);
        controller.SavedChangeBoxId = savedChangeBox.Id;
        controller.changeSavedChangeBox();
        controller.SubmittedChangeBoxId = submittedChangeBox.Id;
        controller.changeSubmittedChangeBox();

        PageReference pageRef = new PageReference('/apex/TM_TerritoryManagementConfiguration?territoryId=' + submittedTerritory.Id);
        Test.setCurrentPage(pageRef);
        TM_TerritoryManagementControllerNew controller1 = new TM_TerritoryManagementControllerNew();
    }
    
    @isTest
    static void testTerritoryManagementController4(){
        TM_TerritoryManagementControllerNew controller = new TM_TerritoryManagementControllerNew();
        controller.checkConfigExisting();
    }
}