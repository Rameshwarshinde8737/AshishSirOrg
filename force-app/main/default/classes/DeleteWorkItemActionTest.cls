/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for DeleteWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@istest
private class DeleteWorkItemActionTest {

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @TestSetup
    static void setupTestData() {

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
    }

    /*-----------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover deleteKanbanCardProcess Method inside DeleteWorkItemAction Class 
    -------------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void removeCardStickerActionTest() {
    
        List<leankor__KanbanCard__c> kanbanCardRecord = [Select Id,
                                                        Name,
                                                        leankor__GUID__c 
                                                      From leankor__KanbanCard__c 
                                                      Where Name = 'activity'];

        
        List<DeleteWorkItemAction.KanbanCardRequest> requestListRecord = new List<DeleteWorkItemAction.KanbanCardRequest>();
        DeleteWorkItemAction.KanbanCardRequest requestRecord = new  DeleteWorkItemAction.KanbanCardRequest();
        requestRecord.kanbanCards = kanbanCardRecord;
        requestListRecord.add(requestRecord);


        Test.startTest();
            System.Assert(DeleteWorkItemAction.deleteKanbanCardProcess(requestListRecord).size() > 0, 'Method Executed Successfully.');
        Test.stopTest();
    }
    
    @istest
    private static void removeCardStickerActionWBSAndSequenceNumber() {
    
        List<leankor__KanbanCard__c> kanbanCardRecord = [Select Id,
                                                        Name,
                                                        leankor__GUID__c 
                                                      From leankor__KanbanCard__c 
                                                      Where Name = 'activity'];

        
        List<DeleteWorkItemAction.KanbanCardRequest> requestListRecord = new List<DeleteWorkItemAction.KanbanCardRequest>();
        DeleteWorkItemAction.KanbanCardRequest requestRecord = new  DeleteWorkItemAction.KanbanCardRequest();
        requestRecord.kanbanCards = kanbanCardRecord;
        requestRecord.generateWorkBreakdownStructure = true;
        requestListRecord.add(requestRecord);


        Test.startTest();
            System.Assert(DeleteWorkItemAction.deleteKanbanCardProcess(requestListRecord).size() > 0, 'Method Executed Successfully.');
        Test.stopTest();
    }
}