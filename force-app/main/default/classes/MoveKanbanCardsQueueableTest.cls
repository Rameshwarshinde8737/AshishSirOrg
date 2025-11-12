/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MoveKanbanCardsQueueable.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private class MoveKanbanCardsQueueableTest {

    @testSetup 
	private static void testSetupData() {
		leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;
        
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
		insert valueStream;

        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
		newMC.name= 'Test MC';
		newMC.leankor__Valuestream__c= valueStream.id;
		insert newMC ;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
		newSw.name = 'Test SW';
		newSw.leankor__mastercontainer__c= newMC.id;
		newSw.leankor__Valuestream__c = valueStream.id;
		insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone1';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c(
		    leankor__JSONDefinition__c = '',
		    leankor__JSONData__c = '',
		    leankor__Width__c = 170,
		    leankor__Height__c =120, 
		    leankor__CSSLayout__c = '',
		    leankor__Color__c = '#bdbffc',
		    leankor__ValueStream__c = valueStream.Id,
		    Name = 'Default',
		    leankor__Title__c ='Default'
		);
		insert kanbanTemplate;

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c(
			Name = 'Test Blackout',
			leankor__EndDate__c = System.Today()+20,
			leankor__ProjectBoard__c = valueStream.Id,
			leankor__StartDate__c = System.Today()+18
		);
		insert blackOut;
		
		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		
		// Create KanbanCard(leankor__KanbanCard__c) records.
		for (Integer i = 1 ; i <= 2000 ;i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 5 + i;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if (i <= 20) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			} else if (i > 20 && i < 40) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
			kanbanCards.add(KanbanCard);
            
		}
        insert kanbanCards;	
		
		List<leankor__ZoneKanbanAction__c> zoneKanbanActionList = new List<leankor__ZoneKanbanAction__c>();
		for (leankor__KanbanCard__c card : kanbanCards) {
			leankor__ZoneKanbanAction__c zoneKanbanActions = new leankor__ZoneKanbanAction__c();
			zoneKanbanActions.leankor__KanbanCard2__c = card.id;
			zoneKanbanActions.leankor__Zone2__c = card.leankor__Zone__c;
			zoneKanbanActions.leankor__ValueStream__c = card.leankor__ValueStream__c;
			zoneKanbanActions.leankor__ActionType2__c ='Entered Zone';
			zoneKanbanActionList.add(zoneKanbanActions);
		}
		insert zoneKanbanActionList;
    }
   
	private @isTest
    static void testMoveKanbanCardsQueueableFirst() {
		leankor__ProjectRoom__c project = [Select Id 
                                            From leankor__ProjectRoom__c 
                                            Where name = :'test'];

		leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

		leankor__Zone__c zoneData =    [Select Id, 
                                            Name, 
                                            leankor__Swimlane__c,
                                            leankor__Swimlane__r.leankor__MasterContainer__c 
                                        From leankor__Zone__c 
                                        Where Name = :'Test Zone1'];

		List<String> kanbanIds = new List<String>();
		Map<Id,leankor__Kanbancard__c> mapOfOldzone = new Map<Id,leankor__Kanbancard__c>();
		Map<Id,leankor__Zone__c> kanbanZoneMap = new Map<Id,leankor__Zone__c>();
		Map<Id, Decimal> mapOfTotalTimeTest = new Map<Id, Decimal>();
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
                                                    Where Name = :'Test Kanban' 
                                                    Limit 10];

		List<leankor__ZoneKanbanAction__c> zoneKanbanActions = [Select Id 
																From leankor__ZoneKanbanAction__c 
																Where leankor__KanbanCard2__c In :kanbanCardList];
															

		leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Backlog Master Container';
        newMC.leankor__Valuestream__c = valueStream.id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMC;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test Swimlane';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = valueStream.id;
        newSw.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSw.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
			kanbanZoneMap.put(kc.id,zoneData);
			mapOfOldzone.put(kc.id,kc);
			kanbanIds.add(kc.id);
			mapOfTotalTimeTest.put(kc.id,0.0);
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = zone.id;
        	
        }													

		List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectId = project.id;
		kanbanCardRequest.projectEventCustomPayload = 'Test';
		Boolean isFirstCallToMove = true;
		Test.startTest();
           	System.enqueueJob(new MoveKanbanCardsQueueable(kanbanCardRequest, true));
			MoveKanbanCardsQueueable.createZkaRecordsForRemainingCards(kanbanIds, mapOfOldzone, kanbanZoneMap,zoneKanbanActions, mapOfTotalTimeTest);
		Test.stopTest();
        leankor__KanbanCard__c kanbanZoneId = [Select Id,
                                              			leankor__Zone__c
                                               		From leankor__KanbanCard__c 
													Limit 1];
        System.assertEquals(zone.Id ,kanbanZoneId.leankor__Zone__c);                                                    

	}

	private @isTest
    static void testMoveKanbanCardsQueueableSecond() {
		leankor__ProjectRoom__c project = [Select Id 
                                            From leankor__ProjectRoom__c
                                            Where Name = :'test'];
											
		leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        List<leankor__KanbanCard__c> kanbanCardList = [Select  
                                                        Id, 
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
                                                    Limit 100];

        for (leankor__KanbanCard__c kanbanCard:kanbanCardList) {
            kanbanCard.leankor__PercentComplete2__c = 200;
        }
        update kanbanCardList;                                            

		
		leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Backlog Master Container';
        newMC.leankor__Valuestream__c = valueStream.id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMC;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test Swimlane';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = valueStream.id;
        newSw.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSw.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = null;
			kc.leankor__Valuestream__c = zone.leankor__ValueStream__c;
			kc.leankor__ZoneGUID__c = zone.leankor__GUID__c;
         }													

		List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectId = project.id;
		kanbanCardRequest.projectEventCustomPayload = 'Test';
		Boolean isFirstCallToMove = true;
		Test.startTest();
           	System.enqueueJob(new MoveKanbanCardsQueueable(kanbanCardRequest, true));
		Test.stopTest();
        leankor__KanbanCard__c kanbanguid = [Select Id,
                                                 		leankor__ZoneGUID__c
                                                 	From leankor__KanbanCard__c 
													Limit 1];
        System.assertEquals(zone.leankor__GUID__c ,kanbanguid.leankor__ZoneGUID__c);                                                    
	}

	private @isTest
    static void testMoveKanbanCardsQueueableThird() {
		leankor__ProjectRoom__c project = [Select Id 
                                            From leankor__ProjectRoom__c
                                            Where Name = :'test'];
											
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

		leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Backlog Master Container';
        newMC.leankor__Valuestream__c = valueStream.id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMC;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test Swimlane';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = valueStream.id;
        newSw.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSw.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = newMC.id;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = null;
         }													

		List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectId = project.id;
		kanbanCardRequest.projectEventCustomPayload = 'Test';
		Boolean isFirstCallToMove = true;
		Test.startTest();
           	System.enqueueJob(new MoveKanbanCardsQueueable(kanbanCardRequest, true));
		Test.stopTest();
        leankor__KanbanCard__c kanbanMasterContainer = [Select Id,
                                                            	leankor__mastercontainer__c
                                                            From leankor__KanbanCard__c 
															Limit 1];
        System.assertEquals(newMC.Id ,kanbanMasterContainer.leankor__mastercontainer__c);
	}

	private @isTest
    static void testMoveKanbanCardsQueueableFourth() {
		leankor__ProjectRoom__c project = [Select Id 
											From leankor__ProjectRoom__c
											Where Name =:'test'];
											
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
                                                    Limit 500];

		leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Backlog Master Container';
        newMC.leankor__Valuestream__c = valueStream.id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMC;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test Swimlane';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = valueStream.id;
        newSw.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSw.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = newSw.id;
            kc.leankor__Zone__c = null;
         }													

		List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectId = project.id;
		kanbanCardRequest.projectEventCustomPayload = 'Test';
		Boolean isFirstCallToMove = true;
		Test.startTest();
           	System.enqueueJob(new MoveKanbanCardsQueueable(kanbanCardRequest, true));
		Test.stopTest();
        leankor__KanbanCard__c kanbanSwimLine = [Select Id,
                                                     	leankor__swimlane__c
                                                    From leankor__KanbanCard__c 
													Limit 1];
        System.assertEquals(newSw.Id ,kanbanSwimLine.leankor__swimlane__c);
	}

	private @isTest
    static void testMoveKanbanCardsQueueableFive() {
		leankor__ProjectRoom__c project = [Select Id 
											From leankor__ProjectRoom__c
											Where Name = :'test'];

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

		leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Backlog Master Container';
        newMC.leankor__Valuestream__c = valueStream.id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
        insert newMC;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test Swimlane';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = valueStream.id;
        newSw.leankor__GUID__c = TestDataFactory.createGuid();
        insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'Test Zone';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = TestDataFactory.createGuid();
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= newSw.id;
        zone.leankor__ValueStream__c = valueStream.Id;
        insert zone;

        for (leankor__KanbanCard__c kc : kanbanCardList) {
            kc.leankor__mastercontainer__c = null;
            kc.leankor__swimlane__c = null;
            kc.leankor__Zone__c = null;
            kc.leankor__ZoneGUID__c = zone.leankor__GUID__c;
			
         }													

		List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleMoveKanbanCardAction.KanbanCardRequest>();
        MultipleMoveKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleMoveKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbancardList = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.kanbancardList.addAll(kanbanCardList);
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectId = project.id;
		kanbanCardRequest.projectEventCustomPayload = 'Test';
		Boolean isFirstCallToMove = true;
		Test.startTest();
			System.enqueueJob(new MoveKanbanCardsQueueable(kanbanCardRequest, true));
		Test.stopTest();
        leankor__KanbanCard__c kanbanZoneGUID = [Select Id,
                                                     	leankor__ZoneGUID__c
                                                     From leankor__KanbanCard__c 
													Limit 1];
        System.assertEquals(zone.leankor__GUID__c ,kanbanZoneGUID.leankor__ZoneGUID__c);
	}

}