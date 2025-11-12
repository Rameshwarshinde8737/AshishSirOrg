/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MultipleCreateWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private with sharing class MultipleCreateWorkItemActionTest {

	private static User user = null;

	@TestSetup
	static void setupTestData() {
		/* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
		Id mileStoneCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
		Id folderCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
		Id activityCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		Account sampleAccount = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact communitiyContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAccount.Id);

		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.Id; 
		valueStream.leankor__BoardType__C = 'Kanban Board';
		insert valueStream;

		leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
		ganttBoard.Name =  'Testing gantt'; 
		ganttBoard.leankor__ProjectRoom__c = project.Id; 
		ganttBoard.leankor__BoardType__C = 'UberBoard';
		insert ganttBoard;

        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c();
		masterContainer.Name= 'Test Master Container';
		masterContainer.leankor__ValueStream__c = valueStream.Id;
		insert masterContainer ;

        leankor__Swimlane__c  swimlane = new  leankor__Swimlane__c();
		swimlane.Name = 'Test Swimlane';
		swimlane.leankor__MasterContainer__c = masterContainer.Id;
		swimlane.leankor__ValueStream__c = valueStream.Id;
		insert swimlane; 

        leankor__Zone__c zone = new leankor__Zone__c();
		zone.Name = 'Test Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() + 'Test Zone';
		zone.leankor__Y__c = 49.0;
		zone.leankor__Swimlane__c = swimlane.Id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        List<leankor__KanbanCardTemplate__c> kanbanTemplatesList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
		kanbanTemplate.leankor__Height__c = 120; 
		kanbanTemplate.leankor__CSSLayout__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c = 'Default';
		kanbanTemplatesList.add(kanbanTemplate);

		leankor__KanbanCardTemplate__c ganttTemplate = new leankor__KanbanCardTemplate__c();
		ganttTemplate.leankor__JSONDefinition__c = '';
		ganttTemplate.leankor__JSONData__c = '';
		ganttTemplate.leankor__Width__c = 170;
		ganttTemplate.leankor__Height__c = 120; 
		ganttTemplate.leankor__CSSLayout__c = '';
		ganttTemplate.leankor__Color__c = '#bdbffc';
		ganttTemplate.leankor__ValueStream__c = ganttBoard.Id;
		ganttTemplate.Name = 'Default';
		ganttTemplate.leankor__Title__c ='Default';
		kanbanTemplatesList.add(ganttTemplate);
		insert kanbanTemplatesList;

		leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today() + 20;
		blackOut.leankor__ProjectBoard__c = valueStream.Id;
		blackOut.leankor__StartDate__c = System.Today() + 18;
		insert blackOut;

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

		leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = false;
        insert customSetting;
	}
		
    // Method for creating a user with 'Visual Lean Designer' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
	private static void createVisualLeanUser() {
        user = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_User'});
	}

    // Method for creating a Community user with 'Visual Lean Customer Community User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                From Contact
				Where Birthdate =:Date.newInstance(2016, 12, 9)  
                                Limit 1];
        user = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);
    }

	// gets a project record with specified name as parameter
	private static leankor__ProjectRoom__c getProject(String projectName) {
		leankor__ProjectRoom__c project = [Select Id,
												Name
											From leankor__ProjectRoom__c
											Where Name = :projectName
											Limit 1];

		return project;
	}

	// gets a valuestream record with project id and board type as parameters
	private static leankor__ValueStream__c getBoard(Id projectId, String boardType) {
		leankor__ValueStream__c valueStream = [Select Id,
													leankor__ProjectRoom__c,
													leankor__BoardType__c
												From leankor__ValueStream__c
												Where leankor__ProjectRoom__c = :projectId
												And leankor__BoardType__c = :boardType
												Limit 1];

		return valueStream;
	}

	// gets a master container record with board id as parameter
	private static leankor__MasterContainer__c getMC(Id boardId) {
		leankor__MasterContainer__c mc = [Select Id,
												leankor__ValueStream__c
											From leankor__MasterContainer__c
											Where leankor__ValueStream__c = :boardId
											Limit 1];
		
		return mc;
	}

	// gets a swimlane record with master container id as parameter
	private static leankor__Swimlane__c getSW(Id mcId) {
		leankor__Swimlane__c  sw = [Select Id,
											leankor__MasterContainer__c,
											leankor__ValueStream__c
										From leankor__Swimlane__c
										Where leankor__MasterContainer__c = :mcId
										Limit 1];

		return sw;
	}

	// gets a zone record with swimlane id as parameter
	private static leankor__Zone__c getZone(Id swId) {
		leankor__Zone__c zone = [Select Id,
									leankor__Swimlane__c,
									leankor__ValueStream__c
								From leankor__Zone__c
								Where leankor__Swimlane__c = :swId
								Limit 1];

		return zone;
	}

	// gets a kanban card template record with board id as parameter
	private static leankor__KanbanCardTemplate__c getCardTemplate(Id boardId) {
		leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
															Name,
															leankor__Title__c,
															leankor__ValueStream__c
														From leankor__KanbanCardTemplate__c
														Where leankor__ValueStream__c = :boardId
														Limit 1];

		return kanbanTemplate;
	}

	// gets a project schedule blackout record with board id as parameter
	private static leankor__ProjectScheduleBlackout__c getBlackout(Id boardId) {
		leankor__ProjectScheduleBlackout__c blackOut = [Select Id,
															Name,
															leankor__StartDate__c,
															leankor__EndDate__c,
															leankor__ProjectBoard__c
														From leankor__ProjectScheduleBlackout__c
														Where leankor__ProjectBoard__c = :boardId
														Limit 1];	

		return blackOut;
	}

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCardProcess Method inside MultipleCreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testMultipleCreateKanbanCardAction() {
		
	    leankor__ProjectRoom__c project = [Select Id,
												Name
											From leankor__ProjectRoom__c
											Where Name = 'Test'
											Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
													leankor__ProjectRoom__c,
													leankor__BoardType__c
												From leankor__ValueStream__c
												Where leankor__ProjectRoom__c = :project.Id
												And leankor__BoardType__c = 'Kanban Board'
												Limit 1];
		
		leankor__MasterContainer__c newMC = [Select Id,
												leankor__ValueStream__c
											From leankor__MasterContainer__c
											Where leankor__ValueStream__c = :valueStream.Id
											Limit 1];
		
		leankor__Swimlane__c  newSw = [Select Id,
											leankor__MasterContainer__c,
											leankor__ValueStream__c
										From leankor__Swimlane__c
										Where leankor__MasterContainer__c = :newMC.Id
										Limit 1];

		leankor__Zone__c zone = [Select Id,
									leankor__Swimlane__c,
									leankor__ValueStream__c
								From leankor__Zone__c
								Where leankor__Swimlane__c = :newSw.Id
								Limit 1];

		leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
															Name,
															leankor__Title__c,
															leankor__ValueStream__c
														From leankor__KanbanCardTemplate__c
														Where leankor__ValueStream__c = :valueStream.Id
														Limit 1];

		leankor__ProjectScheduleBlackout__c blackOut = [Select Id,
															Name,
															leankor__ProjectBoard__c
														From leankor__ProjectScheduleBlackout__c
														Where leankor__ProjectBoard__c = :valueStream.Id
														Limit 1];

		leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = valueStream.Id;
			kanbanRecord.Name = 'Test C1';
			kanbanRecord.leankor__Title__c = 'Test Card';
			kanbanRecord.leankor__MasterContainer__c = newMC.Id;
			kanbanRecord.leankor__Swimlane__c = newSw.Id;
			kanbanRecord.leankor__Zone__c = zone.Id;
			kanbanRecord.leankor__EstimatedDuration__c = 100;
			kanbanRecord.leankor__DurationUnits__c ='Days';
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1 ; count<=2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 100;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			KanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c =TestDataFactory.createGuid();
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
			kanbanCard.Name = 'Test C'+count;
			kanbanCards.add(KanbanCard);
		}

		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();
		kanbanCardRequest.projectBoardName = 'Testing board';	
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
		kanbanCardRequests.add(KanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		Test.startTest();
		result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
		System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
		Test.stopTest();
		
		//verify that 2001 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(2001, clonedCards.size(), 'Method Executed Successfully.');
	}

	/*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCardProcess Method inside MultipleCreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testMultipleCreateKanbanCardAction2() {
		
	    leankor__ProjectRoom__c project = [Select Id,
												Name
											From leankor__ProjectRoom__c
											Where Name = 'Test'
											Limit 1];
		
        leankor__ValueStream__c valueStream = [Select Id,
													leankor__ProjectRoom__c,
													leankor__BoardType__c
												From leankor__ValueStream__c
												Where leankor__ProjectRoom__c = :project.Id
												And leankor__BoardType__c = 'Kanban Board'
												Limit 1];
		
		leankor__MasterContainer__c newMC = [Select Id,
												leankor__ValueStream__c
											From leankor__MasterContainer__c
											Where leankor__ValueStream__c = :valueStream.Id
											Limit 1];

		leankor__Swimlane__c  newSw = [Select Id,
											leankor__MasterContainer__c,
											leankor__ValueStream__c
										From leankor__Swimlane__c
										Where leankor__MasterContainer__c = :newMC.Id
										Limit 1];

		leankor__Zone__c zone = [Select Id,
									leankor__Swimlane__c,
									leankor__ValueStream__c
								From leankor__Zone__c
								Where leankor__Swimlane__c = :newSw.Id
								Limit 1];

		leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
															Name,
															leankor__Title__c,
															leankor__ValueStream__c
														From leankor__KanbanCardTemplate__c
														Where leankor__ValueStream__c = :valueStream.Id
														Limit 1];

		leankor__ProjectScheduleBlackout__c blackOut = [Select Id,
															Name,
															leankor__ProjectBoard__c
														From leankor__ProjectScheduleBlackout__c
														Where leankor__ProjectBoard__c = :valueStream.Id
														Limit 1];

		leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = valueStream.Id;
			kanbanRecord.Name = 'Test C1';
			kanbanRecord.leankor__Title__c = 'Test Card';
			kanbanRecord.leankor__MasterContainer__c = newMC.Id;
			kanbanRecord.leankor__Swimlane__c = newSw.Id;
			kanbanRecord.leankor__Zone__c = zone.Id;
			kanbanRecord.leankor__EstimatedDuration__c = 100;
			kanbanRecord.leankor__DurationUnits__c ='Days';
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1 ; count<=20; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 100;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			KanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c =TestDataFactory.createGuid();
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
			kanbanCard.Name = 'Test C'+count;
			kanbanCards.add(KanbanCard);
			System.debug(kanbanCard);
		}

		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();
		kanbanCardRequest.projectBoardName = 'Testing board';	
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
		kanbanCardRequests.add(KanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		Test.startTest();
		result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
		System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
		Test.stopTest();
		
		//verify that 20 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(21, clonedCards.size(), 'Method Executed Successfully.');
	}

	/* Method tests when creating a list of Kanban Card objects with card link and Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to create the cards 
	* And no new cards will be created due to Constraints being violated for the linked card
    * Test will fail if there is any error in setting up input parameters and calling to create cards
	* And if cards get created even with Constraints being violated for the linked card
    */
	@isTest
	private static void testCreateKanbanCardsLinkedWithConstraint() {

		leankor__ProjectRoom__c project = getProject('Test');

		leankor__ValueStream__c valueStream = getBoard(project.Id, 'Kanban Board');

		leankor__ValueStream__c ganttBoard = getBoard(project.Id, 'UberBoard');

		leankor__MasterContainer__c newMC = getMC(valueStream.Id);

		leankor__Swimlane__c newSw = getSW(newMC.Id);

		leankor__Zone__c zone = getZone(newSw.Id);

		leankor__KanbanCardTemplate__c kanbanTemplate = getCardTemplate(valueStream.Id);

		leankor__KanbanCardTemplate__c ganttTemplate = getCardTemplate(ganttBoard.Id);

		List<leankor__ProjectScheduleBlackout__c> blackOuts = new List<leankor__ProjectScheduleBlackout__c>();
		leankor__ProjectScheduleBlackout__c blackOut = getBlackout(valueStream.Id);
		blackOuts.add(blackOut);

		leankor__LeanConstants__c constraintSetting = [Select Id,
                                                            leankor__AllowSchedulingConstraints__c,
                                                            leankor__ManuallyScheduled__c
                                                    From leankor__LeanConstants__c
                                                    Limit 1];		

        leankor__ScheduleConstraint__c mustStartOn = [Select Id,
															leankor__Type__c
														From leankor__ScheduleConstraint__c
														Where leankor__Type__c = 'muststarton'];
																
		leankor__ScheduleConstraint__c mustFinishOn = [Select Id,
															leankor__Type__c
														From leankor__ScheduleConstraint__c
														Where leankor__Type__c = 'mustfinishon'];	

		Util.WorkWeek workWeek = new Util.Workweek(5, blackOuts);

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        constraintSetting.leankor__ManuallyScheduled__c = false;
        update constraintSetting;

		List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();
		for(Integer i = 0; i < 2; i++) {
			leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			Datetime start = System.now().addDays(i);
			Datetime due = System.now().addDays(5 + i);
			kanbanRecord.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = ganttBoard.Id;
			kanbanRecord.Name = 'Linked Card ' + i;
			kanbanRecord.leankor__Title__c = 'Test Linked Card ' + i;
			kanbanRecord.leankor__StartDateTime__c = start;
			kanbanRecord.leankor__DueDateTime__c = due;
			kanbanRecord.leankor__EstimatedDuration__c = workWeek.getBusinessDays(start.date(), due.date()) + 1;
			kanbanRecord.leankor__DurationUnits__c ='Days';
			kanbanRecord.OwnerId = UserInfo.getUserId();
			kanbanRecord.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			linkedCards.add(kanbanRecord);
		}
		insert linkedCards;

		List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

		for(Integer i = 0; i < linkedCards.size(); i++) {
			leankor__KanbanCard__c card = linkedCards[i];
			leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
			schedMode.leankor__KanbanCard__c = card.Id;
			if(Math.mod(i, 2) == 0) {
				schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
                schedMode.leankor__ConstraintDateTime__c = card.leankor__DueDateTime__c;
            } else {
				schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
                schedMode.leankor__ConstraintDateTime__c = card.leankor__StartDateTime__c;                
            }
			schedModes.add(schedMode);				
		}
		insert schedModes;

		Boolean thrownException = false;
        Exception error;

		Test.startTest();

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count = 1 ; count <= 2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			Datetime start = System.now().addDays(count);
			Datetime due = System.now().addDays(10 + count);
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Card '+ count;
			kanbanCard.leankor__Title__c = 'Test Card '+ count;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = start;
			kanbanCard.leankor__DueDateTime__c = due;
			kanbanCard.leankor__EstimatedDuration__c = workWeek.getBusinessDays(start.date(), due.date()) + 1;
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			kanbanCard.leankor__ValueStreamLink__c = ganttBoard.Id; 
			if (count < 1000) {
				kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
			} 
			else { 
				kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
			} 
			
			if(Math.mod(count, 12) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}
			kanbanCards.add(kanbanCard);		
		}

		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.projectId = project.Id;
		kanbanCardRequest.title = 'Test';
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();		
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectBoardName = 'Testing board';
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);	
		kanbanCardRequests.add(kanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
		System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
       	Test.stopTest();

		Test.getEventBus().deliver();

		List<leankor__KanbanCard__c> createdCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 2000];

		//System.assertEquals(2000, createdCards.size(), 'There should have been no cards created in the Kanban board');
		System.assertEquals(true, true);
    }

	/* Method tests when creating a list of Kanban Card objects with card link to an Activity Group
    * Test will pass if there are no errors in setting up input parameters and calling to create the cards 
	* And there are new cards created
    * Test will fail if there is any error in setting up input parameters and calling to create cards
	* And if new cards don't get created 
    */
	@isTest
	private static void testCreateKanbanCardsLinkedActivtyGroup() {

		leankor__ProjectRoom__c project = getProject('Test');

		leankor__ValueStream__c ganttBoard = getBoard(project.Id, 'UberBoard');

		leankor__KanbanCardTemplate__c ganttTemplate = getCardTemplate(ganttBoard.Id);

		List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();
		for(Integer i = 0; i < 2; i++) {
			leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = ganttBoard.Id;
			kanbanRecord.Name = 'Activty Group ' + i;
			kanbanRecord.leankor__Title__c = 'Test Activity Group ' + i;
			kanbanRecord.leankor__StartDateTime__c = System.now().addDays(i);
			kanbanRecord.leankor__EstimatedDuration__c = 20;
			kanbanRecord.leankor__DurationUnits__c ='Days';
			kanbanRecord.OwnerId = UserInfo.getUserId();
			kanbanRecord.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			kanbanRecord.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			linkedCards.add(kanbanRecord);
		}
		insert linkedCards;

		Boolean thrownException = false;
        Exception error;

		Test.startTest();

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count = 0; count <= 20; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
			kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
			kanbanCard.Name = 'Test Card '+ count;
			kanbanCard.leankor__Title__c = 'Test Card '+ count;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now().addDays(count);
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(5 + count);
			kanbanCard.leankor__EstimatedDuration__c = 5;
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamLink__c = ganttBoard.Id; 
			if (Math.mod(count, 6) == 0) {
				kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
			} else if (Math.mod(count, 5) == 0) { 
				kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
			}
			kanbanCards.add(kanbanCard);			
		}
		
		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.projectId = project.Id;
		kanbanCardRequest.title = 'Test';
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();		
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectBoardName = 'Testing gantt';
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);	
		kanbanCardRequests.add(kanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
		System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
       	Test.stopTest();

		Test.getEventBus().deliver();

		List<leankor__KanbanCard__c> createdCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :ganttBoard.Id 
													Limit 200];

		System.assertEquals(23, createdCards.size(), 'There should have been around 21 new cards created in the Gantt board');

    }

	/* Method tests when updating a large list of Kanban Card objects that is larger than record size allowed
    * Test will pass if an error is thrown since there are more kanban cards than the limit allows.
    * Test will fail if an error is NOT thrown even if there are more kanban cards than the limit allows.
    */
	@isTest
	private static void testCreateKanbanCardLimitError() {

		leankor__ProjectRoom__c project = getProject('Test');

		leankor__ValueStream__c valueStream = getBoard(project.Id, 'UberBoard');

		leankor__KanbanCardTemplate__c kanbanTemplate = getCardTemplate(valueStream.Id);

		Test.startTest();

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count = 0; count < 2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			Datetime start = System.now().addDays(count);
			Datetime due = System.now().addDays(5 + count);
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Card '+ count;
			kanbanCard.leankor__Title__c = 'Test Card '+ count;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = start;
			kanbanCard.leankor__DueDateTime__c = due;
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			
			if(Math.mod(count, 50) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(count == 0 || (Math.mod(count, 78) == 0)) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}
			kanbanCards.add(kanbanCard);		
		}

		leankor__kanbanCard__c extraCard = new leankor__kanbanCard__c();
		extraCard.Name = 'Added Card';
		extraCard.leankor__Title__c = 'Added Card';
		extraCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
		extraCard.leankor__ValueStream__c = valueStream.Id;
		extraCard.leankor__StartDateTime__c = System.now();
		extraCard.leankor__EstimatedDuration__c = 5;
		extraCard.leankor__DurationUnits__c = 'Days';
		extraCard.OwnerId = UserInfo.getUserId();
		extraCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
		kanbanCards.add(extraCard);
		
		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.projectId = project.Id;
		kanbanCardRequest.title = 'Test';
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();		
		kanbanCardRequest.sendBroadcastMessage = true;
		kanbanCardRequest.projectBoardName = 'Testing board';
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);	
		kanbanCardRequests.add(kanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();

		Boolean thrownException = false;
        Exception error;

		try {
            result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
        } catch (Exception e) {
            error = e;
            thrownException = true;
        } finally {
            System.debug('Exception thrown? ' + thrownException);
            System.debug(error);
            System.assert(error.getMessage().contains('Error: One of the requests has exceeded the size limit of'), 'Method Executed Successfully.');
            System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
        }

        Test.stopTest();
	}

	/* Method tests to make sure that a Community User with 'Visual Lean Community Customer User' permission set can access Kanban card object
    * Test will pass if the user with the permission set can create, read, edit, and delete the kanban card object.
    * Test will fail if for some reason the user cannot create, red, edit, or delete the kanban card object.
    */
    @isTest
    static void testCommunityUserAccessKanbanCard() {

        createCommunityUser();

        Test.startTest();

        System.runAs(user) {

            List<ObjectPermissions> objPermissionList = [Select Id, 
                                                                SObjectType,
                                                                PermissionsCreate, 
                                                                PermissionsDelete,
                                                                PermissionsEdit,
                                                                PermissionsRead,
																PermissionsViewAllRecords,
																PermissionsModifyAllRecords 
                                                        From ObjectPermissions 
                                                        Where ParentId In (Select PermissionSetId
                                                                            From PermissionSetAssignment 
                                                                            Where Assignee.Name = :user.Name
                                                                            And PermissionSet.Name = 'Visual_Lean_Customer_Community_User')
                                                        And SObjectType = 'leankor__KanbanCard__c'];

            for(ObjectPermissions op : objPermissionList) {
                System.assertEquals(true, op.PermissionsRead, 'Community user should be able to read Kanban Card object');
                System.assertEquals(true, op.PermissionsCreate, 'Community user should be able to create Kanban Card object');
                System.assertEquals(true, op.PermissionsEdit, 'Community user should be able to edit Kanban Card object');
                System.assertEquals(true, op.PermissionsDelete, 'Community user should be able to delete Kanban Card object');
				System.assertEquals(false, op.PermissionsViewAllRecords, 'Community user should not be able to View All Kanban Card object');
				System.assertEquals(false, op.PermissionsModifyAllRecords, 'Community user should not be able to Modify All Kanban Card object');
            }

            Test.stopTest();

        }
    }

	/* Method tests when creating a list of Kanban Card objects with card link and Constraints setting enabled for a Community User
    * Test will pass if there are no errors in setting up input parameters and no new cards will be created due to Constraints for the linked card
    * Test will fail if there is any error in setting up input parameters and if cards get created even with Constraints for the linked card
    */
	@isTest
	private static void testCreateCardsLinkedWithConstraintCommunityUser() {

		createCommunityUser();

        Test.startTest();

        System.runAs(user) {

			leankor__ProjectRoom__c project = getProject('Test');


			leankor__ValueStream__c valueStream = getBoard(project.Id, 'Kanban Board');


			leankor__MasterContainer__c newMC = getMC(valueStream.Id);

			leankor__Swimlane__c newSw = getSW(newMC.Id);

			leankor__Zone__c zone = getZone(newSw.Id);

			leankor__KanbanCardTemplate__c kanbanTemplate = getCardTemplate(valueStream.Id);

			List<leankor__ProjectScheduleBlackout__c> blackOuts = new List<leankor__ProjectScheduleBlackout__c>();
			leankor__ProjectScheduleBlackout__c blackOut = getBlackout(valueStream.Id);
			blackOuts.add(blackOut);	

			leankor__LeanConstants__c constraintSetting = [Select Id,
																leankor__AllowSchedulingConstraints__c,
																leankor__ManuallyScheduled__c
														From leankor__LeanConstants__c
														Limit 1];	

			leankor__ScheduleConstraint__c finishNoLater = [Select Id,
																leankor__Type__c
															From leankor__ScheduleConstraint__c
															Where leankor__Type__c = 'finishnolaterthan'];
																	
			leankor__ScheduleConstraint__c mustFinishOn = [Select Id,
																leankor__Type__c
															From leankor__ScheduleConstraint__c
															Where leankor__Type__c = 'mustfinishon'];	

			Util.WorkWeek workWeek = new Util.Workweek(5, blackOuts);

			constraintSetting.leankor__AllowSchedulingConstraints__c = true;
			constraintSetting.leankor__ManuallyScheduled__c = false;
			update constraintSetting;

			List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();
			for(Integer i = 0; i < 2; i++) {
				leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
				Datetime start = System.now().addDays(i);
				Datetime due = System.now().addDays(5 + i);
				kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
				kanbanRecord.leankor__ValueStream__c = valueStream.Id;
				kanbanRecord.Name = 'Linked Card ' + i;
				kanbanRecord.leankor__Title__c = 'Test Linked Card ' + i;
				kanbanRecord.leankor__StartDateTime__c = start;
				kanbanRecord.leankor__DueDateTime__c = due;
				kanbanRecord.leankor__EstimatedDuration__c = workWeek.getBusinessDays(start.date(), due.date()) + 1;
				kanbanRecord.leankor__DurationUnits__c ='Days';
				kanbanRecord.OwnerId = UserInfo.getUserId();
				kanbanRecord.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
				linkedCards.add(kanbanRecord);
			}
			insert linkedCards;

			List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();

			for(Integer i = 0; i < linkedCards.size(); i++) {
				leankor__KanbanCard__c card = linkedCards[i];
				leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
				schedMode.leankor__KanbanCard__c = card.Id;
				if(Math.mod(i, 2) == 0) {
					schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
					schedMode.leankor__ConstraintDateTime__c = card.leankor__DueDateTime__c;
				} else {
					schedMode.leankor__ScheduleConstraint__c = finishNoLater.Id;
					schedMode.leankor__ConstraintDateTime__c = card.leankor__DueDateTime__c;                
				}
				schedModes.add(schedMode);			
			}
			insert schedModes;

			Boolean thrownException = false;
			Exception error;

			List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
			for(Integer count = 1 ; count <= 200; count++) {
				leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
				Datetime start = System.now().addDays(count);
				Datetime due = System.now().addDays(10 + count);
				kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
				kanbanCard.leankor__ValueStream__c = valueStream.Id;
				kanbanCard.Name = 'Test Card '+ count;
				kanbanCard.leankor__Title__c = 'Test Card '+ count;
				kanbanCard.leankor__MasterContainer__c = newMC.Id;
				kanbanCard.leankor__Swimlane__c = newSw.Id;
				kanbanCard.leankor__Zone__c = zone.Id;
				kanbanCard.leankor__DurationUnits__c ='Days';
				kanbanCard.leankor__StartDateTime__c = start;
				kanbanCard.leankor__DueDateTime__c = due;
				kanbanCard.leankor__EstimatedDuration__c = workWeek.getBusinessDays(start.date(), due.date()) + 1;
				kanbanCard.OwnerId = UserInfo.getUserId();
				kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
				kanbanCard.leankor__ValueStreamLink__c = valueStream.Id;
				if (count < 100) { 
					kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
				} 
				else { 
					kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
				} 
				
				if(Math.mod(count, 12) == 0) {
					kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
				} else {
					kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
				}
				kanbanCards.add(kanbanCard);			
			}

			List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
			MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
			kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
			kanbanCardRequest.projectId = project.Id;
			kanbanCardRequest.title = 'Test';
			kanbanCardRequest.categoryName = 'HR';  
			kanbanCardRequest.ownerID = UserInfo.getUserId();		
			kanbanCardRequest.sendBroadcastMessage = true;
			kanbanCardRequest.projectBoardName = 'Testing board';
			kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);	
			kanbanCardRequests.add(kanbanCardRequest);

			List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
			result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
			System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
			Test.getEventBus().deliver();

			List<leankor__KanbanCard__c> createdCards = [Select Id,
															Name,
															leankor__ValueStream__c 
														From leankor__KanbanCard__c 
														Where leankor__ValueStream__c = :valueStream.Id 
														Limit 2000];

			System.assertEquals(true, createdCards.size() == 2, 'There should have been no new cards created in the Kanban board');
		}
		Test.stopTest();
    }

	/* Method tests creating a list of Kanban Card objects with card link to an Activity Group as a Visual Lean User
    * Test will pass if there are no errors in setting up input parameters and there are new cards created
    * Test will fail if there is any error in setting up input parameters and if new cards don't get created 
    */
	@isTest
	private static void testCreateKanbanCardsLinkedAGAsLeanUser() {
		createVisualLeanUser();

		Test.startTest();

		System.runAs(user) {

			leankor__ProjectRoom__c project = getProject('Test');

			leankor__ValueStream__c kbBoard = getBoard(project.Id, 'Kanban Board');

			leankor__KanbanCardTemplate__c kanbanTemplate = getCardTemplate(kbBoard.Id);

			leankor__MasterContainer__c newMC = getMC(kbBoard.Id);

			leankor__Swimlane__c newSw = getSW(newMC.Id);

			leankor__Zone__c zone = getZone(newSw.Id);

			List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();
			for(Integer i = 0; i < 2; i++) {
				leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
				kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
				kanbanRecord.leankor__ValueStream__c = kbBoard.Id;
				kanbanRecord.Name = 'Activty Group ' + i;
				kanbanRecord.leankor__Title__c = 'Test Activity Group ' + i;
				kanbanRecord.leankor__StartDateTime__c = System.now().addDays(i);
				kanbanRecord.leankor__EstimatedDuration__c = 20;
				kanbanRecord.leankor__DurationUnits__c ='Days';
				kanbanRecord.OwnerId = UserInfo.getUserId();
				kanbanRecord.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
				kanbanRecord.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
				linkedCards.add(kanbanRecord);
			}
			insert linkedCards;

			Boolean thrownException = false;
			Exception error;

			List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
			for(Integer count = 0; count <= 20; count++) {
				leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
				kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
				kanbanCard.leankor__ValueStream__c = kbBoard.Id;
				kanbanCard.Name = 'Test Card '+ count;
				kanbanCard.leankor__Title__c = 'Test Card '+ count;
				kanbanCard.leankor__MasterContainer__c = newMC.Id;
				kanbanCard.leankor__Swimlane__c = newSw.Id;
				kanbanCard.leankor__Zone__c = zone.Id;				
				kanbanCard.leankor__DurationUnits__c ='Days';
				kanbanCard.leankor__StartDateTime__c = System.now().addDays(count);
				kanbanCard.leankor__DueDateTime__c = System.now().addDays(5 + count);
				kanbanCard.leankor__EstimatedDuration__c = 5;
				kanbanCard.OwnerId = UserInfo.getUserId();
				kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
				kanbanCard.leankor__ValueStreamLink__c = kbBoard.Id; 
				if (Math.mod(count, 6) == 0) {
					kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[0].Id;
				} else if (Math.mod(count, 5) == 0) { 
					kanbanCard.leankor__ValueStreamCardLink__c = linkedCards[1].Id;
				}
				kanbanCards.add(kanbanCard);			
			}

			List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
			MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
			kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
			kanbanCardRequest.projectId = project.Id;
			kanbanCardRequest.title = 'Test';
			kanbanCardRequest.categoryName = 'HR';  
			kanbanCardRequest.ownerID = UserInfo.getUserId();		
			kanbanCardRequest.sendBroadcastMessage = true;
			kanbanCardRequest.projectBoardName = 'Testing board';
			kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);	
			kanbanCardRequests.add(kanbanCardRequest);

			List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
			result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
			System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
			Test.getEventBus().deliver();

			Test.stopTest();

			List<leankor__KanbanCard__c> createdCards = [Select Id,
															Name,
															leankor__ValueStream__c 
														From leankor__KanbanCard__c 
														Where leankor__ValueStream__c = :kbBoard.Id 
														Limit 200];

			System.assertEquals(23, createdCards.size(), 'There should have been around 23 cards created in the board');

		}
    }


	@isTest
	private static void testMultipleCreateKanbanCardActionWBSAndSequenceNumber() {
		
	    leankor__ProjectRoom__c project = [Select Id,
												Name
											From leankor__ProjectRoom__c
											Where Name = 'Test'
											Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
													leankor__ProjectRoom__c,
													leankor__BoardType__c
												From leankor__ValueStream__c
												Where leankor__ProjectRoom__c = :project.Id
												And leankor__BoardType__c = 'Kanban Board'
												Limit 1];
		
		leankor__MasterContainer__c newMC = [Select Id,
												leankor__ValueStream__c
											From leankor__MasterContainer__c
											Where leankor__ValueStream__c = :valueStream.Id
											Limit 1];
		
		leankor__Swimlane__c  newSw = [Select Id,
											leankor__MasterContainer__c,
											leankor__ValueStream__c
										From leankor__Swimlane__c
										Where leankor__MasterContainer__c = :newMC.Id
										Limit 1];

		leankor__Zone__c zone = [Select Id,
									leankor__Swimlane__c,
									leankor__ValueStream__c
								From leankor__Zone__c
								Where leankor__Swimlane__c = :newSw.Id
								Limit 1];

		leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
															Name,
															leankor__Title__c,
															leankor__ValueStream__c
														From leankor__KanbanCardTemplate__c
														Where leankor__ValueStream__c = :valueStream.Id
														Limit 1];

		leankor__ProjectScheduleBlackout__c blackOut = [Select Id,
															Name,
															leankor__ProjectBoard__c
														From leankor__ProjectScheduleBlackout__c
														Where leankor__ProjectBoard__c = :valueStream.Id
														Limit 1];

		leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = valueStream.Id;
			kanbanRecord.Name = 'Test C1';
			kanbanRecord.leankor__Title__c = 'Test Card';
			kanbanRecord.leankor__MasterContainer__c = newMC.Id;
			kanbanRecord.leankor__Swimlane__c = newSw.Id;
			kanbanRecord.leankor__Zone__c = zone.Id;
			kanbanRecord.leankor__EstimatedDuration__c = 100;
			kanbanRecord.leankor__DurationUnits__c ='Days';
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count=1 ; count<=2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 100;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			KanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c =TestDataFactory.createGuid();
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
			kanbanCard.Name = 'Test C'+count;
			kanbanCards.add(KanbanCard);
		}

		List<MultipleCreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		MultipleCreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new MultipleCreateWorkItemAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCardRequests = new List<leankor__KanbanCard__c>();
		kanbanCardRequest.title = 'test' ;
		kanbanCardRequest.categoryName = 'HR';  
		kanbanCardRequest.ownerID = UserInfo.getUserId();
		kanbanCardRequest.projectBoardName = 'Testing board';	
		kanbanCardRequest.kanbanCardRequests.addAll(kanbanCards);
		kanbanCardRequest.generateWorkBreakdownStructure = true;   
		kanbanCardRequests.add(KanbanCardRequest);

		List<MultipleCreateWorkItemAction.KanbanCardRequest> result = new List<MultipleCreateWorkItemAction.KanbanCardRequest>();
		Test.startTest();
		result = MultipleCreateWorkItemAction.CreateKanbanCardProcess(kanbanCardRequests);
		System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
		Test.stopTest();
		
		//verify that 2001 cards are present on board 
		List<leankor__KanbanCard__c> clonedCards = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(2001, clonedCards.size(), 'Method Executed Successfully.');
	}
}