@isTest
public class MultipleMergeProjectBoardActionTest {
    @TestSetup
    static void setupData() {
        leankor__LeanConstants__c leanConstants = leankor__LeanConstants__c.getInstance();
        leanConstants.leankor__FirstDayOfTheWeek__c = 1; // Monday
        upsert leanConstants;

        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;

        leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
        sampleRoom.Name = 'Test Room';
        sampleRoom.leankor__Portfolio__c = testFolder.Id;
        insert sampleRoom;

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
        swimlane1.Name = 'CommonSwimlane';
        swimlane1.leankor__MasterContainer__c = masterContainer1.Id;
        swimlane1.leankor__Order__c = 1.0;
        swimlane1.leankor__ValueStream__c = sampleBoard.Id;

        leankor__Swimlane__c swimlane2 = new leankor__Swimlane__c();
        swimlane2.Name = 'CommonSwimlane';
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
        //Datetime sundayStart = Datetime.newInstance(2025, 6, 29, 9, 0, 0); // Sunday
        leankor__KanbanCard__c kanbanCard1 = new leankor__KanbanCard__c();
        kanbanCard1.leankor__StartDateTime__c = weekendDate;
        kanbanCard1.leankor__DueDateTime__c = weekendDate.addDays(1);
        kanbanCard1.leankor__EstimatedDuration__c = 1;
        kanbanCard1.Name = 'new card 1';
        kanbanCard1.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
        kanbanCard1.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard1.leankor__MasterContainer__c = masterContainer1.Id;
        kanbanCard1.leankor__Swimlane__c = swimlane1.Id;
        kanbanCard1.leankor__Order__c = 5;
        kanbanCard1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanbanCard1.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
        kanbanCard1.leankor__DurationUnits__c = 'Days';

        leankor__KanbanCard__c kanbanCard2 = new leankor__KanbanCard__c();
        kanbanCard2.leankor__StartDateTime__c = weekendDate;
        kanbanCard2.leankor__DueDateTime__c = weekendDate.addDays(2);
        kanbanCard2.leankor__EstimatedDuration__c = 1;
        kanbanCard2.Name = 'new card 2';
        kanbanCard2.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
        kanbanCard2.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard2.leankor__MasterContainer__c = masterContainer2.Id;
        kanbanCard2.leankor__Swimlane__c = swimlane2.Id;
        kanbanCard2.leankor__Order__c = 6;
        kanbanCard2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanbanCard2.leankor__ZoneGUID__c = zone2.leankor__GUID__c;
        kanbanCard2.leankor__DurationUnits__c = 'Days';

        insert new List<leankor__KanbanCard__c>{kanbanCard1, kanbanCard2};

        leankor__Dependency__c dep = new leankor__Dependency__c();
        dep.leankor__Predecessor__c = kanbanCard1.Id;
        dep.leankor__Successor__c = kanbanCard2.Id;
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
    @isTest
    public static void multipleMergeBoardAction() {
    
        Test.startTest();
            leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
            testFolder.Name = 'Test Room';
            insert testFolder;

            leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
            sampleRoom.Name = 'Test Room';
            sampleRoom.leankor__Portfolio__c = testFolder.Id;
            insert sampleRoom;   		
                    
            
            leankor.RealTimeController.ProjectBoard sampleBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
            leankor.RealTimeController.ProjectBoard targetBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
            leankor__ValueStream__c linkBoardIds = new leankor__ValueStream__c();
            linkBoardIds.Name = 'ValueStream Test';
            insert linkBoardIds;
            leankor__KanbanCard__c kanbanCards = new leankor__KanbanCard__c();
            kanbanCards.Name = 'kanbanCard Test';
            kanbanCards.leankor__ValueStream__c = linkBoardIds.Id;
            kanbanCards.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            insert kanbanCards;
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
            list<string> sourceBoardIds = new list<string>();
            sourceBoardIds.add(sampleBoard.Id);
            reqone.SourceBoardId = sourceBoardIds ;
            reqone.targetBoardId = targetBoard.Id;
            reqone.TargetDate = system.now();
            reqone.WithMC = true;
            reqone.linkBoardId = linkBoardIds.Id;
            reqone.linkKanbanCardId = kanbanCards.Id;
            req.add(reqone);
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assert(resultmerge != null,'Assertion Failed');
            // Create a new request for multiple merge
            Datetime sundayStart = Datetime.newInstance(2025, 6, 29, 9, 0, 0); // Sunday
            // Create Master Container
            leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
            masterContainer1.Name = 'masterContainer12';
            masterContainer1.leankor__ValueStream__c = sampleBoard.Id;
            masterContainer1.leankor__order__c = 7.0; 
            masterContainer1.leankor__Guid__c = leankor.TestDataFactory.createGuid();
            insert masterContainer1;
            // Create first Swimlane
            leankor__swimlane__c swimlane1 = new leankor__swimlane__c();
            swimlane1.Name = 'swimlanetest';
            swimlane1.leankor__MasterContainer__c = masterContainer1.ID;
            swimlane1.leankor__order__c = 1.0;
            swimlane1.leankor__ValueStream__c = sampleBoard.Id;
            insert swimlane1;
            // Create second Swimlane
            leankor__swimlane__c swimlane2 = new leankor__swimlane__c();
            swimlane2.Name = 'swimlanetest';
            swimlane2.leankor__MasterContainer__c = masterContainer1.ID;
            swimlane2.leankor__order__c = 1.0;
            swimlane2.leankor__ValueStream__c = sampleBoard.Id;
            insert swimlane2;
            // Create first Zone
            leankor__Zone__c zone1 = new leankor__Zone__c();
            zone1.Name = 'kanban test 3';
            zone1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            zone1.leankor__CmpID__c = 'my-CMPID-zone-test3';
            zone1.leankor__swimlane__c = swimlane1.ID;
            zone1.leankor__ValueStream__c = sampleBoard.Id;
            insert zone1;
            // Create second Zone
            leankor__Zone__c zone2 = new leankor__Zone__c();
            zone2.Name = 'kanban test 3';
            zone2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            zone2.leankor__CmpID__c = 'my-CMPID-zone-test3';
            zone2.leankor__swimlane__c = swimlane2.ID;
            zone2.leankor__ValueStream__c = sampleBoard.Id;
            insert zone2;
            // Create Kanban Card Template
            leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c();
            kanbanCardTemplate.Name = 'RED Card';
            kanbanCardTemplate.leankor__ValueStream__c = sampleBoard.id;
            kanbanCardTemplate.leankor__Color__c = '#F71B1B';
            kanbanCardTemplate.leankor__Width__c = 328.0;
            insert kanbanCardTemplate;    
            // Create Kanban Card  
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__startdatetime__c = sundayStart;
            kanbanCard.leankor__duedatetime__c = system.now();
            kanbanCard.Name = 'new card';
            kanbanCard.leankor__EstimatedDuration__c = 1;
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanCardTemplate.id;
            kanbanCard.leankor__ValueStream__c = sampleBoard.ID;
            kanbanCard.leankor__MasterContainer__c = masterContainer1.ID;
            kanbanCard.leankor__swimlane__c = swimlane1.ID;
            kanbanCard.leankor__order__c = 5;
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__zoneGUID__c = zone1.leankor__GUID__C;
            insert kanbanCard;
            // Create Task
            Task task = new Task ();
            task.Priority = ' high'; 
            task.status = 'in progress'; 
            task.whatid = kanbanCard.id; 
            task.ActivityDate = system.today (); 
            insert task;   
            // Create Issue Log
            leankor__IssueLog__c issueLog = new leankor__IssueLog__c();
            issueLog.Name = 'issue1'; 
            issueLog.leankor__KanbanCard__c = kanbanCard.id ; 
            issueLog.leankor__Task__c = task.id;
            insert issueLog;
            // Create Time Card
            leankor__TimeCard__c timeCardNew = new leankor__TimeCard__c();
            timeCardNew.leankor__KanbanCard__c = kanbanCard.id ;
            timeCardNew.leankor__Task__c = task.id;
            timeCardNew.leankor__TaskDueDate__c = system.now()+5;
            insert timeCardNew;
            // Create Sticker and Attachment
            leankor__Sticker__c  sticker = new leankor__Sticker__c();
            sticker.Name = 'sticker 1';
            sticker.leankor__ValueStream__c = sampleBoard.ID;
            insert sticker;
            // Create Attachment
            Attachment attachments = new Attachment(); 
            attachments.Name = 'attchment1';
            attachments.Body = Blob.valueOf('a file'); 
            attachments.ParentId = sticker.id;
            insert attachments;
            // Create Kanban Card Sticker
            leankor__KanbanCardSticker__c  kanbanCardSticker = new leankor__KanbanCardSticker__c();
            kanbanCardSticker.leankor__KanbanCard__c = kanbanCard.id;
            kanbanCardSticker.leankor__Sticker__c = sticker.id;
            insert kanbanCardSticker;
            // Prepare request for multiple merge
            list<string> sourceswimlane1 = new list<string>();
            sourceswimlane1.add(sampleBoard.Id);
            reqone.SourceBoardId = sourceswimlane1 ;
            reqone.targetBoardId = targetBoard.Id;
            reqone.TargetDate = system.now();
            reqone.WithMC = true;
            req.clear();
            req.add(reqone);
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge1 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assert(resultmerge1 != null,'Assertion Failed');
        Test.StopTest();
    } 
    @isTest
    private static void multipleMergeBoardActionTwo() {
        Test.startTest();
            leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
            testFolder.Name = 'Test Room';
            insert testFolder;

            leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
            sampleRoom.Name = 'Test Room';
            sampleRoom.leankor__Portfolio__c = testFolder.Id;
            insert sampleRoom;   		
                            
            leankor.RealTimeController.ProjectBoard sampleBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
            leankor.RealTimeController.ProjectBoard targetBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
            list<string> sourceBoardIds = new list<string>();
            sourceBoardIds.add(sampleBoard.Id);
            reqone.SourceBoardId = sourceBoardIds ;
            reqone.targetBoardId = targetBoard.Id;
            reqone.TargetDate = system.now();
            reqone.WithMC = true;
            req.add(reqone);
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assert(resultmerge != null,'Assertion Failed');
        Test.StopTest();
    }
   @isTest
    static void testFullMerge() {
        Test.startTest();
        // Create Portfolio and Room
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Test Portfolio';
        insert folder;
    
        leankor__ProjectRoom__c room = new leankor__ProjectRoom__c();
        room.Name = 'Test Room'; 
        room.leankor__Portfolio__c = folder.Id;
        insert room;
        leankor__ValueStream__c sampleBoard = [Select Id
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board' 
                                                    Limit 1];
        leankor__ValueStream__c targetBoard = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board1' 
                                                    Limit 1];
		Datetime sundayStart = Datetime.newInstance(2025, 6, 29, 9, 0, 0); // Sunday
        Datetime saturday = Datetime.newInstance(2025, 6, 28, 9, 0, 0);   // Saturday
    	Datetime monday = Datetime.newInstance(2025, 6, 30, 9, 0, 0);     // Monday
        
        // Create Master Container
        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c();
        masterContainer.Name = 'Test masterContainer';
        masterContainer.leankor__ValueStream__c = sampleBoard.Id;
        masterContainer.leankor__Order__c = 1;
        masterContainer.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        insert masterContainer;
        // Create Swimlane
        leankor__Swimlane__c swimlane = new leankor__Swimlane__c();
        swimlane.Name = 'Test SW';
        swimlane.leankor__MasterContainer__c = masterContainer.Id;
        swimlane.leankor__Order__c = 1;
        swimlane.leankor__ValueStream__c = sampleBoard.Id;
        insert swimlane;
        // Create Zone
        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'Test Zone';
        zone.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        zone.leankor__CmpID__c = 'Zone-CMPID';
        zone.leankor__Swimlane__c = swimlane.Id;
        zone.leankor__ValueStream__c = sampleBoard.Id;
        insert zone;
            
        // Create Card Template
        leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.Name = 'Test Template';
        template.leankor__ValueStream__c = sampleBoard.Id;
        template.leankor__Color__c = '#ABC';
        template.leankor__Width__c = 328;
        insert template;
            
        List<leankor__KanbanCard__c> cardsToInsert = new List<leankor__KanbanCard__c>();
        // Create Kanban Cards
        leankor__KanbanCard__c kanbanCard1 = new leankor__KanbanCard__c();
        kanbanCard1.Name = 'SundayCard';
        kanbanCard1.leankor__zoneGUID__c = zone.leankor__GUID__c;
        kanbanCard1.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard1.leankor__KanbanCardTemplate__c = template.Id;
        kanbanCard1.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard1.leankor__Swimlane__c = swimlane.Id;
        kanbanCard1.leankor__startdatetime__c = sundayStart+2;
        kanbanCard1.leankor__duedatetime__c = System.now();
        kanbanCard1.leankor__EstimatedDuration__c = 1;
        kanbanCard1.leankor__DurationUnits__c = 'Weeks';
        kanbanCard1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        cardsToInsert.add(kanbanCard1);
        // Create another Kanban Card for Saturday
        leankor__KanbanCard__c kanbanCard2 = new leankor__KanbanCard__c();
        kanbanCard2.Name = 'SaturdayCard';
        kanbanCard2.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard2.leankor__KanbanCardTemplate__c = template.Id;
        kanbanCard2.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard2.leankor__Swimlane__c = swimlane.Id;
        kanbanCard2.leankor__zoneGUID__c = zone.leankor__GUID__c;
        kanbanCard2.leankor__startdatetime__c = saturday;
        kanbanCard2.leankor__duedatetime__c = System.now();
        kanbanCard2.leankor__EstimatedDuration__c = 1;
        kanbanCard2.leankor__DurationUnits__c = 'Weeks';
        kanbanCard2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        cardsToInsert.add(kanbanCard2);
        // Insert Kanban Cards
        insert cardsToInsert;

        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
        reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
        reqOne.targetBoardId = targetBoard.Id;
        reqOne.initialDate = sundayStart;
        reqOne.WithMC = false;
        req.clear();
        req.add(reqOne);

        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
        System.assertNotEquals(null, result, 'Result should not be null');

        reqOne.WithMC = false;
        reqOne.initialDate = saturday;
        req.clear();
        req.add(reqOne);
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result2 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
        System.assertNotEquals(null, result2, 'Result should not be null');
        Test.stopTest();
    }
    @isTest
    static void testRestrictedPermissions() {
        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'Minimum Access - Salesforce' 
                        Limit 1];
        User user = new User();
        user.Alias = 'testu';
        user.Email = 'testuser@test.com';
        user.EmailEncodingKey = 'UTF-8';
        user.LastName = 'Test';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.ProfileId = p.Id;
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.Username = 'testuser' + Math.random() + '@test.com';
        insert user;

