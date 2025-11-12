/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : EntitySubscriptionBehaviour.cls
 * CLASS : EntitySubscriptionBehaviour
 * USAGE : This class implements CRUD behaviour of EntitySubscription standard object
 */
public with sharing class EntitySubscriptionBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public EntitySubscriptionBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
		/*if (!EntitySubscription.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!EntitySubscription.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true; 
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!EntitySubscription.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true; 
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!EntitySubscription.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true; 
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsAccessible(Schema.SObjectType.EntitySubscription.fields.getMap(), accessibleFields);          
		return true;  
	}  

	//@override Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsCreateable(Schema.SObjectType.EntitySubscription.fields.getMap(), createableFields);          
		return true;  
	}  	

	//@override Update Access  
	public override boolean isUpdateable(String [] updateableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
       // return checkFieldsUpdateable(Schema.SObjectType.EntitySubscription.fields.getMap(), updateableFields);          
	   return true;  
	}  	
		
}