global class TM_GlobalVariables 
{
    global static Map<String, Schema.DisplayType> FieldTypeMap = new Map<String, Schema.DisplayType>();
    global static Map<String, Schema.DescribeFieldResult> descirbeFieldResultMap = new Map<String, Schema.DescribeFieldResult>();

    static
    {
        Map<String, Schema.sObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        for(String field : fieldMap.keySet())
        {
            Schema.DescribeFieldResult fieldResult = fieldMap.get(field).getDescribe();
            FieldTypeMap.put(fieldResult.getName(), fieldResult.getType());   
        }

        Map<String, Schema.sObjectField> accountFieldMap = Schema.SObjectType.Account.fields.getMap();
        for(String field : accountFieldMap.keySet())
        {
            Schema.DescribeFieldResult fieldResult = accountFieldMap.get(field).getDescribe();
            String fieldName = fieldResult.getName();
            Set<String> fields = new Set<String> { 'LastViewedDate', 'LastReferencedDate', 'LastActivityDate', 'IsDeleted', 'Id', 'Name', 'BillingStreet', 'BillingCountryCode', 'BillingLatitude', 'BillingLongitude', 'BillingStateCode', 'BillingCountry', 'BillingState', 'BillingPostalCode', 'ShippingStreet', 'ShippingCountry', 'ShippingCountryCode', 'ShippingLatitude', 'ShippingLongitude', 'ShippingStateCode', 'ShippingStreet', 'ShippingState', 'ShippingPostalCode', 'Territory__c', 'New_Territory__c', 'Territory_Boundary__c', 'No_Territory_Assignment__c', 'LastViewedDate', 'Last' };
            if(!fields.contains(fieldName))
            {
                TM_GlobalVariables.descirbeFieldResultMap.put(fieldResult.getLabel(), fieldResult);
            }   
        }
    }
}