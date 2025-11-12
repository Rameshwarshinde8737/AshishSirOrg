global with sharing class CreateScheduleModeRecord implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,OwnerId FROM leankor__KanbanCard__c where leankor__Valuestream__r.leankor__boardtype__c = \'UberBoard\' and recordtype.name =\'ActivityCard\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> scope){

        //Check CRUD / FLC behavior   
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        
        if (!scheduleModeBehavior.isCreateable()
        ||  !resourceAssignmentBehavior.isCreateable()){
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior
        list<leankor__ResourceAssignment__c> RAList = new list<leankor__ResourceAssignment__c>();
        List<leankor__ScheduleMode__c> SMlist = new List<leankor__ScheduleMode__c>();
        for(leankor__kanbancard__c Card:scope){
            leankor__ResourceAssignment__c Rsa = new leankor__ResourceAssignment__c();
                RSA.leankor__KanbanCard__c = Card.Id;
                RSA.leankor__AssignedTo__c = Card.OwnerId;
                RSA.leankor__PercentAllocation__c =100;
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
            insert RAList;
            insert SMlist;
        }catch(Exception ex){
            // code for to send email to support@leankor.com with the ORG ID
            //25/04/2023 : We are Throwing Exception
            throw new CreateScheduleModeRecordException('ERROR:' + ex.getMessage()); 
        }
    }  
    global void finish(Database.BatchableContext BC){}

    global class CreateScheduleModeRecordException extends Exception{}
}