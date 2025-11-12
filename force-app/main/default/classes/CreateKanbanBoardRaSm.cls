global with sharing class CreateKanbanBoardRaSm implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	//no need to check record type becuase except planGantt we have all board cards by deafult activityCard.
        String query = 'SELECT Id,leankor__PercentComplete2__c ,leankor__HarveyBallDoneDate__c, OwnerId , LastModifiedDate,Leankor__Valuestream__r.leankor__boardtype__c FROM leankor__KanbanCard__c ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> scope){
        //Check CRUD / FLC behavior
        KanbanCardBehaviour KanbanCardBehaviour = new KanbanCardBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (
            !KanbanCardBehaviour.isAccessible() ||
            !KanbanCardBehaviour.isUpdateable() ||
            !scheduleModeBehavior.isAccessible() ||
            !scheduleModeBehavior.isCreateable() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isCreateable()
        ) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior

        list<leankor__ResourceAssignment__c> RAList = new list<leankor__ResourceAssignment__c>();
        List<leankor__ScheduleMode__c> SMlist = new List<leankor__ScheduleMode__c>();
        List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
        
        for(leankor__kanbancard__c Card:scope){
			if(Card.Leankor__Valuestream__r.leankor__boardtype__c == 'UberBoard') continue;
            leankor__ResourceAssignment__c Rsa = new leankor__ResourceAssignment__c();
                RSA.leankor__KanbanCard__c = Card.Id;
                RSA.leankor__AssignedTo__c = Card.OwnerId;
                RSA.leankor__PercentAllocation__c =100;
                RSA.leankor__PercentCompleted__c = Card.leankor__PercentComplete2__c;
                
                if(RSA.leankor__PercentCompleted__c == 100)
                {
                	//first we are checking harvey ball done date if we get null firstly we have to update date with lastmodified date.
                	if(Card.leankor__HarveyBallDoneDate__c == null)
                	{
                		Card.leankor__HarveyBallDoneDate__c = Card.LastModifiedDate.dateGMT();
                		kclist.add(Card);
                	}
                	RSA.leankor__CompletedDate__c = DateTime.newInstanceGMT(Card.leankor__HarveyBallDoneDate__c.year(),Card.leankor__HarveyBallDoneDate__c.month(),Card.leankor__HarveyBallDoneDate__c.day());
                	
                }
            
            RAList.add(RSA);
            
            leankor__ScheduleMode__c SCM = new leankor__ScheduleMode__c ();
                SCM.leankor__EffortActual__c = 0.0;
                SCM.leankor__EffortUnits__c = 'Days';
                SCM.leankor__KanbanCard__c = Card.Id;
                SCM.leankor__ManuallyScheduled__c = false;
                SCM.leankor__Mode__c = 'Normal';
            SMlist.add(SCM);
        }
        try{
        	update kclist;
            insert RAList;
            insert SMlist;
        }catch(Exception ex){
            //25/04/2023 : We are Throwing Exception
			throw new CreateKanbanBoardRaSmException('ERROR:' + ex.getMessage());
        }
    }  
    global void finish(Database.BatchableContext BC){}

    global class CreateKanbanBoardRaSmException extends Exception{}
}