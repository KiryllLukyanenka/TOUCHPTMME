/*
 ** The controller of TM_Config page.
 ** Written by Joyce.
 */
public class TM_ConfigController
{
    public TM_EntityUtil.ConfigInfo ConfigInfo { get; set; }
    public Territory_Config__c TM_Config { get; set; }    
    public List<TM_EntityUtil.ChangeSetInfo> TM_ChangesWatingSubmit { get; set; }
    public List<TM_EntityUtil.ChangeSetInfo> TM_ChangesPendingApproval { get; set; }
    public List<TM_EntityUtil.ChangeSetInfo> TM_ChangesPendingEffective { get; set; }
    
    public Boolean IsEditMode { get; set; }
    public String  Comments { get; set; }
    public String  ChangeBoxId { get; set; }
    public Boolean IsCurrentApprover { get; set; }
    
    public Boolean IsSystemAdmin
    {
        get
        {
            return TM_OrganizationSettings.isSystemAdmin();
        }
    }
    
    //It used to remember the previous config values before update it again.
    public Territory_Config__c TempConfig
    {
        get
        {
            Territory_Config__c config = new Territory_Config__c();
            config.Catch_All_Territory_Name__c = TM_Config.Catch_All_Territory_Name__c;
            config.Include_Contacts__c = TM_Config.Include_Contacts__c;
            config.Include_Open_Activities__c = TM_Config.Include_Open_Activities__c;
            config.Include_Open_Opps__c = TM_Config.Include_Open_Opps__c;
            return config;      
       }
       set;
    }
    
    public TM_ConfigController()
    {
        IsCurrentApprover = false;
        TM_Config = TM_OrganizationSettings.getTerritoryConfig();

        ConfigInfo = new TM_EntityUtil.ConfigInfo(TM_Config.Catch_All_Territory_Name__c, TM_Config.Catch_All_Territory_Owner__r.Name, TM_Config.Include_Contacts__c, TM_Config.Include_Open_Opps__c, TM_Config.Include_Open_Activities__c, TM_Config.Use_Approval_Process__c, TM_Config.Approver__r.Name, TM_Config.Billing_Shipping_Address__c, TM_Config.Territory_Snapshots__c);
        if(TM_Config.Approver__c == UserInfo.getUserId())
        {
            IsCurrentApprover = true;
        }
        constructChangeBoxLists();
        IsEditMode = false;
    }
    
    public void edit()
    {
        IsEditMode = true;
    }

    public void cancelUpdate()
    {
        IsEditMode = false;
        TM_Config = TM_OrganizationSettings.getTerritoryConfig();
        ConfigInfo = new TM_EntityUtil.ConfigInfo(TM_Config.Catch_All_Territory_Name__c, TM_Config.Catch_All_Territory_Owner__r.Name, TM_Config.Include_Contacts__c, TM_Config.Include_Open_Opps__c, TM_Config.Include_Open_Activities__c, TM_Config.Use_Approval_Process__c, TM_Config.Approver__r.Name, TM_Config.Billing_Shipping_Address__c, TM_Config.Territory_Snapshots__c);
    }

    public void deleteChangeBox()
    {
        String changeBoxId = ApexPages.currentPage().getParameters().get('deleteCBId');
        Territory_Change_Box__c changeBox = [select Id, Status__c from Territory_Change_Box__c where Id = :changeBoxId];
        deleteBoundariesAndOwnersForChangeBox(changeBox.Id, changeBox.Status__c);
        delete changeBox;
        removeBoxFromList(changeBoxId);
    }

    public void rejectChangeBox()
    {
        List<Territory_Change_Box__c> changeBoxes = [select Id, Name, Effective_Date__c, Submit_Date__c, SubmittedBy__c, SubmittedBy__r.Name, SubmittedBy__r.Email, Approve_Date__c, Last_Comment__c, Status__c, Approver__c, Approver__r.Name from Territory_Change_Box__c where Id = :changeBoxId];
        updateChangeBox(changeBoxes, 'Rejected'); 
        TM_TerritoryManagementHelper.sendRejectedAlert(changeBoxes);
        updateBoundariesAndOwnersForRejection(ChangeBoxId);
        constructChangeBoxLists();
    }

