@isTest
private class TM_ChangeBoxDetailControllerTest {
    @isTest
    static void testChangeBoxDetailController()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory_Change_Box__c submittedChangeSet = TM_TestDataPopulationUtil.createChangeSet('Submitted', Date.today());
        Territory__c submittedTerritory = TM_TestDataPopulationUtil.createTerritory(submittedChangeSet.Id);
        Territory_Boundary__c submittedBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(submittedTerritory.Id, 'Submitted', false);
        Assignment_Detail__c submittedAssingment = TM_TestDataPopulationUtil.createAssignment(submittedBoundary.Id);
        Territory_Owner__c submittedOwner = TM_TestDataPopulationUtil.createTerritoryOwner(submittedTerritory.Id, 'Submitted', false);
        ExceptionAccount2TerritoryBoundary__c accountToBoundary = TM_TestDataPopulationUtil.createExceptionAccount(submittedBoundary.Id);
        PageReference pageRef = new PageReference('/apex/TM_ChangeBoxDetail?cid=' + submittedChangeSet.Id);
        Test.setCurrentPage(pageRef);
        TM_ChangeBoxDetailController controller = new TM_ChangeBoxDetailController();
        system.assertEquals(controller.IsShowApproveRejectButton, true);
        List<TM_ChangeBoxDetailController.TerritoryInfo> territoryInfos = controller.TerritoryInfos;
        system.assertEquals(territoryInfos.size(), 1);
        system.assertEquals(territoryInfos[0].Assignments.size(), 1);
        system.assertEquals(territoryInfos[0].ExceptionAccounts.size(), 1);
        controller.ChangeSet.Comment = 'Approved';
        controller.approveChangeBox();
        Territory_Change_Box__c approvedChangeSet = [select Id, Status__c from Territory_Change_Box__c where Id = :submittedChangeSet.Id];
        Territory_Boundary__c approvedBoundary = [select Id, Status__c from Territory_Boundary__c where Id = :submittedBoundary.Id];
        Territory_Owner__c approvedOwner = [select Id, Status__c from Territory_Owner__c where Id = :submittedOwner.Id];
        system.assertEquals(approvedChangeSet.Status__c, 'Approved');
        system.assertEquals(approvedBoundary.Status__c, 'Approved');
        system.assertEquals(approvedOwner.Status__c, 'Approved');   
    }

    @isTest
    static void testChangeBoxDetailController1()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        String recordTypeId = TM_TestDataPopulationUtil.getCatchAllRecordTypeId();
        Territory__c catchAllTerritory = TM_TestDataPopulationUtil.createCatchAllTerritory(recordTypeId, config.Catch_All_Territory_Owner__c);
        Territory_Change_Box__c submittedChangeSet = TM_TestDataPopulationUtil.createChangeSet('Submitted', Date.today());
        Territory__c submittedTerritory = TM_TestDataPopulationUtil.createTerritory(submittedChangeSet.Id);
        Territory_Boundary__c submittedBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(submittedTerritory.Id, 'Submitted', false);
        Assignment_Detail__c submittedAssignment = TM_TestDataPopulationUtil.createAssignment(submittedBoundary.Id);
        Territory_Owner__c submittedOwner = TM_TestDataPopulationUtil.createTerritoryOwner(submittedTerritory.Id, 'Submitted', false);
        PageReference pageRef = new PageReference('/apex/TM_ChangeBoxDetail?cid=' + submittedChangeSet.Id);
        Test.setCurrentPage(pageRef);
        TM_ChangeBoxDetailController controller1 = new TM_ChangeBoxDetailController();
        controller1.ChangeSet.Comment = 'Rejected';
        controller1.rejectChangeBox();
        Territory_Change_Box__c rejectedChangeSet = [select Id, Status__c from Territory_Change_Box__c where Id = :submittedChangeSet.Id];
        Territory_Boundary__c rejectedBoundary = [select Id, Status__c from Territory_Boundary__c where Id = :submittedBoundary.Id];
        Territory_Owner__c rejectedOwner = [select Id, Status__c from Territory_Owner__c where Id = :submittedOwner.Id];
        system.assertEquals(rejectedChangeSet.Status__c, 'Rejected');
        system.assertEquals(rejectedBoundary.Status__c, 'Rejected');
        system.assertEquals(rejectedOwner.Status__c, 'Rejected');
    }
}