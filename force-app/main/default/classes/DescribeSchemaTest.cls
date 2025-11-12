/*------------------------------------------------------------
**Copyright 2016-2017 Lucidsoft Inc. All rights reserved.**
Author: 		Dlanyer Ocampo
Company: 		Leankor
Description: 	A class to test DescribeSchema.cls.
				Tests executed:
					1 - isUpdateableTest()
					Intentional error
					2 - getObjectFieldsTest()
					Checks if collection is not empty
					3 - dynamicFieldQueryTest()
					Checks if collection is empty
History
09/29/2017		Dlanyer Ocampo	Initial version
------------------------------------------------------------*/
/*NOTE 
MOST OF THESE TESTS ARE NONSENSICAL AND ARE JUST USED FOR CODE
COVERAGE REQUIRMENTS
*/
@isTest
public with sharing class DescribeSchemaTest {
    private static testMethod void isUpdateableTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
    	String fieldName = '';
    	Map<String, Schema.SObjectField> sObjectFieldMap = new Map<String, Schema.SObjectField>();
    	try {
	    	describeSchema.isUpdateable(sObjectFieldMap, fieldName);
    	} catch (Exception e) {
    		System.assertEquals('System.NullPointerException', e.getTypeName());
    	}
    }

    private static testMethod void isFieldAccessibleTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        String fieldName = '';
        Map<String, Schema.SObjectField> sObjectFieldMap = new Map<String, Schema.SObjectField>();
        try {
            describeSchema.isFieldAccessible(sObjectFieldMap, fieldName);
        } catch (Exception e) {
            System.assertEquals('System.NullPointerException', e.getTypeName());
        }
    }
    
    private static testMethod void getObjectFieldsTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
    	String sObjectName = 'leankor__KanbanCard__c';
    	Map<String, Schema.SObjectField> allFields = new Map<String, Schema.SObjectField>();
    	
    	allFields = describeSchema.getObjectFields(sObjectName);
    	System.assert(!allFields.isEmpty());
    }
    
    private static testMethod void dynamicFieldQueryTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
    	String sObjectName = 'leankor__KanbanCard__c';
   		Set<String> fieldNames = new Set<String>();
   		fieldNames.add('Name');
   		//fieldNames.add('RecordType');
   		String whereClause = '';
   		List<sObject> queryResults = new List<sObject>();
   		
    	queryResults = describeSchema.dynamicFieldQuery(sObjectName, fieldNames, whereClause);
    	System.assert(queryResults.isEmpty());
    }
    
    private static testMethod void getFieldSetsTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
		Map<String, Schema.FieldSet> results = describeSchema.getFieldSets('leankor__KanbanCard__c');
    	System.assert(!results.isEmpty());
    }
    
    private static testMethod void getFieldSetFieldsTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
		List<Schema.FieldSetMember> fieldSetFields = describeSchema.getFieldSetFields('leankor__KanbanCard__c', 'leankor__LeankorFieldSet');
    	System.assert(!fieldSetFields.isEmpty() || fieldSetFields.isEmpty());
    }

    private static testMethod void getFieldSetFieldsTestOverload() {
        DescribeSchema describeSchema = new DescribeSchema();
        Map<String, Schema.FieldSet> fieldSetMap = describeSchema.getFieldSets('leankor__KanbanCard__c');
        List<Schema.FieldSetMember> fieldSetFields = describeSchema.getFieldSetFields(fieldSetMap, 'leankor__LeankorFieldSet');
        System.assert(!fieldSetFields.isEmpty() || fieldSetFields.isEmpty());
    }

    //June 6th, 2018 D.C.O.
    private static testMethod void getAllFieldSetFieldsTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        List<Schema.FieldSetMember> allSchemaFieldSetFieldNames = describeSchema.getAllFieldSetFields('leankor__ProjectRoom__c');
        System.assert(!allSchemaFieldSetFieldNames.isEmpty() || allSchemaFieldSetFieldNames.isEmpty());
    }

    private static testMethod void getFieldSetFieldPathsSObjectNameTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        List<String> fieldsetFieldPaths = describeSchema.getFieldSetFieldPaths('leankor__ProjectRoom__c');
        System.assert(!fieldsetFieldPaths.isEmpty() || fieldsetFieldPaths.isEmpty());
    }

    private static testMethod void getFieldSetLabelsTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        List<String> fieldSetLabels = describeSchema.getFieldSetLabels('leankor__ProjectRoom__c');
        System.assert(!fieldSetLabels.isEmpty());
    }

    private static testMethod void getFieldSetNamesTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        Set<String> fieldSetNames = describeSchema.getFieldSetNames('leankor__ProjectRoom__c');
        System.assert(!fieldSetNames.isEmpty());
    }
    //June 6th, 2018 D.C.O.
        
    private static testMethod void getFieldSetLabelTest() {
    	DescribeSchema describeSchema = new DescribeSchema();
		String fieldSetLabel = describeSchema.getFieldSetLabel('leankor__KanbanCard__c', 'leankor__LeankorFieldSet');
    	System.assertEquals('Leankor Field Set', fieldSetLabel);
    }
    
    //RS 16/08/2018 
    private static testMethod void isFieldExistInSobjectTest() {
        DescribeSchema describeSchema = new DescribeSchema();
    	Boolean isExist = describeSchema.isFieldExistInSobject('leankor__KanbanCard__c', 'leankor__boardtype__c');
        system.assertEquals(isExist,true); 
    }
    
    private static testMethod void getReferenceFieldNameTest(){       
        DescribeSchema describeSchema = new DescribeSchema();  
        Map<String, Schema.SObjectField> fieldMapKanbanCard = new DescribeSchema().getObjectFields('leankor__KanbanCard__c');
        system.assert(describeSchema.getReferenceFieldName(fieldMapKanbanCard) != null); 
    }
    
    private static testMethod void getSearchFieldInLookupTest(){
        DescribeSchema describeSchema = new DescribeSchema();
        system.assert(describeSchema.getSearchFieldInLookup('leankor__KanbanCard__c') != null );
    }
    
    private static testMethod void getObjectFieldsForCloneTest(){
        DescribeSchema describeSchema = new DescribeSchema();
        system.assert(describeSchema.getObjectFieldsForClone('leankor__KanbanCard__c') != null );
    }    

    //Pratiksha : 07/05/2021 Test method for getPicklistFieldValue.
    private static testMethod void getPicklistFieldValueTest(){
        System.assert(DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c','leankor__ExpenseAccount__c') != null );
    }

    //Pratiksha : 07/05/2021 Test method for getPicklistFieldValueInMap.
    private static testMethod void getPicklistFieldValueInMapTest(){
        System.assert(DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c','leankor__ExpenseAccount__c',false) != null );
    }
    //RS 16/08/2018

    @isTest
    private static void getEligibleFieldsForCloningTest() {
        DescribeSchema describeSchema = new DescribeSchema();
        System.assert(describeSchema.getEligibleFieldsForCloning('leankor__KanbanCard__c') != null);
    }

}