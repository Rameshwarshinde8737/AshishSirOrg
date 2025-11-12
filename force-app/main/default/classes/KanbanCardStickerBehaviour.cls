/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : KanbanCardStickerBehaviour.cls
 * CLASS : KanbanCardStickerBehaviour
 * USAGE : This class implements CRUD behaviour of leankor__KanbanCardSticker__c object
 */
public with sharing class KanbanCardStickerBehaviour extends AbstractCRUDBehaviour{
    
    //default constructor
    public KanbanCardStickerBehaviour() {
        
    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security first
        if (!leankor__KanbanCardSticker__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__KanbanCardSticker__c.fields.getMap());            
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security first
        if (!leankor__KanbanCardSticker__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__KanbanCardSticker__c.fields.getMap()); 

    }

    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security first
        if (!leankor__KanbanCardSticker__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__KanbanCardSticker__c.fields.getMap());

    }   

    //@override Delete Access
    public override boolean isDeletable(){
        if (!leankor__KanbanCardSticker__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    }   
}