@isTest
private class CloneProjectQueueableSFActionTest {
    
    private static testMethod void testCloneProjectQueueableSFAction() {
       
        List<leankor__ProjectRoom__c> listProjectRoom = new List<leankor__ProjectRoom__c>();
        // creating source folder data
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c(Name = 'sourceFolder');
        insert sourceFolder;
        // creating source project data
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(Name = 'sourceProject', leankor__Portfolio__c = sourceFolder.Id, leankor__DueDate__c = System.today());
        insert sourceProject;
        listProjectRoom.add(sourceProject);
        
        ApexPages.StandardController stdController = new ApexPages.standardController(sourceProject);
        CloneProjectAction testController = new CloneProjectAction(stdController);
        
        ApexPages.StandardSetController stdsetController = new ApexPages.StandardSetController(listProjectRoom);
        CloneProjectAction testsetController = new CloneProjectAction(stdsetController);
        
        // creating board data
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c(Name = 'Plan Board', leankor__BoardType__c = 'UberBoard', leankor__ProjectRoom__c = sourceProject.Id, leankor__IsTemplateBoard__c = false);         
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
		//creating  ProjectLaunchBehavior data
		leankor__ProjectLaunchBehavior__c ProjectLaunch = new leankor__ProjectLaunchBehavior__c();       
		ProjectLaunch.leankor__Module__c = module.ID;
		ProjectLaunch.leankor__OneClicklaunch__c = true;
		ProjectLaunch.leankor__OpenNewTab__c = true;
		ProjectLaunch.leankor__Project__c =  sourceProject.Id;
		insert ProjectLaunch;
        //creating Target Portfolio data               
        leankor__Portfolio__c TargetFolder = new leankor__Portfolio__c(Name = 'TargetFolder');
        insert TargetFolder;        
        //creating Target Project data     
        leankor__ProjectRoom__c TargetProject = new leankor__projectRoom__c(name = 'TargetProject', leankor__Portfolio__c = TargetFolder.Id);
        insert TargetProject;
        //getting recordtype data from database for checking recordtype
        List<RecordType> Recordtypelist = [Select Id,
                                                    Name,
                                                    SobjectType 
                                                From RecordType 
                                                Where SobjectType = 'leankor__Expense__c']; 
        // creating Expenses data 
       leankor__Expense__c SampleExpensesCost = new leankor__Expense__c
        (      
		        Name = 'CloneExpenceOne',
		        leankor__Portfolio__c = sourceFolder.Id,
		        leankor__Project__c = sourceProject.Id,
		        leankor__Date__c = System.today(),
		        leankor__ExpenseAmount__c = 100.0,
		        RecordTypeId  = Recordtypelist[0].Id
        );
        insert SampleExpensesCost;
        
        leankor__Expense__c SampleExpenses = new leankor__Expense__c
        (      
		        Name = 'CloneExpenseTwo',
		        leankor__Portfolio__c = sourceFolder.Id,
		        leankor__Project__c = sourceProject.Id,
		        leankor__Date__c = system.today(),
		        leankor__ExpenseAmount__c = 200.0,
		        RecordTypeId  = Recordtypelist[1].Id
        );
        insert SampleExpenses;        
        //
        // creating kanban card data           
        leankor__KanbanCard__c sourceKanbanParent = new leankor__KanbanCard__c();
	        sourceKanbanParent.Name = 'parentKanban';
	        sourceKanbanParent.leankor__ValueStream__c = projectBoardOne.Id;     
	        insert sourceKanbanParent;
        
        leankor__KanbanCard__c sourceKanbanChild = new leankor__KanbanCard__c();
	        sourceKanbanChild.Name = 'childKanban';
	        sourceKanbanChild.leankor__GUID__c = sourceKanbanParent.Id+'-'+'k';
	        sourceKanbanChild.leankor__ValueStream__c = projectBoardOne.Id;
	        sourceKanbanChild.leankor__ValueStreamCardLink__c = sourceKanbanParent.id;      
	        insert sourceKanbanChild;
        
        leankor__KanbanCard__c sourceKanbanCard = new leankor__KanbanCard__c();
	        sourceKanbanCard.Name = 'Kanban';
	        sourceKanbanCard.leankor__GUID__c = projectBoardThree.Id +'-'+'kghhg';
	        sourceKanbanCard.leankor__ValueStream__c = projectBoardThree.Id;             
	        insert sourceKanbanCard;
        
        List<String> boardTypes = new List<String>();
        boardTypes.add('Kanban Board');
	    boardTypes.add('Whiteboard');                           
	    boardTypes.add('DashBoard');
	     
        Integer totalCardsOnBoards  = [Select 
		     		                         count()
									     	 From leankor__KanbanCard__c 
									     	 Where leankor__ValueStream__r.leankor__ProjectRoom__c = :sourceProject.Id And leankor__BoardType__c In :boardTypes];      
        
      
      
        List<CloneProjectQueueableSFAction.CloneProjectRequest> ListCloneProjectRequest = new List<CloneProjectQueueableSFAction.CloneProjectRequest> ();
        
        CloneProjectQueueableSFAction.CloneProjectRequest CloneRoomRequest = new CloneProjectQueueableSFAction.CloneProjectRequest();                
        CloneRoomRequest.sourceFolderId = sourceFolder.Id;
        CloneRoomRequest.sourceFolderName = SourceFolder.Name;
        CloneRoomRequest.sourceProjectId = sourceProject.Id;
        CloneRoomRequest.sourceProjectName = sourceProject.Name;
        CloneRoomRequest.targetFolderId = TargetFolder.Id;
        CloneRoomRequest.targetFolderName = TargetFolder.Name;
        CloneRoomRequest.targetProjectName = 'Clone One';
        CloneRoomRequest.targetProjectStartDateTime = System.now();
        CloneRoomRequest.targetProjectDueDateTime = System.now();
        CloneRoomRequest.planGantt = true;
        CloneRoomRequest.rollUp = true;
        CloneRoomRequest.projectBoard = true;
        CloneRoomRequest.whiteBoard = true;
        CloneRoomRequest.dashBoard = true;
        CloneRoomRequest.expenses = true;
        CloneRoomRequest.returnPortfolioHierarchy = true;
        CloneRoomRequest.totalCardsOfSourceProjectBoards = totalCardsOnBoards;
        CloneRoomRequest.projectBoardTypes = boardTypes;
        CloneRoomRequest.relinkClonedProjectId = '';                     
        ListCloneProjectRequest.add(CloneRoomRequest);
              
        System.assert(ListCloneProjectRequest.size()>0);                   
        List<CloneProjectQueueableSFAction.CloneProjectRequest>  requestBeforeReLink = CloneProjectQueueableSFAction.cloneProjects(ListCloneProjectRequest);      
        System.assertEquals(ListCloneProjectRequest.size(), requestBeforeReLink.size());
    }   
}