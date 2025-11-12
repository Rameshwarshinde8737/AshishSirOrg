@isTest
public Class CloneProjectPlanGanttBatchTest {
    @testSetup
    static void setupTestData() {
        // Create a source Project Board
        User user = leankor.TestDataFactory.createStandardUser('Lean123');
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'TestFolder');
        insert testFolder;
        
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(name = 'testRoom',leankor__DueDate__c = System.today());
        insert sourceProject;
        
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name='_System_Board';
        vStream.leankor__BoardType__c='Kanban Board';
        vStream.leankor__ProjectBoardLaunchDateTime__c = System.now();
        vStream.leankor__ProjectRoom__c = sourceProject.Id;
        insert vStream;
        
        leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.leankor__JSONDefinition__c = '';
        template.leankor__JSONData__c = '';
        template.leankor__Width__c = 170;
        template.leankor__Height__c =120; // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
        template.leankor__CSSLayout__c = '';
        template.leankor__Color__c = '#bdbffc';
        template.leankor__FieldSetName__c = 'leankor__leankorfieldset';
        template.leankor__ValueStream__c = vStream.Id;
        template.Name = 'Default';
        template.leankor__Title__c ='Default';
        insert template;
        
        leankor__KanbanCardTemplate__c templatecard = new leankor__KanbanCardTemplate__c(Name = 'default');
        insert templatecard;
        
        leankor__ValueStream__c sourceProjectBoard = new leankor__ValueStream__c();
        sourceProjectBoard.Name = 'Source Project Board';
        sourceProjectBoard.leankor__TaskIndicator__c = true;
        sourceProjectBoard.leankor__DefaultCategory__c = template.id;
        sourceProjectBoard.leankor__OpportunityCardCategory__c = templatecard.Id;
        sourceProjectBoard.leankor__SevenDayWorkWeek__c = true;
        sourceProjectBoard.leankor__TaskDateCheck__c = true;
        //sourceProjectBoard.leankor__ScheuleBackward__c = false;
        sourceProjectBoard.leankor__ProjectBoardStartDateTime__c = DateTime.now().addDays(-10);
        sourceProjectBoard.leankor__ProjectBoardEndDateTime__c = DateTime.now().addDays(10);
        sourceProjectBoard.leankor__ProjectBoardLaunchDateTime__c = System.now();
        sourceProjectBoard.leankor__ValueStreamLink__c = vStream.Id;
        insert sourceProjectBoard;
        
        leankor__ValueStream__c sourceProjectBoardValueStream = new leankor__ValueStream__c();
        sourceProjectBoardValueStream.Name = 'Source Project Board1';
        sourceProjectBoardValueStream.leankor__TaskIndicator__c = true;
        sourceProjectBoardValueStream.leankor__DefaultCategory__c = template.id;
        sourceProjectBoardValueStream.leankor__OpportunityCardCategory__c = templatecard.Id;
        sourceProjectBoardValueStream.leankor__SevenDayWorkWeek__c = true;
        sourceProjectBoardValueStream.leankor__TaskDateCheck__c = true;
        sourceProjectBoardValueStream.leankor__ValueStreamLink__c = vStream.Id;
        insert sourceProjectBoardValueStream;
        
        leankor__mastercontainer__c newMc = new leankor__mastercontainer__c();
        newMc.name= 'Test MC';
        newMc.leankor__Valuestream__c= sourceProjectBoard.id;
        insert newMc ;
        
        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
        newSw.name = 'Test SW';
        newSw.leankor__mastercontainer__c= newMC.id;
        newSw.leankor__Valuestream__c = sourceProjectBoard.id;
        insert newSw;
        
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        leankor__Zone__c sourceBoardZone1 = new leankor__Zone__c();
        sourceBoardZone1.Name = 'kanban test3';
        sourceBoardZone1.leankor__GUID__c = TestDataFactory.createGuid();
        sourceBoardZone1.leankor__CmpID__c = 'my-CMPID-zone-test1';
        sourceBoardZone1.leankor__swimlane__c = newSw.Id;
        sourceBoardZone1.leankor__ValueStream__c = sourceProjectBoard.id;
        zones.add(sourceBoardZone1);
        
        leankor__Zone__c sourceBoardZone2 = new leankor__Zone__c();
        sourceBoardZone2.Name = 'kanban test3';
        sourceBoardZone2.leankor__GUID__c = TestDataFactory.createGuid();
        sourceBoardZone2.leankor__CmpID__c = 'my-CMPID-zone-test2';
        sourceBoardZone2.leankor__swimlane__c = newSw.Id;
        sourceBoardZone2.leankor__ValueStream__c = sourceProjectBoard.id;
        zones.add(sourceBoardZone2);
        insert zones;
        
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = true;
        customSetting.leankor__ManuallyScheduled__c = false;
        customSetting.leankor__StreamingAPIVersion__c = 55.0;
        customSetting.leankor__FirstDayOfTheWeek__c = 1;
        insert customSetting;
        
        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.Name = 'Test Blackout';
        blackOut.leankor__ProjectBoard__c = sourceProjectBoard.Id;
        blackOut.leankor__EndDate__c = System.Today() + 20;
        blackOut.leankor__StartDate__c = System.Today() + 18;
        blackOutsList.add(blackOut);
        
        leankor__ProjectScheduleBlackout__c blackOut2 = new leankor__ProjectScheduleBlackout__c();
        blackOut2.Name = 'Test Blackout-2';
        blackOut2.leankor__ProjectBoard__c = sourceProjectBoard.Id;
        blackOut2.leankor__EndDate__c = System.Today() + 20;
        blackOut2.leankor__StartDate__c = System.Today() + 18;
        blackOutsList.add(blackOut2);
        insert blackOutsList;
        
        // Create Kanban Card Templates for the source Value Stream
        List<leankor__KanbanCardTemplate__c> kanbanTemplates = new List<leankor__KanbanCardTemplate__c>();
        for (Integer i = 0; i < 5; i++) {
            leankor__KanbanCardTemplate__c templateRecord = new leankor__KanbanCardTemplate__c();
            templateRecord.leankor__ValueStream__c = sourceProjectBoard.Id;
            templateRecord.leankor__Title__c = 'Test Template ' + i;
            templateRecord.leankor__Color__c = '#ffcc00';
            templateRecord.leankor__Width__c = 170;
            templateRecord.leankor__Height__c = 120;
            templateRecord.OwnerId = UserInfo.getUserId();
            templateRecord.leankor__FieldSetName__c = 'leankor__leankorfieldset';
            templateRecord.Name = 'Template ' + i;
            kanbanTemplates.add(templateRecord);
        }
        insert kanbanTemplates;
        
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
        projectBoardOne.Name = 'Plan Board';
        projectBoardOne.leankor__BoardType__c='UberBoard';
        projectBoardOne.leankor__ProjectRoom__c = sourceProject.Id;
        projectBoardOne.leankor__IsTemplateBoard__c = false;
        insert projectBoardOne;
        
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for (Integer i = 0; i < 2; i++) {
            Integer kbCount = 2;
            Integer actCount = 2;
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplates[0].Id;
            kanbanCard.leankor__DurationUnits__c ='Days';
            kanbanCard.leankor__StartDateTime__c = System.now().addDays(kbCount);
            kanbanCard.OwnerId = user.Id;
            kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCard.leankor__Monday__c = false;
            kanbanCard.leankor__Tuesday__c = false;
            kanbanCard.leankor__Wednesday__c = false;
            kanbanCard.leankor__Thursday__c = false;
            kanbanCard.leankor__Friday__c = false;
            kanbanCard.leankor__Saturday__c = false;
            kanbanCard.leankor__Sunday__c = false;
            kanbanCard.leankor__ValueStreamLink__c = projectBoardOne.id;
            if (Math.mod(i, 2) == 0) {
                kanbanCard.Name = 'Activity ';
                kanbanCard.leankor__Title__c = 'Activity ';
                kanbanCard.leankor__ValueStream__c = sourceProjectBoard.Id;
                kanbanCard.leankor__DueDateTime__c = System.now().addDays(kbCount);
                kanbanCard.leankor__EstimatedDuration__c = kbCount;
                kbCount++;
            }
            else {
                kanbanCard.Name = 'Activity ';
                kanbanCard.leankor__Title__c = 'Activity ';
                kanbanCard.leankor__ValueStream__c = sourceProjectBoard.Id;
                kanbanCard.leankor__DueDateTime__c = System.now().addDays(actCount);
                kanbanCard.leankor__EstimatedDuration__c = actCount;
                actCount++;
                //kanbanCard.leankor__ValueStreamCardLink__c = ag.Id;
            }
            kanbanCardsList.add(kanbanCard);
        }
        insert kanbanCardsList;
        
        
        List<leankor__KanbanCard__c> kanbanCardsList1 = new List<leankor__KanbanCard__c>();
        for (leankor__KanbanCard__c ag : kanbanCardsList) {
            for (Integer i = 0; i < 2; i++) {
                Integer kbCount = 2;
                Integer actCount = 2;
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
                kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplates[0].Id;
                kanbanCard.leankor__DurationUnits__c ='Hours';
                kanbanCard.leankor__StartDateTime__c = System.now().addDays(kbCount);
                kanbanCard.OwnerId = user.Id;
                kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
                kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
                kanbanCard.leankor__Monday__c = false;
                kanbanCard.leankor__Tuesday__c = false;
                kanbanCard.leankor__Wednesday__c = true;
                kanbanCard.leankor__Thursday__c = false;
                kanbanCard.leankor__Friday__c = true;
                kanbanCard.leankor__Saturday__c = false;
                kanbanCard.leankor__Sunday__c = false;
                kanbanCard.leankor__ValueStreamLink__c = projectBoardOne.id;
                if (Math.mod(i, 2) == 0) {
                    kanbanCard.Name = 'Activity ';
                    kanbanCard.leankor__Title__c = 'Activity ';
                    kanbanCard.leankor__ValueStream__c = sourceProjectBoardValueStream.Id;
                    kanbanCard.leankor__DueDateTime__c = System.now().addDays(kbCount);
                    kanbanCard.leankor__EstimatedDuration__c = kbCount;
                    kbCount++;
                }
                else {
                    kanbanCard.Name = 'Activity ';
                    kanbanCard.leankor__Title__c = 'Activity ';
                    kanbanCard.leankor__ValueStream__c = sourceProjectBoardValueStream.Id;
                    kanbanCard.leankor__DueDateTime__c = System.now().addDays(actCount);
                    kanbanCard.leankor__EstimatedDuration__c = actCount;
                    actCount++;
                    kanbanCard.leankor__ValueStreamCardLink__c = ag.Id;
                }
                kanbanCardsList1.add(kanbanCard);
            }
        }
        insert kanbanCardsList1;
        
        leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
        mustStartOn.leankor__Description__c = 'muststarton';
        mustStartOn.leankor__Type__c = 'muststarton';
        insert mustStartOn;
        
        List<leankor__ScheduleMode__c> schedModes = new List<leankor__ScheduleMode__c>();
        for (leankor__KanbanCard__c card : kanbanCardsList) {
            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();
            schedMode.leankor__KanbanCard__c = card.Id;
            schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
            schedMode.leankor__ConstraintDateTime__c = card.leankor__StartDateTime__c;
            schedModes.add(schedMode);
        }
        insert schedModes;
        
        List<String> templateIds = new List<String>();
        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c();
        kanbanTemp.Name ='TestTemplate';
        kanbanTemp.leankor__Title__c = 'TestTemplate';
        kanbanTemp.leankor__color__c = '#fff';
        kanbanTemp.leankor__csslayout__c = '';
        kanbanTemp.leankor__height__c = 300;
        kanbanTemp.leankor__width__c = 300;
        kanbanTemp.leankor__jsondata__c = '{}';
        kanbanTemp.leankor__jsondefinition__c = '{}';
        kanbanTemp.leankor__valuestream__c = vStream.Id;
        insert kanbanTemp;
        templateIds.add(kanbanTemp.Id);
        
        List<leankor__Preference__c> preferenceList = new List<leankor__Preference__c>();
        leankor__Preference__c prferen = new leankor__Preference__c();
        prferen.Name = 'users';
        prferen.leankor__FollowOnChatter__c = JSON.serialize(templateIds);
        prferen.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        prferen.OwnerID = UserInfo.getUserId() ;
        prferen.leankor__ValueStream__c = sourceProjectBoard.Id;
        prferen.leankor__CardPastDueDate__c = false;
        prferen.leankor__Moved__c = false;
        prferen.leankor__PercentDone__c = false;
        prferen.leankor__SubscribeToCard__c = JSON.serialize(templateIds);
        prferen.leankor__TaskPastDueDate__c = false;
        prferen.leankor__isTaskCompleted__c = false;
        preferenceList.add(prferen);
        insert preferenceList;
        
        List < leankor__Preference__c > preferenceList1 = new List < leankor__Preference__c > ();
        leankor__Preference__c prferen1 = new leankor__Preference__c();
        prferen1.Name = 'users';
        prferen1.leankor__FollowOnChatter__c = 'all';
        prferen1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        prferen1.OwnerID = UserInfo.getUserId() ;
        prferen1.leankor__ValueStream__c = sourceProjectBoard.Id;
        prferen1.leankor__CardPastDueDate__c = false;
        prferen1.leankor__Moved__c = false;
        prferen1.leankor__PercentDone__c = false;
        prferen1.leankor__SubscribeToCard__c = 'all';
        prferen1.leankor__TaskPastDueDate__c = false;
        prferen1.leankor__isTaskCompleted__c = false;
        preferenceList1.add(prferen1);
        insert preferenceList1;
        
        List<leankor__Subscriber__c> subList = new List<leankor__Subscriber__c>();
        leankor__Subscriber__c sub = new  leankor__Subscriber__c();
        sub.leankor__KanbanCard__c = kanbanCardsList[0].Id;
        sub.leankor__SubscriberKey__c   = TestDataFactory.createGuid();
        subList.add(sub);
        insert subList;
        
        Task task1 = new Task();
        task1.Priority = 'Normal';
        task1.OwnerId = UserInfo.getUserId();
        task1.Subject = 'Task 1 Subject';
        task1.Status = 'Not Started';
        task1.ActivityDate = Date.today();
        task1.WhatId = kanbanCardsList[0].Id;
        task1.Description = 'Task 1 description';
        
        Task task2 = new Task();
        task2.Priority = 'High';
        task2.OwnerId = UserInfo.getUserId();
        task2.Subject = 'Task 2 Subject';
        task2.Status = 'In Progress';
        task2.ActivityDate = Date.today().addDays(5);
        task2.WhatId = kanbanCardsList[0].Id;
        task2.Description = 'Task 2 description';
        insert new List<Task>{task1, task2};
        
        leankor__Sticker__c stick=new leankor__Sticker__c();
        stick.name='Sticker__Name';
        stick.leankor__ValueStream__c=sourceProjectBoard.Id;
        insert stick;
        
        List<leankor__KanbanCardSticker__c>kanbancardStickerList = new List<leankor__KanbanCardSticker__c>();
        for (integer count=0; count< kanbanCardsList.size(); count++) {
            leankor__KanbanCardSticker__c kanSticker=new leankor__KanbanCardSticker__c();
            kanSticker.leankor__KanbanCard__c=kanbanCardsList[count].Id;
            kanSticker.leankor__Sticker__c=stick.id;
            kanbancardStickerList.add(kanSticker);
        }
        insert kanbancardStickerList;
        
        Attachment stickAtt = new Attachment();
        stickAtt.ParentId = stick.Id;
        stickAtt.Name = 'afilename';
        stickAtt.Body = Blob.valueOf('a file');
        insert stickAtt;
        
        list<ContentVersion> contentVersionList = new list<ContentVersion>();
        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.Title = 'Penguins';
        contentVersion1.PathOnClient = 'Penguins.jpg';
        contentVersion1.VersionData = Blob.valueOf('Test Content');
        contentVersion1.IsMajorVersion = true;
        contentVersionList.add(contentVersion1);
        
        ContentVersion contentVersion2 = new ContentVersion();
        contentVersion2.Title = 'Penguins1';
        contentVersion2.PathOnClient = 'Penguins1.jpg';
        contentVersion2.VersionData = Blob.valueOf('Test Content1');
        contentVersion2.IsMajorVersion = true;
        contentVersionList.add(contentVersion2);
        insert contentVersionList;
        
        FeedItem post = new FeedItem();
        post.parentId = UserInfo.getUserId();
        post.Body = 'Body';
        post.relatedRecordId = contentVersionList[0].id;
        insert post;
        
        FeedComment feedComment = new FeedComment();
        feedComment.FeedItemId = post.Id ;
        feedComment.CommentBody  = 'Abc';
        feedComment.RelatedRecordId = contentVersionList[1].Id;
        insert feedComment ;
        
        
        List<FeedItem> feedItems = new List<FeedItem>();
        for (Integer i = 0; i < 3; i++) {
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId =  UserInfo.getUserId(); // Simulating KanbanCard IDs in real scenarios
            feedItem.RelatedRecordId = contentVersionList[1].Id;
            feedItem.Body = 'Test FeedItem ' + i;
            feedItems.add(feedItem);
        }
        insert feedItems;
        
        List<leankor__Marker__c> markerList = new List<leankor__Marker__c>();
        leankor__Marker__c marker = new leankor__Marker__c();
        marker.Name = 'test';
        marker.leankor__ValueStream__c = sourceProjectBoard.Id;
        marker.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        marker.leankor__GUID2__c = leankor.TestDataFactory.createGuid();
        markerList.add(marker);
        insert markerList;
        
        Attachment stickAtt1 = new Attachment();
        stickAtt1.ParentId = markerList[0].Id;
        stickAtt1.Name = 'afilename';
        stickAtt1.Body = Blob.valueOf('a file');
        insert stickAtt1;
        
        leankor__KanbanCard__c kanbanCard1 = new leankor__KanbanCard__c();
        kanbanCard1.leankor__Title__c = 'Kanban Card 1';
        kanbanCard1.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        kanbanCard1.leankor__ValueStream__c = sourceProjectBoard.id;
        
        leankor__KanbanCard__c kanbanCard2 = new leankor__KanbanCard__c();
        kanbanCard2.leankor__Title__c = 'Kanban Card 2';
        kanbanCard2.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        kanbanCard2.leankor__ValueStream__c = sourceProjectBoard.id;
        insert new List<leankor__KanbanCard__c>{kanbanCard1, kanbanCard2};
        
        
        List<leankor__Dependency__c> dependncyList=new List<leankor__Dependency__c>();
        for (Integer i=0;i<5;i++) {
            leankor__Dependency__c dependency=new leankor__Dependency__c();
            dependency.leankor__GUID__c=leankor.TestDataFactory.createGuid()+i;
            dependency.leankor__ValueStream__c = sourceProjectBoard.id;
            dependency.leankor__LagLead__c=2;
            dependency.leankor__SuccessorType__c='Start To Start';
            dependency.leankor__LagLeadUnit__c='';
            dependency.leankor__Predecessor__c=kanbanCard1.id;
            dependency.leankor__Successor__c=kanbanCard2.id;
            dependncyList.add(dependency);
        }
        insert dependncyList;
        
        // Create a new Project Board
        leankor__ValueStream__c newProjectBoard = new leankor__ValueStream__c();
        newProjectBoard.Name = 'new Project Board';
        newProjectBoard.leankor__SevenDayWorkWeek__c = true;
        newProjectBoard.leankor__ProjectBoardLaunchDateTime__c = System.now();
        newProjectBoard.leankor__TaskDateCheck__c = true;
        newProjectBoard.leankor__ValueStreamLink__c = vStream.Id;
        newProjectBoard.leankor__ProjectRoom__c = sourceProject.Id;
        insert newProjectBoard;
        
        // Create records for leankor__ProjectBoardWorkFieldSet__c related to the source Project Board
        List<leankor__ProjectBoardWorkFieldSet__c> fieldSetList = new List<leankor__ProjectBoardWorkFieldSet__c>();
        
        fieldSetList.add(new leankor__ProjectBoardWorkFieldSet__c(
            leankor__FieldSetName__c = 'leankorfieldset__c',
        leankor__ProjectBoard__c = sourceProjectBoard.Id
            ));
        
        fieldSetList.add(new leankor__ProjectBoardWorkFieldSet__c(
            leankor__FieldSetName__c = 'demofieldsset__c',
        leankor__ProjectBoard__c = sourceProjectBoard.Id
            ));
        
        // Insert the list of field sets
        insert fieldSetList;
        
    }
    
    @isTest
    static void testCloneProjectBoardWorkFieldSet() {
        // Get the source and new Project Boards
        leankor__ValueStream__c sourceProjectBoard = [Select Id
                                                        From leankor__ValueStream__c
                                                        Where Name = 'Source Project Board'
                                                        Limit 1];
        leankor__ValueStream__c newProjectBoard = [Select Id
                                                        From leankor__ValueStream__c
                                                        Where Name = 'new Project Board'
                                                        Limit 1];
        
        // Create BoardData object (assuming BoardData is a custom Apex class or data structure)
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.sourceValueStreamId = sourceProjectBoard.Id;
        boardData.newValueStreamId = newProjectBoard.Id;
        
        // Invoke the method to clone records
        Test.startTest();
        CloneProjectPlanGanttBatch.cloneProjectBoardWorkFieldSet(boardData);
        Test.stopTest();
        
        // Verify that the new records were cloned correctly
        List<leankor__ProjectBoardWorkFieldSet__c> clonedRecords = [Select Id,
                                                                        leankor__FieldSetName__c,
                                                                        leankor__ProjectBoard__c
                                                                    From leankor__ProjectBoardWorkFieldSet__c
                                                                    Where leankor__ProjectBoard__c = :newProjectBoard.Id];
        
        // Assert that 3 records were cloned
        System.assertNotEquals(0, clonedRecords.size(), ' records should be cloned.');
    }
    
    @isTest
    static void testReadnewBoardData() {
        List<leankor__ValueStream__c> testValueStream = [Select Id,
                                                                Name
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        
        // Call the method to read the Value Stream data
        Test.startTest();
        leankor__ValueStream__c result = CloneProjectPlanGanttBatch.readnewBoardData(testValueStream[0].Id);
        System.assertEquals(result.Name, 'Source Project Board', 'The Value Stream Name does not match the expected value.');
        
    }
    
    @isTest
    static void testCloneKanbanCardTemplates() {
        // Fetch the source and new Value Streams created in the test setup
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        // Create a mock BoardData object
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.kanbanTemplateVerb = true; // Enable cloning of Kanban templates
        
        Test.startTest();
        CloneProjectPlanGanttBatch.KanbanCardTemplateData clonedData = CloneProjectPlanGanttBatch.cloneKanbanCardTemplates(boardData, newValueStream[0]);
        Test.stopTest();
        
        // Assert the returned KanbanCardTemplateData is not null
        System.assertNotEquals(null, clonedData, 'KanbanCardTemplateData should not be null');
        
        // Verify the cloned templates' fields
        for (leankor__KanbanCardTemplate__c clonedTemplate : clonedData.cloneTemplates) {
            System.assertEquals(newValueStream[0].Id, clonedTemplate.leankor__ValueStream__c, 'The ValueStreamId should be updated to the new Value Stream');
            System.assertEquals('#ffcc00', clonedTemplate.leankor__Color__c, 'The Color should match the original template');
        }
        
        // Assert that no default template was created (since templates were cloned)
        System.assertEquals(false, clonedData.updateVSdefaultKCT, 'No default Kanban Card Template should be created');
    }
    
    @isTest
    static void testCloneKanbanCardTemplatesWithNoSource() {
        // Create a mock BoardData object with an empty sourceValueStreamId
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.sourceValueStreamId = '';
        boardData.newValueStreamId = [Select Id
                                        From leankor__ValueStream__c
                                        Where Name = 'new Project Board'
                                        Limit 1].Id;
        boardData.kanbanTemplateVerb = true;
        
        // Mock the RealTimeControllerHelper.readkanbanCardTemplate() to return empty or specific values if needed
        // You might need to mock this depending on how your org works, but for now we'll skip it
        
        Test.startTest();
        CloneProjectPlanGanttBatch.KanbanCardTemplateData clonedData = CloneProjectPlanGanttBatch.cloneKanbanCardTemplates(boardData, [Select Id From leankor__ValueStream__c Where Name = 'new Project Board' Limit 1]);
        Test.stopTest();
        
        // Assert that a default Kanban Card Template was created
        System.assertNotEquals(null, clonedData.cloneTemplates.size(), 'There should be 1 default Kanban Card Template created');
    }
    
    @isTest
    static void testCloneBoardAdditionalInfo() {
        // Fetch the Value Streams created in the test setup
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                leankor__ProjectBoardStartDateTime__c,
                                                                leankor__ProjectBoardEndDateTime__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        // Create a mock KanbanCardTemplateData object
        List<leankor__KanbanCardTemplate__c> deafultTemplate = [Select Id
                                                                    From leankor__KanbanCardTemplate__c
                                                                    Where leankor__title__c = 'Default'
                                                                    Limit 1];
        CloneProjectPlanGanttBatch.KanbanCardTemplateData kanbanCardTemplateData = new CloneProjectPlanGanttBatch.KanbanCardTemplateData();
        kanbanCardTemplateData.templateIDs = new Map<String, String>();
        
        
        // Create mock BoardData
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.boardType = 'Kanban board';
        
        // Call the cloneBoardAdditionalInfo method
        Test.startTest();
        CloneProjectPlanGanttBatch.cloneBoardAdditionalInfo(boardData, deafultTemplate[0].id, kanbanCardTemplateData);
        Test.stopTest();
        
        // Verify that the new Project Board was updated with the correct fields
        List<leankor__ValueStream__c> updatednewValueStream = [Select leankor__OpportunityCardCategory__c,
                                                                        leankor__DefaultCategory__c
                                                                    From leankor__ValueStream__c
                                                                    Where Id = :newValueStream[0].Id];
        System.assertEquals(deafultTemplate[0].Id, updatednewValueStream[0].leankor__DefaultCategory__c, 'The DefaultCategory should be updated to Category 2.');
    }
    
    @isTest
    static void testCloneBoardAdditionalInfoWithoutSourcevalueStream() {
        // Fetch the Value Streams created in the test setup
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__ProjectBoardStartDateTime__c,
                                                                    leankor__ProjectBoardEndDateTime__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        // Create a mock KanbanCardTemplateData object
        List<leankor__KanbanCardTemplate__c> deafultTemplate = [Select Id
                                                                    From leankor__KanbanCardTemplate__c
                                                                    Where leankor__title__c = 'Default'
                                                                    Limit 1];
        CloneProjectPlanGanttBatch.KanbanCardTemplateData kanbanCardTemplateData = new CloneProjectPlanGanttBatch.KanbanCardTemplateData();
        kanbanCardTemplateData.templateIDs = new Map<String, String>();
        
        
        // Create mock BoardData
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.sourceValueStreamId = '';
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.boardType = 'Kanban board';
        
        // Call the cloneBoardAdditionalInfo method
        Test.startTest();
        CloneProjectPlanGanttBatch.cloneBoardAdditionalInfo(boardData, deafultTemplate[0].id, kanbanCardTemplateData);
        Test.stopTest();
        
        // Verify that the new Project Board was updated with the correct fields
        List<leankor__ValueStream__c> updatednewValueStream = [Select leankor__OpportunityCardCategory__c,
                                                                        leankor__DefaultCategory__c
                                                                    From leankor__ValueStream__c
                                                                    Where Id = :newValueStream[0].Id];
        System.assertEquals(null, updatednewValueStream[0].leankor__DefaultCategory__c, 'The DefaultCategory should be null');
    }
    
    // when boardType is not UberBoard and SavenDayWorkWeek is true and clone the Project to projectBoardLaunchDate
    @isTest
    static void createBoardDataTestWithWhiteBoardsavendayWeek() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,
                                                            Name,
                                                            IsDeleted,
                                                            OwnerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
            AND Name = 'Activity'];
        kanbanCards[0].leankor__DurationUnits__c = 'Weeks';
        kanbanCards[0].RecordType.Name = 'FolderCard';
        Update kanbanCards;
        
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Whiteboard';
        boardData.chartVerb = true;
        boardData.cloneCustomFields = false;
        boardData.projectBoardLaunchDate = JSON.serialize(System.now());
        boardData.isprojectclone = true;
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.newValueStreamRecord =newValueStream[0];
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        System.assertNotEquals(null, boardData, 'BoardData should not be null');
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'new ValueStreamId should match');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'Source ValueStreamId should match');
        System.assertEquals(kanbanCards[0].Id, boardData.linkCloneKanbanCardID, 'KanbanCardId should match');
        List<leankor__KanbanCard__c> clonedKanbanCards = [Select Id,
                                                                Name,
                                                                leankor__ValueStream__c
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :newValueStream[0].Id];
        
        System.assert(clonedKanbanCards.size() > 0, 'Kanban cards should have been cloned to the new ValueStream');
        System.assertEquals(kanbanCards.size(), clonedKanbanCards.size(), 'Number of cloned Kanban cards should match the original cards');
        
    }
    
    //when boardType is not UberBoard and SavenDayWorkWeek is false and clone the Project to projectBoardLaunchDate
    @isTest
    static void createBoardDataTestWithWhiteBoard() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        sourceValueStream[0].leankor__SevenDayWorkWeek__c = false;
        update sourceValueStream;
        
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,Name,
                                                            IsDeleted,
                                                            OwnerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
            AND Name = 'Activity'];
        kanbanCards[0].leankor__DurationUnits__c = 'Weeks';
        Update kanbanCards;
        
        List<leankor__ProjectBoardWorkFieldSet__c> clonedRecords = [Select Id,
                                                                            leankor__FieldSetName__c,
                                                                            leankor__ProjectBoard__c
                                                                        From leankor__ProjectBoardWorkFieldSet__c
                                                                        Where leankor__ProjectBoard__c = :sourceValueStream[0].Id
                                                                            And leankor__FieldSetName__c = 'leankor__leankorfieldset' ];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Whiteboard';
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.projectBoardLaunchDate = JSON.serialize(System.now());
        boardData.isprojectclone = true;
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.newValueStreamRecord =newValueStream[0];
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        System.assertNotEquals(null, boardData, 'BoardData should not be null');
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'new ValueStreamId should match');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'Source ValueStreamId should match');
        System.assertEquals(kanbanCards[0].Id, boardData.linkCloneKanbanCardID, 'KanbanCardId should match');
        List<leankor__KanbanCard__c> clonedKanbanCards = [Select Id,
                                                                Name,
                                                                leankor__ValueStream__c
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :newValueStream[0].Id];
        
        System.assert(clonedKanbanCards.size() > 0, 'Kanban cards should have been cloned to the new ValueStream');
        System.assertEquals(kanbanCards.size(), clonedKanbanCards.size(), 'Number of cloned Kanban cards should match the original cards');
        
    }
    
    // when boardType is not UberBoard and SavenDayWorkWeek is true and clone the Project to projectBoardLaunchDate and also ProjectBoardLaunchDateTime of vlaueStream is null
    @isTest
    static void createBoardDataTestwithValueStreamProjectLaunchDateNull() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board1'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,
                                                            Name,
                                                            IsDeleted,
                                                            OwnerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                            AND Name = 'Activity'];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Kanban Board';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData.cloneCustomFields = true;
        boardData.projectBoardLaunchDate = JSON.serialize(System.now());
        boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.newValueStreamRecord =newValueStream[0];
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        // Assertions to validate the outcomes
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'The source value stream Id should match.');
        System.assertEquals('Kanban Board', boardData.boardType, 'The board type should be Kanban Board.');
        System.assert(boardData.kanbanVerb, 'The kanbanVerb flag should be true.');
        System.assert(boardData.isprojectclone, 'The isprojectclone flag should be true.');
        System.assertNotEquals(null, boardData.projectBoardLaunchDate, 'The projectBoardLaunchDate should not be null.');
        System.assertNotEquals(null, boardData.finalDate, 'The finalDate should not be null.');
        System.assertNotEquals(null, boardData.oldStartDateTime, 'The oldStartDateTime should not be null.');
        System.assertNotEquals(null, boardData.oldEndDateTime, 'The oldEndDateTime should not be null.');
        
        // Validate Kanban card cloning
        System.assertNotEquals(null, boardData.linkCloneKanbanCardID, 'The cloned Kanban Card Id should not be null.');
        System.assertEquals(kanbanCards[0].Id, boardData.linkCloneKanbanCardID, 'The cloned Kanban Card Id should match the original.');
        
        // Ensure there are some Kanban cards to clone
        System.assert(kanbanCards.size() > 0, 'There should be at least one Kanban card in the source board.');
        
        
    }
    
    // when boardType is not UberBoard and SavenDayWorkWeek is true and clone the Project to finalStartDate
    @isTest
    static void createBoardDataTestWithWhiteBoardAndFinalStartDate() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                                leankor__TimeToLaunchMonth__c,
                                                                leankor__PriorityDescription__c,
                                                                leankor__IsCompletedOnTime__c,
                                                                leankor__Folder__c,
                                                                leankor__FinancialBudgetRemaining__c,
                                                                leankor__EffortRemainingTime__c,
                                                                leankor__CompletionVariance__c,
                                                                leankor__CardDetails__c,
                                                                leankor__BudgetTimeRemaining__c,
                                                                leankor__BudgetTimeComplete__c,
                                                                leankor__Actual_Time_Taken__c,
                                                                leankor__BoardType__c,
                                                                leankor__ActualDuration__c,
                                                                leankor__isRecordDeleted__c,
                                                                leankor__ZoneGUID__c,
                                                                leankor__Zone__c,
                                                                leankor__Y__c,
                                                                leankor__X__c,
                                                                leankor__ValueStream__c,
                                                                leankor__Width__c,
                                                                leankor__WeekCalendar__c,
                                                                leankor__Wednesday__c,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ValueStreamCardLink__c,
                                                                leankor__UrlLink__c,
                                                                leankor__Top__c,
                                                                leankor__Thursday__c,
                                                                leankor__Swimlane__c,
                                                                leankor__Sunday__c,
                                                                leankor__StartDateTime__c,
                                                                leankor__StartDate__c,
                                                                leankor__State__c,
                                                                leankor__Title__c,
                                                                leankor__Tuesday__c,
                                                                leankor__Monday__c,
                                                                leankor__KanbanCardTemplate__c,
                                                                leankor__JSONDefinition__c,
                                                                leankor__IsExternallyDependent__c,
                                                                leankor__DurationUnits__c,
                                                                leankor__DueDate__c,
                                                                leankor__EffortRemaining__c,
                                                                leankor__EstimatedDuration__c,
                                                                leankor__Friday__c,
                                                                leankor__Height__c,
                                                                leankor__IsAtRisk__c,
                                                                leankor__IsConstraintRecalculate__c,
                                                                leankor__IsSuccessorRecalculate__c,
                                                                leankor__JSONData__c,
                                                                leankor__IsOnHold__c,
                                                                leankor__HarveyBallDoneDate__c,
                                                                leankor__GUID__c,
                                                                leankor__OnTime__c,
                                                                leankor__Order__c,
                                                                leankor__Opportunity__c,
                                                                leankor__OnQuality__c,
                                                                (Select Id,
                                                                        leankor__ConstraintDateTime__c,
                                                                        leankor__ManuallyScheduled__c,
                                                                        leankor__Mode__c,
                                                                        leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                        leankor__EffortUnits__c,leankor__EffortActual__c
                                                                    From leankor__ScheduleModes__r
                                                                    Limit 1),
                                                                leankor__MasterContainer__c,
                                                                leankor__Left__c,
                                                                leankor__OnBudget__c,
                                                                leankor__PercentComplete2__c,
                                                                leankor__Priority__c,
                                                                leankor__PromiseCompletionDate__c,
                                                                leankor__Saturday__c,
                                                                leankor__Point__c,
                                                                LastModifiedDate,
                                                                SystemModstamp,
                                                                LastActivityDate,
                                                                leankor__CmpID__c,
                                                                leankor__Contact__c,
                                                                leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                                leankor__DueDateTime__c,
                                                                leankor__Description__c,
                                                                leankor__DescriptionLong__c,
                                                                leankor__DateColor__c,
                                                                leankor__Color__c,
                                                                leankor__Case__c,
                                                                leankor__CSSLayout__c,
                                                                leankor__Bottom__c,
                                                                leankor__Account__c,
                                                                leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                                leankor__AcceptanceCriteria__c,
                                                                LastReferencedDate,
                                                                LastViewedDate,
                                                                leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                                LastModifiedById,
                                                                Owner.IsActive ,
                                                                CreatedById,
                                                                CreatedDate,
                                                                RecordTypeId,
                                                                RecordType.Name,Name,
                                                                IsDeleted,
                                                                ownerId,
                                                                Id,
                                                                leankor__CostofCompletedWork__c,
                                                                leankor__Budgeted_Time__c,
                                                                leankor__OriginalFinancialBudget__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__WorkingDays__c,
                                                                leankor__SeriesNumber__c
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                                And Name = 'Activity'];
        kanbanCards[0].leankor__DurationUnits__c = 'years';
        Update kanbanCards;
        Test.startTest();
        
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Whiteboard';
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        //boardData.finalDate = JSON.serialize(System.now());
        boardData.isprojectclone = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData.newValueStreamRecord = newValueStream[0];
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        
        Test.stopTest();
        List<leankor__KanbanCard__c> clonedCards = [
                                                    Select Id, leankor__ValueStream__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :newValueStream];
        
        // Assert that the KanbanCard was cloned to the new ValueStream
        System.assertNotEquals(0, clonedCards.size(), 'KanbanCard should be cloned.');
        //System.assertEquals(newValueStream, clonedCards[0].leankor__ValueStream__c, 'Cloned KanbanCard should belong to the new ValueStream.');
        
        
    }
    
    // when boardType is not UberBoard and SavenDayWorkWeek is true and clone the Project to DueDate
    @isTest
    static void createBoardDataTestWithKanbanBoardAndDueDate() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,
                                                            Name,
                                                            IsDeleted,
                                                            ownerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                            And leankor__Title__c = 'Activity'];
        kanbanCards[0].leankor__DurationUnits__c = 'Years';
        // kanbanCards[0].RecordType.Name = 'MileStoneCard';
        Update kanbanCards;
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Kanban Board';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.finalDate = JSON.serialize(System.now().addDays(1));
        //boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData.newValueStreamRecord =newValueStream[0];
        boardData.workWeek = new Util.WorkWeek(1,5);
        
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        List<leankor__KanbanCard__c> clonedCards = [
                                                    Select Id, leankor__ValueStream__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :newValueStream];
        
        // Assert that the KanbanCard was cloned to the new ValueStream
        System.assertNotEquals(0, clonedCards.size(), 'KanbanCard should be cloned.');
        //System.assertEquals(newValueStream, clonedCards[0].leankor__ValueStream__c, 'Cloned KanbanCard should belong to the new ValueStream.');
        
        
    }
    
    @isTest
    public static void testSetValueStreamAndZoneDatawithBlankValueStream() {
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        
        
        List<leankor__ValueStream__c> newValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        List<leankor__Zone__c> tempZoneList = [Select Id From leankor__Zone__c Where leankor__ValueStream__c = :sourceValueStream[0].Id];
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = '_System_Board',
        leankor__ProjectRoom__c = null,
        leankor__BoardType__c = 'Kanban Board'
            );
        
        
        
        List<leankor__ValueStream__c> valueStreamRecord = new List<leankor__ValueStream__c>();
        valueStreamRecord.add(valueStream);
        insert valueStreamRecord;
        
        Test.startTest();
        
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = '';
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='Kanban Board';
        boardData.chartVerb = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        // Call the method under test
        CloneProjectPlanGanttBatch.ValueStreamData result = leankor.CloneProjectPlanGanttBatch.setValueStreamAndZoneData(boardData, tempZoneList, sourceValueStream);
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'ValueStreamData should not be null');
        // System.assertEquals(0, result.valueStreamRecord.size(), 'ValueStreamRecord should contain one record');
    }
    @isTest
    static void testCloneDependency() {
        // Step 1: Create necessary mock data (ValueStreams and Dependencies)
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        leankor__kanbanCard__c kanbanCard1 = [Select id
                                                From leankor__kanbanCard__c
                                                Where leankor__Title__c = 'Kanban Card 1'];
        leankor__kanbanCard__c kanbanCard2 = [Select id
                                                From leankor__kanbanCard__c
                                                Where leankor__Title__c = 'Kanban Card 1'];
        
        
        // Step 2: Prepare BoardData object
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType = 'Whiteboard';
        boardData.chartVerb = true;
        boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.projectBoardLaunchDate = JSON.serialize(System.now());
        boardData.kanbanCardOldAndnewIdMap = new Map<String, String>{ kanbanCard1.Id => kanbanCard2.Id };
        boardData.workWeek = new Util.WorkWeek(1,5);
        
        // Step 3: Start test and call cloneDependency
        Test.startTest();
        leankor.CloneProjectPlanGanttBatch.cloneDependency(boardData);
        Test.stopTest();
        
        List<leankor__Dependency__c> clonedDependencies = [Select Id
                                                            From leankor__Dependency__c
                                                            Where leankor__KanbanCard__c = :kanbanCard2.Id];
        
        // Step 5: Assert that dependencies were cloned
        System.assertEquals(0, clonedDependencies.size(), 'Expected one cloned dependency.');
        
    }
    @isTest
    static void testCloneSticker() {
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        List<leankor__kanbancard__C> kanbanCardList = [Select Id,
                                                                leankor__EstimatedDuration__c,
                                                                leankor__StartDatetime__c,
                                                                leankor__DueDatetime__c,
                                                                leankor__GUID__c,
                                                                leankor__valuestream__c
                                                            From leankor__kanbanCard__c];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        CloneProjectPlanGanttBatch.cloneStickers(boardData);
        Test.stopTest();
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'The source value stream Id should match.');
        System.assertEquals(true, boardData.stickerVerb, 'The stickerVerb flag should be true.');
        System.assertEquals(true, boardData.kanbanVerb, 'The kanbanVerb flag should be true.');
        System.assertEquals(true, boardData.taskVerb, 'The taskVerb flag should be true.');
        System.assertNotEquals(null, boardData.finalStartDate, 'The finalStartDate should not be null.');
        System.assertNotEquals(null, boardData.oldStartDateTime, 'The oldStartDateTime should not be null.');
        System.assertNotEquals(null, boardData.oldEndDateTime, 'The oldEndDateTime should not be null.');
        
        // Ensure there are some Kanban cards to clone stickers for
        System.assert(kanbanCardList.size() > 0, 'There should be at least one Kanban card in the source value stream.');
        
    }
    
    @isTest
    static void testCloneMarkers() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        CloneProjectPlanGanttBatch.cloneMarkers(boardData);
        Test.stopTest();
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'The source value stream Id should match.');
    }
    
    @isTest
    static void testCloneMarkers1() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData1 = new CloneProjectPlanGanttBatch.BoardData();
        boardData1.newValueStreamId = newValueStream[0].Id;
        boardData1.sourceValueStreamId = sourceValueStream[0].Id;
        boardData1.boardType ='DashBoard';
        boardData1.markerVerb = true;
        CloneProjectPlanGanttBatch.cloneMarkers(boardData1);
        Test.stopTest();
        System.assertEquals(newValueStream[0].Id, boardData1.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData1.sourceValueStreamId, 'The source value stream Id should match.');
    }
    
    @isTest
    static void testCloneCharts() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        List < leankor__Chart__c > chartList = new List < leankor__Chart__c > ();
        leankor__Chart__c chart = new leankor__Chart__c();
        chart.Name = 'Budget vs Actual Variance Report';
        chart.leankor__ChartURL__c = '/apex/leankor__VisualReport?dnm=00Od0000005BOwOEAW&sz=tiny';
        chart.leankor__DeveloperName__c = 'Budget';
        chart.leankor__ReportId__c = '123' ;
        chart.leankor__ValueStream__c = sourceValueStream[0].Id;
        chart.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        chartList.add(chart);
        insert chartList;
        
        Test.startTest();
        
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='DashBoard';
        boardData.chartVerb = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        
        CloneProjectPlanGanttBatch.BoardData boardData1 = new CloneProjectPlanGanttBatch.BoardData();
        boardData1.newValueStreamId = newValueStream[0].Id;
        boardData1.sourceValueStreamId = sourceValueStream[0].Id;
        boardData1.kanbanVerb = true;
        boardData1.boardType ='Plan Board';
        boardData1.chartVerb = true;
        boardData1.finalStartDate = JSON.serialize(System.now());
        boardData1.oldStartDateTime = System.now();
        boardData1.oldEndDateTime = System.now();
        
        
        //CloneProjectPlanGanttBatch.cloneCharts(boardData);
        CloneProjectPlanGanttBatch.cloneCharts(boardData1);
        
        Test.stopTest();
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'The source value stream Id should match.');
        
    }
    
    
    @isTest
    static void testCloneFiles() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board' limit 1];
    // Create lists to hold Kanban cards
        List<leankor__KanbanCard__c> oldKanbanCards = new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> newKanbanCards = new List<leankor__KanbanCard__c>();
        
        // Create old Kanban cards
        for (Integer i = 0; i < 4; i++) {
            leankor__KanbanCard__c oldKanbanCard = new leankor__KanbanCard__c(
                leankor__Title__c = 'Old Kanban Card ' + (i + 1),
            leankor__GUID__c = ResourceGanttController.createGuid().replace('-', ''),
            leankor__ValueStream__c = sourceValueStream[0].id
                );
            oldKanbanCards.add(oldKanbanCard);
        }
        insert oldKanbanCards;
        
        
        // Create new Kanban cards
        for (Integer i = 0; i < 4; i++) {
            leankor__KanbanCard__c newKanbanCard = new leankor__KanbanCard__c(
                leankor__Title__c = 'new Kanban Card ' + (i + 1),
            leankor__GUID__c = ResourceGanttController.createGuid().replace('-', ''),
            leankor__ValueStream__c = newValueStream[0].id
                );
            newKanbanCards.add(newKanbanCard);
        }
        insert newKanbanCards;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
            );
        insert contentVersion;
        
        List<FeedItem> feedItems = new List<FeedItem>();
        
        for (Integer i = 0; i < 3; i++) {
            FeedItem feedItem = new FeedItem(
                parentId = oldKanbanCards[0].id,
            Body = 'Body',
            relatedRecordId = contentVersion.id);
            feedItems.add(feedItem);
        }
        insert feedItems;
        
        // Create a map of old Kanban card IDs to new Kanban card IDs
        Map<String, String> mapWithOldKanbanCard = new Map<String, String>();
        for (Integer i = 0; i < oldKanbanCards.size(); i++) {
            mapWithOldKanbanCard.put(oldKanbanCards[i].Id, newKanbanCards[i].Id);
        }
        
        
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.cloneFiles = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.kanbanCardOldAndnewIdMap = new Map<String, String>{sourceValueStream[0].Id => newValueStream[0].Id};
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        CloneProjectPlanGanttBatch.cloneFiles(boardData,mapWithOldKanbanCard);
        Test.stopTest();
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'The new value stream Id should match.');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'The source value stream Id should match.');
        System.assertEquals(true, boardData.markerVerb, 'The markerVerb flag should be true.');
        System.assertEquals(true, boardData.kanbanVerb, 'The kanbanVerb flag should be true.');
        System.assertEquals(true, boardData.taskVerb, 'The taskVerb flag should be true.');
        System.assertEquals(true, boardData.stickerVerb, 'The stickerVerb flag should be true.');
        System.assertNotEquals(null, boardData.finalStartDate, 'The finalStartDate should not be null.');
        System.assertNotEquals(null, boardData.oldStartDateTime, 'The oldStartDateTime should not be null.');
        System.assertNotEquals(null, boardData.oldEndDateTime, 'The oldEndDateTime should not be null.');
    }
    
    @isTest
    static void testUpdateProjectBoardStartAndEnddate() {
        Integer firstDayOfWeek = 1;
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
        List<DateTime> dateList = new List<DateTime>{
            DateTime.now().addDays(-3),
            DateTime.now().addDays(-2),
            DateTime.now().addDays(-1)
        };
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__ScheduleBackward__c,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        sourceValueStream[0].leankor__ScheduleBackward__c = true;
        Update sourceValueStream;
        List<leankor__ValueStream__c> newValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.cloneFiles = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        // realtimeController.ALLOW_SCHEDULING_CONSTRAINTS = true;
        String finalStartDate = JSON.serialize(DateTime.now().addDays(-5));
        
        //cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(boardData);
        
        cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(sourceValueStream[0].Id,newValueStream[0].Id,DateTime.now().addDays(-10),DateTime.now().addDays(10),workWeek,dateList,DateTime.now().addDays(-8),DateTime.now().addDays(8),finalStartDate,null);
        Test.stopTest();
        leankor__ValueStream__c updatedValueStream = [Select Id, 
                                                                leankor__ProjectBoardStartDateTime__c, 
                                                                leankor__ProjectBoardEndDateTime__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :newValueStream[0].Id
                                                            Limit 1];
        
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardStartDateTime__c, null, 'Start date should not be null.');
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardEndDateTime__c, null, 'End date should not  null.');
    }
    
    @isTest
    static void testUpdateProjectBoardStartAndEnddateFinalStartDateNull() {
        Integer firstDayOfWeek = 1;
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
        List<DateTime> dateList = new List<DateTime>{
            DateTime.now().addDays(-3),
            DateTime.now().addDays(-2),
            DateTime.now().addDays(-1)
        };
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        sourceValueStream[0].leankor__ScheduleBackward__c = true;
        List<leankor__ValueStream__c> newValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.cloneFiles = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        // realtimeController.ALLOW_SCHEDULING_CONSTRAINTS = true;
        String finalDate = JSON.serialize(DateTime.now().addDays(-5));
        
        //cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(boardData);
        
        cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(sourceValueStream[0].Id,newValueStream[0].Id,DateTime.now().addDays(-10),DateTime.now().addDays(10),workWeek,dateList,DateTime.now().addDays(-8),DateTime.now().addDays(8),null,finalDate);
        Test.stopTest();
        
        leankor__ValueStream__c updatedValueStream = [Select Id, 
                                                                leankor__ProjectBoardStartDateTime__c,
                                                                leankor__ProjectBoardEndDateTime__c
                                                            From leankor__ValueStream__c
                                                            Where Id = :newValueStream[0].Id
                                                            Limit 1];
        
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardStartDateTime__c, null, 'Project Board Start Date should not be null.');
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardEndDateTime__c, null, 'Project Board End Date should not be null.');
    }
    
    @isTest
    static void testUpdateProjectBoardStartAndEnddateWithNullDates() {
        Integer firstDayOfWeek = 1;
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
        List<DateTime> dateList = new List<DateTime>{
            DateTime.now().addDays(-3),
            DateTime.now().addDays(-2),
            DateTime.now().addDays(-1)
        };
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        
        update sourceValueStream;
        List<leankor__ValueStream__c> newValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='kanban Board';
        boardData.chartVerb = true;
        boardData.cloneFiles = true;
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        // realtimeController.ALLOW_SCHEDULING_CONSTRAINTS = true;
        
        //cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(boardData);
        
        cloneProjectPlanGanttBatch.updateProjectBoardStartAndEnddate(sourceValueStream[0].Id,newValueStream[0].Id,DateTime.now().addDays(-10),DateTime.now().addDays(10),workWeek,dateList,DateTime.now().addDays(-8),DateTime.now().addDays(8),null,null);
        Test.stopTest();
        leankor__ValueStream__c updatedValueStream = [Select Id, 
                                                                leankor__ProjectBoardStartDateTime__c, 
                                                                leankor__ProjectBoardEndDateTime__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :newValueStream[0].Id
            Limit 1];
        
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardStartDateTime__c, null, 'Start date should not null.');
        System.assertNotEquals(updatedValueStream.leankor__ProjectBoardEndDateTime__c, null, 'End date should  not null.');
    }
    
    @isTest
    static void testGetMaxDateOfBoard() {
        leankor__ProjectRoom__c project = [Select  Id, Name
                                                From leankor__ProjectRoom__c ];
        
        Test.startTest();
        Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> maxDate  = cloneProjectPlanGanttBatch.getMaxDateOfBoard(project.id);
        Test.stopTest();
        System.assertNotEquals(null, maxDate, 'Max date should not be null');
        
        
    }
    
    @isTest
    static void createBoardDataTestWithPlanBoardsavendayWeek() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,Name,
                                                            IsDeleted,
                                                            OwnerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                            AND Name = 'Activity'];
        
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='UberBoard';
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.projectBoardLaunchDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.newValueStreamRecord =newValueStream[0];
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        System.assertNotEquals(null, boardData, 'BoardData should not be null');
        System.assertEquals(newValueStream[0].Id, boardData.newValueStreamId, 'new ValueStreamId should match');
        System.assertEquals(sourceValueStream[0].Id, boardData.sourceValueStreamId, 'Source ValueStreamId should match');
        System.assertEquals(kanbanCards[0].Id, boardData.linkCloneKanbanCardID, 'KanbanCardId should match');
        List<leankor__KanbanCard__c> clonedKanbanCards = [Select Id,
                                                                Name,
                                                                leankor__ValueStream__c
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :newValueStream[0].Id];
        
        System.assert(clonedKanbanCards.size() > 0, 'Kanban cards should have been cloned to the new ValueStream');
        System.assertEquals(kanbanCards.size(), clonedKanbanCards.size(), 'Number of cloned Kanban cards should match the original cards');
        
    }
    
    
    @isTest
    static void createBoardDataTestWithPlanBoardAndFinalStartDate() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,
                                                                    leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,Name,
                                                            IsDeleted,
                                                            ownerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                        AND Name = 'Activity'];
        // kanbanCards[0].RecordType.Name = 'MileStoneCard';
        kanbanCards[0].leankor__DurationUnits__c = 'Months';
        Update kanbanCards;
        
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='UberBoard';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        // boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData.newValueStreamRecord =newValueStream[0];
        
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        List<leankor__KanbanCard__c> clonedCards = [
                                                    Select Id, leankor__ValueStream__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :newValueStream];
        
        // Assert that the KanbanCard was cloned to the new ValueStream
        System.assertNotEquals(0, clonedCards.size(), 'KanbanCard should be cloned.');
        //System.assertEquals(newValueStream, clonedCards[0].leankor__ValueStream__c, 'Cloned KanbanCard should belong to the new ValueStream.');
        
        
    }
    
    
    @isTest
    static void createBoardDataTestWithPlanBoardAndDueDate() {
        List<leankor__ValueStream__c> sourceValueStream = [Select Id,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__TaskDateCheck__c,
                                                                    leankor__ProjectRoom__c,
                                                                    leankor__ProjectBoardLaunchDateTime__c,
                                                                    leankor__ValueStreamLink__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ValueStreamLink__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        
        
        List<leankor__KanbanCard__c> kanbanCards = [Select  leankor__UncompletedPoints__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__TimeToProjectLaunch__c,
                                                            leankor__TimeToLaunchMonth__c,
                                                            leankor__PriorityDescription__c,
                                                            leankor__IsCompletedOnTime__c,
                                                            leankor__Folder__c,
                                                            leankor__FinancialBudgetRemaining__c,
                                                            leankor__EffortRemainingTime__c,
                                                            leankor__CompletionVariance__c,
                                                            leankor__CardDetails__c,
                                                            leankor__BudgetTimeRemaining__c,
                                                            leankor__BudgetTimeComplete__c,
                                                            leankor__Actual_Time_Taken__c,
                                                            leankor__BoardType__c,
                                                            leankor__ActualDuration__c,
                                                            leankor__isRecordDeleted__c,
                                                            leankor__ZoneGUID__c,
                                                            leankor__Zone__c,
                                                            leankor__Y__c,
                                                            leankor__X__c,
                                                            leankor__ValueStream__c,
                                                            leankor__Width__c,
                                                            leankor__WeekCalendar__c,
                                                            leankor__Wednesday__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__UrlLink__c,
                                                            leankor__Top__c,
                                                            leankor__Thursday__c,
                                                            leankor__Swimlane__c,
                                                            leankor__Sunday__c,
                                                            leankor__StartDateTime__c,
                                                            leankor__StartDate__c,
                                                            leankor__State__c,
                                                            leankor__Title__c,
                                                            leankor__Tuesday__c,
                                                            leankor__Monday__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__JSONDefinition__c,
                                                            leankor__IsExternallyDependent__c,
                                                            leankor__DurationUnits__c,
                                                            leankor__DueDate__c,
                                                            leankor__EffortRemaining__c,
                                                            leankor__EstimatedDuration__c,
                                                            leankor__Friday__c,
                                                            leankor__Height__c,
                                                            leankor__IsAtRisk__c,
                                                            leankor__IsConstraintRecalculate__c,
                                                            leankor__IsSuccessorRecalculate__c,
                                                            leankor__JSONData__c,
                                                            leankor__IsOnHold__c,
                                                            leankor__HarveyBallDoneDate__c,
                                                            leankor__GUID__c,
                                                            leankor__OnTime__c,
                                                            leankor__Order__c,
                                                            leankor__Opportunity__c,
                                                            leankor__OnQuality__c,
                                                            (Select Id,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__Mode__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                    leankor__EffortUnits__c,leankor__EffortActual__c
                                                                From leankor__ScheduleModes__r
                                                                Limit 1),
                                                            leankor__MasterContainer__c,
                                                            leankor__Left__c,
                                                            leankor__OnBudget__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__Priority__c,
                                                            leankor__PromiseCompletionDate__c,
                                                            leankor__Saturday__c,
                                                            leankor__Point__c,
                                                            LastModifiedDate,
                                                            SystemModstamp,
                                                            LastActivityDate,
                                                            leankor__CmpID__c,
                                                            leankor__Contact__c,
                                                            leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__DueDateTime__c,
                                                            leankor__Description__c,
                                                            leankor__DescriptionLong__c,
                                                            leankor__DateColor__c,
                                                            leankor__Color__c,
                                                            leankor__Case__c,
                                                            leankor__CSSLayout__c,
                                                            leankor__Bottom__c,
                                                            leankor__Account__c,
                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                            leankor__AcceptanceCriteria__c,
                                                            LastReferencedDate,
                                                            LastViewedDate,
                                                            leankor__CardID__c,leankor__ValueStream__r.leankor__BoardType__c,
                                                            LastModifiedById,
                                                            Owner.IsActive ,
                                                            CreatedById,
                                                            CreatedDate,
                                                            RecordTypeId,
                                                            RecordType.Name,Name,
                                                            IsDeleted,
                                                            ownerId,
                                                            Id,
                                                            leankor__CostofCompletedWork__c,
                                                            leankor__Budgeted_Time__c,
                                                            leankor__OriginalFinancialBudget__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__WorkingDays__c,
                                                            leankor__SeriesNumber__c
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :sourceValueStream[0].Id
                                                            And leankor__Title__c = 'Activity'];
        kanbanCards[0].leankor__DurationUnits__c = 'Months';
        kanbanCards[0].RecordType.Name = 'MileStoneCard';
        Update kanbanCards;
        Test.startTest();
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType ='UberBoard';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.finalDate = JSON.serialize(System.now().addDays(1));
        //boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        boardData.linkCloneVSID = sourceValueStream[0].Id;
        boardData.linkCloneKanbanCardID = kanbanCards[0].Id;
        boardData.newValueStreamRecord =newValueStream[0];
        boardData.workWeek = new Util.WorkWeek(1,5);
        
        boardData = leankor.CloneProjectPlanGanttBatch.createBoardData(boardData);
        CloneProjectPlanGanttBatch.cloneKanbanCards(boardData, kanbanCards);
        Test.stopTest();
        List<leankor__KanbanCard__c> clonedCards = [
                                                    Select Id, leankor__ValueStream__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c = :newValueStream];
        
        // Assert that the KanbanCard was cloned to the new ValueStream
        System.assertNotEquals(0, clonedCards.size(), 'KanbanCard should be cloned.');
        //System.assertEquals(newValueStream, clonedCards[0].leankor__ValueStream__c, 'Cloned KanbanCard should belong to the new ValueStream.');
        
        
    }
    
    @isTest
    static void testProcessAfterBoardCloningDone() {
        
        leankor__Portfolio__c cloneFolder = new leankor__Portfolio__c(Name = 'CloneFolder');
        insert cloneFolder;
        
        leankor__ProjectRoom__c cloneProject = new leankor__projectRoom__c(name = 'cloneRoom',leankor__DueDate__c = System.today());
        insert cloneProject;
        
        List<leankor__Portfolio__c> queriedFolder = [Select Id,
                                                        Name
                                                    From leankor__Portfolio__c
                                                    Limit 1 ];
        
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        List<leankor__ValueStream__c> newValueStream = [Select Id ,leankor__SevenDayWorkWeek__c
                                                        From leankor__ValueStream__c
                                                        Where Name = 'new Project Board'
                                                        Limit 1];
        
        
        CloneProjectProcessAction.CloneProjectRequest requestInstance;
        
        leankor__ProjectRoom__c sourceProject = [Select  Id,
                                                        Name
                                                    From leankor__ProjectRoom__c
                                                    Where Name = 'testRoom'];
        System.assertNotEquals(null, sourceProject, 'sourceProject should not be null');
        
        
        
        // Mocking the Clone Request
        CloneProjectBoardBatch.CloneProjectBoardRequest mockCloneRequest = new CloneProjectBoardBatch.CloneProjectBoardRequest();
        mockCloneRequest.relinkClonedProjectId = cloneProject.id;
        mockCloneRequest.projectBoardTypes = new List<String>{'UberBoard'};
        mockCloneRequest.totalCardsOfSourceProjectBoards = 0;
        mockCloneRequest.totalNumberOfSourceProjectBoards = 1;
        mockCloneRequest.projectEventCustomPayload = 'TestPayload';
        mockCloneRequest.targetFolderId = cloneFolder.Id;
        
        List<RecordType> recordTypeList = [Select Id,
                                                    Name,
                                                    SobjectType
                                                From RecordType
                                                Where SobjectType = 'leankor__Expense__c'];
        leankor__Expense__c sampleExpensesCost = new leankor__Expense__c
            (
            Name = 'CloneExpenceOne',
        // leankor__Portfolio__c = queriedFolder[0].Id,
        leankor__Project__c =cloneProject.Id,
        leankor__Date__c = System.today(),
        leankor__ExpenseAmount__c = 100.0,
        RecordTypeId  = recordTypeList[0].Id
            );
        insert sampleExpensesCost;
        
        Test.startTest();
        // Mocking the Board Data
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType = 'Kanban Board';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        CloneProjectPlanGanttBatch cloneProjectPlanGanttBatch = new CloneProjectPlanGanttBatch(mockCloneRequest,sourceValueStream[0],requestInstance);
        
        // Properly calling the method with the boardData object
        cloneProjectPlanGanttBatch.processAfterBoardCloningDone(boardData);
        
        Test.stopTest();
        List<leankor__ValueStream__c> clonedValueStream = [Select Id From leankor__ValueStream__c Where Id = :boardData.newValueStreamId];
        System.assertEquals(1, clonedValueStream.size(), 'new ValueStream should exist after cloning.');
        
    }
    
    @isTest
    static void testCloneProjectWithValidData() {
        leankor__Portfolio__c sourceFolder = [Select Id,
                                                        Name
                                                    From leankor__Portfolio__c
                                                    Where Name = 'TestFolder' ];
        
        leankor__Portfolio__c targetFolder = [Select Id,
                                                        Name
                                                    From leankor__Portfolio__c
                                                    Where Name = 'TestFolder' ];
        
        leankor__ProjectRoom__c sourceProject = [Select Id,
                                                        Name
                                                    From leankor__ProjectRoom__c ];
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'Source Project Board'
                                                                Limit 1];
            
        List<leankor__ValueStream__c> newValueStream = [Select Id ,
                                                                leankor__SevenDayWorkWeek__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'new Project Board'
                                                            Limit 1];
        List<String> boardTypes = new List<String>();
        boardTypes.add('Kanban Board');
        boardTypes.add('Whiteboard');
        boardTypes.add('DashBoard');
        //boardTypes.add('plan Board');
        // Create the CloneProjectRequest object
        CloneProjectProcessAction.CloneProjectRequest request = new CloneProjectProcessAction.CloneProjectRequest();
        request.sourceFolderId = sourceFolder.Id;
        request.sourceFolderName = SourceFolder.Name;
        request.sourceProjectId = sourceProject.Id;
        request.sourceProjectName = sourceProject.Name;
        request.targetFolderId = TargetFolder.Id;
        request.targetFolderName = TargetFolder.Name;
        request.targetProjectName = 'Clone One';
        request.targetProjectStartDateTime =System.now();
        request.targetProjectDueDateTime = System.now();
        request.planGantt = true;
        request.rollUp = true;
        request.projectBoard = true;
        request.whiteBoard = true;
        request.dashBoard=true;
        request.expenses=true;
        request.returnPortfolioHierarchy = true;
        request.projectBoardTypes = boardTypes;
        request.relinkClonedProjectId = '';
        
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType = 'Kanban Board';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        
        // Execute the cloneProjects method
        Test.startTest();
        CloneProjectProcessAction.cloneProjects(new List<CloneProjectProcessAction.CloneProjectRequest>{request});
        Test.stopTest();
        // Add assertions to validate the results
        leankor__ProjectRoom__c clonedProject = [Select Id, Name
                                                From leankor__ProjectRoom__c
                                                Where Name = 'Clone One'
                                                Limit 1];
        System.assertNotEquals(clonedProject, null, 'Cloned project not found.');
        System.assertEquals(clonedProject.Name, 'Clone One', 'Cloned project name does not match expected value.');
    }
    
    @isTest
    static void testCloneProjectsProcess() {
        leankor__Portfolio__c sourceFolder = [Select Id,
                                                    Name
                                                From leankor__Portfolio__c
                                                Where Name = 'TestFolder' ];
        
        leankor__Portfolio__c targetFolder = [Select Id,
                                                    Name
                                                From leankor__Portfolio__c
                                                Where Name = 'TestFolder' ];
        
        
        
        leankor__ProjectRoom__c sourceProject = [Select  Id,
                                                         Name
                                                    From leankor__ProjectRoom__c ];
        
        List<leankor__ValueStream__c> sourceValueStream = [Select Id ,
                                                                    leankor__SevenDayWorkWeek__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c
                                                            From leankor__ValueStream__c
                                                            Where Name = 'Source Project Board'
                                                            Limit 1];
        sourceValueStream[0].leankor__SevenDayWorkWeek__c = false;
        update sourceValueStream;
        
        List<leankor__ValueStream__c> newValueStream = [Select Id ,
                                                            leankor__SevenDayWorkWeek__c
                                                    From leankor__ValueStream__c
                                                    Where Name = 'new Project Board'
                                                    Limit 1];
        newValueStream[0].leankor__SevenDayWorkWeek__c = false;
        update newValueStream;
        
        
        
        List<String> boardTypes = new List<String>();
        boardTypes.add('Kanban Board');
        boardTypes.add('Whiteboard');
        boardTypes.add('DashBoard');
        CloneProjectProcessAction.CloneProjectRequest request = new CloneProjectProcessAction.CloneProjectRequest();
        request.sourceFolderId = sourceFolder.Id;
        request.sourceFolderName = SourceFolder.Name;
        request.sourceProjectId = sourceProject.Id;
        request.sourceProjectName = sourceProject.Name;
        request.targetFolderId = TargetFolder.Id;
        request.targetFolderName = TargetFolder.Name;
        request.targetProjectName = 'Clone One';
        //request.targetProjectStartDateTime =System.now();
        request.targetProjectDueDateTime = System.now();
        request.planGantt = true;
        request.rollUp = true;
        request.projectBoard = true;
        request.whiteBoard = true;
        request.dashBoard=true;
        request.expenses=true;
        request.returnPortfolioHierarchy = true;
        request.projectBoardTypes = boardTypes;
        request.relinkClonedProjectId = '';
        
        CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
        boardData.newValueStreamId = newValueStream[0].Id;
        boardData.sourceValueStreamId = sourceValueStream[0].Id;
        boardData.kanbanVerb = true;
        boardData.kanbanTemplateVerb = true;
        boardData.stickerVerb = true;
        boardData.taskVerb = true;
        boardData.zoneVerb = true;
        boardData.markerVerb = true;
        boardData.boardType = 'Kanban Board';
        boardData.isprojectclone = true;
        boardData.chartVerb = true;
        boardData.cloneCustomFields = true;
        boardData.finalDate = JSON.serialize(System.now());
        boardData.finalStartDate = JSON.serialize(System.now());
        boardData.oldStartDateTime = System.now();
        boardData.oldEndDateTime = System.now();
        
        // Execute the cloneProjects method
        Test.startTest();
        System.debug('request'+request);
        CloneProjectProcessAction.cloneProjects(new List<CloneProjectProcessAction.CloneProjectRequest>{request});
        leankor__ProjectRoom__c clonedProject = [Select Id, 
                                                        Name
                                                    From leankor__ProjectRoom__c
                                                    Limit 1];
        System.assertNotEquals(clonedProject, null, 'Cloned project not found.');
        System.assertEquals(clonedProject.Name, 'testRoom', 'Cloned project name does not match expected value.');
    }
    
    
}