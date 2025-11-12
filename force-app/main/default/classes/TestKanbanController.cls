/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestKanbanController.cls
 * CLASS: TestKanbanController
*/

@isTest
private class TestKanbanController { 

    private static User uSamp = null;

    @testSetup static void testData() {     
        /* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
		Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);
        
        User u = leankor.TestDataFactory.createStandardUser('Lean123');     
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', u);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> kanbancardList=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,u);
        List<Task> taskList=new List<Task>();
        for(Integer i=0;i<5;i++ ){      
            Task tsk = new Task();
                tsk.Priority = 'High';
                tsk.OwnerID = UserInfo.getUserId();                             
                tsk.Status = 'In Progress';
                tsk.ActivityDate = system.Today();
                tsk.WhatId = kanbancardList[0].Id;  
                tsk.Priority='high';
                tsk.status='Not Started';
                tsk.Description='demo test';                                    
                taskList.add(Tsk);
        }
        insert taskList;
        List<leankor__Dependency__c> dependncyList=new List<leankor__Dependency__c>();
        for(Integer i=0;i<5;i++){
            leankor__Dependency__c dependency=new leankor__Dependency__c();
                dependency.leankor__GUID__c=leankor.TestDataFactory.createGuid()+i;
                dependency.leankor__ValueStream__c=valuestreamlist[0].id;
                dependency.leankor__LagLead__c=2;
                dependency.leankor__SuccessorType__c='Start To Start';
                dependency.leankor__LagLeadUnit__c='';
                dependency.leankor__Predecessor__c=kanbancardList[0].id;
                dependency.leankor__Successor__c=kanbancardList[0].id;
                dependncyList.add(dependency);
        }
        insert dependncyList;
		//create and insert ContentVersion
        leankor__ValueStream__c valueStreamTest= new leankor__ValueStream__c(Name = 'myValueStream',leankor__BoardType__C ='kanbanBoard', leankor__ProjectRoom__C =projectList[0].Id);
        insert valueStreamTest;
        leankor__KanbanCard__c card = new leankor__KanbanCard__c(Name = 'KanbanCard', leankor__ValueStream__c = valueStreamTest.Id);
        insert card;
        list<ContentVersion> contentVersionList = new list<ContentVersion>();   
        ContentVersion contentVersion_1 = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        ContentVersion contentVersion_2 = new ContentVersion(
          Title = 'Penguins1',
          PathOnClient = 'Penguins1.jpg',
          VersionData = Blob.valueOf('Test Content1'),
          IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_2);
        insert contentVersionList;         
        
        //create and insert FeedItem            
        FeedItem post = new FeedItem();
        post.parentid = card.Id;
        post.Body = 'Body';
        post.relatedRecordId = contentVersionList[0].id;
        insert post;  
        
        //create and associate a content attachment to the post
        FeedAttachment FA = new FeedAttachment();
        FA.FeedEntityId = post.Id;                                    
        FA.RecordId = contentVersionList[0].Id; 
        FA.Type = 'CONTENT';
        //insert FA;           
        
        FeedComment FC = new FeedComment();
        FC.FeedItemId = post.Id ;
        FC.CommentBody  = 'Abc';
        FC.RelatedRecordId = contentVersionList[1].Id; 
        insert FC ;   

        Account account = new Account(name ='Account') ;
        insert account; 
    
        Contact contact = new Contact(LastName ='testContact',AccountId = account.Id);
        insert contact;

        // creating data for testing constraints below
        List<leankor__Portfolio__c> constraintFolderList = leankor.TestDataFactory.createFolder('Constraint Test Folder', 1);

        List<leankor__ProjectRoom__c> constProjectsList = new List<leankor__ProjectRoom__c>();
        leankor__ProjectRoom__c constraintProject = new leankor__ProjectRoom__c();
        constraintProject.Name = 'Constraint Test';
        constraintProject.leankor__Portfolio__c = constraintFolderList[0].Id;
        constProjectsList.add(constraintProject);
        insert constProjectsList;

        List<leankor__ValueStream__c> constBoardsList = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c constValueStream = new leankor__ValueStream__c();
		constValueStream.Name =  'Constraint board'; 
		constValueStream.leankor__ProjectRoom__c = constraintProject.Id; 
		constValueStream.leankor__BoardType__c = 'UberBoard';
		constBoardsList.add(constValueStream);

        leankor__ValueStream__c kbValueStream = new leankor__ValueStream__c();
        kbValueStream.Name = 'Constraint kanban';
		kbValueStream.leankor__ProjectRoom__c = constraintProject.id;
		kbValueStream.leankor__BoardType__c = 'Kanban Board';
        kbValueStream.leankor__ScheduleBackward__c = true;
		constBoardsList.add(kbValueStream);
        insert constBoardsList;

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.Name = 'Test Blackout';
        blackOut.leankor__ProjectBoard__c = constValueStream.Id;
        blackOut.leankor__EndDate__c = System.Today() + 20;
        blackOut.leankor__StartDate__c = System.Today() + 18;
        blackOutsList.add(blackOut);

       leankor__ProjectScheduleBlackout__c blackOut2 = new leankor__ProjectScheduleBlackout__c();
        blackOut2.Name = 'Test Blackout-2';
        blackOut2.leankor__ProjectBoard__c = kbValueStream.Id;
        blackOut2.leankor__EndDate__c = System.Today() + 20;
        blackOut2.leankor__StartDate__c = System.Today() + 18;
        blackOutsList.add(blackOut2);
        insert blackOutsList;
        
        leankor__KanbanCardTemplate__c constraintTemplate = leankor.TestDataFactory.createKanbanCardTemplate(constValueStream); 
        List<leankor__KanbanCard__c> constraintActivityList = leankor.TestDataFactory.createActivityGroups(constValueStream,constraintTemplate,3);

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        Integer kbCount = 0;
        Integer actCount = 0;
        for (leankor__KanbanCard__c ag : constraintActivityList){
            for(Integer i = 0; i < 4; i++){			
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
                kanbanCard.leankor__KanbanCardTemplate__c = constraintTemplate.Id;
                kanbanCard.leankor__DurationUnits__c ='Days';
                kanbanCard.leankor__StartDateTime__c = System.now();
                kanbanCard.OwnerId = u.Id;
                kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
                kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
                if(Math.mod(i, 2) == 0) { 
                    kanbanCard.Name = 'Activity '+ kbCount;
                    kanbanCard.leankor__Title__c = 'Activity '+ kbCount; 
                    kanbanCard.leankor__ValueStream__c = kbValueStream.Id;
                    kanbanCard.leankor__DueDateTime__c = System.now().addDays(kbCount);
                    kanbanCard.leankor__EstimatedDuration__c = kbCount;
                    kbCount++;
                } else {
                    kanbanCard.Name = 'Activity '+ actCount;
                    kanbanCard.leankor__Title__c = 'Activity '+ actCount; 
                    kanbanCard.leankor__ValueStream__c = constValueStream.Id;
                    kanbanCard.leankor__DueDateTime__c = System.now().addDays(actCount);
                    kanbanCard.leankor__EstimatedDuration__c = actCount;
                    kanbanCard.leankor__ValueStreamCardLink__c = ag.Id;
                    actCount++;
                }
                kanbanCardsList.add(kanbanCard);
            }
        }
        insert kanbanCardsList;

        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = false;
        customSetting.leankor__ManuallyScheduled__c = false;
        customSetting.leankor__StreamingAPIVersion__c = 55.0;
        insert customSetting;

        List<leankor__ValueStream__c> valuestreamlistWithoutLaunchDate = leankor.TestDataFactory.createValueStream(projectList, '', u);

        leankor__ValueStream__c valuestreamwithProjectLaunchdate = new leankor__ValueStream__c(Name = 'Valuestream ProjectLaunchDate',
                                                                                               leankor__ProjectBoardLaunchDateTime__c = System.now(),
                                                                                               leankor__Boardtype__c = 'UberBoard',
                                                                                               leankor__ProjectRoom__c = projectList[0].Id,
                                                                                               leankor__ProjectBoardStartDateTime__c = System.now().addDays(-4),
                                                                                               leankor__ProjectBoardEndDateTime__c = System.now().addDays(-2));
        insert valuestreamwithProjectLaunchdate; 
        leankor__ValueStream__c valuestreamwithMilestone = new leankor__ValueStream__c(Name = 'Valuestream Milestone',
                                                                                               leankor__ProjectBoardLaunchDateTime__c = System.now(),
                                                                                               leankor__Boardtype__c = 'UberBoard',
                                                                                               leankor__ProjectRoom__c = projectList[0].Id);
        insert valuestreamwithMilestone; 
        leankor__KanbanCard__c milestone = new leankor__KanbanCard__c();
        milestone.Name = 'MileStoneCard';
        milestone.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
        milestone.leankor__ValueStream__c = valuestreamwithMilestone.Id;
        milestone.leankor__GUID__c = TestDataFactory.createGuid();
        milestone.leankor__CardID__c = String.valueOf(1);
        milestone.leankor__Title__c = 'Activity';
        milestone.leankor__Priority__c = 1;
        milestone.leankor__ValueStreamCardLink__c = null;
        milestone.leankor__KanbanCardTemplate__c = template.Id;
        milestone.leankor__StartDate__c = System.today().addDays(1);
        milestone.leankor__DueDate__c = System.today().addDays(1+1);
        milestone.leankor__StartDateTime__c = System.now().addDays(1);
        milestone.leankor__DueDateTime__c = System.now().addDays(1+1);
        milestone.leankor__DurationUnits__c  = 'Minutes';
        milestone.leankor__EstimatedDuration__c = 427;
        milestone.leankor__PercentComplete2__c = 0;
        milestone.leankor__IsSuccessorRecalculate__c = False;
        milestone.leankor__IsExternallyDependent__c = False;
        insert milestone;

        FeedItem feedpost = new FeedItem();
        feedpost.parentid = valuestreamwithProjectLaunchdate.Id;
        feedpost.Body = 'Body';
        feedpost.relatedRecordId = contentVersionList[0].id;
        insert feedpost;

        FeedComment fedComment = new FeedComment();
        fedComment.FeedItemId = feedpost.Id ;
        fedComment.CommentBody  = 'Abc';
        fedComment.RelatedRecordId = contentVersionList[1].Id; 
        insert fedComment ;
        leankor__ValueStream__c valuestreamwithSevendays = new leankor__ValueStream__c(Name = 'Valuestream SevenDay',
                                                                                       leankor__ProjectBoardLaunchDateTime__c = System.now(),
                                                                                       leankor__Boardtype__c = 'UberBoard',
                                                                                       leankor__ProjectRoom__c = projectList[0].Id,
                                                                                       leankor__SevenDayWorkWeek__c = true,
                                                                                       leankor__ScheduleBackward__c = true);
        insert valuestreamwithSevenDays;
        leankor__ValueStream__c valuestrmSevendays = new leankor__ValueStream__c(Name = 'Valuestream Seven Days',
                                                                                 leankor__ProjectBoardLaunchDateTime__c = System.now(),
                                                                                 leankor__Boardtype__c = 'UberBoard',
                                                                                 leankor__ProjectRoom__c = projectList[0].Id,
                                                                                 leankor__SevenDayWorkWeek__c = true,
                                                                                 leankor__ScheduleBackward__c = true);
        insert valuestrmSevendays;
        leankor__KanbanCard__c kanbanhour = new leankor__KanbanCard__c();
        kanbanhour.Name = 'Activity';
        kanbanhour.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanhour.leankor__ValueStream__c = valuestrmSevendays.Id;
        kanbanhour.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanhour.leankor__DurationUnits__c  = 'Hours';
        kanbanhour.leankor__EstimatedDuration__c = 8;
        insert kanbanhour;
        leankor__KanbanCard__c kanbanWeek = new leankor__KanbanCard__c();
        kanbanWeek.Name = 'Activity';
        kanbanWeek.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanWeek.leankor__ValueStream__c = valuestrmSevendays.Id;
        kanbanWeek.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanWeek.leankor__DurationUnits__c  = 'Weeks';
        kanbanWeek.leankor__EstimatedDuration__c = 8;
        insert kanbanWeek;
        leankor__KanbanCard__c kanbanMinutes = new leankor__KanbanCard__c();
        kanbanMinutes.Name = 'Activity';
        kanbanMinutes.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanMinutes.leankor__ValueStream__c = valuestrmSevendays.Id;
        kanbanMinutes.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanMinutes.leankor__DurationUnits__c  = 'Minutes';
        kanbanMinutes.leankor__EstimatedDuration__c = 60;
        insert kanbanMinutes;
        List<String> units = new List<String>{'Days','Years','Months','Minutes','Hours'};
        List<leankor__KanbanCard__c> kanbanList = new List<leankor__KanbanCard__c>();      
        for(Integer count = 0; count < 5; count++){
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'Activity';
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanban.leankor__ValueStream__c = valuestreamwithProjectLaunchdate.Id;
            kanban.leankor__GUID__c = TestDataFactory.createGuid();
            kanban.leankor__CardID__c = String.valueOf(count);
            kanban.leankor__Title__c = 'Activity';
            kanban.leankor__Priority__c = 1;
            kanban.leankor__ValueStreamCardLink__c = null;
            kanban.leankor__KanbanCardTemplate__c = template.Id;
            kanban.leankor__StartDate__c = System.today().addDays(count);
            kanban.leankor__DueDate__c = System.today().addDays(count+1);
            kanban.leankor__StartDateTime__c = System.now().addDays(count);
            kanban.leankor__DueDateTime__c = System.now().addDays(count+1);
            kanban.leankor__DurationUnits__c  = units[count];
            kanban.leankor__EstimatedDuration__c = 6;
            kanban.leankor__PercentComplete2__c = 0;
            kanban.leankor__IsSuccessorRecalculate__c = False;
            kanban.leankor__IsExternallyDependent__c = False;
            kanbanList.add(kanban);
        }
        insert kanbanList;
        leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
        mustFinishOn.leankor__Description__c = 'mustfinishon';
        mustFinishOn.leankor__Type__c = 'mustfinishon';
        insert mustFinishOn;

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = kanbanList[0].Id;
        schedMode.leankor__ConstraintDateTime__c = System.now();
        schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedMode;
        List<leankor__KanbanCard__c> kanbanListSevenDays = new List<leankor__KanbanCard__c>();      
        for(Integer count = 0; count < 5; count++){
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'Activity Seven Day';
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanban.leankor__ValueStream__c = valuestreamwithSevendays.Id;
            kanban.leankor__GUID__c = TestDataFactory.createGuid();
            kanban.leankor__CardID__c = String.valueOf(count);
            kanban.leankor__Title__c = 'Activity';
            kanban.leankor__Priority__c = 1;
            kanban.leankor__ValueStreamCardLink__c = null;
            kanban.leankor__KanbanCardTemplate__c = template.Id;
            kanban.leankor__StartDate__c = System.today().addDays(count);
            kanban.leankor__DueDate__c = System.today().addDays(count+1);
            kanban.leankor__StartDateTime__c = System.now().addDays(count);
            kanban.leankor__DueDateTime__c = System.now().addDays(count+1);
            kanban.leankor__DurationUnits__c  = 'Months';
            kanban.leankor__EstimatedDuration__c = 6;
            kanban.leankor__PercentComplete2__c = 0;
            kanban.leankor__IsSuccessorRecalculate__c = false;
            kanban.leankor__IsExternallyDependent__c = false;
            kanbanListSevenDays.add(kanban);
        }
        insert kanbanListSevenDays;

        List<leankor__KanbanCard__c> kanbanListWithoutLaunchDate = new List<leankor__KanbanCard__c>();      
        for(Integer count = 0; count < 5; count++){
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'Activity';
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanban.leankor__ValueStream__c = valuestreamlistWithoutLaunchDate[0].Id;
            kanban.leankor__GUID__c = TestDataFactory.createGuid();
            kanban.leankor__CardID__c = String.valueOf(count);
            kanban.leankor__Title__c = 'Activity';
            kanban.leankor__Priority__c = 1;
            kanban.leankor__ValueStreamCardLink__c = null;
            kanban.leankor__KanbanCardTemplate__c = template.Id;
            kanban.leankor__StartDate__c = System.today().addDays(count);
            kanban.leankor__DueDate__c = System.today().addDays(count+1);
            kanban.leankor__StartDateTime__c = System.now().addDays(count);
            kanban.leankor__DueDateTime__c = System.now().addDays(count+1);
            kanban.leankor__DurationUnits__c  = 'Days';
            kanban.leankor__EstimatedDuration__c = 6;
            kanban.leankor__PercentComplete2__c = 0;
            kanban.leankor__IsSuccessorRecalculate__c = false;
            kanban.leankor__IsExternallyDependent__c = false;
            kanbanListWithoutLaunchDate.add(kanban);
        }
        insert kanbanListWithoutLaunchDate;

        List<leankor__KanbanCard__c> kanbanListWithoutFinalStart = new List<leankor__KanbanCard__c>();      
        for(Integer count = 0; count < 5; count++){
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'Activity1';
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanban.leankor__ValueStream__c = valuestreamlistWithoutLaunchDate[0].Id;
            kanban.leankor__GUID__c = TestDataFactory.createGuid();
            kanban.leankor__CardID__c = String.valueOf(count);
            kanban.leankor__Title__c = 'Activity';
            kanban.leankor__Priority__c = 1;
            kanban.leankor__ValueStreamCardLink__c = null;
            kanban.leankor__KanbanCardTemplate__c = template.Id;
            kanban.leankor__DurationUnits__c  = 'Days';
            kanban.leankor__EstimatedDuration__c = 6;
            kanban.leankor__PercentComplete2__c = 0;
            kanban.leankor__IsSuccessorRecalculate__c = false;
            kanban.leankor__IsExternallyDependent__c = false;
            kanbanListWithoutFinalStart.add(kanban);
        }
        insert kanbanListWithoutFinalStart;

        List<leankor__KanbanCard__c> kanbanListWithCardLink = new List<leankor__KanbanCard__c>();      
        for(leankor__KanbanCard__C kanbanCardforlinking : kanbanListSevenDays){
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'ActivityLinking';
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanban.leankor__ValueStream__c = valuestreamwithSevendays.Id;
            kanban.leankor__GUID__c = TestDataFactory.createGuid();
            kanban.leankor__Title__c = 'Activity';
            kanban.leankor__Priority__c = 1;
            kanban.leankor__ValueStreamCardLink__c = kanbanCardforlinking.Id;
            kanbanListWithCardLink.add(kanban);
        }
        insert kanbanListWithCardLink;

        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c(Name= 'masterContainer',
                                                                                      leankor__ValueStream__c = valuestreamwithSevendays.Id,
                                                                                      leankor__order__c =0.0,
                                                                                      leankor__Type__c ='backlog');
        insert masterContainer;
       leankor__swimlane__c swimlane =new leankor__swimlane__c(Name ='swimlane test',
                                                               leankor__MasterContainer__c = masterContainer.ID,
                                                               leankor__order__c =0.0,
                                                               leankor__ValueStream__c = valuestreamwithSevendays.Id);
        insert swimlane; 
        leankor__Zone__c zone = new leankor__Zone__c(Name = 'kanban test3',
                                                     leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                     leankor__CmpID__c = 'my-CMPID-zone-test3',
                                                     leankor__swimlane__c = swimlane.ID,
                                                     leankor__ValueStream__c = valuestreamwithSevendays.Id);
        insert zone;
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c(Name ='new card',
                                                                       leankor__ValueStream__C = valuestreamwithSevendays.ID,
                                                                       leankor__order__c = 5,
                                                                       leankor__GUID__c = zone.leankor__GUID__C,
                                                                       leankor__StartDateTime__c= System.now(),
                                                                       leankor__DueDateTime__c= System.now()+5,
                                                                       leankor__StartDate__c = System.Today(),
                                                                       leankor__Zone__c = zone.Id);
        insert kanbanCard;
        leankor__ScheduleMode__c schedModes = new leankor__ScheduleMode__c();
        schedModes.leankor__KanbanCard__c = kanbanCard.Id;
        schedModes.leankor__ConstraintDateTime__c = System.now();
        schedModes.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedModes;
        leankor__KanbanCard__c kanbanCardFiveday = new leankor__KanbanCard__c(Name ='Five day working',
                                                                              leankor__ValueStream__C = valuestreamwithProjectLaunchdate.ID,
                                                                              leankor__order__c = 5,
                                                                              leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                              leankor__StartDateTime__c= System.now(),
                                                                              leankor__DueDateTime__c= System.now()+5,
                                                                              leankor__DurationUnits__c = 'years',
                                                                              leankor__EstimatedDuration__c = 5);
        insert kanbanCardFiveday;
        leankor__KanbanCard__c kanbanCardForMonths = new leankor__KanbanCard__c(Name ='Five day working',
                                                                                leankor__ValueStream__C = valuestreamwithProjectLaunchdate.ID,
                                                                                leankor__order__c = 5,
                                                                                leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                                leankor__StartDateTime__c= System.now(),
                                                                                leankor__DueDateTime__c= System.now()+5,
                                                                                leankor__DurationUnits__c = 'Months',
                                                                                leankor__EstimatedDuration__c = 5);
        insert kanbanCardForMonths;
        leankor__ScheduleMode__c schedModecardRecords = new leankor__ScheduleMode__c();
        schedModecardRecords.leankor__KanbanCard__c = kanbanCardForMonths.Id;
        schedModecardRecords.leankor__ConstraintDateTime__c = kanbanCardForMonths.leankor__DueDateTime__c;
        schedModecardRecords.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedModecardRecords;
        leankor__KanbanCard__c kanbanCardForMinutes = new leankor__KanbanCard__c(Name ='Five day working',
                                                                                 leankor__ValueStream__C = valuestreamwithProjectLaunchdate.ID,
                                                                                 leankor__order__c = 5,
                                                                                 leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                                 leankor__StartDateTime__c= System.now(),
                                                                                 leankor__DueDateTime__c= System.now()+5,
                                                                                 leankor__DurationUnits__c = 'Minutes',
                                                                                 leankor__EstimatedDuration__c = 5);
        insert kanbanCardForMinutes;
        leankor__KanbanCardTemplate__c KCtemp1 = new leankor__KanbanCardTemplate__c(Name = 'RED Card',
                                                                                   leankor__ValueStream__c = valuestreamwithProjectLaunchdate.id,
                                                                                   leankor__Color__c = '#F71B1B',
                                                                                   leankor__Width__c = 328.0);
        insert KCtemp1;
        leankor__Sticker__c  sticker = new leankor__Sticker__c(Name = 'sticker 1',
                                                               leankor__ValueStream__c = valueStreamTest.ID);
        insert sticker;
        Attachment  attachmnt = new Attachment (Name ='attchment1', 
                                                Body = Blob.valueOf('a file'), 
                                                ParentId = sticker.id);
        insert attachmnt;
        leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__Sticker__c = sticker.id );     
        insert KanbanSt;
       leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM') ;
       insert linkr;
       leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',
                                                                 leankor__BoardType__c='Kanban Board' ,
                                                                 leankor__projectroom__C = LinkR.id);
       insert Linkb;
       leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',
                                                                  leankor__GUID__c = leankor.TestDataFactory.createGuid());
       insert linkKC; 
        Task tsk = new Task();
            tsk.Priority = 'High';
            tsk.OwnerID = UserInfo.getUserId();                             
            tsk.Status = 'In Progress';
            tsk.ActivityDate = system.Today();
            tsk.WhatId = kanbanCardForMinutes.Id;  
            tsk.Priority='high';
            tsk.status='Not Started';
            tsk.Description='demo test';                                 
        insert tsk;
        
        leankor__KanbanCard__c kanbanCardLinked = new leankor__KanbanCard__c(Name ='card linked',
                                                                             leankor__ValueStream__C = valuestreamwithSevendays.ID,
                                                                             leankor__order__c = 5,
                                                                             leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                             leankor__StartDateTime__c= System.now().addDays(1),
                                                                             leankor__DueDateTime__c= System.now()+5,
                                                                             leankor__StartDate__c = System.Today(),
                                                                             leankor__Zone__c = zone.Id);
        insert kanbanCardLinked;
        leankor__KanbanCard__c cardLink = new leankor__KanbanCard__c();
        cardLink.Name = 'cardLink';
        cardLink.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        cardLink.leankor__ValueStream__c = valuestreamwithSevendays.Id;
        cardLink.leankor__ValueStreamCardLink__c = kanbanCardLinked.Id;
        cardLink.leankor__StartDateTime__C = System.now().addDays(2);
        cardLink.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        insert cardLink;
        leankor__ValueStream__c valuestreamwithWhithoutcard = new leankor__ValueStream__c(Name = 'Valuestream Whithout card',
                                                                                          leankor__Boardtype__c = 'DashBoard',
                                                                                          leankor__ProjectRoom__c = projectList[0].Id,
                                                                                          leankor__SevenDayWorkWeek__c = true,
                                                                                          leankor__ScheduleBackward__c = true);
        insert valuestreamwithWhithoutcard;
        leankor__Chart__C chart;
        List<leankor__Chart__C> charts = new List<leankor__Chart__C>();
        List<String> labelName = new List<String>{'Value Stream: Value Stream Name', 'Project Room','Project Room Name','Id','Value Stream ID','Project Room ID'};
        List<kanbancontroller.chartJSON> chartJson = new List<kanbancontroller.chartJSON>();
        for(String names : labelName){
            kanbancontroller.chartJSON chatjson = new kanbancontroller.chartJSON();
            chatjson.columnLabel = names;
            chartJson.add(chatjson);
            String json = JSON.Serialize(chartJson);
            chart = new leankor__Chart__C(leankor__ChartURL__c ='123',
                                          leankor__reportID__c = '123',
                                          Name ='tets',
                                          leankor__DeveloperName__c= 'LeanReports',
                                          leankor__GUID__c =leankor.TestDataFactory.createGuid(),
                                          leankor__ValueStream__c = valuestreamwithWhithoutcard.ID,
                                          leankor__jsondata__c = json);
            charts.add(chart);
        }
        insert charts;

        leankor__Chart__C chartRecord = new leankor__Chart__C(leankor__ChartURL__c ='123',
                                                              leankor__reportID__c = '123',
                                                              Name ='tets',
                                                              leankor__DeveloperName__c= 'LeanReports',
                                                              leankor__GUID__c =leankor.TestDataFactory.createGuid(),
                                                              leankor__ValueStream__c = valuestreamwithWhithoutcard.ID,
                                                              leankor__jsondata__c = '');
        insert chartRecord;
        leankor__TimeSheet__c approvalTimeSheet = new leankor__TimeSheet__c(Name = 'testTimeSheet-1',
                                                                            leankor__StartDateTime__c = DateTime.newInstance(2022, 12, 1,00,00,00),
                                                                            leankor__EndDateTime__c = DateTime.newInstance(2023, 1, 7,00,00,00),
                                                                            leankor__Resource__c = UserInfo.getUserId(),
                                                                            leankor__ApprovalHistoryStatus__c = null);
        insert approvalTimeSheet;
        leankor__TimeCard__c timeCard = new leankor__TimeCard__c( leankor__KanbanCard__c = kanbanCardFiveday.id );
        insert timeCard;
        leankor__ValueStream__c valuestreamTask = new leankor__ValueStream__c(Name = 'Valuestream Task',
                                                                              leankor__Boardtype__c = 'DashBoard',
                                                                              leankor__ProjectRoom__c = projectList[0].Id,
                                                                              leankor__SevenDayWorkWeek__c = true,
                                                                              leankor__ScheduleBackward__c = true);
        insert valuestreamTask;
        leankor__KanbanCardTemplate__c cardtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card1',
                                                                                     leankor__ValueStream__c = valuestreamTask.id,
                                                                                     leankor__Color__c = '#F71B1B',
                                                                                     leankor__Width__c = 328.0);
        insert cardtemp;
        leankor__KanbanCard__c kanbanCardTask = new leankor__KanbanCard__c(Name ='card Task',
                                                                           leankor__ValueStream__C = valuestreamTask.ID,
                                                                           leankor__order__c = 5,
                                                                           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                           leankor__StartDateTime__c= System.now().addDays(1),
                                                                           leankor__DueDateTime__c= System.now()+5,
                                                                           leankor__StartDate__c = System.Today(),
                                                                           leankor__Zone__c = zone.Id,
                                                                           leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                           leankor__EstimatedDuration__c = 4,
                                                                           leankor__KanbanCardTemplate__C = cardtemp.Id);
        insert kanbanCardTask;
        Task tskk = new Task();
        tskk.Priority = 'High';
        tskk.OwnerID = UserInfo.getUserId();                             
        tskk.Status = 'In Progress';
        tskk.ActivityDate = System.Today();
        tskk.WhatId = kanbanCardTask.Id;  
        tskk.Priority='high';
        tskk.status='Not Started';
        tskk.Description='demo test';                                 
        insert tskk;
        
        leankor__ValueStream__c valuestramTask = new leankor__ValueStream__c(Name = 'Valuestream seven day false',
                                                                             leankor__Boardtype__c = 'DashBoard',
                                                                             leankor__ProjectRoom__c = projectList[0].Id,
                                                                             leankor__SevenDayWorkWeek__c = false,
                                                                             leankor__TaskDateCheck__c = true);
        insert valuestramTask;
        leankor__KanbanCard__c kanbanCrdTask = new leankor__KanbanCard__c(Name ='card Task five day',
                                                                          leankor__ValueStream__C = valuestreamTask.ID,
                                                                          leankor__order__c = 5,
                                                                          leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                          leankor__StartDateTime__c= System.now().addDays(1),
                                                                          leankor__DueDateTime__c= System.now()+5,
                                                                          leankor__StartDate__c = System.Today());
        insert kanbanCrdTask;
        Task tsskk = new Task();
        tsskk.Priority = 'High';
        tsskk.OwnerID = UserInfo.getUserId();                             
        tsskk.Status = 'In Progress';
        tsskk.ActivityDate = System.Today()+6;
        tsskk.WhatId = kanbanCrdTask.Id;  
        tsskk.Priority='high';
        tsskk.status='Not Started';
        tsskk.Description='demo test';                                 
        insert tsskk;

        leankor__KanbanCard__c kanbanCrdTasknext = new leankor__KanbanCard__c(Name ='Task five day',
                                                                              leankor__ValueStream__C = valuestramTask.ID,
                                                                              leankor__order__c = 5,
                                                                              leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                              leankor__StartDateTime__c= System.now().addDays(1),
                                                                              leankor__DueDateTime__c= System.now()+5,
                                                                              leankor__StartDate__c = System.Today());
        insert kanbanCrdTasknext;
        Task tskkk = new Task();
        tskkk.Priority = 'High';
        tskkk.OwnerID = UserInfo.getUserId();                             
        tskkk.Status = 'In Progress';
        tskkk.ActivityDate = System.Today()+4;
        tskkk.WhatId = kanbanCrdTasknext.Id;  
        tskkk.Priority='high';
        tskkk.status='Not Started';
        tskkk.Description='demo test';                                 
        insert tskkk;

        
        leankor__KanbanCard__c kanbanCrdTasknextone = new leankor__KanbanCard__c(Name ='Task five day next',
                                                                                leankor__ValueStream__C = valuestramTask.ID,
                                                                                leankor__order__c = 5,
                                                                                leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                                leankor__StartDateTime__c= System.now().addDays(1),
                                                                                leankor__DueDateTime__c= System.now()+4,
                                                                                leankor__StartDate__c = System.Today());
        insert kanbanCrdTasknextone;
        Task taskkk = new Task();
        taskkk.Priority = 'High';
        taskkk.OwnerID = UserInfo.getUserId();                             
        taskkk.Status = 'In Progress';
        taskkk.ActivityDate = System.Today()+5;
        taskkk.WhatId = kanbanCrdTasknextone.Id;  
        taskkk.Priority='high';
        taskkk.status='Not Started';
        taskkk.Description='demo test';                                 
        insert taskkk;

        leankor__ValueStream__c valueTask = new leankor__ValueStream__c(Name = 'Valuestream Task five day',
                                                                        leankor__Boardtype__c = 'DashBoard',
                                                                        leankor__ProjectRoom__c = projectList[0].Id,
                                                                        leankor__SevenDayWorkWeek__c = true,
                                                                        leankor__TaskDateCheck__c = true);
        insert valueTask;
        leankor__KanbanCardTemplate__c cardtemptwo = new leankor__KanbanCardTemplate__c(Name = 'RED Card2',
                                                                                        leankor__ValueStream__c = valueTask.id,
                                                                                        leankor__Color__c = '#F71B1B',
                                                                                        leankor__Width__c = 328.0);
        insert cardtemptwo;
        leankor__ValueStream__c valueTaskfive = new leankor__ValueStream__c(Name = 'Valuestream Task five day',
                                                                            leankor__Boardtype__c = 'DashBoard',
                                                                            leankor__ProjectRoom__c = projectList[0].Id,
                                                                            leankor__SevenDayWorkWeek__c = false,
                                                                            leankor__TaskDateCheck__c = true );
        insert valueTaskfive;
        leankor__ValueStream__c valueTaskthree = new leankor__ValueStream__c(Name = 'Valuestream Task five day',
                                                                            leankor__Boardtype__c = 'DashBoard',
                                                                            leankor__ProjectRoom__c = projectList[0].Id,
                                                                            leankor__SevenDayWorkWeek__c = true,
                                                                            leankor__TaskDateCheck__c = true );
        insert valueTaskthree;
        leankor__KanbanCardTemplate__c cardtempfour = new leankor__KanbanCardTemplate__c(Name = 'RED Card2',
                                                                                         leankor__ValueStream__c = valueTaskthree.id,
                                                                                         leankor__Color__c = '#F71B1B',
                                                                                         leankor__Width__c = 328.0);
        insert cardtempfour;
        
        leankor__KanbanCardTemplate__c cardtempthree = new leankor__KanbanCardTemplate__c(Name = 'RED Card2',
                                                                                          leankor__ValueStream__c = valueTaskfive.id,
                                                                                          leankor__Color__c = '#F71B1B',
                                                                                          leankor__Width__c = 328.0);
        insert cardtempthree;  
        leankor__KanbanCard__c kanbanTask = new leankor__KanbanCard__c(Name ='card Task 1',
                                                                       leankor__ValueStream__C = valueTask.ID,
                                                                       leankor__order__c = 5,
                                                                       leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                       leankor__StartDateTime__c= System.now().addDays(1),
                                                                       leankor__DueDateTime__c= System.now()+5,
                                                                       leankor__StartDate__c = System.Today(),
                                                                       leankor__Zone__c = zone.Id,
                                                                       leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                       leankor__EstimatedDuration__c = 4);
        insert kanbanTask;
        leankor__ScheduleMode__c schedRecord = new leankor__ScheduleMode__c();
        schedRecord.leankor__KanbanCard__c = kanbanTask.Id;
        schedRecord.leankor__ConstraintDateTime__c = kanbanTask.leankor__DueDateTime__c;
        schedRecord.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedRecord;
        Task tskk1 = new Task();
        tskk1.Priority = 'High';
        tskk1.OwnerID = UserInfo.getUserId();                             
        tskk1.Status = 'In Progress';
        tskk1.ActivityDate = System.Today();
        tskk1.WhatId = kanbanTask.Id;  
        tskk1.Priority='high';
        tskk1.status='Not Started';
        tskk1.Description='demo test';                                 
        insert tskk1;
        leankor__KanbanCard__c kanbanTaskFirst = new leankor__KanbanCard__c(Name ='card Task 2',
                                                                            leankor__ValueStream__C = valueTask.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 4);
        insert kanbanTaskFirst;
        leankor__KanbanCard__c kanbanTaskSecond = new leankor__KanbanCard__c(Name ='card Task Second',
                                                                            leankor__ValueStream__C = valueTaskfive.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 8,
                                                                            leankor__DurationUnits__c = 'Hours');
        insert kanbanTaskSecond;
        Task taskkSecond = new Task();
        taskkSecond.Priority = 'High';
        taskkSecond.OwnerID = UserInfo.getUserId();                             
        taskkSecond.Status = 'In Progress';
        taskkSecond.ActivityDate = System.Today()+1;
        taskkSecond.WhatId = kanbanTaskSecond.Id;  
        taskkSecond.Priority='high';
        taskkSecond.status='Not Started';
        taskkSecond.Description='demo test';                                 
        insert taskkSecond;
        leankor__KanbanCard__c kanbanTaskThird = new leankor__KanbanCard__c(Name ='card Task three',
                                                                            leankor__ValueStream__C = valueTaskfive.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 60,
                                                                            leankor__DurationUnits__c = 'Minutes');
        insert kanbanTaskThird;
        Task taskkThird = new Task();
        taskkThird.Priority = 'High';
        taskkThird.OwnerID = UserInfo.getUserId();                             
        taskkThird.Status = 'In Progress';
        taskkThird.ActivityDate = System.Today().addDays(-1);
        taskkThird.WhatId = kanbanTaskThird.Id;  
        taskkThird.Priority='high';
        taskkThird.status='Not Started';
        taskkThird.Description='demo test';                                 
        insert taskkThird;
        Task taskkFifthh = new Task();
        taskkFifthh.Priority = 'High';
        taskkFifthh.OwnerID = UserInfo.getUserId();                             
        taskkFifthh.Status = 'In Progress';
        taskkFifthh.ActivityDate = System.Today().addDays(-3);
        taskkFifthh.WhatId = kanbanTaskThird.Id;  
        taskkFifthh.Priority='high';
        taskkFifthh.status='Not Started';
        taskkFifthh.Description='demo test';                                 
        insert taskkFifthh;
        leankor__KanbanCard__c kanbanTaskFourth = new leankor__KanbanCard__c(Name ='card Task Four',
                                                                            leankor__ValueStream__C = valueTaskthree.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 60,
                                                                            leankor__DurationUnits__c = 'Minutes',
                                                                            leankor__KanbanCardTemplate__C = cardtempfour.Id);
        insert kanbanTaskFourth;
        Task taskkfourth = new Task();
        taskkfourth.Priority = 'High';
        taskkfourth.OwnerID = UserInfo.getUserId();                             
        taskkfourth.Status = 'In Progress';
        taskkfourth.ActivityDate = System.Today().addDays(-1);
        taskkfourth.WhatId = kanbanTaskFourth.Id;  
        taskkfourth.Priority='high';
        taskkfourth.status='Not Started';
        taskkfourth.Description='demo test';                                 
        insert taskkfourth;
        Task taskkfifth = new Task();
        taskkfifth.Priority = 'High';
        taskkfifth.OwnerID = UserInfo.getUserId();                             
        taskkfifth.Status = 'In Progress';
        taskkfifth.ActivityDate = System.Today().addDays(3);
        taskkfifth.WhatId = kanbanTaskFourth.Id;  
        taskkfifth.Priority='high';
        taskkfifth.status='Not Started';
        taskkfifth.Description='demo test';                                 
        insert taskkfifth;
        leankor__KanbanCard__c kanbanTaskFifth = new leankor__KanbanCard__c(Name ='card Task Five',
                                                                            leankor__ValueStream__C = valueTask.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 427,
                                                                            leankor__DurationUnits__c = 'Minutes');
        insert kanbanTaskFifth;
        leankor__KanbanCard__c kanbanTaskseven = new leankor__KanbanCard__c(Name ='card Task seven',
                                                                            leankor__ValueStream__C = valueTask.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 427,
                                                                            leankor__DurationUnits__c = 'Weeks');
        insert kanbanTaskseven;
        leankor__KanbanCard__c kanbanTaskEight = new leankor__KanbanCard__c(Name ='card Task Eight',
                                                                            leankor__ValueStream__C = valueTaskfive.ID,
                                                                            leankor__order__c = 5,
                                                                            leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                            leankor__StartDateTime__c= System.now(),
                                                                            leankor__DueDateTime__c= System.now(),
                                                                            leankor__StartDate__c = System.Today(),
                                                                            leankor__Zone__c = zone.Id,
                                                                            leankor__zoneGUID__c = zone.leankor__Guid__c,
                                                                            leankor__EstimatedDuration__c = 60,
                                                                            leankor__DurationUnits__c = 'Minutes');
        insert kanbanTaskEight;
        Task taskkEight = new Task();
        taskkEight.Priority = 'High';
        taskkEight.OwnerID = UserInfo.getUserId();                             
        taskkEight.Status = 'In Progress';
        taskkEight.ActivityDate = System.Today().addDays(3);
        taskkEight.WhatId = kanbanTaskEight.Id;  
        taskkEight.Priority='high';
        taskkEight.status='Not Started';
        taskkEight.Description='demo test';                                 
        insert taskkEight;
        Task taskkNine = new Task();
        taskkNine.Priority = 'High';
        taskkNine.OwnerID = UserInfo.getUserId();                             
        taskkNine.Status = 'In Progress';
        taskkNine.ActivityDate = System.Today().addDays(-3);
        taskkNine.WhatId = kanbanTaskEight.Id;  
        taskkNine.Priority='high';
        taskkNine.status='Not Started';
        taskkNine.Description='demo test';                                 
        insert taskkNine;
        Task taskkFirst = new Task();
        taskkFirst.Priority = 'High';
        taskkFirst.OwnerID = UserInfo.getUserId();                             
        taskkFirst.Status = 'In Progress';
        taskkFirst.ActivityDate = System.Today()+1;
        taskkFirst.WhatId = kanbanTaskFirst.Id;  
        taskkFirst.Priority='high';
        taskkFirst.status='Not Started';
        taskkFirst.Description='demo test';                                 
        insert taskkFirst;
        leankor__Preference__c pre = new leankor__Preference__c(leankor__CardPastDueDate__c =false,
                                                                leankor__FollowOnChatter__c = 'all',
                                                                leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                leankor__Moved__c = false,
                                                                Name = userinfo.getname(),
                                                                leankor__PercentDone__c = false,
                                                                leankor__ValueStream__c  = null,
                                                                leankor__SubscribeToCard__c  = 'all',
                                                                leankor__TaskPastDueDate__c  = false);
        insert pre;
        leankor__ScheduleConstraint__c startNoLaterThan = new leankor__ScheduleConstraint__c();
        startNoLaterThan.leankor__Description__c = 'startnolaterthan';
        startNoLaterThan.leankor__Type__c = 'startnolaterthan';
        insert startNoLaterThan;
        
        leankor__valueStream__c vstream =new leankor__valueStream__c(Name= 'my1_vs',
                                                                    leankor__BoardType__c='Kanban Board');
        insert vstream;
        leankor__valueStream__c vstreamSecond = new leankor__valueStream__c(Name= 'my_vs');
        insert vstreamSecond;
        leankor__valueStream__c vstreamThird = new leankor__valueStream__c(Name= 'my valuestream');
        insert vstreamThird;
        leankor__KanbanCard__c kanbnCardThird = new leankor__KanbanCard__c(Name ='my new card one',
                                                                           leankor__ValueStream__C = vstreamThird.ID,
                                                                           leankor__order__c = 5,
                                                                           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                           leankor__StartDateTime__c= System.now(),
                                                                           leankor__DueDateTime__c= System.now()+5,
                                                                           RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId());
        insert kanbnCardThird;
       leankor__MasterContainer__c masterContainerSecond = new leankor__MasterContainer__c(Name= 'masterContainer',
                                                                                           leankor__ValueStream__c = vstreamSecond.Id,
                                                                                           leankor__order__c =0.0,
                                                                                           leankor__Type__c ='backlog',
                                                                                           leankor__Guid__c = leankor.TestDataFactory.createGuid());
       insert masterContainerSecond;
       leankor__swimlane__c swimlaneSecond =new leankor__swimlane__c(Name ='swimlane test',
                                                                    leankor__MasterContainer__c = masterContainerSecond.ID,
                                                                    leankor__order__c =0.0,
                                                                    leankor__ValueStream__c = vstreamSecond.Id);
        insert swimlaneSecond; 
        leankor__Zone__c zonesecond = new leankor__Zone__c(Name = 'kanban test3',
                                                           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                           leankor__CmpID__c = 'my-CMPID-zone-test3',
                                                           leankor__swimlane__c = swimlaneSecond.ID,
                                                           leankor__ValueStream__c = vstreamSecond.Id);
        insert zonesecond;
        
        leankor__KanbanCard__c kanbnCard = new leankor__KanbanCard__c(Name ='new card one',
                                                                      leankor__ValueStream__C = vstreamSecond.ID,
                                                                      leankor__order__c = 5,
                                                                      leankor__GUID__c = zonesecond.leankor__GUID__C,
                                                                      leankor__StartDateTime__c= System.now(),
                                                                      leankor__DueDateTime__c= System.now()+5);
        insert kanbnCard;
        leankor__Kanbancard__c cardKanban =new leankor__Kanbancard__C (Name ='kanban card one',
                                                                       leankor__GUID__C =leankor.TestDataFactory.createGuid(),
                                                                       leankor__StartDateTime__c =system.now(),        
                                                                       leankor__DueDateTime__c =system.Now(),
                                                                       leankor__Title__c ='MyTitle',
                                                                       leankor__Order__c = 2,
                                                                       leankor__valueStream__c = vstream.ID,
                                                                       leankor__ValuestreamCardlink__c = kanbnCard.Id,
                                                                       leankor__ValueStreamLink__C = vstreamSecond.id);
        insert cardKanban;
        leankor__ScheduleMode__c schedModeRecord = new leankor__ScheduleMode__c();
        schedModeRecord.leankor__KanbanCard__c = cardKanban.Id;
        schedModeRecord.leankor__ConstraintDateTime__c = cardKanban.leankor__DueDateTime__c;
        schedModeRecord.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedModeRecord;
        leankor__Filter__c filter = new leankor__Filter__c(Name = 'filter',
                                                           leankor__ValueStream__C = valuestreamwithSevendays.Id);
        insert filter;
        leankor__ValueStream__c valuestreamwithProjectconstarint = new leankor__ValueStream__c(Name = 'Valuestream ProjectLaunchDate constarint',
                                                                                               leankor__ProjectBoardLaunchDateTime__c = System.now(),
                                                                                               leankor__Boardtype__c = 'UberBoard',
                                                                                               leankor__ProjectRoom__c = projectList[0].Id);
        insert valuestreamwithProjectconstarint; 
        leankor__KanbanCard__c kanbanCardForconstarint = new leankor__KanbanCard__c(Name ='Five day working',
                                                                                    leankor__ValueStream__C = valuestreamwithProjectconstarint.ID,
                                                                                    leankor__order__c = 5,
                                                                                    leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                                                                                    leankor__StartDateTime__c= System.now(),
                                                                                    leankor__DueDateTime__c= System.now()+5,
                                                                                    leankor__DurationUnits__c = 'Minutes',
                                                                                    leankor__EstimatedDuration__c = 5,
                                                                                    leankor__ValueStreamCardLink__c = kanbanCardForMonths.Id,
                                                                                    leankor__ValueStreamLink__C = valuestreamwithProjectLaunchdate.Id,
                                                                                    RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId(),
                                                                                    OwnerId = UserInfo.getUserId());
        insert kanbanCardForconstarint;
        leankor__ScheduleMode__c schedModeRecords = new leankor__ScheduleMode__c();
        schedModeRecords.leankor__KanbanCard__c = kanbanCardForconstarint.Id;
        schedModeRecords.leankor__ConstraintDateTime__c = kanbanCardForconstarint.leankor__DueDateTime__c;
        schedModeRecords.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedModeRecords;
        Task taskkTen = new Task();
        taskkTen.Priority = 'High';
        taskkTen.OwnerID = UserInfo.getUserId();                             
        taskkTen.Status = 'In Progress';
        taskkTen.ActivityDate = System.Today()+1;
        taskkTen.WhatId = kanbanCardForconstarint.Id;  
        taskkTen.Priority='high';
        taskkTen.status='Not Started';
        taskkTen.Description='demo test';                                 
        insert taskkTen;
        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c(leankor__AssignedTo__c = kanbanCardForconstarint.OwnerId,
                                                                                               leankor__KanbanCard__C = kanbanCardForconstarint.Id);
        insert resourceAssignment;
        leankor__marker__c marker = new leankor__marker__c(leankor__valuestream__c = valuestreamwithProjectconstarint.Id,
                                                           leankor__GUID__c =leankor.TestDataFactory.createGuid(),
                                                           leankor__GUID2__c = leankor.TestDataFactory.createGuid());
        insert marker;
    }

    // Method for creating a user with 'Visual Lean User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
	private static void createVisualLeanUser() {
        uSamp = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_User'});
	}

    // Method for creating a Community user with 'Visual Lean Customer Community User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                From Contact
                                Where Birthdate =:Date.newInstance(2016, 12, 9) 
                                Limit 1];
        uSamp = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);
    }

    // method for grabbing value stream - don't have to repeatedly code this 
    private static leankor__ValueStream__c getBoard(String name) {
        leankor__ValueStream__c valueStream = [Select Id,
                                                    Name,
                                                    leankor__BoardType__c,
                                                    leankor__ProjectBoardStartDateTime__c,
                                                    leankor__ProjectBoardEndDateTime__c
                                                From leankor__ValueStream__c 
                                                Where Name = :name
                                                Limit 1];

        return valueStream;
    }

    private static leankor__LeanConstants__c getConstraintSetting() {
        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                              leankor__AllowSchedulingConstraints__c
                                                            From leankor__LeanConstants__c
                                                            Limit 1];

        return constraintSetting;
    }

    private static leankor__ProjectScheduleBlackout__c getProjectBoardBlackout(Id boardId) {
        leankor__ProjectScheduleBlackout__c blackOut = [Select Id,
                                                            Name,
                                                            leankor__ProjectBoard__c,
                                                            leankor__StartDate__c,
                                                            leankor__EndDate__c
                                                        From leankor__ProjectScheduleBlackout__c
                                                        Where leankor__ProjectBoard__c = :boardId];

        return blackOut;
    }

  public static testMethod void testMasterConteiner(){
  leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS');
        insert vs;
        leankor.KanbanController Kc = new leankor.KanbanController();
        List<leankor__ProjectRoom__c> Rooms = new List<leankor__ProjectRoom__c>();
        leankor__Portfolio__c prt = new leankor__Portfolio__c(name = 'parentportfolio1');
        insert prt;
    leankor__ProjectRoom__c SampleRoom = new leankor__ProjectRoom__c(name ='Test Room',leankor__Portfolio__c= prt.id);
    insert SampleRoom;
        Rooms.add(SampleRoom);
        KanbanController.theProjectRooms = Rooms;       
        ApexPages.currentPage().getParameters().put('Id', vs.Id);    
        ApexPages.StandardController sc = new ApexPages.standardController(vs);
        leankor.KanbanController Kcontroller1 = new leankor.KanbanController(sc);
  List<leankor.KanbanController.MasterContainer> masterContainerList=new List<leankor.KanbanController.MasterContainer>();
  leankor.KanbanController.MasterContainer masterContainer=new leankor.KanbanController.MasterContainer();
                masterContainer.Name = 'testName'; 
                masterContainer.Color = 'some color';
                masterContainer.CmpId= 'some-Id';
                masterContainer.GUID = leankor.TestDataFactory.createGuid();
                masterContainer.Height = 100;
                masterContainer.isCardAvailable = true;
                masterContainer.Left = 100;
                masterContainer.Limits = 1;
                masterContainer.Order =1;
                masterContainer.Title = 'some Title';
                masterContainer.Top = 100;
                masterContainer.Type = 'some Type';
                masterContainer.ValueStreamID = vs.id;
                masterContainer.Width = 100;
    masterContainerList.add(masterContainer);
  List<leankor__MasterContainer__c> mContList=leankor.KanbanController.createMasterContainer(masterContainerList);
//assert to check createMasterContainer
    System.assert(mContList !=null || mContList.size()>0);
//assert to check getMasterContainer
  
    List<leankor__MasterContainer__c> mContList1=leankor.KanbanController.getMasterContainer(vs.Id);
    System.assert(mContList1 !=null || mContList1.size()>0);
//assert to check updateMasterContainer
    List<leankor.KanbanController.MasterContainer> masterContainerList1=new List<leankor.KanbanController.MasterContainer>();
    leankor.KanbanController.MasterContainer masterContainer1=new leankor.KanbanController.MasterContainer();
    masterContainer1.Name = 'updated testName';
            masterContainer1.Id = mContList1[0].Id;
                masterContainer1.Color = mContList1[0].leankor__Color__c;
                masterContainer1.CmpId= mContList1[0].leankor__CmpId__c;
                masterContainer1.GUID = mContList1[0].leankor__GUID__c;
                masterContainer1.Height = 100;
                masterContainer1.isCardAvailable = true;
                masterContainer1.Left = 100;
                masterContainer1.Limits = 1;
                masterContainer1.Order =1;
                masterContainer1.Title = mContList1[0].leankor__Title__c;
                masterContainer1.Top = 100;
                masterContainer1.Type = mContList1[0].leankor__Type__C;
                masterContainer.ValueStreamID = vs.id;
                masterContainer1.Width = 100;
        
            masterContainerList1.add(masterContainer1);
                List<leankor__MasterContainer__c> mContList2=leankor.KanbanController.updateMasterContainer(masterContainerList1);
    System.assert(mContList2[0].Name=='updated testName');
//assert to check deleteMasterContainer
    List<String> ids=new List<String>();
        ids.add(mContList1[0].id);
    String returnedString=leankor.KanbanController.deleteMasterContainer(ids);
    System.assert(returnedString=='success');
    List<string> testString = new List<string>();
    testString.add(vs.id);
    String returnedString1=leankor.KanbanController.deleteMasterContainer(testString);
/*    Profile p = [SELECT Id FROM Profile WHERE Name='Chatter Free User']; 
User nonStandardUser = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@leankortest.com');
insert nonStandardUser;
system.runAs(nonStandardUser){
 String returnedString1=leankor.KanbanController.deleteMasterContainer(ids);
}*/
}
   public static testMethod void testSwimlane(){
  leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS');
        insert vs;
 //Rs 22/12/2017 To pass valuestream Id 
  leankor.KanbanController Kc = new leankor.KanbanController();  
  Kc.valueStreamId= vs.Id;        
 
List<leankor.KanbanController.MasterContainer> masterContainerList=new List<leankor.KanbanController.MasterContainer>();
  leankor.KanbanController.MasterContainer masterContainer=new leankor.KanbanController.MasterContainer();
  masterContainer.Name = 'testName';
                masterContainer.Color = 'some color';
                masterContainer.CmpId= 'some-Id';
                masterContainer.GUID = leankor.TestDataFactory.createGuid();
                masterContainer.Height = 100;
                masterContainer.isCardAvailable = true;
                masterContainer.Left = 100;
                masterContainer.Limits = 1;
                masterContainer.Order =1;
                masterContainer.Title = 'some Title';
                masterContainer.Top = 100;
                masterContainer.Type = 'some Type';
                masterContainer.ValueStreamID = vs.id;
                masterContainer.Width = 100;
    masterContainerList.add(masterContainer);
  List<leankor__MasterContainer__c> mContList=leankor.KanbanController.createMasterContainer(masterContainerList);
  List<leankor.KanbanController.Swimlane> swimlaneList=new List<leankor.KanbanController.Swimlane>();
  leankor.KanbanController.Swimlane swimlane=new leankor.KanbanController.Swimlane();
      swimlane.Name = 'testName';
                swimlane.CardPerRow = 2;
    swimlane.Color = 'some color';
                swimlane.CmpId= 'some-Id';
                swimlane.GUID = leankor.TestDataFactory.createGuid();
                swimlane.Height = 100;
     swimlane.Help = 'some Help Text';
                swimlane.isCardAvailable = true;
                swimlane.Left = 100;
                swimlane.Limits = 1;
                swimlane.Order =1;
                swimlane.Title = 'some Title';
                swimlane.Top = 100;
              swimlane.MasterContainer = mContList[0].ID;
                swimlane.ValueStreamID = vs.id;
                swimlane.Width = 100;
    swimlaneList.add(swimlane);
  List<leankor__Swimlane__c> swmList=leankor.KanbanController.createSwimlane(swimlaneList);
       //assert to check createSwimlane
    System.assert(swmList !=null || swmList.size()>0);
       //assert to check getSwimlane
  
    List<leankor__Swimlane__c> swmList1=leankor.KanbanController.getSwimlane(vs.Id);
    System.assert(swmList1 !=null || swmList1.size()>0);
       //assert to check updateSwimlane
    List<leankor.KanbanController.Swimlane> swimlaneList1=new List<leankor.KanbanController.Swimlane>();
    leankor.KanbanController.Swimlane swimlane1=new leankor.KanbanController.Swimlane();
    swimlane1.Name = 'updated testName';
            swimlane1.Id = swmList1[0].Id;
                swimlane1.Color = swmList1[0].leankor__Color__c;
                swimlane1.CmpId= swmList1[0].leankor__CmpId__c;
                swimlane1.GUID = swmList1[0].leankor__GUID__c;
                swimlane1.Height = 100;
                swimlane1.isCardAvailable = true;
                swimlane1.Left = 100;
                swimlane1.Limits = 1;
                swimlane1.Order =1;
                swimlane1.Title = swmList1[0].leankor__Title__c;
                swimlane1.Top = 100;
                swimlane.MasterContainer = '';
                swimlane1.ValueStreamID = vs.id;
                swimlane1.Width = 100;
        
            swimlaneList1.add(swimlane1);
                List<leankor__Swimlane__c> swimlaneList2=leankor.KanbanController.updateSwimlane(swimlaneList1);
    System.assert(swimlaneList2[0].Name=='updated testName');
         
     //Rs 22/12/2017 To call new Methods for kb performance 
     string KMC = Kc.getKanbanBoardMasterContainers();
     System.assert(KMC!=null);
     string KBS = Kc.getKanbanBoardSwimlanes();
     System.assert(KBS!=null);
     
       //assert to check deleteSwimlane
    List<String> ids=new List<String>();
        ids.add(swimlaneList2[0].id);
    String returnedString=leankor.KanbanController.deleteSwimlane(ids);
    System.assert(returnedString=='success');

   }

