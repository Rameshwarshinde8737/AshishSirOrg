@isTest
public with sharing class DependencyTest {

	private static User u = null;

    @TestSetup
    static void makeData(){
		// For creating Account and Contact for Community User
        Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);

		List<leankor__ProjectRoom__c> projects = new List<leankor__ProjectRoom__c>();
		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'test';
		projects.add(project);
        
        leankor__ProjectRoom__c project2 = new leankor__ProjectRoom__c();
		project2.Name = 'test2';
        projects.add(project2);

		insert projects;
        
		List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c kbValueStream = new leankor__ValueStream__c();
        kbValueStream.Name = 'Testing KBboard';
		kbValueStream.leankor__ProjectRoom__c = project.id;
		kbValueStream.leankor__BoardType__c = 'Plan Board';
		boards.add(kbValueStream);

        leankor__ValueStream__c pgValueStream = new leankor__ValueStream__c();
        pgValueStream.Name = 'Testing PGboard';
		pgValueStream.leankor__ProjectRoom__c = project.id;
		pgValueStream.leankor__BoardType__c = 'UberBoard';
		boards.add(pgValueStream);

        leankor__ValueStream__c pgValueStream2 = new leankor__ValueStream__c();
        pgValueStream2.Name = 'Testing PGboard2';
		pgValueStream2.leankor__ProjectRoom__c = project2.id;
		pgValueStream2.leankor__BoardType__C = 'UberBoard';
		boards.add(pgValueStream2);

		insert boards;

		leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name = 'Test MC';
		newMC.leankor__ValueStream__c = kbValueStream.id;
		insert newMC;


        leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c= newMC.id;
		newSw.leankor__ValueStream__c = kbValueStream.id;
		insert newSw;

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name = 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__Swimlane__c = newSw.id;
		zone.leankor__ValueStream__c = kbValueStream.Id;
		insert zone;
        
		List<leankor__KanbanCardTemplate__c> kanbanTemplatesList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
		kanbanTemplate.leankor__Height__c = 120;
		kanbanTemplate.leankor__CSSLayout__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = kbValueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c ='Default';
		kanbanTemplatesList.add(kanbanTemplate);

		leankor__KanbanCardTemplate__c ganttTemplate = new leankor__KanbanCardTemplate__c();
		ganttTemplate.leankor__JSONDefinition__c = '';
		ganttTemplate.leankor__JSONData__c = '';
		ganttTemplate.leankor__Color__c = '#bdbffc';
		ganttTemplate.leankor__ValueStream__c = pgValueStream.Id;
		ganttTemplate.Name = 'Default';
		ganttTemplate.leankor__Title__c ='Default';
		kanbanTemplatesList.add(ganttTemplate);

        insert kanbanTemplatesList;

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today()+20;
		blackOut.leankor__ProjectBoard__c = kbValueStream.Id;
		blackOut.leankor__StartDate__c = System.Today()+18;
        insert blackOut;

        leankor__KanbanCard__c externalGanttCard = new leankor__KanbanCard__c();
        externalGanttCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        externalGanttCard.leankor__ValueStream__c = pgValueStream2.Id;
		externalGanttCard.Name = 'Test External Gantt';
        externalGanttCard.leankor__Title__c = 'A1 Test';
		externalGanttCard.leankor__EstimatedDuration__c = 5;
        externalGanttCard.leankor__DurationUnits__c ='Days';
        externalGanttCard.leankor__StartDateTime__c = System.now();
        externalGanttCard.OwnerId = UserInfo.getUserId();
        externalGanttCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        insert externalGanttCard;

        leankor__KanbanCard__c externalKBCard = new leankor__KanbanCard__c();
		externalKBCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
		externalKBCard.leankor__ValueStream__c = kbValueStream.Id;
		externalKBCard.Name = 'Test External KB';
		externalKBCard.leankor__Title__c = 'External Test';
		externalKBCard.leankor__EstimatedDuration__c = 5;
		externalKBCard.leankor__DurationUnits__c ='Days';
		externalKBCard.leankor__StartDateTime__c = System.now();
		externalKBCard.OwnerId = UserInfo.getUserId();
		externalKBCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
		externalKBCard.leankor__MasterContainer__c = newMC.Id;
		externalKBCard.leankor__Swimlane__c = newSw.Id;
		externalKBCard.leankor__Zone__c = zone.Id;
        insert externalKBCard;

        List<leankor__KanbanCard__c> parentKCList = new List<leankor__KanbanCard__c>();
        for(Integer i = 0; i <= 200; i++) {
            leankor__KanbanCard__c parentKC = new leankor__KanbanCard__c();
			parentKC.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			parentKC.leankor__ValueStream__c = pgValueStream.Id;
			parentKC.Name = 'Test Parent';
			parentKC.leankor__Title__c = 'Test Card '+i;
			parentKC.leankor__MasterContainer__c = newMC.Id;
			parentKC.leankor__Swimlane__c = newSw.Id;
			parentKC.leankor__Zone__c = zone.Id;
			parentKC.leankor__EstimatedDuration__c = 5 + i;
			parentKC.leankor__DurationUnits__c ='Days';
			parentKC.leankor__StartDateTime__c = System.now().addDays(i);
			parentKC.OwnerId = UserInfo.getUserId();
            parentKC.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            parentKCList.add(parentKC);
        }
        insert parentKCList;

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
		for(Integer i = 1; i <= 200; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
			kanbanCard.Name = 'Test Gantt';
			kanbanCard.leankor__Title__c = 'Test Gantt Card ' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 7) == 0) {
                kanbanCard.leankor__ValueStream__c = null;
			} 
			else {
				kanbanCard.leankor__ValueStream__c = pgValueStream.Id;
			}
            if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 27) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}    

			kanbanCardsList.add(kanbanCard);
        }
        insert kanbanCardsList;

		List<leankor__KanbanCard__c> kanbanCardsList2 = new List<leankor__KanbanCard__c>();
		for(Integer i = 1; i <= 200; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = ganttTemplate.Id;
			kanbanCard.Name = 'Test Gantt2';
			kanbanCard.leankor__Title__c = 'Test Gantt Card ' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 7) == 0) {
                kanbanCard.leankor__ValueStream__c = null;
			} 
			else {
				kanbanCard.leankor__ValueStream__c = pgValueStream2.Id;
			}
            if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 27) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}    

			kanbanCardsList2.add(kanbanCard);
        }
        insert kanbanCardsList2;

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

    @isTest
    static void testUpdateExternalDependencies() {

		List<leankor__KanbanCard__c> parentKCList = [Select Id,
														Name,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name = 'Test Parent'
													Limit 10];
		
		leankor__KanbanCard__c externalCard = [Select Id,
													Name
												From leankor__KanbanCard__c
												Where Name = 'Test External Gantt'
												Limit 1];

        Set<String> parentCardIds = new Set<String>();
        Set<String> valueStreamCardIds = new Set<String>();
 
        leankor__Dependency__c dependency = new leankor__Dependency__c();
        dependency.leankor__Predecessor__c = parentKCList[0].Id;
        dependency.leankor__PredecessorType__c = 'Start To Start';
        dependency.leankor__Successor__c = externalCard.Id;
        dependency.leankor__SuccessorType__c = 'Finish To Start';
        dependency.leankor__ValueStream__c = parentKCList[0].leankor__ValueStream__c;
        parentCardIds.add(parentKCList[0].Id);
        valueStreamCardIds.add(parentKCList[0].leankor__ValueStream__c);
        insert dependency;
        
        Test.startTest();
            leankor.Dependency.updateExternalDependencies(parentCardIds, valueStreamCardIds);

        leankor__Dependency__c depen = [SELECT Id, leankor__IsDependencyRecalculate__c FROM leankor__Dependency__c WHERE Id =: dependency.Id LIMIT 1];
        
        System.assertEquals(depen.leankor__IsDependencyRecalculate__c, true);
        Test.stopTest();
    }

	/* Method tests to read some created Dependencies within a set of different Valuestreams
    * Test will pass if at least one Dependency is found within any of the specified Valuestreams.
    * Test will fail if for some reason there is no Dependency found within the Valuestreams.
    */
	@isTest
	private static void testReadDependencyValueStreamSet() {
		Set<Id> valueStreamIds = new Set<Id>();

		leankor__ValueStream__c pgBoard = [Select Id,
												Name
											From leankor__ValueStream__c
											Where Name = 'Testing PGBoard'
											Limit 1];
		valueStreamIds.add(pgBoard.Id);

		List<leankor__KanbanCard__c> parentKCList = [Select Id,
														Name,
														leankor__ValueStream__c,
														leankor__GUID__c
													From leankor__KanbanCard__c
													Where Name = 'Test Parent'
													And leankor__ValueStream__c =: pgBoard.Id
													Limit 50];
		
		List<leankor__KanbanCard__c> ganttCardsList = [Select Id,
														Name,
														leankor__ValueStream__c,
														RecordType.Name
													From leankor__KanbanCard__c
													Where Name = 'Test Gantt2'
													And RecordType.Name In ('ActivityCard', 'MileStoneCard')
													Limit 100];
		valueStreamIds.add(ganttCardsList[0].leankor__ValueStream__c);
		
		leankor__KanbanCard__c externalCard = [Select Id,
													Name,
													leankor__ValueStream__c
												From leankor__KanbanCard__c
												Where Name = 'Test External Gantt'
												Limit 1];
		valueStreamIds.add(externalCard.leankor__ValueStream__c);
	
		List<leankor__Dependency__c> deps = new List<leankor__Dependency__c>();
		for(Integer i = 0; i < parentKCList.size(); i++) {
			leankor__Dependency__c dependency = new leankor__Dependency__c();
			dependency.leankor__GUID__c = parentKCList[i].leankor__GUID__c;

			if(Math.mod(i, 25) == 0) {
				dependency.leankor__Predecessor__c = parentKCList[i].Id;
				dependency.leankor__PredecessorType__c = 'Start To Start';
				dependency.leankor__Successor__c = externalCard.Id;
				dependency.leankor__SuccessorType__c = 'Finish To Start';
				dependency.leankor__ValueStream__c = parentKCList[i].leankor__ValueStream__c;
			}
			else {
				dependency.leankor__Predecessor__c = ganttCardsList[i].Id;
				dependency.leankor__PredecessorType__c = 'Start To Start';
				dependency.leankor__Successor__c = ganttCardsList[ganttCardsList.size()-i].Id;
				dependency.leankor__SuccessorType__c = 'Finish To Start';
				dependency.leankor__ValueStream__c = ganttCardsList[i].leankor__ValueStream__c;
			}

			deps.add(dependency);
		}

		insert deps;

		Test.startTest();

			List<leankor__Dependency__c> dependencies = leankor.Dependency.readDependency(valueStreamIds);
			
			System.assert(dependencies.size() > 1, 'There should have been at least 1 dependency returned');

        Test.stopTest();
												
	}

	/* Method tests to grab a map of the predecessors and successors of created Dependencies within a set of different Valuestreams
    * Test will pass if at least one key-value pair containing a predecessor and a list of its successors is returned.
    * Test will fail if there are no key-value pairs are found within the Valuestreams.
    */
	@isTest
	private static void testGetPredecessorDepMap() {
		leankor__ValueStream__c pgBoard = [Select Id,
												Name
											From leankor__ValueStream__c
											Where Name = 'Testing PGBoard'
											Limit 1];

		List<leankor__KanbanCard__c> parentKCList = [Select Id,
														Name,
														leankor__ValueStream__c,
														leankor__GUID__c
													From leankor__KanbanCard__c
													Where Name = 'Test Parent'
													And leankor__ValueStream__c =: pgBoard.Id
													Limit 50];
		
		List<leankor__KanbanCard__c> ganttCardsList = [Select Id,
														Name,
														leankor__ValueStream__c,
														RecordType.Name
													From leankor__KanbanCard__c
													Where Name = 'Test Gantt'
													And leankor__ValueStream__c =: pgBoard.Id
													Limit 100];
		
		leankor__KanbanCard__c externalCard = [Select Id,
													Name,
													leankor__ValueStream__c
												From leankor__KanbanCard__c
												Where Name = 'Test External Gantt'
												Limit 1];
	
		List<leankor__Dependency__c> deps = new List<leankor__Dependency__c>();
		for(Integer i = 0; i < parentKCList.size(); i++) {
			leankor__Dependency__c dependency = new leankor__Dependency__c();
			dependency.leankor__GUID__c = parentKCList[i].leankor__GUID__c;

			dependency.leankor__Predecessor__c = parentKCList[i].Id;
			dependency.leankor__PredecessorType__c = 'Start To Start';

			if(Math.mod(i, 25) == 0) {
				dependency.leankor__Successor__c = externalCard.Id;
				dependency.leankor__SuccessorType__c = 'Start To Finish';
				dependency.leankor__ValueStream__c = parentKCList[i].leankor__ValueStream__c;
			}
			else {
				dependency.leankor__Successor__c = ganttCardsList[ganttCardsList.size()-i].Id;
				dependency.leankor__SuccessorType__c = 'Finish To Start';
				dependency.leankor__ValueStream__c = ganttCardsList[i].leankor__ValueStream__c;
			}

			deps.add(dependency);
		}

		insert deps;

		Test.startTest();

			Map<Id, List<leankor__Dependency__c>> preDependencies = leankor.Dependency.getPredecessorDependencyMap(deps);
			
			System.assert(preDependencies.size() > 1, 'There should have been at least 1 key and value pair returned');

        Test.stopTest();
												
	}

	/* Method tests to grab a map of the successors and predecessors of created Dependencies within a set of different Valuestreams
    * Test will pass if at least one key-value pair containing a successor and a list of its predecessors is returned.
    * Test will fail if there are no key-value pairs are found within the Valuestreams.
    */
	@isTest
	private static void testGetSuccessorDepMap() {
		leankor__ValueStream__c pgBoard = [Select Id,
												Name
											From leankor__ValueStream__c
											Where Name = 'Testing PGBoard2'
											Limit 1];

		List<leankor__KanbanCard__c> ganttCardsList = [Select Id,
														Name,
														leankor__ValueStream__c,
														leankor__GUID__c
													From leankor__KanbanCard__c
													Where Name = 'Test Gantt2'
													And leankor__ValueStream__c =: pgBoard.Id
													Limit 250];
		
		leankor__KanbanCard__c externalCard = [Select Id,
													Name,
													leankor__ValueStream__c
												From leankor__KanbanCard__c
												Where Name = 'Test External KB'
												Limit 1];
	
		List<leankor__Dependency__c> deps = new List<leankor__Dependency__c>();
		for(Integer i = 0; i < (ganttCardsList.size()/2); i++) {
			leankor__Dependency__c dependency = new leankor__Dependency__c();
			dependency.leankor__GUID__c = ganttCardsList[i].leankor__GUID__c;

			dependency.leankor__Predecessor__c = ganttCardsList[i].Id;
			dependency.leankor__PredecessorType__c = 'Start To Finish';

			if(Math.mod(i, 25) == 0) {
				dependency.leankor__Successor__c = externalCard.Id;
				dependency.leankor__SuccessorType__c = 'Finish To Finish';
				dependency.leankor__ValueStream__c = ganttCardsList[i].leankor__ValueStream__c;
			}
			else {
				dependency.leankor__Successor__c = ganttCardsList[ganttCardsList.size()-i].Id;
				dependency.leankor__SuccessorType__c = 'Finish To Finish';
				dependency.leankor__ValueStream__c = ganttCardsList[i].leankor__ValueStream__c;
			}

			deps.add(dependency);
		}

		insert deps;

		Test.startTest();

			Map<Id, List<leankor__Dependency__c>> sucDependencies = leankor.Dependency.getSuccessorDependencyMap(deps);
			
			System.assert(sucDependencies.size() > 1, 'There should have been at least 1 key and value pair returned');

        Test.stopTest();
												
	}

	/* Method tests to read in some created Dependencies within a specific Valuestream as a Community User
    * Test will pass if at least one Dependency is fouund with the specified Valuestream.
    * Test will fail if for some reason there is no Dependency found for the Valuestream.
    */
	@isTest
	private static void testReadDependencyValueStreamSetAsCommunityUser() {
		createCommunityUser();

		Test.startTest();

		System.runAs(u) {
			Set<Id> valueStreamIds = new Set<Id>();

			leankor__ValueStream__c pgBoard = [Select Id,
													Name
												From leankor__ValueStream__c
												Where Name = 'Testing PGBoard'
												Limit 1];
			valueStreamIds.add(pgBoard.Id);

			List<leankor__KanbanCard__c> parentKCList = [Select Id,
															Name,
															leankor__ValueStream__c,
															leankor__GUID__c
														From leankor__KanbanCard__c
														Where Name = 'Test Parent'
														And leankor__ValueStream__c =: pgBoard.Id
														Limit 25];
			
			List<leankor__KanbanCard__c> ganttCardsList = [Select Id,
															Name,
															leankor__ValueStream__c,
															RecordType.Name
														From leankor__KanbanCard__c
														Where Name = 'Test Gantt2'
														And RecordType.Name In ('ActivityCard', 'MileStoneCard')
														Limit 25];
			valueStreamIds.add(ganttCardsList[0].leankor__ValueStream__c);
			
			leankor__KanbanCard__c externalCard = [Select Id,
														Name,
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name = 'Test External Gantt'
													Limit 1];
			valueStreamIds.add(externalCard.leankor__ValueStream__c);
		
			List<leankor__Dependency__c> deps = new List<leankor__Dependency__c>();
			for(Integer i = 0; i < parentKCList.size(); i++) {
				leankor__Dependency__c dependency = new leankor__Dependency__c();
				dependency.leankor__GUID__c = parentKCList[i].leankor__GUID__c;

				if(Math.mod(i, 5) == 0) {
					dependency.leankor__Predecessor__c = parentKCList[i].Id;
					dependency.leankor__PredecessorType__c = 'Start To Start';
					dependency.leankor__Successor__c = externalCard.Id;
					dependency.leankor__SuccessorType__c = 'Finish To Start';
					dependency.leankor__ValueStream__c = parentKCList[i].leankor__ValueStream__c;
				}
				else {
					dependency.leankor__Predecessor__c = ganttCardsList[i].Id;
					dependency.leankor__PredecessorType__c = 'Start To Start';
					dependency.leankor__Successor__c = ganttCardsList[ganttCardsList.size()-i].Id;
					dependency.leankor__SuccessorType__c = 'Finish To Start';
					dependency.leankor__ValueStream__c = ganttCardsList[i].leankor__ValueStream__c;
				}

				deps.add(dependency);
			}

			insert deps;

			List<leankor__Dependency__c> dependencies = leankor.Dependency.readDependency(valueStreamIds);
				
			System.assert(dependencies.size() > 1, 'There should have been at least 1 dependency returned');

		}

        Test.stopTest();
												
	}

	/* Method tests to grab a map of the predecessors and successors of created Dependencies as a Visual Lean User
    * Test will pass if at least one key-value pair containing a predecessor and a list of its successors is returned.
    * Test will fail if there are no key-value pairs are found within the Valuestreams.
    */
	@isTest
	private static void testGetPredecessorDepMapAsLeanUser() {
		createVisualLeanUser();

		Test.startTest(); 

		System.runAs(u) {
			leankor__ValueStream__c pgBoard = [Select Id,
												Name
											From leankor__ValueStream__c
											Where Name = 'Testing PGBoard'
											Limit 1];

			List<leankor__KanbanCard__c> parentKCList = [Select Id,
															Name,
															leankor__ValueStream__c,
															leankor__GUID__c
														From leankor__KanbanCard__c
														Where Name = 'Test Parent'
														And leankor__ValueStream__c =: pgBoard.Id
														Limit 50];
			
			List<leankor__KanbanCard__c> ganttCardsList = [Select Id,
															Name,
															leankor__ValueStream__c,
															RecordType.Name
														From leankor__KanbanCard__c
														Where Name = 'Test Gantt'
														And leankor__ValueStream__c =: pgBoard.Id
														Limit 25];

			List<leankor__KanbanCard__c> otherGanttCardsList = [Select Id,
															Name,
															leankor__ValueStream__c,
															RecordType.Name
														From leankor__KanbanCard__c
														Where Name = 'Test Gantt2'
														Limit 25];											
		
			List<leankor__Dependency__c> deps = new List<leankor__Dependency__c>();
			Integer size = parentKCList.size();
			Integer count = size - (size / 2) - 1;
			for(Integer i = 0; i < size; i++) {
				leankor__Dependency__c dependency = new leankor__Dependency__c();
				dependency.leankor__GUID__c = parentKCList[i].leankor__GUID__c;

				dependency.leankor__Predecessor__c = parentKCList[i].Id;
				dependency.leankor__PredecessorType__c = 'Start To Start';

				if(Math.mod(i, 2) == 0) {
					dependency.leankor__Successor__c = otherGanttCardsList[count].Id;
					dependency.leankor__SuccessorType__c = 'Start To Finish';
					dependency.leankor__ValueStream__c = parentKCList[i].leankor__ValueStream__c;
				}
				else {
					dependency.leankor__Successor__c = ganttCardsList[count].Id;
					dependency.leankor__SuccessorType__c = 'Finish To Start';
					dependency.leankor__ValueStream__c = ganttCardsList[count].leankor__ValueStream__c;
					count--;
				}
				deps.add(dependency);
			}

			insert deps;

			Map<Id, List<leankor__Dependency__c>> preDependencies = leankor.Dependency.getPredecessorDependencyMap(deps);
			
			System.assert(preDependencies.size() > 1, 'There should have been at least 1 key and value pair returned');

		}

        Test.stopTest();
												
	}

}