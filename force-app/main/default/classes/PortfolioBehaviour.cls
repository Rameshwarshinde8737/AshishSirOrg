/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : PortfolioBehaviour.cls
 * CLASS : PortfolioBehaviour
 * USAGE : This class implements CRUD behaviour of leankor__Portfolio__c object / Folder object
 */
public with sharing class PortfolioBehaviour extends AbstractCRUDBehaviour {
    
    //default constructor
    public PortfolioBehaviour() {
        
    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security first
        if (!leankor__Portfolio__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__Portfolio__c.fields.getMap());            
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security first
        if (!leankor__Portfolio__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__Portfolio__c.fields.getMap()); 

    }

    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security first
        if (!leankor__Portfolio__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__Portfolio__c.fields.getMap());

    }   

    //@override Delete Access
    public override boolean isDeletable(){
        if (!leankor__Portfolio__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    }       
}