    public static testMethod void testCreateKanbanBoard()
    {
        Test.startTest();
            leankor.KanbanController KcObject = new leankor.KanbanController();
            leankor.KanbanController KcObjectnext = new leankor.KanbanController();

            leankor__LeanConstants__c customSetting = [Select Id,
                                                              leankor__AllowSchedulingConstraints__c,
                                                              leankor__StreamingAPIVersion__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];
            customSetting.leankor__AllowSchedulingConstraints__c = true;
            update customSetting;
            leankor__ProjectRoom__c pr=new leankor__ProjectRoom__c(Name ='Test_Project');
            insert pr;
            leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs;
            
            //leankor.KanbanController.createKanbanBoard(vs.Id);
            //List<leankor__Zone__c> zones= [Select Id,Name from leankor__Zone__c where leankor__ValueStream__C = : vs.Id Limit 999];
            //System.assert(zones.size() > 0);
            
            vs.Name ='_System_Board';
            vs.leankor__ProjectRoom__C =null;
            update vs;
            
            leankor__ValueStream__c vs1= new leankor__ValueStream__c(Name = 'myVS1',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs1;
            
            /*leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
                cBoard.VSID = vs1.Id;
                cBoard.RealVSID = '';
                cBoard.KanbanVerb = false;
                cBoard.KanbanTemplateVerb = false;
                cBoard.StickerVerb = false;
                cBoard.TaskVerb = false;
                cBoard.ZoneVerb = true;
                cBoard.MarkerVerb = false;
                cBoard.ChartVerb = false;
                cBoard.BoardType ='Kanban Board';     
                //leankor.KanbanController.CloneSystemBoard(cBoard);*/
            
            leankor__ValueStream__c vs2= new leankor__ValueStream__c(Name = 'myV1S1',leankor__BoardType__C ='whiteboard', leankor__ProjectRoom__C =pr.Id);
            insert vs2;
            leankor__Zone__C z1 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
            insert z1;
            leankor__Zone__C z2 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
            insert z2;
            
            /*leankor.KanbanController.CloneBoard cBoard1 = new leankor.KanbanController.CloneBoard();
              cBoard1.VSID = vs2.Id;
              cBoard1.RealVSID = vs2.Id;
              cBoard1.KanbanVerb = true;
              cBoard1.KanbanTemplateVerb = false;
              cBoard1.StickerVerb = false;
              cBoard1.TaskVerb = false;
              cBoard1.ZoneVerb = true;
              cBoard1.MarkerVerb = true;
              cBoard1.ChartVerb = true;
              cBoard1.FinalDate = JSON.serialize(system.now());
              cBoard1.BoardType ='Whiteboard';  */
            
            leankor__Chart__C NC = New leankor__Chart__C(leankor__ChartURL__c ='123',leankor__reportID__c = '123',Name ='tets',leankor__DeveloperName__c= 'LeanReports',leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__ValueStream__c = VS2.ID);
            insert NC;
            
            leankor__KanbanCard__c KC1 =new leankor__Kanbancard__c (Name = 'kc1',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id ); 
            leankor__KanbanCard__c KC2 =new leankor__Kanbancard__c (leankor__Order__C = 1,Name = 'kc2',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id );   
            insert KC1;
            insert KC2;
            
            task t1 = new task(Subject = 'T1', whatId =KC1.ID,ActivityDate = system.today() );
            task t2 = new task(Subject = 'T2', whatId =KC1.ID,ActivityDate = system.today() );
            insert t1;
            insert t2;
                        
            leankor__marker__c m = new leankor__marker__c(leankor__valuestream__c = vs2.Id,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__GUID2__c = leankor.TestDataFactory.createGuid());
            insert m;
        
            leankor__ValueStream__c vstream = new leankor__ValueStream__c(Name = 'myV1S1',leankor__BoardType__C ='whiteboard', leankor__ProjectRoom__C =pr.Id);
            insert vstream;
            leankor__marker__c marker = new leankor__marker__c(leankor__valuestream__c = vstream.Id,
                                                               leankor__GUID__c =leankor.TestDataFactory.createGuid(),
                                                               leankor__GUID2__c = leankor.TestDataFactory.createGuid(),
                                                               leankor__Type__C = 'Label');
            insert marker;

            Attachment myatt = new Attachment(Body = Blob.valueOf('blobdata') , ContentType='image/png', parentId = m.Id, Name = 'preview.png');
            insert myatt;
            leankor__ValueStream__C valuestream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'my valuestream'
                                                    Limit 1];
            
            
            //leankor.KanbanController.CloneSystemBoard(cBoard1);
            
            List<leankor__Zone__c> zones1= [Select Id,Name from leankor__Zone__c where leankor__ValueStream__C = : vs1.Id Limit 999];
            //System.assert(zones1.size() > 0);
            system.assert(leankor.KanbanController.getURLData() != '');
            List<leankor.RealTimeController.Kanban> listcard = new List<leankor.RealTimeController.Kanban>();
            leankor.RealTimeController.Kanban KC = new leankor.RealTimeController.Kanban();
            KC.Id = KC2.id;
            KC.Order = 1;
            listcard.add(KC);
            system.assert(leankor.KanbanController.manageKanbanOrder(listcard) != 'Failed');
            system.assert(leankor.KanbanController.getValueStreams().size() > 0) ;

            //Rs 22/12/2017 To call new kb performance methods 
            KcObject.valueStreamId= vs2.Id; 
            KcObject.TheValueStream = vs2; 
            system.assert(KcObject.getKanbanBoardKanbanCards(vs1.Id) != Null);
            system.assert(KcObject.getKanbanBoardCharts() != Null);
            system.assert(KcObject.getKanbanBoardZones() != Null);
            system.assert(KcObject.getKanbanBoardCharts() != Null);
            system.assert(KcObject.getKanbanBoardMarkers() != Null);
            //system.assert(leankor.KanbanController.getPackageVersion() != Null);
            KcObjectnext.valueStreamId = vstream.Id;
            KcObjectnext.TheValueStream = vstream;
            system.assert(KcObjectnext.getKanbanBoardMarkers() != Null);
            system.assert(KcObject.getKanbanBoardKanbanCards(valuestream.Id) != Null);
            Test.stopTest();
    }

