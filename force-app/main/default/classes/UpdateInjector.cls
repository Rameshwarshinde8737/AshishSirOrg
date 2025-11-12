/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	Class that injects code into existing code.
Inputs: 		None
Test Class: 	UpdateInjectorTest.cls
History
09/08/2017		Dlanyer Ocampo	Initial version
------------------------------------------------------------*/
//Names of classes may need to be renamed to suit to their
//class usage in the future
//Since a lot of these methods will have to be moved into
//the 'DescribeSchema.cls' UpdateInjector should inherit
//DescribeSchema.cls
public with sharing class UpdateInjector extends DescribeSchema {
    public UpdateInjector() {}
	
	private final string NAMESPACE = 'leankor__';	
	
	//Note this method should be moved into the 'DescribeSchema.cls'
	//for general use in the future
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Maps an object's fields.
	Inputs: 		Object anObject (should be string actually)
	Returns: 		Map<String, Object>
	------------------------------------------------------------*/
	@TestVisible private Map<String, Object> objectMapper (Object anObject){
		Map<String, Object> anObjectMap = new Map<String, Object>();
		try {
			String anObjectString = String.valueOf(anObject);
			Object deserializeUntyped = JSON.deserializeUntyped(anObjectString);
			anObjectMap = (Map<String, Object>) deserializeUntyped;
		} catch (Exception e) {
			anObjectMap = new Map<String, Object>();
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return anObjectMap;
	}
	
	//Note this method should be moved into the 'DescribeSchema.cls'
	//for general use in the future
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Gets a field's type.
	Inputs: 		Map<String, Schema.SObjectField> sObjectFieldMap, 
					String fieldName
	Returns: 		Schema.DisplayType
	------------------------------------------------------------*/
	public Schema.DisplayType getFieldType(Map<String, Schema.SObjectField> sObjectFieldMap, String fieldName) {
		return sObjectFieldMap.get(fieldName.toLowerCase()).getDescribe().getType();
	}
	
    // DCO 10.26.17 changed global describe to getObjectFields method
    // from DescribeSchema.cls
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Constructs a kanban card with updated values, 
					if error occurs give back the original kanban 
					card.
	Inputs: 		leankor__KanbanCard__c aKanbanCard, String JSONData
	Returns: 		leankor__KanbanCard__c
	------------------------------------------------------------*/
	public leankor__KanbanCard__c updateKanbanCard(leankor__KanbanCard__c aKanbanCard, String JSONData, Map<String, Schema.SObjectField> fieldMap) {
		leankor__KanbanCard__c deserializedObject = aKanbanCard;
		
		try {
			if (String.isNotBlank(JSONData) && JSONData != '{}') {
				Map<String, Object> kanbanCardStructure = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(aKanbanCard));
				kanbanCardStructure.remove('attributes');
				
				Map<String, Object> JSONDataMap = (Map<String, Object>) objectMapper(JSONData);
				Map<String, Object> NewJSONDataMap = new Map<String, Object>();
				
				for (String key : kanbanCardStructure.keySet()) {
					NewJSONDataMap.put(key, kanbanCardStructure.get(key));
				}
		
				for (String key : JSONDataMap.keySet()) {
					//Exclude standard sObject Fields and check if key exist in custom field map
					if(!key.equals('Id') && !key.startsWith(NAMESPACE)					
										 && !key.equals('Name') 								 	
										 && !key.equals('RecordTypeId') 										 	
										 && !key.equals('OwnerId') 										 	
										 && !key.equals('LastModifiedById') 										 	
										 && !key.equals('CreatedById')
										 &&	!key.equals('LastModifiedDate')
										 &&	!key.equals('LastViewedDate')
										 &&	!key.equals('LastReferencedDate')
										 &&	!key.equals('LastActivityDate')
										 &&	!key.equals('IsDeleted')
										 && fieldMap.containsKey(key.toLowerCase())	 
										 ) {
										
						if(String.valueOf(getFieldType(fieldMap, key)) == 'CURRENCY') {	
							NewJSONDataMap.put(key, (Decimal)JSON.deserialize((JSON.serialize(JSONDataMap.get(key)).replaceAll(',','')), Decimal.class));
						} else { 
							if(String.valueOf(getFieldType(fieldMap, key)) == 'DATE') {					   						   	     
					   	 		//modified for timeZone issue.
					   	 		String customDate = (String)JSONDataMap.get(key);
					   	 		if (customDate.containsIgnoreCase('T')) {					   	 	
	 								NewJSONDataMap.put(Key,Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(JSONDataMap.get(key)), DateTime.class)));					   	 
						   	 	} else {				   	 
						   	 		NewJSONDataMap.put(Key,Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(JSONDataMap.get(key)+'T08:30:00Z'), DateTime.class)));
								}
					   		} else {
								//SS 28.05.2017
								//-------------------/since we are having name, id (pair value) for reference field
								//-------------------/Use Id in case of reference field 
								if(String.valueOf(getFieldType(fieldMap, key)) == 'REFERENCE') {
									List<Object> refObject = (List<Object>)JSONDataMap.get(key);
									if (refObject.size()>0) {
										NewJSONDataMap.put(key,refObject[1]);
									}
								} else {
						 			NewJSONDataMap.put(key,JSONDataMap.get(key));
								}
							}
						}
					}
				}
				String serializeMap = JSON.serialize(NewJSONDataMap);
				deserializedObject = (leankor__KanbanCard__c)JSON.deserialize(serializeMap, leankor__KanbanCard__c.class);
			}
		} catch (Exception e) {
			deserializedObject = aKanbanCard;
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return deserializedObject;
	}
    
}