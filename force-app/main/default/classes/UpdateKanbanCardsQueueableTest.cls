@isTest
private with sharing class UpdateKanbanCardsQueueableTest {

	@testSetup 
	private static void setupTestData(){
		Profile p = [Select Id 
							From Profile 
							Where Name =: 'System Administrator'];
	        User u1 = new User(Alias = 'Example3', 
					            Email = 'Example3@gmail.test',
					            EmailEncodingKey = 'UTF-8', 
					            LastName = 'demo2', 
					            LanguageLocaleKey = 'en_US',
					            LocaleSidKey = 'en_US', 
					            ProfileId = p.Id,
					            TimeZoneSidKey = 'America/Los_Angeles', 
					            UserName = 'Example3@gmail.test');
	    insert u1;
		leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;
		leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Kanban Board');
		insert valueStream;

		leankor__Valuestream__c valueStreamForGantt = new leankor__Valuestream__c(Name =  'Testing RollUP board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Kanban Board');
		insert valueStreamForGantt;
		
		leankor__KanbanCard__c activityOnGantt = new leankor__KanbanCard__c(Name = 'Testing card',leankor__Valuestream__c = valueStreamForGantt.id, leankor__GUID__c =TestDataFactory.createGuid() , RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId() );
		insert activityOnGantt;

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
		zone.name= 'Test Zone';
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
		for(Integer i=1 ; i<=2000 ;i++){			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(i<=20){
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}else if(i>20 && i<40){
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			}else {
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

		leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
		testResourceAssignment.leankor__KanbanCard__c = kanbanCards[0].Id;
		testResourceAssignment.leankor__PercentAllocation__c = 1;
		testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
		testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
		testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
		testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
		testResourceAssignment.leankor__InternalHourlyRate__c = 1;
		testResourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
		insert testResourceAssignment;
	
	}
	private @isTest
    static void testUpdateKanbanCards(){
		List<leankor__ProjectRoom__c> project = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = :'test' 
													Limit 1];

		List<leankor__kanbanCard__c> k =[Select Id,
												leankor__ValueStream__c
											From leankor__kanbanCard__c 
											Where name = :'Testing card'];

		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c,
														leankor__DurationUnits__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 10];

        // Check for update name 
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCards2 = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
            cardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c KC = new leankor__kanbanCard__c();
            KC.Id = kanbanCard.Id;
            KC.Name = 'Updated Card';
           	KC.leankor__DueDateTime__c = Date.today().addDays(2);
			KC.leankor__EstimatedDuration__c = 5;
			KC.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
			KC.leankor__ValueStreamLink__c = k[0].leankor__ValueStream__c;
			KC.OwnerID = UserInfo.getUserId();
			KC.leankor__PromiseCompletionDate__c = System.today();
			KC.leankor__HarveyBallDoneDate__c = System.today().addDays(4);
			KC.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
            kanbanCards2.add(KC);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCards2;
		request.sendBroadcastMessage = true;
		request.projectId = project[0].id;
		request.projectEventCustomPayload = 'Test';
		requests.add(request);
		Test.startTest();
		UpdateKanbanCard.createScheduleMode(cardIds);
		System.enqueueJob(new UpdateKanbanCardsQueueable(request));
       	Test.stopTest();
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id,
															Name,
															leankor__EstimatedDuration__c
														From leankor__KanbanCard__c 
														Where Id In :kanbanCards 
														Limit 10]; 
		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}


	private @isTest
    static void testUpdateKanbanCardsSecondMethod(){
		List<leankor__ValueStream__c> board = [Select Id 
												From leankor__ValueStream__c 
												Where name = :'Testing RollUP board' 
												Limit 1];

		List<leankor__ProjectRoom__c> project = [Select Id
													From leankor__ProjectRoom__c 
													Where Name = :'test'
													Limit 1];

		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c,
														leankor__DurationUnits__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 50];

        // Check for update name 
        Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
            cardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c KC = new leankor__kanbanCard__c();
            KC.Id = kanbanCard.Id;
            KC.Name = 'Updated Card';
           	KC.leankor__DueDateTime__c = Date.today().addDays(2);
			KC.leankor__EstimatedDuration__c = 5;
			KC.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
			KC.leankor__ValueStreamLink__c = board[0].id;
			KC.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCardsList.add(KC);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		request.projectId = project[0].id;
		request.projectEventCustomPayload = 'Test';
		requests.add(request);
		Test.startTest();
		UpdateKanbanCard.createScheduleMode(cardIds);
		System.enqueueJob(new UpdateKanbanCardsQueueable(request));
       	Test.stopTest();
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id,
															Name,
															leankor__EstimatedDuration__c
														From leankor__KanbanCard__c 
														Where Id In :kanbanCards 
														Limit 10]; 
		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	private @isTest
    static void testUpdateKanbanCardsThirdMethod(){
		List<leankor__ProjectRoom__c> project = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = :'test' 
													Limit 1];

		List<leankor__kanbanCard__c> k =[Select Id,
												leankor__ValueStream__c
											From leankor__kanbanCard__c 
											Where Name = :'Testing card'];

		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c,
														leankor__DurationUnits__c
													From leankor__KanbanCard__c
													Where Name = : 'Test Kanban'
													Limit 1000];

        // Check for update name 
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
            cardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c KC = new leankor__kanbanCard__c();
            KC.Id = kanbanCard.Id;
            KC.Name = 'Updated Card';
           	KC.leankor__DueDateTime__c = Date.today().addDays(2);
			KC.leankor__EstimatedDuration__c = 5;
			KC.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
			KC.leankor__ValueStreamCardLink__c = k[0].id;
			KC.leankor__ValueStreamLink__c = k[0].leankor__ValueStream__c;
			KC.OwnerID = UserInfo.getUserId();
			KC.leankor__PromiseCompletionDate__c = System.today();
			KC.leankor__HarveyBallDoneDate__c = System.today().addDays(4);
			KC.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCardsList.add(KC);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		request.projectId = project[0].id;
		request.projectEventCustomPayload = 'Test';
		requests.add(request);
		Test.startTest();
		UpdateKanbanCard.createScheduleMode(cardIds);
		System.enqueueJob(new UpdateKanbanCardsQueueable(request));
       	Test.stopTest();
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id,
															Name,
															leankor__EstimatedDuration__c 
														From leankor__KanbanCard__c 
														Where Id In :kanbanCards 
														Limit 10]; 
		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	private @isTest
    static void testUpdateKanbanCardsFourthMethod(){
		List<leankor__ProjectRoom__c> project = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = :'test' 
													Limit 1];

		List<leankor__kanbanCard__c> k =[Select Id,
												leankor__ValueStream__c
											From leankor__kanbanCard__c 
											Where Name = :'Testing card'];

		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c,
														leankor__DurationUnits__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 2000];

		User userData = [Select Id
										From User 
									Where LastName =:'demo2'
									Limit 1];											
        // Check for update name 
		Set<Id> cardIds = new Set<Id>();
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
            cardIds.add(kanbanCard.Id);
            leankor__kanbanCard__c KC = new leankor__kanbanCard__c();
            KC.Id = kanbanCard.Id;
            KC.Name = 'Updated Card';
           	KC.leankor__DueDateTime__c = Date.today().addDays(2);
			KC.leankor__EstimatedDuration__c = 5;
			KC.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
			//KC.leankor__ValueStreamCardLink__c = k[0].id;
			KC.leankor__ValueStreamLink__c = k[0].leankor__ValueStream__c;
			KC.OwnerID = userData.id;
			KC.leankor__PromiseCompletionDate__c = System.today();
			KC.leankor__HarveyBallDoneDate__c = System.today().addDays(4);
			KC.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCardsList.add(KC);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		request.projectId = project[0].id;
		request.projectEventCustomPayload = 'Test';
		requests.add(request);
		Test.startTest();
		UpdateKanbanCard.createScheduleMode(cardIds);
		System.enqueueJob(new UpdateKanbanCardsQueueable(request));
       	Test.stopTest();
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id,
															Name,
															leankor__EstimatedDuration__c 
														From leankor__KanbanCard__c 
														Where Id In :kanbanCards 
														Limit 10]; 
		System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
		System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

	private @isTest
    static void testUpdateKanbanCardsFifthMethod(){
		List<leankor__ProjectRoom__c> project = [Select Id 
													From leankor__ProjectRoom__c 
													Where Name = :'test' 
													Limit 1];
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															leankor__ValueStream__c,
															leankor__DurationUnits__c
														From leankor__KanbanCard__c
														Where Name = :'Test Kanban'
														Limit 2000];
		
	// Check for update name 
	Set<Id> cardIds = new Set<Id>();
	List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
	for(leankor__kanbanCard__c kanbanCard : kanbanCards){
		cardIds.add(kanbanCard.Id);
		leankor__kanbanCard__c KC = new leankor__kanbanCard__c();
		KC.Id = kanbanCard.Id;
		KC.Name = 'Updated Card';
		KC.leankor__DueDateTime__c = Date.today().addDays(2);
		KC.leankor__EstimatedDuration__c = 5;
		KC.leankor__DurationUnits__c = kanbanCard.leankor__DurationUnits__c;
		//KC.OwnerID = userData.Id;
		KC.leankor__PromiseCompletionDate__c = System.today();
		KC.leankor__HarveyBallDoneDate__c = System.today().addDays(4);
		KC.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		kanbanCardsList.add(KC);
	}
	
	List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
	MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
	request.kanbancardList = kanbanCardsList;
	request.sendBroadcastMessage = true;
	request.projectId = project[0].id;
	request.projectEventCustomPayload = 'Test';
	requests.add(request);
	Test.startTest();
	UpdateKanbanCard.createScheduleMode(cardIds);
	System.enqueueJob(new UpdateKanbanCardsQueueable(request));
	   Test.stopTest();
	List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id,
														Name,
														leankor__EstimatedDuration__c 
													From leankor__KanbanCard__c 
													Where Id In :kanbanCards 
													Limit 10]; 
	System.assertEquals('Updated Card', updatedKanbanCards[0].Name);
	System.assertEquals('Updated Card', updatedKanbanCards[1].Name);
	}

}