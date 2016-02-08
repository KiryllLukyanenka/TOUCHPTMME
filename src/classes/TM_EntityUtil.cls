public class TM_EntityUtil 
{
    public class ConfigInfo
    {
        public String CatchAllName { get; set; }
        public String CatchAllOwner { get; set; }
        public Boolean IncludeContacts { get; set; }
        public Boolean IncludeOpenOpps { get; set; }
        public Boolean IncludeActivities { get; set; }
        public String UseApproval { get; set; }
        public String Approver { get; set; }
        public String BillingShippingAddress { get; set; }
        public String TerritorySnapshot { get; set; }

        public ConfigInfo(String catchAllName, String catchAllOwner, Boolean includeContacts, Boolean includeOpenOpps, Boolean includeActivities, String useApproval, String approver, String billingShippingAddress, String territorySnapshot)
        {
            this.CatchAllName = catchAllName;
            this.CatchAllOwner = catchAllOwner;
            this.IncludeContacts = includeContacts;
            this.IncludeOpenOpps = includeOpenOpps;
            this.IncludeActivities = includeActivities;
            this.UseApproval = useApproval;
            this.Approver = approver;
            this.BillingShippingAddress = billingShippingAddress;
            this.TerritorySnapshot = territorySnapshot;
        }
        public ConfigInfo() { }
    }

    public class ChangeSetInfo
    {
        public String ChangeSetId { get; set; }
        public String Name { get; set; }
        public String EffectiveDate { get; set; }
        public String Comment { get; set; }
        public String Owner { get; set; }
        public String CreatedBy { get; set; }
        public String Status { get; set; }
        public String SubmittedBy { get; set; }
        public String SubmitDate { get; set; }
        public String Approver { get; set; }
        public String ApproveDate { get; set; }

        public ChangeSetInfo(String changeSetId, String name, String effectiveDate, String comment, String owner, String createdBy, String status, String submittedBy, String submitDate, String approver, String approveDate)
        {
            this.ChangeSetId = changeSetId;
            this.Name = name;
            this.EffectiveDate = effectiveDate;
            this.Comment = comment;
            this.Owner = owner;
            this.CreatedBy = createdBy;
            this.Status = status;
            this.SubmittedBy = submittedBy;
            this.SubmitDate = submitDate;
            this.Approver = approver;
            this.ApproveDate = approveDate;
        }
        public ChangeSetInfo() { }
    }

    public class AccountCriteriaInfo
    {
        public String Label { get; set; }
        public String Operator { get; set; }
        public String Value { get; set; }

        public AccountCriteriaInfo(String label, String operator, String value)
        {
            this.Label = label;
            this.Operator = operator;
            this.Value = value;
        }
    }

    public class TerrInfo
    {
        public String Name { get; set; }
        public String Owner { get; set; }
        public String EffectiveDate { get; set; }
        public String Description { get; set; }

        public TerrInfo(String name, String owner, String effectiveDate, String description)
        {
            this.Name = name;
            this.Owner = owner;
            this.EffectiveDate = effectiveDate;
            this.Description = description;
        }
        public TerrInfo() { }
    }

    public class AssignmentInfo
    {
        public String AssignmentId { get; set; }
        public String Country { get; set; }
        public String State { get; set; }
        public String PostalStart { get; set; }
        public String PostalEnd { get; set; }

        public AssignmentInfo(String country, String state, String postalStart, String postalEnd)
        {
            this.Country = country;
            this.State = state;
            this.PostalStart = postalStart;
            this.PostalEnd = postalEnd;
        }
        public AssignmentInfo() { }
    }

    public class AccountInfo
    {
        public String Name { get; set; }
        public String Territory { get; set; }
        public String Country { get; set; }
        public String State { get; set; }
        public String PostalCode { get; set; }

        public AccountInfo(String name, String territory, String country, String state, String postalCode)
        {
            this.Name = name;
            this.Territory = territory;
            this.Country = country;
            this.State = state;
            this.PostalCode = postalCode;
        }
        public AccountInfo() { }
    }
}