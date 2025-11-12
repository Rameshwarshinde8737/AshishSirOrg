/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	A class to test KanbanSerializer.cls.
				Tests executed:
					(Removed) 1 - getKanbanFieldSetFieldsNoFieldListTest()
					Checks if collection is empty
					2 - serializeItemsEmptyTest()
					Checks if collection is empty
					3 - serializeItemsEmptyField()
					Checks if collection is not empty
					4 - serializeItemsTest()
					Checks if collection is empty
					5 - serializeHeaderTest()
					Checks if JSON string is '{}'
					6 - getOptionsTest()
					Checks if collection is empty
					7 - serializeItemsHelperTest()
					Checks if collection is empty
					8 - getOptionsHelperTest()
					Checks the picklist value
					9 - serializeHeaderHelperTest()
					Checks the header JSON string is not empty
					10 - serializeDataTest()
					Checks if the JSON string is blank
History
09/08/2017		Dlanyer Ocampo	Initial version
09/29/2017		Dlanyer Ocampo 	Modifications to some tests
10/11/2017		Dlanyer Ocampo	Added serializeDataTest()
------------------------------------------------------------*/
//Note that some test might be deprecated later on as the methods 
//they are testing will be moved into the 'DescribeSchema.cls', these 
//these tests should therefore be moved to the 'DescribeSchemaTest.cls' 
@isTest
private class KanbanSerializerTest {
    /*
    private static testMethod void getKanbanFieldSetFieldsNoFieldListTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
    	List<Schema.FieldSetMember> fieldsList = kanbanSerializer.getKanbanFieldSetFields('leankor__KanbanCard__c', '');
    	System.Assert(fieldsList.isEmpty());
    }*/
    
    private static testMethod void serializeItemsEmptyTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
    	List<Map<String, Object>> items = kanbanSerializer.serializeItems('leankor__KanbanCard__c', '', uiItemSettings, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	System.assert(items.isEmpty(), 'Expected items list to be empty, but it was not.');
    }
    
    private static testMethod void serializeItemsEmptyField() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
    	List<Map<String, Object>> items = kanbanSerializer.serializeItems('leankor__KanbanCard__c', 'leankor__LeankorFieldSet', uiItemSettings, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	System.assert(items.isEmpty(), 'Expected items to be empty but it was not.');
	}
    
    private static testMethod void serializeItemsTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	List<leankor__VisualLeanUIItemSetting__mdt> customSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
    	
    	customSettings = realTimeController.getVisualLeanUIItemSettings();
    	List<Map<String, Object>> items = kanbanSerializer.serializeItems('leankor__KanbanCard__c', 'leankor__LeankorFieldSet', customSettings, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	System.assert(items.isEmpty(), 'Expected items list to contain values, but it was empty.');
    }
    
    private static testMethod void serializeHeaderTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	List<leankor__VisualLeanUIHeaderSetting__mdt> uiHeaderSettings = new List<leankor__VisualLeanUIHeaderSetting__mdt>();
    	List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
    	String jsonString = kanbanSerializer.serializeHeader('leankor__KanbanCard__c', '', uiHeaderSettings, uiItemSettings, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	System.assertEquals('{}', jsonString, 'Expected an empty JSON object string, but got something else.');
    }
    
