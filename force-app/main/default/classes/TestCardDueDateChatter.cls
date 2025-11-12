/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: TestCardDueDateChatter.cls
 CLASS: TestCardDueDateChatter
*/
@isTest
public class TestCardDueDateChatter{

     	private static testMethod void testingCardDueDateChatter() 
     	{
	        Database.QueryLocator QL;
	        Database.BatchableContext BC;
	        Date dt=System.today();
	        String due=String.valueOf(dt);
	        
	        Test.startTest();
	        leankor__ProjectRoom__c pr = new leankor__ProjectRoom__c(Name = 'Project-1');
	        insert pr;
	        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c = 'Portfolio View',leankor__projectroom__c = pr.id);
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
	        
	        List<leankor__KanbanCardTemplate__c> temp = realtimeController.createKanbanCardTemplate(kanbanTemps); 	        
	      	User user = leankor.TestDataFactory.createStandardUser('Lean123');		
			List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
			List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
			List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', user);                   
			leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
			List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
			List<leankor__KanbanCard__c> retkan=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,user);     
	     
	        List<leankor__Subscriber__c> subscriberlist= new List<leankor__Subscriber__c>();        	        
	        for(integer i=1;i<100;i++)
	        {
	        	leankor__Subscriber__c sub1 = new leankor__Subscriber__c
	        	(
	        	name = retkan[0].Name,
	        	leankor__KanbanCard__c = retkan[0].Id,
	        	leankor__SubscriberKey__c = retkan[0].Id+'-'+user.id+i,
	        	leankor__SubscriberID__c = user.id,
	        	leankor__Moved__c = true,
	        	leankor__PercentDone__c = true,
	        	leankor__CardPastDueDate__c = true,
	        	leankor__TaskPastDueDate__c = true
	        	);
	        	subscriberlist.add(sub1);
	        }
        	insert subscriberlist;
        	System.assert(retkan.size() != 0);
	        // execute batch apex 	       	        
	        CardDueDateChatter SCDDC = new CardDueDateChatter();	     	
	     	Database.executebatch(SCDDC);
	        Test.stoptest();
		}

	 /*-------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover CardDueDateChatter Class
	-------------------------------------------------------------------------------------------------------*/

	@isTest
	private static void cardDueDateChatterTest(){
		
		User user = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
		List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
		List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Whiteboard', user);                   
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
		List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
		List<leankor__KanbanCard__c> kanbanCardRecord =leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,user); 

		List <leankor__Subscriber__c> subscriberList = new List < leankor__Subscriber__c > ();
		for(Integer i=1;i<=200;i++){
			leankor__Subscriber__c subscriberRecord = new leankor__Subscriber__c();
			subscriberRecord.Name ='Whiteboard subscribe';
			subscriberRecord.leankor__SubscriberKey__c = kanbanCardRecord[0].Id+'-'+user.id+i;
			subscriberRecord.leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid();
			subscriberRecord.leankor__SubscriberID__c = user.id;
			subscriberRecord.leankor__KanbanCard__c = kanbanCardRecord[0].id;
			subscriberRecord.leankor__Moved__c = true;
			subscriberRecord.leankor__PercentDone__c = true;
			subscriberRecord.leankor__CardPastDueDate__c = true;
			subscriberRecord.leankor__TaskPastDueDate__c = true;
			subscriberList.add(subscriberRecord);
		}
		insert subscriberList;
		
		
		Test.startTest();
		CardDueDateChatter cardDueDateChatterRecord = new CardDueDateChatter();
		Id batchId = DataBase.executeBatch(cardDueDateChatterRecord);
		System.assertEquals(200,[Select count() From leankor__Subscriber__c Where Name = 'Whiteboard subscribe'],'The count should be 200');
		Test.stopTest(); 
	}

	/*-------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover CardDueDateChatter Class
	-------------------------------------------------------------------------------------------------------*/
	@isTest
	private static void cardDueDateChatterSecondTest(){
		
		User user = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
		List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
		List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Portfolio View', user);                   
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
		List<leankor__KanbanCard__c> activityList = leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
		List<leankor__KanbanCard__c> kanbanCardRecord = leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,user); 

		List <leankor__Subscriber__c> subscriberList = new List < leankor__Subscriber__c > ();
		for(Integer i=1;i<=200;i++){
			leankor__Subscriber__c subscriberRecord = new leankor__Subscriber__c();
			subscriberRecord.Name ='Portfolio View subscribe';
			subscriberRecord.leankor__SubscriberKey__c = kanbanCardRecord[0].Id+'-'+user.id+i;
			subscriberRecord.leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid();
			subscriberRecord.leankor__SubscriberID__c = user.id;
			subscriberRecord.leankor__KanbanCard__c = kanbanCardRecord[0].id;
			subscriberRecord.leankor__Moved__c = true;
			subscriberRecord.leankor__PercentDone__c = true;
			subscriberRecord.leankor__CardPastDueDate__c = true;
			subscriberRecord.leankor__TaskPastDueDate__c = true;
			subscriberList.add(subscriberRecord);
		}
		insert subscriberList;

		Test.startTest();
		CardDueDateChatter cardDueDateChatterRecord = new CardDueDateChatter();
		Id batchId=DataBase.executeBatch(cardDueDateChatterRecord); 
		System.assertEquals(200,[Select count() From leankor__Subscriber__c Where Name = 'Portfolio View subscribe'],'The count should be 200');
		Test.stopTest();
	}

	/*-------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover CardDueDateChatter Class
	-------------------------------------------------------------------------------------------------------*/
	@isTest
	private static void cardDueDateChatterThirdTest(){
		
		User user = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
		List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
		List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Plan Board', user);                   
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
		List<leankor__KanbanCard__c> activityList = leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
		List<leankor__KanbanCard__c> kanbanCardRecord = leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,activityList,user); 

		List <leankor__Subscriber__c> subscriberList = new List < leankor__Subscriber__c > ();
		for(Integer i=1;i<=200;i++){
			leankor__Subscriber__c subscriberRecord = new leankor__Subscriber__c();
			subscriberRecord.Name ='Portfolio View subscribe';
			subscriberRecord.leankor__SubscriberKey__c = kanbanCardRecord[0].Id+'-'+user.id;
			subscriberRecord.leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid();
			subscriberRecord.leankor__SubscriberID__c = user.id;
			subscriberRecord.leankor__KanbanCard__c = kanbanCardRecord[0].id;
			subscriberRecord.leankor__Moved__c = true;
			subscriberRecord.leankor__PercentDone__c = true;
			subscriberRecord.leankor__CardPastDueDate__c = true;
			subscriberRecord.leankor__TaskPastDueDate__c = true;
			subscriberList.add(subscriberRecord);
		}
		insert subscriberList;
		
		Test.startTest();
		CardDueDateChatter cardDueDateChatterRecord = new CardDueDateChatter();
		Id batchId = DataBase.executeBatch(cardDueDateChatterRecord); 
		System.assertEquals(200,[Select count() From leankor__Subscriber__c Where Name = 'Portfolio View subscribe'],'The count should be 200');
		Test.stopTest();
	}
}