global with sharing class DeleteScheduleModeRecords implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = ' SELECT Id FROM leankor__ScheduleMode__c where leankor__KanbanCard__r.Recordtype.name IN ( \'foldercard\',\'MilestoneCard\') ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<leankor__ScheduleMode__c> scheduleModeList){
        //Check CRUD / FLC behavior   
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isDeletable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior   

        try{
        	if(scheduleModeList.size() > 0)
        	{           
            	delete scheduleModeList;
        	}
        }catch(Exception ex){          
            //25/04/2023 : We are Throwing Exception
            throw new DeleteScheduleModeRecordsException('ERROR:' + ex.getMessage()); 
        }
    }  
    
    global void finish(Database.BatchableContext BC){}

    global class DeleteScheduleModeRecordsException extends Exception{}
}