    public PageReference cancel()
    {
        String changeBoxId = ApexPages.currentPage().getParameters().get('cbId');
        List<Territory_Change_Box__c> changeBoxes = [select Id, Name, Effective_Date__c, Submit_Date__c, SubmittedBy__c, Approve_Date__c, Last_Comment__c, Status__c, Approver__c from Territory_Change_Box__c where Id = :changeBoxId];
        updateChangeBox(changeBoxes, 'Definition');
        updateTerritoryOwnersAndBoundariesForApprovedOrCancelledChangeBox(changeBoxes[0].Id, 'Definition', 'Approved', 'Approved', false, true);
        constructChangeBoxLists();
        return null;
    }

    public void approveChangeBox()
    {
        List<Territory_Change_Box__c> changeBoxes = [select Id, Name, Effective_Date__c, Submit_Date__c, SubmittedBy__c, SubmittedBy__r.Name, Approve_Date__c, Last_Comment__c, Status__c, Approver__c, Approver__r.Name, Approver__r.Email from Territory_Change_Box__c where Id = :changeBoxId];
        updateChangeBox(changeBoxes, 'Approved');
        updateTerritoryOwnersAndBoundariesForApprovedOrCancelledChangeBox(changeBoxId, 'Approved', 'Submitted', 'Approved', false, true);
        if(changeBoxes[0].Effective_Date__c <= Date.today())
        {
            Set<String> effectiveTerritoryIds = getEffectiveTerritoryId(ChangeBoxId);
            Set<String> changeBoxIds = new Set<String> { changeBoxId };
            TM_SubmitChangeBoxHelper.changeBoxIds = changeBoxIds;
            TM_SubmitChangeBoxHelper.executeTerritoryOwnerBatch(effectiveTerritoryIds);
            TM_SubmitChangeBoxHelper.executeTerritoryBoundaryBatch(effectiveTerritoryIds);
        }
        constructChangeBoxLists();
    }

