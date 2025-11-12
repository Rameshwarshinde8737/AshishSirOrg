public with sharing class FinancialDataSourceFieldsets extends VisualEditor.DynamicPickList{
    public override VisualEditor.DataRow getDefaultValue(){
    	DescribeSchema ds = new DescribeSchema();
		List<Schema.FieldSet> fieldSets = ds.getFieldSets('leankor__Expense__c').values();
    	VisualEditor.DataRow defaultValue;
    	if (fieldSets.isEmpty()) {
        	defaultValue = new VisualEditor.DataRow('', '');
    	}else {
    		if(String.isNotBlank(fieldSets[0].getNamespace())) {
    			defaultValue = new VisualEditor.DataRow(fieldSets[0].getLabel(), fieldSets[0].getNamespace() + '__' + fieldSets[0].getName());
    		}else {
    			defaultValue = new VisualEditor.DataRow(fieldSets[0].getLabel(), fieldSets[0].getName());
    		}
    	}
        return defaultValue;
    }

    public override VisualEditor.DynamicPickListRows getValues() {
    	DescribeSchema ds = new DescribeSchema();
		List<Schema.FieldSet> fieldSets = ds.getFieldSets('leankor__Expense__c').values();
    	VisualEditor.DynamicPickListRows  pickListValues = new VisualEditor.DynamicPickListRows();
    	for(Schema.FieldSet fieldSetElement : fieldSets) {
    		VisualEditor.DataRow value;
    		if(String.isNotBlank(fieldSets[0].getNamespace())) {
    			value = new VisualEditor.DataRow(fieldSetElement.getLabel(), fieldSetElement.getNamespace() + '__' + fieldSetElement.getName());
    		}else {
    			value = new VisualEditor.DataRow(fieldSetElement.getLabel(), fieldSetElement.getName());
    		}
    		pickListValues.addRow(value);
    	}
        return pickListValues;
    }
}