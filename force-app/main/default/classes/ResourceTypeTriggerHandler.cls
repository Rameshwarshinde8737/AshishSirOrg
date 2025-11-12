/*		
	FILE: ResourceTypeTriggerHandler.cls
 	CLASS: ResourceTypeTriggerHandler
 	Date :08/10/19	
*/
public with sharing class ResourceTypeTriggerHandler {
	
    public static void onDeleteResourceType(Map<Id,leankor__ResourceType__c> mapOfResourceType){
   
     	List<leankor__ResourceAssignment__c> resourceAssignMentList = [Select Id ,
																				leankor__ResourceType__c 
																			From leankor__ResourceAssignment__c
																			Where  leankor__ResourceType__c In:mapOfResourceType.keySet()
																			With Security_Enforced 
																			Limit 49999];          
    	for (leankor__ResourceAssignment__c resourceType :resourceAssignMentList) {       
        	if (mapOfResourceType.containsKey(resourceType.leankor__ResourceType__c)) { 
        		mapOfResourceType.get(resourceType.leankor__ResourceType__c).adderror('Can\'t delete a resource type that is already assigned to a resource.');
        	}              
    	}   
    
    }
}