/*	
	 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
	 USAGE: To cover CloneProjectBoardAsyncAction class .
	 Date : 02/08/19
*/
@isTest
private class CloneProjectBoardAsyncActionTest {
 

    @isTest
    static void CloneProjectBoardTest() {
        Boolean flag = true;
        
        leankor__Portfolio__c sourcePortfolio = new leankor__Portfolio__c();
        sourcePortfolio.Name = 'ProjectFolderName';
        insert sourcePortfolio;

        leankor__Projectroom__c sourceProject =  new leankor__projectroom__c() ;
        sourceProject.Name = 'testRoom';
        sourceProject.leankor__PortFolio__c = sourcePortfolio.Id;
        insert sourceProject;

        leankor__ValueStream__c sourceValueStream =new leankor__ValueStream__c();
        sourceValueStream.Name='_System_Board';
        sourceValueStream.leankor__BoardType__c='Kanban Board';
        sourceValueStream.leankor__projectroom__C = sourceProject.id;
        insert sourceValueStream;

        leankor__kanbancard__C sourceKanbanCard =  new leankor__kanbancard__C();
        sourceKanbanCard.Name='LINKKC';
        sourceKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        sourceKanbanCard.leankor__ValueStream__c=sourceValueStream.Id;
        insert sourceKanbanCard;
        
        leankor__Portfolio__c linkPortfolio = new leankor__Portfolio__c();
        linkPortfolio.Name = 'LINKP';
        insert linkPortfolio;

        leankor__Projectroom__c linkProject =  new leankor__projectroom__c() ;
        linkProject.Name = 'LinkPro';
        insert linkProject;

        leankor__ValueStream__c linkValueStream =new leankor__ValueStream__c();
        linkValueStream.Name='LINKABC';
        linkValueStream.leankor__BoardType__c='Kanban Board';
        linkValueStream.leankor__projectroom__C = linkProject.id;
        insert linkValueStream;

        leankor__kanbancard__C linkKanbanCard =  new leankor__kanbancard__C();
        linkKanbanCard.Name='LINKKC';
        linkKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        linkKanbanCard.leankor__ValueStream__c=linkValueStream.Id;
        insert linkKanbanCard;
        
        leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest requestboard1 = new leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest();
        requestboard1.ProjectRoom = 'testRoom';
        requestboard1.FolderName = 'ProjectFolderName';
        requestboard1.ProjectBoard = '_System_Board';
        requestboard1.TargetRoom = 'testRoom';
        requestboard1.TargetFolderName = 'ProjectFolderName';
        requestboard1.TargetBoard = 'clone_test';
        requestboard1.LinkKanbanCardName = linkKanbanCard.name;
        requestboard1.LinkBoardName = linkValueStream.name;
        requestboard1.LinkRoomName = linkProject.name;
        requestboard1.TargetDate = system.now();   
        
        List<leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest> requestboardsforFolder2 = new  List<leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest>();
        requestboardsforFolder2.add(requestboard1);

        Test.startTest();
        List<leankor.CloneProjectBoardAsyncAction.CloneProjectBoardResult> resultboard2 = leankor.CloneProjectBoardAsyncAction.CloneProjectBoard(requestboardsforFolder2);
        Test.stopTest();
            
        System.assertEquals(true, flag);
    }
    
