global with sharing class UpdateCompletedTaskBatch implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
	   String query = 'Select Id,LastModifiedDate ' +
	                                'From Task ' +
	                                'Where (Status = \'Completed\' AND  ' +
	                                        'What.Type = \'leankor__KanbanCard__c\' AND IsDeleted = false) All Rows';
	                                        
        return Database.getQueryLocator(query);
    }
        
            
    global void execute(Database.BatchableContext BC, List<Task> TaskList) {
        
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isUpdateable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior
        
        try{          
            update TaskList;
        }catch(Exception ex){
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
    }  


    global void finish(Database.BatchableContext BC) {

    }
}