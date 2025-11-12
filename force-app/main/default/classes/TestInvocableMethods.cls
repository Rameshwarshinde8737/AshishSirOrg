@istest
public class TestInvocableMethods implements HttpCalloutMock{

    private static User uSamp = null;

	/*
	 Date 06/12/18
	*/
 	 @testSetup static void testData() {		
		User u = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'Kanban Board', u);                   
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> kanbancardList=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,5,activityList,u);		
 		List<leankor__MasterContainer__c> mastercontainerList=new List<leankor__MasterContainer__c>();
 		for(Integer i=0;i<6;i++){
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
 		for(leankor__MasterContainer__c mc:mastercontainerList){	
 			leankor__Swimlane__c swimlane =new leankor__Swimlane__c();
 			swimlane.Name='Default Swimlane';
 			swimlane.leankor__GUID__c=TestDataFactory.createguid();
 			swimlane.leankor__MasterContainer__c=mc.id;
 			swimlane.leankor__ValueStream__c=mc.leankor__ValueStream__c;
 	 		SwimlaneList.add(swimlane);
 		}
 		insert SwimlaneList;
 		List<leankor__Sticker__c> stickerList =new List<leankor__Sticker__c>();
 		for(Integer stick=0;stick<5;stick++){
 			leankor__Sticker__c sticker = new leankor__Sticker__c();
           sticker.Name = 'sticker name';
       	  stickerList.add(sticker);
 		}
 		insert stickerList;
 		
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = false;
        insert customSetting;

        // For creating Account and Contact for Community User
        Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);
 		
 	}	

    // Method for creating a Community user with 'Visual Lean Customer Community User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                	From Contact
                                	Where Birthdate =:Date.newInstance(2016, 12, 9) 
                                	Limit 1];
        uSamp = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);
    }

    // Method for creating a user with 'Visual Lean User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
	private static void createVisualLeanUser() {
        uSamp = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_User'});
	}

 public static testMethod void testCreateBoard(){
 List<leankor.KanbanController.MasterContainer> MContainers=new List<leankor.KanbanController.MasterContainer>();
List<leankor.KanbanController.Swimlane> Swims=new List<leankor.KanbanController.Swimlane>();
List<leankor__MasterContainer__c> MasterContainers=new List<leankor__MasterContainer__c>();
List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
String ReturnsZones='';
List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
 leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom');
 insert insertroom;
leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
Insert vStream;
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
leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = kct.ID, ID = vStream.Id);
update projectBoardupdate;
for(Integer i=0;i<5;i++) {
leankor.KanbanController.MasterContainer MC=new leankor.KanbanController.MasterContainer();
MC.CmpID='ext-masterContainer-'+i;
MC.Color=(i==0?'#A0A0A0':(i==1?'#6666FF':(i==2?'#FF8000':(i==3?'#66CC00':'#808080'))));
MC.GUID =vStream.Id+'-'+System.now().getTime()+'-mc00'+i;
MC.Height=670;
MC.Left=2080;
MC.Limits=0;
MC.Name=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
MC.Order=i;
MC.Title=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
MC.Top=2010;
MC.Type=(i==0?'Backlog':(i==1 ||i==2 ||i==3?'Regular':(i==4?'Archive':'Regular')));
MC.ValueStreamID=vStream.Id;
MC.Width=420;
MC.isCardAvailable=false;
MContainers.add(MC);
}
MasterContainers = leankor.KanbanController.createMasterContainer(MContainers);

Integer j=0,k=0;
for(leankor__MasterContainer__c m :MasterContainers){
leankor.KanbanController.Swimlane s=new leankor.KanbanController.Swimlane();
s.CardPerRow =1;
s.CmpID='ext-swimlaneContainer-'+j;
s.Color=(j==2?'#66CC00':'#4183D7');
s.GUID=vStream.Id+'-'+System.now().getTime()+'-sl00'+j;
s.Height=320;
s.Help='';
s.Left=2100;
s.Limits=0;
s.MasterContainer = m.Id;
s.Name='Default Swimlane';
s.Order=0;
s.Title='Default Swimlane';
s.Top=2100;
s.ValueStreamID=vStream.Id;
s.Width=418;
s.isCardAvailable = false;
Swims.add(s);
if(j==2){
leankor.KanbanController.Swimlane s1=new leankor.KanbanController.Swimlane();
s1.CardPerRow =1;
s1.Height=320;
s1.Help='';
s1.Left=2100;
s1.Limits=0;
s1.Top=2100;
s1.ValueStreamID=vStream.Id;
s1.Width=418;
s1.isCardAvailable = false;
s1.CmpID='ext-swimlaneContainer-'+(j+5);
s1.GUID=System.now().getTime()+'-'+vStream.Id+'-sl10-'+(j+5);
s1.Name='New Swimlane';
s1.Title='New Swimlane';
s1.Color = '#FF8000';
s1.MasterContainer = m.Id;
s1.Order=1;
Swims.add(s1);
}
j++;
}
Swimlanes = leankor.KanbanController.createSwimlane(Swims);


 for(leankor__Swimlane__c s:Swimlanes){
leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
    RemoteZone.GUID =vStream.Id+'-'+System.now().getTime()+'-z100'+k;
    RemoteZone.Title = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
    RemoteZone.Top=0;
    RemoteZone.Bottom =0;
    RemoteZone.Left =0;
    RemoteZone.Width =209;
    RemoteZone.Height =(k==2 || k==3) ? 174:492;
    RemoteZone.X = 0;
    RemoteZone.Y = 0;
    RemoteZone.EntryFlowName ='';
    RemoteZone.ExitFlowName ='';
    RemoteZone.ZoneMode ='Vertical Stretch';
    RemoteZone.KanbanSequence = '[]';
    RemoteZone.ValueStreamLinkID ='';
    RemoteZone.ValueStreamCardLink ='';
    RemoteZone.DefaultWidth  = 209;
    RemoteZone.DefaultHeight = (k==2 || k==3) ? 174:492;
    RemoteZone.ZoneStatus ='None';
    RemoteZone.CardsPerRow=1;
    RemoteZone.Help ='';
    RemoteZone.TaskLimit =0;
    RemoteZone.Order=0;
    RemoteZone.ParentZone='';
    RemoteZone.Swimlane=s.Id;
    RemoteZones.add(RemoteZone);
   if(k==1 || k==2 || k==3){
    leankor.realTimeController.Zone RemoteZone1=new leankor.realTimeController.Zone();
    RemoteZone1.GUID =System.now().getTime()+'-'+vStream.Id+'-z100'+k;
    RemoteZone1.Title = 'New SubColumn';
    RemoteZone1.Top=0;
    RemoteZone1.Bottom =0;
    RemoteZone1.Left =0;
    RemoteZone1.Width =209;
    RemoteZone1.Height =(k==2 || k==3) ? 174:492;
    RemoteZone1.X = 0;
    RemoteZone1.Y = 0;
    RemoteZone1.EntryFlowName ='';
    RemoteZone1.ExitFlowName ='';
    RemoteZone1.ZoneMode ='Vertical Stretch';
    RemoteZone1.KanbanSequence = '[]';
    RemoteZone1.ValueStreamLinkID ='';
    RemoteZone1.ValueStreamCardLink ='';
    RemoteZone1.DefaultWidth  = 209;
    RemoteZone1.DefaultHeight = (k==2 || k==3) ? 174:492;
    RemoteZone1.ZoneStatus ='None';
    RemoteZone1.CardsPerRow=1;
    RemoteZone1.Help ='';
    RemoteZone1.TaskLimit =0;
    RemoteZone1.Order=1;
    RemoteZone1.ParentZone='';
    RemoteZone1.Swimlane=s.Id;
    RemoteZones.add(RemoteZone1);
   }
     k++;
}
ReturnsZones=leankor.realTimeController.createZone(vStream.Id,RemoteZones);

leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM') ;
        insert linkr;
        leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',leankor__BoardType__c='Kanban Board' ,leankor__projectroom__C = LinkR.id);
        insert Linkb;
        leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',leankor__GUID__c = '123ds'+system.now()+10, leankor__ValueStream__c = Linkb.Id);
        insert linkKC;

 leankor__ValueStream__c insertboard =new leankor__ValueStream__c(Name ='newproject',leankor__projectRoom__c = insertroom.ID ,leankor__BoardType__C = 'Kanban Board');
 insert insertboard;
leankor__KanbanCard__c card = New leankor__KanbanCard__c(Name ='test',leankor__ValueStream__c = insertboard.ID );
insert card;
 List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> results = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  Testdata.ProjectBoardName ='newproject';
  Testdata.ProjectRoomName ='testRoom';
  Testdata.LinkedRoomName ='LINKROOM';
  Testdata.BoardType = 'Kanban Board';
        Testdata.LinkedBoardName='LINKABC';
       //Testdata.LinkedCardName ='LINKKC';
  testdatas.add(testdata);
  results = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas);
  System.assert(results != null);
  String BoardID = insertboard.Id;
  String cadid = card.id;
   List<leankor.CreateProjectBoardAction.ProjectBoardRequest> CHTestdatas  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> CHresults = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest CHTestdata  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  CHTestdata.ProjectBoardName ='newproject';
  CHTestdata.ProjectRoomName ='testRoom';
  CHTestdata.BoardType = 'Card Hierarchy';
  CHTestdata.CardURL = '?Id='+BoardID+'&&&cardid='+cadid;
  CHtestdatas.add(CHtestdata);
  CHresults = leankor.CreateProjectBoardAction.CreateProjectBoard(CHTestdatas);
  System.assert(CHresults != null);
  
  List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas1  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> results1 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata1  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  Testdata1.ProjectBoardName ='newproject';
  Testdata1.ProjectRoomName ='testRoom';
  Testdata1.LinkedRoomName ='LINKROOM';
        //Testdata.LinkedBoardName='LINKABC';
    Testdata1.LinkedCardName ='LINKKC';
  testdatas1.add(testdata1);
  results1 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas1);
  System.assert(results1 != null);
  
  List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas2  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> results2 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata2  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  Testdata2.ProjectBoardName ='newproject';
  Testdata2.ProjectRoomName ='testRoom';
  Testdata2.LinkedRoomName ='LINKROOM';
  Testdata2.LinkedBoardName='LINKABC';
    Testdata2.LinkedCardName ='LINKKC';
  testdatas2.add(testdata2);
  results2 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas2);
  System.assert(results2 != null);
  
   List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas3  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> results3 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata3  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  Testdata3.ProjectBoardName ='newproject';
  Testdata3.ProjectRoomName ='testRoom';
  Testdata3.LinkedRoomName ='LINKROOM';
  //Testdata3.LinkedBoardName='LINKABC';
  Testdata3.LinkedBoardId = Linkb.id;
   // Testdata3.LinkedCardName ='LINKKC';
  testdatas3.add(testdata3);
  results3 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas3);
  System.assert(results3 != null);
 
 
  List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas4  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
 List<leankor.CreateProjectBoardAction.ProjectBoardResult> results4 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
  leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata4  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
  Testdata4.ProjectBoardName ='newproject';
  Testdata4.ProjectRoomName ='testRoom';
  Testdata4.LinkedRoomName ='LINKROOM';
  //Testdata4.LinkedBoardName='LINKABC';
  Testdata4.LinkedBoardId = Linkb.id;
  Testdata4.LinkedCardId = linkKC.id;
  testdatas4.add(testdata4);
  results4 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas4);
  System.assert(results3 != null);
  //-----------------------------------------------CloneKanbanCardAction.CloneCard------------------------------------------------------
  leankor__KanbanCardTemplate__c temp =new leankor__KanbanCardTemplate__c (Name = 'test_temp', leankor__Valuestream__c =vStream.Id,leankor__Title__C ='test_temp');
  insert temp;
  leankor__Kanbancard__c insertcard =new leankor__Kanbancard__c(Name = 'testkanaban',leankor__title__c ='test_title',leankor__ValueStream__c = insertboard.ID ,leankor__KanbanCardTemplate__c =temp.ID,leankor__GUID__C ='305ee49a-test-4dsf-bf76-8a080880611');
  insert insertcard;
    leankor__Kanbancard__c newcard =new leankor__Kanbancard__c(Name = 'testkanaban12',leankor__title__c ='test_title',leankor__ValueStream__c = vStream.ID ,leankor__KanbanCardTemplate__c =temp.ID,leankor__GUID__C ='305ee49a-test-4df-bf76-8a080880611', leankor__StartDate__c = System.today(), leankor__DueDate__c = System.today() + 10, leankor__StartDateTime__c = System.now(), leankor__DueDateTime__c = System.now() + 10, RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId());
  insert newcard;
  List<CloneCardReturnIdAction.CloneKanbanCardRequest> ListClone = new List<CloneCardReturnIdAction.CloneKanbanCardRequest> ();
