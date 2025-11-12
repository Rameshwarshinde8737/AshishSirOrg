/*---------------------------------------------------------------------------------------
* Copyright 2012-2016 Leankor All rights reserved
Author      :   RBO
Company     :   Leankor
Description :   An API class for cloning existing project          
Test Class  :   CloneProjectActionTest
---------------------------------------------------------------------------------------*/

global with sharing class CloneProjectAction implements Database.Batchable<sObject>, Database.Stateful {

    global cloneProjectAction(ApexPages.StandardController controller){}    
    global cloneProjectAction(){}         
    global cloneProjectAction(ApexPages.StandardSetController controller) {}     

    // Ramanand : 30/06/2021 - Changes : These variables used for async process to create remaining record for clone to decrease CPU time Limit..
    private List<leankor__KanbanCard__c > newKanbanCards = new List <leankor__KanbanCard__c> (); 
    private String valueStreamId;

    public static Boolean isClonedProject = false;
    public static Boolean isExpense = false;
	// 25/03/2022 - using this varibale to prevent "EndCloneBoard" platform event for async baords cloning while project cloning.
    public static Boolean isAsyncBoard = false;
    public static List<leankor__KanbanCard__c > newKanbanCardsStatic = new List <leankor__KanbanCard__c> (); 
    public static String valueStreamIdStatic;
    
    //Pratiksha : 22/09/2021 - These variable used for async process to clone KanbanCard's Sticker...
    private List <Id> kanbanCardIdsForSticker = new List <Id> ();
    private Map<String,String> mapWithOldKanbanCard = new Map<String,String>();
    public static List <Id> kanbanCardIdsForStickerStatic = new List <Id> ();
    public static Map<String,String> mapWithOldKanbanCardStatic = new Map<String,String>();
    
    //Pratiksha : 15/07/2021 - Fixes for Link the Project to portfolio id.
    private Boolean isCloneProjectBoard = false;
	//Ashutosh : 08/10/2021 : new variable is created for sticker cloning verb.
    private Boolean isCloneWithSticker = false;
 
    
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
			public Map<Id, List<leankor__Expense__c>> relinkClonedExpenses;			
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload;
        //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning.    
        @InvocableVariable(label='Clone KanbanCard Stickers' description='Set to true if Clone All Sticker on Face of KanbanCards')
            global Boolean cardStickerVerb; 
        
        global String targetStartDate;             
        global String targetDueDate;
        global String navigationVerb;  
        global boolean isplancloned;
        global String sessionID;  		
        public integer firstDayOfWeek;
        public boolean sevenDayWorkWeek;
        public String targetLaunchDate;
        // Ashutosh - 25/06/2021 - Variable added for verifing cloning is perform with Launch date or not
        public Boolean isCloneWithLaunchDate;
		public Integer totalNumberOfSourceProjectBoards;
    } 

    
    global class CloneProjectResult {
        @InvocableVariable(label='Cloned Project Id' description='The project id of the cloned project.')
            global String clonedProjectId;
        @InvocableVariable(label='Portfolio Hierarchy' description='The full Portfolio Hierarchy.')
            global List<String> portfolioHierarchy = new List<String>();
    }  
    

    // This is Invocable Method for Cloning Project by API call
    @InvocableMethod
    global static List<CloneProjectResult> cloneProjects(List<CloneProjectRequest> requests) {
        //No need to Check CRUD / FLC behavior, because internal method is also checking..
        List<CloneProjectResult> results = new List<CloneProjectResult>();
        for (CloneProjectRequest request : requests) {            
            results.add(cloneProject(request));
        }
        return results;
    }  


    // Method to clone the project
    @RemoteAction
    global static CloneProjectResult cloneProject(CloneProjectRequest request) {   
        // Added Security code for sentize user Input
        if((String.isNotBlank(request.sourceFolderId) && Util.getSObjectName(request.sourceFolderId) != 'leankor__Portfolio__c')
            || (String.isNotBlank(request.targetFolderId) && Util.getSObjectName(request.targetFolderId) != 'leankor__Portfolio__c')
            || (String.isNotBlank(request.sourceProjectId) && Util.getSObjectName(request.sourceProjectId) != 'leankor__ProjectRoom__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour project =  new ProjectRoomBehaviour();
        ExpenseBehaviour expense = new ExpenseBehaviour();
        ProjectLaunchBehavior pLaunch = new ProjectLaunchBehavior();
        PortfolioBehaviour portfolio = new PortfolioBehaviour();
        ValueStreamBehavior vStream = new ValueStreamBehavior();
        KanbanCardBehaviour card = new KanbanCardBehaviour();
        
        if (!portfolio.isAccessible() 
        || !expense.isAccessible() 
        || !expense.isCreateable()
        || !vStream.isAccessible()
        || !vStream.isUpdateable()
        || !project.isCreateable()
        || !pLaunch.isCreateable()
        || !card.isUpdateable())
        {
            throw new Util.LeanException('Error: No access to records');
        }       
        
        CloneProjectResult result = new CloneProjectResult();
		Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;   
		request.firstDayOfWeek = (firstDay == null || firstDay < 0  || firstDay > 6 )? 1 : firstDay.intValue();
        
        // re-define values
        request.targetProjectName = String.escapeSingleQuotes(request.targetProjectName);              
        request.planGantt = request.planGantt != null ? request.planGantt : false;
        request.rollUp = request.rollUp != null ? request.rollUp : false;
        request.projectBoard = request.projectBoard != null ? request.projectBoard : false;
        request.whiteBoard = request.whiteBoard != null ? request.whiteBoard : false;
        request.dashBoard = request.dashBoard != null ? request.dashBoard : false;
        request.expenses = request.expenses != null ? request.expenses : false;
        request.returnPortfolioHierarchy = request.returnPortfolioHierarchy != null ? request.returnPortfolioHierarchy : false;    
        request.isplancloned= (request.planGantt != null ? request.planGantt : false);
        request.cloneFiles= (request.cloneFiles != null ? request.cloneFiles : false);
        //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning. 
        request.cardStickerVerb =(request.cardStickerVerb != null ? request.cardStickerVerb : false);
        
        // TargetLaunchDate becomes start date
        if (request.targetStartDate != null  || request.targetLaunchDate != null) {
            request.targetProjectStartDateTime = (request.targetStartDate != null) 
                    ? (DateTime)JSON.deserialize(JSON.serialize(request.targetStartDate),DateTime.class)
                    : (DateTime)JSON.deserialize(JSON.serialize(request.targetLaunchDate),DateTime.class);
        } else if (request.targetDueDate != null) {
            request.targetProjectDueDateTime = (DateTime)JSON.deserialize(JSON.serialize(request.targetDueDate),DateTime.class);  
        } else if (request.targetLaunchDateTime != null) {
            // Target launch date becomes the Start Date
            request.targetProjectStartDateTime = request.targetLaunchDateTime;
        } else if (request.targetProjectStartDateTime == null && request.targetProjectDueDateTime == null) {
            request.targetProjectStartDateTime = system.now(); 
        }       
     
        // Date: 19/06/2019  - Making time portion to 00:00:00
        //Ashutosh:10/05/2021 - comment below code for this code remove timePortion from the date
        // if(request.targetProjectStartDateTime != null){
        // 	request.targetProjectStartDateTime = (request.targetProjectStartDateTime).dateGMT();
        // }
        
        // start validate inputs    
        if (String.isBlank(request.targetProjectName)) {
            throw new CloneProjectActionException('You must specify the "Target Project Name".');
        }  
        
        // Instance to add boards to be cloned syncronously or asyncronously
        Set<String> synchBoardTypes = new Set<String>();   
        Set<String> asynchBoardTypes = new Set<String>();  
        Set<String> moduleBoardTypes = new Set<String>();   
        
        if (request.planGantt) {
            synchBoardTypes.add('UberBoard');
            moduleBoardTypes.add('_System_UberBoard');
        }   
        
        if (request.rollUp) {
            asynchBoardTypes.add('Plan Board');                       
            moduleBoardTypes.add('_System_PlanBoard');
        } 
        
        if (request.projectBoard) {
            asynchBoardTypes.add('Kanban Board');
            moduleBoardTypes.add('_System_Board');
        } 
        
        if (request.whiteBoard) {
            asynchBoardTypes.add('Whiteboard');                           
            moduleBoardTypes.add('_System_Whiteboard');
        } 
        
        if (request.dashBoard) {
            asynchBoardTypes.add('DashBoard');
            moduleBoardTypes.add('_System_DashBoard');
        } 
        
        // TODO: This is to clone records of expenses
        if (request.expenses) {
            moduleBoardTypes.add(''); //   Expenses board type is nothing that's why its empty string   
        }
        
        if (synchBoardTypes.isEmpty() && asynchBoardTypes.isEmpty() && !request.expenses) {
            throw new CloneProjectActionException('You must specify at least one Project item to clone.');
        }  
        
        // Get the Target folder
        List<leankor__Portfolio__c> targetFolder = getTargetFolder(request);  
        if (targetFolder.isEmpty()) {
            throw new CloneProjectActionException('You must specify a valid "Target Folder Id" or "Target Folder Name".');
        } 
        
        // Get the Source Project
        List<leankor__ProjectRoom__c> sourceProject = getSourceProject(request);
        if (sourceProject.isEmpty()) {
            throw new CloneProjectActionException('You must specify a valid "Source Project Id" or "Source Folder Name and Source Project Name" or "Source Folder Id and Source Project Name".');
        }
        
        // Update the parameter values
        request.targetFolderId = targetFolder[0].Id;
        request.targetFolderName = targetFolder[0].Name;
        request.sourceFolderId = sourceProject[0].leankor__Portfolio__c;
        request.sourceFolderName = sourceProject[0].leankor__Portfolio__r.Name;
        request.sourceProjectId = sourceProject[0].Id;
        request.sourceProjectName = sourceProject[0].Name; 
        
        // Read records to clone
        List<leankor__ProjectLaunchBehavior__c> cloneProjectSetup = readProjectSetup(request.sourceProjectId, moduleBoardTypes);
        List<leankor__ValueStream__c> synchCloneProjectBoards = synchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : readProjectBoards(request.sourceProjectId, synchBoardTypes);        
        List<leankor__ValueStream__c> asynchCloneProjectBoards = asynchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : readProjectBoards(request.sourceProjectId, asynchBoardTypes);
        
        // rbo 11.29.16 
        List<String> projectBoardTypes = new List<String>(asynchBoardTypes); 

		// Ramanand : 28/06/2021 - Changes : Preventing broad cast for everytime board clone, EndClone platform event will fire after every board cloned.
        Integer totalCardsOfProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : readProjectCardCount(request.sourceProjectId, asynchBoardTypes);
		Integer totalNumberOfSourceProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : CloneProjectAction.readProjectBoards(request.sourceProjectId, asynchBoardTypes).size();
        
        // rbo 11.28.16
        leankor__ProjectRoom__c projectRoom = createProject(request);                                    
        
        // set savepoint to rollback if there is an exception
        Savepoint sp = Database.setSavepoint();
        try
        {           
            insert projectRoom;     
            
            request.relinkClonedProjectId = projectRoom.Id;
                            
            insert createProjectSetup(projectRoom.Id, cloneProjectSetup); 
                        
            // Clone records from sources project expenses          
 			request.relinkClonedExpenses = new Map<Id, List<leankor__Expense__c>>(); 
            if (request.expenses)
            {
 				Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
                //16/Aug/2023 cloning the ProjectFinancial Record on target Project while clone Project from UI.
 				Map<String, String> oldNewProjectFinancialIds = FinancialDataTableController.createProjectFinancial(request.sourceProjectId, projectRoom.Id, request.cloneCustomFields); 
                
                List<leankor__Expense__c> targetExpenses = new List<leankor__Expense__c>();
                List<leankor__Expense__c> sourceExpenses = FinancialDataTableController.readRecords(request.sourceProjectId);
                Map<String, Schema.SObjectField> onlyCustomFields;
                if (request.cloneCustomFields == true) {
                    onlyCustomFields = new DescribeSchema().getEligibleFieldsForCloning('leankor__Expense__c');
                }            
				for (leankor__Expense__c sourceExpense : sourceExpenses) {
					leankor__Expense__c targetExpense = new leankor__Expense__c();
        
					targetExpense.put('leankor__Project__c', projectRoom.Id);                                 
					targetExpense.put('leankor__OriginalPlannedExpense__c', (Id)sourceExpense.get('leankor__OriginalPlannedExpense__c')); 
					targetExpense.put('leankor__ApprovingManager__c', (Id)sourceExpense.get('leankor__ApprovingManager__c'));                                 
					targetExpense.put('leankor__ContactSubmittingExpense__c', (Id)sourceExpense.get('leankor__ContactSubmittingExpense__c'));  
					targetExpense.put('leankor__PersonSubmittingExpense__c', (Id)sourceExpense.get('leankor__PersonSubmittingExpense__c'));  
					targetExpense.put('RecordTypeId', (Id)sourceExpense.get('RecordTypeId'));     
					targetExpense.put('leankor__DeliveredProduct__c', (Id)sourceExpense.get('leankor__DeliveredProduct__c')); 
					//targetExpense.put('leankor__KanbanCard__c', (Id)sourceExpense.get('leankor__KanbanCard__c')); 
					//targetExpense.put('leankor__ProjectBoard__c', (Id)sourceExpense.get('leankor__ProjectBoard__c'));     
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

                    //16/Aug/2023 cloning the expense record with ProjectFinancial Record on target Project.
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
                                                				
				// BEGIN: Expense records to relink
				//request.relinkClonedExpenses = new Map<Id, List<leankor__Expense__c>>();

                Map<Id, leankor__Expense__c> mapSourceExpenses = new Map<Id, leankor__Expense__c>(sourceExpenses);
				for (leankor__Expense__c targetExpense : targetExpenses) {	
					if (mapSourceExpenses.containsKey(targetExpense.leankor__ExpenseTemplate__c)) {						
						Id relinkClonedExpense;
						
						if (mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__KanbanCard__c != null) {
							// link KanbanCard
							targetExpense.leankor__KanbanCard__c = mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__KanbanCard__c;
							targetExpense.leankor__ProjectBoard__c = mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__ProjectBoard__c;
					        
					        relinkClonedExpense = targetExpense.leankor__KanbanCard__c;					        							
						/* needs more logic to link a ValueStream
						} else {							
							if (mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__ProjectBoard__c != null) {
								// link ValueStream
								targetExpense.leankor__ProjectBoard__c = mapSourceExpenses.get(targetExpense.leankor__ExpenseTemplate__c).leankor__ProjectBoard__c;
								relinkClonedExpense = targetExpense.leankor__ProjectBoard__c;
							}
						*/							
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
				// END: Expense records to relink
            }
            // clone the Uberboard and Planboard by directly calling the CloneProjectBoard API (Synchronous call)
            // this is to make sure that these two boards are always created
            // currently there is only 1 Uberboard and 1 Planboard in a project, so this should not hit the SOQL 101
            for (leankor__ValueStream__c synchCloneProjectBoard : synchCloneProjectBoards)
            {           
                // 02.12.16 we have changed input parameter string to leankor__valuestream__c for using boardtype and name  
                createProjectBoard(request, synchCloneProjectBoard);
            } 
            
            request.projectBoardTypes = new List<String>();
            request.projectBoardTypes.addAll(asynchBoardTypes);
            request.totalCardsOfSourceProjectBoards = totalCardsOfProjectBoards;
			// Ramanand : 28/06/2021 - Changes : Preventing broad cast for everytime board clone, EndClone platform event will fire after every board cloned.
			request.totalNumberOfSourceProjectBoards = totalNumberOfSourceProjectBoards;
                                
            // clone the Kanban Boards, Whiteboards and Dashboards using Flow that calls the CloneProjectBoard API (Asynchronous call)
            // this is a workaround to reset SOQL 101             
            for (leankor__ValueStream__c asynchCloneProjectBoard : asynchCloneProjectBoards) {       
                request.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;
                // Tilak: 01.07.2020
                //asynchCreateProjectBoard(JSON.serialize(request), JSON.serialize(asynchCloneProjectBoard));   

                CloneProjectAction cloneProjectrequest = new CloneProjectAction(request, asynchCloneProjectBoard);
                Database.executeBatch(cloneProjectrequest);
            }

            //25/03/2021 - when cloning only planGantt board (synchronous Board) then EndClone ProjectEvent broadcast should be publish.
            If(asynchCloneProjectBoards.size()==0)
            {    
				//Ramanand : 11/Sep/2023 - Changes : Changing ProjectEvent structure now will publish EndClone ProjectEvent from isBroadcast method. 
                /*//------------------- BEGIN platform event broadcast
				leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
                
				pe.leankor__EventCategory__c = 'Cloning';
				pe.leankor__EventName__c = 'EndClone';
				pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
				pe.leankor__ProjectID__c = request.relinkClonedProjectId;
				pe.leankor__UserID__c = UserInfo.getUserId();
				pe.leankor__CustomPayload__c = request.projectEventCustomPayload;
		
				// Call method to publish events
				Database.SaveResult pe_result = EventBus.publish(pe);
		
				// quick error processing, no need to Rollback
				if (!pe_result.isSuccess()){
					for(Database.Error err : pe_result.getErrors()) {
						System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
					}
				}         
				//------------------- END platform event broadcast  */ 

                isBroadcast(request);
            }               
            result.clonedProjectId = projectRoom.Id;
                
            if (request.returnPortfolioHierarchy)
            { 
                leankor.ProjectBoardCarousel.PortfolioHierarchy Port = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
                Port.ID = projectRoom.Id;
                Port.Name = projectRoom.Name;
                Port.ParentPortfolio = projectRoom.leankor__Portfolio__c;
                Port.RoomType = 'Room';             
                Port.DueDate = String.valueof(projectRoom.leankor__DueDate__c);
                result.portfolioHierarchy.add(JSON.serialize(Port));
            }                       
        }
        catch(exception ex)
        {
            Database.rollback(sp);
            unlinkProject(request.relinkClonedProjectId, asynchBoardTypes);
            
            throw new CloneProjectActionException(ex.getMessage());
        }   
        
        return result;
    }
    
	// removes links of all cards
	// to be called when exception is encountered during cloning
    public static void unlinkProject(String clonedProjectId, Set<String> boardTypes) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !KanbanCardBehaviour.isAccessible() ||
            !KanbanCardBehaviour.isUpdateable()
        ) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        if (String.isNotBlank(clonedProjectId))
        {	        
	        List<leankor__KanbanCard__c> newKanbanCards = new List<leankor__KanbanCard__c>();

	        for (leankor__KanbanCard__c newKanbanCard : [Select Id,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ValueStreamCardLink__c                        
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__r.leankor__ProjectRoom__c = :clonedProjectId
                                                                And leankor__ValueStream__r.leankor__BoardType__c In :boardTypes
                                                            With Security_Enforced
                                                            Limit 10000]) {   
				if(newKanbanCard.leankor__ValueStreamLink__c != null || newKanbanCard.leankor__ValueStreamCardLink__c != null) {
					newKanbanCard.leankor__ValueStreamCardLink__c = null;
					newKanbanCard.leankor__ValueStreamLink__c = null;
					newKanbanCards.add(newKanbanCard);
				}
	        }        	                  
    
			if (!newKanbanCards.isEmpty())
				update newKanbanCards;
        }
    }
    
    public static void isBroadcast(CloneProjectRequest request){
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (
           !projectRoomBehaviour.isAccessible() || 
           !projectRoomBehaviour.isUpdateable() ||
           !expenseBehaviour.isAccessible() || 
           !expenseBehaviour.isUpdateable()  
        ) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ProjectRoom__c> createdProjects = [Select Id,
                                                                leankor__Portfolio__c
                                                            From leankor__ProjectRoom__c
                                                            Where Id =: request.relinkClonedProjectId
                                                                And leankor__Portfolio__c =:request.targetFolderId
                                                            With Security_Enforced
                                                            Limit 1];
        // Making sure this code will execute once.
        if(createdProjects.isEmpty()) {
            //updating projectroom parent portfolio ID 
            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
            project.leankor__Portfolio__c = request.targetFolderId;
            project.Id = request.relinkClonedProjectId;    
            
            try {
                update project;        
            
                //updating parent portfolio id in expence records
                // due to field filter validation on projectroom field in Expense 
                List<leankor__Expense__c> expenseList = new List<leankor__Expense__c>();
                for (leankor__Expense__c ex : [Select leankor__Portfolio__c 
                                                From leankor__Expense__c 
                                                Where leankor__Project__c = :request.relinkClonedProjectId
                                                With Security_Enforced]) {           
                    ex.leankor__Portfolio__c = request.targetFolderId;
                    expenseList.add(ex);                        
                }
            
                if(expenseList.size()>0){
                    update expenseList;
                }
            
                // this method is calling for broadcast
                //List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(getMaxDateOfBoard(request.relinkClonedProjectId));
                //portfolioresult[0].verb = 'CloneProject';
                //leankor.realtimeKanbanController.manageNavChange('LeankorNAV',JSON.serialize(portfolioresult[0]),request.sessionID);             
                /*
                //------------------- BEGIN platform event broadcast
                leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
                
                pe.leankor__EventCategory__c = 'Cloning';
                pe.leankor__EventName__c = 'EndClone';
                pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                pe.leankor__ProjectID__c = request.relinkClonedProjectId;
                pe.leankor__UserID__c = UserInfo.getUserId();
                pe.leankor__CustomPayload__c = request.projectEventCustomPayload;
        
                // Call method to publish events
                Database.SaveResult pe_result = EventBus.publish(pe);
        
                // quick error processing, no need to Rollback
                //if (pe_result.isSuccess() == false){
                if (!pe_result.isSuccess()){
                    for(Database.Error err : pe_result.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }         
                //------------------- END platform event broadcast                      
                */
            } catch(DMLException ex){
                throw new CloneProjectActionException(ex.getMessage());
            }           
            //Ramanand : 11/Sep/2023 - Changes : Changing ProjectEvent structure now will publish EndClone ProjectEvent from isBroadcast method. 
            try {
                //------------------- BEGIN platform event broadcast
                leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
                
                pe.leankor__EventCategory__c = 'Cloning';
                pe.leankor__EventName__c = 'EndClone';
                pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                pe.leankor__ProjectID__c = request.relinkClonedProjectId;
                pe.leankor__UserID__c = UserInfo.getUserId();
                pe.leankor__CustomPayload__c = request.projectEventCustomPayload;
        
                // Call method to publish events
                Database.SaveResult pe_result = EventBus.publish(pe);
        
                // quick error processing, no need to Rollback
                //if (pe_result.isSuccess() == false){
                if (!pe_result.isSuccess()){
                    for(Database.Error err : pe_result.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }         
                //------------------- END platform event broadcast  
                // this method is calling for broadcast
                List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(getMaxDateOfBoard(request.relinkClonedProjectId));
                portfolioresult[0].verb = 'CloneProject';
                leankor.realtimeKanbanController.manageNavChange('LeankorNAV',JSON.serialize(portfolioresult[0]),request.sessionID);   
            } catch(Exception ex){
                System.debug('ERROR :: '+ex.getMessage());
            } 
        }
    }   
    
    public static CloneProjectResult relinkClonedProject(CloneProjectRequest request) {
        CloneProjectResult result = new CloneProjectResult();
        
        if (request.relinkClonedProjectId instanceOf ID && !request.projectBoardTypes.isEmpty())
        {           
            Set<String> asynchBoardTypes = new Set<String>(request.projectBoardTypes);          

            // Ramanand : 28/06/2021 - Changes : Preventing broad cast for everytime board clone, EndClone platform event will fire after every board cloned.
            if (request.totalCardsOfSourceProjectBoards == readProjectCardCount(request.relinkClonedProjectId, asynchBoardTypes)
                    && request.totalNumberOfSourceProjectBoards == readProjectBoards(request.relinkClonedProjectId, asynchBoardTypes).size())   
            {   
                // set savepoint to rollback if there is an exception
                Savepoint sp = Database.setSavepoint();
                try
                {  
                    List<sObject> updateLinkObjects = new List<sObject>();
                   
                    updateLinkObjects = reLinkProject(request);
                    
          
                        result.clonedProjectId = request.relinkClonedProjectId;
                        
                        isBroadcast(request);
                        
                        /*
                        //updating projectroom parent portfolio ID 
                        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
                        project.leankor__Portfolio__c = request.targetFolderId;
                        project.Id = request.relinkClonedProjectId;         
                        update project;
                        
                        //updating parent portfolio id in expence records
                        // due to field filter validation on projectroom field in Expense 
                        List<leankor__Expense__c> expenceList = new List<leankor__Expense__c>();
                        for(leankor__Expense__c ex : [Select leankor__Portfolio__c From leankor__Expense__c Where leankor__Project__c = :request.relinkClonedProjectId]){           
                            ex.leankor__Portfolio__c = request.targetFolderId;
                            expenceList.add(ex);                        
                    }
                    
                        if(expenceList.size()>0){
                            update expenceList;
                        }
                        //
                                    
                        //this method is calling for broadcast.
                        List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(getMaxDateOfBoard(request.relinkClonedProjectId));
                        portfolioresult[0].verb = 'CloneProject';
                        leankor.realtimeKanbanController.manageNavChange('LeankorNAV',JSON.serialize(portfolioresult[0]),request.sessionID);
                        */
                    //}
                    
                }
                catch(exception ex)
                {
                    Database.rollback(sp);
                    throw new CloneProjectActionException(ex.getMessage());
                }
            }           
        }
        else
        {       
            throw new CloneProjectActionException('You must specify a valid "Relink cloned project id".');
        }

        return result;
    }


    // Clone Project Board API
    // 02.12.16 change input string to leankor__valuestream__c type for new project board name 
    public static void createProjectBoard(CloneProjectRequest request, leankor__ValueStream__c board) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            return;
        }
        //Check CRUD / FLC behavior
        
        //RS 2.5.2018 Changes for FirstDayOfTheWeek    	          	
    	Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, 5);
    	
        // Ashutosh : 07/10/2021 : getting blackout of source project for calculating initial date.
        List<leankor__ProjectScheduleBlackout__c> sourceblackOut = [Select leankor__EndDate__c,                                                                         
                                                                            leankor__StartDate__c
                                                                        From leankor__ProjectScheduleBlackout__c
                                                                        Where leankor__ProjectBoard__c =: board.Id
                                                                        With Security_Enforced
                                                                        Limit 9999 ];
		//Ashutosh : 07/10/2021 : Dynamic value of workWeek is added.
        Util.WorkWeek workWeekwithBlackout = new Util.WorkWeek(request.firstDayOfWeek, board.leankor__SevenDayWorkWeek__c == true ? 7 : 5, sourceblackOut);
        Integer addDays = 0;

        List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestBoards = new List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
        leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestBoard = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
        
        requestBoard.FolderName = request.sourceFolderName;
        requestBoard.ProjectRoom = request.sourceProjectName;
        requestBoard.ProjectBoard = board.Name;
        requestBoard.ProjectBoardId = board.Id;
        requestBoard.TargetFolderName = request.targetFolderName;
        requestBoard.TargetRoom = request.targetProjectName;   
        requestBoard.ProjectRoomId = request.sourceProjectId;
        requestBoard.TargetRoomId = request.relinkClonedProjectId;   
        
        
        if(board.leankor__BoardType__c == 'UberBoard')// 02.12.16update target board name with new project name 
        {
           requestBoard.TargetBoard = 'Plan Board' +'('+requestBoard.TargetRoom+')';
           //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
            if(requestBoard.TargetBoard.length() > 80)
            {         
                 requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
                 requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
        }
            //  
        }
        /*else
        {
           requestBoard.TargetBoard = 'Roll-Up' +'('+requestBoard.TargetRoom+')';
        }
        */ 
        //comment this code because previous version roll up board as synchronous but new version we have changed synchronous to asynchronous
        
        //requestBoard.TargetBoard = boardName;
        //requestBoard.TargetDate = request.targetProjectDueDateTime;  // to be replaced with the card on board that has max due date?
        //requestBoard.initialDate = request.targetProjectStartDateTime;  // to be replaced with the card on board that has min start date?        
        
           
        if(request.targetProjectStartDateTime != null){
        	//Date: 17/06/2019 - Changes for clone the plan gantt according to project launch date.
        	if(request.targetLaunchDateTime != null || request.targetLaunchDate != null){
				AggregateResult[] minStartDate = [Select Min(leankor__StartDateTime__c) minimumDate 
														From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :board.Id 
                                                            And leankor__IsRecordDeleted__c = FALSE 
                                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
                                                        With Security_Enforced];
		        if(minStartDate[0].get('minimumDate') != null){    	
			    	DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
			    	//Add number of days to StartDate to maintain difference with ProjectLaunchDate              
		        	if(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c!=null){
	        			// //Ashutosh : 05/11/2021 : workWeekwithBlackout.getBusinessDays method will work for both 5 and 7 day workweek.
                        addDays = workWeekwithBlackout.getBusinessDays(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c.dateGMT(), minimumStartDate.dateGMT());
                        if (board.leankor__SevenDayWorkWeek__c == true) {
                            request.targetProjectStartDateTime = addDays != 0 ? request.targetProjectStartDateTime + addDays : minimumStartDate.dateGMT();
                        }else {
                            // Ashutosh : 05/11/2021 : for fiveday Workweek we are using custom getBusinessDays method.
                            request.targetProjectStartDateTime = addDays != 0 ? workWeekwithBlackout.nextBusinessDate(request.targetProjectStartDateTime, addDays) : minimumStartDate.dateGmt();
                        }
		        	}
	        	}
	        }
        
            if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE')) && board.leankor__SevenDayWorkWeek__c == false){
                requestBoard.initialDate = addDays < 0 && request.IsCloneWithLaunchDate && board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c > request.targetProjectStartDateTime ? request.targetProjectStartDateTime-1 :request.targetProjectStartDateTime+1;
                if(!workWeek.isWorkingDay(requestBoard.initialDate.formatGMT('EEEE'))){
                    requestBoard.initialDate = addDays < 0 && request.IsCloneWithLaunchDate && board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c > request.targetProjectStartDateTime ? request.targetProjectStartDateTime-1 :request.targetProjectStartDateTime+1;
            }
            }else{
				requestBoard.initialDate = request.targetProjectStartDateTime;
        }       
            //RS 2.5.2018
        }       
        if(request.targetProjectDueDateTime != null)
        {
		    //RS 2.5.2018 Commented static code             
           /*
            if(request.targetProjectDueDateTime.format('E') == 'Sat' && board.leankor__SevenDayWorkWeek__c == false)
            {
               requestBoard.TargetDate = request.targetProjectDueDateTime-1;
            }else if(request.targetProjectDueDateTime.format('E') == 'Sun' && board.leankor__SevenDayWorkWeek__c == false)
            {
               requestBoard.TargetDate = request.targetProjectDueDateTime-2;
            }else
            {
               requestBoard.TargetDate = request.targetProjectDueDateTime;
            }*/
            //RS 2.5.2018 Changes for FirstDayOfTheWeek
            if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE')) && board.leankor__SevenDayWorkWeek__c == false){
            	 requestBoard.TargetDate = request.targetProjectDueDateTime-1;
                 if(!workWeek.isWorkingDay(requestBoard.TargetDate.formatGMT('EEEE'))){
            	 requestBoard.TargetDate = requestBoard.TargetDate-1;            	 
            }
            }else{
            	 requestBoard.TargetDate = request.targetProjectDueDateTime;
        }               
            //RS 2.5.2018 
        }               
        requestBoard.checkCloneProject = 'StopOriginalkanbanCardUpdate';
        requestBoard.isplancloned = request.isplancloned ;
        requestBoard.cloneFiles = request.cloneFiles;
       	requestBoard.cloneCustomFields = request.cloneCustomFields;
        //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning. 
        requestBoard.stickerVerb = request.cardStickerVerb;
        requestBoards.add(requestBoard);
        CloneProjectAction.isClonedProject = true; 
        CloneProjectAction.isExpense = request.expenses;          
                 
        leankor.CloneProjectBoardAction.CloneProjectBoard(requestBoards);  
        //29/09/2021 : Changes for Async Sticker cloning.
		CloneProjectRemainingRecord.cloneCardsSticker(CloneProjectAction.kanbanCardIdsForStickerStatic, CloneProjectAction.mapWithOldKanbanCardStatic);
    }

    
    private leankor__ValueStream__c projectBoard;
    private CloneProjectRequest cloneProjectRequest; 

    public CloneProjectAction(CloneProjectRequest cloneProjectRequest, leankor__ValueStream__c projectBoard) {
        this.cloneProjectRequest = cloneProjectRequest;
        this.projectBoard = projectBoard;
    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID FROM leankor__KanbanCard__c LIMIT 5';
        return Database.getQueryLocator(query);
    }

    public void finish(Database.BatchableContext BC){ 
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
       
        //25/03/2021 - Preparing Project Event data for EndCloneBoard that we publish in another batch.
        leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
        if(isCloneProjectBoard == true){
            /*if(String.isNotBlank(valueStreamId)){
                valueStream = [Select Id, leankor__ProjectRoom__c 
                                        From leankor__ValueStream__c 
                                        Where Id =: valueStreamId
                                            And leankor__IsRecordDeleted__c = false];

                pe.leankor__EventCategory__c = 'Cloning';
                pe.leankor__EventName__c = 'EndCloneBoard';
                pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                pe.leankor__ProjectID__c = valueStream.leankor__ProjectRoom__c;//{Project Id, force.com ID, of the target board};
                pe.leankor__UserID__c = UserInfo.getUserId();
                pe.leankor__JSONPayload__c = JSON.serialize(new List<String>{valueStream.Id});//{JSON List<string> of board ids}   ---> target ValueStream force.com Ids 
                pe.leankor__CustomPayload__c = this.cloneProjectRequest.projectEventCustomPayload;
                                                        
            }*/

            //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in another try/Catch block.
            try{
                if(String.isNotBlank(valueStreamId)){
                    //Ramanand : 30/06/2021 - Changes : Here we will create remaining record for clone project by using another process to decreate CPU time Limit.
            		CloneProjectRemainingRecord cloneRemainingRecordrequest = new CloneProjectRemainingRecord(newKanbanCards, valueStreamId, kanbanCardIdsForSticker, mapWithOldKanbanCard, isCloneWithSticker, pe, this.cloneProjectRequest);
            		Database.executeBatch(cloneRemainingRecordrequest);
                    
                    valueStream = [Select Id, 
                                            leankor__ProjectRoom__c 
                                        From leankor__ValueStream__c 
                                        Where Id =:valueStreamId
                                            And leankor__IsRecordDeleted__c = false
                                        With Security_Enforced];

                    pe.leankor__EventCategory__c = 'Cloning';
                    pe.leankor__EventName__c = 'EndCloneBoard';
                    pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                    pe.leankor__ProjectID__c = valueStream.leankor__ProjectRoom__c;//{Project Id, force.com ID, of the target board};
                    pe.leankor__UserID__c = UserInfo.getUserId();
                    pe.leankor__JSONPayload__c = JSON.serialize(new List<String>{valueStream.Id});//{JSON List<string> of board ids}   ---> target ValueStream force.com Ids 
                    pe.leankor__CustomPayload__c = this.cloneProjectRequest.projectEventCustomPayload;
                    
                    Database.SaveResult pe_result = EventBus.publish(pe);
                
                    // quick error processing, no need to Rollback
                    if (!pe_result.isSuccess()){
                        for(Database.Error err : pe_result.getErrors()) {
                            System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        }
                        // continue on because a failed platform event is no big deal ; do NOT rollback
                    }
                      
                }
                
            }catch(Exception ex){
                System.debug('ERROR :: '+ex.getMessage());
            }
            relinkClonedProject(this.cloneProjectRequest);
        }
    }

    // asynchCreateProjectBoard
    global void execute(Database.BatchableContext context, List<SObject> records){
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        if(!projectRoomBehaviour.isAccessible()){
            System.abortJob(context.getJobId());
        }
        //Check CRUD / FLC behavior

        leankor__ValueStream__c asynchboard = this.projectBoard; 
        CloneProjectRequest request = this.cloneProjectRequest;      	          	
    	Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, request.sevenDayWorkWeek ? 7 : 5);    	                                  
        leankor__ProjectRoom__c pr = new leankor__ProjectRoom__c();                                 
        
        // Ramanand : 08/07/2021 - Changes : we no need to lock this code anymore we are encountering exception with this code "Record Currently Unavailable".
        // EPLB: this should cause all other concurrent instances to block waiting for this process to complete. If more than 10 seconds passes, an exception occurs and we try again 2 more times.
		// SS 14.08.2018 : Changed loop size from 12 to 36 to increase number of attempts for getting lock over record
		// For each attempt 10 sec. Now, max cloning time is 6 minutes
		/*for (Integer ndx = 0; ndx < 36; ndx++){
            try {
                pr = [SELECT Id FROM leankor__ProjectRoom__c WHERE Id =: request.relinkClonedProjectId limit 1 FOR UPDATE];
                break;
            } catch(Exception ex) {
                System.debug('Exception trying to get exclusive lock on Project ['+ request.relinkClonedProjectId  + ']. Will retry a few times. Error text: ' + ex);                
				if (ndx >= 35){                    
                    // rbo 05.24.17 throw exception to be passed to the calling method so it can handle the exception
                    throw new CloneProjectActionException(ex.getMessage());
                }
            }
        }*/
        
        try {                
            List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestBoards = new List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
            leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestBoard = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();       
            requestBoard.FolderName = request.sourceFolderName;
            requestBoard.ProjectRoom = request.sourceProjectName;        
            requestBoard.ProjectBoard = asynchboard.Name;
            requestBoard.ProjectBoardId = asynchboard.Id;
            requestBoard.TargetFolderName = request.targetFolderName;
            requestBoard.TargetRoom = request.targetProjectName;       
            requestBoard.ProjectRoomId = request.sourceProjectId;
            requestBoard.TargetRoomId = request.relinkClonedProjectId;        

            if (request.targetLaunchDateTime != null) {
            	requestBoard.projectBoardLaunchDate = request.targetProjectStartDateTime;            	
            } else if (request.targetLaunchDate != null) {
            	requestBoard.projectBoardLaunchDate = request.targetProjectStartDateTime;
            }
            
            // YJ - 09.01.17 checking plan board for board name because we was not updating board name with new project name
            if (asynchboard.leankor__BoardType__c == 'Plan Board') {                                                               
                requestBoard.TargetBoard = 'Roll-Up' +'('+requestBoard.TargetRoom+')';
                //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                if (requestBoard.TargetBoard.length() > 80) {         
                     requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
                     requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
                }
            } else if(asynchboard.leankor__BoardType__c == 'DashBoard' && asynchboard.Name ==  asynchboard.leankor__ProjectRoom__r.Name+' '+'DashBoard') {                                                                   
                requestBoard.TargetBoard = requestBoard.TargetRoom+' '+'DashBoard';
                //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                if(requestBoard.TargetBoard.length() > 80) {         
                    requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
                    requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
                }                     
            } else {
                requestBoard.TargetBoard = asynchboard.Name;       
            }

            if (request.targetProjectStartDateTime != null) {
                if (!workWeek.isWorkingDay(request.targetProjectStartDateTime.format('EEEE')) && asynchboard.leankor__SevenDayWorkWeek__c == false) {
                    requestBoard.initialDate = request.targetProjectStartDateTime+1;
                    if(!workWeek.isWorkingDay(requestBoard.initialDate.format('EEEE'))){
                        requestBoard.initialDate = requestBoard.initialDate+1;           	 
                    }
	            } else {
	            	requestBoard.initialDate = request.targetProjectStartDateTime;
                }       
            } 

            if (request.targetProjectDueDateTime != null) {
                if (!workWeek.isWorkingDay(request.targetProjectDueDateTime.format('EEEE')) && asynchboard.leankor__SevenDayWorkWeek__c == false) {
                    requestBoard.TargetDate = request.targetProjectDueDateTime-1;
                    if (!workWeek.isWorkingDay(requestBoard.TargetDate.format('EEEE'))) {
                        requestBoard.TargetDate = requestBoard.TargetDate-1;            	 
                    }
	            } else {
	            	requestBoard.TargetDate = request.targetProjectDueDateTime;
	            }
            }    

            requestBoard.checkCloneProject = 'StopOriginalkanbanCardUpdate';
            requestBoard.isplancloned = request.isplancloned ;
            requestBoard.cloneFiles = request.cloneFiles;
            requestBoard.cloneCustomFields = request.cloneCustomFields;
            //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning. 
            requestBoard.stickerVerb = request.cardStickerVerb;
            requestBoards.add(requestBoard);         
            // Ramanand : 28/06/2021 - Changes : CloneProjectAction.isClonedProject is true to prevent some process like clone dependency, enterTheZoneBulkify etc.
            CloneProjectAction.isClonedProject = true;
            CloneProjectAction.isExpense = request.expenses;
			// 25/03/2022 - using this varibale to prevent "EndCloneBoard" platform event for async baords cloning while project cloning. 
            CloneProjectAction.isAsyncBoard = true;
            
            if (!leankor.CloneProjectBoardAction.CloneProjectBoard(requestBoards).isEmpty()) {
                //Pratiksha : 15/07/2021 - Fixes for Link the Project and portfolio id.
                isCloneProjectBoard = true;
                //relinkClonedProject(request);
            }
            // Here we are assigning data to instance member variables to retain their values.
            newKanbanCards = newKanbanCardsStatic;
            valueStreamId = valueStreamIdStatic;
            mapWithOldKanbanCard = mapWithOldKanbanCardStatic;
            kanbanCardIdsForSticker = kanbanCardIdsForStickerStatic;
            // Ashutosh : 08/10/21 : Assign values in isCloneWithSticker variable.
            isCloneWithSticker = request.cardStickerVerb;
        } catch(Exception ex) {
            throw new CloneProjectActionException(ex.getMessage());                
        }                      
    }    
    
    


    //------------------------ BEGIN: Below should be moved to a new class to be reusable -------------------------------
    // rbo 11.23.16
    // method to update links of cards within a project after cloning
    // this method is not currently used
    // there is a similar method in CloneProjectBoardAction API which is the one being used for fixing the links
    //      of cards within a board
    // returns a List<sObject> of updated link objects
    
    //--------
    //17.05.2017 - overload this method for passing both source project id and cloned project id
    public static List<sObject> reLinkProject(CloneProjectRequest request) { 
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (
            !valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isUpdateable() ||
            !kanbanCardBehaviour.isAccessible() ||
            !KanbanCardBehaviour.isUpdateable() ||
            !expenseBehaviour.isAccessible() ||
            !expenseBehaviour.isUpdateable()
        ) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        leankor__KanbanCard__c emptyKanbanCard = new leankor__KanbanCard__c();
        List<sObject> objects = new List<sObject>();
        
        String PlanGanttId;
        String PlanBoardId;
        //--------
        List<leankor__ValueStream__c> valuestreamList = new List<leankor__ValueStream__c>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        
        
        List<leankor__ValueStream__c> newKanbanBoards = [Select Id,
                                                                leankor__ValueStreamCardLink__c,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ProjectRoomLink__c,
                                                                leankor__BoardType__c                 
                                                            From leankor__ValueStream__c
                                                            Where leankor__ProjectRoom__c =:request.relinkClonedProjectId
                                                            With Security_Enforced];

        // remove linking from project boards if any
        
        for (leankor__ValueStream__c newKanbanBoard : newKanbanBoards)
        {   
            if 
            (
                String.isNotBlank(newKanbanBoard.leankor__ValueStreamCardLink__c) || 
                String.isNotBlank(newKanbanBoard.leankor__ValueStreamLink__c) || 
                String.isNotBlank(newKanbanBoard.leankor__ProjectRoomLink__c)
            )
            {
                newKanbanBoard.leankor__ValueStreamCardLink__c = null;
                newKanbanBoard.leankor__ValueStreamLink__c = null;
                newKanbanBoard.leankor__ProjectRoomLink__c = null;
                
                valuestreamList.add(newKanbanBoard);                
                
                // rbo 11.29.16 
                //updateBoards++;
                // rbo 11.29.16                             
            }
            
            if(newKanbanBoard.leankor__BoardType__c == 'UberBoard'){
            	PlanGanttId = newKanbanBoard.Id;
        }
            if(newKanbanBoard.leankor__BoardType__c == 'Plan Board'){
            
            	PlanBoardId = newKanbanBoard.Id;
            }
            
        }
                
        List<leankor__KanbanCard__c> newKanbanCards = leankor.RealTimeControllerHelper.reLinkProject_Helper(request.relinkClonedProjectId);
        /*List<leankor__KanbanCard__c> newKanbanCards = 
            [Select 
                    Id,
                    leankor__ValueStream__c,
                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                    leankor__ValueStreamLink__c,
                    leankor__ValueStreamCardLink__c,
                    leankor__ValueStreamCardLink__r.leankor__ValueStream__c,
                    leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                    leankor__ValueStreamCardLink__r.leankor__BoardType__c,
                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                    leankor__ValueStreamLink__r.leankor__BoardType__c,
                    leankor__GUID__c                            
                From leankor__KanbanCard__c
                Where leankor__ValueStream__r.leankor__ProjectRoom__c = :request.relinkClonedProjectId]; */   
                
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();  
        
        for (leankor__KanbanCard__c newKanbanCard: newKanbanCards)
        {
            String kanbanCardGUID = (newKanbanCard.leankor__GUID__c).SubStringBefore('-');
            if (String.isNotBlank(kanbanCardGUID))
            {
                targetKanbanCards.put(kanbanCardGUID, newKanbanCard);
            }
        } 
 
        
        List<Id> cardLinkIds = new List<Id>();
        // update linking of cards if necessary
        for (leankor__KanbanCard__c newKanbanCard : newKanbanCards)
        {               
                      
            if (String.isBlank(newKanbanCard.leankor__ValueStreamCardLink__c))
            {
              //  if (String.isNotBlank(newKanbanCard.leankor__ValueStreamLink__c) &&
              //  newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c)
                if (String.isNotBlank(newKanbanCard.leankor__ValueStreamLink__c) )
                {
                    // set this to null as linking card to a board alone needs more logic to determine which valuestream record to link it into
                    if(newKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c == 'UberBoard' && newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == request.sourceProjectId )
                    {
                    	newKanbanCard.leankor__ValueStreamLink__c = PlanGanttId;
                    }else if(newKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c == 'Plan Board' && newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == request.sourceProjectId )
                    {
                    	newKanbanCard.leankor__ValueStreamLink__c = PlanBoardId;
                    }else{               
                    newKanbanCard.leankor__ValueStreamLink__c = null;
                }
                    kanbanCardList.add(newKanbanCard);
                }
            
            }
            //17.05.2017 - we are checking condition for cross project linking of kanban card
            // if any cross project link found than that kanban card link will null after cloning project
            else if(newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c != request.relinkClonedProjectId && newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c != request.sourceProjectId){
                
                 newKanbanCard.leankor__ValueStreamCardLink__c = null;
                 newKanbanCard.leankor__ValueStreamLink__c = null;
                 
                 kanbanCardList.add(newKanbanCard);
                      
            }else
            {
                // Is card's project the same as card's link project                
                // This is also to assume that linking of cards within the board is done after cloning the board, so only doing project card linking for efficiency
                // 07.12.2016 (newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__c != newKanbanCard.leankor__ValueStreamLink__c) this condition should be equal
                if (newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__c == newKanbanCard.leankor__ValueStreamLink__c &&
                newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c)
                {
                    leankor__KanbanCard__c targetKanbanCard = targetKanbanCards.get(newKanbanCard.leankor__ValueStreamCardLink__c);
                    if (targetKanbanCard != emptyKanbanCard && targetKanbanCard != null)
                    {   
                        newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCard.Id;
                        newKanbanCard.leankor__ValueStreamLink__c = targetKanbanCard.leankor__ValueStream__c;// 07.12.2016                                                                                          
                        
                    }else{
                        //adding condition if planGantt is untick from cloning popup than linking cards to plangantt will be null                   
                        if(!request.planGantt){                                                
                            if(newKanbanCard.leankor__ValueStreamCardLink__r.leankor__BoardType__c == 'UberBoard'){                   
                                newKanbanCard.leankor__ValueStreamCardLink__c = null;
                                newKanbanCard.leankor__ValueStreamLink__c = null;                                                                              
                            }                       
                         }                                        
                    }
                    //adding  cardlink ids for updating RA percentCompleted field
                    if(newKanbanCard.leankor__ValueStreamCardLink__r.leankor__BoardType__c != 'UberBoard'){
                    	cardLinkIds.add(newKanbanCard.leankor__ValueStreamCardLink__c);
                    }
                    // yj 12.01.2017
                    // shifted  this statement from inner if condtion to outer if condition
                    // because without link card from other board on plangantt parent is not following as child 
                    kanbanCardList.add(newKanbanCard);
                }
            }                                
            // rbo 11.29.16
        }

 		// relink Expenses
		if (request.relinkClonedExpenses != null && request.relinkClonedExpenses.size() > 0) {
			List<leankor__Expense__c> clonedExpenses = new List<leankor__Expense__c>();
			for (String clonedExpenseKey : request.relinkClonedExpenses.keySet()) {
				for (leankor__Expense__c expense : request.relinkClonedExpenses.get(clonedExpenseKey)) {
					expense.leankor__ProjectBoard__c = targetKanbanCards.containsKey(clonedExpenseKey) ? targetKanbanCards.get(clonedExpenseKey).leankor__ValueStream__c : null;
					expense.leankor__KanbanCard__c = targetKanbanCards.containsKey(clonedExpenseKey) ? targetKanbanCards.get(clonedExpenseKey).Id : null;			
					clonedExpenses.add(expense);
				}
			}	
	        update clonedExpenses;
		}
 		//
 		 
        //update objects;
        //updating valuestream and kanban card separately
        // due to this error: Cannot have more than 10 chunks in a single operation. Please rearrange the data to reduce chunking. 
        update valuestreamList;
        
        update kanbanCardList;
        
        /* dont need to this conversion
        List<leankor__KanbanCard__c> kanbancardlist = new List<leankor__KanbanCard__c>();
        
        for(sObject record:objects)
        {  
           if(record.getSObjectType() == leankor__KanbanCard__c.sObjectType)
           {      
              kanbancardlist.add((leankor__KanbanCard__c)record);  
           }
        }
        */
        //10.06.2017 yj - commenting code for prevent recalculation parent child after relink
        // we need exact replica of source board.
        // Card : "IsSuccessorRecalculate is impacting Cloned Project"
        //leankor.realtimeController.KCupdatePVcard(JSON.serialize(kanbanCardList));                              
        
        //updating updating RA percentCompleted field                              
        leankor.ProjectBoardCarousel.updateActivityPercentageComplete(cardLinkIds);
        
        return objects;
    
    }
    
    // returns the total number of cards of for all specified boards within a project
    public static Integer readProjectCardCount(Id projectRoomId, Set<String> boardTypes) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if(!kanbanCardBehaviour.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        /*
        return
            [Select 
                    count()
                From leankor__KanbanCard__c 
                Where leankor__ValueStream__r.leankor__ProjectRoom__c = :projectRoomId And leankor__BoardType__c In :boardTypes];
        */
        
        Integer projectCardCount = [Select count()
                                        From leankor__KanbanCard__c 
                                        Where leankor__ValueStream__r.leankor__ProjectRoom__c =: projectRoomId 
                                            And leankor__BoardType__c In :boardTypes
                                            And leankor__IsRecordDeleted__c = FALSE 
                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
                                        With Security_Enforced];
        return projectCardCount;                
    }
    
    // create a new project
    public static leankor__ProjectRoom__c createProject(CloneProjectRequest request) {
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
        
        //leankor__ProjectRoom__c pr = [SELECT leankor__ProjectManager__c , leankor__AutoAssignResource__c FROM leankor__ProjectRoom__c WHERE Id =: request.sourceProjectId LIMIT 1]; 
        Id sourceProjectId = request.sourceProjectId;             	
		leankor__ProjectRoom__c pr = Database.query
				('SELECT' 
					+ (isMultiCurrency ? ' CurrencyIsoCode,' : '') 					
					+ ' leankor__ProjectManager__c,'
					+ ' leankor__AutoAssignResource__c,'
                 	+ 'leankor__isShowWeekCalendar__c'
					+ ' FROM leankor__ProjectRoom__c' 
					+ ' WHERE Id = :sourceProjectId'
					+ ' LIMIT 1');
        
        if (isMultiCurrency) {
        	project.put('CurrencyIsoCode', (String)pr.get('CurrencyIsoCode'));
        }
        
        project.Name = request.targetProjectName; 
        project.leankor__ProjectManager__c = pr.leankor__ProjectManager__c;

        //clone AutoAssignResource field value as it is original project
        project.leankor__AutoAssignResource__c = pr.leankor__AutoAssignResource__c;
        project.leankor__ProjectTemplate__c = request.sourceProjectId;
        Project.leankor__isShowWeekCalendar__c = pr.leankor__isShowWeekCalendar__c;

        // rbo 01.03.19
                
        // Date: 24/05/2019
        //removing Time value 00:00:000, it was causing incorrect date value on UI
        if(String.isNotBlank(request.targetLaunchDate)){    
        	project.leankor__ProjectLaunchDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(request.targetLaunchDate),DateTime.class);	
            //project.leankor__ProjectLaunchDateTime__c = project.leankor__ProjectLaunchDateTime__c.dateGMT();
        }else if(request.targetLaunchDateTime != null){
        	//project.leankor__ProjectLaunchDateTime__c = request.targetLaunchDateTime.dateGMT();
        	project.leankor__ProjectLaunchDateTime__c = request.targetLaunchDateTime;
        } 
             
        if(request.targetProjectStartDateTime != null)
        {
            //Create New instance instead of Date.valueOf(), date.valueOf() was replacing the time portion from DateTime value
            //For e.g. DateTime dateTimeValue= 2019-08-31T07:54:57.199Z 
            //when we get date using this statement project.leankor__StartDate__c = Date.valueof(dateTimeValue);
            //dateTimeValue replacing with 2019-08-31T07:00:00.000Z 
            Date tempProjectStartDate = Date.newInstance(request.targetProjectStartDateTime.yearGMT(), request.targetProjectStartDateTime.monthGMT(), request.targetProjectStartDateTime.dayGMT());
            
            //To Do : Need to confirm
            //Do we need to do this calculation for Project's StartDate/DueDate Field.
            //As project does not follow 5 / 7 day working setting
            /*
            if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE')) && (nonWorkingDays.get(request.targetProjectStartDateTime.formatGMT('EEEE')) == 1)){ 
            	//project.leankor__StartDate__c = Date.valueof(request.targetProjectStartDateTime)+2;
                project.leankor__StartDate__c = tempProjectStartDate+2;
                
            }else if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE')) && (nonWorkingDays.get(request.targetProjectStartDateTime.formatGMT('EEEE')) == 2)){
            	//project.leankor__StartDate__c = Date.valueof(request.targetProjectStartDateTime)+1;
                project.leankor__StartDate__c = tempProjectStartDate+1;

            }*/
            if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE'))){	
            	project.leankor__StartDate__c =Util.readNextWorkingDate(workWeek,tempProjectStartDate);
                
            }else{
                 project.leankor__StartDate__c = tempProjectStartDate;
            }
        }
        
        if(request.targetProjectDueDateTime != null)
        {
            Date tempProjectDueDate = Date.newInstance(request.targetProjectDueDateTime.yearGMT(), request.targetProjectDueDateTime.monthGMT(), request.targetProjectDueDateTime.dayGMT());        
            
            //To Do : Need to confirm
            //Do we need to do this calculation for Project's StartDate/DueDate Field.
            //As project does not follow 5 / 7 day working setting
            /*if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE')) && (nonWorkingDays.get(request.targetProjectDueDateTime.formatGMT('EEEE')) == 1)){
            	//project.leankor__DueDate__c = Date.valueof(request.targetProjectDueDateTime)-1;
                project.leankor__DueDate__c = tempProjectDueDate-1;
            } else if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE')) && (nonWorkingDays.get(request.targetProjectDueDateTime.formatGMT('EEEE')) == 2)){
            	//project.leankor__DueDate__c = Date.valueof(request.targetProjectDueDateTime)-2;
                project.leankor__DueDate__c = tempProjectDueDate-2;
            }*/
            if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE'))){
            	project.leankor__DueDate__c= Util.readPreviousWorkingDate(workWeek,tempProjectDueDate);                              
            }else{
            	 project.leankor__DueDate__c = tempProjectDueDate;
            }
        }
        
        return project;
    }  
    
    // read all records of all project boards in a given project  
    public static List<leankor__ProjectLaunchBehavior__c> readProjectSetup(Id projectRoomId, Set<String> moduleBoardTypes) {
        //Check CRUD / FLC behavior
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
        if(!projectLaunchBehavior.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return
            [SELECT Id, 
                    Name, 
                    leankor__DefaultBoard__c, 
                    leankor__Module__c, 
                    leankor__OneClicklaunch__c, 
                    leankor__OpenNewTab__c, 
                    leankor__Project__c, 
                    leankor__ViewType__c 
                From leankor__ProjectLaunchBehavior__c
                Where leankor__Project__c =:projectRoomId 
                    And leankor__Module__r.leankor__BoardType__c In :moduleBoardTypes
                With Security_Enforced];      
    } 
    

    // create new project setup with the new project id
    public static List<leankor__ProjectLaunchBehavior__c> createProjectSetup(Id projectRoomId, List<leankor__ProjectLaunchBehavior__c> projectSetup) {
        List<leankor__ProjectLaunchBehavior__c> projectSetupCloned = new List<leankor__ProjectLaunchBehavior__c>();
        for (leankor__ProjectLaunchBehavior__c setup : projectSetup)
        {
            projectSetupCloned.add
                (new leankor__ProjectLaunchBehavior__c
                    (
                        leankor__Project__c = projectRoomId,
                        leankor__Module__c =  setup.leankor__Module__c,
                        //leankor__DefaultBoard__c = setup.leankor__DefaultBoard__c, 
                        leankor__OneClicklaunch__c = setup.leankor__OneClicklaunch__c, 
                        leankor__OpenNewTab__c = setup.leankor__OpenNewTab__c, 
                        leankor__ViewType__c = setup.leankor__ViewType__c
                    )
                );          
        }       
        return projectSetupCloned;
    }  
    

    // read all records of all project boards in a given project  
    public static List<leankor__ValueStream__c> readProjectBoards(Id projectRoomId, Set<String> boardTypes) {
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if(!valueStreamBehavior.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        return  
            [Select Id,
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
                Order By leankor__BoardType__c, Name];
    }
    //------------------------ END: Above should be moved to a new class to be reusable -------------------------------
    
    public class CloneProjectActionException extends Exception {}
    
    //----------------------------checking asynchronous method is completed or not ----------    
    @Remoteaction
    global static List<leankor.ProjectBoardCarousel.PortfolioHierarchy> checkAsynchronousMethod(leankor.ProjectBoardCarousel.portfoliodata port) {
        return new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>();
    }
    //--------------------
    
    public static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getMaxDateOfBoard(Id projectRoomID) {
        leankor.ProjectBoardCarousel.portfoliodata p = new leankor.ProjectBoardCarousel.portfoliodata();
        p.navigationVerb = 'cloneProject';
        p.Id = projectRoomID;       
        return leankor.ProjectBoardCarousel.getPortHierarchy(p);        
    }


    @TestVisible
    private static List<leankor__Portfolio__c> getTargetFolder(CloneProjectRequest request) {
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        if(!portfolioBehaviour.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return (String.isBlank(request.targetFolderId) || !(request.targetFolderId instanceOf ID))
            ? [Select 
                    Id,
                    Name
                From leankor__Portfolio__c 
                Where Name =:request.targetFolderName
                With Security_Enforced 
                Limit 1]
            : [Select 
                    Id,
                    Name
                From leankor__Portfolio__c 
                Where Id =: request.targetFolderId
                With Security_Enforced
                Limit 1]; 
    }

    
    @TestVisible
    private static List<leankor__ProjectRoom__c> getSourceProject(CloneProjectRequest request) {
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        if(!projectRoomBehaviour.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return (String.isBlank(request.sourceProjectId) || !(request.sourceProjectId instanceOf ID))
            ? (
                (String.isBlank(request.sourceFolderId) || !(request.sourceFolderId instanceOf ID))
                ? [Select 
                        Id,
                        Name,                       
                        leankor__Portfolio__c, 
                        leankor__Portfolio__r.Name,
                        leankor__ProjectTemplate__c 
                    From leankor__ProjectRoom__c 
                    Where Name =: request.sourceProjectName 
                        And leankor__Portfolio__r.Name =: request.sourceFolderName 
                        And leankor__Portfolio__c != null 
                    With Security_Enforced
                    Order By CreatedDate DESC
                    Limit 1]
                : [Select 
                        Id,
                        Name,
                        leankor__Portfolio__c, 
                        leankor__Portfolio__r.Name,
                        leankor__ProjectTemplate__c 
                    From leankor__ProjectRoom__c 
                    Where Name =: request.sourceProjectName 
                        AND leankor__Portfolio__c =: request.sourceFolderId 
                    With Security_Enforced
                    Order By CreatedDate DESC
                    Limit 1]
            )
        : [Select 
                Id,
                Name,
                leankor__Portfolio__c, 
                leankor__Portfolio__r.Name,
                leankor__ProjectTemplate__c 
            From leankor__ProjectRoom__c 
            Where Id =: request.sourceProjectId
            With Security_Enforced
            Limit 1];
    }
}