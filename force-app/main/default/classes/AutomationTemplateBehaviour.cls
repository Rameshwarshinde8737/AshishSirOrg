/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : AutomationTemplateBehaviour.cls
 * CLASS : AutomationTemplateBehaviour
 * USAGE : This class implements CRUD behaviour of leankor__AutomationTemplate__c object
 */
public with sharing class AutomationTemplateBehaviour extends AbstractCRUDBehaviour {

    //default constructor
    public AutomationTemplateBehaviour() {
        
    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security first
        if (!leankor__AutomationTemplate__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__AutomationTemplate__c.fields.getMap());            
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security first
        if (!leankor__AutomationTemplate__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__AutomationTemplate__c.fields.getMap()); 

    }

    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security first
        if (!leankor__AutomationTemplate__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__AutomationTemplate__c.fields.getMap());

    }   

    //@override Delete Access
    public override boolean isDeletable(){
        if (!leankor__AutomationTemplate__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    }   
}