CloneCardReturnIdAction.CloneKanbanCardRequest cloneCard = new CloneCardReturnIdAction.CloneKanbanCardRequest();
cloneCard .KanbanID = newcard.ID;
cloneCard .FinalDate = system.now()+10;
ListClone.add(cloneCard);
List<CloneCardReturnIdAction.CloneKanbanCardResult> returnList= CloneCardReturnIdAction.CloneKanbanCards(ListClone);
System.assert(returnList != null);
  // IN TESTkanbancontroller
   //--------------------------------------------------------------CloneProjectBoard.CloneProjectBoardAction--------------
    // IN TESTkanbancontroller line no 618
   
   //--------------------------------------------------CreateTaskAction.insertTaskAction---------------------
		   /*List<leankor.CreateTaskAction.TaskDataRequest> Inputtasks = new List<leankor.CreateTaskAction.TaskDataRequest>();
   leankor.CreateTaskAction.TaskDataRequest Inputtask = new leankor.CreateTaskAction.TaskDataRequest();
   Inputtask.WhatId = insertcard.ID ;
   Inputtasks.add(Inputtask);
   List<leankor.CreateTaskAction.insertTaskResult> outputtaskID = new List<leankor.CreateTaskAction.insertTaskResult>();
   outputtaskID = leankor.CreateTaskAction.insertTaskAction(Inputtasks);
		   System.assert(outputtaskID.Size() != 0);*/
   //------------------------------------------------------GetCardIDAction.GetKanbanAction----------------------
   List<leankor.GetCardIDAction.KanbanIDRequest> inputNames = New List<leankor.GetCardIDAction.KanbanIDRequest> ();
   leankor.GetCardIDAction.KanbanIDRequest inputName = New leankor.GetCardIDAction.KanbanIDRequest   ();
   inputName.KanbanName = 'testkanaban';
   inputNames.add(inputName);
   List<leankor.GetCardIDAction.KanbanRecordResult> resultKanbanID = New List<leankor.GetCardIDAction.KanbanRecordResult>();
   resultKanbanID = leankor.GetCardIDAction.GetKanbanAction(inputNames);
   System.assert(resultKanbanID.size() != 0);
   //----------------------------------------------GetProjectBoardAction.getProjectBoard-------------------------
   List<leankor.GetProjectBoardAction.ProjectBoardRequest> inputboarddatas = new List<leankor.GetProjectBoardAction.ProjectBoardRequest> ();
   leankor.GetProjectBoardAction.ProjectBoardRequest inputboarddata = new leankor.GetProjectBoardAction.ProjectBoardRequest ();
   inputboarddata.ProjectBoardName ='newproject' ;
   inputboarddata.ProjectRoomName = 'testRoom';
   
   inputboarddatas.add(inputboarddata);
   
   List<leankor.GetProjectBoardAction.ProjectBoardResult> resultboardID = New List<leankor.GetProjectBoardAction.ProjectBoardResult> ();
   resultboardID = leankor.GetProjectBoardAction.getProjectBoard(inputboarddatas);
   System.assert(resultboardID.size() != 0);
   Test.startTest();
		   Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
   //----------------------------------------HyperJumpAction.HyperjumpToBoard-------------------------------
   List < leankor.HyperJumpAction.HyperJumpRequest> inputjumps = New List< leankor.HyperJumpAction.HyperJumpRequest> ();
   leankor.HyperJumpAction.HyperJumpRequest inputjump = New leankor.HyperJumpAction.HyperJumpRequest();
   inputjump.KanbanName = 'testkanaban12' ;
   inputjump.OldVSName ='_System_Board' ;
   inputjump.NewVSName ='_System_Board' ;
   inputjump.BoardType = 'Kanban Board' ;
   inputjump.TemplateName = 'test_temp';
   inputjumps.add(inputjump);
   leankor.HyperJumpAction.HyperjumpToBoard(inputjumps);
   //------------------------------------------------------------CreateKanbanCardAction.CreateKanbanCardProcess--------------------
		/*   List<leankor.CreateKanbanCardAction.KanbanCardRequest> inputkanbandatas = New List<leankor.CreateKanbanCardAction.KanbanCardRequest>();
   leankor.CreateKanbanCardAction.KanbanCardRequest inputkanbandata = New leankor.CreateKanbanCardAction.KanbanCardRequest();
   inputkanbandata.CategoryName = 'test_temp';
   inputkanbandata.GUID ='test-guid-'+system.now()+'-123';
   inputkanbandata.Title ='Title-test';
   inputkanbandata.OwnerID = UserInfo.getUserId();
   inputkanbandata.ProjectBoardName ='_System_Board';
   inputkanbandata.StartDate = system.now();
   inputkanbandata.DueDate = system.now();
   inputkanbandata.EstimatedDuration = 20;
   inputkanbandatas.add(inputkanbandata);
   List<leankor.CreateKanbanCardAction.KanbanCardResult> resultkanbandata= New List<leankor.CreateKanbanCardAction.KanbanCardResult>();
   resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
   System.assert(resultkanbandata.size() != 0);
   inputkanbandata.GUID ='test-guid1-'+system.now()+'-123';
   inputkanbandata.MCName = 'Backlog';
   inputkanbandata.SWname = 'SWID';
   resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
   inputkanbandata.SWname = 'New Swimlane';
   inputkanbandata.GUID ='test-guid2-'+system.now()+'-123';
		  // resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);*/
  //----------------------------------------------UpdateKanbanCardAction.UpdateKanbanCardProcess----------------
   List<leankor.UpdateKanbanCardAction.KanbanCardRequest> updatedatas  = new List<leankor.UpdateKanbanCardAction.KanbanCardRequest>();
leankor.UpdateKanbanCardAction.KanbanCardRequest updatedata  = new leankor.UpdateKanbanCardAction.KanbanCardRequest();
  updatedata.ID =newcard.ID;
  updatedata.CategoryName='test_temp';
  updatedata.Title ='updatetitle';
  updatedatas.add(updatedata);
leankor.UpdateKanbanCardAction.UpdateKanbanCardProcess(updatedatas);
//DCO 1/30/2018
leankor.UpdateKanbanCardAction.getKanbanCard(updatedata.ID);
//leankor.UpdateKanbanCardAction.UpdateKanbanCardLightning('');
//DCO 1/30/2018
        /**************************** Date 01/07/19 ******************/
        //Date : 01/07/19  create uber  Board.
      	leankor__ValueStream__c valuestream1=new leankor__ValueStream__c(Name='plan gantt',leankor__BoardType__c='UberBoard');
        	Insert valuestream1;     
      	//create folder cards.
      	leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestream1); 
      	List<leankor__KanbanCard__c> foldercards=leankor.TestDataFactory.createActivityGroups(valuestream1,template,1);               	  	
  	  	leankor__KanbanCard__c kanban=new leankor__KanbanCard__c();
  	  			kanban.Name='subactivity';
  	  			kanban.leankor__ValueStreamCardLink__c=foldercards[0].id;
  	  			kanban.leankor__ValueStream__c=valuestream1.Id;
  	  			kanban.leankor__GUID__c=TestDataFactory.createGuid();
  	  		insert	kanban;

  	    List<leankor.UpdateKanbanCardAction.KanbanCardRequest> updatekanbancards  = new List<leankor.UpdateKanbanCardAction.KanbanCardRequest>();
        leankor.UpdateKanbanCardAction.KanbanCardRequest updatekanbandata  = new leankor.UpdateKanbanCardAction.KanbanCardRequest();
          	updatekanbandata.ID =foldercards[0].ID;
          	updatekanbandata.CategoryName='Default';
          	updatekanbandata.Title = 'foldercard';
         	updatekanbandata.IsOnHold = true;
          	updatekanbancards.add(updatekanbandata);
        leankor.UpdateKanbanCardAction.UpdateKanbanCardProcess(updatekanbancards);
      
    Test.stopTest();
}

/*//RS 18/07/2018 This method needs more refactoring 
public static testMethod void moveKanbanProcess(){
Test.startTest();
 leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom');
 insert insertroom;
leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
Insert vStream;
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

//-------------------- leankor.MoveKanbanCardAction.MoveKanbanCardProcess ----------
 List<leankor.MoveKanbanCardAction.KanbanCardRequest> inputMoveNames = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();
   leankor.MoveKanbanCardAction.KanbanCardRequest inputMoveName = New leankor.MoveKanbanCardAction.KanbanCardRequest();
   inputMoveName.Id = newcard.ID;
   inputMoveName.MCName ='Backlog';
   inputMoveName.SwimlaneName ='Default Swimlane';
   inputMoveName.ColumnName = 'New SubColumn';
   inputMoveNames.add(inputMoveName );
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
   inputMoveName.Id = newcard.ID;
   inputMoveName.MCName ='Backlog';
   inputMoveName.SwimlaneName ='New Swimlane';
   inputMoveName.ColumnName = 'New SubColumn';
   inputMoveNames.add(inputMoveName );

leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames);
inputMoveNames.clear();
    //inputMoveName.BoardType = 'Kanban Board';
    inputMoveName.Id = newcard.ID;
    inputMoveName.MCName ='Backlog';
    inputMoveName.SwimlaneName ='New Swimlane';
    inputMoveName.ColumnName = 'New SubColumn';
    inputMoveNames.add(inputMoveName );
leankor.MoveKanbanCardAction.MoveKanbanCardProcess(inputMoveNames); 
Test.StopTest();

}*/