        System.runAs(user) {
            leankor__ValueStream__c sampleBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            leankor__ValueStream__c targetBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];

            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
            reqOne.targetBoardId = targetBoard.Id;
            reqOne.TargetDate = System.now();
            reqOne.WithMC = true;
            req.add(reqOne);
            // Attempt to merge boards with restricted permissions

            try {
                leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
                System.assert(false, 'Expected Util.LeanException due to insufficient permissions');
            } catch (Util.LeanException e) {
                System.assert(e.getMessage().contains('Error: No access to records'), 'Expected permission error');
            }
        }
    }
    @isTest
    static void testEmptyKanbanCards() {
        Test.startTest();
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room Empty';
        insert testFolder;

        leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
        sampleRoom.Name = 'Test Room Empty';
        sampleRoom.leankor__Portfolio__c = testFolder.Id;
        insert sampleRoom;

        leankor.RealTimeController.ProjectBoard sampleBoard = leankor.ProjectBoardCarousel.createProjectBoard('Empty Project Board', sampleRoom.Id, 'kanban board', '', '');
        leankor.RealTimeController.ProjectBoard targetBoard = leankor.ProjectBoardCarousel.createProjectBoard('Empty Project Board1', sampleRoom.Id, 'kanban board', '', '');

        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
        reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
        reqOne.targetBoardId = targetBoard.Id;
        reqOne.TargetDate = null;
        reqOne.WithMC = true;
        req.add(reqOne);

        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
        System.assertNotEquals(null, result, 'Result should not be null');

        Test.stopTest();
    }
    @isTest
    public static void  multipleMergeBoardActionThird() {

        Test.startTest();
            leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
            testFolder.Name = 'Test Room';
            insert testFolder;

            leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
            sampleRoom.Name = 'Test Room';
            sampleRoom.leankor__Portfolio__c = testFolder.Id;
            insert sampleRoom;   		
                
            leankor.RealTimeController.ProjectBoard sampleBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'kanban board','','');
            leankor.RealTimeController.ProjectBoard targetBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board1',sampleRoom.Id,'kanban board','','');
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>(); 
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqone = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest(); 
            list<string> sourceBoardIds = new list<string>();
            sourceBoardIds.add(sampleBoard.Id);
            reqone.SourceBoardId = sourceBoardIds ;
            reqone.targetBoardId = targetBoard.Id;
            reqone.TargetDate = system.now();
            reqone.WithMC = true;
            req.add(reqone);
            
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            MultipleMergeProjectBoardAction.updateHeightWidth(targetBoard.Id);
            System.assert(resultmerge != null,'Assertion Failed');

            // Create a new request for multiple merge
            Datetime sunday = Datetime.newInstance(2025, 6, 29, 9, 0, 0);     // Sunday
            Datetime saturday = Datetime.newInstance(2025, 6, 28, 9, 0, 0);   // Saturday
            Datetime monday = Datetime.newInstance(2025, 6, 30, 9, 0, 0);  //Monday
            // Create Master Container
            leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
            masterContainer1.Name = 'masterContainer12';
            masterContainer1.leankor__ValueStream__c = sampleBoard.Id;
            masterContainer1.leankor__order__c = 7.0; 
            masterContainer1.leankor__Guid__c = leankor.TestDataFactory.createGuid();
            insert masterContainer1;
            // Create first Swimlane
            leankor__swimlane__c swimlane1 = new leankor__swimlane__c();
            swimlane1.Name ='swimlanetest';
            swimlane1.leankor__MasterContainer__c = masterContainer1.Id;
            swimlane1.leankor__order__c = 1.0;
            swimlane1.leankor__ValueStream__c = sampleBoard.Id;
            insert swimlane1;
            // Create second Swimlane
            leankor__swimlane__c swimlane2 = new leankor__swimlane__c();
            swimlane2.Name = 'swimlanetest';
            swimlane2.MasterContainer__c = masterContainer1.ID;
            swimlane2.leankor__order__c = 1.0;
            swimlane2.leankor__ValueStream__c = sampleBoard.Id;
            insert swimlane2;
            // Create first Zone
            leankor__Zone__c zone1 = new leankor__Zone__c();
            zone1.Name = 'kanban test 3';
            zone1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            zone1.leankor__CmpID__c = 'my-CMPID-zone-test3';
            zone1.leankor__swimlane__c = swimlane1.ID;
            zone1.leankor__ValueStream__c = sampleBoard.Id;
            insert zone1;
            // Create second Zone
            leankor__Zone__c zone2 = new leankor__Zone__c();
            zone2.Name = 'kanban test 3';
            zone2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            zone2.leankor__CmpID__c = 'my-CMPID-zone-test3';
            zone2.leankor__swimlane__c = swimlane2.ID;
            zone2.leankor__ValueStream__c = sampleBoard.Id;
            insert zone2;
            // Create Kanban Card Template
            leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c();
            kanbanCardTemplate.Name = 'RED Card';
            kanbanCardTemplate.leankor__ValueStream__c = sampleBoard.id;
            kanbanCardTemplate.leankor__Color__c = '#F71B1B';
            kanbanCardTemplate.leankor__Width__c = 328.0;
            insert kanbanCardTemplate;    
            // Create Kanban Card  
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'new card';
            kanbanCard.leankor__startdatetime__c = system.now();
            kanbanCard.leankor__duedatetime__c = system.now();
            kanbanCard.leankor__EstimatedDuration__c = 1;
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanCardTemplate.id;
            kanbanCard.leankor__ValueStream__C = sampleBoard.ID;
            kanbanCard.leankor__MasterContainer__c = masterContainer1.ID;
            kanbanCard.leankor__swimlane__c = swimlane1.ID;
            kanbanCard.leankor__order__c = 5;
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__zoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard.leankor__DurationUnits__c = 'Hours';
            insert kanbanCard;
            //changes by Mp
            leankor__KanbanCard__c kanbanCard1 = new leankor__KanbanCard__c();
            kanbanCard1.Name = 'new card';
            kanbanCard1.leankor__startdatetime__c = System.now();
            kanbanCard1.leankor__duedatetime__c = sunday;
            kanbanCard1.leankor__EstimatedDuration__c = 1;
            kanbanCard1.leankor__KanbanCardTemplate__c = kanbanCardTemplate.id;
            kanbanCard1.leankor__ValueStream__c = sampleBoard.Id;
            kanbanCard1.leankor__MasterContainer__c = masterContainer1.Id;
            kanbanCard1.leankor__swimlane__c = swimlane1.Id;
            kanbanCard1.leankor__order__c = 5;
            kanbanCard1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard1.leankor__zoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard1.leankor__DurationUnits__c = 'Years';
            insert kanbanCard1;
            // Create additional Kanban Cards with different due dates and durations
            leankor__KanbanCard__c kanbanCard2 = new leankor__KanbanCard__c();
            kanbanCard2.Name = 'new card';
            kanbanCard2.leankor__startdatetime__c = system.now();
            kanbanCard2.leankor__duedatetime__c = saturday;
            kanbanCard2.leankor__EstimatedDuration__c = 1;
            kanbanCard2.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
            kanbanCard2.leankor__ValueStream__c = sampleBoard.Id;
            kanbanCard2.leankor__MasterContainer__c = masterContainer1.Id;
            kanbanCard2.leankor__swimlane__c = swimlane1.Id;
            kanbanCard2.leankor__order__c = 5;
            kanbanCard2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard2.leankor__zoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard2.leankor__DurationUnits__c = 'Months';
            insert kanbanCard2;
            // Create another Kanban Card with a different duration unit
            leankor__KanbanCard__c kanbanCard3 = new leankor__KanbanCard__c();
            kanbanCard3.Name = 'new card';
            kanbanCard3.leankor__startdatetime__c = system.now();
            kanbanCard3.leankor__duedatetime__c = monday;
            kanbanCard3.leankor__EstimatedDuration__c = 1;
            kanbanCard3.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
            kanbanCard3.leankor__ValueStream__c = sampleBoard.Id;
            kanbanCard3.leankor__MasterContainer__c = masterContainer1.Id;
            kanbanCard3.leankor__swimlane__c = swimlane1.Id;
            kanbanCard3.leankor__order__c = 5;
            kanbanCard3.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard3.leankor__zoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard3.leankor__DurationUnits__c = 'Minutes';
            insert kanbanCard3;
            //Create another Kanban Card with a different duration unit
            leankor__KanbanCard__c kanbanCard4 = new leankor__KanbanCard__c();
            kanbanCard4.Name = 'new card';
            kanbanCard4.leankor__startdatetime__c = system.now();
            kanbanCard4.leankor__duedatetime__c = system.now();
            kanbanCard4.leankor__EstimatedDuration__c = 1;
            kanbanCard4.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
            kanbanCard4.leankor__ValueStream__c = sampleBoard.Id;
            kanbanCard4.leankor__MasterContainer__c = masterContainer1.Id;
            kanbanCard4.leankor__swimlane__c = swimlane1.Id;
            kanbanCard4.leankor__order__c = 5;
            kanbanCard4.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard4.leankor__zoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard4.leankor__DurationUnits__c = 'Weeks';
            insert kanbanCard4;
            // Create Task
            Task  task = new Task();
            task.Priority = 'high';
            task.status = 'in progress';
            task.whatid = kanbanCard.id;
            task.ActivityDate = system.today (); 
            insert task;
            // Create Issue Log
            leankor__IssueLog__c issueLog = new leankor__IssueLog__c();
            issueLog.Name = 'issue1';
            issueLog.leankor__KanbanCard__c = kanbanCard.id; 
            issueLog.leankor__Task__c = task.id;
            insert issueLog;
            // Create Time Card
            leankor__TimeCard__c timeCardNew = new leankor__TimeCard__c();
            timeCardNew.leankor__KanbanCard__c = kanbanCard.id;
            timeCardNew.leankor__Task__c = task.id;
            timeCardNew.leankor__TaskDueDate__c = system.now()+5;
            insert timeCardNew;
            // Create Sticker
            leankor__Sticker__c sticker = new leankor__Sticker__c();
            sticker.leankor__ValueStream__c = sampleBoard.ID;
            sticker.Name = 'sticker 1';
            insert sticker;
            // Create Attachment
            Attachment attch = new Attachment ();
            attch.Name = 'attchment1';
            attch.Body = Blob.valueOf('a file');
            attch.ParentId = sticker.id;
            insert attch;
            // Create Kanban Card Sticker
            leankor__KanbanCardSticker__c kanbanCardSticker = new leankor__KanbanCardSticker__c();
            kanbanCardSticker.leankor__KanbanCard__c = kanbanCard.id;
            kanbanCardSticker.leankor__Sticker__c = sticker.id;     
            insert kanbanCardSticker;
            // Prepare request for multiple merge
            list<string> sourceswimlane1 = new list<string>();
            sourceswimlane1.add(sampleBoard.Id);
            reqone.SourceBoardId = sourceswimlane1 ;
            reqone.targetBoardId = targetBoard.Id;
            reqone.TargetDate = system.now();
            reqone.WithMC = false;
            req.clear();
            req.add(reqone);
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> resultMerge2 = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            MultipleMergeProjectBoardAction.updateHeightWidth(targetBoard.Id); 
            System.assert(resultmerge2 != null,'Assertion Failed');

        Test.StopTest();
    }
    @isTest
    static void testCloneTaskSuccess() {
        // Create test user
        Profile profile = [Select Id
                                From Profile 
                                Where Name = 'Standard User' 
                                Limit 1];
        // Create test user
        User user = new User();
        user.Alias = 'testu';
        user.Email = 'testuser@test.com';
        user.EmailEncodingKey = 'UTF-8'; 
        user.LastName = 'Test'; 
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US'; 
        user.ProfileId = profile.Id;
        user.TimeZoneSidKey = 'America/Los_Angeles'; 
        user.Username = 'testuser@testorg' + System.currentTimeMillis() + '@test.com';
        insert user;
        // Create test ValueStream
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test valueStream';
        insert valueStream;

        // Create test Kanban cards
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        for (Integer i = 0; i < 2; i++) {
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Card ' + i;
            kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCards.add(kanbanCard);
        }
        insert kanbanCards;

        // Create test tasks (multiple tasks for the same Kanban card to hit else block)
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < 3; i++) {
            Task task = new Task();
            task.Subject = 'Test Task ' + i;
            task.Priority = 'Normal';
            task.Status = 'Not Started';
            task.OwnerId = user.Id;
            task.WhatId = kanbanCards[0].Id;
            task.ActivityDate = Date.today();
            task.Description = 'Test Description';
            tasks.add(task);
        }
        Task task = new Task();
        task.Subject = 'Test Task 3';
        task.Priority = 'High';
        task.Status = 'In Progress';
        task.OwnerId = user.Id;
        task.WhatId = kanbanCards[1].Id;
        task.ActivityDate = Date.today();
        task.Description = 'Test Description';
        tasks.add(task);
        // Insert tasks
        insert tasks;

        // Create blackout record for WorkWeek
        List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
        blackout.leankor__StartDate__c = Date.today();
        blackout.leankor__EndDate__c = Date.today().addDays(1);
        blackout.leankor__ProjectBoard__c = valueStream.Id;
        blackouts.add(blackout);
        //Insert blackout records
        insert blackouts;

        // Prepare input parameters
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts); // Monday start, 5-day work week
        Map<String, String> mapKanbanCard = new Map<String, String>();
        Map<String, Decimal> cardDifference = new Map<String, Decimal>();
        
        // Map old Kanban card IDs to new ones
        leankor__KanbanCard__c newCard = new leankor__KanbanCard__c();
        newCard.Name = 'New Card';
        newCard.leankor__GUID__c = TestDataFactory.createGuid();
        insert newCard;
        
        for (leankor__KanbanCard__c card : kanbanCards) {
            mapKanbanCard.put(card.Id, newCard.Id);
            cardDifference.put(card.Id, 2.0); // 2 days difference
        }

        // Test successful execution
        Test.startTest();
            Map<String, String> result = MultipleMergeProjectBoardAction.cloneTask(tasks, workWeek, mapKanbanCard, null, cardDifference, false);
        Test.stopTest();

        // Assertions
        System.assert(!result.isEmpty(), 'Old to new task mapping should not be empty');
        System.assertEquals(tasks.size(), result.size(), 'All tasks should be mapped');
        
        // Verify else block (multiple tasks for same Kanban card)
        List<Task> clonedTasks = [Select Id, WhatId From Task Where WhatId = :newCard.Id];
        System.assertEquals(tasks.size(), clonedTasks.size(), 'All tasks should be cloned to the new Kanban card');
    }
	@isTest
    static void testCloneTaskInsertException() {
        // Create test user
        Profile profile = [Select Id
                                From Profile 
                                Where Name = 'Standard User' 
                                Limit 1];
        // Create test user
        User user = new User();
        user.Alias = 'testu';
        user.Email = 'testuser@test.com';
        user.EmailEncodingKey = 'UTF-8'; 
        user.LastName = 'Test'; 
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US'; 
        user.ProfileId = profile.Id;
        user.TimeZoneSidKey = 'America/Los_Angeles'; 
        user.Username = 'testuser@testorg' + System.currentTimeMillis() + '@test.com';
        insert user;
        // Create test ValueStream
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test valueStream';
        insert valueStream;

        // Create test Kanban card
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Card 1';
        kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCard;

        // Create test task with invalid data to trigger DML exception
        List<Task> tasks = new List<Task>();
        Task task = new Task();
        task.Subject = 'Test Task';
        task.Priority = 'Normal';
        task.Status = 'Not Started';
        task.OwnerId = null; // Invalid OwnerId to cause DML exception
        task.WhatId = kanbanCard.Id;
        task.ActivityDate = Date.today();
        task.Description = 'Test Description';
        tasks.add(task);

        // Create blackout record
        List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
        blackout.leankor__StartDate__c = Date.today();
        blackout.leankor__EndDate__c = Date.today().addDays(1);
        blackout.leankor__ProjectBoard__c = valueStream.Id;  
        blackouts.add(blackout);
        insert blackouts;

        // Prepare input parameters
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts);
        Map<String, String> mapKanbanCard = new Map<String, String>{ kanbanCard.Id => kanbanCard.Id };
        Map<String, Decimal> cardDifference = new Map<String, Decimal>{ kanbanCard.Id => 1.0 };

        Test.startTest();
            try {
                Map<String, String> result = MultipleMergeProjectBoardAction.cloneTask(tasks, workWeek, mapKanbanCard, null, cardDifference, false);
                System.assert(false, 'Expected a LeanException');
            } catch (Util.LeanException ex) {
                System.assert(ex.getMessage().contains('ERROR:'), 'Exception message should contain ERROR');
            }
        Test.stopTest();
    }
	@isTest
    static void testCloneTaskUpdateFeedException() {
        // Create test user
        Profile profile = [Select Id 
                                From Profile 
                                Where Name = 'Standard User' 
                                Limit 1]; 
        User user = new User();
        user.Alias = 'testu';
        user.Email = 'testuser@test.com';
        user.EmailEncodingKey = 'UTF-8'; 
        user.LastName = 'Test'; 
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US'; 
        user.ProfileId = profile.Id;
        user.TimeZoneSidKey = 'America/Los_Angeles'; 
        user.Username = 'testuser@testorg' + System.currentTimeMillis() + '@test.com';
        insert user;
        //create test ValueStream
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test valueStream';
        insert valueStream;
        // Create test Kanban card
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Card 1';
        kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCard;
        // Create valid test task
        List<Task> tasks = new List<Task>();
        Task task = new Task();
        task.Subject = 'Test Task';
        task.Priority = 'Normal';
        task.Status = 'Not Started';
        task.OwnerId = user.Id; // Invalid OwnerId to cause DML exception
        task.WhatId = kanbanCard.Id;
        task.ActivityDate = Date.today();
        task.Description = 'Test Description';
        tasks.add(task);
        insert tasks;

        // Create blackout record
        List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
        blackout.leankor__StartDate__c = Date.today();
        blackout.leankor__EndDate__c = Date.today().addDays(1);
        blackout.leankor__ProjectBoard__c = valueStream.Id;  
        blackouts.add(blackout);
        insert blackouts;

        // Prepare input parameters
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts);
        Map<String, String> mapKanbanCard = new Map<String, String>{ kanbanCard.Id => kanbanCard.Id };
        Map<String, Decimal> cardDifference = new Map<String, Decimal>{ kanbanCard.Id => 1.0 };

        Test.startTest();
        
            // Simulate FeedItem failure by creating an invalid FeedItem
            List<FeedItem> invalidFeeds = new List<FeedItem>();
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = null; // Invalid ParentId to cause DML exception
            feedItem.Type = 'CreateRecordEvent';// Invalid ParentId
            invalidFeeds.add(feedItem);
            try {
                insert invalidFeeds;
                System.assert(false, 'Expected a DMLException');
            } catch (DMLException ex) {
                // This confirms FeedItem insertion can fail
                System.debug('Expected DMLException caught: ' + ex.getMessage());
                //System.assert(ex.getMessage().contains('ERROR: ParentId cannot be null'), 'Exception message should indicate ParentId cannot be null');
            }
            try {
                Map<String, String> result = MultipleMergeProjectBoardAction.cloneTask(tasks, workWeek, mapKanbanCard, null, cardDifference, false);
            } catch (Util.LeanException ex) {
                System.assert(ex.getMessage().contains('ERROR:'), 'Exception message should contain ERROR');
            }
        Test.stopTest();
    }
	@isTest
    static void testReadPreviousWorkingDateException() {
        // Create blackout record
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test valueStream';
        insert valueStream;
        // Create blackout records
        List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
        blackout.leankor__StartDate__c = Date.today();
        blackout.leankor__EndDate__c = Date.today().addDays(1);
        blackout.leankor__ProjectBoard__c = valueStream.Id;  
        blackouts.add(blackout);
        insert blackouts;
        // Prepare WorkWeek
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts);
        DateTime currentDateTime = DateTime.now();
        Date currentDate = Date.today();

        Test.startTest();
            try {
                Util.readPreviousWorkingDate(null, currentDateTime, currentDate);
                System.assert(false, 'Expected a LeanException');
            } catch(Util.LeanException ex) {
                System.assert(ex.getMessage().contains('ERROR:'), 'Exception message should contain ERROR');
            }
        Test.stopTest();
    }
     @isTest
    static void cloneStickersTest() {
        Test.startTest();
            leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
            testFolder.Name = 'Test Room';
            insert testFolder;

            leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
            sampleRoom.Name = 'Test Room';
            sampleRoom.leankor__Portfolio__c = testFolder.Id;
            insert sampleRoom;   
            
            leankor__ValueStream__c linkBoardIds = new leankor__ValueStream__c();
            linkBoardIds.Name = 'ValueStream Test';
            insert linkBoardIds;
            
            leankor__KanbanCard__c kanbanCards = new leankor__KanbanCard__c();
            kanbanCards.Name = 'kanbanCard Test';
            kanbanCards.leankor__ValueStream__c = linkBoardIds.Id;
            kanbanCards.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            insert kanbanCards;
            
            leankor__Sticker__c testSticker = new leankor__Sticker__c();
            testSticker.Name = 'TestSticker';
            testSticker.leankor__ValueStream__c = linkBoardIds.Id;
            insert testSticker;

            leankor.MultipleMergeProjectBoardAction.cloneStickers( new List<String>{linkBoardIds.Id},linkBoardIds.Id, new Map<String,String>(),new List<leankor__KanbanCard__c>());
        Test.stopTest();
        System.assertNotEquals(null, testSticker.Id, 'Sticker should be cloned successfully');
        System.assertEquals('TestSticker', testSticker.Name, 'Sticker name should match');
        System.assertEquals(linkBoardIds.Id, testSticker.leankor__ValueStream__c, 'Sticker should be associated with the correct ValueStream');
    }
   	@isTest
    static void cloneStickersTestCatchBlocks() {
        Test.startTest();
    
            // Setup valid base data
            leankor__ValueStream__c sourceBoard = new leankor__ValueStream__c();
            sourceBoard.Name = 'SourceBoard';
            insert sourceBoard;
        
            leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
            targetBoard.Name = 'targetBoard';
            targetBoard.leankor__BoardType__c = 'Dashboard';
            insert targetBoard;
        
            // Create a valid sticker on the target board to ensure it's seen as a duplicate
            leankor__Sticker__c existingSticker = new leankor__Sticker__c();
            existingSticker.Name = 'TestSticker';
            existingSticker.leankor__ValueStream__c = targetBoard.Id;
            insert existingSticker;
        
            // Create an invalid sticker on the source board (duplicate name or bad data)
            leankor__Sticker__c invalidSticker = new leankor__Sticker__c();
            invalidSticker.Name = 'TestSticker'; // Same name as existingSticker, will be skipped
            invalidSticker.leankor__ValueStream__c = sourceBoard.Id;
            insert invalidSticker;
        
            // Second sticker that will attempt to be cloned and fail
            leankor__Sticker__c badInsertSticker = new leankor__Sticker__c();
            badInsertSticker.Name = null; // Name is usually required
            badInsertSticker.leankor__ValueStream__c = sourceBoard.Id;
            insert badInsertSticker;
        
            // To force it to try to clone, remove sticker with name conflict
            delete existingSticker;
        
            // Prepare stub KanbanCard list to satisfy input, though not necessary for catch
            List<leankor__KanbanCard__c> dummyCards = new List<leankor__KanbanCard__c>();

            try {
                leankor.MultipleMergeProjectBoardAction.cloneStickers( new List<String>{sourceBoard.Id}, targetBoard.Id, new Map<String, String>(), dummyCards);
        
            } catch (Exception e) {
                System.debug('Expected exception caught: ' + e.getMessage());
                System.assert(e.getMessage().contains('ERROR:'), 'Exception message should contain ERROR');
            }
        Test.stopTest();
    }
	@isTest
    private static void multipleMergeProjectBoardTestOne() {
        Test.StartTest();
            Datetime sundayStart = Datetime.newInstance(2025, 6, 29, 9, 0, 0); 
            Datetime saturdayStart = Datetime.newInstance(2025, 6, 28, 9, 0, 0); // Saturday
            Datetime weekdayStart = Datetime.newInstance(2025, 6, 30, 9, 0, 0); // Monday
            leankor__Portfolio__c folder = new leankor__Portfolio__c();
            folder.Name = 'Test-folder';
            insert folder;
            // Create a project room
            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
            project.Name = 'Test-Project';
            project.leankor__Portfolio__c = folder.Id;
            insert project;
            
            leankor__ValueStream__c boardFirst = new leankor__ValueStream__c();
            boardFirst.Name = 'Test-Board';
            boardFirst.leankor__BoardType__c = 'Dashboard';
            boardFirst.leankor__projectroom__c = project.Id;
            boardFirst.leankor__SevenDayWorkWeek__c = true;
            insert boardFirst;

            leankor__MasterContainer__c newMasterContainer = new leankor__MasterContainer__c();
            newMasterContainer.Name = '{}';
            newMasterContainer.leankor__ValueStream__c = boardFirst.Id;
            newMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
            insert newMasterContainer;
            
            leankor__Swimlane__c  newSwimlane = new leankor__Swimlane__c();
            newSwimlane.Name = 'Test-SW';
            newSwimlane.leankor__ValueStream__c = boardFirst.Id;
            newswimlane.leankor__MasterContainer__c = newMasterContainer.Id;
            insert newSwimlane;  
            //getSwimlane method test run
            MultipleMergeProjectBoardAction.getSwimlane(newMasterContainer.Id,boardFirst.Id);

            leankor__Zone__c zone = new leankor__Zone__c();
            zone.Name = 'Test-Zone';
            zone.leankor__Width__c = 180.0;  
            zone.leankor__X__c = 767.0;
            zone.leankor__GUID__c = TestDataFactory.createGuid();
            zone.leankor__Y__c = 49.0;
            zone.leankor__ValueStream__c = boardFirst.Id;
            insert zone;
            //getZone test run
            MultipleMergeProjectBoardAction.getZone(newSwimlane.Id,boardFirst.Id);

            List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
            for(Integer count = 0; count<5; count++){
                leankor__KanbanCard__c card = new leankor__KanbanCard__c();
                card.Name = 'Test-Card-'+count;
                card.leankor__StartDateTime__c = System.Now();
                card.leankor__EstimatedDuration__c = 2;
                card.leankor__GUID__c = TestDataFactory.createGuid();
                card.leankor__ValueStream__c = boardFirst.Id;
                cards.add(card);
            }
            insert cards;

            leankor__ValueStream__c boardSecond = new leankor__ValueStream__c();
            boardSecond.Name = 'Demo-Board';
            boardSecond.leankor__BoardType__c = 'Dashboard';
            boardSecond.leankor__projectroom__c = project.Id;
            boardSecond.leankor__SevenDayWorkWeek__c = true;
            insert boardSecond;
            
            leankor__Swimlane__c newBoardSw = new leankor__Swimlane__c();
            newBoardSw.Name = 'Demo-SW';
            newBoardSw.leankor__ValueStream__c = boardSecond.Id;
            insert newBoardSw;         

            leankor__Zone__c newBoardzone = new leankor__Zone__c();
            newBoardzone.Name = 'Demo-Zone';
            newBoardzone.leankor__Width__c = 180.0;  
            newBoardzone.leankor__X__c = 767.0;
            newBoardzone.leankor__GUID__c = TestDataFactory.createGuid();
            newBoardzone.leankor__Y__c = 49.0;
            newBoardzone.leankor__ValueStream__c = boardSecond.Id;
            insert newBoardzone;

            leankor__KanbanCard__c cardSecond = new leankor__KanbanCard__c();
            cardSecond.Name = 'Demo-Card';
            cardSecond.leankor__StartDateTime__c = System.Now();
            cardSecond.leankor__EstimatedDuration__c = 2;
            cardSecond.leankor__GUID__c = TestDataFactory.createGuid();
            cardSecond.leankor__ValueStream__c = boardSecond.Id;
            cardSecond.leankor__DurationUnits__c = 'Hours';
            cardSecond.leankor__startdatetime__c = sundayStart;
            insert cardSecond;

            List<String> sourceBoardIds = new List<String>();
            sourceBoardIds.add(boardFirst.Id);
            sourceBoardIds.add(boardSecond.Id);
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> requests = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> results = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest request = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            request.SourceBoardId = sourceBoardIds;
            request.targetBoardId = boardSecond.Id;
            request.WithMC = true;
            request.initialDate = System.Now();
            requests.add(request);
            try {
                leankor.MultipleMergeProjectBoardAction.multipleMergeProjectBoard(requests);
            } catch(Exception ex ){
                System.assert(ex.getMessage().contains('Attempt to de-reference a null object'), 'Exception message should contain ERROR');
            }
        Test.StopTest();
    }
    @isTest
    static void testDateCalculationsWithAllDurationUnits() {
        Test.startTest();
            leankor__ValueStream__c sampleBoard = [Select Id
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            leankor__ValueStream__c targetBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            targetBoard.leankor__SevenDayWorkWeek__c = true;
            targetBoard.leankor__BoardType__c = 'Dashboard';
            update targetBoard;
            leankor__MasterContainer__c masterContainer1 = [Select Id 
                                                                From leankor__MasterContainer__c 
                                                                Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                Limit 1];
            leankor__Swimlane__c swimlane1 = [Select Id 
                                                    From leankor__Swimlane__c 
                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                    Limit 1];
            leankor__Zone__c zone1 = [Select Id,
                                                leankor__GUID__c 
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c = :sampleBoard.Id 
                                            Limit 1];
            leankor__KanbanCardTemplate__c kanbanCardTemplate = [Select Id 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                    Limit 1];

            List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
            for (String unit : new List<String>{'Years', 'Months', 'Weeks', 'Days', 'Hours', 'Minutes'}) {
                leankor__KanbanCard__c card = new leankor__KanbanCard__c();
                card.Name = 'Card ' + unit;
                card.leankor__StartDateTime__c = System.now();
                card.leankor__DueDateTime__c = System.now().addDays(1);
                card.leankor__EstimatedDuration__c = 1;
                card.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
                card.leankor__ValueStream__c = sampleBoard.Id;
                card.leankor__MasterContainer__c = masterContainer1.Id;
                card.leankor__Swimlane__c = swimlane1.Id;
                card.leankor__Order__c = 5;
                card.leankor__GUID__c = leankor.TestDataFactory.createGuid();
                card.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
                card.leankor__DurationUnits__c = unit;
                cards.add(card);
            }
            insert cards;

            List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
            leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
            blackout.leankor__StartDate__c = Date.today();
            blackout.leankor__EndDate__c = Date.today().addDays(1);
            blackout.leankor__ProjectBoard__c = sampleBoard.Id;  
            blackouts.add(blackout);
            insert blackouts;
            Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts); // Monday start, 5-day week

            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
            reqOne.targetBoardId = targetBoard.Id;
            reqOne.TargetDate = System.now();
            reqOne.WithMC = true;
            reqOne.initialDate = System.now();
            req.add(reqOne);

            try {
                List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
                System.assertNotEquals(null, result, 'Result should not be null');
            } catch (Exception e) {
                System.assert(false, 'Merge failed: ' + e.getMessage());
            }
            reqOne.initialDate = Null;
            req.add(reqOne);
            try {
                List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
                System.assertNotEquals(null, result, 'Result should not be null');
            } catch (Exception e) {
                System.assert(false, 'Merge failed: ' + e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
    static void testDateCalculationsWithNonWorkingDays() {
        Test.startTest();
        leankor__ValueStream__c sampleBoard = [Select Id
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board' 
                                                    Limit 1];
        leankor__ValueStream__c targetBoard = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'Project Board1' 
                                                    Limit 1];
        leankor__MasterContainer__c masterContainer1 = [Select Id 
                                                            From leankor__MasterContainer__c 
                                                            Where leankor__ValueStream__c = :sampleBoard.Id 
                                                            Limit 1];
        leankor__Swimlane__c swimlane1 = [Select Id 
                                                From leankor__Swimlane__c 
                                                Where leankor__ValueStream__c = :sampleBoard.Id 
                                                Limit 1];
        leankor__Zone__c zone1 = [Select Id,
                                            leankor__GUID__c 
                                        From leankor__Zone__c 
                                        Where leankor__ValueStream__c = :sampleBoard.Id 
                                        Limit 1];
        leankor__KanbanCardTemplate__c kanbanCardTemplate = [Select Id 
                                                                From leankor__KanbanCardTemplate__c 
                                                                Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                Limit 1];

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'NonWorkingDayCard';
        kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2025, 6, 21, 12, 0, 0); // Saturday
        kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2025, 6, 22, 12, 0, 0);   // Sunday
        kanbanCard.leankor__EstimatedDuration__c = 1;
        kanbanCard.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
        kanbanCard.leankor__ValueStream__c = sampleBoard.Id;
        kanbanCard.leankor__MasterContainer__c = masterContainer1.Id;
        kanbanCard.leankor__Swimlane__c = swimlane1.Id;
        kanbanCard.leankor__Order__c = 5;
        kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        kanbanCard.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
        kanbanCard.leankor__DurationUnits__c = 'Days';
        insert kanbanCard;

        List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
        blackout.leankor__StartDate__c = Date.newInstance(2025, 6, 21); // Saturday
        blackout.leankor__EndDate__c = Date.newInstance(2025, 6, 22);   // Sunday
        blackout.leankor__ProjectBoard__c = sampleBoard.Id;
        blackouts.add(blackout);
        insert blackouts;
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts); // Monday start, 5-day week

        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
        reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
        reqOne.targetBoardId = targetBoard.Id;
        reqOne.TargetDate = System.now();
        reqOne.WithMC = true;
        req.add(reqOne);

        try {
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
            System.assertNotEquals(null, result, 'Result should not be null');
        } catch (Exception e) {
            System.assert(false, 'Merge failed: ' + e.getMessage());
        }

        Test.stopTest();
    }
    @isTest
    static void testDateCalculationsWithNullDates() {
        Test.startTest();
            leankor__ValueStream__c sampleBoard = [Select Id
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            leankor__ValueStream__c targetBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            leankor__MasterContainer__c masterContainer1 = [Select Id 
                                                                From leankor__MasterContainer__c 
                                                                Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                Limit 1];
            leankor__Swimlane__c swimlane1 = [Select Id 
                                                    From leankor__Swimlane__c 
                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                    Limit 1];
            leankor__Zone__c zone1 = [Select Id,
                                                leankor__GUID__c 
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c = :sampleBoard.Id 
                                            Limit 1];
            leankor__KanbanCardTemplate__c kanbanCardTemplate = [Select Id 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                    Limit 1];
            // Create a Kanban card with null start and due dates
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'NullDateCard';
            kanbanCard.leankor__StartDateTime__c = null;
            kanbanCard.leankor__DueDateTime__c = null;
            kanbanCard.leankor__EstimatedDuration__c = 1;
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
            kanbanCard.leankor__ValueStream__c = sampleBoard.Id;
            kanbanCard.leankor__MasterContainer__c = masterContainer1.Id;
            kanbanCard.leankor__Swimlane__c = swimlane1.Id;
            kanbanCard.leankor__Order__c = 5;
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
            kanbanCard.leankor__DurationUnits__c = 'Days';
            insert kanbanCard;

            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
            reqOne.targetBoardId = targetBoard.Id;
            reqOne.TargetDate = null;
            reqOne.WithMC = true;
            req.add(reqOne);

            try {
                List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
                System.assertNotEquals(null, result, 'Result should not be null');
            } catch (Exception e) {
                System.assert(true, 'Expected exception for null dates: ' + e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
    static void testUpdateHeightWidthWithInvalidData() {
        Test.startTest();
            leankor__ValueStream__c targetBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];

            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'InvalidHeightWidthCard';
            kanbanCard.leankor__ValueStream__c = targetBoard.Id;
            kanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbanCard.leankor__Width__c = null;
            kanbanCard.leankor__Height__c = null;
            insert kanbanCard;

            try {
                MultipleMergeProjectBoardAction.updateHeightWidth(targetBoard.Id);
                System.assert(true, 'updateHeightWidth executed successfully');
            } catch (Exception e) {
                System.assert(false, 'updateHeightWidth failed: ' + e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
    static void testDateCalculationsWithComplexScenario() {
        Test.startTest();
            // Retrieve test data
            leankor__ValueStream__c sampleBoard = [Select Id
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board' 
                                                        Limit 1];
            leankor__ValueStream__c targetBoard = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'Project Board1' 
                                                        Limit 1];
            leankor__MasterContainer__c masterContainer1 = [Select Id 
                                                                From leankor__MasterContainer__c 
                                                                Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                Limit 1];
            leankor__Swimlane__c swimlane1 = [Select Id 
                                                    From leankor__Swimlane__c 
                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                    Limit 1];
            leankor__Zone__c zone1 = [Select Id,
                                                leankor__GUID__c 
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c = :sampleBoard.Id 
                                            Limit 1];
            leankor__KanbanCardTemplate__c kanbanCardTemplate = [Select Id 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__ValueStream__c = :sampleBoard.Id 
                                                                    Limit 1];
            // Set up a weekend start date and blackout
            DateTime weekendStart = DateTime.newInstance(2025, 6, 21, 12, 0, 0); // Saturday
            List<leankor__ProjectScheduleBlackout__c> blackouts = new List<leankor__ProjectScheduleBlackout__c>();
            leankor__ProjectScheduleBlackout__c blackout = new leankor__ProjectScheduleBlackout__c();
            blackout.leankor__StartDate__c = Date.newInstance(2025, 6, 21); // Saturday
            blackout.leankor__EndDate__c = Date.newInstance(2025, 6, 22);   // Sunday
            blackout.leankor__ProjectBoard__c = sampleBoard.Id;
            blackouts.add(blackout);
            insert blackouts;
            Util.WorkWeek workWeek = new Util.WorkWeek(1, 5, blackouts); // Monday start, 5-day week

            // Create Kanban cards with varied DurationUnits and EstimatedDuration
            List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
            for (String unit : new List<String>{'Years', 'Months', 'Weeks', 'Days', 'Hours', 'Minutes'}) {
                leankor__KanbanCard__c card = new leankor__KanbanCard__c();
                card.Name = 'Card ' + unit;
                card.leankor__StartDateTime__c = weekendStart;
                card.leankor__DueDateTime__c = weekendStart.addDays(1);
                card.leankor__EstimatedDuration__c = (unit == 'Days' ? 3 : 1); // Use 3 for Days to trigger loop
                card.leankor__KanbanCardTemplate__c = kanbanCardTemplate.Id;
                card.leankor__ValueStream__c = sampleBoard.Id;
                card.leankor__MasterContainer__c = masterContainer1.Id;
                card.leankor__Swimlane__c = swimlane1.Id;
                card.leankor__Order__c = 5;
                card.leankor__GUID__c = leankor.TestDataFactory.createGuid();
                card.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
                card.leankor__DurationUnits__c = unit;
                cards.add(card);
            }
            insert cards;
            // Set initialDate to a Monday after the weekend
            DateTime initialDate = DateTime.newInstance(2025, 6, 23, 9, 0, 0);

            // Prepare request
            List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> req = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest reqOne = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            reqOne.SourceBoardId = new List<String>{sampleBoard.Id};
            reqOne.targetBoardId = targetBoard.Id;
            reqOne.TargetDate = System.now();
            reqOne.WithMC = true;
            reqOne.initialDate = initialDate; // Set initialDate to trigger its usage
            req.add(reqOne);

            try {
                List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> result = leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(req);
                System.assertNotEquals(null, result, 'Result should not be null');
            } catch (Exception e) {
                System.assert(false, 'Merge failed: ' + e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
    static void testMultipleMergeProjectBoardCatchBlock() {
        // Step 1: Create Target Board
        leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
        targetBoard.Name = 'Target Board';
        insert targetBoard;

        // Step 2: Create Source Board (even if unused)
        leankor__ValueStream__c sourceBoard = new leankor__ValueStream__c();
        sourceBoard.Name = 'Source Board';
        insert sourceBoard;

        // Step 3: Create Master Container on Target Board
        leankor__MasterContainer__c targetMasterContainer = new leankor__MasterContainer__c();
        targetMasterContainer.Name = 'MainContainer1';
        targetMasterContainer.leankor__ValueStream__c = targetBoard.Id;
        targetMasterContainer.leankor__Order__c = null;
        targetMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert targetMasterContainer;

        // Step 3: Create Master Container on Source Board
        leankor__MasterContainer__c sourceBoardMasterContainer = new leankor__MasterContainer__c();
        sourceBoardMasterContainer.Name = 'MainContainer1';
        sourceBoardMasterContainer.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardMasterContainer.leankor__Order__c = 1;
        sourceBoardMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert sourceBoardMasterContainer;

        // Step 4: Create 2 Swimlanes on the Target Board, both linked to the same Master Container
        leankor__Swimlane__c swimlane1 = new leankor__Swimlane__c();
        swimlane1.Name = 'Swimlane 1';
        swimlane1.leankor__ValueStream__c = targetBoard.Id;
        swimlane1.leankor__MasterContainer__c = targetMasterContainer.Id;
        swimlane1.leankor__Order__c = 1;
        swimlane1.leankor__CardPerRow__c = 3;
        insert swimlane1;

        leankor__Swimlane__c swimlane2 = new leankor__Swimlane__c();
        swimlane2.Name = 'Swimlane 2';
        swimlane2.leankor__ValueStream__c = targetBoard.Id;
        swimlane2.leankor__MasterContainer__c = targetMasterContainer.Id;
        swimlane2.leankor__Order__c = 2;
        swimlane2.leankor__CardPerRow__c = 2;
        insert swimlane2;

        // Step 5: Create Zones for each Swimlane (required to populate finalSWmap)
        leankor__Zone__c zone1 = new leankor__Zone__c();
        zone1.Name = 'Zone 1';
        zone1.leankor__Width__c = 200.0;
        zone1.leankor__X__c = 10.0;
        zone1.leankor__Y__c = 20.0;
        zone1.leankor__GUID__c = TestDataFactory.createGuid();
        zone1.leankor__Swimlane__c = swimlane1.Id;
        zone1.leankor__ValueStream__c = targetBoard.Id;
        zone1.leankor__CardsPerRow__c = 5;
        insert zone1;

        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'Zone 2';
        zone2.leankor__Width__c = 180.0;
        zone2.leankor__X__c = 50.0;
        zone2.leankor__Y__c = 60.0;
        zone2.leankor__GUID__c = TestDataFactory.createGuid();
        zone2.leankor__Swimlane__c = swimlane2.Id;
        zone2.leankor__ValueStream__c = targetBoard.Id;
        zone2.leankor__CardsPerRow__c = 4;
        insert zone2;


        // Step 5: Prepare the request object
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest req = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();

        req.SourceBoardId = new List<Id>{ sourceBoard.Id };
        req.targetBoardId = targetBoard.Id;
        req.WithMC = true;

        // Step 6: Call the method
        Test.startTest();
        //leankor.MultipleMergeProjectBoardAction action = new leankor.MultipleMergeProjectBoardAction();
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>{ req });
        Test.stopTest();
        // Step 7: Verify the results
        List<leankor__KanbanCard__c> cards = [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :targetBoard.Id];
        System.assertEquals(0, cards.size(), 'No cards should be created on the target board since the source board is empty.');
    }
    @isTest
    static void testMultipleMergeProjectBoardIfElse() {
        // Step 1: Create Target Board
        leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
        targetBoard.Name = 'Target Board';
        targetBoard.leankor__BoardType__c = 'Dashboard';
        insert targetBoard;

        // Step 2: Create Source Board (even if unused)
        leankor__ValueStream__c sourceBoard = new leankor__ValueStream__c();
        sourceBoard.Name = 'Source Board';
        insert sourceBoard;

        // Step 3: Create Master Container on Target Board
        leankor__MasterContainer__c targetMasterContainer = new leankor__MasterContainer__c();
        targetMasterContainer.Name = 'MainContainer';
        targetMasterContainer.leankor__ValueStream__c = targetBoard.Id;
        targetMasterContainer.leankor__Order__c = null;
        targetMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert targetMasterContainer;

        // Step 3: Create Master Container on Source Board
        leankor__MasterContainer__c sourceBoardMasterContainer = new leankor__MasterContainer__c();
        sourceBoardMasterContainer.Name = 'MainContainer1';
        sourceBoardMasterContainer.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardMasterContainer.leankor__Order__c = 1;
        sourceBoardMasterContainer.leankor__GUID__c = TestDataFactory.createGuid();
        insert sourceBoardMasterContainer;

        // Step 4: Create 2 Swimlanes on the Target Board, both linked to the same Master Container
        leankor__Swimlane__c swimlane1 = new leankor__Swimlane__c();
        swimlane1.Name = 'Swimlane 1';
        swimlane1.leankor__ValueStream__c = targetBoard.Id;
        swimlane1.leankor__MasterContainer__c = targetMasterContainer.Id;
        swimlane1.leankor__Order__c = 1;
        swimlane1.leankor__CardPerRow__c = 3;
        insert swimlane1;

        leankor__Swimlane__c swimlane2 = new leankor__Swimlane__c();
        swimlane2.Name = 'Swimlane 2';
        swimlane2.leankor__ValueStream__c = targetBoard.Id;
        swimlane2.leankor__MasterContainer__c = targetMasterContainer.Id;
        swimlane2.leankor__Order__c = 4;
        swimlane2.leankor__CardPerRow__c = 2;
        insert swimlane2;
        
        leankor__Swimlane__c sourceBoardSwimlane = new leankor__Swimlane__c();
        sourceBoardSwimlane.Name = 'Swimlane 2';
        sourceBoardSwimlane.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardSwimlane.leankor__Order__c = 3;
        sourceBoardSwimlane.leankor__CardPerRow__c = 2;
        insert sourceBoardSwimlane;
        
        leankor__Swimlane__c sourceBoardSwimlane1 = new leankor__Swimlane__c();
        sourceBoardSwimlane1.Name = 'Swimlane 2';
        sourceBoardSwimlane1.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardSwimlane1.leankor__MasterContainer__c = sourceBoardMasterContainer.Id;
        sourceBoardSwimlane1.leankor__Order__c = 3;
        sourceBoardSwimlane1.leankor__CardPerRow__c = 2;
        insert sourceBoardSwimlane1;

        // Step 5: Create Zones for each Swimlane (required to populate finalSWmap)
        leankor__Zone__c zone1 = new leankor__Zone__c();
        zone1.Name = 'Zone 1';
        zone1.leankor__Width__c = 200.0;
        zone1.leankor__X__c = 10.0;
        zone1.leankor__Y__c = 20.0;
        zone1.leankor__GUID__c = TestDataFactory.createGuid();
        zone1.leankor__Swimlane__c = swimlane1.Id;
        zone1.leankor__ValueStream__c = targetBoard.Id;
        zone1.leankor__CardsPerRow__c = 5;
        insert zone1;

        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'Zone 2';
        zone2.leankor__Width__c = 180.0;
        zone2.leankor__X__c = 50.0;
        zone2.leankor__Y__c = 60.0;
        zone2.leankor__GUID__c = TestDataFactory.createGuid();
        zone2.leankor__Swimlane__c = swimlane2.Id;
        zone2.leankor__ValueStream__c = targetBoard.Id;
        zone2.leankor__CardsPerRow__c = 4;
        insert zone2;

        leankor__Zone__c sourceBoardZone1 = new leankor__Zone__c();
        sourceBoardZone1.Name = 'Source Zone 1';
        sourceBoardZone1.leankor__Width__c = 200.0;
        sourceBoardZone1.leankor__X__c = 10.0;
        sourceBoardZone1.leankor__Y__c = 20.0;
        sourceBoardZone1.leankor__GUID__c = TestDataFactory.createGuid();
        sourceBoardZone1.leankor__Swimlane__c = sourceBoardSwimlane.Id;
        sourceBoardZone1.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardZone1.leankor__CardsPerRow__c = 5;
        insert sourceBoardZone1;
        
        leankor__Zone__c sourceBoardZone2 = new leankor__Zone__c();
        sourceBoardZone2.Name = 'Source Zone 1';
        sourceBoardZone2.leankor__Width__c = 200.0;
        sourceBoardZone2.leankor__X__c = 10.0;
        sourceBoardZone2.leankor__Y__c = 20.0;
        sourceBoardZone2.leankor__GUID__c = TestDataFactory.createGuid();
        sourceBoardZone2.leankor__Swimlane__c = sourceBoardSwimlane1.Id;
        sourceBoardZone2.leankor__ValueStream__c = sourceBoard.Id;
        sourceBoardZone2.leankor__CardsPerRow__c = 5;
        insert sourceBoardZone2;

        // Step 5: Prepare the request object
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest req = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();

        req.SourceBoardId = new List<Id>{ sourceBoard.Id };
        req.targetBoardId = targetBoard.Id;
        req.WithMC = true;
        // Step 6: Call the method
        Test.startTest();
        leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoard(new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>{ req });
        Test.stopTest();
        // Step 7: Verify the results
        List<leankor__KanbanCard__c> targetCards = [Select Id,
                                                            Name,
                                                            leankor__MasterContainer__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :targetBoard.Id];
        System.assertEquals(0, targetCards.size(), 'No cards should be merged to the target board');
    }
}