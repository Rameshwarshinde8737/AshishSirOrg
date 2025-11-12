@isTest
Private class CloneProjectBoardSFActionTest {
    private static testMethod void CloneProjectBoardTest() {
        // creating source folder data
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c(Name = 'sourceFolder');
        insert sourceFolder;
        // creating source project data
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(Name = 'sourceProject', leankor__Portfolio__c = sourceFolder.Id, leankor__DueDate__c = System.today());
        insert sourceProject;
        // creating board data
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c(Name = 'PG-Name', leankor__BoardType__c = 'UberBoard', leankor__ProjectRoom__c = sourceProject.Id, leankor__IsTemplateBoard__c = false);         
        insert projectBoardOne;
    
        leankor__ValueStream__c projectBoardTwo = new leankor__ValueStream__c(Name = 'Roll up', leankor__BoardType__c ='Plan Board', leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardTwo;
        
        leankor__ValueStream__c projectBoardThree = new leankor__ValueStream__c(Name = 'Project Board', leankor__BoardType__c = 'Kanban Board', leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardThree;
        
        leankor__ValueStream__c projectBoardFour = new leankor__ValueStream__c(Name = 'Dash Board', leankor__BoardType__c = 'DashBoard', leankor__ProjectRoom__c = sourceProject.Id);         
        insert projectBoardFour;
        
        //creating module data
        leankor__Module__c module = new leankor__Module__c(Name ='Plan (Gantt)',leankor__BoardType__c = '_System_UberBoard');
        insert module;

        // creating kanban card data           
        leankor__KanbanCard__c sourceKanbanParent = new leankor__KanbanCard__c();
	        sourceKanbanParent.Name = 'parentKanban';
	        sourceKanbanParent.leankor__ValueStream__c = projectBoardOne.Id;     
	        insert sourceKanbanParent;
        
        leankor__KanbanCard__c sourceKanbanChild = new leankor__KanbanCard__c();
	        sourceKanbanChild.Name = 'childKanban';
	        sourceKanbanChild.leankor__GUID__c = sourceKanbanParent.Id+'-'+'k';
	        sourceKanbanChild.leankor__ValueStream__c = projectBoardThree.Id;
	        sourceKanbanChild.leankor__ValueStreamCardLink__c = sourceKanbanParent.id;      
	        insert sourceKanbanChild;
        
        leankor__KanbanCard__c sourceKanbanCard = new leankor__KanbanCard__c();
	        sourceKanbanCard.Name = 'Kanban';
	        sourceKanbanCard.leankor__GUID__c = projectBoardThree.Id +'-'+'kghhg';
	        sourceKanbanCard.leankor__ValueStream__c = projectBoardThree.Id;             
	        insert sourceKanbanCard;

        List<CloneProjectBoardSFAction.CloneProjectBoardRequest> cloneProjectBoardRequests = new List<CloneProjectBoardSFAction.CloneProjectBoardRequest>();
        List<CloneProjectBoardSFAction.CloneProjectBoardRequest> results = new List<CloneProjectBoardSFAction.CloneProjectBoardRequest>();
        Leankor.CloneProjectBoardSFAction.CloneProjectBoardRequest cloneProjectBoardRequest = new Leankor.CloneProjectBoardSFAction.CloneProjectBoardRequest();
        cloneProjectBoardRequest.FolderName = 'sourceFolder';
        cloneProjectBoardRequest.ProjectRoom = 'sourceProject';
        cloneProjectBoardRequest.ProjectBoard = 'Project Board';
        cloneProjectBoardRequest.TargetFolderName = 'sourceFolder';
        cloneProjectBoardRequest.TargetRoom = 'sourceProject';
        cloneProjectBoardRequest.TargetBoard = 'Cloned Board-Example';
        cloneProjectBoardRequest.TargetDate = System.Now();
        cloneProjectBoardRequest.ProjectRoomId = sourceProject.Id;
        cloneProjectBoardRequest.TargetRoomId = sourceProject.Id;
        cloneProjectBoardRequest.ProjectBoardId = projectBoardThree.Id;
        cloneProjectBoardRequest.cloneFiles = true;
        cloneProjectBoardRequest.cloneCustomFields = true;
        cloneProjectBoardRequests.add(cloneProjectBoardRequest);
        results = leankor.CloneProjectBoardSFAction.cloneProjectBoard(cloneProjectBoardRequests);
        System.assertEquals(cloneProjectBoardRequests.size(), results.size());
    }

}