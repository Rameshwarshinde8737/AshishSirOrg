@isTest
private class MultipleUpdateKanbanCardActionTest {
	
	private static User u = null;

	@testSetup 
	private static void setupTestData(){
		/* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
		Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);

		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.id; 
		valueStream.leankor__BoardType__C = 'Kanban Board';
		insert valueStream;

		leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
		ganttBoard.Name =  'Testing gantt'; 
		ganttBoard.leankor__ProjectRoom__c = project.id; 
		ganttBoard.leankor__BoardType__C = 'UberBoard';
		insert ganttBoard;

        leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name= 'Test MC';
		newMC.leankor__ValueStream__c= valueStream.id;
		insert newMC ;

        leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c= newMC.id;
		newSw.leankor__ValueStream__c = valueStream.id;
		insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__Swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        List<leankor__KanbanCardTemplate__c> kanbanTemplatesList = new List<leankor__KanbanCardTemplate__c>();
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
		kanbanTemplatesList.add(kanbanTemplate);

		insert kanbanTemplatesList;

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today() + 20;
		blackOut.leankor__ProjectBoard__c = valueStream.Id;
		blackOut.leankor__StartDate__c = System.Today() + 18;
		blackOutsList.add(blackOut);

		insert blackOutsList;

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
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
			if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			}else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}  
			kanbanCardsList.add(KanbanCard);    
		}

		for(Integer i = 1; i <= 2000; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
			kanbanCard.Name = 'Test Gantt Card';
			kanbanCard.leankor__Title__c = 'Test Gantt Card' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}
            
			kanbanCardsList.add(kanbanCard);
		}
		
        insert kanbanCardsList;

		leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = false;
        insert customSetting;

        List<leankor__ScheduleConstraint__c> scheduleConstraints = new List<leankor__ScheduleConstraint__c>();
        leankor__ScheduleConstraint__c startNoEarlier = new leankor__ScheduleConstraint__c();
        startNoEarlier.leankor__Description__c = 'startnoearlierthan';
        startNoEarlier.leankor__Type__c = 'startnoearlierthan';
        scheduleConstraints.add(startNoEarlier);
        
        leankor__ScheduleConstraint__c startNoLater = new leankor__ScheduleConstraint__c();
        startNoLater.leankor__Description__c = 'startnolaterthan';
        startNoLater.leankor__Type__c = 'startnolaterthan';
        scheduleConstraints.add(startNoLater);
        
        leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
        mustStartOn.leankor__Description__c = 'muststarton';
        mustStartOn.leankor__Type__c = 'muststarton';
        scheduleConstraints.add(mustStartOn);

        leankor__ScheduleConstraint__c finishNoEarlier = new leankor__ScheduleConstraint__c();
        finishNoEarlier.leankor__Description__c = 'finishnoearlierthan';
        finishNoEarlier.leankor__Type__c = 'finishnoearlierthan';
        scheduleConstraints.add(finishNoEarlier);

        leankor__ScheduleConstraint__c finishNoLater = new leankor__ScheduleConstraint__c();
        finishNoLater.leankor__Description__c = 'finishnolaterthan';
        finishNoLater.leankor__Type__c = 'finishnolaterthan';
        scheduleConstraints.add(finishNoLater);

        leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
        mustFinishOn.leankor__Description__c = 'mustfinishon';
        mustFinishOn.leankor__Type__c = 'mustfinishon';
        scheduleConstraints.add(mustFinishOn);

        insert scheduleConstraints;
		
	}


	// Method for creating a user with 'Visual Lean Designer' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
	private static void createVisualLeanUser() {
        u = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_User'});
	}

    // Method for creating a Community user with 'Visual Lean Customer Community User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                From Contact
                                Where Birthdate =:Date.newInstance(2016, 12, 9) 
                                Limit 1];
        u = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);
    }


    private static testmethod void testUpdateKanbanCardsFirst(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 10];

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
		    kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kc.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
            kanbanCardsList.add(kc);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		request.projectId = '';
		request.projectEventCustomPayload = 'Test';
		requests.add(request);
		Test.startTest();
		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);
       	Test.stopTest();
	}

    private static testmethod void testUpdateKanbanCardsSecond(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 50];

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
            kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kc.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanCardsList.add(kc);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		Test.startTest();
		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);
        Test.stopTest();
    }

		
    private static testmethod void testUpdateKanbanCardsThird(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name =: 'Test Kanban'
													Limit 1000];

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
            kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kanbanCardsList.add(kc);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		Test.startTest();
		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);
       	Test.stopTest();
	}

    private static testmethod void testUpdateKanbanCardsFourth(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name =: 'Test Kanban'
													Limit 2000];

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
            kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kanbanCardsList.add(kc);
        }
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		Test.startTest();
		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);
       	Test.stopTest();
	}

	
	/* Method tests when updating a list of Kanban Card objects without Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to update the cards
    * Test will fail if there is any error in setting up input parameters and calling to update
    */
	@isTest
    private static void testUpdateKanbanCardsInGanttNoConstraint() {
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														Name,
                                                        leankor__Title__c,
                                                        RecordType.Name,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
                                                    Where Name = 'Test Gantt Card' 
													Limit 2000];

		leankor__ValueStream__c board = [Select Id, 
											Name, 
											leankor__ProjectRoom__c
										From leankor__ValueStream__c
										Where Id = :kanbanCards[0].leankor__ValueStream__c];

		List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();

        Integer count = 0;
        for(leankor__KanbanCard__c kbCard : kanbanCards) {
			leankor__KanbanCard__c card = new leankor__KanbanCard__c();        
            card.Id = kbCard.Id;
            card.Name = 'Updated Card';
            card.leankor__Title__c = kbCard.leankor__Title__c;
            card.leankor__DescriptionLong__c = 'Description updated';
            card.leankor__StartDateTime__c = Date.today();

            if(kbCard.RecordType.Name != 'MilestoneCard') {
				card.leankor__EstimatedDuration__c = 5;
            } 

            updateCards.add(card);
            count++;
        }

		Test.startTest();

        List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.projectId = board.leankor__ProjectRoom__c;
		request.kanbancardList = updateCards;
		request.sendBroadcastMessage = true;
		requests.add(request);
		
		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);

