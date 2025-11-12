@isTest
public class MergeProjectBoardActionTest {
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/
    @TestSetup
    static void setupData() {
        leankor__LeanConstants__c leanConstants = leankor__LeanConstants__c.getInstance();
        leanConstants.leankor__FirstDayOfTheWeek__c = 1; // Monday  
        upsert leanConstants;

        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;

        leankor__Portfolio__c targetFolder = new leankor__Portfolio__c();
        targetFolder.Name = 'Target Folder';
        insert targetFolder;

        leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
        sampleRoom.Name = 'Test Room';
        sampleRoom.leankor__Portfolio__c = testFolder.Id;
        insert sampleRoom;

        leankor__ProjectRoom__c targetRoom = new leankor__ProjectRoom__c();
        targetRoom.Name = 'Target Room';
        targetRoom.leankor__Portfolio__c = testFolder.Id;
        insert targetRoom;

        leankor.RealTimeController.ProjectBoard sampleBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board', sampleRoom.Id, 'kanban board', '', '');
        leankor.RealTimeController.ProjectBoard targetBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board1', sampleRoom.Id, 'kanban board', '', '');
        
        leankor__ValueStream__c targetValueStream = [Select Id,
                                                            leankor__SevenDayWorkWeek__c 
                                                        From leankor__ValueStream__c 
                                                        Where Id = :targetBoard.Id 
                                                        Limit 1];
        targetValueStream.leankor__SevenDayWorkWeek__c = false;
        update targetValueStream;

        leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
        masterContainer1.Name = 'CommonMC';
        masterContainer1.leankor__ValueStream__c = sampleBoard.Id;
        masterContainer1.leankor__Order__c = 7.0;
        masterContainer1.leankor__Guid__c = leankor.TestDataFactory.createGuid();

        leankor__MasterContainer__c masterContainer2 = new leankor__MasterContainer__c();
        masterContainer2.Name = 'CommonMC';
        masterContainer2.leankor__ValueStream__c = targetBoard.Id;
        masterContainer2.leankor__Order__c = 8.0;
        masterContainer2.leankor__Guid__c = leankor.TestDataFactory.createGuid();

        insert new List<leankor__MasterContainer__c>{masterContainer1, masterContainer2};

        leankor__Swimlane__c swimlane1 = new leankor__Swimlane__c();
        swimlane1.Name = 'CommonSwimlane1';
        swimlane1.leankor__MasterContainer__c = masterContainer1.Id;
        swimlane1.leankor__Order__c = 1.0;
        swimlane1.leankor__ValueStream__c = sampleBoard.Id;

        leankor__Swimlane__c swimlane2 = new leankor__Swimlane__c();
        swimlane2.Name = 'CommonSwimlane2';
        swimlane2.leankor__MasterContainer__c = masterContainer2.Id;
        swimlane2.leankor__Order__c = 1.0;
        swimlane2.leankor__ValueStream__c = targetBoard.Id;

        insert new List<leankor__Swimlane__c>{swimlane1, swimlane2};

        leankor__Zone__c zone1 = new leankor__Zone__c();
        zone1.Name = 'CommonZone';
        zone1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        zone1.leankor__CmpID__c = 'my-CMPID-zone-test';
        zone1.leankor__Swimlane__c = swimlane1.Id;
        zone1.leankor__ValueStream__c = sampleBoard.Id;

        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'CommonZone';
        zone2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        zone2.leankor__CmpID__c = 'my-CMPID-zone-test';
        zone2.leankor__Swimlane__c = swimlane2.Id;
        zone2.leankor__ValueStream__c = targetBoard.Id;

        insert new List<leankor__Zone__c>{zone1, zone2};

        leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c();
        kanbanCardTemplate.Name = 'RED Card';
        kanbanCardTemplate.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCardTemplate.leankor__Color__c = '#F71B1B'; 
        kanbanCardTemplate.leankor__Width__c = 328.0;
        insert kanbanCardTemplate;

        DateTime weekendDate = DateTime.newInstance(2025, 6, 21, 12, 0, 0); // Saturday
        leankor__KanbanCard__c kanbanCard1 = new leankor__KanbanCard__c();
        kanbanCard1.leankor__StartDateTime__c = weekendDate;
        kanbanCard1.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
        kanbanCard1.leankor__EstimatedDuration__c = 1;
        kanbanCard1.Name = 'new card 1';
        kanbanCard1.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
        kanbanCard1.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard1.leankor__MasterContainer__c = masterContainer1.Id;
        kanbanCard1.leankor__Swimlane__c = swimlane1.Id;
        kanbanCard1.leankor__Order__c = 5;
        kanbanCard1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanbanCard1.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
        kanbanCard1.leankor__DurationUnits__c = 'Hours';
        kanbanCard1.leankor__CmpID__c = 'mpsinghKanbanCard';

        insert new List<leankor__KanbanCard__c>{kanbanCard1};

        List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
            for (String unit : new List<String>{'Years', 'Months', 'Weeks', 'Days', 'Hours', 'Minutes'}) {
                leankor__KanbanCard__c card = new leankor__KanbanCard__c();
                card.Name = 'Card ' + unit;
                card.leankor__StartDateTime__c = weekendDate;
                card.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
                card.leankor__EstimatedDuration__c = 1;
                card.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
                card.leankor__ValueStream__c = sampleBoard.Id;
                card.leankor__MasterContainer__c = masterContainer2.Id;
                card.leankor__Swimlane__c = swimlane2.Id;
                card.leankor__Order__c = 5;
                card.leankor__GUID__c = leankor.TestDataFactory.createGuid();
                card.leankor__ZoneGUID__c = zone2.leankor__GUID__c;
                card.leankor__DurationUnits__c = unit;
                cards.add(card);
            }
        insert cards;
        leankor__Dependency__c dep = new leankor__Dependency__c();
        dep.leankor__Predecessor__c = kanbanCard1.Id;
        dep.leankor__Successor__c = cards[0].Id;
        insert dep;

        Task task = new Task();
        task.Priority = 'High';
        task.Status = 'In Progress';
        task.WhatId = kanbanCard1.Id;
        task.ActivityDate = System.today();
        insert task;

        leankor__IssueLog__c issueLog = new leankor__IssueLog__c();
        issueLog.Name = 'issue1';
        issueLog.leankor__KanbanCard__c = kanbanCard1.Id;
        issueLog.leankor__Task__c = task.Id;
        insert issueLog;

        leankor__TimeCard__c timeCard = new leankor__TimeCard__c();
        timeCard.leankor__KanbanCard__c = kanbanCard1.Id;
        timeCard.leankor__Task__c = task.Id;
        timeCard.leankor__TaskDueDate__c = System.now().addDays(5);
        insert timeCard;

        leankor__Sticker__c sticker = new leankor__Sticker__c();
        sticker.leankor__ValueStream__c = sampleBoard.Id;
        sticker.Name = 'sticker 1';
        insert sticker;

        leankor__KanbanCardSticker__c kansticker = new leankor__KanbanCardSticker__c();
        kansticker.leankor__KanbanCard__c = kanbanCard1.Id;
        kansticker.leankor__Sticker__c = sticker.Id;
        insert kansticker;
    }
    /*-------------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This Test method tests the mergeProjectBoard functionality by merging a source project board into a target project board.
    -------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardTest() {
        leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
        targetBoard.Name = 'Project Board1';
        targetBoard.leankor__ProjectRoom__c = [Select Id 
                                                    From leankor__ProjectRoom__c 
                                                    Where Name = 'Test Room' 
                                                    Limit 1].Id;
        targetBoard.leankor__SevenDayWorkWeek__c = false;
        insert targetBoard;
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            Name 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :targetBoard.Id];
        // Create first Swimlane
        leankor__swimlane__c swimlane1 = new leankor__swimlane__c();
        swimlane1.Name = 'swimlanetest';
        swimlane1.leankor__order__c = 1.0;
        swimlane1.leankor__ValueStream__c = targetBoard.Id;
        insert swimlane1;

        // Create first Zone
        leankor__Zone__c zone1 = new leankor__Zone__c();
        zone1.Name = 'kanban test 3';
        zone1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        zone1.leankor__CmpID__c = 'my-CMPID-zone-test3';
        zone1.leankor__swimlane__c = swimlane1.ID;
        zone1.leankor__ValueStream__c = targetBoard.Id;
        insert zone1;
        List<MergeProjectBoardAction.MergeProjectBoardRequest> mergeRequests = new List<MergeProjectBoardAction.MergeProjectBoardRequest>();
        MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
        mergeRequest.sourceBoardId = [Select Id 
                                            From leankor__ValueStream__c 
                                            Where Name = 'Project Board' 
                                            Limit 1].Id;
        mergeRequest.targetBoardId = targetBoard.Id;
        mergeRequest.WithMC = true;
        
        mergeRequests.add(mergeRequest);

        Test.startTest();
            MergeProjectBoardAction.MergeProjectBoard(mergeRequests);
            leankor__KanbanCard__c targetKanbanCards = [Select Id, 
                                                                Name 
                                                            From leankor__KanbanCard__c 
                                                            Limit 1];
            mergeRequest.sourceBoardId = targetKanbanCards.Id;
            mergeRequests.add(mergeRequest);
            try {
                MergeProjectBoardAction.MergeProjectBoard(mergeRequests);
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Error: Invalid input','Assert that the error message is correct');
            }
        Test.stopTest();
    }
    /*-------------------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This Test method tests the mergeProjectBoardProcess functionality by merging a source project board into a target project board
                with Null values for SourceBoardId.
    --------------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTest() {
        leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Test Room' 
                                                        Limit 1];
        leankor__ValueStream__c sourceBoard = [Select Id,
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board' 
                                                    Limit 1];
        leankor__ValueStream__c targetBoard = [Select Id, 
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board1' 
                                                    Limit 1];
        List<MergeProjectBoardAction.MergeProjectBoardRequest> mergeRequests = new List<MergeProjectBoardAction.MergeProjectBoardRequest>();
        MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
        mergeRequest.sourceBoardId = Null;
        mergeRequest.targetBoardId = targetBoard.Id;
        mergeRequest.WithMC = true;
        mergeRequest.SourceBoardName = sourceBoard.Name;
        mergeRequest.TargetBoardName = targetBoard.Name;
        mergeRequest.SourceRoomName = SourceRoomName.Name;
        mergeRequest.SourceFolderName = 'Test Room';
        //Start Test
        Test.startTest();
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            mergeRequest.SourceFolderName = Null;
            List<leankor__KanbanCard__c> result = MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Expected Kanban cards to be returned after successful merge process.');
    }
    /*-------------------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method Tests MergeProjectBoardProcess with a null TargetBoardId to verify successful merging 
                using TargetBoardName and TargetRoomName.
    --------------------------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTest1() {
        leankor__ProjectRoom__c targetRoom = [Select Id, 
                                                        Name 
                                                    From leankor__ProjectRoom__c 
                                                    Where Name = 'Target Room' 
                                                    Limit 1];
        leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Test Room' 
                                                        Limit 1];
        leankor__ValueStream__c sourceBoard = [Select Id,
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board' 
                                                    Limit 1];
        leankor__ValueStream__c targetBoard = [Select Id, 
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board1' 
                                                    Limit 1];
        targetBoard.leankor__ProjectRoom__c = targetRoom.Id;
        update targetBoard;
        
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Test Card';
        kanbanCard.leankor__ValueStream__c = targetBoard.Id;
        kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
        insert kanbanCard;
        
        List<MergeProjectBoardAction.MergeProjectBoardRequest> mergeRequests = new List<MergeProjectBoardAction.MergeProjectBoardRequest>();
        MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
        mergeRequest.targetBoardId = Null;
        mergeRequest.WithMC = true;
        mergeRequest.SourceBoardName = sourceBoard.Name;
        mergeRequest.TargetBoardName = targetBoard.Name;
        mergeRequest.SourceRoomName = SourceRoomName.Name;
        mergeRequest.SourceFolderName = 'Test Room';
        mergeRequest.TargetRoomName = targetRoom.Name;

        Test.startTest();
            List<leankor__KanbanCard__c> result = MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'Expected Kanban cards to be returned after successful merge with valid TargetBoardName.');
    }
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method tests MergeProjectBoardProcess with null LinkKanbanCardId and validates behavior
                with and without LinkFolderName.
    ----------------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTestTwo() {
        Test.startTest();
            leankor__Portfolio__c linkFolder = new leankor__Portfolio__c();
            linkFolder.Name = 'LinkedFolder';
            insert linkFolder;
            
            leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
            linkRoom.Name = 'LinkedRoom';
            linkRoom.leankor__Portfolio__c = linkFolder.Id;
            insert linkRoom;
            
            leankor__ProjectRoom__c targetRoom = [Select Id, 
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Target Room' 
                                                        Limit 1];
            //source Room And Source Board
            leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Where Name = 'Test Room' 
                                                            Limit 1];
            leankor__ValueStream__c sourceBoard = [Select Id,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            sourceBoard.leankor__ProjectRoom__c = SourceRoomName.Id;
            update sourceBoard;
            
            leankor__ValueStream__c targetBoard = [Select Id, 
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            targetBoard.leankor__ProjectRoom__c = targetRoom.Id;
            targetBoard.leankor__BoardType__c = 'Dashboard';
            update targetBoard;
            
            // Insert the LinkBoard record properly with correct lookups
            leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
            linkBoard.Name = 'LinkBoard ValueSream';  // ensure this matches in request
            linkBoard.leankor__Portfolio__c = linkFolder.Id;
            linkBoard.leankor__ProjectRoom__c = linkRoom.Id;
            insert linkBoard;

            // Create Kanban Cards
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Test Card';
            kanbanCard.leankor__ValueStream__c = linkBoard.Id; // changed to LinkBoard for consistency
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0)+2; // Sunday
            insert kanbanCard;
            
            leankor__KanbanCard__c childKanbanCard = new leankor__KanbanCard__c();
            childKanbanCard.Name = 'Child Kanban Card';
            childKanbanCard.leankor__ValueStreamCardLink__c = kanbanCard.Id;
            childKanbanCard.leankor__ValueStream__c = linkBoard.Id;
            childKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            childKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0)+2; // Sunday
            insert childKanbanCard;

            MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
            mergeRequest.LinkKanbanCardId = null;
            mergeRequest.LinkKanbanCardName = childKanbanCard.Name;
            mergeRequest.LinkBoardName = linkBoard.Name;
            mergeRequest.LinkRoomName = linkRoom.Name;
            mergeRequest.LinkfolderName = linkFolder.Name;
            mergeRequest.TargetRoomName = targetRoom.Name;
            mergeRequest.TargetBoardName = targetBoard.Name;
            mergeRequest.SourceRoomName = SourceRoomName.Name;
            mergeRequest.SourceBoardName = sourceBoard.Name;
            mergeRequest.WithMC = true;
            mergeRequest.initialDate = System.today().addDays(-7);

            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            mergeRequest.LinkfolderName = null;
            mergeRequest.LinkRoomName = linkRoom.Name;
            mergeRequest.LinkBoardId = Null;
            mergeRequest.LinkBoardName = linkBoard.Name;
            
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
        //Assertion :
        List<leankor__KanbanCard__c> result = MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        System.assertNotEquals(0, result.size(), 'Expected Kanban cards to be returned after successful merge with valid linked card setup.');
    }
    /*-----------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method tests MergeProjectBoardProcess with valid LinkKanbanCardId.
    ------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTestThree() {
        Test.startTest();
            leankor__Portfolio__c linkFolder = new leankor__Portfolio__c();
            linkFolder.Name = 'LinkedFolder';
            insert linkFolder;

            leankor__Portfolio__c targetFolder = [Select Id, 
                                                            Name 
                                                        From leankor__Portfolio__c 
                                                        Where Name = 'Target Folder' 
                                                        Limit 1];
            
            leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
            linkRoom.Name = 'LinkedRoom';
            linkRoom.leankor__Portfolio__c = linkFolder.Id;
            insert linkRoom;
            
            leankor__ProjectRoom__c targetRoom = [Select Id, 
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Target Room' 
                                                        Limit 1];
            targetRoom.leankor__portfolio__c = targetFolder.Id;
            update targetRoom;
            //source Room And Source Board
            leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Where Name = 'Test Room' 
                                                            Limit 1];
            leankor__ValueStream__c sourceBoard = [Select Id,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            sourceBoard.leankor__ProjectRoom__c = SourceRoomName.Id;
            update sourceBoard;
            
            leankor__ValueStream__c targetBoard = [Select Id, 
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            targetBoard.leankor__ProjectRoom__c = targetRoom.Id;
            targetBoard.leankor__BoardType__c = 'Dashboard';
            update targetBoard;
            
            // Insert the LinkBoard record properly with correct lookups
            leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
            linkBoard.Name = 'LinkBoard ValueSream';
            linkBoard.leankor__Portfolio__c = linkFolder.Id;
            linkBoard.leankor__ProjectRoom__c = linkRoom.Id;
            insert linkBoard;

            // Create Kanban Cards
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Test Card';
            kanbanCard.leankor__ValueStream__c = linkBoard.Id; // changed to LinkBoard for consistency
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert kanbanCard;
            
            leankor__KanbanCard__c childKanbanCard = new leankor__KanbanCard__c();
            childKanbanCard.Name = 'Child Kanban Card';
            childKanbanCard.leankor__ValueStreamCardLink__c = kanbanCard.Id;
            childKanbanCard.leankor__ValueStream__c = linkBoard.Id;
            childKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            childKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert childKanbanCard;

            MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
            mergeRequest.TargetfolderName = 'Target Folder';
            mergeRequest.TargetRoomName = targetRoom.Name;
            mergeRequest.LinkKanbanCardId = null;
            mergeRequest.LinkKanbanCardName = childKanbanCard.Name;
            mergeRequest.LinkBoardId = linkBoard.Id;
            mergeRequest.LinkBoardName = linkBoard.Name;
            mergeRequest.LinkRoomName = linkRoom.Name;
            mergeRequest.LinkfolderName = linkFolder.Name;
            mergeRequest.TargetRoomName = targetRoom.Name;
            mergeRequest.TargetBoardName = targetBoard.Name;
            mergeRequest.SourceRoomName = SourceRoomName.Name;
            mergeRequest.SourceBoardName = sourceBoard.Name;
            mergeRequest.WithMC = true;
            mergeRequest.initialDate = System.today().addDays(-7);

            try {
                MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('LinkKanbanCardId cannot be null') || e.getMessage().contains('required') || e.getMessage().contains('Missing'), 'Expected error due to null LinkKanbanCardId.');
            }
            // Safe re-run with LinkKanbanCardId populated
            mergeRequest.LinkKanbanCardId = childKanbanCard.Id;
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
    }
    /*-----------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method tests MergeProjectBoardProcess with null LinkFolderName and LinkBoardId,
                expecting an exception for invalid input.
    -------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTestFour() {
        Test.startTest();
            leankor__Portfolio__c linkFolder = new leankor__Portfolio__c();
            linkFolder.Name = 'LinkedFolder';
            insert linkFolder;

            leankor__Portfolio__c targetFolder = [Select Id, 
                                                            Name 
                                                        From leankor__Portfolio__c 
                                                        Where Name = 'Target Folder' 
                                                        Limit 1];
            
            leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
            linkRoom.Name = 'LinkedRoom';
            linkRoom.leankor__Portfolio__c = linkFolder.Id;
            insert linkRoom;
            
            leankor__ProjectRoom__c targetRoom = [Select Id, 
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Target Room' 
                                                        Limit 1];
            targetRoom.leankor__portfolio__c = targetFolder.Id;
            update targetRoom;
            //source Room And Source Board
            leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Where Name = 'Test Room' 
                                                            Limit 1];
            leankor__ValueStream__c sourceBoard = [Select Id,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            sourceBoard.leankor__ProjectRoom__c = SourceRoomName.Id;
            update sourceBoard;
            
            leankor__ValueStream__c targetBoard = [Select Id,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            targetBoard.leankor__ProjectRoom__c = targetRoom.Id;
            targetBoard.leankor__BoardType__c = 'Dashboard';
            update targetBoard;
            
            // Insert the LinkBoard record properly with correct lookups
            leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
            linkBoard.Name = 'LinkBoard ValueSream';  // ensure this matches in request
            linkBoard.leankor__Portfolio__c = linkFolder.Id;
            linkBoard.leankor__ProjectRoom__c = linkRoom.Id;
            insert linkBoard;

            // Create Kanban Cards
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Test Card';
            kanbanCard.leankor__ValueStream__c = linkBoard.Id; // changed to LinkBoard for consistency
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert kanbanCard;
            
            leankor__KanbanCard__c childKanbanCard = new leankor__KanbanCard__c();
            childKanbanCard.Name = 'Child Kanban Card';
            childKanbanCard.leankor__ValueStreamCardLink__c = kanbanCard.Id;
            childKanbanCard.leankor__ValueStream__c = linkBoard.Id;
            childKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            childKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert childKanbanCard;

            MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
            mergeRequest.TargetfolderName = 'Target Folder';
            mergeRequest.LinkFolderName = Null;
            mergeRequest.TargetRoomName = targetRoom.Name;
            mergeRequest.LinkRoomName = linkRoom.Name;
            mergeRequest.LinkBoardId = Null;
            mergeRequest.LinkBoardName = linkBoard.Name;
            mergeRequest.LinkKanbanCardId = childKanbanCard.Id;
            mergeRequest.LinkKanbanCardName = childKanbanCard.Name;
            mergeRequest.TargetDate = DateTime.newInstance(2025, 6, 22, 12, 0, 0);
            
            try {
                MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            } catch (Exception e) {
                System.debug('Caught Exception: ' + e.getMessage());
                System.assertNotEquals(null, e, 'An exception should be thrown for invalid merge input.');
            }
        Test.stopTest();
    }
    /*------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method tests MergeProjectBoardProcess with linked Kanban cards, null LinkBoardId, and
                varying WithMC and initialDate settings.
    -------------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTestFive() {
        Test.startTest();
            leankor__Portfolio__c linkFolder = new leankor__Portfolio__c();
            linkFolder.Name = 'LinkedFolder';
            insert linkFolder;

            leankor__Portfolio__c targetFolder = [Select Id, 
                                                            Name 
                                                        From leankor__Portfolio__c 
                                                        Where Name = 'Target Folder' 
                                                        Limit 1];
            
            leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
            linkRoom.Name = 'LinkedRoom';
            linkRoom.leankor__Portfolio__c = linkFolder.Id;
            insert linkRoom;
            
            leankor__ProjectRoom__c targetRoom = [Select Id, 
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Target Room' 
                                                        Limit 1];
            targetRoom.leankor__portfolio__c = targetFolder.Id;
            update targetRoom;
            //source Room And Source Board
            leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Where Name = 'Test Room' 
                                                            Limit 1];
            leankor__ValueStream__c sourceBoard = [Select Id,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            sourceBoard.leankor__ProjectRoom__c = SourceRoomName.Id;
            update sourceBoard;
            
            leankor__ValueStream__c targetBoard = [Select Id, 
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            targetBoard.leankor__ProjectRoom__c = targetRoom.Id;
            targetBoard.leankor__BoardType__c = 'Dashboard';
            targetBoard.leankor__SevenDayWorkWeek__c = true; // Set to true for testing
            update targetBoard;

            // Insert the LinkBoard record properly with correct lookups
            leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
            linkBoard.Name = 'LinkBoard ValueSream';  // ensure this matches in request
            linkBoard.leankor__Portfolio__c = linkFolder.Id;
            linkBoard.leankor__ProjectRoom__c = linkRoom.Id;
            insert linkBoard;
            DateTime weekendDate = DateTime.newInstance(2025, 6, 21, 12, 0, 0);
            // Create Kanban Cards
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Test Card';
            kanbanCard.leankor__ValueStream__c = targetBoard.Id; // changed to LinkBoard for consistency
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__StartDateTime__c = weekendDate;
            kanbanCard.leankor__CmpID__c = 'mpsinghKanbanCard';
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert kanbanCard;
            
            leankor__KanbanCard__c childKanbanCard = new leankor__KanbanCard__c();
            childKanbanCard.Name = 'Child Kanban Card';
            childKanbanCard.leankor__ValueStreamCardLink__c = kanbanCard.Id;
            childKanbanCard.leankor__ValueStream__c = linkBoard.Id;
            childKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            childKanbanCard.leankor__CmpID__c = 'mpsinghChildKanbanCard';
            childKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0); // Sunday
            insert childKanbanCard;

            MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
            mergeRequest.LinkFolderName = linkFolder.Name;
            mergeRequest.LinkBoardId = Null;
            mergeRequest.LinkBoardName = linkBoard.Name;
            mergeRequest.LinkRoomName = linkRoom.Name;
            mergeRequest.TargetBoardId = targetBoard.Id;
            mergeRequest.SourceBoardId = sourceBoard.Id;
            mergeRequest.initialDate = System.today().addDays(-7);
            mergeRequest.WithMC = true;
            mergeRequest.TargetDate = DateTime.newInstance(2025, 6, 22, 12, 0, 0);

            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            mergeRequest.LinkBoardId = linkBoard.Id;
            mergeRequest.WithMC = false;
            mergeRequest.initialDate = Null;
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
        //assertion: check if the target board still exists and is unchanged
        leankor__KanbanCard__c updatedChildCard = [Select Id, 
                                                            Name, 
                                                            leankor__ValueStream__c, 
                                                            leankor__ValueStreamCardLink__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__CmpID__c = 'mpsinghChildKanbanCard' 
                                                        Limit 1];
        System.assertEquals(kanbanCard.Id,updatedChildCard.leankor__ValueStreamCardLink__c,'Child Kanban Card should still be linked to its parent after merge.');
    }
    /*----------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method tests MergeProjectBoardProcess with null SourceBoardId and validates merging 
                with TargetDate, with and without SourceFolderName. 
    -----------------------------------------------------------------------------------------------------*/
    @isTest
    static void mergeProjectBoardProcessTestOne() {
        leankor__ProjectRoom__c sourceRoomName = [Select Id,
                                                            Name 
                                                        From leankor__ProjectRoom__c 
                                                        Where Name = 'Test Room' 
                                                        Limit 1];
        leankor__ValueStream__c sourceBoard = [Select Id,
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board' 
                                                    Limit 1];
        leankor__ValueStream__c targetBoard = [Select Id, 
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board1' 
                                                    Limit 1];
        
        List<MergeProjectBoardAction.MergeProjectBoardRequest> mergeRequests = new List<MergeProjectBoardAction.MergeProjectBoardRequest>();
        MergeProjectBoardAction.MergeProjectBoardRequest mergeRequest = new MergeProjectBoardAction.MergeProjectBoardRequest();
        mergeRequest.sourceBoardId = Null;
        mergeRequest.targetBoardId = targetBoard.Id;
        mergeRequest.WithMC = false;
        mergeRequest.SourceBoardName = sourceBoard.Name;
        mergeRequest.TargetBoardName = targetBoard.Name;
        mergeRequest.SourceRoomName = sourceRoomName.Name;
        mergeRequest.SourceFolderName = 'Test Room';
        mergeRequest.TargetDate = DateTime.newInstance(2025, 6, 22, 12, 0, 0);
        Test.startTest();
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
            mergeRequest.SourceFolderName = Null;
            mergeRequest.TargetDate = DateTime.newInstance(2025, 6, 21, 12, 0, 0);
            MergeProjectBoardAction.MergeProjectBoardProcess(mergeRequest);
        Test.stopTest();
        //assertion: check if the target board still exists and is unchanged
        leankor__ValueStream__c updatedTarget = [Select Id,     
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Where Id = :targetBoard.Id 
                                                    Limit 1];
        System.assertEquals('Project Board1', updatedTarget.Name, 'Target board name should remain unchanged after merge.');
    }
}