/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : AttachmentBehaviour.cls
 * CLASS : AttachmentBehaviour
 * USAGE : This class implements CRUD behaviour of Attachment standard object
 */
public with sharing class AttachmentBehaviour extends AbstractCRUDBehaviour{

	//default constructor
	public AttachmentBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 27/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
		/*if (!Attachment.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 27/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Attachment.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true;
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 27/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Attachment.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true;
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 27/05/2021 : We have relaxed security access for standard object.
	/*	if (!Attachment.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true;
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 27/05/2021 : We have relaxed security access for standard object.
       // return checkFieldsAccessible(Schema.SObjectType.Attachment.fields.getMap(), accessibleFields);          
	   return true;  
	}  

	//@override Update Access  
	public override boolean isUpdateable(String [] updateablFields){ 
		// 27/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsUpdateable(Schema.SObjectType.Attachment.fields.getMap(), updateablFields);        
		return true;  
	}  		  

	//@overload Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 27/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsCreateable(Schema.SObjectType.Attachment.fields.getMap(), createableFields);       
		return true;  
	} 

}