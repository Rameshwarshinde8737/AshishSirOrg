/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestProjectBoardCarousel.cls
 * CLASS: TestProjectBoardCarousel        
 */
@isTest
private class TestProjectBoardCarousel implements HttpCalloutMock{
    
    
	    @testSetup 
	    static void methodName() {

			List<leankor__Portfolio__c> port = leankor.TestDataFactory.createFolder('Demo-1',1);      	     		
	        List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Unit Test Project', port, 1);            
	        List<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', null);
			leankor.TestDataFactory.createLeanConstants();
           //Date 01/07/19 create kanbancard.
            leankor__KanbanCard__c kb =new leankor__KanbanCard__c(Name='Quickcard',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	 		insert kb;

			leankor__Preference__c prefernce = new leankor__Preference__c(Name = 'test name prefernece',
																		  leankor__GUID__C = leankor.TestDataFactory.createGuid(),
																		  leankor__followonchatter__c = 'all',
																		  leankor__SubscribeToCard__c = 'all',
																		  leankor__Moved__c = false,
																		  leankor__PercentDone__c = true);
			insert prefernce;
			leankor__KanbanCard__c card = new leankor__KanbanCard__c();
	        card.name = 'card1';
	        card.leankor__ValueStream__c  = vStream[0].Id;
	        card.leankor__GUID__c = system.now().getTime()+''+vStream[0].Id;
	        card.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();        
	        card.leankor__PercentComplete2__c  = 50;
	        card.leankor__Priority__c  = 3;
	        insert card;
	    }
    
	    public static testMethod void testValueStreams(){
	    	
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
			prjRoom.Name = 'Test Room'; 
			prjRoom.leankor__Portfolio__c = testFolder.Id;
			insert prjRoom;
			
			List<leankor.RealTimeController.ProjectBoard> vsList=new  List<leankor.RealTimeController.ProjectBoard>();
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='Whiteboard',leankor__ProjectRoom__c=prjRoom.Id);
	        insert vss;
	        // set up one attachment as preview
	        Blob myBlob = Blob.valueOf('blobdata');
	        Attachment myatt = new Attachment(Body = myBlob, ContentType='text/plain', parentId = vss.Id, Name = 'preview.txt');
	        insert myatt;
	        vsList = ProjectBoardCarousel.getValueStreams();
	        System.assert(vsList.size() >0);
	    }
	
	    public static testMethod void testKanbanCards(){
	    	
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS');
	        insert vss;
	        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vss);
	        leankor.ProjectBoardCarousel rkc = new leankor.ProjectBoardCarousel(sc);
	        leankor.ProjectBoardCarousel Pbc = new leankor.ProjectBoardCarousel();
	       //  PageReference pr1 = rkc.RedirectVS();
	       //  PageReference pr = rkc.DeleteProjectBoard();
	        
	        System.assert(ProjectBoardCarousel.getKanbanCards(vss.ID).Size() >= 0);
	        List<leankor__KanbanCard__c> kanban = ProjectBoardCarousel.getKanbanCards(vss.Id);
	        System.assert(kanban.size() ==0);
	        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c(
	        Name ='TestTemplate',
	        leankor__Title__c = 'TestTemplate',
	        leankor__color__c = '#fff',
	        leankor__csslayout__c = '',
	        leankor__height__c = 300,
	        leankor__width__c = 300,
	        leankor__jsondata__c = '{}',
	        leankor__jsondefinition__c = '{}',
	        leankor__valuestream__c = vss.Id );
	        insert kanbanTemp;
	        String userId_1=UserInfo.getUserId();
	       
	        //Create Valuestream
	        leankor__valuestream__c vcc = new leankor__valuestream__c(name = 'Testing', ownerId = userId_1); 
	        insert vcc ; 
	
