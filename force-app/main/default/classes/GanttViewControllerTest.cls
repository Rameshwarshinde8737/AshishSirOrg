@IsTest
private class GanttViewControllerTest {
    
    @TestSetup
    static void setupTestData(){
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Value Stream';
        valueStream.leankor__BoardType__c = 'UberBoard';
        insert valueStream;
        
        Profile profile = [Select Id 
                           		From Profile 
                           		Where Name = 'System Administrator' 
                           		Limit 1];

        User testUser = new User();
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
		testUser.Email = 'testuser@example.com';
        testUser.Username = 'testuser@example.com' + System.currentTimeMillis();
        testUser.Alias = 'testusr';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        kanbanCard.OwnerId = testUser.Id;
        kanbanCard.leankor__isRecordDeleted__c = false;
        insert kanbanCard;

        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
        resourceAssignment.leankor__KanbanCard__c = kanbanCard.Id;
        resourceAssignment.leankor__AssignedTo__c = testUser.Id;
        insert resourceAssignment;

        Task testTask = new Task();
        testTask.Subject = 'Test Task';
        testTask.OwnerId = testUser.Id;
        testTask.WhatId = kanbanCard.Id;
        insert testTask;
        
        leankor__Sticker__c sticker = new leankor__Sticker__c(
            Name = 'Test Sticker ' + System.currentTimeMillis(),
            leankor__ValueStream__c = valueStream.Id
        );
        insert sticker;
        
        Attachment attach = new Attachment();
        attach.ParentId = sticker.Id;
        attach.Name = 'Test Attachment';
        attach.Body = Blob.valueOf('Sample Attachment Body');
        insert attach;
        
        leankor__KanbanCardSticker__c kanbanCardSticker = new leankor__KanbanCardSticker__c();
        kanbanCardSticker.leankor__KanbanCard__c = kanbanCard.Id;
        kanbanCardSticker.leankor__Sticker__c = sticker.Id;
        insert kanbanCardSticker;
        
        leankor__KanbanCardTemplate__c templateA = new leankor__KanbanCardTemplate__c();
        templateA.leankor__ValueStream__c = valueStream.Id;
        templateA.Name = 'Template A';
        leankor__KanbanCardTemplate__c templateB = new leankor__KanbanCardTemplate__c();
        templateB.leankor__ValueStream__c = valueStream.Id;
        templateB.Name = 'Template B';
        insert new List<leankor__KanbanCardTemplate__c>{ templateA, templateB };

    }
    
    @IsTest
    static void standardControllerConstructorTest() {
        Account acct = new Account();
        acct.Name = 'Test Account ' + System.currentTimeMillis();
        insert acct;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(acct);
        
        GanttViewController controllerStd = new GanttViewController(stdController);
        System.assertNotEquals(null, controllerStd, 'Controller instance should not be null using StandardController constructor.');
    }
    
    @IsTest
    static void utilConstructorTest() {
        Util dummyUtil = new Util();
        
        GanttViewController controllerUtil = new GanttViewController(dummyUtil);
        System.assertNotEquals(null, controllerUtil, 'Controller instance should not be null using Util constructor.');
    }
    
	@IsTest
    static void calendarViewTest() {
        GanttViewController controller = new GanttViewController();
        
        PageReference result = controller.Calendar_View();
        
        System.assertNotEquals(result, null, 'PageReference should not be null');
        System.assertEquals(result.getUrl(), '/apex/leankor__Test_Page', 'PageReference URL should match expected value');
        System.assertEquals(result.getRedirect(), false, 'Redirect should be false');
    }
    
    @IsTest
    static void readColumnsDataTest() {
        leankor__ValueStream__c testValueStream = [Select Id 
                                                   		From leankor__ValueStream__c 
                                                   		Limit 1];
       
        GanttViewController.PlanGanttRequest request = new GanttViewController.PlanGanttRequest();
        request.valueStreamId = testValueStream.Id;
        request.readRelatedCount = true;
        request.readStickers = true;
        request.fieldsToQuery = new List<String>{'Id', 'Name'};

        Test.startTest();
        GanttViewController.PlanGanttResult result = GanttViewController.readColumnsData(request);
        Test.stopTest();

        System.assert(result != null, 'Result should not be null');
		System.assert(result.kanbanCardData != null, 'Kanban card data should not be null');
        System.assertEquals(1, result.kanbanCardData.size(), 'Kanban card data should contain 1 records');

        GanttViewController.PlanGanttRequest invalidRequest = new GanttViewController.PlanGanttRequest();
        invalidRequest.valueStreamId = 'InvalidId';

        try {
            GanttViewController.readColumnsData(invalidRequest);
            System.assert(false, 'Expected an exception for invalid input');
        } catch (Util.LeanException e) {
            System.assert(e.getMessage().contains('Error: Invalid input'), 'Exception should indicate invalid input');
        }
    }
    
