@isTest
private class TM_ConfigControllerTest {
    @isTest
    static void testConfigController()
    {
        TM_TestDataPopulationUtil.abortJobs();
        Territory_Config__c config = TM_TestDataPopulationUtil.createTerritoryConfig();
        Territory_Change_Box__c changeSet = TM_TestDataPopulationUtil.createChangeSet('Definition', Date.today());
        Territory__c territory = TM_TestDataPopulationUtil.createTerritory(changeSet.Id);
        Territory_Boundary__c boundary = TM_TestDataPopulationUtil.createTerritoryBoundary(territory.Id, 'Definition', false);
        Assignment_Detail__c assignment = TM_TestDataPopulationUtil.createAssignment(boundary.Id);
        Territory_Owner__c owner = TM_TestDataPopulationUtil.createTerritoryOwner(territory.Id, 'Definition', false);
        TM_ConfigController controller = new TM_ConfigController();
        Boolean isSystemAdmin = controller.isSystemAdmin;
        system.assertEquals(isSystemAdmin, true);
        system.assertEquals(config.Include_Open_Activities__c, controller.TempConfig.Include_Open_Activities__c);
        system.assertEquals(config.Include_Open_Opps__c, controller.TempConfig.Include_Open_Opps__c);
        system.assertEquals(config.Include_Contacts__c, controller.TempConfig.Include_Contacts__c);
        controller.edit();
        controller.cancelUpdate();
        controller.TM_Config.Include_Open_Activities__c = false;
        controller.submitConfiguration();
        PageReference pageRef = new PageReference('/apex/TM_Config?deleteCBId=' + changeSet.Id);
        Test.setCurrentPage(pageRef);
        controller.deleteChangeBox();
        List<Territory_Change_Box__c> deletedChangeSets = [select Id from Territory_Change_Box__c where Id = :changeSet.Id];
        List<Territory_Boundary__c> deletedBoundaries = [select Id from Territory_Boundary__c where Id = :boundary.Id];
        List<Territory_Owner__c> deletedOwners = [select Id from Territory_Owner__c where Id = :owner.Id];
        system.assertEquals(deletedChangeSets.size(), 0);

        Territory_Change_Box__c submittedChangeSet = TM_TestDataPopulationUtil.createChangeSet('Submitted', Date.today());
        Territory__c submittedTerritory = TM_TestDataPopulationUtil.createTerritory(submittedChangeSet.Id);
        Territory_Boundary__c submittedBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(submittedTerritory.Id, 'Submitted', false);
        Assignment_Detail__c submittedAssingment = TM_TestDataPopulationUtil.createAssignment(submittedBoundary.Id);
        Territory_Owner__c submittedOwner = TM_TestDataPopulationUtil.createTerritoryOwner(submittedTerritory.Id, 'Submitted', false);
        controller.ChangeBoxId = submittedChangeSet.Id;
        controller.Comments = 'Your request has been approved.';
        controller.approveChangeBox();
        Territory_Change_Box__c approvedChangeSet = [select Id, Status__c from Territory_Change_Box__c where Id = :submittedChangeSet.Id];
        Territory_Boundary__c approvedBoundary = [select Id, Status__c from Territory_Boundary__c where Id = :submittedBoundary.Id];
        Territory_Owner__c approvedOwner = [select Id, Status__c from Territory_Owner__c where Id = :submittedOwner.Id];
        system.assertEquals(approvedChangeSet.Status__c, 'Approved');
        system.assertEquals(approvedBoundary.Status__c, 'Approved');
        system.assertEquals(approvedOwner.Status__c, 'Approved');

        Territory_Change_Box__c submittedChangeSet1 = TM_TestDataPopulationUtil.createChangeSet('Submitted', Date.today());
        Territory__c submittedTerritory1 = TM_TestDataPopulationUtil.createTerritory(submittedChangeSet1.Id);
        Territory_Boundary__c submittedBoundary1 = TM_TestDataPopulationUtil.createTerritoryBoundary(submittedTerritory1.Id, 'Submitted', false);
        Assignment_Detail__c submittedAssignment1 = TM_TestDataPopulationUtil.createAssignment(submittedBoundary1.Id);
        Territory_Owner__c submittedOwner1 = TM_TestDataPopulationUtil.createTerritoryOwner(submittedTerritory1.Id, 'Submitted', false);
        controller.ChangeBoxId = submittedChangeSet1.Id;
        controller.Comments = 'Your request has been rejected.';
        controller.rejectChangeBox();
        Territory_Change_Box__c rejectedChangeSet = [select Id, Status__c from Territory_Change_Box__c where Id = :submittedChangeSet1.Id];
        Territory_Boundary__c rejectedBoundary = [select Id, Status__c from Territory_Boundary__c where Id = :submittedBoundary1.Id];
        Territory_Owner__c rejectedOwner = [select Id, Status__c from Territory_Owner__c where Id = :submittedOwner1.Id];
        system.assertEquals(rejectedChangeSet.Status__c, 'Rejected');
        system.assertEquals(rejectedBoundary.Status__c, 'Rejected');
        system.assertEquals(rejectedOwner.Status__c, 'Rejected');

        Territory_Change_Box__c inEffectiveChangeSet = TM_TestDataPopulationUtil.createChangeSet('Approved', Date.today().addDays(3));
        Territory__c inEffectiveTerritory = TM_TestDataPopulationUtil.createTerritory(inEffectiveChangeSet.Id);
        Territory_Boundary__c inEffectiveBoundary = TM_TestDataPopulationUtil.createTerritoryBoundary(inEffectiveTerritory.Id, 'Approved', true);
        Assignment_Detail__c inEffectiveAssignment = TM_TestDataPopulationUtil.createAssignment(inEffectiveBoundary.Id);
        Territory_Owner__c inEffectiveOwner = TM_TestDataPopulationUtil.createTerritoryOwner(inEffectiveTerritory.Id, 'Approved', true);
        ApexPages.currentPage().getParameters().put('cbId', inEffectiveChangeSet.Id);
        controller.cancel();
        Territory_Change_Box__c cancelledChangeSet = [select Id, Status__c from Territory_Change_Box__c where Id = :inEffectiveChangeSet.Id];
        Territory_Boundary__c cancelledBoundary = [select Id, Status__c from Territory_Boundary__c where Id = :inEffectiveBoundary.Id];
        Territory_Owner__c cancelledOwner = [select Id, Status__c from Territory_Owner__c where Id = :inEffectiveOwner.Id];
        system.assertEquals(cancelledChangeSet.Status__c, 'Definition');
        system.assertEquals(cancelledBoundary.Status__c, 'Approved');
    }
}