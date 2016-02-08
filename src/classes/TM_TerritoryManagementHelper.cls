/*
 ** Written By Joyce 2013/4/18.
 */
public class TM_TerritoryManagementHelper
{
    private static Map<String, Schema.sObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
    private static Folder folder = [select Id from Folder where Name = 'Territory Management' limit 1];
    private static Territory__c catchAllTerritory = TM_OrganizationSettings.getCatchAllTerritory();

    public static Boolean isAccountQualified(Territory__c territory, Account acct)
    {
        Boolean isQualified = true;
        for(AccountCriteria__c criteria : territory.AccountCriteria__r)
        {
            Schema.DisplayType type = TM_GlobalVariables.FieldTypeMap.get(criteria.Field__c);
            if(type == Schema.DisplayType.Boolean)
            {
                Boolean criteriaValue = criteria.Value__c == null || criteria.Value__c.toLowerCase() == 'false' ? false : true;
                Boolean fieldValue = Boolean.valueOf(acct.get(criteria.Field__c));
                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                {
                    isQualified = false;
                }
                else
                {} 
            }
            else if(type == Schema.DisplayType.Currency || type == Schema.DisplayType.Integer || type == Schema.DisplayType.Percent || type == Schema.DisplayType.Double)
            {
                try
                {
                    Decimal criteriaValue = criteria.Value__c == null ? null : Decimal.valueOf(criteria.Value__c.replace(',', ''));
                    Decimal fieldValue = acct.get(criteria.Field__c) == null ? null : Decimal.valueOf(Double.valueOf(acct.get(criteria.Field__c)));
                    if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                    {
                        isQualified = false;
                    }
                    else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                    {
                        isQualified = false;
                    }
                    else if(criteria.Operator__c.toLowerCase() == 'greater than' && (fieldValue == null || fieldValue <= criteriaValue))
                    {
                        isQualified = false;
                    }
                    else if(criteria.Operator__c.toLowerCase() == 'less than' && (fieldValue == null || fieldValue >= criteriaValue))
                    {
                        isQualified = false;
                    }
                    else if(criteria.Operator__c.toLowerCase() == 'greater or equal' && (fieldValue == null || fieldValue < criteriaValue))
                    {
                        isQualified = false;
                    }
                    else if(criteria.Operator__c.toLowerCase() == 'less or equal' && (fieldValue == null || fieldValue > criteriaValue))
                    {
                        isQualified = false;
                    }
                    else
                    {} 
                }
                catch(Exception ex)
                {
                    isQualified = false;
                }
            }
            else if(type == Schema.DisplayType.DateTime)
            {
                DateTime criteriaValue = null;
                if(criteria.Value__c != null)
                {
                    String[] dates = criteria.Value__c.split('/');
                    criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
                }
                DateTime fieldValue = acct.get(criteria.Field__c) == null ? null : DateTime.valueOf(acct.get(criteria.Field__c));
                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'greater than' && (fieldValue == null || fieldValue <= criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'less than' && (fieldValue == null || fieldValue >= criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'greater or equal' && (fieldValue == null || fieldValue < criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'less or equal' && (fieldValue == null || fieldValue > criteriaValue))
                {
                    isQualified = false;
                }
                else
                {} 
            }
            else if(type == Schema.DisplayType.Date)
            {
                Date criteriaValue = null;
                if(criteria.Value__c != null)
                {
                    String[] dates = criteria.Value__c.split('/');
                    criteriaValue = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
                }
                Date fieldValue = acct.get(criteria.Field__c) == null ? null : Date.valueOf(acct.get(criteria.Field__c));
                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'greater than' && (fieldValue == null || fieldValue <= criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'less than' && (fieldValue == null || fieldValue >= criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'greater or equal' && (fieldValue == null || fieldValue < criteriaValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'less or equal' && (fieldValue == null || fieldValue > criteriaValue))
                {
                    isQualified = false;
                }
                else
                {}
            }
            else
            {
                String criteriaValue = criteria.Value__c == null ? '' : criteria.Value__c.trim().toLowerCase();
                String fieldValue = acct.get(criteria.Field__c) == null ? '' : String.valueOf(acct.get(criteria.Field__c)).trim().toLowerCase();
                Set<String> values = new Set<String>();
                for(String value : criteriaValue.split(','))
                {
                    values.add(value.trim().toLowerCase());
                }
                if(criteria.Operator__c.toLowerCase() == 'equals' && !values.contains(fieldValue))
                {
                    isQualified = false;
                }
                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && values.contains(fieldValue))
                {
                    isQualified = false;
                }
                else
                {
                }
            } 
        }
        return isQualified;
    }

    public static void constructAssignmentMap(List<Assignment_Detail__c> assignments, Set<String> territoryIds, Map<String, String> alternateCountryMap, Map<String, String> alternateStateMap, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, Map<String, List<Assignment_Detail__c>> countryAssignmentMap)
    {
        for(Assignment_Detail__c detail : assignments)
        {
            territoryIds.add(detail.Territory_Assignment__r.Territory__c);
            String country = detail.Country__c.toLowerCase();
            if(detail.State__c == null && (detail.Postal_Start__c == null || detail.Postal_End__c == null))
            {
                if(!countryAssignmentMap.containsKey(country))
                {
                    countryAssignmentMap.put(country, new List<Assignment_Detail__c>());
                }
                countryAssignmentMap.get(country).add(detail);
                if(alternateCountryMap.containsKey(country))
                {
                    countryAssignmentMap.put(alternateCountryMap.get(country), new List<Assignment_Detail__c>());
                }
            }
            else if(detail.State__c != null && !(detail.Postal_Start__c != null && detail.Postal_End__c != null))
            {
                String state = detail.State__c.toLowerCase();
                constructCountryAndStateAssignment(country, state, detail, alternateCountryMap, alternateStateMap, countryStateAssignmentMap);    
            }
            else
            {
                String state = detail.State__c != null ? detail.State__c.toLowerCase() : '';
                constructCountryAndStateAssignment(country, state, detail, alternateCountryMap, alternateStateMap, countryZipCodeAssignmentMap);
            }
        }
    }

    private static void constructCountryAndStateAssignment(String country, String state, Assignment_Detail__c detail, Map<String, String> alternateCountryMap, Map<String, String> alternateStateMap, Map<String, List<Assignment_Detail__c>> assignmentMap)
    {
        String countryState = country + '/' + state;
        if(!assignmentMap.containsKey(countryState))
        {
            assignmentMap.put(countryState, new List<Assignment_Detail__c>());
        }
        assignmentMap.get(countryState).add(detail);
        if(alternateStateMap.containsKey(state))
        {
            countryState = country + '/' + alternateStateMap.get(state);
            if(!assignmentMap.containsKey(countryState))
            {
                assignmentMap.put(countryState, new List<Assignment_Detail__c>());
            }
            assignmentMap.get(countryState).add(detail);
        } 
        if(alternateCountryMap.containsKey(country))
        {
            countryState = alternateCountryMap.get(country) + '/' + state;
            if(!assignmentMap.containsKey(countryState))
            {
                assignmentMap.put(countryState, new List<Assignment_Detail__c>());
            }
            assignmentMap.get(countryState).add(detail);
            if(alternateStateMap.containsKey(state))
            {
                countryState = alternateCountryMap.get(country) + '/' + alternateStateMap.get(state);
                if(!assignmentMap.containsKey(countryState))
                {
                    assignmentMap.put(countryState, new List<Assignment_Detail__c>());
                }
                assignmentMap.get(countryState).add(detail);
            }
        }
    }

    public static Set<String> getTerritoryBoundaryIds(Set<String> territoryIds)
    {
        Set<String> territoryBoundaryIds = new Set<String>();
        for(Territory__c territory : [select Id, (select Id, IsEffective__c, Territory__c, Territory__r.Current_Boundary__c from Territory_Assignments__r where Status__c = 'Approved' and IsEffective__c = true order by LastModifiedDate desc limit 1) from Territory__c where Id in :territoryIds])
        {
            if(territory.Territory_Assignments__r.size() > 0)
            {
                territoryBoundaryIds.add(territory.Territory_Assignments__r[0].Id);
            }
        }
        return territoryBoundaryIds;
    }
    
    public static Map<String, String> getAlternateCountryMap()
    {
        Map<String, String> alternateCountryMap = new Map<String, String>();
        if(sObjectTypeMap.containsKey('pw_ccpro__countryobject__c'))
        {
            String queryString = 'select Id, Name, pw_ccpro__IsoCode_2__c from pw_ccpro__CountryObject__c';
            List<sObject> countries = Database.query(queryString);
            for(sObject obj : countries)
            {
                String countryName = ((String)obj.get('Name')).toLowerCase();
                String countryCode = ((String)obj.get('pw_ccpro__IsoCode_2__c')).toLowerCase();
                if(!alternateCountryMap.containsKey(countryName))
                {
                    alternateCountryMap.put(countryName, countryCode);
                }
                if(!alternateCountryMap.containsKey(countryCode))
                {
                    alternateCountryMap.put(countryCode, countryName);
                }
            }
        }
        return alternateCountryMap;
    }
    
    public static Map<String, String> getAlternateStateMap()
    {
        Map<String, String> alternateStateMap = new Map<String, String>();
        if(sObjectTypeMap.containsKey('pw_ccpro__state__c'))
        {
            String queryString = 'select Id, Name, pw_ccpro__IsoCode__c from pw_ccpro__State__c';
            List<sObject> states = Database.query(queryString);
            for(sObject obj : states)
            {
                String stateName = ((String)obj.get('Name')).toLowerCase();
                String stateCode = ((String)obj.get('pw_ccpro__IsoCode__c')).toLowerCase();
                if(!alternateStateMap.containsKey(stateName))
                {
                    alternateStateMap.put(stateName, stateCode);
                }
                if(!alternateStateMap.containsKey(stateCode))
                {
                    alternateStateMap.put(stateCode, stateName);
                }
            }
        }
        return alternateStateMap;
    }
    
    public static String getCatchAllRecordTypeId()
    {
        String recordTypeId = '';
        List<RecordType> recordTypes = [select Id from RecordType where sObjectType = 'Territory__c' and Name = 'Catch All' order by LastModifiedDate desc limit 1];
        if(!recordTypes.isEmpty())
        {
            recordTypeId = recordTypes[0].Id;
        }
        return recordTypeId;
    }
    
    public static void sendApprovalReqeust(List<Territory_Change_Box__c> changeSets)
    {
        Territory_Change_Box__c changeSet = changeSets.size() > 0 ? changeSets[0] : new Territory_Change_Box__c();
        if(changeSet.Approver__c != null && changeSet.SubmittedBy__c != null)
        {
            EmailTemplate emailTemplate = [select Id, Body, NamespacePrefix, Subject from EmailTemplate where FolderId = :folder.Id and Name = 'TM_ApprovalRequestForTerritoryChangeSet' limit 1];
            String namespace = emailTemplate.NamespacePrefix; 
            String approver = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace + '__Approver__c}' : '{!Territory_Change_Box__c.Approver__c}';
            String submitter = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace+ '__SubmittedBy__c}' : '{!Territory_Change_Box__c.SubmittedBy__c}';
            String name = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.Name}' : '{!Territory_Change_Box__c.Name}';
            String effectiveDate = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace + '__Effective_Date__c}' : '{!Territory_Change_Box__c.Effective_Date__c}';
            String baseUrl = URL.getsalesforceBaseUrl().toExternalForm() + '/apex/TM_Config';
            String body = emailTemplate.Body.replace(approver, changeSet.Approver__r.Name).replace(submitter, changeSet.SubmittedBy__r.Name).replace(name, changeSet.Name).replace(effectiveDate, String.valueOf(changeSet.Effective_Date__c)).replace('https://c.cs9.visual.force.com/apex/TM_Config', baseUrl);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(changeSet.Approver__c);
            mail.setSaveAsActivity(false);
            mail.setSubject(emailTemplate.Subject);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }   
    }

    public static void sendRejectedAlert(List<Territory_Change_Box__c> changeSets)
    {
        Territory_Change_Box__c changeSet = changeSets.size() > 0 ? changeSets[0] : new Territory_Change_Box__c();
        if(changeSet.Approver__c != null && changeSet.SubmittedBy__c != null)
        {   
            EmailTemplate emailTemplate = [select Id, Body, NamespacePrefix, Subject from EmailTemplate where FolderId = :folder.Id and Name = 'TM_TerritoryChangeSetReject' limit 1];
            String namespace = emailTemplate.NamespacePrefix;
            String submitter = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace+ '__SubmittedBy__c}' : '{!Territory_Change_Box__c.SubmittedBy__c}';
            String approver = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace + '__Approver__c}' : '{!Territory_Change_Box__c.Approver__c}';
            String lastComment = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.' + namespace + '__Last_Comment__c}' : '{!Territory_Change_Box__c.Last_Comment__c}';
            String changeSetId = String.isNotBlank(namespace) ? '{!' + namespace + '__Territory_Change_Box__c.Id}' : '{!Territory_Change_Box__c.Id}';
            String baseUrl = URL.getsalesforceBaseUrl().toExternalForm();
            String comment = changeSet.Last_Comment__c == null ? '' : changeSet.Last_Comment__c;
            String body = emailTemplate.Body.replace(submitter, changeSet.SubmittedBy__r.Name).replace(approver, changeSet.Approver__r.Name).replace(lastComment, comment).replace(changeSetId, changeSet.Id).replace('https://c.cs9.visual.force.com', baseUrl);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(changeSet.SubmittedBy__c);
            mail.setSaveAsActivity(false);
            mail.setSubject(emailTemplate.Subject);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
     
    public static void sumupExceptionAccountForTerritories(Territory_Config__c config, Set<String> territoryIds, Map<String, Decimal> numberOfAccountMap, Map<String, Decimal> numberOfContactMap, Map<String, Decimal> numberOfOpenOppMap, Map<String, Decimal> numberOfTaskMap, Map<String, Decimal> numberOfEventMap, Map<String, Decimal> closedRevenueYTDMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map)
    {
        Map<String, Territory_Boundary__c> boundaryMap = new Map<String, Territory_Boundary__c>();
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Territory_Boundary__c boundary : [select Id, Territory__c, Territory__r.Name from Territory_Boundary__c where Territory__c in :territoryIds and IsEffective__c = true])
        {
            boundaryMap.put(boundary.Id, boundary);
        }

        for(ExceptionAccount2TerritoryBoundary__c accountToBoundary : [select Id, Exception_Account__c, Exception_Account__r.Territory__c, Exception_Account__r.OwnerId, Exception_Account__r.Closed_Revenue_YTD__c, Exception_Account__r.Pipeline_LT_50__c, Exception_Account__r.Pipeline_GL_50__c, Territory_Boundary__c from ExceptionAccount2TerritoryBoundary__c where Territory_Boundary__c in :boundaryMap.keySet()])
        { 
            accountMap.put(accountToBoundary.Exception_Account__c, accountToBoundary.Exception_Account__r);
            String territoryId = boundaryMap.get(accountToBoundary.Territory_Boundary__c).Territory__c;
            Decimal numberOfAccount = numberOfAccountMap.containsKey(territoryId) ? numberofAccountMap.get(territoryId) + 1 : 1;
            numberOfAccountMap.put(territoryId, numberOfAccount);
            constructTerritoryFieldsMap(territoryId, accountToBoundary.Exception_Account__r, closedRevenueYTDMap, pipelineLT50Map, pipelineGT50Map);
        }
        sumupNumberOfContactsForTerritories(accountMap, numberOfContactMap);
        sumupNumberOfOpportunitiesForTerritories(accountMap, numberOfOpenOppMap);
        sumupNumberOfEventsForTerritories(accountMap, numberOfEventMap);
        sumupNumberOfTasksForTerritories(accountMap, numberOfTaskMap);  
    }

    public static void syncActivitiesOwnerWithAccountOwner(Map<String, Account> accountMap, Map<String, String> oldAccountMap)
    {
        List<Task> updatingTasks = new List<Task>();
        List<Event> updatingEvents = new List<Event>();
        for(Task task : [select Id, OwnerId, AccountId, Account.OwnerId from Task where AccountId in :accountMap.keySet() and IsClosed = false and RecurrenceActivityId = null])
        {
            Account acct = accountMap.get(task.AccountId);
            String oldAcctOwnerId = oldAccountMap.get(task.AccountId);
            if(task.OwnerId != acct.OwnerId && task.OwnerId == oldAcctOwnerId)
            { 
                task.OwnerId = acct.OwnerId;
                updatingTasks.add(task);
            }
        }
        
        for(Event event : [select Id, OwnerId, AccountId, Account.OwnerId from Event where AccountId in :accountMap.keySet() and EndDateTime >= :DateTime.now()])
        {
            Account acct = accountMap.get(event.AccountId);
            String oldAcctOwnerId = oldAccountMap.get(event.AccountId);
            if(event.OwnerId != acct.OwnerId && event.OwnerId == oldAcctOwnerId)
            {
                event.OwnerId = acct.OwnerId;
                updatingEvents.add(event);
            }
        }
        
        if(updatingTasks.size() > 0)
        {
            update updatingTasks;
        }
        
        if(updatingEvents.size() > 0)
        {
            update updatingEvents;
        }
    }
    
    public static void syncOppOwnerWithAccountOwner(Map<String, Account> accountMap)
    {
        List<Opportunity> updatingOpps = new List<Opportunity>();
        
        for(Opportunity opp : [select Id, OwnerId, AccountId from Opportunity where AccountId in :accountMap.keySet() and IsClosed = false])
        {
            Account acct = accountMap.get(opp.AccountId);
            if(opp.OwnerId != acct.OwnerId)
            {
                opp.OwnerId = acct.OwnerId;
                updatingOpps.add(opp);
            }
        }
        
        if(updatingOpps.size() > 0)
        {
            update updatingOpps;
        }
    }
    
    public static void syncContactOwnerWithAccountOwner(Map<String, Account> accountMap)
    {
        List<Contact> updatingContacts = new List<Contact>();
        for(Contact contact : [select Id, OwnerId, AccountId from Contact where AccountId in :accountMap.keySet()])
        {
            Account acct = accountMap.get(contact.AccountId);
            if(contact.OwnerId != acct.OwnerId)
            {
                contact.OwnerId = acct.OwnerId;
                updatingContacts.add(contact);
            }
        }
        
        if(updatingContacts.size() > 0)
        {
            update updatingContacts;
        }
    }
    
    public static void constructTerritoryFieldsMap(String territoryId, Account acct, Map<String, Decimal> closedRevenueYTDMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map)
    {
        Decimal reveue = acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
        Decimal closedRevenue = closedRevenueYTDMap.get(territoryId) == null ? reveue : closedRevenueYTDMap.get(territoryId) + reveue;
        Decimal pipelineGT50 = pipelineGT50Map.get(territoryId) == null ? acct.Pipeline_GL_50__c : pipelineGT50Map.get(territoryId) + acct.Pipeline_GL_50__c;
        Decimal pipelineLT50 = pipelineLT50Map.get(territoryId) == null ? acct.Pipeline_LT_50__c : pipelineLT50Map.get(territoryId) + acct.Pipeline_LT_50__c;
        closedRevenueYTDMap.put(territoryId, closedRevenue);
        pipelineGT50Map.put(territoryId, pipelineGT50);
        pipelineLT50Map.put(territoryId, pipelineLT50);
    } 
    
    public static void sumupNumberOfEventsForTerritories(Map<String, Account> accountMap, Map<String, Decimal> numberOfEventsMap)
    {
        for(Event event : [select Id, OwnerId, AccountId, Account.OwnerId from Event where AccountId in :accountMap.keySet() and ActivityDateTime >= :DateTime.now()])
        {
            String territoryId = accountMap.get(event.AccountId).Territory__c;
            Decimal numberOfEvents = numberOfEventsMap.containsKey(territoryId) ? numberOfEventsMap.get(territoryId) + 1 : 1;
            numberOfEventsMap.put(territoryId, numberOfEvents);  
        }
    }
    
    public static void sumupNumberOfTasksForTerritories(Map<String, Account> accountMap, Map<String, Decimal> numberOfTasksMap)
    {
        for(Task task : [select Id, OwnerId, AccountId, Account.OwnerId from Task where AccountId in :accountMap.keySet() and IsClosed = false and RecurrenceActivityId = null])
        {
            String territoryId = accountMap.get(task.AccountId).Territory__c;
            Decimal numberOfTasks = numberOfTasksMap.containsKey(territoryId) ? numberOfTasksMap.get(territoryId) + 1 : 1;
            numberOfTasksMap.put(territoryId, numberOfTasks);
        }   
    }
    
    public static void sumupNumberOfOpportunitiesForTerritories(Map<String, Account> accountMap, Map<String, Decimal> numberOfOppsMap)
    {
        for(Opportunity opp : [select Id, OwnerId, AccountId from Opportunity where AccountId in :accountMap.keySet() and IsClosed = false])
        {
            String territoryId = accountMap.get(opp.AccountId).Territory__c;
            Decimal numberOfOpps = numberOfOppsMap.containsKey(territoryId) ? numberOfOppsMap.get(territoryId) + 1 : 1;
            numberOfOppsMap.put(territoryId, numberOfOpps);
        }    
    }
    
    public static void sumupNumberOfContactsForTerritories(Map<String, Account> accountMap, Map<String, Decimal> numberOfContactsMap)
    {
        for(Contact contact : [select Id, OwnerId, AccountId from Contact where AccountId in :accountMap.keySet()])
        {
            String territoryId = accountMap.get(contact.AccountId).Territory__c;
            Decimal numberOfContacts = numberOfContactsMap.containsKey(territoryId) ? numberOfContactsMap.get(territoryId) + 1 : 1;
            numberOfContactsMap.put(territoryId, numberOfContacts);
        }
    } 

    private static Boolean findTerritory(List<Account> updatingAccounts, Set<String> territoryIds, Territory__c territory, Account account)
    {
        Boolean isFindTerritory = false;
        if(!territoryIds.contains(territory.Id))
        {
            Boolean isQualified = TM_TerritoryManagementHelper.isAccountQualified(territory, account);
            if(isQualified)
            {
                if(account.Territory__c != territory.Id || account.OwnerId != territory.Current_Owner__c)
                {
                    account.Territory__c = territory.Id;
                    account.OwnerId = territory.Current_Owner__c;
                    updatingAccounts.add(account);
                }
                isFindTerritory = true;
                territoryIds.add(territory.Id);
            }
        }
        return isFindTerritory;
    }

    public static Boolean isFindTerritory(List<Account> updatingAccounts, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, String countryState, Map<String, Territory__c> territoryMap, Account account)
    {
        Boolean isFindTerritory = false;
        Set<String> territoryIds = new Set<String>();
        List<Assignment_Detail__c> assignments = countryStateAssignmentMap.get(countryState);
        for(Assignment_Detail__c detail : assignments)
        {
            if(!isFindTerritory){
                Territory__c territory = territoryMap.get(detail.Territory_Assignment__r.Territory__c);
                isFindTerritory = findTerritory(updatingAccounts, territoryIds, territory, account);
            }else{
                break;
            }
            
        }
        return isFindTerritory;
    }

    public static Boolean isFindTerritoryFromCountryZipCodeMap(List<Account> updatingAccounts, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, String countryState, String postalCode, Map<String, Territory__c> territoryMap, Account account)
    {
        Boolean isFindTerritory = false;
        Set<String> territoryIds = new Set<String>();
        List<Assignment_Detail__c> assignments = countryZipCodeAssignmentMap.get(countryState);
        for(Assignment_Detail__c detail : assignments)
        {
            String postalStart = detail.Postal_Start__c != null ? detail.Postal_Start__c.toLowerCase() : '';
            String postalEnd = detail.Postal_End__c != null ? detail.Postal_End__c.toLowerCase(): '';
            Boolean isInPostalRange = isInPostalRange(postalCode, postalStart, postalEnd);
            if(isInPostalRange)
            {
                if(!isFindTerritory){
                    Territory__c territory = territoryMap.get(detail.Territory_Assignment__r.Territory__c);
                    isFindTerritory = findTerritory(updatingAccounts, territoryIds, territory, account);
                }else{
                    break;
                }   
            }
        }
        if(territoryIds.size() > 1)
        {
            if(account.Territory__c != catchAllTerritory.Id || account.OwnerId != catchAllTerritory.Current_Owner__c){
                account.Territory__c = catchAllTerritory.Id;
                account.OwnerId = catchAllTerritory.Current_Owner__c;
                updatingAccounts.add(account);
            }
            isFindTerritory = true;
        }
        return isFindTerritory;
    }

    private static Boolean isInPostalRange(String postalCode, String postalStart, String postalEnd)
    {
        if(postalStart == null && postalEnd == null)
        {
            return true;
        }
        // When PostalCode is NULL, and PostalStart or PostalEnd is NOT NULL.
        if(postalCode == null)
        {
            return false;
        }            
        
        if(postalStart != null && postalEnd != null)
        {
            return (postalCode.compareTo(postalStart) >= 0 && postalCode.compareTo(postalEnd) <= 0); 
        }
        return false;        
    }
}