/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	A class to test UpdateInjector.cls.
				Tests executed:
					1 - objectMapperTest()
					Accesses an object within a map
					2 - getFieldTypeTest()
					Accesses field type
					3 - updateKanbanCardChangeValueTest()
					Checks if the field is updated
					(no longer used) 4 - getObjectFieldsTest()
					Checks if the collection is not empty
					5 - isAccessibleTest()
					Checks accessibility
					(no longer used) 6 - isUpdateableTest()
					Checks updatability
History
09/08/2017		Dlanyer Ocampo	Initial version
09/29/2017		Dlanyer Ocampo 	Modifications to some tests
------------------------------------------------------------*/
@isTest
private class UpdateInjectorTest {
    
    private static testMethod void objectMapperTest() {
    	UpdateInjector updateInjector = new UpdateInjector();
		String JSONData = '{"region":"123","grapes":"type grape","notes":"testing"}';
    	Map<String, Object> dataMapped = updateInjector.objectMapper(JSONData);
    	String value = String.valueOf(dataMapped.get('region'));
    	System.assertEquals('123', value);
    }
    
    private static testMethod void getFieldTypeTest() {
    	UpdateInjector updateInjector = new UpdateInjector();
    	SObjectType sobjectObject = Schema.getGlobalDescribe().get('leankor__KanbanCard__c');
		Map<String, Schema.SObjectField> fieldMap = sobjectObject.getDescribe().fields.getMap();
    	String fieldType = String.valueOf(updateInjector.getFieldType(fieldMap, 'Name'));
    	System.assertEquals('STRING', fieldType);
    }
    
     private static testMethod void updateKanbanCardChangeValueTest() {
    	UpdateInjector updateInjector = new UpdateInjector();
    	leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c(Name = 'OldName');
    	String JSONData = '{"Name":"NewName"}';
    		
    	// rbo 10.27.17
    	// leankor__KanbanCard__c updatedKanbanCard = updateInjector.updateKanbanCard(kanbanCard, JSONData);
    	leankor__KanbanCard__c updatedKanbanCard = updateInjector.updateKanbanCard(kanbanCard, JSONData, new DescribeSchema().getObjectFields('leankor__KanbanCard__c'));
    	// rbo 10.27.17
    	
    	System.assertEquals('OldName', updatedKanbanCard.Name);
    }
    
    // DCO 10.26.17 no longer used
    /*
    private static testMethod void getObjectFieldsTest() {
    	UpdateInjector updateInjector = new UpdateInjector();
    	Map<String, Schema.SObjectField> objectFields = updateInjector.getObjectFields('leankor__KanbanCard__c');
    	System.assert(!objectFields.isEmpty());
    	
    }
    */
    // DCO 10.26.17
    /*private static testMethod void isAccessibleTest() {
     	UpdateInjector updateInjector = new UpdateInjector();
     	// rbo 10.27.17
     	// Map<String, Schema.SObjectField> objectFields = updateInjector.getObjectFields('leankor__KanbanCard__c');
     	Map<String, Schema.SObjectField> objectFields = new DescribeSchema().getObjectFields('leankor__KanbanCard__c');
     	// rbo 10.27.17
     	boolean accessibility = updateInjector.isAccessible(objectFields, 'Name');
     	System.assert(accessibility);
    } */
    
    // DCO 10.26.17 no longer used
    /*
    private static testMethod void isUpdateableTest() {
     	UpdateInjector updateInjector = new UpdateInjector();
     	Map<String, Schema.SObjectField> objectFields = updateInjector.getObjectFields('leankor__KanbanCard__c');
     	boolean updateability = updateInjector.isUpdateable(objectFields, 'Name');
     	System.assert(updateability);
   	}
    */
    // DCO 10.26.17
}