global with sharing class IsRecordDeletedOfKanbanCard implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id , Recordtype.name , leankor__ValueStream__c ,leankor__ValueStreamCardLink__c ,leankor__ValueStreamLink__c ,leankor__isRecordDeleted__c ,(SELECT Id FROM leankor__ResourceAssignments__r),(SELECT Id FROM leankor__ScheduleModes__r) FROM leankor__KanbanCard__c'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> cardList){
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!resourceAssignmentBehavior.isDeletable() ||
            !scheduleModeBehavior.isDeletable() ||
            !kanbanCardBehaviour.isUpdateable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior 

        list<leankor__ResourceAssignment__c> RAList = new list<leankor__ResourceAssignment__c>();
        List<leankor__ScheduleMode__c> SMlist = new List<leankor__ScheduleMode__c>();
        List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
        
        for(leankor__kanbancard__c card:cardList) {

            if(card.leankor__ValueStream__c == null) {
				if(card.Recordtype.name == 'ActivityCard'){
                    RAList.addAll(card.leankor__ResourceAssignments__r);
                    SMlist.addAll(card.leankor__ScheduleModes__r);
				}
				card.leankor__isRecordDeleted__c = true;
				card.leankor__ValueStreamCardLink__c = null;
				card.leankor__ValueStreamLink__c = null;
			}else{
				card.leankor__isRecordDeleted__c = false;
			}
            
        }
        try{
            if(RAList.size() >  0 ) {
                delete RAList;
            }             
            if(SMlist.size() >  0 ) {
                delete SMlist;
            }                
            update cardList;
        }catch(Exception ex){
            //25/04/2023 : We are Throwing Exception
            throw new IsRecordDeletedOfKanbanCardException('ERROR:' + ex.getMessage());
        }
    }  
    global void finish(Database.BatchableContext BC){}

    global class IsRecordDeletedOfKanbanCardException extends Exception{}
}