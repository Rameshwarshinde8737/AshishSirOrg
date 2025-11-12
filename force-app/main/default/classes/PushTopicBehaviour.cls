/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : PushTopicBehaviour.cls
 * CLASS : PushTopicBehaviour
 * USAGE : This class implements CRUD behaviour of PushTopic standard object
 */
public with sharing class PushTopicBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public PushTopicBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		//Check object level security 
		if (!PushTopic.sObjectType.getDescribe().isAccessible()){
			return false;
		}

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		//Check object level security 
		if (!PushTopic.sObjectType.getDescribe().isUpdateable()){
			return false;
		}

		return true;
	}

	//@override Create Access
	public override boolean isCreateable(){
		//Check object level security 
		if (!PushTopic.sObjectType.getDescribe().isCreateable()){
			return false;
		}

		return true;
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		if (!PushTopic.sObjectType.getDescribe().isDeletable()){
			return false;
		}

		return true;
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 

        return checkFieldsAccessible(Schema.SObjectType.PushTopic.fields.getMap(), accessibleFields);          
	}  

	//@override Update Access  
	public override boolean isUpdateable(String [] updateablFields){ 

		return checkFieldsUpdateable(Schema.SObjectType.PushTopic.fields.getMap(), updateablFields);        
	}  		  

	//@overload Create Access  
	public override boolean isCreateable(String [] createableFields){ 

		return checkFieldsCreateable(Schema.SObjectType.PushTopic.fields.getMap(), createableFields);       
	} 
		
}