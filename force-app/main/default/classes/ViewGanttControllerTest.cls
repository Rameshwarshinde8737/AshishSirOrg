/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@isTest
private class ViewGanttControllerTest {
 	@testSetup static void testData() {		
		User u = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', u); 
 	 	leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]);        
 	    //List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> kanbancardList=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,null,u); 	    	  	    
 	} 
 	 /*
 	   Date :- 31/10/18
 	   To cover checkAccessForBoards method.
 	 */ 
	@isTest
    private static void checkAccessForBoardsTest() {
        List<leankor__ValueStream__c> valuestreamlist =[Select Id, 
																Name 
															From leankor__ValueStream__c];
        Test.startTest();
        	List<String> ids =new List<String>();
          	for(leankor__ValueStream__c vs:valuestreamlist){
          		ids.add(vs.id);
          	}
        	System.assert(leankor.ViewGanttController.checkAccessForBoards(ids)!=null,'checkAccessForBoards method is not working');  
        	System.assertNotEquals(leankor.ViewGanttController.getFolderId(ids[0]),null,'getFolderId method is not working');
        Test.stopTest();  
    }
	
	@isTest
	private static void checkAccessForBoardsTestSecond() {
		List<leankor__ProjectRoom__c> projectList = [Select Id, 
															Name 
														From leankor__ProjectRoom__c
														Where Name = 'Test Project'];
		Test.startTest();
			try{
				List<ViewGanttController.CheckAccessWrapper>  checkAccessNegative = leankor.ViewGanttController.checkAccessForBoards(new List<String>{projectList[0].Id});
			}
			catch (Exception e) {
				System.Assert(e.getMessage().contains('Invalid input'),'checkAccessForBoards method is not working');
			}
		Test.stopTest();
	}

	@isTest
	private static void getAllProjectOfFolderWithoutSharingTest() {
		List<leankor__Portfolio__c> portfolioList = [Select Id, 
															Name 
														From leankor__Portfolio__c
														Where Name = 'Test Folder-1'];
		List<leankor__ProjectRoom__c> projectList = new List<leankor__ProjectRoom__c>();
		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test Project';
		project.leankor__Portfolio__c = portfolioList[0].Id;
		projectList.add(project);
		insert projectList;
		List<leankor__ProjectRoom__c> projects = leankor.ViewGanttController.getAllProjectOfFolderWithoutSharing(new List<leankor__Portfolio__c>{portfolioList[0]});
		System.assertEquals('Test Project', projects[0].Name,'getAllProjectOfFolderWithoutSharing method is not working');
	}
	/*
    Date :- 31/10/18
    To cover getViolatedActivities method.
    */
	@isTest
    private static void getViolatedActivitiesTest() {
     	ViewGanttController  viewGant= new ViewGanttController();      	
     	List<leankor__KanbanCard__c> valueStreamCardLink = [Select Id,
																	Name,
																	leankor__DueDate__c,
																	leankor__StartDate__c,
																	leankor__BoardType__c,
																	RecordType.Name 
																From leankor__KanbanCard__c];                              
        leankor__ValueStream__c  valuestream =new leankor__ValueStream__c();
		valuestream.Name='Kanban Board';
		valuestream.leankor__BoardType__c='Kanban Board';
		valuestream.leankor__IsRecordDeleted__c=false;
        insert valuestream;        	  
        List<leankor__KanbanCard__c> kanbancardList= new  List<leankor__KanbanCard__c>();
		for(Integer i=0;i<5;i++){
			leankor__KanbanCard__c kb=new leankor__KanbanCard__c();
			kb.name='testkanban';
			kb.leankor__ValueStream__c=valuestream.id;	    	     	 
			kb.leankor__valueStreamCardLink__c= valueStreamCardLink[0].id;
			kb.leankor__StartDate__c=System.today()-5-i; 
			kb.leankor__DueDate__c=System.today()+15+i; 	    	     
			kb.leankor__GUID__c=leankor.TestDataFactory.createGuid(); 
			kb.leankor__IsRecordDeleted__c=false;
			kanbancardList.add(kb);		     	    	     	
		}  
 	    insert kanbancardList;
 	    Test.startTest();	 	    	   	
      		System.assert(leankor.RealTimeControllerHelper.getViolatedActivities()!=null,'getViolatedActivities method is not working');      		
      	Test.stopTest();
    }
	@isTest
    static void coverAllConstructorsAndMethods() {
        // Default constructor
        ViewGanttController c1 = new ViewGanttController();
        
        // StandardController constructor
        leankor__ProjectRoom__c p = [Select Id 
										From leankor__ProjectRoom__c Limit 1];
        ApexPages.StandardController std = new ApexPages.StandardController(p);
        ViewGanttController c2 = new ViewGanttController(std);
        
        // StandardSetController constructor
        List<leankor__ProjectRoom__c> plist = [Select Id 
													From leankor__ProjectRoom__c Limit 1];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(plist);
        ViewGanttController c3 = new ViewGanttController(ssc);
        
        // Util constructor
        ViewGanttController c4 = new ViewGanttController(new leankor.Util()); // or use mock/stub
        
        // Call Calendar_View
        PageReference ref = c1.Calendar_View();
        System.assertEquals(null, ref,'Assertion failed: Calendar_View() should return null');
    }
	@isTest
	private static void coverGetViolatedActivitiesMethod() {
		Test.startTest();
		List<leankor__KanbanCard__c> result = ViewGanttController.getViolatedActivities();
		Test.stopTest();
		
		System.assertNotEquals(null, result, 'getViolatedActivities() should not return null');
	}
}