       	Test.stopTest();

		Test.getEventBus().deliver();
		
		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																Name, 
																leankor__StartDateTime__c,
																leankor__DescriptionLong__c
														From leankor__KanbanCard__c
														Where Id In :kanbanCards
														Limit 2000];

		Integer i = 0;
		for(leankor__KanbanCard__c updatedCard : updatedKanbanCards) {
			System.assertEquals('Updated Card', updatedCard.Name);
			//System.assertEquals(updateCards[i].leankor__StartDateTime__c, updatedCard.leankor__StartDateTime__c);
			System.assertEquals(updateCards[i].leankor__DescriptionLong__c, updatedCard.leankor__DescriptionLong__c);
			i++;
		}
	   

    }

	/* Method tests when updating a list of Kanban Card objects with Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to update the cards
	* Along with fields not being updated due to Constraints being violated
    * Test will fail if there is any error in setting up input parameters and calling to update
	* And if fields get updated even with Constraints being violated
    */
	@isTest
	private static void testUpdateKanbanCardsInGanttWithConstraint() {
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														Name,
                                                        leankor__Title__c,
														leankor__DueDateTime__c,
														leankor__StartDateTime__c,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
                                                    Where Name = 'Test Gantt Card' 
													Limit 2000];
		
		leankor__ValueStream__c board = [Select Id, 
											Name, 
											leankor__ProjectRoom__c
										From leankor__ValueStream__c
										Where Id = :kanbanCards[0].leankor__ValueStream__c];

		leankor__LeanConstants__c constraintSetting = [Select Id,
														leankor__AllowSchedulingConstraints__c
													From leankor__LeanConstants__c
													Limit 1];

        List<leankor__ScheduleConstraint__c> constraintTypes = [Select Id,
																leankor__Type__c
                                                        	From leankor__ScheduleConstraint__c];

		List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

		List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();

		Boolean thrownException = false;
        Exception error;

		Test.startTest();

		constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;

        Integer count = 1;
        for(leankor__KanbanCard__c kbCard : kanbanCards) {
			leankor__KanbanCard__c card = new leankor__KanbanCard__c();        
            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
			Integer constraintIndex = (Math.random() * (constraintTypes.size() - 1)).intValue();
			
			card.Id = kbCard.Id;
            card.Name = 'Updated Card ' + count;
            card.leankor__Title__c = kbCard.leankor__Title__c;
			card.leankor__EstimatedDuration__c = 5;
            card.leankor__DueDateTime__c = kbCard.leankor__DueDateTime__c.addDays(count);
			card.leankor__StartDateTime__c = Date.today().addDays(-count);

            if(Math.mod(count, 2) == 0) {
                schedMode.leankor__ConstraintDateTime__c = kbCard.leankor__DueDateTime__c;
            } else {
                schedMode.leankor__ConstraintDateTime__c = kbCard.leankor__StartDateTime__c;                
            }
			
            schedMode.leankor__KanbanCard__c = kbCard.Id;
			schedMode.leankor__ScheduleConstraint__c = constraintTypes[constraintIndex].Id;
			
			schedModes.add(schedMode);
            updateCards.add(card);
            count++;
        }

		insert schedModes;

        List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.projectId = board.leankor__ProjectRoom__c;
		request.kanbancardList = updateCards;
		request.sendBroadcastMessage = true;
		requests.add(request);

		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);

       	Test.stopTest();

		Test.getEventBus().deliver();

		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																Name, 
																leankor__StartDateTime__c,
																leankor__DueDateTime__c
														From leankor__KanbanCard__c
														Where Id In :kanbanCards
														Limit 2000];

		Integer i = 0;
		for(leankor__KanbanCard__c updatedCard : updatedKanbanCards) {
			System.assertNotEquals('Updated Card ' + i, updatedCard.Name);
			System.assertNotEquals(updateCards[i].leankor__StartDateTime__c, updatedCard.leankor__StartDateTime__c);
			System.assertNotEquals(updateCards[i].leankor__DueDateTime__c, updatedCard.leankor__DueDateTime__c);
			i++;
		}

    }

	/* Method tests when updating a list of Kanban Card objects to link to another card with Constraints setting enabled
    * Linked card is set to have a constraint of 'Must Start On' 
    * The constraint date time is set to the start date of the card 
    * Test will pass if an error is thrown since the update will violate the Constraint.
    * Test will fail if an error is NOT thrown even if update violates the Constraint.
    */
	@isTest
	private static void testUpdateKanbanCardsWithLinkAndConstraint() {
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														Name,
                                                        leankor__Title__c,
														leankor__DueDateTime__c,
														leankor__StartDateTime__c,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
                                                    Where Name = 'Test Kanban'
													Limit 2000];

		List<leankor__KanbanCard__c> linkedCards = [Select Id, 
														Name,
														leankor__Title__c,
														leankor__DueDateTime__c,
														leankor__StartDateTime__c,
														leankor__ValueStream__c,
														RecordType.Name
													From leankor__KanbanCard__c
													Where Name = 'Test Gantt Card'  
													And RecordType.Name In ('ActivityCard', 'MileStoneCard')
													Limit 2];
		
		leankor__ValueStream__c board = [Select Id, 
											Name, 
											leankor__ProjectRoom__c
										From leankor__ValueStream__c
										Where Id = :kanbanCards[0].leankor__ValueStream__c];

		leankor__ValueStream__c linkedBoard = [Select Id, 
												Name, 
												leankor__ProjectRoom__c
											From leankor__ValueStream__c
											Where Id = :linkedCards[0].leankor__ValueStream__c];

		leankor__LeanConstants__c constraintSetting = [Select Id,
														leankor__AllowSchedulingConstraints__c
													From leankor__LeanConstants__c
													Limit 1];

		leankor__ScheduleConstraint__c finishNoLater = [Select Id,
															leankor__Type__c
														From leankor__ScheduleConstraint__c
														Where leankor__Type__c = 'mustfinishon'
														Limit 1];

		leankor__ScheduleConstraint__c mustStartOn = [Select Id,
															leankor__Type__c
														From leankor__ScheduleConstraint__c
														Where leankor__Type__c = 'muststarton'
														Limit 1];

		List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

		List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();

		Boolean thrownException = false;
		Exception error;

		Test.startTest();

		constraintSetting.leankor__AllowSchedulingConstraints__c = true;
		update constraintSetting;

		Integer count = 1;
		for(leankor__KanbanCard__c kbCard : kanbanCards) {
			leankor__KanbanCard__c card = new leankor__KanbanCard__c();        
			leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
			
			card.Id = kbCard.Id;
			card.Name = 'Updated Card ' + count;
			card.leankor__Title__c = kbCard.leankor__Title__c;
			card.leankor__DueDateTime__c = kbCard.leankor__DueDateTime__c.addDays(count + 5);
			card.leankor__StartDateTime__c = Date.today().addDays(-count);
			card.leankor__ValueStreamLink__c = linkedBoard.Id;

			if(Math.mod(count, 2) == 0) {
				schedMode.leankor__ConstraintDateTime__c = linkedCards[0].leankor__DueDateTime__c;
				schedMode.leankor__ScheduleConstraint__c = finishNoLater.Id;
				schedMode.leankor__KanbanCard__c = linkedCards[0].Id;
				card.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
			} else {
				schedMode.leankor__ConstraintDateTime__c = linkedCards[1].leankor__StartDateTime__c;
				schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
				schedMode.leankor__KanbanCard__c = linkedCards[1].Id;
				card.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
			}
			
			schedModes.add(schedMode);
			updateCards.add(card);
			count++;
		}

		insert schedModes;

		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.projectId = board.leankor__ProjectRoom__c;
		request.kanbancardList = updateCards;
		request.sendBroadcastMessage = true;
		requests.add(request);

		System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);

		Test.getEventBus().deliver();

		List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																Name, 
																leankor__StartDateTime__c,
																leankor__DueDateTime__c
														From leankor__KanbanCard__c
														Where Id In :kanbanCards
														Limit 2000];

		Integer i = 0;
		for(leankor__KanbanCard__c updatedCard : updatedKanbanCards) {
			System.assertNotEquals('Updated Card ' + i, updatedCard.Name, 'The name of the card should not have been updated');
			System.assertNotEquals(updateCards[i].leankor__StartDateTime__c, updatedCard.leankor__StartDateTime__c, 'The Start Date for the card should not have been updated');
			System.assertNotEquals(updateCards[i].leankor__DueDateTime__c, updatedCard.leankor__DueDateTime__c, 'The Due Date for the card should not have been updated');
			i++;
		}

		Test.stopTest();

    }

	/* Method tests when updating a large list of Kanban Card objects that is larger than record size allowed
    * Test will pass if an error is thrown since there are more kanban cards than the limit allows.
    * Test will fail if an error is NOT thrown even if there are more kanban cards than the limit allows.
    */
	@isTest
	private static void testUpdateKanbanCardLimitError(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name =: 'Test Kanban'
													Limit 2000];

		leankor__KanbanCard__c oneCard = new leankor__KanbanCard__c();
        oneCard.Name = 'Test Card';
        oneCard.leankor__Title__c = 'Default';
        oneCard.leankor__DurationUnits__c = 'Days';
        oneCard.leankor__StartDateTime__c = System.now();
        oneCard.leankor__DueDateTime__c = System.now().addDays(10);
        oneCard.OwnerId = UserInfo.getUserId();
        oneCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        oneCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        oneCard.leankor__ValueStream__c = kanbanCards[0].leankor__ValueStream__c;
        insert oneCard;

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           	leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
            kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kanbanCardsList.add(kc);
        }

		leankor__kanbanCard__c extraCard = new leankor__kanbanCard__c();
		extraCard.Id = oneCard.Id;
		extraCard.Name = 'Updated Card';
		extraCard.leankor__StartDateTime__c = Date.today();
		extraCard.leankor__EstimatedDuration__c = 5;
		kanbanCardsList.add(extraCard);
		
		List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
		MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		
		Boolean thrownException = false;
        Exception error;

        Test.startTest();

		try {
            MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests);    
        } catch (Exception e) {
            error = e;
            thrownException = true;
        } finally {
            System.debug('Exception thrown? ' + thrownException);
            System.debug(error);
            System.assert(error.getMessage().contains('Error: One of the requests has exceeded the size limit of'));
            System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
        }
        Test.stopTest();
	}

	/* Method tests when updating a list of Kanban Card objects as a Community User with Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to update the cards
	* Along with fields not being updated due to Constraints being violated
    * Test will fail if there is any error in setting up input parameters and calling to update
	* And if fields get updated even with Constraints being violated
    */
	@isTest
	private static void testUpdateKanbanCardsWithConstraintAsCommunityUser() {

		createCommunityUser();

		Test.startTest();

		System.runAs(u) {

			List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
															Name,
															leankor__Title__c,
															leankor__DueDateTime__c,
															leankor__StartDateTime__c,
															leankor__ValueStream__c
														From leankor__KanbanCard__c
														Where Name = 'Test Kanban' 
														Limit 1000];
			
			leankor__ValueStream__c board = [Select Id, 
												Name, 
												leankor__ProjectRoom__c
											From leankor__ValueStream__c
											Where Id = :kanbanCards[0].leankor__ValueStream__c];

			leankor__LeanConstants__c constraintSetting = [Select Id,
															leankor__AllowSchedulingConstraints__c
														From leankor__LeanConstants__c
														Limit 1];

			List<leankor__ScheduleConstraint__c> constraintTypes = [Select Id,
																	leankor__Type__c
																From leankor__ScheduleConstraint__c];

			List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

			List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();

			Boolean thrownException = false;
			Exception error;

			constraintSetting.leankor__AllowSchedulingConstraints__c = true;
			update constraintSetting;

			Integer count = 1;
			for(leankor__KanbanCard__c kbCard : kanbanCards) {
				leankor__KanbanCard__c card = new leankor__KanbanCard__c();        
				leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
				Integer constraintIndex = (Math.random() * (constraintTypes.size() - 1)).intValue();
				
				card.Id = kbCard.Id;
				card.Name = kbCard.Name;
				card.leankor__Title__c = 'Updated Card ' + count;
				card.leankor__EstimatedDuration__c = 5;
				card.leankor__DueDateTime__c = kbCard.leankor__DueDateTime__c.addDays(count);
				card.leankor__StartDateTime__c = Date.today().addDays(-count);

				if(Math.mod(count, 2) == 0) {
					schedMode.leankor__ConstraintDateTime__c = kbCard.leankor__DueDateTime__c;
				} else {
					schedMode.leankor__ConstraintDateTime__c = kbCard.leankor__StartDateTime__c;                
				}
				
				schedMode.leankor__KanbanCard__c = kbCard.Id;
				schedMode.leankor__ScheduleConstraint__c = constraintTypes[constraintIndex].Id;
				
				schedModes.add(schedMode);
				updateCards.add(card);
				count++;
			}

			insert schedModes;

			List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
			MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
			request.projectId = board.leankor__ProjectRoom__c;
			request.kanbancardList = updateCards;
			request.sendBroadcastMessage = true;
			requests.add(request);

			System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);

			Test.getEventBus().deliver();

			List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	leankor__Title__c, 
																	leankor__StartDateTime__c,
																	leankor__DueDateTime__c
															From leankor__KanbanCard__c
															Where Id In :kanbanCards
															Limit 1000];

			Integer i = 0;
			for(leankor__KanbanCard__c updatedCard : updatedKanbanCards) {
				System.assertNotEquals('Updated Card ' + i, updatedCard.leankor__Title__c, 'The name of the card should not have been updated');
				System.assertNotEquals(updateCards[i].leankor__StartDateTime__c, updatedCard.leankor__StartDateTime__c, 'The Start Date for the card should not have been updated');
				System.assertNotEquals(updateCards[i].leankor__DueDateTime__c, updatedCard.leankor__DueDateTime__c, 'The Due Date for the card should not have been updated');
				i++;
			}

		}

		Test.stopTest();
    }

	/* Method tests when updating a list of Kanban Card objects to link with a card as a Visual Lean User with Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to update the cards
	* Along with fields not being updated due to Constraints being violated
    * Test will fail if there is any error in setting up input parameters and calling to update
	* And if fields get updated even with Constraints being violated
    */
	@isTest
	private static void testUpdateKanbanCardsWithLinkAndConstraintAsLeanUser() {

		createVisualLeanUser();

		Test.startTest();

		System.runAs(u) {

			List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														Name,
                                                        leankor__Title__c,
														leankor__DueDateTime__c,
														leankor__StartDateTime__c,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
                                                    Where Name = 'Test Kanban' 
													Limit 1000];

			List<leankor__KanbanCard__c> linkedCards = [Select Id, 
															Name,
															leankor__Title__c,
															leankor__DueDateTime__c,
															leankor__StartDateTime__c,
															leankor__ValueStream__c,
															RecordType.Name
														From leankor__KanbanCard__c
														Where Name = 'Test Gantt Card'  
														And RecordType.Name In ('ActivityCard', 'MileStoneCard')
														Limit 2];
			
			leankor__ValueStream__c board = [Select Id, 
												Name, 
												leankor__ProjectRoom__c
											From leankor__ValueStream__c
											Where Id = :kanbanCards[0].leankor__ValueStream__c];

			leankor__ValueStream__c linkedBoard = [Select Id, 
												Name, 
												leankor__ProjectRoom__c
											From leankor__ValueStream__c
											Where Id = :linkedCards[0].leankor__ValueStream__c];

			leankor__LeanConstants__c constraintSetting = [Select Id,
															leankor__AllowSchedulingConstraints__c
														From leankor__LeanConstants__c
														Limit 1];

			leankor__ScheduleConstraint__c mustFinishOn = [Select Id,
																leankor__Type__c
															From leankor__ScheduleConstraint__c
															Where leankor__Type__c = 'mustfinishon'
															Limit 1];

			leankor__ScheduleConstraint__c mustStartOn = [Select Id,
																leankor__Type__c
															From leankor__ScheduleConstraint__c
															Where leankor__Type__c = 'muststarton'
															Limit 1];

			List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

			List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();

			Boolean thrownException = false;
			Exception error;

			constraintSetting.leankor__AllowSchedulingConstraints__c = true;
			update constraintSetting;

			Integer count = 1;
			for(leankor__KanbanCard__c kbCard : kanbanCards) {
				leankor__KanbanCard__c card = new leankor__KanbanCard__c();        
				leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
				
				card.Id = kbCard.Id;
				card.Name = kbCard.Name;
				card.leankor__Title__c = 'Updated Card ' + count;
				card.leankor__DueDateTime__c = kbCard.leankor__DueDateTime__c.addDays(count + 5);
				card.leankor__StartDateTime__c = Date.today().addDays(-count);
				card.leankor__ValueStreamLink__c = linkedBoard.Id;

				if(Math.mod(count, 2) == 0) {
					schedMode.leankor__ConstraintDateTime__c = linkedCards[0].leankor__DueDateTime__c;
					schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
					schedMode.leankor__KanbanCard__c = linkedCards[0].Id;
					card.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
				} else {
					schedMode.leankor__ConstraintDateTime__c = linkedCards[1].leankor__StartDateTime__c;
					schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
					schedMode.leankor__KanbanCard__c = linkedCards[1].Id;
					card.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
				}
				
				schedModes.add(schedMode);
				updateCards.add(card);
				count++;
			}

			insert schedModes;

			List<MultipleUpdateKanbanCardAction.KanbanCardRequest> requests = new List<MultipleUpdateKanbanCardAction.KanbanCardRequest>();
			MultipleUpdateKanbanCardAction.KanbanCardRequest request = new MultipleUpdateKanbanCardAction.KanbanCardRequest();
			request.projectId = board.leankor__ProjectRoom__c;
			request.kanbancardList = updateCards;
			request.sendBroadcastMessage = true;
			requests.add(request);

			System.assert(MultipleUpdateKanbanCardAction.updateKanbanCardProcess(requests) == null);

			Test.getEventBus().deliver();

			List<leankor__KanbanCard__c> updatedKanbanCards = [Select Id, 
																	leankor__Title__c, 
																	leankor__StartDateTime__c,
																	leankor__DueDateTime__c
															From leankor__KanbanCard__c
															Where Id In :kanbanCards
															Limit 1000];

			Integer i = 0;
			for(leankor__KanbanCard__c updatedCard : updatedKanbanCards) {
				System.assertNotEquals('Updated Card ' + i, updatedCard.leankor__Title__c, 'The name of the card should not have been updated');
				System.assertNotEquals(updateCards[i].leankor__StartDateTime__c, updatedCard.leankor__StartDateTime__c, 'The Start Date for the card should not have been updated');
				System.assertNotEquals(updateCards[i].leankor__DueDateTime__c, updatedCard.leankor__DueDateTime__c, 'The Due Date for the card should not have been updated');
				i++;
			}

		}

		Test.stopTest();
    }

}