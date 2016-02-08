/*
 ** It is used to Reassign the accounts to corresponding territories.
 ** Written by Joyce.
 */
global class TM_TerritoryRealignmentAndOwnerBatch implements Database.Batchable<sObject>, Database.Stateful
{
    //obsoleted variables
    //Start
    global Map<String, Territory__c> countryMap = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryStateMap = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryZipCodeMap = new Map<String, Territory__c>();
    global Map<String, Map<String, Territory__c>> newCountryMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryStateMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryZipCodeMap = new Map<String, Map<String, Territory__c>>();
    //End

    global String query = '';
    List<String> addresses = new List<String>();
    Set<String> countries = new Set<String>();
    List<Territory__c> catchAllTerritories = new List<Territory__c>();
    Set<String> changeBoxIds = new Set<String>();
    String changeBoxNameStr = '';
    Territory_Config__c config = new Territory_Config__c();
    Set<String> territoryIds = new Set<String>();

    Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
     
    Map<String, Decimal> numberOfAccountsMap = new Map<String, Decimal>();
    Map<String, Decimal> numberOfContactsMap = new Map<String, Decimal>();
    Map<String, Decimal> numberOfOppsMap = new Map<String, Decimal>();
    Map<String, Decimal> numberOfTasksMap = new Map<String, Decimal>();
    Map<String, Decimal> numberOfEventsMap = new Map<String, Decimal>();
    Map<String, Decimal> closedRevenueYTDMap = new Map<String, Decimal>();
    Map<String, Decimal> pipelineLT50Map = new Map<String, Decimal>();
    Map<String, Decimal> pipelineGT50Map = new Map<String, Decimal>();
     
    global TM_TerritoryRealignmentAndOwnerBatch(String query, Set<String> countries, List<String> addresses, Map<String, Territory__c> countryMap, Map<String, Territory__c> countryStateMap, Map<String, Territory__c> countryZipCodeMap, Set<String> changeBoxIds)
    {
    }
    
    global TM_TerritoryRealignmentAndOwnerBatch(String query, Set<String> countries, List<String> addresses, Map<String, Map<String, Territory__c>> countryMap, Map<String, Map<String, Territory__c>> countryStateMap, Map<String, Map<String, Territory__c>> countryZipCodeMap, Set<String> changeBoxIds)
    {
    }

    global TM_TerritoryRealignmentAndOwnerBatch(String query, Set<String> countries, List<String> addresses, Map<String, List<Assignment_Detail__c>> countryAssignmentMap, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, Set<String> changeBoxIds, Map<String, Territory__c> territoryMap)
    {
        this.query = query;
        this.countries = countries;
        this.addresses = addresses;
        this.countryAssignmentMap = countryAssignmentMap;
        this.countryStateAssignmentMap = countryStateAssignmentMap;
        this.countryZipCodeAssignmentMap = countryZipCodeAssignmentMap; 
        this.territoryMap = territoryMap;
        this.changeBoxIds = changeBoxIds;
        catchAllTerritories = [select Id, Current_Owner__c, Current_Owner__r.IsActive from Territory__c where Territory_Type__c = 'Catch All' limit 1];  
        config = TM_OrganizationSettings.getTerritoryConfig(); 
        territoryIds = getTerritoryIds(changeBoxIds);
    }
     
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Account> accts = (List<Account>)scope;
        List<Account> updatingAccounts = new List<Account>();
        List<Contact> updatingContacts = new List<Contact>();
        List<Opportunity> updatingOpps = new List<Opportunity>();
        List<Task> updatingTasks = new List<Task>();
        List<Event> updatingEvents = new List<Event>();
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, String> oldAccountMap = new Map<String, String>();
        for(Account acct : accts)
        {
            Boolean isFindTerritory = false;
            oldAccountMap.put(acct.Id, acct.OwnerId);
            String country = acct.get(addresses[0]) != null ? ((String)acct.get(addresses[0])).toLowerCase() : '';
            String state = acct.get(addresses[1]) != null ? ((String)acct.get(addresses[1])).toLowerCase() : '';
            String postalCode = acct.get(addresses[2]) != null ? String.valueOf(acct.get(addresses[2])).toLowerCase() : '';
            String countryState = country + '/' + state;
            if(countryZipCodeAssignmentMap.containsKey(countryState))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritoryFromCountryZipCodeMap(updatingAccounts, countryZipCodeAssignmentMap, countryState, postalCode, territoryMap, acct);
            }
            if(!isFindTerritory && countryStateAssignmentMap.containsKey(countryState))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryStateAssignmentMap, countryState, territoryMap, acct);
            }
            if(!isFindTerritory && countryAssignmentMap.containsKey(country))
            {
                isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryAssignmentMap, country, territoryMap, acct);
            }
            if(!isFindTerritory)
            {
                Territory__c territory = catchAllTerritories[0];
                if(territoryIds.contains(acct.Territory__c) || acct.Territory__c == null)
                {
                    acct.OwnerId = territory.Current_Owner__c;
                    acct.Territory__c = territory.Id;
                    updatingAccounts.add(acct);
                }
            }
            sumupNumberOfAccountsForTerritories(acct);
            TM_TerritoryManagementHelper.constructTerritoryFieldsMap(acct.Territory__c, acct, closedRevenueYTDMap, pipelineLT50Map, pipelineGT50Map);
            accountMap.put(acct.Id, acct);    
        }
         
        if(updatingAccounts.size() > 0)
        {
            try
            {
                update updatingAccounts;
            }
            catch(Exception ex)
            {  
            }
        }
        if(config.Include_Contacts__c)
        {
            TM_TerritoryManagementHelper.syncContactOwnerWithAccountOwner(accountMap);
        }
        if(config.Include_Open_Opps__c)
        {
            TM_TerritoryManagementHelper.syncOppOwnerWithAccountOwner(accountMap);
        }
        
        if(config.Include_Open_Activities__c)
        {
           TM_TerritoryManagementHelper.syncActivitiesOwnerWithAccountOwner(accountMap, oldAccountMap);
        }
        
        TM_TerritoryManagementHelper.sumupNumberOfContactsForTerritories(accountMap, numberOfContactsMap);
        TM_TerritoryManagementHelper.sumupNumberOfOpportunitiesForTerritories(accountMap, numberOfOppsMap);
        TM_TerritoryManagementHelper.sumupNumberOfEventsForTerritories(accountMap,numberOfEventsMap);
        TM_TerritoryManagementHelper.sumupNumberOfTasksForTerritories(accountMap, numberOfTasksMap); 
    }
     
    global void finish(Database.BatchableContext bc)
    {
        AsyncApexJob job = [select ExtendedStatus, NumberOfErrors, TotalJobItems, CompletedDate from AsyncApexJob where Id = :bc.getJobId()];
        populateCompletionTimeForChangeBox(job);
        String userId = UserInfo.getUserId();
        User user = [select Id, Email from User where Id = :userId];
        String plainText = '';
        if(job.NumberOfErrors > 0)
        {
            plainText += 'First Error:' + job.ExtendedStatus +'.';
        }
        else
        {
            plainText = '<p style="font-weight:bold;">The submitted changes for ' + changeBoxNameStr + ' completed.</p><p style="font-weight:bold;">Find the results below.</p>';
            plainText += '<table cellpadding="0" cellspacing="0"><tr><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Territory Name</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Accounts</th>' +
                            '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Contacts</th>' + 
                            '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Open Opportunities</th>' + 
                            '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Tasks</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Events</th>' +
                            '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">YTD Sales</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Pipeline < 50%</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Pipeline >= 50%</th></tr>';
            Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
            for(Territory__c territory : [select Id, Name, Number_of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Territory_Change_Box__c in :changeBoxIds])
            {
                territoryMap.put(territory.Id, territory);
            }
            TM_TerritoryManagementHelper.sumupExceptionAccountForTerritories(config, territoryMap.keySet(), numberOfAccountsMap, numberOfContactsMap, numberOfOppsMap, numberOfTasksMap, numberOfEventsMap, closedRevenueYTDMap, pipelineLT50Map, pipelineGT50Map);
            List<Territory__c> territories = new List<Territory__c>();
            for(Territory__c territory : territoryMap.values())
            {
                territory.Number_of_Accounts__c = numberOfAccountsMap.get(territory.Id); 
                territory.Number_of_Open_Opps__c = numberOfOppsMap.get(territory.Id); 
                territory.Closed_Revenue_YTD__c = closedRevenueYTDMap.get(territory.Id);
                territory.Pipeline_Less_Than_Percent50__c = pipelineLT50Map.get(territory.Id); 
                territory.Pipeline_Greater_Than_Percent50__c = pipelineGT50Map.get(territory.Id);
                territories.add(territory);
                String numberOfAccounts = numberOfAccountsMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(numberOfAccountsMap.get(territory.Id)) : '0';
                plainText += '<tr><td style="padding:5px;border:1px solid #f3f3f3">' + territory.Name + '</td><td style="padding:5px;border:1px solid #f3f3f3">' + numberOfAccounts + '</td>';
                String numberOfContacts = numberOfContactsMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(numberOfContactsMap.get(territory.Id)) : '0';
                plainText += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfContacts + '</td>';
                String numberOfOpps = numberOfOppsMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(numberOfOppsMap.get(territory.Id)) : '0';
                plainText += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfOpps + '</td>';
                String numberOfTasks = numberOfTasksMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(numberOfTasksMap.get(territory.Id)) : '0';
                String numberOfEvents = numberOfEventsMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(numberOfEventsMap.get(territory.Id)) : '0';
                plainText += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfTasks + '</td><td style="padding:5px;border:1px solid #f3f3f3">' + numberOfEvents + '</td>';
                String pipelineLT50 = pipelineLT50Map.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(pipelineLT50Map.get(territory.Id)) : '0';
                String pipelineGT50 = pipelineGT50Map.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(pipelineGT50Map.get(territory.Id)) : '0';
                String closedRevenueYTD = closedRevenueYTDMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(closedRevenueYTDMap.get(territory.Id)) : '0';
                plainText += '<td style="padding:5px;border:1px solid #f3f3f3"> $' + closedRevenueYTD + '</td><td style="padding:5px;border:1px solid #f3f3f3"> $' + pipelineLT50 + '</td><td style="padding:5px;border:1px solid #f3f3f3"> $' + pipelineGT50 + '</td></tr>';    
            }
            plainText += '</table>';
            String unassignedObject = '';
            if(!config.Include_Contacts__c)
            {
                unassignedObject += 'Contacts, ';
            }
            if(!config.Include_Open_Opps__c)
            {
                unassignedObject += 'Open Opportunities, ';
            }
            if(!config.Include_Open_Activities__c)
            {
                unassignedObject += 'Tasks, Events, ';
            }
            if(unassignedObject.length() > 0)
            {
                unassignedObject = unassignedObject.substring(0, unassignedObject.length() - 2) + ' are not assigned, because they are unchecked on territory setup.';
                plainText += '<p style="font-weight:bold;">Please Note: ' + unassignedObject + '</p>';
            }
          
            if(territories.size() > 0)
            {
                update territories;
            }
        }
        
        Territory__c territory = [select Id from Territory__c where Territory_Type__c = 'Catch All' limit 1];
        if(territory != null){
            String queryStr = 'select Id, Name, Pipeline_LT_50__c, Pipeline_GL_50__c , Closed_Revenue_YTD__c  from Account where Territory__c = :territoryId';
            TM_CatchAllFieldsCalculationBatch b = new TM_CatchAllFieldsCalculationBatch(queryStr, territory.Id);
            Database.executeBatch(b);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(user.Id);
        email.setSaveAsActivity(false);
        email.setSubject('Batch Result');
        email.setHtmlBody(plainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });   
    }

    private Set<String> getTerritoryIds(Set<String> changeBoxIds)
    {
        Set<String> territoryIds = new Set<String>();
        for(Territory__c territory : [select Id from Territory__c where Territory_Change_Box__c in :changeBoxIds])
        {
            territoryIds.add(territory.Id);
        }
        return territoryIds;
    }
     
    private void populateCompletionTimeForChangeBox(AsyncApexJob job)
    {
        List<Territory_Change_Box__c> boxes = new List<Territory_Change_Box__c>();
        for(Territory_Change_Box__c box : [select Id, Name, Job_Completion_Date_Time__c from Territory_Change_Box__c where Id in :changeBoxIds])
        {
            changeBoxNameStr += box.Name + ',';
            box.Job_Completion_Date_Time__c = job.CompletedDate;
            boxes.add(box);
        }
        if(changeBoxNameStr.length() > 0)
        {
            changeBoxNameStr = changeBoxNameStr.substring(0, changeBoxNameStr.length() - 1);
        }
        if(boxes.size() > 0)
        {
            update boxes;
        }
    }
    
    private void sumupNumberOfAccountsForTerritories(Account acct)
    {
        Decimal numberOfAccounts = numberOfAccountsMap.containsKey(acct.Territory__c) ? numberOfAccountsMap.get(acct.Territory__c) + 1 : 1;
        numberOfAccountsMap.put(acct.Territory__c, numberOfAccounts);
    }
 }