    private static testMethod void testCreateKanbanBoardTwo()
    {
        Test.startTest();
            leankor.KanbanController KcObject = new leankor.KanbanController();
            leankor__ProjectRoom__c pr=new leankor__ProjectRoom__c(Name ='Test_Project');
            insert pr;
            leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs;
            
            leankor.KanbanController.createKanbanBoard(vs.Id);
            List<leankor__Zone__c> zones= [Select Id,Name from leankor__Zone__c where leankor__ValueStream__C = : vs.Id Limit 999];
            System.assert(zones.size() > 0);
            Test.stopTest();
    }

    private static testMethod void testCreateKanbanBoardThird(){
        Test.startTest();
            leankor.KanbanController KcObject = new leankor.KanbanController();
            leankor__ProjectRoom__c pr=new leankor__ProjectRoom__c(Name ='Test_Project');
            insert pr;
            leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs;
            
            vs.Name ='_System_Board';
            vs.leankor__ProjectRoom__C =null;
            update vs;
            
            leankor__ValueStream__c vs1= new leankor__ValueStream__c(Name = 'myVS1',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs1;
            
            leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
                cBoard.VSID = vs1.Id;
                cBoard.RealVSID = '';
                cBoard.KanbanVerb = false;
                cBoard.KanbanTemplateVerb = false;
                cBoard.StickerVerb = false;
                cBoard.TaskVerb = false;
                cBoard.ZoneVerb = true;
                cBoard.MarkerVerb = false;
                cBoard.ChartVerb = false;
                cBoard.BoardType ='Kanban Board';     
                System.assertEquals('Success',leankor.KanbanController.CloneSystemBoard(cBoard));
                Test.stopTest();
    }


    private static testMethod void testCreateKanbanBoardFourth(){
        Test.startTest();
            leankor.KanbanController KcObject = new leankor.KanbanController();
            leankor__ProjectRoom__c pr=new leankor__ProjectRoom__c(Name ='Test_Project');
            insert pr;
            leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs;
            
            vs.Name ='_System_Board';
            vs.leankor__ProjectRoom__C =null;
            update vs;
            
            leankor__ValueStream__c vs1= new leankor__ValueStream__c(Name = 'myVS1',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
            insert vs1;

            leankor__ValueStream__c vs2= new leankor__ValueStream__c(Name = 'myV1S1',leankor__BoardType__C ='whiteboard', leankor__ProjectRoom__C =pr.Id);
            insert vs2;
            leankor__Zone__C z1 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
            insert z1;
            leankor__Zone__C z2 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
            insert z2;
            leankor.KanbanController.CloneBoard cBoard1 = new leankor.KanbanController.CloneBoard();
              cBoard1.VSID = vs2.Id;
              cBoard1.RealVSID = vs2.Id;
              cBoard1.KanbanVerb = true;
              cBoard1.KanbanTemplateVerb = false;
              cBoard1.StickerVerb = false;
              cBoard1.TaskVerb = false;
              cBoard1.ZoneVerb = true;
              cBoard1.MarkerVerb = true;
              cBoard1.ChartVerb = true;
              cBoard1.FinalDate = JSON.serialize(system.now());
              cBoard1.BoardType ='Whiteboard'; 
              cBoard1.oldStartDateTime = System.now();
              cBoard1.oldEndDateTime = System.now();
            leankor__Chart__C NC = New leankor__Chart__C(leankor__ChartURL__c ='123',leankor__reportID__c = '123',Name ='tets',leankor__DeveloperName__c= 'LeanReports',leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__ValueStream__c = VS2.ID);
            insert NC;
            
            leankor__KanbanCard__c KC1 =new leankor__Kanbancard__c (Name = 'kc1',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id ); 
            leankor__KanbanCard__c KC2 =new leankor__Kanbancard__c (leankor__Order__C = 1,Name = 'kc2',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id );   
            insert KC1;
            insert KC2;
            
            task t1 = new task(Subject = 'T1', whatId =KC1.ID,ActivityDate = system.today() );
            task t2 = new task(Subject = 'T2', whatId =KC1.ID,ActivityDate = system.today() );
            insert t1;
            insert t2;
                        
            leankor__marker__c m = new leankor__marker__c(leankor__valuestream__c = vs2.Id,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__GUID2__c = leankor.TestDataFactory.createGuid());
            insert m;
        
            Attachment myatt = new Attachment(Body = Blob.valueOf('blobdata') , ContentType='image/png', parentId = m.Id, Name = 'preview.png');
            insert myatt;
            System.assertEquals('Success', leankor.KanbanController.CloneSystemBoard(cBoard1));
            Test.stopTest();
        }

        private static testMethod void testCreateKanbanBoardfifth(){
            Test.startTest();
                leankor.KanbanController KcObject = new leankor.KanbanController();
                leankor__ProjectRoom__c pr=new leankor__ProjectRoom__c(Name ='Test_Project');
                insert pr;
                leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
                insert vs;
                
                vs.Name ='_System_Board';
                vs.leankor__ProjectRoom__C =null;
                update vs;
                
                leankor__ValueStream__c vs1= new leankor__ValueStream__c(Name = 'myVS1',leankor__BoardType__C ='Kanban Board', leankor__ProjectRoom__C =pr.Id);
                insert vs1;
                
                leankor__ValueStream__c vs2= new leankor__ValueStream__c(Name = 'myV1S1',leankor__BoardType__C ='whiteboard', leankor__ProjectRoom__C =pr.Id);
                insert vs2;
                leankor__Zone__C z1 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
                insert z1;
                leankor__Zone__C z2 = new leankor__Zone__c(Name = 'newzone1',leankor__Valuestream__c = vs2.id,leankor__GUID__c = leankor.TestDataFactory.createGuid());
                insert z2;
                
                leankor__Chart__C NC = New leankor__Chart__C(leankor__ChartURL__c ='123',leankor__reportID__c = '123',Name ='tets',leankor__DeveloperName__c= 'LeanReports',leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__ValueStream__c = VS2.ID);
                insert NC;
                
                leankor__KanbanCard__c KC1 =new leankor__Kanbancard__c (Name = 'kc1',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id ); 
                leankor__KanbanCard__c KC2 =new leankor__Kanbancard__c (leankor__Order__C = 1,Name = 'kc2',leankor__EstimatedDuration__c = 3,leankor__StartDatetime__c = system.now(),leankor__DueDatetime__c = system.now()+3,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__valuestream__c = vs2.Id );   
                insert KC1;
                insert KC2;
                
                task t1 = new task(Subject = 'T1', whatId =KC1.ID,ActivityDate = system.today() );
                task t2 = new task(Subject = 'T2', whatId =KC1.ID,ActivityDate = system.today() );
                insert t1;
                insert t2;
                            
                leankor__marker__c m = new leankor__marker__c(leankor__valuestream__c = vs2.Id,leankor__GUID__c =leankor.TestDataFactory.createGuid(),leankor__GUID2__c = leankor.TestDataFactory.createGuid());
                insert m;
            
                Attachment myatt = new Attachment(Body = Blob.valueOf('blobdata') , ContentType='image/png', parentId = m.Id, Name = 'preview.png');
                insert myatt;
                List<leankor.RealTimeController.Kanban> listcard = new List<leankor.RealTimeController.Kanban>();
                leankor.RealTimeController.Kanban KC = new leankor.RealTimeController.Kanban();
                KC.Id = KC2.id;
                KC.Order = 1;
                listcard.add(KC);
                system.assert(leankor.KanbanController.manageKanbanOrder(listcard) != 'Failed');
                Test.stopTest();
        }
    @isTest
    private static void deleteAssociatedFileTest(){
        List<leankor__ValueStream__c> valueStreams = [Select Id From leankor__ValueStream__c Where Name =: 'myValueStream'];
        List<leankor__KanbanCard__c> cards = [Select Id From leankor__KanbanCard__c Where Name =: 'KanbanCard'];
        List<ContentVersion> contentVersions = [Select Id From ContentVersion Where Title =: 'Penguins'];
        leankor.KanbanController.FileInputWrapper FIW = new leankor.KanbanController.FileInputWrapper();
        FIW.filePublishLocation = 'ValueStream';
        List<Id> listIds = new List<Id>();  
        listIds.add(valueStreams[0].Id);               
        FIW.publishLocationIds = listIds;                        
            
        leankor.KanbanController.DeleteFileWrapper deleteData = new leankor.KanbanController.DeleteFileWrapper();
        deleteData.relatedRecordId = contentVersions[0].Id;
        deleteData.parentId = cards[0].Id;
        String jsonData = JSON.Serialize(deleteData); 
        System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) =='Success');                      
        System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) != Null);  
    }
            
  /*  @isTest
    private static void deleteAssociatedFileTestFirst(){
            
        Profile profile = [Select Id From Profile Where Name='Standard Platform User']; 
        User standardPlatformUser = new User(Alias = 'stanpt', Email='standardplatformuser@testorg.com',EmailEncodingKey='UTF-8', LastName='TestPlatformUser', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standardplatformuser@leankortest.com');
        insert standardPlatformUser;
        PermissionSet permissionSet = [Select Id From PermissionSet Where Name = 'Visual_Lean_User_Secured'];
        insert new PermissionSetAssignment(AssigneeId = standardPlatformUser.Id, PermissionSetId = permissionSet.Id);
                                        
        List<leankor__ValueStream__c> valueStreams = [Select Id From leankor__ValueStream__c Where Name =: 'myValueStream'];
        List<leankor__KanbanCard__c> cards = [Select Id From leankor__KanbanCard__c Where Name =: 'KanbanCard'];
        List<ContentVersion> contentVersions = [Select Id From ContentVersion Where Title =:'Penguins'];
            leankor.KanbanController.FileInputWrapper FIW = new leankor.KanbanController.FileInputWrapper();
            FIW.filePublishLocation = 'ValueStream';
            List<Id> listIds = new List<Id>();  
        listIds.add(valueStreams[0].Id);               
            FIW.publishLocationIds = listIds;                        
            
            leankor.KanbanController.DeleteFileWrapper deleteData = new leankor.KanbanController.DeleteFileWrapper();
        deleteData.relatedRecordId = contentVersions[0].Id;
        deleteData.parentId = cards[0].Id;
            String jsonData = JSON.Serialize(deleteData);                       
            
        System.runAs(standardPlatformUser){
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) =='Success'); 
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) != Null);   
    }
    }*/

    @isTest
    private static void deleteAssociatedFileTestSecond(){
        
        Profile profile = [Select Id From Profile Where Name='Standard User']; 
        User standardUser = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='TestingWtihStandardUser', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@leankortest.com');
        insert standardUser;
        PermissionSet permissionSet = [Select Id From PermissionSet Where Name = 'Visual_Lean_User_Secured'];
        insert new PermissionSetAssignment(AssigneeId = standardUser.Id, PermissionSetId = permissionSet.Id);
        
        List<leankor__ValueStream__c> valueStreams = [Select Id from leankor__ValueStream__c Where Name =: 'myValueStream'];
        List<leankor__KanbanCard__c> cards = [Select Id From leankor__KanbanCard__c Where Name =: 'KanbanCard'];
        List<ContentVersion> contentVersions = [Select id from ContentVersion Where Title =:'Penguins'];
        leankor.KanbanController.FileInputWrapper FIW = new leankor.KanbanController.FileInputWrapper();
        FIW.filePublishLocation = 'ValueStream';
        List<Id> listIds = new List<Id>();  
         listIds.add(valueStreams[0].Id);               
        FIW.publishLocationIds = listIds;                        
        
        leankor.KanbanController.DeleteFileWrapper deleteData = new leankor.KanbanController.DeleteFileWrapper();
        deleteData.relatedRecordId = contentVersions[0].Id;
        deleteData.parentId = cards[0].Id;
        String jsonData = JSON.Serialize(deleteData);                       
        
        System.runAs(standardUser){
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) =='Success'); 
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) != Null);  
        }
    }    

    /*@isTest
    private static void deleteAssociatedFileTestThird(){
        
        List<Contact> contact = [Select Id From Contact Where LastName =: 'testContact']; 
        Profile profile3 = [Select Id From Profile Where Name='Customer community user']; 
        User customerCommunityUser = new User(Alias = 'custcom', Email='customercommunityuser@testorg.com',EmailEncodingKey='UTF-8', LastName='TestCutomerCommunity', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile3.Id, TimeZoneSidKey='America/Los_Angeles', UserName='customercommunityuser@leankortest.com', ContactId = contact[0].Id);
        insert customerCommunityUser;
        PermissionSet permissionSet2 = [Select Id From PermissionSet Where Name = 'Visual_Lean_Customer_Community_User'];
        insert new PermissionSetAssignment(AssigneeId = customerCommunityUser.Id, PermissionSetId = permissionSet2.Id);
        
        List<leankor__ValueStream__c> valueStreams = [Select id from leankor__ValueStream__c Where Name =: 'myValueStream'];
        List<leankor__KanbanCard__c> cards = [Select Id From leankor__KanbanCard__c Where Name =: 'KanbanCard'];
        List<ContentVersion> contentVersions = [Select id from ContentVersion Where Title =:'Penguins'];
        leankor.KanbanController.FileInputWrapper FIW = new leankor.KanbanController.FileInputWrapper();
        FIW.filePublishLocation = 'ValueStream';
        List<Id> listIds = new List<Id>();  
        listIds.add(valueStreams[0].Id);               
        FIW.publishLocationIds = listIds;                        
        
        leankor.KanbanController.DeleteFileWrapper deleteData = new leankor.KanbanController.DeleteFileWrapper();
        deleteData.relatedRecordId = contentVersions[0].Id;
        deleteData.parentId = cards[0].Id;
        String jsonData = JSON.Serialize(deleteData);                       
        System.runAs(customerCommunityUser){
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) =='Success');
            System.assert(leankor.KanbanController.deleteAssociatedFile(jsonData) != Null);   
        }
    }*/

    

 public static testMethod void testCardLogTime(){
        /* leankor__ValueStream__c vs12 = new leankor__ValueStream__c(Name = 'myVS12');
        insert vs12;
        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
            Name = 'template name1',
            leankor__Width__c = 100,
            leankor__Title__c = 'template title',
            leankor__JSONDefinition__c = '{}',
            leankor__JSONData__c = '{}',
            leankor__Height__c = 200,
            leankor__CSSLayout__c = 'some css' ,
            leankor__valueStream__c =vs12.id);
            
        insert kct;
        List<String> kanbanCards = new List<String>();
        leankor.RealTimeController.Kanban newKanban = new leankor.RealTimeController.Kanban();
        
        newKanban.GUID ='305ee49a-8489-4091-bf76-8a080880611';
        newKanban.ownerid=UserInfo.getUserId();
        newKanban.title = 'title';
        newKanban.name = 'Small card';
        newKanban.top = 100;
        newKanban.bottom = 0;
        newKanban.left = 100;
        newKanban.width = 180;
        newKanban.height = 200;
        newKanban.x = 100;
        newKanban.y = 100;
        newKanban.JSONData = '{}';
        newKanban.base64Drawing = 'somedummyfile';
        newKanban.base64FileType = 'image/png';
        newKanban.zoneid = 'randomzone';
        newKanban.state = 'inzone';
        newKanban.durationunits = 'Days';
        newKanban.estimatedDuration = 1;
        newKanban.duedate = System.Now()+1;
        newKanban.startdate =System.Now();
        newKanban.templateid =kct.Id;
        newKanban.priority = 3;
        newKanban.harveyBall = '50';
        newKanban.description = 'short description about the kanbancard';
        kanbanCards.add(JSON.Serialize(newKanban));
        String vst=vs12.id;
        List<leankor__KanbanCard__c> KanbanCardList = leankor.RealTimeController.createKanbanCard(vst,kanbanCards);*/

        leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c(
            Name = 'testTimeSheet-1',
            leankor__StartDateTime__c = System.now(),
            leankor__EndDateTime__c = System.now()+7,
            leankor__Resource__c = UserInfo.getUserId()
         
        );
        insert approvalNullTimeSheet;
        
        User userId_1 = leankor.TestDataFactory.createStandardUser('Lean1');        
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', userId_1);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> KanbanCardList=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,userId_1);
        
        leankor.KanbanController.CardLogTime clogs = new leankor.KanbanController.CardLogTime();
        clogs.LogTime =String.ValueOf(System.Now());
        clogs.Description = 'This is first log time';
        clogs.Duration = 'Days';
        clogs.Estimation = 1.0;
        clogs.Subject = 'Test Task';
        clogs.TaskID = 'TASK123';
        clogs.Hours = 8.0;
        clogs.KanbanCardID = KanbanCardList[0].Id;
        clogs.AssignedTo = UserInfo.getUserId();
        clogs.AssignedAUser = UserInfo.getUserId();
        clogs.TaskDueDate = ''+System.Now();
        
        leankor__TimeCard__c tCard = leankor.KanbanController.createCardLog(clogs);
        tCard.leankor__TimeSheet__c = approvalNullTimeSheet.Id;
        Update tCard;
        System.assert(tCard.leankor__KanbanCard__c != null);
        clogs.Estimation = 2.0;
        clogs.Hours = 16.0;
        clogs.Id = tCard.Id;
        String returnString = leankor.KanbanController.updateCardLogs(clogs);
        System.assert(returnString == 'Success');
        
        List<leankor.KanbanController.CardLogTime> tCards = leankor.KanbanController.getCardLogs(tCard.leankor__KanbanCard__c);
        
        System.assert(tCards.Size() > 0);
        
        String returnString1 = leankor.KanbanController.removeCardLogs(tCard.Id);
        System.assert(returnString1 == 'Success');
   List<CloneKanbanCardAction.CloneKanbanCardRequest> kanbandatas = new List<CloneKanbanCardAction.CloneKanbanCardRequest>();
   leankor.CloneKanbanCardAction.CloneKanbanCardRequest kanbandata = new leankor.CloneKanbanCardAction.CloneKanbanCardRequest();
   
    kanbandata.FinalDate= system.Now();
    kanbandata.KanbanID = KanbanCardList[0].Id;
    kanbandatas.add(kanbandata);
   leankor.CloneKanbanCardAction.CloneKanbanCards(kanbandatas); 
  
     }
     
     public static testMethod void testIssueLogs(){
         /*leankor__ValueStream__c vs12 = new leankor__ValueStream__c(Name = 'myVS12');
        insert vs12;
        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
            Name = 'template name1',
            leankor__Width__c = 100,
            leankor__Title__c = 'template title',
            leankor__JSONDefinition__c = '{}',
            leankor__JSONData__c = '{}',
            leankor__Height__c = 200,
            leankor__CSSLayout__c = 'some css' ,
            leankor__valueStream__c =vs12.id);
            
        insert kct;
        List<String> kanbanCards = new List<String>();
        leankor.RealTimeController.Kanban newKanban = new leankor.RealTimeController.Kanban();
        
        newKanban.GUID ='305ee49a-8489-4091-bf76-8a080880612';
        newKanban.ownerid=UserInfo.getUserId();
        newKanban.title = 'title';
        newKanban.name = 'Small card';
        newKanban.top = 100;
        newKanban.bottom = 0;
        newKanban.left = 100;
        newKanban.width = 180;
        newKanban.height = 200;
        newKanban.x = 100;
        newKanban.y = 100;
        newKanban.JSONData = '{}';
        newKanban.base64Drawing = 'somedummyfile';
        newKanban.base64FileType = 'image/png';
        newKanban.zoneid = 'randomzone';
        newKanban.state = 'inzone';
        newKanban.durationunits = 'Days';
        newKanban.estimatedDuration = 1;
        newKanban.duedate = System.Now()+1;
        newKanban.startdate = System.Now();
        newKanban.templateid =kct.Id;
        newKanban.priority = 3;
        newKanban.harveyBall = '50';
        newKanban.description = 'short description about the kanbancard';
        kanbanCards.add(JSON.Serialize(newKanban));
        String vst=vs12.id;*/
        
        //List<leankor__KanbanCard__c> KanbanCardList = leankor.RealTimeController.createKanbanCard(vst,kanbanCards);
        User userId_1 = leankor.TestDataFactory.createStandardUser('Lean128');      
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', userId_1);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> KanbanCardList = leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,userId_1);
        leankor.KanbanController.IssueLogs clogs = new leankor.KanbanController.IssueLogs();
        
        clogs.Subject = 'Test Task';
        clogs.Detail = 'This is first log time';
        clogs.KanbanCardID = KanbanCardList[0].Id;
        clogs.LogTime = String.ValueOf(System.now());
        clogs.Probability = 'Likely';
        clogs.StatusType = 'Risk';
        clogs.TaskID =  'TASK12343';
        clogs.Weight = 'Important';
        clogs.Resolved = false;
        clogs.Score = 10;
        clogs.AssignedTo = UserInfo.getUserId();
        clogs.TaskDueDate = ''+System.Now();
        
        leankor.KanbanController.IssueLogs tCard = leankor.KanbanController.createIssueLogs(clogs);
        System.assert(tCard.Id != null);
        tCard.Resolved = true;
        tCard.ResolvedTime = ''+System.Now();
        
        String returnString = leankor.KanbanController.updateIssueLogs(tCard);
        System.assert(returnString == 'Success');
        
        List<leankor.KanbanController.IssueLogs> tCards = leankor.KanbanController.getIssueLogs(tCard.KanbanCardID);
        
        System.assert(tCards.Size() > 0);
        
        String returnString1 = leankor.KanbanController.removeIssueLogs(tCard.Id);
        System.assert(returnString1 == 'Success');
     
     }
     
     public static testMethod void testCloneSystemBoard(){
        Test.startTest();
     List<leankor.KanbanController.MasterContainer> MContainers=new List<leankor.KanbanController.MasterContainer>();
        List<leankor.KanbanController.Swimlane> Swims=new List<leankor.KanbanController.Swimlane>();
        List<leankor__MasterContainer__c> MasterContainers=new List<leankor__MasterContainer__c>();
        List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
        List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
        String ReturnsZones='';
        leankor__Portfolio__c Folder = new leankor__Portfolio__c (Name = 'ProjectFolderName');
        insert Folder;
        leankor__ProjectRoom__c newroom = new leankor__ProjectRoom__c(Name ='testRoom');
        insert newroom;
        leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = newroom.ID);
    try{
        Database.insert(vStream);
    }catch(DMLException ex){
        System.debug('Error : '+ex.getMessage());
    } 
        for(Integer i=0;i<5;i++){
        leankor.KanbanController.MasterContainer MC=new leankor.KanbanController.MasterContainer();
        MC.CmpID='ext-masterContainer-'+i;
        MC.Color=(i==0?'#A0A0A0':(i==1?'#6666FF':(i==2?'#FF8000':(i==3?'#66CC00':'#808080'))));
        MC.GUID =leankor.TestDataFactory.createGuid();
        MC.Height=670;
        MC.Left=2080;
        MC.Limits=0;
        MC.Name=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
        MC.Order=i;
        MC.Title=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
        MC.Top=2010;
        MC.Type=(i==0?'Backlog':(i==1 ||i==2 ||i==3?'Regular':(i==4?'Archive':'Regular')));
        MC.ValueStreamID=vStream.Id;
        MC.Width=420;
        MC.isCardAvailable=false;
        MContainers.add(MC);
        }
        MasterContainers = leankor.KanbanController.createMasterContainer(MContainers);
                
        Integer j=0,k=0;
        for(leankor__MasterContainer__c m :MasterContainers){
        leankor.KanbanController.Swimlane s=new leankor.KanbanController.Swimlane();
        s.CardPerRow =1;
        s.CmpID='ext-swimlaneContainer-'+j;
        s.Color=(j==2?'#66CC00':'#4183D7');
        s.GUID=leankor.TestDataFactory.createGuid();
        s.Height=320;
        s.Help='';
        s.Left=2100;
        s.Limits=0;
        s.MasterContainer = m.Id;
        s.Name='Default Swimlane';
        s.Order=0;
        s.Title='Default Swimlane';
        s.Top=2100;
        s.ValueStreamID=vStream.Id;
        s.Width=418;
        s.isCardAvailable = false;
        Swims.add(s);
        if(j==2){
        leankor.KanbanController.Swimlane s1=new leankor.KanbanController.Swimlane();
        s1.CardPerRow =1;
        s1.Height=320;
        s1.Help='';
        s1.Left=2100;
        s1.Limits=0;
        s1.Top=2100;
        s1.ValueStreamID=vStream.Id;
        s1.Width=418;
        s1.isCardAvailable = false;
        s1.CmpID='ext-swimlaneContainer-'+(j+5);
        s1.GUID=leankor.TestDataFactory.createGuid();
        s1.Name='New Swimlane';
        s1.Title='New Swimlane';
        s1.Color = '#FF8000';
        s1.MasterContainer = m.Id;
        s1.Order=1;
        Swims.add(s1);
        }
        j++;
        }
        Swimlanes = leankor.KanbanController.createSwimlane(Swims);

 for(leankor__Swimlane__c s:Swimlanes){
        leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
    RemoteZone.GUID =leankor.TestDataFactory.createGuid();
    RemoteZone.Title = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
    RemoteZone.Top=0;
    RemoteZone.Bottom =0;
    RemoteZone.Left =0;
    RemoteZone.Width =209;
    RemoteZone.Height =(k==2 || k==3) ? 174:492;
    RemoteZone.X = 0;
    RemoteZone.Y = 0;
    RemoteZone.EntryFlowName ='';
    RemoteZone.ExitFlowName ='';
    RemoteZone.ZoneMode ='Vertical Stretch';
    RemoteZone.KanbanSequence = '[]';
    RemoteZone.ValueStreamLinkID ='';
    RemoteZone.ValueStreamCardLink ='';
    RemoteZone.DefaultWidth  = 209;
    RemoteZone.DefaultHeight = (k==2 || k==3) ? 174:492;
    RemoteZone.ZoneStatus ='None';
    RemoteZone.CardsPerRow=1;
    RemoteZone.Help ='';
    RemoteZone.TaskLimit =0;
    RemoteZone.Order=0;
    RemoteZone.ParentZone='';
    RemoteZone.Swimlane=s.Id;
    RemoteZones.add(RemoteZone);
   if(k==1 || k==2 || k==3){
    leankor.realTimeController.Zone RemoteZone1=new leankor.realTimeController.Zone();
    RemoteZone1.GUID =leankor.TestDataFactory.createGuid();
    RemoteZone1.Title = 'New SubColumn';
    RemoteZone1.Top=0;
    RemoteZone1.Bottom =0;
    RemoteZone1.Left =0;
    RemoteZone1.Width =209;
    RemoteZone1.Height =(k==2 || k==3) ? 174:492;
    RemoteZone1.X = 0;
    RemoteZone1.Y = 0;
    RemoteZone1.EntryFlowName ='';
    RemoteZone1.ExitFlowName ='';
    RemoteZone1.ZoneMode ='Vertical Stretch';
    RemoteZone1.KanbanSequence = '[]';
    RemoteZone1.ValueStreamLinkID ='';
    RemoteZone1.ValueStreamCardLink ='';
    RemoteZone1.DefaultWidth  = 209;
    RemoteZone1.DefaultHeight = (k==2 || k==3) ? 174:492;
    RemoteZone1.ZoneStatus ='None';
    RemoteZone1.CardsPerRow=1;
    RemoteZone1.Help ='';
    RemoteZone1.TaskLimit =0;
    RemoteZone1.Order=1;
    RemoteZone1.ParentZone='';
    RemoteZone1.Swimlane=s.Id;
    RemoteZones.add(RemoteZone1);
    
   }
     k++;
        }
        ReturnsZones=leankor.realTimeController.createZone(vStream.Id,RemoteZones);
        List<leankor__Zone__C> zoneRecords = [Select Id,Name,leankor__GUID__C from leankor__Zone__C where leankor__ValueStream__c =:vStream.Id limit 999];
    
        List<String> templateIds = new List<String>();
               
        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c(
        Name ='TestTemplate',
        leankor__Title__c = 'TestTemplate',
        leankor__color__c = '#fff',
        leankor__csslayout__c = '',
        leankor__height__c = 300,
        leankor__width__c = 300,
        leankor__jsondata__c = '{}',
        leankor__jsondefinition__c = '{}',
        leankor__valuestream__c = vStream.Id );
        
        insert kanbanTemp; 
        
        templateIds.add(kanbanTemp.Id); 
        
        leankor__KanbanCardTemplate__c kanbanTemp1 = new leankor__KanbanCardTemplate__c(
        Name ='TestTemplate1',
        leankor__Title__c = 'TestTemplate1',
        leankor__color__c = '#fff',
        leankor__csslayout__c = '',
        leankor__height__c = 300,
        leankor__width__c = 300,
        leankor__jsondata__c = '{}',
        leankor__jsondefinition__c = '{}',
        leankor__valuestream__c = vStream.Id );
        
        insert kanbanTemp1; 
        
        templateIds.add(kanbanTemp1.Id); 
               
        String userId_1 = UserInfo.getUserId();
        List<String> kanbans=new List<String>();
        List<String> childkanbans=new List<String>();
       
        
        // yj 10.01.2017 for bulkify test creating kanban cards
       /* for(Integer i =1;i<100;i++)
        {
        
        realtimeController.Kanban newKanban = new realtimeController.Kanban();
            newKanban.GUid ='305ee49a'+'-'+system.now()+i;
        newKanban.ownerid=userId_1;
            newKanban.title = 'newkanname'+i;
            newKanban.name = 'Small card'+i;
        newKanban.top = 100;
        newKanban.bottom = 0;
        newKanban.left = 100;
        newKanban.width = 180;
        newKanban.height = 200;
        newKanban.x = 100;
        newKanban.y = 100;
        newKanban.JSONData = '{}';
        newKanban.base64Drawing = 'somedummyfile';
        newKanban.base64FileType = 'image/png';
        newKanban.zoneid = 'randomzone';
        newKanban.state = 'inzone';
        newKanban.durationunits = 'Days';
        newKanban.estimatedDuration = 1;
        newKanban.duedate =System.Now();
        newKanban.startdate = System.Now();
        newKanban.templateid =kanbanTemp.Id;
        newKanban.priority = 3;
            newKanban.harveyBall = '50';
            newKanban.ValueStream = vStream.Id;
        newKanban.description = 'short description about the kanbancard';
		// Date: 02/01/2020
        
        newKanban.kanbanUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/apex/leankor__VisualKanban?Id='+vStream.id+'&cardid=';
        kanbans.add(JSON.Serialize(newKanban));
        }*/
        //List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCard(vStream.Id, kanbans); 
        User userId_2 = leankor.TestDataFactory.createStandardUser('Lean12');       
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', userId_2);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> retkan=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,userId_2);
        
       /* for(Integer i=1;i<100;i++)
        {
        
        realtimeController.Kanban newKanban1 = new realtimeController.Kanban();
                                        
            newKanban1.ValueStreamCardLink = retkan[i-1].id;            
            newKanban1.ValueStreamLinkID = vStream.Id;
            newKanban1.GUID ='305eehj49a'+'-'+system.now()+i;
            newKanban1.ownerid=userId_1;
            newKanban1.title = 'newkanname'+i;
            newKanban1.name = 'Small card'+i;
        newKanban1.top = 100;
        newKanban1.bottom = 0;
        newKanban1.left = 100;
        newKanban1.width = 180;
        newKanban1.height = 200;
        newKanban1.x = 100;
        newKanban1.y = 100;
        newKanban1.JSONData = '{}';
        newKanban1.base64Drawing = 'somedummyfile';
        newKanban1.base64FileType = 'image/png';
        newKanban1.zoneid = 'randomzone';
        newKanban1.state = 'inzone';
        newKanban1.durationunits = 'Days';
        newKanban1.estimatedDuration = 1;
            newKanban1.duedate =System.Now();
        newKanban1.startdate = System.Now();
        newKanban1.templateid =kanbanTemp.Id;
        newKanban1.priority = 3;
            newKanban1.harveyBall = '50';
            newKanban1.ValueStream = vStream.Id;
        newKanban1.description = 'short description about the kanbancard';
			// Date: 02/01/2020
            //newKanban1.kanbanUrl = 'https://leankor.na14.visual.force.com/apex/leankor__KanbanBoard?Id='+vStream.id+'&cardid='; 
            newKanban1.kanbanUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/apex/leankor__VisualKanban?Id='+vStream.id+'&cardid=';
                        
            childkanbans.add(JSON.Serialize(newKanban1));
        }*/
       // List<leankor__KanbanCard__c> retkan1 = realtimeController.createKanbanCard(vStream.Id, childkanbans); 
       List<leankor__KanbanCard__c> retkan1=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,userId_2);
        //yj 10.01.2017        
            
        // inserting Preference       
        leankor__Preference__c UserPreference = new leankor__Preference__c(
                    Name = UserInfo.getName(),
                    leankor__GUID__c = leankor.TestDataFactory.createGuid(),                    
                    leankor__ValueStream__c = vStream.Id,
                    leankor__FollowOnChatter__c = JSON.serialize(templateIds),
                    leankor__SubscribeToCard__c = JSON.serialize(templateIds),
                    leankor__DerivedFrom__c =  null );
                    
        insert UserPreference;
        //inserting global Preference
        leankor__Preference__c UserPreference1 = new leankor__Preference__c(
                    Name = UserInfo.getName(),
                    OwnerId = userId_1,
                    leankor__FollowOnChatter__c = JSON.serialize(templateIds),
                    leankor__SubscribeToCard__c = JSON.serialize(templateIds),
                    leankor__GUID__c = leankor.TestDataFactory.createGuid(),                                     
                    leankor__DerivedFrom__c =  null );
                    
        insert UserPreference1;
       //
      List<leankor__Sticker__c> stkrLst=new List<leankor__Sticker__c>();
        leankor__Sticker__c stick = new leankor__Sticker__c(
            Name = 'sticker name',leankor__valueStream__c= vStream.Id
        );
        insert stick;
        leankor__Sticker__c stick1 = new leankor__Sticker__c(
            Name = 'sticker name1',leankor__valueStream__c = vStream.Id
        );
        insert stick1;
        List<Attachment> attachLst=new List<Attachment>();
        Attachment stickAtt = new Attachment(
            ParentId = stick.Id,
            Name = 'afilename',
            Body = Blob.valueOf('a file')
        );
       attachLst.add(stickAtt);
           stickAtt = new Attachment(
            ParentId = stick1.Id,
            Name = 'afilename1',
            Body = Blob.valueOf('a file')
        );
       attachLst.add(stickAtt);
        insert attachLst;
        
        leankor__Portfolio__c LinkF = new leankor__Portfolio__c(Name = 'LinkedFolderName');
            insert LinkF;
        leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM') ;
            insert linkr;
        leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',leankor__BoardType__c='Kanban Board' ,leankor__projectroom__C = LinkR.id);
            insert Linkb;
        leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',leankor__GUID__c = leankor.TestDataFactory.createGuid());
            insert linkKC;
       // yj 10.01.2017 modified data for coverage
    //-----CloneProjectBoardAction without folder data
       List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestboards = new  List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
       leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestboard = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
       requestboard.ProjectRoom = 'testRoom';
       requestboard.ProjectBoard = '_System_Board';
       requestboard.TargetRoom = 'testRoom';
       requestboard.TargetBoard = 'clone_test';
       requestboard.TargetDate = system.now();             
        requestboard.LinkedCardId =  LinkKC.Id;          
       requestboards.add(requestboard);
       
       List<leankor.CloneProjectBoardAction.CloneProjectBoardResult> resultboard = new List<leankor.CloneProjectBoardAction.CloneProjectBoardResult>();       
       resultboard = leankor.CloneProjectBoardAction.CloneProjectBoard(requestboards);      
       System.assert(resultboard.size() >= 0);
       
   //----  CloneProjectBoardAction with folder data
       List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestboardsforFolder = new  List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
       leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestboard1 = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
       requestboard1.ProjectRoom = 'testRoom';
       requestboard1.FolderName = 'ProjectFolderName';
       requestboard1.ProjectBoard = '_System_Board';
       requestboard1.TargetRoom = 'testRoom';
       requestboard1.TargetFolderName = 'ProjectFolderName';
        requestboard1.TargetBoard = 'clone_test';
        requestboard1.LinkKanbanCardName = LinkKC.name;
        requestboard1.LinkBoardName = Linkb.name ;
        requestboard1.LinkRoomName = LinkR.name;
        requestboard1.TargetDate = system.now();      
       requestboardsforFolder.add(requestboard1);
       
       List<leankor.CloneProjectBoardAction.CloneProjectBoardResult> resultboard1 = new List<leankor.CloneProjectBoardAction.CloneProjectBoardResult>();
       resultboard1 = leankor.CloneProjectBoardAction.CloneProjectBoard(requestboardsforFolder);
       System.assert(resultboard1.size() >= 0);
   
   //----  CloneProjectBoardAction with link folder,Room&Board
       List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestboardsforFolder2 = new  List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
       leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestboard2 = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
        requestboard2.LinkRoomName ='LINKROOM';
        requestboard2.LinkFolderName = 'LinkedFolderName';
        //requestboard2.LinkedBoardId = Linkb.Id;
        requestboard2.LinkBoardName = 'LINKKC';
        requestboard2.TargetDate = system.now();
        requestboardsforFolder2.add(requestboard2);
       
       List<leankor.CloneProjectBoardAction.CloneProjectBoardResult> resultboard2 = new List<leankor.CloneProjectBoardAction.CloneProjectBoardResult>();
       resultboard2 = leankor.CloneProjectBoardAction.CloneProjectBoard(requestboardsforFolder2);
       System.assert(resultboard2.size() >= 0);
       Test.stopTest();
       //
     }
     public static testMethod void testpending()
     {
        Test.startTest();
        leankor__valueStream__c vs12 =new leankor__valueStream__c(Name= 'my_vs');
        insert vs12;
         // HyperJUMP test part
       leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(
        Name= 'masterContainer',
        leankor__ValueStream__c = vs12.Id,
        leankor__order__c =0.0,
        leankor__Type__c ='backlog',
        leankor__Guid__c = leankor.TestDataFactory.createGuid()
       );
       insert m1;
       leankor__swimlane__c s1 =new leankor__swimlane__c(
        Name ='swimlane test',
        leankor__MasterContainer__c = m1.ID,
        leankor__order__c =0.0,
        leankor__ValueStream__c = vs12.Id);
        insert s1; 
        leankor__Zone__c z1 = new leankor__Zone__c(
             Name = 'kanban test3',
             leankor__GUID__c = leankor.TestDataFactory.createGuid(),
             leankor__CmpID__c = 'my-CMPID-zone-test3',
             leankor__swimlane__c = s1.ID,
             leankor__ValueStream__c = vs12.Id);
        insert z1;
        
        leankor__KanbanCard__c kan = new leankor__KanbanCard__c(
        Name ='new card',
        leankor__ValueStream__C = vs12.ID,
        leankor__order__c = 5,
        leankor__GUID__c = z1.leankor__GUID__C,
        leankor__StartDateTime__c= System.now(),
        leankor__DueDateTime__c= System.now()+5);
        insert kan;

       list<leankor__KanbanCard__c> listkan = [Select ID,Name,leankor__ValueStream__C,leankor__GUID__c from leankor__KanbanCard__c LIMIT 1 ] ;
       leankor.kanbanController.Hyperjump Ob_hyper= new leankor.kanbanController.Hyperjump();
       Ob_hyper.oldVSID = vs12.ID;
       Ob_hyper.newVSID = vs12.ID;
       Ob_hyper.BoardType = 'kanban Board';
       
       String JSONdata =('{"Id":"'+ kan.ID+'","Name":"'+kan.Name+'","GUID":"'+kan.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kan.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kan.leankor__DueDateTime__c)+',"DurationUnits":"Days","EstimatedDuration":4}'); 

        System.Assert(leankor.KanbanController.HyperjumpToBoard(ob_hyper,JSONdata) != 'Failed');
        
       leankor.kanbanController.Hyperjump hyperJumpCard = new leankor.kanbanController.Hyperjump();
       hyperJumpCard.oldVSID = vs12.ID;
       hyperJumpCard.newVSID = vs12.ID;
       String JSONdatas =('{"Id":"'+ kan.ID+'","Name":"'+kan.Name+'","GUID":"'+kan.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kan.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kan.leankor__DueDateTime__c)+',"DurationUnits":"Years","EstimatedDuration":4}'); 
       System.Assert(leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdatas) != 'Failed');

       leankor.kanbanController.Hyperjump huperJump = new leankor.kanbanController.Hyperjump();
       huperJump.oldVSID = vs12.ID;
       huperJump.newVSID = vs12.ID;
       huperJump.BoardType = 'kanban Board';
       huperJump.ZoneForceID = z1.Id;
       String JSONdataforCard =('{"Id":"'+ kan.ID+'","Name":"'+kan.Name+'","GUID":"'+kan.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kan.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kan.leankor__DueDateTime__c)+',"DurationUnits":"Weeks","EstimatedDuration":4}'); 
       System.Assert(leankor.KanbanController.HyperjumpToBoard(huperJump,JSONdataforCard) != 'Failed');


        // for clone kanban card
        leankor__valueStream__c vs =new leankor__valueStream__c(Name= 'my1_vs',leankor__BoardType__c='Kanban Board');
        insert vs;
        
        leankor__Kanbancard__c c_KC =new leankor__Kanbancard__C (
        Name ='kanban card',
        leankor__GUID__C =leankor.TestDataFactory.createGuid(),
        leankor__StartDateTime__c =system.now(),        
        leankor__DueDateTime__c =system.Now(),
        leankor__Title__c ='MyTitle',
        leankor__Order__c = 2,
        leankor__valueStream__c = vs.ID,
        leankor__ValuestreamCardlink__c = kan.Id,
        leankor__ValueStreamLink__C = vs12.id        
        );
        insert c_KC;
        
        Task TC1 = new Task(
        Status= 'In Progress',
        Priority = 'high',
        Subject = 'task',
        ActivityDate = Date.ValueOf(System.now()),
        WhatID = c_KC.ID
        );        
        insert TC1;
        
        String VSID =String.ValueOf(vs.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        
        leankor.RealTimeController.Kanban k = new leankor.RealTimeController.Kanban();
        k.StartDate = c_KC.leankor__StartDateTime__c;
        k.Id = c_KC.ID;
        k.GUID = c_KC.leankor__GUID__C;
        k.Name = c_KC.Name;
        k.ValueStream = c_KC.leankor__ValueStream__c;
        k.DueDate = c_KC.leankor__DueDateTime__c;
        k.EstimatedDuration = 10;
        k.Width=150;
        k.Left=420;
        k.HarveyBall = String.valueOf(50);
        k.OwnerID = userinfo.getUserid();
        k.DurationUnits = 'Hours';
        String someJSONData = JSON.serialize(k);
        String mySessionID = userinfo.getSessionId();
        
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID) != Null);
                
        //------------------------Clone with Start date ------------------------------------------------- 
        leankor.KanbanController.clonestartboard  clonewithstartdate =  new leankor.KanbanController.clonestartboard();
        clonewithstartdate.StartDate = string.Valueof(system.now());
        clonewithstartdate.TaskVerb = true;
        clonewithstartdate.someJSONData = someJSONData;
        leankor.KanbanController.cloneCardwithStartDate(VSID,clonewithstartdate, userinfo.getSessionId());
        Test.stopTest();
     }
