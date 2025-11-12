@isTest
private class GetObjectFieldsetActionTest {
    
    @isTest
    static void testGetCustomFieldSet() {
        // Creating test data
      leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'Test Value Stream');
      insert valueStream;
        
        // Preparing the record ID list
        List<Id> recordIds = new List<Id> { valueStream.Id };

        // Invoking the method
        List<GetObjectFieldsetAction.FieldSetData> fieldSetDataList = GetObjectFieldsetAction.getCustomFieldSet(recordIds);
        
        // Validating the results
        for (GetObjectFieldsetAction.FieldSetData fieldSetData : fieldSetDataList) {
            System.assertNotEquals(null, fieldSetData.label, 'Label should not be null');
            System.assertNotEquals(null, fieldSetData.fieldName, 'Field Name should not be null');
            System.assertNotEquals(null, fieldSetData.fieldApiName, 'Field API Name should not be null');
            System.assertNotEquals(null, fieldSetData.objectName, 'Object Name should not be null');
        }
    }

    @isTest
    static void testReadObjectFieldSetWithMultipleObjects() {
        // Creating test data
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'Test Value Stream');
        insert valueStream;

        leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c();
            testKanbanCard.Name = 'TestCard';
            testKanbanCard.leankor__DurationUnits__c = 'Days';
            testKanbanCard.leankor__EstimatedDuration__c = 1;
            testKanbanCard.leankor__StartDateTime__c = System.now();
            testKanbanCard.leankor__DueDateTime__c = System.now().addDays(1);
            testKanbanCard.leankor__ValueStream__c = valueStream.Id;
       
		insert testKanbanCard;

        // Preparing the object names set
        Set<String> objectNames = new Set<String> { 'leankor__ValueStream__c', 'leankor__KanbanCard__c' };

        // Invoking the method
        List<GetObjectFieldsetAction.FieldSetData> fieldSetDataList = GetObjectFieldsetAction.readObjectFieldSet(objectNames);
        
        // Validating the results
        System.assertNotEquals(0, fieldSetDataList.size(), 'FieldSetData list should not be empty');
        for (GetObjectFieldsetAction.FieldSetData fieldSetData : fieldSetDataList) {
            System.assertNotEquals(null, fieldSetData.label, 'Label should not be null');
            System.assertNotEquals(null, fieldSetData.fieldName, 'Field Name should not be null');
            System.assertNotEquals(null, fieldSetData.fieldApiName, 'Field API Name should not be null');
            System.assertNotEquals(null, fieldSetData.objectName, 'Object Name should not be null');
        }
    }

    @isTest
    static void testReadObjectFieldSet() {
        // Invoking the method with a single object name
        Map<String, Schema.FieldSet> fieldSetMap = GetObjectFieldsetAction.readObjectFieldSet('Account');
        
        // Validating the results
        System.assertNotEquals(null, fieldSetMap, 'FieldSet map should not be null');
      
    }
    
    @isTest
    static void testEmptyRecordIds() {
        // Invoking the method with empty record IDs
        List<Id> emptyRecordIds = new List<Id>();
        List<GetObjectFieldsetAction.FieldSetData> fieldSetDataList = GetObjectFieldsetAction.getCustomFieldSet(emptyRecordIds);

        // Validating the results
        System.assertEquals(0, fieldSetDataList.size(), 'FieldSetData list should be empty');
    }

    @isTest
    static void testInvalidObjectName() {
        Test.startTest();
        try {
            // Invoking the method with an invalid object name
            GetObjectFieldsetAction.readObjectFieldSet('InvalidObjectName');
            System.assert(false, 'Exception should have been thrown for invalid object name');
        } catch (Exception e) {
           //System.assert(e.getMessage().contains('Invalid'), 'Expected exception message to contain "Invalid"');
        }
        Test.stopTest();
    }
}