    public void submitConfiguration()
    {
        try
        {
            TM_Config.OwnerId = TM_Config.Catch_All_Territory_Owner__c;            
            upsert TM_Config;
            TM_Config = TM_OrganizationSettings.getTerritoryConfig();
            recalculateConfigInfo(); 
            upsertCatchAllTerritory();
            IsEditMode = false;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }

    private void recalculateConfigInfo()
    {
        ConfigInfo.CatchAllName = TM_Config.Catch_All_Territory_Name__c;
        ConfigInfo.CatchAllOwner = TM_Config.Catch_All_Territory_Owner__r.Name;
        ConfigInfo.IncludeContacts = TM_Config.Include_Contacts__c;
        ConfigInfo.IncludeOpenOpps = TM_Config.Include_Open_Opps__c;
        ConfigInfo.IncludeActivities = TM_Config.Include_Open_Activities__c;
        ConfigInfo.UseApproval = TM_Config.Use_Approval_Process__c;
        ConfigInfo.Approver = TM_Config.Approver__r.Name;
        ConfigInfo.BillingShippingAddress = TM_Config.Billing_Shipping_Address__c;
        ConfigInfo.TerritorySnapshot = TM_Config.Territory_Snapshots__c;
    }

    private void getTerritoryIdsAndTerritoryMap(List<Territory__c> territories, Set<String> territoryIds, Map<String, Territory__c> territoryMap)
    {
        for(Territory__c territory : territories)
        {
            territoryIds.add(territory.Id);
            territoryMap.put(territory.Id, territory);
        }
    }

    private void syncTerritoryNewOwnerAndCurrentOwner(List<Territory__c> territories)
    {
        for(Territory__c territory : territories)
        {    
            territory.New_Owner__c = territory.Current_Owner__c;
        }
        if(territories.size() > 0)
        {
            update territories;
        }
    }
    
    private void upsertCatchAllTerritory()
    {
        Territory__c catchAllTerritory = TM_OrganizationSettings.getCatchAllTerritory();
        Territory__c territory = catchAllTerritory == null ? new Territory__c() : catchAllTerritory;
        territory.Name = TM_Config.Catch_All_Territory_Name__c;
        territory.Current_Owner__c = TM_Config.Catch_All_Territory_Owner__c;
        territory.Territory_Type__c = 'Catch All';
        territory.RecordTypeId = TM_OrganizationSettings.getCatchAllRecordTypeId();
        upsert territory;
    }

    private Set<String> getEffectiveTerritoryId(String changeBoxId)
    {
        Set<String> effectiveTerritoryIds = new Set<String>();
        for(Territory__c territory : [select Id, Name from Territory__c where Territory_Change_Box__c = :changeBoxId])
        {
            effectiveTerritoryIds.add(territory.Id);
        }
        return effectiveTerritoryIds;
    }

    private void deactivateTerritoryOwnersAndBoundaries(String changeBoxId, Map<String, Territory_Boundary__c> boundaryMap, Map<String, Territory_Owner__c> ownerMap, String targetStatus)
    {
        for(Territory__c territory : [select Id, (select Id, IsEffective__c, Status__c from Territory_Assignments__r where IsEffective__c = true order by LastModifiedDate desc limit 1), (select Id, Status__c, IsEffective__c from Territory_Owners__r where IsEffective__c = true order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c = :changeBoxId])
        {
            for(Territory_Boundary__c boundary : territory.Territory_Assignments__r)
            {
                boundary.IsEffective__c = false;
                boundary.Status__c = targetStatus;
                boundaryMap.put(territory.Id, boundary);
            }
            for(Territory_Owner__c owner : territory.Territory_Owners__r)
            {
                owner.IsEffective__c = false;
                owner.Status__c = targetStatus;
                ownerMap.put(territory.Id, owner);
            }
        }
    }

    private void updateTerritoryOwnersAndBoundariesForApprovedOrCancelledChangeBox(String changeBoxId, String deactivateStatus, String status, String targetStatus, Boolean IsEffective, Boolean targetEffective)
    {
        Map<String, Territory_Owner__c> deactivatedOwnerMap = new Map<String, Territory_Owner__c>();
        Map<String, Territory_Boundary__c> deactivatedBoundaryMap = new Map<String, Territory_Boundary__c>();
        deactivateTerritoryOwnersAndBoundaries(changeBoxId, deactivatedBoundaryMap, deactivatedOwnerMap, deactivateStatus);
        List<Territory_Boundary__c> boundaries = getTerritoryBoundaries(changeBoxId, status, targetStatus, IsEffective, targetEffective);
        List<Territory_Owner__c> owners = getTerritoryOwners(changeBoxId, status, targetStatus, IsEffective, targetEffective);
        List<Territory_Boundary__c> tempBoundaries = new List<Territory_Boundary__c>();
        List<Territory_Owner__c> tempOwners = new List<Territory_Owner__c>();
        for(Territory_Boundary__c boundary : boundaries)
        {
            if(deactivatedBoundaryMap.containskey(boundary.Territory__c))
            {
                tempBoundaries.add(deactivatedBoundaryMap.get(boundary.Territory__c));
            }
        }
        for(Territory_Owner__c owner : owners)
        {
            if(deactivatedOwnerMap.containsKey(owner.Territory__c))
            {
                tempOwners.add(deactivatedOwnerMap.get(owner.Territory__c));
            }
        }
        
        owners.addAll(tempOwners);
        boundaries.addAll(tempBoundaries);
        if(boundaries.size() > 0)
        {
            update boundaries;
        }
        if(owners.size() > 0)
        {
            update owners;
        }
    }

    private void constructChangeBoxLists()
    {     
        TM_ChangesWatingSubmit = new List<TM_EntityUtil.ChangeSetInfo>();
        TM_ChangesPendingApproval = new List<TM_EntityUtil.ChangeSetInfo>();
        TM_ChangesPendingEffective = new List<TM_EntityUtil.ChangeSetInfo>();
        List<Territory_Change_Box__c> TM_Changes = [select Id, Name, OwnerId, Owner.Name, CreatedById, CreatedBy.Name, Approve_Date__c, Effective_Date__c, Approver__c, Approver__r.Name, Last_Comment__c, Status__c, Submit_Date__c, SubmittedBy__c, SubmittedBy__r.Name, (select Id from Territories__r) from Territory_Change_Box__c where Effective_Date__c != null];
        for(Territory_Change_Box__c change : TM_Changes)
        {
            String effectiveDate = change.Effective_Date__c == null ? null : change.Effective_Date__c.format();
            String submitDate = change.Submit_Date__c == null ? null : change.Submit_Date__c.format();
            String approveDate = change.Approve_Date__c == null ? null : change.Approve_Date__c.format();
            if(!change.Territories__r.isEmpty())
            {
                if(change.Status__c == 'Submitted')
                {
                    TM_ChangesPendingApproval.add(new TM_EntityUtil.ChangeSetInfo(change.Id, change.Name, effectiveDate, change.Last_Comment__c, Change.Owner.Name, change.CreatedBy.Name, change.Status__c, change.SubmittedBy__r.Name, submitDate, change.Approver__r.Name, approveDate));
                }
                else if(change.Status__c == 'Approved' && change.Effective_Date__c > Date.today())
                {
                    TM_ChangesPendingEffective.add(new TM_EntityUtil.ChangeSetInfo(change.Id, change.Name, effectiveDate, change.Last_Comment__c, Change.Owner.Name, change.CreatedBy.Name, change.Status__c, change.SubmittedBy__r.Name, submitDate, change.Approver__r.Name, approveDate));  
                }
                else if(change.Status__c == 'Rejected' || change.Status__c == 'Definition')
                {
                    TM_ChangesWatingSubmit.add(new TM_EntityUtil.ChangeSetInfo(change.Id, change.Name, effectiveDate, change.Last_Comment__c, Change.Owner.Name, change.CreatedBy.Name, change.Status__c, change.SubmittedBy__r.Name, submitDate, change.Approver__r.Name, approveDate));
                }
                else
                {
                }
            }
        }
    }

    private List<Territory_Owner__c> getTerritoryOwners(String changeBoxId, String status, String targetStatus, Boolean IsEffective, Boolean targetEffective)
    {
        List<Territory_Owner__c > owners = new List<Territory_Owner__c>();
        List<Territory__c> territories = [select Id, Name, Effective_Date__c, (select Id, Status__c, IsEffective__c from Territory_Owners__r where Status__c = :status and IsEffective__c = :isEffective order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c =:changeBoxId];
        for(Territory__c territory : territories)
        {
            if(territory.Territory_Owners__r.size() > 0)
            {
                Territory_Owner__c owner = territory.Territory_Owners__r[0];
                owner.Status__c = targetStatus;
                owner.IsEffective__c = targetEffective;
                owners.add(owner);
            }
        }
        return owners;
    }

    private List<Territory_Boundary__c> getTerritoryBoundaries(String changeBoxId, String status, String targetStatus, Boolean IsEffective, Boolean targetEffective)
    {
        List<Territory_Boundary__c> boundaries = new List<Territory_Boundary__c>();
        List<Territory__c> territories = [select Id, Name, Effective_Date__c, Current_Boundary__c, (select Id, Name, Territory__c, Territory__r.Current_Boundary__c, Status__c, IsEffective__c from Territory_Assignments__r where Status__c = :status and IsEffective__c = :IsEffective order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c =:changeBoxId];
        for(Territory__c territory : territories)
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                Territory_Boundary__c boundary = territory.Territory_Assignments__r[0];
                boundary.Status__c = targetStatus;
                boundary.IsEffective__c = targetEffective;
                boundaries.add(boundary);
            }
        }
        return boundaries;
    }

    private void updateBoundariesAndOwnersForRejection(String changeBoxId)
    {
        List<Territory_Owner__c> owners = getTerritoryOwners(ChangeBoxId, 'Submitted', 'Rejected', false, false);
        List<Territory_Boundary__c> boundaries = getTerritoryBoundaries(ChangeBoxId, 'Submitted', 'Rejected', false, false);
        if(owners.size() > 0)
        {
            update owners;
        }
        if(boundaries.size() > 0)
        {
            update boundaries;
        }
    }

    private void updateChangeBox(List<Territory_Change_Box__c> changeBoxes, String status)
    {
        for(Territory_Change_Box__c changeBox : changeBoxes)
        {
            changeBox.Status__c = status;
            changeBox.Approve_Date__c = Date.today();
            changeBox.Last_Comment__c = Comments;
        }
        update changeBoxes;
    }

    private void removeBoxFromList(String changeBoxId)
    {
        Integer index = 0;
        for(TM_EntityUtil.ChangeSetInfo changeBox : TM_ChangesWatingSubmit)
        {
            if(changeBox.ChangeSetId == changeBoxId)
            {
                break;
            }
            index ++;
        }
        TM_ChangesWatingSubmit.remove(index);
    }

    private void deleteBoundariesAndOwnersForChangeBox(String changeBoxId, String status)
    {
        List<Territory_Boundary__c> boundaries = new List<Territory_Boundary__c>();
        List<Territory_Owner__c> owners = new List<Territory_Owner__c>();
        for(Territory__c territory : [select Id, (select Id from Territory_Assignments__r where Status__c = :status and IsEffective__c = false order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c = :changeBoxId])
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                boundaries.add(territory.Territory_Assignments__r[0]);
            }
        }
        if(boundaries.size() > 0)
        {
            delete [select Id from Assignment_Detail__c where Territory_Assignment__c in :boundaries];
            delete [select Id from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :boundaries];
        }
    }
}