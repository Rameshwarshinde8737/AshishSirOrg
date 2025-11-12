/**
* Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
* FILE:  ProjectSetupControllerTest.cls
* CLASS: ProjectSetupControllerTest
* USAGE: manages to Get record of Project Setup.
*/
@istest
public class TestProjectSetupController{
    public static testMethod void testprojectsetupControllerMethod(){
    leankor__ProjectRoom__c PR = new leankor__ProjectRoom__c(Name = 'TestProjectRoomName',leankor__IsTemplateProject__c=false);
    insert PR;
    ApexPages.StandardController sc = new ApexPages.standardController(PR);
    ProjectSetupController controller = new ProjectSetupController (sc); 
    leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom',leankor__IsTemplateProject__c=true);
    insert insertroom;
    ApexPages.currentPage().getParameters().put('id', insertroom.Id);
             controller.Project = insertroom;
             system.debug('Project    id is ' +insertroom.Id);
        leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = insertroom.ID);
             insert vStream;
        controller.oneclick = '';
        controller.timer = true;
        controller.selectSetup1 = '';
        //--------getprojectdata-----------
        leankor__ProjectRoom__c Obj_Room = new leankor__ProjectRoom__c();
            Obj_Room.leankor__DueDate__c = System.today();
            //Obj_Room.leankor__Portfolio__c = 'MyFolder';
            Obj_Room.leankor__ProjectId__c = controller.Project.id; //'a0Jd000000VAuS5';
            Obj_Room.leankor__StartDate__c = System.today();
            Obj_Room.leankor__TargetProjectCost__c = 152;
        insert Obj_Room;
        //leankor.ProjectSetupController.getprojectdata();
        //-----------getModule-------------
        leankor__Module__c Obj_Module = new leankor__Module__c();
            //Obj_Module.ID = system.now()+'kjhik243565';
            Obj_Module.leankor__BoardType__c = '_System_UberBoard';
            Obj_Module.Name='Project Boards';
            Obj_Module.leankor__Order__c = 1.0;
            Obj_Module.leankor__SetUp__c = true;
        insert Obj_Module;
        controller.getModules();
        controller.Module = Obj_Module;
        //----------getProjectLaunch--------
        leankor__ProjectLaunchBehavior__c Obj_PLB = new leankor__ProjectLaunchBehavior__c();
            Obj_PLB.leankor__DefaultBoard__c = vStream.ID;
           // Obj_PLB.leankor__GUID__c = 'HHOSA5565sdds'+system.today();
            Obj_PLB.leankor__Module__c = Obj_Module.Id; //a0Zd000000Fy7iVEAR;
            Obj_PLB.leankor__OneClicklaunch__c = true;
            Obj_PLB.leankor__OpenNewTab__c = true;
            Obj_PLB.leankor__Project__c = insertroom.ID;
            Obj_PLB.leankor__ViewType__c = 'Calendar View';
        insert Obj_PLB;
        //ProjectSetupController.getProjectLaunch();
        controller.ProjectLaunch = Obj_PLB;
        
      ProjectSetupController.Maponload.put(Obj_PLB.leankor__Module__c,Obj_PLB);
      leankor.RealtimeKanbanController.createProjectLaunchSettings(insertroom.ID);
        //---------getboardtype/getDashboards/getWhiteboards----------
    /*    List<SelectOption> Obj_BT = new List<SelectOption>();*/
        
        leankor__ValueStream__c Obj_VS = new leankor__ValueStream__c();
            Obj_VS.leankor__BoardType__c = '_System_PlanBoard';
            Obj_VS.leankor__ProjectRoom__c = insertroom.ID;
            //Obj_BT.add(Obj_VS);
           
           insert Obj_VS; 
        leankor.ProjectSetupController.getboardtype();
        leankor.ProjectSetupController.getDashboards();
        leankor.ProjectSetupController.getWhiteboards();
        //----------getBoardView-------------
        leankor.ProjectSetupController.getBoardView();
        //----------getBoardList-------------
        //leankor.ProjectSetupController.getBoardList();
        //--------------ProjectLaunchBehavior----------------
           
        ProjectSetupController.wrappermodule wrm = new ProjectSetupController.wrappermodule(Obj_Module);
        //wrm.selectSetup = false;
        wrm.openNewTab = true;
        wrm.Oneclick1 = true;
        wrm.DefaultBoard = '_System_Board';
        wrm.DefaultBoardID = Obj_PLB.leankor__DefaultBoard__c ;
        wrm.DefaultView = Obj_PLB.leankor__ViewType__c;
        wrm.selectSetup = true;
        /* controller.CustomSave();
        system.assert(ApexPages.currentPage().getParameters().put('id', PR.Id)!=null);
        controller.CustomSave();
        controller.closePopup();
        */
         // Date : 11/05/19 create User for checking security.
        User user1 = leankor.TestDataFactory.createStandardUser('Lean1');
		User user2 = leankor.TestDataFactory.createStandardUser('Lean2');			
		List<String> ids1=new List<String>();
		 	ids1.add(PR.id); 
		    ids1.add(Obj_Room.id); 
		//leankor.TestDataFactory.shareProjectAsReadWriteAccess(user1,ids1);	
		Boolean isVsEdit = leankor.TestDataFactory.shareRecord(user1,ids1,'leankor__ProjectRoom__Share','Edit');
		List<String> ids=new List<String>();
		 	ids.add(Obj_VS.id); 
		    ids.add(vStream.id); 
		 // Date : 11/05/19 create board access.
		//leankor.TestDataFactory.shareBoardAsReadWriteAccess(user1,ids);		
	    Boolean isProjectEdit =leankor.TestDataFactory.shareRecord(user1, ids,'leankor__ValueStream__share','Edit');
		controller.CustomSave();	
		 // Date : 11/05/19 create board access.
		if(isProjectEdit && isVsEdit){
		System.runAs(user1){							  	     	    		      
		      system.assert(ApexPages.currentPage().getParameters().put('id',PR.Id)!=null);           	        	 
        	  System.assert(controller.CustomSave()==null);
               System.assert(controller.closePopup()==null);
	    } 	    	   
		}else {
			   system.assert(ApexPages.currentPage().getParameters().put('id',PR.Id)!=null);           	        	 
        	   System.assert(controller.CustomSave()==null);
               System.assert(controller.closePopup()==null);
		}	    	   
        //CONTROLLER.clearMessage();
        //controller.timerOff();
    }  
}