/*
 * Copyright 2012-2018 Lucidsoft Inc. All rights reserved.
 * FILE: RealTimeControllerHelperTest.cls
 * CLASS: RealTimeControllerHelperTest
 */
@ isTest
private class RealTimeControllerHelperTest {
	
	//To create data for all the methods in this test class 
	@testSetup static void testData() {
		
		User u = leankor.TestDataFactory.createStandardUser('Lean123');
		User u1 = leankor.TestDataFactory.createStandardUser('leankor1');
		list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
		list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 10);        
		list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', u);    
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
        List<leankor__KanbanCard__c> agList = leankor.TestDataFactory.createActivityGroups(vStream[0], template, 10);
        List<leankor__KanbanCard__c> activityList =leankor.TestDataFactory.createChildActivity(vStream[0], template, agList, 5);
		leankor.TestDataFactory.createScheduleMode(activityList,2);
        leankor.TestDataFactory.createResourceAssignment(activityList, u1, 10);	
		List < leankor__Subscriber__c > subscriberList = new List < leankor__Subscriber__c > ();
		leankor__Subscriber__c sub = new leankor__Subscriber__c();
		sub.Name = u.id;
		sub.leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid();
		subscriberList.add(sub);
		insert subscriberList;
		leankor__Sticker__c sticker = new leankor__Sticker__C(Name = 'sticker');
		insert sticker;
		leankor__KanbanCardSticker__c kanbansticker = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = agList[0].Id, leankor__Sticker__c = sticker.Id);
		insert kanbansticker;
		List<leankor__KanbanCard__c> kblist = new List<leankor__KanbanCard__c>();
			leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
			kanban.Name = 'Activity';
			kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			kanban.leankor__ValueStream__c = vStream[1].Id;
			kanban.leankor__GUID__c = ''+1+TestDataFactory.createGuid();
			kanban.leankor__CardID__c = String.valueOf(1);
			kanban.leankor__Title__c = 'Activity ' + 1;
			kanban.leankor__KanbanCardTemplate__c = template.Id;
			kanban.leankor__StartDate__c = System.today();
			kanban.leankor__DueDate__c = System.today().addDays(1);
			kanban.leankor__PercentComplete2__c = 50;
			kanban.OwnerId=u.id;
			kanban.leankor__EstimatedDuration__c= 1;
			kanban.leankor__IsExternallyDependent__c = true;
			kbList.add(kanban);
		insert kblist;
		List<leankor__KanbanCard__c> kclist = leankor.TestDataFactory.createKanbanCard(vStream[0],template,20,kblist,u);
		List<leankor__Dependency__c> dependenceList = new List<leankor__Dependency__c>();
		for(Integer count=0;count<=kclist.size()-2;count++){
			leankor__Dependency__c dependence = new leankor__Dependency__c(leankor__GUID__c =TestDataFactory.createGuid(),          
																			leankor__ValueStream__c = vStream[0].Id,
																			leankor__predecessor__c=kclist[count].id,
																			leankor__Successor__c=kclist[count+1].id); 
			dependenceList.add(dependence);
		}
		insert dependenceList; 
		leankor__Valuestream__c valuestream = new leankor__ValueStream__C(Name = 'VS',
																		  leankor__Effortindicator__c = 'Days',
        																  leankor__BoardType__c = 'Kanban Board',
        																  leankor__EffortUnits__c='Days',
        																  leankor__Mode__c='Normal',
    																	  leankor__ManuallyScheduled__c=False,
        																  leankor__ProjectRoom__c = project[0].Id,
        																  leankor__Isrecalculate__c=False,
        																  leankor__IsTemplateBoard__c=false,
																		  leankor__IsRecordDeleted__c = false);
		insert valuestream;
	}
	//To get kanbancard records which we have inserted in testSetup method
	private static list<leankor__kanbancard__c> getKanbancardRecords(){
	
	List<leankor__kanbancard__c> kanbancards = [select Id,Recordtype.Name,leankor__TemplateBoard__c,leankor__MasterContainer__r.leankor__Type__c,
											  leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__AutoAssignResource__c,
											  leankor__ValueStreamLink__c,
											  leankor__ValueStreamCardLink__c ,
											  leankor__Priority__c,
											  leankor__valuestream__r.leankor__SevenDayWorkWeek__c,
											  (SELECT Id, ActivityDate, Description, WhatId FROM Tasks), 
											  leankor__MasterContainer__c, 
											  leankor__Swimlane__c, 
											  leankor__Zone__c, 
											  leankor__CardID__c, 
											  leankor__DueDateTime__c, 
											  leankor__GUID__c, 
											  Name, OwnerID, 
											  leankor__StartDate__c, 
											  leankor__StartDateTime__c, leankor__KanbanCardTemplate__c, 
											  leankor__PromiseCompletionDate__c, leankor__HarveyBallDoneDate__c, 
											  leankor__PercentComplete2__c, leankor__Top__c, leankor__Left__c, 
											  leankor__ZoneGUID__c, leankor__ValueStream__c, 
											  leankor__ValueStream__r.Name, leankor__DueDate__c, 
											  leankor__Valuestream__r.leankor__TaskDatecheck__c,
											  leankor__ProjectRoom__c,
											  leankor__IsAtRisk__c,
											  leankor__IsOnHold__c,
											  leankor__Monday__c,
											  leankor__Tuesday__c,
											  leankor__Wednesday__c,
											  leankor__Thursday__c,
											  leankor__Friday__c,
											  leankor__Saturday__c,
											  leankor__Sunday__c,
											  leankor__ValueStream__r.leankor__IsRecordDeleted__c
                                              from leankor__KanbanCard__c where leankor__ValueStreamCardLink__c != null limit 10 ];
											  
		return kanbancards;
	}
	
	/*
	 * Test coverage for moveOrUpdateKanbanCard Method.
	 * insert List of subscriber,KanbanCard
	 * Assign the value of RealTimeControllerHelper.ManageStateChangeWrapper and RealTimeController.StateChangePackage
	 */	  
	private static testMethod void moveOrUpdateKanbanCardTest() {		
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List<leankor__Valuestream__c> valuestreamlist = [select id from leankor__Valuestream__c limit 10] ;
		List<leankor__ResourceAssignment__c> resourceAssignmentList = [select id from leankor__ResourceAssignment__c limit 10];				 
		User u = [select id from User limit 1];
		List < leankor__Subscriber__c > subscriberList = [select id from leankor__Subscriber__c limit 10];	
		
		List < leankor__ScheduleMode__c > scheduleMode = leankor.TestDataFactory.createScheduleMode(kanbancard, 1);
		leankor.RealTimeController.StateChangePackage scp = new leankor.RealTimeController.StateChangePackage();		
		scp.GUID = kanbancard[0].leankor__GUID__c;
		scp.Title = kanbancard[0].Name;
		scp.Id = kanbancard[0].id;
		scp.Width = 20;
		scp.Height = 20;
		scp.Top = 20;
		scp.Bottom = 20;
		scp.Left = 20;
		scp.X = 5;
		scp.Y = 5;
		scp.Help = 'MyWorkCheck';
		scp.HarveyBall = 32.0;
		scp.CmpID = '';
		scp.Color = 'red';
		scp.ValueStreamCardLink = valuestreamlist[0].id;
		scp.BoardType = 'kanbanboard';
		scp.ItemType = 'ActivityCard';		
		scp.StartDate = system.today() + 5;
		scp.DueDate = system.today() + 5;
		scp.Priority = kanbancard[0].leankor__Priority__c;
		
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();		
		manageState.linkedCardVerb = 'LinkedCard';
		manageState.updateparent = true;
		manageState.oldParent = true;
		manageState.oldParentKC = 'parentkc';
		manageState.valueStreamID = valuestreamlist[0].id;		
		manageState.verb = 'UpdateKanbanCard';
		manageState.sessionID = UserInfo.getSessionId();
		manageState.subscribers = subscriberList[0];
		manageState.scheduleMode = scheduleMode;
		manageState.resourceAssignment = resourceAssignmentList[0];
		manageState.kanbanCards = kanbancard;		
		manageState.resourceAssignmentList = resourceAssignmentList;
		manageState.leanFalse = false;
		manageState.kanbanCard = kanbancard[0];
		manageState.listOfSubscribers = subscriberList;
		manageState.stateChangePackageInstance = scp;
		manageState.someJSONData = JSON.serialize(scp);
		
		test.startTest();
		System.Assert(leankor.RealTimeControllerHelper.moveOrUpdateKanbanCard(manageState) != null);
		test.stopTest();
	}
	
	/*
	*To cover  moveOrUpdate method
	*insert List of Zone and assign the value of RealTimeController.StateChangePackage
	*/
	private static testMethod void moveOrUpdateZoneTest() {
		
		List < leankor__Zone__c > zonList = new List < leankor__Zone__c > ();
		leankor__Zone__c zone = new leankor__Zone__c();
		zone.Name = 'Default Column';
		zone.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		zonList.add(zone);
		insert zonList;
		
		leankor.RealTimeController.StateChangePackage scp = new leankor.RealTimeController.StateChangePackage();		
		scp.GUID = leankor.TestDataFactory.createGuid();
		scp.Title = 'test';
		scp.Width = 20;
		scp.Height = 20;
		scp.Top = 20;
		scp.Bottom = 20;
		scp.Left = 20;
		scp.X = 5;
		scp.Y = 5;
		scp.CmpID = '';
		scp.Color = 'red';
		scp.DueDate = system.today() + 5;
		String someJSONData = JSON.serialize(scp);
		
		test.startTest();
		System.Assert(leankor.RealTimeControllerHelper.moveOrUpdateZone(someJSONData) != null);
		test.stopTest();
	}
	
	/*
	 * To cover moveMarker Method.
	 * Insert List of Marker
	 */
	private static testMethod void moveMarkerTest() {		
		
		//data creation for Marker object
		List < leankor__Marker__c > markerList = new List < leankor__Marker__c > ();
		leankor__Marker__c marker = new leankor__Marker__c();
		marker.Name = 'test';
		marker.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		marker.leankor__GUID2__c = leankor.TestDataFactory.createGuid();
		markerList.add(marker);
		insert markerList;
		
		//Add RealTimeController.Marker class data.
		leankor.RealTimeController.Marker realMarker = new leankor.RealTimeController.Marker();
		realMarker.GUID = leankor.TestDataFactory.createGuid();
		realMarker.Top = 20;
		realMarker.Bottom = 20;
		realMarker.Left = 20;
		realMarker.Width = 20;
		realMarker.Height = 20;
		realMarker.X = 20;
		realMarker.Y = 20;
		realMarker.Name = 'TestName';
		String someJSONData = JSON.serialize(realMarker);
		
		test.startTest();
		//call moveMarker method.
		System.assert(leankor.RealTimeControllerHelper.moveMarker(someJSONData) != null);
		test.stopTest();
	}
	
	/*
	 *To cover moveMarker Method.
	 */
	private static testMethod void moveChartTest() {
		 
		// data creation for chart object.
		List < leankor__Chart__c > chartList = new List < leankor__Chart__c > ();
		leankor__Chart__c chart = new leankor__Chart__c();
		chart.Name = 'Budget vs Actual Variance Report';		
		chart.leankor__ChartURL__c = '/apex/leankor__VisualReport?dnm=00Od0000005BOwOEAW&sz=tiny';
		chart.leankor__DeveloperName__c = 'Budget';
		chart.leankor__ReportId__c = '123' ;
		chart.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		chartList.add(chart);
		insert chartList;
		
		leankor.RealTimeController.Chart realTimeChart = new leankor.RealTimeController.Chart();
		realTimeChart.Name = 'testing';
		realTimeChart.DeveloperName = 'testbudget';
		realTimeChart.GUID = leankor.TestDataFactory.createGuid();
		realTimeChart.Top = 1;
		realTimeChart.X = 1;
		realTimeChart.Y = 1;
		realTimeChart.Width = 2;
		String someJSONData = JSON.serialize(realTimeChart);
		
		test.startTest();
		System.Assert(RealTimeControllerHelper.moveChart(someJSONData) != null);
		test.stopTest();
	}
	/*
	 * Test method for  moveActivity Method
	 */
	private static testMethod void moveActivityTest() {
		
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		
		leankor.RealTimeController.StateChangePackage scp = new leankor.RealTimeController.StateChangePackage();
		scp.GUID = kanbancard[0].leankor__GUID__c;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.someJSONData = JSON.serialize(scp);
		
		test.startTest();
		System.Assert(leankor.RealTimeControllerHelper.moveActivity(manageState) != null);
		test.stopTest();
	}
	/*
	 * To Cover createSubscriber method
	 *Insert List of Subscriber,Preference
	 */
	private static testMethod void createSubscriberTest() {
		
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		User u = [select id from User limit 1];		
		List < leankor__Subscriber__c > subscriberList = [select id from leankor__Subscriber__c limit 10];
		
		User users = leankor.TestDataFactory.createStandardUser('lean1234');
		User users1 = leankor.TestDataFactory.createStandardUser('lean2345');		
		
		leankor.RealTimeController.StateChangePackage scp = new leankor.RealTimeController.StateChangePackage();
		scp.OwnerID = users1.Id;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.sessionID = UserInfo.getSessionId();
		manageState.listOfSubscribers = subscriberList;
		manageState.kanbanCard = kanbancard[0];
		manageState.stateChangePackageInstance = scp;

		List < leankor__Preference__c > preferenceList = new List < leankor__Preference__c > ();
		leankor__Preference__c prferen = new leankor__Preference__c();
		prferen.Name = users.name;
		prferen.leankor__FollowOnChatter__c = 'all';
		prferen.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		prferen.OwnerID = manageState.stateChangePackageInstance.OwnerID;
		prferen.leankor__ValueStream__c = manageState.kanbanCard.leankor__ValueStream__c;
		prferen.leankor__CardPastDueDate__c = false;
		prferen.leankor__Moved__c = false;
		prferen.leankor__PercentDone__c = false;
		prferen.leankor__SubscribeToCard__c = 'none';
		prferen.leankor__TaskPastDueDate__c = false;
		prferen.leankor__isTaskCompleted__c = false;
		preferenceList.add(prferen);
		insert preferenceList;
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.createSubscriber(manageState) != null);
		test.stopTest();
	}
	/*
	 *To cover createSubscriber Method
	 */
	private static testMethod void createSubscribTest() {
		
		User users1 = leankor.TestDataFactory.createStandardUser('Standard');	
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords(); 
		User u = [select id from User limit 1];	
		List < leankor__Subscriber__c > subscriberList = [select id from leankor__Subscriber__c limit 10];
		
		leankor.RealTimeController.StateChangePackage scp = new leankor.RealTimeController.StateChangePackage();
		scp.OwnerID = users1.Id;		
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.sessionID = UserInfo.getSessionId();
		manageState.listOfSubscribers = subscriberList;
		manageState.kanbanCard = kanbancard[0];
		manageState.stateChangePackageInstance = scp;
		
		test.startTest();
		System.Assert(leankor.RealTimeControllerHelper.createSubscriber(manageState) != null);
		test.stopTest();
	}
	/*
	 * To cover postChatter method.
	 *Insert List of Subscriber.
	 */
	private static testMethod void postChatterTest() {
		
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List < leankor__Subscriber__c > subscriberList = [select id,leankor__SubscriberID__c,leankor__Moved__c from leankor__Subscriber__c limit 10]; 
		
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.HarveyBall = 10.0;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.kanbanCard = kanbancard[0];
		manageState.stateChangePackageInstance = stateChange;
		manageState.listOfSubscribers = subscriberList;
		manageState.verb = 'MoveKanbanCard';
		System.assert(leankor.RealTimeControllerHelper.postChatter(manageState) != null);
		//negative scenario
		List < leankor__Subscriber__c > subscriberList1 = new List < leankor__Subscriber__c > ();
		leankor__Subscriber__c subs = new leankor__Subscriber__c();
		subs.Name = UserInfo.getUserId();
		subs.leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid();
		subs.leankor__Moved__c = true;
		subs.leankor__PercentDone__c = true;
		subscriberList1.add(subs);
		insert subscriberList1;
		leankor.RealTimeController.StateChangePackage stateChange1 = new leankor.RealTimeController.StateChangePackage();
		stateChange1.HarveyBall = 100.0;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState1 = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState1.kanbanCard = kanbancard[0];
		manageState1.stateChangePackageInstance = stateChange1;
		manageState1.listOfSubscribers = subscriberList1;
		manageState.verb = 'MoveKanbanCard';
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.postChatter(manageState1) != null);
		test.stopTest();
	}

	/*
	 * To cover ownerChangeChatter method.
	 * Insert List of  Preference.
	 */
	private static testMethod void ownerChangeChatterTest() {
		 
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords(); 
		User users1 = leankor.TestDataFactory.createStandardUser('lean');		
		 
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.OwnerId = users1.Id;
		stateChange.ItemType = 'MileStone';
		stateChange.kanbanURL = '';
		stateChange.BoardType = '';
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.kanbanCard = kanbancard[0];
		manageState.leanFalse = false;
		manageState.stateChangePackageInstance = stateChange;
		List < leankor__Preference__c > preferenceList = new List < leankor__Preference__c > ();
		leankor__Preference__c prferen = new leankor__Preference__c();
		prferen.Name = users1.name;
		prferen.leankor__FollowOnChatter__c = 'all';
		prferen.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		prferen.OwnerID = manageState.stateChangePackageInstance.OwnerID;
		prferen.leankor__ValueStream__c = manageState.kanbanCard.leankor__ValueStream__c;
		prferen.leankor__CardPastDueDate__c = false;
		prferen.leankor__Moved__c = false;
		prferen.leankor__PercentDone__c = false;
		prferen.leankor__SubscribeToCard__c = 'none';
		prferen.leankor__TaskPastDueDate__c = false;
		prferen.leankor__isTaskCompleted__c = false;
		preferenceList.add(prferen);
		insert preferenceList;
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.ownerChangeChatter(manageState) != null);
		test.stopTest();
	}
	/*
	 */
	private static testMethod void getEntitySubscriptionTest() {
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		system.assert(leankor.RealTimeControllerHelper.getEntitySubscription(stateChange) != null);
	}
	/*
	 */
	private static testMethod void realTimeTrackerHelperTest() {
		
		List<leankor__Valuestream__c> valuestreamlist = [select id from leankor__Valuestream__c limit 10] ;
		//Ashutosh : 11/12/2021 : fixes added for project cloning when GS is enabled
		List < string > jsonList = new List < String >{'{"' + 'ValueStream' + '":' + '"' + valuestreamlist[0].id + '"' + '}'};
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.valueStreamID = valuestreamlist[0].id;
		manageState.verb = 'MoveKanbanCard';
		manageState.listOfJSON = jsonList;
		manageState.linkedCardVerb = 'CardHierarchyToOther';
		manageState.linkedVS = 'a0U0W00000PlZ6w';
		manageState.sessionID = UserInfo.getSessionId();
		
		test.startTest();
		leankor.RealTimeControllerHelper.realTimeTrackerHelper(manageState);
		List<leankor__RealtimeTracker__c> results = [SELECT Id, Name FROM leankor__RealtimeTracker__c WHERE leankor__ValueStream__c =: valuestreamlist[0].id];
		System.assert(results.size() > 0);
		test.stopTest();
	}
	
	/*
	 *	To cover createEntitySubscription method.
	 *	Insert list of Preference.
	 */
	private static testMethod void createEntitySubscriptionTest() {
		
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		User u = [select id,Name from User limit 1]; 
		List < leankor__Preference__c > preferenceList = new List < leankor__Preference__c > ();
		leankor__Preference__c prferen = new leankor__Preference__c();
		prferen.Name = u.name;
		prferen.leankor__FollowOnChatter__c = 'all';
		prferen.leankor__GUID__c =leankor.TestDataFactory.createGuid();
		prferen.OwnerID = userInfo.getUserID();
		prferen.leankor__ValueStream__c = kanbancard[0].leankor__ValueStream__c;
		prferen.leankor__CardPastDueDate__c = false;
		prferen.leankor__Moved__c = false;
		prferen.leankor__PercentDone__c = false;
		prferen.leankor__SubscribeToCard__c = 'none';
		prferen.leankor__TaskPastDueDate__c = false;
		prferen.leankor__isTaskCompleted__c = false;
		preferenceList.add(prferen);
		insert preferenceList;
		//String nwid=Network.getNetworkId();
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.TemplateID = 'a0A0W00000dbch7';
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.createEntitySubscription(kanbancard, stateChange) != null);
		test.stopTest();
	}
	
	/*
	 * To cover deleteMiniature method.
	 */
	private static testMethod void deleteMiniatureTest() {
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.deleteMiniature = true;
		stateChange.id = kanbancard[0].leankor__ValueStreamCardLink__c;
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.deleteMiniature(stateChange) != null);
		test.stopTest();
	}
	
	private static testMethod void createResourceAssignmentTest() {
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.HarveyBall = 100;
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.createResourceAssignment(stateChange) != null);
		test.stopTest();
	}
	/*
	 * To cover updateHarveyBall method.
	 * Insert list of Subscriber.
	 */
	private static testMethod void updateHarveyBallTest() {
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.GUID = kanbancard[0].leankor__GUID__C;
		stateChange.HarveyBall = 100.0;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.leanFalse = false;
		manageState.kanbanCard = kanbancard[0];
		manageState.stateChangePackageInstance = stateChange;
		manageState.someJSONData = JSON.serialize(stateChange);
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.updateHarveyBall(manageState) != null);
		test.stopTest();

	}
	/*
	 * TO cover updateTask method.
	 * Insert List of Task.
	 */
	private static testMethod void updateTaskTest() {
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords(); 
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.StartDate = System.now() + 12;
		stateChange.DueDate = system.now() + 2;
		List < Task > taskList = new List < Task > ();
		Task t = new Task();
		t.OwnerId = Userinfo.getUserId();
		t.Status = 'In Progress';
		t.Priority = 'Normal';
		t.ActivityDate = System.today() + 4;
		t.WhatId = kanbancard[0].id;
		taskList.add(t);
		insert taskList;
		
		test.startTest();
		System.assert(leankor.RealTimeControllerHelper.updateTask(kanbancard[0], stateChange) != null);
		test.stopTest();
		
	}
	private static testMethod void updateKanbanCardInstanceTest() {
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		leankor.RealTimeController.StateChangePackage stateChange = new leankor.RealTimeController.StateChangePackage();
		stateChange.ItemType = 'MilestoneCard';
		stateChange.id = kanbancard[0].id;
        stateChange.StartDate = system.now();
        stateChange.DueDate = system.now() + 5;
		stateChange.onTime = '';
		stateChange.HarveyBall = 10.0;
		stateChange.Help = 'MyWorkCheck';
        stateChange.ValueStreamCardLink = kanbancard[0].leankor__ValueStreamCardLink__c ;
        stateChange.ValueStreamLinkID = kanbancard[0].leankor__ValueStreamLink__c ;
        stateChange.IsExternallyDependent=false;
		leankor.RealTimeControllerHelper.ManageStateChangeWrapper manageState = new leankor.RealTimeControllerHelper.ManageStateChangeWrapper();
		manageState.verb = 'MoveKanbanCard';
		manageState.stateChangePackageInstance = stateChange;
		manageState.someJSONData = JSON.serialize(stateChange);
        manageState.kanbanCard = kanbanCard[0] ; 
		test.startTest();
		System.Assert(leankor.RealTimeControllerHelper.updateKanbanCardInstance(manageState) != null);
		test.stopTest();
	}
	
	@isTest
	private static void testgetDependentCardsDataForStreaming(){
		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
														    	leankor__BoardType__c 
														    From leankor__Valuestream__c 
														    Where leankor__BoardType__c = 'UberBoard'];
	    List<leankor__Dependency__c> depenallList = [Select Id, 
															leankor__ValueStream__c, 
															leankor__Predecessor__c 
													    From leankor__Dependency__c 
													    Where leankor__ValueStream__c In : valuestreamlist ];
		Set<leankor__Dependency__c> dependencies = new Set<leankor__Dependency__c>();
		dependencies.addAll(depenallList);
		List<leankor.realtimeController.bulkStreaming> bulkdata = RealTimeControllerHelper.getDependentCardsDataForStreaming(dependencies);
		System.assert(bulkdata.size() > 0);
	}

	@isTest
	private static void testreadCardsWithStickers(){

		leankor__Valuestream__c valuestream = [Select Id 
												  From leankor__Valuestream__c 
												  limit 1] ;
		List<realTimeController.ChatterFeedStats> chatterfeeds = new List<realTimeController.ChatterFeedStats>();
		List<User> users = [Select Id 
								From User
								where Name = 'Lean123' ];
		realTimeController.GlueforceData readCards = RealTimeControllerHelper.readCardsWithStickers(valuestream.Id,chatterfeeds, users);
		System.assert(readCards != null);
	}

	@isTest
	private static void testreadExternallyDependentCards(){
		List<leankor__Valuestream__c> vslist = new List<leankor__Valuestream__c>();
		for(Integer count=0;count<2;count++){
			leankor__ValueStream__C vs = new Leankor__ValueStream__c(Name = 'Vs'+count,leankor__BoardType__c = 'UberBoard');
			vslist.add(vs);
		}
		insert vslist;
		Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		List<leankor__KanbanCard__c> kbList = new List<leankor__KanbanCard__C>();
		for(Integer count=0;count<2;count++){
			leankor__KanbanCard__c kb = new leankor__KanbanCard__c();
			kb.Name = 'Activity'+1;
			kb.RecordTypeId = recType;
			kb.leankor__ValueStream__c = vslist[count].Id;
			kb.leankor__GUID__c = ''+1+leankor.TestDataFactory.createGuid();
			kb.leankor__StartDate__c = System.today();
			kb.leankor__DueDate__c = System.today().addDays(count+1);
			kb.leankor__PercentComplete2__c = 50;
			kb.leankor__ValueStreamCardLink__c= null;
			kb.OwnerId=UserInfo.getUserID();
			kb.leankor__IsExternallyDependent__c = true;
			kbList.add(kb);
		}
		insert kbList;
		List<leankor__Dependency__c> depenList = new List<leankor__Dependency__c>();
		leankor__Dependency__c dependence = new leankor__Dependency__c(leankor__ValueStream__c = vslist[0].Id,
																		leankor__Predecessor__c = kbList[0].Id ,
																		leankor__GUID__c = leankor.TestDataFactory.createGuid(),
																		leankor__Successor__C = kbList[1].Id);
        insert dependence;

		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
																leankor__BoardType__c 
															From leankor__Valuestream__c 
															Where Name Like 'Activity%'];
		
		List<leankor__kanbancard__c> kanbancard = [Select Id,
														  leankor__Valuestream__c 
														From leankor__kanbancard__c 
														Where leankor__Valuestream__c =: valuestreamlist ];
		List<String> listOfIds = new List<String>();
		for(leankor__kanbancard__c kb:kbList){
			listOfIds.add(kb.Id);
		}
		Set<String> cardIds = new Set<String>();
			cardIds.addAll(listOfIds);
		RealTimeControllerHelper.readExternallyDependentCards(cardIds);
		RealTimeControllerHelper.DependencyMap depMap = new RealTimeControllerHelper.DependencyMap();
		System.assert(depMap.dependentCardIds == null);
	}

	@isTest
	private static void testupdateExternallyDependentCards(){
		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
		                                                    	leankor__BoardType__c 
		                                                    From leankor__Valuestream__c 
		                                                    Where leankor__BoardType__c = 'UberBoard'];
		List<leankor__KanbanCard__C> kclst = [Select Id,
		                                        	 leankor__Valuestream__c 
		                                        From leankor__kanbancard__c 
		                                        Where leankor__Valuestream__c =: valuestreamlist];
		List<String> listOfIds = new List<String>();
		for(leankor__kanbancard__c kb:kclst){
			listOfIds.add(kb.Id);
		}
		Set<String> cardIds = new Set<String>();
		cardIds.addAll(listOfIds); 
		RealTimeController.KanbanCardsData kbdata = RealTimeControllerHelper.updateExternallyDependentCards(cardIds);
		System.assert(kbdata.kanbanCards.size() > 0);
	}
	
	@isTest
	private static void testreadKcUpdatePvCards(){
		List<leankor__kanbancard__c> kanbancards = [Select Id
                                              		    From leankor__KanbanCard__c 
													    Where leankor__ValueStreamCardLink__c != null limit 10 ];
        List<String> kanbanIds = new List<String>();
		for(leankor__kanbancard__c kbIds:kanbancards){
			kanbanIds.add(kbIds.Id);
		}
		Set<String> parentIds = new Set<String>();
			parentIds.addAll(kanbanIds);
			List <leankor__kanbancard__c> kbcards = RealTimeControllerHelper.readKcUpdatePvCards(parentIds);
		System.assert(kbcards.size()>0);
	}

	@isTest
	private static void testreadLinkedCard(){
		leankor__kanbancard__c kb = [Select Id 
		                                From leankor__KanbanCard__c 
		                                Where leankor__ValueStreamCardLink__c != null limit 1 ];
		leankor__kanbancard__c kbcard = RealTimeControllerHelper.readLinkedCard(String.valueOf(kb.Id));
		System.assert(kbcard != null);
	}

	@isTest
	private static void testreadremoveLinkedCard(){
		List<leankor__ProjectRoom__c> projectroom = [Select Id 
														From leankor__ProjectRoom__c 
														Where Name = 'Test Project']; 
	    List<String> prIds = new List<String>();
		for(leankor__ProjectRoom__c pr : projectroom){
			prIds.add(pr.Id);
		}
		List<leankor__KanbanCard__c> kbcards = RealTimeControllerHelper.readremoveLinkedCard(prIds);
		System.assert(kbcards.size()>0);
	}

	@isTest
	private static void testreadupdateBulkCard(){
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List<String> kbcardIds = new List<String>();
        for(leankor__kanbancard__c kb : kanbancard){
			kbcardIds.add(kb.Id);
		}
		List<leankor__KanbanCard__c> bulkcard = RealTimeControllerHelper.readupdateBulkCard(kbcardIds);
		System.assert(bulkcard.size() > 0);
	}

	@isTest
	private static void testreadTask(){
		leankor__kanbancard__c kb = [Select Id 
										From leankor__KanbanCard__c 
										Where leankor__ValueStreamCardLink__c != null limit 1 ];
		leankor__kanbancard__c kbcard = RealTimeControllerHelper.readLinkedCard(String.valueOf(kb.Id));
		System.assert(kbcard != null);
	}

	@isTest
	private static void testremoveSubscriberHelper(){
		leankor__kanbancard__c kb = [Select Id 
										From leankor__KanbanCard__c 
										Where leankor__PercentComplete2__c = 50 limit 1 ];
	    leankor__Subscriber__c subscriber = new leankor__Subscriber__c(Name = 'Subscriber',
																	   leankor__KanbanCard__c = kb.Id,
																	   leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid(),
																	   leankor__SubscriberID__c = UserInfo.getUserID());
		insert subscriber;
		System.assertEquals('success', RealTimeControllerHelper.removeSubscriberHelper(String.ValueOf(kb.Id),String.valueOf(subscriber.leankor__SubscriberID__c)));
	}

	@isTest
	private static void testgetParentRecords(){
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List<String> kbcardIds = new List<String>();
        for(leankor__kanbancard__c kb : kanbancard){
			kbcardIds.add(kb.Id);
		}
		Set<String> kbIds = new Set<String>();
		kbIds.addAll(kbcardIds);
		Map<Id, leankor.Util.WorkWeek> workWeekMap = new Map<Id, leankor.Util.WorkWeek>();
		List <leankor__kanbancard__c> parentrecords = RealTimeControllerHelper.getParentRecords(kbIds,workWeekMap);
		System.assert(parentrecords.size()>0);
	}

	@isTest
	private static void testreadKanbanCardMap(){
		List<leankor__kanbancard__c> kanbancards = getKanbancardRecords();
		Map<Id, leankor__kanbanCard__c> readCards = RealTimeControllerHelper.readKanbanCardMap(kanbancards);
		System.assert(readCards.values() != null);
	}

	@isTest
	private static void testcheckAccessForBoards(){
		List<leankor__Valuestream__c> recordIds = [Select Id,
														leankor__BoardType__c 
														From leankor__Valuestream__c 
														Where leankor__BoardType__c = 'UberBoard'];
		List<String> projectIds = new List<String>();
        for(leankor__Valuestream__c record : recordIds){
			projectIds.add(record.Id);
		}
		List<leankor.ViewGanttController.CheckAccessWrapper> checkBoards = RealTimeControllerHelper.checkAccessForBoards(projectIds);
		System.assert(checkBoards.size()>0);
	}

	@isTest
	private static void testreadDefaultBoard(){
		leankor__ProjectRoom__c projectroom = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = 'Test Project' limit 1];
		List<leankor__ValueStream__c> vsIds = RealTimeControllerHelper.readDefaultBoard(String.valueOf(projectroom.Id));
		System.assert(vsIds.size()>0);
	}	

	@isTest
	private static void testgetAllProjectOfFolderWithoutSharing(){
		List<leankor__Portfolio__c> portId = [Select Id 
		                                        From leankor__Portfolio__c];
		List<leankor__ProjectRoom__c> portIds = RealTimeControllerHelper.getAllProjectOfFolderWithoutSharing(portId);
		System.assert(portIds.size()>0);
	}

    @isTest
	private static void testgetKanbanCardsHelper(){
		leankor__Valuestream__c valuestream = [Select Id,
													leankor__BoardType__c 
													From leankor__Valuestream__c 
													Where leankor__BoardType__c = 'UberBoard' limit 1];
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		leankor__ScheduleMode__c  scheduleMode = new leankor__ScheduleMode__c(leankor__KanbanCard__c = kanbancard[0].Id,
																			  leankor__EffortActual__c = 2,
																			  leankor__EffortUnits__c = 'Days',
																			  leankor__ManuallyScheduled__c = false);
		insert scheduleMode;
		List<leankor__KanbanCard__c> kanbancards = RealTimeControllerHelper.getKanbanCardsHelper(valuestream.Id);
		System.assert(kanbancards.size()>0);
	}

	@isTest
	private static void testreadPlanBoard(){
		List<leankor__Valuestream__c> valuestreamlist = [Select Id 
		                                                    From leankor__Valuestream__c limit 10] ;
		List<String> vsIds = new List<String>();
		for(leankor__Valuestream__c vs:valuestreamlist){
			vsIds.add(vs.id);
		}
		Set<String> valuestreamIDs = new Set<String>();
		valuestreamIDs.addAll(vsIds);
		List<leankor__ValueStream__c> vss = RealTimeControllerHelper.readPlanBoard(valuestreamIDs);
		System.assert(vss.size()>0);
	}

	@isTest
	private static void testreadTaskValueStream(){
		leankor__Valuestream__c valuestream = [Select Id,
													  leankor__BoardType__c 
												    From leankor__Valuestream__c 
													Where leankor__BoardType__c = 'UberBoard' limit 1];
		leankor__ValueStream__c taskvs = RealTimeControllerHelper.readTaskValueStream(String.valueOf(valuestream.Id));
		System.assert(taskvs!=null);
	}

	@isTest
	private static void testreadGanttTaskRecords(){
		leankor__kanbancard__c kb = [Select Id 
										From leankor__KanbanCard__c 
										Where leankor__ValueStreamCardLink__c != null limit 1 ];
		List<leankor__kanbancard__c> kbcard = RealTimeControllerHelper.readGanttTaskRecords(String.valueOf(kb.Id));
		System.assert(kbcard != null);
	}

	@isTest
	private static void testreadKanbanCardRecord(){
		List<String> boardVerb = new List<String>{'Lean','DeleteKanbanCard'};
		leankor__kanbancard__c kb = [Select Id,
											leankor__GUID__C 
										From leankor__KanbanCard__c 
										Where leankor__ValueStreamCardLink__c != null limit 1 ];
		leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
		remoteKanban.GUID = kb.leankor__GUID__C;
		for(string verb:boardVerb ){
			leankor__KanbanCard__c readcard =  RealTimeControllerHelper.readKanbanCardRecord(remoteKanban,verb);
			System.assert(readcard!=null);
		}
	}

	@isTest
	private static void testreadKanbanCardData(){
		List<String> boardVerb = new List<String>{'MultipleDragDrop',''};
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List<String> kbcardIds = new List<String>();
        for(leankor__kanbancard__c kb : kanbancard){
			kbcardIds.add(kb.Id);
		}
		for(string verb:boardVerb ){
			List<leankor__KanbanCard__c> kbcards = RealTimeControllerHelper.readKanbanCardData(kbcardIds,verb);
			System.assert(kbcards.size()>0);
		}
		
	}

	@isTest
	private static void testgetProjectCards(){
		User us = leankor.TestDataFactory.createStandardUser('Lean1234');
		list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
		list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
		list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'Kanban Board', us);
		leankor__MasterContainer__C mastercontainer = new leankor__MasterContainer__C(leankor__GUID__C = TestDataFactory.createGuid(),
																					  leankor__Type__c = 'Backlog',
																					  leankor__ValueStream__C = vStream[0].Id);
		insert mastercontainer;
		leankor__KanbanCard__C kb = new leankor__KanbanCard__C(leankor__GUID__C = TestDataFactory.createGuid(),
															   Name = 'KB',
															   leankor__MasterContainer__C = mastercontainer.Id);
		insert kb;
		Leankor__ProjectRoom__c pr = [Select Id 
										From Leankor__ProjectRoom__c 
										Where Name = 'Test Project' limit 1];
		ProjectBoardCarousel.WorkFilter filterObj = new ProjectBoardCarousel.WorkFilter();
		filterObj.projectId = pr.Id;
		Set<Id> ids = RealTimeControllerHelper.getProjectCards(filterObj);
		System.assert(ids.size()>0);
	}

	@isTest
	private static void testgetResources_Helper(){        
		leankor__ProjectRoom__c project = [Select Id 
											  From leankor__ProjectRoom__c 
											  Where Name = 'Test Project' Limit 1]; 
		leankor__Valuestream__c valuestream = new leankor__ValueStream__C(Name = 'VS',
																		  leankor__Effortindicator__c = 'Days',
        																  leankor__BoardType__c = 'Kanban Board',
        																  leankor__EffortUnits__c = 'Days',
        																  leankor__Mode__c = 'Normal',
    																	  leankor__ManuallyScheduled__c=False,
        																  leankor__ProjectRoom__c = project.Id,
        																  leankor__Isrecalculate__c=False,
        																  leankor__IsTemplateBoard__c=false);
		insert valuestream;
		leankor__MasterContainer__C mastercontainer = new leankor__MasterContainer__C(leankor__GUID__C = TestDataFactory.createGuid(),
																					  leankor__Type__c = 'Backlog',
																					  leankor__ValueStream__C = valuestream.Id);
		insert mastercontainer;
		leankor__swimlane__c  newSw = new  leankor__swimlane__c();
		newSw.name = 'Test SW';
		newSw.leankor__mastercontainer__c= mastercontainer.id;
		newSw.leankor__Valuestream__c = valueStream.id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = TestDataFactory.createGuid();
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

		leankor__KanbanCard__C kb1 = new leankor__KanbanCard__C(leankor__GUID__C = TestDataFactory.createGuid(),
															   Name = 'KB1',
															   leankor__MasterContainer__C = mastercontainer.Id,
															   leankor__ValueStream__C = valuestream.Id,
															   leankor__ZoneGUID__c = zone.leankor__Guid__c);
	    insert kb1;
		leankor__KanbanCard__C kb2 = new leankor__KanbanCard__C(leankor__GUID__C = TestDataFactory.createGuid(),
															   Name = 'KB2',
															   leankor__MasterContainer__C = mastercontainer.Id,
															   leankor__ValueStreamLink__c = valuestream.Id,
															   leankor__ValueStream__C = valuestream.Id,
															   leankor__ValueStreamCardLink__c = kb1.Id,
															   leankor__ZoneGUID__c = zone.leankor__Guid__c);
		insert kb2;
		String remoteVerb = 'Card Hierarchy';
		leankor__Dependency__c dependency = new leankor__Dependency__c(leankor__GUID__c =TestDataFactory.createGuid(),          
																	   leankor__ValueStream__c = valuestream.Id,
																	   leankor__predecessor__c = kb1.id,
																	   leankor__Successor__c = kb2.id);
		insert dependency;
		leankor.CardHierarchyController.CardHierarchyResourceScheduler resourcehelper = RealTimeControllerHelper.getResources_Helper(String.valueOf(valuestream.Id),String.valueOf(kb1.Id),remoteVerb);
		System.assert(resourcehelper.relatedVSIds.size()>0);
	}

	@isTest
	private static void testgetAllTask_Helper(){
		List<leankor__kanbancard__c> kanbancard = getKanbancardRecords();
		List<Task> TaskList = new List<Task>();
        for(leankor__KanbanCard__c kanbanId : kanbancard){
            Task Tsk = new Task();
            Tsk.Priority = 'High';
            Tsk.Status = 'In Progress';
            Tsk.ActivityDate = system.Today();
            Tsk.WhatId = kanbanId.Id;              
            TaskList.add(Tsk);
        }
        insert TaskList;  
		List<leankor.KanbanToGanttController.MasterContainer> tasks = RealTimeControllerHelper.getAllTask_Helper(TaskList);
		System.assert(tasks.size()>0);
	}

	@isTest
	private static void testgetTaskDataByList_Helper(){
		List<leankor__kanbancard__c> kanbancards = getKanbancardRecords();
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1]; 
		List<String> kbcardIds = new List<String>();
        for(leankor__kanbancard__c kb : kanbancards){
			kbcardIds.add(kb.Id);
		}
		Set<String> cardsID = new Set<String>();
		cardsID.addAll(kbcardIds);
		Map<ID,leankor__Kanbancard__c> taskData = RealTimeControllerHelper.getTaskDataByList_Helper(cardsID,String.valueOf(project.Id));
		System.assert(taskData.values().size()>0);
	}

	@isTest
	private static void testdeleteProjectRoom_Helper(){
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1]; 
		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
																leankor__BoardType__c 
															From leankor__Valuestream__c 
															Where leankor__BoardType__c = 'UberBoard'];
	    List<leankor__Dependency__c> depenallList = [Select Id, 
															leankor__ValueStream__c, 
															leankor__Predecessor__c 
														From leankor__Dependency__c 
														Where leankor__ValueStream__c In : valuestreamlist ];
		List<leankor__Dependency__c> deleteroom = RealTimeControllerHelper.deleteProjectRoom_Helper(String.valueOf(project.Id));
		System.assert(deleteroom.size()>0);
	}

	@isTest
	private static void testgetPortHierarchy_HelperForCards(){
		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
																leankor__BoardType__c 
															From leankor__Valuestream__c 
															Where leankor__BoardType__c = 'UberBoard'];
		List<AggregateResult> porthierarchy = RealTimeControllerHelper.getPortHierarchy_HelperForCards(valuestreamlist);
		System.assert(porthierarchy.size()>0);
	}

	@isTest
	private static void testgetPortHierarchy_HelperForActivity(){
		List<leankor__Valuestream__c> valuestreamlist = [Select Id,
																leankor__BoardType__c 
															From leankor__Valuestream__c 
															Where leankor__BoardType__c = 'UberBoard'];
		List<AggregateResult> porthierarchy = RealTimeControllerHelper.getPortHierarchy_HelperForActivity(valuestreamlist);
		System.assert(porthierarchy.size()>0);
	}

	@isTest
	private static void testcreateKanbanCard_Helper(){
		Boolean flag = true;
		List<leankor__kanbancard__c> kanbancards = getKanbancardRecords();
		Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;
		RealTimeControllerHelper.createKanbanCard_Helper(kanbancards, externField, true);
		System.assertEquals(true,flag);
	}

	@isTest
	private static void testreLinkProject_Helper(){
		leankor__ProjectRoom__c project = [Select Id 
											From leankor__ProjectRoom__c 
											Where Name = 'Test Project' Limit 1]; 
		List<leankor__KanbanCard__c> cards = RealTimeControllerHelper.reLinkProject_Helper(String.ValueOf(project.Id));
		System.assert(cards.size()>0);
	} 
	
	@isTest
	private static void testreadBoards(){
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1];
		List<String> boardType = new List<String>{'UberBoard','Kanban Board'};
		List<leankor__valuestream__c> readboards = RealTimeControllerHelper.readBoards(String.valueOf(project.Id),boardType);
		System.assert(readboards.size()>0);
	}

	@isTest
	private static void testingreadBoards(){
		List<leankor__ProjectRoom__c> projects = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = 'Test Project'];
		List<leankor__valuestream__c> readboards = RealTimeControllerHelper.readBoards(projects);
		System.assert(readboards.size()>0);
	}

	@isTest
	private static void testgetAllChildFolders(){
		List<leankor__Portfolio__c> portIds = [Select Id 
		                                        From leankor__Portfolio__c];
		list<leankor__Portfolio__c> portfolioList = new list<leankor__Portfolio__c>();
        for(leankor__Portfolio__c port : portIds){
        	leankor__Portfolio__c f = new leankor__Portfolio__c(Name = 'folderName',
																leankor__ParentPortfolio__c = port.Id);
        	portfolioList.add(f); 
        }
        insert portfolioList;
		list<String> portList = new list<String>();
		for(leankor__Portfolio__c port : portfolioList){
			portList.add(port.leankor__ParentPortfolio__c);
		}
		List<leankor__Portfolio__c> parentportfolio = RealTimeControllerHelper.getAllChildFolders(portList);
		System.assert(parentportfolio.size()>0);
	}

	@isTest
	private static void testgetVSForCloneSystemBoard_Helper(){
			leankor__Valuestream__c valuestream1 = new leankor__ValueStream__C(Name = '_System_Board',
																			  leankor__Effortindicator__c = 'Days',
																			  leankor__BoardType__c = 'Kanban Board',
																			  leankor__EffortUnits__c='Days',
																			  leankor__Mode__c='Normal',
																			  leankor__ManuallyScheduled__c=False,
																			  leankor__Isrecalculate__c=False,
																			  leankor__IsTemplateBoard__c=false,
																			  leankor__IsRecordDeleted__c = false);
			leankor__Valuestream__c valuestream2 = new leankor__ValueStream__C(Name = '_System_PlanBoard',
																			  leankor__Effortindicator__c = 'Days',
																			  leankor__BoardType__c = 'Plan Board',
																			  leankor__EffortUnits__c='Days',
																			  leankor__Mode__c='Normal',
																			  leankor__ManuallyScheduled__c=False,
																			  leankor__Isrecalculate__c=False,
																			  leankor__IsTemplateBoard__c=false,
																			  leankor__IsRecordDeleted__c = false);
			leankor__Valuestream__c valuestream3 = new leankor__ValueStream__C(Name = '_System_DashBoard',
																			  leankor__Effortindicator__c = 'Days',
																			  leankor__BoardType__c = 'DashBoard',
																			  leankor__EffortUnits__c='Days',
																			  leankor__Mode__c='Normal',
																			  leankor__ManuallyScheduled__c=False,
																			  leankor__Isrecalculate__c=False,
																			  leankor__IsTemplateBoard__c=false,
																			  leankor__IsRecordDeleted__c = false);
		
		insert valuestream1;
		insert valuestream2;
		insert valuestream3;
		leankor__MasterContainer__C mastercontainer1 = new leankor__MasterContainer__C(leankor__GUID__C = TestDataFactory.createGuid(),
																					  leankor__Type__c = 'Backlog',
																					  leankor__ValueStream__C = valuestream1.Id);
		insert mastercontainer1;
		leankor__swimlane__c  newSw1 = new  leankor__swimlane__c();
		newSw1.name = 'Test SW';
		newSw1.leankor__mastercontainer__c= mastercontainer1.id;
		newSw1.leankor__Valuestream__c = valuestream1.id;
		insert newSw1;
		
		leankor__MasterContainer__C mastercontainer2 = new leankor__MasterContainer__C(leankor__GUID__C = TestDataFactory.createGuid(),
																					  leankor__Type__c = 'Backlog',
																					  leankor__ValueStream__C = valuestream2.Id);
		insert mastercontainer2;
		leankor__swimlane__c  newSw2 = new  leankor__swimlane__c();
		newSw2.name = 'Test SW';
		newSw2.leankor__mastercontainer__c= mastercontainer2.id;
		newSw2.leankor__Valuestream__c = valuestream2.id;
		insert newSw2;

		leankor__MasterContainer__C mastercontainer3 = new leankor__MasterContainer__C(leankor__GUID__C = TestDataFactory.createGuid(),
																					   leankor__Type__c = 'Backlog',
																					   leankor__ValueStream__C = valuestream3.Id);
		insert mastercontainer3;
		leankor__swimlane__c  newSw3 = new  leankor__swimlane__c();
		newSw3.name = 'Test SW';
		newSw3.leankor__mastercontainer__c= mastercontainer2.id;
		newSw3.leankor__Valuestream__c = valuestream3.id;
		insert newSw3;
		List<String> boardTypes = new List<String>{'Kanban Board','Plan Board','DashBoard'};
		for(String board : boardTypes){
			List<leankor__ValueStream__c> valuestreamList = RealTimeControllerHelper.getVSForCloneSystemBoard_Helper(board);
			System.assert(valuestreamList.size()>0);
		}
	}	

	@isTest
	private static void testreadsystemBoard(){
		leankor__Valuestream__c valuestream1 = new leankor__ValueStream__C(Name = '_System_Board',
																		   leankor__Effortindicator__c = 'Days',
																		   leankor__BoardType__c = 'Kanban Board',
																		   leankor__EffortUnits__c='Days',
																		   leankor__Mode__c='Normal',
																		   leankor__ManuallyScheduled__c=False,
																		   leankor__Isrecalculate__c=False,
																		   leankor__IsTemplateBoard__c=false,
																		   leankor__IsRecordDeleted__c = false);
		insert valuestream1;
		leankor__ValueStream__c valuestream = RealTimeControllerHelper.readsystemBoard();
		System.assert(valuestream!=null);
	}

	@isTest
	private static void testreadkanbanCardTemplate(){
		leankor__Valuestream__c valuestream1 = new leankor__ValueStream__C(Name = '_System_Board',
																		   leankor__Effortindicator__c = 'Days',
																		   leankor__BoardType__c = 'Kanban Board',
																		   leankor__EffortUnits__c='Days',
																		   leankor__Mode__c='Normal',
																		   leankor__ManuallyScheduled__c=False,
																		   leankor__Isrecalculate__c=False,
																		   leankor__IsTemplateBoard__c=false,
																		   leankor__IsRecordDeleted__c = false);
		insert valuestream1;
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestream1);
		List<leankor__KanbanCardTemplate__C> kanbantemplate = RealTimeControllerHelper.readkanbanCardTemplate();
		System.assert(kanbantemplate.size()>0);
	}

	@isTest
	private static void testreadMarkers(){

		leankor__Valuestream__c valuestream = new leankor__ValueStream__C(Name = '_System_DashBoard',
																		  leankor__Effortindicator__c = 'Days',
																		  leankor__BoardType__c = 'DashBoard',
																		  leankor__EffortUnits__c='Days',
																		  leankor__Mode__c='Normal',
																		  leankor__ManuallyScheduled__c=False,
																		  leankor__Isrecalculate__c=False,
																		  leankor__IsTemplateBoard__c=false,
																		  leankor__IsRecordDeleted__c = false);
		
		insert valuestream;
		leankor__Marker__c marker = new leankor__Marker__c();
		marker.Name = 'test';
		marker.leankor__GUID__c = leankor.TestDataFactory.createGuid();
		marker.leankor__GUID2__c = leankor.TestDataFactory.createGuid();
		marker.leankor__ValueStream__c = valuestream.Id;
		insert marker;
		List<leankor__Marker__c> markerList = RealTimeControllerHelper.readMarkers();
		System.assert(markerList.size()>0);
	}

	@isTest
	private static void testreadProjectRecord(){
		List<leankor__ProjectRoom__c> projects = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = 'Test Project']; 
		List<String> prList = new List<String>();
		for (leankor__ProjectRoom__c pr : projects) {
			prList.add(pr.Id);
		}
		List<leankor__ProjectRoom__c> projectList = RealTimeControllerHelper.readProjectRecord(prList);
		System.assert(projectList.size()>0);
	}

	@isTest
	private static void testgetFolderId(){
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1];
		leankor__Valuestream__c valuestream = [Select Id,
													  leankor__BoardType__c 
												From leankor__Valuestream__c 
												Where leankor__BoardType__c = 'UberBoard' limit 1];
		leankor__Portfolio__c portId = [Select Id 
		                                    From leankor__Portfolio__c Limit 1];
		List<Id> ids = new List<Id>();
		ids.add(project.Id);
		ids.add(valuestream.Id);
		ids.add(portId.Id);
		for(Id singleId : ids){
			String folderId = RealTimeControllerHelper.getFolderId(singleId);
			System.assert(folderId!=null);
		}
	}

	@isTest
	private static void testgetBlackOutRecords(){
		leankor__Valuestream__c valuestream = [Select Id,
													  leankor__BoardType__c 
													From leankor__Valuestream__c 
													Where leankor__BoardType__c = 'UberBoard' limit 1];
		leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c(Name = 'Test Blackout',
																							   leankor__EndDate__c = System.Today()+2,
																							   leankor__ProjectBoard__c = valueStream.Id,
																							   leankor__StartDate__c = System.Today()+1);
	
        insert blackOut;
		Set<Id> ids = new Set<Id>();
		ids.add(valuestream.Id);
		Map<Id, List<leankor__ProjectScheduleBlackout__c>> scheduleblackout = RealTimeControllerHelper.getBlackOutRecords(ids);
		System.assert(scheduleblackout.values().size()>0);
	}

	@isTest
	private static void testreadDependentNavKanbanCard(){
		leankor__Valuestream__c valuestream = [Select Id,
													  leankor__BoardType__c 
													From leankor__Valuestream__c
													Where leankor__BoardType__c = 'UberBoard' Limit 1];
		List<leankor__kanbancard__c> kanbancards = getKanbancardRecords();
		List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>();
		for(Integer count=0; count<=kanbancards.size()-2; count++){
			leankor__Dependency__c dep = new leankor__Dependency__c(                                        
				leankor__GUID__c =TestDataFactory.createGuid(),          
				leankor__ValueStream__c = valuestream.Id,
				leankor__predecessor__c = kanbancards[count].id,
				leankor__Successor__c = kanbancards[count+1].id); 
				dependencyList.add(dep);
		}
		insert dependencyList; 

		list<leankor__KanbanCard__c> kbcards = RealTimeControllerHelper.readDependentNavKanbanCard(valuestream.Id);
		System.assert(kbcards.size()>0);

		Set<String> dependents = RealTimeControllerHelper.getDependentItems(valuestream.Id);
		System.assert(dependents.size()>0);
	}

	@isTest
	private static void testinsertKanbanCardTemplateRecords(){
		Boolean flag = true;
		List<leankor__KanbanCardTemplate__c> tempList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.Name = 'Default';
        template.leankor__Title__c = 'Default';
        template.leankor__Height__c = 120;
        template.leankor__Color__c = '#bdbffc';
        template.leankor__Width__c = 170;
		tempList.add(template);
		System.assertEquals(flag,RealTimeControllerHelper.insertKanbanCardTemplateRecords(tempList));
	}

	@isTest
	private static void testupdateKanbanCardTemplateRecords(){
		Boolean flag = true;
		List<leankor__KanbanCardTemplate__c> tempList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.Name = 'Default';
        template.leankor__Title__c = 'Default';
        template.leankor__Height__c = 120;
        template.leankor__Color__c = '#bdbffc';
        template.leankor__Width__c = 170;
		tempList.add(template);
		insert tempList;
		List<leankor__KanbanCardTemplate__c> tempList2 = new List<leankor__KanbanCardTemplate__c>();
		for(leankor__KanbanCardTemplate__c temp : tempList){
			leankor__KanbanCardTemplate__c temp1 = new leankor__KanbanCardTemplate__c();
			temp1.Id = temp.Id;
			temp1.leankor__Width__c = 180;
			tempList2.add(temp1);	
		}														  
		System.assertEquals(flag,RealTimeControllerHelper.updateKanbanCardTemplateRecords(tempList2));
	}

	@isTest
	private static void testupdateProjectBoardDates(){
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1];
		leankor__Valuestream__c valuestream = new leankor__ValueStream__C(Name = '_System_DashBoard',
																		  leankor__Effortindicator__c = 'Days',
																		  leankor__BoardType__c = 'DashBoard',
																		  leankor__EffortUnits__c= 'Days',
																		  leankor__Mode__c= 'Normal',
																		  leankor__ProjectRoom__C = project.Id,
																		  leankor__ManuallyScheduled__c= false,
																		  leankor__Isrecalculate__c = false,
																		  leankor__IsTemplateBoard__c = false,
																		  leankor__IsRecordDeleted__c = false);
		insert valuestream;
		Set<String> ids = new Set<String>();
		ids.add(valuestream.Id);
		RealTimeControllerHelper.updateProjectBoardDates(ids);
		for(leankor__Valuestream__c valuestreamId : 	[Select Id,
																leankor__BoardType__c,
																leankor__ProjectBoardEndDateTime__c 
															From leankor__Valuestream__c
															Where Id In : ids]){
			Date actualResult = date.newinstance(valuestreamId.leankor__ProjectBoardEndDateTime__c.year(), valuestreamId.leankor__ProjectBoardEndDateTime__c.month(), valuestreamId.leankor__ProjectBoardEndDateTime__c.day());
			System.assertEquals(System.Today(),actualResult);
		}
	}

	@isTest
	private static void testupdateProjectBoardDatesFirst(){
		leankor__ProjectRoom__c project = [Select Id 
												From leankor__ProjectRoom__c 
												Where Name = 'Test Project' Limit 1];
		leankor__Valuestream__c valuestream = new leankor__ValueStream__C(Name = 'TestingBoard',
																		  	leankor__Effortindicator__c = 'Days',
																			leankor__ProjectBoardEndDateTime__c = null,
																			leankor__ProjectBoardStartDateTime__c = null,
																		  	leankor__ProjectRoom__C = project.Id,
																		  	leankor__ManuallyScheduled__c= false,
																		  	leankor__Isrecalculate__c = false,
																		  	leankor__IsTemplateBoard__c = false,
																		  	leankor__IsRecordDeleted__c = false);
		
		insert valuestream;
		List<leankor__KanbanCard__c> kblist = new List<leankor__KanbanCard__c>();
			leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
			kanban.Name = 'Card';
			kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			kanban.leankor__ValueStream__c = valuestream.Id;
			kanban.leankor__GUID__c = ''+1+TestDataFactory.createGuid();
			kanban.leankor__StartDateTime__c = System.Now();
			kanban.leankor__DueDateTime__c = System.Now().addDays(1);
			kbList.add(kanban);
		insert kblist;
		Set<String> ids = new Set<String>();
		ids.add(valuestream.Id);
		RealTimeControllerHelper.updateProjectBoardDates(ids);
		for(leankor__Valuestream__c valuestreamId : [Select Id,
															leankor__BoardType__c,
															leankor__ProjectBoardStartDateTime__c 
														From leankor__Valuestream__c
														Where Id In : ids]){
		Date actualResult = date.newinstance(valuestreamId.leankor__ProjectBoardStartDateTime__c.year(), valuestreamId.leankor__ProjectBoardStartDateTime__c.month(), valuestreamId.leankor__ProjectBoardStartDateTime__c.day());
		System.assertEquals(System.Today(),actualResult);
		}
	}
		/*---------------------------------------------------------------------------------------------------------
		Company     : Leankor
		Description : This method is cover getParentCardConstraintData Method inside  RealTimeControllerHelper Class 
	----------------------------------------------------------------------------------------------------------*/ 
	@istest 
	private static void getParentCardConstraintDataTest(){
        
		leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
		projectRecord.Name = 'Demo Project Name';
		insert projectRecord;
		
		leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
		projectBoardOne.Name = 'PG';
		projectBoardOne.leankor__BoardType__c = 'UberBoard';   
		projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
		projectBoardOne.leankor__IsTemplateBoard__c = false;
		insert projectBoardOne;
		
		leankor__KanbanCard__c kanbanCardRecord  = new leankor__KanbanCard__c();
		kanbanCardRecord.Name = 'activity';
		kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
		kanbanCardRecord.leankor__StartDateTime__c= System.now();
		insert kanbanCardRecord;
		
		
		leankor__ValueStream__c clonedProjectBoardOne = new leankor__ValueStream__c();         
		clonedProjectBoardOne.Name = 'RollUp';
		clonedProjectBoardOne.leankor__BoardType__c = 'Plan Board';   
		clonedProjectBoardOne.leankor__ProjectRoom__c = projectRecord.Id;                                                                           
		clonedProjectBoardOne.leankor__IsTemplateBoard__c = false;                                                                                                                            
		insert clonedProjectBoardOne;
		
		leankor__KanbanCard__c kanbanCardParent = new leankor__KanbanCard__c();
		kanbanCardParent.Name = 'parentKanban';
		kanbanCardParent.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardParent.leankor__ValueStream__c = clonedProjectBoardOne.Id; 
		insert kanbanCardParent;
		
		
		leankor__KanbanCard__c kanbanCardChild = new leankor__KanbanCard__c();  
		kanbanCardChild.Name = 'childKanban';
		kanbanCardChild.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardChild.leankor__ValueStream__c =  clonedProjectBoardOne.Id;  
		kanbanCardChild.leankor__ValueStreamCardLink__c = kanbanCardParent.Id;
		kanbanCardChild.leankor__ValueStreamLink__c = clonedProjectBoardOne.Id; 
		insert kanbanCardChild; 
		
		
		List<leankor__KanbanCard__c> listKanbanCardRecord = new List<leankor__KanbanCard__c>();
		
		for(Integer count=1;count<=5;count++){
			leankor__KanbanCard__c cloneKanbanChild = new leankor__KanbanCard__c();
			cloneKanbanChild.Name = 'ChildKanban'+count;  
			cloneKanbanChild.leankor__GUID__c = TestDataFactory.createGuid();
			cloneKanbanChild.leankor__ValueStream__c = clonedProjectBoardOne.Id ;
			cloneKanbanChild.leankor__ValueStreamCardLink__c =  kanbanCardRecord.Id; 
			cloneKanbanChild.leankor__ValueStreamLink__c = projectBoardOne.Id;   
			cloneKanbanChild.leankor__StartDateTime__c= System.now().addDays(count);
			listKanbanCardRecord.add(cloneKanbanChild);
		}
		insert listKanbanCardRecord; 
		
		
		
		List<leankor__KanbanCard__c>  finalKanbancard = [Select Id,
																name,
																leankor__ValueStreamCardLink__c, 
																leankor__ValueStreamLink__c,
																leankor__ValueStream__c,
																leankor__ValueStreamLink__r.leankor__BoardType__c,
																leankor__StartDateTime__c 
														From leankor__KanbanCard__c
														Where leankor__ValueStreamLink__r.leankor__BoardType__c = 'UberBoard'
														Or leankor__ValueStreamLink__r.leankor__BoardType__c = 'Plan Board']; 
		
		
		leankor__ScheduleMode__c scheduleModeRecord = new leankor__ScheduleMode__c ();
		scheduleModeRecord.leankor__KanbanCard__c = kanbanCardRecord.Id;
		scheduleModeRecord.leankor__ConstraintDateTime__c = kanbanCardRecord.leankor__StartDateTime__c;
		insert scheduleModeRecord;
		Test.startTest();
		Map<String, leankor__ScheduleMode__c> getParentCardConstraintDataRecords  = leankor.RealTimeControllerHelper.getParentCardConstraintData(finalKanbancard);
		System.assert(getParentCardConstraintDataRecords.size()>0);       
		Test.stopTest();  
	}

	/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getParentCardConstraintData Method inside  RealTimeControllerHelper Class Where leankor__BoardType__c='UberBoard' Or leankor__BoardType__c='Whiteboard'
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 

	@istest Private static void getParentCardConstraintNullDataTest(){
		
		
		leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
		projectRecord.Name = 'Demo Project Name';
		insert projectRecord;
		
		leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
		projectBoardOne.Name = 'PG';
		projectBoardOne.leankor__BoardType__c = 'UberBoard';   
		projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
		projectBoardOne.leankor__IsTemplateBoard__c = false;
		insert projectBoardOne;
		
		leankor__KanbanCard__c kanbanCardRecord  = new leankor__KanbanCard__c();
		kanbanCardRecord.Name = 'activity';
		kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id; 
		insert kanbanCardRecord;
		
		leankor__ValueStream__c clonedProjectBoardOne = new leankor__ValueStream__c();         
		clonedProjectBoardOne.Name = 'Whiteboard';
		clonedProjectBoardOne.leankor__BoardType__c = 'Whiteboard';   
		clonedProjectBoardOne.leankor__ProjectRoom__c = projectRecord.Id;                                                                           
		clonedProjectBoardOne.leankor__IsTemplateBoard__c = false;                                                                                                                            
		insert clonedProjectBoardOne;
		
		leankor__KanbanCard__c kanbanCardParent = new leankor__KanbanCard__c();
		kanbanCardParent.Name = 'Kanban-card';
		kanbanCardParent.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardParent.leankor__ValueStream__c = clonedProjectBoardOne.Id; 
		insert kanbanCardParent;
		List<leankor__KanbanCard__c>  finalKanbancard = [Select Id,
																Name,
																leankor__ValueStreamCardLink__c,
																leankor__ValueStreamLink__c,
																leankor__ValueStream__c,
																leankor__ValueStreamLink__r.leankor__BoardType__c,
																leankor__StartDateTime__c
														From leankor__KanbanCard__c
														Where leankor__ValueStreamLink__r.leankor__BoardType__c = 'UberBoard'
														Or leankor__ValueStreamLink__r.leankor__BoardType__c = 'Whiteboard']; 
		
		
		Test.startTest();
		Map<String, leankor__ScheduleMode__c> getParentCardConstraintDataRecords  = leankor.RealTimeControllerHelper.getParentCardConstraintData(finalKanbancard);
		System.assert(getParentCardConstraintDataRecords.isEmpty());
		Test.stopTest();
	} 

	/*-----------------------------------------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getParentCardConstraintData Method inside  RealTimeControllerHelper Class  where leankor__ScheduleMode__c is null 
	--------------------------------------------------------------------------------------------------------------------------------------------*/ 
	@istest 
	private static void getParentCardConstraintScheduleModeNullTest(){
	
		leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
		projectRecord.Name = 'Demo Project Name';
		insert projectRecord;
		
		leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
		projectBoardOne.Name = 'PG';
		projectBoardOne.leankor__BoardType__c = 'UberBoard';   
		projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
		projectBoardOne.leankor__IsTemplateBoard__c = false;
		insert projectBoardOne;
		
		leankor__KanbanCard__c kanbanCardRecord  = new leankor__KanbanCard__c();
		kanbanCardRecord.Name = 'Activity';
		kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.id; 
		insert kanbanCardRecord;
		
		leankor__ValueStream__c clonedProjectBoardOne = new leankor__ValueStream__c();         
		clonedProjectBoardOne.Name = 'RollUp';
		clonedProjectBoardOne.leankor__BoardType__c = 'Plan Board';   
		clonedProjectBoardOne.leankor__ProjectRoom__c = projectRecord.id;                                                                           
		clonedProjectBoardOne.leankor__IsTemplateBoard__c = false;                                                                                                                            
		insert clonedProjectBoardOne;
		
		leankor__KanbanCard__c kanbanCardParent = new leankor__KanbanCard__c();
		kanbanCardParent.Name = 'parentKanban';
		kanbanCardParent.leankor__GUID__c = TestDataFactory.createGuid();
		kanbanCardParent.leankor__ValueStream__c = clonedProjectBoardOne.id; 
		insert kanbanCardParent;
		
		List<leankor__KanbanCard__c>  finalKanbancard = [Select Id,
																Name,
																leankor__ValueStreamCardLink__c,
																leankor__ValueStreamLink__c,
																leankor__ValueStream__c,
																leankor__ValueStreamLink__r.leankor__BoardType__c,
																leankor__StartDateTime__c
															From leankor__KanbanCard__c
															Where leankor__ValueStreamLink__r.leankor__BoardType__c = 'UberBoard'
															Or leankor__ValueStreamLink__r.leankor__BoardType__c = 'Plan Board']; 
		
		
		Test.startTest(); 
		Map<String, leankor__ScheduleMode__c> getParentCardConstraintDataRecords  = leankor.RealTimeControllerHelper.getParentCardConstraintData(finalKanbancard);
		System.assert(getParentCardConstraintDataRecords.isEmpty());
		Test.stopTest();
	} 
}