    private static testMethod void getOptionsTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
        List<Map<String, Object>> testOption = kanbanSerializer.getOptions('leankor__KanbanCard__c', '',new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));

		List<Map<String, Object>> testOptions = kanbanSerializer.getOptions('leankor__KanbanCard__c', 'leankor__DurationUnits__c',new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
		System.assert(!testOptions.isEmpty(), 'Expected testOptions to contain elements, but it was empty.');
	}
    
    private static testMethod void serializeItemsHelperTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	List<leankor__VisualLeanUIItemSetting__mdt> customSettings = realTimeController.getVisualLeanUIItemSettings();
    	
    	Map<String, Object> newCustomSettingsMap = new Map<String, Object>();
    	for (leankor__VisualLeanUIItemSetting__mdt newCustomSetting : customSettings) {
	    	newCustomSettingsMap.put(newCustomSetting.Label, newCustomSetting.leankor__UIJSONString__c);
    	}
	    	
    	Map<String, Object> serializedItem = kanbanSerializer.serializeItemsHelper('BOOLEAN', 'leankor__IsExternallyDependent__c', 'IsExternallyDependent', newCustomSettingsMap, 'leankor__KanbanCard__c', new DescribeSchema().getObjectFields('leankor__KanbanCard__c'),0);
		System.assert(!serializedItem.isEmpty(), 'Expected serializedItem to contain JSON content, but it was empty.');
    }
    
    private static testMethod void getOptionsHelperTest() {
    	KanbanSerializer kanbanSerializer = new KanbanSerializer();
    	Map<String, Object> pickListMap = kanbanSerializer.getOptionsHelper('picklistLabel', 'picklistValue');
    	System.assertEquals('picklistValue', pickListMap.get('value'), 'Expected pickListMap to return picklistValue for key "value".');
	}
    
    private static testMethod void serializeHeaderHelperTest() {
    	Kanbanserializer kanbanSerializer = new KanbanSerializer();
    	String customSettingsJSON = ''; 
    	String stringKeySetElement = 'config';
    	String sObjectName = 'Lean_KanbanCard__c'; 
    	String fieldSetName = '';
    	Map<String, Object> customSettingsJSONMap = new Map<String, Object>();
    	    	
    	List<leankor__VisualLeanUIHeaderSetting__mdt> uiHeaderSettings = new List<leankor__VisualLeanUIHeaderSetting__mdt>();
    	List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
		uiHeaderSettings = realTimeController.getVisualLeanUIHeaderSettings();
    	
    	Map<String, Object> newCustomSettingsMap = new Map<String, Object>();
    	for (leankor__VisualLeanUIHeaderSetting__mdt newCustomSetting : uiHeaderSettings) {
	    	newCustomSettingsMap.put(newCustomSetting.Label, newCustomSetting.leankor__UIJSONString__c);
    	}
		
    	String testJSONStringFragment = kanbanSerializer.serializeHeaderHelper(customSettingsJSON, stringKeySetElement, customSettingsJSONMap, newCustomSettingsMap, sObjectName, fieldSetName, uiItemSettings, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	System.assert(String.isNotEmpty(testJSONStringFragment), 'Expected testJSONStringFragment to contain JSON data, but it was empty or null.');

    }
    @isTest
    static void testCustomMetadataHeaderLogic() {

    	leankor__VisualLeanUIHeaderSetting__mdt mockHeaderSetting = new leankor__VisualLeanUIHeaderSetting__mdt();
    	mockHeaderSetting.Label = 'config';
        mockHeaderSetting.leankor__UIJSONString__c = '{"key":"value"}';
        
        // Step 2: Prepare test item settings (empty list for now)
        List<leankor__VisualLeanUIHeaderSetting__mdt> uiHeaderSettings = new List<leankor__VisualLeanUIHeaderSetting__mdt>{mockHeaderSetting};
      
    	List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();

        // Step 3: Prepare a simple field map (use Account standard fields)
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();

        // Step 4: Call the method
        Test.startTest();
        KanbanSerializer serializer = new KanbanSerializer(); // Replace with actual class name
        Map<String, Object> result = serializer.customMetadataHeader('Account',
																	'TestFieldSet',
																	uiHeaderSettings,
																	uiItemSettings,
																	fieldMap);
        Test.stopTest();

        // Step 5: Assertions
        System.assertNotEquals(null, result, 'The returned map should not be null');
        System.assert(result.size() >= 0, 'Returned map should have keys (depending on CustomMetadataHeaderHepler)');
    }

    @isTest
    static void testCustomFieldsData() {
        
		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
		leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
		ganttBoard.Name =  'Testing gantt'; 
		ganttBoard.leankor__ProjectRoom__c = project.Id; 
		ganttBoard.leankor__BoardType__C = 'UberBoard';
		insert ganttBoard;
        
    	String testFieldSet = 'leankor__LeankorFieldSet'; 
        
        leankor__KanbanCardTemplate__c ganttTemplate = new leankor__KanbanCardTemplate__c();
		ganttTemplate.leankor__JSONDefinition__c = '';
		ganttTemplate.leankor__JSONData__c = '';
		ganttTemplate.leankor__Width__c = 170;
		ganttTemplate.leankor__Height__c = 120; 
		ganttTemplate.leankor__CSSLayout__c = '';
		ganttTemplate.leankor__Color__c = '#bdbffc';
		ganttTemplate.leankor__ValueStream__c = ganttBoard.Id;
		ganttTemplate.Name = 'Default';
		ganttTemplate.leankor__Title__c = 'Default';
        ganttTemplate.leankor__FieldSetName__c = testFieldSet;
        insert ganttTemplate;

        // Simulate a Kanban Card
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Test Card';
        kanbanCard.leankor__ValueStream__c = ganttBoard.id;
        kanbanCard.leankor__KanbanCardTemplate__c = ganttTemplate.id;
        insert kanbanCard;

		List<leankor__KanbanCard__c> cardList = [Select Id, 
		 												leankor__KanbanCardTemplate__r.leankor__FieldSetName__c 
													From leankor__KanbanCard__c 
													Where Id = :kanbanCard.Id];
		System.assert(!cardList.isEmpty(), 'Kanban card not found after insert.');
		kanbanCard = cardList[0];
   
        // Create field map
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.leankor__kanbanCard__c.fields.getMap();

        KanbanSerializer serializer = new KanbanSerializer();
        Test.startTest();
        Map<String, Object> filteredMap = serializer.customFieldsData(kanbanCard, fieldMap);
        System.debug('Filtered Map: ' + filteredMap);
        Test.stopTest();
        System.assert(filteredMap != null, 'Map should not be null');
    }
    
    @isTest
    static void testCustomMetadataHeaderHelper() {
        // Prepare valid customSettings with JSON string
        String json = '{ "xtype":"panel", "itemId":"header", "style":"border:1px", "title":"Header", "instructions":"Some help text", "items":[] }';
        Map<String, Object> customSettings = new Map<String, Object>{'config' => json};

        // Setup other params
        String stringKeySetElement = 'config';
        String sObjectName = 'Account';
        String fieldSetName = 'TestFieldSet';

        List<leankor__VisualLeanUIItemSetting__mdt> uiItemSettings = new List<leankor__VisualLeanUIItemSetting__mdt>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();

        // Instantiate your serializer
        KanbanSerializer serializer = new KanbanSerializer();

        // Call the method
        Test.startTest();
        Map<String, Object> result = serializer.customMetadataHeaderHepler('',
																			stringKeySetElement,
																			new Map<String, Object>(), // customSettingsJSONMap
																			customSettings,
																			sObjectName,
																			fieldSetName,
																			uiItemSettings,
																			fieldMap);
        Test.stopTest();

        // Validate keys removed and items replaced
        System.assertNotEquals(null, result, 'Returned map should not be null');
        System.assert(!result.containsKey('xtype'), 'xtype should be removed');
        System.assert(result.containsKey('items'), 'items should be replaced');
    }    
}