    @IsTest
    static void readPlanGanttInfo_ValidInputTest() {
        leankor__ValueStream__c testValueStream = [Select Id 
                                                   		From leankor__ValueStream__c 
                                                   		Limit 1];

        GanttViewController.PlanGanttRequestInfo request = new GanttViewController.PlanGanttRequestInfo();
        request.valueStreamId = testValueStream.Id;

        Test.startTest();
        GanttViewController.PlanGanttInfo result = GanttViewController.readPlanGanttInfo(request);
        Test.stopTest();
        
        System.assert(result != null, 'Result should not be null');
        System.assert(result.baseURL != null, 'Base URL should not be null');
        System.assert(result.userLog != null, 'User log should not be null');
        System.assert(result.filters != null, 'Filters should not be null');
        System.assert(result.filterUserRecords != null, 'Filtered user records should not be null');
        System.assert(result.isServiceAppointmentEnable != null, 'Service appointment flag should not be null');
        System.assert(result.isFieldExist != null, 'Field existence flag should not be null');
        System.assert(result.orgBaseURL != null, 'Org base URL should not be null');
    }
    
    @IsTest
    static void readPlanGanttInfo_InvalidInputTest() {
        GanttViewController.PlanGanttRequestInfo request = new GanttViewController.PlanGanttRequestInfo();
        request.valueStreamId = 'InvalidId';

        try {
            Test.startTest();
            GanttViewController.PlanGanttInfo result = GanttViewController.readPlanGanttInfo(request);
            Test.stopTest();
            System.assert(false, 'Method should have thrown an exception');
        } catch (Util.LeanException e) {
            System.assertEquals('Error: Invalid input', e.getMessage(), 'Expected error message did not match');
        }
    }
    
    @IsTest
    static void getUserLogTest() {
        User testUser = [Select Id 
                         	From User 
                         	Where Email 
                         	Like 'testuser@example.com%' 
                         	Limit 1];

        System.runAs(testUser) {
            Test.startTest();
            User result = GanttViewController.getUserLog();
            Test.stopTest();

            System.assert(result != null, 'User result should not be null');
            System.assertEquals(testUser.Id, result.Id, 'User ID should match the logged-in user');
            System.assert(result.LocaleSidKey != null, 'LocaleSidKey should not be null');
            System.assert(result.Name != null, 'User Name should not be null');
            System.assert(result.SmallPhotoUrl != null, 'SmallPhotoUrl should not be null');
        }
    }
    