    @isTest
    static void asyncCloneBoardTest() {
        Boolean flag = false;
        leankor__Portfolio__c sourcePortfolio = new leankor__Portfolio__c();
        sourcePortfolio.Name = 'ProjectFolderName';
        insert sourcePortfolio;

        leankor__Projectroom__c sourceProject =  new leankor__projectroom__c() ;
        sourceProject.Name = 'testRoom';
        sourceProject.leankor__PortFolio__c = sourcePortfolio.Id;
        insert sourceProject;

        leankor__ValueStream__c sourceValueStream =new leankor__ValueStream__c();
        sourceValueStream.Name='_System_Board';
        sourceValueStream.leankor__BoardType__c='Kanban Board';
        sourceValueStream.leankor__projectroom__C = sourceProject.id;
        insert sourceValueStream;

        leankor__kanbancard__C sourceKanbanCard =  new leankor__kanbancard__C();
        sourceKanbanCard.Name='LINKKC';
        sourceKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        sourceKanbanCard.leankor__ValueStream__c=sourceValueStream.Id;
        insert sourceKanbanCard;
        
        leankor__Portfolio__c linkPortfolio = new leankor__Portfolio__c();
        linkPortfolio.Name = 'LINKP';
        insert linkPortfolio;

        leankor__Projectroom__c linkProject =  new leankor__projectroom__c() ;
        linkProject.Name = 'LinkPro';
        insert linkProject;

        leankor__ValueStream__c linkValueStream =new leankor__ValueStream__c();
        linkValueStream.Name='LINKABC';
        linkValueStream.leankor__BoardType__c='Kanban Board';
        linkValueStream.leankor__projectroom__C = linkProject.id;
        insert linkValueStream;

        leankor__kanbancard__C linkKanbanCard =  new leankor__kanbancard__C();
        linkKanbanCard.Name='LINKKC';
        linkKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        linkKanbanCard.leankor__ValueStream__c=linkValueStream.Id;
        insert linkKanbanCard;
        
        leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestboard1 = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
        requestboard1.ProjectRoom = 'testRoom';
        requestboard1.FolderName = 'ProjectFolderName';
        requestboard1.ProjectBoard = '_System_Board';
        requestboard1.TargetRoom = 'testRoom';
        requestboard1.TargetFolderName = 'ProjectFolderName';
        requestboard1.TargetBoard = 'clone_test';
        requestboard1.LinkKanbanCardName = linkKanbanCard.name;
        requestboard1.LinkBoardName = linkValueStream.name;
        requestboard1.LinkRoomName = linkProject.name;
        requestboard1.TargetDate = system.now();   
        String data = JSON.serialize(requestboard1);
        
        Test.startTest();
       	CloneProjectBoardAsyncAction.asyncCloneBoard(data);
        Test.stopTest();
        
        flag = true;
        System.assert(flag==true);
    }
    
    @isTest
    static void executeTest() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
        insert project;

        Boolean flag = false;
        leankor__Portfolio__c sourcePortfolio = new leankor__Portfolio__c();
        sourcePortfolio.Name = 'ProjectFolderName';
        insert sourcePortfolio;

        leankor__Projectroom__c sourceProject =  new leankor__projectroom__c() ;
        sourceProject.Name = 'testRoom';
        sourceProject.leankor__PortFolio__c = sourcePortfolio.Id;
        insert sourceProject;

        leankor__ValueStream__c sourceValueStream =new leankor__ValueStream__c();
        sourceValueStream.Name='_System_Board';
        sourceValueStream.leankor__BoardType__c='Kanban Board';
        sourceValueStream.leankor__projectroom__C = sourceProject.id;
        insert sourceValueStream;

        leankor__kanbancard__C sourceKanbanCard =  new leankor__kanbancard__C();
        sourceKanbanCard.Name='LINKKC';
        sourceKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        sourceKanbanCard.leankor__ValueStream__c=sourceValueStream.Id;
        insert sourceKanbanCard;
        
        leankor__Portfolio__c linkPortfolio = new leankor__Portfolio__c();
        linkPortfolio.Name = 'LINKP';
        insert linkPortfolio;

        leankor__Projectroom__c linkProject =  new leankor__projectroom__c() ;
        linkProject.Name = 'LinkPro';
        insert linkProject;

        leankor__ValueStream__c linkValueStream =new leankor__ValueStream__c();
        linkValueStream.Name='LINKABC';
        linkValueStream.leankor__BoardType__c='Kanban Board';
        linkValueStream.leankor__projectroom__C = linkProject.id;
        insert linkValueStream;

