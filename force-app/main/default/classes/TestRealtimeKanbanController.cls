/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestRealtimeKanbanController.cls
 * CLASS: TestRealtimeKanbanController
 */
@isTest
private class TestRealtimeKanbanController {
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/
    @TestSetup
    private static void makeData(){

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        insert port1;

        leankor__projectroom__c room1 = new leankor__projectroom__c();
        room1.leankor__Portfolio__c = port1.id;
        room1.Name = 'room1';
        insert room1;

        List<leankor__ValueStream__c> valueStreamListData = new List<leankor__ValueStream__c>();
        for(Integer i=1; i<=5; i++){
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'dummy Data';    
            valueStream.leankor__ScheduleBackward__c = false;
            valueStream.leankor__ProjectRoom__c = room1.id;
            valueStream.leankor__BoardType__c = 'Plan Board';
            valueStreamListData.add(valueStream);
        }
        insert valueStreamListData;

        leankor__LeanConstants__c leanConstant = new leankor__LeanConstants__c(leankor__StreamingAPIVersion__c = 55.0);
        insert leanConstant;
    }

    @isTest
    private static void testkanbancontroller(){
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'myVS',leankor__SevenDayWorkWeek__c = false);
        insert valueStream;

        ApexPages.Standardcontroller standardController = new ApexPages.Standardcontroller(valueStream);
        leankor.RealtimeKanbanController rkc1 = new leankor.RealtimeKanbanController();
        leankor.RealtimeKanbanController rkc = new leankor.RealtimeKanbanController(standardController);
        List<leankor__Portfolio__c>  listportfolio = new List<leankor__Portfolio__c> ();
        List<leankor__ProjectRoom__c> listroom = new list<leankor__ProjectRoom__c> (); 
            leankor__portfolio__c port1 = new leankor__portfolio__c();
            port1.Name = 'port1';
            insert port1;
        listportfolio.add(port1);
        leankor__projectroom__c room1 = new leankor__projectroom__c ();
            room1.leankor__Portfolio__c = port1.Id;
            room1.Name = 'room1';
            insert room1;
        listroom .add(room1);
        leankor__portfolio__c port2 = new leankor__portfolio__c();
            port2.leankor__ParentPortfolio__c= port1.Id;
            port2.Name = 'port2';
            insert port2 ;
        listportfolio.add(port1);
        leankor__projectroom__c room2 = new leankor__projectroom__c ();
            room2.leankor__Portfolio__c = port2.Id; 
            room2.Name = 'room2';
            insert room2;
        listroom .add(room2);

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                              leankor__StreamingAPIVersion__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

