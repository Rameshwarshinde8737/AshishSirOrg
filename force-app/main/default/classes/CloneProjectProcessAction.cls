/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

global with sharing class CloneProjectProcessAction {

    global class CloneProjectRequest {
        @InvocableVariable(label='Folder id of source project' description='The folder id where the project to be cloned is located.')
            global String sourceFolderId;
        @InvocableVariable(label='Folder name of source project' description='The folder name where the project to be cloned is located. This is not needed if “Folder id of source project” is defined.')
            global String sourceFolderName;         
        @InvocableVariable(label='Project id of source project' description='The project id of the project to be cloned. If this is defined, there is no need to define “Folder id of source project” or “Folder name of source project” or “Project name of source project”.')
            global String sourceProjectId;          
        @InvocableVariable(label='Project name of source' description='The project name of the project to be cloned.” is defined.')
            global String sourceProjectName;            
        @InvocableVariable(label='Folder id of target project' description='The folder id where the cloned project is to be located.”')
            global String targetFolderId;           
        @InvocableVariable(label='Folder name of target project' description='The folder name where the cloned project is to be located. This is not needed if “Folder id of target project” is defined.')
            global String targetFolderName;
        @InvocableVariable(label='Project name of target project' description='The project name of the cloned project.' required=true)
            global String targetProjectName;
        @InvocableVariable(label='Project start date time' description='The start date of the cloned project in date and time data type. If this is defined, there is no need to specify “Project due date time”.')
            global DateTime targetProjectStartDateTime;
        @InvocableVariable(label='Project due date time' description='The due date of the cloned project in date and time data type. Define this if “Project start date time” is not defined. “Project start date time” takes precedence, meaning it is only used if “Project start date time” is not defined.')
            global DateTime targetProjectDueDateTime;
        @InvocableVariable(label='Plan Gantt' description='Set to true if Plan Gantt will be cloned.')
            global Boolean planGantt;
        @InvocableVariable(label='Roll Up' description='Set to true if Roll Up will be cloned.')
            global Boolean rollUp;
        @InvocableVariable(label='Project Board' description='Set to true if Project board(s) will be cloned.')
            global Boolean projectBoard;
        @InvocableVariable(label='White Board' description='Set to true if Whiteboard(s) will be cloned.')
            global Boolean whiteBoard;
        @InvocableVariable(label='Dash Board' description='Set to true if Dashboard(s) will be cloned.')
            global Boolean dashBoard;           
        @InvocableVariable(label='Expenses' description='Set to true if Expenses will be cloned.')
            global Boolean expenses;    
        @InvocableVariable(label='Return Portfolio Hierarchy' description='Set to true if Hierarchy of Portfolio will be returned as a List of strings.')
            global Boolean returnPortfolioHierarchy;   
        @InvocableVariable(label='Relink cloned project id' description='The project id of cloned project to relink items within. If this is defined, the API will only execute relinking and not cloning making values of the other parameters unnecessary.')
            global String relinkClonedProjectId;
        @InvocableVariable(label='Set of project board types within the source project' description='The board types of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global List<String> projectBoardTypes;
        @InvocableVariable(label='Total cards of all project boards within the source project' description='The total number of cards of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global Integer totalCardsOfSourceProjectBoards;
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
            global Boolean cloneFiles;
        @InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
            global Boolean cloneCustomFields;
        @InvocableVariable(label='Project Launch date time' description='The launch date of the cloned project in date and time data type. Define this if “Project start date time” and "Project due date time" are not defined.')              
            global Datetime targetLaunchDateTime; 
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload; 
        @InvocableVariable(label='Clone KanbanCard Stickers' description='Set to true if Clone All Sticker on Face of KanbanCards')
            global Boolean cardStickerVerb;  

        public String targetStartDate;      
        public String targetLaunchDate;
        public String targetDueDate;
        public String sessionID;

    }

    global class CloneProjectResult {
        @InvocableVariable(label='Cloned Project Id' description ='The project id of the cloned project.')
            global String clonedProjectId;
    } 

    global CloneProjectProcessAction(ApexPages.StandardSetController  controller){}  


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    This is Invocable Method for Cloning Project by API call
	    Inputs:         List of CloneProjectRequest
	    Returns:        No Output
	------------------------------------------------------------*/
    @InvocableMethod
    global static void cloneProjects(List<CloneProjectRequest> requests) {
        CloneProjectResult result = new CloneProjectResult();
        for (CloneProjectRequest request : requests) {            
            result = cloneProject(request);     
        }
    }  


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    helper method to clone the project and also this method is RemoteAction so UI can use this method. 
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        No Output
	------------------------------------------------------------*/
    @RemoteAction
    global static CloneProjectResult cloneProject(CloneProjectRequest requestInstance) {   
        // Added Security code for sentize user Input
        if((String.isNotBlank(requestInstance.sourceFolderId) && Util.getSObjectName(requestInstance.sourceFolderId) != 'leankor__Portfolio__c')
        || (String.isNotBlank(requestInstance.sourceProjectId) && Util.getSObjectName(requestInstance.sourceProjectId) != 'leankor__ProjectRoom__c')
        || (String.isNotBlank(requestInstance.targetFolderId) && Util.getSObjectName(requestInstance.targetFolderId) != 'leankor__Portfolio__c')
        || (String.isNotBlank(requestInstance.relinkClonedProjectId) && Util.getSObjectName(requestInstance.relinkClonedProjectId) != 'leankor__ProjectRoom__c')) {
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior   
        ProjectRoomBehaviour projectBehaviour =  new ProjectRoomBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();

        if (!projectBehaviour.isAccessible() 
        ||  !projectBehaviour.isCreateable()
        ||  !expenseBehaviour.isAccessible()
        ||  !expenseBehaviour.isCreateable()
        ||  !projectLaunchBehavior.isAccessible()
        ||  !projectLaunchBehavior.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }        
        //Check CRUD / FLC behavior
        
        CloneProjectBoardBatch.CloneProjectBoardRequest request = prepareBoardRequest(requestInstance);
        CloneProjectResult result = new CloneProjectResult();
        // determine board type to clone  
        Set<String> synchBoardTypes = new Set<String>();  
        Set<String> asynchBoardTypes = new Set<String>();  
        Set<String> moduleBoardTypes = new Set<String>();   
        
        setBoardTypesToClone(asynchBoardTypes, synchBoardTypes, moduleBoardTypes, requestInstance);
        
        if (synchBoardTypes.isEmpty() && asynchBoardTypes.isEmpty() && !request.expenses) {
            throw new CloneProjectAction.CloneProjectActionException('You must specify at least one Project item to clone.');
        }  

        List<leankor__Portfolio__c> targetFolder = readTargetFolder(requestInstance); 
                
        if (targetFolder.isEmpty()) {
            throw new CloneProjectAction.CloneProjectActionException('You must specify a valid "Target Folder Id" or "Target Folder Name".');
        } 
        
        List<leankor__ProjectRoom__c> sourceProject = readSourceProject(requestInstance);

        if (sourceProject.isEmpty()) {
            throw new CloneProjectAction.CloneProjectActionException('You must specify a valid "Source Project Id" or "Source Folder Name and Source Project Name" or "Source Folder Id and Source Project Name".');
        }

        request.targetFolderId = targetFolder[0].Id;
        request.targetFolderName = targetFolder[0].Name;
        request.folderName = sourceProject[0].leankor__Portfolio__r.Name;
        request.projectRoomId = sourceProject[0].Id;  
        request.sourceProjectName = sourceProject[0].Name;
        request.sourceProjectId = requestInstance.sourceProjectId;
        List<leankor__ProjectLaunchBehavior__c> cloneProjectSetup = CloneProjectAction.readProjectSetup(request.projectRoomId, moduleBoardTypes);
        List<leankor__ValueStream__c> synchCloneProjectBoards = synchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : readProjectBoards(request.projectRoomId, synchBoardTypes);        
        List<leankor__ValueStream__c> asynchCloneProjectBoards = asynchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : readProjectBoards(request.projectRoomId, asynchBoardTypes);


        Integer totalCardsOfProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : CloneProjectAction.readProjectCardCount(request.projectRoomId, asynchBoardTypes);
        Integer totalNumberOfSourceProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : readProjectBoards(request.projectRoomId, asynchBoardTypes).size();
        leankor__ProjectRoom__c projectRoom = CloneProjectProcessAction.createProject(request); 

        // set savepoint to rollback if there is an exception
        Savepoint savePoint = Database.setSavepoint();

        try {
            insert projectRoom;

            request.relinkClonedProjectId = projectRoom.Id;

            insert CloneProjectAction.createProjectSetup(projectRoom.Id, cloneProjectSetup); 

            if (request.expenses) { 
                cloneExpenses(request, projectRoom);
            }

            request.projectBoardTypes = new List<String>();
            if (asynchCloneProjectBoards.size() > 0 ) {
                request.projectBoardTypes.addAll(asynchBoardTypes);
            }
            request.totalCardsOfSourceProjectBoards = totalCardsOfProjectBoards;
            request.totalNumberOfSourceProjectBoards = totalNumberOfSourceProjectBoards;
            if(synchCloneProjectBoards.size() > 0) {
                for (leankor__ValueStream__c synchCloneProjectBoard : synchCloneProjectBoards) {      
                    
                    request.ProjectBoard = synchCloneProjectBoard.Name;
                    request.ProjectBoardId = synchCloneProjectBoard.Id;
                    
                    if (synchCloneProjectBoard.leankor__BoardType__c == 'UberBoard') {
                        request.TargetBoard = 'Plan Board(' + request.projectRoom + ')';
                    }

                    // Truncate if necessary
                    request.TargetBoard = truncateTargetBoard(request.TargetBoard);

                    request.sevenDayWorkWeek = synchCloneProjectBoard.leankor__SevenDayWorkWeek__c;   
                    CloneProjectPlanGanttBatch cloneProjectPlanGanttBatch = new CloneProjectPlanGanttBatch(request, synchCloneProjectBoard, requestInstance);
                    Database.executeBatch(cloneProjectPlanGanttBatch, 200);
                }
            } else {
                for (leankor__ValueStream__c asynchCloneProjectBoard : asynchCloneProjectBoards) {      
                
                    request.ProjectBoard = asynchCloneProjectBoard.Name;
                    request.ProjectBoardId = asynchCloneProjectBoard.Id;
                    if (asynchCloneProjectBoard.leankor__BoardType__c == 'Plan Board') {
                        request.TargetBoard = 'Roll-Up (' + request.projectRoom + ')';
                    } else if (asynchCloneProjectBoard.leankor__BoardType__c == 'DashBoard' && asynchCloneProjectBoard.Name == asynchCloneProjectBoard.leankor__ProjectRoom__r.Name + ' DashBoard') {
                        request.TargetBoard = request.projectRoom + ' DashBoard';
                    } else {
                        request.TargetBoard = asynchCloneProjectBoard.Name;
                    }
                    
                    // Truncate if necessary
                    request.TargetBoard = truncateTargetBoard(request.TargetBoard);
    
                    request.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;     
                    CloneProjectBoardBatch cloneProjectBoardBatch = new CloneProjectBoardBatch(request, asynchCloneProjectBoard, requestInstance);
                    Database.executeBatch(cloneProjectBoardBatch, 200);
                } 
            } 
            result.clonedProjectId = projectRoom.Id;
        } catch (exception ex) {
            Database.rollback(savePoint);
            CloneProjectAction.unlinkProject(requestInstance.relinkClonedProjectId, asynchBoardTypes);
            throw new CloneProjectAction.CloneProjectActionException(ex.getMessage());
        }   
        return result;
    }

     @AuraEnabled
    public static CloneProjectResponse cloneProjectAura(CloneProjectRequestData request) {
        CloneProjectResponse response = new CloneProjectResponse();
        try { 
            // Map UI wrapper -> existing invocable request
            CloneProjectRequest requestInstance = new CloneProjectRequest();
            requestInstance.sourceFolderId = request.sourceFolderId;
            requestInstance.sourceFolderName = request.sourceFolderName;
            requestInstance.sourceProjectId = request.sourceProjectId;
            requestInstance.sourceProjectName = request.sourceProjectName;
            requestInstance.targetFolderId = request.targetFolderId;
            requestInstance.targetFolderName = request.targetFolderName;
            requestInstance.targetProjectName = request.targetProjectName;
            requestInstance.targetProjectStartDateTime = request.targetProjectStartDateTime;
            requestInstance.targetProjectDueDateTime = request.targetProjectDueDateTime;
            requestInstance.planGantt = request.planGantt;
            requestInstance.rollUp = request.rollUp;
            requestInstance.projectBoard = request.projectBoard;
            requestInstance.whiteBoard = request.whiteBoard;
            requestInstance.dashBoard = request.dashBoard;
            requestInstance.expenses = request.expenses;
            requestInstance.returnPortfolioHierarchy = request.returnPortfolioHierarchy;
            requestInstance.relinkClonedProjectId = request.relinkClonedProjectId;
            requestInstance.projectBoardTypes = request.projectBoardTypes;
            requestInstance.totalCardsOfSourceProjectBoards = request.totalCardsOfSourceProjectBoards;
            requestInstance.cloneFiles = request.cloneFiles;
            requestInstance.cloneCustomFields = request.cloneCustomFields;
            requestInstance.targetLaunchDateTime = request.targetLaunchDateTime;
            requestInstance.projectEventCustomPayload = request.projectEventCustomPayload;
            requestInstance.cardStickerVerb = request.cardStickerVerb;

            // Optional passthroughs
            requestInstance.targetStartDate = request.targetStartDate;
            requestInstance.targetLaunchDate = request.targetLaunchDate;
            requestInstance.targetDueDate = request.targetDueDate;
            requestInstance.sessionID = request.sessionID;

            // Call your existing invocable logic
             CloneProjectResult result = cloneProject(requestInstance);

            response.clonedProjectId = result.clonedProjectId;   
        } catch (Exception e) {
        }
        return response;
    }

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Read project records.
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        List of leankor__ProjectRoom__c(Project)
	------------------------------------------------------------*/
    private static List<leankor__ProjectRoom__c> readSourceProject(CloneProjectRequest requestInstance) {

        return String.isBlank(requestInstance.sourceProjectId) || !(requestInstance.sourceProjectId instanceOf ID)
            ? (String.isBlank(requestInstance.sourceFolderId) || !(requestInstance.sourceFolderId instanceOf ID)
                ? [Select Id,
                            Name,                       
                            leankor__Portfolio__c, 
                            leankor__Portfolio__r.Name,
                            leankor__ProjectTemplate__c 
                        From leankor__ProjectRoom__c 
                        Where Name = :requestInstance.sourceProjectName And leankor__Portfolio__r.Name = :requestInstance.sourceFolderName 
                            And leankor__Portfolio__c != null 
                        With Security_Enforced
                        Order By CreatedDate Desc
                        Limit 1]
                : [Select Id,
                            Name,
                            leankor__Portfolio__c, 
                            leankor__Portfolio__r.Name,
                            leankor__ProjectTemplate__c 
                        From leankor__ProjectRoom__c 
                        Where Name = :requestInstance.sourceProjectName And leankor__Portfolio__c = :requestInstance.sourceFolderId 
                        With Security_Enforced
                        Order By CreatedDate Desc
                        Limit 1])
            : [Select Id,
                        Name,
                        leankor__Portfolio__c, 
                        leankor__Portfolio__r.Name,
                        leankor__ProjectTemplate__c 
                    From leankor__ProjectRoom__c 
                    Where Id = :requestInstance.sourceProjectId
                    With Security_Enforced];
    }

    
    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Read folder records.
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        List of leankor__Portfolio__c(Folder)
	------------------------------------------------------------*/
    private static List<leankor__Portfolio__c> readTargetFolder(CloneProjectRequest requestInstance) {
        return String.isBlank(requestInstance.targetFolderId) || !(requestInstance.targetFolderId instanceOf ID)
                ? [Select Id,
                            Name
                        From leankor__Portfolio__c 
                        Where Name = :requestInstance.targetFolderName
                        With Security_Enforced
                        Limit 1]
                : [Select Id,
                            Name
                        From leankor__Portfolio__c 
                        Where Id = :requestInstance.targetFolderId
                        With Security_Enforced];  
    }


     /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Preparing Board request to send for CloneProjectBoardBatch Batch class.
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        CloneProjectBoardBatch.CloneProjectBoardRequest
	------------------------------------------------------------*/
    private static CloneProjectBoardBatch.CloneProjectBoardRequest prepareBoardRequest(CloneProjectRequest requestInstance) {

        CloneProjectBoardBatch.CloneProjectBoardRequest request = new CloneProjectBoardBatch.CloneProjectBoardRequest();   
        
        Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;   
        request.firstDayOfWeek = firstDay == null || firstDay < 0  || firstDay > 6 ? 1 : firstDay.intValue();

        request.projectRoom = String.escapeSingleQuotes(requestInstance.targetProjectName);              
        request.expenses = requestInstance.expenses != null ? requestInstance.expenses : false;   
        request.isplancloned= (requestInstance.planGantt != null ? requestInstance.planGantt : false);
        request.cloneFiles= (requestInstance.cloneFiles != null ? requestInstance.cloneFiles : false);
        request.cloneCustomFields= (requestInstance.cloneCustomFields != null ? requestInstance.cloneCustomFields : false); 
        request.relinkClonedProjectId = requestInstance.relinkClonedProjectId;
        request.projectEventCustomPayload = requestInstance.projectEventCustomPayload;
        request.isCloneWithLaunchDate = requestInstance.targetLaunchDateTime != null || requestInstance.targetLaunchDate != null ? true : false;
        request.cardStickerVerb = requestInstance.cardStickerVerb != null ? requestInstance.cardStickerVerb : false;
        if (requestInstance.targetStartDate != null  || requestInstance.targetLaunchDate != null) {
            request.targetProjectStartDateTime = (requestInstance.targetStartDate != null) ? (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetStartDate),DateTime.class): (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetLaunchDate),DateTime.class);
            if (requestInstance.targetLaunchDate!=null) {
    		    request.targetLaunchDateTime = request.targetProjectStartDateTime;
        	}
        } else if (requestInstance.targetDueDate != null) {
           request.targetProjectDueDateTime = (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetDueDate),DateTime.class);  
        } else if (requestInstance.targetLaunchDateTime != null) {
            request.targetLaunchDateTime = requestInstance.targetLaunchDateTime;
            request.targetProjectStartDateTime = requestInstance.targetLaunchDateTime;
        } else if (requestInstance.targetProjectStartDateTime == null && requestInstance.targetProjectDueDateTime == null) {
            request.targetProjectStartDateTime = system.now(); 
        } else if (requestInstance.targetProjectStartDateTime!=null) {
            request.targetProjectStartDateTime = requestInstance.targetProjectStartDateTime;
        } else if (requestInstance.targetProjectDueDateTime!=null) {
            request.targetProjectDueDateTime = requestInstance.targetProjectDueDateTime;
        }      

        if (requestInstance.targetLaunchDateTime != null) {
            request.projectBoardLaunchDate = requestInstance.targetProjectStartDateTime;            	
        } else if (requestInstance.targetLaunchDate != null) {
            request.projectBoardLaunchDate = requestInstance.targetProjectStartDateTime;
        }
        
        request.cloneFiles = requestInstance.cloneFiles;
        request.cloneCustomFields = requestInstance.cloneCustomFields; 
        request.stickerVerb = requestInstance.cardStickerVerb;
        
        request.isExpense = requestInstance.expenses;
        request.sessionID = requestInstance.sessionID;
        request.kanbanVerb = true;
        request.TaskVerb = true;
        request.kanbanTemplateVerb = true;
        
        return request;
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Setting boards to clone for asynchronus process. 
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        void
	------------------------------------------------------------*/
    private static void setBoardTypesToClone(Set<String> asynchBoardTypes, Set<String> synchBoardTypes, Set<String> moduleBoardTypes, CloneProjectRequest requestInstance) {
        if (requestInstance.planGantt != null) {
            if  (requestInstance.planGantt) {
                synchBoardTypes.add('UberBoard');
                moduleBoardTypes.add('_System_UberBoard'); 
            }
        }   
        
        if (requestInstance.rollUp != null) {
            if(requestInstance.rollUp) {
                asynchBoardTypes.add('Plan Board');                       
                moduleBoardTypes.add('_System_PlanBoard');
            }
        } 
        
        if (requestInstance.projectBoard != null) {
            if  (requestInstance.projectBoard) {
                asynchBoardTypes.add('Kanban Board');
                moduleBoardTypes.add('_System_Board');
            }
        } 
        
        if (requestInstance.whiteBoard != null) {
            if  (requestInstance.whiteBoard) {
                asynchBoardTypes.add('Whiteboard');                           
                moduleBoardTypes.add('_System_Whiteboard');
            }
        } 
        
        if (requestInstance.dashBoard != null) {
            if  (requestInstance.dashBoard) {
                asynchBoardTypes.add('DashBoard');
                moduleBoardTypes.add('_System_DashBoard');
            }
        } 
        
        // TODO: This is to clone records of expenses
        if (requestInstance.expenses != null) {
            if  (requestInstance.expenses) {
                moduleBoardTypes.add(''); //   Expenses board type is nothing that's why its empty string 
            } 
        }
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    preparing data to create a new project.
	    Inputs:         Instance of CloneProjectRequest inner class.
	    Returns:        leankor__ProjectRoom__c
	------------------------------------------------------------*/
    public static leankor__ProjectRoom__c createProject(CloneProjectBoardBatch.CloneProjectBoardRequest request) {

        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        if (!projectRoomBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

    	Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, 5);
    	Map<String, Integer> nonWorkingDays = workWeek.readNonWorkingDays();
    	
		Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();   	
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
        
        Id sourceProjectId = request.projectRoomId;             	
		leankor__ProjectRoom__c pr = Database.query
				('Select' 
					+ (isMultiCurrency ? ' CurrencyIsoCode,' : '') 					
					+ ' leankor__ProjectManager__c,'
					+ ' leankor__AutoAssignResource__c,'
                 	+ 'leankor__isShowWeekCalendar__c'
					+ ' From leankor__ProjectRoom__c' 
					+ ' Where Id = :sourceProjectId'
					+ ' Limit 1');
        
        if (isMultiCurrency) {
        	project.put('CurrencyIsoCode', (String)pr.get('CurrencyIsoCode'));
        }
        

        project.Name = request.projectRoom; 
        project.leankor__ProjectManager__c = pr.leankor__ProjectManager__c;

        //clone AutoAssignResource field value as it is original project
        project.leankor__AutoAssignResource__c = pr.leankor__AutoAssignResource__c;
        project.leankor__ProjectTemplate__c = request.projectRoomId;
        Project.leankor__isShowWeekCalendar__c = pr.leankor__isShowWeekCalendar__c;

        //removing Time value 00:00:000, it was causing incorrect date value on UI
        if (String.isNotBlank(request.targetLaunchDate)) {    
        	project.leankor__ProjectLaunchDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(request.targetLaunchDate),DateTime.class);	
        } else if(request.targetLaunchDateTime != null) {
        	project.leankor__ProjectLaunchDateTime__c = request.targetLaunchDateTime;
        } 
             
        if (request.targetProjectStartDateTime != null) {
            Date tempProjectStartDate = Date.newInstance(request.targetProjectStartDateTime.yearGMT(), request.targetProjectStartDateTime.monthGMT(), request.targetProjectStartDateTime.dayGMT());
            
            if (!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE'))) {	
            	project.leankor__StartDate__c =Util.readNextWorkingDate(workWeek,tempProjectStartDate);
            } else {
                 project.leankor__StartDate__c = tempProjectStartDate;
            }
        }
        
        if (request.targetProjectDueDateTime != null) {
            Date tempProjectDueDate = Date.newInstance(request.targetProjectDueDateTime.yearGMT(), request.targetProjectDueDateTime.monthGMT(), request.targetProjectDueDateTime.dayGMT());        
            
            if (!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE'))) {
            	project.leankor__DueDate__c= Util.readPreviousWorkingDate(workWeek,tempProjectDueDate);                              
            } else {
            	project.leankor__DueDate__c = tempProjectDueDate;
            }
        }
        
        return project;
    }  


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    create a new Expenses reocrds.
	    Inputs:         Instance of CloneProjectRequest inner class and instance of leankor__ProjectRoom__c.
	    Returns:        void
	------------------------------------------------------------*/
    private static void cloneExpenses(CloneProjectBoardBatch.CloneProjectBoardRequest request, leankor__ProjectRoom__c projectRoom) {
        Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        // Cloning the ProjectFinancial Record on target Project while clone Project from UI.      
        Map<String, String> oldNewProjectFinancialIds = FinancialDataTableController.createProjectFinancial(request.projectRoomId, projectRoom.Id, request.cloneCustomFields);
        List<leankor__Expense__c> targetExpenses = new List<leankor__Expense__c>();
        List<leankor__Expense__c> sourceExpenses = FinancialDataTableController.readRecords(request.projectRoomId);
        Map<String, Schema.SObjectField> onlyCustomFields;
        if (request.cloneCustomFields == true) {
            onlyCustomFields = new DescribeSchema().getEligibleFieldsForCloning('leankor__Expense__c');
        }
        for (leankor__Expense__c sourceExpense : sourceExpenses) {
            leankor__Expense__c targetExpense = new leankor__Expense__c();

            targetExpense.put('leankor__Portfolio__c', projectRoom.leankor__Portfolio__c);  
            targetExpense.put('leankor__Project__c', projectRoom.Id);                                 
            targetExpense.put('leankor__OriginalPlannedExpense__c', (Id)sourceExpense.get('leankor__OriginalPlannedExpense__c')); 
            targetExpense.put('leankor__ApprovingManager__c', (Id)sourceExpense.get('leankor__ApprovingManager__c'));                                 
            targetExpense.put('leankor__ContactSubmittingExpense__c', (Id)sourceExpense.get('leankor__ContactSubmittingExpense__c'));  
            targetExpense.put('leankor__PersonSubmittingExpense__c', (Id)sourceExpense.get('leankor__PersonSubmittingExpense__c'));  
            targetExpense.put('RecordTypeId', (Id)sourceExpense.get('RecordTypeId'));     
            targetExpense.put('leankor__DeliveredProduct__c', (Id)sourceExpense.get('leankor__DeliveredProduct__c'));     
            targetExpense.put('leankor__PlannedExpense__c', (Id)sourceExpense.get('leankor__PlannedExpense__c'));        
            targetExpense.put('Name', (String)sourceExpense.get('Name'));                                
            targetExpense.put('leankor__LongDescription__c', (String)sourceExpense.get('leankor__LongDescription__c'));  
            targetExpense.put('leankor__ExpenseCode__c', (String)sourceExpense.get('leankor__ExpenseCode__c'));
            targetExpense.put('leankor__Category__c', (String)sourceExpense.get('leankor__Category__c'));   
            targetExpense.put('leankor__ExpenseSubCategory__c', (String)sourceExpense.get('leankor__ExpenseSubCategory__c')); 
            targetExpense.put('leankor__ExpenseAccount__c', (String)sourceExpense.get('leankor__ExpenseAccount__c')); 
            targetExpense.put('leankor__PaymentNotes__c', (String)sourceExpense.get('leankor__PaymentNotes__c')); 
            targetExpense.put('leankor__PaymentReceived__c', (Boolean)sourceExpense.get('leankor__PaymentReceived__c')); 
            targetExpense.put('leankor__IncludesTax__c', (Boolean)sourceExpense.get('leankor__IncludesTax__c'));      
            targetExpense.put('leankor__Reimbursable__c', (Boolean)sourceExpense.get('leankor__Reimbursable__c')); 
            targetExpense.put('leankor__IsCapEx__c',  (Boolean)sourceExpense.get('leankor__IsCapEx__c')); 
            targetExpense.put('leankor__Invoiced__c', (Boolean)sourceExpense.get('leankor__Invoiced__c')); 
            targetExpense.put('leankor__Plan__c', (Boolean)sourceExpense.get('leankor__Plan__c'));   
            targetExpense.put('leankor__IsForecast__c', (Boolean)sourceExpense.get('leankor__IsForecast__c'));   
            targetExpense.put('leankor__IsPrevForecast__c', (Boolean)sourceExpense.get('leankor__IsPrevForecast__c')); 
            targetExpense.put('leankor__IsCurrForecast__c', (Boolean)sourceExpense.get('leankor__IsCurrForecast__c')); 
            targetExpense.put('leankor__Chargeable__c', (Boolean)sourceExpense.get('leankor__Chargeable__c'));  
            targetExpense.put('leankor__Date__c', (Date)sourceExpense.get('leankor__Date__c'));                                 
            targetExpense.put('leankor__ForecastDate__c', (Date)sourceExpense.get('leankor__ForecastDate__c')); 
            targetExpense.put('leankor__ExpenseAmount__c', (Decimal)sourceExpense.get('leankor__ExpenseAmount__c'));                    
            targetExpense.put('leankor__ExpenseTemplate__c', (Id)sourceExpense.get('Id'));
            targetExpense.put('leankor__ExpenseAllocationHours__c', (Decimal)sourceExpense.get('leankor__ExpenseAllocationHours__c'));  
            targetExpense.put('leankor__ExpenseHours__c', (Decimal)sourceExpense.get('leankor__ExpenseHours__c'));                    
            targetExpense.put('leankor__ReferenceSourceId__c', sourceExpense.Id);
            
            if (isMultiCurrency) {
                targetExpense.put('CurrencyIsoCode', (String)sourceExpense.get('CurrencyIsoCode'));
            }
            //Cloning the expense record with ProjectFinancial Record on target Project.
            targetExpense.put('leankor__ProjectFinancial__c', sourceExpense.get('leankor__ProjectFinancial__c') != null ? oldNewProjectFinancialIds.get((String)sourceExpense.get('leankor__ProjectFinancial__c')) : '' );   
            targetExpense.put('leankor__Quantity__c', (Decimal)sourceExpense.get('leankor__Quantity__c')); 
            if (request.cloneCustomFields == true && onlyCustomFields != null && !onlyCustomFields.isEmpty()) {
                //  Now add only non-leankor custom fields dynamically
                for (String fieldName : onlyCustomFields.keySet()) {
                    if (sourceExpense.get(fieldName) != null) {
                        targetExpense.put(fieldName, sourceExpense.get(fieldName));
                    }
                }
            }
            targetExpenses.add(targetExpense);              
        }
                        
        insert targetExpenses;

        Map<Id, leankor__Expense__c> mapSourceExpenses = new Map<Id, leankor__Expense__c>(sourceExpenses);
        for (leankor__Expense__c targetExpense : targetExpenses) { 
            if (mapSourceExpenses.containsKey(targetExpense.leankor__ExpenseTemplate__c)) {                        
                Id relinkClonedExpense;
                
                if (mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__KanbanCard__c != null) {
                    // link KanbanCard
                    targetExpense.leankor__KanbanCard__c = mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__KanbanCard__c;
                    targetExpense.leankor__ProjectBoard__c = mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__ProjectBoard__c;
                    relinkClonedExpense = targetExpense.leankor__KanbanCard__c;                                                                               
                }
                                        
                if (String.isNotBlank(relinkClonedExpense)) {
                    List<leankor__Expense__c> listExpense = new List<leankor__Expense__c>();                      
                    if (request.relinkClonedExpenses.containsKey(relinkClonedExpense)) {   
                        listExpense = request.relinkClonedExpenses.get(relinkClonedExpense);
                    }

                    listExpense.add(targetExpense);
                    request.relinkClonedExpenses.put(relinkClonedExpense, listExpense); 
                }
            }
        } 
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Helper method to truncate the TargetBoard name if it exceeds 80 characters
	    Inputs:         String => new Board name.
	    Returns:        String
	------------------------------------------------------------*/
    public static String truncateTargetBoard(String targetBoard) {
        if (targetBoard.length() > 80) {
            return targetBoard.substring(0, 79) + ')';
        }
        return targetBoard;
    }


    // read all records of all project boards in a given project  
    public static List<leankor__ValueStream__c> readProjectBoards(Id projectRoomId, Set<String> boardTypes) {
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if(!valueStreamBehavior.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        return  [Select Id,
                    Name,
                    leankor__BoardType__c,
					leankor__ProjectRoom__r.Name,
					leankor__SevenDayWorkWeek__c,
                    leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c
                From leankor__ValueStream__c
                Where leankor__ProjectRoom__c =: projectRoomId 
					And leankor__BoardType__c In: boardTypes
                    And leankor__IsRecordDeleted__c = FALSE
                With Security_Enforced
                Order By leankor__BoardType__c, Name ];
    }
}