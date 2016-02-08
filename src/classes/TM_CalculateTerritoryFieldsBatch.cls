/*
 ** After creating a change box, if the "what if" button is clicked, the batch will be called to calculate the corresponding fields on Terriotry.
 ** Written by Joyce. 2013/4/3.
 */
global class TM_CalculateTerritoryFieldsBatch implements Database.Batchable<sObject>, Database.Stateful
{
    //obsoleted variables
    //Start
    global Map<String, Territory__c> countryMap  = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryStateMap = new Map<String, Territory__c>();
    global Map<String, Territory__c> countryZipCodeMap  = new Map<String, Territory__c>();
    global Map<String, Map<String, Territory__c>> newCountryMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryStateMap = new Map<String, Map<String, Territory__c>>();
    global Map<String, Map<String, Territory__c>> newCountryZipCodeMap = new Map<String, Map<String, Territory__c>>();
    //End

    global String query { get; set; }
    global String changeName { get; set; }
    global List<String> addresses = new List<String>();
    global Set<String> countries  = new Set<String>();
    global Set<String> territoryIds = new Set<String>();
    global Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
    global Map<String, Decimal> accountCountMap = new Map<String, Decimal>();
    global Map<String, Decimal> openOppCountMap = new Map<String, Decimal>();
    global Map<String, Decimal> contactCountMap = new Map<String, Decimal>();
    global Map<String, Decimal> taskCountMap = new Map<String, Decimal>();
    global Map<String, Decimal> eventCountMap = new Map<String, Decimal>(); 
    global Map<String, Decimal> pipelineLT50Map = new Map<String, Decimal>();
    global Map<String, Decimal> pipelineGT50Map = new Map<String, Decimal>();
    global Map<String, Decimal> closedRevenueYTDMap = new Map<String, Decimal>(); 
    global Territory_Config__c config;
    Set<String> modifiedTerritoryIds = new Set<String>();

    Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
    Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();

    global TM_CalculateTerritoryFieldsBatch(String query, String changeName, List<String> addresses, Set<String> countries, Map<String, Territory__c> territoryMap, Map<String, Territory__c> countryMap, Map<String, Territory__c> countryStateMap, Map<String, Territory__c> countryZipCodeMap, Map<String, Decimal> accountCountMap, Map<String, Decimal> openOppCountMap, Map<String, Decimal> contactCountMap, Map<String, Decimal> taskCountMap, Map<String, Decimal> eventCountMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map, Map<String, Decimal> closedRevenueYTDMap)
    {
    }
    
    global TM_CalculateTerritoryFieldsBatch(String query, String changeName, List<String> addresses, Set<String> countries, Map<String, Territory__c> territoryMap, Map<String, Map<String, Territory__c>> countryMap, Map<String, Map<String, Territory__c>> countryStateMap, Map<String, Map<String, Territory__c>> countryZipCodeMap, Map<String, Decimal> accountCountMap, Map<String, Decimal> openOppCountMap, Map<String, Decimal> contactCountMap, Map<String, Decimal> taskCountMap, Map<String, Decimal> eventCountMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map, Map<String, Decimal> closedRevenueYTDMap)
    {
    }

    global TM_CalculateTerritoryFieldsBatch(String query, String changeName, Set<String> modifiedTerritoryIds, List<String> addresses, Set<String> countries, Map<String, Territory__c> territoryMap, Map<String, List<Assignment_Detail__c>> countryAssignmentMap, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, Map<String, Decimal> accountCountMap, Map<String, Decimal> openOppCountMap, Map<String, Decimal> contactCountMap, Map<String, Decimal> taskCountMap, Map<String, Decimal> eventCountMap, Map<String, Decimal> pipelineLT50Map, Map<String, Decimal> pipelineGT50Map, Map<String, Decimal> closedRevenueYTDMap)
    {
        this.query = query;
        this.changeName = changeName;
        this.modifiedTerritoryIds = modifiedTerritoryIds;
        this.addresses = addresses;
        this.countries = countries;
        this.territoryMap = territoryMap;
        this.countryAssignmentMap = countryAssignmentMap;
        this.countryStateAssignmentMap = countryStateAssignmentMap;
        this.countryZipCodeAssignmentMap = countryZipCodeAssignmentMap;
        this.accountCountMap = accountCountMap;
        this.openOppCountMap = openOppCountMap; 
        this.contactCountMap = contactCountMap;
        this.taskCountMap = taskCountMap;
        this.eventCountMap = eventCountMap;
        this.pipelineLT50Map = pipelineLT50Map;
        this.pipelineGT50Map = pipelineGT50Map;
        this.closedRevenueYTDMap = closedRevenueYTDMap;
        config = TM_OrganizationSettings.getTerritoryConfig(); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {      
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Account> accts = (List<Account>)scope;
        List<Account> updatingAccounts = new List<Account>();
        for(Account acct : accts)
        {
            Boolean isFindTerritory = false;
            String country = ((String)acct.get(addresses[0])).toLowerCase();
            String state = acct.get(addresses[1]) == null ? '' : ((String)acct.get(addresses[1])).toLowerCase();
            String countryState = country + '/' + state;
            String postalCode = acct.get(addresses[2]) != null ? String.valueOf(acct.get(addresses[2])).toLowerCase() : '';
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
            if(isFindTerritory)
            {
                accountMap.put(acct.Id, acct);
                sumupNumberOfAccountsForTerritories(acct);
                constructTerritoryFieldsMap(acct.Territory__c, acct);
            }    
        }
        TM_TerritoryManagementHelper.sumupNumberOfContactsForTerritories(accountMap, contactCountMap);
        TM_TerritoryManagementHelper.sumupNumberOfOpportunitiesForTerritories(accountMap, openOppCountMap);
        TM_TerritoryManagementHelper.sumupNumberOfEventsForTerritories(accountMap,eventCountMap);
        TM_TerritoryManagementHelper.sumupNumberOfTasksForTerritories(accountMap, taskCountMap);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        String result = '';
        for(Territory__c territory : TerritoryMap.values())
        {           
            if(modifiedTerritoryIds.contains(territory.Id))
            {
                territory.New_Number_Of_Accounts__c = accountCountMap.get(territory.Id);
                territory.New_Number_Of_Open_Opps__c = openOppCountMap.get(territory.Id);
                territory.New_Closed_Revenue_YTD__c = closedRevenueYTDMap.get(territory.Id);
                territory.New_Pipeline_Less__c = pipelineLT50Map.get(territory.Id);
                territory.New_Pipeline_Greater__c = pipelineGT50Map.get(territory.Id);
            }
        }
        try
        {
            update TerritoryMap.values();
            result = constructResult();
        }
        catch(Exception ex)
        {
        }
        AsyncApexJob job = [select ExtendedStatus, NumberOfErrors, TotalJobItems, CompletedDate from AsyncApexJob where Id = :bc.getJobId()];
        User user = [select Id, Email from User where Id = :UserInfo.getUserId()];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String plainText = '<p style="font-weight:bold;">Your What If\'s for ' + changeName + ' completed. </p> <p style="font-weight:bold;">Find the results below.</p>';    
        plainText += result;
        email.setTargetObjectId(user.Id);
        email.setSubject('Batch Result');
        email.setSaveAsActivity(false);
        email.setHtmlBody(plainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });    
    }

    private String constructResult()
    {
        String result = '<table cellpadding="0" cellspacing="0"><tr><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Territory Name</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Accounts</th>';
        if(config.Include_Contacts__c)
        {
            result += '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Contacts</th>';
        }
        if(config.Include_Open_Opps__c)
        {
            result += '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Open Opportunities</th>';
        }
        if(config.Include_Open_Activities__c)
        {
            result += '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Tasks</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Events</th>';
        }
        result += '<th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">YTD Sales</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Pipeline < 50%</th><th style="background:#15335c;color:#ffffff;border:1px solid #000000;padding:5px;">Pipeline >= 50%</th></tr>';
        for(Territory__c territory : [select Id, Name from Territory__c where Id in :modifiedTerritoryIds])
        {
            String numberOfAccounts = accountCountMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(accountCountMap.get(territory.Id)) : '0';
            String numberOfContacts = contactCountMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(contactCountMap.get(territory.Id)) : '0';
            String numberOfOpenOpps = openOppCountMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(openOppCountMap.get(territory.Id)) : '0';
            String numberOfTasks = taskCountMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(taskCountMap.get(territory.Id)) : '0';
            String numberOfEvents = eventCountMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(eventCountMap.get(territory.Id)) : '0';
            result += '<tr><td style="padding:5px;border:1px solid #f3f3f3">' + territory.Name + '</td><td style="padding:5px;border:1px solid #f3f3f3">' + numberOfAccounts + '</td>';
            if(config.Include_Contacts__c)
            {
                result += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfContacts + '</td>';
            }
            if(config.Include_Open_Opps__c)
            {
                result += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfOpenOpps + '</td>';
            }
            if(config.Include_Open_Activities__c)
            {
                result += '<td style="padding:5px;border:1px solid #f3f3f3">' + numberOfTasks + '</td><td style="padding:5px;border:1px solid #f3f3f3">' + numberOfEvents + '</td>';
            }
            String pipelineLT50 = pipelineLT50Map.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(pipelineLT50Map.get(territory.Id)) : '0';
            String pipelineGT50 = pipelineGT50Map.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(pipelineGT50Map.get(territory.Id)) : '0';
            String closedRevenueYTD = closedRevenueYTDMap.containsKey(territory.Id) ? TM_SubmitChangeBoxHelper.convertNumberToCurrencyFormat(closedRevenueYTDMap.get(territory.Id)) : '0';
            result += '<td style="padding:5px;border:1px solid #f3f3f3"> $' + closedRevenueYTD + '</td><td style="padding:5px;border:1px solid #f3f3f3"> $' + pipelineLT50 + '</td><td style="padding:5px;border:1px solid #f3f3f3"> $' + pipelineGT50 + '</td></tr>';      
        }
        result += '</table>';
        return result;
    }  
 
    private void constructTerritoryFieldsMap(String territoryId, Account acct)
    {
        Decimal reveue = acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
        Decimal closedRevenue = closedRevenueYTDMap.get(territoryId) == null ? reveue : closedRevenueYTDMap.get(territoryId) + reveue;
        Decimal pipelineGT50 = pipelineGT50Map.get(territoryId) == null ? acct.Pipeline_GL_50__c : pipelineGT50Map.get(territoryId) + acct.Pipeline_GL_50__c;
        Decimal pipelineLT50 = pipelineLT50Map.get(territoryId) == null ? acct.Pipeline_LT_50__c : pipelineLT50Map.get(territoryId) + acct.Pipeline_LT_50__c;
        closedRevenueYTDMap.put(territoryId, closedRevenue);
        pipelineGT50Map.put(territoryId, pipelineGT50);
        pipelineLT50Map.put(territoryId, pipelineLT50);
    } 

    private void sumupNumberOfAccountsForTerritories(Account acct)
    {
         Decimal numberOfAccounts = accountCountMap.containsKey(acct.Territory__c) ? accountCountMap.get(acct.Territory__c) + 1 : 1;
         accountCountMap.put(acct.Territory__c, numberOfAccounts);
    }
}