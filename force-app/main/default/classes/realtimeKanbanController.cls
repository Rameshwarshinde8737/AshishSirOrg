/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: realtimeKanbanController.cls
 * CLASS: realtimeKanbanController
 * USAGE: manages the realtime view of a VisualStream object rendered as a flow
*/
global with sharing class realtimeKanbanController { 

    public realtimeKanbanController(Util controller) {}
	global realtimeKanbanController(ApexPages.StandardSetController controller) {}
	global realtimeKanbanController(){}
	private static Final String BLANKSTRING = ''; 
	global realtimeKanbanController(ApexPages.StandardController StdController) {
		this.TheController = StdController;       
	}
	   
	public final ApexPages.StandardController TheController {public get; public set;}


    // Getting first level of folders    
    @RemoteAction
	@AuraEnabled
    global static List<leankor.ProjectBoardCarousel.PortfolioHierarchy> getallParentFolder() {
		PortfolioBehaviour portfolio = new PortfolioBehaviour();
		if (!portfolio.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
		}
		List<leankor.ProjectBoardCarousel.PortfolioHierarchy> parentFolder = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
		
		List<leankor__Portfolio__c> allParentFolders =[Select 
														Id,
														UserRecordAccess.HasEditAccess,
        												UserRecordAccess.HasDeleteAccess,
        												UserRecordAccess.HasReadAccess,
														leankor__ParentPortfolio__c,
														Name 
													From leankor__Portfolio__c 
													Where leankor__ParentPortfolio__c = null 
													Order By Name Asc]; 
        											             
        for (leankor__Portfolio__c singlefolder : allParentFolders) {
			leankor.ProjectBoardCarousel.PortfolioHierarchy ph = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
			ph.Id = singlefolder.Id;
			ph.Name = singlefolder.Name;
			ph.RoomType = 'Portfolio';
			ph.Leaf = false;
			ph.ChildRecords = new Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
			//PH.ChildRecords = getchildFolders(Singlefolder.Id,Allpotfolio);
			ph.hasReadAccess = singlefolder.UserRecordAccess.HasReadAccess;
			ph.hasEditAccess = singlefolder.UserRecordAccess.HasEditAccess;
			ph.hasDeleteAccess =  singlefolder.UserRecordAccess.HasDeleteAccess;	

			parentFolder.add(ph);		
		}                       
		
		return parentFolder;
    }
	   
	
    // Getting second level folders
    global static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getchildFolders (String ParentportfolioId, List<leankor__Portfolio__c> Portfolios) {
		Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> childFolder = new Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
		/*
		if (String.isNotBlank(ParentportfolioId) && Util.getSObjectName(ParentportfolioId) != 'leankor__Portfolio__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
		for(leankor__Portfolio__c portfolio : Portfolios){
			if (String.isNotBlank(portfolio.Id) && Util.getSObjectName(portfolio.Id) != 'leankor__Portfolio__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> childFolder = new Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
		
		for (leankor__Portfolio__c ChildSubFolder : Portfolios) {
			if (ChildSubFolder.leankor__ParentPortfolio__c == ParentportfolioId) {
				leankor.ProjectBoardCarousel.PortfolioHierarchy PH = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
				PH.Id = ChildSubFolder.Id;
				PH.Name = ChildSubFolder.Name;
				PH.Leaf = false;

				childFolder.add(PH);
			}
		}
		*/
		return childFolder;
	}
	

    // Getting full Hierarchy of folders and projects 
    @RemoteAction
	global static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getPortfoliofilterHierarchy() {
	    Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> Portfolio = new Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
	    List<leankor__Portfolio__c> PortfolioLogs= [Select Id, 
															Name, 
															leankor__ParentPortfolio__c 
														From leankor__Portfolio__c 
														With Security_Enforced
														Order By Name Asc 
														Limit 50000];
	    List<leankor__ProjectRoom__c> RoomLogs = [Select Id, 
															Name, 
															leankor__Portfolio__c 
														From leankor__ProjectRoom__c 
														With Security_Enforced
														Order By Name Asc 
														Limit 50000];
		
		for (leankor__Portfolio__c PortfolioLog : PortfolioLogs) {
	        if (PortfolioLog.leankor__ParentPortfolio__c == null) {
	            leankor.ProjectBoardCarousel.PortfolioHierarchy obj_Portfoliohierarchy = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
	            obj_Portfoliohierarchy.Id = PortfolioLog.ID;
	            obj_Portfoliohierarchy.Name = PortfolioLog.Name ;
	            obj_Portfoliohierarchy.RoomType = 'Portfolio';
	            obj_Portfoliohierarchy.ChildRecords = getfilterchildPortfolioHierarchy(PortfolioLog.ID,PortfolioLogs,RoomLogs);
	            Portfolio.add(obj_Portfoliohierarchy);            
	        }
		}
		
	    return Portfolio;
    }
	
	
    global static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getfilterchildPortfolioHierarchy(String parentId, List<leankor__Portfolio__c> ListOfPortfolio, List<leankor__ProjectRoom__c> RoomRecords) {
		if (String.isNotBlank(parentId) && Util.getSObjectName(parentId) != 'leankor__Portfolio__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
		for(leankor__Portfolio__c portfolio : ListOfPortfolio){
			if (String.isNotBlank(portfolio.Id) && Util.getSObjectName(portfolio.Id) != 'leankor__Portfolio__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> SetofchildPortfolio  = new Set<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
		
        for (leankor__ProjectRoom__c roomlog :RoomRecords) {
            if (roomlog.leankor__Portfolio__c == parentId) {
                leankor.ProjectBoardCarousel.PortfolioHierarchy obj_roomchild = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
                obj_roomchild.Id = roomlog.Id;
                obj_roomchild.Name = roomlog.Name;
                obj_roomchild.RoomType = 'Room';
                obj_roomchild.ParentPortfolio = roomlog.leankor__Portfolio__c;
                obj_roomchild.leaf = true;
                SetofchildPortfolio.add(obj_roomchild);
            }
		}
		
        for (leankor__Portfolio__c childOfPF :ListOfPortfolio) {
            if (childOfPF.leankor__ParentPortfolio__c == parentId) {
                leankor.ProjectBoardCarousel.PortfolioHierarchy obj_childPF = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
                obj_childPF.Name = childOfPF.Name;
                obj_childPF.ID = childOfPF.Id;
                obj_childPF.RoomType = 'Portfolio';
                obj_childPF.ParentPortfolio = childOfPF.leankor__ParentPortfolio__c;
                obj_childPF.ChildRecords = getfilterchildPortfolioHierarchy(childOfPF.ID,ListOfPortfolio,RoomRecords);
				
				if (obj_childPF.ChildRecords.size() == 0) {
                    obj_childPF.ChildRecords = leankor.ProjectBoardCarousel.Childroomrecords(childOfPF.ID,RoomRecords);
				}
				
				SetofchildPortfolio.add(obj_childPF);                      
			}       
		}

        return SetofchildPortfolio;
	}
	

    // Inner class for project launch setting
    global class Projectsetting {
        global string DefaultBoard;
        global String ModuleName;
        global String ModuleID;
        global boolean OneClicklaunch; 
        global boolean OpenNewTab;
        global string ProjectID;
        global string ViewType;
        global String Name;
        global string DefaultBoardType;
        global string ModuleBoardType; 
        global string UrlLink;  
        public Boolean hasReadAccess; 
	}
	

    // Inner class for Json string group for broadcasting
    global class JSONGroup {
        global String JSON1;
        global String JSON2;
        global String JSON3;
        global String JSON4;
        global String JSON5;
        global String JSON6;
        global String JSON7;
        global String JSON8;
    }
	    

    // Creating launch setting.   
    @Remoteaction
	global static List<Projectsetting> createProjectLaunchSettings(String RID) {
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
		if (!valueStreamBehavior.isAccessible() ||!projectLaunchBehavior.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
		if (String.isNotBlank(RID) && Util.getSObjectName(RID) != 'leankor__Projectroom__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
		List<Projectsetting> projLaunchBehaviorList = new List<Projectsetting>();
		List<leankor__Valuestream__c> vsLog = [Select 
												Id,
												Name,
												leankor__BoardType__c,
												UserRecordAccess.HasReadAccess  
											From leankor__valuestream__c 
											Where leankor__Projectroom__c =: RID
												And leankor__isRecordDeleted__c = false
											Limit 50000];
	    
		for (leankor__ProjectLaunchBehavior__c  projLaunchBehavior :[Select 
																		Name,
																		leankor__DefaultBoard__r.leankor__UrlLink__c, 
																		leankor__DefaultBoard__r.leankor__BoardType__c,
																		leankor__DefaultBoard__c,
																		leankor__Module__c,
																		leankor__Module__r.Name,
																		leankor__Module__r.leankor__boardType__c,
																		leankor__OneClicklaunch__c,
																		leankor__OpenNewTab__c,
																		leankor__Project__c,
																		leankor__ViewType__c,
																		leankor__DefaultBoard__r.UserRecordAccess.HasReadAccess  
																	From leankor__ProjectLaunchBehavior__c 
																	Where leankor__Project__c =: RID 
																	Order By leankor__Module__r.leankor__Order__c Asc]) {
	    
			Projectsetting projLaunchBehaviorLog = new Projectsetting();
			projLaunchBehaviorLog.DefaultBoard = (projLaunchBehavior.leankor__DefaultBoard__c == null ?'' :projLaunchBehavior.leankor__DefaultBoard__c );
			projLaunchBehaviorLog.DefaultBoardType = (projLaunchBehavior.leankor__DefaultBoard__c == null ? '' : projLaunchBehavior.leankor__DefaultBoard__r.leankor__BoardType__c);
			
			if (projLaunchBehavior.leankor__Module__r.leankor__boardType__c == '_System_PlanBoard') {
				for (leankor__Valuestream__c vs : vsLog) {
					if (vs.leankor__BoardType__c == 'Plan Board') {            
						projLaunchBehaviorLog.DefaultBoard = vs.Id;
						projLaunchBehaviorLog.DefaultBoardType = vs.leankor__BoardType__c ;
						projLaunchBehaviorLog.hasReadAccess = vs.UserRecordAccess.HasReadAccess;
					}
				}
			} else if (projLaunchBehavior.leankor__Module__r.leankor__boardType__c == '_System_UberBoard') {
				for (leankor__Valuestream__c vs: vsLog ) {
					if (vs.leankor__BoardType__c == 'UberBoard') {
						projLaunchBehaviorLog.DefaultBoard = vs.ID;
						projLaunchBehaviorLog.DefaultBoardType = vs.leankor__BoardType__c ;
						projLaunchBehaviorLog.hasReadAccess = vs.UserRecordAccess.HasReadAccess; 
					}    
				}
			}

			projLaunchBehaviorLog.ModuleName = projLaunchBehavior.leankor__Module__r.Name;
			projLaunchBehaviorLog.ModuleID = (projLaunchBehavior.leankor__Module__c == null ?'' :projLaunchBehavior.leankor__Module__c);	      	     
			projLaunchBehaviorLog.OneClicklaunch = projLaunchBehavior.leankor__OneClicklaunch__c;       
			projLaunchBehaviorLog.OpenNewTab = projLaunchBehavior.leankor__OpenNewTab__c;
			projLaunchBehaviorLog.ProjectID = projLaunchBehavior.leankor__Project__c;
			projLaunchBehaviorLog.ViewType = (projLaunchBehavior.leankor__ViewType__c == null ?'':projLaunchBehavior.leankor__ViewType__c);
			projLaunchBehaviorLog.Name = projLaunchBehavior.Name;
			projLaunchBehaviorLog.UrlLink = projLaunchBehavior.leankor__DefaultBoard__r.leankor__UrlLink__c;
	       	
	       	if (projLaunchBehavior.leankor__DefaultBoard__c != null) {	   
				if (String.isNotBlank(String.valueOf(projLaunchBehavior.leankor__DefaultBoard__r.UserRecordAccess.HasReadAccess))) {
					projLaunchBehaviorLog.hasReadAccess = projLaunchBehavior.leankor__DefaultBoard__r.UserRecordAccess.HasReadAccess;
				} else {
					projLaunchBehaviorLog.hasReadAccess= false;
	     		}
			}
           	
			if (projLaunchBehaviorLog.ModuleName == 'Financials') {
				projLaunchBehaviorLog.ModuleBoardType = 'Financials' ;
			} else {
				projLaunchBehaviorLog.ModuleBoardType = projLaunchBehavior.leankor__Module__r.leankor__boardType__c ;
			}

			projLaunchBehaviorList.add(projLaunchBehaviorLog);
		}
		
		return projLaunchBehaviorList; 
	}

	@AuraEnabled(cacheable=true)
	public static List<ProjectSettingsModel> createProjectLaunchSettingsAura(String projectRoomId) {
		List<Projectsetting> projLaunchBehaviorList = createProjectLaunchSettings(projectRoomId);
		List<ProjectSettingsModel> projectSettingList = new List<ProjectSettingsModel>();
		for (Projectsetting projLaunchBehavior : projLaunchBehaviorList) {
			ProjectSettingsModel projLaunchBehaviorLog = new ProjectSettingsModel();
			projLaunchBehaviorLog.defaultBoard = projLaunchBehavior.DefaultBoard;
			projLaunchBehaviorLog.defaultBoardType = projLaunchBehavior.DefaultBoardType;
			projLaunchBehaviorLog.moduleName = projLaunchBehavior.ModuleName;
			projLaunchBehaviorLog.moduleID = projLaunchBehavior.ModuleID;
			projLaunchBehaviorLog.oneClicklaunch = projLaunchBehavior.OneClicklaunch;
			projLaunchBehaviorLog.openNewTab = projLaunchBehavior.OpenNewTab;
			projLaunchBehaviorLog.projectID = projLaunchBehavior.ProjectID;
			projLaunchBehaviorLog.viewType = projLaunchBehavior.ViewType;
			projLaunchBehaviorLog.name = projLaunchBehavior.Name;
			projLaunchBehaviorLog.moduleBoardType = projLaunchBehavior.ModuleBoardType;
			projLaunchBehaviorLog.urlLink = projLaunchBehavior.UrlLink;
			projLaunchBehaviorLog.hasReadAccess = projLaunchBehavior.hasReadAccess;
			
			projectSettingList.add(projLaunchBehaviorLog);			
		}
		
		return projectSettingList;
	}		


	@deprecated
	@Remoteaction  
	global static String createNavPushTopic(String SessionID) {		   	   
	    return 'SessionID';
	}


	// Updating and move for folder and project NAV and portfolio
	@Remoteaction
	@AuraEnabled
	global static String manageNavChange(String Verb, String SomeJSONData, String SessionID) {
		List<String> JSONList = new List<String> {SomeJSONData};
		
		try {
			leankor.ProjectBoardCarousel.PortfolioHierarchy jsonItemData = (leankor.ProjectBoardCarousel.PortfolioHierarchy)JSON.deserialize(SomeJSONData, leankor.ProjectBoardCarousel.PortfolioHierarchy.class);
		 				
			if (jsonItemData.verb == 'UpdateFolder' || jsonItemData.verb == 'UpdateProject' || jsonItemData.verb == 'MoveRoom') {		     
				List<leankor.ProjectBoardCarousel.portfoliodata> portfolioList = new List<leankor.ProjectBoardCarousel.portfoliodata>();	     		     
				leankor.ProjectBoardCarousel.portfoliodata port = new  leankor.ProjectBoardCarousel.portfoliodata();
				port.Id = jsonItemData.Id;
				port.Name = jsonItemData.Name;
				port.ParentPortfolio = jsonItemData.ParentPortfolio;
				port.type = jsonItemData.Roomtype;		     
				portfolioList.add(port);
										
				if (jsonItemData.verb == 'MoveRoom') {				      
					leankor.ProjectBoardCarousel.moveRoom(portfolioList);		 
				} else if (jsonItemData.Roomtype == 'Portfolio') {
					leankor.ProjectBoardCarousel.updatePortfolio(portfolioList);
				}else if (jsonItemData.Roomtype == 'Room') {
					leankor.ProjectBoardCarousel.updateProjects(port);
				}	 	
			} else if (jsonItemData.verb == 'UpdateProjectBoard') {			 
			   leankor.RealTimeController.ProjectBoard  projectboard = new leankor.RealTimeController.ProjectBoard();
			   projectboard.Id  = jsonItemData.Id;
			   projectboard.Name = jsonItemData.Name;
			   leankor.ProjectBoardCarousel.updateListProjectBoard(projectboard);		 							
			}
			// Ashutosh : 27/01/2021 - Fixes for "Send broadcast message after successfully record save".
			leankor.GenericStreamingController.createRealtimeTracker(BLANKSTRING, Verb, JSONList, SessionID);
		} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage()); 
		}
		return 'success';		
	}


	@deprecated
	@Remoteaction
	global static string createfolderPushTopic(Id FolderID, String SomeJSONData, String SessionID) {
		return 'success';
    }
    
	
	@Remoteaction
	global static String updateIsrecalculate(List<String> valueStreamIds) {
		for(String valueStreamId : valueStreamIds) {
			if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		
		//Check CRUD / FLC behavior
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior(); 
		if (
			!valueStreamBehavior.isAccessible() ||
			!valueStreamBehavior.isUpdateable()
		) {
			throw new Util.LeanException('Error: No access to records');	
		}
		//Check CRUD / FLC behavior
		
		List<leankor__valuestream__c> valueStreams = new List<leankor__valuestream__c>();
		for(String valueStreamId : valueStreamIds) {
	    	leankor__valuestream__c valueStream = new leankor__valuestream__c();
	    	valueStream.Id = valueStreamId;
	    	valueStream.leankor__Isrecalculate__c = false;
			valueStream.leankor__IsSchedulerecalculate__c = false;
			
	    	valueStreams.add(valueStream);
    	}
    	try {
    		//update valueStreams;
			RealTimeControllerHelper.updateOperation_Helper(valueStreams);
    	} catch (DmlException e) {
    		throw new Util.LeanException('ERROR:' + e.getMessage()); 
		}
		
    	return 'success';
    }          
}