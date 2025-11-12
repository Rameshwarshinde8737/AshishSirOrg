/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : ReportBehaviour.cls
 * CLASS : ReportBehaviour
 * USAGE : This class implements CRUD behaviour of Report standard object
 */
public with sharing class ReportBehaviour extends AbstractCRUDBehaviour {

	//default constructor
	public ReportBehaviour() {
		
	}

	//@override Read Access  
	public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Report.sObjectType.getDescribe().isAccessible()){
			return false;
		}*/

		return true;   
	}   

	//@override Update Access
	public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Report.sObjectType.getDescribe().isUpdateable()){
			return false;
		}*/

		return true;
	}

	//@override Create Access
	public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
		//Check object level security 
	/*	if (!Report.sObjectType.getDescribe().isCreateable()){
			return false;
		}*/

		return true;
	}   

	//@override Delete Access
	public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
	/*	if (!Report.sObjectType.getDescribe().isDeletable()){
			return false;
		}*/

		return true;
	} 

	//@override Read Access  
	public override boolean isAccessible(String [] accessibleFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
       // return checkFieldsAccessible(Schema.SObjectType.Report.fields.getMap(), accessibleFields);          
	   return true;  
	}  

	//@override Update Access  
	public override boolean isUpdateable(String [] updateablFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsUpdateable(Schema.SObjectType.Report.fields.getMap(), updateablFields);        
		return true;  
	}  		  

	//@overload Create Access  
	public override boolean isCreateable(String [] createableFields){ 
		// 28/05/2021 : We have relaxed security access for standard object.
		//return checkFieldsCreateable(Schema.SObjectType.Report.fields.getMap(), createableFields);       
		return true;  
	} 	
}