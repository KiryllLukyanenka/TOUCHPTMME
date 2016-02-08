@isTest
private class TM_CriteriaValuesControllerTest 
{
	@isTest 
	static void testCriteriaValuesController() 
	{
		PageReference pageRef = new PageReference('/apex/TM_CriteriaValues?fieldLabel=Account Type&isEdit=1&fieldValue=Prospect');
		Test.setCurrentPage(pageRef);
		TM_CriteriaValuesController controller = new TM_CriteriaValuesController();
		system.assertEquals(controller.isEdit, '1');
	}
}