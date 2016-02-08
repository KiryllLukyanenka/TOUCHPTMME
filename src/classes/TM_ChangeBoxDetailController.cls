public class TM_ChangeBoxDetailController
{
    private static String cId = ApexPages.currentPage().getParameters().get('cid');
    //private Territory_Change_Box__c changeBox = new Territory_Change_Box__c();
    private List<Territory_Change_Box__c> changeBoxes = new List<Territory_Change_Box__c>();

    public TM_EntityUtil.ChangeSetInfo ChangeSet { get; set; }
    public Boolean IsShowApproveRejectButton { get; set; }
    public Territory_Config__c Config { get; private set; }
    public Boolean IsCurrentUserApprover { get; set; }

    public Boolean IsSystemAdmin
    {
        get
        {
            return TM_OrganizationSettings.isSystemAdmin();
        }
    }

    public List<TerritoryInfo> TerritoryInfos 
    { 
        get
        {
            List<TerritoryInfo> tempTerritoryInfos = new List<TerritoryInfo>();
            if(String.isNotBlank(cId) && cId instanceOf Id)
            {
                List<Territory__c> territories = [select Id, Name, New_Owner__r.Name, Effective_Date__c, Territory_Description__c, (select Id, Label__c, Field__c, Operator__c, Value__c from AccountCriteria__r) from Territory__c where Territory_Change_Box__c = :cId];
                Boolean isEffective = false;
                if(changeBoxes[0].Status__c == 'Approved')
                {
                    isEffective = true;
                }
                Map<String, String> boundaryMap = getTerritoryBoundaryMap(territories, changeBoxes[0].Status__c, isEffective);
                Map<String, List<TM_EntityUtil.AccountCriteriaInfo>> accountCriteriaMap = getAccountCriteriaMap(territories, boundaryMap);
                Map<String, List<TM_EntityUtil.AssignmentInfo>> assignmentMap = getAssignmentMap(territories, boundaryMap);
                Map<String, List<TM_EntityUtil.AccountInfo>> exceptionAccountMap = getExceptionAccountMap(territories, boundaryMap);
                for(Territory__c territory : territories)
                {
                    String effectiveDate = territory.Effective_Date__c == null ? null : territory.Effective_Date__c.format();
                    TM_EntityUtil.TerrInfo terrInfo = new TM_EntityUtil.TerrInfo(territory.Name, territory.New_Owner__r.Name, effectiveDate, territory.Territory_Description__c);
                    TerritoryInfo territoryInfo = new TerritoryInfo();
                    territoryInfo.Territory = terrInfo; 
                    territoryInfo.Assignments = assignmentMap.get(territory.Id);
                    territoryInfo.ExceptionAccounts = exceptionAccountMap.get(territory.Id);
                    territoryInfo.AccountCriteria = accountCriteriaMap.get(territory.Id);
                    tempTerritoryInfos.add(territoryInfo);
                }
            }
            return tempTerritoryInfos;
        }
        set; 
    }

    public TM_ChangeBoxDetailController()
    {
        ChangeSet = new TM_EntityUtil.ChangeSetInfo();
        Config = TM_OrganizationSettings.getTerritoryConfig();
        if(String.isNotBlank(cId) && cId instanceOf Id)
        {
            changeBoxes = [select Id, Name, Status__c, Approve_Date__c, Approver__c, Approver__r.Name, Approver__r.Email, SubmittedBy__c, SubmittedBy__r.Name, SubmittedBy__r.Email, Effective_Date__c, Last_Comment__c from Territory_Change_Box__c where Id = :cId];
            if(changeBoxes.size() > 0)
            {
                changeSet.Name = changeBoxes[0].Name;
            }
        }
        IsShowApproveRejectButton = changeBoxes[0].Status__c == 'Submitted' ? true : false;
        IsCurrentUserApprover = Config.Approver__c == UserInfo.getUserId() ? true : false;
    }

    public class TerritoryInfo
    {
        public TM_EntityUtil.TerrInfo Territory { get; set; }
        public List<TM_EntityUtil.AssignmentInfo> Assignments { get; set; }
        public List<TM_EntityUtil.AccountInfo> ExceptionAccounts { get; set; }
        public List<TM_EntityUtil.AccountCriteriaInfo> AccountCriteria { get; set; }
    } 

    public PageReference approveChangeBox()
    {
        updateChangeBox(changeBoxes, 'Approved');
        updateTerritoryOwnersAndBoundariesForApprovedOrCancelledChangeBox(cId, 'Approved', 'Submitted', 'Approved', false, true);
        if(changeBoxes[0].Effective_Date__c <= Date.today())
        {
            Set<String> effectiveTerritoryIds = getEffectiveTerritoryId(cId);
            Set<String> changeBoxIds = new Set<String> { cId };
            TM_SubmitChangeBoxHelper.changeBoxIds = changeBoxIds;
            TM_SubmitChangeBoxHelper.executeTerritoryOwnerBatch(effectiveTerritoryIds);
            TM_SubmitChangeBoxHelper.executeTerritoryBoundaryBatch(effectiveTerritoryIds);
        }
        return new PageReference('/apex/TM_Config');
    }

    public PageReference rejectChangeBox()
    {
        updateChangeBox(changeBoxes, 'Rejected'); 
        TM_TerritoryManagementHelper.sendRejectedAlert(changeBoxes);
        updateBoundariesAndOwnersForRejection(cId);
        return new PageReference('/apex/TM_Config');
    }

    private Map<String, List<TM_EntityUtil.AccountInfo>> getExceptionAccountMap(List<Territory__c> territories, Map<String, String> boundaryMap)
    {
        Map<String, List<TM_EntityUtil.AccountInfo>> accountMap = new Map<String, List<TM_EntityUtil.AccountInfo>>();
        for(Territory__c territory : territories)
        {
            accountMap.put(territory.Id, new List<TM_EntityUtil.AccountInfo>());
        }
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : [select Id, Territory_Boundary__c, Exception_Account__c, Exception_Account__r.Name, Exception_Account__r.BillingCountry, Exception_Account__r.ShippingCountry, Exception_Account__r.BillingState, Exception_Account__r.ShippingState, Exception_Account__r.BillingPostalCode, Exception_Account__r.ShippingPostalCode, Exception_Account__r.New_Territory__r.Name from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :boundaryMap.keySet()])
        {
            String territoryId = boundaryMap.get(accountToBoundary.Territory_Boundary__c);
            if(!accountMap.containsKey(territoryId))
            {
                accountMap.put(territoryId, new List<TM_EntityUtil.AccountInfo>());
            }
            Account acct = accountToBoundary.Exception_Account__r;
            if(Config.Billing_Shipping_Address__c.toLowerCase() == 'shipping')
            {
                accountMap.get(territoryId).add(new TM_EntityUtil.AccountInfo(acct.Name, acct.New_Territory__r.Name, acct.ShippingCountry, acct.ShippingState, acct.ShippingPostalCode));
            }
            else
            {
                accountMap.get(territoryId).add(new TM_EntityUtil.AccountInfo(acct.Name, acct.New_Territory__r.Name, acct.BillingCountry, acct.BillingState, acct.BillingPostalCode));
            }
            
        }
        return accountMap;
    }

    private Map<String, List<TM_EntityUtil.AccountCriteriaInfo>> getAccountCriteriaMap(List<Territory__c> territories, Map<String, String> boundaryMap)
    {
        Map<String, List<TM_EntityUtil.AccountCriteriaInfo>> accountCriteriaMap = new Map<String, List<TM_EntityUtil.AccountCriteriaInfo>>();
        for(Territory__c territory : territories)
        {
            accountCriteriaMap.put(territory.Id, new List<TM_EntityUtil.AccountCriteriaInfo>());
        }
        for(AccountCriteria__c criteria : [select Id, Territory_Boundary__c, Field__c, Label__c, Operator__c, Value__c from AccountCriteria__c where Territory_Boundary__c in :boundaryMap.keySet()])
        {
            String territoryId = boundaryMap.get(criteria.Territory_Boundary__c);
            accountCriteriaMap.get(territoryId).add(new TM_EntityUtil.AccountCriteriaInfo(criteria.Label__c, criteria.Operator__c, criteria.Value__c));
        }
        return accountCriteriaMap;
    }

    private Map<String, List<TM_EntityUtil.AssignmentInfo>> getAssignmentMap(List<Territory__c> territories, Map<String, String> boundaryMap)
    {
        Map<String, List<TM_EntityUtil.AssignmentInfo>> assignmentMap = new Map<String, List<TM_EntityUtil.AssignmentInfo>>();
        for(Territory__c territory : territories)
        {
            assignmentMap.put(territory.Id, new List<TM_EntityUtil.AssignmentInfo>());
        }
        for(Assignment_Detail__c assignment : [select Id, Territory_Assignment__c, Country__c, State__c, Postal_Start__c, Postal_End__c from Assignment_Detail__c where Territory_Assignment__c in :boundaryMap.keySet()])
        {
            String territoryId = boundaryMap.get(assignment.Territory_Assignment__c);
            assignmentMap.get(territoryId).add(new TM_EntityUtil.AssignmentInfo(assignment.Country__c, assignment.State__c, assignment.Postal_Start__c, assignment.Postal_End__c));
        }
        return assignmentMap;
    }

    private Map<String, String> getTerritoryBoundaryMap(List<Territory__c> territories, String status, Boolean isEffective)
    {
        Map<String, String> boundaryMap = new Map<String, String>();
        for(Territory__c territory :[select Id, Name, (select Id from Territory_Assignments__r where IsEffective__c = :isEffective and Status__c = :status order by LastModifiedDate desc limit 1) from Territory__c where Id in :territories])
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                boundaryMap.put(territory.Territory_Assignments__r[0].Id, territory.Id);
            }
        }
        return boundaryMap;
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

    private void updateChangeBox(List<Territory_Change_Box__c> changeBoxes, String status)
    {
        for(Territory_Change_Box__c changeBox : changeBoxes)
        {
            changeBox.Status__c = status;
            changeBox.Approve_Date__c = Date.today();
            changeBox.Last_Comment__c = ChangeSet.Comment;
        }
        update changeBoxes;
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

    private Set<String> getEffectiveTerritoryId(String changeBoxId)
    {
        Set<String> effectiveTerritoryIds = new Set<String>();
        for(Territory__c territory : [select Id, Name from Territory__c where Territory_Change_Box__c = :changeBoxId])
        {
            effectiveTerritoryIds.add(territory.Id);
        }
        return effectiveTerritoryIds;
    }
}