@istest
private class RemoveWorkItemStickerActionTest {

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @TestSetup
    static void setupTestData(){

        leankor__portfolio__c portfolio = new leankor__portfolio__c();
        portfolio.Name = 'folder';
        insert portfolio;

        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project';
        projectRecord.leankor__portfolio__c = portfolio.Id;
        insert projectRecord;
        
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
        projectBoardOne.Name = 'PG';
        projectBoardOne.leankor__BoardType__c = 'UberBoard';   
        projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
        projectBoardOne.leankor__IsTemplateBoard__c = false;
        insert projectBoardOne;
        
        leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
        kanbanCardRecord.Name = 'activity';
        kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
        kanbanCardRecord.leankor__StartDateTime__c = System.now();
        insert kanbanCardRecord;

        leankor__Sticker__c testSticker = new leankor__Sticker__c(Name = 'TestSticker', leankor__ValueStream__c = projectBoardOne.Id);
        insert testSticker;
 
        leankor__KanbanCardSticker__c testKanbanCardSticker = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kanbanCardRecord.Id, leankor__Sticker__c = testSticker.Id); 
        insert testKanbanCardSticker;
    }

    /*-----------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover RemoveCardStickerAction Method inside RemoveKanbanCardStickerSFAction Class 
    -------------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void removeCardStickerActionTest(){
    
        leankor__KanbanCard__c kanbanCardRecord = [Select Id 
                                                      From leankor__KanbanCard__c 
                                                      Where Name = 'activity'];

        
        List<RemoveWorkItemStickerAction.StickerDataRequest> stickerDataRequestListRecord = new List<RemoveWorkItemStickerAction.StickerDataRequest>();
        RemoveWorkItemStickerAction.StickerDataRequest stickerDataRequestRecord = new  RemoveWorkItemStickerAction.StickerDataRequest();
        stickerDataRequestRecord.KanbanID = kanbanCardRecord.Id;
        stickerDataRequestListRecord.add(stickerDataRequestRecord);

        Test.startTest();
        System.Assert(RemoveWorkItemStickerAction.RemoveCardStickerAction(stickerDataRequestListRecord).size()>0);
        Test.stopTest();
    }
}