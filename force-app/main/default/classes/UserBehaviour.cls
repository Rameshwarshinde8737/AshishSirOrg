/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : UserBehaviour.cls
 * CLASS : UserBehaviour
 * USAGE : This class implements CRUD behaviour of User standard object
 */
public with sharing class UserBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public UserBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!User.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!User.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true;
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!User.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true;
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
	/*	if (!User.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true;
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsAccessible(Schema.SObjectType.User.fields.getMap(), accessibleFields);          
		return true;  
	}  

	//@override Update Access  
	public override boolean isUpdateable(String [] updateablFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsUpdateable(Schema.SObjectType.User.fields.getMap(), updateablFields);        
		return true;  
	}  		  

	//@overload Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsCreateable(Schema.SObjectType.User.fields.getMap(), createableFields);       
		return true;  
	} 	
}