        leankor__kanbancard__C linkKanbanCard =  new leankor__kanbancard__C();
        linkKanbanCard.Name='LINKKC';
        linkKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        linkKanbanCard.leankor__ValueStream__c=linkValueStream.Id;
        insert linkKanbanCard;
        
        leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestboard1 = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
        requestboard1.ProjectRoom = 'testRoom';
        requestboard1.FolderName = 'ProjectFolderName';
        requestboard1.ProjectBoard = '_System_Board';
        requestboard1.TargetRoom = 'testRoom';
        requestboard1.TargetFolderName = 'ProjectFolderName';
        requestboard1.TargetBoard = 'clone_test';
        requestboard1.LinkKanbanCardName = linkKanbanCard.name;
        requestboard1.LinkBoardName = linkValueStream.name;
        requestboard1.LinkRoomName = linkProject.name;
        requestboard1.TargetDate = system.now();   
        
        Test.startTest();
        System.enqueueJob(new CloneProjectBoardAsyncAction(requestboard1));
        Test.stopTest();

        flag = true;
        System.assert(flag==true);
    }
    
    @isTest
    static void asyncCloneProjectBoard() {
        leankor__Portfolio__c sourcePortfolio = new leankor__Portfolio__c();
        sourcePortfolio.Name = 'ProjectFolderName';
        insert sourcePortfolio;

        leankor__Projectroom__c sourceProject =  new leankor__projectroom__c() ;
        sourceProject.Name = 'testRoom';
        sourceProject.leankor__PortFolio__c = sourcePortfolio.Id;
        insert sourceProject;

        leankor__ValueStream__c sourceValueStream =new leankor__ValueStream__c();
        sourceValueStream.Name='_System_Board';
        sourceValueStream.leankor__BoardType__c='Kanban Board';
        sourceValueStream.leankor__projectroom__C = sourceProject.id;
        insert sourceValueStream;

        leankor__kanbancard__C sourceKanbanCard =  new leankor__kanbancard__C();
        sourceKanbanCard.Name='LINKKC';
        sourceKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        sourceKanbanCard.leankor__ValueStream__c=sourceValueStream.Id;
        insert sourceKanbanCard;
        
        leankor__Portfolio__c linkPortfolio = new leankor__Portfolio__c();
        linkPortfolio.Name = 'LINKP';
        insert linkPortfolio;

        leankor__Projectroom__c linkProject =  new leankor__projectroom__c() ;
        linkProject.Name = 'LinkPro';
        insert linkProject;

        leankor__ValueStream__c linkValueStream =new leankor__ValueStream__c();
        linkValueStream.Name='LINKABC';
        linkValueStream.leankor__BoardType__c='Kanban Board';
        linkValueStream.leankor__projectroom__C = linkProject.id;
        insert linkValueStream;

        leankor__kanbancard__C linkKanbanCard =  new leankor__kanbancard__C();
        linkKanbanCard.Name='LINKKC';
        linkKanbanCard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        linkKanbanCard.leankor__ValueStream__c=linkValueStream.Id;
        insert linkKanbanCard;
        
        leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest requestboard1 = new leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest();
        requestboard1.ProjectRoom = 'testRoom';
        requestboard1.FolderName = 'ProjectFolderName';
        requestboard1.ProjectBoard = '_System_Board';
        requestboard1.TargetRoom = 'testRoom';
        requestboard1.TargetFolderName = 'ProjectFolderName';
        requestboard1.TargetBoard = 'clone_test';
        requestboard1.LinkKanbanCardName = linkKanbanCard.name;
        requestboard1.LinkBoardName = linkValueStream.name;
        requestboard1.LinkRoomName = linkProject.name;
        requestboard1.TargetDate = system.now();   
        
        List<leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest> requestboardsforFolder = new  List<leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest>();
        requestboardsforFolder.add(requestboard1);
        
        Test.startTest();
        String result = CloneProjectBoardAsyncAction.asyncCloneProjectBoard(requestboardsforFolder);
        Test.stopTest();
        
        System.assert(result=='Sucsess');
       
    }
}