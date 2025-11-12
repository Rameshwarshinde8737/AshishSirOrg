public with sharing class FilterBehaviour extends AbstractCRUDBehaviour{
	
	//default constructor
	public FilterBehaviour() {
		
	}


    //@override Read Access  
    public override boolean isAccessible(){ 
        //Check object level security first
        if (!leankor__Filter__c.sObjectType.getDescribe().isAccessible()){
            return false;
        }
            
        //Check field level security second
        return checkFieldsAccessible(Schema.SObjectType.leankor__Filter__c.fields.getMap());            
    }   


    //@override Update Access
    public override boolean isUpdateable(){
        //Check object level security first
        if (!leankor__Filter__c.sObjectType.getDescribe().isUpdateable()){
            return false;
        }
            
        //Check field level security second 
        return checkFieldsUpdateable(Schema.SObjectType.leankor__Filter__c.fields.getMap()); 
    }


    //@override Create Access
    public override boolean isCreateable(){
        //Check object level security first
        if (!leankor__Filter__c.sObjectType.getDescribe().isCreateable()){
            return false;
        }
            
        //Check field level security second  
        return checkFieldsCreateable(Schema.SObjectType.leankor__Filter__c.fields.getMap());
    }   

    
    //@override Delete Access
    public override boolean isDeletable(){
        if (!leankor__Filter__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }

        return true;
    }  	
}