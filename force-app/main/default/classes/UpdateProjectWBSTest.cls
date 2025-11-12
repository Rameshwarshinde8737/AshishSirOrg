/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for UpdateProjectWBSTest.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 

@isTest
private with sharing class UpdateProjectWBSTest {
    private static User user = null;

    @testSetup 
	private static void setupTestData() {
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

		insert kanbanTemplatesList;
        
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
		for (Integer i = 1; i <= 2000; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = masterContainer.Id;
			kanbanCard.leankor__Swimlane__c = swimlane.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if (Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = mileStoneCard;
			} else if (Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = folderCard;
			} else {
				kanbanCard.RecordTypeId = activityCard;
			}  
			kanbanCardsList.add(KanbanCard);    
		}

		for (Integer i = 1; i <= 2000; i++) {			
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
			if (Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = mileStoneCard;
			} else if (Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = folderCard;
			} else {
				kanbanCard.RecordTypeId = activityCard;
			}
            
			kanbanCardsList.add(kanbanCard);
		}
		
        insert kanbanCardsList;


		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for (leankor__KanbanCard__c kanbanCard1 : [Select Id
														From leankor__KanbanCard__c
														Where leankor__ValueStream__c = :ganttBoard.Id
															And RecordTypeId = :folderCard]) {
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
			kanbanCard.Name = 'Test Gantt Card';
			kanbanCard.leankor__Title__c = 'Test Gantt Card';
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now();
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-', '');
			kanbanCard.RecordTypeId = activityCard;
            kanbanCard.leankor__ValueStreamCardLink__c = kanbanCard1.Id;

			kanbanCards.add(kanbanCard);
		}
		insert kanbanCards;
	}


    private static void createVisualLeanUser() {
        user = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_User'});
	}


    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                From Contact
								Where Birthdate =: Date.newInstance(2016, 12, 9)  
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


    @isTest
	private static void testConstructor() {
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
        Test.startTest();
        UpdateProjectWBS updateProjectWBS1 = new UpdateProjectWBS();
        UpdateProjectWBS updateProjectWBS2 = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
        UpdateProjectWBS updateProjectWBS3 = new UpdateProjectWBS(valueStream.Id);
        UpdateProjectWBS updateProjectWBS4 = new UpdateProjectWBS(new Set<Id>{valueStream.Id}, 'parent', 'children', '.');
        UpdateProjectWBS updateProjectWBS5 = new UpdateProjectWBS(valueStream.Id, 'parent', 'children', '.');
		Assert.isTrue(updateProjectWBS1 != null, 'Method Executed Successfully.');
		Test.stopTest();
    }


    @isTest
	private static void testGenerateProjectWorkOrderTree() {
        List<Map<String, Object>> kanbanCardTree = new List<Map<String, Object>>();
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

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

        Test.startTest();
        UpdateProjectWBS updateProjectWBS = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
		kanbanCards = updateProjectWBS.generateProjectWorkOrderTree(kanbanCardTree, valueStream);
		Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
        kanbanCards = updateProjectWBS.updatekanbanCards(kanbanCards);
		Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
		Test.stopTest();
    }

    @isTest
	private static void testReadKanbanCards() {
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
        Test.startTest();
        List<leankor__KanbanCard__c> kanbanCards = UpdateProjectWBS.readKanbanCards(new Set<Id>{valueStream.Id});
		Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
		Test.stopTest();
    }


    @isTest
	private static void testGenerateProjectWorkOrderTreeWithStandardUser() {

		createVisualLeanUser();
        System.runAs(user) {
            List<Map<String, Object>> kanbanCardTree = new List<Map<String, Object>>();
            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

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

            Test.startTest();
            UpdateProjectWBS updateProjectWBS = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
            kanbanCards = updateProjectWBS.generateProjectWorkOrderTree(kanbanCardTree, valueStream);
            Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
            kanbanCards = updateProjectWBS.updatekanbanCards(kanbanCards);
            Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
            Test.stopTest();
        }
    }


    @isTest
	private static void testGenerateProjectWorkOrderTreeWithCommunityUser() {

		createCommunityUser();
        System.runAs(user) {
            List<Map<String, Object>> kanbanCardTree = new List<Map<String, Object>>();
            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

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

            Test.startTest();
            UpdateProjectWBS updateProjectWBS = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
            kanbanCards = updateProjectWBS.generateProjectWorkOrderTree(kanbanCardTree, valueStream);
            Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
            kanbanCards = updateProjectWBS.updatekanbanCards(kanbanCards);
            Assert.isTrue(!kanbanCards.isEmpty(), 'Method Executed Successfully.');
            Test.stopTest();
        }
    }
}