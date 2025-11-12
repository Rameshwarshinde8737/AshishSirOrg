@isTest
private class CreateProjectBoardSFActionTest {
    @isTest 
    private static void createProjectBoardTest(){
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Test-folder';
        insert folder;
        leankor__Projectroom__c project =  new leankor__Projectroom__c();
        project.Name = 'Test-Project';
        project.leankor__Portfolio__c = folder.Id;
        insert project;
        leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
        linkBoard.Name = 'LinkBoard';
        linkBoard.leankor__BoardType__c ='Kanban Board';
        linkBoard.leankor__projectroom__c = project.Id;
        insert linkBoard;
        leankor__kanbancard__c linkCard =  new leankor__kanbancard__c();
        linkCard.Name = 'LinkCard';
        linkCard.leankor__GUID__c = TestDataFactory.createGuid();
        linkCard.leankor__ValueStream__c = linkBoard.Id;
        insert linkCard;

        List<leankor.CreateProjectBoardSFAction.ProjectBoardRequest> requests  = new List<leankor.CreateProjectBoardSFAction.ProjectBoardRequest>();
        List<leankor.CreateProjectBoardSFAction.ProjectBoardRequest> results  = new List<leankor.CreateProjectBoardSFAction.ProjectBoardRequest>();
        leankor.CreateProjectBoardSFAction.ProjectBoardRequest request = new leankor.CreateProjectBoardSFAction.ProjectBoardRequest();
        request.ProjectBoardName = 'New-Board';
        request.ProjectRoomName = 'Test-Project';
        request.LinkedRoomName = 'Test-Project';
        request.LinkedBoardId = linkBoard.Id;
        request.LinkedCardName = 'LinkCard';
        requests.add(request);
        Test.startTest();
        results = leankor.CreateProjectBoardSFAction.createProjectBoard(requests);
        System.assertEquals(requests.size(), results.size());
        Test.stopTest();

    }
}