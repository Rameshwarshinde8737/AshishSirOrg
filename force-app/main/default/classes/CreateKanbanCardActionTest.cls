/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for CreateKanbanCardAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private with sharing class CreateKanbanCardActionTest {
    private static User user = null;

    @TestSetup
	static void setupTestData() {
		Id mileStoneCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
		Id folderCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
		Id activityCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		
        /* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
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
		ganttTemplate.leankor__Title__c = 'Default';
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
     Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testCreateKanbanCardAction() {
		
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
			kanbanRecord.leankor__DurationUnits__c = 'Days';
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for (Integer count = 1; count <= 2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 100;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			KanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
			kanbanCard.Name = 'Test C' + count;
			kanbanCards.add(KanbanCard);
		}


		List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
		CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();
		kanbanCardRequest.KanbanCardList = new List<leankor__KanbanCard__c>();
	
		kanbanCardRequest.KanbanCardList.addAll(kanbanCards);
		kanbanCardRequests.add(KanbanCardRequest);

		List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
		Test.startTest();
		CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
		Test.stopTest();
		
		//verify that 2001 cards are present on board 
		List<leankor__KanbanCard__c> results = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(2001, results.size(), 'Cards Generated Successfully.');
	}


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testCreateKanbanCardActionUberBoard() {
		
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
												And leankor__BoardType__c = 'UberBoard'
												Limit 1];

		leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
															Name,
															leankor__Title__c,
															leankor__ValueStream__c
														From leankor__KanbanCardTemplate__c
														Where leankor__ValueStream__c = :valueStream.Id
														Limit 1];

		leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
			kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanRecord.leankor__ValueStream__c = valueStream.Id;
			kanbanRecord.Name = 'Test C1';
			kanbanRecord.leankor__Title__c = 'Test Card';
			kanbanRecord.leankor__EstimatedDuration__c = 100;
			kanbanRecord.leankor__DurationUnits__c = 'Days';
			kanbanRecord.leankor__StartDateTime__c = System.now();
			kanbanRecord.OwnerId = UserInfo.getUserId();
            kanbanRecord.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
		insert kanbanRecord;

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for (Integer count = 1; count <= 2000; count++) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			//kanbanCard.leankor__MasterContainer__c = newMC.Id;
			//kanbanCard.leankor__Swimlane__c = newSw.Id;
			//kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 100;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			KanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
			kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
			kanbanCard.Name = 'Test C' + count;
			kanbanCards.add(KanbanCard);
		}


		List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
		CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();
		kanbanCardRequest.KanbanCardList = new List<leankor__KanbanCard__c>();
	
		kanbanCardRequest.KanbanCardList.addAll(kanbanCards);
		kanbanCardRequests.add(KanbanCardRequest);

		List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
		Test.startTest();
		CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
		Test.stopTest();
		
		//verify that 2001 cards are present on board 
		List<leankor__KanbanCard__c> results = [Select Id,
													  	Name,
													  	leankor__ValueStream__c 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :valueStream.Id 
													Limit 50000];
		System.assertEquals(2001, results.size(), 'Cards Generated Successfully.');
	}


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
        private static void testCreateKanbanCardActionWithCommunityUser() {
            createCommunityUser();

            System.runAs(user) {
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
                kanbanRecord.leankor__DurationUnits__c = 'Days';
                kanbanRecord.leankor__StartDateTime__c = System.now();
                kanbanRecord.OwnerId = UserInfo.getUserId();
            insert kanbanRecord;

            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
            for (Integer count = 1; count <= 2000; count++) {
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
                kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
                kanbanCard.leankor__ValueStream__c = valueStream.Id;
                kanbanCard.leankor__Title__c = 'Test Card '+count;
                kanbanCard.leankor__MasterContainer__c = newMC.Id;
                kanbanCard.leankor__Swimlane__c = newSw.Id;
                kanbanCard.leankor__Zone__c = zone.Id;
                kanbanCard.leankor__EstimatedDuration__c = 100;
                kanbanCard.leankor__DurationUnits__c = 'Days';
                kanbanCard.leankor__StartDateTime__c = System.now();
                KanbanCard.OwnerId = UserInfo.getUserId();
                kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
                kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
                kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
                kanbanCard.Name = 'Test C' + count;
                kanbanCards.add(KanbanCard);
            }


            List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
            CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();
            kanbanCardRequest.KanbanCardList = new List<leankor__KanbanCard__c>();
        
            kanbanCardRequest.KanbanCardList.addAll(kanbanCards);
            kanbanCardRequests.add(KanbanCardRequest);

            List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
            Test.startTest();
            CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
            Test.stopTest();
            
            //verify that 2001 cards are present on board 
            List<leankor__KanbanCard__c> results = [Select Id,
                                                            Name,
                                                            leankor__ValueStream__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :valueStream.Id 
                                                        Limit 50000];
            System.assertEquals(2001, results.size(), 'Cards Generated Successfully.');
        }
	}


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
        private static void testCreateKanbanCardActionWithStandardUser() {
            createVisualLeanUser();

            System.runAs(user) {
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
                kanbanRecord.leankor__DurationUnits__c = 'Days';
                kanbanRecord.leankor__StartDateTime__c = System.now();
                kanbanRecord.OwnerId = UserInfo.getUserId();
            insert kanbanRecord;

            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
            for (Integer count = 1; count <= 2000; count++) {
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
                kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
                kanbanCard.leankor__ValueStream__c = valueStream.Id;
                kanbanCard.leankor__Title__c = 'Test Card '+count;
                kanbanCard.leankor__MasterContainer__c = newMC.Id;
                kanbanCard.leankor__Swimlane__c = newSw.Id;
                kanbanCard.leankor__Zone__c = zone.Id;
                kanbanCard.leankor__EstimatedDuration__c = 100;
                kanbanCard.leankor__DurationUnits__c = 'Days';
                kanbanCard.leankor__StartDateTime__c = System.now();
                KanbanCard.OwnerId = UserInfo.getUserId();
                kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
                kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
                kanbanCard.leankor__ValueStreamCardLink__c = kanbanRecord.Id;
                kanbanCard.Name = 'Test C' + count;
                kanbanCards.add(KanbanCard);
            }


            List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
            CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();
            kanbanCardRequest.KanbanCardList = new List<leankor__KanbanCard__c>();
        
            kanbanCardRequest.KanbanCardList.addAll(kanbanCards);
            kanbanCardRequests.add(KanbanCardRequest);

            List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
            Test.startTest();
            CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
            Test.stopTest();
            
            //verify that 2001 cards are present on board 
            List<leankor__KanbanCard__c> results = [Select Id,
                                                            Name,
                                                            leankor__ValueStream__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :valueStream.Id 
                                                        Limit 50000];
            System.assertEquals(2001, results.size(), 'Cards Generated Successfully.');
        }
	}


    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void testCreateKanbanCardActionSingleRecord() {
        
        leankor__ProjectRoom__c project = [Select Id,
                                                Name,
                                                leankor__Portfolio__r.Name
                                            From leankor__ProjectRoom__c
                                            Where Name = 'Test'
                                            Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
                                                    Name,
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

        leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
        kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanRecord.leankor__ValueStream__c = valueStream.Id;
        kanbanRecord.Name = 'Test C1';
        kanbanRecord.leankor__Title__c = 'Test Card';
        kanbanRecord.leankor__MasterContainer__c = newMC.Id;
        kanbanRecord.leankor__Swimlane__c = newSw.Id;
        kanbanRecord.leankor__Zone__c = zone.Id;
        kanbanRecord.leankor__EstimatedDuration__c = 100;
        kanbanRecord.leankor__DurationUnits__c = 'Days';
        kanbanRecord.leankor__StartDateTime__c = System.now();
        kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

        List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
        CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();

        kanbanCardRequest.GUID = TestDataFactory.createGuid();
        kanbanCardRequest.Title = 'Test';
        kanbanCardRequest.CategoryName = kanbanTemplate.Name;
        kanbanCardRequest.Description = 'Test';
        kanbanCardRequest.AcceptanceCriteria = 'Test';
        kanbanCardRequest.DueDate = DateTime.newInstance(2025, 1, 31, 7, 8, 16);
        kanbanCardRequest.EstimatedDuration = 5;
        kanbanCardRequest.DurationUnits = 'Days';
        kanbanCardRequest.Priority = 2;
        kanbanCardRequest.OwnerID = UserInfo.getUserId();
        kanbanCardRequest.HarveyBall = 25;
        kanbanCardRequest.ZoneForceID = zone.Id;
        kanbanCardRequest.MCForceID = newMC.Id;
        kanbanCardRequest.SWForceID = newSw.Id;
        kanbanCardRequest.ProjectBoardName = valueStream.Name;
        kanbanCardRequest.ProjectFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest.ProjectRoomName = project.Name;
        kanbanCardRequest.RecordTypeName = 'ActivityCard';
        kanbanCardRequest.LinkedFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest.LinkedRoomName = project.Name;
        kanbanCardRequest.LinkedBoardName = valueStream.Name;
        kanbanCardRequest.LinkedCardName = kanbanRecord.Name;


        kanbanCardRequests.add(kanbanCardRequest);

        List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
        Test.startTest();
        CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
        Test.stopTest();

        //verify that 1 cards are present on board 
        List<leankor__KanbanCard__c> results = [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :valueStream.Id 
                                                    Limit 50000];
        System.assertEquals(2, results.size(), 'Cards Generated Successfully.');
    }


    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void testCreateKanbanCardActionSingleRecordMileStone() {
        
        leankor__ProjectRoom__c project = [Select Id,
                                                Name,
                                                leankor__Portfolio__r.Name
                                            From leankor__ProjectRoom__c
                                            Where Name = 'Test'
                                            Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
                                                    Name,
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

        List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
        CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();

        kanbanCardRequest.GUID = TestDataFactory.createGuid();
        kanbanCardRequest.Title = 'Test';
        kanbanCardRequest.CategoryName = kanbanTemplate.Name;
        kanbanCardRequest.Description = 'Test';
        kanbanCardRequest.AcceptanceCriteria = 'Test';
        kanbanCardRequest.StartDate = DateTime.newInstance(2025, 1, 31, 7, 8, 16);
        kanbanCardRequest.EstimatedDuration = 5;
        kanbanCardRequest.DurationUnits = 'Days';
        kanbanCardRequest.Priority = 2;
        kanbanCardRequest.OwnerID = UserInfo.getUserId();
        kanbanCardRequest.HarveyBall = 25;
        kanbanCardRequest.ZoneForceID = zone.Id;
        kanbanCardRequest.MCForceID = newMC.Id;
        kanbanCardRequest.SWForceID = newSw.Id;
        kanbanCardRequest.ProjectBoardName = valueStream.Name;
        kanbanCardRequest.ProjectFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest.ProjectRoomName = project.Name;
        kanbanCardRequest.RecordTypeName = 'MileStoneCard';

        kanbanCardRequests.add(kanbanCardRequest);

        List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
        Test.startTest();
        CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
        Test.stopTest();

        //verify that 1 cards are present on board 
        List<leankor__KanbanCard__c> results = [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :valueStream.Id 
                                                    Limit 50000];
        System.assertEquals(1, results.size(), 'Cards Generated Successfully.');
    }


    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void testCreateKanbanCardActionSingleRecordFolderCard() {
        
        leankor__ProjectRoom__c project = [Select Id,
                                                Name,
                                                leankor__Portfolio__r.Name
                                            From leankor__ProjectRoom__c
                                            Where Name = 'Test'
                                            Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
                                                    Name,
                                                    leankor__ProjectRoom__c,
                                                    leankor__BoardType__c
                                                From leankor__ValueStream__c
                                                Where leankor__ProjectRoom__c = :project.Id
                                                And leankor__BoardType__c = 'UberBoard'
                                                Limit 1];

        leankor__KanbanCardTemplate__c kanbanTemplate = [Select Id,
                                                            Name,
                                                            leankor__Title__c,
                                                            leankor__ValueStream__c
                                                        From leankor__KanbanCardTemplate__c
                                                        Where leankor__ValueStream__c = :valueStream.Id
                                                        Limit 1];

        List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
        CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();
        CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest2 = new CreateKanbanCardAction.KanbanCardRequest();


        kanbanCardRequest.GUID = TestDataFactory.createGuid();
        kanbanCardRequest.Title = 'Test';
        kanbanCardRequest.CategoryName = kanbanTemplate.Name;
        kanbanCardRequest.Description = 'Test';
        kanbanCardRequest.AcceptanceCriteria = 'Test';
        kanbanCardRequest.DueDate = DateTime.newInstance(2025, 1, 31, 7, 8, 16);
        kanbanCardRequest.StartDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
        kanbanCardRequest.DurationUnits = 'Days';
        kanbanCardRequest.Priority = 2;
        kanbanCardRequest.OwnerID = UserInfo.getUserId();
        kanbanCardRequest.HarveyBall = 25;
        kanbanCardRequest.ProjectBoardName = valueStream.Name;
        kanbanCardRequest.ProjectFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest.ProjectRoomName = project.Name;
        kanbanCardRequest.RecordTypeName = 'FolderCard';

        kanbanCardRequests.add(kanbanCardRequest);

        kanbanCardRequest2.GUID = TestDataFactory.createGuid();
        kanbanCardRequest2.Title = 'Test';
        kanbanCardRequest2.CategoryName = kanbanTemplate.Name;
        kanbanCardRequest2.Description = 'Test';
        kanbanCardRequest2.AcceptanceCriteria = 'Test';
        kanbanCardRequest2.DueDate = DateTime.newInstance(2025, 1, 31, 7, 8, 16);
        kanbanCardRequest2.StartDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
        kanbanCardRequest2.DurationUnits = 'Days';
        kanbanCardRequest2.Priority = 2;
        kanbanCardRequest2.OwnerID = UserInfo.getUserId();
        kanbanCardRequest2.HarveyBall = 25;
        kanbanCardRequest2.ProjectBoardName = valueStream.Name;
        kanbanCardRequest2.ProjectFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest2.ProjectRoomName = project.Name;

        kanbanCardRequests.add(kanbanCardRequest2);

        List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
        Test.startTest();
        CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
        Test.stopTest();

        //verify that 1 cards are present on board 
        List<leankor__KanbanCard__c> results = [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :valueStream.Id 
                                                    Limit 50000];
        System.assertEquals(2, results.size(), 'Cards Generated Successfully.');
    } 

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for CreateKanbanCardProcess Method inside CreateKanbanCardAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void testCreateKanbanCardActionSingleRecordWBSAndSequenceNumber() {
        
        leankor__ProjectRoom__c project = [Select Id,
                                                Name,
                                                leankor__Portfolio__r.Name
                                            From leankor__ProjectRoom__c
                                            Where Name = 'Test'
                                            Limit 1];

        leankor__ValueStream__c valueStream = [Select Id,
                                                    Name,
                                                    leankor__ProjectRoom__c,
                                                    leankor__BoardType__c
                                                From leankor__ValueStream__c
                                                Where leankor__ProjectRoom__c = :project.Id
                                                And leankor__BoardType__c = 'Kanban Board'
                                                Limit 1];
        
        leankor__MasterContainer__c newMC = [Select Id,
                                                Name,
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

        leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
        kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanRecord.leankor__ValueStream__c = valueStream.Id;
        kanbanRecord.Name = 'Test C1';
        kanbanRecord.leankor__Title__c = 'Test Card';
        kanbanRecord.leankor__MasterContainer__c = newMC.Id;
        kanbanRecord.leankor__Swimlane__c = newSw.Id;
        kanbanRecord.leankor__Zone__c = zone.Id;
        kanbanRecord.leankor__EstimatedDuration__c = 100;
        kanbanRecord.leankor__DurationUnits__c = 'Days';
        kanbanRecord.leankor__StartDateTime__c = System.now();
        kanbanRecord.OwnerId = UserInfo.getUserId();
		insert kanbanRecord;

        List<CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<CreateKanbanCardAction.KanbanCardRequest>();
        CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new CreateKanbanCardAction.KanbanCardRequest();

        kanbanCardRequest.GUID = TestDataFactory.createGuid();
        kanbanCardRequest.Title = 'Test';
        kanbanCardRequest.CategoryName = kanbanTemplate.Name;
        kanbanCardRequest.Description = 'Test';
        kanbanCardRequest.AcceptanceCriteria = 'Test';
        kanbanCardRequest.DueDate = DateTime.newInstance(2025, 1, 31, 7, 8, 16);
        kanbanCardRequest.EstimatedDuration = 5;
        kanbanCardRequest.DurationUnits = 'Days';
        kanbanCardRequest.Priority = 2;
        kanbanCardRequest.OwnerID = UserInfo.getUserId();
        kanbanCardRequest.HarveyBall = 25;
        kanbanCardRequest.ZoneForceID = zone.Id;
        kanbanCardRequest.MCName = newMC.Name;
        kanbanCardRequest.SWForceID = newSw.Id;
        kanbanCardRequest.ProjectBoardId = valueStream.Id;
        kanbanCardRequest.ProjectFolderName = project.leankor__Portfolio__r.Name;
        kanbanCardRequest.ProjectRoomName = project.Name;
        kanbanCardRequest.RecordTypeName = 'ActivityCard';
        kanbanCardRequest.generateWorkBreakdownStructure = true;
        kanbanCardRequest.LinkedBoardId = valueStream.Id;
        kanbanCardRequest.LinkedCardId = kanbanRecord.Id;
        kanbanCardRequest.CardId = '1.2';

        kanbanCardRequests.add(kanbanCardRequest);

        List<CreateKanbanCardAction.KanbanCardResult> kanbanCardResults = new List<CreateKanbanCardAction.KanbanCardResult>();
        Test.startTest();
        CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequests);
        Test.stopTest();

        //verify that 1 cards are present on board 
        List<leankor__KanbanCard__c> results = [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :valueStream.Id 
                                                    Limit 50000];
        System.assertEquals(2, results.size(), 'Cards Generated Successfully.');
    }
}