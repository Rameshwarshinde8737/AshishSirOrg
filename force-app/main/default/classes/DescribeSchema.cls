/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	Class to describe schema.
Inputs: 		None
Test Class: 	DescribeSchemaTest.cls
History
09/08/2017		Dlanyer Ocampo	Initial version
10/26/17		Dlanyer Ocampo	Increased performance on some
								methods (See logs).
------------------------------------------------------------*/

public virtual with sharing class DescribeSchema {
    public DescribeSchema() {
    }
    
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Check a field's update permission.
	Inputs: 		Map<String, Schema.SObjectField> sObjectFieldMap, 
					String fieldName
	Returns: 		boolean
	------------------------------------------------------------*/
	public boolean isUpdateable(Map<String, Schema.SObjectField> sObjectFieldMap, String fieldName) {
		return sObjectFieldMap.get(fieldName).getDescribe().isUpdateable();
	}

	//DCO 06.03.18 Added new method
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Check a field's access permission.
	Inputs: 		Map<String, Schema.SObjectField> sObjectFieldMap, 
					String fieldName
	Returns: 		boolean
	------------------------------------------------------------*/
	public boolean isFieldAccessible(Map<String, Schema.SObjectField> sObjectFieldMap, String fieldName) {
		return sObjectFieldMap.get(fieldName).getDescribe().isAccessible();
	}
	//DCO 06.03.18 Added new method

	//DCO 10.26.17 changed method to a single object describe instead of global
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Get an object's fields.
	Inputs: 		String sObjectName
	Returns: 		Map<String, Schema.SObjectField>
	------------------------------------------------------------*/
	public Map<String, Schema.SObjectField> getObjectFields(String sObjectName) {
		Map<String, Schema.SObjectField> allFields = new Map<String, Schema.SObjectField>();
        List<String> sObjectNames = new List<String>();
        List<Schema.DescribeSObjectResult> results = new List<Schema.DescribeSObjectResult>();

		try {
            sObjectNames.add(sObjectName); //This is only adding one element, please check and refactor - DCO
            results = Schema.describeSObjects(sObjectNames); //Please check if can use the describeSObject method - DCO
            for(Schema.DescribeSObjectResult res : results) //This is looping on one element, please check and refactor - DCO
                allFields = res.fields.getMap();
			//SObjectType sobjectObject = Schema.getGlobalDescribe().get(sObjectName);
			//allFields = sobjectObject.getDescribe().fields.getMap();
		} catch (Exception e) { 
			throw new Util.LeanException('ERROR:' + e.getMessage()); 

		}
		return allFields;
	}
	
	public Map<String, Schema.SObjectField> getObjectFieldsForClone(String sObjectName) {
		
		Map<String, Schema.SObjectField> allFields = new Map<String, Schema.SObjectField>();
		Map<String, Schema.SObjectField> onlyCustomFieldsMap = new Map<String, Schema.SObjectField>();
		
        List<String> sObjectNames = new List<String>();
        List<Schema.DescribeSObjectResult> results = new List<Schema.DescribeSObjectResult>();

		try {
            sObjectNames.add(sObjectName);
            results = Schema.describeSObjects(sObjectNames);
            for(Schema.DescribeSObjectResult res : results)
                allFields = res.fields.getMap();
			//SObjectType sobjectObject = Schema.getGlobalDescribe().get(sObjectName);
			//allFields = sobjectObject.getDescribe().fields.getMap();
			
			for(String key : allFields.keySet())
			{
			   if((!key.containsIgnoreCase('leankor__')) && (key.containsIgnoreCase('__c')))
			   {
			    	onlyCustomFieldsMap.put(key,allFields.get(key));
			   }
			}

		} catch (Exception e) { 
			throw new Util.LeanException('ERROR:' + e.getMessage()); 	
		}
		return onlyCustomFieldsMap;
	}
    //DCO 10.26.17

	public Map<String, Schema.SObjectField> getEligibleFieldsForCloning(String sObjectName) {
		Map<String, Schema.SObjectField> allFields = new Map<String, Schema.SObjectField>();
		Map<String, Schema.SObjectField> onlyCustomFieldsMap = new Map<String, Schema.SObjectField>();

		Set<Schema.DisplayType> allowedDataTypes = new Set<Schema.DisplayType> {
			Schema.DisplayType.BOOLEAN,
			Schema.DisplayType.CURRENCY,
			Schema.DisplayType.DATE,
			Schema.DisplayType.DOUBLE,
			Schema.DisplayType.PICKLIST,
			Schema.DisplayType.REFERENCE,
			Schema.DisplayType.STRING,
			Schema.DisplayType.URL,
			Schema.DisplayType.PERCENT,
            Schema.DisplayType.DATETIME
		};

		try {
			List<String> sObjectNames = new List<String> { sObjectName };
			List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(sObjectNames);

			for (Schema.DescribeSObjectResult res : results) {
				allFields = res.fields.getMap();
			}

			for (String key : allFields.keySet()) {
				Schema.SObjectField field = allFields.get(key);
				Schema.DescribeFieldResult describeField = field.getDescribe();

				if (key.containsIgnoreCase('__c') && !key.containsIgnoreCase('leankor__') && describeField.isUpdateable() && allowedDataTypes.contains(describeField.getType())) {
					onlyCustomFieldsMap.put(key, field);
				}
			}

		} catch (Exception e) {
			throw new Util.LeanException('ERROR: ' + e.getMessage());
		}

		return onlyCustomFieldsMap;
	}
	
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	A dynamic query method.
	Inputs: 		String sObjectName, Set<String> fieldNames, 
					String whereClause
	Returns: 		List<sObject>
	------------------------------------------------------------*/
    public List<sObject> dynamicFieldQuery(String sObjectName, Set<String> fieldNames, String whereClause) {
		List<sObject> queryResults = new List<sObject>();
   		if (Util.isObjectAccessible(sObjectName)) {
			String SOQLString = '';
			List<String> stringFieldNames = new List<String>();
			try {
				stringFieldNames.addAll(fieldNames);
				SOQLString = 'Select ' + String.join(stringFieldNames, ', ');
				if (String.isNotBlank(sObjectName)) {
					SOQLString += ' From ' + sObjectName;
					if(String.isNotBlank(whereClause))
						SOQLString += ' ' + Util.parseWhereClause(whereClause);
				
					//Query sObject records irrespective of security rule
					queryResults = RealTimeControllerHelper.querySobjectRecords(SOQLString);
				}
			} catch (Exception e) {
				queryResults = new List<sObject>();	
				//25/04/2023 : We are Throwing Exception
				throw new Util.LeanException('ERROR:' + e.getMessage()); 		
			}
		}
    	return queryResults;
    }
    
    //DCO 10.26.17 changed method to a single object describe instead of global
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a map of fieldsets of
					a given object.
	Inputs: 		String sObjectName
	Returns: 		Map<String, Schema.FieldSet>
	------------------------------------------------------------*/
	public Map<String, Schema.FieldSet> getFieldSets(String sObjectName) {
		Map<String, Schema.FieldSet> fieldSetMap = new Map<String, Schema.FieldSet>();
		List<String> sObjectNames = new List<String>();
        List<Schema.DescribeSObjectResult> results = new List<Schema.DescribeSObjectResult>();
		try {
            sObjectNames.add(sObjectName);
            results = Schema.describeSObjects(sObjectNames);
            for(Schema.DescribeSObjectResult res : results)
                fieldSetMap = res.fieldsets.getMap();
			//SObjectType sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName);
			//fieldSetMap = sObjectDescribe.getDescribe().fieldsets.getMap();
		} catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage()); 	
		}
		return fieldSetMap;
	}
	
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a list of fields of
					a given fieldset.
	Inputs: 		String sObjectName, String fieldSetAPIName
	Returns: 		List<Schema.FieldSetMember>
	------------------------------------------------------------*/
	public List<Schema.FieldSetMember> getFieldSetFields(String sObjectName, String fieldSetAPIName) {	
		List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
		try {
			Map<String, Schema.FieldSet> fieldSetMap = getFieldSets(sObjectName);
			fieldSetMembers = fieldSetMap.get(fieldSetAPIName).getFields();
		} catch (Exception e) {
			System.debug(e); 	
		}
		return fieldSetMembers;
	}

	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a list of fields of
					a given fieldset.
	Inputs: 		Map<String, Schema.FieldSet> fieldSetMap, String fieldSetAPIName
	Returns: 		List<Schema.FieldSetMember>
	------------------------------------------------------------*/
	public List<Schema.FieldSetMember> getFieldSetFields(Map<String, Schema.FieldSet> fieldSetMap, String fieldSetAPIName) {	
		List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
		try {
			fieldSetMembers = fieldSetMap.get(fieldSetAPIName).getFields();
		} catch (Exception e) {
			System.debug(e);
		}
		return fieldSetMembers;
	}
	
	//June 6th, 2018 D.C.O.
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a list of fields of
					a of an objects fieldsets.
	Inputs: 		String sObjectName
	Returns: 		List<Schema.FieldSetMember>
	------------------------------------------------------------*/
    public List<Schema.FieldSetMember> getAllFieldSetFields(String sObjectName) {
      	List<Schema.FieldSetMember> allSchemaFieldSetFieldNames = new List<Schema.FieldSetMember>();
  		List<String> fieldSetNames = new List<String>(getFieldSetNames(sObjectName));
      	try {
	    	for (String fieldSetName : fieldSetNames) {
	    		//getFieldSetFields is called in a loop, not a good idea because getFieldSets is called every time
	        	List<Schema.FieldSetMember> schemaFieldSetFieldNames = getFieldSetFields(sObjectName, fieldSetName);
	        	allSchemaFieldSetFieldNames.addAll(schemaFieldSetFieldNames);
        	} 
        } catch (Exception e) {
      		throw new Util.LeanException('ERROR:' + e.getMessage()); 	
    	}
      	return allSchemaFieldSetFieldNames;
    }
	//June 6th, 2018 D.C.O.

	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a list of fieldpaths 
					from a given an sObject.
	Inputs: 		String sObjectName
	Returns: 		List<String>
	------------------------------------------------------------*/
    public List<String> getFieldSetFieldPaths(String sObjectName) {
      List<String> fieldsetFieldPaths = new List<String>();
      List<Schema.FieldSetMember> fieldSetFields = getAllFieldSetFields(sObjectName);
      try {
	      for (Schema.FieldSetMember fieldSetField : fieldSetFields) {
	        String fieldsetFieldPath = fieldSetField.getFieldPath();
	        fieldsetFieldPaths.add(fieldsetFieldPath);
	      }
		} catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage()); 	
		}
      return fieldsetFieldPaths;
    }

	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain a field label of a
					given fieldset.
	Inputs: 		String sObjectName, String fieldSetAPIName
	Returns: 		String
	------------------------------------------------------------*/
	public String getFieldSetLabel(String sObjectName, String fieldSetAPIName) {	
		String fieldSetLabel = '';
		try {
			Map<String, Schema.FieldSet> fieldSetMap = getFieldSets(sObjectName);
			fieldSetLabel = fieldsetMap.get(fieldSetAPIName).getLabel();
		} catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage()); 	
		}
		return fieldSetLabel;
	}

	//June 6th, 2018 D.C.O.
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain field labels of all
					fieldsets of a given sObject.
	Inputs: 		String sObjectName
	Returns: 		List<String>
	------------------------------------------------------------*/
    public List<String> getFieldSetLabels(String sObjectName) {
      List<String> fieldSetLabels = new List<String>();
      List<String> fieldSetNames = new List<String>(getFieldSetNames(sObjectName));
      try {
      	for (String fieldSetsKeySetElement : fieldSetNames) {
	        String fieldSetLabel = getFieldSetLabel(sObjectName, fieldSetsKeySetElement);
	        fieldSetLabels.add(fieldSetLabel);
      	}
      } catch (Exception e) {
  		throw new Util.LeanException('ERROR:' + e.getMessage());
      }
      return fieldSetLabels;
    }
	//June 6th, 2018 D.C.O.

	//June 6th, 2018 D.C.O.
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accesor method to obtain the keyset of all
					fieldsets within the specified object
	Inputs: 		String sObjectName
	Returns: 		Set<String>
	------------------------------------------------------------*/
    public Set<String> getFieldSetNames(String sObjectName) {
      	Map<String, Schema.FieldSet> fieldSets = getFieldSets(sObjectName);
      	Set<String> fieldSetNames = new Set<String>();
      	try {
      		fieldSetNames = fieldSets.keySet();
  		} catch (Exception e) {
  			throw new Util.LeanException('ERROR:' + e.getMessage()); 	
  		}
      	return fieldSetNames;
    }
	
	/*------------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Check field exist in given sObject 
					or not.  
	Inputs: 		String sObjectName, String fieldName
	Returns: 		boolean
	------------------------------------------------------------*/
    public boolean isFieldExistInSobject(String sObjectName , String fieldName){
    	Boolean fieldExist;
		try{
			Map <String, Schema.SObjectField> fieldMap = getObjectFields(sObjectName);
			fieldExist = fieldMap.containsKey(fieldName);
		} catch(Exception ex){
			fieldExist = false;		
		}
		return fieldExist;		
	}
	
	
	/*------------------------------------------------------------
	Author: 		Yash Jain
	Company: 		Leankor
	Description: 	Check field is avaialbe or not in refrenceObject(lookup Object)
	Inputs: 		Schema.DescribeFieldResult fieldDescribe, String fieldAPIName
	Returns: 		Boolean
	------------------------------------------------------------*/
	/*public Boolean checkReferenceObjectField(Schema.DescribeFieldResult fieldDescribe,String FieldAPIName){
	
		List<Schema.sObjectType> refrenceObject = fieldDescribe.getReferenceTo();
		if(refrenceObject.size()>0)
		{			
			Map<String, Schema.SObjectField> fieldMapKanbanCard = new DescribeSchema().getObjectFields(refrenceObject[0].getDescribe().getName());		
			return fieldMapKanbanCard.keyset().contains(FieldAPIName.toLowerCase());
		}
		return false;
	}
	
	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	Add reference field name of sObject for dynamic query 
	Inputs: 		Map<String, Schema.SObjectField>
	Returns: 		Set<String>
	------------------------------------------------------------*/
	
	public Set<String> getReferenceFieldName(Map<String, Schema.SObjectField> sobjectFieldMap){
		Set<String> referenceFieldNames = new Set<String>();
		for(String fieldName : sobjectFieldMap.keyset())
		{   
		    //getting field metadata
			Schema.DescribeFieldResult fieldDescribe = sobjectFieldMap.get(fieldName).getDescribe();
			
			//check field is loookup and out of leankor Namespace
			if(fieldDescribe.getType().name() == 'Reference'){	
				List<Schema.sObjectType> refrenceObject = fieldDescribe.getReferenceTo();
				/*if(isFieldExistInSobject(String.valueOf(refrenceObject[0]),'Name')){
					 referenceFieldNames.add(fieldDescribe.getRelationshipName()+'.Name');
				}	 
				//----------------/SS 29.05.2018/----------------//
				//If sObject does not contains name field we will check for AutoNumber field
				/*else if(getAutoNumberField(String.valueOf(refrenceObject[0]))!=null){
					 referenceFieldNames.add(fieldDescribe.getRelationshipName()+'.'+getAutoNumberField(String.valueOf(refrenceObject[0])).getName());
				}*/
				//This method will return description of field which is used for quick search for lookup records.
				//Date :28/02/2020 
				if(refrenceObject.size()>0){
					Schema.DescribeFieldResult referenceObjectSearchField  = getSearchFieldInLookup(String.valueOf(refrenceObject[0]));
					if(referenceObjectSearchField!=null){
						 referenceFieldNames.add(fieldDescribe.getRelationshipName()+'.'+referenceObjectSearchField.getName());
					}
				}
				//----------------/SS 29.05.2018/----------------//
			}
			
		}
	return referenceFieldNames;	
	}
	
	//Currently We are not using this method.
	/*------------------------------------------------------------
	Author: 		Suraj Sen, Rahul Solanki
	Company: 		Leankor
	Description: 	get and describe AutoNumber field of sObject  
	Inputs: 		sObjectName
	Returns: 		Schema.DescribeFieldResult
	------------------------------------------------------------*/
	/*public Schema.DescribeFieldResult getAutoNumberField(String sObjectName)
	{
	   for(Schema.SObjectField sobjectField : getObjectFields(sObjectName).values())
	   {
	   	  Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
	      if(describeFieldResult.isAutoNumber())
	      {
	           return describeFieldResult;
	      }
	   }
	   return null;
	}*/
	
	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	get and describe isNameField field of sObject
	                (This field is used for quick search for lookup records)  
	Inputs: 		sObjectName
	Returns: 		Schema.DescribeFieldResult
	------------------------------------------------------------*/
	public Schema.DescribeFieldResult getSearchFieldInLookup(String sObjectName)
	{
	   for(Schema.SObjectField sobjectField : getObjectFields(sObjectName).values())
	   {
	   	  Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();
	      if(describeFieldResult.isNameField())
	      {
	           return describeFieldResult;
	}
	   }
	   return null;
	}

	public static Map<String, String> getPicklistFieldValueInMap(String sObjectName, String picklistFieldName){
		List<Schema.PicklistEntry> fieldpicklist = new List<Schema.PicklistEntry>();
		DescribeSchema describeschema = new DescribeSchema();
		Map<String, Schema.SObjectField> sObjectFieldMap = new Map<String, Schema.SObjectField>();
		Map<String, String> picklistMap = new Map<String, String>();

		sObjectFieldMap = describeschema.getObjectFields(sObjectName);

		for(Schema.SObjectField sObjectField : sObjectFieldMap.values()){
			if(sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST && sObjectField.getDescribe().getName() == picklistFieldName){
				List<Schema.PicklistEntry> picklistvalues = sObjectField.getDescribe().getPickListValues();
				fieldpicklist.addAll(picklistvalues);
			}
		}

		for(Schema.PicklistEntry picklist : new Set<Schema.PicklistEntry>(fieldpicklist)){
            if(picklist.isActive()){
                picklistMap.put(picklist.getValue(), picklist.getLabel());
            }
        }
		return picklistMap;
	}


	/*---------------------------------------------------------------------------------------------------------
     Description : Get picklist values
     Input       : Object Name, Fieldname of picklist, parameter used for overloading 
     Output      : Map of picklist info
    ----------------------------------------------------------------------------------------------------------*/
	public static Map<String, TimeCard.PicklistValueInfo> getPicklistFieldValueInMap(String sObjectName, String picklistFieldName, Boolean isPicklistValueInfo) {
		List<Schema.PicklistEntry> fieldPicklist = new List<Schema.PicklistEntry>();
		DescribeSchema describeSchema = new DescribeSchema();
		Map<String, Schema.SObjectField> sObjectFieldMap = new Map<String, Schema.SObjectField>();
		Map<String, TimeCard.PicklistValueInfo> picklistMap = new Map<String, TimeCard.PicklistValueInfo>();

		sObjectFieldMap = describeSchema.getObjectFields(sObjectName);

		for (Schema.SObjectField sObjectField : sObjectFieldMap.values()) {
			if (sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST && sObjectField.getDescribe().getName() == picklistFieldName) {
				List<Schema.PicklistEntry> picklistValues = sObjectField.getDescribe().getPickListValues();
				fieldPicklist.addAll(picklistValues);
			}
		}

		for (Schema.PicklistEntry picklist : new Set<Schema.PicklistEntry>(fieldPicklist)){
            if (picklist.isActive()) {
				TimeCard.PicklistValueInfo picklistValueInfo = new TimeCard.PicklistValueInfo();

				picklistValueInfo.Label = picklist.getLabel();
				picklistValueInfo.IsDefaultValue = picklist.isDefaultValue();
				picklistValueInfo.Value = picklist.getValue();
                picklistMap.put(picklist.getValue(), picklistValueInfo);
            }
		}
		
		return picklistMap;
	}
}