/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : ProjectLaunchBehavior.cls
 * CLASS : ProjectLaunchBehavior
 * USAGE : This class implements CRUD behaviour of leankor__ProjectLaunchBehavior__c object
 */
public with sharing class ProjectLaunchBehavior extends AbstractCRUDBehaviour{
    
    //default constructor
    public ProjectLaunchBehavior() {
        
    }

   //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security first
        if (!leankor__ProjectLaunchBehavior__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__ProjectLaunchBehavior__c.fields.getMap());            
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security first
        if (!leankor__ProjectLaunchBehavior__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__ProjectLaunchBehavior__c.fields.getMap()); 

    }

    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security first
        if (!leankor__ProjectLaunchBehavior__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__ProjectLaunchBehavior__c.fields.getMap());

    }   

    //@override Delete Access
    public override boolean isDeletable(){
        if (!leankor__ProjectLaunchBehavior__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    }   
}