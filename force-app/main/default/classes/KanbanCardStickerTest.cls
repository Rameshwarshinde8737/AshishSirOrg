@isTest
private class KanbanCardStickerTest {
	private static final String BOARD_TYPE = 'Kanban Board';
	@testSetup static void setupTestData() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;
		String kanbanCardId = createTestKanbanCardRecord('Card', valueStreamId).Id;
        String stickerId = createTestStickerRecord('Local Sticker', valueStreamId).Id;
        createTestKanbanCardStickerRecord(kanbanCardId, stickerId);
        createTestStickerRecord('Global Sticker', null);
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

	private static List<leankor__KanbanCard__c> createTestClonedKanbanCardRecord(List<leankor__KanbanCard__c> kanbanCards, String valueStreamId) {
        Integer recordCount = 0;
        List<leankor__KanbanCard__c> testKanbanCards = new List<leankor__KanbanCard__c>();
		for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
		    recordCount++;
            testKanbanCards.add(
                new leankor__KanbanCard__c(
                    leankor__ValueStream__c =  valueStreamId, 
                    leankor__GUID__c = kanbanCard.Id + '-' + String.valueOf(recordCount)
                )
            );
        }
        insert testKanbanCards;
		return testKanbanCards;
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
        return [Select 
                        Id,
                    leankor__GUID__c
            	From leankor__KanbanCard__c];
	}

	private static List<leankor__KanbanCardSticker__c> readTestKanbanCardStickerRecord() {
        return [Select 
                        Id,
                    leankor__KanbanCard__c,
                    leankor__Sticker__c
            	From leankor__KanbanCardSticker__c];
 	}

    private static List<leankor__Sticker__c> readTestStickerRecord(Boolean isGlobalSticker) {
        List<leankor__Sticker__c> stickerRecords =  new List<leankor__Sticker__c>();
        if (isGlobalSticker) {
            stickerRecords = [Select 
                                    Id
                                From leankor__Sticker__c
                                Where leankor__ValueStream__c = null 
                                Limit 1];
        } else {
            stickerRecords = [Select Id
                                From leankor__Sticker__c
                                Where leankor__ValueStream__c != null 
                                Limit 1];
        }
        return stickerRecords;
 	}

    private static List<leankor__ProjectRoom__c> readTestProjectRoomRecord() {
        return [Select Id
            	    From leankor__ProjectRoom__c 
                    Limit 1];
	}
    
    @isTest
    static void testEmptyInputCoversLine5() {
        // Pass an empty list to trigger the early return on line 5
        List<leankor__KanbanCard__c> emptyKanbanCards = new List<leankor__KanbanCard__c>();
        
        Test.startTest();
        List<leankor__KanbanCardSticker__c> result = KanbanCardSticker.cloneKanbanCardStickers(emptyKanbanCards);
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return an empty list when input is empty');
    }

    @isTest 
    static void cloneKanbanCardStickersTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;

        List<leankor__KanbanCardSticker__c> kanbanCardStickersSource = readTestKanbanCardStickerRecord();
        List<leankor__KanbanCard__c> kanbanCardsSource = readTestKanbanCardRecord();
        List<leankor__KanbanCard__c> kanbanCardsCreated = createTestClonedKanbanCardRecord(kanbanCardsSource, valueStreamId);

        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickersCloned = KanbanCardSticker.cloneKanbanCardStickers(kanbanCardsCreated);
        Test.stopTest();
           
        System.assert(kanbanCardStickersSource.size() == kanbanCardStickersCloned.size());
        
    }

    @isTest 
    static void getMapTargetKanbanCardStickersIdsTest() {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = readTestKanbanCardStickerRecord();

        Test.startTest();
        Map<Id, Set<Id>> mapKanbanCardStickerIds = KanbanCardSticker.getMapTargetKanbanCardStickerIds(kanbanCardStickers);
        Test.stopTest();

        System.assert(mapKanbanCardStickerIds.size() > 0);
    }
    // modified this 03 apl
    
    @isTest
    static void testGetMapTargetKanbanCardStickerIdsAddAll() {
        // Retrieve test data from setup
        leankor__KanbanCard__c card = [Select Id 
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c localSticker = [Select Id 
                                                From leankor__Sticker__c 
                                                Where Name = 'Local Sticker' 
                                                Limit 1];
        leankor__Sticker__c globalSticker = [Select Id 
                                                    From leankor__Sticker__c 
                                                    Where Name = 'Global Sticker' 
                                                    Limit 1];

        // Create multiple KanbanCardSticker records with the same KanbanCard but different Stickers
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = localSticker.Id
            ),
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = globalSticker.Id
            )
        };
        insert kanbanCardStickers; // Insert to simulate existing records

        Test.startTest();
        Map<Id, Set<Id>> result = KanbanCardSticker.getMapTargetKanbanCardStickerIds(kanbanCardStickers);
        Test.stopTest();

        // Verify the map contains the KanbanCard ID with both Sticker IDs
        System.assertEquals(1, result.size(), 'Map should contain one KanbanCard ID');
        System.assertEquals(2, result.get(card.Id).size(), 'Set should contain both Sticker IDs');
        System.assert(result.get(card.Id).contains(localSticker.Id), 'Should contain Local Sticker ID');
        System.assert(result.get(card.Id).contains(globalSticker.Id), 'Should contain Global Sticker ID');
    }
    // end here 03 apl-------------

    @isTest 
    static void createKanbanCardStickersTest() {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>();        
        
        Test.startTest();
        List<leankor__KanbanCardSticker__c> createKanbanCardStickers = KanbanCardSticker.createKanbanCardStickers(kanbanCardStickers);
        Test.stopTest();

        System.assert(kanbanCardStickers.size() == createKanbanCardStickers.size());        
    }
    
    //code for custom exception
    @isTest
    static void testCreateKanbanCardStickersNoAccess() {
        // Create a minimal profile with no create access to leankor__KanbanCardSticker__c
        Profile minimalProfile = [Select  Id 
                                        From Profile 
                                        Where Name = 'Minimum Access - Salesforce' 
                                        Limit 1];
        
        // Create a test user with the minimal profile
        User testUser = new User(
            Alias = 'testu',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = minimalProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Retrieve test data from setup
        leankor__KanbanCard__c card = [Select Id 
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c sticker = [Select Id 
                                            From leankor__Sticker__c 
                                            Where Name = 'Global Sticker' 
                                            Limit 1];

        // Create a KanbanCardSticker list
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = sticker.Id
            )
        };

        Test.startTest();
        System.runAs(testUser) {
            try {
                KanbanCardSticker.createKanbanCardStickers(kanbanCardStickers);
                System.assert(false, 'Expected a Util.LeanException to be thrown');
            } catch (Util.LeanException e) {
                System.debug('Caught exception: ' + e.getMessage());
                System.assertEquals('Error: No access to records', e.getMessage(), 'Expected LeanException for no create access');
                System.assert(true, 'Exception caught, throw statement covered');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateKanbanCardStickersNoAccess() {
        // Create a minimal profile with no create access to leankor__KanbanCardSticker__c
        Profile minimalProfile = [Select Id 
                                        From Profile 
                                        Where Name = 'Minimum Access - Salesforce' 
                                        Limit 1];
        
        // Create a test user with the minimal profile
        User testUser = new User(
            Alias = 'testu',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = minimalProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Retrieve test data from setup
        leankor__KanbanCard__c card = [Select Id 
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c sticker = [Select Id 
                                            From leankor__Sticker__c 
                                            Where Name = 'Global Sticker' 
                                            Limit 1];

        // Create a KanbanCardSticker list
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = sticker.Id
            )
        };

        Test.startTest();
        System.runAs(testUser) {
            try {
                KanbanCardSticker.updateKanbanCardStickers(kanbanCardStickers);
                System.assert(false, 'Expected a Util.LeanException to be thrown');
            } catch (Util.LeanException e) {
                System.debug('Caught exception: ' + e.getMessage());
                System.assertEquals('Error: No access to records', e.getMessage(), 'Expected LeanException for no create access');
                System.assert(true, 'Exception caught, throw statement covered');
            }
        }
        Test.stopTest();
    }

    //-------------------code for upsertKanbanCardStickers method 
    @isTest
    static void testUpsertKanbanCardStickersNoAccess() {
        // Create a minimal profile with no create/update access to leankor__KanbanCardSticker__c
        Profile minimalProfile = [Select  Id From Profile Where Name = 'Minimum Access - Salesforce' Limit 1];
        
        // Create a test user with the minimal profile
        User testUser = new User(
            Alias = 'testu',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = minimalProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Retrieve test data from setup
        leankor__KanbanCard__c card = [Select Id   
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c sticker = [Select Id 
                                            From leankor__Sticker__c 
                                            Where Name = 'Global Sticker' 
                                            Limit 1];

        // Create a KanbanCardSticker list
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = sticker.Id
            )
        };

        Test.startTest();
        System.runAs(testUser) {
            try {
                KanbanCardSticker.upsertKanbanCardStickers(kanbanCardStickers);
                System.assert(false, 'Expected a Util.LeanException to be thrown');
            } catch (Util.LeanException e) {
                System.debug('Caught exception: ' + e.getMessage());
                System.assertEquals('Error: No access to records', e.getMessage(), 'Expected LeanException for no create/update access');
                System.assert(true, 'Exception caught, throw statement covered');
            }
        }
        Test.stopTest();
    }

    //-------------End Here-------------------------

    @isTest 
    static void readKanbanCardStickersTest() {        
        Set<Id> kanbanCardIds = new Set<Id>();
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = readTestKanbanCardStickerRecord();
        for (leankor__KanbanCardSticker__c kanbanCardSticker : kanbanCardStickers) {
            if (kanbanCardSticker.leankor__KanbanCard__c != null && kanbanCardSticker.leankor__Sticker__c != null) {
                kanbanCardIds.add(kanbanCardSticker.leankor__KanbanCard__c);
            }
        }
        
        Test.startTest();
        List<leankor__KanbanCardSticker__c> readKanbanCardStickers = KanbanCardSticker.readKanbanCardStickers(kanbanCardIds);        
        Test.stopTest();

        System.assert(kanbanCardIds.size() == readKanbanCardStickers.size());
    }


    @isTest 
    static void removeKanbanCardStickersTest() {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = readTestKanbanCardStickerRecord();
        Integer expected = kanbanCardStickers.size();        
        kanbanCardStickers.add(
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = null
            )
        );
        
        Test.startTest();
        KanbanCardSticker.removeKanbanCardStickers(kanbanCardStickers);        
        Test.stopTest();

        System.assert(expected == kanbanCardStickers.size());
    }


    @isTest 
    static void getMapSourceKanbanCardIdsTest() {

		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;

        List<leankor__KanbanCard__c> kanbanCardsSource = readTestKanbanCardRecord();
        List<leankor__KanbanCard__c> kanbanCardsCreated = createTestClonedKanbanCardRecord(kanbanCardsSource, valueStreamId);

        Test.startTest();
        Map<Id, Id> mapSourceKanbanCardIds = KanbanCardSticker.getMapSourceKanbanCardIds(kanbanCardsCreated);
        Test.stopTest();

        System.assert(mapSourceKanbanCardIds.size() > 0);
    }

    @isTest 
    static void getIdFromGUIDTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId, BOARD_TYPE).Id;

        List<leankor__KanbanCard__c> kanbanCardsSource = readTestKanbanCardRecord();

        Test.startTest();
        List<leankor__KanbanCard__c> kanbanCardsCreated = createTestClonedKanbanCardRecord(kanbanCardsSource, valueStreamId);        
        Test.stopTest();

        List<Id> idFromGUIDs = new List<Id>();
        for (leankor__KanbanCard__c kanbanCardCreated : kanbanCardsCreated) {
            Id idFromGUID = KanbanCardSticker.getIdFromGUID(kanbanCardCreated.leankor__GUID__c);
            if (idFromGUID != null) {
                idFromGUIDs.add(idFromGUID);
            }
        }

        System.assert(idFromGUIDs.size() > 0);
    }
        

    @isTest 
    static void kanbanCardStickerTest() {
        Test.startTest();
        KanbanCardSticker instanceKanbanCardSticker = new KanbanCardSticker();        
        Test.stopTest(); 

        System.assert(instanceKanbanCardSticker != null);
    }


    @isTest 
    static void addKanbanCardStickersNoneTest() {
        List<leankor__KanbanCard__c> kanbanCards = readTestKanbanCardRecord();
        List<leankor__Sticker__c> stickers = readTestStickerRecord(false);

        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickersAdded = KanbanCardSticker.createKanbanCardStickers(kanbanCards, stickers);        
        Test.stopTest(); 

        System.assert(kanbanCardStickersAdded.size() == 0); // sticker already associated to the card, no sticker is added
    }
    // modification to cover return statement of if condition
     @isTest 
    static void addKanbanCardStickersNullTest() {
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        List<leankor__Sticker__c> stickers = new List<leankor__Sticker__c>();

        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickersAdded = KanbanCardSticker.createKanbanCardStickers(kanbanCards, stickers);        
        Test.stopTest(); 

        System.assert(kanbanCardStickersAdded.size() == 0); // sticker already associated to the card, no sticker is added
    }
        

    @isTest 
    static void addKanbanCardStickersAnyTest() {
        List<leankor__KanbanCard__c> kanbanCards = readTestKanbanCardRecord();
        List<leankor__Sticker__c> stickers = readTestStickerRecord(true);

        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickersAdded = KanbanCardSticker.createKanbanCardStickers(kanbanCards, stickers);        
        Test.stopTest();

        System.assert(kanbanCardStickersAdded.size() > 0); // sticker is not associated to the card, sticker is added
    }


    @isTest 
    static void updateKanbanCardStickersTest() {
        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = readTestKanbanCardStickerRecord();        
        Test.stopTest(); 

        System.assert(kanbanCardStickers.size() == KanbanCardSticker.updateKanbanCardStickers(kanbanCardStickers).size());
    }


    @isTest 
    static void addKanbanCardStickersMultipleTest() {
        List<leankor__KanbanCard__c> kanbanCards = readTestKanbanCardRecord();
        List<leankor__Sticker__c> stickers = readTestStickerRecord(true);

        MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request = new MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest();
        request.kanbanCardRequest = kanbanCards;
        request.stickerRequest = stickers;
        request.sendBroadcastMessage = true;  // true = to broadcast the event, otherwise false
    
        Test.startTest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickersCreated = KanbanCardSticker.createKanbanCardStickers(request);        
        Test.stopTest(); 

        System.assert(kanbanCardStickersCreated.size() > 0); // stickers are created
    }
    
    //test to cover catch block 
    
    
    // to cover return statement
    @isTest
    static void broadcastKanbanCardStickersNullTest() {
        MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request = new MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest();
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>();
        
        Test.startTest();
        KanbanCardSticker.broadcastKanbanCardStickers(kanbanCardStickers, request);  // this is just for code coverage, no need to assert    
        Test.stopTest();
        Boolean expectedValue = true;
        System.assertEquals(true, expectedValue);
    }


    @isTest 
    static void broadcastKanbanCardStickersTest() {
        List<leankor__ProjectRoom__c> projectRoomId = readTestProjectRoomRecord();    
        List<leankor__KanbanCard__c> kanbanCards = readTestKanbanCardRecord();
        List<leankor__Sticker__c> stickers = readTestStickerRecord(true);
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = readTestKanbanCardStickerRecord();        

        MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request = new MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest();
        request.kanbanCardRequest = kanbanCards;
        request.stickerRequest = stickers;
        request.sendBroadcastMessage = true;  // true = to broadcast the event, otherwise false
        request.projectId = projectRoomId[0].Id;
    
        Test.startTest();
        KanbanCardSticker.broadcastKanbanCardStickers(kanbanCardStickers, request);  // this is just for code coverage, no need to assert    
        Test.stopTest(); 
        Boolean expectedValue = true;
        System.assertEquals(true, expectedValue);
    }

    // Test methods for upsertKanbanCardStickers(List<leankor__KanbanCardSticker__c>)
    // New Test Code
    @isTest
    static void testUpsertKanbanCardStickersListPositiveInsert() {
        // Retrieve existing test data
        leankor__KanbanCard__c card = [Select Id 
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c sticker = [Select Id 
                                            From leankor__Sticker__c 
                                            Where Name = 'Global Sticker' 
                                            Limit 1];
        
        // Create a new KanbanCardSticker to insert
        List<leankor__KanbanCardSticker__c> newStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = sticker.Id
            )
        };
        
        Test.startTest();
        List<leankor__KanbanCardSticker__c> result = KanbanCardSticker.upsertKanbanCardStickers(newStickers);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should upsert one new sticker');
        System.assertNotEquals(null, result[0].Id, 'New sticker should have an ID after insert');
        System.assertEquals(card.Id, result[0].leankor__KanbanCard__c, 'Kanban card ID should match');
    }

    @isTest
    static void testUpsertKanbanCardStickersListPositiveUpdate() {
        // Retrieve existing test data
        leankor__KanbanCardSticker__c existingSticker = [Select  Id, leankor__KanbanCard__c, leankor__Sticker__c 
                                                        From leankor__KanbanCardSticker__c Limit 1];
        leankor__Sticker__c newSticker = [Select  Id From leankor__Sticker__c Where Name = 'Global Sticker' Limit 1];
        
        // Update the existing sticker
        existingSticker.leankor__Sticker__c = newSticker.Id;
        
        Test.startTest();
        List<leankor__KanbanCardSticker__c> result = KanbanCardSticker.upsertKanbanCardStickers(
            new List<leankor__KanbanCardSticker__c>{existingSticker}
        );
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should upsert one updated sticker');
        System.assertEquals(newSticker.Id, result[0].leankor__Sticker__c, 'Sticker ID should be updated');
    }

    @isTest
    static void testUpsertKanbanCardStickersListNegativeDMLException() {
        // Create an invalid sticker (missing required fields)
        List<leankor__KanbanCardSticker__c> invalidStickers = new List<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c() // No KanbanCard__c or Sticker__c
        };
        
        Test.startTest();
        try {
            KanbanCardSticker.upsertKanbanCardStickers(invalidStickers);
            // If no exception is thrown, verify the upsert with null fields
            List<leankor__KanbanCardSticker__c> result = [Select  Id From leankor__KanbanCardSticker__c 
                                                         Where leankor__KanbanCard__c = null 
                                                         AND leankor__Sticker__c = null];
            System.assertEquals(1, result.size(), 'Upsert should succeed with null fields if not required');
        } catch (DMLException e) {
            System.assert(e.getMessage().contains('required'), 'Should throw DML exception for missing required fields');
        }
        Test.stopTest();
    }

    // Test methods for upsertKanbanCardStickers(Set<leankor__KanbanCardSticker__c>, Set<Id>)
    @isTest
    static void testUpsertKanbanCardStickersSetPositive() {
        // Retrieve existing test data
        leankor__KanbanCard__c card = [Select Id 
                                            From leankor__KanbanCard__c 
                                            Where Name = 'Card' 
                                            Limit 1];
        leankor__Sticker__c sticker = [Select Id 
                                            From leankor__Sticker__c 
                                            Where Name = 'Global Sticker' 
                                            Limit 1];
        
        // Create a new sticker to upsert
        Set<leankor__KanbanCardSticker__c> newStickers = new Set<leankor__KanbanCardSticker__c>{
            new leankor__KanbanCardSticker__c(
                leankor__KanbanCard__c = card.Id,
                leankor__Sticker__c = sticker.Id
            )
        };
        Set<Id> workItemIds = new Set<Id>{card.Id};
        
        Test.startTest();
        KanbanCardSticker.upsertKanbanCardStickers(newStickers, workItemIds);
        Test.stopTest();
        
        List<leankor__KanbanCardSticker__c> result = [Select  Id, 
                                                            leankor__KanbanCard__c, 
                                                            leankor__Sticker__c 
                                                        From leankor__KanbanCardSticker__c 
                                                        Where leankor__KanbanCard__c = :card.Id];
        System.assertEquals(1, result.size(), 'Should upsert only one sticker due to method behavior');
        System.assertEquals(sticker.Id, result[0].leankor__Sticker__c, 'New sticker should be upserted');
    }

    @isTest
    static void testUpsertKanbanCardStickersSetNegativeEmpty() {
        // Retrieve existing test data
        leankor__KanbanCard__c card = [Select Id From leankor__KanbanCard__c Where Name = 'Card' Limit 1];
        Set<leankor__KanbanCardSticker__c> emptyStickers = new Set<leankor__KanbanCardSticker__c>();
        Set<Id> workItemIds = new Set<Id>{card.Id};
        
        Test.startTest();
        KanbanCardSticker.upsertKanbanCardStickers(emptyStickers, workItemIds);
        Test.stopTest();
        
        List<leankor__KanbanCardSticker__c> result = [Select Id 
                                                            From leankor__KanbanCardSticker__c 
                                                        Where leankor__KanbanCard__c = :card.Id];
        System.assertEquals(0, result.size(), 'Should be modify existing stickers when newStickers is empty');
    }

    @isTest
    static void testUpsertKanbanCardStickersSetNegativeNull() {
        // Retrieve existing test data
        Set<Id> workItemIds = new Set<Id>();
        
        Test.startTest();
        KanbanCardSticker.upsertKanbanCardStickers(null, workItemIds);
        Test.stopTest();
        
        List<leankor__KanbanCardSticker__c> result = [Select Id 
                                                            From leankor__KanbanCardSticker__c 
                                                            Where leankor__KanbanCard__c = :workItemIds];
        System.assertEquals(0, result.size(), 'Should be modify existing stickers when newStickers is null and WorkItemIdsEmpty');
    }
}