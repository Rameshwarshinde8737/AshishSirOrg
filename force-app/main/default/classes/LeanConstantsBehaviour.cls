public with sharing class LeanConstantsBehaviour extends AbstractCRUDBehaviour {

    //default constructor
    public LeanConstantsBehaviour() {

    }

    //@override Read Access  
    public override boolean isAccessible(){ 
		// 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
        /*if (!leankor__LeanConstants__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__LeanConstants__c.fields.getMap()); */       
        return true;   
    }   

    //@override Update Access
    public override boolean isUpdateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
        /*if (!leankor__LeanConstants__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__LeanConstants__c.fields.getMap()); */
        return true;
    }

    //@override Create Access
    public override boolean isCreateable(){
		// 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
        /*if (!leankor__LeanConstants__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__LeanConstants__c.fields.getMap()); */
        return true;
    }   

    //@override Delete Access
    public override boolean isDeletable(){
		// 28/05/2021 : We have relaxed security access for standard object.
        /*if (!leankor__LeanConstants__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }*/

        return true;
    }    

}