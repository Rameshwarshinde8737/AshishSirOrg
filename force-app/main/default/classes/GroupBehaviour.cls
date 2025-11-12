/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : GroupBehaviour.cls
 * CLASS : GroupBehaviour
 * USAGE : This class implements CRUD behaviour of Group standard object
 */
public with sharing class GroupBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public GroupBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Group.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Group.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true; 
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Group.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true; 
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Group.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true; 
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
       // return checkFieldsAccessible(Schema.SObjectType.Group.fields.getMap(), accessibleFields);          
	   return true;  
	}  

	//@override Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsCreateable(Schema.SObjectType.Group.fields.getMap(), createableFields);          
		return true;  
	}  	

	//@override Update Access  
	public override boolean isUpdateable(String [] updateableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsUpdateable(Schema.SObjectType.Group.fields.getMap(), updateableFields);          
		return true;  
	}  	
		
}