/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestKanbanToGanttController.cls
 * CLASS: TestKanbanToGanttController
 */
@isTest
private class TestKanbanToGanttController 
{ 
	@testSetup static void testData() {		
		User user = leankor.TestDataFactory.createStandardUser('Lean123');		
		list<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        list<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        list<leankor__ValueStream__c> vStreamList = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', user);       
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStreamList[0]);      
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(vStreamList[0],template,5);
        List<leankor__KanbanCard__c> kanbancardList=leankor.TestDataFactory.createKanbanCard(vStreamList[0],template,1,activityList,user);				 	
		List<Task> taskList=new List<Task>();		
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
		insert taskList;	
	}

    public static testMethod void testGetResources() {
		leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
		testFolder.Name = 'Test Room';
		insert testFolder;

		leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
		prjRoom.Name = 'Test Room';
		prjRoom.leankor__Portfolio__c = testFolder.Id;
		insert prjRoom;

		leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name = 'myVS';
		valueStream.leankor__ProjectRoom__c = prjRoom.Id;
		valueStream.leankor__BoardType__c ='Whiteboard';
		valueStream.leankor__Istemplateboard__c = false;
		valueStream.leankor__DisableTaskAsMiniature__c=true;
        insert valueStream;

        ApexPages.StandardController standardController = new ApexPages.standardController(valueStream);
        leankor.KanbanToGanttController kanbanController = new leankor.KanbanToGanttController(standardController);
        leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.Name = 'template name';
        template.leankor__Width__c = 100;
        template.leankor__Title__c = 'template title';
        template.leankor__JSONDefinition__c = '{}';
        template.leankor__JSONData__c = '{}';
        template.leankor__Height__c = 200;
        template.leankor__CSSLayout__c = 'some css';
        template.leankor__valueStream__c = valueStream.id;
        insert template;

        task task1 = new task();
		task1.Subject = 'T1';
		task1.whatId =template.ID;
		task1.ActivityDate = system.today();

    	task task2 = new task();
		task2.Subject = 'T2';
		task2.whatId =Template.Id;
		task2.ActivityDate = system.today();
    	insert task1;
    	insert task2;

    	leankor__Zone__c zone = new leankor__Zone__c();
		zone.Name='Zone1';
		zone.leankor__ValueStream__c=valueStream.Id;
		zone.leankor__GUID__c= leankor.TestDataFactory.createGuid();
    	insert zone;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
		kanbanCard.Name = 'kanban test';
		kanbanCard.leankor__Y__c = 20;
		kanbanCard.leankor__X__c = 50;
		kanbanCard.leankor__Width__c = 100;
		kanbanCard.leankor__ValueStream__c = valueStream.Id;
		kanbanCard.leankor__Top__c = 150;
		kanbanCard.leankor__Title__c = 'kanban title test';
		kanbanCard.leankor__Left__c = 250;
		kanbanCard.leankor__JSONDefinition__c = '{}';
		kanbanCard.leankor__JSONData__c = '{}';
		kanbanCard.leankor__Height__c = 110;
		kanbanCard.leankor__GUID__c =leankor.TestDataFactory.createGuid();
		kanbanCard.leankor__CmpID__c = 'my-CMPID-kanban-test';
		kanbanCard.leankor__CSSLayout__c = 'some css';
		kanbanCard.leankor__Bottom__c = 450;
		kanbanCard.leankor__Priority__c = 1;
		kanbanCard.leankor__KanbanCardTemplate__c = template.Id;
		kanbanCard.leankor__DurationUnits__c='Minutes';
		kanbanCard.leankor__EstimatedDuration__c=2;
		kanbanCard.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		insert kanbanCard;

        task task3 = new task();
		task3.Subject = 'T1';
		task3.whatId =kanbanCard.Id;
		task3.ActivityDate = system.today();

		task task4 = new task();
		task3.Subject = 'T2';
		task3.whatId =kanbanCard.Id;
		task3.ActivityDate = system.today();
		insert task3;
		insert task4;

        leankor__KanbanCard__c kanban1 = new leankor__KanbanCard__c();
		kanban1.Name = 'kanban test1';
		kanban1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		kanban1.leankor__CmpID__c = 'my-CMPID-kanban-test1';
		kanban1.leankor__ValueStream__c = valueStream.Id;
		kanban1.leankor__KanbanCardTemplate__c=template.Id;
		kanban1.leankor__DurationUnits__c ='Minutes';
		kanban1.leankor__EstimatedDuration__c = 2;
		kanban1.leankor__ZoneGUID__c = zone.leankor__GUID__c;
		kanban1.leankor__ValueStreamCardLink__c = kanbanCard.Id;
		kanban1.leankor__ValueStreamLink__c = valueStream.Id;
		kanban1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
       	insert kanban1;

        task taskdata1 = new task();
		taskdata1.Subject = 'T1';
		taskdata1.whatId =kanban1.Id;
		taskdata1.ActivityDate = system.today();

		task taskdata2 = new task();
		taskdata2.Subject = 'T2';
		taskdata2.whatId =kanban1.Id;
		taskdata2.ActivityDate = system.today();
		insert taskdata1;
		insert taskdata2;

        leankor__KanbanCard__c kanban2 = new leankor__KanbanCard__c();
		kanban2.Name = 'kanban test2';
		kanban2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		kanban2.leankor__CmpID__c = 'my-CMPID-kanban-test2';
		kanban2.leankor__ValueStream__c = valueStream.Id;
		kanban2.leankor__KanbanCardTemplate__c=template.Id;
		kanban2.leankor__EstimatedDuration__c=2;
		kanban2.leankor__ZoneGUID__c =zone.leankor__GUID__c;
		kanban2.leankor__ValueStreamCardLink__c=kanbanCard.Id;
		kanban2.leankor__ValueStreamLink__c =valueStream.Id;
		kanban2.leankor__DurationUnits__c='Days';
		kanban2.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kanban2;

        task tc12 = new task();
		tc12.Subject = 'T1';
		tc12.whatId =kanban2.ID;
		tc12.ActivityDate = system.today();

    	task tc3 = new task();
		tc3.Subject = 'T2';
		tc3.whatId =kanban2.Id;
		tc3.ActivityDate = system.today();
		insert tc3;
		insert tc12;

		leankor__Zone__c zone1 = new leankor__Zone__c();
		zone1.Name='Zone12';
		zone1.leankor__ValueStream__c=valueStream.Id;
		zone1.leankor__GUID__c= leankor.TestDataFactory.createGuid();
		insert zone1;

        leankor__KanbanCard__c kanban3 = new leankor__KanbanCard__c();
		kanban3.Name = 'kanban test3';
		kanban3.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		kanban3.leankor__CmpID__c = 'my-CMPID-kanban-test3';
		kanban3.leankor__ValueStream__c = valueStream.Id;
		kanban3.leankor__KanbanCardTemplate__c = template.Id;
		kanban3.leankor__DurationUnits__c ='Years'; 
		kanban3.leankor__EstimatedDuration__c=2;
		kanban3.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
		kanban3.leankor__ValueStreamCardLink__c = kanban2.Id;
		kanban3.leankor__ValueStreamLink__c = valueStream.Id;
		kanban3.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kanban3;

        task tc31 = new task();
		tc31.Subject = 'T1';
		tc31.whatId =kanban3.Id;
		tc31.ActivityDate = system.today();
		task tc32 = new task();
		tc32.Subject = 'T2';
		tc32.whatId =kanban3.Id;
		tc32.ActivityDate = system.today();
		insert tc31;
		insert tc32;

        leankor__KanbanCard__c kanban4 = new leankor__KanbanCard__c();
		kanban4.Name = 'kanban test4';
		kanban4.leankor__GUID__c =leankor.TestDataFactory.createGuid();
		kanban4.leankor__CmpID__c = 'my-CMPID-kanban-test4';
		kanban4.leankor__ValueStream__c = valueStream.Id;
		kanban4.leankor__KanbanCardTemplate__c=template.Id;
		kanban4.leankor__ValueStreamCardLink__c=kanban3.Id;
		kanban4.leankor__ValueStreamLink__c =valueStream.Id;
		kanban4.leankor__DurationUnits__c='Minutes';
		kanban4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
       	insert kanban4;

       	task tc41 = new task();
		tc41.Subject = 'T1';
		tc41.whatId =kanban4.Id;
		tc41.ActivityDate = system.today();
		task tc42 = new task();
		tc42.Subject = 'T2';
		tc42.whatId =kanban4.Id;
		tc42.ActivityDate = system.today();
		insert tc41;
		insert tc42;  

		leankor.KanbanToGanttController.CalenderResourceScheduler zones=leankor.KanbanToGanttController.getResources(valueStream.Id,'Whiteboard');
		leankor.KanbanToGanttController.CalenderResourceScheduler zones1=leankor.KanbanToGanttController.getResources(valueStream.Id,'Whiteboard');
    	try {
    		leankor.KanbanToGanttController.CalenderResourceScheduler result = leankor.KanbanToGanttController.getResources('00Dd0000001h60X','Whiteboard');
    	}catch(Exception e){
      		System.Assert(e.getMessage().contains('Invalid input'));
    	}
		System.assert(zones != null, 'zones should not be null');
		System.assert(zones1 != null, 'zones1 should not be null');
		
   		//Set<String> vsIds= leankor.KanbanToGanttController.getAllValueStreamID(vs.Id);
    	/*
		try{
      		Set<String> result= leankor.KanbanToGanttController.getAllValueStreamID('00Dd0000001h60X');
    	}catch(Exception e){
      		System.Assert(e.getMessage().contains('Invalid input'));
    	}
		*/
    	leankor__ValueStream__c vs1= new leankor__ValueStream__c();
		vs1.Name = 'myVS1';
		vs1.leankor__ProjectRoom__c = prjRoom.Id;
		vs1.leankor__BoardType__c='Kanban Board';
		vs1.leankor__Istemplateboard__c = false;
        insert vs1;
       
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
        masterContainer.Type = 'Template';
        masterContainer.ValueStreamID = vs1.id;
        masterContainer.Width = 100;
        masterContainerList.add(masterContainer);
        List<leankor__MasterContainer__c> mContList=leankor.KanbanController.createMasterContainer(masterContainerList);
        System.assert(mContList != null && !mContList.isEmpty(), 'mContList should not be null or empty');

    
		List<leankor.KanbanController.Swimlane> swimlaneList=new List<leankor.KanbanController.Swimlane>();
		for(integer i=0;i<5;i++){
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
            swimlane.MasterContainer = mContList[0].id;
            swimlane.ValueStreamID = vs1.id;
            swimlane.Width = 100;
            swimlaneList.add(swimlane);
  		}
        List<leankor__Swimlane__c> swmList=leankor.KanbanController.createSwimlane(swimlaneList);
        System.assert(swmList != null && !swmList.isEmpty(), 'swmList should not be null or empty');

        leankor__KanbanCardTemplate__c kct1 = new leankor__KanbanCardTemplate__c();
        kct1.Name = 'template name';
        kct1.leankor__Width__c = 100;
        kct1.leankor__Title__c = 'template title';
        kct1.leankor__JSONDefinition__c = '{}';
        kct1.leankor__JSONData__c = '{}';
        kct1.leankor__Height__c = 200;
        kct1.leankor__CSSLayout__c = 'some css';
        kct1.leankor__valueStream__c =vs1.id;
        insert kct1;

    	leankor__Zone__c zone2 = new leankor__Zone__c();
		zone2.Name='Zone2';
		zone2.leankor__ValueStream__c=vs1.Id;
		zone2.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		zone2.leankor__Swimlane__c=swmList[0].id;
    	insert zone2;

    	leankor.KanbanToGanttController.MasterContainer remoteZone = leankor.KanbanToGanttController.getZoneRecord(zone2.leankor__GUID__c); 
		System.assert(remoteZone != null, 'RemoteZone should not be null');

        leankor__KanbanCard__c kc5 = new leankor__KanbanCard__c();
        kc5.Name = 'kanban test';
        kc5.leankor__Y__c = 20;
        kc5.leankor__X__c = 50;
        kc5.leankor__Width__c = 100;
        kc5.leankor__ValueStream__c = vs1.Id;
        kc5.leankor__Top__c = 150;
        kc5.leankor__Title__c = 'kanban title test';
        kc5.leankor__Left__c = 250;
        kc5.leankor__JSONDefinition__c = '{}';
        kc5.leankor__JSONData__c = '{}';
        kc5.leankor__Height__c = 110;
        kc5.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kc5.leankor__CmpID__c = 'my-CMPID-kanban-test5';
        kc5.leankor__CSSLayout__c = 'some css';
        kc5.leankor__Bottom__c = 450;
        kc5.leankor__Priority__c = 1;
        kc5.leankor__KanbanCardTemplate__c=kct1.Id;
        kc5.leankor__DurationUnits__c='Minutes';
        kc5.leankor__EstimatedDuration__c=2;
        kc5.leankor__ZoneGUID__c =zone2.leankor__GUID__c;
        kc5.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc5;

        task t51 = new task();
		t51.Subject = 'T1';
		t51.whatId =KC5.Id;
		t51.ActivityDate = system.today();

		task t52 = new task();
		t52.Subject = 'T2';
		t52.whatId =KC5.Id;
		t52.ActivityDate = system.today();
		insert t51;
		insert t52;
         
    	leankor.KanbanToGanttController.CalenderResourceScheduler MC=leankor.KanbanToGanttController.getResources(vs1.Id, 'Kanban Board');
    	System.assert(MC != null, 'MC should not be null');

		list<string> UserIds =  new list<string>();
  		for(leankor.KanbanToGanttController.CardResource UserLog : MC.CardResources){
    		UserIds.add(UserLog.id);
  		}  
		  
		//modified Test Class
		leankor.KanbanToGanttController.MasterContainer filterData = new leankor.KanbanToGanttController.MasterContainer();
		filterData.ValueStreamID = vs1.Id;
		filterData.StartDate = (system.now()-10).format('yyyy-MM-dd');
		filterData.DueDate = (system.now()+10).format('yyyy-MM-dd');
		
		
		leankor.KanbanToGanttController.ResourceScheduler CHRSResult  = leankor.KanbanToGanttController.getKanbanCardsByResource(UserIds,JSON.Serialize(filterData));
      	system.assert(CHRSResult !=null);
		
		User nonStandardUser = [Select Id 
									From User 
									Where UserType = 'Standard' 
									And IsActive = true 
									Limit 1];
		system.runAs(nonStandardUser) {
			leankor.KanbanToGanttController.ResourceScheduler CHRSResultNoAccess  =leankor.KanbanToGanttController.getKanbanCardsByResource(UserIds,JSON.Serialize(filterData));
		}
		try {
			leankor.KanbanToGanttController.ResourceScheduler CHRSResultNoAccess  =leankor.KanbanToGanttController.getKanbanCardsByResource(new List<String>{'00Dd0000001h60X'},JSON.Serialize(filterData));
		} catch(Exception e) {
			System.Assert(e.getMessage().contains('Invalid input'));
		}
	}

    static testMethod void cloneActivityGroupTest() {
        test.startTest();               
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c();
		sourceProject.name = 'testProject';
        insert sourceProject;
                    
        leankor__ValueStream__c planGanttBoard = new leankor__ValueStream__c();
		planGanttBoard.Name = 'Plan Board';
		planGanttBoard.leankor__BoardType__c='UberBoard';
		planGanttBoard.leankor__ProjectRoom__c = sourceProject.Id;
		planGanttBoard.leankor__IsTemplateBoard__c = false;         
        insert planGanttBoard;
        
        List<String> kanbanCardList = new List<String>();
                
        leankor__KanbanCard__c kanban1 = new leankor__KanbanCard__c();
        kanban1.Name = 'ACT1';
        kanban1.leankor__ValueStream__c = planGanttBoard.Id;
        kanban1.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();     
        insert kanban1;
        
        kanbanCardList.add(kanban1.Id);
                    
        leankor__KanbanCard__c kanban2 = new leankor__KanbanCard__c();
        kanban2.Name = 'Mile1';
        kanban2.leankor__ValueStream__c = planGanttBoard.Id;
        kanban2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanban2.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();     
        insert kanban2;
        
        kanbanCardList.add(kanban2.Id);
        // inserting top level folder - first level           
        leankor__KanbanCard__c kanban3 = new leankor__KanbanCard__c();
        kanban3.Name = 'folder1';
        kanban3.leankor__ValueStream__c = planGanttBoard.Id;
        kanban3.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanban3.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();     
        insert kanban3;
               
        kanbanCardList.add(kanban3.Id);
        
        // inserting 200 sub folders in folder1 - second level
        List<leankor__KanbanCard__c> kanbanlistGroup = new list<leankor__KanbanCard__c>();           
        for(Integer i=1;i<=200;i++)
        {
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'folder1'+i;
            kanban.leankor__ValueStream__c = planGanttBoard.Id;
            kanban.leankor__GUID__c =leankor.TestDataFactory.createGuid();
            kanban.leankor__ValueStreamCardLink__c = kanban3.id;
            kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();     
            kanbanlistGroup.add(kanban);
        }
        insert kanbanlistGroup;
        
        for(leankor__KanbanCard__c k : kanbanlistGroup){kanbanCardList.add(k.Id);}
        
        // inserting 100 activity card in folder1 - second level           
        List<leankor__KanbanCard__c> kanbanlistAct = new list<leankor__KanbanCard__c>();  
        for(Integer i=1;i<=100;i++) {
            leankor__KanbanCard__c kanban4 = new leankor__KanbanCard__c();
            kanban4.Name = 'Act2';
            kanban4.leankor__ValueStream__c = planGanttBoard.Id;
            kanban4.leankor__GUID__c =leankor.TestDataFactory.createGuid();
            kanban4.leankor__ValueStreamCardLink__c = kanban3.id;
            kanban4.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();     
            kanbanlistAct.add(kanban4);
        }
        insert kanbanlistAct;
               
        for(leankor__KanbanCard__c k : kanbanlistAct){kanbanCardList.add(k.Id);}
                                                               
        leankor__Dependency__c dependency = new leankor__Dependency__c();
        dependency.leankor__ValueStream__c = planGanttBoard.Id;
        dependency.leankor__Predecessor__c = kanbanlistAct[0].Id;
        dependency.leankor__Successor__c = kanban1.Id;
        dependency.leankor__LagLead__c = 1;
        dependency.leankor__LagLeadUnit__c = 'days';
        dependency.leankor__SuccessorType__c = 'Start To Start';
        insert dependency;
                    
        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
        resourceAssignment.leankor__KanbanCard__c = kanbanlistAct[0].ID;
        resourceAssignment.leankor__AssignedTo__c = kanbanlistAct[0].OwnerId;
        resourceAssignment.leankor__PercentAllocation__c =50.00;
        insert resourceAssignment;
                        
        leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c ();                       
        scheduleMode.leankor__KanbanCard__c = kanbanlistAct[0].ID;  
        scheduleMode.leankor__Mode__c = 'Normal';          
        insert scheduleMode;
                                           
        leankor.KanbanToGanttController.CloneCardData clone = new leankor.KanbanToGanttController.CloneCardData();
        
        clone.ItemType = 'foldercard';
        clone.BoardId = planGanttBoard.ID;
        clone.cardIdlist = new List<String>();
        clone.cardIdlist.addall(kanbanCardList);
                       
        // checking ActivityGroup cloning                           
        leankor.KanbanToGanttController.CloneCardData clonecard = leankor.KanbanToGanttController.cloneActivityGroup(clone,UserInfo.getSessionId());
		System.assert(clonecard.someJSONData == 'success', 'Expected success in someJSONData');
        test.stopTest();                                                     
    }           
	
	private static testMethod void getAllVSIdsForStreamingTest(){
		Test.startTest();
		User users =leankor.TestDataFactory.createStandardUser('lea563');		
		List<String> userslist=New List<String>();
		userslist.add(users.id);		
		List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];
		List<leankor__KanbanCard__c> kanbancardList=new List<leankor__KanbanCard__c>();
		leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
		kb.name='test1';
		kb.OwnerId=users.id;
		kb.leankor__ValueStream__c=valuestreamlist[0].id;
		kb.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		kb.leankor__IsRecordDeleted__c=false;	
		kanbancardList.add(kb);
		insert kanbancardList;			
		try{
        	KanbanToGanttController.readAllVSIdsForStreaming(valuestreamlist[0].id,userslist,new List<String>{'00Dd0000001h60X'});
      	}catch(Exception e){
			System.assert(e.getMessage().contains('Invalid input'), 'Expected error message to contain "Invalid input"');
      	}
		Test.stopTest();
	}
	
	private static testMethod void getUsersRefInBoardTest(){		
	   Test.startTest();
	   	List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];	   							
	   	String vsid=valuestreamlist[0].id;	   	   
	   	//call getUsersRefInBoard Method.
	    System.assert(KanbanToGanttController.readUsersRefInBoard(vsid)!=null);
        try{
        	Set<String> result = leankor.KanbanToGanttController.readUsersRefInBoard('00Dd0000001h60X');
        }catch(Exception e){
        	System.Assert(e.getMessage().contains('Invalid input'));
        }
	    //call getAllTaskOfUsers Methods.
	    List<String> userId=new List<String>();
	   	userId.add(UserInfo.getUserId());
	    System.assert(KanbanToGanttController.readAllTaskOfUsers(userId)!=null);
        try{
        	Set<String> result = leankor.KanbanToGanttController.readAllTaskOfUsers(new List<String>{'00Dd0000001h60X'});
        }catch(Exception e){
			System.assert(e.getMessage().contains('Invalid input'), 'Exception message should contain "Invalid input"');
        }
	   Test.stopTest();
	}
	

	private static testMethod void getTaskDataOnCVTest(){
		Test.startTest();			
	   	List<leankor__KanbanCard__c> kanbancardList=[select id from leankor__KanbanCard__c];
		List<Task> taskList=new List<Task>();		
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
		insert taskList;		
		List<String> kclist=New List<String>();
		kclist.add(kanbancardList[0].id);	
		List<leankor.realTimeController.TaskData> taskData = KanbanToGanttController.getTaskDataOnCV(kclist);
		System.assert(taskData != null, 'getTaskDataOnCV should not return null for a valid Kanban card list (kclist)');
				  try{
        	list<leankor.realTimeController.TaskData> result = leankor.KanbanToGanttController.getTaskDataOnCV(new List<String>{'00Dd0000001h60X'});
      	}catch(Exception e){
			System.assert(e.getMessage().contains('Invalid input'), 'Exception message should contain "Invalid input"');
      	}
		Test.stopTest();	
	}
	/*
		code Coverage for getKanbanCardsByResource method.
		Code Coverage for getAssociatedCardsOfResources method,getAssociatedTaskOfResources,.
		insert List of Task ,kanban card.		
	*/	
	private static testMethod void getAssociatedCardsOfResourcesTest(){
		Test.startTest();				
		User users =leankor.TestDataFactory.createStandardUser('leankor');			                     			
		List<String> resource=new List<String>();
		resource.add(users.id);					  	
		List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];
		List<leankor__MasterContainer__c> mscontainerList=new List<leankor__MasterContainer__c>();
		leankor__MasterContainer__c mscontainer=new leankor__MasterContainer__c();
		mscontainer.name='Backlog';
		mscontainer.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		mscontainer.leankor__Type__c='Backlog';
		mscontainerList.add(mscontainer);
		insert mscontainerList;
		//get record type.
		Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		List<leankor__KanbanCard__c> kanbancardList= new List<leankor__KanbanCard__c>();
		leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
		kb.name='test';
		kb.leankor__ValueStream__C=valuestreamlist[0].id;
		kb.leankor__MasterContainer__c=mscontainerList[0].id;
		kb.leankor__StartDate__c=System.today();
		kb.RecordTypeId=recType;
		kb.OwnerID=users.id;
		kanbancardList.add(kb);
		insert kanbancardList;					
		List<Task> taskList=new List<Task>();
		for(Integer i=0;i<=5;i++){			
			Task tsk = new Task();
			tsk.Priority = 'High';
			tsk.OwnerID =users.id;								
			tsk.Status = 'In Progress';
			tsk.ActivityDate = system.Today();
			tsk.WhatId = kanbancardList[0].Id;	
			tsk.Priority='high';
			tsk.status='Not Started';
			tsk.Description='demo test';									
			taskList.add(Tsk);
		}
		insert taskList;	
		//create data for  MasterContainer inner class
		List<KanbanToGanttController.MasterContainer> masterList=new List<KanbanToGanttController.MasterContainer>();
		KanbanToGanttController.MasterContainer mastercon=new KanbanToGanttController.MasterContainer();
		Integer taskListSize=masterList.size();
		mastercon.CardID=kanbancardList[0].id;
		mastercon.ValueStreamID =valuestreamlist[0].Id;
		mastercon.StartDate=(system.now()-10).format('yyyy-MM-dd');
		mastercon.DueDate = (system.now()+10).format('yyyy-MM-dd');	
		mastercon.lastCardid='';
		mastercon.lastTaskId=taskList[0].id;
		masterList.add(mastercon);			
		System.assert(KanbanToGanttController.getKanbanCardsByResource(resource, JSON.serialize(mastercon)) != null,'getKanbanCardsByResource should not return null for the given resource and mastercon input');

		Test.stopTest();
	} 
	/*
		code coverage for getProjectBoardUrl Method
		Insert List of Kanban Card
	*/
	private static testMethod void getProjectBoardUrlTest(){
		Test.startTest();				
		List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];	
		List<leankor__KanbanCard__c> kanbancardList=new List<leankor__KanbanCard__c>();
		leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
		kb.name='test1';				
		kb.leankor__ValueStream__c=valuestreamlist[0].id;
		kb.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		kb.leankor__IsRecordDeleted__c=false;							
		kanbancardList.add(kb);
		insert kanbancardList;
		string kanbanCardId=kanbancardList[0].id;
		System.assert(KanbanToGanttController.getProjectBoardUrl(kanbanCardId) != null, 'Project board URL should not be null for the given Kanban card ID');
	
      	try {
        	String result = leankor.KanbanToGanttController.getProjectBoardUrl('00Dd0000001h60X'); // input is dummy id, need to get exception
    	} catch (Exception e) {
        	System.assert(e.getMessage().contains('Invalid input'), 'Exception message should contain "Invalid input"');
    	}
		Test.stopTest();		
	}
	/*
	 Code coverage for getMilestoneCardUrl method.
	  Create Kanban card Data.
	*/
	private static testMethod void getMilestoneCardUrlTest(){		
		Test.startTest();
		User users =leankor.TestDataFactory.createStandardUser('leankor');		
		List<String> resource=new List<String>();
		resource.add(users.id);	
		List<leankor__ValueStream__c> valuestreamlist=[select id from leankor__ValueStream__c];				
		//create record trype
		Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
		List<leankor__KanbanCard__c> kanbancardList=new List<leankor__KanbanCard__c>();
		leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
		kb.name='test1';				
		kb.leankor__ValueStream__c=valuestreamlist[0].id;
		kb.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		kb.leankor__IsRecordDeleted__c=false;	
		kb.RecordTypeId=recType;						
		kanbancardList.add(kb);
		insert kanbancardList;
	  	KanbanToGanttController.milestoneObj= kanbancardList[0];	   
		System.assert(KanbanToGanttController.getMilestoneCardUrl() != null, 'Milestone card URL should not be null');

		Test.stopTest();
	}
	/*
	  Code coverage for getOrgTimeZone method.
	  Insert list of kanban card.
	*/
	private static testMethod void getOrgTimeZoneTest(){	
		Test.startTest();			
		List<leankor__KanbanCard__c> kanbancardList=new List<leankor__KanbanCard__c>();
		leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
		kb.name='test1';							
		kb.leankor__GUID__c=leankor.TestDataFactory.createGuid();
		kb.leankor__IsRecordDeleted__c=false;	
		kb.DueDateTime__c=System.now();				
		kanbancardList.add(kb);
		insert kanbancardList;
		KanbanToGanttController.milestoneObj=kanbancardList[0];
		System.assert(KanbanToGanttController.getOrgTimeZone() != null, 'Organization time zone should not be null');

		Test.stopTest();
	}          
}