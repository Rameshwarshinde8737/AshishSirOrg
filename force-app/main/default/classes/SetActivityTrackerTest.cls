@isTest
private class SetActivityTrackerTest {
	
	@testSetup static void setupTestData()
	{
		final String ACTIVITY_VERB = 'CreateKanbanCard';
		final String BOARD_TYPE = 'Kanban Board';
		final Id USER_ID = UserInfo.getUserId();
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;
		String kanbanCardId = createTestKanbanCardRecord('Card', valueStreamId).Id;
        String activityTrackerRecordId = createTestActivityTrackerRecord(USER_ID, System.now(), ACTIVITY_VERB, valueStreamId, kanbanCardId, 'Test Detail').Id;
      	createTestRealTimeTrackerRecord(valueStreamId, kanbanCardId, ACTIVITY_VERB, USER_ID);
	}

	private static leankor__Portfolio__c createTestFolderRecord(String nameInput) {
		leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
		testFolder.Name = nameInput;
		insert testFolder;
		return testFolder;
	}

	private static leankor__ProjectRoom__c createTestProjectRecord(String nameInput, String folderId) {
		leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
		testProject.Name = nameInput;
		testProject.leankor__Portfolio__c = folderId;
		insert testProject;
		return testProject;
	}

	private static leankor__ValueStream__c createTestValueStreamRecord(String nameInput, String projectRoomId, String boardType) {
		leankor__ValueStream__c testValueStream = new leankor__ValueStream__c();
		testValueStream.Name = nameInput;
		testValueStream.leankor__ProjectRoom__c = projectRoomId;
		testValueStream.leankor__BoardType__c = boardType;
		insert testValueStream;
		return testValueStream;
	}
	
	private static leankor__KanbanCard__c createTestKanbanCardRecord(String nameInput, String valueStreamId) {
		leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c();
		testKanbanCard.Name = nameInput;
		testKanbanCard.leankor__DurationUnits__c = 'Days';
		testKanbanCard.leankor__EstimatedDuration__c = 1;
		testKanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
		testKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
		testKanbanCard.leankor__ValueStream__c = valueStreamId;
		testKanbanCard.leankor__isRecordDeleted__c = false;
		insert testKanbanCard;
		return testKanbanCard;
	}

	private static void createTestRealTimeTrackerRecord(String valueStreamId, String kanbanCardId, String activityVerb, String userId) {
		List<String> jsonData = new List<String>();
        RealTimeController.Kanban remoteKanban = new RealTimeController.Kanban();
		remoteKanban.ValueStream = valueStreamId;
		remoteKanban.Id = kanbanCardId;
		remoteKanban.Name = 'Name';        	
		remoteKanban.Title = 'Title';        	
		jsonData.add(JSON.serialize(remoteKanban));
		GenericStreamingController.createRealtimeTracker(valueStreamId, activityVerb, jsonData, userId);
	}

	private static leankor__ActivityTracker__c createTestActivityTrackerRecord(String activitySource, DateTime activityDateTime, String activityVerb, String valueStreamId, string kanbanCardId, String activityDetail) {
		leankor__ActivityTracker__c testActivityTracker = new leankor__ActivityTracker__c();
        testActivityTracker.leankor__ActivitySource__c = activitySource;
        testActivityTracker.leankor__ActivityDateTime__c = activityDateTime;
        testActivityTracker.leankor__ActivityVerb__c = activityVerb;
        testActivityTracker.leankor__ValueStream__c = valueStreamId;
        testActivityTracker.leankor__KanbanCard__c = kanbanCardId;
        testActivityTracker.leankor__ActivityDetail__c = activityDetail;
        insert testActivityTracker;
		return testActivityTracker;
	}

	private static List<leankor__ActivityTracker__c> readTestActivityTrackerRecord() {
        return [Select Id,
                    leankor__ActivitySource__c ,
                    leankor__ActivityDateTime__c,
                    leankor__ActivityVerb__c,
                    leankor__ValueStream__c,
                    leankor__KanbanCard__c,
                    leankor__ActivityDetail__c 
                From leankor__ActivityTracker__c];
	}

	private static List<leankor__RealTimeTracker__c> readTestRealTimeTrackerRecord() {
		return [Select Id,
            		CreatedById,
            		CreatedDate,
            		CreatedBy.Name,
            		leankor__KanbanVerb__c,
            		leankor__ValueStream__c,
            		leankor__ValueStream__r.Name,
					leankor__ValueStream__r.leankor__BoardType__c,
					leankor__ActivityTracked__c,
            		leankor__JSONDataSmall__c,
            		leankor__JSONDataSmall2__c,
            		leankor__JSONDataSmall3__c,
            		leankor__JSONDataSmall4__c,
            		leankor__JSONDataSmall5__c,
            		leankor__JSONDataSmall6__c,
            		leankor__JSONDataSmall7__c,
            		leankor__JSONDataSmall8__c
            	From leankor__RealtimeTracker__c
            	Where leankor__ActivityTracked__c = false
            	Order By CreatedDate Desc];
	}

	private static Set<Id> readKanbanCardIds(List<leankor__ActivityTracker__c> activityTrackers) {
        Set<Id> kanbanCardIds = new Set<Id>();
		for (leankor__ActivityTracker__c activityTracker : activityTrackers) {
			kanbanCardIds.add(activityTracker.leankor__KanbanCard__c);
		}
		return kanbanCardIds;
	}

    @isTest static void setActivityTrackerRecordTest1() {
        Test.startTest();

        List<leankor__ActivityTracker__c> activityTrackers = readTestActivityTrackerRecord();
		List<leankor__RealTimeTracker__c> realTimeTrackers = readTestRealTimeTrackerRecord();
        Set<Id> kanbanCardIds = readKanbanCardIds(activityTrackers);

        // test method
		SetActivityTracker setActivityTracker = new SetActivityTracker();
        setActivityTracker.setActivityTrackerRecord(kanbanCardIds, activityTrackers, realTimeTrackers);
        System.assert(kanbanCardIds.size() == realTimeTrackers.size());

        // test schedule
        ScheduleSetActivityTracker tracking = new ScheduleSetActivityTracker(); 
        tracking.execute(null);
        
        Test.stopTest(); 
    }

    @isTest static void setActivityTrackerRecordTest2() {
        Test.startTest();

        List<leankor__ActivityTracker__c> activityTrackers = readTestActivityTrackerRecord();
        Set<Id> kanbanCardIds = readKanbanCardIds(activityTrackers);

        // test method
		SetActivityTracker setActivityTracker = new SetActivityTracker();
        setActivityTracker.setActivityTrackerRecord(kanbanCardIds, activityTrackers);
        System.assert(kanbanCardIds.size() == activityTrackers.size());

        // test schedule
        ScheduleSetActivityTracker tracking = new ScheduleSetActivityTracker(); 
        tracking.execute(null);
        
        Test.stopTest(); 
    }

	@isTest static void getActivityFieldTest() {
		SetActivityTracker setActivityTracker = new SetActivityTracker();
		String expected = 'Title';
		String actual = setActivityTracker.getActivityField('Name');
		System.assert(expected == actual);
	}
}