    @IsTest
    static void getFilteredUsersTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                               		From leankor__ValueStream__c 
                                               		Limit 1];

        Test.startTest();
        List<User> filteredUsers = GanttViewController.getFilteredUsers(valueStream.Id);
        Test.stopTest();

        System.assert(filteredUsers != null, 'Filtered Users list should not be null');
        System.assert(filteredUsers.size() > 0, 'There should be at least one filtered user');
        System.assert(filteredUsers[0].Id != null, 'User ID should not be null');
    }
    
    @IsTest
    static void readKanbanCardStickersTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                               		From leankor__ValueStream__c 
                                               		Limit 1];
        
        leankor__KanbanCard__c kanbanCard = [Select Id 
                                       			From leankor__KanbanCard__c 
                                       			Where leankor__ValueStream__c = :valueStream.Id 
                                       			Limit 1];
        
        Map<Id, List<leankor__Sticker__c>> result = GanttViewController.readKanbanCardStickers(new List<Id>{ valueStream.Id }, new List<Id>());
        
        System.assert(result.containsKey(kanbanCard.Id), 'The returned map should contain the KanbanCard Id as a key.');
                      
        List<leankor__Sticker__c> stickers = result.get(kanbanCard.Id);
        
        System.assertEquals(1, stickers.size(), 'There should be exactly one sticker returned for the KanbanCard.');
        
        for (leankor__Sticker__c st : stickers) {
            System.assertNotEquals(null, st.Attachments, 'Sticker should have an Attachments collection.');
            System.assert(st.Attachments.size() > 0, 'Sticker should have at least one attachment.');
        }
    }
    
    @IsTest
    static void getKanbanCardTemplates_WithTemplateTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                               		From leankor__ValueStream__c 
                                               		Limit 1];
        
        Test.startTest();
        leankor__KanbanCardTemplate__c result = GanttViewController.getKanbanCardTemplates(valueStream.Id);
        Test.stopTest();
        
        System.assert(result != null, 'Expected a KanbanCardTemplate record, but got null.');
        System.assertEquals('Template A', result.Name, 'Expected Template A to be returned after sorting.');
    }
    
    @IsTest
    static void readStickerData_BothBranchesTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                      				From leankor__ValueStream__c 
                                      				Limit 1];
        leankor__KanbanCard__c card = [Select Id 
                                       		From leankor__KanbanCard__c 
                                       		Where leankor__ValueStream__c = :valueStream.Id 
                                       		Limit 1];
        
        String vsId = valueStream.Id;
        List<String> kanbanCardIds = new List<String>{ card.Id };
        
        Test.startTest();
        GanttViewController.StickerData result = GanttViewController.readStickerData(vsId, kanbanCardIds);
        Test.stopTest();
        
        System.assert(result.allStickers != null, 'Expected allStickers to be populated when valueStreamId is not null.');
        System.assert(result.allStickers.size() > 0, 'Expected at least one sticker in allStickers.');
        System.assert(result.kanbanCardStickers != null, 'Expected kanbanCardStickers to be populated when kanbanCardIds is not empty.');
        System.assert(result.kanbanCardStickers.containsKey(card.Id), 'Expected the kanban card Id to be a key in kanbanCardStickers.');
        System.assert(result.kanbanCardStickers.get(card.Id).size() > 0, 'Expected at least one sticker linked to the kanban card.');
    }
    
    @IsTest
    static void getAllStickers_ValidValueStreamTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Limit 1];
        
        Test.startTest();
        List<leankor__Sticker__c> results = GanttViewController.getAllStickers(valueStream.Id);
        Test.stopTest();
        
        List<Id> stickerIds = new List<Id>();
        for (leankor__Sticker__c st : results) {
            stickerIds.add(st.Id);
        }
        List<leankor__Sticker__c> stickersWithField = [Select Id, 
                                                                leankor__ValueStream__c 
                                                            From leankor__Sticker__c 
                                                            Where Id In :stickerIds];

        Map<Id, leankor__Sticker__c> stickerMap = new Map<Id, leankor__Sticker__c>(stickersWithField);
        
        System.assertNotEquals(0, results.size(), 'Expected at least one sticker for the given ValueStream.');
        for (leankor__Sticker__c sticker : results) {
            System.assert(sticker.Attachments != null && sticker.Attachments.size() > 0, 'Each sticker should have at least one attachment.');
            
            leankor__Sticker__c fullSticker = stickerMap.get(sticker.Id);
            if (fullSticker.leankor__ValueStream__c != null) {
                System.assertEquals(valueStream.Id, fullSticker.leankor__ValueStream__c,  'Sticker should be associated with the given ValueStream.');
            }
        }
    }
    
    @IsTest
    static void createRealtimeTrackerForHistoryTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                      				From leankor__ValueStream__c 
                                      				Limit 1];
        
        List<GanttViewController.RealTimeTrackerInfomation> trackerInfos = new List<GanttViewController.RealTimeTrackerInfomation>();
        
        GanttViewController.RealTimeTrackerInfomation info1 = new GanttViewController.RealTimeTrackerInfomation();
        info1.valueStreamId = valueStream.Id;
        info1.verb = 'Create';
        info1.clientSessionId = 'Session123';
        trackerInfos.add(info1);
        
        Test.startTest();
        GanttViewController.createRealtimeTrackerForHistory(trackerInfos);
        Test.stopTest();
        
        leankor__RealtimeTracker__c trackers = [Select Id, 
                                                            leankor__KanbanVerb__c, 
                                                            leankor__SessionID__c, 
                                                            leankor__ValueStream__c 
                                                        From leankor__RealtimeTracker__c 
                                                        Where leankor__SessionID__c = 'Session123'
                                                        Limit 1];
        
        System.assertEquals('Create', trackers.leankor__KanbanVerb__c, 'Tracker verb should be "Create".');
		System.assertEquals(valueStream.Id, trackers.leankor__ValueStream__c, 'Tracker valueStream should match the inserted record.');
    }
    
}