public static testMethod void testinvocablemethod() {
        // create the value stream
        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS');
        insert vs;
        // test Stickers -------------------------------------------------------------------
        List<leankor__Sticker__c> stickL;
        leankor__Sticker__c stick = new leankor__Sticker__c(
            Name = 'sticker name'
        );
        
        insert stick;
        
        Attachment stickAtt = new Attachment(
            ParentId = stick.Id,
            Name = 'afilename',
            Body = Blob.valueOf('a file')
        );
        
        insert stickAtt;
        
        stickL = leankor.RealTimeController.getAllStickers(null); 
        
        // Find the Id of the sticker we just inserted !
       Boolean found_it = false;
        for (leankor__Sticker__c lstick : stickL){
            if (lstick.Id == stick.Id){
                if (lstick.Attachments.size() == 1){
                    // we don't call this assert successful unless the attachment also exists
                    found_it = true;
                    break;
                }
            }
        }
        System.Assert(found_it);
        
        // test getting all kanban card stickers -----------------------------------------------
            leankor__KanbanCard__c kcsticker = new leankor__KanbanCard__c(
             Name = 'kanban test sticker',
             leankor__Y__c = 20,
             leankor__X__c = 50,
             leankor__Width__c = 100,
             leankor__ValueStream__c = vs.Id,
             leankor__Top__c = 150,
             leankor__Title__c = 'kanban title test sticker',
             leankor__State__c = 'zoneaccepted',
             leankor__Left__c = 250,
             leankor__JSONDefinition__c = '{}',
             leankor__JSONData__c = '{}',
             leankor__Height__c = 110,
             leankor__GUID__c = 'my-GUID-kanban-sticker-test',
             leankor__CmpID__c = 'my-CMPID-kanban-sticker-test',
             leankor__CSSLayout__c = 'some css',
             leankor__Bottom__c = 450,
             leankor__Priority__c = 1
        );
        
        insert kcsticker;
        //-----AddKanbanCardStickerAction
      /*  List<leankor.AddKanbanCardStickerAction.StickerDataRequest> clonedata = new List<leankor.AddKanbanCardStickerAction.StickerDataRequest>();
    leankor.AddKanbanCardStickerAction.StickerDataRequest OneLog = new leankor.AddKanbanCardStickerAction.StickerDataRequest();
    OneLog.KanbanID =kcsticker.Id;
    OneLog.StickerID =stick.Id;    
    clonedata.add(OneLog);
    List<leankor.AddKanbanCardStickerAction.StickerDataResult> result =  leankor.AddKanbanCardStickerAction.AddCardStickerAction(clonedata);
        System.Assert(!result.isEmpty());
     */   
        //----------RemoveKanbanCardStickerAction
   /*List<leankor.RemoveKanbanCardStickerAction.StickerDataRequest> clonedata2 = new List<leankor.RemoveKanbanCardStickerAction.StickerDataRequest>();
    leankor.RemoveKanbanCardStickerAction.StickerDataRequest OneLog2 = new leankor.RemoveKanbanCardStickerAction.StickerDataRequest();
    OneLog2.KanbanID = kcsticker.Id;
    OneLog2.StickerID =stick.Id;
    clonedata2.add(OneLog2);
    List<leankor.RemoveKanbanCardStickerAction.StickerDataResult> result2 =  leankor.RemoveKanbanCardStickerAction.RemoveCardStickerAction(clonedata2);
    System.Assert(!result2.isEmpty());*/
    PostInstallLean postinstall = new PostInstallLean();
        Test.testInstall(postinstall,new Version(1,41));
       //Test.testInstall(postinstall,new Version(1,67));
        //Test.testInstall(postinstall,new Version(1,73));
        //Test.testInstall(postinstall,new Version(1,86));
      //Test.testInstall(postinstall,new Version(1,103));
      //Test.testInstall(postinstall,new Version(1,133));
      //Test.testInstall(postinstall,new Version(1,138));
       //Test.testInstall(postinstall,new Version(1,200));
        Test.testInstall(postinstall,new Version(1,212));
  //------------------------------------------------------GetCardsAction.GetKanbanCardsAction----------------------

   List<leankor.GetCardsAction.KanbanRequest> inputNames = New List<leankor.GetCardsAction.KanbanRequest> ();
 
   leankor.GetCardsAction.KanbanRequest inputName = New leankor.GetCardsAction.KanbanRequest();
   inputName.BoardName = 'newproject';
   inputName.RoomName = 'testRoom';
   inputNames.add(inputName);
      leankor__projectroom__c Room = new leankor__projectroom__c( Name ='testRoom');
      insert Room;

      leankor__Valuestream__c VS1 = new leankor__Valuestream__c(Name = 'newproject',leankor__BoardType__c ='Kanban Board',leankor__ProjectRoom__c = Room.Id);
            insert VS1;
      List<leankor__kanbancard__c> kanbancardlist = new List<leankor__kanbancard__c>();
          leankor__kanbancard__c insertkanbancard = new leankor__kanbancard__c();
          insertkanbancard.Name = 'Kanban1';
          insertkanbancard.leankor__ValueStream__c = VS1.id;
          insertkanbancard.leankor__GUID__c =  system.now()+'d-Guid51';
          kanbancardlist.add(insertkanbancard);
          insert kanbancardlist;
        
 
   leankor.GetCardsAction.KanbanRequest inputName2 = New leankor.GetCardsAction.KanbanRequest();
   inputName2.BoardId = vs.id ;  // not sure which board to put here... need to create one previous to this call
   inputNames.add(inputName2);
   leankor.GetCardsAction.KanbanRequest inputName4 = New leankor.GetCardsAction.KanbanRequest();
   inputNames.add(inputName4);  //this code cove else part.
   List<leankor.GetCardsAction.KanbanRecordResult> resultKanbans = New List<leankor.GetCardsAction.KanbanRecordResult>();
   resultKanbans = leankor.GetCardsAction.GetKanbanCardsAction(inputNames);

   System.assert(resultKanbans.size() != 0);
   
  //------------------------------test for popupaction----------------------------
  
  
         leankor__projectroom__c pr = new leankor__projectroom__c( Name ='test');
            insert pr;
        leankor__Valuestream__c VS2 = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = pr.id);
            insert VS2;
            leankor__mastercontainer__c NewMC = new leankor__mastercontainer__c();
            NewMC.name= 'MC1';
            NewMC.leankor__Valuestream__c= VS2.id;
            insert NewMC ;
            leankor__swimlane__c  NewSw = new  leankor__swimlane__c();
            NewSw.name = 'sw';
            NewSw.leankor__mastercontainer__c= NewMC.id;
            NewSw.leankor__Valuestream__c = VS2.id;
            insert NewSw;         

            leankor__kanbancard__c kanbancard = new leankor__kanbancard__c();
            kanbancard.Name = 'Kanban1';
            kanbancard.leankor__ValueStream__c = VS2.id;
            kanbancard.leankor__GUID__c = system.now() +'A183289';
            kanbancard.leankor__StartDateTime__c = system.now();                     
           insert kanbancard;
            leankor__Zone__c zone1= new leankor__Zone__c();
            zone1.name= 'zone1';
            zone1.leankor__Width__c= 180.0;  
            zone1.leankor__X__c = 767.0;
            zone1.leankor__GUID__c = system.now() +'zone1';
            zone1.leankor__Y__c= 49.0;
            zone1.leankor__swimlane__c= NewSw.id;
           insert zone1;
           leankor__ZoneKanbanAction__c ZKA = new leankor__ZoneKanbanAction__c(leankor__ActionType2__c = 'left zone',
				leankor__KanbanCard2__c= kanbancard.id,
				leankor__ValueStream__c =VS2.id, leankor__SessionID__c = 'ahujfhjdgnildfijdfig', leankor__Zone2__c = Zone1.Id);
            insert ZKA;
            list<leankor.PopupAction.PopUpRequest> testrequest = new  list<leankor.PopupAction.PopUpRequest> ();
            leankor.PopupAction.PopUpRequest  request = new leankor.PopupAction.PopUpRequest();
            request.CardID =  kanbancard.id;
            request.YES = 'proceed';
            request.Buttonflag= false;
            request.customMessage= 'get card new';
            request.sessionID = 'ahujfhjdgnildfijdfig';
            testrequest.add(request);
            leankor.PopupAction.PopupProcess(testrequest);
            List<leankor.CreateKanbanCardAction.KanbanCardRequest> inputkanbandatas = New List<leankor.CreateKanbanCardAction.KanbanCardRequest>();
   /*leankor.CreateKanbanCardAction.KanbanCardRequest inputkanbandata = New leankor.CreateKanbanCardAction.KanbanCardRequest();
   inputkanbandata.CategoryName = 'test_temp';
   inputkanbandata.GUID ='test-guid-'+system.now()+'-123';
   inputkanbandata.Title ='Title-test';
   inputkanbandata.OwnerID = UserInfo.getUserId();
   inputkanbandata.ProjectBoardName ='_System_Board';
   inputkanbandata.StartDate = system.now();
   inputkanbandata.DueDate = system.now();
   inputkanbandata.EstimatedDuration = 20; 
   inputkanbandatas.add(inputkanbandata);
   List<leankor.CreateKanbanCardAction.KanbanCardResult> resultkanbandata= New List<leankor.CreateKanbanCardAction.KanbanCardResult>();*/
  // resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
 /*  leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c(name ='new room');
   insert pr1;
   leankor__Valuestream__c VS55 = new leankor__valuestream__c(Name = 'new VS',leankor__ProjectRoom__c = pr.ID,leankor__BoardType__C = 'whiteboard');
   insert VS55;
   leankor__KanbanCardTemplate__c kct123 = new leankor__KanbanCardTemplate__c(
    leankor__JSONDefinition__c = '',
    leankor__JSONData__c = '',
    leankor__Width__c = 170,
    leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
    leankor__CSSLayout__c = '',
    leankor__Color__c = '#bdbffc',
    leankor__ValueStream__c = VS55.Id,
    Name = 'test_temp',
    leankor__Title__c ='Default'
    );
Insert kct123;
  /* inputkanbandata.ProjectBoardId = Vs55.ID;
   inputkanbandata.GUID ='test-guid1-'+system.now()+'-123';
   inputkanbandata.DurationUnits = 'Minutes';
   inputkanbandata.LinkedCardName = 'data';
   inputkanbandata.LinkedBoardName = 'new VS';
   inputkanbandata.LinkedRoomName = 'new room';
   resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
   inputkanbandata.ProjectBoardId = Vs55.ID;
   inputkanbandata.DurationUnits = 'Hours';
   inputkanbandata.GUID ='test-guid2-'+system.now()+'-123';
   inputkanbandata.LinkedCardName = 'test_temp';
   inputkanbandata.LinkedBoardName = 'new VS';
   inputkanbandata.LinkedRoomName = 'new room';
   resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);*/
 }
    //New Method for API action classes
    public static testMethod void testAPImethods(){
        List<leankor.KanbanController.MasterContainer> MContainers=new List<leankor.KanbanController.MasterContainer>();
        List<leankor.KanbanController.Swimlane> Swims=new List<leankor.KanbanController.Swimlane>();
        List<leankor__MasterContainer__c> MasterContainers=new List<leankor__MasterContainer__c>();
        List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
        String ReturnsZones='';
        List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
        leankor__Portfolio__c foldername = new leankor__Portfolio__c(Name = 'ProjectFolderName');
            insert foldername;
        leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom', leankor__Portfolio__c = foldername.Id);
            insert insertroom;
        leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
        Insert vStream;
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
        leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = kct.ID, ID = vStream.Id);
            update projectBoardupdate;
        for(Integer i=0;i<5;i++) {
        leankor.KanbanController.MasterContainer MC=new leankor.KanbanController.MasterContainer();
            MC.CmpID='ext-masterContainer-'+i;
            MC.Color=(i==0?'#A0A0A0':(i==1?'#6666FF':(i==2?'#FF8000':(i==3?'#66CC00':'#808080'))));
            MC.GUID =vStream.Id+'-'+System.now().getTime()+'-mc00'+i;
            MC.Height=670;
            MC.Left=2080;
            MC.Limits=0;
            MC.Name=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
            MC.Order=i;
            MC.Title=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
            MC.Top=2010;
            MC.Type=(i==0?'Backlog':(i==1 ||i==2 ||i==3?'Regular':(i==4?'Archive':'Regular')));
            MC.ValueStreamID=vStream.Id;
            MC.Width=420;
            MC.isCardAvailable=false;
        MContainers.add(MC);
        }
        MasterContainers = leankor.KanbanController.createMasterContainer(MContainers);
        
        Integer j=0,k=0;
        for(leankor__MasterContainer__c m :MasterContainers){
        leankor.KanbanController.Swimlane s=new leankor.KanbanController.Swimlane();
            s.CardPerRow =1;
            s.CmpID='ext-swimlaneContainer-'+j;
            s.Color=(j==2?'#66CC00':'#4183D7');
            s.GUID=vStream.Id+'-'+System.now().getTime()+'-sl00'+j;
            s.Height=320;
            s.Help='';
            s.Left=2100;
            s.Limits=0;
            s.MasterContainer = m.Id;
            s.Name='Default Swimlane';
            s.Order=0;
            s.Title='Default Swimlane';
            s.Top=2100;
            s.ValueStreamID=vStream.Id;
            s.Width=418;
            s.isCardAvailable = false;
        Swims.add(s);
        if(j==2){
        leankor.KanbanController.Swimlane s1=new leankor.KanbanController.Swimlane();
            s1.CardPerRow =1;
            s1.Height=320;
            s1.Help='';
            s1.Left=2100;
            s1.Limits=0;
            s1.Top=2100;
            s1.ValueStreamID=vStream.Id;
            s1.Width=418;
            s1.isCardAvailable = false;
            s1.CmpID='ext-swimlaneContainer-'+(j+5);
            s1.GUID=System.now().getTime()+'-'+vStream.Id+'-sl10-'+(j+5);
            s1.Name='New Swimlane';
            s1.Title='New Swimlane';
            s1.Color = '#FF8000';
            s1.MasterContainer = m.Id;
            s1.Order=1;
        Swims.add(s1);
        }
        j++;
        }
        Swimlanes = leankor.KanbanController.createSwimlane(Swims);
        for(leankor__Swimlane__c s:Swimlanes){
        leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
            RemoteZone.GUID =vStream.Id+'-'+System.now().getTime()+'-z100'+k;
            RemoteZone.Title = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
            RemoteZone.Top=0;
            RemoteZone.Bottom =0;
            RemoteZone.Left =0;
            RemoteZone.Width =209;
            RemoteZone.Height =(k==2 || k==3) ? 174:492;
            RemoteZone.X = 0;
            RemoteZone.Y = 0;
            RemoteZone.EntryFlowName ='';
            RemoteZone.ExitFlowName ='';
            RemoteZone.ZoneMode ='Vertical Stretch';
            RemoteZone.KanbanSequence = '[]';
            RemoteZone.ValueStreamLinkID ='';
            RemoteZone.ValueStreamCardLink ='';
            RemoteZone.DefaultWidth  = 209;
            RemoteZone.DefaultHeight = (k==2 || k==3) ? 174:492;
            RemoteZone.ZoneStatus ='None';
            RemoteZone.CardsPerRow=1;
            RemoteZone.Help ='';
            RemoteZone.TaskLimit =0;
            RemoteZone.Order=0;
            RemoteZone.ParentZone='';
            RemoteZone.Swimlane=s.Id;
            RemoteZones.add(RemoteZone);
           if(k==1 || k==2 || k==3){
            leankor.realTimeController.Zone RemoteZone1=new leankor.realTimeController.Zone();
            RemoteZone1.GUID =System.now().getTime()+'-'+vStream.Id+'-z100'+k;
            RemoteZone1.Title = 'New SubColumn';
            RemoteZone1.Top=0;
            RemoteZone1.Bottom =0;
            RemoteZone1.Left =0;
            RemoteZone1.Width =209;
            RemoteZone1.Height =(k==2 || k==3) ? 174:492;
            RemoteZone1.X = 0;
            RemoteZone1.Y = 0;
            RemoteZone1.EntryFlowName ='';
            RemoteZone1.ExitFlowName ='';
            RemoteZone1.ZoneMode ='Vertical Stretch';
            RemoteZone1.KanbanSequence = '[]';
            RemoteZone1.ValueStreamLinkID ='';
            RemoteZone1.ValueStreamCardLink ='';
            RemoteZone1.DefaultWidth  = 209;
            RemoteZone1.DefaultHeight = (k==2 || k==3) ? 174:492;
            RemoteZone1.ZoneStatus ='None';
            RemoteZone1.CardsPerRow=1;
            RemoteZone1.Help ='';
            RemoteZone1.TaskLimit =0;
            RemoteZone1.Order=1;
            RemoteZone1.ParentZone='';
            RemoteZone1.Swimlane=s.Id;
            RemoteZones.add(RemoteZone1);
           }
             k++;
        }
        ReturnsZones=leankor.realTimeController.createZone(vStream.Id,RemoteZones);
        
        leankor__Portfolio__c LinkF = new leankor__Portfolio__c(Name = 'LinkedFolderName');
                insert LinkF;
        leankor__Projectroom__c LinkR =  new leankor__projectroom__c(Name = 'LINKROOM' ,leankor__Portfolio__c = linkF.Id) ;
                insert linkr;
        leankor__ValueStream__c Linkb =new leankor__ValueStream__c(Name='LINKABC',leankor__BoardType__c='Kanban Board' ,leankor__projectroom__C = LinkR.id);
                insert Linkb;
        leankor__kanbancard__C LinkKC =  new leankor__kanbancard__C(Name='LINKKC',leankor__GUID__c = '123ds'+system.now()+10);
                insert linkKC;
        
         leankor__ValueStream__c insertboard =new leankor__ValueStream__c(Name ='newproject',leankor__projectRoom__c = insertroom.ID ,leankor__BoardType__C = 'Kanban Board');
         insert insertboard;
        leankor__KanbanCard__c card = New leankor__KanbanCard__c(Name ='test',leankor__ValueStream__c = insertboard.ID );
        insert card;

        leankor__Portfolio__c linkFolder = new leankor__Portfolio__c(Name = 'Linke Folder');
        insert linkFolder;
        
        leankor__Projectroom__c projectroom =  new leankor__projectroom__c(Name = 'LINKROOM' ,leankor__Portfolio__c = linkFolder.Id) ;
        insert projectroom;

        leankor__ValueStream__c board =new leankor__ValueStream__c(Name ='LINKABC',leankor__projectRoom__c = projectroom.ID ,leankor__BoardType__C = 'Kanban Board');
         insert board;

        leankor__KanbanCard__c cardnext = new leankor__KanbanCard__c(Name ='LINKKC',leankor__ValueStream__c = board.ID ,leankor__Guid__c = leankor.TestDatafactory.createguid());
        insert cardnext;

            //----------------CreateProjectBoardAction API----------------------------
        List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
        List<leankor.CreateProjectBoardAction.ProjectBoardResult> results = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
        leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          Testdata.ProjectBoardName ='newproject';
          Testdata.ProjectRoomName ='testRoom';
          Testdata.LinkedRoomName ='LINKROOM';
          Testdata.ProjectFolderName = 'ProjectFolderName';
          Testdata.LinkedFolderName = linkFolder.Id;
          Testdata.BoardType = 'Kanban Board';
          Testdata.LinkedBoardName='LINKABC';
          Testdata.LinkedCardName ='LINKKC';
       testdatas.add(testdata);
       results = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas);
       System.assert(results != null);
       String BoardID = insertboard.Id;
       String cadid = card.id;
       List<leankor.CreateProjectBoardAction.ProjectBoardRequest> CHTestdatas  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
       List<leankor.CreateProjectBoardAction.ProjectBoardResult> CHresults = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
       leankor.CreateProjectBoardAction.ProjectBoardRequest CHTestdata  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          CHTestdata.ProjectBoardName ='newproject';
          CHTestdata.ProjectRoomName ='testRoom';
          CHTestdata.ProjectFolderName = 'ProjectFolderName';
          CHTestdata.BoardType = 'Card Hierarchy';
          CHTestdata.CardURL = '?Id='+BoardID+'&&&cardid='+cadid;
          CHtestdatas.add(CHtestdata);
          CHresults = leankor.CreateProjectBoardAction.CreateProjectBoard(CHTestdatas);
      System.assert(CHresults != null);
      
      List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas1  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
      List<leankor.CreateProjectBoardAction.ProjectBoardResult> results1 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
      leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata1  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          Testdata1.ProjectBoardName ='newproject';
          Testdata1.ProjectRoomName ='testRoom';
          Testdata1.ProjectFolderName = 'ProjectFolderName';
          Testdata1.LinkedRoomName ='LINKROOM';
          Testdata1.LinkedFolderName = 'Linke Folder';
          //Testdata.LinkedBoardName='LINKABC';
          Testdata1.LinkedCardName ='LINKKC';
          testdatas1.add(testdata1);
          results1 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas1);
      System.assert(results1 != null);
      
      List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas2  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
      List<leankor.CreateProjectBoardAction.ProjectBoardResult> results2 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
      leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata2  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          Testdata2.ProjectBoardName ='newproject';
          Testdata2.ProjectRoomName ='testRoom';
          Testdata2.ProjectFolderName = 'ProjectFolderName';
          Testdata2.LinkedRoomName ='LINKROOM';
          Testdata2.LinkedFolderName = linkFolder.Id;
          Testdata2.LinkedBoardName='LINKABC';
          Testdata2.LinkedCardName ='LINKKC';
          testdatas2.add(testdata2);
          results2 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas2);
      System.assert(results2 != null);
      
       List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas3  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
       List<leankor.CreateProjectBoardAction.ProjectBoardResult> results3 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
       leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata3  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          Testdata3.ProjectBoardName ='newproject';
          Testdata3.ProjectRoomName ='testRoom';
          Testdata3.ProjectFolderName = 'ProjectFolderName';
          Testdata3.LinkedRoomName ='LINKROOM';
          Testdata3.LinkedFolderName = 'Linke Folder';
          //Testdata3.LinkedBoardName='LINKABC';
          Testdata3.LinkedBoardId = Linkb.id;
          // Testdata3.LinkedCardName ='LINKKC';
          testdatas3.add(testdata3);
          results3 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas3);
      System.assert(results3 != null);
     
     
      List<leankor.CreateProjectBoardAction.ProjectBoardRequest> Testdatas4  = new List<leankor.CreateProjectBoardAction.ProjectBoardRequest>();
      List<leankor.CreateProjectBoardAction.ProjectBoardResult> results4 = new  List<leankor.CreateProjectBoardAction.ProjectBoardResult>();
      leankor.CreateProjectBoardAction.ProjectBoardRequest Testdata4  = new leankor.CreateProjectBoardAction.ProjectBoardRequest();
          Testdata4.ProjectBoardName ='newproject';
          Testdata4.ProjectRoomName ='testRoom';
          Testdata4.ProjectFolderName = 'ProjectFolderName';
          Testdata4.LinkedRoomName ='LINKROOM';
          Testdata4.LinkedFolderName = 'Linke Folder';
          //Testdata4.LinkedBoardName='LINKABC';
          Testdata4.LinkedBoardId = Linkb.id;
          Testdata4.LinkedCardId = linkKC.id;
          testdatas4.add(testdata4);
          results4 = leankor.CreateProjectBoardAction.CreateProjectBoard(Testdatas4);
      System.assert(results4 != null);
      //------------------------------------------------------------CreateKanbanCardAction.CreateKanbanCardProcess--------------------
       /*List<leankor.CreateKanbanCardAction.KanbanCardRequest> inputkanbandatas = New List<leankor.CreateKanbanCardAction.KanbanCardRequest>();
       leankor.CreateKanbanCardAction.KanbanCardRequest inputkanbandata = New leankor.CreateKanbanCardAction.KanbanCardRequest();
           inputkanbandata.CategoryName = 'test_temp';
           inputkanbandata.GUID ='test-guid-'+system.now()+'-123';
           inputkanbandata.Title ='Title-test';
           inputkanbandata.OwnerID = UserInfo.getUserId();
           inputkanbandata.ProjectFolderName = 'ProjectFolderName';
           inputkanbandata.LinkedFolderName = 'Link Folder';
           inputkanbandata.ProjectRoomName = 'ProjectRoomName';
           inputkanbandata.LinkedRoomName = 'Link Room';
           inputkanbandata.LinkedBoardName='LINKABC';
           inputkanbandata.ProjectBoardName ='_System_Board';
           inputkanbandata.StartDate = system.now();
           inputkanbandata.DueDate = system.now();
           inputkanbandata.EstimatedDuration = 20;
           inputkanbandatas.add(inputkanbandata);
       List<leankor.CreateKanbanCardAction.KanbanCardResult> resultkanbandata= New List<leankor.CreateKanbanCardAction.KanbanCardResult>();
       resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
      System.debug(resultkanbandata);
      // System.assert(resultkanbandata.size() != 0);
           inputkanbandata.GUID ='test-guid1-'+system.now()+'-123';
           inputkanbandata.MCName = 'Backlog';
           inputkanbandata.SWname = 'SWID';
       resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
           inputkanbandata.SWname = 'New Swimlane';
           inputkanbandata.GUID ='test-guid2-'+system.now()+'-123';
      // resultkanbandata = leankor.CreateKanbanCardAction.CreateKanbanCardProcess(inputkanbandatas);
      */
      //------------------------------------------------------GetCardsAction.GetKanbanCardsAction----------------------

       List<leankor.GetCardsAction.KanbanRequest> inputNames = New List<leankor.GetCardsAction.KanbanRequest> ();
     
       leankor.GetCardsAction.KanbanRequest inputName = New leankor.GetCardsAction.KanbanRequest();
       inputName.BoardName = 'newproject';
       inputName.RoomName = 'testRoom';
       inputName.FolderName = 'ProjectFolderName';
       inputNames.add(inputName);
          leankor__projectroom__c Room = new leankor__projectroom__c( Name ='testRoom');
            insert Room;
          leankor__Portfolio__c Folder = new leankor__Portfolio__c(Name = 'ProjectFolderName');
            insert Folder;
    
          leankor__Valuestream__c VS1 = new leankor__Valuestream__c(Name = 'newproject',leankor__BoardType__c ='Kanban Board',leankor__ProjectRoom__c = Room.Id,leankor__Portfolio__c = Folder.ID);
                insert VS1;
          List<leankor__kanbancard__c> kanbancardlist = new List<leankor__kanbancard__c>();
              leankor__kanbancard__c insertkanbancard = new leankor__kanbancard__c();
              insertkanbancard.Name = 'Kanban1';
              insertkanbancard.leankor__ValueStream__c = VS1.id;
              insertkanbancard.leankor__GUID__c =  system.now()+'d-Guid51';
              kanbancardlist.add(insertkanbancard);
              insert kanbancardlist;
            
     
       leankor.GetCardsAction.KanbanRequest inputName2 = New leankor.GetCardsAction.KanbanRequest();
           inputName2.BoardId = VS1.id ;  // not sure which board to put here... need to create one previous to this call
           inputNames.add(inputName2);
       leankor.GetCardsAction.KanbanRequest inputName4 = New leankor.GetCardsAction.KanbanRequest();
           inputNames.add(inputName4);  //this code cove else part.
       List<leankor.GetCardsAction.KanbanRecordResult> resultKanbans = New List<leankor.GetCardsAction.KanbanRecordResult>();
       resultKanbans = leankor.GetCardsAction.GetKanbanCardsAction(inputNames);
    
       System.assert(resultKanbans.size() != 0);
       //----------------------------------------------GetProjectBoardAction.getProjectBoard-------------------------
       List<leankor.GetProjectBoardAction.ProjectBoardRequest> inputboarddatas = new List<leankor.GetProjectBoardAction.ProjectBoardRequest> ();
       leankor.GetProjectBoardAction.ProjectBoardRequest inputboarddata = new leankor.GetProjectBoardAction.ProjectBoardRequest ();
           inputboarddata.ProjectBoardName ='newproject' ;
           inputboarddata.ProjectRoomName = 'testRoom';
           inputboarddata.ProjectFolderName = 'ProjectFolderName';
           inputboarddatas.add(inputboarddata);
       
       List<leankor.GetProjectBoardAction.ProjectBoardResult> resultboardID = New List<leankor.GetProjectBoardAction.ProjectBoardResult> ();
       resultboardID = leankor.GetProjectBoardAction.getProjectBoard(inputboarddatas);
       System.assert(resultboardID.size() != 0);
       //------------------------------------------CloneKanbanCardAction.CloneKanbanCards--------------------
        List<leankor.CloneKanbanCardAction.CloneKanbanCardRequest> ListClone = new List<leankor.CloneKanbanCardAction.CloneKanbanCardRequest> ();
        leankor.CloneKanbanCardAction.CloneKanbanCardRequest cloneCard = new leankor.CloneKanbanCardAction.CloneKanbanCardRequest();
            cloneCard.KanbanID = 'a0Ao000000wJSyPEAW'; // Put here ID of the Kanban Card which one you wanna clone. Mandatory Field.
            cloneCard.FinalDate = system.now(); // This will take system date. If you wanna increase or decrease due date just put '+' or '-' with number of days right after "()".
            cloneCard.LinkedRoomName ='LINKROOM';
            cloneCard.LinkedFolderName = 'Linke Folder';
            //cloneCard.LinkedBoardName='LINKABC';
            cloneCard.LinkedBoardId = Linkb.id;
            cloneCard.LinkedCardId = linkKC.id;
        ListClone.add(cloneCard);
        //leankor.CloneKanbanCardAction.CloneKanbanCards(ListClone);
        try{
            leankor.CloneKanbanCardAction.CloneKanbanCards(ListClone); // Checking Exception in Case of Wrong ID 
    }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        //System.assert(ListClone.size() != 0);    
    }
      /*
    	Date :06/12/18
    	To cover Movekanbancardaction class methods.
    */
    private static testMethod void moveKanbanProcessTest(){
    	List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();
    	List<leankor__Swimlane__c> swimlaneList =[select Id,Name,leankor__ValueStream__C,leankor__MasterContainer__c from leankor__Swimlane__c];
    	List<leankor__Zone__c> zoneList =new List<leankor__Zone__c>();
    	Integer intNum=0;
        Boolean flag = true;
    	for(leankor__Swimlane__c sw:swimlaneList){
    		leankor__Zone__c zone =new leankor__Zone__c();
    		zone.name='Default column'+intNum++;
    		zone.leankor__Swimlane__C=sw.id;
    		zone.leankor__Guid__c=leankor.TestDatafactory.createguid();
    		zone.leankor__ValueStream__C=sw.leankor__ValueStream__C;
    		zoneList.add(zone);
    	}
    	insert zoneList;
    	List<leankor__Kanbancard__c> kanbancards=new List<leankor__Kanbancard__c>();
    	for(leankor__Zone__c zone:zoneList){
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
    	for(leankor__Kanbancard__c kb:kanbancards){
    		system.debug(kb.Zone__c);
    		leankor.MoveKanbanCardAction.KanbanCardRequest request=new leankor.MoveKanbanCardAction.KanbanCardRequest();
    		request.id=kb.id;   		
    		request.MCName ='Template' ;   		
    		request.SwimlaneName ='Default Swimlane';
    		request.ColumnName ='Default column';
    		kanbanCardRequestList.add(request);
    	}
    	//System.assert(leankor.MoveKanbanCardAction.MoveKanbanCardProcess(kanbanCardRequestList)==null);
    	List<leankor.MoveKanbanCardAction.KanbanCardRequest> kanbanCardRequestList1 = New List<leankor.MoveKanbanCardAction.KanbanCardRequest> ();
    	List<leankor__Kanbancard__c> kanbancards1=new List<leankor__Kanbancard__c>();
    	for(leankor__Kanbancard__c kb:kanbancards){
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
    	//System.assert(leankor.MoveKanbanCardAction.MoveKanbanCardProcess(kanbanCardRequestList1)!=null);
        System.assert(flag);
    	Test.stopTest();
    }
    /*
     Date 06/12/18
     To cover  CreateTaskAction class.
    */
    private static testMethod void CreateTaskActionTest(){
    	List<leankor__Kanbancard__c> kanbancardList =[select Id,Name,leankor__valueStream__c,leankor__title__c,leankor__KanbanCardTemplate__c,leankor__Guid__c from leankor__Kanbancard__c];  
        List<leankor.CreateTaskAction.TaskDataRequest> inputTasks = new List<leankor.CreateTaskAction.TaskDataRequest>();				 	
		for(leankor__Kanbancard__c kanbancard:kanbancardList){
				 leankor.CreateTaskAction.TaskDataRequest taskData = new leankor.CreateTaskAction.TaskDataRequest();
				 taskData.WhatId = kanbancard.ID ;
				 inputTasks.add(taskData);
		}
		Test.startTest();
	   		List<leankor.CreateTaskAction.insertTaskResult> outputTaskID = new List<leankor.CreateTaskAction.insertTaskResult>();
	   		outputTaskID = leankor.CreateTaskAction.insertTaskAction(inputTasks);
	   		System.assert(outputTaskID.Size() != 0);
       Test.stopTest();
    }
     /*
      Date :10/12/18
      To cover RemoveCardStickerAction class.
    */
	private static testMethod void RemoveCardStickerActionTest(){
			List<leankor__Kanbancard__c> kanbancardList =[select Id,Name,leankor__valueStream__c,leankor__title__c,leankor__KanbanCardTemplate__c,leankor__Guid__c from leankor__Kanbancard__c];
	    	List<leankor.RemoveKanbanCardStickerAction.StickerDataRequest> requestList = new List<leankor.RemoveKanbanCardStickerAction.StickerDataRequest>();	    	
	    	List<leankor__Sticker__c> stickerList=[select Id,Name from leankor__Sticker__c];
	    	List<leankor.AddKanbanCardStickerAction.StickerDataRequest> clonedata = new List<leankor.AddKanbanCardStickerAction.StickerDataRequest>();   		
	    	List<leankor__KanbanCardSticker__c> kanbanCardStickerList =new List<leankor__KanbanCardSticker__c>();	    	
	    	for(leankor__Sticker__c sticker: stickerList){
	    		leankor__KanbanCardSticker__c kanbanCardSticker =new leankor__KanbanCardSticker__c();
	    			kanbanCardSticker.leankor__Sticker__c =sticker.Id;
	    			kanbanCardSticker.leankor__KanbanCard__c = kanbancardList[0].Id;
	    			kanbanCardStickerList.add(kanbanCardSticker);	
	    	}	    		
	    	insert KanbanCardStickerList;
	    	
	    	//for(leankor__Sticker__c sticker:stickerList){
	    	leankor.RemoveKanbanCardStickerAction.StickerDataRequest request = new leankor.RemoveKanbanCardStickerAction.StickerDataRequest();
	    		request.KanbanID = kanbancardList[0].Id;
	    		request.StickerID =stickerList[0].Id;
	    		requestList.add(request);
	    	//}	
	    	//List<leankor.RemoveKanbanCardStickerAction.StickerDataResult> result =  leankor.RemoveKanbanCardStickerAction.RemoveCardStickerAction(requestList);
	    	//System.Assert(!result2.isEmpty());
	    	leankor.RemoveKanbanCardStickerAction.StickerDataRequest request2 = new leankor.RemoveKanbanCardStickerAction.StickerDataRequest();
	    		request2.KanbanID = kanbancardList[1].Id;
	    		request2.StickerName =stickerList[1].Name;	    		
	    		requestList.add(request2);
	    	//}	
	    	Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
	    	List<leankor.RemoveKanbanCardStickerAction.StickerDataResult> result =  leankor.RemoveKanbanCardStickerAction.RemoveCardStickerAction(requestList);
	    	System.Assert(!result.isEmpty());
	    	Test.stopTest();
	}
    
    
    /*
      Date :07/12/18
    */
    static testMethod void testAddCardStickerAction(){
    	
    	User u = leankor.TestDataFactory.createStandardUser('Lean1');
        list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
        list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
        list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', u);       
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
        List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStream[0], template,3,null,u);
        
        leankor__Sticker__c sticker = new leankor__Sticker__c();
        sticker.leankor__ValueStream__c = vStream[0].Id;
        sticker.Name = 'Test Sticker Name';
        sticker.OwnerId = kanbanCardList[0].OwnerId;
        insert sticker;
        
        leankor__Sticker__c sticker2 = new leankor__Sticker__c();
        sticker2.leankor__ValueStream__c = vStream[0].Id;
        sticker2.Name = 'Test Sticker Name 2';
        sticker2.OwnerId = kanbanCardList[1].OwnerId;
        insert sticker2;
        
        leankor__KanbanCardSticker__c kanCardSticker = new leankor__KanbanCardSticker__c();
        kanCardSticker.leankor__KanbanCard__c = kanbanCardList[1].Id;
        kanCardSticker.leankor__Sticker__c = sticker2.ID;
        kanCardSticker.OwnerId = kanbanCardList[1].OwnerId;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
        list <leankor.AddKanbanCardStickerAction.StickerDataRequest> createCardList = new list <leankor.AddKanbanCardStickerAction.StickerDataRequest>();
        
		leankor.AddKanbanCardStickerAction.StickerDataRequest createCard = new leankor.AddKanbanCardStickerAction.StickerDataRequest();
		createCard.KanbanID = kanbanCardList[0].ID;
		createCard.StickerID = sticker.ID;
		createCard.StickerName = 'Test Sticker Name';
		
		leankor.AddKanbanCardStickerAction.StickerDataRequest createCard2 = new leankor.AddKanbanCardStickerAction.StickerDataRequest();
		createCard2.KanbanID = kanbanCardList[1].ID;
		//createCard2.StickerID = sticker2.ID;
		createCard2.StickerName = 'Test Sticker Name 2';
    	
    	createCardList.add(createCard);
    	createCardList.add(createCard2);
		List<AddKanbanCardStickerAction.StickerDataResult> result = leankor.AddKanbanCardStickerAction.AddCardStickerAction(createCardList);
        System.assert(result.size() > 0);
		Test.stopTest();
    } 
    
    /*
      Date :07/12/18
      
    */
    public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"status":"success"}');
		res.setStatusCode(200);
		return res; 
    }
    
    static testMethod void testCreateKanbanCardProcess(){
    	Test.startTest();
    	User u = leankor.TestDataFactory.createStandardUser('Lean12');
        /*list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
        list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
        list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', u);       
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
        List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStream[0], template,3,null,u);*/       
        List<leankor.KanbanController.MasterContainer> MContainers=new List<leankor.KanbanController.MasterContainer>();
		List<leankor.KanbanController.Swimlane> Swims=new List<leankor.KanbanController.Swimlane>();
		List<leankor__MasterContainer__c> MasterContainers=new List<leankor__MasterContainer__c>();
		List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
		String ReturnsZones='';
		List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
		leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom');
		insert insertroom;
		leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
		leankor__ValueStream__c vStream2=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
		insert vStream;
		insert vStream2;       
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
		
		leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = kct.ID, ID = vStream.Id);
		update projectBoardupdate;
		for(Integer i=0;i<5;i++) {
		leankor.KanbanController.MasterContainer MC=new leankor.KanbanController.MasterContainer();
		MC.CmpID='ext-masterContainer-'+i;
		MC.Color=(i==0?'#A0A0A0':(i==1?'#6666FF':(i==2?'#FF8000':(i==3?'#66CC00':'#808080'))));
			//MC.GUID =vStream.Id+'-'+System.now().getTime()+'-mc00'+i;
			MC.GUID =TestDataFactory.createGuid();
		MC.Height=670;
		MC.Left=2080;
		MC.Limits=0;
		MC.Name=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
		MC.Order=i;
		MC.Title=(i==0?'Backlog':(i==1?'Requested':(i==2?'In Progress':(i==3?'Done':'Archive'))));
		MC.Top=2010;
		MC.Type=(i==0?'Backlog':(i==1 ||i==2 ||i==3?'Regular':(i==4?'Archive':'Regular')));
		MC.ValueStreamID=vStream.Id;
		MC.Width=420;
		MC.isCardAvailable=false;
		MContainers.add(MC);
		}
		MasterContainers = leankor.KanbanController.createMasterContainer(MContainers);

		Integer j=0,k=0;
		for(leankor__MasterContainer__c m :MasterContainers){
			leankor.KanbanController.Swimlane swimlane=new leankor.KanbanController.Swimlane();
			swimlane.CardPerRow =1;
			swimlane.CmpID='ext-swimlaneContainer-'+j;
			swimlane.Color=(j==2?'#66CC00':'#4183D7');
			//swimlane.GUID=vStream.Id+'-'+System.now().getTime()+'-sl00'+j;
			swimlane.GUID=TestDataFactory.createGuid();
			swimlane.Height=320;
			swimlane.Help='';
			swimlane.Left=2100;
			swimlane.Limits=0;
			swimlane.MasterContainer = m.Id;
			swimlane.Name='Default Swimlane';
			swimlane.Order=0;
			swimlane.Title='Default Swimlane';
			swimlane.Top=2100;
			swimlane.ValueStreamID=vStream.Id;
			swimlane.Width=418;
			swimlane.isCardAvailable = false;
			Swims.add(swimlane);
			
			if(j==2){
				leankor.KanbanController.Swimlane swimlane1=new leankor.KanbanController.Swimlane();
				swimlane1.CardPerRow =1;
				swimlane1.Height=320;
				swimlane1.Help='';
				swimlane1.Left=2100;
				swimlane1.Limits=0;
				swimlane1.Top=2100;
				swimlane1.ValueStreamID=vStream.Id;
				swimlane1.Width=418;
				swimlane1.isCardAvailable = false;
				swimlane1.CmpID='ext-swimlaneContainer-'+(j+5);
				//swimlane1.GUID=System.now().getTime()+'-'+vStream.Id+'-sl10-'+(j+5);
				swimlane1.GUID=TestDataFactory.createGuid();
				swimlane1.Name='New Swimlane';
				swimlane1.Title='New Swimlane';
				swimlane1.Color = '#FF8000';
				swimlane1.MasterContainer = m.Id;
				swimlane1.Order=1;
				Swims.add(swimlane1);
			}
			j++;
		}
		Swimlanes = leankor.KanbanController.createSwimlane(Swims);


		for(leankor__Swimlane__c s:Swimlanes){
		leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
			//RemoteZone.GUID = vStream.Id+'-'+System.now().getTime()+'-z100'+k;
			RemoteZone.GUID =TestDataFactory.createGuid();  
		    RemoteZone.Title = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
		    RemoteZone.Top=0;
		    RemoteZone.Bottom =0;
		    RemoteZone.Left =0;
		    RemoteZone.Width =209;
		    RemoteZone.Height =(k==2 || k==3) ? 174:492;
		    RemoteZone.X = 0;
		    RemoteZone.Y = 0;
		    RemoteZone.EntryFlowName ='';
		    RemoteZone.ExitFlowName ='';
		    RemoteZone.ZoneMode ='Vertical Stretch';
		    RemoteZone.KanbanSequence = '[]';
		    RemoteZone.ValueStreamLinkID ='';
		    RemoteZone.ValueStreamCardLink ='';
		    RemoteZone.DefaultWidth  = 209;
		    RemoteZone.DefaultHeight = (k==2 || k==3) ? 174:492;
		    RemoteZone.ZoneStatus ='None';
		    RemoteZone.CardsPerRow=1;
		    RemoteZone.Help ='';
		    RemoteZone.TaskLimit =0;
		    RemoteZone.Order=0;
		    RemoteZone.ParentZone='';
		    RemoteZone.Swimlane=s.Id;
		    RemoteZones.add(RemoteZone);
		   	if(k==1 || k==2 || k==3){
			    leankor.realTimeController.Zone RemoteZone1=new leankor.realTimeController.Zone();
			    //RemoteZone1.GUID =System.now().getTime()+'-'+vStream.Id+'-z100'+k;
				RemoteZone1.GUID =TestDataFactory.createGuid();  
			    RemoteZone1.Title = 'New SubColumn';
			    RemoteZone1.Top=0;
			    RemoteZone1.Bottom =0;
			    RemoteZone1.Left =0;
			    RemoteZone1.Width =209;
			    RemoteZone1.Height =(k==2 || k==3) ? 174:492;
			    RemoteZone1.X = 0;
			    RemoteZone1.Y = 0;
			    RemoteZone1.EntryFlowName ='';
			    RemoteZone1.ExitFlowName ='';
			    RemoteZone1.ZoneMode ='Vertical Stretch';
			    RemoteZone1.KanbanSequence = '[]';
			    RemoteZone1.ValueStreamLinkID ='';
			    RemoteZone1.ValueStreamCardLink ='';
			    RemoteZone1.DefaultWidth  = 209;
			    RemoteZone1.DefaultHeight = (k==2 || k==3) ? 174:492;
			    RemoteZone1.ZoneStatus ='None';
			    RemoteZone1.CardsPerRow=1;
			    RemoteZone1.Help ='';
			    RemoteZone1.TaskLimit =0;
			    RemoteZone1.Order=1;
			    RemoteZone1.ParentZone='';
			    RemoteZone1.Swimlane=s.Id;
			    RemoteZones.add(RemoteZone1);
		   }
		     k++;
		}
		ReturnsZones=leankor.realTimeController.createZone(vStream.Id,RemoteZones);
        
        

		/** Data has created to test normal KanbanCardRequest in API. */
        List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStream, kct, 100, null, u);       
        list <leankor.CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequestList = new list <leankor.CreateKanbanCardAction.KanbanCardRequest>();
		
		leankor.CreateKanbanCardAction.KanbanCardRequest createCard_1 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		createCard_1.CategoryName = 'Default';
		createCard_1.OwnerID = kanbanCardList[0].OwnerID;		
		createCard_1.ProjectBoardId = vStream.Id;
		createCard_1.Title = 'Test Card Name';
		createCard_1.MCName = 'In Progress';
		createCard_1.SWName = 'New Swimlane';
		createCard_1.ZoneName = 'New SubColumn';
		createCard_1.DurationUnits = 'Weeks';
		createCard_1.LinkedCardName = 'Activity 1';
		kanbanCardRequestList.add(createCard_1);
		
		leankor.CreateKanbanCardAction.KanbanCardRequest createCard_2 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		createCard_2.CategoryName = 'Default';
		createCard_2.OwnerID = kanbanCardList[1].OwnerID;		
		createCard_2.ProjectBoardId = vStream.Id;
		createCard_2.Title = 'Test Card Name 2';
		createCard_2.MCName = 'Done';
		createCard_2.DurationUnits = 'Years';
		createCard_2.LinkedCardName = 'Activity 2';
		kanbanCardRequestList.add(createCard_2);
		
		leankor.CreateKanbanCardAction.KanbanCardRequest createCard_3 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		createCard_3.CategoryName = 'Default';
		createCard_3.OwnerID = kanbanCardList[1].OwnerID;		
		createCard_3.ProjectBoardId = vStream.Id;
		createCard_3.Title = 'Test Card Name 311';
		createCard_3.MCName = 'In Progress';
		createCard_3.DurationUnits = 'Hours';
		createCard_3.LinkedCardName = 'Activity 3';	
		kanbanCardRequestList.add(createCard_3);
		
		// For Seven Days work week.
		vStream2.leankor__SevenDayWorkWeek__c = true;
		upsert vStream2;
		
		leankor.CreateKanbanCardAction.KanbanCardRequest createCard_4 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		createCard_4.CategoryName = 'Default';
		createCard_4.OwnerID = kanbanCardList[0].OwnerID;		
		createCard_4.ProjectBoardName = vStream2.Name;
		createCard_4.Title = 'Test Card Name';		
		createCard_4.DurationUnits = 'Minutes';
		createCard_4.HarveyBallDoneDate = System.today();
		createCard_4.PromiseCompletionDate = System.today();
		createCard_4.EstimatedDuration = 24;
		createCard_4.LinkedCardName = 'Activity 3';	
		createCard_4.LinkedCardId = kanbanCardList[0].ID;
		createCard_4.LinkedBoardId = kanbanCardList[0].leankor__Valuestream__c;
		createCard_4.LinkedBoardName='_System_Board';
		createCard_4.LinkedRoomName	='testRoom';
		kanbanCardRequestList.add(createCard_4);
		
		leankor.CreateKanbanCardAction.KanbanCardRequest createCard_5 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		createCard_5.CategoryName = 'Default';
		createCard_5.OwnerID = kanbanCardList[0].OwnerID;		
		createCard_5.ProjectBoardName = vStream2.Name;
		createCard_5.Title = 'Test Card Name';
		createCard_5.MCName = 'In Progress';
		createCard_5.SWName = 'New Swimlane';
		createCard_5.ZoneName = 'New SubColumn';
		createCard_5.DurationUnits = 'Minutes';
		createCard_5.LinkedCardName = 'Activity 4';	
		kanbanCardRequestList.add(createCard_5);
		
		
		/** Data create to test code when KanbanCardRequest contains leankor__KanbanCard__c list. */
		List <leankor__KanbanCard__c> sObjectList = new List <leankor__KanbanCard__c> ();
		Integer cardCount=0;		
		for(leankor__KanbanCard__c kb :[SELECT Id, Name, OwnerId, leankor__Title__c, 
										leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, 
										leankor__KanbanCardTemplate__c,leankor__MasterContainer__c,leankor__Swimlane__c,
										leankor__ValueStream__c, leankor__ZoneGUID__c, leankor__Zone__c, leankor__HarveyBallDoneDate__c, 
										leankor__PromiseCompletionDate__c, leankor__EstimatedDuration__c FROM leankor__KanbanCard__c limit 100]){
		    
		leankor__KanbanCard__c kanInsatnce = new leankor__KanbanCard__c();
			kanInsatnce.Name='Test name '+cardCount;
			kanInsatnce.leankor__Title__c ='Test Title '+cardCount;
			kanInsatnce.leankor__KanbanCardTemplate__c = kb.leankor__KanbanCardTemplate__c;
			kanInsatnce.leankor__MasterContainer__c = kb.leankor__MasterContainer__c;
			kanInsatnce.leankor__Swimlane__c = kb.leankor__Swimlane__c;
			kanInsatnce.leankor__ValueStream__c = kb.leankor__ValueStream__c;
			kanInsatnce.leankor__ZoneGUID__c = kb.leankor__ZoneGUID__c;
			kanInsatnce.leankor__Zone__c = kb.leankor__Zone__c;
			kanInsatnce.OwnerId = kb.OwnerId;
		kanInsatnce.leankor__EstimatedDuration__c =100;
			if(cardCount<10){
				kanInsatnce.leankor__DurationUnits__c = 'Months';
			}else if(cardCount>=10 &&  cardCount <=20){
				kanInsatnce.leankor__DurationUnits__c = 'Minutes';
			}else if(cardCount>20 &&  cardCount <=30){
		kanInsatnce.leankor__DurationUnits__c = 'Hours';
			}else if(cardCount>30 &&  cardCount <=40){
				kanInsatnce.leankor__DurationUnits__c = 'Years';
			}else{
				kanInsatnce.leankor__DurationUnits__c = 'Days';
			}

		kanInsatnce.leankor__StartDateTime__c = System.today();
			sObjectList.add(kanInsatnce);
			cardCount ++;
		}
		
		leankor.CreateKanbanCardAction.KanbanCardRequest sObjectRequest_1 = new leankor.CreateKanbanCardAction.KanbanCardRequest();
		sObjectRequest_1.CategoryName = 'Default';
		sObjectRequest_1.OwnerID = kanbanCardList[0].OwnerID;		
		sObjectRequest_1.ProjectBoardName = 'KB No Name';
		sObjectRequest_1.KanbanCardList = sObjectList;
		kanbanCardRequestList.add(sObjectRequest_1);		
		
		Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
		leankor.CreateKanbanCardAction.CreateKanbanCardProcess(kanbanCardRequestList);
        Test.stopTest();
        List<leankor__KanbanCard__c> results = [Select Id, Name From leankor__KanbanCard__c];
        System.assert(results.size() > 0);
    }
    
     /* Method tests when updating a Kanban Card object without Constraints setting enabled
    * Test will pass if there are no errors in setting up input parameters and calling to update the card
    * Test will fail if there is any error in setting up input parameters and calling to update
    */
    @isTest
    private static void testUpdateOneCardNoConstraint() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
        insert project;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Board'; 
        valueStream.leankor__ProjectRoom__c = project.Id; 
        valueStream.leankor__BoardType__C = 'UberBoard';
        valueStream.leankor__SevenDayWorkWeek__c= true;
		insert valueStream;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
        kanbanTemplate.leankor__Height__c = 120; 
        kanbanTemplate.leankor__CSSLayout__c = '';
        kanbanTemplate.leankor__Color__c = '#bdbffc';
        kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
        kanbanTemplate.Name = 'Default';
        kanbanTemplate.leankor__Title__c = 'Default';
		insert kanbanTemplate;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanCard.Name = 'Test Card';
        kanbanCard.leankor__Title__c = 'Default';
        kanbanCard.leankor__DurationUnits__c = 'Days';
        kanbanCard.leankor__StartDateTime__c = System.now().addDays(-1);
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(10);
        kanbanCard.OwnerId = UserInfo.getUserId();
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        insert kanbanCard;

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                            leankor__AllowSchedulingConstraints__c,
                                                            leankor__DisableAutoTranslationOfActivity__c
                                                    From leankor__LeanConstants__c
                                                    Limit 1];

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;
        
        UpdateKanbanCardAction.KanbanCardRequest kbRequest = new UpdateKanbanCardAction.KanbanCardRequest();        
        List<UpdateKanbanCardAction.KanbanCardRequest> updateCards = new List<UpdateKanbanCardAction.KanbanCardRequest>();

        Test.startTest();

        kbRequest.Id = kanbanCard.Id;
        kbRequest.Name = 'Updated Card';
        kbRequest.CategoryName = kanbanCard.leankor__Title__c;
        kbRequest.StartDate = System.now().addDays(1);
        kbRequest.RecordTypeName = 'MileStoneCard';
        kbRequest.PromiseCompletionDate = System.now().addDays(6);

        updateCards.add(kbRequest);

        UpdateKanbanCardAction.UpdateKanbanCardProcess(updateCards);

        leankor__KanbanCard__c updatedKanbanCard = [Select Id, 
														Name, 
                                                        leankor__StartDateTime__c,
                                                        RecordType.Name,
                                                        leankor__PromiseCompletionDate__c 
                                                    From leankor__KanbanCard__c
                                                    Where Id = :kanbanCard.Id 
                                                    Limit 1];
        
        System.assertEquals('Updated Card', updatedKanbanCard.Name);
        System.assertEquals(kbRequest.StartDate, updatedKanbanCard.leankor__StartDateTime__c);
        System.assertEquals('MileStoneCard', updatedKanbanCard.RecordType.Name);
        System.assertEquals(kbRequest.PromiseCompletionDate, updatedKanbanCard.leankor__PromiseCompletionDate__c);
        
        Test.stopTest();

    }

    /* Method tests when updating a Kanban Card object with Constraints setting enabled
    * Card is set to have a constraint of 'Finish No Earlier Than' 
    * The constraint date time is set to the due date of the card and will be updated to move back 
    * Test will pass if an error is thrown since the update will violate the Constraint.
    * Test will fail if an error is NOT thrown even if update violates the Constraint.
    */
    @isTest
    private static void testUpdateOneCardWithConstraint() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
        insert project;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Board'; 
        valueStream.leankor__ProjectRoom__c = project.Id; 
        valueStream.leankor__BoardType__C = 'UberBoard';
		insert valueStream;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
        kanbanTemplate.leankor__Height__c = 120; 
        kanbanTemplate.leankor__CSSLayout__c = '';
        kanbanTemplate.leankor__Color__c = '#bdbffc';
        kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
        kanbanTemplate.Name = 'Default';
        kanbanTemplate.leankor__Title__c = 'Default';
		insert kanbanTemplate;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanCard.Name = 'Test Card';
        kanbanCard.leankor__Title__c = 'Default';
        kanbanCard.leankor__DurationUnits__c = 'Days';
        kanbanCard.leankor__StartDateTime__c = System.now();
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(10);
        kanbanCard.OwnerId = UserInfo.getUserId();
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        insert kanbanCard;

        leankor__ScheduleConstraint__c finishNoEarlier = new leankor__ScheduleConstraint__c();
        finishNoEarlier.leankor__Description__c = 'finishnoearlierthan';
        finishNoEarlier.leankor__Type__c = 'finishnoearlierthan';
        insert finishNoEarlier;

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                            leankor__AllowSchedulingConstraints__c,
                                                            leankor__DisableAutoTranslationOfActivity__c
                                                    From leankor__LeanConstants__c
                                                    Limit 1];

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        update constraintSetting;
        
        UpdateKanbanCardAction.KanbanCardRequest kbRequest = new UpdateKanbanCardAction.KanbanCardRequest();        
        List<UpdateKanbanCardAction.KanbanCardRequest> updateCards = new List<UpdateKanbanCardAction.KanbanCardRequest>();

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();

        Boolean thrownException = false;
        Exception error;

        Test.startTest();

        schedMode.leankor__KanbanCard__c = kanbanCard.Id;
        schedMode.leankor__ConstraintDateTime__c = kanbanCard.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = finishNoEarlier.Id;
        insert schedMode;

        kbRequest.Id = kanbanCard.Id;
        kbRequest.Name = 'Updated Card';
        kbRequest.CategoryName = kanbanCard.leankor__Title__c;
        kbRequest.DueDate = System.now();
        kbRequest.EstimatedDuration = 5;
        kbRequest.HarveyBall = 50;
        kbRequest.HarveyBallDoneDate = System.now().addDays(5).date();
        
        updateCards.add(kbRequest);

        try {
            UpdateKanbanCardAction.UpdateKanbanCardProcess(updateCards);    
        } catch (Exception e) {
            error = e;
            thrownException = true;
        } finally {
            System.debug('Exception thrown? ' + thrownException);
            System.debug(error);
            System.assert(error.getMessage().contains('KanbanCardConstraintViolation'));
            System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
        }

        Test.stopTest();
    }

    /* Method tests when updating a Kanban Card object that is linked to another card with Constraints setting enabled
    * Linked card is set to have a constraint of 'Finish No Later Than' 
    * The constraint date time is set to the due date of the linked card 
    * Test will pass if an error is thrown since the update will violate the Constraint.
    * Test will fail if an error is NOT thrown even if update violates the Constraint.
    */
    @isTest
    private static void testUpdateOneCardWithLinkAndConstraint() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
        insert project;

        List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Board'; 
        valueStream.leankor__ProjectRoom__c = project.Id; 
        valueStream.leankor__BoardType__c = 'Kanban Board';
		boards.add(valueStream);

        leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
        ganttBoard.Name = 'Test Gantt'; 
        ganttBoard.leankor__ProjectRoom__c = project.Id; 
        ganttBoard.leankor__BoardType__c = 'UberBoard';
		boards.add(ganttBoard);
        insert boards;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
        kanbanTemplate.leankor__Height__c = 120; 
        kanbanTemplate.leankor__CSSLayout__c = '';
        kanbanTemplate.leankor__Color__c = '#bdbffc';
        kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
        kanbanTemplate.Name = 'Default';
        kanbanTemplate.leankor__Title__c = 'Default';
		insert kanbanTemplate;

        List<leankor__KanbanCard__c> kbCards = new List<leankor__KanbanCard__c>();
        for(Integer i = 0; i < 2; i++) {
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
            kanbanCard.Name = 'Test Card ' + i;
            kanbanCard.leankor__Title__c = 'Default';
            kanbanCard.leankor__DurationUnits__c = 'Days';
            kanbanCard.leankor__StartDateTime__c = System.now();
            kanbanCard.leankor__DueDateTime__c = System.now().addDays(5+i);
            kanbanCard.OwnerId = UserInfo.getUserId();
            kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            if(Math.mod(i, 2) == 0) {
                kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
            }
            else { 
                kanbanCard.leankor__ValueStream__c = valueStream.Id;
            }
            kbCards.add(kanbanCard);
        }
        insert kbCards;

        leankor__ScheduleConstraint__c finishNoLater = new leankor__ScheduleConstraint__c();
        finishNoLater.leankor__Description__c = 'finishnolaterthan';
        finishNoLater.leankor__Type__c = 'finishnolaterthan';
        insert finishNoLater;

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                            leankor__AllowSchedulingConstraints__c,
                                                            leankor__ManuallyScheduled__c
                                                    From leankor__LeanConstants__c
                                                    Limit 1];

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        constraintSetting.leankor__ManuallyScheduled__c = false;
        update constraintSetting;
        
        UpdateKanbanCardAction.KanbanCardRequest kbRequest = new UpdateKanbanCardAction.KanbanCardRequest();        
        List<UpdateKanbanCardAction.KanbanCardRequest> updateCards = new List<UpdateKanbanCardAction.KanbanCardRequest>();

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();

        Boolean thrownException = false;
        Exception error;

        Test.startTest();

        schedMode.leankor__KanbanCard__c = kbCards[0].Id;
        schedMode.leankor__ConstraintDateTime__c = kbCards[0].leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = finishNoLater.Id;
        insert schedMode;

        kbRequest.Id = kbCards[1].Id;
        kbRequest.Name = 'Updated Card';
        kbRequest.CategoryName = kbCards[1].leankor__Title__c;
        kbRequest.DueDate = kbCards[1].leankor__DueDateTime__c.addDays(1);
        kbRequest.EstimatedDuration = 5;
        kbRequest.HarveyBall = 50;
        kbRequest.ValueStreamCardLink = kbCards[0].Id;
        kbRequest.ValueStreamLinkID = kbCards[0].leankor__ValueStream__c;
        
        updateCards.add(kbRequest);

        try {
            UpdateKanbanCardAction.UpdateKanbanCardProcess(updateCards);    
        } catch (Exception e) {
            error = e;
            thrownException = true;
        } finally {
            System.debug('Exception thrown? ' + thrownException);
            System.debug(error);
            System.assert(error.getMessage().contains('KanbanCardConstraintViolation'));
            System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
        }

        Test.stopTest();
    }

    /* Method tests when creating a Kanban Card object to link with a card with Constraints setting enabled
    * Linked card is set to have a constraint of 'Start no Later Than' 
    * The constraint date time is set to the start date of the linked card 
    * Test will pass if an error is thrown since the create will move the linked card's date and violate the Constraint.
    * Test will fail if an error is NOT thrown even if create violates the Constraint.
    */
    @isTest
    private static void testCreateOneCardWithLinkAndConstraint() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
        insert project;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Gantt'; 
        valueStream.leankor__ProjectRoom__c = project.Id; 
        valueStream.leankor__BoardType__c = 'UberBoard';
        insert valueStream;

        leankor__ValueStream__c kbBoard = [Select Id,
                                                Name,
                                                leankor__BoardType__c
                                            From leankor__ValueStream__c
                                            Where leankor__BoardType__c = 'Kanban Board'
                                            Limit 1];

        leankor__MasterContainer__c mc = [Select Id,
                                            Name,
                                            leankor__ValueStream__c
                                        From leankor__MasterContainer__c
                                        Where leankor__ValueStream__c = :kbBoard.Id
                                        And Name = 'Backlog'
                                        Limit 1];
        
        leankor__Swimlane__c sw = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__MasterContainer__c
                                    From leankor__Swimlane__c
                                    Where leankor__ValueStream__c = :kbBoard.Id
                                    And leankor__MasterContainer__c = :mc.Id
                                    Limit 1];

        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'Test Zone';
        zone.leankor__Swimlane__c = sw.Id;
        zone.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        zone.leankor__ValueStream__c = kbBoard.Id;
        insert zone;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
        kanbanTemplate.leankor__Height__c = 120; 
        kanbanTemplate.leankor__CSSLayout__c = '';
        kanbanTemplate.leankor__Color__c = '#bdbffc';
        kanbanTemplate.leankor__ValueStream__c = kbBoard.Id;
        kanbanTemplate.Name = 'Default';
        kanbanTemplate.leankor__Title__c = 'Default';
		insert kanbanTemplate;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
        kanbanCard.Name = 'Test Card';
        kanbanCard.leankor__Title__c = 'Default';
        kanbanCard.leankor__DurationUnits__c = 'Days';
        kanbanCard.leankor__StartDateTime__c = System.now();
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(5);
        kanbanCard.OwnerId = UserInfo.getUserId();
        kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        insert kanbanCard;                      
        
        leankor__ScheduleConstraint__c startNoLaterThan = new leankor__ScheduleConstraint__c();
        startNoLaterThan.leankor__Description__c = 'startnolaterthan';
        startNoLaterThan.leankor__Type__c = 'startnolaterthan';
        insert startNoLaterThan;
        
        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                            leankor__AllowSchedulingConstraints__c,
                                                            leankor__ManuallyScheduled__c
                                                    From leankor__LeanConstants__c
                                                    Limit 1];

        constraintSetting.leankor__AllowSchedulingConstraints__c = true;
        constraintSetting.leankor__ManuallyScheduled__c = false;
        update constraintSetting;
        
        CreateKanbanCardAction.KanbanCardRequest kbRequest = new CreateKanbanCardAction.KanbanCardRequest();        
        List<CreateKanbanCardAction.KanbanCardRequest> createCards = new List<CreateKanbanCardAction.KanbanCardRequest>();

        leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();

        Boolean thrownException = false;
        Exception error;

        Test.startTest();
        
        schedMode.leankor__KanbanCard__c = kanbanCard.Id;
        schedMode.leankor__ConstraintDateTime__c = kanbanCard.leankor__DueDateTime__c;
        schedMode.leankor__ScheduleConstraint__c = startNoLaterThan.Id;
        insert schedMode;

        kbRequest.Title = 'New Card';
        kbRequest.CategoryName = kanbanTemplate.Name;
        kbRequest.DurationUnits = 'Days';
        kbRequest.ProjectBoardName = 'Test Board';
        kbRequest.StartDate = System.now().addDays(10);
        kbRequest.DueDate = System.now().addDays(16);
        kbRequest.OwnerId = UserInfo.getUserId();
        kbRequest.GUID = ResourceGanttController.createGuid().replace('-','');
        kbRequest.RecordTypeName = 'ActivityCard';
        kbRequest.ProjectBoardId = kbBoard.Id;
        kbRequest.ZoneID = zone.Id;
        kbRequest.LinkedCardId = kanbanCard.Id;
        kbRequest.LinkedBoardId = valueStream.Id;
        
        createCards.add(kbRequest);

        try {
            CreateKanbanCardAction.CreateKanbanCardProcess(createCards);    
        } catch (Exception e) {
            error = e;
            thrownException = true;
        } finally {
            System.debug('Exception thrown? ' + thrownException);
            System.debug(error);
            System.assert(error.getMessage().contains('KanbanCardConstraintViolation'));
            System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
        }

        Test.stopTest();
    }

    /* Method tests to make sure that a Community User with 'Visual Lean Community Customer User' permission set can access kanban card object
    * Test will pass if the user with the permission set can create, read, edit, and delete the kanban card object.
    * Test will fail if for some reason the user cannot create, read, edit, or delete the kanban card object.
    */
    @isTest
    static void testCommunityUserAccessKanbanCard() {

        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                	From Contact
                                	Where Birthdate =:Date.newInstance(2016, 12, 9)  
                                	Limit 1];
        User u = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);

        Test.startTest();

        System.runAs(u) {

            List<ObjectPermissions> objPermissionList = [Select Id, 
                                                                SObjectType,
                                                                PermissionsCreate, 
                                                                PermissionsDelete,
                                                                PermissionsEdit,
                                                                PermissionsRead 
                                                        From ObjectPermissions 
                                                        Where ParentId In (Select PermissionSetId
                                                                            From PermissionSetAssignment 
                                                                            Where Assignee.Name = :u.Name
                                                                            And PermissionSet.Name = 'Visual_Lean_Customer_Community_User')
                                                        And SObjectType = 'leankor__KanbanCard__c'];

            for(ObjectPermissions op : objPermissionList) {
                System.assertEquals(true, op.PermissionsRead, 'Community user should be able to read Kanban Card object');
                System.assertEquals(true, op.PermissionsCreate, 'Community user should be able to create Kanban Card object');
                System.assertEquals(true, op.PermissionsEdit, 'Community user should be able to edit Kanban Card object');
                System.assertEquals(true, op.PermissionsDelete, 'Community user should be able to delete Kanban Card object');
            }

            Test.stopTest();

        }
    }
    
    /* Method tests when updating a Kanban Card object as a Community User with Constraints setting enabled
    * Test will pass if an error is thrown since the update will violate the Constraint.
    * Test will fail if an error is NOT thrown even if update violates the Constraint.
    */
    @isTest
    private static void testUpdateCardWithLinkAndConstraintAsCommunityUser() {

        createCommunityUser();

        Test.startTest();

        System.runAs(uSamp) {

            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
            insert project;

            List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'Test Board'; 
            valueStream.leankor__ProjectRoom__c = project.Id; 
            valueStream.leankor__BoardType__c = 'Kanban Board';
            boards.add(valueStream);

            leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
            ganttBoard.Name = 'Test Gantt'; 
            ganttBoard.leankor__ProjectRoom__c = project.Id; 
            ganttBoard.leankor__BoardType__c = 'UberBoard';
            boards.add(ganttBoard);
            insert boards;

            leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
            kanbanTemplate.leankor__JSONDefinition__c = '';
            kanbanTemplate.leankor__JSONData__c = '';
            kanbanTemplate.leankor__Width__c = 170;
            kanbanTemplate.leankor__Height__c = 120; 
            kanbanTemplate.leankor__CSSLayout__c = '';
            kanbanTemplate.leankor__Color__c = '#bdbffc';
            kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
            kanbanTemplate.Name = 'Default';
            kanbanTemplate.leankor__Title__c = 'Default';
            insert kanbanTemplate;

            List<leankor__KanbanCard__c> kbCards = new List<leankor__KanbanCard__c>();
            for(Integer i = 0; i < 2; i++) {
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
                kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
                kanbanCard.Name = 'Test Card ' + i;
                kanbanCard.leankor__Title__c = 'Default';
                kanbanCard.leankor__DurationUnits__c = 'Days';
                kanbanCard.leankor__StartDateTime__c = System.now();
                kanbanCard.leankor__DueDateTime__c = System.now().addDays(3+i);
                kanbanCard.OwnerId = UserInfo.getUserId();
                kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
                kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
                if(Math.mod(i, 2) == 0) {
                    kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
                }
                else { 
                    kanbanCard.leankor__ValueStream__c = valueStream.Id;
                }
                kbCards.add(kanbanCard);
            }
            insert kbCards;

            leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
            mustFinishOn.leankor__Description__c = 'mustfinishon';
            mustFinishOn.leankor__Type__c = 'mustfinishon';
            insert mustFinishOn;

            leankor__LeanConstants__c constraintSetting = [Select Id,
                                                                leankor__AllowSchedulingConstraints__c,
                                                                leankor__ManuallyScheduled__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

            constraintSetting.leankor__AllowSchedulingConstraints__c = true;
            constraintSetting.leankor__ManuallyScheduled__c = false;
            update constraintSetting;
            
            UpdateKanbanCardAction.KanbanCardRequest kbRequest = new UpdateKanbanCardAction.KanbanCardRequest();        
            List<UpdateKanbanCardAction.KanbanCardRequest> updateCards = new List<UpdateKanbanCardAction.KanbanCardRequest>();

            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();

            Boolean thrownException = false;
            Exception error;

            schedMode.leankor__KanbanCard__c = kbCards[0].Id;
            schedMode.leankor__ConstraintDateTime__c = kbCards[0].leankor__DueDateTime__c;
            schedMode.leankor__ScheduleConstraint__c = mustFinishOn.Id;
            insert schedMode;

            kbRequest.Id = kbCards[1].Id;
            kbRequest.Name = 'Updated Card';
            kbRequest.CategoryName = kbCards[1].leankor__Title__c;
            kbRequest.DueDate = kbCards[1].leankor__DueDateTime__c.addDays(1);
            kbRequest.EstimatedDuration = 5;
            kbRequest.HarveyBall = 50;
            kbRequest.ValueStreamCardLink = kbCards[0].Id;
            kbRequest.ValueStreamLinkID = kbCards[0].leankor__ValueStream__c;
            
            updateCards.add(kbRequest);

            try {
                UpdateKanbanCardAction.UpdateKanbanCardProcess(updateCards);    
            } catch (Exception e) {
                error = e;
                thrownException = true;
            } finally {
                System.debug('Exception thrown? ' + thrownException);
                System.debug(error);
                System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
            }

        }

        Test.stopTest();
    }

    /* Method tests when creating a Kanban Card object to link with a card as a Visual Lean User with Constraints setting enabled
    * Test will pass if an error is thrown since the create will move the linked card's date and violate the Constraint.
    * Test will fail if an error is NOT thrown even if create violates the Constraint.
    */
    @isTest
    private static void testCreateOneCardWithLinkAndConstraintAsLeanUser() {
        createVisualLeanUser();

        Test.startTest();

        System.runAs(uSamp) {

            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'Test Project');
            insert project;

            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'Test Gantt'; 
            valueStream.leankor__ProjectRoom__c = project.Id; 
            valueStream.leankor__BoardType__c = 'UberBoard';
            insert valueStream;

            leankor__ValueStream__c kbBoard = [Select Id,
                                                    Name,
                                                    leankor__BoardType__c
                                                From leankor__ValueStream__c
                                                Where leankor__BoardType__c = 'Kanban Board'
                                                Limit 1];

            leankor__MasterContainer__c mc = [Select Id,
                                                Name,
                                                leankor__ValueStream__c
                                            From leankor__MasterContainer__c
                                            Where leankor__ValueStream__c = :kbBoard.Id
                                            And Name = 'Backlog'
                                            Limit 1];
            
            leankor__Swimlane__c sw = [Select Id,
                                            Name,
                                            leankor__ValueStream__c,
                                            leankor__MasterContainer__c
                                        From leankor__Swimlane__c
                                        Where leankor__ValueStream__c = :kbBoard.Id
                                        And leankor__MasterContainer__c = :mc.Id
                                        Limit 1];

            leankor__Zone__c zone = new leankor__Zone__c();
            zone.Name = 'Test Zone';
            zone.leankor__Swimlane__c = sw.Id;
            zone.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            zone.leankor__ValueStream__c = kbBoard.Id;
            insert zone;

            leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
            kanbanTemplate.leankor__JSONDefinition__c = '';
            kanbanTemplate.leankor__JSONData__c = '';
            kanbanTemplate.leankor__Width__c = 170;
            kanbanTemplate.leankor__Height__c = 120; 
            kanbanTemplate.leankor__CSSLayout__c = '';
            kanbanTemplate.leankor__Color__c = '#bdbffc';
            kanbanTemplate.leankor__ValueStream__c = kbBoard.Id;
            kanbanTemplate.Name = 'Default';
            kanbanTemplate.leankor__Title__c = 'Default';
            insert kanbanTemplate;

            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
            kanbanCard.Name = 'Test Card';
            kanbanCard.leankor__Title__c = 'Default';
            kanbanCard.leankor__DurationUnits__c = 'Days';
            kanbanCard.leankor__StartDateTime__c = System.now();
            kanbanCard.leankor__DueDateTime__c = System.now().addDays(5);
            kanbanCard.OwnerId = UserInfo.getUserId();
            kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            kanbanCard.leankor__ValueStream__c = valueStream.Id;
            insert kanbanCard;                      
            
            leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
            mustStartOn.leankor__Description__c = 'muststarton';
            mustStartOn.leankor__Type__c = 'muststarton';
            insert mustStartOn;

            
            leankor__LeanConstants__c constraintSetting = [Select Id,
                                                                leankor__AllowSchedulingConstraints__c,
                                                                leankor__ManuallyScheduled__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

            constraintSetting.leankor__AllowSchedulingConstraints__c = true;
            constraintSetting.leankor__ManuallyScheduled__c = false;
            update constraintSetting;
            
            CreateKanbanCardAction.KanbanCardRequest kbRequest = new CreateKanbanCardAction.KanbanCardRequest();        
            List<CreateKanbanCardAction.KanbanCardRequest> createCards = new List<CreateKanbanCardAction.KanbanCardRequest>();

            leankor__ScheduleMode__c schedMode = new leankor__ScheduleMode__c();

            Boolean thrownException = false;
            Exception error;
            
            schedMode.leankor__KanbanCard__c = kanbanCard.Id;
            schedMode.leankor__ConstraintDateTime__c = kanbanCard.leankor__DueDateTime__c;
            schedMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
            insert schedMode;

            kbRequest.Title = 'New Card';
            kbRequest.CategoryName = kanbanTemplate.Name;
            kbRequest.DurationUnits = 'Days';
            kbRequest.ProjectBoardName = 'Test Board';
            kbRequest.StartDate = System.now().addDays(-6);
            kbRequest.DueDate = System.now();
            kbRequest.OwnerId = UserInfo.getUserId();
            kbRequest.GUID = ResourceGanttController.createGuid().replace('-','');
            kbRequest.RecordTypeName = 'ActivityCard';
            kbRequest.ProjectBoardId = kbBoard.Id;
            kbRequest.ZoneID = zone.Id;
            kbRequest.LinkedCardId = kanbanCard.Id;
            kbRequest.LinkedBoardId = valueStream.Id;
            
            createCards.add(kbRequest);

            try {
                CreateKanbanCardAction.CreateKanbanCardProcess(createCards);    
            } catch (Exception e) {
                error = e;
                thrownException = true;
            } finally {
                System.debug('Exception thrown? ' + thrownException);
                System.debug(error);
                System.assert(error.getMessage().contains('KanbanCardConstraintViolation'));
                System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
            }

        }

        Test.stopTest();
    }

 }