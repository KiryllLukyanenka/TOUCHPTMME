public class TM_TerritoryManagementControllerNew
{
    private Set<String> tempModifiedTerritoryIds = new Set<String>();
    private Map<String, List<Assignment_Detail__c>> assignmentMap = new Map<String, List<Assignment_Detail__c>>();
    private Map<String, List<Account>> exceptionAccountMap = new Map<String, List<Account>>();
    private Map<String, List<AccountCriteria__c>> accountCriteriaMap = new Map<String, List<AccountCriteria__c>>();
    private Map<String, List<Territory_Member__c>> territoryMemberMap = new Map<String, List<Territory_Member__c>>();
    private Set<String> modifiedTerritoryIds = new Set<String>();
    private Set<String> availableTerritoryIds = new Set<String>();
    private Territory__c tempTerritory = new Territory__c();
    private Map<String, String> fieldNameToLabelMap = new Map<String, String>(); 
    private String defaultACField;
    
    public Territory_Config__c Config { get; set; }
    public Territory_Change_Box__c Change { get; set; }
    public Territory_Change_Box__c Change2 { get; set; }
    public List<Territory__c> AvailableTerritories { get; set; }
    public List<Territory__c> ChangedTerritories { get; set; }
    public Territory__c Territory { get; set; }
    
    public List<Assignment_Detail__c> Assignments { get; set; }
    public List<Assignment_Detail__c> currentPageAssignments { get; set; }
    public List<Assignment_Detail__c> NewAssignments { get; set; }
    public List<Assignment_Detail__c> BrokenAssignments { get; set; }
    public List<AccountCriteria__c> AccountCriteria { get; set; }
    public List<Territory_Member__c> TerritoryMembers { get; set; }
    public List<AccountCriteria__c> NewCriteria { get; set; }
    public AccountCriteria__c AcctCriteria { get; set; }
    public List<Territory_Member__c> NewTerritoryMembers { get; set; }
    public Territory_Member__c TerritoryMember { get; set; }
    
    public List<Account> ExceptionAccounts { get; set; }
    public List<AccountInfo> AccountList { get; set; }
    
    public List<SelectOption> PopAvailableTerritories { get; set; }
    public List<SelectOption> PopSelectedTerritories { get; set; }
    public List<SelectOption> AccountFields { get; set; }
    public List<SelectOption> Operators { get; set; }

    public Assignment_Detail__c Assignment { get; set; }
    public String SelectedHidden { get; set; }
    public Integer Index { get; set; }   
    public Integer AssignmentIndex { get; set; }
    public Integer ExceptionAccountIndex { get; set; }
    public Integer TerritoryMemberIndex { get; set; }
    public String AssignmentType { get; set; }
    public String AssignmentsCSV { get; set; }
    public String KeyWord { get; set; }
    public String NumberKeyWord { get; set; }
    public String CountryKeyWord { get; set; }
    public String StateKeyWord { get; set; }
    public String CityKeyWord { get; set; }
    public String TerritoryId { get; set; }
    public String SavedChangeBoxId { get; set; }
    public String SubmittedChangeBoxId { get; set; }
    public Integer RemovedIndex { get; set; }
    public Integer AccountCriteriaIndex { get; set; }

    public String EffectiveDate { get; set; }
    
    public String ExtendedPanelId { get; set; }
    
    public Boolean IsShowCreateCriteriaPop { get; set; }
    public Boolean IsShowEditCriteriaPop { get; set; }
    public Boolean IsShowAssignmentAndExceptionAccount { get; set; }
    public Boolean IsShowAddExistingPop { get; set; }
    public Boolean IsShowNewAssignmentPop { get; set; }
    public Boolean IsShowEditAssignmentPop { get; set; }
    public Boolean IsShowBreakAssignmentPop { get; set; }
    public Boolean IsShowExceptionAccountPop { get; set; }
    public Boolean IsEnableAllButtons { get; set; }
    public Boolean IsDisableSaveAndSubmitButton { get; set; }
    public String IsShowSavePop { get; set; }
    public String IsShowSubmitPop { get; set; }
    public Boolean IsShowAddMemberPop { get; set; }
    public Boolean IsShowEditMemberPop { get; set; }

    public Integer pageSize { get; set; }
    public Integer pageNum {get;set;}
    public Integer totalPage {get;set;}
    public Integer totalResults {get;set;}

    public Boolean showPrevious {
        get{
            return pageNum > 1;
        }
        set;
    }

    public Boolean showNext
    {
        get
        {
            return pageNum < totalPage;
        }
    }

    public List<SelectOption> SavedTerritoryChanges {  
        get
        {
            List<SelectOption> territoryChanges = new List<SelectOption>();
            territoryChanges.add(new SelectOption('Saved Territory Changes', 'Saved Territory Changes'));
            List<Territory_Change_Box__c> boxes = [select Id, Name, (select Id from Territories__r) from Territory_Change_Box__c where (Status__c = 'Definition' or Status__c = 'Rejected') and Effective_Date__c != null order by Name];
            for(Territory_Change_Box__c box : boxes)
            {
                if(box.Territories__r.size() > 0)
                {
                    territoryChanges.add(new SelectOption(box.Id, box.Name));
                }
            }
            return territoryChanges;
        }
        set; 
    }
    
    public List<SelectOption> SubmittedTerritoryChanges 
    { 
        get
        {
            List<SelectOption> territoryChanges = new List<SelectOption>();
            territoryChanges.add(new SelectOption('Submitted Territory Changes', 'Submitted Territory Changes'));
            List<Territory_Change_Box__c> boxes = [select Id, Name, (select Id from Territories__r) from Territory_Change_Box__c where Status__c = 'Submitted' and Effective_Date__c != null order by Name];
            for(Territory_Change_Box__c box : boxes)
            {
                if(box.Territories__r.size() > 0)
                {
                    territoryChanges.add(new SelectOption(box.Id, box.Name));
                }
            }
            return territoryChanges;
        }
        set; 
     }

    public TM_TerritoryManagementControllerNew()
    {       
        initProperties();
        initTerritoryChangeBox();
        initAccountFieldsAndOperators();
        showPop(false, false, false, false, false, false, false, false, false);
    }

    public void previous(){
        if(pageNum > 1){
            pageNum --;
            getCurrentPageRecords();
        }  
    }
   
    public void next(){
        if(pageNum < totalPage){
            pageNum ++;
            getCurrentPageRecords();
        }
    }

    public void getCurrentPageRecords(){
        currentPageAssignments = new List<Assignment_Detail__c>();
        Integer startIndex = (pageNum - 1) * pageSize > 0 ? (pageNum - 1) * pageSize : 0;
        Integer endIndex = startIndex + pageSize > totalResults ? totalResults : startIndex + pageSize;
        for(Integer i = startIndex; i < endIndex; i ++){
            currentPageAssignments.add(Assignments[i]);
        }
    }
    
    public PageReference checkConfigExisting()
    {
        List<Territory_Config__c> configs = [select Id from Territory_Config__c order by LastModifiedDate desc limit 1];
        if(configs.size() == 0)
        {
            String namespace = TM_OrganizationSettings.Namespace;
            String pageName = String.isNotBlank(namespace) ? namespace + '__TM_Config' : 'TM_Config';
            PageReference pageRef = new PageReference('/apex/' + pageName);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    public void editAccountCriteria()
    {
        showPop(false, true, false, false, false, false, false, false, false);
        Integer index = Integer.valueOf(AccountCriteriaIndex);
        AcctCriteria = AccountCriteria.get(index);
        String label = fieldNameToLabelMap.get(AcctCriteria.Field__c);
        recontructOperators(TM_GlobalVariables.descirbeFieldResultMap.get(label), AcctCriteria);
    }

    public void editTerritoryMember(){
        showPop(false, false, false, false, false, false, false, false, true);
        Integer index = Integer.valueOf(TerritoryMemberIndex);
        TerritoryMember = TerritoryMembers.get(index);
    }

    public void saveEditAccountCriteria()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        if(AcctCriteria.Field__c != null && AcctCriteria.Operator__c != null)
        {
            AcctCriteria.Label__c = fieldNameToLabelMap.get(AcctCriteria.Field__c);
            populateBoundaryForAccountCriteria(AccountCriteria);
            try
            {
                upsert AccountCriteria;
                addTerritoryToChangedTerritories();
            }
            catch(Exception ex)
            {
            }
        }  
    }

    public void saveEditTerritoryMember(){
        showPop(false, false, false, false, false, false, false, false, false);
        if(TerritoryMember.Territory_Member__c != null){
            populateBoundaryForTerritoryMembers(TerritoryMembers);
            try{
                upsert TerritoryMembers;
                addTerritoryToChangedTerritories();
            }catch(Exception ex){

            }
        }
    }

    public void deleteAccountCriteria()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        populateBoundaryForAccountCriteria(AccountCriteria);
        try
        {
            upsert AccountCriteria;
            delete [select Id from AccountCriteria__c where Id = :AccountCriteria[AccountCriteriaIndex].Id];
            AccountCriteria.remove(AccountCriteriaIndex);
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }    
    }

    public void deleteTerritoryMember()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        populateBoundaryForTerritoryMembers(TerritoryMembers);
        try
        {
            upsert TerritoryMembers;
            delete [select Id from Territory_Member__c where Id = :TerritoryMembers[TerritoryMemberIndex].Id];
            TerritoryMembers.remove(TerritoryMemberIndex);
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }    
    }

    public void addAccountCriteria()
    {
        showPop(true, false, false, false, false, false, false, false, false);
        NewCriteria = new List<AccountCriteria__c>();
        AccountCriteria__c criteria = new AccountCriteria__c(Field__c = defaultACField);
        String label = fieldNameToLabelMap.get(defaultACField);
        recontructOperators(TM_GlobalVariables.descirbeFieldResultMap.get(label), criteria);
        NewCriteria.add(criteria);
    }

    public void addTerritoryMember(){
        showPop(false, false, false, false, false, false, false, true, false);
        NewTerritoryMembers = new List<Territory_Member__c>();
        Territory_Member__c member = new Territory_Member__c();
        NewTerritoryMembers.add(member);
    }

    public void addMoreCriteria()
    {
        AccountCriteria__c criteria = new AccountCriteria__c(Field__c = defaultACField);
        String label = fieldNameToLabelMap.get(defaultACField);
        recontructOperators(TM_GlobalVariables.descirbeFieldResultMap.get(label), criteria);
        NewCriteria.add(criteria);
    }

    public void addMoreTerritoryMember(){
        Territory_Member__c member = new Territory_Member__c();
        NewTerritoryMembers.add(member);
    }

    public void deleteNewCriteria()
    {
        NewCriteria.remove(AccountCriteriaIndex);
    }

    public void saveCreateCriteria()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        constructAccountCriteriaList();
        populateBoundaryForAccountCriteria(AccountCriteria);
        try
        {
            upsert AccountCriteria;
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }
    }

    public void saveCreateTerritoryMembers(){
        showPop(false, false, false, false, false, false, false, false, false);
        constructTerritoryMemberList();
        populateBoundaryForTerritoryMembers(TerritoryMembers);
        try{
            upsert TerritoryMembers;
            addTerritoryToChangedTerritories();
        }catch(Exception ex){

        }
    }
    
    public void changeAccountCriteria()
    {
        Integer index = Integer.valueOf(AccountCriteriaIndex);
        AccountCriteria__c criteria = NewCriteria.get(index);
        String label = fieldNameToLabelMap.get(criteria.Field__c);
        recontructOperators(TM_GlobalVariables.descirbeFieldResultMap.get(label), criteria);
    }

    public void changeAccountCriteriaForEditPanel()
    {
        String label = fieldNameToLabelMap.get(AcctCriteria.Field__c);
        recontructOperators(TM_GlobalVariables.descirbeFieldResultMap.get(label), AcctCriteria);
    }
    
    public void changeSavedChangeBox()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        resetRelatedVariables();
        List<String> territoryIds = new List<String>();
        if(SavedChangeBoxId != 'Saved Territory Changes')
        {
            Change = [select Id, Name, Approve_Date__c, Approver__c, Effective_Date__c, Last_Comment__c, Status__c, Submit_Date__c, SubmittedBy__c from Territory_Change_Box__c where Id = :SavedChangeBoxId];
            Change2.Name = Change.Name;
            Change2.Effective_Date__c = Change.Effective_Date__c;
            String day = Change2.Effective_Date__c.day() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.day()) : String.valueOf(Change2.Effective_Date__c.day());
            String month = Change2.Effective_Date__c.month() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.month()) : String.valueOf(Change2.Effective_Date__c.month());
            String year = String.valueOf(Change2.Effective_Date__c.year());
            EffectiveDate = month + '/' + day + '/' + year;
            getChangeBoxData(SavedChangeBoxId, territoryIds);
            Territory = AvailableTerritories[0];
            IsShowAssignmentAndExceptionAccount = true; 
            IsEnableAllButtons = true;
            if(Change.Status__c == 'Rejected')
            {
                getAssignmentMapForChangeBox(Change.Id, Change.Status__c);
                getExceptionAccountMapForChangeBox(Change.Id, Change.Status__c);
            }
            else
            {
                getAssignmentMap(territoryIds);
                getExceptionAccountMap(territoryIds);
            }
            getAssignmentsAndExceptionAccounts();   
        }
    }
    
    /*
     **  When you select a change box in the "Submitted Change Boxes" dropdown list.
     */
    public void changeSubmittedChangeBox()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        resetRelatedVariables();
        List<String> territoryIds = new List<String>();
        if(SubmittedChangeBoxId != 'Submitted Territory Changes')
        {
            Change = [select Id, Name, Approve_Date__c, Approver__c, Effective_Date__c, Last_Comment__c, Status__c, Submit_Date__c, SubmittedBy__c from Territory_Change_Box__c where Id = :SubmittedChangeBoxId];
            Change2.Name = Change.Name;
            Change2.Effective_Date__c = Change.Effective_Date__c;
            String day = Change2.Effective_Date__c.day() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.day()) : String.valueOf(Change2.Effective_Date__c.day());
            String month = Change2.Effective_Date__c.month() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.month()) : String.valueOf(Change2.Effective_Date__c.month());
            String year = String.valueOf(Change2.Effective_Date__c.year());
            EffectiveDate = month + '/' + day + '/' + year;
            getChangeBoxData(SubmittedChangeBoxId, territoryIds);
            Territory = AvailableTerritories[0];
            IsShowAssignmentAndExceptionAccount = true;
            IsEnableAllButtons = false;
            IsDisableSaveAndSubmitButton = true;
            getAssignmentMapForChangeBox(Territory.Territory_Change_Box__c, 'Submitted');
            getExceptionAccountMapForChangeBox(Territory.Territory_Change_Box__c, 'Submitted');
            getAssignmentsAndExceptionAccounts();  
        } 
        else
        {
            IsEnableAllButtons = true;
        }
    }

    /*
     ** operation: click the "Add Existing" link.
     ** it will show the territories which are not in submitted and approved change boxes but effecitive date less than today change boxes.
     */
    public void addExistingTerritories()
    {        
        PopAvailableTerritories.clear();
        showPop(false, false, true, false, false, false, false, false, false);
        Set<String> territoryIds = new Set<String>();
        for(Territory__c territory : AvailableTerritories)
        {
            territoryIds.add(territory.Id);
        }
        List<Territory__c> territoryList = [select Id, Name from Territory__c where (Territory_Change_Box__c = null or Territory_Change_Box__r.Status__c = 'Rejected' or (Territory_Change_Box__r.Status__c = 'Approved' and Territory_Change_Box__r.Job_Completion_Date_Time__c <= :DateTime.now())) and Territory_Type__c != 'Catch All' and Id not in :territoryIds order by Name];
        for(Territory__c territory : territoryList)
        {
            PopAvailableTerritories.add(new SelectOption(territory.Id, territory.Name));
        }
    }

    /* 
     ** operation: click the "Add" button on the Territory Popup.
     ** adds the selected territories into the left bar of the page.
     */
    public void addTerritories()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        String[] territoryIds = SelectedHidden.split(';');
        availableTerritoryIds.addAll(territoryIds);
        List<Territory__c> addingTerritories = [select Id, Name, Territory_Change_Box__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, New_Owner__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Current_Boundary__c, Current_Owner__c, Territory_Description__c from Territory__c where Id in :territoryIds];
        Territory = addingTerritories[0];
        tempTerritory.New_Owner__c = Territory.New_Owner__c;
        AvailableTerritories.addAll(addingTerritories);
        getAssignmentMap(territoryIds);
        getExceptionAccountMap(territoryIds); 
        Assignments = assignmentMap.get(Territory.Id);
        initPageProperties();
        totalResults = Assignments.size();
        totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
        getCurrentPageRecords();
        ExceptionAccounts = exceptionAccountMap.get(Territory.Id);
        AccountCriteria = accountCriteriaMap.get(Territory.Id);
        TerritoryMembers = territoryMemberMap.get(Territory.Id);
        IsShowAssignmentAndExceptionAccount = true;
    }

    /*
     ** operation : click "Create New" link
     ** creates a new territory.
     */
    public void createNewTerritory()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Territory = new Territory__c();
        Assignments = new List<Assignment_Detail__c>();
        ExceptionAccounts = new List<Account>();
        AccountCriteria = new List<AccountCriteria__c>();
        IsShowAssignmentAndExceptionAccount = false;
    }

    /*
     ** operation : click the specific territory in the left bar.
     ** gets the territory which will be updated, such as add new assignemtns and add exception accounts.
     */
    public void editTerritories()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Territory = AvailableTerritories.get(Index); 
        tempTerritory.New_Owner__c = Territory.New_Owner__c;
        
        if(!assignmentMap.containsKey(Territory.Id)) 
        {
            assignmentMap.put(Territory.Id, new List<Assignment_Detail__c>());
        }
        if(!exceptionAccountMap.containsKey(Territory.Id))
        {
            exceptionAccountMap.put(Territory.Id, new List<Account>());
        }
        Assignments = assignmentMap.get(Territory.Id);

        initPageProperties();
        totalResults = Assignments.size();
        totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
        getCurrentPageRecords();

        ExceptionAccounts = exceptionAccountMap.get(Territory.Id);
        AccountCriteria = accountCriteriaMap.get(Territory.Id);
        TerritoryMembers = territoryMemberMap.get(Territory.Id);
        IsShowAssignmentAndExceptionAccount = true;
    }
    
    /*
     ** Click "Save" button on Terriory Information section.
     ** It is used to upsert Territory. It also includes upsert the "Definition" Territory Owner under this territory.
     */
    public void saveTerritory()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Territory.Territory_Type__c = 'Standard';
        if(String.isNotBlank(Territory.Id))
        {
            updateTerritory();
        }
        else
        {
            insertTerritory();
        }
        tempTerritory.New_Owner__c = Territory.New_Owner__c;
        IsShowAssignmentAndExceptionAccount = true;
        if(!assignmentMap.containsKey(Territory.Id))
        {
            AvailableTerritories.add(Territory);
            assignmentMap.put(Territory.Id, new List<Assignment_Detail__c>());
            exceptionAccountMap.put(Territory.Id, new List<Account>());
            accountCriteriaMap.put(Territory.Id, new List<AccountCriteria__c>());
            territoryMemberMap.put(Territory.Id, new List<Territory_Member__c>());
            Assignments = assignmentMap.get(Territory.Id);

            initPageProperties();
            totalResults = Assignments.size();
            totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
            getCurrentPageRecords();

            ExceptionAccounts = exceptionAccountMap.get(Territory.Id);
            AccountCriteria = accountCriteriaMap.get(Territory.Id);
            TerritoryMembers = territoryMemberMap.get(Territory.Id);
        } 
             
    }

    //click "Create" button in Assignments section.
    public void createAssignment()
    {
        showPop(false, false, false, true, false, false, false, false, false);  
        NewAssignments.clear(); 
        AssignmentType = 'Type Assignments';
        AssignmentsCSV = '';
        for(Integer i = 0; i < 2; i++)
        {
            NewAssignments.add(new Assignment_Detail__c());
        }      
    }

    public void addMoreAssignments()
    {
        NewAssignments.add(new Assignment_Detail__c());
    }

    //save the created assignments.
    public void saveCreateAssignment()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        isShowNewAssignmentPop = false;
        constuctAssignmentList();
        populateBoundaryForAssignments(Assignments);
        try
        {
            upsert Assignments;
            totalResults = Assignments.size();
            totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
            pageNum = totalPage;
            getCurrentPageRecords();
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }
    } 

    //Click "Break Assignment" icon in Assignment section.
    public void breakAssignment()
    {
        showPop(false, false, false, false, false, true, false, false, false);
        Assignment = Assignments.get(assignmentIndex);
        BrokenAssignments.clear();
        for(Integer i = 0; i < 2; i++)
        {
            Assignment_Detail__c tempAssignment = new Assignment_Detail__c();
            tempAssignment.Country__c = Assignment.Country__c;
            tempAssignment.State__c = Assignment.State__c;
            BrokenAssignments.add(tempAssignment);
        }    
    }

    public void addBrokenAssignment()
    {
        Assignment_Detail__c tempAssignment = new Assignment_Detail__c();
        tempAssignment.Country__c = Assignment.Country__c;
        tempAssignment.State__c = Assignment.State__c;
        BrokenAssignments.add(tempAssignment);
    }

    public void deleteBrokenAssignment()
    {
        Integer assignmentIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        BrokenAssignments.remove(assignmentIndex);
    }

    //click "Save" button on Broken Assignment popup
    public void saveBrokenAssignments()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Assignments.remove(assignmentIndex);
        for(Assignment_Detail__c detail : BrokenAssignments)
        {
            Assignments.add(detail);
        }
        populateBoundaryForAssignments(Assignments);
        try
        {
            upsert Assignments; 
            delete [select Id from Assignment_Detail__c where Id = :Assignment.Id]; 
            totalResults = Assignments.size();
            totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
            pageNum = totalPage;
            getCurrentPageRecords();     
            AddTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }
    }

    //click "Edit Assignment" icon in Assignments section.
    public void editAssignment()
    {
        Assignment_Detail__c tempAssignment = currentPageAssignments.get(assignmentIndex);
        Assignment = new Assignment_Detail__c();
        Assignment.Country__c = tempAssignment.Country__c;
        Assignment.State__c = tempAssignment.State__c;
        Assignment.Postal_Start__c = tempAssignment.Postal_Start__c;
        Assignment.Postal_End__c = tempAssignment.Postal_End__c;       
        showPop(false, false, false, false, true, false, false, false, false);
    }

    //save the edited assignment
    public void saveEditAssignment()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Assignment_Detail__c assignmentDetail = currentPageAssignments.get(assignmentIndex);
        assignmentDetail.Country__c = Assignment.Country__c;
        assignmentDetail.State__c = Assignment.State__c;
        assignmentDetail.Postal_Start__c = Assignment.Postal_Start__c;
        assignmentDetail.Postal_End__c = Assignment.Postal_End__c;
        populateBoundaryForAssignments(Assignments);
        try
        {
            upsert Assignments;
            totalResults = Assignments.size();
            totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
            getCurrentPageRecords();
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }
    }

    //click "Delete Assignment" icon in Assignments section.
    public void deleteAssignment()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Assignment_Detail__c tempAssignment = Assignments.get(assignmentIndex);
        populateBoundaryForAssignments(Assignments);
        try
        {   
            upsert Assignments;       
            delete [select Id from Assignment_Detail__c where Id = :Assignments.get(assignmentIndex).Id];
            Assignments.remove(assignmentIndex); 
            totalResults = Assignments.size();
            totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
            if(pageNum > totalPage) pageNum = totalPage;
            getCurrentPageRecords(); 
            addTerritoryToChangedTerritories();
        }
        catch(Exception ex)
        {
        }
    } 
    
    public void saveDragAssignment()
    {
        Assignment_Detail__c tempAssignment = Assignments.get(assignmentIndex);
        populateBoundaryForAssignments(Assignments);
        deleteAssignmentForResourceTerritory();
        upsert Assignments;
        totalResults = Assignments.size();
        totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
        insertAssignmentForTargetTerritory(tempAssignment);
        updateTerritoryChangedTerritoriesForDrag();    
        getCurrentPageRecords();  
    }

    //click "Add Exception Account" button
    public void createExceptionAccount()
    {
        showPop(false, false, false, false, false, false, true, false, false);
        AccountList.clear();  
    }

    public void searchAccount()
    {
        AccountList.clear();
        Set<String> accountIds = new Set<String>();
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Exception_Account__c from ExceptionAccount2TerritoryBoundary__c where (Territory_Boundary__r.Status__c = 'Approved' and Territory_Boundary__r.Territory__r.Territory_Change_Box__c != null and Territory_Boundary__r.Territory__r.Territory_Change_Box__r.Job_Completion_Date_Time__c = null) or Territory_Boundary__r.Status__c = 'Submitted'];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : account2BoundaryList)
        {
            accountIds.add(accountToBoundary.Exception_Account__c);
        }
        List<String> addresses = TM_OrganizationSettings.getShippingOrBillingAddresses();
        if(addresses != null)
        {
            String queryString = constructQueryString(accountIds, addresses);
            List<Account> accts = (List<Account>)Database.query(queryString);
            for(Account acct : accts)
            {
                String country = String.valueOf(acct.get(addresses[0]));
                String state = String.valueOf(acct.get(addresses[1]));
                String postalCode = String.valueOf(acct.get(addresses[2]));
                String city = String.valueOf(acct.get(addresses[3]));
                AccountInfo info = new AccountInfo(acct.Id, acct.Name, acct.AccountNumber, acct.New_Territory__r.Name, country, state, city, postalCode);
                AccountList.add(info);
            }
        }
    }

    public void saveExceptionAccount()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Set<String> accountIds = new Set<String>();
        Set<String> changedTerritoryIds = new Set<String>();
        Set<String> effectiveTerritoryIds = new Set<String>();
        
        changedTerritoryIds.add(Territory.Id);
        List<Territory_Boundary__c> territoryBoundaries = getTerritoryBoundaryForExceptionAccount(Territory.Id);
        Set<String> selectedAccountIds = getSelectedAccountIds();
        Map<String, ExceptionAccount2TerritoryBoundary__c> accountBoundaryToAccountMap = getAccountBoundaryToAccountMap(territoryBoundaries);
        List<ExceptionAccount2TerritoryBoundary__c> accountToBoundaries = createAccountToBoundariesForCurrentTerritory(territoryBoundaries[0], accountBoundaryToAccountMap, accountIds, selectedAccountIds);
        List<ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaries = [select Id, Territory_Boundary__r.Territory__c, Territory_Boundary__r.Status__c, Territory_Boundary__r.IsEffective__c from ExceptionAccount2TerritoryBoundary__c where Exception_Account__c in :selectedAccountIds and Territory_Boundary__c in :territoryBoundaries];
        List<ExceptionAccount2TerritoryBoundary__c> delAccountToBoundaries = getDelAccountToBoundaries(exceptionAccount2TerritoryBoundaries, effectiveTerritoryIds, changedTerritoryIds);
        Set<String> territoryIdsWithoutIneffectiveBoundary = getTerritoryIdsWithoutIneffectiveBoundary(effectiveTerritoryIds);
        List<Account> accounts = changeAccountsTerritory(selectedAccountIds);
        try
        {
            update accounts;
            insert accountToBoundaries;
            delete delAccountToBoundaries;
            Map<String, List<Account>> territoryAccountMap = getAccountToTerritoryMap(territoryIdsWithoutIneffectiveBoundary, selectedAccountIds);
            if (!territoryAccountMap.isEmpty()) 
            {
                insertAccountToBoundariesForTerritory(territoryAccountMap);
            }   
            reconstructExceptionAccounts(selectedAccountIds, accountIds);
            reconstructAvailableTerritoriesAndChangedTerritories(changedTerritoryIds);
            List<String> territoryIds = new List<String>();
            for(String territoryId : changedTerritoryIds)
            {
                if(territoryId != Territory.Id)
                {
                    territoryIds.add(territoryId);
                }
            }
            getExceptionAccountMap(territoryIds);
         }
         catch(Exception ex)
         {
         }
    }

    //click "Del Exception Account" icon in Exception Accounts section.
    public void deleteExceptionAccount()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        List<Territory_Boundary__c> territoryBoundaries = getTerritoryBoundaryForExceptionAccount(Territory.Id);
        Map<String, ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaryMap = getExceptionAccount2TerritoryBoundaryMap(territoryBoundaries[0].Id);
        insertExceptionAccountList(territoryBoundaries[0].Id, exceptionAccount2TerritoryBoundaryMap);
        deleteExceptionAccountForCurrentTerritory(territoryBoundaries[0].Id);
        addTerritoryToChangedTerritories();
    }
    
    /*
     ** click "What If's" button in "modified Territories" section. 
     ** Because there might be intercrossed territories in the org. So we need to check which territory should an account matches. 
     ** Calculate Territory new fields.
     */
    public void calculateTerritoryFields()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        IsEnableAllButtons = false;
        IsDisableSaveAndSubmitButton = false;
        Set<String> territoryIds = new Set<String>();
        territoryIds.addAll(modifiedTerritoryIds);
        Map<String, String> alternateCountryMap = TM_TerritoryManagementHelper.getAlternateCountryMap();
        Map<String, String> alternateStateMap = TM_TerritoryManagementHelper.getAlternateStateMap();
        Set<String> territoryBoundaryIds = getTerritoryBoundaryIds(modifiedTerritoryIds, Change.Status__c);
        Map<String, List<Account>> exceptionAccountMap = getExceptionAccountMapForWhatIf(territoryBoundaryIds);
        Set<String> countries = constructCountries(territoryBoundaryIds, alternateCountryMap);    
        List<Assignment_Detail__c> assignments = [select Id, Country__c, Territory_Assignment__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Country__c in :countries and Territory_Assignment__r.Status__c = 'Approved' and Territory_Assignment__r.IsEffective__c = true and Territory_Assignment__r.Territory__c not in :territoryIds];
        for(Assignment_Detail__c detail : assignments)
        {
            territoryBoundaryIds.add(detail.Territory_Assignment__c);
            territoryIds.add(detail.Territory_Assignment__r.Territory__c);
        }
        Set<String> accountQueryFields = new Set<String>();
        Map<String, Territory__c> territoryMap = getTerritoryMap(territoryIds, accountQueryFields, territoryBoundaryIds);
        Map<String, Decimal> accountCountMap = new Map<String, Decimal>();
        Map<String, Decimal> openOppCountMap = new Map<String, Decimal>();
        Map<String, Decimal> contactCountMap = new Map<String, Decimal>();
        Map<String, Decimal> taskCountMap = new Map<String, Decimal>();
        Map<String, Decimal> eventCountMap = new Map<String, Decimal>();
        Map<String, Decimal> closedRevenueYTDMap = new Map<String, Decimal>();
        Map<String, Decimal> pipelineLT50Map = new Map<String, Decimal>();
        Map<String, Decimal> pipelineGT50Map = new Map<String, Decimal>();
        calculateTerritoryFieldsByExceptionAccount(exceptionAccountMap, accountCountMap, openOppCountMap, contactCountMap, taskCountMap, eventCountMap, pipelineLT50Map, pipelineGT50Map, closedRevenueYTDMap);
        Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        List<Assignment_Detail__c> details = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__c != null and Territory_Assignment__c in :territoryBoundaryIds];
        TM_TerritoryManagementHelper.constructAssignmentMap(details, territoryIds, alternateCountryMap, alternateStateMap, countryZipCodeAssignmentMap, countryStateAssignmentMap, countryAssignmentMap);
        List<String> addresses = TM_OrganizationSettings.getShippingOrBillingAddresses();
        if(addresses != null)
        {
            String namespace = TM_OrganizationSettings.Namespace;
            String queryString = 'select Id, Name, OwnerId, ' + addresses[0] + ', ' + addresses[1] + ', ' + addresses[2] + ', ' + namespace + '__No_Territory_Assignment__c, ' + namespace + '__Territory__c, ' + namespace + '__Number_of_Open_Opps__c, ' + namespace + '__Closed_Revenue_YTD__c, ' + namespace + '__Pipeline_LT_50__c, ' + namespace + '__Pipeline_GL_50__c';
            //String queryString = 'select Id, Name, ' + addresses[0] + ',' + addresses[1] + ',' + addresses[2] + ', No_Territory_Assignment__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_LT_50__c, Pipeline_GL_50__c'; 
            for(String queryField : accountQueryFields)
            {
                if(!queryString.contains(queryField))
                {
                    queryString += ', ' + queryField;
                }
            }
            queryString += ' from Account where ' + addresses[0] + ' in :countries and ' + namespace + '__No_Territory_Assignment__c = false and ' + namespace + '__Territory_Boundary__c = null';
            TM_CalculateTerritoryFieldsBatch b = new TM_CalculateTerritoryFieldsBatch(queryString, change.Name, modifiedTerritoryIds, addresses, countries, territoryMap, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap, accountCountMap, openOppCountMap, contactCountMap, taskCountMap, eventCountMap, pipelineLT50Map, pipelineGT50Map, closedRevenueYTDMap);
            Database.executeBatch(b, 20);
        }
    }
    
    /*
     **  Click remove button on Modified Territory List.
     */
    public void removeTerritory()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Territory__c territory = ChangedTerritories.get(RemovedIndex);
        if(String.isNotBlank(territory.Territory_Change_Box__c))
        {
            territory.Territory_Change_Box__c = null; 
            update territory;
        }
        ChangedTerritories.remove(RemovedIndex);
        modifiedTerritoryIds.remove(territory.Id);    
    }

    /*
     ** click "Save" button in "Modified Territories" section. Include all territories in the created Change Box.
     */
    public PageReference saveChangeBox()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        IsShowSavePop = '1';
        String status = Change.Status__c;
        List<Territory_Change_Box__c> changeBoxes = new List<Territory_Change_Box__c>();
        changeBoxes.add(Change);
        List<String> dates = EffectiveDate.split('/');
        Change.Effective_Date__c = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        updateChangeBox(changeBoxes, Change.Name, 'Definition', null, Change.Effective_Date__c, '', null, null);
        Change2.Name = Change.Name;
        String day = Change.Effective_Date__c.day() < 10 ? '0' + String.valueOf(Change.Effective_Date__c.day()) : String.valueOf(Change.Effective_Date__c.day());
        String month = Change.Effective_Date__c.month() < 10 ? '0' + String.valueOf(Change.Effective_Date__c.month()) : String.valueOf(Change.Effective_Date__c.month());
        String year = String.valueOf(Change.Effective_Date__c.year());
        EffectiveDate = month + '/' + day + '/' + year;
        populateChangeBoxForTerritories(modifiedTerritoryIds);
        if(status == 'Rejected')
        {
            updateTerritoryBoundariesAndOwners(Change.Id, 'Rejected', 'Definition', false, false);
        }
        return null;
    }

    /*
     ** click "Submit" button in "modified Territories" section. 
     */
    public PageReference submit()
    {
        IsShowSubmitPop = '1';
        //IsEnableAllButtons = false;
        //IsDisableSaveAndSubmitButton = true;
        Config = TM_OrganizationSettings.getTerritoryConfig();
        String useApprovalProcess = String.isNotBlank(Config.Use_Approval_Process__c) ? Config.Use_Approval_Process__c : '';
        String status = Change.Status__c == 'Rejected' ? 'Rejected' : 'Definition';
        String changeStatus = useApprovalProcess.toLowerCase() != 'yes' ? 'Approved' : 'Submitted';
        List<Territory_Change_Box__c> changeBoxes = new List<Territory_Change_Box__c>();
        changeBoxes.add(Change);
        List<String> dates = EffectiveDate.split('/');
        Change2.Effective_Date__c = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        String day = Change2.Effective_Date__c.day() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.day()) : String.valueOf(Change2.Effective_Date__c.day());
        String month = Change2.Effective_Date__c.month() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.month()) : String.valueOf(Change2.Effective_Date__c.month());
        String year = String.valueOf(Change2.Effective_Date__c.year());
        EffectiveDate = month + '/' + day + '/' + year;
        updateChangeBox(changeBoxes, Change2.Name, changeStatus, Date.today(), Change2.Effective_Date__c, '', Date.today(), UserInfo.getUserId());
        List<Territory_Change_Box__c> changeSets = [select Id, Name, Effective_Date__c, Submit_Date__c, SubmittedBy__c, SubmittedBy__r.Name, Approve_Date__c, Last_Comment__c, Status__c, Approver__c, Approver__r.Name, Approver__r.Email from Territory_Change_Box__c where Id = :Change.Id];
        TM_TerritoryManagementHelper.sendApprovalReqeust(changeSets);
        populateChangeBoxForTerritories(modifiedTerritoryIds);
        updateTerritoryBoundariesAndOwners(Change.Id, status, 'Submitted', false, false);
        if(status == 'Rejected')
        {
            updateTerritoryBoundariesAndOwners(Change.Id, 'Definition', 'Submitted', false, false);
        }
        if(useApprovalProcess.toLowerCase() != 'yes')
        {
            updateTerritoryOwnersAndBoundariesForApprovedChangeBox(Change.Id, 'Approved', 'Submitted', 'Approved', false, true);
            if(Change2.Effective_Date__c <= Date.today())
            {
                Set<String> changeBoxIds = new Set<String> { change.Id };
                TM_SubmitChangeBoxHelper.changeBoxIds = changeBoxIds;
                TM_SubmitChangeBoxHelper.executeTerritoryOwnerBatch(modifiedTerritoryIds);
                TM_SubmitChangeBoxHelper.executeTerritoryBoundaryBatch(modifiedTerritoryIds); 
            }
        }   
        showPop(false, false, false, false, false, false, false, false, false);
        resetRelatedVariables();
        IsShowAssignmentAndExceptionAccount = false;
        List<String> territoryIds = new List<String>();  
        return null;
    }

    public void checkAsisignmentWithSaveChangeBox()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Set<String> territoryNames = checkAssignmentAndExceptionSize();
        IsShowSavePop = territoryNames.size() > 0 ? '1' : '0';
        IsShowSubmitPop = '1';
        if(territoryNames.size() > 0)
        {
            alertMsgWithoutAssignments(territoryNames);
        }
    }

    public void checkAsisignmentWithSubmittedChangeBox()
    {
        showPop(false, false, false, false, false, false, false, false, false);
        Set<String> territoryNames = checkAssignmentAndExceptionSize();
        IsShowSubmitPop = territoryNames.size() > 0 ? '1' : '0';
        IsShowSavePop = '1';
        if(territoryNames.size() > 0)
        {
            alertMsgWithoutAssignments(territoryNames);
        }   
    }   
    
    public class AccountInfo
    {
        public Boolean IsChecked { get; set; }
        public String AccountId { get; set; }
        public String AccountNumber { get; set; }
        public String Name { get; set; }
        public String Territory { get; set; }
        public String Country { get; set; }
        public String State { get; set; }
        public String PostalCode { get; set; }
        public String City { get; set; }
        
        public AccountInfo() 
        { 
            this.IsChecked = false;
        }
        public AccountInfo(String accountId, String name, String accountNumber, String territory, String country, String state, String city, String postalCode) 
        {
            this.IsChecked = false;
            this.AccountId = accountId;
            this.AccountNumber = accountNumber;
            this.Name = name;
            this.Territory = territory;
            this.Country = country;
            this.State = state;
            this.City = city;
            this.PostalCode = postalCode;
        }       
    }

    private String constructQueryString(Set<String> accountIds, List<String> addresses)
    {
        String queryString = 'select Id, Name, AccountNumber, Territory__r.Name, New_Territory__r.Name, BillingCountry, BillingState, BillingCity, BillingPostalCode, ShippingCountry, ShippingPostalCode, ShippingState, ShippingCity from Account where Id not in :accountIds and No_Territory_Assignment__c = false ';
        if(String.isNotBlank(KeyWord) && KeyWord != 'Name')
        {
            queryString += ' And Name Like \'%' + String.escapeSingleQuotes(KeyWord) + '%\'';
        }
        if(String.isNotBlank(NumberKeyWord) && NumberKeyWord != 'Account Number')
        {
            queryString += ' And AccountNumber Like \'%' + String.escapeSingleQuotes(NumberKeyWord) + '%\'';
        }
        if(String.isNotBlank(CountryKeyWord) && CountryKeyWord != 'Account Country')
        {
            queryString += ' And ' + addresses[0] + ' Like \'%' + String.escapeSingleQuotes(CountryKeyWord) + '%\'';
        }
        if(String.isNotBlank(StateKeyWord) && StateKeyWord != 'Account State')
        {
            queryString += ' And ' + addresses[1] + ' Like \'%' + String.escapeSingleQuotes(StateKeyWord) + '%\'';
        }
        if(String.isNotBlank(CityKeyWord) && CityKeyWord != 'Account City')
        {
            queryString += ' And ' + addresses[3] + ' Like \'%' + String.escapeSingleQuotes(CityKeyWord) + '%\'';
        }
        queryString += ' order by Name limit 200';
        return queryString;
    }

    private void insertAssingnmentForTerritoryWithoutIneffectiveBoundaries(Map<String, Territory_Boundary__c> territoryBoundaryMap)
    {
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        Map<String, List<Assignment_Detail__c>> assignmentMap = new Map<String, List<Assignment_Detail__c>>();
        List<Assignment_Detail__c> detailList = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__r.IsEffective__c = true and Territory_Assignment__r.Territory__c in :territoryBoundaryMap.keySet()];
        for(Assignment_Detail__c detail : detailList){
            String terrId = detail.Territory_Assignment__r.Territory__c;
            if(!assignmentMap.containsKey(terrId)){
                assignmentMap.put(terrId, new List<Assignment_Detail__c>());
            }
            assignmentMap.get(terrId).add(detail);
        }

        for(String territoryId : assignmentMap.keySet())
        {
            List<Assignment_Detail__c> assignmentDetails = assignmentMap.get(territoryId);
            Territory_Boundary__c boundary = territoryBoundaryMap.get(territoryId);
            for(Assignment_Detail__c detail : assignmentDetails)
            {
                Assignment_Detail__c assignmentDetail = new Assignment_Detail__c(Territory_Assignment__c = boundary.Id, Country__c = detail.Country__c, State__c = detail.State__c, Postal_Start__c = detail.Postal_Start__c, Postal_End__c = detail.Postal_End__c);
                assignments.add(assignmentDetail);
            }
        }
        if(assignments.size() > 0)
        {
            insert assignments;
        }
    }

    private void reconstructAvailableTerritoriesAndChangedTerritories(Set<String> changedTerritoryIds)
    {
        List<Territory__c> territoryList = [select Id, Name, Territory_Change_Box__c, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Current_Owner__r.IsActive, Current_Owner__r.Name, New_Owner__c, New_Owner__r.Name, Territory_Description__c from Territory__c where Id in :changedTerritoryIds];
        for(Territory__c tempTerritory : territoryList)
        {
            if(!availableTerritoryIds.contains(tempTerritory.Id))
            {
                AvailableTerritories.add(tempTerritory);
                availableTerritoryIds.add(tempTerritory.Id);
            }
            if(!modifiedTerritoryIds.contains(tempTerritory.Id))
            {
                ChangedTerritories.add(tempTerritory);  
                modifiedTerritoryIds.add(tempTerritory.Id);
            }
        }
    }

    private void reconstructExceptionAccounts(Set<String> selectedAccountIds, Set<String> accountIds)
    {   
        Set<String> addToExceptionAccountIds = new Set<String>();
        for(String selectedAccountId : selectedAccountIds)
        {
            if(!accountIds.contains(selectedAccountId))
            {
                addToExceptionAccountIds.add(selectedAccountId);
            }
        } 
        ExceptionAccounts.addAll([select Id, Name, New_Territory__c, New_Territory__r.Name, Territory__c, Territory__r.Name, BillingCountry, BillingState, BillingPostalCode, ShippingCountry, ShippingState, ShippingPostalCode from Account where Id in :addToExceptionAccountIds]);
    }

    private void insertAccountToBoundariesForTerritory(Map<String, List<Account>> territoryAccountMap)
    {
        Map<String, Territory_Boundary__c> tempTerritoryBoundaryMap = new Map<String, Territory_Boundary__c>();
        List<ExceptionAccount2TerritoryBoundary__c> tempExceptionAccount2TerritoryBoundaries = new List<ExceptionAccount2TerritoryBoundary__c>();
        for (String territoryId : territoryAccountMap.keySet()) 
        {
            Territory_Boundary__c tempTerritoryBoundary = new Territory_Boundary__c(Territory__c = territoryId, Status__c = 'Definition');
            tempTerritoryBoundaryMap.put(territoryId, tempTerritoryBoundary);
        }
        insert tempTerritoryBoundaryMap.values();
        
        for (String territoryId : territoryAccountMap.keySet())
        {
            for (Account account : territoryAccountMap.get(territoryId)) 
            {
                ExceptionAccount2TerritoryBoundary__c accountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = account.Id, Territory_Boundary__c = tempTerritoryBoundaryMap.get(territoryId).Id);
                tempExceptionAccount2TerritoryBoundaries.add(accountToBoundary);    
            }
        }
        if (tempExceptionAccount2TerritoryBoundaries.size() > 0) 
        {
            insert tempExceptionAccount2TerritoryBoundaries;    
        }

        insertAssingnmentForTerritoryWithoutIneffectiveBoundaries(tempTerritoryBoundaryMap);
    }

    private Map<String, List<Account>> getAccountToTerritoryMap(Set<String> territoryIds, Set<String> accountIds)
    {
        Map<String, List<Account>> accountToBoundaryMap = new Map<String, List<Account>>();
        for(String territoryId : territoryIds)
        {
            accountToBoundaryMap.put(territoryId, new List<Account>());
        }
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Territory_Boundary__c, Territory_Boundary__r.Territory__c, Exception_Account__c, Exception_Account__r.Name, Exception_Account__r.Territory__r.Name, Exception_Account__r.BillingCountry,
            Exception_Account__r.BillingState, Exception_Account__r.BillingPostalCode, Exception_Account__r.ShippingCountry, Exception_Account__r.ShippingState, Exception_Account__r.ShippingPostalCode from ExceptionAccount2TerritoryBoundary__c where Exception_Account__c not in :accountIds and Territory_Boundary__r.Territory__c in :territoryIds and Territory_Boundary__r.IsEffective__c = true];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : account2BoundaryList)
        {
            accountToBoundaryMap.get(accountToBoundary.Territory_Boundary__r.Territory__c).add(accountToBoundary.Exception_Account__r);
        }       
        return accountToBoundaryMap;
    }

    private List<Account> changeAccountsTerritory(Set<String> selectedAccountIds)
    {
        List<Account> accounts = new List<Account>();
        List<Account> acctList = [select Id, Name, New_Territory__c from Account where Id in :selectedAccountIds];
        for(Account acct : acctList)
        {
            acct.New_Territory__c = Territory.Id;
            accounts.add(acct);
        }
        return accounts;
    }

    private Set<String> getTerritoryIdsWithoutIneffectiveBoundary(Set<String> effectiveTerritoryIds)
    {
        Set<String> territoryIdsWithoutIneffectiveBoundary = new Set<String>();
        List<Territory__c> territoryList = [select Id, (select Id from Territory_Assignments__r where IsEffective__c = false and (Status__c = 'Definition' or Status__c = 'Rejected')) from Territory__c where Id in :effectiveTerritoryIds];
        for(Territory__c territory : territoryList)
        {
            if(territory.Territory_Assignments__r.size() == 0)
            {
                territoryIdsWithoutIneffectiveBoundary.add(territory.Id);
            }
        } 
        return territoryIdsWithoutIneffectiveBoundary;
    }

    private List<ExceptionAccount2TerritoryBoundary__c> getDelAccountToBoundaries(List<ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaries, Set<String> effectiveTerritoryIds, Set<String> changedTerritoryIds)
    {
        List<ExceptionAccount2TerritoryBoundary__c> delAccountToBoundaries = new List<ExceptionAccount2TerritoryBoundary__c>();
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : exceptionAccount2TerritoryBoundaries)
        {
            if(!accountToBoundary.Territory_Boundary__r.IsEffective__c)
            {
                delAccountToBoundaries.add(accountToBoundary);
                changedTerritoryIds.add(accountToBoundary.Territory_Boundary__r.Territory__c);
            }
            else
            {
                effectiveTerritoryIds.add(accountToBoundary.Territory_Boundary__r.Territory__c);
                changedTerritoryIds.add(accountToBoundary.Territory_Boundary__r.Territory__c);
            }
            
        }
        return delAccountToBoundaries;
    }

    private List<ExceptionAccount2TerritoryBoundary__c> createAccountToBoundariesForCurrentTerritory(Territory_Boundary__c territoryBoundary, Map<String, ExceptionAccount2TerritoryBoundary__c> accountBoundaryToAccountMap, Set<String> accountIds, Set<String> selectedAccountIds)
    {
        List<ExceptionAccount2TerritoryBoundary__c> accountToBoundaries = new List<ExceptionAccount2TerritoryBoundary__c>();
        for(Account account : ExceptionAccounts)
        {
            accountIds.add(account.Id);
            if(accountBoundaryToAccountMap.get(account.Id) == null)
            {
                ExceptionAccount2TerritoryBoundary__c accountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = account.Id, Territory_Boundary__c = territoryBoundary.Id);
                accountToBoundaries.add(accountToBoundary);
            }
        }
        
        for(String accountId : selectedAccountIds)
        {
            if(!accountIds.contains(accountId))
            {
                accountToBoundaries.add(new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = accountId, Territory_Boundary__c = territoryBoundary.Id));
            }
        }
        
        return accountToBoundaries;
    }

    private Set<String> getSelectedAccountIds()
    {
        Set<String> selectedAccountIds = new Set<String>();
        for(AccountInfo acctInfo : AccountList)
        {
            if(acctInfo.IsChecked)
            {
                selectedAccountIds.add(acctInfo.AccountId);
            }
        }
        return selectedAccountIds;
    }

    private Map<String, ExceptionAccount2TerritoryBoundary__c> getAccountBoundaryToAccountMap(List<Territory_Boundary__c> territoryBoundaries)
    {
        Map<String, ExceptionAccount2TerritoryBoundary__c> accountBoundaryToAccountMap = new Map<String, ExceptionAccount2TerritoryBoundary__c>();
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Exception_Account__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :territoryBoundaries];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : account2BoundaryList)
        {
            accountBoundaryToAccountMap.put(accountToBoundary.Exception_Account__c, accountToBoundary);
        }
        return accountBoundaryToAccountMap;
    }
    
    private List<Territory_Owner__c> getTerritoryOwners(String changeBoxId, String status, String targetStatus, Boolean IsEffective, Boolean targetEffective)
    {
        List<Territory_Owner__c > owners = new List<Territory_Owner__c>();
        List<Territory__c> territoryList = [select Id, Name, Effective_Date__c, (select Id, Status__c, IsEffective__c from Territory_Owners__r where Status__c = :status and IsEffective__c = :isEffective order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c =:changeBoxId];
        for(Territory__c territory : territoryList)
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
    
    private List<Territory_Boundary__c> getTerritoryBoundaries(String changeBoxId, String status, String targetStatus, Boolean isEffective, Boolean targetEffective)
    {
        List<Territory_Boundary__c> boundaries = new List<Territory_Boundary__c>();
        List<Territory__c> territoryList = [select Id, Name, (select Id, Status__c from Territory_Assignments__r where Status__c = :status and IsEffective__c = :isEffective order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c = :changeBoxId];
        for(Territory__c territory : territoryList)
        {
            for(Territory_Boundary__c boundary : territory.Territory_Assignments__r)
            {
                boundary.IsEffective__c = targetEffective;
                boundary.Status__c = targetStatus;
                boundaries.add(boundary);
            }
        }
        return boundaries;
    }
    
    private void deactivateTerritoryOwnersAndBoundaries(String changeBoxId, Map<String, Territory_Boundary__c> boundaryMap, Map<String, Territory_Owner__c> ownerMap, String targetStatus)
    {
        List<Territory__c> territoryList = [select Id, (select Id, IsEffective__c, Status__c from Territory_Assignments__r where IsEffective__c = true order by LastModifiedDate desc limit 1), (select Id, Status__c, IsEffective__c from Territory_Owners__r where IsEffective__c = true order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c = :changeBoxId];
        for(Territory__c territory : territoryList)
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
    
    private Set<String> checkAssignmentAndExceptionSize()
    {
        Set<String> territoryNames = new Set<String>();
        Set<String> territoryIds = new Set<String>();
        for(String territoryId : modifiedTerritoryIds)
        {    
            if(!((assignmentMap.containsKey(territoryId) && assignmentMap.get(territoryId).size() > 0) || (exceptionAccountMap.containsKey(territoryId) && exceptionAccountMap.get(territoryId).size() > 0)))
            {
                territoryIds.add(territoryId);
            }
        }
        List<Territory__c> territoryList = [select Id, Name, IsNewCreated__c from Territory__c where Id in :territoryIds];
        for(Territory__c territory : territoryList)
        {
            if(territory.IsNewCreated__c)
            {
                territoryNames.add(territory.Name);
            }    
        }
        return territoryNames;
    }
    
    private void updateTerritoryOwnersAndBoundariesForApprovedChangeBox(String changeBoxId, String deactivateStatus, String status, String targetStatus, Boolean IsEffective, Boolean targetEffective)
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
    
    private void updateTerritoryBoundariesAndOwners(String changeBoxId, String status, String targetStatus, Boolean isEffective, Boolean targetEffective)
    {
        List<Territory_Boundary__c> boundaries = getTerritoryBoundaries(changeBoxId, status, targetStatus, isEffective, targetEffective);
        List<Territory_Owner__c> owners = getTerritoryOwners(changeBoxId, status, targetStatus, isEffective, targetEffective);
        if(boundaries.size() > 0)
        {
            update boundaries;
        }
        if(owners.size() > 0)
        {
            update owners;
        }
    }
    
    private void populateChangeBoxForTerritories(Set<String> modifiedTerritoryIds)
    {
        List<Territory__c> territories = new List<Territory__c>();
        List<Territory__c> territoryList = [select Id, Territory_Change_Box__c, IsNewCreated__c from Territory__c where Id in :modifiedTerritoryIds];
        for(Territory__c territory : territoryList)
        {
            if(territory.Territory_Change_Box__c != Change.Id)
            {
                territory.Territory_Change_Box__c = Change.Id;
                territory.IsNewCreated__c = false;
                territories.add(territory);
            }
        }
        if(territories.size() > 0)
        {
            update territories;
        } 
    }
    
    private void updateChangeBox(List<Territory_Change_Box__c> changes, String name, String status, Date approveDate, Date effectiveDate, String lastComment, Date submitDate, String submittedBy)
    {
        for(Territory_Change_Box__c change : changes)
        {
            change.Name = name;
            change.Approve_Date__c = approveDate;
            change.Effective_Date__c = effectiveDate;
            change.Last_Comment__c = lastComment;
            change.Status__c = status;
            change.Submit_Date__c = submitDate;
            change.SubmittedBy__c = submittedBy;
        }
        upsert changes;
    }
    
    private Set<String> constructCountries(Set<String> territoryBoundaryIds, Map<String, String> alternateCountryMap)
    {
        Set<String> countries = new Set<String>();
        List<Assignment_Detail__c> detailList = [select Id, Country__c from Assignment_Detail__c where Territory_Assignment__c in :territoryBoundaryIds];
        for(Assignment_Detail__c detail : detailList)
        {
            if(String.isNotBlank(detail.Country__c))
            {
                String country = detail.Country__c.toLowerCase();
                countries.add(country);
                if(alternateCountryMap.containsKey(country) && String.isNotBlank(alternateCountryMap.get(country)))
                {
                    countries.add(alternateCountryMap.get(country));
                }
            }
        }
        return countries;
    }
    
    private void calculateTerritoryFieldsByExceptionAccount(Map<String, List<Account>> exceptionAccountMap, Map<String, Decimal> accountCountMap, Map<String, Decimal> openOppCountMap, Map<String, Decimal> contactCountMap, Map<String, Decimal> taskCountMap, Map<String, Decimal> eventCountMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map, Map<String, Decimal> closedRevenueYTDMap)
    {
        for(String territoryId : exceptionAccountMap.keySet())
        {
            List<Account> accts = exceptionAccountMap.get(territoryId);
            Integer accountCount = exceptionAccountMap.get(territoryId).size();
            accountCountMap.put(territoryId, accountCount);
            Map<String, Account> accountMap = new Map<String, Account>();
            Decimal closedRevenue = 0;
            Decimal pipelineGT50Revenue = 0;
            Decimal pipelineLT50Revenue = 0;
            for(Account acct : accts)
            {
                acct.Territory__c = territoryId;
                accountMap.put(acct.Id, acct);
                closedRevenue += acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
                pipelineGT50Revenue += acct.Pipeline_GL_50__c;
                pipelineLT50Revenue += acct.Pipeline_LT_50__c;
            }
            closedRevenueYTDMap.put(territoryId, closedRevenue);
            pipelineLT50Map.put(territoryId, pipelineLT50Revenue);
            pipelineGT50Map.put(territoryId, pipelineGT50Revenue);
            TM_TerritoryManagementHelper.sumupNumberOfContactsForTerritories(accountMap, contactCountMap);
            TM_TerritoryManagementHelper.sumupNumberOfOpportunitiesForTerritories(accountMap, openOppCountMap);
            TM_TerritoryManagementHelper.sumupNumberOfEventsForTerritories(accountMap,eventCountMap);
            TM_TerritoryManagementHelper.sumupNumberOfTasksForTerritories(accountMap, taskCountMap);  
        }
    }
    
    private Map<String, List<Account>> getExceptionAccountMapForWhatIf(Set<String> territoryBoundaryIds)
    {
        Map<String, List<Account>> exceptionAccountMap = new Map<String, List<Account>>();
        List<ExceptionAccount2TerritoryBoundary__c> accountToBoundaryList = [select Id, Exception_Account__c, Exception_Account__r.Id, Exception_Account__r.Number_of_Open_Opps__c, Exception_Account__r.Closed_Revenue_YTD__c, Exception_Account__r.Pipeline_LT_50__c, Exception_Account__r.Pipeline_GL_50__c, Territory_Boundary__c, Territory_Boundary__r.Territory__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :territoryBoundaryIds];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : accountToBoundaryList)
        {
            String territoryId = accountToBoundary.Territory_Boundary__r.Territory__c;
            if(!exceptionAccountMap.containsKey(territoryId))
            {
                exceptionAccountMap.put(territoryId, new List<Account>());
            }
            exceptionAccountMap.get(territoryId).add(accountToBoundary.Exception_Account__r);
        }
        return exceptionAccountMap;
    }
    
    private Map<String, Territory__c> getTerritoryMap(Set<String> territoryIds, Set<String> accountQueryFields, Set<String> boundaryIds)
    {
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
        String status = Change.Status__c == 'Rejected' ? 'Rejected' : 'Definition';
        List<Territory__c> territoryList = [select Id, Name, Current_Owner__c, Territory_Change_Box__c, Territory_Change_Box__r.Name, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, (select Id, Field__c, Label__c, Operator__c, Value__c, IsMultiple__c, IsDate__c from AccountCriteria__r where Territory_Boundary__c in :boundaryIds) from Territory__c where Id in :territoryIds];
        for(Territory__c territory : territoryList)
        {
            territoryMap.put(territory.Id, territory);
            for(AccountCriteria__c criteria : territory.AccountCriteria__r)
            {
                accountQueryFields.add(criteria.Field__c);
            }
        }
        return territoryMap;
    }
    
    private Set<String> getTerritoryBoundaryIds(Set<String> territoryIds, String status)
    {
        Set<String> territoryBoundaryIds = new Set<String>();
        List<Territory__c> territoryList = [select Id, (select Id, IsEffective__c, Territory__c, Territory__r.Current_Boundary__c from Territory_Assignments__r where Status__c = :status and IsEffective__c = false order by LastModifiedDate desc limit 1) from Territory__c where Id in :territoryIds];
        for(Territory__c territory : territoryList)
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                territoryBoundaryIds.add(territory.Territory_Assignments__r[0].Id);
            }
        }
        return territoryBoundaryIds;
    }


    private void alertMsgWithoutAssignments(Set<String> territoryNames)
    {
        String msg = 'Before saving or submitting a territory change set you must modify at least one territory. This includes adding/removing territory assignments or adding/removing exception accounts.';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,  '<script type="text/javascript">$(".message.infoM3").remove();$("#saveAlertMsg").find(".warningMsg").html("'+ msg +'");$("#saveAlertMsg").css("display", "block");</script>'));
    }

    private void updateTerritoryChangedTerritoriesForDrag()
    {
        List<Territory__c> tempTerritories = new List<Territory__c>();
        Territory__c tempTerritory = [select Id, Name, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Territory_Type__c, Current_Boundary__c, Current_Owner__c, New_Owner__c, Territory_Description__c, Territory_Change_Box__c from Territory__c where Id = :TerritoryId];
        tempTerritories.add(Territory);
        tempTerritories.add(tempTerritory);
        for(Territory__c territory : tempTerritories)
        {
            if(!modifiedTerritoryIds.contains(territory.Id))
            {
                ChangedTerritories.add(territory);
                modifiedTerritoryIds.add(territory.Id);
            }
        } 
    }

    private Territory_Boundary__c getTerritoryBoundaryForTerritoryMembers(String territoryId){
        String status = Change.Status__c == 'Rejected' && tempModifiedTerritoryIds.contains(Territory.Id) ? 'Rejected' : 'Definition';
        Territory_Boundary__c territoryBoundary = new Territory_Boundary__c(Territory__c = territoryId, Status__c = 'Definition');
        List<Territory_Boundary__c> territoryBoundaries = [select Id, IsEffective__c from Territory_Boundary__c where Territory__c = :territoryId and IsEffective__c = false and Status__c = :status order by LastModifiedDate desc limit 1];
        if(territoryBoundaries != null && territoryBoundaries.size() > 0)
        {
            territoryBoundary = territoryBoundaries[0];
        }
        else
        {
            insert territoryBoundary;
            insertAssignmentForTerritory(territoryBoundary.Id);
            insertExceptionAccountForTerritory(territoryBoundary.Id, exceptionAccountMap.get(territoryId));
            insertAccountCriteriaForTerritory(territoryBoundary.Id);
        }
        return territoryBoundary;
    }

    private Territory_Boundary__c getTerritoryBoundaryForAccountCriteria(String territoryId)
    {
        String status = Change.Status__c == 'Rejected' && tempModifiedTerritoryIds.contains(Territory.Id) ? 'Rejected' : 'Definition';
        Territory_Boundary__c territoryBoundary = new Territory_Boundary__c(Territory__c = territoryId, Status__c = 'Definition');
        List<Territory_Boundary__c> territoryBoundaries = [select Id, IsEffective__c from Territory_Boundary__c where Territory__c = :territoryId and IsEffective__c = false and Status__c = :status order by LastModifiedDate desc limit 1];
        if(territoryBoundaries != null && territoryBoundaries.size() > 0)
        {
            territoryBoundary = territoryBoundaries[0];
        }
        else
        {
            insert territoryBoundary;
            insertAssignmentForTerritory(territoryBoundary.Id);
            insertExceptionAccountForTerritory(territoryBoundary.Id, exceptionAccountMap.get(territoryId));
            insertTerritoryMembersForTerritory(territoryBoundary.Id);
        }
        return territoryBoundary;
    }
    
    private Territory_Boundary__c getTerritoryBoundary(String territoryId)
    {
        String status = Change.Status__c == 'Rejected' && tempModifiedTerritoryIds.contains(Territory.Id) ? 'Rejected' : 'Definition';
        Territory_Boundary__c territoryBoundary = new Territory_Boundary__c(Territory__c = territoryId, Status__c = 'Definition');
        List<Territory_Boundary__c> territoryBoundaries = [select Id, IsEffective__c from Territory_Boundary__c where Territory__c = :territoryId and IsEffective__c = false and Status__c = :status order by LastModifiedDate desc limit 1];
        if(territoryBoundaries != null && territoryBoundaries.size() > 0)
        {
            territoryBoundary = territoryBoundaries[0];
        }
        else
        {
            insert territoryBoundary;
            insertAccountCriteriaForTerritory(territoryBoundary.Id);
            insertExceptionAccountForTerritory(territoryBoundary.Id, exceptionAccountMap.get(territoryId));
            insertTerritoryMembersForTerritory(territoryBoundary.Id);
        }
        return territoryBoundary;
    }

    private void insertAssignmentForTargetTerritory(Assignment_Detail__c tempAssignment)
    {
        Territory_Boundary__c tempTerritoryBoundary = getTerritoryBoundary(TerritoryId);
        List<Assignment_Detail__c> assignments = new List<Assignment_Detail__c>();
        for(Assignment_Detail__c assignment : assignmentMap.get(TerritoryId))
        {
            assignment.Territory_Assignment__c = tempTerritoryBoundary.Id;
            assignments.add(assignment);
        }
        Assignment_Detail__c tempTerritoryAssignment = new Assignment_Detail__c();
        tempTerritoryAssignment.Territory_Assignment__c = tempTerritoryBoundary.Id;
        tempTerritoryAssignment.Country__c = tempAssignment.Country__c;
        tempTerritoryAssignment.State__c = tempAssignment.State__c;
        tempTerritoryAssignment.Postal_Start__c = tempAssignment.Postal_Start__c;
        tempTerritoryAssignment.Postal_End__c = tempAssignment.Postal_End__c;
        assignments.add(tempTerritoryAssignment);
        try
        {
            upsert assignments;
            assignmentMap.get(TerritoryId).add(tempTerritoryAssignment);
        }
        catch(Exception ex)
        {
        }   
    }

    private void deleteAssignmentForResourceTerritory()
    {
        delete [select Id from Assignment_Detail__c where Id = :Assignments.get(assignmentIndex).Id];
        Assignments.remove(assignmentIndex);
    }

    private void deleteExceptionAccountForCurrentTerritory(String territoryBoundaryId)
    {
        Account acct = ExceptionAccounts.get(ExceptionAccountIndex);
        acct.New_Territory__c = null;
        update acct;
        delete [select Id from ExceptionAccount2TerritoryBoundary__c where Exception_Account__c = :acct.Id and Territory_Boundary__c = :territoryBoundaryId];
        ExceptionAccounts.remove(ExceptionAccountIndex);
    }

    private void insertExceptionAccountList(String territoryBoundaryId, Map<String, ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaryMap)
    {
        List<ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaries = new List<ExceptionAccount2TerritoryBoundary__c>();
        for(Account acct : ExceptionAccounts)
        {
            if(!exceptionAccount2TerritoryBoundaryMap.containsKey(acct.Id))
            {
                exceptionAccount2TerritoryBoundaries.add(new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = acct.Id, Territory_Boundary__c = territoryBoundaryId));
            }
        }
        if (exceptionAccount2TerritoryBoundaries.size() > 0) 
        {
            insert exceptionAccount2TerritoryBoundaries;
        }   
    }

    private Map<String, ExceptionAccount2TerritoryBoundary__c> getExceptionAccount2TerritoryBoundaryMap(String territoryBoundaryId)
    {
        Map<String, ExceptionAccount2TerritoryBoundary__c> exceptionAccount2TerritoryBoundaryMap = new Map<String, ExceptionAccount2TerritoryBoundary__c>();
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Exception_Account__c, Territory_Boundary__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c = :territoryBoundaryId and Exception_Account__c in :ExceptionAccounts];
        for(ExceptionAccount2TerritoryBoundary__c exceptionAccount2TerritoryBoundary : account2BoundaryList)
        {
            if(!exceptionAccount2TerritoryBoundaryMap.containsKey(exceptionAccount2TerritoryBoundary.Exception_Account__c))
            {
                exceptionAccount2TerritoryBoundaryMap.put(exceptionAccount2TerritoryBoundary.Exception_Account__c, exceptionAccount2TerritoryBoundary);
            }
        }
        return exceptionAccount2TerritoryBoundaryMap;
    }

    private void insertTerritoryMembersForTerritory(String territoryBoundaryId){
        for(Territory_Member__c member : TerritoryMembers){
            if(member.Territory_Boundary__c != territoryBoundaryId){
                member.Territory_Boundary__c = territoryBoundaryId;
                member.Territory__c = Territory.Id;
            }
        }
        upsert TerritoryMembers;
    }
    
    private void insertAssignmentForTerritory(String territoryBoundaryId)
    {
        for(Assignment_Detail__c detail : Assignments)
        {
            if(detail.Territory_Assignment__c != territoryBoundaryId)
            {
                detail.Territory_Assignment__c = territoryBoundaryId;
            }   
        }
        upsert Assignments;
    }

    private List<Territory_Boundary__c> getTerritoryBoundaryForExceptionAccount(String territoryId)
    {
        List<Territory_Boundary__c> boundaries = new List<Territory_Boundary__c>();
        String status = Change.Status__c == 'Rejected' && tempModifiedTerritoryIds.contains(Territory.Id) ? 'Rejected' : 'Definition';
        List<Territory_Boundary__c> territoryBoundaries = [select Id, IsEffective__c from Territory_Boundary__c where Territory__c = :territoryId and IsEffective__c = false and Status__c = :status order by LastModifiedDate desc limit 1];
        if(territoryBoundaries != null && territoryBoundaries.size() > 0)
        {
            boundaries.add(territoryBoundaries[0]);
        }
        else
        {
            Territory_Boundary__c territoryBoundary = new Territory_Boundary__c(Territory__c = territoryId, Status__c = 'Definition');
            insert territoryBoundary;
            insertAssignmentForTerritory(territoryBoundary.Id);
            insertAccountCriteriaForTerritory(territoryBoundary.Id);
            insertTerritoryMembersForTerritory(territoryBoundary.Id);
            boundaries.add(territoryBoundary);
        }
        return boundaries;
    }

    private void addTerritoryToChangedTerritories()
    {
        if(!modifiedTerritoryIds.contains(Territory.Id))
        {
            ChangedTerritories.add(Territory);
            modifiedTerritoryIds.add(Territory.Id);
        }
    }

    private void insertAccountCriteriaForTerritory(String territoryBoundaryId)
    {
        // Updated by Eric
        // Start
        if(AccountCriteria == null)
        {
            AccountCriteria = new List<AccountCriteria__c>();
        }
        // End
        for(AccountCriteria__c criteria : AccountCriteria)
        {
            if(criteria.Territory_Boundary__c != territoryBoundaryId)
            {
                criteria.Territory_Boundary__c = territoryBoundaryId;
                criteria.Territory__c = Territory.Id;
            }
        }
        upsert AccountCriteria;
    }

    private void insertExceptionAccountForTerritory(String territoryBoundaryId, List<Account> accts)
    {
        List<ExceptionAccount2TerritoryBoundary__c> accountToBoundaries = new List<exceptionAccount2TerritoryBoundary__c>();
        for(Account acct : accts)
        {
            ExceptionAccount2TerritoryBoundary__c accountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = acct.Id, Territory_Boundary__c = territoryBoundaryId);
            accountToBoundaries.add(accountToBoundary);
        }
        insert accountToBoundaries;
    }

    private void populateBoundaryForAccountCriteria(List<AccountCriteria__c> accountCriterias)
    {
        Territory_Boundary__c boundary = getTerritoryBoundaryForAccountCriteria(Territory.Id);
        for(AccountCriteria__c criteria : accountCriterias)
        {
            criteria.Territory_Boundary__c = boundary.Id;
            criteria.Territory__c = Territory.Id;
        }
    }

    private void populateBoundaryForTerritoryMembers(List<Territory_Member__c> members){
        Territory_Boundary__c boundary = getTerritoryBoundaryForTerritoryMembers(Territory.Id);
        for(Territory_Member__c member : TerritoryMembers){
            member.Territory_Boundary__c = boundary.Id;
            member.Territory__c = Territory.Id;
        }
    }

    private void populateBoundaryForAssignments(List<Assignment_Detail__c> assignments)
    {
        Territory_Boundary__c boundary = getTerritoryBoundary(Territory.Id);  
        for(Assignment_Detail__c detail : assignments)
        {
            detail.Territory_Assignment__c = boundary.Id;
        }
    }

    private void constructAccountCriteriaList()
    {
        for(AccountCriteria__c criteria : NewCriteria)
        {
            if(criteria.Field__c != null && criteria.Operator__c != null)
            {
                Boolean isExisted = false;
                for(AccountCriteria__c aCriteria : AccountCriteria)
                {
                    if(aCriteria.Field__c == criteria.Field__c && aCriteria.Operator__c == criteria.Operator__c)
                    {
                        isExisted = true;
                        aCriteria.Operator__c = criteria.Operator__c;
                        aCriteria.Value__c = criteria.Value__c;
                        aCriteria.Label__c = fieldNameToLabelMap.get(criteria.Field__c);
                        break;
                    }
                }
                if(!isExisted)
                {
                    criteria.Label__c = fieldNameToLabelMap.get(criteria.Field__c);
                    AccountCriteria.add(criteria);
                }
            }    
        }
    }

    private void constructTerritoryMemberList(){
        for(Territory_Member__c member : NewTerritoryMembers){
            Boolean isExisted = false;
            for(Territory_Member__c tMember : TerritoryMembers){
                if(member.Territory_Member__c == tMember.Territory_Member__c){
                    isExisted = false;
                    tMember.Account_Access__c = member.Account_Access__c;
                    tMember.Opportunity_Access__c = member.Opportunity_Access__c;
                    break;
                }
            }
            if(!isExisted && member.Territory_Member__c != null){
                TerritoryMembers.add(member);
            }
        }
    }

    private void constuctAssignmentList()
    {
        if(AssignmentType == 'Paste Assignments')
        {
            List<Assignment_Detail__c> csvAssignments = analyseCSVString(AssignmentsCSV);
            Assignments.addAll(csvAssignments);
        }
        else
        {
            for(Assignment_Detail__c detail : NewAssignments)
            {    
                if(!(String.isBlank(detail.Country__c) && String.isBlank(detail.State__c) && String.isBlank(detail.Postal_Start__c) && String.isBlank(detail.Postal_End__c)))
                {
                    Assignments.add(detail);
                }
            }
        }
    }

    private void insertTerritory()
    {
        try
        {
            Territory.Current_Owner__c = Territory.New_Owner__c;
            insert Territory;
            Territory = [select Id, Name, Territory_Change_Box__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Territory_Description__c, Current_Owner__c, New_Owner__c from Territory__c where Id = :Territory.Id];
            availableTerritoryIds.add(Territory.Id);
            if(Territory.New_Owner__c != null)
            {
                upsertTerritoryOwner();
                reconstructChangedTerritories();
            }  
                     
        }
        catch(Exception ex)
        {
        }
    }

    private void updateTerritory()
    {
        try
        {
            update Territory;
            Territory = [select Id, Name, Territory_Change_Box__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Territory_Description__c, Current_Owner__c, New_Owner__c from Territory__c where Id = :Territory.Id];
            AvailableTerritories.set(Index, Territory);
            if(Territory.New_Owner__c != tempTerritory.New_Owner__c)
            {
                upsertTerritoryOwner();
                reconstructChangedTerritories();  
            } 
             
        }
        catch(Exception ex)
        {      
        }
    }

    private void reconstructChangedTerritories()
    {
        if(modifiedTerritoryIds.contains(Territory.Id))
        {
            Integer index = 0;
            for(Territory__c tempTerritory : ChangedTerritories)               
            {
                if(tempTerritory.Id == Territory.Id)
                {
                    break;
                }
                index ++;
            }
            ChangedTerritories.remove(index);
        }    
        modifiedTerritoryIds.add(Territory.Id);
        ChangedTerritories.add(Territory); 
    }
    
    private void upsertTerritoryOwner()
    {
        Territory_Owner__c territoryOwner;
        String status = Change.Status__c == 'Rejected' && tempModifiedTerritoryIds.contains(Territory.Id) ? 'Rejected' : 'Definition';
        List<Territory_Owner__c> territoryOwners = [select Id, IsEffective__c from Territory_Owner__c where Territory__c = :Territory.Id and Status__c = :status and IsEffective__c = false order by LastModifiedDate desc limit 1];
        if(territoryOwners != null && territoryOwners.size() > 0)
        {
            territoryOwner = territoryOwners[0];
            territoryOwner.New_Owner__c = Territory.New_Owner__c;
        }
        else
        {
            territoryOwner = new Territory_Owner__c(Territory__c = Territory.Id, Status__c = 'Definition', New_Owner__c = territory.New_Owner__c);
        }
        List<Territory_Boundary__c> territoryBoundaries = [select Id, Status__c from Territory_Boundary__c where Territory__c = :Territory.Id and Status__c = :status and IsEffective__c = false];
        if(territoryBoundaries.size() == 0 && (Assignments.size() > 0 || ExceptionAccounts.size() > 0))
        {
            Territory_Boundary__c boundary = new Territory_Boundary__c(Territory__c = Territory.Id, Status__c = 'Definition');
            insert boundary;
            List<Assignment_Detail__c> assignmentDetails = assignmentMap.get(Territory.Id);
            for(Assignment_Detail__c assignment : assignmentDetails)
            {
                assignment.Territory_Assignment__c = boundary.Id;
            }
            List<ExceptionAccount2TerritoryBoundary__c> boundary2Accounts = new List<ExceptionAccount2TerritoryBoundary__c>();
            for(Account acct : exceptionAccountMap.get(Territory.Id))
            {
                ExceptionAccount2TerritoryBoundary__c boundary2Account = new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = acct.Id, Territory_Boundary__c = boundary.Id);
                boundary2Accounts.add(boundary2Account);
            }
            if(assignmentDetails.size() > 0)
            {
                insert assignmentDetails;
            }
            if(boundary2Accounts.size() > 0)
            {
                insert boundary2Accounts;
            }
        }
        upsert territoryOwner;
    }

    private void resetRelatedVariables()
    {
        Territory = new Territory__c();
        Change = new Territory_Change_Box__c();
        Change2 = new Territory_Change_Box__c();
        AvailableTerritories.clear();
        availableTerritoryIds.clear();
        ChangedTerritories.clear();
        modifiedTerritoryIds.clear();
        tempModifiedTerritoryIds.clear();
        Assignments.clear();
        ExceptionAccounts.clear();
        AccountCriteria.clear();
        String tDay = Date.today().day() < 10 ? '0' + String.valueOf(Date.today().day()) : String.valueOf(Date.today().day());
        String tMonth = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month());
        String tYear = String.valueOf(Date.today().year());
        EffectiveDate = tMonth + '/' + tDay + '/' + tYear;
    }

    private void constructEffectiveAndIneffectiveTerritoryBoundaryForTerritory(List<String> territoryIds, Map<String, List<Assignment_Detail__c>> effectiveAssignmentMap, Map<String, List<Assignment_Detail__c>> ineffectiveAssignmentMap, Map<String, List<AccountCriteria__c>> effectiveAccountCriteriaMap, Map<String, List<AccountCriteria__c>> ineffectiveAccountCriteriaMap, Map<String, List<Territory_Member__c>> effectiveTerritoryMemberMap, Map<String, List<Territory_Member__c>> ineffectiveTerritoryMemberMap)
    {
        List<Territory_Boundary__c> boundaries = [select Id, IsEffective__c, Status__c, Territory__c, (select Id, Field__c, Operator__c, Label__c, Value__c, Territory_Boundary__c from AccountCriteria__r order by Label__c), (select Id, Account_Access__c, Opportunity_Access__c, Territory_Member__c, Territory_Boundary__c from Territory_Members__r order by Territory_Member__r.Name) from Territory_Boundary__c where Territory__c in :territoryIds order by LastModifiedDate Desc];
        Map<String, List<Assignment_Detail__c>> detailMap = new Map<String, List<Assignment_Detail__c>>();
        List<Assignment_Detail__c> details = [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__r.Territory__c in :territoryIds order by Country__c, State__c, Postal_Start__c];
        for(Assignment_Detail__c detail : details){
            if(!detailMap.containsKey(detail.Territory_Assignment__c)){
                detailMap.put(detail.Territory_Assignment__c, new List<Assignment_Detail__c>());
            }
            detailMap.get(detail.Territory_Assignment__c).add(detail);
        }
        for(Territory_Boundary__c boundary : boundaries)
        {
            String territoryId = boundary.Territory__c;
            if(boundary.IsEffective__c)
            {
                if(!effectiveAssignmentMap.containsKey(territoryId))
                {
                    effectiveAssignmentMap.put(territoryId, new List<Assignment_Detail__c>());
                    effectiveAccountCriteriaMap.put(territoryId, new List<AccountCriteria__c>());
                    effectiveTerritoryMemberMap.put(territoryId, new List<Territory_Member__c>());
                }
                effectiveAssignmentMap.get(territoryId).addAll(detailMap.get(boundary.Id));
                effectiveAccountCriteriaMap.get(territoryId).addAll(boundary.AccountCriteria__r);
                effectiveTerritoryMemberMap.get(territoryId).addAll(boundary.Territory_Members__r);
            }
            else if(boundary.Status__c =='Definition')
            {
                if(!ineffectiveAssignmentMap.containsKey(territoryId))
                {
                    ineffectiveAssignmentMap.put(territoryId, new List<Assignment_Detail__c>());
                    ineffectiveAccountCriteriaMap.put(territoryId, new List<AccountCriteria__c>());
                    ineffectiveTerritoryMemberMap.put(territoryId, new List<Territory_Member__c>());
                }
                if(ineffectiveAssignmentMap.get(territoryId).size() == 0)
                {
                    ineffectiveAssignmentMap.get(territoryId).addAll(detailMap.get(boundary.Id));
                    ineffectiveAccountCriteriaMap.get(territoryId).addAll(boundary.AccountCriteria__r);
                    ineffectiveTerritoryMemberMap.get(territoryId).addAll(boundary.Territory_Members__r);
                }
            }
            else
            {           
            }   
        }
    }

    private void getAssignmentMap(List<String> territoryIds)
    {
        for(String territoryId : territoryIds)
        {
            assignmentMap.put(territoryId, new List<Assignment_Detail__c>());
            accountCriteriaMap.put(territoryId, new List<AccountCriteria__c>());
            territoryMemberMap.put(territoryId, new List<Territory_Member__c>());
        } 
        Map<String, List<Assignment_Detail__c>> effectiveAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<Assignment_Detail__c>> ineffectiveAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
        Map<String, List<AccountCriteria__c>> effectiveAccountCriteriaMap = new Map<String, List<AccountCriteria__c>>();
        Map<String, List<AccountCriteria__c>> ineffectiveAccountCriteriaMap = new Map<String, List<AccountCriteria__c>>();
        Map<String, List<Territory_Member__c>> effectiveTerritoryMemberMap = new Map<String, List<Territory_Member__c>>();
        Map<String, List<Territory_Member__c>> ineffectiveTerritoryMemberMap = new Map<String, List<Territory_Member__c>>();
        constructEffectiveAndIneffectiveTerritoryBoundaryForTerritory(territoryIds, effectiveAssignmentMap, ineffectiveAssignmentMap, effectiveAccountCriteriaMap, ineffectiveAccountCriteriaMap, effectiveTerritoryMemberMap, ineffectiveTerritoryMemberMap);
        for(String territoryId : ineffectiveAssignmentMap.keySet())
        {
            assignmentMap.get(territoryId).addAll(ineffectiveAssignmentMap.get(territoryId));
            accountCriteriaMap.get(territoryId).addAll(ineffectiveAccountCriteriaMap.get(territoryId));
            territoryMemberMap.get(territoryId).addAll(ineffectiveTerritoryMemberMap.get(territoryId));
        }
        for(String territoryId : effectiveAssignmentMap.keySet())
        {
            if(!ineffectiveAssignmentMap.containsKey(territoryId))
            {
                assignmentMap.get(territoryId).addAll(effectiveAssignmentMap.get(territoryId).deepClone());  
                accountCriteriaMap.get(territoryId).addAll(effectiveAccountCriteriaMap.get(territoryId).deepClone()); 
                territoryMemberMap.get(territoryId).addAll(effectiveTerritoryMemberMap.get(territoryId).deepClone());
            }
        }   
    }

    private void getExceptionAccountMap(List<String> territoryIds)
    {
        for(String territoryId : territoryIds)
        {
            exceptionAccountMap.put(territoryId, new List<Account>());
        }
        Map<String, Territory_Boundary__c> effectiveTerritoryMap = new Map<String, Territory_Boundary__c>();
        Map<String, Territory_Boundary__c> ineffectiveTerritoryMap = new Map<String, Territory_Boundary__c>();
        List<Territory__c> territoryList = [select Id, (select Id from Territory_Assignments__r where IsEffective__c = false and Status__c = 'Definition' order by LastModifiedDate desc) from Territory__c where Id in :territoryIds];
        for(Territory__c territory : territoryList)
        {
            if(territory.Territory_Assignments__r.size() == 0)
            {
                effectiveTerritoryMap.put(territory.Id, new Territory_Boundary__c());
            }
            else
            {
                ineffectiveTerritoryMap.put(territory.Id, territory.Territory_Assignments__r[0]);
            }
        }  
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Exception_Account__c, Territory_Boundary__c, Territory_Boundary__r.Territory__c, Territory_Boundary__r.IsEffective__c, Exception_Account__r.New_Territory__c, Exception_Account__r.New_Territory__r.Name, Exception_Account__r.BillingCountry, Exception_Account__r.BillingState, Exception_Account__r.BillingPostalCode, Exception_Account__r.Name, Exception_Account__r.Territory__r.Name,
        Exception_Account__r.ShippingCountry, Exception_Account__r.ShippingState, Exception_Account__r.ShippingPostalCode from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__r.Territory__c in :ineffectiveTerritoryMap.keySet() and Territory_Boundary__r.IsEffective__c = false and Territory_Boundary__r.Status__c = 'Definition'];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : account2BoundaryList)
        {
            String territoryId = accountToBoundary.Territory_Boundary__r.Territory__c;
            exceptionAccountMap.get(territoryId).add(accountToBoundary.Exception_Account__r);
        }
        List<ExceptionAccount2TerritoryBoundary__c> accountToBoundaryList = [select Id, Exception_Account__c, Territory_Boundary__r.Territory__c, Territory_Boundary__r.IsEffective__c, Exception_Account__r.New_Territory__c, Exception_Account__r.New_Territory__r.Name, Exception_Account__r.BillingCountry, Exception_Account__r.BillingState, Exception_Account__r.BillingPostalCode, Exception_Account__r.Name, Exception_Account__r.Territory__r.Name,
        Exception_Account__r.ShippingCountry, Exception_Account__r.ShippingState, Exception_Account__r.ShippingPostalCode from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__r.Territory__c in :effectiveTerritoryMap.keySet() and Territory_Boundary__r.IsEffective__c = true];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : accountToBoundaryList)
        {
            String territoryId = accountToBoundary.Territory_Boundary__r.Territory__c;
            if(!ineffectiveTerritoryMap.containsKey(territoryId))
            {
                exceptionAccountMap.get(territoryId).add(accountToBoundary.Exception_Account__r);
            }   
        }    
    }

    private void getChangeBoxData(String changeboxId, List<String> territoryIds)
    {
        List<Territory__c> territoryList = [select Id, Name, Territory_Change_Box__c, New_Number_Of_Accounts__c, New_Number_Of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Current_Boundary__c, Current_Owner__c, New_Owner__c, Territory_Description__c from Territory__c where Territory_Change_Box__c = :changeBoxId order by Name];
        for(Territory__c territory : territoryList)
        {
            availableTerritoryIds.add(territory.Id);
            AvailableTerritories.add(territory);
            territoryIds.add(territory.Id);
            ChangedTerritories.add(territory);
            modifiedTerritoryIds.add(territory.Id);
            tempModifiedTerritoryIds.add(Territory.Id);   
        }
    }

    private void getAssignmentsAndExceptionAccounts()
    {
        if(String.isNotBlank(Territory.Id))
        {
            if(assignmentMap.containsKey(Territory.Id))
            {
                Assignments = assignmentMap.get(Territory.Id);
                initPageProperties();
                totalResults = Assignments.size();
                totalPage = (Integer)Math.ceil((Double)totalResults/ (Double)pageSize);
                getCurrentPageRecords();
            }
            
            if(exceptionAccountMap.containsKey(Territory.Id))
            {
                ExceptionAccounts = exceptionAccountMap.get(Territory.Id);
            }

            if(accountCriteriaMap.containsKey(Territory.Id))
            {
                AccountCriteria = accountCriteriaMap.get(Territory.Id);
            }

            if(territoryMemberMap.containsKey(Territory.Id)){
                TerritoryMembers = territoryMemberMap.get(Territory.Id);
            }
        }
    }

    private Map<String, String> getTerritoryBoudnaryMap(String changeBoxId, String status)
    {
        Map<String, String> territoryBoundaryMap = new Map<String, String>();
        List<Territory__c> territoryList = [select Id, (select Id from Territory_Assignments__r where Status__c = :status order by LastModifiedDate desc limit 1) from Territory__c where Territory_Change_Box__c = :changeBoxId];
        for(Territory__c territory : territoryList)
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                territoryBoundaryMap.put(territory.Territory_Assignments__r[0].Id, territory.Id);
            }
        }
        return territoryBoundaryMap;
    }

    private void getAssignmentMapForChangeBox(String changeBoxId, String status)
    {
        Map<String, String> territoryBoundaryMap = getTerritoryBoudnaryMap(changeBoxId, status);
        List<Assignment_Detail__c> detailList = [select Id, Territory_Assignment__c, Country__c, State__c, Postal_Start__c, Postal_End__c from Assignment_Detail__c where Territory_Assignment__c in :territoryBoundaryMap.keySet()];
        for(Assignment_Detail__c detail : detailList)
        {
            String territoryId = territoryBoundaryMap.get(detail.Territory_Assignment__c);
            if(!assignmentMap.containsKey(territoryId))
            {
                assignmentMap.put(territoryId, new List<Assignment_Detail__c>());
            }
            assignmentMap.get(territoryId).add(detail);
        }
        List<AccountCriteria__c> criteriaList = [select Id, Field__c, Label__c, Operator__c, Value__c, Territory_Boundary__c, Territory__c from AccountCriteria__c where Territory_Boundary__c in :territoryBoundaryMap.keySet()];
        for(AccountCriteria__c criteria : criteriaList)
        {
            String territoryId = territoryBoundaryMap.get(criteria.Territory_Boundary__c);
            if(!accountCriteriaMap.containsKey(territoryId))
            {
                accountCriteriaMap.put(territoryId, new List<AccountCriteria__c>());
            }
            accountCriteriaMap.get(territoryId).add(criteria);
        }
        List<Territory_Member__c> memberList = [select Id, Account_Access__c, Opportunity_Access__c, Territory_Boundary__c, Territory__c from Territory_Member__c where Territory_Boundary__c in:territoryBoundaryMap.keySet()];
        for(Territory_Member__c member : memberList){
            String territoryId = territoryBoundaryMap.get(member.Territory_Boundary__c);
            if(!territoryMemberMap.containsKey(territoryId)){
                territoryMemberMap.put(territoryId, new List<Territory_Member__c>());
            }
            territoryMemberMap.get(territoryId).add(member);
        }
    }

    private void getExceptionAccountMapForChangeBox(String changeBoxId, String status)
    {
        Map<String, String> territoryBoundaryMap = getTerritoryBoudnaryMap(changeboxId, status);
        List<ExceptionAccount2TerritoryBoundary__c> account2BoundaryList = [select Id, Territory_Boundary__c, Exception_Account__r.Name, Exception_Account__r.New_Territory__r.Name, Exception_Account__r.BillingCountry, Exception_Account__r.BillingState, Exception_Account__r.BillingPostalCode, Exception_Account__r.ShippingCountry, Exception_Account__r.ShippingState, Exception_Account__r.ShippingPostalCode, Exception_Account__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :territoryBoundaryMap.keySet()];
        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : account2BoundaryList)
        {
            String territoryId = territoryBoundaryMap.get(accountToBoundary.Territory_Boundary__c);
            if(!exceptionAccountMap.containsKey(territoryId))
            {
                exceptionAccountMap.put(territoryId, new List<Account>());
            }
            exceptionAccountMap.get(territoryId).add(accountToBoundary.Exception_Account__r);
        }
    }

    private void showPop(Boolean isShowCreateCriteriaPop, Boolean isShowEditCriteriaPop, Boolean isShowAddExistingPop, Boolean isShowNewAssignmentPop, Boolean isShowEditAssignmentPop, Boolean isShowBreakAssignmentPop, Boolean isShowExceptionAccountPop, Boolean isShowAddMemberPop, Boolean isShowEditMemberPop)
    {
        this.IsShowCreateCriteriaPop = isShowCreateCriteriaPop;
        this.IsShowEditCriteriaPop = isShowEditCriteriaPop;
        this.IsShowAddExistingPop = isShowAddExistingPop;
        this.IsShowNewAssignmentPop = isShowNewAssignmentPop;
        this.IsShowEditAssignmentPop = isShowEditAssignmentPop;
        this.IsShowBreakAssignmentPop = isShowBreakAssignmentPop;
        this.IsShowExceptionAccountPop = isShowExceptionAccountPop;
        this.IsShowAddMemberPop = isShowAddMemberPop;
        this.IsShowEditMemberPop = isShowEditMemberPop;
    }

    private void initAccountFieldsAndOperators()
    {
        AccountFields = new List<SelectOption>();
        Operators = new List<SelectOption>();
        List<String> fieldLabels = new List<String>();
        for(String key : TM_GlobalVariables.descirbeFieldResultMap.keySet())
        {
            fieldLabels.add(key);
        }
        fieldLabels.sort();
        for(String fieldLabel : fieldLabels)
        {
            Schema.DescribeFieldResult result = TM_GlobalVariables.descirbeFieldResultMap.get(fieldLabel);
            AccountFields.add(new SelectOption(result.getName(), fieldLabel));
            fieldNameToLabelMap.put(result.getName(), fieldLabel);
        }
        defaultACField = AccountFields[0].getValue();
    }

    private void recontructOperators(Schema.DescribeFieldResult result, AccountCriteria__c criteria)
    {
        Schema.DisplayType type = result.getType();
        if(type == Schema.DisplayType.Boolean)
        {
            criteria.IsMultiple__c = true;
            criteria.IsDate__c = false;
            if(criteria.Value__c == null)
            {
                criteria.Value__c = 'True';
            }
        }
        else if(type == Schema.DisplayType.MultiPicklist || type == Schema.DisplayType.Picklist)
        {
            criteria.IsMultiple__c = true;
            criteria.IsDate__c = false;
        }
        else if(type == Schema.DisplayType.Date || type == Schema.DisplayType.DateTime)
        {
            criteria.IsMultiple__c = false;
            criteria.IsDate__c = true;
        }
        else
        {
            criteria.IsMultiple__c = false;
            criteria.IsDate__c = false;
        }

        Operators.clear();
        if(type == Schema.DisplayType.Boolean || type == Schema.DisplayType.Email || type == Schema.DisplayType.EncryptedString || type == Schema.DisplayType.MultiPicklist || type == Schema.DisplayType.Picklist || type == Schema.DisplayType.Phone || type == Schema.DisplayType.Reference || type == Schema.DisplayType.String || type == Schema.DisplayType.URL || type == Schema.DisplayType.TextArea)
        {
            Operators.addAll(new List<SelectOption> { new SelectOption('equals', 'equals'), new SelectOption('not equal to', 'not equal to') });
        }
        else
        {
            Operators.addAll(new List<SelectOption> { new SelectOption('equals', 'equals'), new SelectOption('not equal to', 'not equal to'), new SelectOption('greater than', 'greater than'), new SelectOption('less than', 'less than'), new SelectOption('greater or equal', 'greater or equal'), new SelectOption('less or equal', 'less or equal')});
        }
    }

    private void initTerritoryChangeBox()
    {
        List<String> territoryIds = new List<String>();
        String changeBoxId = ApexPages.currentPage().getParameters().get('cid');
        String territoryId = ApexPages.currentPage().getParameters().get('territoryId');
        if(String.isNotBlank(territoryId) && territoryId instanceOf Id)
        {
            IsShowAssignmentAndExceptionAccount = true;
            Territory = [select Id, Name, Territory_Change_Box__c, New_Number_of_Accounts__c, New_Number_of_Open_Opps__c, New_Closed_Revenue_YTD__c, New_Pipeline_Less__c, New_Pipeline_Greater__c, Number_of_Accounts__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c, Territory_Type__c, Current_Boundary__c, Current_Owner__c, New_Owner__c, Territory_Description__c from Territory__c where Id = :territoryId order by Name];
            changeBoxId = [select Id, Territory_Change_Box__c from Territory__c where Id = :territoryId].Territory_Change_Box__c;
            if(String.isBlank(changeboxId))
            {
                String tDay = Date.today().day() < 10 ? '0' + String.valueOf(Date.today().day()) : String.valueOf(Date.today().day());
                String tMonth = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month());
                String tYear = String.valueOf(Date.today().year());
                EffectiveDate = tMonth + '/' + tDay + '/' + tYear;
                territoryIds.add(Territory.Id);
                AvailableTerritories.add(Territory);
                getAssignmentMap(territoryIds);
                getExceptionAccountMap(territoryIds);
            }
        }
        if(String.isNotBlank(changeBoxId))
        {
            IsShowAssignmentAndExceptionAccount = true;
            Change = [select Id, Name, Approve_Date__c, Approver__c, Effective_Date__c, Last_Comment__c, Status__c, Submit_Date__c, SubmittedBy__c, Job_Completion_Date_Time__c from Territory_Change_Box__c where Id = :changeBoxId];
            Change2.Name = Change.Name;
            Change2.Effective_Date__c = Change.Effective_Date__c;
            String day = Change2.Effective_Date__c.day() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.day()) : String.valueOf(Change2.Effective_Date__c.day());
            String month = Change2.Effective_Date__c.month() < 10 ? '0' + String.valueOf(Change2.Effective_Date__c.month()) : String.valueOf(Change2.Effective_Date__c.month());
            String year = String.valueOf(Change2.Effective_Date__c.year());
            EffectiveDate = month + '/' + day + '/' + year;
            if(Change.Status__c == 'Submitted' || Change.Status__c == 'Rejected' || (Change.Status__c == 'Approved' && Change.Job_Completion_Date_Time__c == null))
            {
                getChangeBoxData(changeBoxId, territoryIds);
                getAssignmentMapForChangeBox(Change.Id, Change.Status__c);
                getExceptionAccountMapForChangeBox(Change.Id, Change.Status__c);
            }
            else if(Change.Status__c == 'Definition')
            {
                getChangeBoxData(changeBoxId, territoryIds);
                getAssignmentMap(territoryIds);
                getExceptionAccountMap(territoryIds);
            }
            else if(String.isNotBlank(Territory.Id))
            {
                territoryIds.add(Territory.Id);
                AvailableTerritories.add(Territory);
                getAssignmentMap(territoryIds);
                getExceptionAccountMap(territoryIds);
            } 
            else
            {}
        }
        else
        {
            String tDay = Date.today().day() < 10 ? '0' + String.valueOf(Date.today().day()) : String.valueOf(Date.today().day());
            String tMonth = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month());
            String tYear = String.valueOf(Date.today().year());
            EffectiveDate = tMonth + '/' + tDay + '/' + tYear;
        }
        Territory = AvailableTerritories.size() > 0 && String.isBlank(Territory.Id) ? AvailableTerritories[0] : Territory;
        IsEnableAllButtons = Change.Status__c == 'Submitted' || (Change.Status__c == 'Approved' && Change.Job_Completion_Date_Time__c == null) ? false : true;
        IsDisableSaveAndSubmitButton = Change.Status__c == 'Submitted' || (Change.Status__c == 'Approved' && Change.Job_Completion_Date_Time__c == null) ? true : false;
        Change = Change.Status__c == 'Approved' && Change.Job_Completion_Date_Time__c <= DateTime.now() ? new Territory_Change_Box__c() : Change;
        getAssignmentsAndExceptionAccounts();    
    }

    private void initProperties()
    {
        AvailableTerritories = new List<Territory__c>();
        ChangedTerritories = new List<Territory__c>();
        Territory = new Territory__c();
        Change = new Territory_Change_Box__c();
        Change2 = new Territory_Change_Box__c();
        PopAvailableTerritories = new List<SelectOption>();
        PopSelectedTerritories = new List<SelectOption>();
        Assignments = new List<Assignment_Detail__c>();
        NewAssignments = new List<Assignment_Detail__c>();
        BrokenAssignments = new List<Assignment_Detail__c>();
        ExceptionAccounts = new List<Account>();
        AccountCriteria = new List<AccountCriteria__c>();
        NewCriteria = new List<AccountCriteria__c>();
        AcctCriteria = new AccountCriteria__c();
        TerritoryMembers = new List<Territory_Member__c>();
        NewTerritoryMembers = new List<Territory_Member__c>();
        TerritoryMember = new Territory_Member__c();
        AccountList = new List<AccountInfo>();
        Index = 0;
        AssignmentIndex = 0;
        RemovedIndex = 0;
        AccountCriteriaIndex = 0;
        IsShowEditCriteriaPop = false;
        IsShowAssignmentAndExceptionAccount = false;
        IsEnableAllButtons = true;
        IsDisableSaveAndSubmitButton = false;
        IsShowSavePop = '1';
        IsShowSubmitPop = '1';
        Config = TM_OrganizationSettings.getTerritoryConfig();
    }

    private void initPageProperties(){
        pageSize = 100;
        pageNum = 1;
    }
    
    private List<Assignment_Detail__c> analyseCSVString(String assignmentCsv)
    {
        List<Assignment_Detail__c> assignmentDetails = new List<Assignment_Detail__c>();
        if(assignmentCsv != null && assignmentCsv != '')
        {              
            String[] csvLines = assignmentCsv.split('\n');
            for(String csvLine : csvLines)
            {
                List<String> fieldValues = analyseCsvLine(csvLine);
                Assignment_Detail__c detail = new Assignment_Detail__c();
                detail.Country__c = fieldValues[0];
                detail.State__c = fieldValues[1];
                detail.Postal_Start__c = fieldValues[2];
                detail.Postal_End__c = fieldValues[3];
                assignmentDetails.add(detail);
            }
        }
        return assignmentDetails;
    }
    
    // This method will analyse the  csv line.
    private List<String> analyseCsvLine(String cvsLine)
    {
        List<String> analyseResults = new List<String>();
        if(cvsLine != null)
        {
            cvsLine = cvsLine.trim() + ',';
            Pattern cvsPattern = Pattern.compile('("[^"]*("{2})*[^"]*")*[^,]*,'); 
            Matcher cvsMatcher = cvsPattern.matcher(cvsLine);
            String tempCell ;
            while(cvsMatcher.find())
            {
                tempCell = cvsMatcher.group();
                tempCell = replaceDoubleQuotationMarks(tempCell);
                analyseResults.add(tempCell);
            }
        }
        return analyseResults;
    }

    private String replaceDoubleQuotationMarks(String input)
    {
        if(input != null && input != '')
        {
            input = input.trim();
            if(input.startsWith('"'))
            {   // The string is contained  double quotation marks.
                input = input.replaceAll('^"', '');
                input = input.replaceAll('",$', '');    
                input = input.replaceAll('""', '"');
            }
            else
            {
                input = input.replaceAll(',$','' );
            }
                return input;
        }
        return '';
    }
}