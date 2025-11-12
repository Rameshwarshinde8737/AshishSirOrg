/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	Handles serialization of a given fieldset into 
				a JSONString format.
Inputs: 		None
Test Class: 	KanbanSerializerTest.cls
History
08/30/2017		Dlanyer Ocampo	Initial version
------------------------------------------------------------*/
//Names of classes may need to be renamed to suit to their
//class usage in the future
public with sharing class KanbanSerializer extends DescribeSchema {
	private final string ERROR_JSON_STRING = '{ "showFields": {"title":"edit","forceid":"protected"}, "modelFieldsToFlow": { "kanbancard": {"forceid":"kanbanId"}, "zone": {"forceid":"zoneId"}, "global": {"vsId":"vsId", "sessionId":"sessionId" } }, "config": { "xtype":"fieldset", "itemId":"formExtendPanelKanban", "style":"font-size: .9em;", "title":"Extended Info", "instructions":"There was an error displaying your custom fields.", "items": [] } }';
	
	private final string NAMESPACE = 'leankor__';
    private final boolean READONLY_NAMESPACE = true; // uncomment this before uploading to packaging org or SVN
    //private final boolean READONLY_NAMESPACE = false;  // comment this out before uploading to packaging org or SVN
	public static Map<String, Object> configPartOfHeaderSettings;
	
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Constructor for class.
	------------------------------------------------------------*/
	public KanbanSerializer() {
		
	}

	/*------------------------------------------------------------
	Author: 		Abhishek Joshi
	Company: 		Leankor
	Inputs: 		leankor__KanbanCard__c kanbanCard  Map<String, Schema.SObjectField> fieldMap
	Returns: 		Map<String, Object>
	------------------------------------------------------------*/ 
	@TestVisible public Map<String, Object> customFieldsData(leankor__KanbanCard__c kanbanCard, Map<String, Schema.SObjectField> fieldMap) {
		Map<String, Object> dataMap = new Map<String, Object>();
		Map<String, Object> filteredDataMap = new Map<String, Object>();
		Set<String> fieldSetFieldNames = new Set<String>();
		List<Schema.FieldSetMember> fieldSetFields = new List<Schema.FieldSetMember>();
		DescribeSchema describeSchema = new describeSchema();
		String JSONData = '';
		try {
			//Map kanban card
			dataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(kanbanCard));
			//Filter kanban card
			fieldSetFields = describeSchema.getFieldSetFields(NAMESPACE + 'KanbanCard__c', kanbanCard.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c);
			
			for (Schema.FieldSetMember fieldSetField : fieldSetFields)
                fieldSetFieldNames.add(fieldSetField.getFieldPath());	

            for (String fieldSetFieldName : fieldSetFieldNames) {
				Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldSetFieldName).getDescribe();
				//rbo 10.29.17
				if(fieldDescribe.getType().name() == 'Reference') {
					//Start : NW 25OCT17 : Added code to fix reference field issue.
					String referenceFieldName = fieldSetFieldName;
					if(fieldSetFieldName == 'RecordTypeId' || fieldSetFieldName == 'OwnerId' || fieldSetFieldName == 'CreatedById'|| fieldSetFieldName == 'LastModifiedById')
						referenceFieldName = fieldSetFieldName.replace('Id','');
					else
						referenceFieldName = fieldSetFieldName.replace('__c','__r');
						
					Map<String, Object> referenceMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(dataMap.get(referenceFieldName)));
					
					//-------------/SS 31.05.2018/-------------//
					List<Object> referenceValues = new List<Object>();
					String name = '';
					if(referenceMap != null){
				        //This method will return description of field which is used for quick search for lookup records.
				        Schema.DescribeFieldResult describeField = describeSchema.getSearchFieldInLookup(String.valueOf(fieldDescribe.getReferenceTo()[0]));
				        if(describeField!=null)
				        {
				        	name = (String) referenceMap.get(describeField.getName());
				        }
                        referenceValues.add(name);
                        referenceValues.add(referenceMap.get('Id'));  
                    }
                    //If reference map is null that means reference object does not have Name and AutoNumber type field in that case we assign its Force.com Id to display as Name 
                    else{
                    	name = (String) dataMap.get(fieldSetFieldName);
                        referenceValues.add(name);
                        referenceValues.add(name);
                	}
                    filteredDataMap.put(fieldSetFieldName, referenceValues);
                }
 
				else if(fieldDescribe.getType().name() == 'DATE' || fieldDescribe.getType().name() == 'DATETIME') {       														
					if(fieldSetFieldName == NAMESPACE + 'HarveyBallDoneDate__c') {																	
						if(dataMap.get(fieldSetFieldName) == null)								
							filteredDataMap.put(fieldSetFieldName, dataMap.get(NAMESPACE + 'DueDate__c'));
						else								
								filteredDataMap.put(fieldSetFieldName, dataMap.get(fieldSetFieldName));
							}
                    else if(dataMap.get(fieldSetFieldName) == null)
						filteredDataMap.put(fieldSetFieldName, System.now());
					else
							filteredDataMap.put(fieldSetFieldName, dataMap.get(fieldSetFieldName));
				}
                else
					filteredDataMap.put(fieldSetFieldName, dataMap.get(fieldSetFieldName));
			}
		} 
		catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return filteredDataMap;
	}
	

	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Serializes items.
	Inputs: 		String sObjectName, String fieldSetName, 
					leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings
	Returns: 		List<Map<String, Object>>
	------------------------------------------------------------*/
    public List<Map<String, Object>> serializeItems(String sObjectName, String fieldSetName, leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings, Map<String, Schema.SObjectField> fieldMap) {
    	String fieldSetMemberType = '';
    	String fieldPath = '';
    	String fieldLabel = '';
		Integer maxLength;
    	
    	List<Schema.FieldSetMember> fieldslist = new List<Schema.FieldSetMember>();
    	List<Map<String, Object>> itemList = new List<Map<String, Object>>();
    			
    	Map<String, Object> items = new Map<String, Object>();
		Map<String, Object> customSettingsJSONMap = new Map<String, Object>();
		Map<String, Object> newCustomSettingsMap = new Map<String, Object>();
		
    	try {
	    	for (leankor__VisualLeanUIItemSetting__mdt newCustomSetting : UIItemSettings) {
	    		newCustomSettingsMap.put(newCustomSetting.Label, newCustomSetting.leankor__UIJSONString__c);
	    	}
	    	//DCO 10.26.17 replaced with DescribeSchema method
	    	fieldsList = getFieldSetFields(sObjectName, fieldSetName);
	    	Set<String> fieldMapKeyset = fieldMap.keySet();
              
	    	for (Integer i = 0; i < fieldsList.size(); i++) {
	    		fieldSetMemberType = String.valueOf(fieldsList[i].getType());
	    		fieldPath = fieldsList[i].getFieldPath();
	    		fieldLabel = fieldsList[i].getLabel();
				if(String.valueOf(fieldsList[i].getSObjectField().getDescribe().getSoapType()) == 'DOUBLE'){
					maxLength = fieldsList[i].getSObjectField().getDescribe().getPrecision();
				}
				if(String.valueOf(fieldsList[i].getSObjectField().getDescribe().getSoapType()) == 'STRING'){
					maxLength = fieldsList[i].getSObjectField().getDescribe().getLength();
				}
				if(fieldMapKeyset.contains(fieldPath.toLowerCase()) ? true : false)  //DCO 10.29.17 replaced fieldMap.keySet() with fieldMapKeyset                    
					itemList.add(serializeItemsHelper(fieldSetMemberType, fieldPath, fieldLabel, newCustomSettingsMap, sObjectName, fieldMap, maxLength));
					maxLength = null;
			}

    	} catch (Exception e) {
    		itemList = new List<Map<String, Object>>();
    		throw new KanbanSerializerException('Error serializing the JSON Data.');
    	}
    	return itemList;
    }
       
    /*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Helper method for serializing items.
	Inputs: 		String fieldSetMemberType, String fieldPath, 
					String fieldLabel, Map<String, Object> customSettings, 
					String sObjectName
	Returns: 		Map<String, Object>
	------------------------------------------------------------*/
    @TestVisible private Map<String, Object> serializeItemsHelper(String fieldSetMemberType, String fieldPath, String fieldLabel, Map<String, Object> customSettings, String sObjectName, Map<String, Schema.SObjectField> fieldMap, Integer maxLength) {
	    Map<String, Object> customSettingsJSONMap = new Map<String, Object>();
	    String customSettingsJSONNew = '';
	    String customSettingsJSON = '';
		Boolean percentField = false;
    	try {
			if (customSettings.containsKey(fieldSetMemberType)) {
	    	   	customSettingsJSON = String.valueOf(customSettings.get(fieldSetMemberType));
	    	   	customSettingsJSONMap = (Map<String, Object>) JSON.deserializeUntyped(customSettingsJSON);
				customSettingsJSONMap.put('name', fieldPath);
				customSettingsJSONMap.put('label', fieldLabel);
				customSettingsJSONMap.put('maxLength', maxLength);
				if(fieldSetMemberType == 'PERCENT') {
					percentField = true;
					customSettingsJSONMap.put('percentField', percentField);
				}

				// rbo 10.27.17
				//if (!isUpdateable(getObjectFields(sObjectName), fieldPath) || (READONLY_NAMESPACE ? fieldPath.startsWith(NAMESPACE) : false) || fieldSetMemberType == 'REFERENCE' || fieldPath == 'Name')
				// Check read and edit access
				if (!isFieldAccessible(fieldMap, fieldPath)) {
					return new Map<String, Object>(); // Return empty map if no readable 
				}
				if (!isUpdateable(fieldMap, fieldPath) || (READONLY_NAMESPACE ? fieldPath.startsWith(NAMESPACE) : false) || fieldSetMemberType == 'REFERENCE' || fieldPath == 'Name')
				// rbo 10.27.17
				{
					if(fieldSetMemberType != 'BOOLEAN')
					{
					customSettingsJSONMap.put('readOnly', true);
					}else{
						customSettingsJSONMap.put('disabled', true);
					}
				}
				if (customSettingsJSONMap.containsKey('options'))
					customSettingsJSONMap.put('options', getOptions(sObjectName, fieldPath, fieldMap)); //rbo 10.29.17 added fieldMap parameter
	    	}
    	} catch (Exception e) {
    		throw new KanbanSerializerException('Error serializing the JSON Data.');
    	}
    	return customSettingsJSONMap;
    }
    
    /*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Serializes header.
	Inputs: 		String sObjectName, String fieldSetName, 
	leankor__VisualLeanUIHeaderSetting__mdt[] UIHeaderSettings, 
	leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings
	Returns: 		String
	------------------------------------------------------------*/
    public String serializeHeader(String sObjectName, String fieldSetName, leankor__VisualLeanUIHeaderSetting__mdt[] UIHeaderSettings, leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings, Map<String, Schema.SObjectField> fieldMap) {
    	String customSettingsJSON = '';
		String header = '{';
    	String JSONString = '';
    	String stringKeySetElement = '';
    
    	List<String> stringKeySet = new List<String>();
    	List<String> headerComponents = new List<String>();
    	List<String> headerString = new List<String>();
		
		Map<String, Object> newCustomSettingsMap = new Map<String, Object>();
		Map<String, Object> customSettingsJSONMap = new Map<String, Object>();
    	//rbo 10.29.17 not used
        //Map<String, leankor__VisualLeanUIHeaderSetting__mdt> customSettings = new Map<String, leankor__VisualLeanUIHeaderSetting__mdt>();
        //rbo 10.29.17 not used
    	//System.debug('UIHeaderSettings: ' + UIHeaderSettings);
    	try {
	    	for (leankor__VisualLeanUIHeaderSetting__mdt newCustomSetting : UIHeaderSettings) {
	    		newCustomSettingsMap.put(newCustomSetting.Label, newCustomSetting.leankor__UIJSONString__c);
	    	}
	    		    	
			stringKeyset.addAll(newCustomSettingsMap.keySet());
	    	for (Integer i = 0; i < stringKeyset.size(); i++) {
	    		//rbo 10.29.17 to save heap space by not using a variable
                //stringKeySetElement = stringKeySet[i];
	    		//headerString.add(serializeHeaderHelper(customSettingsJSON, stringKeySetElement, customSettingsJSONMap, newCustomSettingsMap, sObjectName, fieldSetName, UIItemSettings, fieldMap));
	    		headerString.add(serializeHeaderHelper(customSettingsJSON, stringKeySet[i], customSettingsJSONMap, newCustomSettingsMap, sObjectName, fieldSetName, UIItemSettings, fieldMap));
                //rbo 10.29.17
	    	}
	    	JSONString = '{' + String.join(headerString, ',') + '}';
    	} catch (Exception e) {
    		JSONString = ERROR_JSON_STRING;
    		throw new KanbanSerializerException('Error serializing the JSON Data.');
    	}
    	return JSONString;
    }
	
	/*------------------------------------------------------------
		Author: 		Abhishek Joshi
		Company: 		Leankor
		Description: 	Sending Custom Metadata with our Serializes
		Inputs: 		String sObjectName, String fieldSetName, 
						leankor__VisualLeanUIHeaderSetting__mdt[] UIHeaderSettings, 
						leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings

		Returns: Map<String, Object>
	------------------------------------------------------------*/
	public Map<String, Object> customMetadataHeader(String sObjectName, String fieldSetName, leankor__VisualLeanUIHeaderSetting__mdt[] uiHeaderSettings, leankor__VisualLeanUIItemSetting__mdt[] uiItemSettings, Map<String, Schema.SObjectField> fieldMap) {
    	String customSettingsJSON = '';
		Map<String, Object> customMetaData = new Map<String, Object>();
    
    	List<String> stringKeySet = new List<String>();	
		Map<String, Object> newCustomSettingsMap = new Map<String, Object>();
		Map<String, Object> customSettingsJSONMap = new Map<String, Object>();
    	try {
	    	for (leankor__VisualLeanUIHeaderSetting__mdt newCustomSetting : uiHeaderSettings) {
				if(newCustomSetting.Label =='config'){
	    		newCustomSettingsMap.put(newCustomSetting.Label, newCustomSetting.leankor__UIJSONString__c);
				}
	    	}
	    		    	
			stringKeyset.addAll(newCustomSettingsMap.keySet());
	    	for (Integer i = 0; i < stringKeyset.size(); i++) {
                customMetaData.putAll(CustomMetadataHeaderHepler(customSettingsJSON, stringKeySet[i], customSettingsJSONMap, newCustomSettingsMap, sObjectName, fieldSetName, uiItemSettings, fieldMap));
	    	}
    	} catch (Exception e) {
    		throw new KanbanSerializerException('Error serializing the JSON Data.');
    	}
    	return customMetaData;
    }


	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Helper method for serializing header.
	Inputs: 		String customSettingsJSON, String 
					stringKeySetElement, Map<String, Object> customSettingsJSONMap, 
					Map<String, Object> customSettings, String sObjectName, 
					String fieldSetName, leankor__VisualLeanUIItemSetting__mdt[] 
	UIItemSettings
	Returns: 		String
	------------------------------------------------------------*/
    @TestVisible private String serializeHeaderHelper(String customSettingsJSON, String stringKeySetElement, Map<String, Object> customSettingsJSONMap, Map<String, Object> customSettings, String sObjectName, String fieldSetName, leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings, Map<String, Schema.SObjectField> fieldMap) {
	    String result = '';
	    customSettingsJSON = String.valueOf(customSettings.get(stringKeySetElement));
		customSettingsJSONMap = (Map<String, Object>) JSON.deserializeUntyped(customSettingsJSON);
		try {
			if (customSettingsJSONMap.containsKey('items')) {
				customSettingsJSONMap.put('items', serializeItems(sObjectName, fieldSetName, UIItemSettings, fieldMap));	
			}
			result = '"' + stringKeySetElement + '" : ' + JSON.serializePretty(customSettingsJSONMap);
		} catch (Exception e) {
			throw new KanbanSerializerException('Error serializing the JSON Data.');
		}
		return result;		
    }

	/*------------------------------------------------------------
	Author: 		Abhishek Joshi
	Company: 		Leankor
	Description: 	Helper method for sending CustomMetaData
	Inputs: 		String customSettingsJSON, String 
					stringKeySetElement, Map<String, Object> customSettingsJSONMap, 
					Map<String, Object> customSettings, String sObjectName, 
					String fieldSetName, leankor__VisualLeanUIItemSetting__mdt[] 
					UIItemSettings
	Returns: 		Map<String, Object>
	------------------------------------------------------------*/
	@TestVisible Map<String, Object>  customMetadataHeaderHepler(String customSettingsJSON, String stringKeySetElement, Map<String, Object> customSettingsJSONMap, Map<String, Object> customSettings, String sObjectName, String fieldSetName, leankor__VisualLeanUIItemSetting__mdt[] UIItemSettings, Map<String, Schema.SObjectField> fieldMap) {

	    customSettingsJSON = String.valueOf(customSettings.get(stringKeySetElement));
		customSettingsJSONMap = (Map<String, Object>) JSON.deserializeUntyped(customSettingsJSON);
		configPartOfHeaderSettings = (Map<String, Object>) JSON.deserializeUntyped(customSettingsJSON);

		if (configPartOfHeaderSettings.containsKey('items')) {
			configPartOfHeaderSettings.remove('items');
		}

		try {
			if (customSettingsJSONMap.containsKey('xtype') || customSettingsJSONMap.containsKey('itemId') || customSettingsJSONMap.containsKey('style') || customSettingsJSONMap.containsKey('title') || customSettingsJSONMap.containsKey('instructions')) {
					customSettingsJSONMap.remove('xtype');
					customSettingsJSONMap.remove('itemId');
					customSettingsJSONMap.remove('style');
					customSettingsJSONMap.remove('title');
					customSettingsJSONMap.remove('instructions');
			}
			if (customSettingsJSONMap.containsKey('items')) {
				customSettingsJSONMap.put('items', serializeItems(sObjectName, fieldSetName, UIItemSettings, fieldMap));	
			}
		} catch (Exception e) {
			throw new KanbanSerializerException('Error serializing the JSON Data.');
		}
		return customSettingsJSONMap;		
    }

	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Obtains options to insert.
	Inputs: 		String sObjectName, String pickListName
	Returns: 		List<Map<String, Object>>
	------------------------------------------------------------*/
	//rbo 10.29.17
	/*
    //@TestVisible private List<Map<String, Object>> getOptions(String sObjectName, String pickListName) {
		Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
		Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
		Map<String, Schema.SObjectField> sObjectTypeFields = describeSObjectResult.fields.getMap();
	*/
    @TestVisible private List<Map<String, Object>> getOptions(String sObjectName, String pickListName, Map<String, Schema.SObjectField> sObjectTypeFields) {
	//rbo 10.29.17
		
		List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
		List<Map<String, Object>> listPickListMaps = new List<Map<String, Object>>();
		
		String picklistLabel = '';
		String picklistValue = '';
		try {
			if(String.isNotEmpty(pickListName))
				picklistValues = sObjectTypeFields.get(pickListName).getDescribe().getPickListValues();
			for (Integer i = 0; i < picklistValues.size(); i++) {
				picklistLabel = picklistValues[i].getLabel();
				picklistValue = picklistValues[i].getValue();
				
				listPickListMaps.add(getOptionsHelper(picklistLabel, picklistValue));
			}
		} catch (Exception e) {
			listPickListMaps = new List<Map<String, Object>>();	
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return listPickListMaps;
	}
	
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Helper method for obtaining options.
	Inputs: 		String picklistLabel, String picklistValue
	Returns: 		Map<String, Object>
	------------------------------------------------------------*/
	@TestVisible private Map<String, Object> getOptionsHelper(String picklistLabel, String picklistValue) {
		Map<String, Object> pickListMap = new Map<String, Object>();
		pickListMap.put('text', picklistLabel);
		pickListMap.put('value', picklistValue);
		return pickListMap;
	}
	
	class KanbanSerializerException extends Exception {}
}