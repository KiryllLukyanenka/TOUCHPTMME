public class TM_ChangeBoxTriggerHandler
{
    public static void setChangeBoxDefaultApprover(List<Territory_Change_Box__c> changeBoxes)
    {
        Territory_Config__c config = TM_OrganizationSettings.getTerritoryConfig();
        if(config.Use_Approval_Process__c == 'Yes')
        {
            for(Territory_Change_Box__c changeBox : changeBoxes)
            {
                changeBox.Approver__c = config.Approver__c;
            }
        }
    }
}