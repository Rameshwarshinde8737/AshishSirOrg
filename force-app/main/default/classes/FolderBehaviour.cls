/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : FolderBehaviour.cls
 * CLASS : FolderBehaviour
 * USAGE : This class implements CRUD behaviour of Folder standard object
 */
public with sharing class FolderBehaviour extends AbstractCRUDBehaviour {

    //default constructor
    public FolderBehaviour() {
        
    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security 
        if (!Folder.sObjectType.getDescribe().isAccessible()){
            return false;
        }

        return true;   
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security 
        if (!Folder.sObjectType.getDescribe().isUpdateable()){
            return false;
        }

        return true;
    }

    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security 
        if (!Folder.sObjectType.getDescribe().isCreateable()){
            return false;
        }

        return true;
    }   

    //@override Delete Access
    public override boolean isDeletable(){
        if (!Folder.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    } 

    //@override Read Access  
    public override boolean isAccessible(String [] accessibleFields){ 

        return checkFieldsAccessible(Schema.SObjectType.Folder.fields.getMap(), accessibleFields);          
    }  

    //@override Update Access  
    public override boolean isUpdateable(String [] updateablFields){ 

        return checkFieldsUpdateable(Schema.SObjectType.Folder.fields.getMap(), updateablFields);        
    }         

    //@overload Create Access  
    public override boolean isCreateable(String [] createableFields){ 

        return checkFieldsCreateable(Schema.SObjectType.Folder.fields.getMap(), createableFields);       
    }   
}