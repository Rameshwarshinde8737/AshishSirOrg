@isTest
private class CreateKanbanCardTest {

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup 
	private static void setupTestData() {
        leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
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
	}
	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCard Method inside CreateKanbanCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
     @isTest
	 private static void testCreateKanbanCard(){
        leankor__ProjectRoom__c project  = [Select Id, 
											  	Name 
											From leankor__ProjectRoom__c 
											Where Name = 'test' Limit 1];

        leankor__ValueStream__c valueStream = [Select Id, 
												 	Name 
												From leankor__ValueStream__c 
												Where leankor__ProjectRoom__c = :project.Id]; 

        leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id, 
														   	Name 
														From leankor__KanbanCardTemplate__c 
														Where leankor__ValueStream__c =: valueStream.Id];

        leankor__MasterContainer__c masterContainer = [Select Id, 
															Name 
														From leankor__MasterContainer__c 
														Where leankor__ValueStream__c = :valueStream.Id];

        leankor__Swimlane__c swimlane = [Select Id, 
										   Name 
										From leankor__Swimlane__c 
										Where leankor__MasterContainer__c = :masterContainer.Id];

        leankor__Zone__c zone = [Select Id, 
								   Name 
								From leankor__Zone__c 
								Where leankor__Swimlane__c = :swimlane.Id];

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1; count<=2000; count++){
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__MasterContainer__c = masterContainer.Id;
			kanbanCard.leankor__Swimlane__c = swimlane.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = system.Now().addDays(1);
			KanbanCard.OwnerId = UserInfo.getUserId();

			if(count<=50){
				kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 22, 3, 3, 3); 
				kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
				kanbanCard.leankor__EstimatedDuration__c = null;
			}

			if (count > 50 && count < 150) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}


			if(count>150 && count<220){
				//kanbanCard.RecordTypeId=null;
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			}

			if(count>220 && count<250){
				kanbanCard.leankor__StartDateTime__c = null; 
				kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
			}

			else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
			//kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			kanbanCards.add(KanbanCard);
        }

        List<MultipleCreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateKanbanCardAction.KanbanCardRequest>();
        MultipleCreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateKanbanCardAction.KanbanCardRequest();
        
        kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();
        kanbanCardRequest.projectBoardName = 'Testing board';	
        kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
        kanbanCardRequests.add(KanbanCardRequest);
		Test.startTest();
		CreateKanbanCard.createKanbanCard(kanbanCardRequests);
		Test.stopTest();

		//verify that 2000 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
														Name,
														leankor__ValueStream__C
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(2000, clonedCards.size());
    }

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCard Method inside CreateKanbanCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
	@isTest
	private static void testCreateKanbanCard2(){
	   leankor__ProjectRoom__c project  = [Select Id, 
												Name 
											From leankor__ProjectRoom__c 
											Where Name = 'test' Limit 1];

	   leankor__ValueStream__c valueStream = [Select Id, 
													Name 
												From leankor__ValueStream__c 
												Where leankor__ProjectRoom__c = :project.Id]; 

	   leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id, 
														  	Name 
														From leankor__KanbanCardTemplate__c 
														Where leankor__ValueStream__c =: valueStream.Id];

	   leankor__MasterContainer__c masterContainer = [Select Id, 
															Name 
														From leankor__MasterContainer__c 
														Where leankor__ValueStream__c =: valueStream.Id];

	   leankor__Swimlane__c swimlane = [Select Id, 
										  	Name 
										From leankor__Swimlane__c 
										Where leankor__MasterContainer__c =: masterContainer.Id];

	   leankor__Zone__c zone = [Select Id, 
								  	Name 
								From leankor__Zone__c 
								Where leankor__Swimlane__c =: swimlane.Id];

	   List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
	   for(Integer count=1; count<=20; count++){
		   leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
		   kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
		   kanbanCard.leankor__ValueStream__c = valueStream.Id;
		   kanbanCard.leankor__Title__c = 'Test Card '+count;
		   kanbanCard.leankor__MasterContainer__c = masterContainer.Id;
		   kanbanCard.leankor__Swimlane__c = swimlane.Id;
		   kanbanCard.leankor__Zone__c = zone.Id;
		   kanbanCard.leankor__DurationUnits__c ='Days';
		   kanbanCard.leankor__StartDateTime__c = System.now();
		   kanbanCard.leankor__DueDateTime__c = system.Now().addDays(1);
		   KanbanCard.OwnerId = UserInfo.getUserId();

		   if(count<=5){
			   kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 22, 3, 3, 3); 
			   kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
			   kanbanCard.leankor__EstimatedDuration__c = null;
		   }



		   if(count>5 && count<10){
			   //kanbanCard.RecordTypeId=null;
			   kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
		   }

		   if(count>10 && count<15){
			   kanbanCard.leankor__StartDateTime__c = null; 
			   kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
		   } else {
			   kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
		   }
		   //kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
		   kanbanCards.add(KanbanCard);
	   }

	   List<leankor.MultipleCreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<leankor.MultipleCreateKanbanCardAction.KanbanCardRequest>();
	   leankor.MultipleCreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new leankor.MultipleCreateKanbanCardAction.KanbanCardRequest();
	   
	   kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
	   kanbanCardRequest.title = 'test' ;
	   kanbanCardRequest.categoryName = 'HR';  
	   kanbanCardRequest.ownerID = UserInfo.getUserId();
	   kanbanCardRequest.projectBoardName = 'Testing board';	
	   kanbanCardRequest.sendBroadcastMessage = true;
	   kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
	   kanbanCardRequests.add(KanbanCardRequest);
	   Test.startTest();
	   leankor.CreateKanbanCard.createKanbanCard(kanbanCardRequests);
	   Test.stopTest();

	   //verify that 20 cards are present on board 
	   List<leankor__KanbanCard__c> clonedCards = [Select Id,
													 	Name,
													 	leankor__ValueStream__C
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
	   System.assertEquals(20, clonedCards.size());
   }

}