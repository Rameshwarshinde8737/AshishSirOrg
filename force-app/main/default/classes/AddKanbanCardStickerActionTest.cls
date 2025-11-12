@isTest
private class AddKanbanCardStickerActionTest {
    
    @TestSetup
    static void setupTestData(){
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'TestFolder');
		insert testFolder;

        leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c(Name = 'TestProject', leankor__Portfolio__c = testFolder.Id);
		insert testProject;

        leankor__ValueStream__c testValueStream = new leankor__ValueStream__c(Name = 'TestBoard', leankor__ProjectRoom__c = testProject.id, leankor__BoardType__c = 'Kanban Board');
		insert testValueStream;

        leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c(
            Name = 'TestCard',
            leankor__DurationUnits__c = 'Days',
            leankor__EstimatedDuration__c = 1,
            leankor__StartDateTime__c = System.now(),
            leankor__DueDateTime__c = System.now().addDays(1),
            leankor__ValueStream__c = testValueStream.Id
        );
		insert testKanbanCard;
        
        leankor__Sticker__c testSticker = new leankor__Sticker__c(Name = 'TestSticker', leankor__ValueStream__c = testValueStream.Id);
        insert testSticker;

    }

    private static leankor__KanbanCard__c getKanbanCardRecord(){
        List<leankor__KanbanCard__c> cards = [SELECT Name,Id FROM leankor__KanbanCard__c WHERE Name = 'TestCard'];
        return cards.get(0);
    }

    private static leankor__Sticker__c getStickerRecord(){
        List<leankor__Sticker__c> stickers = [SELECT Name,Id FROM leankor__Sticker__c WHERE Name = 'TestSticker'];
        return stickers.get(0);
    }

    // Tests if user is able to add a Sticker to a Kanban Card, which then creates a new KanbanCardSticker record behind the scenes (bts)
    @isTest static void addKanbanCardStickerTest() {

        ID cardId = getKanbanCardRecord().Id;
        ID stickerId = getStickerRecord().Id;
        String stickerName = getStickerRecord().Name;

        List<AddKanbanCardStickerAction.StickerDataRequest> requests = new List<AddKanbanCardStickerAction.StickerDataRequest>();
        AddKanbanCardStickerAction.StickerDataRequest request = new AddKanbanCardStickerAction.StickerDataRequest();

        request.KanbanID = cardId;
        request.StickerID = stickerId;
        request.StickerName = stickerName;
        requests.add(request);

        List<AddKanbanCardStickerAction.StickerDataResult> result = new List<AddKanbanCardStickerAction.StickerDataResult>();

        Test.startTest();

        result = AddKanbanCardStickerAction.AddCardStickerAction(requests);

        System.assert(result.size() > 0, 'Result should not be empty');

        Test.stopTest();

    }

    /* 
        Tests if user is able to add a Sticker to a Kanban Card, but the Id passed is null
        The KanbanCardSticker will still be created since the code will just use the Sticker Name instead bts
    */
    @isTest static void addKanbanCardWithNullStickerTest() {

        ID cardId = getKanbanCardRecord().Id;
        ID stickerId = null;
        String stickerName = 'TestSticker';

        List<AddKanbanCardStickerAction.StickerDataRequest> requests = new List<AddKanbanCardStickerAction.StickerDataRequest>();
        AddKanbanCardStickerAction.StickerDataRequest request = new AddKanbanCardStickerAction.StickerDataRequest();

        request.KanbanID = cardId;
        request.StickerID = stickerId;
        request.StickerName = stickerName;
        requests.add(request);

        List<AddKanbanCardStickerAction.StickerDataResult> result = new List<AddKanbanCardStickerAction.StickerDataResult>();

        Test.startTest();

        result = AddKanbanCardStickerAction.AddCardStickerAction(requests);

        System.assert(result.size() > 0, 'Result should not be empty');

        Test.stopTest();

    }

    /* 
        Tests if user is able to add Sticker to a Kanban Card 
        This time, a KanbanCardSticker record already exists, so no need to create the record bts
    */
    @isTest static void addExistingKanbanCardWithStickerTest() {

        Test.startTest();

        ID cardId = getKanbanCardRecord().Id;
        ID stickerId = getStickerRecord().Id;
        String stickerName = getStickerRecord().Name;

        leankor__KanbanCardSticker__c testKanbanCardSticker = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = cardId, leankor__Sticker__c = stickerId); 
        insert testKanbanCardSticker;

        List<AddKanbanCardStickerAction.StickerDataRequest> requests = new List<AddKanbanCardStickerAction.StickerDataRequest>();
        AddKanbanCardStickerAction.StickerDataRequest request = new AddKanbanCardStickerAction.StickerDataRequest();

        request.KanbanID = cardId;
        request.StickerID = stickerId;
        request.StickerName = stickerName;
        requests.add(request);

        List<AddKanbanCardStickerAction.StickerDataResult> result = new List<AddKanbanCardStickerAction.StickerDataResult>();

        result = AddKanbanCardStickerAction.AddCardStickerAction(requests);

        System.assert(result.size() > 0, 'Result should not be empty');

        Test.stopTest();

    }

    /*---------------------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover Negative Senario AddCardStickerAction Method inside AddKanbanCardStickerAction Class 
    -----------------------------------------------------------------------------------------------------------------------*/ 
    @isTest static void testAddCardStickerActionNegavieSenario() {

        Test.startTest();

        ID cardId = getKanbanCardRecord().Id;
        ID stickerId = getStickerRecord().Id;
        String stickerName = getStickerRecord().Name;

        leankor__KanbanCardSticker__c testKanbanCardSticker = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = cardId, leankor__Sticker__c = stickerId); 
        insert testKanbanCardSticker;

        List<AddKanbanCardStickerAction.StickerDataRequest> requests = new List<AddKanbanCardStickerAction.StickerDataRequest>();
        AddKanbanCardStickerAction.StickerDataRequest request = new AddKanbanCardStickerAction.StickerDataRequest();

        request.KanbanID = stickerId; // in place of Kanaban Id we pass Sticker Id
        request.StickerID = cardId;   // in place of StickerID Id we pass cardId Id
        request.StickerName = stickerName;
        requests.add(request);

        List<AddKanbanCardStickerAction.StickerDataResult> result = new List<AddKanbanCardStickerAction.StickerDataResult>();

        try{
            result = AddKanbanCardStickerAction.AddCardStickerAction(requests); // Checking Exception in Case of Wrong ID 
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        Test.stopTest();

    }

}