@isTest
private class MultipleAddKanbanCardStickerActionTest {

    private final static Integer MAXIMUM_RECORD_SIZE = 10000;

    @testSetup 
    static void setupTestData() {
        String projectRoomId = createTestProjectRecord('Project', createTestFolderRecord('Folder').Id).id;
        String valueStreamId = createTestValueStreamRecord('Kanban', projectRoomId, 'Kanban Board').Id;
        createTestKanbanCardRecord('Card', valueStreamId);
        createTestStickerRecord('Sticker', valueStreamId);
    }


    @isTest 
    static void testAddKanbanCardStickerProcess() {
        List<leankor__KanbanCard__c> kanbanCards =	readTestKanbanCardRecord();
        List<leankor__Sticker__c> stickers = readTestStickerRecord();

		List<MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest> requests =  new List<MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest>();
        MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request = new MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest();

        request.kanbanCardRequest = kanbanCards;
        request.stickerRequest = stickers;
        requests.add(request);
        
        Test.startTest();
        MultipleAddKanbanCardStickerAction.addKanbanCardStickerProcess(requests);

        // Here we focus on ensuring that the queueable job is processed correctly.
        System.assertEquals(1, Limits.getQueueableJobs(), 'Expected one queueable job to be enqueued.');
        Test.stopTest();
    }


    @isTest
    static void testMaximumRecordSizeExceeded() {
        Integer recordSize = MAXIMUM_RECORD_SIZE + 1;

        // Create request exceeding MAXIMUM_RECORD_SIZE        
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        for (Integer i = 0; i < recordSize; i++) {
            kanbanCards.add(new leankor__KanbanCard__c(Name = 'CardExtra' + i));
        }

        List<leankor__Sticker__c> stickers = new List<leankor__Sticker__c>();
        for (Integer i = 0; i < 1; i++) {
            stickers.add(new leankor__Sticker__c(Name = 'StickerExtra' + i));
        }

		List<MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest> requests =  new List<MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest>();
        MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request = new MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest();

        request.kanbanCardRequest = kanbanCards;
        request.stickerRequest = stickers;
        requests.add(request);

        Test.startTest();
        try {
            MultipleAddKanbanCardStickerAction.addKanbanCardStickerProcess(requests);
            System.assert(false, 'Expected an exception due to maximum record size exceeded');
        } catch (Util.LeanException ex) {
            System.assertEquals('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.', ex.getMessage());
        }
        Test.stopTest();
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


	private static List<leankor__KanbanCard__c> createTestKanbanCardRecord(String nameInput, String valueStreamId) {
		List<leankor__KanbanCard__c> testKanbanCards = new List<leankor__KanbanCard__c>();

        for (Integer i = 0; i < 1000; i++) {
            testKanbanCards.add(new leankor__KanbanCard__c(Name = nameInput + i, leankor__ValueStream__c = valueStreamId, leankor__GUID__c = UUID.randomUUID().toString()));
        }

		insert testKanbanCards;
		return testKanbanCards;
    }
    

	private static List<leankor__Sticker__c> createTestStickerRecord(String nameInput, String valueStreamId) {
		List<leankor__Sticker__c> testStickers = new List<leankor__Sticker__c>();

        for (Integer i = 0; i < 10; i++) {
            testStickers.add(new leankor__Sticker__c(Name = nameInput + i, leankor__ValueStream__c = valueStreamId));
        }

        insert testStickers;
        return testStickers;
    }    


	private static List<leankor__KanbanCard__c> readTestKanbanCardRecord() {
		return [Select Id
            	    From leankor__KanbanCard__c];
    }
    
    
	private static List<leankor__Sticker__c> readTestStickerRecord() {
		return [Select Id
            	    From leankor__Sticker__c];
    }
}