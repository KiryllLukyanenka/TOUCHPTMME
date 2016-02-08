public class TM_AccountTriggerHandler
{
	private static List<String> shippingOrBillingAddresses = TM_OrganizationSettings.getShippingOrBillingAddresses();
	private static Territory_Config__c config = TM_OrganizationSettings.getTerritoryConfig(); 
	//private static Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();
	private static Territory__c catchAllTerritory = TM_OrganizationSettings.getCatchAllTerritory();
	
	public static void fireUpdateTrigger(Boolean isInsert, Map<Id, Account> acctMap, Map<Id, Account> oldAcctMap)
	{
		if(shippingOrBillingAddresses != null)
		{
			Set<String> acctIds = new Set<String>();
			if(isInsert)
			{
				for(Account acct : acctMap.values())
				{
					if(!acct.No_Territory_Assignment__c)
					{
						acctIds.add(acct.Id);
					}    
				}
			}
			else
			{
				for(Account acct : acctMap.values())
				{
					Account oldAcct = oldAcctMap.get(acct.Id);
					if(!acct.No_Territory_Assignment__c && (acct.get(shippingOrBillingAddresses[0]) != oldAcct.get(shippingOrBillingAddresses[0]) || acct.get(shippingOrBillingAddresses[1]) != oldAcct.get(shippingOrBillingAddresses[1]) || acct.get(shippingOrBillingAddresses[2]) != oldAcct.get(shippingOrBillingAddresses[2])))
					{
						acctIds.add(acct.Id);
					}
				}
			}
			
			if(acctIds.size() > 0)
			{    
				List<Account> accts = [select Id, Invoke_Update_Trigger__c from Account where Id in :acctIds];
				for(Account acct : accts)
				{
					acct.Invoke_Update_Trigger__c = !acct.Invoke_Update_Trigger__c;
				}
				update accts;
			}
		}
	}

	public static void calculateTerritoryFieldsForDelete(Map<Id, Account> accountMap)
	{
		Map<String, List<Account>> acctMap = new Map<String, List<Account>>();
		Map<String, List<Account>> oldAcctMap = new Map<String, List<Account>>();
		List<Territory__c> territories = new List<Territory__c>();
		for(Account acct : accountMap.values())
		{
			String territoryId = acct.Territory__c;
			if(String.isNotBlank(territoryId))
			{
			   if(!oldAcctMap.containsKey(territoryId))
			   {
				   oldAcctMap.put(territoryId, new List<Account>());
			   }
			   oldAcctMap.get(territoryId).add(acct);
			}
		}
		if(!oldAcctMap.isEmpty())
		{
			calculateTerritoryFields(acctMap, oldAcctMap, territories);
			if(territories.size() > 0)
			{
				update territories;
			}
		}
	}
	public static void calculateTerritoryFieldsForInsert(Map<Id, Account> accountMap)
	{
		Map<String, List<Account>> acctMap = new Map<String, List<Account>>();
		Map<String, List<Account>> oldAcctMap = new Map<String, List<Account>>();
		List<Territory__c> territories = new List<Territory__c>();
		for(Account acct : accountMap.values())
		{
			if(String.isNotBlank(acct.Territory__c))
			{
				if(!acctMap.containsKey(acct.Territory__c))
				{
					acctMap.put(acct.Territory__c, new List<Account>());
				}
				acctMap.get(acct.Territory__c).add(acct);
			}    
		} 
		if(!acctMap.isEmpty())
		{
			calculateTerritoryFields(acctMap, oldAcctMap, territories);
			if(territories.size() > 0)
			{
				update territories;
			}
		}
	}
	
	public static void calculateTerritoryFieldsForUpdate(Map<Id, Account> accountMap, Map<Id, Account> oldAccountMap)
	{
		Map<String, List<Account>> acctMap = new Map<String, List<Account>>();
		Map<String, List<Account>> oldAcctMap = new Map<String, List<Account>>();
		List<Territory__c> territories = new List<Territory__c>();
		
		for(Account acct : accountMap.values())
		{
			Account oldAcct = oldAccountMap.get(acct.Id);
			if(acct.Territory__c != oldAcct.Territory__c || acct.Number_of_Open_Opps__c != oldAcct.Number_of_Open_Opps__c || acct.Closed_Revenue_YTD__c != oldAcct.Closed_Revenue_YTD__c || acct.Pipeline_LT_50__c != oldAcct.Pipeline_GL_50__c || acct.Pipeline_GL_50__c != oldAcct.Pipeline_GL_50__c)
			{
				if(String.isNotBlank(acct.Territory__c))
				{
					if(!acctMap.containsKey(acct.Territory__c))
					{
						acctMap.put(acct.Territory__c, new List<Account>());
					}
					acctMap.get(acct.Territory__c).add(acct);
				} 
				if(String.isNotBlank(oldAcct.Territory__c))
				{
					if(!oldAcctMap.containsKey(oldAcct.Territory__c))
					{
						oldAcctMap.put(oldAcct.Territory__c, new List<Account>());
					}
					oldAcctMap.get(oldAcct.Territory__c).add(oldAcct);
				}  
			}    
		}
		if(!acctMap.isEmpty() || !oldAcctMap.isEmpty())
		{
			calculateTerritoryFields(acctMap, oldAcctMap, territories);
			if(territories.size() > 0)
			{
				update territories;
			}   
		}
	}
	
	public static void unsyncAccountRelatedObjectOwner(Map<Id, Account> acctMap, Map<Id, Account> oldAcctMap)
	{
		Map<String, String> accountOwnerMap = new Map<String, String>();
		Map<String, String> accountOldOwnerMap = new Map<String, String>();
		for(Account acct : acctMap.values())
		{
			Account oldAcct = oldAcctMap.get(acct.Id);
			if((oldAcct.OwnerId != acct.OwnerId || oldAcct.No_Territory_Assignment__c != acct.No_Territory_Assignment__c) && !acct.No_Territory_Assignment__c)
			{
				accountOwnerMap.put(acct.Id, acct.OwnerId);
				accountOldOwnerMap.put(oldAcct.Id, oldAcct.OwnerId);
			}
		}
		
		if(!accountOwnerMap.isEmpty())
		{
			if(!config.Include_Contacts__c)
			{
				//unsyncContacts(accountOwnerMap, accountOldOwnerMap);
				syncContactsByCode(accountOwnerMap, accountOldOwnerMap);
			}
			else
			{
				syncContacts(accountOwnerMap);
			}
		
			if(!config.Include_Open_Opps__c)
			{
				unsyncOpenOpps(accountOwnerMap, accountOldOwnerMap);
			}
			else
			{
				syncOpenOpps(accountOwnerMap);
			}
		
			if(!config.Include_Open_Activities__c)
			{
				//unsyncActivities(accountOwnerMap, accountOldOwnerMap);
			} 
			else
			{
				syncActivities(accountOwnerMap, accountOldOwnerMap);
			}
		}
	}
	
	public static void setSalesTerritoryForUpdate(Map<Id, Account> acctMap, Map<Id, Account> oldAcctMap)
	{
		List<Account> notMatchedAccounts = new List<Account>();
		List<Account> normalAccounts = new List<Account>();
		Map<String, List<Account>> exceptionAccountMap = new Map<String, List<Account>>();
		if(shippingOrBillingAddresses != null)
		{
			Set<String> countryStates = new Set<String>();
			for(Account acct : acctMap.values())
			{
				constructAccountLists(acct, oldAcctMap, countryStates, notMatchedAccounts, normalAccounts, exceptionAccountMap);
			}
		}
		if(normalAccounts.size() > 0)
		{
			dealWithTerritoryRealignment(normalAccounts, notMatchedAccounts);
		}                                      
	}

	public static void shareAccountWithTerritoryMembersForUpdate(List<Account> accounts, Map<Id, Account> oldMap){
		Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
		Map<String, String> oldAccountMap = new Map<String, String>();
		for(Account acct : accounts){
			Account oldAcct = oldMap.get(acct.Id);
			if(oldAcct.Territory__c != acct.Territory__c){
				if(!accountMap.containsKey(acct.Territory__c)){
					accountMap.put(acct.Territory__c, new List<Account>());
				}
				accountMap.get(acct.Territory__c).add(acct);
				oldAccountMap.put(acct.Id, oldAcct.Territory__c);
			}   
		}

		Map<String, List<Territory_Member__c>> territoryMemberMap = new Map<String, List<Territory_Member__c>>();
		Map<String, Set<String>> oldTerritoryMemberMap = new Map<String, Set<String>>();
		if(!accountMap.isEmpty()){
			for(Territory__c territory : [select Id, (select Id, Name, Territory_Member__c, Territory__c, Account_Access__c, Contact_Access__c, Opportunity_Access__c from Territory_Members__r where Territory_Boundary__r.IsEffective__c = true) from Territory__c where Id in :accountMap.keySet()]){
				territoryMemberMap.put(territory.Id, new List<Territory_Member__c>());
				territoryMemberMap.get(territory.Id).addAll(territory.Territory_Members__r);
			}
		}
		if(!oldAccountMap.isEmpty()){
			for(Territory_Member__c member : [select Id, Name, Territory_Member__c, Account_Access__c, Contact_Access__c, Opportunity_Access__c, Territory__c from Territory_Member__c where Territory__c in :oldAccountMap.values() and Territory_Boundary__r.IsEffective__c = true]){
				if(!oldTerritoryMemberMap.containsKey(member.Territory__c)){
					oldTerritoryMemberMap.put(member.Territory__c, new Set<String>());
				}
				oldTerritoryMemberMap.get(member.Territory__c).add(member.Territory_Member__c);
			}  
			List<AccountTeamMember> deletingAcctTeamMembers = new List<AccountTeamMember>();
			for(AccountTeamMember member : [select AccountId, Account.Territory__c, UserId from AccountTeamMember where AccountId in :oldAccountMap.keySet()]){
				String oldTerritoryId = oldAccountMap.get(member.AccountId);
				if(oldTerritoryMemberMap.containsKey(oldTerritoryId) && oldTerritoryMemberMap.get(oldTerritoryId).contains(member.UserId)){
					deletingAcctTeamMembers.add(member);
				}
			}
			if(deletingAcctTeamMembers.size() > 0){
				delete deletingAcctTeamMembers;
			}
		}
		
		List<Account> validAccts = new List<Account>();
		Map<String, Map<String, Territory_Member__c>> memberMap = new Map<String, Map<String, Territory_Member__c>>();
		List<AccountTeamMember> acctTeamMembers = new List<AccountTeamMember>();
		for(String territoryId : territoryMemberMap.keySet()){
			List<Territory_Member__c> members = territoryMemberMap.get(territoryId);
			List<Account> accts = accountMap.get(territoryId);
			validAccts.addAll(accts);
			for(Account acct : accts){
				memberMap.put(acct.Id, new Map<String, Territory_Member__c>());
				for(Territory_Member__c member : members){
					if(member.Territory_Member__c != acct.OwnerId){
						memberMap.get(acct.Id).put(member.Territory_Member__c, member);
						acctTeamMembers.add(new AccountTeamMember(AccountId = acct.Id, TeamMemberRole = 'Account Manager', UserId = member.Territory_Member__c));
					}
				}
			}
		}
		if(acctTeamMembers.size() > 0){
			insert acctTeamMembers;
			List<AccountShare> acctShares = new List<AccountShare>();
			for(AccountShare acctShare : [select Id, AccountId, Account.OwnerId, UserOrGroupId, OpportunityAccessLevel from AccountShare where AccountId in :validAccts]){
				Map<String, Territory_Member__c> terrMembers = memberMap.get(acctShare.AccountId);
				if(terrMembers.containsKey(acctShare.UserOrGroupId) && acctShare.Account.OwnerId != acctShare.UserOrGroupId){
					acctShare.AccountAccessLevel = terrMembers.get(acctShare.UserOrGroupId).Account_Access__c;
					acctShare.OpportunityAccessLevel = terrMembers.get(acctShare.UserOrGroupId).Opportunity_Access__c;
					acctShares.add(acctShare);
				}
			}
			update acctShares;
		}
	}

	private static void dealWithTerritoryRealignment(List<Account> normalAccounts, List<Account> notMatchedAccounts)
	{
		Map<String, List<Assignment_Detail__c>> countryAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
		Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
		Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap = new Map<String, List<Assignment_Detail__c>>();
		Set<String> territoryIds = new Set<String>();
		constructAssignmentMap(normalAccounts, countryAssignmentMap, countryStateAssignmentMap, countryZipCodeAssignmentMap, territoryIds);
		Map<String, Territory__c> territoryMap = TM_SubmitChangeBoxHelper.getTerritoryMap(territoryIds);
		List<Account> updatingAccounts = new List<Account>();
		for(Account account : normalAccounts)
		{
			String country = String.valueOf(account.get(shippingOrBillingAddresses[0])).toLowerCase();
			String state = account.get(shippingOrBillingAddresses[1]) != null ? String.valueOf(account.get(shippingOrBillingAddresses[1])).toLowerCase() : '';
			String postalCode = account.get(shippingOrBillingAddresses[2]) != null ? String.valueOf(account.get(shippingOrBillingAddresses[2])).toLowerCase() : '';
			String countryState = country + '/' + state;
			Boolean isFindTerritory = false;
			if(countryZipCodeAssignmentMap.containsKey(countryState))
			{
				isFindTerritory = TM_TerritoryManagementHelper.isFindTerritoryFromCountryZipCodeMap(updatingAccounts, countryZipCodeAssignmentMap, countryState, postalCode, territoryMap, account);
			}
			if(!isFindTerritory && countryStateAssignmentMap.containsKey(countryState))
			{
				isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryStateAssignmentMap, countryState, territoryMap, account);
			}
			if(!isFindTerritory && countryAssignmentMap.containsKey(country))
			{
				isFindTerritory = TM_TerritoryManagementHelper.isFindTerritory(updatingAccounts, countryAssignmentMap, country, territoryMap, account);
			}
			if(!isFindTerritory)
			{
				if(account.Territory__c != catchAllTerritory.Id){
					account.Territory__c = catchAllTerritory.Id;
				}
				if(account.OwnerId != catchAllTerritory.Current_Owner__c){
					account.OwnerId = catchAllTerritory.Current_Owner__c;
				}
			}
		}
	}

	private static void constructAssignmentMap(List<Account> accounts, Map<String, List<Assignment_Detail__c>> countryAssignmentMap, Map<String, List<Assignment_Detail__c>> countryStateAssignmentMap, Map<String, List<Assignment_Detail__c>> countryZipCodeAssignmentMap, Set<String> territoryIds)
	{
		Set<String> countryStates = constructCountryStates(accounts);
		for(Assignment_Detail__c detail : [select Id, Country__c, State__c, Postal_Start__c, Postal_End__c, Territory_Assignment__r.Territory__c from Assignment_Detail__c where Territory_Assignment__r.IsEffective__c = true and Territory_Assignment__r.Status__c = 'Approved' and CountryState__c in :countryStates])
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
			}
			else if(detail.State__c != null && !(detail.Postal_Start__c != null && detail.Postal_End__c != null))
			{
				String state = detail.State__c.toLowerCase();
				String countryState = country + '/' + state;
				if(!countryStateAssignmentMap.containsKey(countryState))
				{
					countryStateAssignmentMap.put(countryState, new List<Assignment_Detail__c>());
				}
				countryStateAssignmentMap.get(countryState).add(detail);         
			}
			else
			{
				String state = detail.State__c != null ? detail.State__c.toLowerCase() : '';
				String countryState = country + '/' + state;
				if(!countryZipCodeAssignmentMap.containsKey(countryState))
				{
					countryZipCodeAssignmentMap.put(countryState, new List<Assignment_Detail__c>());
				}
				countryZipCodeAssignmentMap.get(countryState).add(detail);
			}
		}
	}

	private static Set<String> constructCountryStates(List<Account> accounts)
	{
		Map<String, String> alternateCountryMap = TM_TerritoryManagementHelper.getAlternateCountryMap();
		Map<String, String> alternateStateMap = TM_TerritoryManagementHelper.getAlternateStateMap(); 
		Set<String> countryStates = new Set<String>();
		for(Account acct : accounts)
		{
			String country = String.valueOf(acct.get(shippingOrBillingAddresses[0]));
			String state = acct.get(shippingOrBillingAddresses[1]) == null ? '' : String.valueOf(acct.get(shippingOrBillingAddresses[1]));
			String countryState = country + state;
			countryStates.add(country);
			countryStates.add(countryState);
			if(alternateCountryMap.containsKey(country))
			{
				String countryCode = alternateCountryMap.get(country);
				countryStates.add(countryCode);
				countryState = alternateCountryMap.get(country) + state;
				countryStates.add(countryState); 
				if(alternateStateMap.containsKey(state))
				{
					String stateCode = alternateStateMap.get(state);
					countryState = country + stateCode;
					countryStates.add(countryState);
					countryState = countryCode + stateCode;
					countryStates.add(countryState);
				}
			}
		}
		return countryStates;
	}

	private static void constructAccountLists(Account acct, Map<Id, Account> oldAcctMap, Set<String> countryStates, List<Account> notMatchedAccounts, List<Account> normalAccounts, Map<String, List<Account>> exceptionAccountMap)
	{
		if(acct.Territory_Boundary__c == null)
		{
			Account oldAcct = oldAcctMap.get(acct.Id);
			if((catchAllTerritory != null && acct.Territory__c == catchAllTerritory.Id) || !(acct.Territory__c != oldAcct.Territory__c || acct.OwnerId != oldAcct.OwnerId))
			{    
				if(acct.get(shippingOrBillingAddresses[0]) != null && !acct.No_Territory_Assignment__c)
				{
					normalAccounts.add(acct);                            
				} 
				else
				{
					notMatchedAccounts.add(acct);
				}                     
			}
		}
		else if(acct.Territory_Boundary__c != oldAcctMap.get(acct.Id).Territory_Boundary__c)
		{
			if(!exceptionAccountMap.containsKey(acct.Territory_Boundary__c))
			{
				exceptionAccountMap.put(acct.Territory_Boundary__c, new List<Account>());
			}
			exceptionAccountMap.get(acct.Territory_Boundary__c).add(acct);
		}
	}
	
	private static void unsyncActivities(Map<String, String> accountOwnerMap, Map<String, String> accountOldOwnerMap)
	{
		List<Task> tasks = new List<Task>();
		List<Event> events = new List<Event>();
		system.debug(accountOwnerMap);system.debug('##' + accountOldOwnerMap);
		for(Task task : [select Id, OwnerId, AccountId from Task where AccountId in :accountOwnerMap.keySet() and IsClosed = false and RecurrenceActivityId = null])
		{
			if(task.OwnerId == accountOwnerMap.get(task.AccountId))
			{
				task.OwnerId = accountOldOwnerMap.get(task.AccountId);
				tasks.add(task);
			}
		}

		for(Event event : [select Id, OwnerId, AccountId from Event where AccountId in :accountOwnerMap.keySet() and EndDateTime >= :DateTime.now()])
		{
			if(event.OwnerId == accountOwnerMap.get(event.OwnerId))
			{
				event.OwnerId = accountOldOwnerMap.get(event.OwnerId);
				events.add(event);
			}
		}
		
		if(tasks.size() > 0)
		{
			update tasks;
		}
		if(events.size() > 0)
		{
			update events;
		}
	}
	
	private static void syncActivities(Map<String, String> accountOwnerMap, Map<String, String> accountOldOwnerMap)
	{
		List<Task> tasks = new List<Task>();
		List<Event> events = new List<Event>();
		for(Task task : [select Id, OwnerId, AccountId from Task where AccountId in :accountOwnerMap.keySet() and IsClosed = false and RecurrenceActivityId = null])
		{
			if(task.OwnerId == AccountOldOwnerMap.get(task.AccountId))
			{
				task.OwnerId = accountOwnerMap.get(task.AccountId);
				tasks.add(task);
			}
		}

		for(Event event : [select Id, OwnerId, AccountId from Event where AccountId in :accountOwnerMap.keySet() and EndDateTime >= :DateTime.now()])
		{
			if(event.OwnerId == AccountOldOwnerMap.get(event.OwnerId))
			{
				event.OwnerId = accountOwnerMap.get(event.OwnerId);
				events.add(event);
			}
		}
		if(tasks.size() > 0)
		{
			update tasks;
		}
		if(events.size() > 0)
		{
			update events;
		}
	}

	private static void unsyncOpenOpps(Map<String, String> accountOwnerMap, Map<String, String> accountOldOwnerMap)
	{
		List<Opportunity> opps = new List<Opportunity>();
		for(Opportunity opp : [select Id, OwnerId, AccountId from Opportunity where AccountId in :accountOwnerMap.keySet() and IsClosed = false])
		{
			if(opp.OwnerId == accountOwnerMap.get(opp.AccountId))
			{
				opp.OwnerId = accountOldOwnerMap.get(opp.AccountId);
				opps.add(opp);
			}   
		}
		if(opps.size() > 0)
		{
			update opps;
		}
	}
	
	private static void syncOpenOpps(Map<String, String> accountOwnerMap)
	{
		List<Opportunity> opps = new List<Opportunity>();
		for(Opportunity opp : [select Id, OwnerId, AccountId from Opportunity where AccountId in :accountOwnerMap.keySet() and IsClosed = false])
		{
			String ownerId = accountOwnerMap.get(opp.AccountId);
			if(opp.OwnerId != ownerId)
			{
				opp.OwnerId = ownerId;
				opps.add(opp); 
			}
		}
		if(opps.size() > 0)
		{
			update opps;
		}
	}
	
	/*
	private static void unsyncContacts(Map<String, String> accountOwnerMap, Map<String, String> accountOldOwnerMap)
	{
		List<Contact> contacts = new List<Contact>();
		for(Contact contact : [select Id, OwnerId, AccountId from Contact where AccountId in :accountOwnerMap.keySet()])
		{
			if(contact.OwnerId == accountOwnerMap.get(contact.AccountId))
			{
				contact.OwnerId = accountOldOwnerMap.get(contact.AccountId);
				contacts.add(contact);
			} 
		}
		if(contacts.size() > 0)
		{
			update contacts;
		}
	}
	*/

	private static void syncContactsByCode(Map<String, String> accountOwnerMap, Map<String, String> accountOldOwnerMap){
		List<Contact> contacts = new List<Contact>();
		for(Contact contact : [select Id, OwnerId, AccountId from Contact where AccountId in :accountOwnerMap.keySet()])
		{
			if(contact.OwnerId == accountOldOwnerMap.get(contact.AccountId))
			{
				contact.OwnerId = accountOwnerMap.get(contact.AccountId);
				contacts.add(contact);
			} 
		}
		if(contacts.size() > 0)
		{
			update contacts;
		}
	}
	
	private static void syncContacts(Map<String, String> accountOwnerMap)
	{
		List<Contact> contacts = new List<Contact>();
		for(Contact contact : [select Id, OwnerId, AccountId from Contact where AccountId in :accountOwnerMap.keySet()])
		{
			String ownerId = accountOwnerMap.get(contact.AccountId);
			if(contact.OwnerId != ownerId)
			{
				contact.OwnerId = ownerId;
				contacts.add(contact);
			}
		}
		if(contacts.size() > 0)
		{
			update contacts;
		}
	}
	
	private static void calculateTerritoryFields(Map<String, List<Account>> acctMap, Map<String, List<Account>> oldAcctMap, List<Territory__c> territories)
	{
		for(Territory__c territory : [select Id, Territory_Type__c, RecordTypeId, Name, Number_Of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Id in :acctMap.keySet()])
		{
			List<Account> accounts = acctMap.get(territory.Id);
			Decimal accountCount = territory.Number_Of_Accounts__c == null ? accounts.size() : territory.Number_Of_Accounts__c + accounts.size();
			Decimal openOpps = territory.Number_Of_Open_Opps__c == null ? 0 : territory.Number_Of_Open_Opps__c;
			Decimal closedRevenue = territory.Closed_Revenue_YTD__c == null ? 0 : territory.Closed_Revenue_YTD__c;
			Decimal pipeGT50 = territory.Pipeline_Greater_Than_Percent50__c == null ? 0 : territory.Pipeline_Greater_Than_Percent50__c;
			Decimal pipeLT50 = territory.Pipeline_Less_Than_Percent50__c == null ? 0 : territory.Pipeline_Less_Than_Percent50__c;            
			for(Account acct : accounts)
			{
				openOpps += acct.Number_of_Open_Opps__c;
				closedRevenue += acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
				pipeGT50 += acct.Pipeline_GL_50__c;
				pipeLT50 += acct.Pipeline_LT_50__c;
			}
			if(oldAcctMap.containsKey(territory.Id))
			{
				List<Account> accts = oldAcctMap.get(territory.Id);
				if(accountCount >= accts.size())
				{
					accountCount -= accts.size();
				}    
				for(Account acct : accts)
				{
					if(openOpps >= acct.Number_Of_Open_Opps__c)
					{
						openOpps -= acct.Number_Of_Open_Opps__c;
					}
					Decimal revenue = acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
					if(closedRevenue >= revenue)
					{
						closedRevenue -= revenue;
					}
					if(pipeGT50 >= acct.Pipeline_GL_50__c)
					{
						pipeGT50 -= acct.Pipeline_GL_50__c;
					}
					if(pipeLT50 >= acct.Pipeline_LT_50__c)
					{
						pipeLT50 -= acct.Pipeline_LT_50__c;
					}    
				}
			}
			territory.Number_Of_Accounts__c = accountCount;
			territory.Number_of_Open_Opps__c = openOpps;
			territory.Closed_Revenue_YTD__c = closedRevenue;
			territory.Pipeline_Less_Than_Percent50__c = pipeLT50;
			territory.Pipeline_Greater_Than_Percent50__c = pipeGT50;
			territories.add(territory);       
		}
		
		for(Territory__c territory : [select Id, Name, RecordTypeId, Territory_Type__c, Number_Of_Accounts__c, Number_of_Open_Opps__c, Closed_Revenue_YTD__c, Pipeline_Less_Than_Percent50__c, Pipeline_Greater_Than_Percent50__c from Territory__c where Id in :oldAcctMap.keySet() and Id not in :acctMap.keySet()])
		{
			List<Account> accounts = oldAcctMap.get(territory.Id);
			
			Decimal accountCount = territory.Number_Of_Accounts__c == null ? 0 : territory.Number_Of_Accounts__c;
			Decimal openOpps = territory.Number_Of_Open_Opps__c == null ? 0 : territory.Number_Of_Open_Opps__c;
			Decimal closedRevenue = territory.Closed_Revenue_YTD__c == null ? 0 : territory.Closed_Revenue_YTD__c;
			Decimal pipeLT50 = territory.Pipeline_Less_Than_Percent50__c == null ? 0 : territory.Pipeline_Less_Than_Percent50__c;
			Decimal pipeGT50 = territory.Pipeline_Greater_Than_Percent50__c == null ? 0 : territory.Pipeline_Greater_Than_Percent50__c;
			if(accountCount >= accounts.size())
			{
				accountCount -= accounts.size();
			}
			for(Account acct : accounts)
			{
				if(openOpps >= acct.Number_of_Open_Opps__c)
				{
					openOpps -= acct.Number_of_Open_Opps__c;
				}
				Decimal accountClosedRevenue = acct.Closed_Revenue_YTD__c == null ? 0 : acct.Closed_Revenue_YTD__c;
				if(closedRevenue >= accountClosedRevenue)
				{
					closedRevenue -= accountClosedRevenue;
				}
				if(pipeGT50 >= acct.Pipeline_GL_50__c)
				{
					pipeGT50 -= acct.Pipeline_GL_50__c;
				}
				if(pipeLT50 >= acct.Pipeline_LT_50__c)
				{
					pipeLT50 -= acct.Pipeline_LT_50__c;
				}    
			}
			territory.Number_Of_Accounts__c = accountCount;
			territory.Number_of_Open_Opps__c = openOpps;
			territory.Closed_Revenue_YTD__c = closedRevenue;
			territory.Pipeline_Less_Than_Percent50__c = pipeLT50;
			territory.Pipeline_Greater_Than_Percent50__c = pipeGT50;
			territories.add(territory);
		}   
	}  
	
	//@future (callout=true)
	public static void getGeolocationCoordinates(Map<Id, List<Account>> acctNewMap, Map<Id, List<Account>> oldAcctMap) {
		// gather account info
		List<Account> accounts = [
			SELECT BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
				BillingLatitude, BillingLongitude
			FROM Account 
			WHERE id IN :acctNewMap.keySet()];

		List<Account> accountsToUpdate = new List<Account>();

		for (Account acc : accounts) {
			// create an address string
			String address = '';
			if (acc.BillingStreet != null)
				address += acc.BillingStreet +', ';
			if (acc.BillingCity != null)
				address += acc.BillingCity +', ';
			if (acc.BillingState != null)
				address += acc.BillingState +' ';
			if (acc.BillingPostalCode != null)
				address += acc.BillingPostalCode +', ';
			if (acc.BillingCountry != null)
				address += acc.BillingCountry;

			address = EncodingUtil.urlEncode(address, 'UTF-8');

			// build callout
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address=' + address + '&sensor=false');
			req.setMethod('GET');
			req.setTimeout(60000);

			try {
				// callout
				HttpResponse res = h.send(req);

				// parse coordinates from response
				JSONParser parser = JSON.createParser(res.getBody());
				Double latitude = null;
				Double longitude = null;
				while (parser.nextToken() != null) {
					if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
						(parser.getText() == 'location')) {
							parser.nextToken(); // object start
							while (parser.nextToken() != JSONToken.END_OBJECT) {
								String txt = parser.getText();
								parser.nextToken();
								if (txt == 'lat')
									latitude = parser.getDoubleValue();
								else if (txt == 'lng')
									longitude = parser.getDoubleValue();
						}
					}
				}

				// update coordinates if we get back
				if (latitude != null) {
					acc.BillingLatitude  = latitude;
					acc.BillingLongitude = longitude;
					accountsToUpdate.add(acc);
				}

			} catch (Exception e) {
			}
		}

		update accountsToUpdate;
	}


	public static Integer triggerExecuted = 0;  
}