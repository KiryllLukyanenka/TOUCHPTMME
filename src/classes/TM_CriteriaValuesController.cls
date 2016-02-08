/*
 ** This is the controller of TM_CriteriaValues page. When we create/edit an criteria, if the field is an picklist/multipicklist/boolean,
 ** it will redirect to this page to allow the user select values.
 ** Written by Joyce. 2013/11/12.
 */
public class TM_CriteriaValuesController
{
    public List<FieldValue> FieldValues { get; set; }
    public String IsEdit { get; set; }
    public Boolean IsRadioButton { get; set; }

    public TM_CriteriaValuesController()
    {
        FieldValues = new List<FieldValue>();
        IsRadioButton = false;
        IsEdit = apexPages.currentPage().getParameters().get('isEdit');
        String acctField = apexPages.currentPage().getParameters().get('fieldLabel');
        String valueString = apexPages.currentPage().getParameters().get('fieldValue');
        Schema.DescribeFieldResult result = TM_GlobalVariables.descirbeFieldResultMap.get(acctField);
        if(result != null)
        {
            constructFieldValues(result, valueString);
        }
    }

    public class FieldValue
    {
        public Boolean IsChecked { get; set; }
        public String Field { get; set; } 
        public FieldValue(String field)
        {
            this.IsChecked = false;
            this.Field = field;
        }
    }

    private void constructFieldValues(Schema.DescribeFieldResult result, String valueString)
    {
        if(result.getType() == Schema.DisplayType.Boolean)
        {
            IsRadioButton = true;
            FieldValues.addAll(new List<FieldValue> { new FieldValue('True'), new FieldValue('False')});
            if(valueString != null && valueString != '' && valueString.trim().toLowerCase() == 'false')
            {
                FieldValues[1].IsChecked = true;
            }
            else
            {
                FieldValues[0].IsChecked = true;
            }
        }
        else
        {
            Set<String> values = new Set<String>();
            if(valueString != null && valueString != '')
            {
                for(String split : valueString.split(','))
                {
                    values.add(split.trim());
                }
            }
            for(PicklistEntry entry : result.getPicklistValues())
            {
                FieldValue fieldValue = new FieldValue(entry.getValue());
                if(values.contains(entry.getValue()))
                {
                    fieldValue.IsChecked = true;
                }
                FieldValues.add(fieldValue);
            }
        }
    }
}