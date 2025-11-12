/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestPortfolioController.cls
 * CLASS: TestPortfolioController
 */
 
@isTest
private class TestPortfolioController { 

public static testMethod void testGetResources(){
  leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c ='Kanban Board');
        insert vs;
         leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
            Name = 'template name',
            leankor__Width__c = 100,
            leankor__Title__c = 'template title',
            leankor__JSONDefinition__c = '{}',
            leankor__JSONData__c = '{}',
            leankor__Height__c = 200,
            leankor__CSSLayout__c = 'some css' ,
            leankor__valueStream__c =vs.id
           );
            
        insert kct;
      
          leankor__KanbanCard__c kc = new leankor__KanbanCard__c(
             Name = 'kanban test',
             leankor__Y__c = 20,
             leankor__X__c = 50,
             leankor__Width__c = 100,
             leankor__ValueStream__c = vs.Id,
             leankor__Top__c = 150,
             leankor__Title__c = 'kanban title test',
             leankor__Left__c = 250,
             leankor__JSONDefinition__c = '{}',
             leankor__JSONData__c = '{}',
             leankor__Height__c = 110,
             leankor__GUID__c = 'my-GUID-kanban-test',
             leankor__CmpID__c = 'my-CMPID-kanban-test',
             leankor__CSSLayout__c = 'some css',
             leankor__Bottom__c = 450,
             leankor__Priority__c = 1,
             leankor__KanbanCardTemplate__c=kct.Id,
             leankor__DurationUnits__c='Hours',
             leankor__EstimatedDuration__c=2
        );
        
        insert kc;
            task tsk = new task();
            tsk.WhatId = kc.id;
            tsk.Subject = 'my task';
            tsk.ActivityDate = system.today();
            insert tsk;
          leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c(
             Name = 'kanban test1',
              leankor__GUID__c = 'my-GUID-kanban-test1',
             leankor__CmpID__c = 'my-CMPID-kanban-test1',
             leankor__ValueStream__c = vs.Id,
             leankor__KanbanCardTemplate__c=kct.Id,
             leankor__DurationUnits__c='Minutes',
             leankor__EstimatedDuration__c=2
        );
       insert kc1;
         
         leankor__KanbanCard__c kc2 = new leankor__KanbanCard__c(
             Name = 'kanban test2',
             leankor__GUID__c = 'my-GUID-kanban-test2',
             leankor__CmpID__c = 'my-CMPID-kanban-test2',
             leankor__ValueStream__c = vs.Id,
             leankor__KanbanCardTemplate__c=kct.Id,
             leankor__DurationUnits__c='Months',
             leankor__EstimatedDuration__c=2
        );
        insert kc2;
         
         leankor__KanbanCard__c kc3 = new leankor__KanbanCard__c(
             Name = 'kanban test3',
             leankor__GUID__c = 'my-GUID-kanban-test3',
             leankor__CmpID__c = 'my-CMPID-kanban-test3',
             leankor__ValueStream__c = vs.Id,
             leankor__KanbanCardTemplate__c=kct.Id,
             leankor__DurationUnits__c='Years',
             leankor__EstimatedDuration__c=2
        );
        insert kc3;
         task tsk123 = new task();
        tsk123.WhatId = kc3.id;
        tsk123.Subject = 'my task';
        tsk123.ActivityDate = system.today();
        insert tsk123;
         leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c(
             Name = 'kanban test4',
             leankor__GUID__c = 'my-GUID-kanban-test4',
             leankor__CmpID__c = 'my-CMPID-kanban-test4',
             leankor__ValueStream__c = vs.Id,
             leankor__KanbanCardTemplate__c=kct.Id
             
        );
       insert kc4;
       
         
    //List<leankor.realtimeController.KanbanTemplate> kcTempList=leankor.PortfolioController.getResources(vs.Id);
    
    //leankor.PortfolioController.PortfolioResourceRecords KCTempList = leankor.PortfolioController.getResources(vs.Id);
    //System.assert(kcTempList !=null);
    List<String>remoteCards = new List<String>();
    Datetime StartDate =System.now();
    Datetime DueDate = System.now()+5;
    String remoteCard='{"Id" :"'+kc3.Id+'", "GUID" : "'+kc3.leankor__GUID__c+'","StartDate" : '+JSON.Serialize(StartDate)+',"DueDate" : '+JSON.Serialize(DueDate)+'}';
     remoteCards.add(remoteCard);
     String returnString = leankor.RealtimeController.UpdateDependencyCards(remoteCards);
         System.assert(returnString != 'Failed');

}
}