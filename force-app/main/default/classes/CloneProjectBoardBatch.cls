/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CloneProjectBoardBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public class CloneProjectBoardRequest {
        public String folderName;
        public String projectRoom;
        public String projectBoard;
        public String targetFolderName;
        public String targetRoom;
        public String targetBoard;
        public DateTime targetDate;
        public String linkFolderName; 
        public String linkRoomName;
        public String linkBoardName;
        public String linkKanbanCardName;
        public String linkedBoardId;  
        public String linkedCardId;
        public DateTime initialDate;
        public String projectRoomId;
        public String targetRoomId;
        public String projectBoardId;
        public boolean isPlanCloned;
        public String checkCloneProject;
        public Boolean cloneFiles;
        public Boolean cloneCustomFields;    
        public DateTime projectBoardLaunchDate;
        public String projectEventCustomPayload;  
        public Boolean stickerVerb;     
        public Boolean taskVerb; 
        public Boolean markerVerb; 
        public Boolean chartVerb;      
        public Boolean kanbanVerb;
        public Boolean zoneVerb;
        public Boolean kanbanTemplateVerb;
        public String sessionID;
        public Boolean expenses;  
        public String sourceFolderName;  
        public String sourceProjectId;     
        public String relinkClonedProjectId;
        public List<String> projectBoardTypes;
        public Integer totalCardsOfSourceProjectBoards;  
        public Integer totalNumberOfSourceProjectBoards;
        public DateTime targetProjectStartDateTime;
        public DateTime targetProjectDueDateTime;
        public boolean sevenDayWorkWeek;
        public Integer firstDayOfWeek;
        public Boolean isCloneWithLaunchDate;
        public Boolean cardStickerVerb; 
        public Datetime targetLaunchDateTime; 
        public String targetLaunchDate;
        public Map<Id, List<leankor__Expense__c>> relinkClonedExpenses;	
        public String sourceProjectName;
        public Boolean isExpense;
        public String targetFolderId; 
    }

    @TestVisible   
    private CloneProjectBoardRequest cloneProjectBoardRequest; 
    @TestVisible  
    private leankor__valueStream__c valueStream;
    CloneProjectProcessAction.CloneProjectRequest requestInstance;
    @TestVisible   
    private Boolean firstChunkExecution = true;
    @TestVisible   
    private CloneProjectPlanGanttBatch.BoardData boardData = new CloneProjectPlanGanttBatch.BoardData();
    public static final Integer BATCHCHUNKSIZE_CONST = 200;
    public Integer totalChunks = 0;
    public Integer chunkCount = 0;

    // Parameterized constructor
    public CloneProjectBoardBatch(CloneProjectBoardRequest cloneProjectBoardRequest, leankor__valueStream__c valueStream, CloneProjectProcessAction.CloneProjectRequest requestInstance) {
        this.cloneProjectBoardRequest = cloneProjectBoardRequest;
        this.valueStream = valueStream;
        this.requestInstance = requestInstance;
    }

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    The start method of the Batch class will return leankor__KanbanCard__c if Kanban cards are available in the source board. Otherwise, 
                        it will return leankor__ValueStream__c for the QueryLocator.
	    Inputs:         Database.BatchableContext
	    Returns:        Database.QueryLocator
	------------------------------------------------------------*/
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
    
        Integer kanbanCardcount = [Select count() 
                                        From leankor__KanbanCard__c 
                                        Where leankor__ValueStream__c = :this.valueStream.Id
                                            And leankor__IsRecordDeleted__c = False
                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                        With Security_Enforced
                                        Limit 10000];
        String query;
        
        if (kanbanCardcount > 0) {
            Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__KanbanCard__c'); 
            String customFields = '';  
            this.totalChunks = (kanbanCardcount + BATCHCHUNKSIZE_CONST - 1) / BATCHCHUNKSIZE_CONST;

            String sObjectFields = 'Id,leankor__IsSuccessorRecalculate__c,leankor__EffortRemaining__c,leankor__MasterContainer__c,'+                                                                     
                                    'leankor__CardID__c,leankor__Point__c,leankor__Swimlane__c,leankor__Zone__c,leankor__UrlLink__c,'+
                                    'leankor__Account__c,leankor__ActualDuration__c,leankor__Actual_Time_Taken__c,leankor__Bottom__c,leankor__Budgeted_Time__c,leankor__Case__c,'+
                                    'leankor__CmpID__c,leankor__Color__c,leankor__CompletionVariance__c,leankor__Contact__c,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,'+
                                    'leankor__AcceptanceCriteria__c,leankor__Description__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,'+
                                    'leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__IsCompletedOnTime__c,leankor__JSONData__c,'+
                                    'leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__Left__c,leankor__Opportunity__c,leankor__Order__c,leankor__PercentComplete2__c,'+
                                    'leankor__Priority__c,leankor__PromiseCompletionDate__c,leankor__StartDate__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,'+
                                    'leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId, leankor__StartDateTime__c,'+
                                    'leankor__DueDateTime__c,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,leankor__IsAtRisk__c,leankor__IsOnHold__c,Owner.IsActive,leankor__Monday__c,'+
                                    'leankor__Tuesday__c,leankor__Wednesday__c,leankor__Thursday__c,leankor__Friday__c,leankor__Saturday__c,leankor__Sunday__c,leankor__WeekCalendar__c,leankor__SeriesNumber__c,';
                                            
            String relatedsObjects =' (Select Id,leankor__ManuallyScheduled__c,leankor__Mode__c,leankor__ScheduleConstraint__r.leankor__Type__c,leankor__ConstraintDateTime__c,'+
                                    'leankor__EffortUnits__c,leankor__EffortActual__c,leankor__KanbanCard__c,leankor__KanbanCard__r.leankor__valuestream__c, leankor__ReadOnly__c From leankor__ScheduleModes__r Limit 1),'+
                                    '(Select Id,leankor__AssignedTo__c,leankor__KanbanCard__c,leankor__KanbanCard__r.leankor__valuestream__c,leankor__PercentAllocation__c,leankor__CompletedDate__c,Name,leankor__PercentCompleted__c,leankor__ExpenseAccount__c,leankor__ExpenseSubCategory__c,leankor__ExpenseCategory__c,leankor__ExternalHourlyRate__c,leankor__InternalHourlyRate__c,leankor__ResourceType__c,leankor__ProjectFinancial__c,leankor__AssignedTo__r.IsActive From leankor__ResourceAssignments__r),'+
                                    'leankor__ValueStream__r.leankor__ProjectRoom__c, leankor__ValueStream__r.leankor__ScheduleBackward__c, leankor__valuestream__r.leankor__boardtype__c,leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c, leankor__ValueStreamLink__r.leankor__ProjectRoom__c,'+
                                                'leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,RecordType.Name ';
                            

            for (String customField : fieldMapKanbanCardForClone.keySet()) {
                customFields =  customFields + customField +',';					
            }   

            query = 'Select '+ customFields + sObjectFields + relatedsObjects + ' From leankor__KanbanCard__c where leankor__ValueStream__c =\'' + String.escapeSingleQuotes(this.valueStream.Id) + '\' And leankor__IsRecordDeleted__c = False And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False Limit 10000';  			  				
        } else {
            query = 'Select Id From leankor__ValueStream__c Where Id =\'' + String.escapeSingleQuotes(this.valueStream.Id) + '\' Limit 1'; 
        }
        return Database.getQueryLocator(query);
    }

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    The execute method is called for each batch of records.
	    Inputs:         Database.BatchableContext, List<sObject>
	    Returns:        No Output
	------------------------------------------------------------*/
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
		if (this.firstChunkExecution) {
            // Fetch ProjectRoom based on provided criteria
            leankor__ProjectRoom__c projectRoom;
            if (this.cloneProjectBoardRequest.relinkClonedProjectId != null) {
                projectRoom = [Select Id, 
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Id = :this.cloneProjectBoardRequest.relinkClonedProjectId 
                                    With Security_Enforced
                                    Limit 1];
            } else {
                String folderName = this.cloneProjectBoardRequest.targetFolderName != null && this.cloneProjectBoardRequest.targetFolderName != '' ? this.cloneProjectBoardRequest.targetFolderName : null;
                String tempProjectName = this.cloneProjectBoardRequest.projectRoom;
                String query = 'Select Id, Name From leankor__ProjectRoom__c Where Name = :tempProjectName';
                
                if (folderName != null) {
                    query += ' And leankor__Portfolio__r.name = :folderName';
                }
                
                projectRoom = Database.query(query + ' Limit 1');
            }
            // Fetch getProjectRoom based on provided criteria
            leankor__ProjectRoom__c getProjectRoom;
            if (this.cloneProjectBoardRequest.ProjectRoomId != null) {
                getProjectRoom = [Select Id, 
                                            Name 
                                        From leankor__ProjectRoom__c 
                                        Where Id = :this.cloneProjectBoardRequest.ProjectRoomId 
                                        With Security_Enforced
                                        Limit 1];
            } else {
                String folderName = this.cloneProjectBoardRequest.FolderName != null && this.cloneProjectBoardRequest.FolderName != '' ? this.cloneProjectBoardRequest.FolderName : null;
                String tempProjectRoom = this.cloneProjectBoardRequest.sourceProjectName;
                String query = 'Select Id, Name From leankor__ProjectRoom__c Where Name = :tempProjectRoom';
                
                if (folderName != null) {
                    query += ' And leankor__Portfolio__r.name = :folderName';
                }
                getProjectRoom = Database.query(query + ' Limit 1');
            }
            // Fetch boardToBeClone based on provided criteria
            leankor__ValueStream__c boardToBeClone;
            String queryBoard = 'Select Id From leankor__ValueStream__c Where ';
            
            if (this.cloneProjectBoardRequest.ProjectBoardId != null) {
                String tempProjectBoardId = this.cloneProjectBoardRequest.projectBoardId;
                queryBoard += 'Id = :tempProjectBoardId';
            } else {
                String projectBoard = this.cloneProjectBoardRequest.ProjectBoard;
                queryBoard += 'Name = :projectBoard';
            }
            
            Id projectRoomId = getProjectRoom.Id;
            queryBoard += ' And leankor__ProjectRoom__c = :projectRoomId Limit 1';
            
            boardToBeClone = Database.query(queryBoard);

            leankor.RealTimeController.ProjectBoardClone tempBoard = New leankor.RealTimeController.ProjectBoardClone();
            tempBoard.PrjName = this.cloneProjectBoardRequest.targetBoard;
            tempBoard.ProjectRoomId = projectRoom.Id;
            tempBoard.ParentVS = boardToBeClone.Id;
            tempBoard.Isrecalculate = true;

            leankor__ValueStream__c  newProjectBoard = leankor.RealTimeController.createProjectBoard(TempBoard);
            this.boardData.newValueStreamId = newProjectBoard.Id;
            this.boardData.sourceValueStreamId = boardToBeClone.Id;
            this.boardData.kanbanTemplateVerb = true;
            this.boardData.boardType = newProjectBoard.leankor__BoardType__c;
            this.boardData.zoneVerb = this.cloneProjectBoardRequest.zoneVerb == false ? false : true ;
            this.boardData.kanbanVerb = this.cloneProjectBoardRequest.kanbanVerb;
            this.boardData.taskVerb = this.cloneProjectBoardRequest.taskVerb;
            this.boardData.stickerVerb =  this.cloneProjectBoardRequest.stickerVerb;
            this.boardData.markerVerb =  this.cloneProjectBoardRequest.markerVerb;
            this.boardData.chartVerb =  this.cloneProjectBoardRequest.chartVerb;
            this.boardData.cloneFiles =  this.cloneProjectBoardRequest.cloneFiles;
            this.boardData.cloneCustomFields = this.cloneProjectBoardRequest.cloneCustomFields;
            this.boardData.LinkCloneVSID = '';

            this.boardData = CloneProjectPlanGanttBatch.createBoardData(this.boardData);
            if (this.cloneProjectBoardRequest.targetProjectStartDateTime != null) {
                if (!this.boardData.workWeek.isWorkingDay(this.cloneProjectBoardRequest.targetProjectStartDateTime.format('EEEE')) && this.valueStream.leankor__SevenDayWorkWeek__c == false) {
                    this.cloneProjectBoardRequest.initialDate = this.cloneProjectBoardRequest.targetProjectStartDateTime+1;
                    if (!this.boardData.workWeek.isWorkingDay(this.cloneProjectBoardRequest.initialDate.format('EEEE'))) {
                        this.cloneProjectBoardRequest.initialDate = this.cloneProjectBoardRequest.initialDate+1;           	 
                    }
                } else {
                    this.cloneProjectBoardRequest.initialDate = this.cloneProjectBoardRequest.targetProjectStartDateTime;
                }       
            } 
    
           if (this.cloneProjectBoardRequest.targetProjectDueDateTime != null) {
                if (!this.boardData.workWeek.isWorkingDay(this.cloneProjectBoardRequest.targetProjectDueDateTime.format('EEEE')) && this.valueStream.leankor__SevenDayWorkWeek__c == false) {
                    this.cloneProjectBoardRequest.targetDate = this.cloneProjectBoardRequest.targetProjectDueDateTime-1;
                    if (!this.boardData.workWeek.isWorkingDay(this.cloneProjectBoardRequest.targetDate.format('EEEE'))) {
                        this.cloneProjectBoardRequest.targetDate = this.cloneProjectBoardRequest.targetDate-1;            	 
                    }
                } else {
                    this.cloneProjectBoardRequest.targetDate = this.cloneProjectBoardRequest.targetProjectDueDateTime;
                }
            }    
    
            if (this.cloneProjectBoardRequest.initialDate != null ) {
                this.boardData.FinalStartDate = JSON.Serialize(this.cloneProjectBoardRequest.initialDate);
            } else if (this.cloneProjectBoardRequest.targetDate != null ) {
                this.boardData.FinalDate = JSON.Serialize(this.cloneProjectBoardRequest.targetDate);
            } else {
                this.boardData.FinalStartDate = JSON.Serialize(system.now());
            }
            
            this.firstChunkExecution = false;
        } 

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        if (scope instanceOf List<leankor__kanbanCard__c>) { 
            this.chunkCount++;
            kanbanCards.addAll((List<leankor__kanbanCard__c>)scope);
            this.boardData.sourceProjectId = this.cloneProjectBoardRequest.sourceProjectId;
            CloneProjectPlanGanttBatch.KanbanCardResponse kanbanCardResponse  = CloneProjectPlanGanttBatch.cloneKanbanCards(this.boardData, kanbanCards);
            
            if (this.boardData.stickerVerb == true) {
                CloneProjectRemainingRecord.cloneCardsSticker(kanbanCardResponse.kanbanCardIdsForSticker, kanbanCardResponse.mapWithOldKanbanCard);
            }
            
            if (boardData.stickerVerb == true && boardData.boardType != 'UberBoard') {
                CloneProjectPlanGanttBatch.cloneStickers(boardData);
            }
            
            if (boardData.markerVerb == true && boardData.boardType != 'UberBoard') {
                CloneProjectPlanGanttBatch.cloneMarkers(boardData);   
            }
             
            if (boardData.chartVerb == true && boardData.boardType != 'UberBoard') {
                CloneProjectPlanGanttBatch.cloneCharts(boardData);
            }
            if (boardData.cloneFiles!=null && boardData.cloneFiles) {
                CloneProjectPlanGanttBatch.cloneFiles(boardData, kanbanCardResponse.mapWithOldKanbanCard);
            } 
            if (this.totalChunks == this.chunkCount) {
                CloneProjectBoardAction.linkKanbanCards(this.boardData.newValueStreamId);
            }
        }
    }

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    The finish method is called after all batches have been processed.
	    Inputs:         Database.BatchableContext
	    Returns:        No Output
	------------------------------------------------------------*/
    public void finish(Database.BatchableContext batchableContext) {
        // Perform any final actions like sending a notification
        CloneProjectPlanGanttBatch.cloneDependency(this.boardData);
        processAfterBoardCloningDone(this.boardData);
    }

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    In this method processing to link folder Id to the project if project cloned successfully. 
	    Inputs:         BoardData inner class
	    Returns:        No output
	------------------------------------------------------------*/
    @TestVisible   
    private void processAfterBoardCloningDone(CloneProjectPlanGanttBatch.BoardData boardData) {
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

        Integer projectCardCount = [Select count()
                                        From leankor__KanbanCard__c 
                                        Where leankor__ValueStream__r.leankor__ProjectRoom__c =: this.cloneProjectBoardRequest.relinkClonedProjectId 
                                            And leankor__BoardType__c In: this.cloneProjectBoardRequest.projectBoardTypes
                                            And leankor__IsRecordDeleted__c = FALSE 
                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                        With Security_Enforced];

        Integer boardCount = [Select count()
                                From leankor__ValueStream__c
                                Where leankor__ProjectRoom__c =: this.cloneProjectBoardRequest.relinkClonedProjectId  
                                    And leankor__BoardType__c In: this.cloneProjectBoardRequest.projectBoardTypes
                                    And leankor__IsRecordDeleted__c = False
                                With Security_Enforced];

        
        List<leankor__ProjectRoom__c> createdProjects = [Select Id,
                                                                leankor__Portfolio__c
                                                            From leankor__ProjectRoom__c
                                                            Where Id =: this.cloneProjectBoardRequest.relinkClonedProjectId
                                                                And leankor__Portfolio__c =: this.cloneProjectBoardRequest.targetFolderId
                                                            With Security_Enforced
                                                            Limit 1];

        if (this.cloneProjectBoardRequest.totalCardsOfSourceProjectBoards == projectCardCount && this.cloneProjectBoardRequest.totalNumberOfSourceProjectBoards == boardCount) {   
            reLinkProject(this.cloneProjectBoardRequest);
        }
        // Making sure this code will execute once.
        if (createdProjects.isEmpty()) {
            //updating projectroom parent portfolio ID 
            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
            project.leankor__Portfolio__c = this.cloneProjectBoardRequest.targetFolderId;
            project.Id = this.cloneProjectBoardRequest.relinkClonedProjectId;   

            try {
                update project;   
                List<leankor__Expense__c> expenseList = new List<leankor__Expense__c>();
                for (leankor__Expense__c ex : [Select leankor__Portfolio__c 
                                                    From leankor__Expense__c 
                                                    Where leankor__Project__c = :this.cloneProjectBoardRequest.relinkClonedProjectId
                                                    With Security_Enforced]) {           
                    ex.leankor__Portfolio__c = this.cloneProjectBoardRequest.targetFolderId;
                    expenseList.add(ex);                        
                }
            
                if (expenseList.size() > 0) {
                    update expenseList;
                } 
            } catch(DMLException ex) {
                throw new CloneProjectBoardBatchException(ex.getMessage());
            }  

            try {
                //------------------- BEGIN platform event broadcast
                leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
                
                pe.leankor__EventCategory__c = 'Cloning';
                pe.leankor__EventName__c = 'EndClone';
                pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                pe.leankor__ProjectID__c = this.cloneProjectBoardRequest.relinkClonedProjectId;
                pe.leankor__UserID__c = UserInfo.getUserId();
                pe.leankor__CustomPayload__c = this.cloneProjectBoardRequest.projectEventCustomPayload;
        
                // Call method to publish events
                Database.SaveResult peResult = EventBus.publish(pe);
        
                if (!peResult.isSuccess()) {
                    for (Database.Error err : peResult.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }         
                //------------------- END platform event broadcast  
                // this method is calling for broadcast
                List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(CloneProjectPlanGanttBatch.getMaxDateOfBoard(this.cloneProjectBoardRequest.relinkClonedProjectId));
                portfolioresult[0].verb = 'CloneProject';
                leankor.realtimeKanbanController.manageNavChange('LeankorNAV', JSON.serialize(portfolioresult[0]), this.cloneProjectBoardRequest.sessionID);   
            } catch(Exception ex) {
                System.debug('ERROR :: '+ex.getMessage());
            } 
        }
    }

    public static void reLinkProject(CloneProjectBoardRequest request) { 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!valueStreamBehavior.isAccessible() ||
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
        List<leankor__ValueStream__c> valuestreamList = new List<leankor__ValueStream__c>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        List<leankor__ValueStream__c> newKanbanBoards = 
            [Select Id,
                    leankor__ValueStreamCardLink__c,
                    leankor__ValueStreamLink__c,
                    leankor__ProjectRoomLink__c,
                    leankor__BoardType__c                 
                From leankor__ValueStream__c
                Where leankor__ProjectRoom__c =:request.relinkClonedProjectId
                With Security_Enforced];

        for (leankor__ValueStream__c newKanbanBoard : newKanbanBoards){   
            if (String.isNotBlank(newKanbanBoard.leankor__ValueStreamCardLink__c) || 
                String.isNotBlank(newKanbanBoard.leankor__ValueStreamLink__c) || 
                String.isNotBlank(newKanbanBoard.leankor__ProjectRoomLink__c)) {
                newKanbanBoard.leankor__ValueStreamCardLink__c = null;
                newKanbanBoard.leankor__ValueStreamLink__c = null;
                newKanbanBoard.leankor__ProjectRoomLink__c = null;
                valuestreamList.add(newKanbanBoard);                
            }
            
            if (newKanbanBoard.leankor__BoardType__c == 'UberBoard') {
            	PlanGanttId = newKanbanBoard.Id;
            }
            if (newKanbanBoard.leankor__BoardType__c == 'Plan Board') {
                PlanBoardId = newKanbanBoard.Id;
            }
        }
                
        List<leankor__KanbanCard__c> newKanbanCards = leankor.RealTimeControllerHelper.reLinkProject_Helper(request.relinkClonedProjectId);
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();  
        
        for (leankor__KanbanCard__c newKanbanCard: newKanbanCards) {
            String kanbanCardGUID = (newKanbanCard.leankor__GUID__c).SubStringBefore('-');
            if (String.isNotBlank(kanbanCardGUID)) {
                targetKanbanCards.put(kanbanCardGUID, newKanbanCard);
            }
        } 
 
        
        List<Id> cardLinkIds = new List<Id>();
        for (leankor__KanbanCard__c newKanbanCard : newKanbanCards) {               
            if (String.isBlank(newKanbanCard.leankor__ValueStreamCardLink__c)) {
              if(String.isNotBlank(newKanbanCard.leankor__ValueStreamLink__c)) {
                    if(newKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c == 'UberBoard' && newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == request.projectRoomId) {
                    	newKanbanCard.leankor__ValueStreamLink__c = PlanGanttId;
                    }else if(newKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c == 'Plan Board' && newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == request.projectRoomId) {
                    	newKanbanCard.leankor__ValueStreamLink__c = PlanBoardId;
                    }else {               
                        newKanbanCard.leankor__ValueStreamLink__c = null;
                    }
                    kanbanCardList.add(newKanbanCard);
                }
            } else if(newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c != request.relinkClonedProjectId && newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c != request.projectRoomId){
                newKanbanCard.leankor__ValueStreamCardLink__c = null;
                newKanbanCard.leankor__ValueStreamLink__c = null;
                kanbanCardList.add(newKanbanCard);
            } else {
                if (newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__c == newKanbanCard.leankor__ValueStreamLink__c &&
                    newKanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c) {
                    leankor__KanbanCard__c targetKanbanCard = targetKanbanCards.get(newKanbanCard.leankor__ValueStreamCardLink__c);
                    if (targetKanbanCard != emptyKanbanCard && targetKanbanCard != null) {   
                        newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCard.Id;
                        newKanbanCard.leankor__ValueStreamLink__c = targetKanbanCard.leankor__ValueStream__c;                                                                                       
                    } 
                    if(newKanbanCard.leankor__ValueStreamCardLink__r.leankor__BoardType__c != 'UberBoard'){
                    	cardLinkIds.add(newKanbanCard.leankor__ValueStreamCardLink__c);
                    }
                    kanbanCardList.add(newKanbanCard);
                }
            }                                
        }
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
        update valuestreamList;
        update kanbanCardList;
        leankor.ProjectBoardCarousel.updateActivityPercentageComplete(cardLinkIds);
    }
    
    public class CloneProjectBoardBatchException extends Exception {}
}