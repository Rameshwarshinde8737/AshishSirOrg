/*
       Date :27/09/19
       To cover ResourceType trigger.
 */
@isTest
public class ResourceTypeTriggerTest {
    
    private Static testMethod void testResourceType(){
       user  thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];  
        List< leankor__ResourceType__c>  resourceTypeList =new List< leankor__ResourceType__c>();
    	for(Integer i=0;i<5;i++){
    		leankor__ResourceType__c  resourceType =new  leankor__ResourceType__c();
    			resourceType.Name='IT'+i;
    			resourceType.leankor__InternalHourlyRate__c=50;
    			resourceType.leankor__ExternalHourlyRate__c=60;   		   	
    			resourceTypeList.add(resourceType);
    		
    	}    	
    	 insert resourceTypeList;
    	 List<leankor__ResourceAssignment__c> resourceAssignmentList =new List<leankor__ResourceAssignment__c>();
    	 for(leankor__ResourceType__c resource:resourceTypeList){
    	 	leankor__ResourceAssignment__c resourceAssignment =new  leankor__ResourceAssignment__c();
    	  	resourceAssignment.leankor__ResourceType__c=resource.Id;
    	  	resourceAssignment.leankor__PercentCompleted__c=50;
    	  	resourceAssignment.leankor__PercentAllocation__c=60;
    	  	resourceAssignmentList.add(resourceAssignment);    	 	    	 
    	 }
    	insert  resourceAssignmentList;
    	System.runAs(thisUser){               
          try{
            	delete resourceTypeList;  
         	}catch(DMLexception e){
            	system.assert(e.getMessage().contains('Can\'t delete a resource type that is already assigned to a resource.'),'Can\'t delete a resource type that is already assigned to a resource.');                       
        	}     
        } 
        
    }
}