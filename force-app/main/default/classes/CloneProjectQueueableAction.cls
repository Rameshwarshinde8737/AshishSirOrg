/*---------------------------------------------------------------------------------------
* Copyright 2012-2016 Leankor All rights reserved
Author     :    
Company    :    Leankor
Description:    An API class for cloning existing project
Inputs     :    sourceFolderId - String, Folder id of source project
                sourceFolderName - String, Folder name of source project
                sourceProjectId - String, Project id of source project
                sourceProjectName - String, Project name of source project      
                targetFolderId - String, Folder id of target project    
                targetFolderName - String, Folder name of target project    
                targetProjectName - String, Required Project name of target project
                targetProjectStartDateTime - Datetime, Project start date time
                targetProjectDueDateTime - Datetime, Project due date time
                planGantt - Boolean, True if Plan Gantt is to be cloned
                rollUp - Boolean, True if Roll-up board is to be cloned
                projectBoard - Boolean, True if Project Board(s) is to be cloned
                whiteBoard - Boolean, True if Whiteboard(s) is to be cloned
                dashBoard - Boolean, True if Dashboard(s) is to be cloned
                expenses - Boolean, True if Expenses is to be cloned
                returnPortfolioHierarchy - Boolean, True if Portfolio Hierarchy is to be returned
Output      :   clonedProjectId - String, Required Cloned Project Id
                                  Empty string if it is unable to clone the project
                portfolioHierarchy - String List, Portfolio Hierarchy             
Test Class  : CloneProjectActionTest
History     :
<Date>       <Authors Name>     <Brief Description of Change>
---------------------------------------------------------------------------------------*/
global with sharing class CloneProjectQueueableAction 
{   
    global cloneProjectQueueableAction(ApexPages.StandardController controller){}    
    global cloneProjectQueueableAction(){}         
    global cloneProjectQueueableAction(ApexPages.StandardSetController controller) {}     
    global class CloneProjectRequest
    {
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
        // rbo 11.28.16 modified
        @InvocableVariable(label='Relink cloned project id' description='The project id of cloned project to relink items within. If this is defined, the API will only execute relinking and not cloning making values of the other parameters unnecessary.')
            global String relinkClonedProjectId;
        @InvocableVariable(label='Set of project board types within the source project' description='The board types of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global List<String> projectBoardTypes;
        @InvocableVariable(label='Total cards of all project boards within the source project' description='The total number of cards of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global Integer totalCardsOfSourceProjectBoards;
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
            Global Boolean cloneFiles;
        @InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
            Global Boolean cloneCustomFields;
        @InvocableVariable(label='Project Launch date time' description='The launch date of the cloned project in date and time data type. Define this if “Project start date time” and "Project due date time" are not defined.')              
            Global Datetime targetLaunchDateTime; 
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload;                       
        // rbo 11.28.16                            
            public String targetStartDate;             
            public String targetDueDate;
            public String navigationVerb;  
            public boolean isplancloned;
            public String sessionID;  
        //RS 2.5.2018 FirstDayOfTheWeek         
            public integer firstDayOfWeek;
            public boolean sevenDayWorkWeek;
        // Date: 03/06/2019 
            public String targetLaunchDate;
            public Map<Id, List<leankor__Expense__c>> relinkClonedExpenses;   
        //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning.    
        @InvocableVariable(label='Clone KanbanCard Stickers' description='Set to true if Clone All Sticker on Face of KanbanCards')
            global Boolean cardStickerVerb;  
                     
    } 
    
    global class CloneProjectResult
    {
        @InvocableVariable(label='Cloned Project Id' description='The project id of the cloned project.')
            global String clonedProjectId;
        @InvocableVariable(label='Portfolio Hierarchy' description='The full Portfolio Hierarchy.')
            global List<String> portfolioHierarchy = new List<String>();
    }  
    
    // This is Invocable Method for Cloning Project by API call
    @InvocableMethod
    global static List<CloneProjectResult> cloneProjects(List<CloneProjectRequest> requests)
    {
        List<CloneProjectResult> results = new List<CloneProjectResult>();
        for (CloneProjectRequest request : requests) 
        {            
            results.add(cloneProject(request));
            //results.add(String.isBlank(request.relinkClonedProjectId) ?  cloneProject(request) : relinkClonedProject(request));            
        }
        return results;
    }  
    // Method to clone the project
    @RemoteAction
    global static CloneProjectResult cloneProject(CloneProjectRequest requestInstance)
    {   
         // Added Security code for sentize user Input
        if((String.isNotBlank(requestInstance.sourceFolderId) && Util.getSObjectName(requestInstance.sourceFolderId) != 'leankor__Portfolio__c')
        || (String.isNotBlank(requestInstance.sourceProjectId) && Util.getSObjectName(requestInstance.sourceProjectId) != 'leankor__ProjectRoom__c')
        || (String.isNotBlank(requestInstance.targetFolderId) && Util.getSObjectName(requestInstance.targetFolderId) != 'leankor__Portfolio__c')
        || (String.isNotBlank(requestInstance.relinkClonedProjectId) && Util.getSObjectName(requestInstance.relinkClonedProjectId) != 'leankor__ProjectRoom__c')){
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
        ||  !projectLaunchBehavior.isCreateable()) 
        {
            throw new Util.LeanException('Error: No access to records');
        }        
        //Check CRUD / FLC behavior
        
        CloneProjectAction.CloneProjectRequest request = new CloneProjectAction.CloneProjectRequest();            
        CloneProjectResult result = new CloneProjectResult();
        
        decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;   
        request.firstDayOfWeek = firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();
        // re-define values
        //Assign values to CloneProjectAction's request Instance from Queueable Instance
        //We are using CloneProjectAction's object in  our cloning
        //Need to assign all request values to that object
        request.targetProjectName = String.escapeSingleQuotes(requestInstance.targetProjectName);              
        request.planGantt = requestInstance.planGantt != null ? requestInstance.planGantt : false;
        request.rollUp = requestInstance.rollUp != null ? requestInstance.rollUp : false;
        request.projectBoard = requestInstance.projectBoard != null ? requestInstance.projectBoard : false;
        request.whiteBoard = requestInstance.whiteBoard != null ? requestInstance.whiteBoard : false;
        request.dashBoard = requestInstance.dashBoard != null ? requestInstance.dashBoard : false;
        request.expenses = requestInstance.expenses != null ? requestInstance.expenses : false;
        request.returnPortfolioHierarchy = requestInstance.returnPortfolioHierarchy != null ? requestInstance.returnPortfolioHierarchy : false;    
        request.isplancloned= (requestInstance.planGantt != null ? requestInstance.planGantt : false);
        request.cloneFiles= (requestInstance.cloneFiles != null ? requestInstance.cloneFiles : false);
        request.cloneCustomFields= (requestInstance.cloneCustomFields != null ? requestInstance.cloneCustomFields : false); 
        request.relinkClonedProjectId = requestInstance.relinkClonedProjectId;
        request.projectEventCustomPayload = requestInstance.projectEventCustomPayload;
        // Ashutosh - 25/06/2021 - assiging value in request.isCloneWithLaunchDate project is cloned with launch date or not.
        request.isCloneWithLaunchDate = requestInstance.targetLaunchDateTime != null || requestInstance.targetLaunchDate != null ? true : false;
		 //Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning.
        request.cardStickerVerb = requestInstance.cardStickerVerb != null ? requestInstance.cardStickerVerb : false;
        //TargetLaunchDate becomes start date 
        if(requestInstance.targetStartDate != null  || requestInstance.targetLaunchDate != null)
        {
            request.targetProjectStartDateTime = (requestInstance.targetStartDate != null) ? (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetStartDate),DateTime.class): (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetLaunchDate),DateTime.class);
            if(requestInstance.targetLaunchDate!=null){
            //removing Time value 00:00:000, it was causing incorrect date value on UI
    		//request.targetLaunchDateTime = request.targetProjectStartDateTime.dateGMT();
    		request.targetLaunchDateTime = request.targetProjectStartDateTime;
        	}
        }
        else if(requestInstance.targetDueDate != null){
            
           request.targetProjectDueDateTime = (DateTime)JSON.deserialize(JSON.serialize(requestInstance.targetDueDate),DateTime.class);  
        
        }else if(requestInstance.targetLaunchDateTime != null){
            //removing Time value 00:00:000, it was causing incorrect date value on UI
            //request.targetLaunchDateTime = requestInstance.targetLaunchDateTime.dateGMT();
            request.targetLaunchDateTime = requestInstance.targetLaunchDateTime;
            // Target launch date becomes the Start Date
            request.targetProjectStartDateTime = requestInstance.targetLaunchDateTime;
            
        }else if(requestInstance.targetProjectStartDateTime == null && requestInstance.targetProjectDueDateTime == null)
        {
            request.targetProjectStartDateTime = system.now(); 
        } else if(requestInstance.targetProjectStartDateTime!=null){
            request.targetProjectStartDateTime = requestInstance.targetProjectStartDateTime;
        } else if(requestInstance.targetProjectDueDateTime!=null){
            request.targetProjectDueDateTime = requestInstance.targetProjectDueDateTime;
        }      
        /*   //Date: 19/06/2019  - Making time portion to 00:00:00
        if(request.targetProjectStartDateTime != null){
            request.targetProjectStartDateTime = (request.targetProjectStartDateTime).date();
        }*/
        
        // start validate inputs    
        if (String.isBlank(requestInstance.targetProjectName))
        {
            throw new CloneProjectAction.CloneProjectActionException('You must specify the "Target Project Name".');
            //return result;
        }  
        
        // determine board type to clone
        Set<String> synchBoardTypes = new Set<String>();   // boards to be cloned syncronously     
        Set<String> asynchBoardTypes = new Set<String>();  // boards to be cloned asyncronously via Flow
        Set<String> moduleBoardTypes = new Set<String>();   
        
        if (request.planGantt)
        {
            synchBoardTypes.add('UberBoard');
            moduleBoardTypes.add('_System_UberBoard');
        }   
        
        if (request.rollUp)
        {
            asynchBoardTypes.add('Plan Board');                       
            moduleBoardTypes.add('_System_PlanBoard');
        } 
        
        if (request.projectBoard)
        {
            asynchBoardTypes.add('Kanban Board');
            moduleBoardTypes.add('_System_Board');
        } 
        
        if (request.whiteBoard)
        {
            asynchBoardTypes.add('Whiteboard');                           
            moduleBoardTypes.add('_System_Whiteboard');
        } 
        
        if (request.dashBoard)
        {
            asynchBoardTypes.add('DashBoard');
            moduleBoardTypes.add('_System_DashBoard');
        } 
        
        // TODO: This is to clone records of expenses
        if (request.expenses)
        {
           moduleBoardTypes.add(''); //   Expenses board type is nothing that's why its empty string 
            
        }
        
        if (synchBoardTypes.isEmpty() && asynchBoardTypes.isEmpty() && !request.expenses)
        {
            throw new CloneProjectAction.CloneProjectActionException('You must specify at least one Project item to clone.');
            //return result;
        }  
        
        List<leankor__Portfolio__c> targetFolder = String.isBlank(requestInstance.targetFolderId) || !(requestInstance.targetFolderId instanceOf ID)
            ? [Select 
                    Id,
                    Name
                From leankor__Portfolio__c 
                Where Name = :requestInstance.targetFolderName 
                Limit 1]
            : [Select 
                    Id,
                    Name
                From leankor__Portfolio__c 
                Where Id = :requestInstance.targetFolderId];  
                
        if (targetFolder.isEmpty())
        {
            throw new CloneProjectAction.CloneProjectActionException('You must specify a valid "Target Folder Id" or "Target Folder Name".');
            //return result;
        } 
        
        List<leankor__ProjectRoom__c> sourceProject = String.isBlank(requestInstance.sourceProjectId) || !(requestInstance.sourceProjectId instanceOf ID)
            ? (String.isBlank(requestInstance.sourceFolderId) || !(requestInstance.sourceFolderId instanceOf ID)
                ? [Select 
                        Id,
                        Name,                       
                        leankor__Portfolio__c, 
                        leankor__Portfolio__r.Name,
                        leankor__ProjectTemplate__c 
                    From leankor__ProjectRoom__c 
                    Where Name = :requestInstance.sourceProjectName And leankor__Portfolio__r.Name = :requestInstance.sourceFolderName And leankor__Portfolio__c != null 
                    Order By CreatedDate Desc
                    Limit 1]
                : [Select 
                        Id,
                        Name,
                        leankor__Portfolio__c, 
                        leankor__Portfolio__r.Name,
                        leankor__ProjectTemplate__c 
                    From leankor__ProjectRoom__c 
                    Where Name = :requestInstance.sourceProjectName And leankor__Portfolio__c = :requestInstance.sourceFolderId 
                    Order By CreatedDate Desc
                    Limit 1])
            : [Select 
                    Id,
                    Name,
                    leankor__Portfolio__c, 
                    leankor__Portfolio__r.Name,
                    leankor__ProjectTemplate__c 
                From leankor__ProjectRoom__c 
                Where Id = :requestInstance.sourceProjectId];
                
        if (sourceProject.isEmpty())
        {
            throw new CloneProjectAction.CloneProjectActionException('You must specify a valid "Source Project Id" or "Source Folder Name and Source Project Name" or "Source Folder Id and Source Project Name".');
            //return result;
        }
        
        // end validate inputs
        // update parameter values
        request.targetFolderId = targetFolder[0].Id;
        request.targetFolderName = targetFolder[0].Name;
        request.sourceFolderId = sourceProject[0].leankor__Portfolio__c;
        request.sourceFolderName = sourceProject[0].leankor__Portfolio__r.Name;
        request.sourceProjectId = sourceProject[0].Id;
        request.sourceProjectName = sourceProject[0].Name; 
        //      
        // read records to clone
        List<leankor__ProjectLaunchBehavior__c> cloneProjectSetup = CloneProjectAction.readProjectSetup(request.sourceProjectId, moduleBoardTypes);
        List<leankor__ValueStream__c> synchCloneProjectBoards = synchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : CloneProjectAction.readProjectBoards(request.sourceProjectId, synchBoardTypes);        
        List<leankor__ValueStream__c> asynchCloneProjectBoards = asynchBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : CloneProjectAction.readProjectBoards(request.sourceProjectId, asynchBoardTypes);
        
        //
        // rbo 11.29.16 
        List<String> projectBoardTypes = new List<String>(asynchBoardTypes); 

        Integer totalCardsOfProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : CloneProjectAction.readProjectCardCount(request.sourceProjectId, asynchBoardTypes);
        Integer totalNumberOfSourceProjectBoards = asynchCloneProjectBoards.isEmpty() ? 0 : CloneProjectAction.readProjectBoards(request.sourceProjectId, asynchBoardTypes).size();
        
        
        leankor__ProjectRoom__c projectRoom = CloneProjectAction.createProject(request);                                    
        
        // set savepoint to rollback if there is an exception
        Savepoint sp = Database.setSavepoint();
        try
        {           
            insert projectRoom;     
            
            request.relinkClonedProjectId = projectRoom.Id;
                            
            insert CloneProjectAction.createProjectSetup(projectRoom.Id, cloneProjectSetup); 
                        
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
            
            request.projectBoardTypes = new List<String>();
            request.projectBoardTypes.addAll(asynchBoardTypes);
            request.totalCardsOfSourceProjectBoards = totalCardsOfProjectBoards;
            request.totalNumberOfSourceProjectBoards = totalNumberOfSourceProjectBoards;
                        
            // clone the Uberboard and Planboard by directly calling the CloneProjectBoard API (Synchronous call)
            // this is to make sure that these two boards are always created
            // currently there is only 1 Uberboard and 1 Planboard in a project, so this should not hit the SOQL 101
            /*for (leankor__ValueStream__c synchCloneProjectBoard : synchCloneProjectBoards)
            {           
                //createProjectBoard(request, synchCloneProjectBoard);
            }  */
            if(synchCloneProjectBoards.size()>0){
                System.enqueueJob(new CreateProjectBoardQueueable(request, synchCloneProjectBoards, asynchCloneProjectBoards));
            } else {
                for (leankor__ValueStream__c asynchCloneProjectBoard : asynchCloneProjectBoards)
                {       
                    request.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;
                    
                    // Tilak: 01.07.2020
                    // CloneProjectAction.asynchCreateProjectBoard(JSON.serialize(request), JSON.serialize(asynchCloneProjectBoard));                        
                    CloneProjectAction cloneProjectrequest = new CloneProjectAction(request, asynchCloneProjectBoard);
                    //System.enqueueJob(cloneProjectrequest);
                    Database.executeBatch(cloneProjectrequest);
                }
            }
            
                                
            // clone the Kanban Boards, Whiteboards and Dashboards using Flow that calls the CloneProjectBoard API (Asynchronous call)
            // this is a workaround to reset SOQL 101             
            /*for (leankor__ValueStream__c asynchCloneProjectBoard : asynchCloneProjectBoards)
            {       
                request.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;
                asynchCreateProjectBoard(JSON.serialize(request), JSON.serialize(asynchCloneProjectBoard));                        
            }*/

            // when cloning only planGantt board (synchronous Board)
            /*If(asynchCloneProjectBoards.size()==0)
            {    
                isBroadcast(request);
            }*/               
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
            CloneProjectAction.unlinkProject(requestInstance.relinkClonedProjectId, asynchBoardTypes);
            
            throw new CloneProjectAction.CloneProjectActionException(ex.getMessage());
        }   
        
        return result;
    }
    
    /*
    // removes links of all cards
    // to be called when exception is encountered during cloning
    private static void unlinkProject(String clonedProjectId, Set<String> boardTypes)
    {
        if (String.isNotBlank(clonedProjectId))
        {           
            List<leankor__KanbanCard__c> newKanbanCards = new List<leankor__KanbanCard__c>();

            for (leankor__KanbanCard__c newKanbanCard : 
                [Select 
                        Id,
                        leankor__ValueStreamLink__c,
                        leankor__ValueStreamCardLink__c                        
                    From leankor__KanbanCard__c
                    Where (leankor__ValueStreamLink__c != null Or leankor__ValueStreamCardLink__c != null)
                        And leankor__ValueStream__r.leankor__ProjectRoom__c = :clonedProjectId
                        And leankor__ValueStream__r.leankor__BoardType__c In :boardTypes
                        Limit 10000])
            {   
                newKanbanCard.leankor__ValueStreamCardLink__c = null;
                newKanbanCard.leankor__ValueStreamLink__c = null;
                newKanbanCards.add(newKanbanCard);
            }                             
    
            if (!newKanbanCards.isEmpty())
                update newKanbanCards;
        }
    }
    
    public static void isBroadcast(CloneProjectRequest request){
        //updating projectroom parent portfolio ID 
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
        project.leankor__Portfolio__c = request.targetFolderId;
        project.Id = request.relinkClonedProjectId;    
        
        try {
             update project;        
        
            //updating parent portfolio id in expence records
            // due to field filter validation on projectroom field in Expense 
            List<leankor__Expense__c> expenseList = new List<leankor__Expense__c>();
            for(leankor__Expense__c ex : [Select leankor__Portfolio__c From leankor__Expense__c Where leankor__Project__c = :request.relinkClonedProjectId]){           
                ex.leankor__Portfolio__c = request.targetFolderId;
                expenseList.add(ex);                        
            }
            
            if(expenseList.size()>0){
                update expenseList;
            }
            
            // this method is calling for broadcast
            List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(getMaxDateOfBoard(request.relinkClonedProjectId));
            portfolioresult[0].verb = 'CloneProject';
            leankor.realtimeKanbanController.manageNavChange('LeankorNAV',JSON.serialize(portfolioresult[0]),request.sessionID);             
        
            //------------------- BEGIN platform event broadcast
            leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
            
            pe.leankor__EventCategory__c = 'Cloning';
            pe.leankor__EventName__c = 'EndClone';
            pe.leankor__IsAPIGenerated__c = false;  // set true if in Leankor API
            pe.leankor__ProjectID__c = request.relinkClonedProjectId;
            pe.leankor__UserID__c = UserInfo.getUserId();
    
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
        
        } catch(DMLException ex){
            throw new CloneProjectActionException(ex.getMessage());
        }           
    }   
    
    public static CloneProjectResult relinkClonedProject(CloneProjectRequest request)
    {
        CloneProjectResult result = new CloneProjectResult();
        
        if (request.relinkClonedProjectId instanceOf ID && !request.projectBoardTypes.isEmpty())
        {           
            Set<String> asynchBoardTypes = new Set<String>(request.projectBoardTypes);          
            if (request.totalCardsOfSourceProjectBoards == readProjectCardCount(request.relinkClonedProjectId, asynchBoardTypes))   
            {   
                // set savepoint to rollback if there is an exception
                Savepoint sp = Database.setSavepoint();
                try
                {  
                    List<sObject> updateLinkObjects = new List<sObject>();
                   
                    updateLinkObjects = reLinkProject(request);
                    
                    // updateLinkObjects = reLinkProject(request.relinkClonedProjectId);
                        
                    // 02.12.16 use ! notation with updateLinkObjects because if updateLinkObjects is not empty than  sobjects must be update                   
                    //if (!updateLinkObjects.isEmpty())
                    //{
                    // yj & bm 19.05.2017
                    // we are removing this if condition if there is no link and no cards in project so we have empty list in above method.
                    // we have to remove this condition             
                        result.clonedProjectId = request.relinkClonedProjectId;
                        
                        isBroadcast(request);
                        
                        
                    //}
                    
                }
                catch(exception ex)
                {
                    System.debug('Exception sub relinkClonedProject(): ' + ex.getMessage());
                    // rollback
                    Database.rollback(sp);
                    throw new CloneProjectActionException(ex.getMessage());
                }
            }           
        }
        else
        {       
            System.debug('Error main relinkClonedProject(): ' + 'You must specify a valid "Relink cloned project id".');
            throw new CloneProjectActionException('You must specify a valid "Relink cloned project id".');
        }

        System.debug('Exit relinkClonedProject(CloneProjectRequest request) result: ' + result);

        return result;
    }
    // Clone Project Board API
    // 02.12.16 change input string to leankor__valuestream__c type for new project board name 
    private static void createProjectBoard(CloneProjectRequest request, leankor__ValueStream__c board)
    {
        //RS 2.5.2018 Changes for FirstDayOfTheWeek                 
        Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, 5);
        
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
        //comment this code because previous version roll up board as synchronous but new version we have changed synchronous to asynchronous
        
        //requestBoard.TargetBoard = boardName;
        //requestBoard.TargetDate = request.targetProjectDueDateTime;  // to be replaced with the card on board that has max due date?
        //requestBoard.initialDate = request.targetProjectStartDateTime;  // to be replaced with the card on board that has min start date?        
        
           
        if(request.targetProjectStartDateTime != null){
            //Date: 17/06/2019 - Changes for clone the plan gantt according to project launch date.
            if(request.targetLaunchDateTime != null || request.targetLaunchDate != null){
                AggregateResult[] minStartDate = [SELECT MIN(leankor__StartDateTime__c) minimumDate 
                                                        FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : board.Id 
                                                             AND leankor__IsRecordDeleted__c = FALSE 
                                                             AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
                if(minStartDate[0].get('minimumDate') != null){     
                    DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
                    //Add number of days to StartDate to maintain difference with ProjectLaunchDate              
                    if(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c!=null){
                        Integer addDays = (board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c.dateGMT()).daysBetween(minimumStartDate.dateGMT());
                        request.targetProjectStartDateTime = request.targetProjectStartDateTime + addDays;
                    }
                }
            }
        
            if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE')) && board.leankor__SevenDayWorkWeek__c == false){
                 requestBoard.initialDate = request.targetProjectStartDateTime+1;                            
                if(!workWeek.isWorkingDay(requestBoard.initialDate.formatGMT('EEEE'))){
                 requestBoard.initialDate = requestBoard.initialDate+1;              
            }
            }else{
                requestBoard.initialDate = request.targetProjectStartDateTime;
        }       
            //RS 2.5.2018
        }       
        if(request.targetProjectDueDateTime != null)
        {
           
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
        requestBoards.add(requestBoard);
                 
        leankor.CloneProjectBoardAction.CloneProjectBoard(requestBoards);  
    }

    @future
    public static void asynchCreateProjectBoard(String jsonString, String boardName)
    {               
        leankor__ValueStream__c asynchboard = (leankor__ValueStream__c)JSON.deserialize(boardName, leankor__ValueStream__c.class);//yj 09.01.17 
        CloneProjectRequest request = (CloneProjectRequest)JSON.deserialize(jsonString, CloneProjectRequest.class);                                     
        //RS 2.5.2018 Changes for FirstDayOfTheWeek                         
        Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, request.sevenDayWorkWeek ? 7 : 5);       

        // rbo 05.24.17        
        //leankor__ProjectRoom__c pr;                                   
        leankor__ProjectRoom__c pr = new leankor__ProjectRoom__c();                                 
        // rbo 05.24.17
        
        // EPLB: this should cause all other concurrent instances to block waiting for this process to complete. If more than 10 seconds passes, an exception occurs and we try again 2 more times.
        
        
        //Changed loop size from 12 to 36 to increase number of attempts for getting lock over record
        //For each attempt 10 sec. Now, max cloning time is 6 minutes
        
        //for (Integer ndx = 0; ndx < 12; ndx++){
        for (Integer ndx = 0; ndx < 36; ndx++){
            try {
                // rbo 05.24.17 use Id as a preference
                //pr = [SELECT leankor__AsynchCount__c FROM leankor__ProjectRoom__c WHERE Id =: request.relinkClonedProjectId limit 1 FOR UPDATE];
                pr = [SELECT Id FROM leankor__ProjectRoom__c WHERE Id =: request.relinkClonedProjectId limit 1 FOR UPDATE];
                // rbo 05.24.17

                break;
            } catch(Exception ex) {
                System.debug('Exception trying to get exclusive lock on Project ['+ request.relinkClonedProjectId  + ']. Will retry a few times. Error text: ' + ex);
                //if (ndx >= 11){                    
                if (ndx >= 35){                    
                    // rbo 05.24.17 throw exception to be passed to the calling method so it can handle the exception
                    throw new CloneProjectActionException(ex.getMessage());
                    // rbo 05.24.17
                    
                    //return;
                }
            }
        }
        
        try {                
            List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestBoards = new List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
            leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestBoard = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();       
            requestBoard.FolderName = request.sourceFolderName;
            requestBoard.ProjectRoom = request.sourceProjectName;        
            requestBoard.ProjectBoard = asynchboard.Name;//yj 09.01.17 
            requestBoard.ProjectBoardId = asynchboard.Id;
            requestBoard.TargetFolderName = request.targetFolderName;
            requestBoard.TargetRoom = request.targetProjectName;       
            requestBoard.ProjectRoomId = request.sourceProjectId;
            requestBoard.TargetRoomId = request.relinkClonedProjectId;        
            //Date: 18/06/2019
            if(request.targetLaunchDateTime != null){
                requestBoard.projectBoardLaunchDate = request.targetLaunchDateTime;             
            } else if(request.targetLaunchDate != null){
                requestBoard.projectBoardLaunchDate = (DateTime)JSON.deserialize(JSON.serialize(request.targetLaunchDate),DateTime.class);
            }
            
            // yj 09.01.17 checking plan board for board name because we was not updating board name with new project name
            if(asynchboard.leankor__BoardType__c == 'Plan Board')// 02.12.16update target board name with new project name 
            {                                                               
                requestBoard.TargetBoard = 'Roll-Up' +'('+requestBoard.TargetRoom+')';
                //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                if(requestBoard.TargetBoard.length() > 80)
                {         
                     requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
                     requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
                }
                //
            }
            else if(asynchboard.leankor__BoardType__c == 'DashBoard' && asynchboard.Name ==  asynchboard.leankor__ProjectRoom__r.Name+' '+'DashBoard')
            {                                                                   
                requestBoard.TargetBoard = requestBoard.TargetRoom+' '+'DashBoard';
                //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                if(requestBoard.TargetBoard.length() > 80)
                {         
                     requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
                     requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
                }
                //
                     
            }else
            {
                requestBoard.TargetBoard = asynchboard.Name;       
            }
            //yj 13.01.2017 above we added if condition for default dashboard name with new project room name     
            //requestBoard.TargetDate = request.targetProjectDueDateTime;  // to be replaced with the card on board that has max due date?
            //requestBoard.initialDate = request.targetProjectStartDateTime;  // to be replaced with the card on board that has min start date?        
            if(request.targetProjectStartDateTime != null)
            {
                //RS 2.5.2018 Changes for FirstDayOfTheWeek
                if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.format('EEEE')) && asynchboard.leankor__SevenDayWorkWeek__c == false){
                     requestBoard.initialDate = request.targetProjectStartDateTime+1;
                     if(!workWeek.isWorkingDay(requestBoard.initialDate.format('EEEE'))){
                     requestBoard.initialDate = requestBoard.initialDate+1;              
                }
                }else{
                    requestBoard.initialDate = request.targetProjectStartDateTime;
            }       
                //RS 2.5.2018                
                
            }       
            if(request.targetProjectDueDateTime != null)
            {
                //RS 2.5.2018 Changes for FirstDayOfTheWeek
                if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.format('EEEE')) && asynchboard.leankor__SevenDayWorkWeek__c == false){
                     requestBoard.TargetDate = request.targetProjectDueDateTime-1;
                     if(!workWeek.isWorkingDay(requestBoard.TargetDate.format('EEEE'))){
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
            requestBoards.add(requestBoard);         
 
                  
            if (!leankor.CloneProjectBoardAction.CloneProjectBoard(requestBoards).isEmpty())
            {
                relinkClonedProject(request);
            }
            
        }catch(Exception ex)
        {
            System.debug('Exception asynchCreateProjectBoard(): ' + ex);
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
    private static List<sObject> reLinkProject(CloneProjectRequest request)
    {              
        leankor__KanbanCard__c emptyKanbanCard = new leankor__KanbanCard__c();
        List<sObject> objects = new List<sObject>();
        
        String PlanGanttId;
        String PlanBoardId;
        //--------
        List<leankor__ValueStream__c> valuestreamList = new List<leankor__ValueStream__c>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        
        
        List<leankor__ValueStream__c> newKanbanBoards = 
            [Select 
                    Id,
                    leankor__ValueStreamCardLink__c,
                    leankor__ValueStreamLink__c,
                    leankor__ProjectRoomLink__c,
                    leankor__BoardType__c                 
                From leankor__ValueStream__c
                Where leankor__ProjectRoom__c = :request.relinkClonedProjectId];

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
        
        //updating updating RA percentCompleted field                              
        leankor.ProjectBoardCarousel.updateActivityPercentageComplete(cardLinkIds);
        
        return objects;
    
    }
    
    // returns the total number of cards of for all specified boards within a project
    private static Integer readProjectCardCount(Id projectRoomId, Set<String> boardTypes)
    {
        Integer projectCardCount = [Select 
                    count()
                From leankor__KanbanCard__c 
                Where leankor__ValueStream__r.leankor__ProjectRoom__c = :projectRoomId And leankor__BoardType__c In :boardTypes];
        return projectCardCount;                
    }
    
      
    
    // read all records of all project boards in a given project  
    private static List<leankor__ProjectLaunchBehavior__c> readProjectSetup(Id projectRoomId, Set<String> moduleBoardTypes)
    {
        return
            [
                Select
                    Id, 
                    Name, 
                    leankor__DefaultBoard__c, 
                    leankor__Module__c, 
                    leankor__OneClicklaunch__c, 
                    leankor__OpenNewTab__c, 
                    leankor__Project__c, 
                    leankor__ViewType__c 
                From leankor__ProjectLaunchBehavior__c
                Where leankor__Project__c = :projectRoomId And leankor__Module__r.leankor__BoardType__c In :moduleBoardTypes
            ];      
    } 
    
    // create new project setup with the new project id
    private static List<leankor__ProjectLaunchBehavior__c> createProjectSetup(Id projectRoomId, List<leankor__ProjectLaunchBehavior__c> projectSetup) 
    {
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
    private static List<leankor__ValueStream__c> readProjectBoards(Id projectRoomId, Set<String> boardTypes)
    {
        return  
            [
                Select
                    Id,
                    Name,
                    leankor__BoardType__c,leankor__ProjectRoom__r.Name,leankor__SevenDayWorkWeek__c,
                    leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c
                From leankor__ValueStream__c
                Where leankor__ProjectRoom__c = :projectRoomId And leankor__BoardType__c In :boardTypes
                Order By leankor__BoardType__c, Name
            ];
    }
    //------------------------ END: Above should be moved to a new class to be reusable -------------------------------
    
    class CloneProjectActionException extends Exception {}
    //--------------------
    
    public static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getMaxDateOfBoard(Id projectRoomID)
    {
        leankor.ProjectBoardCarousel.portfoliodata p = new leankor.ProjectBoardCarousel.portfoliodata();
        p.navigationVerb = 'cloneProject';
        p.Id = projectRoomID;       
        return leankor.ProjectBoardCarousel.getPortHierarchy(p);        
    }*/
          
}