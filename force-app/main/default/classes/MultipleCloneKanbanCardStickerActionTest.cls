@isTest
private class MultipleCloneKanbanCardStickerActionTest {
	
	private static final String BOARD_TYPE = 'Kanban Board';
	@testSetup static void setupTestData() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;
		String kanbanCardId = createTestKanbanCardRecord('Card', valueStreamId).Id;
        String stickerId = createTestStickerRecord('Sticker', valueStreamId).Id;
        createTestKanbanCardStickerRecord(kanbanCardId, stickerId);
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

	private static leankor__Sticker__c createTestStickerRecord(String nameInput, String valueStreamId) {
		leankor__Sticker__c testSticker = new leankor__Sticker__c();
        testSticker.Name = nameInput;
        testSticker.leankor__ValueStream__c = valueStreamId;
        insert testSticker;
        return testSticker;
    }

	private static leankor__KanbanCardSticker__c createTestKanbanCardStickerRecord(String kanbanCardId, String stickerId) {
		leankor__KanbanCardSticker__c testKanbanCardSticker = new leankor__KanbanCardSticker__c();
		testKanbanCardSticker.leankor__KanbanCard__c = kanbanCardId;
        testKanbanCardSticker.leankor__Sticker__c = stickerId;
		insert testKanbanCardSticker;
		return testKanbanCardSticker;
	}

	private static List<leankor__KanbanCard__c> readTestKanbanCardRecord() {
		return [Select Id,
                    leankor__GUID__c
            	From leankor__KanbanCard__c];
	}

    @isTest static void cloneKanbanCardStickersTest() {
        Test.startTest();
		
		List<leankor__KanbanCard__c> kanbanCards =	readTestKanbanCardRecord();
		List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest> requests =  
			new List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest>();
		MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest request = 
    		new MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest();

		request.kanbanCardRequest = kanbanCards;
		requests.add(request);

		List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerResult> results = 
    		new List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerResult>();

		results = MultipleCloneKanbanCardStickerAction.cloneKanbanCardStickerProcess(requests);
		System.debug('results ---> ' + results);  

        System.assert(results.size() > 0);
        
        Test.stopTest(); 
    }
}