@isTest
private class StickerTest {
	private static final String BOARD_TYPE = 'Kanban Board';
	
    @testSetup 
    static void setupTestData() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;
        String stickerId = createTestStickerRecord('Sticker', valueStreamId).Id;
        createTestAttachmentRecord('Attachment', stickerId);
	}

    
    private static Attachment createTestAttachmentRecord(String nameInput, String parentId) {
        Attachment stickerAttachment = new Attachment();
        stickerAttachment.ParentId = parentId;
        stickerAttachment.Name = nameInput;
        stickerAttachment.Body = Blob.valueOf('An attachment');
        insert stickerAttachment;
        return stickerAttachment;
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
	    
    
	private static leankor__Sticker__c createTestStickerRecord(String nameInput, String valueStreamId) {
		leankor__Sticker__c testSticker = new leankor__Sticker__c();
        testSticker.Name = nameInput;
        testSticker.leankor__ValueStream__c = valueStreamId;
        insert testSticker;
        return testSticker;
    }


	private static List<leankor__Sticker__c> readTestStickerRecord() {
        return [Select Id,
                    Name,
                    leankor__ValueStream__c
            	From leankor__Sticker__c];
 	}


    private static List<leankor__ValueStream__c> readTestValueStreamRecord() {
        return [Select Id,
                    Name
            	From leankor__ValueStream__c];
 	}


    @isTest 
    static void createStickersTest() {        
        List<leankor__Sticker__c> stickerRecords = new List<leankor__Sticker__c>();
        leankor__Sticker__c stickerRecord = new leankor__Sticker__c();
        stickerRecord.Name = 'Test Sticker';
        stickerRecords.add(stickerRecord);

        Test.startTest();        
        List<leankor__Sticker__c> createStickers = Sticker.createStickers(stickerRecords);        
        Test.stopTest();
        System.assert(createStickers.size() > 0);
    }


    @isTest 
    static void readStickersByValueStreamTest() {
        Test.startTest();
        List<leankor__Sticker__c> readStickers = Sticker.readStickers(readTestValueStreamRecord());
        System.assert(readStickers.size() > 0);

        Test.stopTest();
    }


    @isTest 
    static void readStickersByStickerTest() {
        Test.startTest();        
        List<leankor__Sticker__c> readStickers = Sticker.readStickers(readTestStickerRecord());
        Test.stopTest();

        System.assert(readStickers.size() > 0);
    }
}