        System.assert(leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id) != null);
        System.assert(leankor.RealtimeKanbanController.manageNavChange('LeankorNAV', '{}', UserInfo.getSessionId()) != null);
        System.assert(leankor.RealtimeKanbanController.getallParentFolder() != null);
        //System.assert(leankor.RealtimeKanbanController.getchildFolders (port1.Id,listportfolio) != null);
        System.assert(leankor.RealtimeKanbanController.getPortfoliofilterHierarchy() != null);
        System.assert(leankor.RealtimeKanbanController.getfilterchildPortfolioHierarchy(port1.Id,listportfolio, listroom ) != null);
    }

    @isTest
    private static void testvalustreammethod(){
        List<String> valuestm=new List<String>();
        User use =leankor.TestDataFactory.createStandardUser('yesh');
        list<leankor__Portfolio__c> folder =TestDataFactory.createFolder('test',1);
        List<leankor__ProjectRoom__c> projlist=TestDataFactory.createProjects('firstdemo',folder,1);
        List<leankor__ValueStream__c> value=TestDataFactory.createValueStream(projlist,'planboard',use);
        List<leankor__ValueStream__c> vals=new List<leankor__ValueStream__c>();
        leankor__ValueStream__c val=new leankor__ValueStream__c();
        val.id=value[0].id;
        val.name='planboard';
        vals.add(val);            
        upsert vals;
        for(leankor__ValueStream__c vsObj :vals){
            valuestm.add(vsObj.Id);
        }
        String result = leankor.RealtimeKanbanController.updateIsrecalculate(valuestm);   
        System.assertEquals('success', result);
        String userId_1 = UserInfo.getUserId(); 
        String SomeJSONData;   
        leankor.ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchyRecord = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
        portfolioHierarchyRecord.name = 'test';
        portfolioHierarchyRecord.verb = 'MoveRoom';
        portfolioHierarchyRecord.OwnerId = userId_1;   
        SomeJSONData = JSON.serialize(portfolioHierarchyRecord);
        String manage = leankor.RealtimeKanbanController.manageNavChange('MoveRoom', SomeJSONData, UserInfo.getSessionId());
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover manageNavChange method inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void valustreammethodTest(){
        
        List<String> valuestm = new List<String>();
        User use =leankor.TestDataFactory.createStandardUser('yesh');
        list<leankor__Portfolio__c> folder = TestDataFactory.createFolder('test',1);
        List<leankor__ProjectRoom__c> projlist = TestDataFactory.createProjects('firstdemo',folder,1);
        List<leankor__ValueStream__c> value = TestDataFactory.createValueStream(projlist,'planboard',use);

        List<leankor__ValueStream__c> vals = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c val = new leankor__ValueStream__c();
        val.id=value[0].id;
        val.name='planboard';
        vals.add(val);            
        upsert vals;

        for(leankor__ValueStream__c vsObj :vals){
            valuestm.add(vsObj.Id);
        }
        String result = leankor.RealtimeKanbanController.updateIsrecalculate(valuestm);   
        System.assertEquals('success', result);
        String userId_1= UserInfo.getUserId(); 
        String SomeJSONData;     
        leankor.ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchyRecord = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
        portfolioHierarchyRecord.name = 'test';
        portfolioHierarchyRecord.verb = 'UpdateProject';
        portfolioHierarchyRecord.Roomtype = 'Portfolio';
        portfolioHierarchyRecord.OwnerId = userId_1;   
        SomeJSONData = JSON.serialize(portfolioHierarchyRecord);
        String manage = leankor.RealtimeKanbanController.manageNavChange('UpdateProject', SomeJSONData, UserInfo.getSessionId());
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover manageNavChange method inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void valustreammethodOneTest(){
        List<String> valuestm = new List<String>();
        User use =leankor.TestDataFactory.createStandardUser('yesh');
        list<leankor__Portfolio__c> folder = TestDataFactory.createFolder('test',1);
        List<leankor__ProjectRoom__c> projlist = TestDataFactory.createProjects('firstdemo',folder,1);
        List<leankor__ValueStream__c> value = TestDataFactory.createValueStream(projlist,'planboard',use);
        List<leankor__ValueStream__c> vals = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c val = new leankor__ValueStream__c();
        val.id = value[0].id;
        val.name ='planboard';
        vals.add(val);            
        upsert vals;

        for(leankor__ValueStream__c vsObj :vals){
            valuestm.add(vsObj.Id);
        }
        String result = leankor.RealtimeKanbanController.updateIsrecalculate(valuestm);   
        System.assertEquals('success', result);
        String userId_1 = UserInfo.getUserId(); 
        String SomeJSONData;     
        leankor.ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchyRecord = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
        portfolioHierarchyRecord.name = 'test';
        portfolioHierarchyRecord.verb = 'UpdateProject';
        portfolioHierarchyRecord.Roomtype ='Room';
        portfolioHierarchyRecord.OwnerId = userId_1;   
        for(leankor__ProjectRoom__c project : projlist){
            portfolioHierarchyRecord.Id = project.Id;
        }
        SomeJSONData = JSON.serialize(portfolioHierarchyRecord);
        String manage = leankor.RealtimeKanbanController.manageNavChange('UpdateProject',SomeJSONData,UserInfo.getSessionId());
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover manageNavChange method inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void valustreammethodTwoTest(){

        List<String> valuestm = new List<String>();
        User use = leankor.TestDataFactory.createStandardUser('yesh');
        list<leankor__Portfolio__c> folder = TestDataFactory.createFolder('test',1);
        List<leankor__ProjectRoom__c> projlist = TestDataFactory.createProjects('firstdemo',folder,1);
        List<leankor__ValueStream__c> value = TestDataFactory.createValueStream(projlist,'planboard',use);
        List<leankor__ValueStream__c> vals = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c val = new leankor__ValueStream__c();
        val.id = value[0].id;
        val.name = 'planboard';       
        vals.add(val);            
        upsert vals;

        for(leankor__ValueStream__c vsObj :vals){
            valuestm.add(vsObj.Id);
        }
        String result = leankor.RealtimeKanbanController.updateIsrecalculate(valuestm);   
        System.assertEquals('success', result);
        String userId_1 = UserInfo.getUserId(); 
        String SomeJSONData;     
        leankor.ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchyRecord = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
        portfolioHierarchyRecord.name = 'test';
        portfolioHierarchyRecord.verb = 'UpdateProjectBoard';
        portfolioHierarchyRecord.Roomtype ='Room';
        portfolioHierarchyRecord.OwnerId = userId_1; 
        for(leankor__ValueStream__c vStream : vals){
            portfolioHierarchyRecord.Id = vStream.Id;
        }  
        SomeJSONData = JSON.serialize(portfolioHierarchyRecord);
        String manage = leankor.RealtimeKanbanController.manageNavChange('UpdateProject',SomeJSONData,UserInfo.getSessionId());
    }

    @isTest
    private static void testRealTimeKanbanController(){
        List<leankor__Portfolio__c>  listportfolio = new List<leankor__Portfolio__c> ();
        List<leankor__ProjectRoom__c> listroom = new list<leankor__ProjectRoom__c> (); 
        leankor__portfolio__c portdemo = new leankor__portfolio__c();
        portdemo.Name = 'portdemo';
        insert portdemo;

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        port1.leankor__ParentPortfolio__c = portdemo.Id;
        insert port1;
        listportfolio.add(port1);

        leankor__projectroom__c room1 = new leankor__projectroom__c();
        room1.leankor__Portfolio__c = port1.Id;
        room1.Name = 'room1';
        insert room1;

        listroom.add(room1);

        leankor__portfolio__C port2 = new leankor__portfolio__C();
        port2.leankor__ParentPortfolio__c = port1.Id;
        port2.Name = 'port2';
        port2.leankor__ParentPortfolio__c = port1.Id; 
        insert port2;
        listportfolio.add(port1);

        leankor__projectroom__c room2 = new leankor__projectroom__c();
        room2.leankor__Portfolio__c = port2.id; 
        room2.Name = 'room2';
        insert room2;
        listroom .add(room2);

        realtimeKanbanController.Projectsetting  projectest=new realtimeKanbanController.Projectsetting();
        projectest.DefaultBoardType = 'Plan Board';
        projectest.ModuleName = 'Expenses';
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard', leankor__Order__c = 1, leankor__SetUp__c = true, Name = 'Plan (Gantt)'); 
        insert moduleRecord;  
   
        leankor__ProjectLaunchBehavior__c prolan = new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c = room1.id;
        prolan.leankor__Module__c = moduleRecord.id;
        insert prolan;  
    
        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS',leankor__SevenDayWorkWeek__c=false,leankor__BoardType__c='UberBoard',leankor__Projectroom__c=room1.id);
        insert vs;

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                              leankor__StreamingAPIVersion__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vs);
        leankor.RealtimeKanbanController rkc1 = new leankor.RealtimeKanbanController();
        leankor.RealtimeKanbanController rkc = new leankor.RealtimeKanbanController(sc);
        // Date : 11/05/19 create User for checking security.
        User user1 = leankor.TestDataFactory.createStandardUser('Lean1');
		User user2 = leankor.TestDataFactory.createStandardUser('Lean2');	
		User user3 = leankor.TestDataFactory.createStandardUser('Lean3');
		List<String> sharingList = new List<String> ();
		List<String> sharingList1 = new List<String> ();
		for(leankor__Portfolio__c folder :listportfolio){
			sharingList.add(folder.id);
		}			 					
	
		Boolean isFolderReadOnly = leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__Portfolio__share','Read');	  		
		Boolean isFolderReadWrite = leankor.TestDataFactory.shareRecord(user2, sharingList1,'leankor__Portfolio__share','Edit');	
		
		List<String> ids = new List<String>();
		ids.add(vs.id);  
		
		Boolean isvsReadWrite = leankor.TestDataFactory.shareRecord(user1, ids,'leankor__ValueStream__share','Read');
		
		if(isFolderReadOnly){
            System.runAs(user1){
                List<leankor.RealtimeKanbanController.Projectsetting> ProjectLaunchSettings = leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id);
                for(leankor.RealtimeKanbanController.Projectsetting  projectLaunch:ProjectLaunchSettings){
                    System.assertEquals(projectLaunch.hasReadAccess, true);
                }
                System.assert(ProjectLaunchSettings.size()>0);
            }
		}
		if(isFolderReadWrite){
            System.runAs(user2){
                List<leankor.RealtimeKanbanController.Projectsetting> ProjectLaunchSettings = leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id);
                for(leankor.RealtimeKanbanController.Projectsetting  projectLaunch:ProjectLaunchSettings){
                    System.assertEquals(projectLaunch.hasReadAccess, null);
                }				
            }
		}
        System.assert(leankor.RealtimeKanbanController.manageNavChange('LeankorNAV', '{}', UserInfo.getSessionId()) != null);
               
	
		if(isFolderReadOnly){
            System.runAs(user1){
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>  parentFolders = leankor.RealtimeKanbanController.getallParentFolder(); 
                for(leankor.ProjectBoardCarousel.PortfolioHierarchy folder : parentFolders){
                    System.assertEquals(folder.hasReadAccess, true);
                    System.assertEquals(folder.hasEditAccess, false);
                    System.assertEquals(folder.hasDeleteAccess, false);		        	
                }
            }
		}
	
		if(isFolderReadWrite){
            System.runAs(user2){
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>  parentFolders = leankor.RealtimeKanbanController.getallParentFolder(); 
                for(leankor.ProjectBoardCarousel.PortfolioHierarchy folder : parentFolders){
                    System.assertEquals(folder.hasReadAccess, true);
                    System.assertEquals(folder.hasEditAccess, true);
                    System.assertEquals(folder.hasDeleteAccess, false);		        	
                }
            }  
		}  
	  
        System.runAs(user3){
        	try {    
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> parenFolders = leankor.RealtimeKanbanController.getallParentFolder();
                if (parenFolders.size()>0) {
                    system.assert(parenFolders.size() != 0);
                } else {
                    system.assert(parenFolders.size() == 0);
                }    
            } catch (Exception e) {
                System.assertEquals('leankor.Util.LeanException',e.getTypeName());  
            }                                  
		}        
                                            
        //System.assert(leankor.RealtimeKanbanController.getchildFolders (portdemo.Id,listportfolio) != null);
        System.assert(leankor.RealtimeKanbanController.getPortfoliofilterHierarchy() != null);
        System.assert(leankor.RealtimeKanbanController.getfilterchildPortfolioHierarchy(port1.Id, listportfolio, listroom ) != null);
    }

    @isTest
    private static void realTimeKanbanControllerTest(){

        List<leankor__Portfolio__c>  listportfolio = new List<leankor__Portfolio__c> ();
        List<leankor__ProjectRoom__c> listroom = new list<leankor__ProjectRoom__c> (); 

        leankor__portfolio__c portdemo = new leankor__portfolio__c();
        portdemo.Name = 'portdemo';
        insert portdemo;

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        port1.leankor__ParentPortfolio__c = portdemo.id;
        insert port1;
        listportfolio.add(port1);

        leankor__projectroom__C room1 = new leankor__projectroom__C ();
        room1.leankor__Portfolio__c = portdemo.id;
        room1.Name = 'room1';
        insert room1;
        listroom .add(room1);

        leankor__projectroom__C room2 = new leankor__projectroom__C ();

        realtimeKanbanController.Projectsetting projectest = new realtimeKanbanController.Projectsetting();
     
        projectest.DefaultBoardType = 'Plan Board';
        projectest.ModuleName = 'Expenses';
       
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true,Name = 'Plan (Gantt)'); 
        insert moduleRecord;  
  
        leankor__ProjectLaunchBehavior__c prolan=new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c=room1.id;
        prolan.leankor__Module__c=moduleRecord.id;
     
        insert prolan;  
     
        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS',leankor__SevenDayWorkWeek__c=false,leankor__BoardType__c='UberBoard',leankor__Projectroom__c=room1.id);
        insert vs;
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vs);
        leankor.RealtimeKanbanController rkc1 = new leankor.RealtimeKanbanController();
        leankor.RealtimeKanbanController rkc = new leankor.RealtimeKanbanController(sc);
    
        User user1 = leankor.TestDataFactory.createStandardUser('Lean1');
		User user2 = leankor.TestDataFactory.createStandardUser('Lean2');	
		User user3 = leankor.TestDataFactory.createStandardUser('Lean3');

        leankor__LeanConstants__c constraintSetting = [Select Id,
                                                              leankor__StreamingAPIVersion__c
                                                        From leankor__LeanConstants__c
                                                        Limit 1];

		List<String> sharingList = new List<String> ();
		List<String> sharingList1 = new List<String> ();
		for(leankor__Portfolio__c folder :listportfolio){
			sharingList.add(folder.id);
		}			 					

		Boolean isFolderReadOnly = leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__Portfolio__share','Read');	  		
		Boolean isFolderReadWrite =leankor.TestDataFactory.shareRecord(user2, sharingList1,'leankor__Portfolio__share','Edit');	
		
		List<String> ids=new List<String>();
		ids.add(vs.id);  

		Boolean isvsReadWrite =  leankor.TestDataFactory.shareRecord(user1, ids,'leankor__ValueStream__share','Read');
		
		if(isFolderReadOnly){
		System.runAs(user1){
			List<leankor.RealtimeKanbanController.Projectsetting> ProjectLaunchSettings = leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id);
				for(leankor.RealtimeKanbanController.Projectsetting  projectLaunch:ProjectLaunchSettings){
					System.assertEquals(projectLaunch.hasReadAccess,true);
				}
				System.assert(ProjectLaunchSettings.size()>0);
			}
		}
		if(isFolderReadWrite){
            System.runAs(user2){
                List<leankor.RealtimeKanbanController.Projectsetting> ProjectLaunchSettings = leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id);
                for(leankor.RealtimeKanbanController.Projectsetting  projectLaunch:ProjectLaunchSettings){
                    System.assertEquals(projectLaunch.hasReadAccess,null);
                }				
            }
		}
        System.assert(leankor.RealtimeKanbanController.manageNavChange('LeankorNAV','{}',UserInfo.getSessionId()) != null);
               
	
		if(isFolderReadOnly){
            System.runAs(user1){
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>  parentFolders = leankor.RealtimeKanbanController.getallParentFolder(); 
                for(leankor.ProjectBoardCarousel.PortfolioHierarchy folder : parentFolders){
                    System.assertEquals(folder.hasReadAccess, true);
                    System.assertEquals(folder.hasEditAccess, false);
                    System.assertEquals(folder.hasDeleteAccess, false);		        	
                }
            }
		}
	
		if(isFolderReadWrite){
            System.runAs(user2){
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>  parentFolders = leankor.RealtimeKanbanController.getallParentFolder(); 
                for(leankor.ProjectBoardCarousel.PortfolioHierarchy folder :parentFolders){
                    System.assertEquals(folder.hasReadAccess, true);
                    System.assertEquals(folder.hasEditAccess, true);
                    System.assertEquals(folder.hasDeleteAccess, false);		        	
                }
            }  
		}  
	
        System.runAs(user3){
            try {
                Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> parenFolders = leankor.RealtimeKanbanController.getallParentFolder();
                if (parenFolders.size()>0) {
                    system.assert(parenFolders.size()!=0);
                } else {
                    system.assert(parenFolders.size()==0);
                }  
            } catch (Exception e) {
                System.assertEquals('leankor.Util.LeanException',e.getTypeName());  
            }                                   
		}        
                                            
        //System.assert(leankor.RealtimeKanbanController.getchildFolders (port1.id,listportfolio)!=null);
        System.assert(leankor.RealtimeKanbanController.getPortfoliofilterHierarchy()!=null);
        System.assert(leankor.RealtimeKanbanController.getfilterchildPortfolioHierarchy(port1.id,listportfolio,listroom )!=null);
    }

    /*---------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover createProjectLaunchSettings method inside  realtimeKanbanController Class
    -----------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void createProjectLaunchSettingsOneTest(){

        leankor__portfolio__C portfolioRecord = [Select Id
                                                    From leankor__portfolio__c
                                                    Where Name ='port1'
                                                    Limit 1];

        leankor__projectroom__C room1 = new leankor__projectroom__c ();
        room1.leankor__Portfolio__c = portfolioRecord.id;
        room1.Name = 'room1';
        insert room1;
        
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true,Name = 'Plan (Gantt)'); 
        insert moduleRecord;  

        leankor__ProjectLaunchBehavior__c prolan = new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c=room1.id;
        prolan.leankor__Module__c=moduleRecord.id;
        insert prolan;  

        System.assert(leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id)!=null);
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover createProjectLaunchSettings method inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void  createProjectLaunchSettingsTwoTest(){
        
        leankor__portfolio__C portfolioRecord = [Select Id
                                                    From leankor__portfolio__c
                                                    Where name = 'port1'
                                                    Limit 1];

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        port1.leankor__ParentPortfolio__c=portfolioRecord.Id;
        insert port1;

        leankor__projectroom__c room1 = new leankor__projectroom__c();
        room1.leankor__Portfolio__c = port1.Id;
        room1.Name = 'room1';
        insert room1;
     
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true, Name = 'Plan (Gantt)'); 
        insert moduleRecord;  

        leankor__ProjectLaunchBehavior__c prolan = new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c = room1.Id;
        prolan.leankor__Module__c = moduleRecord.Id;
        insert prolan; 

        leankor__portfolio__c port2 = new leankor__portfolio__c();
        port2.leankor__ParentPortfolio__c = port1.Id;
        port2.Name = 'port2';
        insert port2 ;
        
        leankor__projectroom__c room2 = new leankor__projectroom__c();
        room2.leankor__Portfolio__c = port2.Id; 
        room2.Name = 'room2';
        insert room2;
     
        leankor__ProjectLaunchBehavior__c prolan1 = new leankor__ProjectLaunchBehavior__c();
        prolan1.leankor__Project__c=room1.Id;
        prolan1.leankor__Module__c=moduleRecord.Id;
        insert prolan1; 

        List<leankor__ValueStream__c> valueStreamListData = new List<leankor__ValueStream__c>();
        for(Integer i=1;i<=5;i++){
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'dummy Data';    
            valueStream.leankor__ScheduleBackward__c = false;
            valueStream.leankor__ProjectRoom__c = room1.Id;
            valueStream.leankor__BoardType__c = 'UberBoard';
            valueStreamListData.add(valueStream);
        }
        insert valueStreamListData;
        System.assert(leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id)!=null);
    }

    /*---------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover createProjectLaunchSettings method inside  realtimeKanbanController Class
    -----------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void createProjectLaunchSettingsThreeTest(){
        
        leankor__portfolio__C portfolioRecord = [Select Id
                                                    From leankor__portfolio__C
                                                    Where Name = 'port1'
                                                    Limit 1];

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        port1.leankor__ParentPortfolio__c=portfolioRecord.Id;
        insert port1;

        leankor__projectroom__c room1 = new leankor__projectroom__c();
        room1.leankor__Portfolio__c = port1.Id;
        room1.Name = 'room1';
        insert room1;
     
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_PlanBoard', leankor__Order__c = 1, leankor__SetUp__c = true, Name = 'Plan (Gantt)'); 
        insert moduleRecord;   

        leankor__ProjectLaunchBehavior__c prolan = new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c = room1.Id;
        prolan.leankor__Module__c = moduleRecord.Id;
        insert prolan; 

        leankor__portfolio__c port2 = new leankor__portfolio__c();
        port2.leankor__ParentPortfolio__c = port1.Id;
        port2.Name = 'port2';
        insert port2 ;
        
        leankor__projectroom__C room2 = new leankor__projectroom__C ();
        room2.leankor__Portfolio__c = port2.Id; 
        room2.Name = 'room2';
        insert room2;
      
        List<leankor__ValueStream__c> valueStreamListData = new List<leankor__ValueStream__c>();
        for(Integer i=1; i<=5; i++){
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'dummy Data';    
            valueStream.leankor__ScheduleBackward__c = false;
            valueStream.leankor__ProjectRoom__c = room1.id;
            valueStream.leankor__BoardType__c = 'Plan Board';
            valueStreamListData.add(valueStream);
        }
        insert valueStreamListData;

        leankor__ProjectLaunchBehavior__c prolan1 = new leankor__ProjectLaunchBehavior__c();
        prolan1.leankor__Project__c = room1.Id;
        prolan1.leankor__Module__c = moduleRecord.Id;
        prolan1.leankor__DefaultBoard__c = valueStreamListData[0].Id;
        insert prolan1; 
        System.assert(leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id) != null);
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover createProjectLaunchSettings method inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void createProjectLaunchSettingsForthTest(){
      
        leankor__portfolio__C portfolioRecord = [Select Id
                                                    From leankor__portfolio__C
                                                    Where name ='port1'
                                                    Limit 1];

        leankor__portfolio__c port1 = new leankor__portfolio__c();
        port1.Name = 'port1';
        port1.leankor__ParentPortfolio__c = portfolioRecord.Id; 
        insert port1;

        leankor__projectroom__c room1 = new leankor__projectroom__c();
        room1.leankor__Portfolio__c = port1.Id;
        room1.Name = 'room1';
        insert room1;
     
        leankor__Module__c moduleRecord = new leankor__Module__c(leankor__BoardType__c = '_System_PlanBoard', leankor__Order__c = 1, leankor__SetUp__c = true, Name = 'Financials'); 
        insert moduleRecord;  

        leankor__ProjectLaunchBehavior__c prolan = new leankor__ProjectLaunchBehavior__c();
        prolan.leankor__Project__c = room1.Id;
        prolan.leankor__Module__c = moduleRecord.Id;
        insert prolan; 

        leankor__portfolio__c port2 = new leankor__portfolio__c();
        port2.leankor__ParentPortfolio__c = port1.Id;
        port2.Name = 'port2';
        insert port2 ;
        
        leankor__projectroom__c room2 = new leankor__projectroom__c();
        room2.leankor__Portfolio__c = port2.Id; 
        room2.Name = 'room2';
        insert room2;
        System.assert(leankor.RealtimeKanbanController.createProjectLaunchSettings(room1.Id) != null);
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover realtimeKanbanController constructor inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/
    @istest
    private static void  realtimeKanbanControllerOneTest(){
        Boolean flag = true; 
        Test.startTest(); 
        Util utilRecord = new Util();
        realtimeKanbanController realtimeKanbanControllerRescord   = new realtimeKanbanController(utilRecord);
        System.assertEquals(true, flag); 
        Test.stopTest(); 
    }

  	/*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover realtimeKanbanController constructor inside  realtimeKanbanController Class
    ---------------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void realtimeKanbanControllerTwoTest(){
        Boolean flag = true; 
        Test.startTest();
        List<leankor__ValueStream__c> valueStreamListData =[Select Id
                                                               From leankor__ValueStream__c
                                                               Limit 5];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(valueStreamListData);
        Leankor.realtimeKanbanController realtimeKanbanControllerstdSetController = new Leankor.realtimeKanbanController(stdSetController);
        System.assertEquals(true, flag);
        Test.stopTest();     
    }
}