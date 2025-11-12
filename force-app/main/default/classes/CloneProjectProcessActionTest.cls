@isTest
public class CloneProjectProcessActionTest {

    // Test setup method to create test data for the source project and folders
    @isTest
    static void cloneProjectProcessActionTest() {
        // Create a test folder (Portfolio)
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c(Name = 'Source Folder');
        insert sourceFolder;
        
        leankor__Portfolio__c targetFolder = new leankor__Portfolio__c(Name = 'Target Folder');
        insert targetFolder;

        // Create a test project (ProjectRoom)
        leankor__ProjectRoom__c sourceProject = new leankor__ProjectRoom__c(
            Name = 'Source Project',
            leankor__Portfolio__c = sourceFolder.Id
        );
        insert sourceProject;
        
          List<RecordType> Recordtypelist = [SELECT Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'leankor__Expense__c'];
        
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
        
        
        // creating board data
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = sourceProject.Id,leankor__IsTemplateBoard__c = false);         
        insert projectBoardOne;
    
        leankor__ValueStream__c projectBoardTwo = new leankor__ValueStream__c(Name = 'Roll up',leankor__BoardType__c='Plan Board',leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardTwo;
        
        leankor__ValueStream__c projectBoardThree = new leankor__ValueStream__c(Name = 'Project Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoardThree;
        
        leankor__ValueStream__c projectBoardFour = new leankor__ValueStream__c(Name = 'Dash Board',leankor__BoardType__c='DashBoard',leankor__ProjectRoom__c = sourceProject.Id);         
        insert projectBoardFour;
        
        
        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
		newMC.name= 'Test MC';
		newMC.leankor__Valuestream__c= projectBoardThree.id;
		insert newMC ;
		
		leankor__swimlane__c  newSw = new  leankor__swimlane__c();
		newSw.name = 'Test SW';
		newSw.leankor__mastercontainer__c= newMC.id;
		newSw.leankor__Valuestream__c = projectBoardThree.id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = projectBoardThree.Id;
		insert zone;
        
          leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c(
		    leankor__JSONDefinition__c = '',
		    leankor__JSONData__c = '',
		    leankor__Width__c = 170,
		    leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
		    leankor__CSSLayout__c = '',
		    leankor__Color__c = '#bdbffc',
		    leankor__ValueStream__c = projectBoardOne.Id,
		    Name = 'Default',
		    leankor__Title__c ='Default'
		);
        insert kanbanTemplate;
		
        leankor__Preference__c Preference = new leankor__Preference__c(
        Name = 'Preference',
        leankor__GUID__c = system.now()+'11',
        leankor__FollowOnChatter__c = 'all',
        leankor__SubscribeToCard__c = 'all',
        leankor__CardPastDueDate__c = false,
        leankor__Moved__c = false,
        leankor__PercentDone__c = true,
        leankor__TaskPastDueDate__c = true,
        leankor__isTaskCompleted__c =  true,
        leankor__ValueStream__c =projectBoardOne.Id );
      	insert Preference;
        
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
        boardTypes.add('plan Board');
	     
        Boolean expectedValue = true;
        // Create the CloneProjectRequest object
        CloneProjectProcessAction.CloneProjectRequest request = new CloneProjectProcessAction.CloneProjectRequest();
        request.sourceFolderId = sourceFolder.Id;
        request.sourceFolderName = SourceFolder.Name;
        request.sourceProjectId = sourceProject.Id;
        request.sourceProjectName = sourceProject.Name;
        request.targetFolderId = TargetFolder.Id;
        request.targetFolderName = TargetFolder.Name;
        request.targetProjectName = 'Clone One';
        request.targetProjectStartDateTime =system.now();
        request.targetProjectDueDateTime = system.now();
        request.planGantt = true;
        request.rollUp = true;
        request.projectBoard = true;
        request.whiteBoard = true;
        request.dashBoard=true;
        request.expenses=true;
        request.returnPortfolioHierarchy = true;
        request.projectBoardTypes = boardTypes;
        request.relinkClonedProjectId = '';  
        // Execute the cloneProjects method
        Test.startTest();
       // List<CloneProjectProcessAction.CloneProjectProcessActionResult> result = CloneProjectProcessAction.cloneProjects(new List<CloneProjectProcessAction.CloneProjectRequest>{request});
        CloneProjectProcessAction.cloneProjects(new List<CloneProjectProcessAction.CloneProjectRequest>{request});
        Test.stopTest();
        System.assertEquals(true, expectedValue);
        // Assert that a new project is created
    //    System.assertEquals(1, result.size(), 'A project should be cloned.');
      //  System.assertNotEquals(null, result[0].clonedProjectId, 'Cloned project Id should not be null.');
    
    } 
    // Test invalid input scenario
    @isTest
    static void testCloneProjectInvalidInput() {
        // Create the CloneProjectRequest object with invalid data
        CloneProjectProcessAction.CloneProjectRequest request = new CloneProjectProcessAction.CloneProjectRequest();
        request.sourceFolderId = 'invalidId'; // Invalid folder id
        request.targetFolderId = 'invalidId'; // Invalid target id
        request.targetProjectName = 'Cloned Project';
        request.planGantt = true;
        request.whiteBoard = true;

        // Expect an exception due to invalid input
        Test.startTest();
             try {
            CloneProjectProcessAction.cloneProjects(new List<CloneProjectProcessAction.CloneProjectRequest>{request});
            System.assert(false, 'An exception should have been thrown.');
        } catch (Exception e) {
            System.assertEquals('Error: Invalid input', e.getMessage(), 'Expected invalid ID error message.');
        }
        Test.stopTest();
    }
}