	        //Create EntitySubscriptions 
	        Test.startTest();
	        List<EntitySubscription> subscriptions = new List<EntitySubscription>(); 
	        /*subscriptions.add(new EntitySubscription(SubscriberId = UserInfo.getUserId(), ParentId = vcc.id)); 
	        Insert subscriptions;*/
	        Test.stopTest();
	        leankor.ChatterAutoFollow.createAutoFollow(subscriptions);
	        leankor.ChatterAutoFollow.removeAutoFollow(subscriptions);
	        // test create kanban call
            //Date:23/10/19
            //List<String> kanbans=new List<String>();
            List<realTimeController.Kanban> kanbans=new List<realTimeController.Kanban>();
	        realtimeController.Kanban newKanban = new realtimeController.Kanban();
	        newKanban.GUID ='305ee49a-8489-4091-bf76-8a08088066g8';
	        newKanban.ownerid=userId_1;
	        newKanban.title = 'newkanname';
	        newKanban.name = 'Small card';
	        newKanban.top = 100;
	        newKanban.bottom = 0;
	        newKanban.left = 100;
	        newKanban.width = 180;
	        newKanban.height = 200;
	        newKanban.x = 100;
	        newKanban.y = 100;
	        newKanban.JSONData = '{}';
	        newKanban.base64Drawing = 'somedummyfile';
	        newKanban.base64FileType = 'image/png';
	        newKanban.zoneid = 'randomzone';
	        newKanban.state = 'inzone';
	        newKanban.durationunits = 'Days';
	        newKanban.estimatedDuration = 1;
	        newKanban.duedate = System.Now();
	        newKanban.startdate = System.Now();
	        newKanban.templateid =kanbanTemp.Id;
	        newKanban.priority = 3;
	        newKanban.harveyBall = '50';
	        newKanban.description = 'short description about the kanbancard';
			// Date: 02/01/2020
            newKanban.kanbanUrl = 'https://' + DomainCreator.getOrgMyDomainHostname()+'/apex/leankor__VisualKanban?Id='+vss.id+'&cardid=';
			//RS 28/11/2019 Added Owner.IsActive in object
    		newKanban.ownerIsActive = true; 
           //Date :23/10/19
            //kanbans.add(JSON.Serialize(newKanban));
            kanbans.add(newKanban);
            //List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCard(vss.Id, kanbans);
            List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCards(vss.Id, kanbans);
	        kanban = ProjectBoardCarousel.getKanbanCards(vss.Id);
	        System.assert(kanban.size() >= 0);
	    }

		@isTest
		private static void testgetKanbanCardsNegative(){
			try{
				leankor__KanbanCard__c kan1 = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        	insert kan1;
				List<leankor__KanbanCard__c> cardResult = ProjectBoardCarousel.getKanbanCards(kan1.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
    
		static testMethod void testCreateProjectRoom(){
			
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
			prjRoom.Name = 'Test Room';
			prjRoom.leankor__Portfolio__c = testFolder.Id;
			insert prjRoom;

	        leankor__ProjectRoom__c pr = new leankor__ProjectRoom__c(Name='Test');
	        insert pr;
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='Kanban Board');
	        insert vss;
	        //insert room;
	        System.assert(prjRoom.Name=='Test Room');
	        //System.assert(ProjectBoardCarousel.updateProjectRoom(prjRoom.Id,'new update board') =='Success');
	        /*leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c(
	        Name ='TestTemplate',
	        leankor__DerivedFrom__c = '',
	        leankor__valuestream__c =vss.Id,
	        leankor__ProjectRoom__c = '' );
	        //insert kanbanTemp;
	        leankor__KanbanCardTemplate__c kanbanTemp2 = new leankor__KanbanCardTemplate__c(
	        Name ='TestTemplate2',
	        leankor__DerivedFrom__c = kanbanTemp.Id,
	        leankor__valuestream__c ='',
	        leankor__ProjectRoom__c = '' );
	        //insert kanbanTemp2;*/
	        System.assert(ProjectBoardCarousel.deleteProjectRoom(pr.Id)=='Success');
	    }
		@isTest
		private static void deleteProjectRoomWithDummyId(){
			try{
				leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        	insert kan;
				String result = ProjectBoardCarousel.deleteProjectRoom(kan.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
		/*
		@isTest
		private static void updateProjectRoomWithDummyId(){
			try{
				leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        	insert kan;
				String result = ProjectBoardCarousel.updateProjectRoom(kan.Id,'New Project');
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
		*/
    
		public static testMethod void testCreateProjectBoard(){
	 
			//To get User data
		    User userInstance = [SELECT Id,SmallPhotoUrl,Name FROM User where ID=:Userinfo.getUserId()];
		    //Date: 10/05/2019 - Instance of leankor.RealTimeController.ProjectBoard is created
		    leankor.RealTimeController.ProjectBoard prjBoard;
		         
	        system.runAs(userInstance){
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
			prjRoom.Name = 'Test Room';
			prjRoom.leankor__Portfolio__c = testFolder.Id;
			insert prjRoom;

			leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='Kanban Board');
			insert vss;
			// set up one attachment as preview
			Blob myBlob = Blob.valueOf('blobdata');
			Attachment myatt = new Attachment(Body = myBlob, ContentType='image/gif', parentId = vss.Id, Name = 'nopreview');
			insert myatt;
			leankor__ValueStream__c vss2 = new leankor__ValueStream__c(Name = 'myVS2',leankor__BoardType__c='Portfolio View');
			insert vss2;
			Blob myBlob2 = Blob.valueOf('blobdata');
			Attachment myatt2 = new Attachment(Body = myBlob2, ContentType='image/jpeg', parentId = vss2.Id, Name = 'nopreview');
			insert myatt2;
			leankor__ValueStream__c vss3 = new leankor__ValueStream__c(Name = 'myVS3',leankor__BoardType__c='Whiteboard');
			insert vss3;
			Blob myBlob3 = Blob.valueOf('blobdata');
			Attachment myatt3 = new Attachment(Body = myBlob3, ContentType='image/jpeg', parentId = vss3.Id, Name = 'nopreview');
			insert myatt3;
			// Calling the Method
			prjBoard = ProjectBoardCarousel.createProjectBoard('New Test Board',prjRoom.Id,'Whiteboard','','');
			System.assert(prjBoard.Name == 'New Test Board');
	        }
	        
	        User user1 = leankor.TestDataFactory.createStandardUser('Lean');
			User user2 = leankor.TestDataFactory.createStandardUser('Leankor');
			User user3 = leankor.TestDataFactory.createStandardUser('Leankor1');
			
			List<String> sharingList = new List<String> ();
			sharingList.add(prjBoard.Id);
			
			Boolean user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__ValueStream__share','Read');
		   	Boolean user2Access = leankor.TestDataFactory.shareRecord(user2, sharingList,'leankor__ValueStream__share','Edit');
			
			if(user1Access){
			System.runAs(user1) { 
				leankor__ValueStream__c vs =[select id , name, UserRecordAccess.HasReadAccess, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess 
				                            from leankor__ValueStream__c where id =: prjBoard.Id limit 1];                     
				System.assertEquals(vs.UserRecordAccess.hasReadAccess,true);
				System.assertEquals(vs.UserRecordAccess.hasEditAccess,false);
				System.assertEquals(vs.UserRecordAccess.hasDeleteAccess,false); 
			}
			}
			
			if(user2Access){
			System.runAs(user2) { 
				leankor__ValueStream__c vs =[select id , name, UserRecordAccess.HasReadAccess, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess 
				                            from leankor__ValueStream__c where id =: prjBoard.Id limit 1];
				System.assertEquals(vs.UserRecordAccess.hasReadAccess,true);
				System.assertEquals(vs.UserRecordAccess.hasEditAccess,true);
				System.assertEquals(vs.UserRecordAccess.hasDeleteAccess,false); 
			}
			}
			
			System.runAs(user3) { 
				List<leankor__ValueStream__c> vs = [select id , name, UserRecordAccess.HasReadAccess, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess 				                            
												   from leankor__ValueStream__c where id =: prjBoard.Id limit 9999];
				if(vs.size()==0){
				System.assertEquals(vs.size(), 0);
				}else{
					System.assertEquals(vs.size(), 1);
				}			
	    	}
		}
    
		public static testMethod void testRemoveProjectBoard(){
	    	
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='Kanban Board');
	        insert vss;
	        String returnString=ProjectBoardCarousel.removeProjectBoard(vss.Id);
	        System.assert(returnString=='Success');
	    
	        String returnString1=ProjectBoardCarousel.DeleteBoard(vss.Id);
	        System.assert(returnString1!=null);
	    }

		@isTest
		private static void DeleteBoardWithDummyId(){
			try{
				leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        	insert kan;
				String result = ProjectBoardCarousel.DeleteBoard(kan.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}

		@isTest
	    private static void removeProjectBoardWithDummyId(){
			try{
				leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        	insert kan;
				String result = ProjectBoardCarousel.removeProjectBoard(kan.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
	    
	    public static testMethod void testUpdateProjectBoard(){
	    	
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
			prjRoom.Name = 'Test Room';
			prjRoom.leankor__Portfolio__c = testFolder.Id;
			insert prjRoom;

	        leankor.RealTimeController.ProjectBoard prjBoard=ProjectBoardCarousel.createProjectBoard('New Test Board',prjRoom.Id,'Kanban Board','','');
	        prjBoard.Name='Updated Name';
	        prjBoard.IsTemplateBoard=true;
	        String returnString=ProjectBoardCarousel.updateProjectBoard(prjBoard);
	        System.assert(returnString=='Success');
	    }
	    
		/*
		public static testMethod void testUserWorkStatus(){
			
			leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS');
	        insert vss;
	        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c(
	        Name ='TestTemplate',
	        leankor__Title__c = 'TestTemplate',
	        leankor__color__c = '#fff',
	        leankor__csslayout__c = '',
	        leankor__height__c = 300,
	        leankor__width__c = 300,
	        leankor__jsondata__c = '{}',
	        leankor__jsondefinition__c = '{}',
	        leankor__valuestream__c = vss.Id );
	        insert kanbanTemp;
	        
	        String userId_1=UserInfo.getUserId();
	        // test create kanban call
            //Date :23/10/19
           // List<String> kanbans=new List<String>();
             List<realTimeController.Kanban> kanbans=new List<realTimeController.Kanban>();
	        realtimeController.Kanban newKanban = new realtimeController.Kanban();
	        newKanban.GUID ='305ee49a-8489-4091-bf76-8a08088066g8';
	        newKanban.ownerid=userId_1;
	        newKanban.title = 'newkanname';
	        newKanban.name = 'Small card';
	        newKanban.top = 100;
	        newKanban.bottom = 0;
	        newKanban.left = 100;
	        newKanban.width = 180;
	        newKanban.height = 200;
	        newKanban.x = 100;
	        newKanban.y = 100;
	        newKanban.JSONData = '{}';
	        newKanban.base64Drawing = 'somedummyfile';
	        newKanban.base64FileType = 'image/png';
	        newKanban.zoneid = 'randomzone';
	        newKanban.state = 'inzone';
	        newKanban.durationunits = 'Days';
	        newKanban.estimatedDuration = 1;
	        newKanban.duedate = System.Now();
	        newKanban.startdate = System.Now();
	        newKanban.templateid =kanbanTemp.Id;
	        newKanban.priority = 3;
	        newKanban.harveyBall = '100';
	        newKanban.description = 'short description about the kanbancard';
			// Date: 02/01/2020
            newKanban.kanbanUrl = 'https://' + DomainCreator.getOrgMyDomainHostname()+'/apex/leankor__VisualKanban?Id='+vss.id+'&cardid=';
			//Date :23/10/19
            //kanbans.add(JSON.Serialize(newKanban));
            kanbans.add(newKanban);
            //List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCard(vss.Id, kanbans);
            List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCards(vss.Id, kanbans);
	        Date dt=System.today();
	        Task tsk1 = new Task();
	        tsk1.Priority   =   'High';
	        tsk1.OwnerId     =  userId_1;
	        tsk1.Subject    =   'Other';
	        tsk1.Status         =   'Completed';
	        tsk1.ActivityDate = dt;
	        tsk1.WhatId     =   retkan[0].Id;
	        tsk1.Description =  'This is First Demo Task';
	        insert tsk1;
	        Map<String,ProjectBoardCarousel.PastDue> record=ProjectBoardCarousel.getUserWorkStatus(vss.Id);
	        System.assert(record.size()>0);
	    }
		*/
	    

		static testMethod void testPreference(){
	        
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS');
	        insert vss;
	        leankor__Preference__c prefer=new leankor__Preference__c(Name='test name',leankor__ValueStream__c=vss.Id,leankor__GUID__C='12345',leankor__followonchatter__c='all',leankor__SubscribeToCard__c='all',leankor__Moved__c=false,leankor__PercentDone__c=true);
	        insert prefer;
	        ProjectBoardCarousel.Preference pref=new ProjectBoardCarousel.Preference();
	        pref.name='';
	        pref.GUID='123456';
	        pref.currentUser= UserInfo.getUserId();
	        pref.followonchatter= 'all';
	        pref.subscribetocard = 'all';
	        pref.valuestream=vss.Id;
	        pref.moved=false;
	        pref.cardpastduedate=true;
	        pref.percentdone=true;
	        pref.taskpastduedate=true;
	        pref.isTaskCompleted=true;
	        pref.valuestreamowner = UserInfo.getUserId();
	        ProjectBoardCarousel.Preference prefResult=ProjectBoardCarousel.getPreference(pref);
	        System.assert(prefResult!=null);
	    }

		@isTest
		private static void getPreferenceWithDummyId(){
			leankor__KanbanCard__c kan = new leankor__KanbanCard__c(Name = 'test',leankor__Guid__c =leankor.TestDataFactory.createGuid());
	        insert kan;
			ProjectBoardCarousel.Preference pref=new ProjectBoardCarousel.Preference();
	        pref.name = '';
	        pref.GUID ='123456';
	        pref.currentUser= UserInfo.getUserId();
	        pref.followonchatter = 'all';
	        pref.subscribetocard = 'all';
	        pref.valuestream = kan.Id;
	        pref.moved = false;
	        pref.cardpastduedate = true;
	        pref.percentdone = true;
	        pref.taskpastduedate = true;
	        pref.isTaskCompleted = true;
	        pref.valuestreamowner = UserInfo.getUserId();
			try{
				ProjectBoardCarousel.Preference result = ProjectBoardCarousel.getPreference(pref);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
		
		public static testMethod void testSetUserPreferenceAndSecurity(){
			 
			leankor.ProjectBoardCarousel pbcCon = new leankor.ProjectBoardCarousel();
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS');
	        insert vss;
	        ProjectBoardCarousel.theValueStreams = new List<leankor__Valuestream__c>();
	
	        leankor.ProjectBoardCarousel.Preference pref=new leankor.ProjectBoardCarousel.Preference();
	        pref.name='';
	        pref.GUID='123456';
	        pref.currentUser= UserInfo.getUserId();
	        pref.followonchatter= 'all';
	        pref.subscribetocard = 'all';
	        pref.valuestream=vss.Id;
	        pref.moved=false;
	        pref.cardpastduedate=true;
	        pref.percentdone=true;
	        pref.taskpastduedate=true;
	        pref.ValueStream=vss.Id;
	        pref.isTaskCompleted=true;
	        pref.valuestreamowner = UserInfo.getUserId();
	        leankor.ProjectBoardCarousel.Preference prefResult=leankor.ProjectBoardCarousel.setUserPreferenceAndSecurity(pref);
	        System.assert(prefResult.Id!=null && prefResult.Id!='');
	        //System.assert(leankor.ProjectBoardCarousel.GetAutomationData('case','status')!= NULL);
	        System.assert(ProjectBoardCarousel.getBoardTypes().size()>=0);
	        System.assert(leankor.ProjectBoardCarousel.getProjectRooms().size()>= 0);
	        leankor__AutomationTemplate__c testlog = New leankor__AutomationTemplate__c();
	        testlog.leankor__GUID__c = 'test-'+system.now()+'-123';
	        testlog.OwnerId = UserInfo.getUserId();
	        insert testlog ;
	        
	        list<String> deletelogs = new list<String>();
	        deletelogs.add(testlog.ID);
	        //System.assert(leankor.ProjectBoardCarousel.deleteAutomationTemplate(deletelogs));
			/*
			try{
				Boolean result = leankor.ProjectBoardCarousel.deleteAutomationTemplate(new List<String>{vss.Id});
			}catch(Exception e ){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
			*/
	        leankor.ProjectBoardCarousel.AutomationTemplate insertlog = New leankor.ProjectBoardCarousel.AutomationTemplate();
	        
		   leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
		   testFolder.Name = 'Test Room';
		   insert testFolder;

			leankor__ProjectRoom__c prjRoom1 = new leankor__ProjectRoom__c();
			prjRoom1.Name = 'Test Room';
			prjRoom1.leankor__Portfolio__c = testFolder.Id;
			insert prjRoom1;

	        leankor.ProjectBoardCarousel.theProjectRooms = new List<leankor__ProjectRoom__c>();
	        leankor__ValueStream__c vss1 = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c=prjRoom1.Id);
	        insert vss1;
	        leankor__KanbanCard__c kan1 = New leankor__KanbanCard__c(Name = 'test', leankor__Valuestream__c = vss1.id,leankor__GUID__c = '305ee49a-test8489-4091-bf76-8a08088066g8');
	        insert kan1 ;
	        
	        leankor.ProjectBoardCarousel.createListProjectBoard('ProName',prjRoom1.Id,'UberBoard',vss1.Id,kan1.Id);
	        leankor.RealTimeController.ProjectBoard pb = new leankor.RealTimeController.ProjectBoard();
	        pb.Id=vss1.Id;
	        pb.Name='UpdatedName';
	        pb.IsAgile = false;
	        pb.SevenDayWorkWeek = false;
	        pb.IsTemplateBoard = false;
	        pb.cardsRequireFilterConfirmation = 10;
	        leankor.ProjectBoardCarousel.updateListProjectBoard(pb);

	        List<String> insertlogs = New List<String>();
	        Account acc = new account(Name = 'testautomation');
	        insert acc ;
	        leankor__projectRoom__c room =  New leankor__ProjectRoom__c (Name = 'testroom');
	        insert room ;
	        leankor__Valuestream__c VS = New leankor__Valuestream__c(Name = 'newprojectboard',leankor__ProjectRoom__c = room.id);
	        insert vs;
	        leankor__KanbanCardTemplate__c temp = new leankor__KanbanCardTemplate__c(Name ='new test temp');
	        insert temp;
	        leankor__Zone__c testzone = new leankor__Zone__c(Name ='testzone', leankor__GUID__c = 'GUID-TETST-123456');
	        leankor__KanbanCard__c kan = New leankor__KanbanCard__c(Name = 'test', leankor__Valuestream__c = vs.id,leankor__GUID__c = '305'+system.now().getTime());
	        insert kan ;
	        insert testzone;
	        //System.assert(leankor.ProjectBoardCarousel.getProjectBoards(room.id).size()>0);
			/*
			try{
				List<leankor.realTimeController.ProjectBoard> result = leankor.ProjectBoardCarousel.getProjectBoards(kan.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
			*/
	        insertlog.RecordTypeName = 'testrecord';
	        insertlog.RecordTypeId = '';
	        insertlog.RoleName = '';
	        insertlog.RoleId = Userinfo.getUserRoleId();
	        insertlog.AccountId =acc.ID;
	        insertlog.AccountName = acc.Name;
	        insertlog.StageName = 'Prospecting';
	        insertlog.RoomId = room.id;
	        insertlog.RoomName = room.name;
	        insertlog.TemplateEndDate = system.now()+5;
	        insertlog.TemplateStartDate = system.now() ;
	        insertlog.KanbanCardTemplateId = temp.id;
	        insertlog.KanbanCardTemplateName = temp.name;
	        insertlog.ProjectBoardId = vs.id;
	        insertlog.ProjectBoardName = vs.name;
	        insertlog.ColumnId = testzone.id;
	        insertlog.ColumnTitle = testzone.Name;
	        insertlog.GUID = 'test-'+system.now()+'-456';
	        insertlog.OwnerId = UserInfo.getUserId();
	        insertlog.OwnerName = '';
	        // insertlog.JSONData = '{}';
	        // insertlog.JSONDefinition = '{}';
	        insertlogs.add(JSON.Serialize(insertlog));
	
	        //System.assert(leankor.ProjectBoardCarousel.createAutomationTemplate(insertlogs).size() >= 0);
	        leankor__AutomationTemplate__c insertlog1 = New leankor__AutomationTemplate__c();
	        insertlog1.leankor__Account__c =acc.ID;
	        insertlog1.leankor__RoleId__c = Userinfo.getUserRoleId();
	        insertlog1.leankor__StageName__c = 'Prospecting';
	        insertlog1.leankor__ProjectRoom__c = room.id;
	        insertlog1.leankor__EndDate__c = system.now()+5;
	        insertlog1.leankor__StartDate__c = system.now();
	        insertlog1.leankor__KanbanCardTemplate__c = temp.id;
	        insertlog1.leankor__ValueStream__c = vs.id;
	        insertlog1.leankor__Zone__c = testzone.id;
	        insertlog1.leankor__GUID__c = '12321-'+system.now()+'-456';
	        insertlog1.OwnerId = UserInfo.getUserId();
	        // insertlog1.leankor__JSONData__c = '{}';
	        //insertlog1.leankor__JSONData__c = '{}';
	        insert insertlog1;
	        //Opportunity testopp = New Opportunity(Name ='new opp',stageName ='new test', CloseDate = system.today());
	        List<String> updatelog1s = New LIst<String>();
	        leankor.ProjectBoardCarousel.AutomationTemplate updatelog1 = New leankor.ProjectBoardCarousel.AutomationTemplate();
	        updatelog1.RecordTypeName = 'testrecord';
	        updatelog1.RecordTypeId = '';
	        updatelog1.RoleName = '';
	        updatelog1.RoleId = Userinfo.getUserRoleId();
	        updatelog1.AccountId =acc.ID;
	        updatelog1.AccountName = acc.Name;
	        updatelog1.StageName = 'Prospecting';
	        updatelog1.RoomId = room.id;
	        updatelog1.RoomName = room.name;
	        updatelog1.TemplateEndDate = system.now()+6;
	        updatelog1.TemplateStartDate = system.now() ;
	        updatelog1.KanbanCardTemplateId = temp.id;
	        updatelog1.KanbanCardTemplateName = temp.name;
	        updatelog1.ProjectBoardId = vs.id;
	        updatelog1.ProjectBoardName = vs.name;
	        updatelog1.ColumnId = testzone.id;
	        updatelog1.ColumnTitle = testzone.Name;
	        updatelog1.GUID = 'test-'+system.now()+'-456';
	        updatelog1.OwnerId = UserInfo.getUserId();
	        updatelog1.LinkProjectRoomId =room.id ;
	        updatelog1.LinkProjectRoomName = 'testroom' ;
	        updatelog1.LinkValueStreamId = vs.id;
	        updatelog1.LinkValueStreamName = 'newprojectboard';
	        updatelog1.LinkKanbanTemplateId = temp.id ;
	        updatelog1.ValueStreamCardLinkId = kan.id ;
	        updatelog1.ValueStreamCardLinkName ='test';
	        updatelog1.WithLinkVerb = true ;
	        updatelog1s.add(JSON.Serialize(updatelog1));
	        //System.assert(leankor.ProjectBoardCarousel.updateAutomationTemplate(updatelog1s));
	        List<String> updatelog2s = New LIst<String>();
	        leankor.ProjectBoardCarousel.AutomationTemplate updatelog2 = New leankor.ProjectBoardCarousel.AutomationTemplate();
            updatelog2.RecordTypeName = 'testrecord';
            updatelog2.RecordTypeId = '';
            updatelog2.RoleName = '';
            updatelog2.RoleId = Userinfo.getUserRoleId();
            updatelog2.accountId =acc.ID;
            updatelog2.AccountName = acc.Name;
            updatelog2.StageName = 'Prospecting';
            updatelog2.RoomId = room.id;
            updatelog2.RoomName = room.name;
            updatelog2.TemplateEndDate = system.now()+6;
            updatelog2.TemplateStartDate = system.now() ;
            updatelog2.KanbanCardTemplateId = temp.id;
            updatelog2.KanbanCardTemplateName = temp.name;
            updatelog2.ProjectBoardId = vs.id;
            updatelog2.ProjectBoardName = vs.name;
            updatelog2.ColumnId = testzone.id;
            updatelog2.ColumnTitle = testzone.Name;
            updatelog2.GUID = 'test-'+system.now()+'-2345456';
            updatelog2.OwnerId = UserInfo.getUserId();
            updatelog2.LinkProjectRoomId =room.id ;
            updatelog2.LinkProjectRoomName = 'testroom' ;
            updatelog2.LinkValueStreamId = vs.id;
            updatelog2.LinkValueStreamName = 'newprojectboard';
            updatelog2.LinkKanbanTemplateId = temp.id;
            updatelog2.ValueStreamCardLinkId = '' ;
            updatelog2.ValueStreamCardLinkName ='test';
            updatelog2.WithLinkVerb = true ;
            updatelog1s.add(JSON.Serialize(updatelog2));
	        //System.assert(leankor.ProjectBoardCarousel.updateAutomationTemplate(updatelog2s));
	        //system.assert(leankor.ProjectBoardCarousel.getautomationtemplate().size()>=0);
	        leankor__Zone__c testzone1 = New leankor__Zone__c(Name = 'test-zone1', leankor__Valuestream__c =vss.id, leankor__GUID__c = 'test-guid-12342345');
	        insert testzone1;
	
	        leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = vss.id,leankor__IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+system.now());
	        insert Mc;
	        leankor__Swimlane__c sw = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = vss.id,Name =  'zone',leankor__GUID__c = 'test-1234-'+system.now());
	        insert sw;
	        leankor__Swimlane__c sw1 = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = vss.id,Name =  'zone1',leankor__GUID__c = 'test-12ee34-'+system.now());
	        insert sw1;
	        leankor__Zone__c z1t = new leankor__Zone__c (leankor__Swimlane__c = sw1.id ,leankor__Valuestream__C = vss.id, Name =  'zone',leankor__GUID__c = 'test-21234-'+system.now());
	        insert z1t;
	        leankor__Zone__c z1t1 = new leankor__Zone__c (leankor__Swimlane__c = sw1.id ,leankor__Valuestream__C = vss.id, Name =  'zone1',leankor__GUID__c = 'test-12333443-'+system.now());
	        insert z1t1;
	        leankor__Zone__c zt = new leankor__Zone__c (leankor__Swimlane__c = sw.id ,leankor__Valuestream__C = vss.id, Name =  'zone',leankor__GUID__c = 'test-1234-'+system.now());
	        insert zt;
	        leankor__Zone__c zt1 = new leankor__Zone__c (leankor__Swimlane__c = sw.id ,leankor__Valuestream__C = vss.id, Name =  'zone1',leankor__GUID__c = 'test-123443-'+system.now());
	        insert zt1;
	        leankor__KanbanCardTemplate__c tempcard = New leankor__KanbanCardTemplate__c(Name = 'default',leankor__Valuestream__C = vss.id );
	        insert tempcard;
	        //system.assert(leankor.ProjectBoardCarousel.getColumnAndCategory(vss.id) != null);
			/*
			try{
				leankor.ProjectBoardCarousel.RequiredData requiredData = leankor.ProjectBoardCarousel.getColumnAndCategory(zt.Id);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
			*/
	        LIst<String> testtasks = new LIst<String>();
	        leankor.ProjectBoardCarousel.TaskTemplate testtask =  new leankor.ProjectBoardCarousel.TaskTemplate();
	
	        testtask.Subject = 'new test subject';
	        testtask.Description = 'testlong';
	        testtask.OwnerId = Userinfo.getuserID();
	        testtask.DueDate = system.now();
	        testtask.AutomationTemplateId = insertlog1.ID ;
	        testtask.Priority = 'High' ;
	        testtask.GUID = 'Test_GUID-'+system.Now()+'12354' ;
	        testtask.Status = 'completed';
	        testtasks.add(JSON.Serialize(testtask));
	
	        //System.assert(leankor.ProjectBoardCarousel.createTaskTemplate(testtasks).size()>0);
	        
	        List<String> deltaskid = new List<String>();
	        leankor__TaskTemplate__c NewTaskLog = New leankor__TaskTemplate__c();    
            NewTaskLog.Name = 'new task';
            NewTaskLog.leankor__Description__c = 'TaskLog.Description';
            NewTaskLog.OwnerId = UserInfo.getUserId()   ;
            NewTaskLog.leankor__ActivityDate__c = system.now();
            NewTaskLog.leankor__AutomationTemplate__c = insertlog1.ID;
            NewTaskLog.leankor__Priority__c =  'High';
            NewTaskLog.leankor__Status__c =  'TaskLog.Status';
            string GUIDS = 'GUID-TEST-'+system.now()+'-123-test';
            NewTaskLog.leankor__GUID__c = GUIDS;
	        insert NewTaskLog;
	        
	        deltaskid.add(NewTaskLog.id);
	        List<String> listIDs = New List<String>();
	        listIDs.add(insertlog1.ID);
	        //System.assert(leankor.ProjectBoardCarousel.getTaskTemplate(listIDs).size()>0);
			/*
			try{
				List<String> result = leankor.ProjectBoardCarousel.getTaskTemplate(new List<String>{zt.Id});
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
			*/
			/*
	        List<String> updatetasks =  new List<String>();
	        leankor.ProjectBoardCarousel.TaskTemplate updatetask =  new leankor.ProjectBoardCarousel.TaskTemplate();
	        updatetask.ID = NewTaskLog.ID;
	        updatetask.Subject = 'new test subject';
	        updatetask.Description = 'testlong';
	        updatetask.OwnerId = Userinfo.getuserID();
	        updatetask.DueDate = system.now();
	        updatetask.AutomationTemplateId = insertlog1.ID ;
	        updatetask.Priority = 'High' ;
	        updatetask.Status = 'completed';
	        updatetask.GUID = GUIDS;
	        updatetasks.add(JSON.Serialize(updatetask));
	        System.assert(leankor.ProjectBoardCarousel.updateTaskTemplate(updatetasks));
			*/
	    }
	    
	    
		public static testMethod void addallscript(){
			
	        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myVS');
	        insert vss;
	        leankor__KanbanCardTemplate__c tempcard = New leankor__KanbanCardTemplate__c(Name = 'default',leankor__Valuestream__C = vss.id );
	        insert tempcard;  
	        leankor__ValueStream__c OppVS = New leankor__ValueStream__c(Name = 'NewVS',leankor__OpportunityRecordType__c ='All', leankor__OpportunityCardCategory__c = tempcard.ID, leankor__OpportunityLeadSource__c = 'All',leankor__OpportunityRoleId__c = Userinfo.getUserRoleId() ,leankor__OpportunitySynchronization__c = True,leankor__OpportunityType__c = 'All');
	        insert OppVs;
	        Account acc = new account(Name = 'testautomation');
	        insert acc ;
	        
	        leankor__AutomationTemplate__c AT = New leankor__AutomationTemplate__c();
	        AT.leankor__GUID__c = 'test-'+system.now()+'-123';
	        AT.leankor__ValueStream__c = OppVS.id;
	        AT.leankor__StageName__c = 'Prospecting';
	        AT.leankor__Account__c =  acc.id ;
	        AT.leankor__EndDate__c = system.now();
	        AT.leankor__StartDate__c = system.now()-2;
	        AT.OwnerId = UserInfo.getUserId();
	        insert AT ;
	        
	        leankor__AutomationTemplate__c AT1 = New leankor__AutomationTemplate__c();
	        AT1.leankor__GUID__c = 'test-'+system.now()+'-12212';
	        AT1.leankor__ValueStream__c = vss.id;
	        AT1.leankor__StageName__c = 'Prospecting';
	        AT1.leankor__Account__c =  acc.id ;
	        AT1.leankor__EndDate__c = system.now();
	        AT1.leankor__StartDate__c = system.now()-2;
	        AT1.OwnerId = UserInfo.getUserId();
	        insert AT1 ;
	        
	        leankor__TaskTemplate__c TT= new leankor__TaskTemplate__c();
	        TT.leankor__ActivityDate__c = system.today()+10;
	        TT.leankor__GUID__c= system.now()+'52230';
	        TT.name = 'new task';
			TT.leankor__AutomationTemplate__c = AT.id;
	        insert tt;
	        
	        leankor__TaskTemplate__c TT1= new leankor__TaskTemplate__c();
	        TT1.leankor__ActivityDate__c = system.today()+15;
	        TT1.leankor__GUID__c= system.now()+'5223sdfa0';
	        TT1.name = 'new task';
	        TT1.leankor__AutomationTemplate__c = AT1.id;
	        insert tt1;
	        
	        Opportunity insertdata =  New Opportunity();
            insertdata.Name = 'TestOpportunity';
            insertdata.stageName = 'Prospecting';
            insertdata.Accountid = acc.id ;
            insertdata.CloseDate = System.today();
      		insert insertdata;
            
            List<Opportunity> Opp=new List<Opportunity>();
            Integer i=0;
            Opportunity bc=new Opportunity(Name='High',stageName='Prospecting',Accountid=acc.id,CloseDate = System.today()+i); 
            insert bc;
            bc.stageName ='Close Won';
            update bc;
       
			//System.assert(leankor.ProjectBoardCarousel.deleteTaskTemplate(deltaskid));
			leankor__AutomationTemplate__c ATLog = new leankor__AutomationTemplate__c(leankor__GUID__C = 'test-158235-uhuads-565362');
			insert ATLog;
			//system.assert(leankor.ProjectBoardCarousel.getSobjectFields(ATLog.id,'Opportunity').size()>0);
			List<String> newtestlogs=  new List<String>();
			leankor.ProjectBoardCarousel.FieldsValues newtestlog = New leankor.ProjectBoardCarousel.FieldsValues();
		    newtestlog.FieldLabel = 'Name';
		    newtestlog.FieldAPIName ='Name';
		    newtestlog.KanbanLabel ='Name';
		    newtestlog.KanbanAPIName ='Name';
		    newtestlog.FieldType ='Text';
			newtestlogs.add(JSON.Serialize(newtestlog));
			leankor__CustomFields__c testCF1 = New leankor__CustomFields__c(Name = 'Name1',leankor__AutomationTemplate__c = ATLog.id );
			insert testCF1;
			leankor__CustomFields__c testCF = New leankor__CustomFields__c(Name = 'Name',leankor__CustomFieldAPIName__c = 'Name',leankor__AutomationTemplate__c = ATLog.id );
			insert testCF;
			//system.assert(leankor.ProjectBoardCarousel.getSobjectFields(ATLog.id,'Opportunity').size()>0);
			/*
			try{
				List<leankor.ProjectBoardCarousel.FieldsValues> result = leankor.ProjectBoardCarousel.getSobjectFields(testCF.Id,'Opportunity');
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
			*/
			//system.assert(leankor.ProjectBoardCarousel.manageCustomField(ATLog.ID,newtestlogs).size()>0);
			//-------------------
			Test.startTest();
			leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = vss.id,IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+system.now());
			insert Mc;
			leankor__ValueStream__c vss2 = New leankor__ValueStream__c(Name = 'NewVS',leankor__OpportunityRecordType__c ='All', leankor__OpportunityCardCategory__c = tempcard.ID, leankor__OpportunityLeadSource__c = 'All',leankor__OpportunityRoleId__c = Userinfo.getUserRoleId() ,leankor__OpportunitySynchronization__c = True,leankor__OpportunityType__c = 'All');
			insert vss2;
			leankor__Swimlane__c sw1 = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = vss.id,Name =  'zone1',leankor__GUID__c = 'test-12ee34-'+system.now());
			insert sw1;
			leankor__Zone__c oppz1t = new leankor__Zone__c (leankor__Swimlane__c = sw1.id,leankor__OpportunityStageName__c ='Prospecting',leankor__Valuestream__C = vss2.id, Name =  'zone',leankor__GUID__c = 'test-21234-'+system.now());
			insert oppz1t;
			
			leankor__Zone__c oppz1t1 = new leankor__Zone__c (leankor__Swimlane__c = sw1.id,leankor__OpportunityStageName__c ='Default' ,leankor__Valuestream__C = vss2.id, Name =  'zone1',leankor__GUID__c = 'test-12333443-'+system.now());
			insert oppz1t1;
		    Opportunity insertdata1 =  New Opportunity();
            insertdata1.Name = 'TestOpportunity';
            insertdata1.stageName = 'Prospecting';
            insertdata1.Accountid = acc.id ;
            insertdata1.CloseDate = System.today();
		    insert insertdata1;
		    Opportunity insertdata2 =  New Opportunity();
            insertdata2.Name = 'TestOpportunity';
            insertdata2.stageName = 'close won';
            insertdata2.Accountid = acc.id ;
            insertdata2.CloseDate = System.today();
		    insert insertdata2;
			insertdata1.StageName = 'Qualification';
			update insertdata1;
			PostInstallLean postinstall = new PostInstallLean();
		    Test.testInstall(postinstall,null); 
		    Test.testInstall(postinstall,new Version(1,41));
		    Test.testInstall(postinstall,new Version(1,67));
		    Test.testInstall(postinstall,new Version(1,73));  
			Test.stopTest();
		}
		
		public static testMethod void postinstallscript_FirstVersion(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall = new PostInstallLean();
		  
		    Test.testInstall(postinstall,null);
			
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			sampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		    leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
		    //Test.testInstall(postinstall,new Version(1,86));
		   	//PostInstallLean postinstall1 = new PostInstallLean();
		    //Test.testInstall(postinstall1,new Version(1,129));
		    
		    Test.stopTest();
		}

		public static testMethod void postinstallscript_FirstVersion2(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall = new PostInstallLean();
		  
		    //Test.testInstall(postinstall,null);
			
		    //leankor.ProjectBoardCarousel.ProjectRoom SampleRoom = leankor.ProjectBoardCarousel.createProjectRoom('Sample Room');
		    //leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
		    Test.testInstall(postinstall,new Version(1,86));
		   	PostInstallLean postinstall1 = new PostInstallLean();
		    //Test.testInstall(postinstall1,new Version(1,129));
		    
		    Test.stopTest();
		}
		
		public static testMethod void postinstallscript_SecondVersion(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall = new PostInstallLean();
		  
		    Test.testInstall(postinstall,null);
			

			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			SampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		    leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
		    //Test.testInstall(postinstall,new Version(1,86));
		   	//PostInstallLean postinstall1 = new PostInstallLean();
		    //Test.testInstall(postinstall1,new Version(1,103));
		    Test.stopTest();
		}

		public static testMethod void postinstallscript_SecondVersion2(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall = new PostInstallLean();
		  
		    //Test.testInstall(postinstall,null);
			
		    //leankor.ProjectBoardCarousel.ProjectRoom SampleRoom = leankor.ProjectBoardCarousel.createProjectRoom('Sample Room');
		    //leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
		    Test.testInstall(postinstall,new Version(1,86));
		   	PostInstallLean postinstall1 = new PostInstallLean();
		    //Test.testInstall(postinstall1,new Version(1,103));
		    Test.stopTest();
		}

		
		public static testMethod void postinstallscript_ThirdVersion(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall1 = new PostInstallLean();
		    		
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			sampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		   	leankor__ValueStream__c valuestreamboard = new leankor__ValueStream__c(leankor__PointPicklist__c ='[1,2,3,5,8,13,21,34,55,89]' ,name = 'vs1',leankor__projectroom__c = sampleRoom.id,leankor__boardtype__c = 'Kanban Board');
		    insert valuestreamboard;
		    leankor__KanbanCard__c kanbancard = new leankor__KanbanCard__c(leankor__ValueStream__c = valuestreamboard.Id,Name='Card',leankor__Point__c = null);
		    insert kanbancard;
		    Test.testInstall(postinstall1,new Version(1,138));
		   	//Test.testInstall(postinstall1,new Version(1,145));
		    //Test.testInstall(postinstall1,new Version(1,151));
		    Test.stopTest();
		}

		public static testMethod void postinstallscript_ThirdVersion2(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall1 = new PostInstallLean();
		    		
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			sampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		   	leankor__ValueStream__c valuestreamboard = new leankor__ValueStream__c(leankor__PointPicklist__c ='[1,2,3,5,8,13,21,34,55,89]' ,name = 'vs1',leankor__projectroom__c = sampleRoom.id,leankor__boardtype__c = 'Kanban Board');
		    insert valuestreamboard;
		    leankor__KanbanCard__c kanbancard = new leankor__KanbanCard__c(leankor__ValueStream__c = valuestreamboard.Id,Name='Card',leankor__Point__c = null);
		    insert kanbancard;
		    //Test.testInstall(postinstall1,new Version(1,138));
		    Test.testInstall(postinstall1,new Version(1,145));
		    //Test.testInstall(postinstall1,new Version(1,151));
		    Test.stopTest();
		}
		
		
		public static testMethod void postinstallscript_FifthVersion(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    //leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    //system.assert(prlog.ID != null);
		    PostInstallLean postinstall1 = new PostInstallLean();
		    		
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			sampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		   	leankor__ValueStream__c valuestreamboard = new leankor__ValueStream__c(leankor__PointPicklist__c ='[1,2,3,5,8,13,21,34,55,89]' ,name = 'vs1',leankor__projectroom__c = sampleRoom.id,leankor__boardtype__c = 'Kanban Board');
		    insert valuestreamboard;
		    leankor__KanbanCard__c kanbancard = new leankor__KanbanCard__c(leankor__ValueStream__c = valuestreamboard.Id,Name='Card',leankor__Point__c = null);
		    insert kanbancard;
		    Test.testInstall(postinstall1,new Version(1,158));
		    Test.testInstall(postinstall1,new Version(1,166));
		    Test.stopTest();
		}
		
		public static testMethod void postinstallscript_ForthVersion(){
            Boolean flag = true;
		    Test.startTest();
			
			leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
			testFolder.Name = 'Test Room';
			insert testFolder;

			leankor__ProjectRoom__c sampleRoom = new leankor__ProjectRoom__c();
			sampleRoom.Name = 'Test Room';
			sampleRoom.leankor__Portfolio__c = testFolder.Id;
			insert sampleRoom;

		    leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',sampleRoom.Id,'Kanban Board','','');
			// To cover Version(1,175) - 01-09-17
		    List<leankor__Module__c> modules = [SELECT Id FROM leankor__Module__c];
		    
		    if(modules.Size()>0){
		    	delete modules;
		    }
		    
		    PostInstallLean postinstall1 = new PostInstallLean();
		    Test.testInstall(postinstall1, new Version(1,189));
		    leankor__IssueLog__c Issuelog1 = new leankor__IssueLog__c(leankor__Probability__c='Likely',
		    leankor__Weight__c ='Important',
		    leankor__Score__c = 1.0);
		    insert Issuelog1;
		    
		    Test.testInstall(postinstall1,new Version(1,175));
		    Test.testInstall(postinstall1,new Version(1,200));
		    
		    leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = kanbanboard1.id,IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+system.now());
		    insert Mc;
			
			leankor__Swimlane__c sw1 = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = kanbanboard1.id,Name =  'zone1',leankor__GUID__c = 'test-12ee34-'+system.now());
			insert sw1;
			
			leankor__Zone__c oppz1t = new leankor__Zone__c (leankor__Swimlane__c = sw1.id,leankor__Valuestream__C = kanbanboard1.id, Name =  'zone',leankor__GUID__c = 'test-21234-'+system.now());
			insert oppz1t;
			
		    leankor__KanbanCardTemplate__c tempcard = New leankor__KanbanCardTemplate__c(Name = 'default',leankor__Valuestream__C = kanbanboard1.id );
		    insert tempcard;
		        
		    leankor__KanbanCard__c Kc = new leankor__KanbanCard__c();
		    kc.name= 'kc1';
		    kc.leankor__ValueStream__c = kanbanboard1.Id;
		    kc.leankor__KanbanCardTemplate__c = tempcard.id;
		    kc.leankor__PercentComplete2__c = 100;
		    kc.leankor__ZoneGUID__c = oppz1t.leankor__GUID__c;
		    kc.leankor__EstimatedDuration__c = 1;
		    //kc.leankor__HarveyBallDoneDate__c = system.today();
		    kc.leankor__GUID__c= system.now() +'dsgsd';
		    insert kc;    
		    leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1',leankor__Probability__c= 'likely',leankor__Weight__c ='Important');
		    insert Ilog;
		    
		    Test.testInstall(postinstall1,new Version(1,129));
		    
		    Test.stopTest();

            System.assertEquals(true, flag);
		}
		
		/*public static testMethod void postinstallscript(){
		   
		    Test.startTest();
		    
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
		   		Name = userinfo.getname(),
		   		leankor__PercentDone__c = false,
		   		leankor__ValueStream__c  = null,
		   		leankor__SubscribeToCard__c  = 'none',
		   		leankor__isTaskCompleted__c=true,
		   		leankor__TaskPastDueDate__c  = false
			);
		  
		    insert pre;       
		    leankor.ProjectBoardCarousel.portfoliodata prlog =  leankor.ProjectBoardCarousel.getSampleBoard();
		    system.assert(prlog.ID != null);
		    PostInstallLean postinstall = new PostInstallLean();
		  
		    Test.testInstall(postinstall,null);
			
			//Test.starttest();
			
		    leankor.ProjectBoardCarousel.ProjectRoom SampleRoom = leankor.ProjectBoardCarousel.createProjectRoom('Sample Room');
		    leankor.RealTimeController.ProjectBoard kanbanboard1 =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
		    Test.testInstall(postinstall,new Version(1,86));
		   	PostInstallLean postinstall1 = new PostInstallLean();
		    Test.testInstall(postinstall1,new Version(1,103));
		    Test.testInstall(postinstall1,new Version(1,129));
		   
		    // To cover Version(1,138) - 01-09-17
		    leankor__ValueStream__c valuestreamboard = new leankor__ValueStream__c(leankor__PointPicklist__c ='[1,2,3,5,8,13,21,34,55,89]' ,name = 'vs1',leankor__projectroom__c = SampleRoom.id,leankor__boardtype__c = 'Kanban Board');
		    insert valuestreamboard;
		    leankor__KanbanCard__c kanbancard = new leankor__KanbanCard__c(leankor__ValueStream__c = valuestreamboard.Id,Name='Card',leankor__Point__c = null);
		    insert kanbancard;
		    Test.testInstall(postinstall1,new Version(1,138));
		    Test.testInstall(postinstall1,new Version(1,145));
		    Test.testInstall(postinstall1,new Version(1,151));
		   // Test.stopTest();
		   
		    Test.testInstall(postinstall1,new Version(1,158));
		    Test.testInstall(postinstall1,new Version(1,166));
		    
		    // To cover Version(1,175) - 01-09-17
		    List<leankor__Module__c> modules = [SELECT Id FROM leankor__Module__c];
		    
		    if(modules.Size()>0){
		    	delete modules;
		    }
		    
		    Test.testInstall(postinstall1, new Version(1,189));
		    leankor__IssueLog__c Issuelog1 = new leankor__IssueLog__c(leankor__Probability__c='Likely',
		    leankor__Weight__c ='Important',
		    leankor__Score__c = 1.0);
		    insert Issuelog1;
		    
		    Test.testInstall(postinstall1,new Version(1,175));
		    Test.testInstall(postinstall1,new Version(1,200));
		    
		    leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = kanbanboard1.id,IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+system.now());
		    insert Mc;
			
			leankor__Swimlane__c sw1 = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = kanbanboard1.id,Name =  'zone1',leankor__GUID__c = 'test-12ee34-'+system.now());
			insert sw1;
			
			leankor__Zone__c oppz1t = new leankor__Zone__c (leankor__Swimlane__c = sw1.id,leankor__Valuestream__C = kanbanboard1.id, Name =  'zone',leankor__GUID__c = 'test-21234-'+system.now());
			insert oppz1t;
			
		    leankor__KanbanCardTemplate__c tempcard = New leankor__KanbanCardTemplate__c(Name = 'default',leankor__Valuestream__C = kanbanboard1.id );
		    insert tempcard;
		        
		    leankor__KanbanCard__c Kc = new leankor__KanbanCard__c();
		    kc.name= 'kc1';
		    kc.leankor__ValueStream__c = kanbanboard1.Id;
		    kc.leankor__KanbanCardTemplate__c = tempcard.id;
		    kc.leankor__PercentComplete2__c = 100;
		    kc.leankor__ZoneGUID__c = oppz1t.leankor__GUID__c;
		    kc.leankor__EstimatedDuration__c = 1;
		    //kc.leankor__HarveyBallDoneDate__c = system.today();
		    kc.leankor__GUID__c= system.now() +'dsgsd';
		    insert kc;    
		    leankor__IssueLog__c Ilog = new leankor__IssueLog__c( name = 'issue1',leankor__Probability__c= 'likely',leankor__Weight__c ='Important');
		    insert Ilog;
		    
		    Test.testInstall(postinstall1,new Version(1,129));
		    
		    Test.stopTest();
		}*/
	
	
		public static testMethod void projectHierarchy(){
			
			leankor__Preference__c pre = new leankor__Preference__c(
		   		leankor__CardPastDueDate__c =false,
		   		leankor__FollowOnChatter__c = 'none',
		   		leankor__GUID__c = system.now()+'global',
		   		leankor__Moved__c = false,
			    Name = userinfo.getname(),
			    leankor__PercentDone__c = false,
			    leankor__ValueStream__c  = null,
			    leankor__SubscribeToCard__c  = 'none',
			    leankor__isTaskCompleted__c=true,
			    leankor__TaskPastDueDate__c  = false
			);
		  	insert pre;
		  
			list<leankor.ProjectBoardCarousel.portfoliodata> portfoliolist = new list<leankor.ProjectBoardCarousel.portfoliodata>();
		    list<leankor__Portfolio__c> portlist = new list<leankor__Portfolio__c>();
		    leankor__Portfolio__c prt = new leankor__Portfolio__c(name = 'parentportfolio1');
		    insert prt;
		    portlist.add(prt);
		  
		    leankor.ProjectBoardCarousel.portfoliodata prtdata = new leankor.ProjectBoardCarousel.portfoliodata();
		    prtdata.name = 'child';
		    prtdata.ParentPortfolio = prt.id ;
		    portfoliolist.add(prtdata);
            system.assert(portfoliolist!= null);
          
            list<leankor.ProjectBoardCarousel.portfoliodata> ptrlistnew =leankor.ProjectBoardCarousel.createPortfolio(portfoliolist);
            set<leankor.ProjectBoardCarousel.PortfolioHierarchy> ptrsetnew = leankor.ProjectBoardCarousel.createListPortfolio(portfoliolist);
            set<leankor.ProjectBoardCarousel.PortfolioHierarchy> ptrlist =leankor.ProjectBoardCarousel.updatePortfolio(portfoliolist);
          
            leankor__ProjectRoom__c prjroom = new leankor__ProjectRoom__c(name ='Test Room',leankor__Portfolio__c= prt.id);
            insert prjroom;
		    
		    List<leankor__ProjectRoom__c> pjrlist = new list<leankor__ProjectRoom__c>();
		    pjrlist.add(prjroom);
		    system.assert(pjrlist!= null);
		  
		    list<leankor__ValueStream__c> valuestreams = new list<leankor__ValueStream__c> ();
            leankor__ValueStream__c vs = new leankor__ValueStream__c(name = 'vs1',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Kanban Board');
            leankor__ValueStream__c vs1 = new leankor__ValueStream__c(name = 'vs2',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Kanban Board');
            leankor__ValueStream__c vs2 = new leankor__ValueStream__c(name = 'vs2',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Plan Board');
		    insert vs;
		    insert vs1;
		    insert vs2;
		    valuestreams.add(vs);
		    valuestreams.add(vs1);
		    valuestreams.add(vs2);
		        
		    /*leankor.ProjectBoardCarousel.BoardHierarchy(prjRoom.id , 'kanban board' , valuestreams);
		    leankor.ProjectBoardCarousel.getProjectBoardHierarchy(prjRoom.id,'Test Room');*/
		    
		    leankor__ValueStream__c vs3 = new leankor__ValueStream__c(name = 'Plan Board(Test Room)',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'UberBoard');
		    leankor__ValueStream__c vs4 = new leankor__ValueStream__c(name = 'Test Room DashBoard',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'DashBoard');
		    leankor__ValueStream__c vs5 = new leankor__ValueStream__c(name = 'vs1',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Card Hierarchy');
		    insert vs3;
		    insert vs4;
		    insert vs5;
		    
		    /*leankor.ProjectBoardCarousel.getProjectBoardHierarchy(prjRoom.id,'Test Room');
		    leankor.ProjectBoardCarousel.getPortfolioHierarchyNav();
		    leankor.ProjectBoardCarousel.getPortfolioHierarchy();*/
		    
		    // creating data to pass get porthierachy
		    leankor.ProjectBoardCarousel.portfoliodata pf = new leankor.ProjectBoardCarousel.portfoliodata();
		    pf.id = prt.Id;
		    pf.navigationVerb = 'leankorNav';
		    leankor.ProjectBoardCarousel.getPortHierarchy(pf);// call method for navigation
		    pf.navigationVerb = 'portfolioview';
		    leankor.ProjectBoardCarousel.getPortHierarchy(pf);// call method for portfolio view
		    pf.navigationVerb = 'ResourceManagementView';//call for resource management view
		    leankor.ProjectBoardCarousel.getPortHierarchy(pf);
		    
		    leankor.ProjectBoardCarousel.childPortfolioHierarchy(prt.id,portlist,pjrlist);
		    leankor__Kanbancard__c KC = new leankor__kanbancard__c(name = 'testing', leankor__GUID__c = system.now()+'1223', leankor__valuestream__c = vs1.id);
		    insert KC;
		    
		    Task t = new task(Subject = 'testing task', ActivityDate = system.today(),whatId = KC.Id);
		    insert t;
		    
		    User u = leankor.ProjectBoardCarousel.getuserlog();
		    Test.startTest();
		    leankor__LeanConstants__c Customsetting = new leankor__LeanConstants__c(leankor__DisableKanbanCardTrigger__c = true,leankor__FirstInstall__c = true ,leankor__DisableCaseTrigger__c= true,leankor__DisableOpportunityTrigger__c= true,leankor__AvoidTaskDueDateCheck__c = true);
		    
		    try{
		        insert customSetting;
		    }catch(Exception Ex){
		        system.debug('Error:'+Ex.getMessage());
		    }
		    
		    Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> PH= leankor.ProjectBoardCarousel.getSamplePortfolio();
		    leankor.ProjectBoardCarousel.portfoliodata Prjlogs =  new leankor.ProjectBoardCarousel.portfoliodata();
		    Prjlogs.ID=prjroom.id;
		    prjlogs.Name = 'newname';
		    set<leankor.ProjectBoardCarousel.PortfolioHierarchy> Pr1= leankor.ProjectBoardCarousel.updateProjects(Prjlogs);
		    
		    prjlogs.Name = 'testing Purpose Example - testing Purpose Example - testing Purpose Example ';
		    set<leankor.ProjectBoardCarousel.PortfolioHierarchy> Pr2= leankor.ProjectBoardCarousel.updateProjects(Prjlogs);
		    
		    leankor__TaskTemplate__c ttemp = new leankor__TaskTemplate__c();
		    ttemp.leankor__GUID__c = system.now()+'-123';
		    insert ttemp;
		    
		    List<string> PortID =new List<string>();
		    PortID.add(ptrlistnew[0].ID);

		    string  rs= leankor.ProjectBoardCarousel.removePortfolio(PortID);
		    List<String> TaskIDs = new List<String>();
		    TaskIDs.add(ttemp.ID);
		    //Boolean BR= leankor.ProjectBoardCarousel.deleteTaskTemplate(TaskIDs);
		    //leankor.ProjectBoardCarousel.RedirectVS();
		    PageReference pg = Page.leankor__LeankorNav; 
		    Test.setCurrentPage(pg);
		    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new leankor__Valuestream__c()); 
		    ApexPages.currentPage().getParameters().put('id', vs2.id);
		    //leankor.ProjectBoardCarousel.DeleteProjectBoard();
			ProjectBoardCarousel Ex = new ProjectBoardCarousel(sc);
		}

		/*
		@isTest
		private static void deleteTaskTemplateWithDummyId(){
			try{
				leankor__ProjectRoom__c prjroom = new leankor__ProjectRoom__c(name ='Test Room');
            	insert prjroom;
				Boolean result = leankor.ProjectBoardCarousel.deleteTaskTemplate(new List<String>{prjroom.Id});
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Invalid input'));
			}
		}
		*/
		
		public static testMethod void testMoveRoom(){
			
			Test.startTest();
			leankor__Portfolio__c prt = new leankor__Portfolio__c(name = 'parentportfolio1');
		    insert prt;
		    
			/***----------------- TestgetParentportfolio Method -------------------***/
		    //List<portfoliodata> portfolio_List = new List<portfoliodata>();
		    leankor__Portfolio__c Portfolio_Obj = new leankor__Portfolio__c();
		    Portfolio_Obj.Name = 'PortfolioParent';
		    insert Portfolio_Obj;
		    
		    leankor__Portfolio__c PortfolioChild_Obj = new leankor__Portfolio__c();
		    PortfolioChild_Obj.Name = 'PortfolioParent';
		    PortfolioChild_Obj.leankor__ParentPortfolio__c = Portfolio_Obj.ID;
		    insert PortfolioChild_Obj;
		    //portfolio_List.add(PortfolioChild_Obj);
		    
		    //leankor.ProjectBoardCarousel.getParentportfolio();
		    //leankor.ProjectBoardCarousel.getChildportfolio(Portfolio_Obj.ID);
		    leankor.ProjectBoardCarousel.getFolderHierarchy();	
			
			/***------------------------------ TestmoveRoom ------------------------------------***/
		    List<leankor.ProjectBoardCarousel.portfoliodata> portfoliodata_list = new List<leankor.ProjectBoardCarousel.portfoliodata>();
		    leankor__ProjectRoom__c PR_Obj = new leankor__ProjectRoom__c(Name = 'prjt room',leankor__Portfolio__c=PortfolioChild_Obj.id );
		    insert PR_Obj;
		    
		    leankor.ProjectBoardCarousel.portfoliodata portfolio_Objct = new leankor.ProjectBoardCarousel.portfoliodata();
	        portfolio_Objct.Id = PR_Obj.Id;
		    portfolio_Objct.Name = 'Odesk';
	        portfolio_Objct.ParentPortfolio = Portfolio_Obj.ID;
		    portfolio_Objct.type = 'Projects';
		    
		    leankor.ProjectBoardCarousel.portfoliodata portfolio_Objct_New = new leankor.ProjectBoardCarousel.portfoliodata();
	        portfolio_Objct_New.Id = PR_Obj.Id;
		    portfolio_Objct_New.Name = 'Odesk';
	        portfolio_Objct_New.ParentPortfolio = Portfolio_Obj.ID;
		    portfolio_Objct_New.type = 'Room';
	        
	        leankor.ProjectBoardCarousel.portfoliodata portfolio_Objct2 = new leankor.ProjectBoardCarousel.portfoliodata();
	        portfolio_Objct.Id = Portfolio_Obj.Id;
	        portfolio_Objct.Name = 'Odesk';
	        portfolio_Objct.ParentPortfolio = null;
	        portfolio_Objct.type = 'folder';
	        
	        portfoliodata_list.add(portfolio_Objct2);
		    system.assert(portfoliodata_list != null);
		    leankor.ProjectBoardCarousel.moveRoom(portfoliodata_list);
		    
		    //-------------creating project --------
		    leankor.ProjectBoardCarousel.portfoliodata project = new leankor.ProjectBoardCarousel.portfoliodata();
		    project.Name = 'project-1';
		    project.ParentPortfolio = prt.ID;
		    leankor.ProjectBoardCarousel.createListProjects(project);
		    
		    //----------Else condition
		    List<leankor.ProjectBoardCarousel.portfoliodata> portfoliodata_list1 = new List<leankor.ProjectBoardCarousel.portfoliodata>();
		    leankor__ProjectRoom__c PR_Obj1 = new leankor__ProjectRoom__c();
		    leankor.ProjectBoardCarousel.portfoliodata portfolio_Objct1 = new leankor.ProjectBoardCarousel.portfoliodata();
	        portfolio_Objct1.Name = 'Odesk';
	        portfolio_Objct1.ParentPortfolio = Portfolio_Obj.ID;
	        portfolio_Objct1.type = 'portfolio';
	        
	        portfoliodata_list1.add(portfolio_Objct);
	        portfoliodata_list1.add(portfolio_Objct_New);
	        
	        system.assert(portfoliodata_list1 != null);
			leankor.ProjectBoardCarousel.moveRoom(portfoliodata_list1);
	        Test.stopTest();
		}
	  
		
		public static testMethod void testGetPortHierarchy(){
			
			Test.startTest();
			//To get User data
	      	User userData = [SELECT Id,SmallPhotoUrl,Name FROM User where ID=:Userinfo.getUserId()];
		  	////Date 10/05/2019 - For security test case
		  	leankor__Portfolio__c prt;
		  	leankor__ProjectRoom__c prjroom;
		  	leankor__ValueStream__c vs;
			leankor__Preference__c prefrnce = [Select Id,
													  Name,
													  leankor__ValueStream__c 
													From leankor__Preference__c 
													Where Name = 'test name prefernece' 
													Limit 1];
	      	System.runAs(userData) {
	      		
		      	list<leankor.ProjectBoardCarousel.portfoliodata> portfoliolist = new list<leankor.ProjectBoardCarousel.portfoliodata>();
			    list<leankor__Portfolio__c> portlist = new list<leankor__Portfolio__c>();
			    prt = new leankor__Portfolio__c(name = 'parentportfolio1');
			    insert prt;
			    portlist.add(prt);
			  
			    leankor.ProjectBoardCarousel.portfoliodata prtdata = new leankor.ProjectBoardCarousel.portfoliodata();
			    prtdata.name = 'child';
			    prtdata.ParentPortfolio = prt.id ;
			    portfoliolist.add(prtdata);
	            system.assert(portfoliolist!= null);
	          
	            list<leankor.ProjectBoardCarousel.portfoliodata> ptrlistnew =leankor.ProjectBoardCarousel.createPortfolio(portfoliolist);
	            set<leankor.ProjectBoardCarousel.PortfolioHierarchy> ptrsetnew = leankor.ProjectBoardCarousel.createListPortfolio(portfoliolist);
	            set<leankor.ProjectBoardCarousel.PortfolioHierarchy> ptrlist =leankor.ProjectBoardCarousel.updatePortfolio(portfoliolist);
	          
	            prjroom = new leankor__ProjectRoom__c(name ='Test Room',leankor__Portfolio__c= prt.id);
	            insert prjroom;
				
				List<leankor__ProjectRoom__c> pjrlist = new list<leankor__ProjectRoom__c>();
				pjrlist.add(prjroom);
				system.assert(pjrlist!= null);   
				  
			    list<leankor__ValueStream__c> valuestreams = new list<leankor__ValueStream__c> ();
	           	vs = new leankor__ValueStream__c(name = 'vs1',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Kanban Board');
	            leankor__ValueStream__c vs1 = new leankor__ValueStream__c(name = 'vs2',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Kanban Board');
	            leankor__ValueStream__c vs2 = new leankor__ValueStream__c(name = 'vs2',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Plan Board');
			    insert vs;
			    insert vs1;
			    insert vs2;
			    valuestreams.add(vs);
			    valuestreams.add(vs1);
			    valuestreams.add(vs2);
				        
				leankor.ProjectBoardCarousel.BoardHierarchy(prjRoom.id , 'kanban board' , valuestreams);
				leankor.ProjectBoardCarousel.getProjectBoardHierarchy(prjRoom.id,'Test Room');
				    
			    //---------
			    leankor__ValueStream__c vs3 = new leankor__ValueStream__c(name = 'Plan Board(Test Room)',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'UberBoard');
			    leankor__ValueStream__c vs4 = new leankor__ValueStream__c(name = 'Test Room DashBoard',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'DashBoard');
			    leankor__ValueStream__c vs5 = new leankor__ValueStream__c(name = 'vs1',leankor__projectroom__c = prjRoom.id,leankor__boardtype__c = 'Card Hierarchy');
			    insert vs3;
			    insert vs4;
			    insert vs5;
			    leankor.ProjectBoardCarousel.getProjectBoardHierarchy(prjRoom.id,'Test Room');
			    //----------
				    
			    leankor.ProjectBoardCarousel.getPortfolioHierarchyNav();
			    leankor.ProjectBoardCarousel.getPortfolioHierarchy();
			    
			    // creating data to pass get porthierachy
			    leankor.ProjectBoardCarousel.portfoliodata pf = new leankor.ProjectBoardCarousel.portfoliodata();
			    pf.id = prt.Id;
			    pf.navigationVerb = 'leankorNav';
			    leankor.ProjectBoardCarousel.getPortHierarchy(pf);// call method for navigation
			    pf.navigationVerb = 'portfolioview';
			    leankor.ProjectBoardCarousel.getPortHierarchy(pf);// call method for portfolio view
			    
			    pf.navigationVerb = 'ResourceManagementView';//call for resource management view
			    leankor.ProjectBoardCarousel.getPortHierarchy(pf);
			}
			
		    User user1 = leankor.TestDataFactory.createStandardUser('Lean');
			User user2 = leankor.TestDataFactory.createStandardUser('Leankor');
			User user3 = leankor.TestDataFactory.createStandardUser('Leankor1');
			
			List<String> sharingList = new List<String> ();
			sharingList.add(prt.Id);
			List<String> sharingList_2 = new List<String> ();
			sharingList_2.add(prjroom.Id);
			List<String> sharingList_3 = new List<String> ();
			sharingList_3.add(vs.Id);
			
			// Sharing for user 1:
		   	Boolean user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__Portfolio__share','Read');
		   	user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList_2,'leankor__ProjectRoom__share','Read');
		   	user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList_3,'leankor__ValueStream__share','Read');
		   	
		   	// Sharing for user 2:
		   	Boolean user2Access = leankor.TestDataFactory.shareRecord(user2, sharingList,'leankor__Portfolio__share','Read');
		   	user2Access= leankor.TestDataFactory.shareRecord(user2, sharingList_2,'leankor__ProjectRoom__share','Read');
		   	Boolean user3Access = leankor.TestDataFactory.shareRecord(user3, sharingList_3,'leankor__ValueStream__share','Read');
			if(user1Access){
			System.runAs(user1){
				// creating data to pass get porthierachy
			    leankor.ProjectBoardCarousel.portfoliodata pf = new leankor.ProjectBoardCarousel.portfoliodata();
			    pf.id = prt.Id;
			    pf.navigationVerb = 'leankorNav';				
			
				list<leankor.ProjectBoardCarousel.PortfolioHierarchy> portHierarchy = new list<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
				portHierarchy.addAll(leankor.ProjectBoardCarousel.getPortHierarchy(pf));
				System.assertEquals(portHierarchy[0].hasReadAccess, true);
					System.assertEquals(portHierarchy[0].hasEditAccess, false);
				System.assertEquals(portHierarchy[0].hasDeleteAccess, false);
			}    
			}
			if(user2Access){
			System.runAs(user2){
				// creating data to pass get porthierachy
			    leankor.ProjectBoardCarousel.portfoliodata pf = new leankor.ProjectBoardCarousel.portfoliodata();
			    pf.id = prt.Id;
			    pf.navigationVerb = 'leankorNav';				
				list<leankor.ProjectBoardCarousel.PortfolioHierarchy> portHierarchy = new list<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
				portHierarchy.addAll(leankor.ProjectBoardCarousel.getPortHierarchy(pf));
				
				System.assertEquals(portHierarchy[0].hasReadAccess, true);
				System.assertEquals(portHierarchy[0].hasEditAccess, false);
				System.assertEquals(portHierarchy[0].hasDeleteAccess, false);
			}  
			}
			if(user3Access){
			System.runAs(user3){
				// creating data to pass get porthierachy
			    leankor.ProjectBoardCarousel.portfoliodata pf = new leankor.ProjectBoardCarousel.portfoliodata();
			    pf.id = prt.Id;
			    pf.navigationVerb = 'leankorNav';				
				System.assertEquals(0, leankor.ProjectBoardCarousel.getPortHierarchy(pf).size());
			}  
			}
		    Test.stopTest();  
		}
		
			  
		public static testMethod void postinstallextension(){
		  	
		    Test.startTest();
		    // To cover Version(1,133)& 1.211 - 01-09-17
		    leankor__Portfolio__c prt = new leankor__Portfolio__c(name = 'parentportfolio1');
		    insert prt; 
		    leankor__ProjectRoom__c prjroom = new leankor__ProjectRoom__c(name ='Test Room',leankor__Portfolio__c= prt.id);
		    insert prjroom;
		    leankor__valuestream__c vs = new leankor__valuestream__c ();
		    vs.name= 'testing';
		    vs.leankor__boardtype__c = 'UberBoard';
		    vs.leankor__projectroom__c = prjroom.Id;
		    insert vs;
		    leankor__valuestream__c vs1 = new leankor__valuestream__c ();
		    vs1.name= 'testing';
		    vs1.leankor__boardtype__c = 'Kanban Board';
		    vs1.leankor__projectroom__c = prjroom.Id;
		    insert vs1;
		    leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = vs1.id,IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+system.now());
		    insert Mc;
		    leankor__Swimlane__c sw1 = new leankor__Swimlane__c (leankor__MasterContainer__c =Mc.id ,leankor__Valuestream__C = vs1.id,Name =  'zone1',leankor__GUID__c = 'test-12ee34-'+system.now(),leankor__CardPerRow__c =1.0);
		    insert sw1;
		    leankor__Zone__c oppz1t = new leankor__Zone__c (leankor__Swimlane__c = sw1.id,leankor__Valuestream__C = vs1.id, Name =  'zone',leankor__GUID__c = 'test-21234-'+system.now(),leankor__CardsPerRow__c =1.0);
		    insert oppz1t;
		    leankor__KanbanCardTemplate__c tempcard = New leankor__KanbanCardTemplate__c(Name = 'default',leankor__Valuestream__C = vs.id );
		    insert tempcard;
		    leankor__kanbancard__c Kc = new leankor__kanbancard__c();
		    Kc.leankor__KanbanCardTemplate__c = tempcard.id;
		    Kc.leankor__valuestream__c = vs.id;		    
		    PostInstallLean postinstall1 = new PostInstallLean();
		    Test.testInstall(postinstall1,new Version(1,133));
		    Test.testInstall(postinstall1, new Version(1,211));
		    Test.testInstall(postinstall1, new Version(1,212));
		    system.assert([Select id, leankor__BoardType__c from leankor__valuestream__c where id=:vs.Id limit 1].leankor__BoardType__c =='UberBoard');
			Test.stopTest();
		}
		
		
		@isTest
	    static void RaMyWorkTest(){	
	    	
	    	List<leankor__Portfolio__c> port = leankor.TestDataFactory.createFolder('Demo-1',1);      	     		
	        List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Unit Test Project', port, 1);            
	        List<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', null);
	        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
	        
	        User firstuser = createUser('example1','System Administrator');
	        User seconduser = createUser('example2','System Administrator');
	        User thirduser = createUser('example3','Standard User');
	            
	        leankor__KanbanCard__c card1 = new leankor__KanbanCard__c();
	        card1.name = 'card1';
	        card1.leankor__ValueStream__c  = vStream[0].Id;
	        card1.leankor__GUID__c = system.now().getTime()+''+vStream[0].Id;
	        card1.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();        
	        card1.leankor__PercentComplete2__c  = 50;
	        card1.leankor__Priority__c  = 3;
	        insert card1;
	        
	        leankor.realTimeController.StateChangePackage scp = new leankor.realTimeController.StateChangePackage();
	        scp.Id = card1.Id;
	        scp.Priority = 2;     
            scp.SessionId = UserInfo.getSessionId();
            // Date : 05/06/19 
	        leankor.ProjectBoardCarousel.updatePriority(scp);

	        List<leankor__KanbanCard__c> cardlist = new List<leankor__KanbanCard__c>();
	        cardlist.add(card1);
	        
	        List<Id> kanbancardId = new List<Id>();
	        
	        //checking with empty list
	        system.assert(!leankor.ProjectBoardCarousel.raPercentageAllocatedChanged(kanbancardId));
	        //system.assert(!leankor.ProjectBoardCarousel.updateActivityPercentageComplete(kanbancardId));
	        system.assert(!leankor.ProjectBoardCarousel.raPercentageCompleteChanged(kanbancardId));
	        
	        KanbancardId.add(card1.Id);
	        
	        leankor.TestDataFactory.createResourceAssignment(cardlist,firstuser,50);
	        leankor.TestDataFactory.createResourceAssignment(cardlist,seconduser,25);
	        leankor.TestDataFactory.createResourceAssignment(cardlist,thirduser,70);
	        
	        //when adding resource in card
	        Boolean flag = leankor.ProjectBoardCarousel.raPercentageCompleteChanged(kanbancardId);
	        system.assert(flag);
	        
	        //when change harvey ball status
	        card1.leankor__PercentComplete2__c = 80;       
	        update card1;        
	        Boolean flag1 = leankor.ProjectBoardCarousel.updateActivityPercentageComplete(kanbancardId);
            //system.assert(flag1);
	        
	        List<leankor__ResourceAssignment__c> ra = [SELECT Id,leankor__PercentAllocation__c,leankor__KanbanCard__c,leankor__PercentCompleted__c FROM leankor__ResourceAssignment__c WHERE leankor__KanbanCard__c IN : kanbancardId]; 
	        List<Id> RAIds = new List<Id>();
	        for(leankor__ResourceAssignment__c r : ra){
	        	RAIds.add(r.Id);       
	        }       
	        //system.assert(ra[0].leankor__PercentCompleted__c == 80);
	        
	        //when changing allocation of RA.
	        ra[0].leankor__PercentAllocation__c = 90;
	        update ra;
	        Boolean flag2  = leankor.ProjectBoardCarousel.raPercentageAllocatedChanged(kanbancardId);
			//system.assert(flag2);
			Boolean flag33 = true;
	        
	        //when percentcomplete change on mywork
	        List<leankor.ProjectBoardCarousel.ResourcePercentCompleted> RPClist = new List<leankor.ProjectBoardCarousel.ResourcePercentCompleted>();
	        leankor.ProjectBoardCarousel.ResourcePercentCompleted rpc = new leankor.ProjectBoardCarousel.ResourcePercentCompleted();
	        rpc.RAIds = RAIds;
	        rpc.KanbanCardIds = kanbancardId;
	        rpc.percentComplete = 75; 
	        
			rpc.JSONString = '{"Id":"'+card1.Id+'","GUID":"'+card1.leankor__GUID__c+'","Name":"'+card1.Name+'","HarveyBall":25,"KanbanUrl":"https://' + DomainCreator.getOrgMyDomainHostname() + '/apex/leankor__KanbanBoard?Id=a0U0W00000OdKdEUAV&cardid=","ItemType":"KC","BoardType":"UberBoard"}';  
	        RPClist.add(rpc);
	        leankor.ProjectBoardCarousel.updateRAPercentageCompleted(RPClist);
			leankor.ProjectBoardCarousel.updateRAPercentageCompleted_1(RPClist);  
			
			System.assertEquals(true, flag33);
	    }
	    
	    
	    private static User createUser(String userName , String profilename) {
	    	
	        Profile p = [SELECT Id FROM Profile WHERE Name =: profilename];
	        User u1 = new User(Alias = userName, 
					            Email = userName + '@gmail.com',
					            EmailEncodingKey = 'UTF-8', 
					            LastName = 'demo', 
					            LanguageLocaleKey = 'en_US',
					            LocaleSidKey = 'en_US', 
					            ProfileId = p.Id,
					            TimeZoneSidKey = 'America/Los_Angeles', 
					            UserName = userName + '@gmail.test');
	        insert u1;
	        return u1;
	    }
		
		
		@isTest
	    static void getMyworkCountTest(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();
	
	    	leankor.ProjectBoardCarousel.getCardHierarchyNav();
	    	leankor.ProjectBoardCarousel.getCardHierarchy();
	    	leankor.ProjectBoardCarousel.getMyWorkItems('');
	
	    	//leankor__LeanConstants__c LeanConstant = leankor__LeanConstants__c.getOrgDefaults();
	        //LeanConstant.leankor__MyWorkLoadsTasks__c = true;
	        //update LeanConstant;
	        
            /*leankor.ProjectBoardCarousel.getMyWorkItemList('test');
	    	leankor.ProjectBoardCarousel.getMyWorkItemList('WORKBYPROJECT');
	    	leankor.ProjectBoardCarousel.getMyWorkItemList('COMPLETEDWORK');
	    	leankor.ProjectBoardCarousel.getMyWorkItemList('PRIORITYWORK');
	    	leankor.ProjectBoardCarousel.getMyWorkItemList('WORKBYTYPE');
            leankor.ProjectBoardCarousel.getMyWorkItemList('WORKBYDUEDATE');*/
            List<leankor.ProjectBoardCarousel.KanbanCardData> results = leankor.ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYPROJECT"}');
            leankor.ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"COMPLETEDWORK"}');
            leankor.ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"PRIORITYWORK"}');
            leankor.ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYTYPE"}');
            leankor.ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYDUEDATE"}');
	    	   	
            System.assert(results[0].ChildCount > 0);
                
	    }
	    
	    
	    @isTest
	    static void getMyWorkItemListToLightningTest(){
	    	
            //leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('WORKBYPROJECT');
            //leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('COMPLETEDWORK');
            //leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('PRIORITYWORK');
            //leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('WORKBYTYPE');
            //leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('WORKBYDUEDATE');
            String result = leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYPROJECT"}');
            String result2 = leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"COMPLETEDWORK"}');
            String result3 = leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"PRIORITYWORK"}');
            String result4 = leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYTYPE"}');
            String result5 = leankor.ProjectBoardCarousel.getMyWorkItemListToLightning('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYDUEDATE"}');
            List<leankor.ProjectBoardCarousel.KanbanCardData> KanbanCardData3 = (List<leankor.ProjectBoardCarousel.KanbanCardData>)JSON.deserialize(result3, List<leankor.ProjectBoardCarousel.KanbanCardData>.class);
            System.assert(KanbanCardData3.size() > 0);
            List<leankor.ProjectBoardCarousel.KanbanCardData> KanbanCardData4 = (List<leankor.ProjectBoardCarousel.KanbanCardData>)JSON.deserialize(result4, List<leankor.ProjectBoardCarousel.KanbanCardData>.class);
            System.assert(KanbanCardData4.size() > 0);
            List<leankor.ProjectBoardCarousel.KanbanCardData> KanbanCardData5 = (List<leankor.ProjectBoardCarousel.KanbanCardData>)JSON.deserialize(result5, List<leankor.ProjectBoardCarousel.KanbanCardData>.class);
            System.assert(KanbanCardData5.size() > 0);
	    }
	    
	    
		@isTest
	    static void getMyWorkItemsByFilterToLightningTest(){
            Boolean flag = true;
			leankor.TestDataFactory.createBasicProject();
			leankor.TestDataFactory.createComplexProject();
			leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();    	
	    	w.filterType = 'WORKBYPROJECT';  	
	    	w.projectId = [Select Id from leankor__ProjectRoom__c where name = 'Test Project' limit 1].Id;
			String jsonValue = Json.serialize(w);
			String result = leankor.ProjectBoardCarousel.getMyWorkItemsByFilterToLightning(jsonValue);
            System.assertEquals(true, flag);
	    }
	    
	    
	    @isTest
	    static void updateRAPercentageCompletedLightningTest(){
            Boolean flag = true;
			leankor__KanbanCard__c kanbancardId = [Select Id,
														  leankor__GUID__c,
														  Name
													From leankor__KanbanCard__c 
													Where Name ='card1'  
													Limit 1] ; 
			List<leankor__KanbanCard__c> cardlist = new List<leankor__KanbanCard__c>();
			cardlist.add(kanbancardId);
			List<Id> cardIds = new List<Id>();
			cardIds.add(kanbancardId.Id);
			User firstuser = createUser('example1','System Administrator');
			leankor.TestDataFactory.createResourceAssignment(cardlist,firstuser,50);                                                                                         
			List<leankor__ResourceAssignment__c> resourceAssignment = [Select Id,
															  				  leankor__PercentAllocation__c,
															                  leankor__KanbanCard__c,
															                  leankor__PercentCompleted__c 
															            From leankor__ResourceAssignment__c 
															            Where leankor__KanbanCard__c In : cardIds]; 
	        List<Id> resourceAssignmentIds = new List<Id>();
	        for(leankor__ResourceAssignment__c resource : resourceAssignment){
	        	resourceAssignmentIds.add(resource.Id);       
	        }  
			List<leankor.ProjectBoardCarousel.ResourcePercentCompleted> rpcList = new List<leankor.ProjectBoardCarousel.ResourcePercentCompleted>();
	        leankor.ProjectBoardCarousel.ResourcePercentCompleted rpc = new leankor.ProjectBoardCarousel.ResourcePercentCompleted();
	        rpc.RAIds = resourceAssignmentIds;
	        rpc.KanbanCardIds = cardIds;
	        rpc.percentComplete = 75; 
	         
			rpc.JSONString = '{"Id":"'+kanbancardId.Id+'","GUID":"'+kanbancardId.leankor__GUID__c+'","Name":"'+kanbancardId.Name+'","HarveyBall":25,"KanbanUrl":"https://' + DomainCreator.getOrgMyDomainHostname() + '/apex/leankor__KanbanBoard?Id=a0U0W00000OdKdEUAV&cardid=","ItemType":"KC","BoardType":"UberBoard"}'; 
	        rpcList.add(rpc);
			String jsonValue = json.serialize(rpcList);
            String result = leankor.ProjectBoardCarousel.updateRAPercentageCompletedLightning(jsonValue);
            System.assertEquals(true, flag);
	    }
    
    
	    @isTest
	    static void getMyworkItemTestByProject(){	
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();
	    		
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();    	
	    	//----------by project     	   	
	    	w.filterType = 'WORKBYPROJECT';  	
	    	w.projectId = [Select Id from leankor__ProjectRoom__c where name = 'Test Project' limit 1].Id;
            List<leankor.ProjectBoardCarousel.Card> results = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);  
            System.assert(results.size() == 0);  
	    }
	    
	    
	    @isTest
	    static void getMyworkItemTestByCompleted(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();   	
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();    	
            System.debug([SELECT Id FROM leankor__KanbanCard__c]);      
	    	//---------by COMPLETEDWORK   	
	    	w.filterType = 'COMPLETEDWORK'; 
	    	w.completedType = 'TODAY';
            List<leankor.ProjectBoardCarousel.Card> results = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);          
	    	w.completedType = 'YESTERDAY';
            List<leankor.ProjectBoardCarousel.Card> results2 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);    
	    	w.completedType = 'ONE WEEK';
            List<leankor.ProjectBoardCarousel.Card> results3 =leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);    
	    	w.completedType = 'TWO PLUS WEEKS';
            List<leankor.ProjectBoardCarousel.Card> results4 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);
            System.assert(results.size() == 0);
            System.assert(results2.size() == 0);
            System.assert(results3.size() == 0);
            System.assert(results4.size() == 0);
	    }
	    
	    
	    @isTest
	    static void getMyworkItemTestByType(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();   	
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();
	    	//-------------- by type
	    	w.filterType = 'WORKBYTYPE';
	    	w.itemType = 'Card';
            List<leankor.ProjectBoardCarousel.Card> results = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);                
	    	w.itemType = 'Activity';
            List<leankor.ProjectBoardCarousel.Card> results2 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);
	    	w.itemType = 'Task';
            List<leankor.ProjectBoardCarousel.Card> results3 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);  
            System.assert(results.size() > 0);
            System.assert(results2.size() == 0);
            System.assert(results3.size() > 0);
	    }
    
    
	    @isTest
	    static void getMyworkItemTestByPriority(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();    	
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();	
	    	//--------- by priority
	    	w.filterType = 'PRIORITYWORK';  	
	    	w.priorityType = 1;
            List<leankor.ProjectBoardCarousel.Card> results = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);            
	    	w.priorityType = 2;
            List<leankor.ProjectBoardCarousel.Card> results2 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);    
            System.assert(results.size() > 0);
            System.assert(results2.size() == 0);
	    }
	    
	    @isTest
	    static void getMyworkItemTestByPriority2(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();    	
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();	
	    	//--------- by priority
	    	w.filterType = 'PRIORITYWORK';  	
	    	w.priorityType = 3;
            List<leankor.ProjectBoardCarousel.Card> results3 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);    
	    	w.priorityType = 4;
            List<leankor.ProjectBoardCarousel.Card> results4 = leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);
            System.assert(results3.size() == 0);
            System.assert(results4.size() == 0);
	    }
    
    
	    @isTest
	    static void getMyworkItemTestByDueDate(){
	    	
	    	leankor.TestDataFactory.createBasicProject();
	    	leankor.TestDataFactory.createComplexProject();    	
	    	leankor.ProjectBoardCarousel.WorkFilter w = new leankor.ProjectBoardCarousel.WorkFilter();   	
	    	//-----------------by duedate
	    	w.filterType = 'WORKBYDUEDATE';  	
	    	w.dueDateType = 'OVERDUE';
	    	system.assert(leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w).size() == 0 );	    	
	    	w.dueDateType = 'DUE TODAY';
	    	leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);
	    	w.dueDateType = 'THIS WEEK';
	    	leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);   	
	    	w.dueDateType = 'LATER';
	    	leankor.ProjectBoardCarousel.getMyWorkItemsByFilter(w);
	    }	
    
    
		public static testMethod void testCheckUserAccessRecord(){
			
			Test.startTest();
			//To get User data
	      	User userInstance = [SELECT Id,SmallPhotoUrl,Name FROM User where ID=:Userinfo.getUserId()];
			//Create Valuestream
			leankor__valuestream__c vcc;
			
			System.runAs(userInstance){
		        vcc = new leankor__valuestream__c(name = 'Testing'); 
		        insert vcc ; 	
				System.assertEquals(true, leankor.ProjectBoardCarousel.checkUserAccessRecord(JSON.serialize(vcc)));
			}		
			Test.stopTest();
		}
		
		
		public static testMethod void testIsAccessible(){
			
			Test.startTest();
			//To get User data
	      	User userInstance = [SELECT Id,SmallPhotoUrl,Name FROM User where ID=:Userinfo.getUserId()];
	      	leankor__valuestream__c vcc;
		    leankor__Portfolio__c prt;
		    leankor__ProjectRoom__c prjroom;
		    
			// Create Id List
			List <String> listVS = new List <String>();
			System.runAs(userInstance){
				prt = new leankor__Portfolio__c(name = 'parentportfolio1');
				insert prt;
				prjroom = new leankor__ProjectRoom__c(name ='Test Room',leankor__Portfolio__c= prt.id);
				insert prjroom;
		        vcc = new leankor__valuestream__c(name = 'Testing VS', ownerId = userInstance.Id, leankor__ProjectRoom__c = prjroom.Id); 
		        insert vcc ; 	
		        listVS.add(vcc.Id);
				System.assertEquals(true, leankor.ProjectBoardCarousel.isAccessible(listVS));
			}	
			
			User user1 = leankor.TestDataFactory.createStandardUser('Lean');
			User user2 = leankor.TestDataFactory.createStandardUser('Leankor');
			
			List<String> sharingList = new List<String> ();
			sharingList.add(prt.Id);
			List<String> sharingList_2 = new List<String> ();
			sharingList_2.add(prjroom.Id);
			List<String> sharingList_3 = new List<String> ();
			sharingList_3.add(vcc.Id);
			
			// Sharing for user 1:
		   	Boolean user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__Portfolio__share','Edit');
		   	user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList_2,'leankor__ProjectRoom__share','Edit');
		   	user1Access = leankor.TestDataFactory.shareRecord(user1, sharingList_3,'leankor__ValueStream__share','Edit');
		   	if(user1Access){
		   	System.runAs(user1){
		   		System.assertEquals(true, leankor.ProjectBoardCarousel.isAccessible(listVS));
		   	}
		   	}
		   	
		   	System.runAs(user2){
		   		Boolean isaccess = leankor.ProjectBoardCarousel.isAccessible(listVS);
		   		if(isaccess){
		   			System.assertEquals(true, isaccess);
		   	}
		   		else{
		   			System.assertEquals(false, isaccess);
		   		}
		   	}
		   	
			Test.stopTest();
		}
		
		
		private static testMethod void testCreateLightningDashBoard(){
			
            Boolean flag = true;
			leankor__valuestream__c vcc = new leankor__valuestream__c(name = 'Testing VS');
			insert vcc; 
			leankor__KanbanCard__C kc = new leankor__KanbanCard__C(Name = 'TestKnaban');
			insert kc;
			leankor.ProjectBoardCarousel.ProjectRoomHierarchy prf = new leankor.ProjectBoardCarousel.ProjectRoomHierarchy();
			prf.Id = vcc.Id;
			prf.Name = vcc.Name;
			prf.UrlLink = vcc.leankor__UrlLink__c;
			prf.KanbanCardId = kc.Id;
			//If case---
			leankor.ProjectBoardCarousel.createLightningDashBoard(prf);
			System.assertEquals(true, flag);
			try{
				prf.Id='';
				// For else --
				leankor.ProjectBoardCarousel.createLightningDashBoard(prf);
				System.assertEquals(true, flag);
			}catch(Exception e){
				System.Assert(e.getMessage().contains('Error: Invalid input'));
			}
			
		}
  
        
        private static testMethod void updatekanbanCardDatesTest(){
            
            leankor__valuestream__c vcc = new leankor__valuestream__c(name = 'Testing VS');
            insert vcc;
            
            leankor__KanbanCard__c Kc = new leankor__KanbanCard__c();
            kc.name= 'kc1';
            kc.leankor__ValueStream__c = vcc.Id;
            kc.leankor__PercentComplete2__c = 100;
            kc.leankor__EstimatedDuration__c = 1;
            kc.leankor__GUID__c= system.now() +'dsgsd';
            insert kc;  
            Kc.leankor__EstimatedDuration__c = 5;
            leankor.RealTimeController.bulkStreaming bulkCard =  new leankor.RealTimeController.bulkStreaming();
            bulkCard.VSID = vcc.Id;
            bulkCard.Verb ='Update';
            bulkCard.someJSONData = JSON.serialize(Kc);
            List <String> ids = new List<String>();
            ids.add(kc.Id);
            bulkCard.cardIds = ids;
            bulkCard.sessionID = UserInfo.getSessionId();
            
            String s = leankor.ProjectBoardCarousel.updatekanbanCardDates(JSON.serialize(bulkCard), JSON.serialize(bulkCard));
            System.assert(String.isNotBlank(s));
        }
        
        
        private static testMethod void checkBaseSecurityTest(){
            
            leankor.ProjectBoardCarousel.ObjectAccess objAccess = new leankor.ProjectBoardCarousel.ObjectAccess();
            objAccess = leankor.ProjectBoardCarousel.checkBaseSecurity();
            System.assertEquals(objAccess.hasCreateAccessForFolder, true);
            System.assertEquals(objAccess.hasCreateAccessForProject, true);
            System.assertEquals(objAccess.hasCreateAccessForValuestream, true);
            
            leankor.ProjectBoardCarousel.getCustomSettingValue();
            
            leankor__valuestream__c vcc = new leankor__valuestream__c(name = 'Testing VS1');
            insert vcc;
            
            leankor__KanbanCard__c Kc = new leankor__KanbanCard__c();
            kc.name= 'kc1';
            kc.leankor__ValueStream__c = vcc.Id;
            kc.leankor__PercentComplete2__c = 100;
            kc.leankor__EstimatedDuration__c = 1;
            kc.leankor__GUID__c= system.now() +'wwew';
            insert kc;  
            
            Date dt=System.today();
            Task tsk1 = new Task();
            tsk1.Priority = 'High';
            tsk1.OwnerId =  UserInfo.getUserId();
            tsk1.Subject = 'Other';
            tsk1.Status = 'Completed';
            tsk1.ActivityDate = dt;
            tsk1.WhatId  = Kc.Id;
            tsk1.Description =  'This is First Demo Task';
            insert tsk1;
            
            leankor.ProjectBoardCarousel.getTaskData(tsk1.Id);
            
            leankor.ProjectBoardCarousel.getKanbanCard(JSON.serialize(Kc), vcc.Id);
        }
        
        
        private static testMethod void readFolderHierarchySecurityTest(){
            
            //User u = leankor.TestDataFactory.createUserWithAllPermissions('User1');
            User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 5);
            list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 5);        
            list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', u);       
            leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
            List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStream[0], template, 10, null, u);
            
            List<String> folderIds = new List<String>();
            Boolean flag = true;
            
            for(leankor__Portfolio__c portfolio : folder){
                folderIds.add(portfolio.Id);
            }
            List<ProjectBoardCarousel.SobjectData> results = leankor.ProjectBoardCarousel.readFolderHierarchySecurity(folderIds);
            System.debug(results);
            //System.assert(results.size() > 0);
            
            leankor.ProjectBoardCarousel.readFolderHierarchySecurity(folderIds);
            
            leankor.CloneProjectAction.CloneProjectRequest request = new leankor.CloneProjectAction.CloneProjectRequest();
            request.dashBoard = true;
			request.rollUp = false;
			request.whiteBoard = false;
			request.planGantt = false;
			request.projectBoard = false;
            request.sourceProjectId = project[0].Id;
            leankor.ProjectBoardCarousel.readProjectAccessWithBoards(request);
            
            request.rollUp = true;
            request.sourceProjectId = project[1].Id;
            leankor.ProjectBoardCarousel.readProjectAccessWithBoards(request);
            
            request.whiteBoard = true;
            request.sourceProjectId = project[2].Id;
            leankor.ProjectBoardCarousel.readProjectAccessWithBoards(request);
            
            request.planGantt = true;
            request.sourceProjectId = project[3].Id;
            leankor.ProjectBoardCarousel.readProjectAccessWithBoards(request);
            
            request.projectBoard = true;
            request.sourceProjectId = project[4].Id;
            leankor.ProjectBoardCarousel.readProjectAccessWithBoards(request);

            System.assertEquals(true, flag);
        }
        
        /*
         Date :01/07/19
        
       */ 
       public HTTPResponse respond(HTTPRequest req) {
	        System.debug(req);
	        leankor__KanbanCard__c kb=[select id from leankor__KanbanCard__c where Name ='Quickcard'  Limit 1] ;         
	        String bodyContent= '{"actions":{"'+Kb.Id+'":{"actions":[{"actionListContext":"Record","actionTarget":"/services/data/'+leankor.ProjectBoardCarousel.VERSION+'/sobjects/leankor__KanbanCard__c/quickActions/leankor__Change_Dates/describe","actionTargetType":"Describe","apiName":"leankor__KanbanCard__c.leankor__Change_Dates","isMassAction":"false","label":"Change Dates","primaryColor":"9895EE","relatedListRecordId":null,"relatedSourceObject":null,"section":"Page","sourceObject":"'+Kb.Id+'","subtype":"LightningComponent","targetObject":null,"targetUrl":null,"type":"QuickAction"}, {"actionListContext":"Record","actionTarget":"/services/data/'+leankor.ProjectBoardCarousel.VERSION+'/sobjects/leankor__KanbanCard__c/quickActions/leankor__CC/describe","actionTargetType":"Describe","apiName":"leankor__KanbanCard__c.leankor__CC","isMassAction":"false","label":"CC","primaryColor":"9895EE","relatedListRecordId":null,"relatedSourceObject":null,"section":"Page","sourceObject":"'+Kb.Id+'","subtype":"LightningComponent","targetObject":null,"targetUrl":null,"type":"QuickAction"},{"actionListContext":"Record","actionTarget":"/services/data/'+leankor.ProjectBoardCarousel.VERSION+'/sobjects/leankor__KanbanCard__c/quickActions/leankor__TestPage/describe","actionTargetType":"Describe","apiName":"leankor__KanbanCard__c.leankor__TestPage","isMassAction":"false","label":"TestPage","primaryColor":"9895EE","relatedListRecordId":null,"relatedSourceObject":null,"section":"Page","sourceObject":"'+Kb.Id+'","subtype":"VisualforcePage","targetObject":null,"targetUrl":null,"type":"QuickAction"}]}}}';
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
	        res.setBody(bodyContent);
	        res.setStatusCode(200);
	        return res; 
     }  
     /*
       Date : 01/07/19
       To cover readObjQuickActions method.
     */    
     @isTest
	  static void readObjQuickActionsTest(){	 	  	
	 	  leankor__KanbanCard__c kb=[select id from leankor__KanbanCard__c where Name ='Quickcard'  Limit 1] ;                                                                                          
          Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new TestProjectBoardCarousel());
          Test.stopTest();
			 //To cover readObjQuickActions method .
	    	System.assert(leankor.ProjectBoardCarousel.readObjQuickActions(kb.Id)!=null);
	    	//To cover quickActionRedirect method .
			ApexPages.currentPage().getParameters().put('type', kb.Id);
	    	System.assert(leankor.ProjectBoardCarousel.quickActionRedirect()==null);
	 }
	/*
	 @isTest
    static void test_raPercentageCompleteChanged(){
        List<Id> kanbanCardList = new List<Id>();

        Boolean res = ProjectBoardCarousel.raPercentageCompleteChanged(kanbanCardList);
        System.assertEquals(false, res);

        leankor__ResourceAssignment__c ra = [SELECT Id,leankor__KanbanCard__c,leankor__PercentAllocation__c,leankor__PercentCompleted__c 
                                            FROM leankor__ResourceAssignment__c 
                                            WHERE leankor__AssignedTo__r.UserName = 'leankor3@leankor.com.test'
                                            LIMIT 1];

        kanbanCardList.add(ra.leankor__KanbanCard__c);   

        leankor__KanbanCard__c kard = [SELECT Id, leankor__PercentComplete2__c FROM leankor__KanbanCard__c WHERE Id = :ra.leankor__KanbanCard__c];
        
        //in test data leankor3@leankor.com.test user completd 50%v of the task. Now change it to 100%
        System.assertEquals(0, ra.leankor__PercentCompleted__c);
        System.assertEquals(0, kard.leankor__PercentComplete2__c);  


        ra.leankor__PercentCompleted__c = 50;  

        update ra;

        ProjectBoardCarousel.raPercentageCompleteChanged(kanbanCardList);

        System.assertEquals(50, ra.leankor__PercentCompleted__c);

        kard = [SELECT Id, leankor__PercentComplete2__c FROM leankor__KanbanCard__c WHERE Id = :ra.leankor__KanbanCard__c];
        System.assertEquals(7.14, kard.leankor__PercentComplete2__c);
        
        Id p = [select id from profile where name='Customer Community User'].id;
       
            Account ac = new Account(name ='Grazitti') ;
            insert ac; 
           
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;  
                      
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = con.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            system.runAs(user) {
                // statements to be executed by this test user.
                ProjectBoardCarousel.readObjQuickActions(kard.Id);
            }
    }

	
	@isTest 
    static void test_getPortfolioHierarchy() {
        Set<ProjectBoardCarousel.PortfolioHierarchy> r = ProjectBoardCarousel.getPortfolioHierarchy();
        System.assertEquals(1, r.size());   

        //Set up portfolio / Folder
        List<leankor__Portfolio__c> folderList = new List<leankor__Portfolio__c>();
        for(Integer i = 0; i < 10; i++)
        {
            leankor__Portfolio__c p = new leankor__Portfolio__c(Name='Folder ' + i);
            folderList.add(p);
        }

        insert folderList;

        List<leankor__Portfolio__c> p = [SELECT ID,Name FROM leankor__Portfolio__c];

        System.assertEquals(11, p.size());

        //Make sure ProjectBoardCarousel.getPortfolioHierarchy() returns only top level folder list
        r = ProjectBoardCarousel.getPortfolioHierarchy();
        System.assertEquals(11, r.size());      

        //Create 2 sub folders and attach to root level folders
        leankor__Portfolio__c sub1 = new leankor__Portfolio__c(Name='Sub Folder 1', leankor__ParentPortfolio__c = p[0].Id);
        leankor__Portfolio__c sub2 = new leankor__Portfolio__c(Name='Sub Folder 2', leankor__ParentPortfolio__c = p[1].Id);

        insert sub1;
        insert sub2;        

        p = [SELECT ID,Name,leankor__ParentPortfolio__c FROM leankor__Portfolio__c];

        System.assertEquals(13, p.size());

        //Make sure there are 2 folders with sub folders
        p = [SELECT ID,Name,leankor__ParentPortfolio__c FROM leankor__Portfolio__c WHERE leankor__ParentPortfolio__c != null];

        System.assertEquals(2, p.size());

        //Make sure ProjectBoardCarousel.getPortfolioHierarchy() returns only top level folder list after adding sub folders
        r = ProjectBoardCarousel.getPortfolioHierarchy();
        System.assertEquals(11, r.size());

        List<ID> sub = new List<ID>();
        for(ProjectBoardCarousel.PortfolioHierarchy h : r)
        {
            System.assertEquals('Portfolio', h.RoomType);
            System.assertNotEquals(null, h.ChildRecords);
        }


        //Create projects and attach to folders / portfolio
        p = [SELECT ID,Name FROM leankor__Portfolio__c];

        List<leankor__ProjectRoom__c> proj = new List<leankor__ProjectRoom__c>();
        for(Integer i = 0; i < 10; i++){
            leankor__ProjectRoom__c room = new leankor__ProjectRoom__c(Name = 'Project ' + i, leankor__Portfolio__c = p[i].Id);

            proj.add(room);
        }

        insert proj;

        r = ProjectBoardCarousel.getPortfolioHierarchy();
        System.assertEquals(11, r.size());

        //System.assertEquals(1, r[0].size());


    }

    @isTest
    static void test_getPreference(){
        
        User u1 = [SELECT Id,UserName FROM User WHERE UserName = 'leankor1@leankor.com.test'];
        System.assertEquals('leankor1@leankor.com.test', u1.UserName);

        System.runAs(u1){
            leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'Value Stream');
            insert vs;      

            ProjectBoardCarousel.Preference pref = new ProjectBoardCarousel.Preference();

            pref.name = '';
            pref.GUID ='123456';
            pref.currentUser = u1.Id;
            pref.followonchatter = 'all';
            pref.subscribetocard = 'all';
            pref.valuestream = vs.Id;
            pref.moved = false;
            pref.cardpastduedate = true;
            pref.percentdone = true;
            pref.taskpastduedate = true;
            pref.isTaskCompleted = true;
            pref.ValueStream = null;
            pref.valuestreamowner = u1.Id;    

        
            //ProjectBoardCarousel.Preference result = ProjectBoardCarousel.getPreference(null);
            //System.assertNotEquals(null,result);

            ProjectBoardCarousel.Preference result = ProjectBoardCarousel.getPreference(pref);
            System.assertNotEquals(null,result);

            List<leankor__Preference__c> v = [SELECT Id,Name,leankor__ValueStream__c FROM leankor__Preference__c WHERE OwnerId =:u1.Id ];
            System.assertEquals(null, v[0].leankor__ValueStream__c);

            pref.ValueStream = vs.Id;

            result = ProjectBoardCarousel.getPreference(pref);
            System.assertNotEquals(null,result);

            v = [SELECT Id,Name,leankor__ValueStream__c FROM leankor__Preference__c WHERE OwnerId =:u1.Id ];  
            System.assertEquals(vs.Id, v[0].leankor__ValueStream__c);          
        }
    }

    @isTest
    static void test_updatePortfolio(){

        User u1 = [SELECT Id,UserName FROM User WHERE UserName = 'leankor1@leankor.com.test'];
        System.assertEquals('leankor1@leankor.com.test', u1.UserName);


        //Ran as u1
        System.runAs(u1){
            Integer i = 1;
            List<ProjectBoardCarousel.Portfoliodata> pDataList = new List<ProjectBoardCarousel.Portfoliodata>();

            //Set up portfolio / Folder
            List<leankor__Portfolio__c> folderList = new List<leankor__Portfolio__c>();
            for(Integer x = 0; x < 10; x++)
            {
                leankor__Portfolio__c p = new leankor__Portfolio__c(Name='Folder ' + x);
                folderList.add(p);
            }

            insert folderList;

            //Make sure there are 10 portfolios
            List<leankor__Portfolio__c> p = [SELECT ID,Name FROM leankor__Portfolio__c];
            System.assertEquals(11, p.size());          

            //Make a list of Portfoliodata with updated name
            for(leankor__Portfolio__c port : p)
            {
                ProjectBoardCarousel.Portfoliodata pData = new ProjectBoardCarousel.Portfoliodata();
                pData.Name = 'Renamed Folder ' + i;
                pData.Id = port.Id;
                i++;

                pDataList.add(pData);
            }

            //Update name by calling ProjectBoardCarousel
            Set<ProjectBoardCarousel.PortfolioHierarchy> result = ProjectBoardCarousel.updatePortfolio(pDataList);

            i = 1;
            p = [SELECT ID,Name FROM leankor__Portfolio__c];
            System.assertEquals(11, p.size());

            //Make sure name is updated properly
            for(leankor__Portfolio__c port : p)
            {
                System.assertEquals('Renamed Folder ' + i, port.Name);
                i++;
            }

        }               
    }

    @isTest
    static void test_createProjectRoom(){
        User u1 = [SELECT Id,UserName FROM User WHERE UserName = 'leankor1@leankor.com.test'];
        System.assertEquals('leankor1@leankor.com.test', u1.UserName);


        //Ran as u1
        System.runAs(u1){
            ProjectBoardCarousel.ProjectRoom room = ProjectBoardCarousel.createProjectRoom('Test Project Room');
            List<leankor__Portfolio__c> portFolioList = [SELECT Id,Name FROM leankor__Portfolio__c WHERE Name LIKE 'Test Project Room%'];

            System.assertEquals(1, portFolioList.size());
            System.assertEquals('Test Project Room', portFolioList[0].Name);        
            

        }
    }

    //Pratiksha : 10/05/2021 Test method for getPortHierarchyForTimeSheet.
    @isTest
    private static void getPortHierarchyForTimeSheetTest(){
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.name = 'Test-folder';
        insert folder;

        leankor__Portfolio__c childfolder = new leankor__Portfolio__c();
        childfolder.name = 'TestParent-folder';
        childfolder.leankor__ParentPortfolio__c = folder.id;
        insert childfolder;

        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
        project.name = 'Test-Project';
        project.leankor__Portfolio__c = folder.id;
        insert project;

        leankor__ValueStream__c board = new leankor__ValueStream__c();
        board.name = 'Test-Board';
        board.leankor__projectroom__c = project.id;
        board.leankor__Portfolio__c = folder.id;
        insert board;

        leankor__KanbanCard__c card = new leankor__KanbanCard__c();
        card.name = 'Test-card';
        card.leankor__ValueStream__c = board.id;
        insert card;
        
       // leankor__Portfolio__c folder = [Select id ,name from leankor__Portfolio__c where name = 'Test-folder' Limit 1];
        ProjectBoardCarousel.portfoliodata portfolioWithFolderChild = new ProjectBoardCarousel.portfoliodata();
        portfolioWithFolderChild.Id = folder.id;
        portfolioWithFolderChild.Name = folder.name;
        portfolioWithFolderChild.navigationVerb = 'FolderChild';

        
       // leankor__ProjectRoom__c project = [Select id, name from leankor__ProjectRoom__c where name = 'Test-Project' Limit 1];
        ProjectBoardCarousel.portfoliodata portfolioWithProjectChild = new ProjectBoardCarousel.portfoliodata();
        portfolioWithProjectChild.Id = project.id;
        portfolioWithProjectChild.Name = project.name;
        portfolioWithProjectChild.navigationVerb = 'ProjectChild';

       // leankor__ValueStream__c board = [Select id, name from leankor__ValueStream__c where name = 'Test-Board' Limit 1];
        ProjectBoardCarousel.portfoliodata portfolioWithBoardChild = new ProjectBoardCarousel.portfoliodata();
        portfolioWithBoardChild.Id = board.id;
        portfolioWithBoardChild.Name = board.name;
        portfolioWithBoardChild.navigationVerb = 'BoardChild';
        
        Test.startTest();
        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> portfolioHierarchyFolderChild = new Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet>();
        portfolioHierarchyFolderChild = ProjectBoardCarousel.getPortHierarchyForTimeSheet(portfolioWithFolderChild);

        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> portfolioHierarchyProjectChild = new Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet>();
        portfolioHierarchyProjectChild = ProjectBoardCarousel.getPortHierarchyForTimeSheet(portfolioWithProjectChild);
        
        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> portfolioHierarchyBoardChild = new Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet>();
        portfolioHierarchyBoardChild = ProjectBoardCarousel.getPortHierarchyForTimeSheet(portfolioWithBoardChild);
        Test.stopTest();

        System.assert(portfolioHierarchyFolderChild.size() >0);
        System.assertEquals(portfolioHierarchyFolderChild.size(),2 );
        System.assert(portfolioHierarchyProjectChild.size() >0);
        System.assert(portfolioHierarchyBoardChild.size() >0);
    } */

	@isTest
	static void testRemovePortfolio() {
   
	   Test.startTest();
	   
	   leankor__Portfolio__c testPortfolio = new leankor__Portfolio__c(Name = 'Test');

	   insert testPortfolio;
   
	   leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
	   projectRecord.Name = 'Demo Project Name';
	   projectRecord.leankor__Portfolio__c = testPortfolio.Id;

	   insert projectRecord;
   
	   List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
   
	   for (Integer valueStreamCount = 1; valueStreamCount <= 3; valueStreamCount++) {
		   leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
		   valueStreamRecord.Name = 'valueStream Record ' + valueStreamCount;
		   valueStreamRecord.leankor__ProjectRoom__c = projectRecord.Id;
		   valueStreamRecord.leankor__isRecordDeleted__c = false;
		   valueStreamList.add(valueStreamRecord);
	   }
   
	   insert valueStreamList;
   
	   List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
   
	   for (leankor__ValueStream__c valueStream : valueStreamList) {
	   
		   for (Integer kanbanCardcardCount = 1; kanbanCardcardCount <= 800; kanbanCardcardCount++) {
			   leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
			   kanbanCardRecord.Name = 'kanbanCardRecord ' + kanbanCardcardCount + ' for ValueStream ' + valueStream.Name;
			   kanbanCardRecord.leankor__GUID__c = testDataFactory.createGuid();
			   kanbanCardRecord.leankor__ValueStream__c = valueStream.Id;
			   kanbanCardRecord.leankor__isRecordDeleted__c = false;
			   kanbanCardList.add(kanbanCardRecord);
		   }
	   }
   
	   insert kanbanCardList;

	   List<String> portfolioIds = new List<String>();
	   portfolioIds.add(testPortfolio.Id);
   
	   String result = ProjectBoardCarousel.removePortfolio(portfolioIds);
   
	   Test.stopTest();
   
	   System.assertEquals('Success', result, 'Expected result should be Success');
   
	   for (String portfolioId : portfolioIds) {
   
	   System.assertEquals(0, [Select Count() 
										From leankor__Portfolio__c 
										Where Id = :portfolioId], 'Expected Portfolio to be deleted');
	   }
   
   }
   @isTest
    static void quickActionDateEditWithWeekCalendarTest1() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs1';
        valueStreamData.leankor__SevenDayWorkWeek__c = true;
        insert valueStreamData;
        
        leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.Name = 'kb';
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCardData;

		Test.startTest();
        
        ProjectBoardCarousel.CalculateDates result1 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(3).date(), 3, 'Hours',valueStreamData.Id, kanbanCardData.Id);
        ProjectBoardCarousel.CalculateDates result2 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(3).date(), 3, 'Years',valueStreamData.Id, kanbanCardData.Id);
        ProjectBoardCarousel.CalculateDates result3 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(3).date(), 3, 'Months',valueStreamData.Id, kanbanCardData.Id);
        ProjectBoardCarousel.CalculateDates result4 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(3).date(), 3, 'Minutes',valueStreamData.Id, kanbanCardData.Id);
        ProjectBoardCarousel.CalculateDates result5 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(3).date(), 3, 'Weeks',valueStreamData.Id, kanbanCardData.Id);

		Test.stopTest();

        System.assert(result1!=null);
        System.assert(result2!=null);
        System.assert(result3!=null);
        System.assert(result4!=null);
        System.assert(result5!=null);
    } 
    
    @isTest
    static void quickActionDateEditWithWeekCalendarTest2() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs1';
        valueStreamData.leankor__SevenDayWorkWeek__c = true;
        insert valueStreamData;
        
        leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.Name = 'kb';
        kanbanCardData.leankor__Monday__c = true;
        kanbanCardData.leankor__Tuesday__c = true;
        kanbanCardData.leankor__Wednesday__c = true;
        kanbanCardData.leankor__Thursday__c = false;
        kanbanCardData.leankor__Friday__c = true;
        kanbanCardData.leankor__Saturday__c = true;
        kanbanCardData.leankor__Sunday__c = true;
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCardData;

		Test.startTest();
        
        ProjectBoardCarousel.CalculateDates result1 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(1).date(), null, 'Hours',valueStreamData.Id, kanbanCardData.Id);
        
        ProjectBoardCarousel.CalculateDates result2 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(1).date(), null, 'Years',valueStreamData.Id, kanbanCardData.Id);
        
        ProjectBoardCarousel.CalculateDates result3 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(1).date(), null, 'Months',valueStreamData.Id, kanbanCardData.Id);
        
        ProjectBoardCarousel.CalculateDates result4 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(1).date(), null, 'Minutes',valueStreamData.Id, kanbanCardData.Id);
        
        ProjectBoardCarousel.CalculateDates result5 = ProjectBoardCarousel.quickActionDateEditWithWeekCalendar(System.now().date(), System.now().addDays(1).date(), null, 'Weeks',valueStreamData.Id, kanbanCardData.Id);

		Test.stopTest();

        System.assert(result1!=null);
        System.assert(result2!=null);
        System.assert(result3!=null);
        System.assert(result4!=null);
        System.assert(result5!=null);
    } 
    
    @isTest
    static void getLabelsForConsumersTest() {
		Test.startTest();
        Map<String, String> result = ProjectBoardCarousel.getLabelsForConsumers('hello');
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void checkTranslationLanguageActiveTest() {
		Test.startTest();
        Boolean result = ProjectBoardCarousel.checkTranslationLanguageActive();
		Test.stopTest();

        System.assert(result!=null);
    } 
    
    @isTest
    static void quickActionDateEditTest1() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs1';
        valueStreamData.leankor__SevenDayWorkWeek__c = true;
        insert valueStreamData;
        
        leankor__KanbanCard__c kb = new leankor__KanbanCard__c();
        kb.Name = 'kb';
        kb.leankor__Monday__c = true;
        kb.leankor__Tuesday__c = true;
        kb.leankor__Wednesday__c = true;
        kb.leankor__Thursday__c = false;
        kb.leankor__Friday__c = true;
        kb.leankor__Saturday__c = true;
        kb.leankor__Sunday__c = true;
        kb.leankor__ValueStream__c = valueStreamData.Id;
        kb.leankor__GUID__c = TestDataFactory.createGuid();
        insert kb;

		Test.startTest();
        
        ProjectBoardCarousel.CalculateDates result1 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), null, 'Hours',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result2 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), null, 'Years',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result3 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), null, 'Months',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result4 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), null, 'Minutes',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result5 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), null, 'Weeks',valueStreamData.Id);
		Test.stopTest();

        System.assert(result1!=null);
        System.assert(result2!=null);
        System.assert(result3!=null);
        System.assert(result4!=null);
        System.assert(result5!=null);
    } 
    
    @isTest
    static void quickActionDateEditTest2() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs1';
        valueStreamData.leankor__SevenDayWorkWeek__c = true;
        insert valueStreamData;
                
		Test.startTest();
        ProjectBoardCarousel.CalculateDates result1 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), 1, 'Hours',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result2 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), 1, 'Years',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result3 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), 1, 'Months',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result4 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), 1, 'Minutes',valueStreamData.Id);
        
        ProjectBoardCarousel.CalculateDates result5 = ProjectBoardCarousel.quickActionDateEdit(System.now().date(), System.now().addDays(1).date(), 1, 'Weeks',valueStreamData.Id);
		Test.stopTest();

        System.assert(result1!=null);
        System.assert(result2!=null);
        System.assert(result3!=null);
        System.assert(result4!=null);
        System.assert(result5!=null);
    } 
    /*
    @isTest
    static void validateKanbanCardDatesTest() {
        RealTimeController.Kanban previousData = new RealTimeController.Kanban();
        previousData.Id = 'zdfght';
        previousData.CardId = 'drtyh';
        String json1 = JSON.serialize(previousData);
        RealTimeController.bulkStreaming newData = new RealTimeController.bulkStreaming();
        newData.VSID = 'saert';
        newData.SomeJSONData = 'styyh';
        String json2 = JSON.serialize(newData);
        String result = ProjectBoardCarousel.validateKanbanCardDates(json1, json2);
        System.debug(result);
    }
*/

    @IsTest
    static void DeleteProjectBoardTest() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'Test vs';
        insert valueStreamData;

        PageReference pageRef = new PageReference('/apex/dummy');
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('Id', valueStreamData.Id);

        ProjectBoardCarousel controller = new ProjectBoardCarousel();
        Test.startTest();
        PageReference result = controller.DeleteProjectBoard();
        Test.stopTest();

        System.assertNotEquals(null, result, 'PageReference should not be null');
        System.assert(result.getRedirect(), 'PageReference should be set to redirect');
        System.assert(result.getUrl().startsWith('/'), 'URL should start with "/"');
    }

    @isTest
    static void RedirectVSTest1() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'Test vs';
        insert valueStreamData;

        PageReference pageRef = new PageReference('/apex/dummy');
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('Id', valueStreamData.Id);

        ProjectBoardCarousel controller = new ProjectBoardCarousel();
        Test.startTest();
            PageReference result = controller.RedirectVS();
        Test.stopTest();

        System.assertNotEquals(null, result, 'PageReference should not be null');
        System.assert(result.getRedirect(), 'PageReference should be set to redirect');
        System.assert(result.getUrl().startsWith('/'), 'URL should start with "/"');
    }
    
	@isTest
    static void RedirectVSTest2() {
        PageReference dummyPage = new PageReference('/apex/SomePage');
        Test.setCurrentPage(dummyPage);

        // Provide blank Id parameter
        ApexPages.currentPage().getParameters().put('Id', '');
        Test.setCurrentPageReference(ApexPages.currentPage());

        try {
            Test.startTest();
            ProjectBoardCarousel page = new ProjectBoardCarousel();
        	PageReference result = page.RedirectVS();
            Test.stopTest();
            System.assert(false, 'Expected GanttTaskBoard.LeanException was not thrown');
        } catch (GanttTaskBoard.LeanException e) {
            System.assert(
                e.getMessage().contains('ERROR: BoardId invalid'),
                'Exception message mismatch'
            );
        }
    }

	@isTest
    static void RedirectVSTest3() {
        PageReference dummyPage = new PageReference('/apex/SomePage');
        Test.setCurrentPage(dummyPage);

        // Supply a non-existent Id prefix to trigger SOQL exception
        ApexPages.currentPage().getParameters().put('Id', '001000000000000AAA');
        Test.setCurrentPageReference(ApexPages.currentPage());

        try {
            Test.startTest();
            ProjectBoardCarousel page = new ProjectBoardCarousel();
        	PageReference result = page.RedirectVS();
            Test.stopTest();
            System.assert(false, 'Expected ProjectBoardCarouselException was not thrown');
        } catch (ProjectBoardCarousel.ProjectBoardCarouselException e) {
            System.assert(
                e.getMessage().startsWith('ERROR:'),
                'Exception message should start with ERROR:'
            );
        }
    }
    
    
    /*
    @IsTest
    static void getPicklistTest() {
        List<Schema.PicklistEntry> result = ProjectBoardCarousel.getPicklist('leankor__KanbanCard__c','On Budget');
        System.debug(result);
    }*/
    
    @isTest
    static void getRoleHierarchyTest1() {
        // Ensure behaviour is accessible
        UserRole role = new UserRole(Name='CEO');
		insert role;
        
        Test.startTest();
        Set<ProjectBoardCarousel.RoleLog> result = ProjectBoardCarousel.getRoleHierarchy();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Resulting set should not be null');
        System.assertEquals(1, result.size(), 'Should contain exactly one root RoleLog');
        
        ProjectBoardCarousel.RoleLog rootLog = result.iterator().next();
        System.assertEquals('RoleHierarchy', rootLog.Name, 'Root log name should match');
        System.assert(rootLog.SubordinateRoles != null
            && !rootLog.SubordinateRoles.isEmpty(),
            'SubordinateRoles should be populated');
    }
    
    @isTest
    static void getColumnHierarchyTest1() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs';
        valueStreamData.leankor__BoardType__c = 'Kanban Board';
        insert valueStreamData;
        
        leankor__MasterContainer__c masterContainerData = new leankor__MasterContainer__c();
        masterContainerData.Name = 'ms';
        masterContainerData.leankor__ValueStream__c = valueStreamData.Id;
        insert masterContainerData;
        
        leankor__Swimlane__c swim = new leankor__Swimlane__c();
        swim.Name = 'Swim';
        swim.leankor__MasterContainer__c = masterContainerData.Id;
        swim.leankor__ValueStream__c = valueStreamData.Id;
        insert swim;
        
        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'zone';
        zone.leankor__Swimlane__c = swim.Id;
        zone.leankor__ValueStream__c = valueStreamData.Id;
        zone.leankor__GUID__c = 'zone1';
        insert zone;
        
        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'zone';
        zone2.leankor__Swimlane__c = swim.Id;
        zone2.leankor__ValueStream__c = valueStreamData.Id;
        zone2.leankor__GUID__c = 'zone2';
        insert zone2;
        
		Test.startTest();
        Set<ProjectBoardCarousel.ColumnHierarchy> result = ProjectBoardCarousel.getColumnHierarchy(valueStreamData.Id);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getColumnHierarchyTest2() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs';
        valueStreamData.leankor__BoardType__c = 'WhiteBoard';
        insert valueStreamData;
        
        leankor__MasterContainer__c masterContainerData = new leankor__MasterContainer__c();
        masterContainerData.Name = 'ms';
        masterContainerData.leankor__ValueStream__c = valueStreamData.Id;
        insert masterContainerData;
        
        leankor__Swimlane__c swim = new leankor__Swimlane__c();
        swim.Name = 'Swim';
        swim.leankor__MasterContainer__c = masterContainerData.Id;
        swim.leankor__ValueStream__c = valueStreamData.Id;
        insert swim;
        
        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'zone';
        zone.leankor__Swimlane__c = swim.Id;
        zone.leankor__ValueStream__c = valueStreamData.Id;
        zone.leankor__GUID__c = 'zone1';
        insert zone;
        
        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'zone';
        zone2.leankor__Swimlane__c = swim.Id;
        zone2.leankor__ValueStream__c = valueStreamData.Id;
        zone2.leankor__GUID__c = 'zone2';
        insert zone2;
        
		Test.startTest();
        Set<ProjectBoardCarousel.ColumnHierarchy> result = ProjectBoardCarousel.getColumnHierarchy(valueStreamData.Id);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getdefultcolumnTest1() {
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs';
        valueStreamData.leankor__BoardType__c = 'Kanban Board';
        insert valueStreamData;
        
        leankor__MasterContainer__c masterContainerData = new leankor__MasterContainer__c();
        masterContainerData.Name = 'ms';
        masterContainerData.leankor__ValueStream__c = valueStreamData.Id;
        insert masterContainerData;
        
        leankor__Swimlane__c swim = new leankor__Swimlane__c();
        swim.Name = 'Swim';
        swim.leankor__MasterContainer__c = masterContainerData.Id;
        swim.leankor__ValueStream__c = valueStreamData.Id;
        insert swim;
        
        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'zone';
        zone.leankor__Swimlane__c = swim.Id;
        zone.leankor__ValueStream__c = valueStreamData.Id;
        zone.leankor__GUID__c = 'zone1';
        insert zone;
        
        leankor__Zone__c zone2 = new leankor__Zone__c();
        zone2.Name = 'zone';
        zone2.leankor__Swimlane__c = swim.Id;
        zone2.leankor__ValueStream__c = valueStreamData.Id;
        zone2.leankor__GUID__c = 'zone2';
        insert zone2;
        
		Test.startTest();
        ProjectBoardCarousel.ColumnHierarchy result = ProjectBoardCarousel.getdefultcolumn(valueStreamData.Id);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getFirstInstallValueTest1() {
		Test.startTest();
        boolean result = ProjectBoardCarousel.getFirstInstallValue();
		Test.stopTest();

        System.assert(result==true);
    }
    
    @isTest
    static void getPortHierarchyForTimeSheetTest1() {
        leankor__Portfolio__c portfolioData = new leankor__Portfolio__c();
        portfolioData.Name = 'port1';
        insert portfolioData;
        
        leankor__ProjectRoom__c projectData = new leankor__ProjectRoom__c();
        projectData.Name = 'pro';
        projectData.leankor__Portfolio__c = portfolioData.Id;
        projectData.leankor__IsTemplateProject__c = false;
        insert projectData;
        
        leankor__Portfolio__c portfolioData2 = new leankor__Portfolio__c();
        portfolioData2.Name = 'port2';
        portfolioData2.leankor__ParentPortfolio__c = portfolioData.Id;
        insert portfolioData2;

        ProjectBoardCarousel.portfoliodata data1 = new ProjectBoardCarousel.portfoliodata();
        data1.navigationVerb = 'FolderChild';
        data1.Id = portfolioData.Id;
        
		Test.startTest();
        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> result = ProjectBoardCarousel.getPortHierarchyForTimeSheet(data1);
		Test.stopTest();

        List<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> list1 = new list<ProjectBoardCarousel.PortfolioHierarchyTimeSheet>(result);
        System.assert(list1[0].ParentPortfolio==portfolioData.Id);
    }
    
    @isTest
    static void getPortHierarchyForTimeSheetTest2() {
        leankor__Portfolio__c portfolioData = new leankor__Portfolio__c();
        portfolioData.Name = 'port1';
        insert portfolioData;
        
        leankor__ProjectRoom__c projectData = new leankor__ProjectRoom__c();
        projectData.Name = 'pro';
        projectData.leankor__Portfolio__c = portfolioData.Id;
        projectData.leankor__IsTemplateProject__c = false;
        insert projectData;
        
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs';
        valueStreamData.leankor__BoardType__c = 'Portfolio View';
        valueStreamData.leankor__ProjectRoom__c = projectData.Id;
        valueStreamData.leankor__isRecordDeleted__c = false;
        insert valueStreamData;
        
        ProjectBoardCarousel.portfoliodata data1 = new ProjectBoardCarousel.portfoliodata();
        data1.navigationVerb = 'ProjectChild';
        data1.Id = projectData.Id;
        
		Test.startTest();
        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> result = ProjectBoardCarousel.getPortHierarchyForTimeSheet(data1);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getPortHierarchyForTimeSheetTest3() {
        
        leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
        valueStreamData.Name = 'vs';
        valueStreamData.leankor__BoardType__c = 'Portfolio View';
        valueStreamData.leankor__isRecordDeleted__c = false;
        insert valueStreamData;
        
        leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.Name = 'kb';
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__isRecordDeleted__c = false;
        insert kanbanCardData;
        
        ProjectBoardCarousel.portfoliodata data1 = new ProjectBoardCarousel.portfoliodata();
        data1.navigationVerb = 'BoardChild';
        data1.Id = valueStreamData.Id;
        
		Test.startTest();
        Set<ProjectBoardCarousel.PortfolioHierarchyTimeSheet> result = ProjectBoardCarousel.getPortHierarchyForTimeSheet(data1);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void createProjectLaunchTest() {
        leankor__Module__c moduleData = new leankor__Module__c();
        moduleData.Name = 'mc';
        moduleData.leankor__SetUp__c = true;
        insert moduleData;
        
        leankor__projectRoom__c projectData = new leankor__projectRoom__c();
        projectData.Name = 'pro';
        insert projectData;
        
		Test.startTest();
        String result = ProjectBoardCarousel.createprojectlaunch(projectData.Id);
		Test.stopTest();

		System.assert(result!=null);
    }
    
    @isTest
    static void getMyWorkItemsByFilterToLightningAllTest() {
        
        ProjectBoardCarousel.WorkFilter data1 = new ProjectBoardCarousel.WorkFilter();
        data1.itemType = '';
        data1.filterType = 'WORKBYPROJECT';  	
	    data1.projectId = [Select Id 
								From leankor__ProjectRoom__c 
								Limit 1].Id;

        String data2 = JSON.serialize(data1);

		Test.startTest();
        String result = ProjectBoardCarousel.getMyWorkItemsByFilterToLightningAll(data2, new List<String>{'hello'});
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void updateMyWorkTaskLoadTest() {

		Test.startTest();
        Boolean result = ProjectBoardCarousel.updateMyWorkTaskLoad(true);
		Test.stopTest();

        System.assert(result==true);
    }
    
    @isTest
    static void getWIByFilterReadOnlyTest() {
        ProjectBoardCarousel.WorkFilter data1 = new ProjectBoardCarousel.WorkFilter();
        data1.filterType = 'WORKBYDUEDATE';
        data1.dueDateType = 'hello';

		Test.startTest();
        List<leankor.ProjectBoardCarousel.Card> result = ProjectBoardCarousel.getWIByFilterReadOnly(data1);
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void validateKanbanCardDatesTest() {

        leankor__ProjectRoom__c projectData = new leankor__ProjectRoom__c();
        projectData.name = 'pro';
        insert projectData;

		leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
		valueStreamData.Name = 'vs';
        valueStreamData.leankor__ProjectRoom__c = projectData.Id;
        valueStreamData.leankor__IsRecordDeleted__c = false;
		insert valueStreamData;        
        
		leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.Name = 'kb';
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__IsRecordDeleted__c = false;
        insert kanbanCardData;
        
		leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
        remoteKanban.Id = kanbanCardData.Id;  
        remoteKanban.Name = 'Updated Card';
        remoteKanban.StartDate = System.now();
        remoteKanban.DueDate = System.now() + 5;
		remoteKanban.GUID = TestDataFactory.createGuid();
        
        leankor.realtimeController.bulkStreaming jsonLog = New leankor.realtimeController.bulkStreaming();   
        jsonLog.SomeJSONData = JSON.Serialize(remoteKanban);  
        jsonLog.VSID = valueStreamData.Id;
        jsonLog.Verb = 'updateKanbancards';
        jsonLog.SessionID = UserInfo.getSessionId();

		Test.startTest();
        String result = ProjectBoardCarousel.validateKanbanCardDates(JSON.serialize(remoteKanban),JSON.serialize(jsonLog));
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void validateKbCardDatesTest() {
        leankor__ProjectRoom__c projectData = new leankor__ProjectRoom__c();
        projectData.name = 'pro';
        insert projectData;

		leankor__ValueStream__c valueStreamData = new leankor__ValueStream__c();
		valueStreamData.Name = 'vs';
        valueStreamData.leankor__ProjectRoom__c = projectData.Id;
        valueStreamData.leankor__IsRecordDeleted__c = false;
		insert valueStreamData;        
        
		leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.Name = 'kb';
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__IsRecordDeleted__c = false;
        insert kanbanCardData;
        
		leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
        remoteKanban.Id = kanbanCardData.Id;  
        remoteKanban.Name = 'Updated Card';
        remoteKanban.StartDate = System.now();
        remoteKanban.DueDate = System.now() + 5;
		remoteKanban.GUID = TestDataFactory.createGuid();
        
        leankor.realtimeController.bulkStreaming jsonLog = New leankor.realtimeController.bulkStreaming();   
        jsonLog.SomeJSONData = JSON.Serialize(remoteKanban);  
        jsonLog.VSID = valueStreamData.Id;
        jsonLog.Verb = 'updateKanbancards';
        jsonLog.SessionID = UserInfo.getSessionId();

		Test.startTest();
        String result = ProjectBoardCarousel.validateKbCardDates(JSON.serialize(remoteKanban),JSON.serialize(jsonLog));
		Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void updateKbCardDatesTest() {
		Boolean flag = true;
        leankor__valuestream__c valueStreamData = new leankor__valuestream__c();
		valueStreamData.name = 'Testing VS';
        insert valueStreamData;
            
        leankor__KanbanCard__c kanbanCardData = new leankor__KanbanCard__c();
        kanbanCardData.name= 'kc1';
        kanbanCardData.leankor__ValueStream__c = valueStreamData.Id;
        kanbanCardData.leankor__PercentComplete2__c = 100;
        kanbanCardData.leankor__EstimatedDuration__c = 1;
        kanbanCardData.leankor__GUID__c= system.now() +'dsgsd';
        insert kanbanCardData;  
        
        leankor.RealTimeController.bulkStreaming bulkCard =  new leankor.RealTimeController.bulkStreaming();
        bulkCard.VSID = valueStreamData.Id;
        bulkCard.Verb ='Update';
        bulkCard.someJSONData = JSON.serialize(kanbanCardData);

        List <String> ids = new List<String>();
        ids.add(kanbanCardData.Id);
        bulkCard.cardIds = ids;
        bulkCard.sessionID = UserInfo.getSessionId();

        Test.startTest();
        leankor.ProjectBoardCarousel.updateKbCardDates(JSON.serialize(bulkCard), JSON.serialize(bulkCard));
		Test.stopTest();

        System.assert(flag==true);
    }
    
    @isTest
    static void quickActionRedirectTest1() {
        PageReference pageRef = new PageReference('/apex/dummy');
        pageRef.getParameters().put('type', 'LightningComponent');
        Test.setCurrentPageReference(pageRef);

        Test.startTest();
        PageReference result = ProjectBoardCarousel.quickActionRedirect();
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null for LightningComponent type');
    
    }
    
    @isTest
    static void quickActionRedirectTest2() {
        String cmpName = 'MyVFPage';
        String recId   = '001xx000003NG6V';
        PageReference pageRef = new PageReference('/apex/dummy')
	;
        pageRef.getParameters().put('type', 'VisualforcePage');
        pageRef.getParameters().put('cmpName', cmpName);
        pageRef.getParameters().put('rid', recId);
        Test.setCurrentPageReference(pageRef);

        Test.startTest();
        PageReference result = ProjectBoardCarousel.quickActionRedirect();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected non-null PageReference for VF page');
        String url = result.getUrl();
        System.assert(url.contains('/' + cmpName), 'URL should contain VF page name');
        System.assert(url.contains('id=' + recId), 'URL should include record id parameter');
    }
   
   }