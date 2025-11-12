@isTest
private class UpdateKanbanCardTest {
	
	@testSetup 
	private static void setupTestData(){
		leankor__projectroom__c project = new leankor__projectroom__c();
		project.Name ='test';
        insert project;
        
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__projectroom__c = project.id; 
		valueStream.leankor__BoardType__C = 'UberBoard'; 
		valueStream.leankor__SevenDayWorkWeek__c = true;
		insert valueStream;

		leankor__Valuestream__c valueStreamForGantt = new leankor__Valuestream__c();
		valueStreamForGantt.Name =  'Testing Plan board'; 
		valueStreamForGantt.leankor__projectroom__c = project.id;
		valueStreamForGantt.leankor__BoardType__C = 'Plan Board';
		insert valueStreamForGantt;

		leankor__KanbanCard__c activityOnGantt = new leankor__KanbanCard__c();
		activityOnGantt.Name =  'Testing card'; 
		activityOnGantt.leankor__ValueStream__c = valueStreamForGantt.id;
		insert activityOnGantt;

        leankor__mastercontainer__c newMasterContainer = new leankor__mastercontainer__c();
		newMasterContainer.name= 'Test newMasterContainer';
		newMasterContainer.leankor__Valuestream__c= valueStream.id;
		insert newMasterContainer ;

        leankor__swimlane__c  newSwimlane = new  leankor__swimlane__c();
		newSwimlane.name = 'Test SW';
		newSwimlane.leankor__mastercontainer__c= newMasterContainer.id;
		newSwimlane.leankor__Valuestream__c = valueStream.id;
		insert newSwimlane; 

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSwimlane.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
		kanbanTemplate.leankor__Height__c =120; 
		kanbanTemplate.leankor__CSSLayout__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c ='Default';
		insert kanbanTemplate;

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today()+20;
		blackOut.leankor__ProjectBoard__c = valueStream.Id;
		blackOut.leankor__StartDate__c = System.Today()+18;
		insert blackOut;
        
		List<leankor__ScheduleMode__c> listSchedualMode = new List<leankor__ScheduleMode__c>();
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer i = 1 ; i <= 20; i++){			
            
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = newMasterContainer.Id;
			kanbanCard.leankor__Swimlane__c = newSwimlane.Id;
			kanbanCard.leankor__Monday__c = false;
			kanbanCard.leankor__Tuesday__c = false;
			kanbanCard.leankor__Wednesday__c = false;
			kanbanCard.leankor__Thursday__c = false;
			kanbanCard.leankor__Friday__c = true;
			kanbanCard.leankor__Saturday__c = false;
			kanbanCard.leankor__Sunday__c = true;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			//KanbanCard.leankor__ValueStreamCardLink__c = activityOnGantt.id;
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');

			if (i <= 5) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			} else if (i > 10 && i < 15) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
                 
			kanbanCards.add(KanbanCard);
        }
        
        insert kanbanCards;       


		leankor__LeanConstants__c Customsetting = 
                new leankor__LeanConstants__c(
					leankor__AllowSchedulingConstraints__c = true
                	);
		insert Customsetting;

	}


	@isTest
    private static void testUpdateKanbanCardFirstMethod(){

		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															leankor__ValueStream__c,
															leankor__DurationUnits__c
														From leankor__KanbanCard__c
														Where (Name = :'Test Kanban'
															And RecordType.Name = :'ActivityCard')
														Limit 10];

        List<Id> kanbanCardIds = new List<Id>();
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();

        for (leankor__kanbanCard__c kanbanCard : kanbanCards) {
            kanbanCardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c kanban = new leankor__kanbanCard__c();
            kanban.Id = kanbanCard.Id;
            kanban.Name = 'Updated Card';
            kanban.leankor__DueDateTime__c = Date.today().addDays(7);
			kanban.leankor__EstimatedDuration__c = 5;
			kanban.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
			kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCardsList.add(kanban);
        }

		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		cardIds.addAll(kanbanCardIds);
        Test.startTest();
       	UpdateKanbanCard.updateKanbanCards(request);
		UpdateKanbanCard.createScheduleMode(cardIds);
		UpdateKanbanCard.deleteScheduleModes(cardIds);
        Test.stopTest();
		
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	Name 
																From leankor__KanbanCard__c 
																Where Id In :kanbanCards 
																Limit 10]; 

		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	@isTest
    private static void testUpdateKanbanCardSecondMethod(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															leankor__ValueStream__c
														From leankor__KanbanCard__c
														Where Name = :'Test Kanban'
														Limit 50];

        // Check for update name 
        List<Id> kanbanCardIds = new List<Id>();
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();

        for (leankor__kanbanCard__c kanbanCard : kanbanCards) {
            kanbanCardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c kanban = new leankor__kanbanCard__c();
            kanban.Id = kanbanCard.Id;
            kanban.Name = 'Updated Card';
            kanban.leankor__StartDateTime__c = Date.today().addDays(2);
            kanban.leankor__DueDateTime__c = Date.today();
			kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCardsList.add(kanban);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		cardIds.addAll(kanbanCardIds);

        Test.startTest();
      	UpdateKanbanCard.updateKanbanCards(request);
		UpdateKanbanCard.createScheduleMode(cardIds);
		UpdateKanbanCard.deleteScheduleModes(cardIds);
        Test.stopTest();

		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	Name 
																From leankor__KanbanCard__c 
																Where Id In :kanbanCards 
																Limit 10];

		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	@isTest
    private static void testUpdateKanbanCardThirdMethod(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															leankor__ValueStream__c
														From leankor__KanbanCard__c
														Where Name = :'Test Kanban'
														Limit 1000];

        // Check for update name 
        List<Id> kanbanCardIds = new List<Id>();
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();

        for (leankor__kanbanCard__c kanbanCard : kanbanCards) {
            kanbanCardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c kanban = new leankor__kanbanCard__c();
            kanban.Id = kanbanCard.Id;
            kanban.Name = 'Updated Card';
            kanban.leankor__StartDateTime__c = Date.today();
            kanban.leankor__EstimatedDuration__c = 5;
			kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanCardsList.add(kanban);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		cardIds.addAll(kanbanCardIds);
        Test.startTest();
       	UpdateKanbanCard.updateKanbanCards(request);
		UpdateKanbanCard.createScheduleMode(cardIds);
		UpdateKanbanCard.deleteScheduleModes(cardIds);
        Test.stopTest();
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	Name 
																From leankor__KanbanCard__c 
																Where Id In :kanbanCards 
																Limit 10];

		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	@isTest
    private static void testUpdateKanbanCardFourthMethod(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															leankor__ValueStream__c
														From leankor__KanbanCard__c
														Where Name = :'Test Kanban'
														Limit 2000];

        // Check for update name 
        List<Id> kanbanCardIds = new List<Id>();
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();

        for (leankor__kanbanCard__c kanbanCard : kanbanCards) {
            kanbanCardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c Kanban = new leankor__kanbanCard__c();
            Kanban.Id = kanbanCard.Id;
            Kanban.Name = 'Updated Card';
            Kanban.leankor__StartDateTime__c = Date.today();
            Kanban.leankor__EstimatedDuration__c = 5;
			Kanban.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanCardsList.add(Kanban);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		cardIds.addAll(kanbanCardIds);
        Test.startTest();
       	UpdateKanbanCard.updateKanbanCards(request);
		UpdateKanbanCard.createScheduleMode(cardIds);
		UpdateKanbanCard.deleteScheduleModes(cardIds);
        Test.stopTest();
		
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	Name 
																From leankor__KanbanCard__c 
																Where Id In :kanbanCards 
																Limit 10];

		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

}