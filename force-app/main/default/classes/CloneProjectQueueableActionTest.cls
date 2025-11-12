/*
  Date : 29/07/19
  To cover CloneProjectQueueableAction and CreateProjectBoardQueueable class .
 */
@isTest
private class CloneProjectQueueableActionTest {

    static testMethod void testCloneProjectAction() {
       
        List<leankor__ProjectRoom__c> listProjectRoom = new List<leankor__ProjectRoom__c>();
        // creating source folder data
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c(Name = 'sourceFolder');
        insert sourceFolder;
        // creating source project data
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(name = 'sourceProject',leankor__Portfolio__c=sourceFolder.Id,leankor__DueDate__c = system.today(),leankor__ProjectLaunchDateTime__c=System.now()+10);
        insert sourceProject;
        listProjectRoom.add(sourceProject);
        
        ApexPages.StandardController stdController = new ApexPages.standardController(sourceProject);
        CloneProjectQueueableAction testController = new CloneProjectQueueableAction(stdController);
        
        leankor__ProjectRoom__c sourceProjectOne = new leankor__projectRoom__c(name = 'sourceProjectOne',leankor__Portfolio__c=sourceFolder.Id,leankor__DueDate__c = system.today()+1);
        insert sourceProjectOne;
        listProjectRoom.add(sourceProjectOne);
        
        ApexPages.StandardSetController stdsetController = new ApexPages.StandardSetController(listProjectRoom);
        CloneProjectQueueableAction testsetController = new CloneProjectQueueableAction(stdsetController);
        
        // creating board data
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = sourceProject.Id,leankor__IsTemplateBoard__c = false);         
        insert projectBoardOne;
    
