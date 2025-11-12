public with sharing class OpportunityBehaviour extends AbstractCRUDBehaviour  {

    //default constructor
    public OpportunityBehaviour() {

    }

    //@override Read Access  
    public override boolean isAccessible(){ 
        // 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
     /*   if (!Opportunity.sObjectType.getDescribe().isAccessible()){
            return false;
        }*/
            
        //Check field level security second
       // return checkFieldsAccessible(Schema.SObjectType.Opportunity.fields.getMap());            
       return true;  
    }   

    //@override Update Access
    public override boolean isUpdateable(){
        // 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
       /* if (!Opportunity.sObjectType.getDescribe().isUpdateable()){
            return false;
        }*/
            
        //Check field level security second 
        //return checkFieldsUpdateable(Schema.SObjectType.Opportunity.fields.getMap()); 
        return true;  
    }

    //@override Create Access
    public override boolean isCreateable(){
        // 28/05/2021 : We have relaxed security access for standard object.
        //Check object level security first
      /*  if (!Opportunity.sObjectType.getDescribe().isCreateable()){
            return false;
        }*/
            
        //Check field level security second  
        //return checkFieldsCreateable(Schema.SObjectType.Opportunity.fields.getMap());
        return true;  
    }   

    //@override Delete Access
    public override boolean isDeletable(){
        // 28/05/2021 : We have relaxed security access for standard object.
       /* if (!Opportunity.sObjectType.getDescribe().isDeletable()){
            return false;
        }*/

        return true;
    } 
}