@isTest
private class AddWorkItemStickerActionTest {

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
        List<leankor__KanbanCard__c> cards = [Select Name,
                                                     Id
                                                From leankor__KanbanCard__c 
                                                Where Name = 'TestCard'];
        return cards.get(0);
    }

    private static leankor__Sticker__c getStickerRecord(){
        List<leankor__Sticker__c> stickers = [Select Name,
                                                        Id 
                                                    From leankor__Sticker__c 
                                                    Where Name = 'TestSticker'];

        return stickers.get(0);
    }
    // Tests if user is able to add a Sticker to a Kanban Card, which then creates a new KanbanCardSticker record behind the scenes (bts)
    @isTest static void addKanbanCardStickerTest() {

        ID cardId = getKanbanCardRecord().Id;
        ID stickerId = getStickerRecord().Id;
        String stickerName = getStickerRecord().Name;

        List<AddWorkItemStickerAction.StickerDataRequest> requests = new List<AddWorkItemStickerAction.StickerDataRequest>();
        AddWorkItemStickerAction.StickerDataRequest request = new AddWorkItemStickerAction.StickerDataRequest();

        request.KanbanID = cardId;
        request.StickerID = stickerId;
        request.StickerName = stickerName;
        requests.add(request);
        Test.startTest();

        System.assert(AddWorkItemStickerAction.AddCardStickerAction(requests).size()!=0);

        Test.stopTest();

    }
    
}