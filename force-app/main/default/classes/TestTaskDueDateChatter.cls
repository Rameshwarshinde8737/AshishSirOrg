/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestTaskDueDateChatter.cls
 * CLASS: TestTaskDueDateChatter
 */

@isTest
public class TestTaskDueDateChatter{

    static testMethod void test() {
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        Date dt=System.today();
        String due=String.valueOf(dt);
        /*leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS');
        insert vs;
         List<realtimeController.KanbanTemplate> kanbanTemps= new List<realtimeController.KanbanTemplate>();
        realtimeController.KanbanTemplate kanbanTemp= new realtimeController.KanbanTemplate();
        kanbanTemp.name ='TestTemplate';
        kanbanTemp.title ='TestTemplate';
        kanbanTemp.color ='#fff';
        kanbanTemp.csslayout='';
        kanbanTemp.height=300;
        kanbanTemp.width =300;
        kanbanTemp.jsondata='{}';
        kanbanTemp.jsondefinition='{}';
        kanbanTemp.valuestream=vs.Id;
        kanbanTemp.EntireBoard = true;
        kanbanTemp.EntireORG = false;
        kanbanTemp.EntireRoom = false;
        kanbanTemps.add(kanbanTemp);
        List<leankor__KanbanCardTemplate__c> temp =realtimeController.createKanbanCardTemplate(kanbanTemps); 
        system.assert(temp.size() != 0);
       String userId_1=UserInfo.getUserId();
         List<String> kanbans=new List<String>();
        realtimeController.Kanban newKanban2 = new realtimeController.Kanban();
        newKanban2.GUID ='305ee49a-8489-4091-bf76-8a08088066g8';
        newKanban2.ownerid=userId_1;
        newKanban2.title = 'newkanname';
        newKanban2.name = 'Small card';
        newKanban2.top = 100;
        newKanban2.bottom = 0;
        newKanban2.left = 100;
        newKanban2.width = 180;
        newKanban2.height = 200;
        newKanban2.x = 100;
        newKanban2.y = 100;
        newKanban2.JSONData = '{}';
        newKanban2.base64Drawing = 'somedummyfile';
        newKanban2.base64FileType = 'image/png';
        newKanban2.zoneid = 'randomzone';
        newKanban2.state = 'inzone';
        newKanban2.durationunits = 'Days';
        newKanban2.estimatedDuration = 1;
        newKanban2.duedate = System.Now();
        newKanban2.startdate = system.Now();
        newKanban2.templateid =temp[0].Id;
        newKanban2.priority = 3;
        newKanban2.harveyBall = '50';
        newKanban2.description = 'short description about the kanbancard';
		// Date: 02/01/2020
        newKanban2.kanbanUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/apex/leankor__VisualKanban?Id='+vs.id+'&cardid=';
        kanbans.add(JSON.Serialize(newKanban2));*/
        
        User user = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', user);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> retkan=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,user);
       // List<leankor__Preference__c> prefrenceList=TestDataFactory.createPreference(vs.Id);  
       // List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCard(vs.Id, kanbans);
         system.assert(retkan.size() > 0);
        leankor__Subscriber__c sub1=new leankor__Subscriber__c(name=retkan[0].Name,leankor__KanbanCard__c=retkan[0].Id,leankor__SubscriberKey__c=retkan[0].Id+'-'+user.id,leankor__SubscriberID__c=user.id,leankor__Moved__c=true,leankor__PercentDone__c=true,leankor__CardPastDueDate__c=true,leankor__TaskPastDueDate__c=true);
        insert sub1;
         List<realtimeController.TaskData> taskLst1= new List<realtimeController.TaskData>();
         //system.assert(taskLst1.size() >= 0);     
        realtimeController.TaskData tsk1 = new realtimeController.TaskData();
        tsk1.Priority   =   'High';
        tsk1.OwnerId     =  user.id;
        tsk1.Subject    =   'Other';
        tsk1.Status         =   'Not Started';
        tsk1.ActivityDate = due;
        tsk1.WhatId     =   retkan[0].Id;
        tsk1.Description =  'This is First Demo Task';
          taskLst1.add(tsk1);
        List<leankor.realtimeController.TaskData> TaskDataList1 = realtimeController.insertTask(taskLst1);
        System.assert(TaskDataList1.size() != 0);
        List<Task> AcctList = new List<Task>();
        TaskDueDateChatter AU = new TaskDueDateChatter(); 
        QL = AU.start(bc);
        
        Database.QueryLocatorIterator QIT =  QL.iterator();
            while (QIT.hasNext())
        {
            Task Acc = (Task)QIT.next();            
           
            AcctList.add(Acc);
        }        
    
       
      
        AU.execute(BC, AcctList);
        AU.finish(BC);        
    }
}