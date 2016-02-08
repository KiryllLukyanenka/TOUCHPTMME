public class TM_NewTerritoryRedirectController
{
    public TM_NewTerritoryRedirectController(ApexPages.StandardController controller)
    {
    }
    
    public PageReference redirect()
    {
        PageReference pageRef = new PageReference('/apex/TM_TerritoryManagementConfigurationNew');
        pageRef.setRedirect(true);
        return pageRef;
    }
}