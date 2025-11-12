/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MoveWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private with sharing class MoveWorkItemActionTest {

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover moveKanbanCardProcess Method inside MoveWorkItemAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void moveKanbanCardProcessTest() { 
        Test.startTest();
        User u = leankor.TestDataFactory.createStandardUser('Lean123');
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', u);
		List<leankor__ValueStream__c> valuestreamlistForPotfolio = leankor.TestDataFactory.createValueStream(projectList, 'Portfolio View', u); 
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlistForPotfolio[0]);
		//List<leankor__Kanbancard__c> listOfKanbanCards =  leankor.TestDataFactory.createKanbanCard(valuestreamlistForPotfolio[0],template,5,Null,u);
    	List<leankor__MasterContainer__c> mastercontainerList=new List<leankor__MasterContainer__c>();


 		for (Integer i = 0;i < 6; i++) {
 			leankor__MasterContainer__c mastercontainer = new leankor__MasterContainer__c ();
 			mastercontainer.leankor__Valuestream__C = valuestreamlist[0].id;	
 			mastercontainer.Name = (i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
 			mastercontainer.leankor__GUID__c = leankor.TestDatafactory.createguid();
 			mastercontainer.leankor__Type__c  =(i==0?'Template':(i==1?'Backlog':(i==2||i==3 ||i==4?'Regular':(i==5?'Archive':'Regular'))));
 			mastercontainer.leankor__Title__c=(i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
 			mastercontainerList.add(mastercontainer);
 		}				
    	insert mastercontainerList;

 		List<leankor__Swimlane__c> swimlaneList=new List<leankor__Swimlane__c>();
 		for (leankor__MasterContainer__c mc : mastercontainerList) {	
 			leankor__Swimlane__c swimlane = new leankor__Swimlane__c();
 			swimlane.Name = 'Default Swimlane';
 			swimlane.leankor__GUID__c = TestDataFactory.createguid();
 			swimlane.leankor__MasterContainer__c = mc.id;
 			swimlane.leankor__ValueStream__c = mc.leankor__ValueStream__c;
 	 		swimlaneList.add(swimlane);
 		}
 		insert swimlaneList;

    	List<leankor__Zone__c> zoneList =new List<leankor__Zone__c>();
    	Integer intNum=0;
    	for (leankor__Swimlane__c sw : swimlaneList) {
    		leankor__Zone__c zone = new leankor__Zone__c();
    		zone.name = 'Default column' + intNum++;
    		zone.leankor__Swimlane__c = sw.id;
    		zone.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		zone.leankor__ValueStream__c = sw.leankor__ValueStream__c;
    		zoneList.add(zone);
    	}
    	insert zoneList;   	

    	List<leankor__Kanbancard__c> kanbancards=new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kb = new leankor__Kanbancard__c();
    		kb.Name = 'kanbancard12';
    		kb.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		kb.leankor__Zone__c = zone.id;
    		kb.leankor__Swimlane__c = zone.leankor__Swimlane__c;
    		kb.leankor__ValueStream__c = zone.leankor__ValueStream__c;
    		kb.leankor__MasterContainer__c = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
    		kb.leankor__ZoneGUID__c = zone.leankor__Guid__c;
    		kanbancards.add(kb);
    	}
    	insert kanbancards; 

    	List<leankor.MoveWorkItemAction.KanbanCardRequest> kanbanCardRequestList = New List<leankor.MoveWorkItemAction.KanbanCardRequest> ();
    	for (leankor__Kanbancard__c kb : kanbancards) {
    		system.debug(kb.Zone__c);
    		leankor.MoveWorkItemAction.KanbanCardRequest request = new leankor.MoveWorkItemAction.KanbanCardRequest();
    		request.id = kb.id;   		
    		request.MCName = 'Template' ;   		
    		request.SwimlaneName = 'Default Swimlane';
    		request.ColumnName = 'Default column';
    		kanbanCardRequestList.add(request);
    	}
    	System.assert(leankor.MoveWorkItemAction.moveKanbanCardProcess(kanbanCardRequestList).size() > 0, 'Method Executed Successfully.');
        Test.stopTest();
    }


	@isTest
    private static void moveKanbanCardProcessWBSAndSequenceNumber() { 
        Test.startTest();
        User u = leankor.TestDataFactory.createStandardUser('Lean123');
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', u);
		List<leankor__ValueStream__c> valuestreamlistForPotfolio = leankor.TestDataFactory.createValueStream(projectList, 'Portfolio View', u); 
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlistForPotfolio[0]);
		//List<leankor__Kanbancard__c> listOfKanbanCards =  leankor.TestDataFactory.createKanbanCard(valuestreamlistForPotfolio[0],template,5,Null,u);
    	List<leankor__MasterContainer__c> mastercontainerList=new List<leankor__MasterContainer__c>();


 		for (Integer i=0;i<6;i++) {
 			leankor__MasterContainer__c mastercontainer = new leankor__MasterContainer__c ();
 			mastercontainer.leankor__Valuestream__C = valuestreamlist[0].id;	
 			mastercontainer.Name = (i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
 			mastercontainer.leankor__GUID__c = leankor.TestDatafactory.createguid();
 			mastercontainer.leankor__Type__c  =(i==0?'Template':(i==1?'Backlog':(i==2||i==3 ||i==4?'Regular':(i==5?'Archive':'Regular'))));
 			mastercontainer.leankor__Title__c=(i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
 			mastercontainerList.add(mastercontainer);
 		}				
    	insert mastercontainerList;

 		List<leankor__Swimlane__c> swimlaneList = new List<leankor__Swimlane__c>();
 		for (leankor__MasterContainer__c mc : mastercontainerList) {	
 			leankor__Swimlane__c swimlane = new leankor__Swimlane__c();
 			swimlane.Name = 'Default Swimlane';
 			swimlane.leankor__GUID__c = TestDataFactory.createguid();
 			swimlane.leankor__MasterContainer__c = mc.id;
 			swimlane.leankor__ValueStream__c = mc.leankor__ValueStream__c;
 	 		swimlaneList.add(swimlane);
 		}
 		insert swimlaneList;

    	List<leankor__Zone__c> zoneList =new List<leankor__Zone__c>();
    	Integer intNum=0;
    	for (leankor__Swimlane__c sw : swimlaneList) {
    		leankor__Zone__c zone = new leankor__Zone__c();
    		zone.name = 'Default column'+intNum++;
    		zone.leankor__Swimlane__c = sw.id;
    		zone.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		zone.leankor__ValueStream__C = sw.leankor__ValueStream__C;
    		zoneList.add(zone);
    	}
    	insert zoneList;   	

    	List<leankor__Kanbancard__c> kanbancards = new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kb = new leankor__Kanbancard__c();
    		kb.Name = 'kanbancard12';
    		kb.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		kb.leankor__Zone__c = zone.id;
    		kb.leankor__Swimlane__C = zone.leankor__Swimlane__C;
    		kb.leankor__ValueStream__C = zone.leankor__ValueStream__C;
    		kb.leankor__MasterContainer__c = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
    		kb.leankor__ZoneGUID__c = zone.leankor__Guid__c;
    		kanbancards.add(kb);
    	}
    	insert kanbancards; 

    	List<leankor.MoveWorkItemAction.KanbanCardRequest> kanbanCardRequestList = New List<leankor.MoveWorkItemAction.KanbanCardRequest> ();
    	for (leankor__Kanbancard__c kb : kanbancards) {
    		system.debug(kb.Zone__c);
    		leankor.MoveWorkItemAction.KanbanCardRequest request = new leankor.MoveWorkItemAction.KanbanCardRequest();
    		request.id = kb.id;   		
    		request.MCName = 'Template' ;   		
    		request.SwimlaneName = 'Default Swimlane';
    		request.ColumnName = 'Default column';
    		request.generateWorkBreakdownStructure = true;
    		kanbanCardRequestList.add(request);
    	}
    	System.assert(leankor.MoveWorkItemAction.moveKanbanCardProcess(kanbanCardRequestList).size() > 0, 'Method Executed Successfully.');
        Test.stopTest();
    }
}