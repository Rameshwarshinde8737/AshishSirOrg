/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: DeleteQueuesandGroup.cls
 * CLASS: DeleteQueuesandGroup    
 */
 
global with sharing class DeleteQueuesandGroup implements Database.Batchable<sObject>
{
    //
    // This Method is for Getting Per Card Chatter Massage in Batchformate  
    //
    global Database.QueryLocator start(Database.BatchableContext BC){
        string ob1 = 'leankor__KanbanCard__c';
        string ob2 = 'leankor__ZoneKanbanAction__c';
        string query = 'SELECT Id,QueueId,SobjectType FROM QueueSobject WHERE SobjectType = :ob1 OR SobjectType = :ob2 ';
        return Database.getQueryLocator(query);
    }
    //
    // This(Execute Method) is for Getting Per Card Chatter Massage in Batchformate  
    //
    global void execute(Database.BatchableContext BC, List<QueueSobject > scope){
        //Check CRUD / FLC behavior
        GroupBehaviour groupBehaviour = new GroupBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ZoneKanbanActionBehavior zoneKanbanActionBehavior = new ZoneKanbanActionBehavior();

        if  (!groupBehaviour.isAccessible()
        ||  !groupBehaviour.isDeletable()
        ||  !kanbanCardBehaviour.isAccessible()
        ||  !kanbanCardBehaviour.isDeletable()
        ||  !zoneKanbanActionBehavior.isAccessible()
        ||  !zoneKanbanActionBehavior.isDeletable()){
            //abort the job if no access
            System.abortJob(BC.getJobId());
        }        
        //Check CRUD / FLC behavior

        list<string> QueueIds = new List<string>();
        for(QueueSobject QuequeLog :scope){
            QueueIds.add(QuequeLog.QueueId);
        }
        List<Group> groupList=[SELECT Id,Type FROM Group WHERE ID IN : QueueIds AND Type = 'Queue'];
        //system.debug(QuequeList.size());
        if(scope.size()>0){
            DataBase.DeleteResult[] uResult;
            try{
                uResult = DataBase.Delete(scope,false); 
            }catch(DMLException ex){
                //25/04/2023 : We are Throwing Exception
                throw new DeleteQueuesandGroupException('ERROR:' + ex.getMessage()); 
            }
        }
        if(groupList.size()>0){
            DataBase.DeleteResult[] uResults;
            try{
                uResults = DataBase.Delete(groupList,false); 
            }catch(DMLException ex){ 
                //25/04/2023 : We are Throwing Exception
                throw new DeleteQueuesandGroupException('ERROR:' + ex.getMessage()); 
            }
        }
    }
    global void finish(Database.BatchableContext BC) {}

    global class DeleteQueuesandGroupException extends Exception{}
}