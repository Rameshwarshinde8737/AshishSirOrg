/**
*Class : SetPercentCompletedOnRA
*Description :  Batch Apex class for update RA with new field value leankor__PercentCompleted__c
                and update RA with new field value completed date
*/

global with sharing class SetPercentCompletedOnRA implements Database.Batchable<sObject> {
       
    @TestVisible
    private Boolean isCompletedDate = false;
    
    public SetPercentCompletedOnRA(){}
    
    // This constructer will assign as true to isCompletedDate 
    public SetPercentCompletedOnRA(Boolean isCompletedDate) {
    	this.isCompletedDate = isCompletedDate;
    }

        
    //make batch apex for updating leankor__PercentCompleted__c field according to activity percentage level.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, leankor__PercentComplete2__c, leankor__HarveyBallDoneDate__c, (SELECT Id, LastModifiedDate, leankor__PercentCompleted__c FROM leankor__ResourceAssignments__r) FROM leankor__KanbanCard__c WHERE leankor__Valuestream__r.leankor__BoardType__c = \'UberBoard\' AND RecordType.Name =\'ActivityCard\' ';
        
        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> scope) {
        //Check CRUD / FLC behavior
		ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior(); 
		if (!resourceAssignmentBehavior.isUpdateable()) {
			System.abortJob(BC.getJobId());
		}
        //Check CRUD / FLC behavior
        
        List<leankor__ResourceAssignment__c> RAlist = new List<leankor__ResourceAssignment__c>();  
        // Update RA - leankor__PercentCompleted__c field according to activity percentage level.
        for (leankor__KanbanCard__c kc : scope) {            
            for (leankor__ResourceAssignment__c ra : kc.leankor__ResourceAssignments__r) {          
            	// If iscompleteddate will be true then only completed date field will be update 
            	if (isCompletedDate) {
            		if (ra.leankor__PercentCompleted__c == 100) {   
            			ra.leankor__CompletedDate__c = kc.leankor__HarveyBallDoneDate__c != null ? 
                            DateTime.newInstanceGMT(kc.leankor__HarveyBallDoneDate__c.year(),kc.leankor__HarveyBallDoneDate__c.month(),kc.leankor__HarveyBallDoneDate__c.day()):
                            ra.LastModifiedDate ;
            		} else if(kc.leankor__PercentComplete2__c == 100) {            		
            		    ra.leankor__PercentCompleted__c = kc.leankor__PercentComplete2__c;     		
            		}  		
            	}
            	//else iscompleteddate will be false then only percentcompleted field will be update
            	else{
            	    ra.leankor__PercentCompleted__c = kc.leankor__PercentComplete2__c;
            	}
            	
            	RAlist.add(ra);
            }                                          
        }

        if (RAlist.size() > 0) {
        	update RAlist;      
        }       	
    }
 
    global void finish(Database.BatchableContext BC) {
            
    }
}