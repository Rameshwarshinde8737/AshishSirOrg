@isTest
private with sharing class CreateKanbanCardsQueueableTest {

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup 
	private static void setupTestData(){
		leankor__LeanConstants__c leanConstant = new leankor__LeanConstants__c(leankor__AllowSchedulingConstraints__c = false);
		insert leanConstant;
        leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board',leankor__IsScheduleRecalculate__c= false, leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
        insert valueStream;
        
        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
		newMC.name= 'Test MC';
		newMC.leankor__Valuestream__c= valueStream.id;
        insert newMC;
        
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
		    leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
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

		leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = valueStream.Id;
			kanbanRecord.Name = 'Test C1';
			kanbanRecord.leankor__Title__c = 'Test Card';
			kanbanRecord.leankor__MasterContainer__c = newMC.Id;
			kanbanRecord.leankor__Swimlane__c = newSw.Id;
			kanbanRecord.leankor__Zone__c = zone.Id;
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.leankor__DueDateTime__c = system.Now().addDays(1);
			kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;	
    }

	 /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover CreateKanbanCardsQueueable
    ----------------------------------------------------------------------------------------------------------*/ 
     @isTest
	 private static void testCreateKanbanCardsQueueable(){

        leankor__ProjectRoom__c project  = [Select Id, 
											  	Name 
											From leankor__ProjectRoom__c 
											Where Name = 'test' 
											Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
												Name 
											From leankor__ValueStream__c 
											Where leankor__ProjectRoom__c = :project.Id]; 

		leankor__KanbanCard__c previousKanbanRecord = [Select Id 
														From leankor__KanbanCard__c 
														Where Name= 'Test C1' ];
													
        leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id, 
														   	Name 
														From leankor__KanbanCardTemplate__c 
														Where leankor__ValueStream__c = :valueStream.Id];

		Set<String> folderCards = new Set<String>();
		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1 ; count<=20; count++){
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.Name = 'Test Records';
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = system.Now().addDays(1);
			KanbanCard.OwnerId = UserInfo.getUserId();

			if(count>3 && count<5){
				kanbanCard.leankor__KanbanCardTemplate__c = null;	
			}

			if (count > 5 && count < 15){
				kanbanCard.leankor__ValueStreamCardLink__c=null;
				KanbanCard.OwnerId = UserInfo.getUserId();
			}

			if (count<20){
				kanbanCard.leankor__ValueStreamCardLink__c = previousKanbanRecord.Id;
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}

			else{
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
			kanbanCards.add(KanbanCard);
        }
		
		MultipleCreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.projectId= project.id;
		kanbanCardRequest.ownerID = UserInfo.getUserId();
        kanbanCardRequest.projectBoardName = 'Testing board';	
        kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
		kanbanCardRequest.projectEventCustomPayload='Test data';
		
		Test.startTest();
			System.enqueueJob(new CreateKanbanCardsQueueable(kanbanCardRequest, true));
			System.enqueueJob(new CreateKanbanCardsQueueable(kanbanCardRequest, false));
		Test.stopTest();

		//verify that 21 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
														leankor__ZoneGUID__c,
														leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];

		System.assertEquals(21,clonedCards.size());
    }

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover updateIsScheduleRecalculate Method inside CreateKanbanCardsQueueable Class
    ----------------------------------------------------------------------------------------------------------*/ 
	@isTest
	private static void testupdateIsScheduleRecalculate(){
		List<leankor__ValueStream__c> valueStream =  [Select Id,
														leankor__IsScheduleRecalculate__c,
														Name 
													From leankor__ValueStream__c]; 
		RealTimeController.isCalledAPI = true;												
		CreateKanbanCardsQueueable.updateIsScheduleRecalculate(valueStream);	
		Test.startTest();
		leankor__ValueStream__c valueStream1 =  [Select Id,
													 	leankor__IsScheduleRecalculate__c,
													 	Name 
													From leankor__ValueStream__c
													Limit 1];
		System.assert(valueStream1.leankor__IsScheduleRecalculate__c == true);
			
		Test.stopTest();	
	}

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover CreateKanbanCardsQueueable  Class For Bulk Records
    ----------------------------------------------------------------------------------------------------------*/ 
	@isTest
	private static void testCreateKanbanCardsQueueableForBulkCards(){

		leankor__ProjectRoom__c project  = [Select Id, 
											  	Name 
											From leankor__ProjectRoom__c 
											Where Name = 'test' 
											Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
												Name 
											From leankor__ValueStream__c 
											Where leankor__ProjectRoom__c = :project.Id]; 

		leankor__KanbanCard__c previousKanbanRecord = [Select Id 
														From leankor__KanbanCard__c 
														Where Name= 'Test C1' ];
													
        leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id, 
														   	Name 
														From leankor__KanbanCardTemplate__c 
														Where leankor__ValueStream__c = :valueStream.Id];

		Set<String> folderCards = new Set<String>();
		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1 ; count<=2000; count++){
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.Name = 'Test Records';
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = system.Now().addDays(1);
			KanbanCard.OwnerId = UserInfo.getUserId();

			if(count>30 && count<50){
				kanbanCard.leankor__KanbanCardTemplate__c = null;	
			}

			if (count > 50 && count < 150){
				kanbanCard.leankor__ValueStreamCardLink__c=null;
				KanbanCard.OwnerId = UserInfo.getUserId();
			}

			if (count<200){
				kanbanCard.leankor__ValueStreamCardLink__c = previousKanbanRecord.Id;
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}

			else{
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
			kanbanCards.add(KanbanCard);
        }
		
		MultipleCreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateKanbanCardAction.KanbanCardRequest();
        kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.projectId= project.id;
		kanbanCardRequest.ownerID = UserInfo.getUserId();
        kanbanCardRequest.projectBoardName = 'Testing board';	
        kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
		kanbanCardRequest.projectEventCustomPayload='Test data';
		
		Test.startTest();
			System.enqueueJob(new CreateKanbanCardsQueueable(kanbanCardRequest, true));
			System.enqueueJob(new CreateKanbanCardsQueueable(kanbanCardRequest, false));
		Test.stopTest();

		//verify that 2001 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
													leankor__ZoneGUID__c,
													leankor__ValueStream__c 
												From leankor__KanbanCard__c 
												Where leankor__ValueStream__c = :valueStream.Id 
												Limit 50000];

		System.assertEquals(2001,clonedCards.size());		
	}	
}