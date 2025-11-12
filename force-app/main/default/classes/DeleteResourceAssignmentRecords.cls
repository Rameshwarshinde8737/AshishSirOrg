global with sharing class DeleteResourceAssignmentRecords implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = ' SELECT Id FROM leankor__ResourceAssignment__c where leankor__KanbanCard__r.Recordtype.name IN ( \'foldercard\',\'MilestoneCard\') ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<leankor__ResourceAssignment__c> resourceAssignmentList){
        //Check CRUD / FLC behavior   
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!resourceAssignmentBehavior.isDeletable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior   

        try{
        	if(resourceAssignmentList.size() > 0)
        	{           
            	delete resourceAssignmentList;
        	}
        }catch(Exception ex){          
            //25/04/2023 : We are Throwing Exception
            throw new DeleteResourceAssignmentRecordsException('ERROR:' + ex.getMessage()); 
        }
    } 
     
    global void finish(Database.BatchableContext BC){}

    global class DeleteResourceAssignmentRecordsException extends Exception{}
}