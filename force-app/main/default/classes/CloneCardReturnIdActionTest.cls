/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for CloneCardReturnIdAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private with sharing class CloneCardReturnIdActionTest {
    private static User user = null;

    @TestSetup  
    static void makeData() {
        
        /* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
        Account sampleAccount = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact communitiyContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAccount.Id);
        

        leankor__Portfolio__c folder = new leankor__Portfolio__c();
		folder.Name = 'Test Folder';
        insert folder;

		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        project.leankor__Portfolio__c = folder.Id;
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.Id; 
		valueStream.leankor__BoardType__C = 'Kanban Board';
		insert valueStream;

		leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
		ganttBoard.Name =  'Testing gantt2'; 
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

        leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
        kanbanRecord.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanRecord.leankor__ValueStream__c = valueStream.Id;
        kanbanRecord.Name = 'Test C1';
        kanbanRecord.leankor__Title__c = 'Test Card';
        kanbanRecord.leankor__MasterContainer__c = masterContainer.Id;
        kanbanRecord.leankor__Swimlane__c = swimlane.Id;
        kanbanRecord.leankor__Zone__c = zone.Id;
        kanbanRecord.leankor__EstimatedDuration__c = 100;
        kanbanRecord.leankor__DurationUnits__c = 'Days';
        kanbanRecord.leankor__StartDateTime__c = Date.newInstance(2024, 2, 17);
        kanbanRecord.leankor__DueDateTime__c = Date.newInstance(2024, 2, 18);
        kanbanRecord.leankor__StartDate__c = Date.newInstance(2024, 2, 17);
        kanbanRecord.leankor__DueDate__c = Date.newInstance(2024, 2, 18);
        kanbanRecord.OwnerId = UserInfo.getUserId();
        kanbanRecord.leankor__GUID__c = TestDataFactory.createGuid();
		insert kanbanRecord;

        leankor__KanbanCard__c kanbanRecord2 = new leankor__KanbanCard__c();
        kanbanRecord2.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
        kanbanRecord2.leankor__ValueStream__c = ganttBoard.Id;
        kanbanRecord2.Name = 'Test Linked';
        kanbanRecord2.leankor__Title__c = 'Test Card';
        kanbanRecord2.leankor__EstimatedDuration__c = 100;
        kanbanRecord2.leankor__DurationUnits__c = 'Days';
        kanbanRecord2.leankor__StartDateTime__c = Date.newInstance(2024, 2, 17);
        kanbanRecord2.leankor__DueDateTime__c = Date.newInstance(2024, 2, 18);
        kanbanRecord2.leankor__StartDate__c = Date.newInstance(2024, 2, 17);
        kanbanRecord2.leankor__DueDate__c = Date.newInstance(2024, 2, 18);
        kanbanRecord2.OwnerId = UserInfo.getUserId();
        kanbanRecord2.leankor__GUID__c = TestDataFactory.createGuid();
		insert kanbanRecord2;
        System.debug('kanbanRecord2 =>'+kanbanRecord2);

        System.debug('kanbanRecord => '+kanbanRecord);
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


	private static leankor__KanbanCard__c getKanbanCard (String name) {
		leankor__KanbanCard__c kanbanCard = [Select Id,
                                                    Name
                                                From leankor__KanbanCard__c
                                                Where Name = :name
                                                Limit 1];

		return kanbanCard;
	}


	private static leankor__ValueStream__c getValueStream (String name) {
		leankor__ValueStream__c valueStream = [Select Id,
                                                        Name
                                                    From leankor__ValueStream__c
                                                    Where Name = :name
                                                    Limit 1];

		return valueStream;
	}


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for cloneKanbanCardProcess Method inside CloneCardReturnIdAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testCloneCardReturnIdAction() { 

        leankor__KanbanCard__c kanbanCard = getKanbanCard('Test C1');
        leankor__ValueStream__c valueStream = getValueStream('Testing board');

        List<CloneCardReturnIdAction.CloneKanbanCardRequest> kanbanCardRequests = new List<CloneCardReturnIdAction.CloneKanbanCardRequest>();
		CloneCardReturnIdAction.CloneKanbanCardRequest kanbanCardRequest = new CloneCardReturnIdAction.CloneKanbanCardRequest();
        kanbanCardRequest.FinalDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
        kanbanCardRequest.StartDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
        kanbanCardRequest.KanbanID = kanbanCard.Id;
        kanbanCardRequest.generateWorkBreakdownStructure = true;
        kanbanCardRequests.add(kanbanCardRequest);
        Test.startTest();        
        CloneCardReturnIdAction.CloneKanbanCards(kanbanCardRequests);

        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                    Name
                                                From leankor__KanbanCard__c
                                                Where leankor__ValueStream__c = :valueStream.Id
                                                Limit 50000];

        Assert.areEqual(2, kanbanCards.size(), 'Cards Generated Successfully.');
        Test.stopTest();
    }


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for cloneKanbanCardProcess Method inside CloneCardReturnIdAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testCloneCardReturnIdActionWithFinalDateStandardUser() { 
        createVisualLeanUser();
        System.runAs(user) {
            leankor__KanbanCard__c kanbanCard = getKanbanCard('Test C1');
            leankor__ValueStream__c valueStream = getValueStream('Testing board');

            List<CloneCardReturnIdAction.CloneKanbanCardRequest> kanbanCardRequests = new List<CloneCardReturnIdAction.CloneKanbanCardRequest>();
            CloneCardReturnIdAction.CloneKanbanCardRequest kanbanCardRequest = new CloneCardReturnIdAction.CloneKanbanCardRequest();
            //kanbanCardRequest.FinalDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
            kanbanCardRequest.StartDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
            kanbanCardRequest.KanbanID = kanbanCard.Id;
            kanbanCardRequest.generateWorkBreakdownStructure = true;
            kanbanCardRequests.add(kanbanCardRequest);
            Test.startTest();        
            CloneCardReturnIdAction.CloneKanbanCards(kanbanCardRequests);

            List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                        Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :valueStream.Id
                                                    Limit 50000];

            Assert.areEqual(2, kanbanCards.size(), 'Cards Generated Successfully.');
            Test.stopTest();
        }
    }


    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for cloneKanbanCardProcess Method inside CloneCardReturnIdAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
	private static void testCloneCardReturnIdActionWithFinalDateCommunityUser() { 
        createCommunityUser();
        System.runAs(user) {
            leankor__KanbanCard__c kanbanCard = getKanbanCard('Test C1');
            leankor__ValueStream__c valueStream = getValueStream('Testing board');

            List<CloneCardReturnIdAction.CloneKanbanCardRequest> kanbanCardRequests = new List<CloneCardReturnIdAction.CloneKanbanCardRequest>();
            CloneCardReturnIdAction.CloneKanbanCardRequest kanbanCardRequest = new CloneCardReturnIdAction.CloneKanbanCardRequest();
            //kanbanCardRequest.FinalDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
            kanbanCardRequest.StartDate = DateTime.newInstance(2025, 1, 30, 7, 8, 16);
            kanbanCardRequest.KanbanID = kanbanCard.Id;
            kanbanCardRequest.generateWorkBreakdownStructure = true;
            kanbanCardRequests.add(kanbanCardRequest);
            Test.startTest();        
            CloneCardReturnIdAction.CloneKanbanCards(kanbanCardRequests);

            List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                        Name
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :valueStream.Id
                                                    Limit 50000];

            Assert.areEqual(2, kanbanCards.size(), 'Cards Generated Successfully.');
            Test.stopTest();
        }
    }
}