//---------TestallMCCardsHyperJump--------------
public static testMethod void  AllmCCards (){
    Test.startTest();
    List<String> KCID = new List<String>();
    leankor__valueStream__c vs12 =new leankor__valueStream__c(Name= 'my_vs');
    insert vs12;
    leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(Name= 'masterContainer',leankor__ValueStream__c = vs12.Id,leankor__order__c =0.0,leankor__Type__c ='backlog', leankor__Guid__c = leankor.TestDataFactory.createGuid());
    insert m1;
    leankor__swimlane__c s1 =new leankor__swimlane__c(Name ='swimlane test',leankor__MasterContainer__c = m1.ID,leankor__order__c =0.0,leankor__ValueStream__c = vs12.Id);
    insert s1;
    leankor__Zone__c z1 = new leankor__Zone__c(Name = 'kanban test3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s1.ID,leankor__ValueStream__c = vs12.Id);
    insert z1;
    leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name ='new card',leankor__ValueStream__C = vs12.ID,leankor__MasterContainer__c = m1.ID,leankor__swimlane__c = s1.ID,leankor__order__c = 5,leankor__GUID__c = z1.leankor__GUID__C,leankor__DurationUnits__c ='Hours',leankor__EstimatedDuration__c = 4);
    insert kan;
    KCID.add(kan.ID);
    leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = Vs12.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
    insert KCtemp;
    Task kanbanTask = new Task(Priority = 'low',WhatId = kan.ID,Description='jadj',Status= 'In progress',Subject= 'new',Activitydate= system.today());
    insert kanbanTask;
    leankor.kanbanController.MCHyperJumpLog Ob_hyper= new leankor.kanbanController.MCHyperJumpLog();
        Ob_hyper.TargetVSID = vs12.id;
        Ob_hyper.DefaultCardtemplateID=KCtemp.id;
        Ob_hyper.CardIDs = KCID;
        //Ob_hyper.MCID = m1.id;
        //Ob_hyper.SWID = s1.id;
        Ob_hyper.IsClone = true;
        Ob_hyper.LinkVSID ='';
        Ob_hyper.LinkCardID ='';
        string obj_mc =leankor.KanbanController.allMCCardsHyperJump(Ob_hyper);
    leankor.kanbanController.MCHyperJumpLog Ob_hyper1= new leankor.kanbanController.MCHyperJumpLog();
        Ob_hyper1.TargetVSID = vs12.id;
        Ob_hyper1.DefaultCardtemplateID=KCtemp.id;
        Ob_hyper1.CardIDs = KCID;
        //Ob_hyper1.MCID = '';
        //Ob_hyper1.SWID = s1.id;
        Ob_hyper1.IsClone = false;
        Ob_hyper1.LinkVSID ='';
        Ob_hyper1.LinkCardID ='';
        string obj_mc1 =leankor.KanbanController.allMCCardsHyperJump(Ob_hyper1);
     
         //-------------------------filtertest class--------------------------------------- 
         
         //creating filter               
         list<leankor.kanbanController.CreateFilter> filterList = new list<leankor.kanbanController.CreateFilter>();        
         
         leankor.kanbanController.CreateFilter filterLog1 = new leankor.kanbanController.CreateFilter();
         filterLog1.CategoryName = 'Long';
         filterLog1.OwnerName = Userinfo.getusername();
         filterLog1.PortfolioLinkCards = 'many';
         filterLog1.ValueStream = vs12.id;
         filterLog1.FilterName = 'myfilter';
         filterLog1.User = Userinfo.getuserId();
         filterLog1.IsDefaultFilter = true;
         filterLog1.IsFilterON = false;
         filterLog1.BoardURL = '';
         filterList.add(filterLog1);                     
                 
         leankor.kanbanController.CreateFilter Rfilter = leankor.kanbanController.createFilterRecords(filterList);  
         system.assert(Rfilter != null);
        
         list<leankor.kanbanController.CreateFilter> getfilterlist = leankor.kanbanController.getFilterRecords(vs12.id);
         system.assert(getfilterlist.size() > 0);
          
         //updating filter               
         Rfilter.CategoryName = 'Long1';
         Rfilter.PortfolioLinkCards = 'many many';
         Rfilter.isFilterONUpdate = false;   
         Rfilter.FeatureData = 'Feature';   
         leankor.kanbanController.CreateFilter updatefilter = leankor.kanbanController.updateFilterRecords(Rfilter);
         system.assert(updatefilter != null);
            
         Rfilter.isFilterONUpdate = true;   
         Rfilter.IsFilterON = true;   
         leankor.kanbanController.CreateFilter updatefiltersecond = leankor.kanbanController.updateFilterRecords(Rfilter);
         system.assert(updatefiltersecond != null);
         //delete filer       
         list<string> deletefilterIDs = new list<string>();  
         deletefilterIDs.add(Rfilter.ID);
         boolean Result= leankor.kanbanController.deleteFilterRecords(deletefilterIDs);
         system.assert(result);
         Test.stopTest();
    }
    
    //-----------------------------MultipleMergeBoardAction-----------------------------------------
    public static testMethod void  MultipleMergeBoardAction (){
    
        Test.startTest();
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;

        leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
        sampleRoom.Name = 'Test Room';
        sampleRoom.leankor__Portfolio__c = testFolder.Id;
        insert sampleRoom;   		
        		
        
        leankor.RealTimeController.ProjectBoard SampleBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
        leankor.RealTimeController.ProjectBoard TargetBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
        
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
        list<string> ss = new list<string>();
        ss.add(SampleBoard.Id);
        reqone .SourceBoardId = ss ;
        reqone .TargetBoardId = TargetBoard.Id;
        reqone .TargetDate = system.now();
        reqone .WithMC = true;
        req.add(reqone);
        
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
        
            System.assert(resultmerge != null);
        leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(Name= 'masterContainer12',leankor__ValueStream__c = SampleBoard.Id,leankor__order__c =7.0, leankor__Guid__c = leankor.TestDataFactory.createGuid());
          insert m1;
        leankor__swimlane__c s1 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
          insert s1;
        leankor__swimlane__c s2 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
          insert s2;
        leankor__Zone__c z1 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s1.ID,leankor__ValueStream__c = SampleBoard.Id);
          insert z1;
        leankor__Zone__c z2 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s2.ID,leankor__ValueStream__c = SampleBoard.Id);
          insert z2;
        leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = SampleBoard.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
          insert KCtemp;      
        leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now(),leankor__EstimatedDuration__c =1 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = SampleBoard.ID,leankor__MasterContainer__c = m1.ID,leankor__swimlane__c = s1.ID,leankor__order__c = 5,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__zoneGUID__c = z1.leankor__GUID__C);
            insert kan;
            Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan.id, ActivityDate = system.today ()); 
        insert tsk;   
       
       leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1', leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id );
         insert Ilog;
       
       leankor__TimeCard__c TCNew = new leankor__TimeCard__c( leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id,leankor__TaskDueDate__c= system.now()+5);
         insert TCNew;
           
       leankor__Sticker__c  Stk = new leankor__Sticker__c(leankor__ValueStream__c = SampleBoard.ID , Name = 'sticker 1');
         insert stk;
      
       Attachment  attch = new Attachment ( name ='attchment1', Body = Blob.valueOf('a file'), ParentId =stk.id);
         insert attch;
         
       leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kan.id ,leankor__Sticker__c = stk.id );     
         insert KanbanSt; 
        list<string> ss1 = new list<string>();
        ss1.add(SampleBoard.Id);
        reqone .SourceBoardId = ss1 ;
        reqone .TargetBoardId = TargetBoard.Id;
        reqone .TargetDate = system.now();
        reqone .WithMC = true;
        req.clear();
        req.add(reqone);
        
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge1 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assert(resultmerge1 != null);
        list<string> ss2 = new list<string>();
        ss2.add(SampleBoard.Id);
        reqone .SourceBoardId = ss2 ;
        reqone .TargetBoardId = TargetBoard.Id;
        reqone .TargetDate = system.now();
        reqone .WithMC = false;
        req.clear();
        req.add(reqone);
        
       /* Test.startTest();
        
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge2 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assert(resultmerge2 != null);
            List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> clonetwodata = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
        leankor.MergeProjectBoardAction.MergeProjectBoardRequest TwoLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
      TwoLog.SourceRoomName = 'Sample Room';
       TwoLog.SourceBoardName = 'Project Board';
       TwoLog.TargetRoomName = 'Sample Room';
        TwoLog.TargetBoardName = 'Project Board';
        TwoLog.WithMC=true;
        TwoLog.initialDate = system.now()+11;
        clonetwodata.add(TwoLog);
        
        List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> resulttwo =  leankor.MergeProjectBoardAction.MergeProjectBoard(clonetwodata);
        */
        Test.StopTest();
   }


   private static testMethod void  MultipleMergeBoardActionTwo (){
    Test.startTest();
    leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
    testFolder.Name = 'Test Room';
    insert testFolder;

    leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
    sampleRoom.Name = 'Test Room';
    sampleRoom.leankor__Portfolio__c = testFolder.Id;
    insert sampleRoom;   		
                    
        
    leankor.RealTimeController.ProjectBoard SampleBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
    leankor.RealTimeController.ProjectBoard TargetBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
    
    List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
    leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
    list<string> ss = new list<string>();
    ss.add(SampleBoard.Id);
    reqone .SourceBoardId = ss ;
    reqone .TargetBoardId = TargetBoard.Id;
    reqone .TargetDate = system.now();
    reqone .WithMC = true;
    req.add(reqone);
    
    List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
    
        System.assert(resultmerge != null);
    leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(Name= 'masterContainer12',leankor__ValueStream__c = SampleBoard.Id,leankor__order__c =7.0, leankor__Guid__c = leankor.TestDataFactory.createGuid());
      insert m1;
    leankor__swimlane__c s1 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
      insert s1;
    leankor__swimlane__c s2 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
      insert s2;
    leankor__Zone__c z1 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s1.ID,leankor__ValueStream__c = SampleBoard.Id);
      insert z1;
    leankor__Zone__c z2 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s2.ID,leankor__ValueStream__c = SampleBoard.Id);
      insert z2;
    leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = SampleBoard.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
      insert KCtemp;      
    leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now(),leankor__EstimatedDuration__c =1 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = SampleBoard.ID,leankor__MasterContainer__c = m1.ID,leankor__swimlane__c = s1.ID,leankor__order__c = 5,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__zoneGUID__c = z1.leankor__GUID__C);
        insert kan;
        Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan.id, ActivityDate = system.today ()); 
    insert tsk;   
   
   leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1', leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id );
     insert Ilog;
   
   leankor__TimeCard__c TCNew = new leankor__TimeCard__c( leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id,leankor__TaskDueDate__c= system.now()+5);
     insert TCNew;
       
   leankor__Sticker__c  Stk = new leankor__Sticker__c(leankor__ValueStream__c = SampleBoard.ID , Name = 'sticker 1');
     insert stk;
  
   Attachment  attch = new Attachment ( name ='attchment1', Body = Blob.valueOf('a file'), ParentId =stk.id);
     insert attch;
     
   leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kan.id ,leankor__Sticker__c = stk.id );     
     insert KanbanSt; 
    list<string> ss1 = new list<string>();
    ss1.add(SampleBoard.Id);
    reqone .SourceBoardId = ss1 ;
    reqone .TargetBoardId = TargetBoard.Id;
    reqone .TargetDate = system.now();
    reqone .WithMC = true;
    req.clear();
    req.add(reqone);   
        List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> clonetwodata = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
    leankor.MergeProjectBoardAction.MergeProjectBoardRequest TwoLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
    TwoLog.SourceRoomName = 'Sample Room';
    TwoLog.SourceBoardName = 'Project Board';
    TwoLog.TargetRoomName = 'Sample Room';
    TwoLog.TargetBoardName = 'Project Board';
    TwoLog.WithMC=true;
    TwoLog.initialDate = system.now()+11;
    clonetwodata.add(TwoLog);
    
    //List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> resulttwo =  leankor.MergeProjectBoardAction.MergeProjectBoard(clonetwodata);  
    //System.assert(resulttwo != null);
    Test.StopTest();
}



 //-----------------------------MultipleMergeBoardAction-----------------------------------------
 public static testMethod void  MultipleMergeBoardActionThird (){
    System.debug(Limits.getLimitQueries());
    Test.startTest();
    leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
    testFolder.Name = 'Test Room';
    insert testFolder;

    leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
    sampleRoom.Name = 'Test Room';
    sampleRoom.leankor__Portfolio__c = testFolder.Id;
    insert sampleRoom;   		
        
    leankor.RealTimeController.ProjectBoard SampleBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
    leankor.RealTimeController.ProjectBoard TargetBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
    
    List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
    leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
    list<string> ss = new list<string>();
    ss.add(SampleBoard.Id);
    reqone .SourceBoardId = ss ;
    reqone .TargetBoardId = TargetBoard.Id;
    reqone .TargetDate = system.now();
    reqone .WithMC = true;
    req.add(reqone);
    
    List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
    
        System.assert(resultmerge != null);
    leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(Name= 'masterContainer12',leankor__ValueStream__c = SampleBoard.Id,leankor__order__c =7.0, leankor__Guid__c = leankor.TestDataFactory.createGuid());
      insert m1;
    leankor__swimlane__c s1 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
      insert s1;
    leankor__swimlane__c s2 =new leankor__swimlane__c(Name ='swimlanetest',leankor__MasterContainer__c = m1.ID,leankor__order__c =1.0,leankor__ValueStream__c = SampleBoard.Id);
      insert s2;
    leankor__Zone__c z1 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s1.ID,leankor__ValueStream__c = SampleBoard.Id);
      insert z1;
    leankor__Zone__c z2 = new leankor__Zone__c(Name = 'kanban test 3',leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__CmpID__c = 'my-CMPID-zone-test3',leankor__swimlane__c = s2.ID,leankor__ValueStream__c = SampleBoard.Id);
      insert z2;
    leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = SampleBoard.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
      insert KCtemp;      
    leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now(),leankor__EstimatedDuration__c =1 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = SampleBoard.ID,leankor__MasterContainer__c = m1.ID,leankor__swimlane__c = s1.ID,leankor__order__c = 5,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__zoneGUID__c = z1.leankor__GUID__C);
        insert kan;
        Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan.id, ActivityDate = system.today ()); 
    insert tsk;   
   
   leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1', leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id );
     insert Ilog;
   
   leankor__TimeCard__c TCNew = new leankor__TimeCard__c( leankor__KanbanCard__c =kan.id , leankor__Task__c = tsk.id,leankor__TaskDueDate__c= system.now()+5);
     insert TCNew;
       
   leankor__Sticker__c  Stk = new leankor__Sticker__c(leankor__ValueStream__c = SampleBoard.ID , Name = 'sticker 1');
     insert stk;
  
   Attachment  attch = new Attachment ( name ='attchment1', Body = Blob.valueOf('a file'), ParentId =stk.id);
     insert attch;
     
   leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kan.id ,leankor__Sticker__c = stk.id );     
     insert KanbanSt; 
    list<string> ss1 = new list<string>();
    ss1.add(SampleBoard.Id);
    reqone .SourceBoardId = ss1 ;
    reqone .TargetBoardId = TargetBoard.Id;
    reqone .TargetDate = system.now();
    reqone .WithMC = true;
    req.clear();
    req.add(reqone);  
    List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge2 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
        System.assert(resultmerge2 != null);
        List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> clonetwodata = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
    leankor.MergeProjectBoardAction.MergeProjectBoardRequest TwoLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
  TwoLog.SourceRoomName = 'Sample Room';
   TwoLog.SourceBoardName = 'Project Board';
   TwoLog.TargetRoomName = 'Sample Room';
    TwoLog.TargetBoardName = 'Project Board';
    TwoLog.WithMC=true;
    TwoLog.initialDate = system.now()+11;
    clonetwodata.add(TwoLog);    
    Test.StopTest();
}
   //---------------------------------create dashboard/plan board-------------------------------------
    /*public static testMethod void CreateDashboard(){
        leankor__Preference__c pre = new leankor__Preference__c(
           leankor__CardPastDueDate__c =false,
           leankor__FollowOnChatter__c = 'all',
           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
           leankor__Moved__c = false,
           Name = userinfo.getname(),
           leankor__PercentDone__c = false,
           leankor__ValueStream__c  = null,
           leankor__SubscribeToCard__c  = 'all',
           leankor__TaskPastDueDate__c  = false
      );
      insert pre;
        leankor.ProjectBoardCarousel.ProjectRoom SampleRoom = leankor.ProjectBoardCarousel.createProjectRoom('Sample Room');
        leankor.RealTimeController.ProjectBoard Planboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Plan Board','','');
        leankor.RealTimeController.ProjectBoard Dashboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'DashBoard','','');
        leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
        leankor.RealTimeController.ProjectBoard clonekanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
            leankor__marker__c m = new leankor__marker__c(leankor__valuestream__c = kanbanboard1.Id,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__GUID2__c = leankor.TestDataFactory.createGuid()  );
                insert m;
                Blob myBlob = Blob.valueOf('blobdata');
            Attachment myatt = new Attachment(Body = myBlob, ContentType='image/png', parentId = m.Id, Name = 'preview.png');
                    insert myatt;
            leankor__Preference__c pref = new leankor__Preference__c();
                    pref.name = 'pref11';
                    pref.leankor__valuestream__c= kanbanboard1.id;
                    pref.leankor__GUID__c = leankor.TestDataFactory.createGuid();
                    pref.ownerid = userinfo.getUserId();
                    insert pref;
            leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = kanbanboard1.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
                insert KCtemp;
            leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now(),leankor__EstimatedDuration__c =1 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard1.ID,leankor__order__c = 5, leankor__Guid__c = leankor.TestDataFactory.createGuid());
                insert kan;
            Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan.id, ActivityDate = system.today ()); 
                insert tsk;
                    
            leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
                cBoard.VSID = kanbanboard1.Id;
                cBoard.RealVSID = clonekanbanboard1.id;
                cBoard.KanbanVerb = false;
                cBoard.KanbanTemplateVerb = false;
                cBoard.StickerVerb = false;
                cBoard.TaskVerb = true;
                cBoard.ZoneVerb = true;
                cBoard.MarkerVerb = true;
                cBoard.ChartVerb = false;
                cBoard.FinalStartDate=JSON.serialize(system.now()+2);
                cBoard.BoardType ='Kanban Board'; 
                system.assert(cBoard!= null);    
            leankor.KanbanController.CloneSystemBoard(cBoard);
            cBoard.FinalStartDate='';
            leankor.KanbanController.CloneSystemBoard(cBoard);
    }*/
  //---------------------------------create dashboard/plan board-------------------------------------
    public static testMethod void CreateDashboardFinalDate(){
        leankor__Preference__c pre = new leankor__Preference__c(
           leankor__CardPastDueDate__c =false,
           leankor__FollowOnChatter__c = 'all',
           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
           leankor__Moved__c = false,
           Name = userinfo.getname(),
           leankor__PercentDone__c = false,
           leankor__ValueStream__c  = null,
           leankor__SubscribeToCard__c  = 'all',
           leankor__TaskPastDueDate__c  = false
      );
      insert pre;
        Test.startTest();
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;

        leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
        sampleRoom.Name = 'Test Room';
        sampleRoom.leankor__Portfolio__c = testFolder.Id;
        insert sampleRoom;   		
          		
        
        leankor.RealTimeController.ProjectBoard Planboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Plan Board','','');
        leankor.RealTimeController.ProjectBoard Dashboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'DashBoard','','');
        leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
        leankor.RealTimeController.ProjectBoard clonekanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
            leankor__marker__c m = new leankor__marker__c(leankor__valuestream__c = kanbanboard1.Id,leankor__GUID__c = leankor.TestDataFactory.createGuid(),leankor__GUID2__c = leankor.TestDataFactory.createGuid()  );
                insert m;
                Blob myBlob = Blob.valueOf('blobdata');
            Attachment myatt = new Attachment(Body = myBlob, ContentType='image/png', parentId = m.Id, Name = 'preview.png');
                    insert myatt;
            leankor__Preference__c pref = new leankor__Preference__c();
                    pref.name = 'pref11';
                    pref.leankor__valuestream__c= kanbanboard1.id;
                    pref.leankor__GUID__c = leankor.TestDataFactory.createGuid();
                    pref.ownerid = userinfo.getUserId();
                    insert pref;
            leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = kanbanboard1.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
                insert KCtemp;
            leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now(),leankor__EstimatedDuration__c =1 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard1.ID,leankor__order__c = 5, leankor__Guid__c = leankor.TestDataFactory.createGuid());
                insert kan;
            Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan.id, ActivityDate = system.today ()); 
                insert tsk;
                    
            leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
                cBoard.VSID = kanbanboard1.Id;
                cBoard.RealVSID = clonekanbanboard1.id;
                cBoard.KanbanVerb = false;
                cBoard.KanbanTemplateVerb = false;
                cBoard.StickerVerb = false;
                cBoard.TaskVerb = true;
                cBoard.ZoneVerb = true;
                cBoard.MarkerVerb = true;
                cBoard.ChartVerb = false;
                cBoard.BoardType ='Kanban Board'; 
                cBoard.oldStartDateTime = System.now();
                cBoard.oldEndDateTime = System.now();
            cBoard.FinalStartDate='';
            String result = leankor.KanbanController.CloneSystemBoard(cBoard);
            System.assertEquals('Success', result);
            Test.stopTest();
    }  
 public static testMethod void testMergeprojectboardaction(){ 
        Test.startTest();
         leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
         testFolder.Name = 'Test Room';
         insert testFolder;
     
         leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
         sampleRoom.Name = 'Test Room';
         sampleRoom.leankor__Portfolio__c = testFolder.Id;
         insert sampleRoom;   		
                        
        
         leankor.RealTimeController.ProjectBoard kanbanboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
         leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'Kanban Board','','');
            leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(
       Name= 'masterContainer',
        leankor__ValueStream__c = kanbanboard.Id,
        leankor__order__c =0.0,
        leankor__Type__c ='backlog',
        leankor__GUID__c = leankor.TestDataFactory.createGuid() 
       );
       insert m1;
       leankor__swimlane__c s1 =new leankor__swimlane__c(
        Name ='swimlane test',
        leankor__MasterContainer__c = m1.ID,
        leankor__order__c =0.0,
        leankor__cardperrow__c= 2,
        leankor__ValueStream__c = kanbanboard.Id);
        insert s1;
        
        leankor__Zone__c z1 = new leankor__Zone__c(
             Name = 'kanban test3',
             leankor__GUID__c = leankor.TestDataFactory.createGuid(),
             leankor__CmpID__c = 'my-CMPID-zone-test3',
             leankor__swimlane__c = s1.ID,
             leankor__cardsperrow__c= 2,
             leankor__ValueStream__c = kanbanboard.Id);
        insert z1;
        list<leankor__MasterContainer__c> MClist = [Select Id, Name from leankor__MasterContainer__c Where leankor__ValueStream__c = :kanbanboard.Id];
        list<leankor__swimlane__c> SWlist = [Select Id, Name from leankor__swimlane__c Where leankor__ValueStream__c = :kanbanboard.Id];
            leankor__swimlane__c s11 =new leankor__swimlane__c(
        Name ='swimlane test',
        leankor__MasterContainer__c = MClist[0].ID,
        leankor__order__c =0.0,
        leankor__cardperrow__c= 2,
        leankor__ValueStream__c = kanbanboard.Id);
        insert s11;
        leankor__Zone__c z1S11 = new leankor__Zone__c(
             Name = 'kanban test3',
             leankor__GUID__c =leankor.TestDataFactory.createGuid(),
             leankor__CmpID__c = 'my-CMPID-zone-test3',
             leankor__swimlane__c = s11.ID,
             leankor__cardsperrow__c= 2,
             leankor__ValueStream__c = kanbanboard.Id);
        insert z1S11;
        leankor__Zone__c z1SW = new leankor__Zone__c(
             Name = 'kanban test3',
             leankor__GUID__c = leankor.TestDataFactory.createGuid(),
             leankor__CmpID__c = 'my-CMPID-zone-test3',
             leankor__swimlane__c = SWlist[0].ID,
             leankor__cardsperrow__c= 2,
             leankor__ValueStream__c = kanbanboard.Id);
        insert z1SW;
             leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = kanbanboard.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
                insert KCtemp;
             leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now()+2,leankor__EstimatedDuration__c =3 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard.ID,leankor__Guid__c= leankor.TestDataFactory.createGuid());
                insert kan;
            leankor__KanbanCard__c kan1 = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now()+2,leankor__EstimatedDuration__c =3 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard.ID,leankor__Guid__c= leankor.TestDataFactory.createGuid());
                insert kan1;
           leankor__Dependency__c d = new leankor__Dependency__c(
                        leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                        leankor__ValueStream__c = kanbanboard.ID,
                        leankor__Predecessor__c = kan1.id ,                     
                        leankor__Successor__c = kan.id);  
                        insert d;
                        
       Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan1.id, ActivityDate = system.today ()); 
        insert tsk;   
       
       leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1', leankor__KanbanCard__c =kan1.id , leankor__Task__c = tsk.id );
         insert Ilog;
       
       leankor__TimeCard__c TCNew = new leankor__TimeCard__c( leankor__KanbanCard__c =kan1.id , leankor__Task__c = tsk.id,leankor__TaskDueDate__c= system.now()+5);
         insert TCNew;
           
       leankor__Sticker__c  Stk = new leankor__Sticker__c(leankor__ValueStream__c = kanbanboard.ID , Name = 'sticker 1');
         insert stk;
      
       Attachment  attch = new Attachment ( name ='attchment1', Body = Blob.valueOf('a file'), ParentId =stk.id);
         insert attch;
         
       leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kan1.id ,leankor__Sticker__c = stk.id );     
         insert KanbanSt;
        leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM') ;
        insert linkr;
        leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',leankor__BoardType__c='Kanban Board' ,leankor__projectroom__C = LinkR.id);
        insert Linkb;
        leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',leankor__GUID__c = leankor.TestDataFactory.createGuid());
        insert linkKC; 
            
        List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> mergedata = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
        leankor.MergeProjectBoardAction.MergeProjectBoardRequest OneLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
            OneLog.SourceRoomName = 'Sample Room';
            OneLog.SourceBoardName = 'Project Board';
            //OneLog.SourceBoardId =kanbanboard.id;
            OneLog.TargetRoomName = 'Sample Room';
            OneLog.TargetBoardName = 'Project Board1';
            OneLog.LinkRoomName = 'LINKROOM';
            OneLog.LinkBoardName = 'LINKABC';
            OneLog.LinkKanbanCardId = linkKC.ID;
            OneLog.WithMC=true;
            OneLog.TargetDate = system.now()+10;
            mergedata.add(OneLog);
            system.assert(mergedata !=null);
        //List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> result =  leankor.MergeProjectBoardAction.MergeProjectBoard(mergedata);
      
       /* Test.StartTest();
        //-------------------------
        List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> mergedata1 = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
        leankor.MergeProjectBoardAction.MergeProjectBoardRequest twoLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
            twoLog.SourceRoomName = 'Sample Room';
            twoLog.SourceBoardName = 'Project Board';
            //twoLog.SourceBoardId =kanbanboard.id;
            twoLog.TargetRoomName = 'Sample Room';
            twoLog.TargetBoardName = 'Project Board1';
            twoLog.LinkRoomName = 'LINKROOM';
            twoLog.LinkBoardName = 'LINKABC';
            twoLog.LinkKanbanCardId = linkKC.ID;
            twoLog.WithMC=true;
            twoLog.initialDate = system.now()+10;
            mergedata1.add(twoLog);
            system.assert(mergedata !=null);
        List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> result1 =  leankor.MergeProjectBoardAction.MergeProjectBoard(mergedata1); */
        Test.StopTest();
 }  

 private static testMethod void testMergeprojectboardactiontwo(){ 
    Test.startTest();
    leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
    testFolder.Name = 'Test Room';
    insert testFolder;

    leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
    sampleRoom.Name = 'Test Room';
    sampleRoom.leankor__Portfolio__c = testFolder.Id;
    insert sampleRoom;   		
         		
    
    leankor.RealTimeController.ProjectBoard kanbanboard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
    leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'Kanban Board','','');
    leankor__MasterContainer__c m1 = new leankor__MasterContainer__c(
    Name= 'masterContainer',
    leankor__ValueStream__c = kanbanboard.Id,
    leankor__order__c =0.0,
    leankor__Type__c ='backlog',
    leankor__GUID__c = leankor.TestDataFactory.createGuid() 
   );
   insert m1;
   leankor__swimlane__c s1 =new leankor__swimlane__c(
    Name ='swimlane test',
    leankor__MasterContainer__c = m1.ID,
    leankor__order__c =0.0,
    leankor__cardperrow__c= 2,
    leankor__ValueStream__c = kanbanboard.Id);
    insert s1;
    
    leankor__Zone__c z1 = new leankor__Zone__c(
         Name = 'kanban test3',
         leankor__GUID__c = leankor.TestDataFactory.createGuid(),
         leankor__CmpID__c = 'my-CMPID-zone-test3',
         leankor__swimlane__c = s1.ID,
         leankor__cardsperrow__c= 2,
         leankor__ValueStream__c = kanbanboard.Id);
    insert z1;
    list<leankor__MasterContainer__c> MClist = [Select Id, Name from leankor__MasterContainer__c Where leankor__ValueStream__c = :kanbanboard.Id];
    list<leankor__swimlane__c> SWlist = [Select Id, Name from leankor__swimlane__c Where leankor__ValueStream__c = :kanbanboard.Id];
        leankor__swimlane__c s11 =new leankor__swimlane__c(
    Name ='swimlane test',
    leankor__MasterContainer__c = MClist[0].ID,
    leankor__order__c =0.0,
    leankor__cardperrow__c= 2,
    leankor__ValueStream__c = kanbanboard.Id);
    insert s11;
    leankor__Zone__c z1S11 = new leankor__Zone__c(
         Name = 'kanban test3',
         leankor__GUID__c =leankor.TestDataFactory.createGuid(),
         leankor__CmpID__c = 'my-CMPID-zone-test3',
         leankor__swimlane__c = s11.ID,
         leankor__cardsperrow__c= 2,
         leankor__ValueStream__c = kanbanboard.Id);
    insert z1S11;
    leankor__Zone__c z1SW = new leankor__Zone__c(
         Name = 'kanban test3',
         leankor__GUID__c = leankor.TestDataFactory.createGuid(),
         leankor__CmpID__c = 'my-CMPID-zone-test3',
         leankor__swimlane__c = SWlist[0].ID,
         leankor__cardsperrow__c= 2,
         leankor__ValueStream__c = kanbanboard.Id);
    insert z1SW;
    
         leankor__KanbanCardTemplate__c KCtemp = new leankor__KanbanCardTemplate__c(Name = 'RED Card',leankor__ValueStream__c = kanbanboard.id,leankor__Color__c = '#F71B1B',leankor__Width__c = 328.0);
            insert KCtemp;
         leankor__KanbanCard__c kan = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now()+2,leankor__EstimatedDuration__c =3 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard.ID,leankor__Guid__c= leankor.TestDataFactory.createGuid());
            insert kan;
        leankor__KanbanCard__c kan1 = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now()+2,leankor__EstimatedDuration__c =3 ,Name ='new card',leankor__KanbanCardTemplate__c= KCtemp.id,leankor__ValueStream__C = kanbanboard.ID,leankor__Guid__c= leankor.TestDataFactory.createGuid());
            insert kan1;
       leankor__Dependency__c d = new leankor__Dependency__c(
                    leankor__GUID__c = leankor.TestDataFactory.createGuid(),
                    leankor__ValueStream__c = kanbanboard.ID,
                    leankor__Predecessor__c = kan1.id ,                     
                    leankor__Successor__c = kan.id);  
                    insert d;
                    
   Task  tsk = new Task (Priority = ' high', status = 'in progress', whatid = kan1.id, ActivityDate = system.today ()); 
    insert tsk;   
   
   leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1', leankor__KanbanCard__c =kan1.id , leankor__Task__c = tsk.id );
     insert Ilog;
   
   leankor__TimeCard__c TCNew = new leankor__TimeCard__c( leankor__KanbanCard__c =kan1.id , leankor__Task__c = tsk.id,leankor__TaskDueDate__c= system.now()+5);
     insert TCNew;
       
   leankor__Sticker__c  Stk = new leankor__Sticker__c(leankor__ValueStream__c = kanbanboard.ID , Name = 'sticker 1');
     insert stk;
  
   Attachment  attch = new Attachment ( name ='attchment1', Body = Blob.valueOf('a file'), ParentId =stk.id);
     insert attch;
     
   leankor__KanbanCardSticker__c  KanbanSt = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kan1.id ,leankor__Sticker__c = stk.id );     
     insert KanbanSt;
    leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM') ;
    insert linkr;
    leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',leankor__BoardType__c='Kanban Board' ,leankor__projectroom__C = LinkR.id);
    insert Linkb;
    leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',leankor__GUID__c = leankor.TestDataFactory.createGuid());
    insert linkKC;                             
   /* List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> mergedata = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
    leankor.MergeProjectBoardAction.MergeProjectBoardRequest OneLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
        OneLog.SourceRoomName = 'Sample Room';
        OneLog.SourceBoardName = 'Project Board';
        //OneLog.SourceBoardId =kanbanboard.id;
        OneLog.TargetRoomName = 'Sample Room';
        OneLog.TargetBoardName = 'Project Board1';
        OneLog.LinkRoomName = 'LINKROOM';
        OneLog.LinkBoardName = 'LINKABC';
        OneLog.LinkKanbanCardId = linkKC.ID;
        OneLog.WithMC=true;
        OneLog.TargetDate = system.now()+10;
        mergedata.add(OneLog);
        system.assert(mergedata !=null);
    List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> result =  leankor.MergeProjectBoardAction.MergeProjectBoard(mergedata);*/
  
    //-------------------------
    List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> mergedata1 = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
    leankor.MergeProjectBoardAction.MergeProjectBoardRequest twoLog = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
        twoLog.SourceRoomName = 'Sample Room';
        twoLog.SourceBoardName = 'Project Board';
        //twoLog.SourceBoardId =kanbanboard.id;
        twoLog.TargetRoomName = 'Sample Room';
        twoLog.TargetBoardName = 'Project Board1';
        twoLog.LinkRoomName = 'LINKROOM';
        twoLog.LinkBoardName = 'LINKABC';
        twoLog.LinkKanbanCardId = linkKC.ID;
        twoLog.WithMC=true;
        twoLog.initialDate = system.now()+10;
        mergedata1.add(twoLog);
        system.assert(mergedata1 !=null);
    //List<leankor.MergeProjectBoardAction.MergeProjectBoardResult> result1 =  leankor.MergeProjectBoardAction.MergeProjectBoard(mergedata1); 
    Test.StopTest();
}  
    private static testMethod void cloneSystemBoardTest1(){
        List<leankor__ProjectRoom__C> projectRoom=[select id from leankor__ProjectRoom__C];
        List<leankor__ValueStream__c> vsList1=[select id from leankor__ValueStream__c];
        leankor__Preference__c pre = new leankor__Preference__c(
           leankor__CardPastDueDate__c =false,
           leankor__FollowOnChatter__c = 'all',
           leankor__GUID__c = leankor.TestDataFactory.createGuid(),
           leankor__Moved__c = false,
           Name = userinfo.getname(),
           leankor__PercentDone__c = false,
           leankor__ValueStream__c  = null,
           leankor__SubscribeToCard__c  = 'all',
           leankor__TaskPastDueDate__c  = false
      );
      insert pre;
        List<leankor__KanbanCard__c> kanbancardList= [select id,OwnerId,leankor__EstimatedDuration__c,leankor__Title__c,leankor__X__c,leankor__Y__c from leankor__KanbanCard__c];                 
        System.debug(kanbancardList.size());
        Test.startTest();
            leankor.KanbanController.CloneBoard cBoard2 = new leankor.KanbanController.CloneBoard();
                cBoard2.VSID = vsList1[0].Id;
                cBoard2.RealVSID = vsList1[0].Id;
                cBoard2.KanbanVerb = true;
                cBoard2.KanbanTemplateVerb = true;
                cBoard2.StickerVerb = false;
                cBoard2.TaskVerb = true;
                cBoard2.ZoneVerb = true;
                cBoard2.MarkerVerb = true;
                cBoard2.ChartVerb = true;
                cBoard2.FinalDate = JSON.serialize(system.now());
                cBoard2.BoardType ='Whiteboard';           
                cBoard2.FinalStartDate = JSON.serialize(system.now()); 
                cBoard2.oldStartDateTime = System.now();
                cBoard2.oldEndDateTime = System.now(); 
            System.assert(leankor.KanbanController.CloneSystemBoard(cBoard2)!=null);    
        Test.stopTest();    
    }               
    /*
        Date :- 31/10/18
        To cover createStatusLogs and getStatusLogs methods.
    */
    private static testMethod void createStatusLogsTest(){      
        List<leankor__KanbanCard__c> kanbancardList= [select id ,name from leankor__KanbanCard__c];
        List<leankor__StatusLog__c> StatusLogList = new List<leankor__StatusLog__c>();
         for(Integer status=0;status<5;status++){
            leankor__StatusLog__c statuslog=new leankor__StatusLog__c();
                statuslog.leankor__Detail__c='StatusLog';
                statuslog.leankor__OnBudget__c='Green';
                statuslog.leankor__OnQuality__c='Green';
                statuslog.leankor__OnTime__c='Green';
                statuslog.leankor__KanbanCard__c=kanbancardList[0].id;
                statuslog.leankor__PercentComplete__c=50;
                StatusLogList.add(statuslog);
         }
         insert StatusLogList;
          Test.startTest();
                List<kanbancontroller.StatusLogs>  statuslist= new list<kanbancontroller.StatusLogs>();
                 for(leankor__StatusLog__c status:StatusLogList){
                    kanbancontroller.StatusLogs statusLog= new kanbancontroller.StatusLogs();
                        statusLog.id=status.id;
                        statusLog.onBudget=status.leankor__OnBudget__c;
                        statusLog.onTime=status.leankor__OnTime__c;
                        statusLog.kanbanCard=status.leankor__KanbanCard__c;
                        statusLog.percentComplete=string.valueOf(status.leankor__PercentComplete__c);
                        statusLog.onQuality = status.leankor__OnQuality__c;
                        statuslist.add(statusLog);
                } 
                //call createStatusLogs method.
                System.assert(kanbancontroller.createStatusLogs(statuslist)!=null); 
            
                List<String> kbids =new List<String>();
                for(leankor__KanbanCard__c kb:kanbancardList){
                     kbids.add(kb.id);
                }   
                //call  getStatusLogs method.   
                System.assert(kanbancontroller.getStatusLogs(kbids)!=null);  
         Test.StopTest();
    }   
    /*
      Data :- 31/10/18
      To cover getTaskChatterCounts and getTaskChatterStats methods .
    */
    private static testMethod void getTaskChatterCountsTest(){
      Test.startTest(); 
            List <Id> taskIds = new List <Id>();
            List<TaskFeed> taskfeedList = [select id, ParentId from TaskFeed];
            for(TaskFeed tskFeed : taskfeedList){
                taskIds.add(tskFeed.ParentId);
            }
            List<Task> taskList =[Select id ,Priority,status,WhatId from Task where Id IN: taskIds];    
            List<FeedItem> feedList=new List<FeedItem>();
            List<Id> tskids = new List<Id>();
            for(Task tsk:taskList){        
                FeedItem feed=new FeedItem();
                    feed.ParentId=taskList[0].id;
                    feed.type='TextPost';
                    feed.Body='hdsf';
                    feedList.add(feed);
                    tskids.add(tsk.id);
            
            }
            try{
            insert feedList;
            }catch(Exception exp){
                System.debug('Error : '+exp.getMessage());
            }
        
            //call getTaskChatterCounts method.
            System.assert(kanbancontroller.getTaskChatterCounts(taskList)!=null);   
            //call getTaskChatterStats method.                      
            System.assert(leankor.KanbanController.getTaskChatterStats(tskids)!= null);
        Test.stopTest();
    }
    /*
      Date :31/10/18
      To cover readJSONDataByCategory and getFilteredUsers methods .
    */
    private static testMethod void readJSONDataByCategoryTest(){
        Test.startTest();
            List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];             
            List<leankor__KanbanCard__c> kanbancardList=[select id from leankor__KanbanCard__c];
            leankor__KanbanCardTemplate__c kanbanTemp=leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]);
            leankor.KanbanController.TemplateData template = new leankor.KanbanController.TemplateData();
                template.templateId=kanbanTemp.id;
                template.id=kanbancardList[0].id;
                template.fieldSetName=kanbanTemp.FieldSetName__c;
            //call readJSONDataByCategory method .
            System.assert(leankor.KanbanController.readJSONDataByCategory(JSON.Serialize(template))== null);
            // call getFilteredUsers method.
            leankor__ValueStream__c valuestream = [Select id,
                                                          Name 
                                                        From leankor__ValueStream__c 
                                                        Where name = 'Valuestream ProjectLaunchDate constarint'];
            
            System.assert(leankor.KanbanController.getFilteredUsers(valuestream.id)!=null);
        Test.stopTest();
    }
    /*
       Date : 31/10/18
       To cover listIdsToString , getTimeCardDurationValues,checkFSLManageApp methods .
    */
    private static testMethod void listIdsToStringTest(){
        Test.startTest();
            List<leankor__KanbanCard__c> kanbancardList=[select id from leankor__KanbanCard__c];        
            //convert kanban card to string.
            List<String> kanbanCardIds=new List<String>();
                kanbanCardIds.add(kanbancardList[0].id);  
            //call listIdsToString Method.                 
            System.assert(leankor.KanbanController.listIdsToString(kanbanCardIds)!= null); 
            //call getTimeCardDurationValues   
            System.assert(leankor.KanbanController.getTimeCardDurationValues()!= null);
            // call checkFSLManageApp method.
            System.assert(leankor.KanbanController.checkFSLManageApp()!= null);                 
        Test.stopTest();    
    }       
    
    /* Method tests to see if cards that get passed to getConstraintViolation method have any violations
    * Test will pass if a constraint violation was not found.
    * Test will fail if a constraint violation was somehow found.
    */
    @isTest
    private static void testGetConstraintViolationNoViolation() {
        //leankor__ValueStream__c valueStream = getBoard('Constraint board');
        leankor__ValueStream__c valueStream = getBoard('Constraint kanban');
        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(valueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);
        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);
        
        leankor__LeanConstants__c constraintSetting = getConstraintSetting();
        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        leankor__KanbanCard__c cardToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And RecordType.Name = 'ActivityCard'
                                                Limit 1];
        
        /*leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
        mustFinishOn.leankor__Description__c = 'mustfinishon';
        mustFinishOn.leankor__Type__c = 'mustfinishon';
        insert mustFinishOn;*/
        leankor__ScheduleConstraint__c mustFinishOn = [Select Id
                                                            From leankor__ScheduleConstraint__c
                                                            Where leankor__Description__c = 'mustfinishon'
                                                            Limit 1];

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardToUpdate.Id;
        schedMode.leankor__ConstraintDateTime__c = cardToUpdate.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = cardToUpdate.Id;
        card.valueStream = cardToUpdate.leankor__ValueStream__c;
        card.startDateTime = System.now().addDays(-2);
        card.dueDateTime = cardToUpdate.leankor__DueDateTime__c;
        //card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
        card.boardType = cardToUpdate.leankor__ValueStream__r.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = false;
        card.valueStreamLink = null;
        card.valueStreamCardLink = null;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(true, constraintsViolated.isEmpty(), 'There should not have been any constraint violation');

        Test.stopTest();

    }

    /* Method tests to see if cards that get passed to getConstraintViolation method have any violations
    * Test will pass if a constraint violation was found, since the card's start date is being changed but has as constraint violation of 'must start on'.
    * Test will fail if a constraint violation was somehow not found despite the start date change.
    */
    @isTest
    private static void testGetConstraintViolationStartChange() {
        leankor__ValueStream__c valueStream = getBoard('Constraint board');                                        

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(valueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        leankor__KanbanCard__c cardToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And RecordType.Name = 'ActivityCard'
                                                Limit 1];
        
        leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
        mustStartOn.leankor__Description__c = 'muststarton';
        mustStartOn.leankor__Type__c = 'muststarton';
        insert mustStartOn;

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardToUpdate.Id;
        schedMode.leankor__ConstraintDateTime__c = cardToUpdate.leankor__StartDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = cardToUpdate.Id;
        card.valueStream = cardToUpdate.leankor__ValueStream__c;
        card.startDateTime = System.now().addDays(3);
        card.dueDateTime = cardToUpdate.leankor__DueDateTime__c.addDays(3);
        card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1;
        card.boardType = cardToUpdate.leankor__ValueStream__r.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = false;
        card.valueStreamLink = null;
        card.valueStreamCardLink = null;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Must Start On');

        Test.stopTest();

    }

    /* Method tests a card that gets updated to have a link to another card and calls getConstraintViolation method to check for any violations
    * Test will pass if a constraint violation is found since the linked card has constraint of finish no later than,
    * and the card to be updated has a due date time later than the linked card, making the linked card's due date move later.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the linked card and the updated card's due date.
    */
    @isTest
    private static void testGetConstraintViolationUpdateLink() {
        leankor__ValueStream__c valueStream = getBoard('Constraint board');

        leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        leankor__KanbanCard__c cardToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And Name = 'Activity 2'
                                                Limit 1];

        leankor__KanbanCard__c cardToLink = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :linkValueStream.Id
                                                And Name = 'Activity 0'
                                                Limit 1];                
        
        leankor__ScheduleConstraint__c finishNoLaterThan = new leankor__ScheduleConstraint__c();
        finishNoLaterThan.leankor__Description__c = 'finishnolaterthan';
        finishNoLaterThan.leankor__Type__c = 'finishnolaterthan';
        insert finishNoLaterThan;

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardToLink.Id;
        schedMode.leankor__ConstraintDateTime__c = cardToLink.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = finishNoLaterThan.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = cardToUpdate.Id;
        card.valueStream = cardToUpdate.leankor__ValueStream__c;
        card.startDateTime = cardToUpdate.leankor__StartDateTime__c;
        card.dueDateTime = cardToUpdate.leankor__DueDateTime__c;
        card.estimatedDuration = cardToUpdate.leankor__EstimatedDuration__c; 
        card.boardType = cardToUpdate.leankor__ValueStream__r.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = true;
        card.valueStreamLink = linkValueStream.Id;
        card.valueStreamCardLink = cardToLink.Id;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Finish No Later Than');

        Test.stopTest();

    }

    /* Method tests a card have an updated date and a link to another card removed and calls getConstraintViolation method to check for any violations
    * Test will pass if a constraint violation is found since the has constraint of finish no earlier than,
    * and the card to be updated has a new due date earlier than constraint date.
    * Test will fail if a constraint violation was somehow not found despite the updated card's due date changing.
    */
    @isTest
    private static void testGetConstraintViolationRemoveLink() {
        leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

        leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        leankor__KanbanCard__c cardToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And Name = 'Activity 1'
                                                Limit 1];

        leankor__KanbanCard__c cardToLink = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :linkValueStream.Id
                                                And Name = 'Activity 0'
                                                Limit 1];  

        cardToUpdate.leankor__ValueStreamLink__c = linkValueStream.Id;
        cardToUpdate.leankor__ValueStreamCardLink__c = cardToLink.Id;
        update cardToUpdate;                               
        
        leankor__ScheduleConstraint__c finishNoEarlierThan = new leankor__ScheduleConstraint__c();
        finishNoEarlierThan.leankor__Description__c = 'finishnoearlierthan';
        finishNoEarlierThan.leankor__Type__c = 'finishnoearlierthan';
        insert finishNoEarlierThan;

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardToUpdate.Id;
        schedMode.leankor__ConstraintDateTime__c = cardToUpdate.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = finishNoEarlierThan.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = cardToUpdate.Id;
        card.valueStream = cardToUpdate.leankor__ValueStream__c;
        card.startDateTime = cardToUpdate.leankor__StartDateTime__c.addDays(-2);
        card.dueDateTime = cardToUpdate.leankor__DueDateTime__c.addDays(-2);
        card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
        card.boardType = cardToUpdate.leankor__ValueStream__r.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = true;
        card.valueStreamLink = null;
        card.valueStreamCardLink = null;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Finish No Earlier Than');

        Test.stopTest();

    }

    /* Method tests two linked cards, where the parent gets updated, and calls getConstraintViolation method to check for any violations
    * Test will pass if a constraint violation is found since the parent card has constraint of start no earlier than,
    * and the card to be updated has a start date time earlier than the constraint date.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the parent card and its date being changed.
    */
    @isTest
    private static void testGetConstraintViolationLinkParent() {
        leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

        leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        List<leankor__KanbanCard__c> cardsToUpdate = [Select Id,
                                                            Name,
                                                            leankor__StartDateTime__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__ValueStream__c,
                                                            leankor__ValueStream__r.leankor__BoardType__c,
                                                            RecordType.Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :valueStream.Id
                                                    And RecordType.Name = 'ActivityCard'
                                                    Limit 2];

        cardsToUpdate[0].leankor__ValueStreamLink__c = valueStream.Id;
        cardsToUpdate[0].leankor__ValueStreamCardLink__c = cardsToUpdate[1].Id;
        update cardsToUpdate[0];                               
        
        leankor__ScheduleConstraint__c startNoEarlierThan = new leankor__ScheduleConstraint__c();
        startNoEarlierThan.leankor__Description__c = 'startnoearlierthan';
        startNoEarlierThan.leankor__Type__c = 'startnoearlierthan';
        insert startNoEarlierThan;

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardsToUpdate[1].Id;
        schedMode.leankor__ConstraintDateTime__c = cardsToUpdate[1].leankor__StartDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = startNoEarlierThan.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = cardsToUpdate[1].Id;
        card.valueStream = cardsToUpdate[1].leankor__ValueStream__c;
        card.startDateTime = cardsToUpdate[1].leankor__StartDateTime__c.addDays(-1);
        card.dueDateTime = cardsToUpdate[1].leankor__DueDateTime__c;
        card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
        card.boardType = cardsToUpdate[1].leankor__ValueStream__r.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = false;
        card.valueStreamLink = null;
        card.valueStreamCardLink = null;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Start No Earlier Than');

        Test.stopTest();

    }

    /* Method tests two linked cards, where they both get updated, and calls getConstraintViolation method to check for any violations
    * Test will pass if a constraint violation is found since both cards have constraints,
    * and the cards to be updated has their dates changed to conflict with the constraint type and date.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the cards and their dates being changed.
    */
    @isTest
    private static void testGetConstraintViolationLinkBothConstraint() {
        leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

        leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        List<leankor__KanbanCard__c> cardsToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And RecordType.Name = 'ActivityCard'
                                                Limit 2];

        cardsToUpdate[1].leankor__ValueStreamLink__c = valueStream.Id;
        cardsToUpdate[1].leankor__ValueStreamCardLink__c = cardsToUpdate[0].Id;
        update cardsToUpdate[1];                               
        
        List<leankor__ScheduleConstraint__c> constraints = new List<leankor__ScheduleConstraint__c>();
        leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
        mustFinishOn.leankor__Description__c = 'mustfinishon';
        mustFinishOn.leankor__Type__c = 'mustfinishon';
        constraints.add(mustFinishOn);

        leankor__ScheduleConstraint__c startNoLaterThan = [Select Id
                                                            From leankor__ScheduleConstraint__c
                                                            Where leankor__Type__c = 'startnolaterthan'];

        /*leankor__ScheduleConstraint__c startNoLaterThan = new leankor__ScheduleConstraint__c();
        startNoLaterThan.leankor__Description__c = 'startnolaterthan';
        startNoLaterThan.leankor__Type__c = 'startnolaterthan';
        constraints.add(startNoLaterThan);
        insert constraints;*/

        List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();
        leankor__ScheduleMode__c schedMode1 = new leankor__ScheduleMode__c();
        schedMode1.leankor__KanbanCard__c = cardsToUpdate[0].Id;
        schedMode1.leankor__ConstraintDateTime__c = cardsToUpdate[0].leankor__DueDateTime__c;
        schedMode1.leankor__ScheduleConstraint__c = mustFinishOn.Id;
        schedModes.add(schedMode1);

        leankor__ScheduleMode__c schedMode2 = new leankor__ScheduleMode__c();
        schedMode2.leankor__KanbanCard__c = cardsToUpdate[1].Id;
        schedMode2.leankor__ConstraintDateTime__c = cardsToUpdate[1].leankor__StartDateTime__c;
        schedMode2.leankor__ScheduleConstraint__c = startNoLaterThan.Id;
        schedModes.add(schedMode2);
        insert schedModes;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        for(Integer i = 0; i < 2; i++) {
            KanbanCard card = new KanbanCard();
            card.id = cardsToUpdate[i].Id;
            card.valueStream = cardsToUpdate[i].leankor__ValueStream__c;
            card.startDateTime = cardsToUpdate[i].leankor__StartDateTime__c.addDays(3);
            card.dueDateTime = cardsToUpdate[i].leankor__DueDateTime__c.addDays(4);
            card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
            card.boardType = cardsToUpdate[i].leankor__ValueStream__r.leankor__BoardType__c;
            card.isUpdateValueStreamCardLink = false;
            card.valueStreamLink = null;
            card.valueStreamCardLink = null;
            cardsToCheck.add(card);
        }

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been constraint violations for both cards');

        Test.stopTest();

    }

    /* Method tests creating a card and adding a link to a card in the process and calls getConstraintViolation method to check for any violations
    * Test will pass if a constraint violation is found since the card being linked has constraint of start no later than,
    * and the card to be created does not get created since its start date time is later than the constraint date.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the linked card, and if the card then gets created.
    */
    @isTest
    private static void testGetConstraintViolationCreateLink() {
        leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

        leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        leankor__KanbanCard__c cardToLink = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :linkValueStream.Id
                                                And Name = 'Activity 0'
                                                Limit 1];               
        /*leankor__ScheduleConstraint__c startNoLaterThan = new leankor__ScheduleConstraint__c();
        startNoLaterThan.leankor__Description__c = 'startnolaterthan';
        startNoLaterThan.leankor__Type__c = 'startnolaterthan';
        insert startNoLaterThan;*/
        leankor__ScheduleConstraint__c startNoLaterThan = [Select Id
                                                            From leankor__ScheduleConstraint__c
                                                            Where leankor__Type__c = 'startnolaterthan'];
        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
        schedMode.leankor__KanbanCard__c = cardToLink.Id;
        schedMode.leankor__ConstraintDateTime__c = cardToLink.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = startNoLaterThan.Id;
        insert schedMode;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        Boolean checkDepConstraint = false;

        KanbanCard card = new KanbanCard();
        card.id = null;
        card.valueStream = valueStream.Id;
        card.startDateTime = System.now().addDays(10);
        card.dueDateTime = System.now().addDays(15);
        card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
        card.boardType = valueStream.leankor__BoardType__c;
        card.isUpdateValueStreamCardLink = true;
        card.valueStreamLink = linkValueStream.Id;
        card.valueStreamCardLink = cardToLink.Id;
        cardsToCheck.add(card);

        Test.startTest();

        KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

        System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Start No Later Than');

        Test.stopTest();

    }

    /* Method tests to create some schedule modes for some cards and call getScheduleMode method to return a map of the card Ids and schedule modes
    * Test will pass if at least one key-value pair of a kanban card id, and its schedule mode is returned
    * Test will fail if the map returns empty.
    */
    @isTest
    private static void testGetScheduleModeCards() {
        leankor__ValueStream__c valueStream = getBoard('Constraint board');

        leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(valueStream.Id);

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        blackOutsList.add(blackOut);

        leankor__LeanConstants__c constraintSetting = getConstraintSetting();

        Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        List<leankor__KanbanCard__c> cardsToUpdate = [Select Id,
                                                    Name,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c,
                                                    RecordType.Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                And RecordType.Name = 'ActivityCard'
                                                Limit 3];

        leankor__ScheduleConstraint__c asap = new leankor__ScheduleConstraint__c();
        asap.leankor__Description__c = 'assoonaspossible';
        asap.leankor__Type__c = 'assoonaspossible';
        insert asap;

        List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();
        Set<Id> cardIds = new Set<Id>();
        for(leankor__KanbanCard__c card : cardsToUpdate) {
            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
            schedMode.leankor__KanbanCard__c = card.Id;
            schedMode.leankor__ConstraintDateTime__c = valueStream.leankor__ProjectBoardStartDateTime__c;
            schedMode.leankor__ScheduleConstraint__c = asap.Id;
            schedModes.add(schedMode);
            cardIds.add(card.Id);
        }
        insert schedModes;
          
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();

        Test.startTest();

        Map<Id, leankor__ScheduleMode__c> schedModeCards = KanbanController.getScheduleModeCards(cardIds);

        System.assert(schedModeCards.size() > 0, 'The map returned should have contained at least 1 schedule mode');

        Test.stopTest();

    }

    /* Method tests a card that gets updated to have a link to another card then checks for any constraint violations - ran as Community User
    * Test will pass if a constraint violation is found since the linked card has constraint of must finish on,
    * and the card to be updated has a due date time later than the linked card, making the linked card's due date move.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the linked card and the updated card's due date.
    */
    @isTest
    private static void testGetConstraintViolationUpdateLinkAsCommunityUser() {

        /*createCommunityUser();

        Test.startTest();

        System.runAs(uSamp) {
            leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

            leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

            leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

            List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
            blackOutsList.add(blackOut);

            leankor__LeanConstants__c constraintSetting = getConstraintSetting();

            Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

            constraintSetting.leankor__AllowSchedulingConstraints__c = true;
            update constraintSetting;

            leankor__KanbanCard__c cardToUpdate = [Select Id,
                                                        Name,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.leankor__BoardType__c,
                                                        RecordType.Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :valueStream.Id
                                                    And Name = 'Activity 2'
                                                    Limit 1];

            leankor__KanbanCard__c cardToLink = [Select Id,
                                                        Name,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.leankor__BoardType__c,
                                                        RecordType.Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :linkValueStream.Id
                                                    And Name = 'Activity 0'
                                                    Limit 1];            
            


            leankor__ScheduleConstraint__c mustFinishOn = [Select Id
                                                                From leankor__ScheduleConstraint__c
                                                                Where leankor__Description__c = 'mustfinishon'
                                                                Limit 1];
            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
            schedMode.leankor__KanbanCard__c = cardToLink.Id;
            schedMode.leankor__ConstraintDateTime__c = cardToLink.leankor__DueDateTime__c;
            schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
            insert schedMode;
            
            List<KanbanCard> cardsToCheck = new List<KanbanCard>();
            Boolean checkDepConstraint = false;

            KanbanCard card = new KanbanCard();
            card.id = cardToUpdate.Id;
            card.valueStream = cardToUpdate.leankor__ValueStream__c;
            card.startDateTime = cardToUpdate.leankor__StartDateTime__c;
            card.dueDateTime = cardToUpdate.leankor__DueDateTime__c;
            card.estimatedDuration = cardToUpdate.leankor__EstimatedDuration__c; 
            card.boardType = cardToUpdate.leankor__ValueStream__r.leankor__BoardType__c;
            card.isUpdateValueStreamCardLink = true;
            card.valueStreamLink = linkValueStream.Id;
            card.valueStreamCardLink = cardToLink.Id;
            cardsToCheck.add(card);

            KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

            System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Must Finish On');

        }

        Test.stopTest(); */
    }

    /* Method tests creating a card and adding a link to a card in the process and checks for any constraint violations - run as Visual Lean User
    * Test will pass if a constraint violation is found since the card being linked has constraint of must start on,
    * and the card to be created does not get created since its start date time is earlier than the constraint date.
    * Test will fail if a constraint violation was somehow not found despite the constraint for the linked card, and if the card then gets created.
    */
    @isTest
    private static void testGetConstraintViolationCreateLinkAsLeanUser() {

        createVisualLeanUser();

        Test.startTest();

        System.runAs(uSamp) {
            leankor__ValueStream__c valueStream = getBoard('Constraint kanban');

            leankor__ValueStream__c linkValueStream = getBoard('Constraint board');

            leankor__ProjectScheduleBlackout__c blackOut = getProjectBoardBlackout(linkValueStream.Id);

            List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
            blackOutsList.add(blackOut);

            leankor__LeanConstants__c constraintSetting = getConstraintSetting();

            Util.WorkWeek workWeek = new Util.Workweek(5, blackOutsList);

            constraintSetting.leankor__AllowSchedulingConstraints__c = true;
            update constraintSetting;

            leankor__KanbanCard__c cardToLink = [Select Id,
                                                        Name,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.leankor__BoardType__c,
                                                        RecordType.Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :linkValueStream.Id
                                                    And Name = 'Activity 0'
                                                    Limit 1];              
            
            leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
            mustStartOn.leankor__Description__c = 'muststarton';
            mustStartOn.leankor__Type__c = 'muststarton';
            insert mustStartOn;

            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
            schedMode.leankor__KanbanCard__c = cardToLink.Id;
            schedMode.leankor__ConstraintDateTime__c = cardToLink.leankor__DueDateTime__c;
            schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
            insert schedMode;
            
            List<KanbanCard> cardsToCheck = new List<KanbanCard>();
            Boolean checkDepConstraint = false;

            KanbanCard card = new KanbanCard();
            card.id = null;
            card.valueStream = valueStream.Id;
            card.startDateTime = System.now().addDays(-5);
            card.dueDateTime = System.now().addDays(-2);
            card.estimatedDuration = workWeek.getBusinessDays(card.startDateTime.date(), card.dueDateTime.date()) + 1; 
            card.boardType = valueStream.leankor__BoardType__c;
            card.isUpdateValueStreamCardLink = true;
            card.valueStreamLink = linkValueStream.Id;
            card.valueStreamCardLink = cardToLink.Id;
            cardsToCheck.add(card);

            KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

            System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Must Start On');

        }

        Test.stopTest();

    }

    // For checking dependencies - not ready yet, don't edit or uncomment until Dependencies are available for checking constraint violations
    // @isTest
    // private static void testGetConstraintViolationWithDependencies() {
    //     leankor__ValueStream__c valueStream = [Select Id,
    //                                                 Name,
    //                                                 leankor__BoardType__c
    //                                             From leankor__ValueStream__c
    //                                             Where Name = 'Constraint board'
    //                                             Limit 1];

    //     List<leankor__ProjectScheduleBlackout__c> blackOut = [Select Id,
    //                                                             Name,
    //                                                             leankor__ProjectBoard__c,
    //                                                             leankor__StartDate__c,
    //                                                             leankor__EndDate__c
    //                                                         From leankor__ProjectScheduleBlackout__c
    //                                                         Where leankor__ProjectBoard__c = :valueStream.Id
    //                                                         Limit 1];

    //     leankor__LeanConstants__c constraintSetting = [Select Id,
    //                                                         leankor__AllowSchedulingConstraints__c
    //                                                 From leankor__LeanConstants__c
    //                                                 Limit 1];

    //     Util.WorkWeek workWeek = new Util.Workweek(5, blackOut);

    //     constraintSetting.leankor__AllowSchedulingConstraints__c = true;
    //     // constraintSetting.leankor__DisableAutoTranslationOfActivity__c = false;
    //     update constraintSetting;

    //     List<leankor__KanbanCard__c> cardsToLink = [Select Id,
    //                                                 Name,
    //                                                 leankor__StartDateTime__c,
    //                                                 leankor__DueDateTime__c,
    //                                                 leankor__EstimatedDuration__c,
    //                                                 leankor__ValueStream__c,
    //                                                 leankor__ValueStream__r.leankor__BoardType__c,
    //                                                 RecordType.Name
    //                                             From leankor__KanbanCard__c
    //                                             Where leankor__ValueStream__c = :valueStream.Id
    //                                             And RecordType.Name = 'ActivityCard'
    //                                             Limit 2];  

    //     leankor__Dependency__c dependency = new leankor__Dependency__c();
    //     dependency.leankor__Predecessor__c = cardsToLink[0].Id;
    //     dependency.leankor__PredecessorType__c = 'Start To Start';
    //     dependency.leankor__Successor__c = cardsToLink[1].Id;
    //     dependency.leankor__SuccessorType__c = 'Finish To Start';
    //     dependency.leankor__ValueStream__c = valueStream.Id;
    //     insert dependency;
        
    //     leankor__ScheduleConstraint__c startNoEarlierThan = new leankor__ScheduleConstraint__c();
    //     startNoEarlierThan.leankor__Description__c = 'startnoearlierthan';
    //     startNoEarlierThan.leankor__Type__c = 'startnoearlierthan';
    //     insert startNoEarlierThan;

    //     List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();
    //     for(Integer i = 0; i < cardsToLink.size(); i++) {
    //         leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
    //         schedMode.leankor__KanbanCard__c = cardsToLink[i].Id;
    //         if(Math.mod(i, 2) != 0) {
    //             schedMode.leankor__ConstraintDateTime__c = cardsToLink[i].leankor__StartDateTime__c;
    //             schedMode.leankor__ScheduleConstraint__c = startNoEarlierThan.Id;
    //         }
    //         schedModes.add(schedMode);
    //     }
    //     insert schedModes;
          
    //     List<KanbanCard> cardsToCheck = new List<KanbanCard>();
    //     Boolean checkDepConstraint = false;

    //     KanbanCard card = new KanbanCard();
    //     card.id = cardsToLink[0].Id;
    //     card.valueStream = valueStream.Id;
    //     card.startDateTime = cardsToLink[0].leankor__StartDateTime__c.addDays(-2);
    //     card.dueDateTime = cardsToLink[0].leankor__DueDateTime__c.addDays(-2);
    //     card.estimatedDuration = cardsToLink[0].leankor__EstimatedDuration__c; 
    //     card.boardType = valueStream.leankor__BoardType__c;
    //     card.isUpdateValueStreamCardLink = false;
    //     card.valueStreamLink = null;
    //     card.valueStreamCardLink = null;
    //     cardsToCheck.add(card);

    //     Test.startTest();

    //     KanbanController.KanbanCardConstraintViolation constraintsViolated = KanbanController.getConstraintViolation(cardsToCheck, checkDepConstraint);

    //     System.assertEquals(false, constraintsViolated.isEmpty(), 'There should have been a constraint violation for Start No Earlier Than');

    //     Test.stopTest();

    // }

	 @isTest
    private static void readProjectBoardPointsTestFirst(){
        List<leankor__ProjectRoom__c> projectList =[Select Id From leankor__ProjectRoom__c Where Name =:'Test Project'];
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Constraint kanban';
		valueStream.leankor__ProjectRoom__c = projectList[0].id;
		valueStream.leankor__BoardType__c = 'Kanban Board';
        valueStream.leankor__SprintStartDate__c = DateTime.newInstance(2022, 08, 01, 0, 0, 0); 
        valueStream.leankor__DaysPerSprint__c = 3;
        valueStream.leankor__IsAgile__c = true;
        valueStream.leankor__SevenDayWorkWeek__c = false;
		insert valueStream;
        
        leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
        masterContainer1.Name= 'Test-MasterContainer';
        masterContainer1.leankor__ValueStream__c = valueStream.Id;
        masterContainer1.leankor__order__c =0.0;
        masterContainer1.leankor__Type__c ='Backlog';
        
       leankor__KanbanCard__c card1 = new leankor__Kanbancard__c ();
       card1.Name = 'Card1';
       card1.leankor__valuestream__c = valueStream.Id;
        card1.leankor__MasterContainer__c = masterContainer1.Id;
       card1.leankor__PercentComplete2__c = 50;
       card1.leankor__Point__c = 4; 
       card1.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        insert card1;
        Test.startTest();
        KanbanController.SprintDetail sprintDetail = KanbanController.readProjectBoardPoints(valueStream.Id);
        System.assert(sprintDetail != null);
        DateTime sprintdateTime = sprintDetail.sprintEndDate;
        Date sprintdate = date.newinstance(sprintdateTime.year(), sprintdateTime.month(), sprintdateTime.day());
        System.assertEquals(Date.newInstance(2022, 08, 03), sprintdate);
        Test.stopTest();
    }
    @isTest
    private static void readProjectBoardPointsTestSecond(){
        List<leankor__ProjectRoom__c> projectList =[Select Id From leankor__ProjectRoom__c Where Name =:'Test Project'];
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Constraint kanban';
		valueStream.leankor__ProjectRoom__c = projectList[0].id;
		valueStream.leankor__BoardType__c = 'Kanban Board';
        valueStream.leankor__SprintStartDate__c = System.now();
        valueStream.leankor__DaysPerSprint__c = 2;
        valueStream.leankor__IsAgile__c = false;
        valueStream.leankor__SevenDayWorkWeek__c = false;
		insert valueStream;
        
        Test.startTest();
        KanbanController.SprintDetail sprintDetail = KanbanController.readProjectBoardPoints(valueStream.Id);
       	System.assertEquals( null, sprintDetail.unCompletedPoint);
        System.assertEquals( null, sprintDetail.totalPoint);
        System.assertEquals( null, sprintDetail.sprintEndDate);
        Test.stopTest();
    }

    /* Method tests for cloning cards*/
    @isTest
    private static void clonesysteBoardTest(){

        Test.startTest();
        leankor__ValueStream__c valueStream = getBoard('Valuestream ProjectLaunchDate');
        leankor__ValueStream__c valueStreamWithSevenDays = getBoard('Valuestream SevenDay');
        leankor.KanbanController.CloneBoard cloneBoard = new leankor.KanbanController.CloneBoard();
            cloneBoard.VSID = valueStream.Id;
            cloneBoard.RealVSID = valueStream.Id;
            cloneBoard.KanbanVerb = false;
            cloneBoard.KanbanTemplateVerb = false;
            cloneBoard.StickerVerb = false;
            cloneBoard.TaskVerb = false;
            cloneBoard.ZoneVerb = true;
            cloneBoard.MarkerVerb = false;
            cloneBoard.ChartVerb = false;    
            cloneBoard.oldStartDateTime = System.now();
            cloneBoard.oldEndDateTime = System.now();
            System.Assert(leankor.KanbanController.CloneSystemBoard(cloneBoard) != null);
            
        List<leankor__ProjectRoom__C> projectRoom=[Select Id 
                                                      From leankor__ProjectRoom__C];

        List<leankor__KanbanCard__c> kanbancardList = [Select Id,
                                                              Name,
                                                              OwnerId,
                                                              leankor__EstimatedDuration__c,
                                                              leankor__Title__c,
                                                              leankor__X__c,
                                                              leankor__Y__c 
                                                          From leankor__KanbanCard__c
                                                          Where Name = 'Activity'];   

        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.VSID = valueStream.Id;
        cBoard.RealVSID = valueStream.Id;
        cBoard.KanbanVerb = true;
        cBoard.KanbanTemplateVerb = true;
        cBoard.StickerVerb = false;
        cBoard.TaskVerb = true;
        cBoard.ZoneVerb = true;
        cBoard.MarkerVerb = true;
        cBoard.ChartVerb = true;
        cBoard.FinalDate = JSON.serialize(System.now());
        cBoard.BoardType ='Whiteboard';          
        cBoard.FinalStartDate = JSON.serialize(System.now());  
        cBoard.isprojectclone = true;
        cBoard.projectBoardLaunchDate = JSON.serialize(System.now()); 
        cBoard.oldStartDateTime = System.now();
        cBoard.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);   

        leankor.KanbanController.CloneBoard cBoardSecond = new leankor.KanbanController.CloneBoard();
        cBoardSecond.VSID = valueStreamWithSevenDays.Id;
        cBoardSecond.RealVSID = valueStreamWithSevenDays.Id;
        cBoardSecond.KanbanVerb = true;
        cBoardSecond.KanbanTemplateVerb = true;
        cBoardSecond.StickerVerb = false;
        cBoardSecond.TaskVerb = true;
        cBoardSecond.ZoneVerb = true;
        cBoardSecond.MarkerVerb = true;
        cBoardSecond.ChartVerb = true;
        cBoardSecond.FinalDate = JSON.serialize(System.now());
        cBoardSecond.BoardType ='Whiteboard';          
        cBoardSecond.FinalStartDate = JSON.serialize(System.now());  
        cBoardSecond.isprojectclone = true;
        cBoardSecond.projectBoardLaunchDate = JSON.serialize(System.now()); 
        cBoardSecond.oldStartDateTime = System.now();
        cBoardSecond.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoardSecond)!=null);
        Test.stopTest();
    }

    /* Method tests for cloning cards*/
    @isTest
    private static void clonesysteBoardTestThird(){

        Test.startTest();
        leankor__ValueStream__c valuestreamlistWithoutLaunchDate = getBoard('Plan Board (Test Project)');

        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.VSID = valuestreamlistWithoutLaunchDate.Id;
        cBoard.RealVSID = valuestreamlistWithoutLaunchDate.Id;
        cBoard.KanbanVerb = true;
        cBoard.KanbanTemplateVerb = true;
        cBoard.StickerVerb = false;
        cBoard.TaskVerb = true;
        cBoard.ZoneVerb = true;
        cBoard.MarkerVerb = true;
        cBoard.ChartVerb = true;
        cBoard.FinalDate = JSON.serialize(System.now());
        cBoard.BoardType ='Whiteboard';        
        cBoard.FinalStartDate = JSON.serialize(System.now());  
        cBoard.isprojectclone = true;
        cBoard.oldStartDateTime = System.now();
        cBoard.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);

        leankor.KanbanController.CloneBoard cBoardSecond = new leankor.KanbanController.CloneBoard();
        cBoardSecond.VSID = valuestreamlistWithoutLaunchDate.Id;
        cBoardSecond.RealVSID = valuestreamlistWithoutLaunchDate.Id;
        cBoardSecond.KanbanVerb = true;
        cBoardSecond.KanbanTemplateVerb = true;
        cBoardSecond.StickerVerb = false;
        cBoardSecond.TaskVerb = true;
        cBoardSecond.ZoneVerb = true;
        cBoardSecond.MarkerVerb = true;
        cBoardSecond.ChartVerb = true;
        cBoardSecond.FinalDate = JSON.serialize(System.now());
        cBoardSecond.BoardType ='Whiteboard';           
        cBoardSecond.isprojectclone = true;
        cBoardSecond.oldStartDateTime = System.now();
        cBoardSecond.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoardSecond)!=null);
        Test.StopTest();
    }

    /* Method tests for cloning cards*/
    @isTest
    private static void clonesysteBoardTestFourth(){

        Test.startTest();
        leankor__ValueStream__c valuestreamlistWithLaunchDate = getBoard('Valuestream ProjectLaunchDate');

        leankor.CloneProjectAction.isClonedProject = true;
        leankor.CloneProjectBoardAsyncAction.isClonedBoard = true;
        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.VSID = valuestreamlistWithLaunchDate.Id;
        cBoard.RealVSID = valuestreamlistWithLaunchDate.Id;
        cBoard.KanbanVerb = true;
        cBoard.KanbanTemplateVerb = true;
        cBoard.StickerVerb = false;
        cBoard.TaskVerb = true;
        cBoard.ZoneVerb = true;
        cBoard.MarkerVerb = true;
        cBoard.ChartVerb = true;
        cBoard.FinalDate = JSON.serialize(System.now());
        cBoard.BoardType ='Whiteboard';   
        cBoard.projectBoardLaunchDate = JSON.serialize(System.now());
        cBoard.cloneCustomFields = true; 
        cBoard.oldStartDateTime = System.now();
        cBoard.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);
        Test.stopTest();
    }

     /* Method tests for cloning cards*/
     @isTest
     private static void clonesysteBoardTestEight(){

         Test.startTest();
         leankor__ValueStream__c valuestreamlistWithoutLaunchDate = getBoard('Valuestream Seven Days');
         
         leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
         cBoard.VSID = valuestreamlistWithoutLaunchDate.Id;
         cBoard.RealVSID = valuestreamlistWithoutLaunchDate.Id;
         cBoard.KanbanVerb = true;
         cBoard.KanbanTemplateVerb = true;
         cBoard.StickerVerb = false;
         cBoard.TaskVerb = true;
         cBoard.ZoneVerb = true;
         cBoard.MarkerVerb = true;
         cBoard.ChartVerb = true;
         cBoard.FinalDate = JSON.serialize(System.now());
         cBoard.BoardType ='Whiteboard';        
         cBoard.FinalStartDate = JSON.serialize(System.now().addDays(-2));  
         cBoard.isprojectclone = true;
         cBoard.oldStartDateTime = System.now();
        cBoard.oldEndDateTime = System.now();
         System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);
         Test.stopTest();
     }

     /* Method tests for cloning cards*/
     @isTest
     private static void clonesysteBoardTestNine(){

         Test.startTest();
         leankor__ValueStream__c valuestreamlistWithoutLaunchDate = getBoard('Valuestream Task');

         leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
         cBoard.VSID = valuestreamlistWithoutLaunchDate.Id;
         cBoard.RealVSID = valuestreamlistWithoutLaunchDate.Id;
         cBoard.KanbanVerb = true;
         cBoard.KanbanTemplateVerb = true;
         cBoard.StickerVerb = false;
         cBoard.TaskVerb = true;
         cBoard.ZoneVerb = true;
         cBoard.MarkerVerb = true;
         cBoard.ChartVerb = true;
         cBoard.FinalDate = JSON.serialize(System.now());
         cBoard.BoardType ='Whiteboard';        
         cBoard.FinalStartDate = JSON.serialize(System.now().addDays(-2));  
         cBoard.isprojectclone = false;
         cBoard.projectBoardLaunchDate = JSON.serialize(System.now().addDays(2));
         cBoard.oldStartDateTime = System.now();
         cBoard.oldEndDateTime = System.now();
         System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);
         Test.stopTest();
     }

    /* Method tests for cloning Files*/
    @isTest
    private static void cloneFilesTest(){

        Test.startTest();
        leankor__KanbanCard__C card = [Select Id,
                                              leankor__Guid__c,
                                              leankor__ValueStream__C
                                          From leankor__KanbanCard__C 
                                          Where Name = 'kanbanCard'
                                          Limit 1];

        Map<String,String> mapofCard = new Map<String,String>();
        mapOfcard.put(String.valueOf(card.Id),String.valueOf(card.leankor__ValueStream__C));
        leankor.KanbanController.cloneFiles(String.valueOf(card.leankor__ValueStream__C),mapOfcard);

        List<FeedItem> feeds = [Select Id
                                    From FeedItem
                                    Where parentId =: card.Id];

        System.assert(feeds.size()>0);
        Test.stopTest();
    }

    /* Method tests for cloning Stickers*/
    @isTest
    private static void cloneStickersTest(){

        Test.startTest();
        leankor__ValueStream__c valuestreamWithSticker = getBoard('myValueStream');
        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.RealVSID = valuestreamWithSticker.Id;
        leankor.KanbanController.cloneStickers(cBoard);

        List<leankor__Sticker__C> stickers = [Select Id
                                                From leankor__Sticker__C 
                                                Where leankor__ValueStream__c =: cBoard.RealVSID ];
        System.assert(stickers.size()>0);
        Test.stopTest();
    }

    @isTest 
    private static void changeValueStreamOnHyperJumpTest(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          leankor__ValueStream__c,
                                                          leankor__ValueStreamLink__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'Activity Seven Day'];

        leankor__ValueStream__C valueStreamWithSevenDays = [Select Id
                                                                From leankor__ValueStream__C
                                                                Where Name = 'Valuestream SevenDay'];

        leankor.KanbanController.changeValueStreamOnHyperJump(kanbanList ,valueStreamWithSevenDays.Id);

        List<leankor__KanbanCard__C> kanbanCardList = [Select Id,
                                                              leankor__ValueStream__c,
                                                              leankor__ValueStreamLink__c
                                                         From leankor__KanbanCard__C
                                                         Where Id In : kanbanList];
        System.assert(kanbanCardList.size()>0);
        Test.stopTest();
    }

    @isTest
    private static void hyperjumpToBoardTest(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'new card'
                                            Limit 1];

        leankor__ValueStream__C valueStreamWithSevenDays = [Select Id
                                                                From leankor__ValueStream__C
                                                                Where Name = 'Valuestream SevenDay'];

        leankor.kanbanController.Hyperjump hyperJumpCard = new leankor.kanbanController.Hyperjump();
        hyperJumpCard.oldVSID = valueStreamWithSevenDays.ID;
        hyperJumpCard.newVSID = valueStreamWithSevenDays.ID;

        String JSONdataforDurationMonths =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Months","EstimatedDuration":4}'); 
        System.Assert(leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationMonths) != 'Failed');
       
        String JSONdataforDurationMinutes =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Minutes","EstimatedDuration":4}'); 
        System.Assert(leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationMinutes) != 'Failed');

        String JSONdataforDurationHours =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Hours","EstimatedDuration":4}'); 
        System.Assert(leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationHours) != 'Failed');
        String jsonData = leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationHours);

        leankor.RealTimeController.StateChangePackage stateChange = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(jsonData, leankor.RealTimeController.StateChangePackage.class);
        System.assertEquals(stateChange.DurationUnits, 'Hours');
        Test.stopTest();
    }

    /* Method tests for only cloning Knabancard*/
    @isTest
    private static void clonekanbanCardTest(){

        Test.startTest();
        leankor__LeanConstants__c customSetting = [Select Id,
                                                          leankor__AllowSchedulingConstraints__c
                                                      From leankor__LeanConstants__c
                                                      Limit 1];

        customSetting.leankor__AllowSchedulingConstraints__c = true;
        update customSetting;

        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'new card'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Minutes';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();       
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID) != Null);
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardTestSeventh(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'new card'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Years';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();       
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID) != Null);
        Test.stopTest();

    }

    @isTest
    private static void clonekanbanCardTestEighth(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Five day working'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Months';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();       
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID) != Null);
        Test.stopTest();

    }

    /* Method tests for cloning kanbancards*/
    @isTest
    private static void clonekanbanCardForFivedayTest(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Five day working'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Years';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();
        leankor.RealTimeController.Kanban kanbanobject = new leankor.RealTimeController.Kanban();   
        kanbanobject.id = '';
        String WithoutId = JSON.serialize(kanbanobject);    
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID) != Null);
        System.AssertEquals('failure',leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,WithoutId,mySessionID));
        Test.stopTest();
    }

    /* Method tests for cloning cards in Mastercontainer*/
    @isTest
    private static void allMCCardsHyperJumpTest(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'Five day working'];

        leankor__KanbanCardTemplate__C kanbanTemplate = [Select Id
                                                            From leankor__KanbanCardTemplate__C
                                                            Where Name = 'RED Card'
                                                            Limit 1];
        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                 From leankor__ProjectRoom__C
                                                 Where Name = 'Test project'
                                                 Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.DefaultCardtemplateID = kanbanTemplate.id;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.IsClone = false;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    /* Method tests for cloning cards in Mastercontainer*/
    @isTest
    private static void allMCCardsHyperJumpTestTwo(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'card Task'];

        List<leankor__KanbanCard__C> kanbanLists = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                       From leankor__KanbanCard__C
                                                       Where Name = 'Five day working'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        leankor__KanbanCardTemplate__C kanbanTemplate = [Select Id
                                                            From leankor__KanbanCardTemplate__C
                                                            Where Name = 'RED Card1'
                                                            Limit 1];

        List<String> KanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            KanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                   From leankor__ProjectRoom__C
                                                   Where Name = 'Test project'
                                                   Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.DefaultCardtemplateID = kanbanTemplate.id;
        hyperjump.CardIDs = KanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.IsClone = false;
        hyperjump.ColumnID = zone.Id;
        hyperjump.LinkCardID = kanbanLists[0].Id;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    /* Method tests for cloning cards in Mastercontainer*/
    @isTest
    private static void allMCCardsHyperJumpTestThird(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'card Task'];

        List<leankor__KanbanCard__C> kanbanLists = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                      From leankor__KanbanCard__C
                                                      Where Name = 'Five day working'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        leankor__KanbanCardTemplate__C kanbanTemplate = [Select Id
                                                            From leankor__KanbanCardTemplate__C
                                                            Where Name = 'RED Card1'
                                                            Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanLists){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                  From leankor__ProjectRoom__C
                                                  Where Name = 'Test project'
                                                  Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.DefaultCardtemplateID = kanbanTemplate.id;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = false;
        hyperjump.ColumnID = zone.Id;
        hyperjump.LinkCardID = kanbanLists[0].Id;
        hyperjump.Isclone = true;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }


    /* Method tests for cloning cards in Mastercontainer*/
    @isTest
    private static void allMCCardsHyperJumpTestFourth(){

        Test.startTest();
        leankor__LeanConstants__c customSetting = [Select Id,
                                                          leankor__AllowSchedulingConstraints__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];
                                                        
        customSetting.leankor__AllowSchedulingConstraints__c = true;
        update customSetting;

        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task 1'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = true;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    
    /* Method tests for cloning cards in Mastercontainer*/
    @isTest
    private static void allMCCardsHyperJumpTestFifth(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                      From leankor__KanbanCard__C
                                                      Where Name = 'card Task 2'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = true;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestSix(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task Second'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = true;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestSeven(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task three'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }

        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = true;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestEight(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task Four'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestNine(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task Five'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestTen(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task seven'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.IsClone = true;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTestEleven(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'card Task Second'];
        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = false;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    @isTest
    private static void allMCCardsHyperJumpTesttwelve(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'card Task three'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = false;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();

    }

    @isTest
    private static void allMCCardsHyperJumpTestthirteen(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'card Task Four'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }

        leankor__ProjectRoom__c projectRoom = [Select Id
                                                   From leankor__ProjectRoom__C
                                                   Where Name = 'Test project'
                                                   Limit 1];

        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = false;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();

    }

    @isTest
    private static void allMCCardsHyperJumpTestFourteen(){

        Test.startTest();
        List<leankor__KanbanCard__C> kanbanList = [Select Id,
                                                          Name,
                                                          leankor__GUID__c,
                                                          leankor__StartDateTime__c,
                                                          leankor__DueDateTime__c,
                                                          leankor__ValueStream__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'card Task Eight'];

        leankor__Zone__C zone = [Select Id
                                    From leankor__Zone__C
                                    Where Name = 'kanban test3'
                                    Limit 1];

        List<String> kanbanIds = new List<String>();
        for(leankor__KanbanCard__C kanban : kanbanList){
            kanbanIds.add(kanban.Id);
        }
        leankor__ProjectRoom__c projectRoom = [Select Id
                                                    From leankor__ProjectRoom__C
                                                    Where Name = 'Test project'
                                                    Limit 1];
                                                    
        leankor.kanbanController.MCHyperJumpLog hyperjump = new leankor.kanbanController.MCHyperJumpLog();
        hyperjump.TargetVSID = kanbanList[0].leankor__ValueStream__c;
        hyperjump.CardIDs = kanbanIds;
        hyperjump.LinkVSID ='';
        hyperjump.LinkCardID ='';
        hyperjump.projectId = projectRoom.Id;
        hyperjump.sendBroadcastMessage = true;
        hyperjump.ColumnID = zone.Id;
        hyperjump.Isclone = false;
        System.assert(leankor.KanbanController.allMCCardsHyperJump(hyperjump) != null);
        Test.stopTest();
    }

    /* Method tests for create or update  Multiple filter records*/
    @isTest
    private static void setMultipleFilterRecordsTest(){

        Test.startTest();
        leankor__Portfolio__c folder = [Select Id
                                            From leankor__Portfolio__c
                                            Where Name = 'Test Folder-1'];

        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream SevenDay'];

        List<KanbanController.CreateFilter> restultLogs = new List<KanbanController.CreateFilter>();
        KanbanController.CreateFilter fliterObjLog = new KanbanController.CreateFilter();
        fliterObjLog.CategoryName = 'Category';
        fliterObjLog.OwnerName = UserInfo.getusername();
        fliterObjLog.PortfolioLinkCards = folder.Id;
        fliterObjLog.ValueStream = valueStream.Id;
        fliterObjLog.FilterName = 'Filter';
        fliterObjLog.User = UserInfo.getUserId();
        fliterObjLog.PriorityName = 'low';
        fliterObjLog.StickerName = 'Sticker';
        fliterObjLog.IsFilterON = true;
        fliterObjLog.IsDefaultFilter = true;
        fliterObjLog.BoardURL = '';
        fliterObjLog.MiniatureName = 'Miniature';
        fliterObjLog.PercentCompleteRange = '50';
        fliterObjLog.IsFilterON = true;
        fliterObjLog.isFilterONUpdate = false;
        restultLogs.add(fliterObjLog);
        List<KanbanController.CreateFilter> filterlogs = leankor.KanbanController.setMultipleFilterRecords(restultLogs);
        System.assert(filterlogs.size()>0);
        System.assertEquals(filterlogs[0].valuestream,restultLogs[0].valuestream);
        Test.stopTest();

    }

    @isTest
    private static void setMultipleFilterRecordsTestTwo(){

        Test.startTest();
        leankor__Portfolio__c folder = [Select Id
                                            From leankor__Portfolio__c
                                            Where Name = 'Test Folder-1'];

        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream SevenDay'];

        leankor__Filter__c filter = [Select Id
                                        From leankor__Filter__c
                                        Where Name = 'filter'
                                        Limit 1];

        List<KanbanController.CreateFilter> restultLogs = new List<KanbanController.CreateFilter>();
        KanbanController.CreateFilter fliterObjLog = new KanbanController.CreateFilter();
        fliterObjLog.Id = filter.Id;
        fliterObjLog.IsFilterON = true;
        fliterObjLog.ValueStream = valueStream.Id;
        fliterObjLog.isFilterONUpdate = true;
        restultLogs.add(fliterObjLog);
        List<KanbanController.CreateFilter> filterlogs = leankor.KanbanController.setMultipleFilterRecords(restultLogs);
        System.assert(filterlogs.size()>0);
        System.assertEquals(filterlogs[0].valuestream,restultLogs[0].valuestream);
        Test.stopTest();

    }

    
    @isTest
    private static void setMultipleFilterRecordsTestThird(){

        Test.startTest();
        leankor__Portfolio__c folder = [Select Id
                                            From leankor__Portfolio__c
                                            Where Name = 'Test Folder-1'];

        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream SevenDay'];

        leankor__Filter__c filter = [Select Id
                                        From leankor__Filter__c
                                        Where Name = 'filter'
                                        Limit 1];

        List<KanbanController.CreateFilter> restultLogs = new List<KanbanController.CreateFilter>();
        KanbanController.CreateFilter fliterObjLog = new KanbanController.CreateFilter();
        fliterObjLog.Id = filter.Id;
        fliterObjLog.CategoryName = 'Category';
        fliterObjLog.OwnerName = UserInfo.getusername();
        fliterObjLog.PortfolioLinkCards = folder.Id;
        fliterObjLog.ValueStream = valueStream.Id;
        fliterObjLog.FilterName = 'Filter';
        fliterObjLog.User = UserInfo.getUserId();
        fliterObjLog.PriorityName = 'low';
        fliterObjLog.StickerName = 'Sticker';
        fliterObjLog.IsDefaultFilter = true;
        fliterObjLog.BoardURL = '';
        fliterObjLog.MiniatureName = 'Miniature';
        fliterObjLog.PercentCompleteRange = '50';
        fliterObjLog.IsFilterON = true;
        fliterObjLog.isFilterONUpdate = false;
        restultLogs.add(fliterObjLog);
        List<KanbanController.CreateFilter> filterlogs = leankor.KanbanController.setMultipleFilterRecords(restultLogs);
        System.assert(filterlogs.size()>0);
        System.assertEquals(filterlogs[0].valuestream,restultLogs[0].valuestream);
        Test.stopTest();

    }

    /* Method tests for create or update  Multiple filter records*/
    @isTest
    private static void setFilterFeatureDataTest(){

        Test.startTest();
        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream SevenDay'];
        leankor__Filter__c filter = [Select Id
                                        From leankor__Filter__c
                                        Where Name = 'filter'
                                        Limit 1];

        List<KanbanController.CreateFilter> resultLogs = new List<KanbanController.CreateFilter>();
        KanbanController.CreateFilter fliterObjLog = new KanbanController.CreateFilter();
        fliterObjLog.ValueStream = valueStream.Id;
        fliterObjLog.BoardURL = '';
        fliterObjLog.FeatureData = 'Feature';
        fliterObjLog.User = UserInfo.getUserId();
        fliterObjLog.ID = filter.id;
        resultLogs.add(fliterObjLog);
        List<KanbanController.CreateFilter> filterLogs = leankor.KanbanController.setFilterFeatureData(resultLogs);
        System.assert(filterLogs.size()>0);
        System.assertEquals(filterLogs[0].valuestream,valuestream.Id);
        Test.stopTest();

    }

    /* Method tests for create or update  Multiple filter records*/
    @isTest
    private static void setFilterFeatureDataTestTwo(){

        Test.startTest();
        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream SevenDay'];

        List<KanbanController.CreateFilter> resultLogs = new List<KanbanController.CreateFilter>();
        KanbanController.CreateFilter fliterObjLog = new KanbanController.CreateFilter();
        fliterObjLog.ValueStream = valueStream.Id;
        fliterObjLog.BoardURL = '';
        fliterObjLog.FeatureData = 'Feature';
        fliterObjLog.User = UserInfo.getUserId();
        resultLogs.add(fliterObjLog);
        List<KanbanController.CreateFilter> filterLogs = leankor.KanbanController.setFilterFeatureData(resultLogs);
        System.assert(filterLogs.size()>0);
        System.assertEquals(filterLogs[0].valuestream,valuestream.Id);
        Test.stopTest();

    }  

    @isTest
    private static void getAssociatedFilesTest(){

        Test.startTest();
        KanbanController.FileInputWrapper fileInput = new KanbanController.FileInputWrapper();

        List<leankor__ValueStream__c> valuestreamList = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Valuestream ProjectLaunchDate'];

        List<Id> ids = new List<Id>();
        for(leankor__ValueStream__c valuestream :valuestreamList){
            ids.add(valuestream.Id);
        }
        fileInput.publishLocationIds = ids;
        fileInput.filePublishLocation = 'ValueStream';
        System.assert(leankor.KanbanController.getAssociatedFiles(fileInput) != null);
        Test.stopTest();
    }

    @isTest
    private static void getServiceAppointmentRecordsTest(){

        Test.startTest();
        List<leankor__KanbanCard__C> cardList = [Select Id,
                                                        Name
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'Five day working'];
        
        List<String> cardIds = new List<String>();
        for(leankor__KanbanCard__C cardId : cardList){
            cardIds.add(cardId.Id);
        }
        //List<KanbanController.FieldServiceLigtning>  fieldsSevice  = KanbanController.getServiceAppointmentRecords(cardIds);
        //System.assert(fieldsSevice.size()==0);
        Test.stopTest();
    }

    /*@isTest
    private static void getBoardRemoteConfigTest(){

        Test.startTest();
        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream ProjectLaunchDate'];

        KanbanController.BoardOnLoadConfig boardConfig = new KanbanController.BoardOnLoadConfig();
        boardConfig.boardName = 'KnabanBoard';
        boardConfig.valueStreamId = valueStream.Id;
        KanbanController.BoardOnLoadConfig config = KanbanController.getBoardRemoteConfig(boardConfig);
        System.assert(config.kanbanCardTemplates.size()>0);
        Test.stopTest();
    }*/
    @isTest
	static void getBoardRemoteConfigTest() {
        Test.startTest();
    
            // Step 1: Create required ValueStream
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'test valueStream';
            insert valueStream;
        
            // Step 2: Create related KanbanCard
            leankor__KanbanCard__c card = new leankor__KanbanCard__c();
            card.Name = 'Test Kanban';
            card.leankor__ValueStream__c = valueStream.Id;
            card.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            card.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            insert card;
        
            // Step 3: Insert child ScheduleMode to prevent index error
            leankor__ScheduleMode__c sched = new leankor__ScheduleMode__c();
            sched.leankor__KanbanCard__c = card.Id;
            sched.leankor__Mode__c = 'normal';
            sched.leankor__ManuallyScheduled__c = true;
            insert sched;
        
            // Step 4: Create board config and call tested method
            KanbanController.BoardOnLoadConfig boardConfig = new KanbanController.BoardOnLoadConfig();
            boardConfig.boardName = 'KnabanBoard';
            boardConfig.valueStreamId = valueStream.Id;
        
            // Call method and assert
            KanbanController.BoardOnLoadConfig config = KanbanController.getBoardRemoteConfig(boardConfig);
            System.assert(config.kanbanCardTemplates != null,'Assertion failed : Kanban card templates should not be null');
        Test.stopTest();
	}
    @isTest
    private static void getBoardRemoteConfigTestTwo(){

        Test.startTest();
        leankor__LeanConstants__c customSetting = [Select Id,
                                                          leankor__AllowSchedulingConstraints__c
                                                      From leankor__LeanConstants__c
                                                      Limit 1];

        customSetting.leankor__AllowSchedulingConstraints__c = true;
        update customSetting;

        leankor__ValueStream__C valueStream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'Valuestream ProjectLaunchDate constarint'];

        KanbanController.BoardOnLoadConfig boardConfig = new KanbanController.BoardOnLoadConfig();
        boardConfig.boardName = 'KnabanBoard';
        boardConfig.valueStreamId = valueStream.Id;
        KanbanController.BoardOnLoadConfig config = KanbanController.getBoardRemoteConfig(boardConfig);
        System.assertEquals(config.boardName, null);
        Test.stopTest();
    }

    /* Method tests for getzoneRecords related kanbancard*/
    @isTest
    private static void getZoneKanbanCardsTest(){

        Test.startTest();
        List<leankor__Zone__C> zonelist = [Select Id,
                                                  leankor__GUID__C
                                             From leankor__Zone__C
                                             Where Name = 'kanban test3'];

        List<String> ids = new List<String>();
        for(leankor__Zone__C zoneId : zonelist){
            ids.add(zoneId.Id);
        }
        Map<String, leankor__KanbanCard__c> cards = KanbanController.getZoneKanbanCards(ids);
        System.assert(cards.values().size()>0);
        System.assertEquals(true,cards.containskey(zonelist[0].leankor__GUID__C));
        Test.stopTest();
    }

    @isTest
    private static void getBoardRemoteConfigForCalendarViewTest(){

        Test.startTest();
        leankor__ValueStream__C valueStream = [Select Id
                                                  From leankor__ValueStream__C
                                                  Where Name = 'Valuestream ProjectLaunchDate'];

        KanbanController.BoardOnLoadConfig boardConfig = new KanbanController.BoardOnLoadConfig();
        boardConfig.boardName = 'KnabanBoard';
        boardConfig.valueStreamId = valueStream.Id;
        KanbanController.BoardOnLoadConfig config = KanbanController.getBoardRemoteConfigForCalendarView(boardConfig);
        System.assert(config.kanbanCardTemplates.size()>0);
        Test.stopTest();
    }

    /* Method tests for geeting kanbancards*/
    @isTest
    private static void readKanbanCardBulkRecordTest(){

        Test.startTest();
        List<leankor__ValueStream__C> valueStreamList = [Select Id
                                                             From leankor__ValueStream__C
                                                             Where Name = 'Valuestream SevenDay'];

        List<leankor__KanbanCard__C> cardList = [Select Id,
                                                        Name
                                                    From leankor__KanbanCard__C
                                                    Where Name = 'Activity Seven Day']; 

        leankor__ValueStream__C valuestream = [Select Id
                                                    From leankor__ValueStream__C
                                                    Where Name = 'my valuestream'
                                                    Limit 1];

        List<String> valuestreamId = new List<String>();
        valuestreamId.add(valuestream.Id);
        List<String> valuestreamIds = new List<String>();
        valuestreamIds.add(valueStreamList[0].Id);
        List<String> cardIds = new List<String>();
        for(leankor__KanbanCard__C card : cardList){
            cardIds.add(card.Id);
        }
        List <realtimeController.kanban> remotecard = KanbanController.readKanbanCardBulkRecord(valuestreamId,cardIds);
        System.assert(remotecard.size() > 0);
        List <realtimeController.kanban> cards = KanbanController.readKanbanCardBulkRecord(valuestreamIds,cardIds); 
        System.assert(cards.size()>0);
        System.assertEquals(cards[0].valueStream,valueStreamList[0].Id);
        Test.stopTest();
    }

    /* Method tests for geeting Dependence records*/
    @isTest
    private static void getDependentCardIdsTest(){

        Test.startTest();
        List<leankor__Dependency__c> dependencies = [Select Id,
                                                            leankor__Successor__c
                                                        From leankor__Dependency__c];

        Set<Id> ids = KanbanController.getDependentCardIds(dependencies);
        System.assert(ids.size()>0);
        Test.stopTest();
    }

    /* Method tests for geeting next card schedule*/
    @isTest
    private static void getNextKanbanCardScheduleTest(){

        Test.startTest();
        leankor__KanbanCard__C card = [Select Id,
                                              Name
                                          From leankor__KanbanCard__C
                                          Where Name = 'Five day working'
                                          Limit 1];

        KanbanController.DaysBetweenDates betweendays = new KanbanController.DaysBetweenDates();
        betweendays.startDates = 1;
        leankor__Dependency__c dependence = [Select Id,
                                                    leankor__SuccessorType__c
                                                From leankor__Dependency__c
                                                Limit 1];

        List<leankor__Dependency__c> dependenceList = [Select Id,
                                                              leankor__SuccessorType__c
                                                        From leankor__Dependency__c];

        Map<Id, List<leankor__Dependency__c>> mapofdependence = new Map<Id, List<leankor__Dependency__c>>();
        mapofdependence.put(dependence.Id,dependenceList);
        KanbanCard nextKanbanCardSchedule = KanbanController.getNextKanbanCardSchedule(card,betweendays,dependence,mapofdependence);
        System.assertEquals(nextKanbanCardSchedule.Id,card.Id);
        Test.stopTest();
    }

    @isTest
    private static void setKanbanCardLinkDatesTest(){

        Test.startTest();
        Boolean flag = true;
        Map<Date, Integer> mapPutKanbanCardDates = new Map<Date, Integer>();
        Map<Date, Integer> mapGetKanbanCardDates = new Map<Date, Integer>();
        mapGetKanbanCardDates.put(System.Today(),1);
        KanbanController.setKanbanCardLinkDates(mapPutKanbanCardDates, mapGetKanbanCardDates, System.Today());
        System.assertEquals(true , flag);
        Test.stopTest();
    }


    @isTest
    private static void clonesysteBoardTestFifth(){

        Test.startTest();
        leankor__LeanConstants__c constraint = getConstraintSetting();
        leankor__ValueStream__c valueStream = getBoard('Valuestream ProjectLaunchDate');

        leankor.KanbanController.CloneBoard cBoard2 = new leankor.KanbanController.CloneBoard();
        cBoard2.VSID = valueStream.Id;
        cBoard2.RealVSID = valueStream.Id;
        cBoard2.KanbanVerb = true;
        cBoard2.KanbanTemplateVerb = true;
        cBoard2.StickerVerb = false;
        cBoard2.TaskVerb = true;
        cBoard2.ZoneVerb = true;
        cBoard2.MarkerVerb = true;
        cBoard2.ChartVerb = true;
        cBoard2.FinalDate = JSON.serialize(System.now());
        cBoard2.BoardType ='Whiteboard';          
        cBoard2.FinalStartDate = JSON.serialize(System.now());  
        cBoard2.isprojectclone = true;
        cBoard2.projectBoardLaunchDate = JSON.serialize(System.now()); 
        cBoard2.oldStartDateTime = System.now();
        cBoard2.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard2)!=null);
        Test.stopTest();

    }

   
    private static testMethod void cloneSystemBoardTest6(){

        leankor__LeanConstants__c customSetting = [Select Id,
                                                          leankor__AllowSchedulingConstraints__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

        customSetting.leankor__AllowSchedulingConstraints__c = true;
        update customSetting;

        List<leankor__ValueStream__c> valuestream = [Select Id 
                                                        From leankor__ValueStream__c
                                                        Where Name = 'Valuestream ProjectLaunchDate'];

        leankor__ValueStream__c valuestreamWhithoutcard = [Select Id 
                                                               From leankor__ValueStream__c
                                                               Where Name = 'Valuestream Whithout card'
                                                               Limit 1];

        Test.startTest();
        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.VSID = valuestream[0].Id;
        cBoard.RealVSID = valuestream[0].Id;
        cBoard.KanbanVerb = true;
        cBoard.KanbanTemplateVerb = true;
        cBoard.StickerVerb = false;
        cBoard.TaskVerb = true;
        cBoard.ZoneVerb = true;
        cBoard.MarkerVerb = true;
        cBoard.ChartVerb = true;
        cBoard.FinalDate = JSON.serialize(system.now());
        cBoard.BoardType ='Whiteboard';   
        cBoard.oldStartDateTime = System.now();
        cBoard.oldEndDateTime = System.now();         
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard)!=null);    

        leankor.KanbanController.CloneBoard cloneBoard = new leankor.KanbanController.CloneBoard();
        cloneBoard.VSID = valuestreamWhithoutcard.Id;
        cloneBoard.RealVSID = valuestreamWhithoutcard.Id;
        cloneBoard.KanbanVerb = true;
        cloneBoard.KanbanTemplateVerb = true;
        cloneBoard.StickerVerb = false;
        cloneBoard.TaskVerb = true;
        cloneBoard.ZoneVerb = true;
        cloneBoard.MarkerVerb = true;
        cloneBoard.ChartVerb = true;
        cloneBoard.FinalDate = JSON.serialize(System.now());
        cloneBoard.BoardType ='Whiteboard'; 
        cloneBoard.oldStartDateTime = System.now();
        cloneBoard.oldEndDateTime = System.now();           
        System.assert(leankor.KanbanController.CloneSystemBoard(cloneBoard)!=null);  
        Test.stopTest();
    }  
    
    @isTest
    private static void clonesysteBoardTestseven(){

        Test.startTest();
        leankor__LeanConstants__c constraint = getConstraintSetting();
        leankor__ValueStream__c valueStream = getBoard('Valuestream Milestone');

        leankor.KanbanController.CloneBoard cBoard2 = new leankor.KanbanController.CloneBoard();
        cBoard2.VSID = valueStream.Id;
        cBoard2.RealVSID = valueStream.Id;
        cBoard2.KanbanVerb = true;
        cBoard2.KanbanTemplateVerb = true;
        cBoard2.StickerVerb = false;
        cBoard2.TaskVerb = true;
        cBoard2.ZoneVerb = true;
        cBoard2.MarkerVerb = true;
        cBoard2.ChartVerb = true;
        cBoard2.FinalDate = JSON.serialize(System.now());
        cBoard2.BoardType ='Whiteboard';          
        cBoard2.FinalStartDate = JSON.serialize(System.now());  
        cBoard2.isprojectclone = true;
        cBoard2.cloneCustomFields = false;
        cBoard2.cloneFiles = true;
        cBoard2.projectBoardLaunchDate = JSON.serialize(System.now()); 
        cBoard2.oldStartDateTime = System.now();
        cBoard2.oldEndDateTime = System.now();
        System.assert(leankor.KanbanController.CloneSystemBoard(cBoard2)!=null);
        Test.stopTest();
    }

    @isTest
    private static void cloneChartsTest(){

        Test.startTest();
        List<leankor__ValueStream__c> valuestreamWhithoutcard = [Select Id 
                                                                    From leankor__ValueStream__c
                                                                    Where Name = 'Valuestream Whithout card'
                                                                    Limit 1];
        
        leankor.KanbanController.CloneBoard cloneBoard = new leankor.KanbanController.CloneBoard();
        cloneBoard.VSID = valuestreamWhithoutcard[0].Id;
        cloneBoard.BoardType = 'DashBoard';
        leankor.KanbanController.cloneCharts(cloneBoard,valuestreamWhithoutcard);

        List<leankor__Chart__C> charts = [Select Id,
                                                 Name
                                            From leankor__Chart__C
                                            where leankor__ValueStream__C =: valuestreamWhithoutcard[0].Id];

        System.assertEquals('tets', charts[0].Name);
        Test.stopTest();
    }

    @isTest
    private static void createcardlogTest(){

        Test.startTest();
        leankor__KanbanCard__C card = [Select Id,
                                              Name
                                            From leankor__KanbanCard__C
                                            Where Name = 'Five day working'
                                            Limit 1];

        leankor.KanbanController.CardLogTime cardlogs = new leankor.KanbanController.CardLogTime();
        cardlogs.LogTime = String.valueof(Date.newInstance(2023, 1, 1));
        cardlogs.Description = 'This is first log time';
        cardlogs.Duration = 'Days';
        cardlogs.Estimation = 1.0;
        cardlogs.Subject = 'Test Task';
        cardlogs.TaskID = 'TASK123';
        cardlogs.Hours = 8.0;
        cardlogs.KanbanCardID = card.Id;
        cardlogs.AssignedTo = UserInfo.getUserId();
        cardlogs.AssignedAUser = UserInfo.getUserId();
        leankor__TimeCard__c timeCard = leankor.KanbanController.createCardLog(cardlogs);

        leankor__TimeCard__c timeCrd = [Select Id,
                                               leankor__Hours__c
                                            From leankor__TimeCard__c
                                            Where Id =: timeCard.Id];

        System.assertEquals(timeCrd.leankor__Hours__c,8.0);
        List<leankor.KanbanController.CardLogTime> tCards = leankor.KanbanController.getCardLogs(timeCard.leankor__KanbanCard__c);
        System.assert(tCards.Size() > 0);
        Test.stopTest();
    }

    @isTest
    private static void updatecardlogTest(){

        Test.startTest();
        User userIsactive = [Select Id,
                                    IsActive 
                                From User 
                                Where Alias = 'Lean123' ];

        userIsactive.IsActive = false;
        update userIsactive;

        leankor__KanbanCard__C card = [Select Id,
                                              Name
                                            From leankor__KanbanCard__C
                                            Where Name = 'Five day working'
                                            Limit 1];

        leankor__TimeCard__c timeCard = [Select Id
                                            From leankor__TimeCard__c
                                            Where leankor__KanbanCard__C =: card.Id
                                            Limit 1];

        leankor.KanbanController.CardLogTime cardlogs = new leankor.KanbanController.CardLogTime();
        cardlogs.LogTime = String.valueof(Date.newInstance(2023, 1, 1));
        cardlogs.Description = 'This is first log time';
        cardlogs.Duration = 'Days';
        cardlogs.Estimation = 1.0;
        cardlogs.Subject = 'Test Task';
        cardlogs.TaskID = 'TASK123';
        cardlogs.Hours = 8.0;
        cardlogs.KanbanCardID = card.Id;
        cardlogs.AssignedTo = userIsactive.Id;
        cardlogs.AssignedAUser = userIsactive.Id;
        cardlogs.Id = timeCard.Id;
        System.assertEquals('Failed',leankor.KanbanController.updateCardLogs(cardlogs));
        Test.stopTest();
    }

    @isTest
    private static void getIssueLogsTest(){

        Test.startTest();
        leankor__KanbanCard__C card = [Select Id,
                                              Name
                                            From leankor__KanbanCard__C
                                            Where Name = 'Five day working'
                                            Limit 1];

        leankor.KanbanController.IssueLogs cardlogs = new leankor.KanbanController.IssueLogs();
        cardlogs.Subject = 'Test Task';
        cardlogs.Detail = 'This is first log time';
        cardlogs.KanbanCardID = card.Id;
        cardlogs.LogTime = String.ValueOf(System.now());
        cardlogs.Probability = 'Likely';
        cardlogs.StatusType = 'Risk';
        cardlogs.TaskID =  'TASK12343';
        cardlogs.Weight = 'Important';
        cardlogs.Resolved = false;
        cardlogs.Score = 10;
        cardlogs.AssignedTo = UserInfo.getUserId();
        cardlogs.TaskDueDate = '';
        leankor.KanbanController.IssueLogs timeCard = leankor.KanbanController.createIssueLogs(cardlogs);
        List<leankor.KanbanController.IssueLogs> timeCards = leankor.KanbanController.getIssueLogs(timeCard.KanbanCardID);
        System.assertEquals(timeCards[0].Resolved, false);
        Test.stopTest();
    }

    @isTest
    private static void hyperjumpToBoardTestTwo(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'card Task'
                                            Limit 1];

        leankor__ValueStream__C valueStreamWithSevenDays = [Select Id
                                                                From leankor__ValueStream__C
                                                                Where Name = 'Valuestream Task'];

        leankor.kanbanController.Hyperjump hyperJumpCard = new leankor.kanbanController.Hyperjump();
        hyperJumpCard.oldVSID = valueStreamWithSevenDays.ID;
        hyperJumpCard.newVSID = valueStreamWithSevenDays.ID;
        String JSONdataforDurationHours =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Hours","EstimatedDuration":8}'); 
        String jsonData = leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationHours);
        leankor.RealTimeController.StateChangePackage stateChange = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(jsonData, leankor.RealTimeController.StateChangePackage.class);
        System.assertEquals(stateChange.DurationUnits, 'Hours');
        Test.stopTest();
    }

    @isTest
    private static void hyperjumpToBoardTestThird(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'card Task five day'
                                            Limit 1];

        leankor__ValueStream__C valueStreamWithSevenDays = [Select Id
                                                                From leankor__ValueStream__C
                                                                Where Name = 'Valuestream seven day false'];

        leankor.kanbanController.Hyperjump hyperJumpCard = new leankor.kanbanController.Hyperjump();
        hyperJumpCard.oldVSID = valueStreamWithSevenDays.ID;
        hyperJumpCard.newVSID = valueStreamWithSevenDays.ID;
        String JSONdataforDurationHours =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Minutes","EstimatedDuration":60}'); 
        String jsonData = leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationHours);
        leankor.RealTimeController.StateChangePackage stateChange = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(jsonData, leankor.RealTimeController.StateChangePackage.class);
        System.assertEquals(stateChange.DurationUnits, 'Minutes');

        String JSONdataforDurationMinutes =('{"Id":"'+ kanban.ID+'","Name":"'+kanban.Name+'","GUID":"'+kanban.leankor__GUID__c+'","StartDate":'+ JSON.serialize(kanban.leankor__StartDateTime__c)+',"DueDate":'+ JSON.serialize(kanban.leankor__DueDateTime__c)+',"DurationUnits":"Minutes","EstimatedDuration":427}'); 
        String jsonDatas = leankor.KanbanController.HyperjumpToBoard(hyperJumpCard,JSONdataforDurationMinutes);
        leankor.RealTimeController.StateChangePackage stateChanges = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(jsonDatas, leankor.RealTimeController.StateChangePackage.class);
        System.assertEquals(stateChanges.DurationUnits, 'Minutes');
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardTestTwo(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'new card'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(DateTime.newInstance(2022, 03, 7, 3, 3, 3));
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 427;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Minutes';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();   
        String jsonData = leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID);
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(jsonData, leankor.RealTimeController.Kanban.class);
        System.AssertEquals(remoteKanban.DurationUnits,'Minutes');
        kanbanobj.EstimatedDuration = 60;
        String someJSONDatas = JSON.serialize(kanbanobj);
        String jsonDatas = leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONDatas,mySessionID);
        leankor.RealTimeController.Kanban remoteKanbans = (leankor.RealTimeController.Kanban)JSON.deserialize(jsonDatas, leankor.RealTimeController.Kanban.class);
        System.AssertEquals(remoteKanbans.DurationUnits,'Minutes');
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardTestThird(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Task five day'];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(DateTime.newInstance(2022, 03, 7, 3, 3, 3));
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 8;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Hours';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();   
        String jsonData = leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID);
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(jsonData, leankor.RealTimeController.Kanban.class);
        System.AssertEquals(remoteKanban.DurationUnits,'Hours');
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardTestFourth(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Task five day'];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(DateTime.newInstance(2022, 03, 7, 3, 3, 3));
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 8;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Weeks';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();   
        String jsonData = leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID);
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(jsonData, leankor.RealTimeController.Kanban.class);
        System.AssertEquals(remoteKanban.DurationUnits,'Weeks');
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardForFifth(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Task five day'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Months';
        String mySessionID = userinfo.getSessionId();  
        String someJSONDataForMonths = JSON.serialize(kanbanobj);
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONDataForMonths,mySessionID) != Null);
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardForsixth(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Activity Seven Day'
                                            Limit 1];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 10;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Years';
        String someJSONDataForyears = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId(); 
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONDataForyears,mySessionID) != Null);
        kanbanobj.DurationUnits = 'Weeks';
        String someJSONDataForWeeks = JSON.serialize(kanbanobj);
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONDataForWeeks,mySessionID) != Null);
        kanbanobj.DurationUnits = 'Months';
        String someJSONDataForMonths = JSON.serialize(kanbanobj);
        System.Assert(leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONDataForMonths,mySessionID) != Null);
        Test.stopTest();
    }

    @isTest
    private static void clonekanbanCardTestnine(){

        Test.startTest();
        leankor__KanbanCard__C kanban = [Select Id,
                                                Name,
                                                leankor__GUID__c,
                                                leankor__StartDateTime__c,
                                                leankor__DueDateTime__c,
                                                leankor__ValueStream__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Task five day next'];

        String VSID = String.ValueOf(kanban.leankor__ValueStream__c);
        String testFinalDate = JSON.Serialize(DateTime.newInstance(2022, 03, 7, 3, 3, 3));
        Boolean testTaskVerb = true;
        leankor.RealTimeController.Kanban kanbanobj = new leankor.RealTimeController.Kanban();
        kanbanobj.StartDate = kanban.leankor__StartDateTime__c;
        kanbanobj.Id = kanban.ID;
        kanbanobj.GUID = kanban.leankor__GUID__C;
        kanbanobj.Name = kanban.Name;
        kanbanobj.ValueStream = kanban.leankor__ValueStream__c;
        kanbanobj.DueDate = kanban.leankor__DueDateTime__c;
        kanbanobj.EstimatedDuration = 8;
        kanbanobj.Width = 150;
        kanbanobj.Left = 420;
        kanbanobj.HarveyBall = String.valueOf(50);
        kanbanobj.OwnerID = userinfo.getUserid();
        kanbanobj.DurationUnits = 'Weeks';
        String someJSONData = JSON.serialize(kanbanobj);
        String mySessionID = userinfo.getSessionId();   
        String jsonData = leankor.KanbanController.CloneKanbanCard(VSID,testFinalDate,testTaskVerb,someJSONData,mySessionID);
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(jsonData, leankor.RealTimeController.Kanban.class);
        System.AssertEquals(remoteKanban.DurationUnits,'Weeks');
        Test.stopTest();
    }


    @isTest
    private static void cloneCardwithStartDateTest(){

        Test.startTest();
        leankor__LeanConstants__c customSetting = [Select Id,
                                                          leankor__AllowSchedulingConstraints__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

        customSetting.leankor__AllowSchedulingConstraints__c = true;
        update customSetting;

        leankor__ValueStream__C valuestream = [Select Id
                                                From leankor__ValueStream__C
                                                Where Name= 'my1_vs'
                                                Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'kanban card one'
                                            Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Years';
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits, 'Years');
        Test.stopTest();
    }

    @isTest
    private static void cloneCardwithStartDateTestTwo(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name= 'my1_vs'
                                                 Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                          From leankor__KanbanCard__C
                                          Where Name = 'kanban card one'
                                          Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Minutes';
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits, 'Minutes');
        Test.stopTest();
    }

    
    @isTest
    private static void cloneCardwithStartDateTestThird(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                From leankor__ValueStream__C
                                                Where Name= 'my1_vs'
                                                Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'kanban card one'
                                            Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Weeks';
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits,'Weeks');  
        kanban.DurationUnits = 'Months';
        kanban.EstimatedDuration = 60;
        String someJSONDatase = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdatese =  new leankor.KanbanController.clonestartboard();
        clonewithstartdatese.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdatese.TaskVerb = true;
        clonewithstartdatese.someJSONData = someJSONDatase;
        String cloneStartDatee = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdatese, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanbancards = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDatee, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanbancards.DurationUnits, 'Months'); 
        kanban.DurationUnits = 'Hours';
        kanban.EstimatedDuration = 8;
        String someJSON = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithdatese =  new leankor.KanbanController.clonestartboard();
        clonewithdatese.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithdatese.TaskVerb = true;
        clonewithdatese.someJSONData = someJSON;
        String cloneStart = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithdatese, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanbancard = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStart, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanbancard.DurationUnits, 'Hours');
        Test.stopTest();

    }

    @isTest
    private static void cloneCardwithStartDateTestFourth(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name= 'Valuestream SevenDay'
                                                 Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Activity Seven Day'
                                            Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Weeks';
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits,'Weeks');   
        Test.stopTest();
    }

    
    @isTest
    private static void cloneCardwithStartDateTestFifth(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name= 'Valuestream SevenDay'
                                                 Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                          From leankor__KanbanCard__C
                                          Where Name = 'Activity Seven Day'
                                          Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Years';
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits,'Years');  
        Test.stopTest();
    }

    @isTest
    private static void cloneCardwithStartDateTestsixth(){

        Test.startTest();
        KanbanController.ChatterFileContent newchatter = new KanbanController.ChatterFileContent();

        leankor__ValueStream__C valuestream = [Select Id
                                                   From leankor__ValueStream__C
                                                   Where Name= 'Valuestream SevenDay'
                                                   Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'Activity Seven Day'
                                            Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanbancard = new leankor.RealTimeController.Kanban();
        kanbancard.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanbancard.Id = card.ID;
        kanbancard.GUID = card.leankor__GUID__C;
        kanbancard.Name = card.Name;
        kanbancard.ValueStream = card.leankor__ValueStream__c;
        kanbancard.DueDate = card.leankor__DueDateTime__c;
        kanbancard.EstimatedDuration = 10;
        kanbancard.Width=150;
        kanbancard.Left=420;
        kanbancard.HarveyBall = String.valueOf(50);
        kanbancard.OwnerID = userinfo.getUserid();
        kanbancard.DurationUnits = 'Months';
        String someJSONDatas = JSON.serialize(kanbancard);
        leankor.KanbanController.clonestartboard  startdates =  new leankor.KanbanController.clonestartboard();
        startdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        startdates.TaskVerb = true;
        startdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,startdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanbancard = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanbancard.DurationUnits,'Months');  
        Test.stopTest();
        
    }

    
    @isTest
    private static void cloneCardwithStartDateTestSeventh(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name= 'my1_vs'
                                                 Limit 1];

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                            From leankor__KanbanCard__C
                                            Where Name = 'kanban card one'
                                            Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanbancard = new leankor.RealTimeController.Kanban();
        kanbancard.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanbancard.Id = card.ID;
        kanbancard.GUID = card.leankor__GUID__C;
        kanbancard.Name = card.Name;
        kanbancard.ValueStream = card.leankor__ValueStream__c;
        kanbancard.DueDate = card.leankor__DueDateTime__c;
        kanbancard.EstimatedDuration = 427;
        kanbancard.Width=150;
        kanbancard.Left=420;
        kanbancard.HarveyBall = String.valueOf(50);
        kanbancard.OwnerID = userinfo.getUserid();
        kanbancard.DurationUnits = 'Minutes';
        String someJSONDatas = JSON.serialize(kanbancard);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits, 'Minutes');

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 10;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        kanban.DurationUnits = 'Weeks';
        String someJSONDataes = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithdates =  new leankor.KanbanController.clonestartboard();
        clonewithdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithdates.TaskVerb = true;
        clonewithdates.someJSONData = someJSONDataes;
        String cloneStartDates = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanbans = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDates, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanbans.DurationUnits,'Weeks'); 
        Test.stopTest();
    }

    @isTest
    private static void cloneCardwithStartDateTestEight(){

        Test.startTest();
        List<leankor__ProjectRoom__c> listProjectRoom = new List<leankor__ProjectRoom__c>();
        leankor.Util until = new leankor.Util();
        KanbanController kanbans = new kanbancontroller(until);

        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name = 'my1_vs'
                                                 Limit 1];

        leankor__ProjectRoom__c sourceProjectOne = new leankor__projectRoom__c(name = 'sourceProjectOne');
        insert sourceProjectOne;
        listProjectRoom.add(sourceProjectOne);
        ApexPages.StandardSetController stdController = new ApexPages.standardSetController(listProjectRoom);
        KanbanController testController = new KanbanController(stdController);

        leankor__KanbanCard__C card = [Select Id,
                                              leankor__StartDateTime__c,
                                              leankor__GUID__C,
                                              Name,
                                              leankor__ValueStream__c,
                                              leankor__DueDateTime__c
                                         From leankor__KanbanCard__C
                                         Where Name = 'kanban card one'
                                         Limit 1];

        String valueStreamId =String.ValueOf(valuestream.ID);
        String testFinalDate = JSON.Serialize(System.Now()+5);
        Boolean testTaskVerb = true;

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = card.ID;
        kanban.GUID = card.leankor__GUID__C;
        kanban.Name = card.Name;
        kanban.ValueStream = card.leankor__ValueStream__c;
        kanban.DueDate = card.leankor__DueDateTime__c;
        kanban.EstimatedDuration = 427;
        kanban.Width=150;
        kanban.Left=420;
        kanban.HarveyBall = String.valueOf(50);
        kanban.OwnerID = userinfo.getUserid();
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdates, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDate, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanban.DurationUnits, null);
        kanban.DurationUnits = 'Minutes';
        kanban.EstimatedDuration = 60;
        String someJSONDatase = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdatese =  new leankor.KanbanController.clonestartboard();
        clonewithstartdatese.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdatese.TaskVerb = true;
        clonewithstartdatese.someJSONData = someJSONDatase;
        String cloneStartDatee = leankor.KanbanController.cloneCardwithStartDate(valueStreamId,clonewithstartdatese, userinfo.getSessionId());  
        leankor.RealTimeController.Kanban remoteKanbancards = (leankor.RealTimeController.Kanban)JSON.deserialize(cloneStartDatee, leankor.RealTimeController.Kanban.class);
        System.assertEquals(remoteKanbancards.DurationUnits, 'Minutes');
        Test.stopTest();
    }

    @isTest
    private static void cloneCardwithStartDateTestNine(){

        Test.startTest();
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name = 'my1_vs'
                                                 Limit 1];

        leankor.RealTimeController.Kanban kanban = new leankor.RealTimeController.Kanban();
        kanban.StartDate = DateTime.newInstance(2021, 12, 1,00,00,00);
        kanban.Id = valuestream.ID;
        String someJSONDatas = JSON.serialize(kanban);
        leankor.KanbanController.clonestartboard  clonewithstartdates =  new leankor.KanbanController.clonestartboard();
        clonewithstartdates.StartDate = String.valueOf(DateTime.newInstance(2022, 11, 1,00,00,00));
        clonewithstartdates.TaskVerb = true;
        clonewithstartdates.someJSONData = someJSONDatas;
        String cloneStartDate = leankor.KanbanController.cloneCardwithStartDate(valuestream.Id,clonewithstartdates, userinfo.getSessionId());  
        System.assertEquals('failure',cloneStartDate );
        Test.stopTest();

    }

    @isTest
    private static void getKanbanCardConstraintTest(){

        Test.startTest();
        leankor.KanbanController.KanbanCardConstraint constraint = new leankor.KanbanController.KanbanCardConstraint();
        constraint.scheduleModeRecord.constraintType = 'aslateaspossible';
        constraint.kanbanCardRecord.current.startDateTime = System.now();
        constraint.kanbanCardRecord.current.dueDateTime = System.now();

        leankor.KanbanCard nextKanbanCardRecord = new leankor.KanbanCard();
        nextKanbanCardRecord.startDateTime = System.now().addDays(1);
        nextKanbanCardRecord.dueDateTime = System.now().addDays(1);

        KanbanController.KanbanCardConstraint constraintType = leankor.KanbanController.getKanbanCardConstraint(constraint, nextKanbanCardRecord);
        System.assertEquals(constraint.kanbanCardRecord.current.startDateTime, constraintType.kanbanCardRecord.current.startDateTime);

        leankor.KanbanController.KanbanCardConstraint constraints = new leankor.KanbanController.KanbanCardConstraint();
        constraints.scheduleModeRecord.constraintType = 'assoonaspossible';
        constraints.kanbanCardRecord.current.startDateTime = System.now();
        constraints.kanbanCardRecord.current.dueDateTime = System.now();

        leankor.KanbanCard nextKanbanCardRecords = new leankor.KanbanCard();
        nextKanbanCardRecords.startDateTime = System.now().addDays(1);
        nextKanbanCardRecords.dueDateTime = System.now().addDays(1);

        KanbanController.KanbanCardConstraint constraintTypes = leankor.KanbanController.getKanbanCardConstraint(constraints, nextKanbanCardRecords);
        System.assertEquals(constraints.kanbanCardRecord.current.startDateTime, constraintTypes.kanbanCardRecord.current.startDateTime);
        Test.stopTest();

    }

    @isTest
    private static void cloneMarkersTest(){

        Test.startTest();
        leankor__ValueStream__c valuestreamlistWithoutLaunchDate = getBoard('Valuestream ProjectLaunchDate constarint');
        leankor__ValueStream__C valuestream = [Select Id
                                                 From leankor__ValueStream__C
                                                 Where Name = 'my1_vs'
                                                 Limit 1];

        leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
        cBoard.RealVSID = valuestreamlistWithoutLaunchDate.Id;
        cBoard.BoardType = 'DashBoard';
        cBoard.VSID = valuestreamlistWithoutLaunchDate.Id;
        KanbanController.cloneMarkers(cBoard);

        List<leankor__Marker__c> marker = [Select Id,
                                                  leankor__ValueStream__C
                                              From leankor__Marker__c
                                              Where leankor__ValueStream__C =: cBoard.RealVSID];

        System.assertEquals(marker[0].leankor__ValueStream__C,cBoard.VSID);
        leankor.KanbanController.CloneBoard cloneBoard = new leankor.KanbanController.CloneBoard();
        cloneBoard.RealVSID = valuestream.Id;
        cloneBoard.BoardType = 'DashBoard';
        KanbanController.cloneMarkers(cloneBoard);

        List<leankor__Marker__c> markers = [Select Id,
                                                   leankor__ValueStream__C
                                               From leankor__Marker__c
                                               Where leankor__ValueStream__C =: cloneBoard.RealVSID];

        System.assertEquals(markers.size(),0);
        Test.stopTest();
    }
}