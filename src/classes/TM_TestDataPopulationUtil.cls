/*
 ** It is used to create Data which is used in test methods.
 ** Written by Joyce.
 */
public class TM_TestDataPopulationUtil 
{
    private static User user = [select Id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1];
    public static String namespace = [select NamespacePrefix from ApexClass where Name = 'TM_ConfigController'].NamespacePrefix;
    public static void abortJobs()
    {
        for(CronTrigger job : [select Id from CronTrigger where NextFireTime != null])
        {
            system.abortJob(job.Id);
        }
    }
    /*
     ** Create a Config.
     */
    public static Territory_Config__c createTerritoryConfig()
    {
        Territory_Config__c config = new Territory_Config__c(Catch_All_Territory_Name__c = 'Catch All', Catch_All_Territory_Owner__c = user.Id, Include_Contacts__c = true, Include_Open_Opps__c = true, Include_Open_Activities__c = true, Use_Approval_Process__c = 'Yes', Approver__c = user.Id, Billing_Shipping_Address__c = 'Billing', Territory_Snapshots__c = 'Weekly');
        insert config;
        return config;
    }
    
    /*
     ** Create a change set.
     */
    public static Territory_Change_Box__c createChangeSet(String status, Date effectiveDate)
    {
        Territory_Change_Box__c changeSet = new Territory_Change_Box__c(Name = 'Acme 001', Effective_Date__c = effectiveDate, Status__c = status, SubmittedBy__c = UserInfo.getUserId(), Approver__c = UserInfo.getUserId(), Last_Comment__c = 'Comment');
        insert changeSet;
        return changeSet;
    }

    /*
     ** Create Catch All Territory.
     */
    public static Territory__c createCatchAllTerritory(String recordTypeId, String currentOwner)
    {
        Territory__c catchAllTerritory = new Territory__c(Name = 'Catch All Acme', RecordTypeId = recordTypeId, Territory_Type__c = 'Catch All', Current_Owner__c = currentOwner);
        insert catchAllTerritory;
        return catchAllTerritory;
    }

    /*
     ** Create a Territory.
     */
    public static Territory__c createTerritory(String changeSetId)
    {
        Territory__c territory = new Territory__c(Name = 'Acme 001', New_Owner__c = user.Id, Current_Owner__c = user.Id, Territory_Change_Box__c = changeSetId);
        insert territory;
        return territory;
    }

    /*
     ** Create a Territory Boundary.
     */
    public static Territory_Boundary__c createTerritoryBoundary(String territoryId, String status, Boolean isEffective)
    {
        Territory_Boundary__c boundary = new Territory_Boundary__c(Status__c = status, Territory__c = territoryId, IsEffective__c = isEffective);
        insert boundary;
        return boundary;
    }

    /*
     ** Create a Territory Owner.
     */
    public static Territory_Owner__c createTerritoryOwner(String territoryId, String status, Boolean isEffective)
    {
        Territory_Owner__c owner = new Territory_Owner__c(Status__c = status, Territory__c = territoryId, IsEffective__c = isEffective);
        insert owner;
        return owner;
    }

    /*
     ** Create a Assignment.
     */
    public static Assignment_Detail__c createAssignment(String territoryBoundaryId)
    {
        Assignment_Detail__c assignment = new Assignment_Detail__c(Country__c = 'CN', Territory_Assignment__c = territoryBoundaryId);
        insert assignment;
        return assignment;
    }

    public static Assignment_Detail__c createAssignment(String territoryBoundaryId, String country, String state, String postalStart, String postalEnd)
    {
        Assignment_Detail__c detail = new Assignment_Detail__c(Territory_Assignment__c = territoryBoundaryId, Country__c = country, State__c = state, Postal_Start__c = postalStart, Postal_End__c = postalEnd);
        insert detail;
        return detail;
    }

    /*
     ** Create a Exception Account.
     */
    public static ExceptionAccount2TerritoryBoundary__c createExceptionAccount(String territoryBoundaryId)
    {
        Account acct = new Account(Name = 'Acme 001', BillingCountry = 'CN');
        insert acct;
        ExceptionAccount2TerritoryBoundary__c accountToBoundary = new ExceptionAccount2TerritoryBoundary__c(Exception_Account__c = acct.Id, Territory_Boundary__c = territoryBoundaryId);
        insert accountToBoundary;
        return accountToBoundary;
    }

    /*
     ** Create an Account.
     */
    public static Account createAccount(String name, String country, String state, String postalCode, String territoryId)
    {
        Account acct = new Account(Name = name, BillingCountry = country, ShippingCountry = country, BillingState = state, ShippingState = state, BillingPostalCode = postalCode, ShippingPostalCode = postalCode, Territory__c = territoryId, No_Territory_Assignment__c = false);
        insert acct;
        return acct;
    }

    /*
     ** Create an Contact.
     */
    public static Contact createContact(String name, String accountId)
    {
        Contact contact = new Contact(LastName = name, AccountId = accountId);
        insert contact;
        return contact;
    }

    /*
     ** Create an Opportunity.
     */

    public static Opportunity createOpportunity(String name, String accountId, Date closeDate, String stageName, Decimal probability, Decimal amount)
    {
        Opportunity opp = new Opportunity(Name = name, AccountId = accountId, CloseDate = closeDate, StageName = stageName, Probability = probability, Amount = amount);
        insert opp;
        return opp;
    }

    /*
     ** Create an Event.
     */
    public static Event createEvent(String whatId)
    {
        DateTime activityTime = DateTime.now().addDays(1);
        Event event = new Event(WhatId = whatId, ActivityDateTime = activityTime, StartDateTime = activityTime, DurationInMinutes = 60, Subject = 'Meeting', OwnerId = user.Id);
        insert event;
        return event;
    }

    /*
     ** Create an Task.
     */
    public static Task createTask(String whatId)
    {
        Task task = new Task(WhatId = whatId, OwnerId = user.Id, Subject = 'Call', Priority = 'Normal', Status = 'Not Started');
        insert task;
        return task;
    }
    
    /* 
     ** Get Catch All RecordTypeId.
     */
    public static String getCatchAllRecordTypeId()
    {
        String objectName = String.isNotBlank(namespace) ? namespace + '__Territory__c' : 'Territory__c';
        return [select Id from RecordType where sObjectType = :objectName and Name = 'Catch All' limit 1].Id;
    }

    /*
     ** Create a AccountCriteria
     */
    public static AccountCriteria__c createAccountCriteria(Id territoryId, String field, String label, String operator, String value)
    {
        AccountCriteria__c acctCriteria = new AccountCriteria__c(Territory__c = territoryId, Field__c = field, Label__c = label, Operator__c = operator, Value__c = value);
        insert acctCriteria;
        return acctCriteria;
    }
}