@istest
private class RemoveKanbanCardStickerActionTest {
     
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
     Description : This method is cover RemoveCardStickerAction Method inside RemoveKanbanCardStickerAction Class 
    -------------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void removeCardStickerActionTest(){
    
        leankor__KanbanCard__c kanbanCardRecord = [Select Id 
                                                      From leankor__KanbanCard__c 
                                                      Where Name = 'activity'];

        
        List<RemoveKanbanCardStickerAction.StickerDataRequest> stickerDataRequestListRecord = new List<RemoveKanbanCardStickerAction.StickerDataRequest>();
        RemoveKanbanCardStickerAction.StickerDataRequest stickerDataRequestRecord = new  RemoveKanbanCardStickerAction.StickerDataRequest();
        stickerDataRequestRecord.KanbanID = kanbanCardRecord.Id;
        stickerDataRequestListRecord.add(stickerDataRequestRecord);

        List<RemoveKanbanCardStickerAction.StickerDataResult> stickerDataResultListRecord = new List<RemoveKanbanCardStickerAction.StickerDataResult>();
        RemoveKanbanCardStickerAction.StickerDataResult stickerDataResultRecord = new RemoveKanbanCardStickerAction.StickerDataResult();
        stickerDataResultRecord.result = true;
        stickerDataResultListRecord.add(stickerDataResultRecord);

        Test.startTest();
        List<RemoveKanbanCardStickerAction.StickerDataResult> stickerDataRequestRecords = new List<RemoveKanbanCardStickerAction.StickerDataResult>();
        stickerDataRequestRecords = RemoveKanbanCardStickerAction.RemoveCardStickerAction(stickerDataRequestListRecord);
        System.Assert(stickerDataRequestRecords.size()>0);
        Test.stopTest();
    }
    
    /*---------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover RemoveCardSticker Method inside RemoveKanbanCardStickerAction Class 
    --------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void removeCardStickerOneTest(){
        
        leankor__KanbanCard__c kanbanCardRecord = [Select Id 
                                                      From leankor__KanbanCard__c 
                                                      Where Name = 'activity'];

        leankor__Sticker__c testSticker = [Select Name 
                                              From leankor__Sticker__c 
                                              Where Name = 'TestSticker'];

        RemoveKanbanCardStickerAction.StickerDataRequest stickerDataRequestRecord = new RemoveKanbanCardStickerAction.StickerDataRequest();
        stickerDataRequestRecord.KanbanID=kanbanCardRecord.Id;
        stickerDataRequestRecord.StickerName=testSticker.Name;

        Test.startTest();
        boolean removeCardStickerRecord = RemoveKanbanCardStickerAction.RemoveCardSticker(stickerDataRequestRecord);
        System.Assertequals(removeCardStickerRecord,true);
        Test.stopTest();
    }
    /*-------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover RemoveCardSticker Method inside RemoveKanbanCardStickerAction Class 
    ---------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void removeCardStickerTwoTest(){
        
        leankor__ValueStream__c projectBoardOne = [Select Id 
                                                      From leankor__ValueStream__c 
                                                      Where Name = 'PG'];

        projectBoardOne.leankor__BoardType__c ='Plan Board';
        update projectBoardOne;
       
        leankor__KanbanCard__c kanbanCardRecord = [Select Id 
                                                     From leankor__KanbanCard__c 
                                                     Where Name = 'activity'];

        kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
        update kanbanCardRecord;
           
        leankor__Sticker__c testSticker = [Select Name
                                             From leankor__Sticker__c 
                                             Where Name = 'TestSticker'];
      
        RemoveKanbanCardStickerAction.StickerDataRequest stickerDataRequestRecord = new  RemoveKanbanCardStickerAction.StickerDataRequest();
        stickerDataRequestRecord.KanbanID = kanbanCardRecord.Id;
        stickerDataRequestRecord.StickerName = testSticker.Name;

        Test.startTest();
        boolean removeCardSticker = RemoveKanbanCardStickerAction.RemoveCardSticker(stickerDataRequestRecord);
        System.Assertequals(removeCardSticker,true);
        Test.stopTest();
    }

}