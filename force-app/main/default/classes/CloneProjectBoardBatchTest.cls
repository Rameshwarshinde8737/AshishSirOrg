@isTest
private class CloneProjectBoardBatchTest {

    @isTest
    static void testBatchWithKanbanCards() {
        
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c();
        sourceFolder.Name = 'Source Folder111';
        insert sourceFolder;

        leankor__Portfolio__c targetFolder = new leankor__Portfolio__c();
        targetFolder.Name = 'Target Folder111';
        insert targetFolder;

        leankor__ProjectRoom__c sourceProjectRoom = new leankor__ProjectRoom__c();
        sourceProjectRoom.Name = 'Source Project Room111';
        sourceProjectRoom.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom;
        
        leankor__ProjectRoom__c sourceProjectRoom2 = new leankor__ProjectRoom__c();
        sourceProjectRoom2.Name = 'Source Project Room111222';
        sourceProjectRoom2.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom2;

        leankor__ValueStream__c sourceProjectBoard = new leankor__ValueStream__c();
        sourceProjectBoard.Name = 'Source Folder111';
        sourceProjectBoard.leankor__TaskIndicator__c = true;
        sourceProjectBoard.leankor__SevenDayWorkWeek__c = true;
        sourceProjectBoard.leankor__TaskDateCheck__c = true;
        sourceProjectBoard.leankor__ProjectBoardStartDateTime__c = DateTime.now().addDays(-10);
        sourceProjectBoard.leankor__ProjectBoardEndDateTime__c = DateTime.now().addDays(10);
        sourceProjectBoard.leankor__ProjectBoardLaunchDateTime__c = System.now();
        sourceProjectBoard.leankor__ProjectRoom__c = sourceProjectRoom.Id;
        sourceProjectBoard.leankor__IsRecordDeleted__c = false;
        insert sourceProjectBoard;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__DurationUnits__c ='Days';
        kanbanCard.leankor__StartDateTime__c = System.now().addDays(2);
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');kanbanCard.leankor__Monday__c = false;
        kanbanCard.Name = 'Activity ';
        //kanbanCard.OwnerId = standardUser.Id;
        kanbanCard.leankor__Title__c = 'Activity ';
        kanbanCard.leankor__ValueStream__c = sourceProjectBoard.Id;
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(7);
        kanbanCard.leankor__EstimatedDuration__c = 5;
        insert kanbanCard;
        
        
        CloneProjectBoardBatch.CloneProjectBoardRequest request = new CloneProjectBoardBatch.CloneProjectBoardRequest();
        request.projectRoomId = sourceProjectRoom.Id;
        request.projectBoardId = sourceProjectBoard.Id;
        request.sourceProjectId = sourceProjectRoom.Id;
        request.targetBoard = 'Cloned Board';
        request.targetRoom = 'Target Project Room';
        request.kanbanVerb = true;
        request.stickerVerb = true;
        request.markerVerb = true;
        request.chartVerb = true;
        request.cloneFiles = true;
        request.cloneCustomFields = true;
        request.zoneVerb = true;
        request.relinkClonedProjectId = sourceProjectRoom2.Id;
        request.targetProjectStartDateTime = System.now();
        request.targetProjectDueDateTime = System.now().addDays(4);
        request.projectBoardTypes = new List<String>{'Plan Board'};


        CloneProjectProcessAction.CloneProjectRequest cloneRequest = new CloneProjectProcessAction.CloneProjectRequest();

        Test.startTest();
        CloneProjectBoardBatch batch = new CloneProjectBoardBatch(request, sourceProjectBoard, cloneRequest);
        Database.executeBatch(batch);
        Test.stopTest();
            
        List<leankor__ValueStream__c> clonedBoards = [Select Id 
                                                            From leankor__ValueStream__c 
                                                            Where Name = 'Cloned Board'];

        System.assertEquals(1, clonedBoards.size(), 'Cloned board should exist');

        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :clonedBoards[0].Id];
        System.assert(!clonedCards.isEmpty(), 'Kanban cards should be cloned');
        
    }
    
    @isTest
    static void testBatchWithKanbanCards2() {
        
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c();
        sourceFolder.Name = 'Source Folder111';
        insert sourceFolder;

        leankor__Portfolio__c targetFolder = new leankor__Portfolio__c();
        targetFolder.Name = 'Target Folder111';
        insert targetFolder;

        leankor__ProjectRoom__c sourceProjectRoom = new leankor__ProjectRoom__c();
        sourceProjectRoom.Name = 'Source Project Room111';
        sourceProjectRoom.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom;
        
        leankor__ProjectRoom__c sourceProjectRoom2 = new leankor__ProjectRoom__c();
        sourceProjectRoom2.Name = 'Source Project Room111222';
        sourceProjectRoom2.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom2;

        leankor__ValueStream__c sourceProjectBoard = new leankor__ValueStream__c();
        sourceProjectBoard.Name = 'Source Folder111';
        sourceProjectBoard.leankor__TaskIndicator__c = true;
        sourceProjectBoard.leankor__SevenDayWorkWeek__c = true;
        sourceProjectBoard.leankor__TaskDateCheck__c = true;
        sourceProjectBoard.leankor__ProjectBoardStartDateTime__c = DateTime.now().addDays(-10);
        sourceProjectBoard.leankor__ProjectBoardEndDateTime__c = DateTime.now().addDays(10);
        sourceProjectBoard.leankor__ProjectBoardLaunchDateTime__c = System.now();
        sourceProjectBoard.leankor__ProjectRoom__c = sourceProjectRoom.Id;
        sourceProjectBoard.leankor__IsRecordDeleted__c = false;
        insert sourceProjectBoard;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__DurationUnits__c ='Days';
        kanbanCard.leankor__StartDateTime__c = System.now().addDays(2);
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');kanbanCard.leankor__Monday__c = false;
        kanbanCard.Name = 'Activity ';
        //kanbanCard.OwnerId = standardUser.Id;
        kanbanCard.leankor__Title__c = 'Activity ';
        kanbanCard.leankor__ValueStream__c = sourceProjectBoard.Id;
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(7);
        kanbanCard.leankor__EstimatedDuration__c = 5;
        insert kanbanCard;
        
        
        CloneProjectBoardBatch.CloneProjectBoardRequest request = new CloneProjectBoardBatch.CloneProjectBoardRequest();
        //request.projectRoomId = sourceProjectRoom.Id;
        //request.projectBoardId = sourceProjectBoard.Id;
        request.sourceProjectId = sourceProjectRoom.Id;
        request.targetBoard = 'Cloned Board';
        request.targetRoom = 'Target Project Room';
        request.kanbanVerb = true;
        request.stickerVerb = true;
        request.markerVerb = true;
        request.chartVerb = true;
        request.cloneFiles = true;
        request.cloneCustomFields = true;
        request.zoneVerb = true;
        request.relinkClonedProjectId = sourceProjectRoom2.Id;
        request.targetProjectStartDateTime = System.now();
        request.targetProjectDueDateTime = System.now().addDays(4);
        request.projectBoardTypes = new List<String>{'Plan Board'};
        //request.targetFolderName = 'Source Folder111';
		//request.projectRoom = 'Source Project Room111222';
        request.FolderName = 'Source Folder111';
        request.sourceProjectName = 'Source Project Room111';
        request.ProjectBoard = 'Source Folder111';
        request.sourceProjectName = 'Source Project Room111';

        CloneProjectProcessAction.CloneProjectRequest cloneRequest = new CloneProjectProcessAction.CloneProjectRequest();

        Test.startTest();
        CloneProjectBoardBatch batch = new CloneProjectBoardBatch(request, sourceProjectBoard, cloneRequest);
        Database.executeBatch(batch);
        Test.stopTest();
            
        List<leankor__ValueStream__c> clonedBoards = [Select Id 
                                                            From leankor__ValueStream__c 
                                                            Where Name = 'Cloned Board'];

        System.assertEquals(1, clonedBoards.size(), 'Cloned board should exist');

        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :clonedBoards[0].Id];
        System.assert(!clonedCards.isEmpty(), 'Kanban cards should be cloned');
        
    }
    /*
    @isTest
    static void testBatchWithKanbanCards3() {
        
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c();
        sourceFolder.Name = 'Source Folder111';
        insert sourceFolder;

        leankor__Portfolio__c targetFolder = new leankor__Portfolio__c();
        targetFolder.Name = 'Target Folder111';
        insert targetFolder;

        leankor__ProjectRoom__c sourceProjectRoom = new leankor__ProjectRoom__c();
        sourceProjectRoom.Name = 'Source Project Room111';
        sourceProjectRoom.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom;
        
        leankor__ProjectRoom__c sourceProjectRoom2 = new leankor__ProjectRoom__c();
        sourceProjectRoom2.Name = 'Source Project Room111222';
        sourceProjectRoom2.leankor__Portfolio__c = sourceFolder.Id;
        insert sourceProjectRoom2;

        leankor__ValueStream__c sourceProjectBoard = new leankor__ValueStream__c();
        sourceProjectBoard.Name = 'Source Folder111';
        sourceProjectBoard.leankor__TaskIndicator__c = true;
        sourceProjectBoard.leankor__SevenDayWorkWeek__c = true;
        sourceProjectBoard.leankor__TaskDateCheck__c = true;
        sourceProjectBoard.leankor__ProjectBoardStartDateTime__c = DateTime.now().addDays(-10);
        sourceProjectBoard.leankor__ProjectBoardEndDateTime__c = DateTime.now().addDays(10);
        sourceProjectBoard.leankor__ProjectBoardLaunchDateTime__c = System.now();
        sourceProjectBoard.leankor__ProjectRoom__c = sourceProjectRoom.Id;
        sourceProjectBoard.leankor__IsRecordDeleted__c = false;
        insert sourceProjectBoard;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__DurationUnits__c ='Days';
        kanbanCard.leankor__StartDateTime__c = System.now().addDays(2);
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');kanbanCard.leankor__Monday__c = false;
        kanbanCard.Name = 'Activity ';
        //kanbanCard.OwnerId = standardUser.Id;
        kanbanCard.leankor__Title__c = 'Activity ';
        kanbanCard.leankor__ValueStream__c = sourceProjectBoard.Id;
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(7);
        kanbanCard.leankor__EstimatedDuration__c = 5;
        insert kanbanCard;
        
        
        CloneProjectBoardBatch.CloneProjectBoardRequest request = new CloneProjectBoardBatch.CloneProjectBoardRequest();
        //request.projectRoomId = sourceProjectRoom.Id;
        request.projectBoardId = sourceProjectBoard.Id;
        request.sourceProjectId = sourceProjectRoom.Id;
        request.targetBoard = 'Cloned Board';
        request.targetRoom = 'Target Project Room';
        request.kanbanVerb = true;
        request.stickerVerb = true;
        request.markerVerb = true;
        request.chartVerb = true;
        request.cloneFiles = true;
        request.cloneCustomFields = true;
        request.zoneVerb = true;
        request.relinkClonedProjectId = sourceProjectRoom2.Id;
        request.targetProjectStartDateTime = System.now();
        request.targetProjectDueDateTime = System.now().addDays(4);
        request.projectBoardTypes = new List<String>{'Plan Board'};
        request.targetFolderName = 'Source Folder111';
		request.projectRoom = 'Source Project Room111222';
        request.FolderName = 'Source Folder111';
        request.sourceProjectName = 'Source Project Room111';

        CloneProjectProcessAction.CloneProjectRequest cloneRequest = new CloneProjectProcessAction.CloneProjectRequest();

        Test.startTest();
        
        
        try {
            CloneProjectBoardBatch batch = new CloneProjectBoardBatch(request, sourceProjectBoard, cloneRequest);
        	Database.executeBatch(batch);
            //System.assert(false, 'Expected CloneProjectBoardBatchException was not thrown');
        } catch (DMLException  e) {
            System.assert(e.getMessage().contains('Simulated DML failure'), 'Unexpected exception message: ' + e.getMessage());
        }
        
        Test.stopTest();
            
        List<leankor__ValueStream__c> clonedBoards = [Select Id 
                                                            From leankor__ValueStream__c 
                                                            Where Name = 'Cloned Board'];

        System.assertEquals(1, clonedBoards.size(), 'Cloned board should exist');

        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :clonedBoards[0].Id];
        System.assert(!clonedCards.isEmpty(), 'Kanban cards should be cloned');
        
    }
    */
    @isTest
    static void testReLinkProjectSuccess() {
        
        leankor__ProjectRoom__c insertroom1 = new leankor__ProjectRoom__c();
        insertroom1.Name ='testRoom1';
		insert insertroom1;

        leankor__ValueStream__c vs1 = new leankor__ValueStream__c();
        vs1.Name = 'Test Data1';
        vs1.leankor__isRecordDeleted__c = false;
        vs1.leankor__BoardType__c = 'UberBoard';
        vs1.leankor__ProjectRoom__c = insertroom1.Id;

        leankor__ValueStream__c vs2 = new leankor__ValueStream__c();
        vs2.Name = 'Test Data2';
        vs2.leankor__isRecordDeleted__c = false;
        vs2.leankor__BoardType__c = 'Plan Board';
        vs2.leankor__ProjectRoom__c = insertroom1.Id;

        leankor__ValueStream__c vs3 = new leankor__ValueStream__c();
        vs3.Name = 'Test Data3';
        vs3.leankor__isRecordDeleted__c = false;
        vs3.leankor__ProjectRoom__c = insertroom1.Id;

        leankor__ValueStream__c vs4 = new leankor__ValueStream__c();
        vs4.Name = 'Test Data4';
        vs4.leankor__ProjectRoom__c = insertroom1.Id;

        insert new List<leankor__ValueStream__c>{vs1, vs2, vs3, vs4};
        
        leankor__ValueStream__c uberBoard = new leankor__ValueStream__c();
        uberBoard.leankor__ProjectRoom__c = insertroom1.Id;
        uberBoard.leankor__BoardType__c = 'UberBoard';
        uberBoard.leankor__ProjectRoomLink__c = insertroom1.Id;
        uberBoard.leankor__isRecordDeleted__c = false;

        leankor__ValueStream__c planBoard = new leankor__ValueStream__c();
        planBoard.leankor__ProjectRoom__c = insertroom1.Id;
        planBoard.leankor__BoardType__c = 'Plan Board';
        planBoard.leankor__ProjectRoomLink__c = insertroom1.Id;
        planBoard.leankor__isRecordDeleted__c = false;

        insert new List<leankor__ValueStream__c>{ uberBoard, planBoard };
        
        leankor__kanbanCard__c kb1 = new leankor__kanbanCard__c();
        kb1.Name = 'kb1';
        kb1.leankor__GUID__c = 'test1';
        kb1.leankor__isRecordDeleted__c = false;
        kb1.leankor__ValueStream__c = uberBoard.Id;
        kb1.leankor__ValueStreamLink__c = vs1.Id;

        leankor__kanbanCard__c kb2 = new leankor__kanbanCard__c();
        kb2.Name = 'kb2';
        kb2.leankor__GUID__c = 'test2';
        kb2.leankor__isRecordDeleted__c = false;
        kb2.leankor__ValueStream__c = planBoard.Id;
        kb2.leankor__ValueStreamLink__c = vs2.Id;

        leankor__kanbanCard__c kb4 = new leankor__kanbanCard__c(); 
        kb4.Name = 'kb5';
        kb4.leankor__GUID__c = 'test4';
        insert kb4;

        leankor__kanbanCard__c kb3 = new leankor__kanbanCard__c();
        kb3.Name = 'kb4';
        kb3.leankor__GUID__c = 'test3';
        kb3.leankor__ValueStreamCardLink__c = kb4.Id;
        kb3.leankor__isRecordDeleted__c = false;
        kb3.leankor__ValueStream__c = vs3.Id;
        
        leankor__kanbanCard__c kb5 = new leankor__kanbanCard__c(); 
        kb5.Name = 'kb7';
        kb5.leankor__GUID__c = 'test8';
        kb5.leankor__isRecordDeleted__c = true;
        kb5.leankor__ValueStream__c = vs4.Id;
        insert kb5;

        leankor__kanbanCard__c kb6 = new leankor__kanbanCard__c();
        kb6.Name = 'kb8';
        kb6.leankor__GUID__c = 'test9';
        kb6.leankor__ValueStreamCardLink__c = kb5.Id;
        kb6.leankor__isRecordDeleted__c = false;
        kb6.leankor__ValueStream__c = vs4.Id;
        kb6.leankor__ValueStreamLink__c = vs4.Id;
        
        insert new List<leankor__kanbanCard__c>{kb1, kb2, kb3, kb6};
            
        CLoneProjectBoardBatch.CloneProjectBoardRequest req = new CLoneProjectBoardBatch.CloneProjectBoardRequest();
        req.relinkClonedProjectId = insertroom1.Id;
        req.projectRoomId = insertroom1.Id;
        req.relinkClonedExpenses = new Map<Id, List<leankor__Expense__c>>();
        
        Test.startTest();
        CloneProjectBoardBatch.reLinkProject(req);
            
        leankor__ValueStream__c updatedUber = [Select leankor__ValueStreamCardLink__c, 
                                                        leankor__ValueStreamLink__c, 
                                                        leankor__ProjectRoomLink__c 
                                                    From leankor__ValueStream__c 
                                                    Where Id = :uberBoard.Id];

        System.assertEquals(null, updatedUber.leankor__ValueStreamCardLink__c, 'UberBoard card link should be null');
        System.assertEquals(null, updatedUber.leankor__ValueStreamLink__c, 'UberBoard stream link should be null');
        System.assertEquals(null, updatedUber.leankor__ProjectRoomLink__c, 'UberBoard project room link should be null');
            
        leankor__ValueStream__c updatedPlan = [Select leankor__ValueStreamCardLink__c, 
                                                        leankor__ValueStreamLink__c, 
                                                        leankor__ProjectRoomLink__c 
                                                    From leankor__ValueStream__c 
                                                    Where Id = :planBoard.Id];
                                                        
        System.assertEquals(null, updatedPlan.leankor__ValueStreamCardLink__c, 'PlanBoard card link should be null');
        System.assertEquals(null, updatedPlan.leankor__ValueStreamLink__c, 'PlanBoard stream link should be null');
        System.assertEquals(null, updatedPlan.leankor__ProjectRoomLink__c, 'PlanBoard project room link should be null');
        
        Test.stopTest();
                    
    }
    
    @isTest
    static void testReLinkProjectWithExpenses() {
        
        leankor__ProjectRoom__c testProjectRoom = new leankor__ProjectRoom__c();
        testProjectRoom.Name = 'Test Project Room';
        insert testProjectRoom;

        leankor__ProjectRoom__c clonedProjectRoom = new leankor__ProjectRoom__c();
        clonedProjectRoom.Name = 'Cloned Project Room';
        insert clonedProjectRoom;

        leankor__ValueStream__c uberBoard = new leankor__ValueStream__c();
        uberBoard.Name = 'Test 1';
        uberBoard.leankor__ProjectRoom__c = clonedProjectRoom.Id;
        uberBoard.leankor__BoardType__c = 'UberBoard';
        uberBoard.leankor__isRecordDeleted__c = false; // Example of another filter condition
        insert uberBoard;

        leankor__KanbanCard__c uberCard = new leankor__KanbanCard__c();
        uberCard.Name = 'Uber Card';
        uberCard.leankor__GUID__c = uberBoard.Id;
        uberCard.leankor__ValueStream__c = uberBoard.Id;
        insert uberCard;

        // Create expenses linked to the KanbanCard
        leankor__Expense__c expense = new leankor__Expense__c();
        expense.Name = 'Test Expense';
        expense.leankor__ProjectBoard__c = uberBoard.Id;
        expense.leankor__KanbanCard__c = uberCard.Id;
        expense.leankor__Project__c = clonedProjectRoom.Id;
        
        insert expense;

        // Prepare the request with expenses
        CLoneProjectBoardBatch.CloneProjectBoardRequest request = new CLoneProjectBoardBatch.CloneProjectBoardRequest();
        request.relinkClonedProjectId = clonedProjectRoom.Id;
        request.projectRoomId = testProjectRoom.Id;
        request.relinkClonedExpenses = new Map<Id, List<leankor__Expense__c>>{
            uberCard.Id => new List<leankor__Expense__c>{ expense }
        };

        Test.startTest();
        CloneProjectBoardBatch.reLinkProject(request);
    
        leankor__Expense__c updatedExpense = [Select leankor__ProjectBoard__c, 
                                                        leankor__KanbanCard__c
                                                    From leankor__Expense__c
                                                    Where Id = :expense.Id];
            
        System.assertEquals(null, updatedExpense.leankor__ProjectBoard__c, 'Expense ProjectBoard should be updated');
        System.assertEquals(null, updatedExpense.leankor__KanbanCard__c, 'Expense KanbanCard should be updated');
        
        Test.stopTest();
    }


}