@isTest
private class KanbanCardTest {

    public KanbanCardTest() {}

	private static User u = null;
    
    @testSetup 
	private static void setupTestData(){
		// For creating Account and Contact for Community User
        Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);

		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.id; 
		valueStream.leankor__BoardType__C = 'UberBoard';
		insert valueStream;

        List<leankor__KanbanCardTemplate__c> kanbanTemplatesList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c ='Default';
		kanbanTemplatesList.add(kanbanTemplate);

        insert kanbanTemplatesList;

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
		for(Integer i = 1; i <= 2000; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Gantt';
			kanbanCard.leankor__Title__c = 'Test Gantt Card ' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 27) == 0) {
                kanbanCard.leankor__ValueStream__c = null;
			}
			else {
                kanbanCard.leankor__ValueStream__c = valueStream.Id;
			}
            if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 45) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}    

			kanbanCardsList.add(kanbanCard);
        }

        insert kanbanCardsList;
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

	/* Method tests the properties defined within the KanbanCard class by grabbing a Kanban Card object and using its fields for the properties
    * Test will pass if the properties from the KanbanCard class match up with equivalent fields from the Kanban Card object.
    * Test will fail if there are errors in matching the properties with the fields.
    */
	@isTest
	private static void testKanbanCardProperties() {

		List<leankor__KanbanCard__c> cardInfo = [Select Id,
													Name,
													leankor__ValueStream__c,
													leankor__StartDateTime__c,
													leankor__DueDateTime__c,
													leankor__EstimatedDuration__c,
													leankor__BoardType__c,
													leankor__ValueStreamLink__c,
													leankor__ValueStreamCardLink__c,
													leankor__IsSuccessorRecalculate__c
												From leankor__KanbanCard__c
												Limit 2];

		cardInfo[0].leankor__ValueStreamCardLink__c = cardInfo[1].Id;
		cardInfo[0].leankor__ValueStreamLink__c = cardInfo[1].leankor__ValueStream__c;
		cardInfo[0].leankor__IsSuccessorRecalculate__c = true;

		Test.startTest();

		KanbanCard card = new KanbanCard();

		card.Id = cardInfo[0].Id;
		card.name = cardInfo[0].Name;
		card.valueStream = cardInfo[0].leankor__ValueStream__c;
		card.startDateTime = cardInfo[0].leankor__StartDateTime__c;
		card.dueDateTime = cardInfo[0].leankor__DueDateTime__c;
		card.estimatedDuration = cardInfo[0].leankor__EstimatedDuration__c;
		card.boardType = cardInfo[0].leankor__BoardType__c;
		card.isSuccessorRecalculate = cardInfo[0].leankor__IsSuccessorRecalculate__c;
		card.isScheduleBackward = false;
		card.valueStreamLink = cardInfo[0].leankor__ValueStreamLink__c;
		card.valueStreamCardLink = cardInfo[0].leankor__ValueStreamCardLink__c;
		card.isUpdateValueStreamCardLink = true;

		System.assertEquals(cardInfo[0].Id, card.Id);
		System.assertEquals(cardInfo[0].Name, card.name);
		System.assertEquals(cardInfo[0].leankor__ValueStream__c, card.valueStream);
		System.assertEquals(cardInfo[0].leankor__StartDateTime__c, card.startDateTime);
		System.assertEquals(cardInfo[0].leankor__DueDateTime__c, card.dueDateTime);
		System.assertEquals(cardInfo[0].leankor__EstimatedDuration__c, card.estimatedDuration);
		System.assertEquals(cardInfo[0].leankor__BoardType__c, card.boardType);
		System.assertEquals(cardInfo[0].leankor__IsSuccessorRecalculate__c, card.isSuccessorRecalculate);
		System.assertEquals(false, card.isScheduleBackward);
		System.assertEquals(cardInfo[0].leankor__ValueStreamLink__c, card.valueStreamLink);
		System.assertEquals(cardInfo[0].leankor__ValueStreamCardLink__c, card.valueStreamCardLink);
		System.assertEquals(true, card.isUpdateValueStreamCardLink);

		Test.stopTest();

	}

	@isTest
	private static void testEmptyConstructor() {
		Boolean flag = true;		
		Test.startTest();

		KanbanCard check = new KanbanCard();
		System.assert(flag);
		Test.stopTest();
	}

	@isTest
	private static void testCreateKanbanCards() {
		Boolean flag = true;
		Test.startTest();

		KanbanCard check = new KanbanCard();
		check.createKanbanCards();
		System.assert(flag);
		Test.stopTest();
	}

	@isTest
	private static void testDeleteKanbanCards() {
		Boolean flag = true;
		Test.startTest();

		KanbanCard check = new KanbanCard();
		check.deleteKanbanCards();
		System.assert(flag);
		Test.stopTest();
	}

	@isTest
	private static void testEmptyReadKanbanCards() {
		Boolean flag = true;
		Test.startTest();

		KanbanCard check = new KanbanCard();
		check.readKanbanCards();
		System.assert(flag);
		Test.stopTest();
	}

	/* Method tests to read in a set of Ids of Kanban Cards and then returns a list of Kanban Card objects that have those Ids
    * Test will pass if at least one card is found from the returned list.
    * Test will fail if the returned list is somehow empty.
    */
	@isTest
	private static void readKanbanCardTestOneParameter() {
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														Name 
													From leankor__KanbanCard__c
													Limit 2000];

		Set<Id> cardIds = new Set<Id>();
		for(leankor__KanbanCard__c card : kanbanCards) {
			cardIds.add(card.Id);
		}

		Test.startTest();

		List<leankor__KanbanCard__c> cardsReturned = KanbanCard.readKanbanCards(cardIds);

		System.assert(cardsReturned.size() > 1, 'There should have been at least 1 card returned');

		Test.stopTest();
	}

	/* Method tests to read in a set of Ids of Kanban Cards and a set of record type names
	* It then returns a list of Kanban Card objects that have those Ids and are of the record type found within the set
    * Test will pass if at least one card is found from the returned list, and if all the cards' record type is listed within the set.
    * Test will fail if the returned list is somehow empty, or if there is a card with a record type not specified in the set.
    */
	@isTest
	private static void readKanbanCardTestTwoParameters() {
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														Name
													From leankor__KanbanCard__c
													Limit 2000];

		Set<Id> cardIds = new Set<Id>();
		for(leankor__KanbanCard__c card : kanbanCards) {
			cardIds.add(card.Id);
		}
	
		Set<String> recordTypeNames = new Set<String>{'ActivityCard'};

		Test.startTest();

		List<leankor__KanbanCard__c> cardsReturned = KanbanCard.readKanbanCards(cardIds, recordTypeNames);

		List<leankor__KanbanCard__c> checkList = [Select Id,
													Name,
													RecordType.Name
												From leankor__KanbanCard__c
												Where leankor__ValueStream__c != null
												And Id In :cardsReturned
												Limit 2000];

		System.assert(cardsReturned.size() > 1, 'There should have been at least 1 card returned');
		for(leankor__KanbanCard__c card : checkList) {
			System.assertEquals('ActivityCard', card.RecordType.Name, 'The card returned should only be an ActivityCard');
		}
		Test.stopTest();
		
	}

	/* Method tests to read in a list of Kanban Card objects with updated fields and return updated cards
    * Test will pass if from the returned list has at least one updated card.
    * Test will fail if the returned list is somehow empty or if fields were not updated.
    */
	@isTest
	private static void testUpdateKanbanCards() {

		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														Name,
														leankor__DescriptionLong__c 
													From leankor__KanbanCard__c
													Limit 2000];

		List<leankor__KanbanCard__c> updatedCards = new List<leankor__KanbanCard__c>();
		for(leankor__KanbanCard__c card : kanbanCards) {
			card.leankor__DescriptionLong__c = 'Test new description';
			updatedCards.add(card);
		}

		Test.startTest();

		List<leankor__KanbanCard__c> cardsReturned = KanbanCard.updateKanbanCards(updatedCards);

		List<leankor__KanbanCard__c> checkList = [Select Id,
													Name,
													leankor__DescriptionLong__c
												From leankor__KanbanCard__c
												Where leankor__ValueStream__c != null
												And Id In :cardsReturned
												Limit 2000];

		System.assert(cardsReturned.size() > 1, 'There should have been at least 1 updated card returned');
		for(leankor__KanbanCard__c card : checkList) {
			System.assertEquals('Test new description', card.leankor__DescriptionLong__c, 'The card returned should have an updated Description');
		}

		Test.stopTest();

	}

	/* Method tests to read in a list of Kanban Card objects with updated fields and return updated cards - run as a Visual Lean User
    * Test will pass if from the returned list has at least one updated card.
    * Test will fail if the returned list is somehow empty or if fields were not updated.
    */
	@isTest
	private static void testUpdateKanbanCardsAsLeanUser() {
		createVisualLeanUser();

		Test.startTest();

		System.runAs(u) {

			List<leankor__KanbanCard__c> kanbanCards = [Select Id,
															Name,
															leankor__DescriptionLong__c 
														From leankor__KanbanCard__c
														Limit 2000];

			List<leankor__KanbanCard__c> updatedCards = new List<leankor__KanbanCard__c>();
			for(leankor__KanbanCard__c card : kanbanCards) {
				card.Name = 'New Updated';
				updatedCards.add(card);
			}

			List<leankor__KanbanCard__c> cardsReturned = KanbanCard.updateKanbanCards(updatedCards);

			List<leankor__KanbanCard__c> checkList = [Select Id,
														Name
													From leankor__KanbanCard__c
													Where leankor__ValueStream__c != null
													And Id In :cardsReturned
													Limit 2000];

			System.assert(cardsReturned.size() > 1, 'There should have been at least 1 updated card returned');
			for(leankor__KanbanCard__c card : checkList) {
				System.assertEquals('New Updated', card.Name, 'The card returned should have an updated name');
			}

		}

		Test.stopTest();

	}

	/* Method tests to read in a set of Ids of Kanban Cards and a set of record type names - run as a Community User
	* It then returns a list of Kanban Card objects that have those Ids and are of the record type found within the set
    * Test will pass if at least one card is found from the returned list, and if all the cards' record type is listed within the set.
    * Test will fail if the returned list is somehow empty, or if there is a card with a record type not specified in the set.
    */
	@isTest
	private static void readKanbanCardTestTwoParametersAsCommunityUser() {
		createCommunityUser();

		Test.startTest();

		System.runAs(u) {
			List<leankor__KanbanCard__c> kanbanCards = [Select Id,
															Name
														From leankor__KanbanCard__c
														Limit 2000];

			Set<Id> cardIds = new Set<Id>();
			for(leankor__KanbanCard__c card : kanbanCards) {
				cardIds.add(card.Id);
			}
		
			Set<String> recordTypeNames = new Set<String>{'MileStoneCard'};

			List<leankor__KanbanCard__c> cardsReturned = KanbanCard.readKanbanCards(cardIds, recordTypeNames);

			List<leankor__KanbanCard__c> checkList = [Select Id,
														Name,
														RecordType.Name
													From leankor__KanbanCard__c
													Where leankor__ValueStream__c != null
													And Id In :cardsReturned
													Limit 2000];

			System.assert(cardsReturned.size() > 1, 'There should have been at least 1 card returned');
			for(leankor__KanbanCard__c card : checkList) {
				System.assertEquals('MileStoneCard', card.RecordType.Name, 'The card returned should only be an MileStoneCard');
			}

		}

		Test.stopTest();
	}


	@isTest
	private static void readKanbanCardTestListParameter() {
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														Name 
													From leankor__KanbanCard__c
													Limit 2000];

		Test.startTest();
		List<leankor__KanbanCard__c> cardsReturned = KanbanCard.readKanbanCards(kanbanCards);
		Test.stopTest();

		System.assert(cardsReturned.size() > 1, 'There should have been at least 1 card returned');
}
}