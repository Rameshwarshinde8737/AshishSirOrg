/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MultipleMoveKanbanCardAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private class MultipleMoveKanbanCardActionTest {

    @TestSetup
    static void testSetupDate() {
        Id activityRecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        List<leankor__MasterContainer__c> masterContainers = new List<leankor__MasterContainer__c>();
        List<leankor__Swimlane__c> swimlanes = new List<leankor__Swimlane__c>();
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();

        leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert  project;
        
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
        insert valueStream;

        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name= 'Test MC';
        newMasterContainer.leankor__Valuestream__c= valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer ;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test SW';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c = 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c = newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c(
            leankor__JSONDefinition__c = '',
            leankor__JSONData__c = '',
            leankor__Width__c = 170,
            leankor__Height__c = 120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
            leankor__CSSLayout__c = '',
            leankor__Color__c = '#bdbffc',
            leankor__ValueStream__c = valueStream.Id,
            Name = 'Default',
            leankor__Title__c ='Default'
        );
        insert kanbanTemplate;

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c(
            Name = 'Test Blackout',
            leankor__EndDate__c = System.Today() + 20,
            leankor__ProjectBoard__c = valueStream.Id,
            leankor__StartDate__c = System.Today() + 18
        );
        insert blackOut;

        

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for (Integer i = 1 ; i <= 2000; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card ' + i;
			kanbanCard.leankor__MasterContainer__c = newMasterContainer.Id;
			kanbanCard.leankor__Swimlane__c = newSwimlane.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 5 + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			kanbanCard.RecordTypeId = activityRecordTypeId;
			kanbanCards.add(KanbanCard);
            
        }
        
        insert kanbanCards;       

    }
    
    @isTest
    static void testMoveKanbanCardProcessOne() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Title__c, 
                                                        leankor__MasterContainer__c, 
                                                        leankor__Swimlane__c, 
                                                        leankor__Zone__c, 
                                                        leankor__EstimatedDuration__c,
                                                        leankor__StartDateTime__c, 
                                                        OwnerId, 
                                                        leankor__GUID__c, 
                                                        RecordTypeId
                                                    From leankor__KanbanCard__c 
                                                    Limit 10];
        
        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name = 'Backlog Master Container';
        newMasterContainer.leankor__Valuestream__c = valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test Swimlane';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = zone.Id;
        }

        List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();

        kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
        kanbanCardRequest.sendBroadcastMessage = true;
        kanbanCardRequests.add(kanbanCardRequest);

        Test.startTest();
            System.assert(MultipleMoveKanbanCardAction.moveKanbanCardProcess(kanbanCardRequests) == null);
        Test.stopTest();

    } 

    @isTest
    static void testMoveKanbanCardProcessTwo(){
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Title__c, 
                                                        leankor__MasterContainer__c, 
                                                        leankor__Swimlane__c, 
                                                        leankor__Zone__c, 
                                                        leankor__EstimatedDuration__c,
                                                        leankor__StartDateTime__c, 
                                                        OwnerId, 
                                                        leankor__GUID__c, 
                                                        RecordTypeId
                                                    From leankor__KanbanCard__c 
                                                    Limit 50];
        
        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name = 'Backlog Master Container';
        newMasterContainer.leankor__Valuestream__c = valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test Swimlane';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = newSwimlane.Id;
            kc.leankor__Zone__c = null;
        }

        List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();

        kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
        kanbanCardRequests.add(kanbanCardRequest);

        Test.startTest();
            System.assert(MultipleMoveKanbanCardAction.moveKanbanCardProcess(kanbanCardRequests) == null);
        Test.stopTest();

    } 

    @isTest
    static void testMoveKanbanCardProcessThree(){
        
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Title__c, 
                                                        leankor__MasterContainer__c, 
                                                        leankor__Swimlane__c, 
                                                        leankor__Zone__c, 
                                                        leankor__EstimatedDuration__c,
                                                        leankor__StartDateTime__c, 
                                                        OwnerId, 
                                                        leankor__GUID__c, 
                                                        RecordTypeId
                                                    From leankor__KanbanCard__c 
                                                    Limit 1000];
        
        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name = 'Backlog Master Container';
        newMasterContainer.leankor__Valuestream__c = valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test Swimlane';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = newMasterContainer.Id;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = null;
        }

        List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();

        kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
        kanbanCardRequests.add(kanbanCardRequest);

        Test.startTest();
            System.assert(MultipleMoveKanbanCardAction.moveKanbanCardProcess(kanbanCardRequests) == null);
        Test.stopTest();
    }

    @isTest
    static void testMoveKanbanCardProcessFour(){
        
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Title__c, 
                                                        leankor__MasterContainer__c, 
                                                        leankor__Swimlane__c, 
                                                        leankor__Zone__c, 
                                                        leankor__EstimatedDuration__c,
                                                        leankor__StartDateTime__c, 
                                                        OwnerId, 
                                                        leankor__GUID__c, 
                                                        RecordTypeId
                                                    From leankor__KanbanCard__c 
                                                    Limit 2000];
        
        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name = 'Backlog Master Container';
        newMasterContainer.leankor__Valuestream__c = valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test Swimlane';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = newMasterContainer.Id;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = null;
        }

        List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();

        kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
        kanbanCardRequests.add(kanbanCardRequest);

        Test.startTest();
            System.assert(MultipleMoveKanbanCardAction.moveKanbanCardProcess(kanbanCardRequests) == null);
        Test.stopTest();
    }


    @isTest
    static void testMoveKanbanCardProcessWBSAndSequenceNumber() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Title__c, 
                                                        leankor__MasterContainer__c, 
                                                        leankor__Swimlane__c, 
                                                        leankor__Zone__c, 
                                                        leankor__EstimatedDuration__c,
                                                        leankor__StartDateTime__c, 
                                                        OwnerId, 
                                                        leankor__GUID__c, 
                                                        RecordTypeId
                                                    From leankor__KanbanCard__c 
                                                    Limit 10];
        
        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
        newMasterContainer.name = 'Backlog Master Container';
        newMasterContainer.leankor__Valuestream__c = valueStream.id;
        newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMasterContainer;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
        newSwimlane.name = 'Test Swimlane';
        newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
        newSwimlane.leankor__Valuestream__c = valueStream.id;
        newSwimlane.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSwimlane.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = zone.Id;
        }

        List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();

        kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
        kanbanCardRequest.sendBroadcastMessage = true;
        kanbanCardRequest.generateWorkBreakdownStructure = true;
        kanbanCardRequests.add(kanbanCardRequest);

        Test.startTest();
        Assert.isTrue(MultipleMoveKanbanCardAction.moveKanbanCardProcess(kanbanCardRequests) == null, 'Method Executed Successfully.');
        Test.stopTest();
        //verify that 20 cards are present on board 
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
														And leankor__SeriesNumber__c != null
													Limit 50000];
		Assert.isTrue(kanbanCards.size() > 0, 'Method Executed Successfully.');
    } 
}