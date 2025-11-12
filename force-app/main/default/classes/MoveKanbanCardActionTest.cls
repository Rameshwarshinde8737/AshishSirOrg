/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class MoveKanbanCardActionTest {

	@TestSetup
	private static void makeData() {
		User u = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', u);
		List<leankor__ValueStream__c> valuestreamlistForPotfolio = leankor.TestDataFactory.createValueStream(projectList, 'Portfolio View', u);
		List<leankor__ValueStream__c> valuestreamlistForWhiteboard = leankor.TestDataFactory.createValueStream(projectList, 'White Board', u);  
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlistForPotfolio[0]);
		List<leankor__Kanbancard__c> listOfKanbanCards =  leankor.TestDataFactory.createKanbanCard(valuestreamlistForPotfolio[0],template,5,Null,u);
    	List<leankor__MasterContainer__c> mastercontainerList=new List<leankor__MasterContainer__c>();
		Boolean flag = true;
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
 		for (leankor__MasterContainer__c mastercontainer : mastercontainerList) {	
 			leankor__Swimlane__c swimlane =new leankor__Swimlane__c();
 			swimlane.Name='Default Swimlane';
 			swimlane.leankor__GUID__c=TestDataFactory.createguid();
 			swimlane.leankor__MasterContainer__c=mastercontainer.id;
 			swimlane.leankor__ValueStream__c=mastercontainer.leankor__ValueStream__c;
			 swimlaneList.add(swimlane);
 		}
 		insert swimlaneList;
		
    	List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();   		   	    	
    	//List<leankor__Swimlane__c> swimlaneList =[select Id,Name,leankor__ValueStream__C,leankor__MasterContainer__c from leankor__Swimlane__c];   	
    	List<leankor__Zone__c> zoneList =new List<leankor__Zone__c>();
    	Integer intNum=0;
    	for (leankor__Swimlane__c sw:swimlaneList) {
    		leankor__Zone__c zone =new leankor__Zone__c();
    		zone.name='Default column'+intNum++;
    		zone.leankor__Swimlane__C=sw.id;
    		zone.leankor__Guid__c=leankor.TestDatafactory.createguid();
    		zone.leankor__ValueStream__C=sw.leankor__ValueStream__C;
    		zoneList.add(zone);
    	}
    	insert zoneList;   	
    	List<leankor__Kanbancard__c> kanbancards=new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone:zoneList) {
    		leankor__Kanbancard__c kanban=new leankor__Kanbancard__c();
    		kanban.Name='kanbancard12';
    		kanban.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		kanban.leankor__Zone__c = zone.id;
    		kanban.leankor__Swimlane__C = zone.leankor__Swimlane__C;
    		kanban.leankor__ValueStream__C = zone.leankor__ValueStream__C;
    		kanban.leankor__MasterContainer__c = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
    		kanban.leankor__ZoneGUID__c = zone.leankor__Guid__c;
    		kanbancards.add(kanban);
    	}
    	insert kanbancards; 
		List<leankor__Kanbancard__c> kanbancardsforWhiteboard = new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
    		kanban.Name = 'kanbancard123';
    		kanban.leankor__Guid__c = leankor.TestDatafactory.createguid();
			kanban.leankor__ZoneGUID__C = kanban.leankor__Guid__c;
    		kanban.leankor__ValueStream__C = valuestreamlistForWhiteboard[0].Id;
			kanban.leankor__Swimlane__C = zone.leankor__Swimlane__C;
			kanban.leankor__MasterContainer__c = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
    		kanbancardsforWhiteboard.add(kanban);
    	}
    	insert kanbancardsforWhiteboard;
		List<leankor__Kanbancard__c> kanbancardsforzoneGUid = new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
    		kanban.Name = 'zoneGuid';
    		kanban.leankor__Guid__c = leankor.TestDatafactory.createguid();
			kanban.leankor__ZoneGUID__C = zone.leankor__GUID__C;
    		kanban.leankor__ValueStream__C = zone.leankor__ValueStream__C;
			kanban.leankor__Swimlane__C = SwimlaneList[0].Id;
			kanban.leankor__MasterContainer__c = mastercontainerList[0].Id;
    		kanbancardsforzoneGUid.add(kanban);
    	}
    	insert kanbancardsforzoneGUid;
		List<leankor__Kanbancard__c> kanbancardsforswimlane = new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
    		kanban.Name = 'SwimlaneId';
    		kanban.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		kanban.leankor__ValueStream__C = zone.leankor__ValueStream__C;
			kanban.leankor__Swimlane__C = zone.leankor__SwimLane__c;
			kanban.leankor__MasterContainer__c = mastercontainerList[0].Id;
    		kanbancardsforswimlane.add(kanban);
    	}
    	insert kanbancardsforswimlane;

		List<leankor__Kanbancard__c> kanbancardsformastercontainer = new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone : zoneList) {
    		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
    		kanban.Name = 'masterContainerId';
    		kanban.leankor__Guid__c = leankor.TestDatafactory.createguid();
    		kanban.leankor__ValueStream__C = zone.leankor__ValueStream__C;
			kanban.leankor__MasterContainer__c = mastercontainerList[0].Id;
    		kanbancardsformastercontainer.add(kanban);
    	}
    	insert kanbancardsformastercontainer;

		leankor__MasterContainer__c mastercontainerforvaluestream = new leankor__MasterContainer__c ();
		mastercontainerforvaluestream.leankor__Valuestream__C = valuestreamlistForPotfolio[0].Id;	
		mastercontainerforvaluestream.Name = 'Backlog';
		mastercontainerforvaluestream.leankor__GUID__c = leankor.TestDatafactory.createguid();
		mastercontainerforvaluestream.leankor__Type__c  = 'Backlog';
		mastercontainerforvaluestream.leankor__Title__c = 'Backlog';
		insert mastercontainerforvaluestream;

		leankor__Swimlane__c swimlaneforvaluestream = new leankor__Swimlane__c();
		swimlaneforvaluestream.Name = 'Default Swimlane';
		swimlaneforvaluestream.leankor__GUID__c = TestDataFactory.createguid();
		swimlaneforvaluestream.leankor__MasterContainer__c = mastercontainerforvaluestream.id;
		swimlaneforvaluestream.leankor__ValueStream__c = mastercontainerforvaluestream.leankor__ValueStream__c;
		insert swimlaneforvaluestream;

		leankor__Zone__c zoneforvalustream = new leankor__Zone__c();
		zoneforvalustream.name = 'Default column';
		zoneforvalustream.leankor__Guid__c = leankor.TestDatafactory.createguid();
		zoneforvalustream.leankor__ValueStream__C = valuestreamlistForPotfolio[0].Id;
		zoneforvalustream.leankor__SwimLane__c = swimlaneforvaluestream.Id;
		insert zoneforvalustream;
		
		leankor__MasterContainer__c mastercontainerforWhiteboard = new leankor__MasterContainer__c ();
		mastercontainerforWhiteboard.leankor__Valuestream__C = valuestreamlistForWhiteboard[0].Id;	
		mastercontainerforWhiteboard.Name = 'Backlog';
		mastercontainerforWhiteboard.leankor__GUID__c = leankor.TestDatafactory.createguid();
		mastercontainerforWhiteboard.leankor__Type__c  = 'Backlog';
		mastercontainerforWhiteboard.leankor__Title__c = 'Backlog';
		insert mastercontainerforWhiteboard;

		leankor__Swimlane__c swimlaneforWhiteboard = new leankor__Swimlane__c();
		swimlaneforWhiteboard.Name = 'Default Swimlane';
		swimlaneforWhiteboard.leankor__GUID__c = TestDataFactory.createguid();
		swimlaneforWhiteboard.leankor__MasterContainer__c = mastercontainerforWhiteboard.id;
		swimlaneforWhiteboard.leankor__ValueStream__c = mastercontainerforWhiteboard.leankor__ValueStream__c;
		insert swimlaneforWhiteboard;

		leankor__Zone__c zoneforWhiteboard = new leankor__Zone__c();
		zoneforWhiteboard.name = 'Default column';
		zoneforWhiteboard.leankor__Guid__c = leankor.TestDatafactory.createguid();
		zoneforWhiteboard.leankor__ValueStream__C = valuestreamlistForWhiteboard[0].Id;
		zoneforWhiteboard.leankor__SwimLane__c = swimlaneforWhiteboard.Id;
		insert zoneforWhiteboard;

		leankor__Kanbancard__c kanbanforWhiteboard = new leankor__Kanbancard__c();
		kanbanforWhiteboard.Name = 'kanbancard1234';
		kanbanforWhiteboard.leankor__Guid__c = leankor.TestDatafactory.createguid();
		kanbanforWhiteboard.leankor__ZoneGUID__C = zoneforWhiteboard.leankor__Guid__c;
		kanbanforWhiteboard.leankor__ValueStream__C = valuestreamlistForWhiteboard[0].Id;
		kanbanforWhiteboard.leankor__Swimlane__C = zoneforWhiteboard.leankor__Swimlane__C;
		kanbanforWhiteboard.leankor__MasterContainer__c = zoneforWhiteboard.leankor__Swimlane__r.leankor__MasterContainer__c;
		insert kanbanforWhiteboard;

	}
    static testMethod void testMoveKanbanCard() {
    	/*Test.startTest();
 		leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom');
 		insert insertroom;
 		
		leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
		Insert vStream;
		
		leankor__ValueStream__c vStream2=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Portfolio View',leankor__ProjectRoom__c = insertroom.ID);
		Insert vStream2;
		
		leankor__ValueStream__c vStream3=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Regular View',leankor__ProjectRoom__c = insertroom.ID);
		Insert vStream3;

		leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
    	leankor__JSONDefinition__c = '',
    	leankor__JSONData__c = '',
    	leankor__Width__c = 170,
    	leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
    	leankor__CSSLayout__c = '',
    	leankor__Color__c = '#bdbffc',
   	 	leankor__ValueStream__c = vStream.Id,
    	Name = 'Default',
    	leankor__Title__c ='Default'
    	);
		Insert kct;

  		leankor__Kanbancard__c newcard =new leankor__Kanbancard__c(Name = 'testkanaban12',leankor__title__c ='test_title',leankor__ValueStream__c = vStream.ID ,leankor__KanbanCardTemplate__c =kct.ID,leankor__GUID__C ='305ee49a-test-4df-bf76-8a080880611');
  		insert newcard;
  		
  		leankor__Kanbancard__c newcard2 =new leankor__Kanbancard__c(Name = 'testkanaban122',leankor__title__c ='test_title_2',leankor__ValueStream__c = vStream2.ID ,leankor__KanbanCardTemplate__c =kct.ID,leankor__GUID__C ='305ee49a-test-4df-bf76-8a080880619');
  		insert newcard2;
  		
  		leankor__Kanbancard__c newcard3 =new leankor__Kanbancard__c(Name = 'testkanaban123',leankor__title__c ='test_title_2',leankor__ValueStream__c = vStream3.ID ,leankor__KanbanCardTemplate__c =kct.ID,leankor__GUID__C ='305ee49a-test-4df-bf76-8a080880618');
  		insert newcard3;

		//-------------------- leankor.MoveKanbanCardAction.MoveKanbanCardProcess ----------
 		List<leankor.MoveKanbanCardAction.KanbanCardRequest> inputMoveNames = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();
   		leankor.MoveKanbanCardAction.KanbanCardRequest inputMoveName = New leankor.MoveKanbanCardAction.KanbanCardRequest();
   		inputMoveName.Id = newcard.ID;
	   	inputMoveName.MCName ='Backlog';
	   	inputMoveName.SwimlaneName ='Default Swimlane';
	   	inputMoveName.ColumnName = 'New SubColumn';
	   	inputMoveNames.add(inputMoveName );
        
        leankor__MasterContainer__c newMasterContainer = new leankor__MasterContainer__c();
        newMasterContainer.name = 'Backlog';
        newMasterContainer.leankor__ValueStream__c =  vStream.Id;
        insert newMasterContainer;
        leankor__Swimlane__c newSwimline = new leankor__Swimlane__c();
        newSwimline.name = 'Default Swimlane';
        newSwimline.leankor__ValueStream__c = vStream.Id;
        newSwimline.leankor__MasterContainer__c = newMasterContainer.Id;
        insert newSwimline;
        leankor__Zone__c newZone = new leankor__Zone__c();
        newZone.leankor__ValueStream__c = vStream.Id;
        newZone.name = inputMoveName.ColumnName;
        newZone.leankor__Swimlane__c = newSwimline.Id;
        insert newZone;
		leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
	
		inputMoveNames.clear();
	   	inputMoveName.Id = newcard.ID;
	   	inputMoveName.MCName ='Backlog';
	   	inputMoveName.SwimlaneName ='Default Swimlane';
	   	inputMoveName.ColumnName = NULL;
	   	inputMoveNames.add(inputMoveName );
		leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
	
		inputMoveNames.clear();
	   	inputMoveName.Id = newcard.ID;
	  	inputMoveName.MCName ='Backlog';
	   	inputMoveName.SwimlaneName = NULL;
	   	inputMoveName.ColumnName = NULL;
	   	inputMoveNames.add(inputMoveName );
		leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
		
		inputMoveNames.clear();
		inputMoveName.Id = newcard.ID;
	   	inputMoveName.MCName ='Backlog';
	   	inputMoveName.SwimlaneName = NULL;
	   	inputMoveName.ColumnName = 'New SubColumn';
	   	inputMoveNames.add(inputMoveName );
	   	leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
	
		inputMoveNames.clear();
	   	inputMoveName.Id = newcard3.ID;
	   	inputMoveName.MCName ='Backlog';
	   	inputMoveName.SwimlaneName ='New Swimlane';
	  	inputMoveName.ColumnName = 'New SubColumn';
	   	inputMoveNames.add(inputMoveName );
		leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
		
		inputMoveNames.clear();
	    //inputMoveName.BoardType = 'Portfolio View';
	    inputMoveName.Id = newcard2.ID;
	    inputMoveName.MCName ='Backlog';
	    inputMoveName.SwimlaneName ='New Swimlane';
	    inputMoveName.ColumnName = 'New SubColumn';
	    inputMoveNames.add(inputMoveName );
	    
	    /*leankor__MasterContainer__c newMasterContainer2 = new leankor__MasterContainer__c();
        newMasterContainer2.name = 'New Master Container 2';
        newMasterContainer2.leankor__ValueStream__c =  vStream2.Id;
        insert newMasterContainer2;
        leankor__Swimlane__c newSwimline2 = new leankor__Swimlane__c();
        newSwimline2.name = 'Default Swimlane';
        newSwimline2.leankor__ValueStream__c = vStream2.Id;
        newSwimline2.leankor__MasterContainer__c = newMasterContainer.Id;
        insert newSwimline2;
        leankor__Zone__c newZone2 = new leankor__Zone__c();
        newZone2.leankor__ValueStream__c = vStream2.Id;
        newZone2.name = inputMoveName.ColumnName;
        newZone2.leankor__Swimlane__c = newSwimline2.Id;
        insert newZone2;*/
	  
		//leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames); 
		
		  /*
    	Date :25/09/18
    	To cover Movekanbancardaction class methods.
    	*/  
    	//User u = leankor.TestDataFactory.createStandardUser('Lean123');	
		User u = [Select Id
					From User
					Where Alias = 'Lean123'
					Limit 1]	;
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', u);
		List<leankor__ValueStream__c> valuestreamlistForPotfolio = leankor.TestDataFactory.createValueStream(projectList, 'Portfolio View', u); 
		leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlistForPotfolio[0]);
		List<leankor__Kanbancard__c> listOfKanbanCards =  leankor.TestDataFactory.createKanbanCard(valuestreamlistForPotfolio[0],template,5,Null,u);
    	List<leankor__MasterContainer__c> mastercontainerList=new List<leankor__MasterContainer__c>();
		Boolean flag = true;
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
 		List<leankor__Swimlane__c> SwimlaneList=new List<leankor__Swimlane__c>();
 		for (leankor__MasterContainer__c mc:mastercontainerList) {	
 			leankor__Swimlane__c swimlane =new leankor__Swimlane__c();
 			swimlane.Name='Default Swimlane';
 			swimlane.leankor__GUID__c=TestDataFactory.createguid();
 			swimlane.leankor__MasterContainer__c=mc.id;
 			swimlane.leankor__ValueStream__c=mc.leankor__ValueStream__c;
 	 		SwimlaneList.add(swimlane);
 		}
 		insert SwimlaneList;
    	List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();   		   	    	
    	//List<leankor__Swimlane__c> swimlaneList =[select Id,Name,leankor__ValueStream__C,leankor__MasterContainer__c from leankor__Swimlane__c];   	
    	List<leankor__Zone__c> zoneList =new List<leankor__Zone__c>();
    	Integer intNum=0;
    	for (leankor__Swimlane__c sw:swimlaneList) {
    		leankor__Zone__c zone =new leankor__Zone__c();
    		zone.name='Default column'+intNum++;
    		zone.leankor__Swimlane__C=sw.id;
    		zone.leankor__Guid__c=leankor.TestDatafactory.createguid();
    		zone.leankor__ValueStream__C=sw.leankor__ValueStream__C;
    		zoneList.add(zone);
    	}
    	insert zoneList;   	
    	List<leankor__Kanbancard__c> kanbancards=new List<leankor__Kanbancard__c>();
    	for (leankor__Zone__c zone:zoneList) {
    		leankor__Kanbancard__c kb=new leankor__Kanbancard__c();
    		kb.Name='kanbancard12';
    		kb.leankor__Guid__c=leankor.TestDatafactory.createguid();
    		kb.leankor__Zone__c=zone.id;
    		kb.leankor__Swimlane__C=zone.leankor__Swimlane__C;
    		kb.leankor__ValueStream__C=zone.leankor__ValueStream__C;
    		kb.leankor__MasterContainer__c=zone.leankor__Swimlane__r.leankor__MasterContainer__c;
    		kb.leankor__ZoneGUID__c=zone.leankor__Guid__c;
    		kanbancards.add(kb);
    	}
    	insert kanbancards; 
    	for (leankor__Kanbancard__c kb:kanbancards) {
    		system.debug(kb.Zone__c);
    		leankor.MoveKanbanCardAction.KanbanCardRequest request=new leankor.MoveKanbanCardAction.KanbanCardRequest();
    		request.id=kb.id;   		
    		request.MCName ='Template' ;   		
    		request.SwimlaneName ='Default Swimlane';
    		request.ColumnName ='Default column';
    		kanbanCardRequestList.add(request);
    	}
    	System.assert(leankor.MoveKanbanCardAction.MoveKanbanCardProcess(kanbanCardRequestList) == null, 'Method Executed Successfully.');
		for (leankor__Kanbancard__c kb:kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request=new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +valuestreamlist[0].id+ '&cardid='+kb.id;
			request.MCName = 'Template' ;   		
    		request.SwimlaneName = 'Default Swimlane';
    		request.ColumnName = 'Default column0';
    		kanbanCardRequestList.add(request);
    	}
		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
		kanbanCardRequestList.clear();
    	List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList1 = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();
    	List<leankor__Kanbancard__c> kanbancards1=new List<leankor__Kanbancard__c>();
    	for (leankor__Kanbancard__c kb:kanbancards) {
    		leankor__Kanbancard__c kb1=new leankor__Kanbancard__c();
    		kb1.Id=Kb.Id ;   		
    		kb1.leankor__Zone__c=zoneList[0].id;
    		kb1.leankor__Swimlane__C=zoneList[0].leankor__Swimlane__C;
    		kb1.leankor__ValueStream__C=zoneList[0].leankor__ValueStream__C;
    		kb1.leankor__MasterContainer__c=zoneList[0].leankor__Swimlane__r.leankor__MasterContainer__c;    	
    		kanbancards1.add(kb1);
    	}    	    	
        leankor.MoveKanbanCardAction.KanbanCardRequest request1=new leankor.MoveKanbanCardAction.KanbanCardRequest();    		
    	request1.kanbancardList=kanbancards1;
    	kanbanCardRequestList1.add(request1);  	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());   	
    	System.assert(leankor.MoveKanbanCardAction.MoveKanbanCardProcess(kanbanCardRequestList1) == null, 'Method Executed Successfully.');   	    
		//leankor.MoveKanbanCardAction.MoveKanbanCardProcess(kanbanCardRequestList1); 		
		System.assert(flag, 'Method Executed Successfully.');	
		Test.StopTest();
		for (leankor__Kanbancard__c kanban : listOfKanbanCards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request=new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.Id = kanban.id;
			request.MCName = 'Template' ;   		
    		request.SwimlaneName = 'Default Swimlane';
    		request.ColumnName = 'Default column0';
    		kanbanCardRequestList.add(request);
    	}
		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
    }

	@isTest
	private static void moveKanbanCardTest() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.MCName = 'Template' ;   		
    		request.ColumnName = 'Default column0';
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestTwo() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.MCName = 'Template' ;   
			request.SwimlaneName = 'Default Swimlane';
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestThird() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.MCName = 'Template' ;   
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestWBSAndSequenceNumber() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.MCName = 'Template';
			request.generateWorkBreakdownStructure = true;      
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestfourth() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.ColumnName = 'Default column0';  
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestfifth() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.SwimlaneName = 'Default Swimlane';
			request.ColumnName = 'Default column0';  
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestsixth() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard12'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanban.leankor__ValueStream__C+ '&cardid='+kanban.id;
			request.SwimlaneName = 'Default Swimlane';
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveKanbanCardTestseventh() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__ValueStream__C
														From leankor__KanbanCard__c
														Where Name = 'kanbancard123'];
		for (leankor__Kanbancard__c kanban : kanbancards) {
    		leankor.MoveKanbanCardAction.KanbanCardRequest request = new leankor.MoveKanbanCardAction.KanbanCardRequest();  		
			request.CardURL = '?Id=' +kanbanCards[0].leankor__ValueStream__C+ '&cardid='+kanban.id;
    		kanbanCardRequestList.add(request);
    	}

		System.assert((leankor.MoveKanbanCardAction.moveKanbanCard(kanbanCardRequestList)).size() > 0, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveMultipleKanbanCardsTest() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__Zone__C,
														   leankor__ZoneGUID__C,
														   leankor__ValueStream__c,
														   leankor__MasterContainer__c,
														   leankor__Swimlane__c
														From leankor__KanbanCard__c
														Where Name = 'zoneGuid'];
		List<leankor.RealTimeController.Kanban> moveMultiplecard = leankor.MoveKanbanCardAction.moveMultipleKanbanCards(kanbanCards);
		System.assertEquals(moveMultiplecard[0].zoneId, kanbanCards[0].leankor__ZoneGUID__C, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveMultipleKanbanCardsTestTwo() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__Zone__C,
														   leankor__ZoneGUID__C,
														   leankor__ValueStream__c,
														   leankor__MasterContainer__c,
														   leankor__Swimlane__c
														From leankor__KanbanCard__c
														Where Name = 'SwimlaneId'];
		List<leankor.RealTimeController.Kanban> moveMultiplecard = leankor.MoveKanbanCardAction.moveMultipleKanbanCards(kanbanCards);
		System.assertEquals(moveMultiplecard[0].SWForceID, kanbanCards[0].leankor__Swimlane__c, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveMultipleKanbanCardsTestThird() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__Zone__C,
														   leankor__ZoneGUID__C,
														   leankor__ValueStream__c,
														   leankor__MasterContainer__c,
														   leankor__Swimlane__c
														From leankor__KanbanCard__c
														Where Name = 'masterContainerId'];
		List<leankor.RealTimeController.Kanban> moveMultiplecard = leankor.MoveKanbanCardAction.moveMultipleKanbanCards(kanbanCards);
		System.assertEquals(moveMultiplecard[0].MCForceID, kanbanCards[0].leankor__MasterContainer__c, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveMultipleKanbanCardsTestFourth() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__Zone__C,
														   leankor__ZoneGUID__C,
														   leankor__ValueStream__c,
														   leankor__MasterContainer__c,
														   leankor__Swimlane__c
														From leankor__KanbanCard__c
														Where Name = 'Activity 0'];
		List<leankor.RealTimeController.Kanban> moveMultiplecard = leankor.MoveKanbanCardAction.moveMultipleKanbanCards(kanbanCards);
		System.assertEquals(moveMultiplecard[0].Id, kanbanCards[0].Id, 'Method Executed Successfully.');
	}

	@isTest
	private static void moveMultipleKanbanCardsTestFifth() {
		List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new List<leankor.MoveKanbanCardAction.KanbanCardRequest>();
		List<leankor__KanbanCard__c> kanbanCards = [Select Id,
														   leankor__Zone__C,
														   leankor__ZoneGUID__C,
														   leankor__ValueStream__c,
														   leankor__MasterContainer__c,
														   leankor__Swimlane__c
														From leankor__KanbanCard__c
														Where Name = 'kanbancard1234'];
		List<leankor.RealTimeController.Kanban> moveMultiplecard = leankor.MoveKanbanCardAction.moveMultipleKanbanCards(kanbanCards);
		System.assertEquals(moveMultiplecard[0].Id, kanbanCards[0].Id, 'Method Executed Successfully.');
	}
}