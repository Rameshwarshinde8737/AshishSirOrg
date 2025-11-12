/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : ContentVersionBehaviour.cls
 * CLASS : ContentVersionBehaviour
 * USAGE : This class implements CRUD behaviour of ContentVersion standard object
 */
public with sharing class ContentVersionBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public ContentVersionBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
		/*if (!ContentVersion.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security
	/*	if (!ContentVersion.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true;  
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
		/*if (!ContentVersion.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true;  
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!ContentVersion.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true;  
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
       // return checkFieldsAccessible(Schema.SObjectType.ContentVersion.fields.getMap(), accessibleFields);          
	   return true;  
	}  

	//@override Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsCreateable(Schema.SObjectType.ContentVersion.fields.getMap(), createableFields);          
		return true;  
	}  	

	//@override Update Access  
	public override boolean isUpdateable(String [] updateableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //return checkFieldsUpdateable(Schema.SObjectType.ContentVersion.fields.getMap(), updateableFields);          
		return true;  
	}  				

}