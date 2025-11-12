/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : RecordTypeBehaviour.cls
 * CLASS : RecordTypeBehaviour
 * USAGE : This class implements CRUD behaviour of RecordType standard object
 */
public with sharing class RecordTypeBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public RecordTypeBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!RecordType.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!RecordType.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true;
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!RecordType.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true;
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//isDeletable() not available for RecordType object. Always return false
		/*if (!RecordType.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true;
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsAccessible(Schema.SObjectType.RecordType.fields.getMap(), accessibleFields);          
		return true;  
	}  

	//@override Update Access  
	public override boolean isUpdateable(String [] updateablFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsUpdateable(Schema.SObjectType.RecordType.fields.getMap(), updateablFields);        
		return true;  
	}  		  

	//@overload Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsCreateable(Schema.SObjectType.RecordType.fields.getMap(), createableFields);       
		return true;  
	} 

}