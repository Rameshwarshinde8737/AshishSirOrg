@isTest
private class FinancialDataSourceFieldsetsTest {
    
    @isTest
    static void testGetDefaultValueAndGetValues() {
        Test.startTest();

        FinancialDataSourceFieldsets dataSourceFieldsets = new FinancialDataSourceFieldsets();
        
        // Call getDefaultValue
        VisualEditor.DataRow defaultRow = dataSourceFieldsets.getDefaultValue();
        System.assertNotEquals(null, defaultRow, 'Default value row should not be null');
        System.assertNotEquals(null, defaultRow.getLabel(), 'Label should not be null');
        System.assertNotEquals(null, defaultRow.getValue(), 'Value should not be null');

        // Call getValues
        VisualEditor.DynamicPickListRows rows = dataSourceFieldsets.getValues();
        System.assertNotEquals(null, rows, 'Picklist rows should not be null');

        // You may want to check number of rows if known (optional)
        // System.assert(rows.getRows().size() > 0, 'There should be at least one field set row returned');
        
        Test.stopTest();
    }
}