        leankor__ValueStream__c projectBoardTwo = new leankor__ValueStream__c(Name = 'Roll up',leankor__BoardType__c='Plan Board',leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardTwo;
        
        leankor__ValueStream__c projectBoardThree = new leankor__ValueStream__c(Name = 'Project Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardThree;
        
        leankor__ValueStream__c projectBoardFour = new leankor__ValueStream__c(Name = 'Dash Board',leankor__BoardType__c='DashBoard',leankor__ProjectRoom__c = sourceProject.Id);         
        insert projectBoardFour;
        //
        // creating module data
        leankor__Module__c module = new leankor__Module__c(Name ='Plan (Gantt)',leankor__BoardType__c = '_System_UberBoard');
        insert module;
		 // creating  ProjectLaunchBehavior data
		 leankor__ProjectLaunchBehavior__c ProjectLaunch = new leankor__ProjectLaunchBehavior__c();       
		 ProjectLaunch.leankor__Module__c = module.ID;
		 ProjectLaunch.leankor__OneClicklaunch__c = true;
		 ProjectLaunch.leankor__OpenNewTab__c = true;
		 ProjectLaunch.leankor__Project__c =  sourceProject.Id;
		 insert ProjectLaunch;
        // creating Target Portfolio data               
        leankor__Portfolio__c TargetFolder = new leankor__Portfolio__c(Name = 'TargetFolder');
        insert TargetFolder;        
        // creating Target Project data     
        leankor__ProjectRoom__c TargetProject = new leankor__projectRoom__c(name = 'TargetProject',leankor__Portfolio__c=TargetFolder.Id);
        insert TargetProject;
         // getting recordtype data from database for checking recordtype
        List<RecordType> Recordtypelist = [SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'leankor__Expense__c']; 
        //
        //
        // creating Expenses data 
       leankor__Expense__c SampleExpensesCost = new leankor__Expense__c
        (      
		        Name = 'CloneExpenceOne',
		        leankor__Portfolio__c = sourceFolder.Id,
		        leankor__Project__c = sourceProject.Id,
		        leankor__Date__c = system.today(),
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
        //
        List<String> boardTypes = new List<String>();
        boardTypes.add('Kanban Board');
	    boardTypes.add('Whiteboard');                           
	    boardTypes.add('DashBoard');
	     
        Integer totalCardsOnBoards  = [Select 
		     		                         count()
									     	 From leankor__KanbanCard__c 
									     	 Where leankor__ValueStream__r.leankor__ProjectRoom__c = :sourceProject.Id And leankor__BoardType__c In :boardTypes];      
        
      
      
        List<CloneProjectQueueableAction.CloneProjectRequest> ListCloneProjectRequest = new List<CloneProjectQueueableAction.CloneProjectRequest> ();
        
        CloneProjectQueueableAction.CloneProjectRequest CloneRoomRequest = new CloneProjectQueueableAction.CloneProjectRequest();                
        CloneRoomRequest.sourceFolderId = sourceFolder.Id;
        CloneRoomRequest.sourceFolderName = SourceFolder.Name;
        CloneRoomRequest.sourceProjectId = sourceProject.Id;
        CloneRoomRequest.sourceProjectName = sourceProject.Name;
        CloneRoomRequest.targetFolderId = TargetFolder.Id;
        CloneRoomRequest.targetFolderName = TargetFolder.Name;
        CloneRoomRequest.targetProjectName = 'Clone  test project One to cover create project  board   Queueable    class';
        CloneRoomRequest.targetProjectStartDateTime =system.now();
       
        CloneRoomRequest.planGantt = true;
        CloneRoomRequest.rollUp = true;
        CloneRoomRequest.projectBoard = true;
        CloneRoomRequest.whiteBoard = true;
        CloneRoomRequest.dashBoard=true;
        CloneRoomRequest.expenses=true;
        CloneRoomRequest.returnPortfolioHierarchy = true;
        CloneRoomRequest.totalCardsOfSourceProjectBoards = totalCardsOnBoards;
        CloneRoomRequest.projectBoardTypes = boardTypes;
        CloneRoomRequest.relinkClonedProjectId = '';
        CloneRoomRequest.targetLaunchDateTime =System.now()+10; 
        CloneRoomRequest.targetProjectDueDateTime=System.now()+20;                    
        ListCloneProjectRequest.add(CloneRoomRequest);
                      
        system.assert(ListCloneProjectRequest.size()>0);                   
        
        List<CloneProjectQueueableAction.CloneProjectResult>  resultBeforeReLink = CloneProjectQueueableAction.cloneProjects(ListCloneProjectRequest);      
        
        system.assert(resultBeforeReLink[0].clonedProjectId != null);
                                                                      
        CloneRoomRequest.relinkClonedProjectId = resultBeforeReLink[0].clonedProjectId;               
        ListCloneProjectRequest.add(CloneRoomRequest);             
        
        // creating project Board data               
        leankor__ValueStream__c clonedProjectBoardOne = new leankor__ValueStream__c
        (   
             Name = 'Plan Board',leankor__BoardType__c='UberBoard',
             leankor__ProjectRoom__c = CloneRoomRequest.relinkClonedProjectId,
             leankor__IsTemplateBoard__c = false           
        );
        insert clonedProjectBoardOne;
        
        leankor__KanbanCard__c CloneKanban = new leankor__KanbanCard__c();
        CloneKanban.Name = 'FirstKanban';  
        CloneKanban.leankor__GUID__c = clonedProjectBoardOne.Id+'-'+'lf';      
        CloneKanban.leankor__ValueStream__c = clonedProjectBoardOne.Id;
        CloneKanban.leankor__StartDateTime__c = system.now();
        CloneKanban.leankor__DueDateTime__c = system.now();
        insert CloneKanban;
                         
        leankor__ValueStream__c clonedProjectBoardTwo = new leankor__ValueStream__c
        (    Name = 'Roll up',
             leankor__BoardType__c='Plan Board',
             leankor__ProjectRoom__c = CloneRoomRequest.relinkClonedProjectId,
             leankor__ValueStreamCardLink__c = CloneKanban.Id,
             leankor__ValueStreamLink__c = clonedProjectBoardOne.Id              
        );        
        insert clonedProjectBoardTwo;
        
        leankor__ValueStream__c clonedProjectBoardThree = new leankor__ValueStream__c
        (    Name = 'Project Board',
             leankor__BoardType__c='Kanban Board',
             leankor__ProjectRoom__c = CloneRoomRequest.relinkClonedProjectId
        );        
        insert clonedProjectBoardThree;
        //
        // creating Kanban Card data 
        leankor__KanbanCard__c KanbanCard = new leankor__KanbanCard__c();
        KanbanCard.Name = 'Kanban';
        KanbanCard.leankor__GUID__c = clonedProjectBoardThree.Id +'-'+'kmmg';
        KanbanCard.leankor__ValueStream__c = clonedProjectBoardThree.Id;             
        insert KanbanCard;
               
        leankor__KanbanCard__c cloneKanbanParent = new leankor__KanbanCard__c();
        cloneKanbanParent.Name = 'ParentKanban';  
        cloneKanbanParent.leankor__GUID__c = sourceKanbanParent.Id+'-'+'gd';      
        cloneKanbanParent.leankor__ValueStream__c = clonedProjectBoardOne.Id;             
        insert cloneKanbanParent;
              
        leankor__KanbanCard__c cloneKanbanChild = new leankor__KanbanCard__c();
        cloneKanbanChild.Name = 'ChildKanban';  
        cloneKanbanChild.leankor__GUID__c = CloneKanbanParent.Id+'-'+'ft';
        cloneKanbanChild.leankor__ValueStreamCardLink__c = cloneKanbanParent.Id;
        cloneKanbanChild.leankor__ValueStreamLink__c = projectBoardOne.id;     
        cloneKanbanChild.leankor__ValueStream__c = clonedProjectBoardOne.Id;     
        insert cloneKanbanChild;
        
        leankor__KanbanCard__c cloneKanbanSample = new leankor__KanbanCard__c();
        cloneKanbanSample.Name = 'ChildKanban';  
        cloneKanbanSample.leankor__GUID__c = CloneKanbanParent.Id+'-'+'ftrft';
        cloneKanbanSample.leankor__ValueStreamCardLink__c = null;
        cloneKanbanSample.leankor__ValueStreamLink__c = clonedProjectBoardOne.id;     
        cloneKanbanSample.leankor__ValueStream__c = clonedProjectBoardOne.Id;      
        insert cloneKanbanSample;                                                     
    
    
    }   
}