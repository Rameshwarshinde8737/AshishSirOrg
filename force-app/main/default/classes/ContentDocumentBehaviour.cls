public with sharing class ContentDocumentBehaviour extends AbstractCRUDBehaviour {

    //default constructor
    public ContentDocumentBehaviour() {

    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        // 27/05/2021 : We have relaxed security access for standard object. 
        //Check object level security first
    	/* if (!ContentDocument.sObjectType.getDescribe().isAccessible()){
            return false;
        }*/
            
        //Check field level security second
        //return checkFieldsAccessible(Schema.SObjectType.ContentDocument.fields.getMap());            
        return true;  
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        // 27/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
      /*  if (!ContentDocument.sObjectType.getDescribe().isUpdateable()){
            return false;
        }*/
            
        //Check field level security second 
       // return checkFieldsUpdateable(Schema.SObjectType.ContentDocument.fields.getMap()); 
       return true;  
    }

    //@override Create Access
    public override boolean isCreateable(){
        // 27/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
     /*   if (!ContentDocument.sObjectType.getDescribe().isCreateable()){
            return false;
        }*/
            
        //Check field level security second  
       // return checkFieldsCreateable(Schema.SObjectType.ContentDocument.fields.getMap());
       return true;  
    }   

    //@override Delete Access
    public override boolean isDeletable(){
        // 27/05/2021 : We have relaxed security access for standard object.
    /*    if (!ContentDocument.sObjectType.getDescribe().isDeletable()){
            return false;
        }*/

        return true;
    } 
}