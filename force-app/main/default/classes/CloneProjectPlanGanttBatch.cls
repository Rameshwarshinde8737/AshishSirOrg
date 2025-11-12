/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-11-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CloneProjectPlanGanttBatch implements Database.Batchable<sObject>, Database.Stateful{

    @TestVisible
    private CloneProjectBoardBatch.CloneProjectBoardRequest cloneProjectBoardRequest;
    @TestVisible
    private leankor__valueStream__c valueStream;
    @TestVisible
    private CloneProjectProcessAction.CloneProjectRequest requestInstance;
    @TestVisible
    private Boolean firstChunkExecution = true;
    @TestVisible
    private static leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
    @TestVisible
    private BoardData boardData = new BoardData();
    public static final Integer BATCHCHUNKSIZE_CONST = 200;
    public Integer totalChunks = 0;
    public Integer chunkCount = 0;
    public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};


    // Parameterized constructor
    public CloneProjectPlanGanttBatch(CloneProjectBoardBatch.CloneProjectBoardRequest cloneProjectBoardRequest, leankor__valueStream__c valueStream, CloneProjectProcessAction.CloneProjectRequest requestInstance) {
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
            Map<String, String> templateIDs = new  Map<String,String>();
            CloneProjectBoardBatch.CloneProjectBoardRequest cloneRequest = this.cloneProjectBoardRequest;

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
                String folderName = this.cloneProjectBoardRequest.TargetFolderName != null && this.cloneProjectBoardRequest.TargetFolderName != '' ? this.cloneProjectBoardRequest.TargetFolderName : null;
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
                String tempProjectRoom = cloneRequest.ProjectRoom;
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
                String projectBoard = cloneRequest.ProjectBoard;
                queryBoard += 'Name = :projectBoard';
            }
            
            Id projectRoomId = getProjectRoom.Id;
            queryBoard += ' And leankor__ProjectRoom__c = :projectRoomId Limit 1';
            
            boardToBeClone = Database.query(queryBoard);

            leankor.RealTimeController.ProjectBoardClone tempBoard = New leankor.RealTimeController.ProjectBoardClone();
            tempBoard.PrjName = this.cloneProjectBoardRequest.TargetBoard;
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
            this.boardData.linkCloneVSID = '';
            this.boardData.oldStartDateTime = newProjectBoard.leankor__ProjectBoardStartDateTime__c;
            this.boardData.oldEndDateTime = newProjectBoard.leankor__ProjectBoardEndDateTime__c;
            this.boardData = createBoardData(this.boardData);
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
                    this.cloneProjectBoardRequest.TargetDate = this.cloneProjectBoardRequest.targetProjectDueDateTime-1;
                    if (!this.boardData.workWeek.isWorkingDay(this.cloneProjectBoardRequest.TargetDate.format('EEEE'))) {
                        this.cloneProjectBoardRequest.TargetDate = this.cloneProjectBoardRequest.TargetDate-1;            	 
                    }
                } else {
                    this.cloneProjectBoardRequest.TargetDate = this.cloneProjectBoardRequest.targetProjectDueDateTime;
                }
            }    
            
            if (this.cloneProjectBoardRequest.initialDate != null ) {
                this.boardData.FinalStartDate = JSON.Serialize(this.cloneProjectBoardRequest.initialDate);
            } else if (this.cloneProjectBoardRequest.TargetDate != null) {
                this.boardData.finalDate = JSON.Serialize(this.cloneProjectBoardRequest.TargetDate);
            } else {
                this.boardData.finalStartDate = JSON.Serialize(System.now());
            }
            this.firstChunkExecution = false;

        } 

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        if (scope instanceOf List<leankor__kanbanCard__c>) { 
            this.chunkCount++;
            kanbanCards.addAll((List<leankor__kanbanCard__c>)scope);
            KanbanCardResponse kanbanCardResponse  = cloneKanbanCards(this.boardData, kanbanCards);

           
            
            if (this.boardData.stickerVerb == true) {
                CloneProjectRemainingRecord.cloneCardsSticker(kanbanCardResponse.kanbanCardIdsForSticker, kanbanCardResponse.mapWithOldKanbanCard);
            }
            
            if (boardData.stickerVerb == true && boardData.boardType != 'UberBoard') {
                cloneStickers(boardData);
            }
            
            if (boardData.markerVerb == true && boardData.boardType != 'UberBoard') {
                cloneMarkers(boardData);   
            }
             
            if (boardData.chartVerb == true && boardData.boardType != 'UberBoard') {
                cloneCharts(boardData);
            }
            
            if (boardData.cloneFiles!=null && boardData.cloneFiles) {
                cloneFiles(boardData , kanbanCardResponse.mapWithOldKanbanCard);
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
        String sourceValueStreamId = boardData.sourceValueStreamId;
        String targetValueStream = boardData.newValueStreamId;
        DateTime oldMinimumStart = boardData.oldMinimumStart;
        DateTime oldMaximumStart = boardData.oldMaximumStart;
        Util.WorkWeek workWeek = boardData.workWeek; 
        List<DateTime> dateList = new List<DateTime>();
        dateList = boardData.dateList;
        DateTime oldStartDateTime =  boardData.oldStartDateTime; 
        DateTime oldEndDateTime = boardData.oldEndDateTime;
        String finalStartDate = boardData.FinalStartDate;
        String finalDate = boardData.finalDate;


        
        // Perform any final actions like sending a notification
        cloneDependency(boardData);
        List<leankor__ValueStream__c> asynchCloneProjectBoards = this.cloneProjectBoardRequest.projectBoardTypes.isEmpty() ? new List<leankor__ValueStream__c>() : CloneProjectProcessAction.readProjectBoards(this.cloneProjectBoardRequest.projectRoomId, new Set<String>(this.cloneProjectBoardRequest.projectBoardTypes));
        
        for (leankor__ValueStream__c asynchCloneProjectBoard : asynchCloneProjectBoards) {      
                
            this.cloneProjectBoardRequest.ProjectBoard = asynchCloneProjectBoard.Name;
            this.cloneProjectBoardRequest.ProjectBoardId = asynchCloneProjectBoard.Id;
            if (asynchCloneProjectBoard.leankor__BoardType__c == 'Plan Board') {
                this.cloneProjectBoardRequest.TargetBoard = 'Roll-Up (' + this.cloneProjectBoardRequest.projectRoom + ')';
            } else if (asynchCloneProjectBoard.leankor__BoardType__c == 'DashBoard' && asynchCloneProjectBoard.Name == asynchCloneProjectBoard.leankor__ProjectRoom__r.Name + ' DashBoard') {
                this.cloneProjectBoardRequest.TargetBoard = this.cloneProjectBoardRequest.projectRoom + ' DashBoard';
            } else {
                this.cloneProjectBoardRequest.TargetBoard = asynchCloneProjectBoard.Name;
            }
            
            // Truncate if necessary
            this.cloneProjectBoardRequest.TargetBoard = CloneProjectProcessAction.truncateTargetBoard(this.cloneProjectBoardRequest.TargetBoard);

            this.cloneProjectBoardRequest.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;     
            CloneProjectBoardBatch cloneProjectBoardBatch = new CloneProjectBoardBatch(this.cloneProjectBoardRequest, asynchCloneProjectBoard, requestInstance);
            Database.executeBatch(cloneProjectBoardBatch, 200);
        } 
        updateProjectBoardStartAndEnddate(sourceValueStreamId,targetValueStream,oldMinimumStart,oldMaximumStart, workWeek,dateList,oldStartDateTime,oldEndDateTime,finalStartDate,finalDate);

        if(this.cloneProjectBoardRequest.projectBoardTypes.size() == 0) {
            processAfterBoardCloningDone(this.boardData);
        }
    }

    
    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Prepare Board Data.
	    Inputs:         BoardData inner class
	    Returns:        BoardData inner class
	------------------------------------------------------------*/
    public static BoardData createBoardData(BoardData boardData) {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        List<leankor__Zone__c> tempZoneList = new List<leankor__Zone__c>();
        List<leankor__ValueStream__c> valueStreamRecord = new List<leankor__ValueStream__c>();
        Map<String,String> zoneGUIDs = new  Map<String,String>();// Collection of zone guid old and new for clone Cards.
        Map<String,String> masterContainerForceIDs = new  Map<String,String>();// Collection of MC IDs old and new for clone Cards.
        Map<String,String> newMCForceIDs = new  Map<String,String>();// Collection of MC IDs old and new for clone Cards.
        Map<String,String> swimlaneForceIDs = new  Map<String,String>();// Collection of SW IDs old and new for clone Cards.
        Map<String,String> newSWForceIDs = new  Map<String,String>();// Collection of SW IDs old and new for clone Cards.
        Map<String,String> zoneForceIDs = new  Map<String,String>();// Collection of zone ID old and new for clone Cards.

        Map<String,String> newZoneForceIDs = new  Map<String,String>();// Collection of zone ID old and new for clone Cards.

        ValueStreamData valueStreamData = setValueStreamAndZoneData(boardData, tempZoneList, valueStreamRecord);

        tempZoneList = valueStreamData.tempZoneList;
        valueStreamRecord = valueStreamData.valueStreamRecord;

        if (valueStreamRecord.size() > 0) {
            Savepoint newSavepoint = Database.setSavepoint();
            try {
                if (boardData.BoardType == 'Kanban Board' || boardData.BoardType == 'Plan Board') {
                    //Moved here while HeapSize issue
                    List<leankor.MasterContainer> newMasterContainers = new List<leankor.MasterContainer>();
                    List<leankor.Swimlane> newSwimlanes = new List<leankor.Swimlane>();
                    List<leankor.Zone> newZones = new List<leankor.Zone>();                	               	
                    for (leankor__MasterContainer__c serverMasterContainer : valueStreamRecord[0].leankor__Master_Containers__r) {                  
                        leankor.MasterContainer localMasterContainer = new leankor.MasterContainer(boardData.newValueStreamId, serverMasterContainer);
                        newMasterContainers.add(localMasterContainer);
                        masterContainerForceIDs.put(localMasterContainer.guid, serverMasterContainer.id);
                    }

                    for (leankor__MasterContainer__c serverMasterContainer : leankor.MasterContainer.createMasterContainers(newMasterContainers)) {
                        newMCForceIDs.put(masterContainerForceIDs.get(serverMasterContainer.leankor__GUID__c),serverMasterContainer.id);
                        for (leankor__Swimlane__c serverSwimlane : valueStreamRecord[0].leankor__Swimlanes__r) {
                            if (serverMasterContainer.leankor__GUID__c.contains(serverSwimlane.leankor__MasterContainer__c)) {
                                leankor.Swimlane localSwimlane = new leankor.Swimlane(boardData.newValueStreamId, serverMasterContainer.id, serverSwimlane);
                                newSwimlanes.add(localSwimlane);
                                swimlaneForceIDs.put(localSwimlane.guid, serverSwimlane.id);
                            }
                        }
                    }
                    
                    //masterContainerForceIDs.clear();
                    //newMasterContainers.clear();
                
                    for (leankor__Swimlane__c serverSwimlane : leankor.Swimlane.createSwimlanes(newSwimlanes)) {
                        newSWForceIDs.put(swimlaneForceIDs.get(serverSwimlane.leankor__GUID__c), serverSwimlane.id);
                        for (leankor__Zone__c serverZone : tempZoneList) {
                            if ((serverSwimlane.leankor__GUID__c).contains(serverZone.leankor__Swimlane__c)) {
                                leankor.Zone localZone = new leankor.Zone(boardData.newValueStreamId, serverSwimlane.id, serverZone);
                                newZones.add(localZone);
                                zoneForceIDs.put(localZone.guid, serverZone.id);
                                zoneGUIDs.put(serverZone.leankor__GUID__c, localZone.guid); // preparing collection of zone guid old and new for clone Cards.
                            }
                        }
                    }
                   // newSwimlanes.clear();
                    //tempZoneList.clear(); 
                    leankor.Zone.createZones(newZones);
                    //newZones.clear();
                    // End of KanbanBoard clone for MC, Swimlane, Zone.

                } else if (boardData.BoardType == 'Whiteboard' || boardData.BoardType== 'DashBoard') {
                    if (valueStreamRecord[0].leankor__Zones__r.size() > 0 && boardData.ZoneVerb == true) {
                        //Changes for HeapSize reducing
                        List<leankor.RealTimeController.Zone> remoteZones = new List<leankor.RealTimeController.Zone>();
                        for (leankor__Zone__c zone : valueStreamRecord[0].leankor__Zones__r) {
                            leankor.RealTimeController.Zone remoteZone = new leankor.RealTimeController.Zone();
                            remoteZone.GUID = zone.Id+'-'+boardData.newValueStreamId+'-z';
                            remoteZone.Title = zone.leankor__Title__c;
                            remoteZone.Top = zone.leankor__Top__c;
                            remoteZone.UrlLink = zone.leankor__UrlLink__c;
                            remoteZone.Bottom = zone.leankor__Bottom__c;
                            remoteZone.Left = zone.leankor__Left__c;
                            remoteZone.Width = zone.leankor__Width__c;
                            remoteZone.Height = zone.leankor__Height__c;
                            remoteZone.X = zone.leankor__X__c;
                            remoteZone.Y = zone.leankor__Y__c;
                            remoteZone.EntryFlowName = zone.leankor__EntryFlowName__c;
                            remoteZone.ExitFlowName = zone.leankor__ExitFlowName__c;
                            remoteZone.ZoneMode = zone.leankor__zoneMode__c;
                            remoteZone.KanbanSequence = zone.leankor__kanbanSequence__c;
                            remoteZone.ValueStreamLinkID = zone.leankor__ValueStreamLink__c;
                            remoteZone.ValueStreamCardLink = zone.leankor__ValueStreamCardLink__c;
                            remoteZone.DefaultWidth  = zone.leankor__DefaultWidth__c;
                            remoteZone.DefaultHeight = zone.leankor__DefaultHeight__c;
                            remoteZone.ZoneStatus = zone.leankor__CaseStatus__c ;
                            remoteZone.ZoneOpportunityStage = zone.leankor__OpportunityStageName__c ;
                            remoteZone.CardsPerRow = zone.leankor__CardsPerRow__c;
                            remoteZone.Help = zone.leankor__Help__c;
                            remoteZone.TaskLimit = zone.leankor__Limit__c;
                            remoteZone.Order = (zone.leankor__Order__c == null ? 0 : zone.leankor__Order__c);
                            remoteZone.ParentZone = '';
                            remoteZone.Swimlane = '';
                            remoteZones.add(remoteZone);
                            zoneForceIDs.put(remoteZone.GUID, zone.Id);
                            zoneGUIDs.put(zone.leankor__GUID__c, remoteZone.GUID);                 
                        }    
                        RealTimeController.createZone(boardData.newValueStreamId, remoteZones);
                        //remoteZones.clear();
                    }
                }

                for (leankor__Zone__c zone :[Select Id, 
                                                    leankor__GUID__c 
                                                From leankor__Zone__c 
                                                Where leankor__ValueStream__c = :boardData.newValueStreamId 
                                                With Security_Enforced
                                                Limit 10000]) {
                    newZoneForceIDs.put(zoneForceIDs.get(zone.leankor__GUID__c),zone.Id);
                }
                boardData.newZoneForceIDs = newZoneForceIDs;
                //zoneForceIDs.clear();

                cloneProjectBoardWorkFieldSet(boardData);

                leankor__ValueStream__c newValueStream = readNewBoardData(boardData.newValueStreamId);

                KanbanCardTemplateData kanbanCardTemplateData = cloneKanbanCardTemplates(boardData, newValueStream);

                for (leankor__KanbanCardTemplate__c kanbanCardTemplate : kanbanCardTemplateData.cloneTemplates) {
                    String kanbanCardTemplateId = kanbanCardTemplate.leankor__Title__c;
                    kanbanCardTemplate.leankor__Title__c = kanbanCardTemplateData.templateIDs.get(kanbanCardTemplateId);
                    kanbanCardTemplateData.templateIDs.put(kanbanCardTemplateId, kanbanCardTemplate.Id); 
                }
                
                leankor.RealTimeControllerHelper.updateKanbanCardTemplateRecords(kanbanCardTemplateData.cloneTemplates);

                String cloneTemplateId = kanbanCardTemplateData.cloneTemplates[0].Id;
                //kanbanCardTemplateData.cloneTemplates.clear();
                if (kanbanCardTemplateData.updateVSdefaultKCT) {
                    leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = cloneTemplateId, Id = boardData.newValueStreamId);
                    DataBase.update(projectBoardupdate);
                }

                boardData.newValueStreamRecord  = cloneBoardAdditionalInfo(boardData,cloneTemplateId,kanbanCardTemplateData);

                List<leankor__ProjectScheduleBlackout__c> blackOutList = [Select leankor__EndDate__c,                                                                           
                                                                                    leankor__StartDate__c
                                                                                From leankor__ProjectScheduleBlackout__c
                                                                                Where leankor__ProjectBoard__c =: newValueStream.Id
                                                                                With Security_Enforced
                                                                                Limit 10000 ];
                Util.WorkWeek workWeek;
                Integer firstDayOfWeek;
                    
                //get First day number  of week
                firstDayOfWeek= leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0  || leanConstant.leankor__FirstDayOfTheWeek__c > 6?1:leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
                workWeek = new Util.WorkWeek(firstDayOfWeek, boardData.newValueStreamRecord.leankor__SevenDayWorkWeek__c? 7 : 5, blackOutList);

                boardData.workWeek = workWeek;
                boardData.templateIDs = kanbanCardTemplateData.templateIDs;
                boardData.zoneGUIDs = zoneGUIDs;
                boardData.newMCForceIDs = newMCForceIDs;
                boardData.newSWForceIDs = newSWForceIDs;

            } catch (Exception e) {
                throw e;
            }
        } 

        return boardData;
    }
    
    public class BoardData {
        public String newValueStreamId;
        public String sourceValueStreamId;
        public Boolean kanbanTemplateVerb;
        public String boardType;
        public Boolean zoneVerb;
        public String projectBoardLaunchDate;
        public Boolean kanbanVerb;
        public Boolean taskVerb;
        public Boolean cloneFiles;
        public Boolean markerVerb;
        public Boolean chartVerb;
        public Boolean isprojectclone;
        public String finalDate;
        public String finalStartDate;
        public String linkCloneKanbanCardID;
        public Boolean cloneCustomFields;
        public String linkCloneVSID;
        public Boolean stickerVerb;
        public leankor__ValueStream__c newValueStreamRecord;
        public leankor__ValueStream__c sourceValueStreamRecord;
        public Util.WorkWeek workWeek;
        public Map<String,String> templateIDs;
        public Map<String,String> zoneGUIDs;
        public Map<String,String> newMCForceIDs;
        public Map<String,String> newSWForceIDs;
        public Map<String,String> newZoneForceIDs;
        public Map<String, String> kanbanCardOldAndNewIdMap = new Map<String, String>();
        public DateTime newProjectBoardStartDate;
        public DateTime newProjectBoardEndDate;
        public DateTime oldProjectBoardStartDate;
        public DateTime oldProjectBoardEndDate;
        public DateTime oldMinimumStart;
        public DateTime oldMaximumStart;
        public DateTime oldStartDateTime; 
        public DateTime oldEndDateTime;
        public String sourceProjectId;
        public List<DateTime> dateList = new List<DateTime>();
    }

    public class ValueStreamData{
        List<leankor__Zone__c> tempZoneList;
        List<leankor__ValueStream__c> valueStreamRecord;
    }

    public class KanbanCardResponse{
        public List <Id> kanbanCardIdsForSticker;
        public Map<String,String> mapWithOldKanbanCard;
        DateTime newProjectBoardEndDate;
        DateTime newProjectBoardStartDate;
        
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Process to set Valuestream and Zone data.
	    Inputs:         BoardData, List<leankor__Zone__c>,List<leankor__ValueStream__c>
	    Returns:        ValueStreamData inner class
	------------------------------------------------------------*/
    @TestVisible
    private static ValueStreamData setValueStreamAndZoneData(BoardData boardData, List<leankor__Zone__c> tempZoneList,List<leankor__ValueStream__c> valueStreamRecord) {
        String query;
        ValueStreamData valueStreamData = new ValueStreamData();
        
            if (boardData.sourceValueStreamId == '') {
                
                valueStreamRecord = leankor.RealTimeControllerHelper.getVSForCloneSystemBoard_Helper(boardData.BoardType);
                
                if (valueStreamRecord.size() > 0) {
                    tempZoneList = getZones(new Set<String>{valueStreamRecord[0].Id});
                }       
            } else {
                String boardType = boardData.BoardType;
                Boolean isKanbanOrPlanBoard = boardType == 'Kanban Board' || boardType == 'Plan Board';
                String vsId = boardData.sourceValueStreamId;
            
                if (isKanbanOrPlanBoard || boardType == 'Whiteboard' || boardType == 'Dashboard') {
                    if (isKanbanOrPlanBoard) {
                        query = 'Select Id, Name, leankor__ProjectRoom__c, ' +
                                '(Select Id, leankor__CmpID__c, leankor__Color__c, leankor__GUID__c, leankor__Unit__c, leankor__Height__c, ' +
                                'leankor__IsCardAvailable__c, leankor__Left__c, leankor__Limit__c, leankor__Order__c, leankor__Title__c, ' +
                                'leankor__Top__c, leankor__Type__c, leankor__ValueStream__c, leankor__Width__c, Name, OwnerId ' +
                                'From leankor__ValueStream__c.leankor__Master_Containers__r), ' +
                                '(Select Id, leankor__CardPerRow__c, leankor__CmpID__c, leankor__Color__c, leankor__GUID__c, leankor__Height__c, ' +
                                'leankor__Help__c, leankor__IsCardAvailable__c, leankor__Left__c, leankor__Limit__c, leankor__MasterContainer__c, ' +
                                'leankor__Order__c, leankor__Title__c, leankor__Top__c, leankor__ValueStream__c, leankor__Width__c, Name, OwnerId, ' +
                                'leankor__Unit__c From leankor__ValueStream__c.leankor__Swimlanes__r) ' +
                                'From leankor__ValueStream__c Where Id = :vsId AND leankor__IsRecordDeleted__c = FALSE LIMIT 1';

                                tempZoneList = getZones(new Set<String>{vsId});
                    }
                    
                    if (boardType == 'Whiteboard' || boardType == 'Dashboard') {
                        query = 'Select Id, Name, leankor__ProjectRoom__c, ' +
                                '(Select Id, leankor__Bottom__c, leankor__UrlLink__c, leankor__CardsPerRow__c, leankor__CaseStatus__c, ' +
                                'leankor__CmpID__c, leankor__CompletionRateUnits__c, leankor__CompletionRate__c, leankor__CSSLayout__c, ' +
                                'leankor__DefaultHeight__c, leankor__DefaultWidth__c, leankor__EntryFlowName__c, leankor__ExitFlowName__c, ' +
                                'leankor__GUID__c, leankor__Height__c, leankor__Help__c, leankor__JSONDefinition__c, leankor__KanbanCardCount2__c, ' +
                                'leankor__KanbanCardThroughput__c, leankor__kanbanSequence__c, leankor__LeadTime__c, leankor__Left__c, leankor__Limit__c, ' +
                                'leankor__Order__c, leankor__ParentZone__c, leankor__Swimlane__c, leankor__Title__c, leankor__Top__c, ' +
                                'leankor__ValueStreamCardLink__c, leankor__ValueStreamLink__c, leankor__ValueStream__c, leankor__Width__c, leankor__X__c, ' +
                                'leankor__Y__c, leankor__zoneMode__c, leankor__ZoneTemplate__c, Name, OwnerId, leankor__Unit__c, ' +
                                'leankor__OpportunityStageName__c From leankor__ValueStream__c.leankor__Zones__r) ' +
                                'From leankor__ValueStream__c Where Id = :vsId And leankor__IsRecordDeleted__c = False Limit 1';
                    }
            
                    valueStreamRecord = Database.query(query);
            
                } else {
                    // Handle other board types if necessary, currently falls back to default VS query.
                    valueStreamRecord = [Select Id,
                                                Name,
                                                leankor__ProjectRoom__c, 
                                                (Select Id, 
                                                        leankor__CmpID__c,
                                                        leankor__Color__c, 
                                                        leankor__GUID__c, 
                                                        leankor__Unit__c, 
                                                        leankor__Height__c, 
                                                        leankor__IsCardAvailable__c, 
                                                        leankor__Left__c, 
                                                        leankor__Limit__c, 
                                                        leankor__Order__c, 
                                                        leankor__Title__c, 
                                                        leankor__Top__c, 
                                                        leankor__Type__c, 
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,
                                                        Name, 
                                                        OwnerId 
                                                    From leankor__ValueStream__c.leankor__Master_Containers__r),     
                                                (Select Id, 
                                                        leankor__CardPerRow__c, 
                                                        leankor__CmpID__c, 
                                                        leankor__Color__c, 
                                                        leankor__GUID__c, 
                                                        leankor__Height__c,
                                                        leankor__Help__c, 
                                                        leankor__IsCardAvailable__c, 
                                                        leankor__Left__c, 
                                                        leankor__Limit__c, 
                                                        leankor__MasterContainer__c,
                                                        leankor__Order__c, 
                                                        leankor__Title__c, 
                                                        leankor__Top__c, 
                                                        leankor__ValueStream__c, 
                                                        leankor__Width__c,
                                                        Name, OwnerId,
                                                        leankor__Unit__c
                                                    From leankor__ValueStream__c.leankor__Swimlanes__r)
                                        From leankor__ValueStream__c 
                                        Where Id = :vsId
                                            And leankor__IsRecordDeleted__c = FALSE 
                                        With Security_Enforced
                                        Limit 1];
                }
                
            }
    
            valueStreamData.tempZoneList = tempZoneList;
            valueStreamData.valueStreamRecord = valueStreamRecord;
            return valueStreamData;          
    }
    

    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Clone ProjectBoardWorkFieldSet records
	    Inputs:         BoardData inner class
	    Returns:        No Output
	------------------------------------------------------------*/
    public static void cloneProjectBoardWorkFieldSet(BoardData boardData) {
        ProjectBoardWorkFieldSetBehaviour projectBoardWorkFieldSetBehaviour = new projectBoardWorkFieldSetBehaviour();
        if (!projectBoardWorkFieldSetBehaviour.isAccessible() ||
            !projectBoardWorkFieldSetBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        List<leankor__ProjectBoardWorkFieldSet__c> newprojectBoardWorkFieldSet = new List<leankor__ProjectBoardWorkFieldSet__c>();
        List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSet = [Select Id,
                                                                                        Name,
                                                                                        leankor__FieldSetName__c,
                                                                                        leankor__ProjectBoard__c,
                                                                                        leankor__AutoCalculateTotals__c
                                                                                    From leankor__ProjectBoardWorkFieldSet__c
                                                                                    Where leankor__ProjectBoard__c =: boardData.sourceValueStreamId
                                                                                    With Security_Enforced];
        
        for (leankor__ProjectBoardWorkFieldSet__c singleRecord : projectBoardWorkFieldSet) {
            leankor__ProjectBoardWorkFieldSet__c newRecord = new leankor__ProjectBoardWorkFieldSet__c();
            newRecord.leankor__FieldSetName__c = singleRecord.leankor__FieldSetName__c;
            newRecord.leankor__ProjectBoard__c = boardData.newValueStreamId;
            newRecord.leankor__AutoCalculateTotals__c = singleRecord.leankor__AutoCalculateTotals__c;
            newprojectBoardWorkFieldSet.add(newRecord);
        }
        if (newprojectBoardWorkFieldSet.size() > 0) {
            insert newprojectBoardWorkFieldSet;
        }
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Read new board records.
	    Inputs:         ValueStream Id
	    Returns:        leankor__ValueStream__c object
	------------------------------------------------------------*/
    public static leankor__ValueStream__c readNewBoardData(Id valueStreamId) {
        return [Select Id,
                        leankor__projectroom__c,
                        leankor__SevenDayWorkWeek__c,
                        (Select Id 
                            From leankor__Kanban_Card_Templates__r),
                        leankor__TaskIndicator__c,
                        leankor__DefaultCategory__c,
                        leankor__ViewChatterOptions__c,
                        leankor__DisableCalendarView__c,
                        leankor__IsTemplateBoard__c,
                        leankor__DefaultOwnerID__c,
                        leankor__TaskDateCheck__c,
                        leankor__Effortindicator__c,
                        leankor__IsAgile__c,
                        leankor__DaysPerSprint__c,
                        leankor__PointPicklist__c,
                        leankor__SprintStartDate__c,
                        leankor__OpportunitySynchronization__c, 
                        leankor__OpportunityType__c, 
                        leankor__OpportunityCardCategory__c,
                        leankor__OpportunityRecordType__c,
                        leankor__OpportunityLeadSource__c,
                        leankor__OpportunityRoleId__c,
                        leankor__OpportunityRoleName__c,
                        leankor__CaseCardCategory__c,
                        leankor__CaseRecordType__c,
                        leankor__CaseSynchronization__c,
                        leankor__CaseType__c,
                        Name,
                        leankor__ProjectRoomLink__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        leankor__projectroom__r.Name 
                    From leankor__ValueStream__c 
                    Where Id = :valueStreamId
                    Limit 1]; 
    }

    @TestVisible
    private class KanbanCardTemplateData {
       @TestVisible
        List<leankor__KanbanCardTemplate__C> cloneTemplates;
        @TestVisible
        Map<String,String> templateIDs;
        @TestVisible
        Boolean updateVSdefaultKCT;
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    Process to clone KanbanCardTemplates records.
	    Inputs:         BoardData, leankor__ValueStream__c object
	    Returns:        KanbanCardTemplateData inner class
	------------------------------------------------------------*/
    public static KanbanCardTemplateData cloneKanbanCardTemplates(BoardData boardData, leankor__ValueStream__c newProjectBoard) {
        List<leankor__KanbanCardTemplate__c> cloneTemplates = new List<leankor__KanbanCardTemplate__c>();
        Map<String,String> templateIDs = new Map<String,String>();
        Boolean updateVSdefaultKCT = false;  

        if (boardData.KanbanTemplateVerb == true) {           
            
            List<leankor__KanbanCardTemplate__c> kanbanTempates = new List<leankor__KanbanCardTemplate__c>();
            if (boardData.sourceValueStreamId == '') {
                
                kanbanTempates = RealTimeControllerHelper.readkanbanCardTemplate();  
                
            } else {
                
                kanbanTempates =[ Select Id, 
                                            leankor__Color__c, 
                                            leankor__CSSLayout__c, 
                                            leankor__DerivedFrom__c, 
                                            leankor__Height__c, 
                                            leankor__JSONData__c, 
                                            leankor__JSONDefinition__c, 
                                            leankor__Title__c, 
                                            leankor__ValueStream__c, 
                                            leankor__Width__c, 
                                            Name, 
                                            OwnerId, 
                                            leankor__FieldSetName__c, 
                                            Owner.IsActive,
                                            leankor__WeekCalendar__c 
                                        From leankor__KanbanCardTemplate__c 
                                        Where leankor__ValueStream__c = :boardData.sourceValueStreamId 
                                        With Security_Enforced
                                        Limit 10000];
            }
            String newOwnerId;
            for (leankor__KanbanCardTemplate__c serverKanbanCardTemplate : kanbanTempates) {
                templateIDs.put(serverKanbanCardTemplate.Id, serverKanbanCardTemplate.leankor__Title__c);
                newOwnerId = serverKanbanCardTemplate.Owner.IsActive ? serverKanbanCardTemplate.OwnerId : UserInfo.getUserId() ; 
                leankor.KanbanCardTemplate localKanbanCardTemplate = new leankor.KanbanCardTemplate(boardData.newValueStreamId, newOwnerId, serverKanbanCardTemplate);
                localKanbanCardTemplate.setKanbanCardTemplate(localKanbanCardTemplate);               
                cloneTemplates.add(localKanbanCardTemplate.kanbanCardTemplate);
            }

            //kanbanTempates.clear();
            if (cloneTemplates.size() ==0) {
                leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
                template.leankor__JSONDefinition__c = '';
                template.leankor__JSONData__c = '';
                template.leankor__Width__c = 170;
                template.leankor__Height__c =120;
                template.leankor__CSSLayout__c = '';
                template.leankor__Color__c = '#bdbffc';
                template.leankor__ValueStream__c = boardData.newValueStreamId;
                template.Name = 'Default';
                template.leankor__Title__c = 'Default';
                updateVSdefaultKCT = true;
                cloneTemplates.add(template);
            }
            
            leankor.RealTimeControllerHelper.insertKanbanCardTemplateRecords(cloneTemplates);
            
        } 
        KanbanCardTemplateData kanbanCardTemplateData = new KanbanCardTemplateData();
        kanbanCardTemplateData.cloneTemplates = cloneTemplates;
        kanbanCardTemplateData.templateIDs = templateIDs;
        kanbanCardTemplateData.updateVSdefaultKCT = updateVSdefaultKCT;
        return kanbanCardTemplateData;
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    In this method processing to update ValueStream records and clone preferences.
	    Inputs:         BoardData, String cloneTemplateId, KanbanCardTemplateData kanbanCardTemplateData
	    Returns:        void
	------------------------------------------------------------*/
    @TestVisible
    private static leankor__ValueStream__c cloneBoardAdditionalInfo(BoardData boardData, String cloneTemplateId, KanbanCardTemplateData kanbanCardTemplateData) {
        PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();//for update VS parent method is already checking.
        if (!preferenceBehaviour.isAccessible() ||
            !preferenceBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        DateTime oldProjectBoardStartDate;
        Boolean issevendays = false; 
        Boolean newValueStreamtaskchecker = false;

        leankor__ValueStream__c newValueStream = [Select Id,
                                                        leankor__projectroom__c,
                                                        leankor__SevenDayWorkWeek__c,
                                                        (Select Id 
                                                            From leankor__Kanban_Card_Templates__r),
                                                        leankor__TaskIndicator__c,
                                                        leankor__DefaultCategory__c,
                                                        leankor__ViewChatterOptions__c,
                                                        leankor__DisableCalendarView__c,
                                                        leankor__IsTemplateBoard__c,
                                                        leankor__DefaultOwnerID__c,
                                                        leankor__TaskDateCheck__c,
                                                        leankor__Effortindicator__c,
                                                        leankor__IsAgile__c,
                                                        leankor__DaysPerSprint__c,
                                                        leankor__PointPicklist__c,
                                                        leankor__SprintStartDate__c,
                                                        leankor__OpportunitySynchronization__c, 
                                                        leankor__OpportunityType__c, 
                                                        leankor__OpportunityCardCategory__c,
                                                        leankor__OpportunityRecordType__c,
                                                        leankor__OpportunityLeadSource__c,
                                                        leankor__OpportunityRoleId__c,
                                                        leankor__OpportunityRoleName__c,
                                                        leankor__CaseCardCategory__c,
                                                        leankor__CaseRecordType__c,
                                                        leankor__CaseSynchronization__c,
                                                        leankor__CaseType__c,
                                                        Name,
                                                        leankor__ProjectRoomLink__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__projectroom__r.Name 
                                                    From leankor__ValueStream__c 
                                                    Where Id =: boardData.newValueStreamId 
                                                    Limit 1];
        if (boardData.sourceValueStreamId != '') {
            /**Here, Need to write code for update template values in new created Project Board using clone*/
            leankor__ValueStream__c sourceValueStream = [Select Id,
                                                                leankor__DisableTaskAsMiniature__c,
                                                                leankor__IsShowCategoryColor__c,
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__TaskIndicator__c,
                                                                leankor__PortfolioMode__c,
                                                                leankor__ViewChatterOptions__c,
                                                                leankor__DefaultCategory__c,
                                                                leankor__DisableCalendarView__c,
                                                                leankor__IsTemplateBoard__c,
                                                                leankor__DefaultOwnerID__c,
                                                                leankor__TaskDateCheck__c,
                                                                leankor__Effortindicator__c,
                                                                leankor__IsAgile__c,
                                                                leankor__DaysPerSprint__c,
                                                                leankor__PointPicklist__c,
                                                                leankor__SprintStartDate__c,
                                                                leankor__OpportunitySynchronization__c, 
                                                                leankor__OpportunityType__c, 
                                                                leankor__OpportunityCardCategory__c,
                                                                leankor__OpportunityRecordType__c,
                                                                leankor__OpportunityLeadSource__c,
                                                                leankor__OpportunityRoleId__c,
                                                                leankor__OpportunityRoleName__c, 
                                                                leankor__CaseCardCategory__c,
                                                                leankor__CaseRecordType__c,
                                                                leankor__CaseSynchronization__c,
                                                                leankor__CaseType__c,
                                                                Name,
                                                                leankor__ProjectRoomLink__c,
                                                                leankor__ValueStreamCardLink__c,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ProjectBoardStartDateTime__c,
                                                                leankor__ProjectBoardEndDateTime__c
                                                            From leankor__ValueStream__c 
                                                            Where Id =: boardData.sourceValueStreamId
                                                            Limit 1];
            
            
            //boardData.oldProjectBoardStartDate = sourceValueStream.leankor__ProjectBoardStartDateTime__c;
            //boardData.oldProjectBoardEndDate = sourceValueStream.leankor__ProjectBoardEndDateTime__c;                          
            newValueStream.leankor__CaseCardCategory__c = kanbanCardTemplateData.templateIDs.get(sourceValueStream.leankor__CaseCardCategory__c);
            newValueStream.leankor__CaseRecordType__c = sourceValueStream.leankor__CaseRecordType__c;
            newValueStream.leankor__CaseSynchronization__c = sourceValueStream.leankor__CaseSynchronization__c;
            newValueStream.leankor__CaseType__c = sourceValueStream.leankor__CaseType__c;
            newValueStream.leankor__SprintStartDate__c = (sourceValueStream.leankor__SprintStartDate__c == null ? null : sourceValueStream.leankor__SprintStartDate__c) ;
            newValueStream.leankor__PointPicklist__c = (sourceValueStream.leankor__PointPicklist__c == '' ? ((leanConstant.leankor__PointSequence__c == null || leanConstant.leankor__PointSequence__c == '') ?'[]' :leanConstant.leankor__PointSequence__c) :sourceValueStream.leankor__PointPicklist__c) ;
            newValueStream.leankor__DaysPerSprint__c = (sourceValueStream.leankor__DaysPerSprint__c == null ? null : sourceValueStream.leankor__DaysPerSprint__c);
            newValueStream.leankor__IsAgile__c = (sourceValueStream.leankor__IsAgile__c == null ?false :sourceValueStream.leankor__IsAgile__c);
            newValueStream.leankor__Effortindicator__c = ((sourceValueStream.leankor__Effortindicator__c == '' || sourceValueStream.leankor__Effortindicator__c == Null) ? 'Days' :sourceValueStream.leankor__Effortindicator__c);
            newValueStream.leankor__TaskDateCheck__c = sourceValueStream.leankor__TaskDateCheck__c;          
            newValueStreamtaskchecker = newValueStream.leankor__TaskDateCheck__c;
            newValueStream.leankor__OpportunitySynchronization__c = sourceValueStream.leankor__OpportunitySynchronization__c;
            newValueStream.leankor__OpportunityType__c = sourceValueStream.leankor__OpportunityType__c;
            newValueStream.leankor__OpportunityCardCategory__c = kanbanCardTemplateData.templateIDs.get(sourceValueStream.leankor__OpportunityCardCategory__c);
            newValueStream.leankor__OpportunityRecordType__c = sourceValueStream.leankor__OpportunityRecordType__c;
            newValueStream.leankor__OpportunityLeadSource__c = sourceValueStream.leankor__OpportunityLeadSource__c;
            newValueStream.leankor__OpportunityRoleId__c  = sourceValueStream.leankor__OpportunityRoleId__c;
            newValueStream.leankor__OpportunityRoleName__c = sourceValueStream.leankor__OpportunityRoleName__c;
            
            newValueStream.leankor__DefaultCategory__c = cloneTemplateId;
            newValueStream.leankor__DisableCalendarView__c = sourceValueStream.leankor__DisableCalendarView__c;
            
            newValueStream.leankor__DefaultOwnerID__c = sourceValueStream.leankor__DefaultOwnerID__c;
            newValueStream.leankor__PortfolioMode__c = sourceValueStream.leankor__PortfolioMode__c;
            newValueStream.leankor__DisableTaskAsMiniature__c = sourceValueStream.leankor__DisableTaskAsMiniature__c;
            newValueStream.leankor__TaskIndicator__c = sourceValueStream.leankor__TaskIndicator__c;
            newValueStream.leankor__SevenDayWorkWeek__c = sourceValueStream.leankor__SevenDayWorkWeek__c;
            newValueStream.leankor__ViewChatterOptions__c = sourceValueStream.leankor__ViewChatterOptions__c;
            newValueStream.leankor__IsShowCategoryColor__c = sourceValueStream.leankor__IsShowCategoryColor__c;
            newValueStream.leankor__ProjectBoardLaunchDateTime__c = String.isNotBlank(boardData.projectBoardLaunchDate) ? (DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class) : sourceValueStream.leankor__ProjectBoardLaunchDateTime__c;
            issevendays = sourceValueStream.leankor__SevenDayWorkWeek__c;
            
            DataBase.update(newValueStream, false);
            
            List<leankor__Preference__c> globalPref = [Select Id,
                                                                leankor__CardPastDueDate__c, 
                                                                leankor__DerivedFrom__c, 
                                                                leankor__FollowOnChatter__c, 
                                                                leankor__GUID__c, 
                                                                leankor__Moved__c, 
                                                                leankor__PercentDone__c, 
                                                                leankor__SubscribeToCard__c, 
                                                                leankor__TaskPastDueDate__c, 
                                                                leankor__ValueStream__c, 
                                                                Name, 
                                                                OwnerId 
                                                            From leankor__Preference__c 
                                                            Where leankor__ValueStream__c = '' 
                                                                And OwnerId =: UserInfo.getUserId() 
                                                            With Security_Enforced
                                                            Limit 1];
            List<leankor__Preference__c> clonePreferenceList = new List<leankor__Preference__c>();
                
            List<Id> prefUsers = new List<Id>();
            for (leankor__Preference__c preference : [Select Id,
                                                                OwnerId,
                                                                leankor__ValueStream__c,
                                                                Name 
                                                            From leankor__Preference__c 
                                                            Where leankor__ValueStream__c = :boardData.sourceValueStreamId 
                                                            With Security_Enforced
                                                            Order By OwnerId Desc 
                                                            Limit 10000]) {
                
                if (!prefUsers.contains(preference.OwnerId)) {
                    prefUsers.add(preference.OwnerId);
                } else {
                    continue;
                }
            }
            List<Id> activeUsers = new List<Id>();
            for (User user : [Select Id, 
                                        Name, 
                                        IsActive 
                                    From User 
                                    Where Id In :prefUsers 
                                        And IsActive = true 
                                    Limit 10000]) {
                
                if (activeUsers.contains(user.Id)) {
                    continue;
                } else {
                    activeUsers.add(user.Id);
                }
            }
            List<Id> uniqueIdCheck = new List<Id>();

            for (leankor__Preference__c prefLog :[Select Id,
                                                            OwnerId,
                                                            leankor__CardPastDueDate__c, 
                                                            leankor__DerivedFrom__c,
                                                            leankor__FollowOnChatter__c,
                                                            leankor__GUID__c,
                                                            leankor__Moved__c,
                                                            leankor__PercentDone__c,
                                                            leankor__SubscribeToCard__c,
                                                            leankor__TaskPastDueDate__c,
                                                            leankor__ValueStream__c,
                                                            Name, 
                                                            leankor__isTaskCompleted__c,
                                                            Owner.IsActive 
                                                        From leankor__Preference__c 
                                                        Where leankor__ValueStream__c =: boardData.sourceValueStreamId
                                                            And OwnerId In :activeUsers 
                                                        With Security_Enforced
                                                        Limit 10000]) {
                
                Blob generatedBlob = Crypto.GenerateAESKey(128);
                String hex = EncodingUtil.ConvertTohex(generatedBlob);
                String guid = hex.subString(0, 8) + '-' + hex.subString(8, 12) + '-' + hex.subString(12, 16);
                
                leankor__Preference__c clonePref = New leankor__Preference__c();
                clonePref.leankor__ValueStream__c = boardData.newValueStreamId;      
                clonePref.OwnerId = prefLog.Owner.IsActive ? prefLog.OwnerId : UserInfo.getUserId() ;
                clonePref.leankor__CardPastDueDate__c =prefLog.leankor__CardPastDueDate__c;
                clonePref.leankor__DerivedFrom__c = globalPref.isEmpty() ? null :globalPref[0].Id;
                clonePref.leankor__SubscribeToCard__c = prefLog.leankor__SubscribeToCard__c;
                clonePref.leankor__FollowOnChatter__c = prefLog.leankor__FollowOnChatter__c;
                if (prefLog.leankor__FollowOnChatter__c != 'all' && prefLog.leankor__FollowOnChatter__c != 'none') {
                    List<String> chatters =(List<String>) JSON.deserialize(prefLog.leankor__FollowOnChatter__c, List<String>.class) ;
                    List<String> chatterIdToUpdate = New List<String>();
                    for (String chatter : chatters) {
                        chatterIdToUpdate.add(kanbanCardTemplateData.templateIDs.get(chatter));
                    }
                    clonePref.leankor__FollowOnChatter__c =(chatters.size() > 0 ?JSON.serialize(chatterIdToUpdate) :prefLog.leankor__FollowOnChatter__c);
                }
                if (prefLog.leankor__SubscribeToCard__c != 'all' && prefLog.leankor__SubscribeToCard__c != 'none') {
                    List<String> cards = (List<String>) JSON.deserialize(prefLog.leankor__SubscribeToCard__c, List<String>.class) ;                             
                    List<String> cardIdsUpdate = New List<String>();
                    for (String card : cards) {
                        cardIdsUpdate.add(kanbanCardTemplateData.templateIDs.get(card));
                    }
                    clonePref.leankor__SubscribeToCard__c = (cards.size() > 0 ? JSON.serialize(cardIdsUpdate) : prefLog.leankor__SubscribeToCard__c);
                }
                
                clonePref.leankor__GUID__c = guid +'a-b'+prefLog.Id;
                clonePref.leankor__Moved__c = prefLog.leankor__Moved__c;
                clonePref.leankor__PercentDone__c = prefLog.leankor__PercentDone__c;
                clonePref.leankor__TaskPastDueDate__c = prefLog.leankor__TaskPastDueDate__c;
                clonePref.Name = prefLog.Name;
                clonePref.leankor__isTaskCompleted__c = prefLog.leankor__isTaskCompleted__c;
                
                if (!uniqueIdCheck.contains(prefLog.OwnerId)) { 
                    clonePreferenceList.add(clonePref);
                    uniqueIdCheck.add(prefLog.OwnerId);
                }
                else continue;
                
            }
            insert clonePreferenceList;
            //clonePreferenceList.clear();
        } else if (boardData.BoardType == 'Kanban board') {
            leankor__ValueStream__c sourceValueStream = RealTimeControllerHelper.readsystemBoard();
            newValueStream.leankor__OpportunityCardCategory__c = kanbanCardTemplateData.templateIDs.get(sourceValueStream.leankor__OpportunityCardCategory__c);
            newValueStream.leankor__CaseCardCategory__c = kanbanCardTemplateData.templateIDs.get(sourceValueStream.leankor__CaseCardCategory__c);
            newValueStream.leankor__DefaultCategory__c = kanbanCardTemplateData.templateIDs.get(sourceValueStream.leankor__DefaultCategory__c);
            DataBase.update(newValueStream, false);           
        } 
        return newValueStream;
    }

   
    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    In this method processing to KanbanCard object and it's related records.
	    Inputs:         BoardData boardData, List<leankor__KanbanCard__c> remoteKanbanCards
	    Returns:        KanbanCardResponse
	------------------------------------------------------------*/
    public static KanbanCardResponse cloneKanbanCards(BoardData boardData, List<leankor__KanbanCard__c> remoteKanbanCards) {
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        TaskBehaviour taskBehaviour= new TaskBehaviour();
        if (!feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable() ||
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
       // Map<String,String> mapWithOldKanbanCard = new Map<String,String>();
        Map<String,Date> mapcardduedate = new Map<String,Date>();
        Map<String,Date> mapcardstartedate = new Map<String,Date>();
        Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__KanbanCard__c');
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();  
        List <Id> kanbanCardIdsForSticker = new List <Id> ();
        Map<String,String> mapWithOldKanbanCard = new Map<String,String>();
        if (boardData.KanbanVerb == true) {
            
        Boolean newVStaskchecker = boardData.newValueStreamRecord.leankor__TaskDateCheck__c;
        Boolean issevendays = boardData.newValueStreamRecord.leankor__SevenDayWorkWeek__c;
        Boolean isFromStartDate = false;
        Decimal otherDifference;
        Integer dateDifference;
        DateTime startDate;
        DateTime finalDate;
        DateTime tempDueDateTime;
        DateTime tempstartDateTime;
                        
        List <Id> kanbanCardIdListForTask = new List <Id> ();             
        if (remoteKanbanCards.size() > 0) {
            boardData.isprojectclone = (boardData.isprojectclone==null ? false : boardData.isprojectclone);

            if (boardData.BoardType != 'UberBoard' && boardData.isprojectclone) {
                //getting source project Board(Plan Gantt)
                List<leankor__ValueStream__c> sourceBoardId = [Select Id 
                                                                    From leankor__ValueStream__c 
                                                                    Where leankor__ProjectRoom__c = :boardData.newValueStreamRecord.leankor__ProjectRoom__c
                                                                    And leankor__Boardtype__c = 'UberBoard' 
                                                                    With Security_Enforced
                                                                    Limit 1];
            
                if (!String.isBlank(boardData.projectBoardLaunchDate)) {   
                    Isfromstartdate = true;                       
                    Datetime valueStreamStartDate;
                    // Project launch date become the start date of project 
                    boardData.FinalStartDate = boardData.projectBoardLaunchDate;
                    
                    AggregateResult[] minStartDate = [Select Min(leankor__StartDateTime__c) minimumDate, 
                                                                Max(leankor__StartDateTime__c) maximumDate 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__ValueStream__c = : boardData.sourceValueStreamId 
                                                            And leankor__IsRecordDeleted__c = False And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                            With Security_Enforced]; 

                    leankor__ValueStream__c valueStream = [Select leankor__ProjectBoardLaunchDateTime__c 
                                                                From leankor__ValueStream__c 
                                                                Where Id =: boardData.sourceValueStreamId
                                                                With Security_Enforced];
                                                    
                    if (minStartDate[0].get('minimumDate') != null) {
                        boardData.oldMinimumStart = (Datetime)minStartDate[0].get('minimumDate');	
                        boardData.oldMaximumStart	= (Datetime)minStartDate[0].get('maximumDate');	
                        DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
                        DateTime projectLaunchDate = valueStream.leankor__ProjectBoardLaunchDateTime__c ;             
                        valueStreamStartDate = (Datetime)minStartDate[0].get('minimumDate');
                        if (projectLaunchDate != null) {
                            if (issevendays) {
                            Integer numberOfDaysToAdd = (projectLaunchDate.dateGMT()).daysBetween(minimumStartDate.dateGMT());							        							        		
                            boardData.FinalStartDate = Json.serialize((((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class)).addDays(numberOfDaysToAdd)));
                            }
                            else {
                                Integer numberOfDaysToAdd = boardData.workWeek.getBusinessDays(projectLaunchDate.dateGMT(), minimumStartDate.dateGMT());
                                boardData.FinalStartDate = Json.serialize(numberOfDaysToAdd != 0 ? boardData.workWeek.nextBusinessDate((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class), numberOfDaysToAdd): minimumStartDate);
                            
                                if (projectLaunchDate.dateGMT() == minimumStartDate.dateGMT()) {
                                    boardData.FinalStartDate = Json.serialize(boardData.workWeek.nextBusinessDate((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class), numberOfDaysToAdd));
                                }
                            }
                        } else {
                            
                            if (issevendays) {
                                if (!sourceBoardId.isEmpty()) {
                                    minStartDate = [Select 
                                                    Min(leankor__StartDateTime__c) minimumDate 
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c = : sourceBoardId[0].Id
                                                    And leankor__IsRecordDeleted__c = False 
                                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                With Security_Enforced];
                                }
                                else {
                                    minStartDate.clear();
                                }
                            }
                        }
                    } 
                    StartDate = (DateTime)JSON.deserialize(boardData.FinalStartDate, DateTime.class); 
                    StartDate = boardData.workWeek.getNextWorkingDay(StartDate); 
                    
                    dateDifference = !minStartDate.isEmpty() && minStartDate[0].get('minimumDate') != null ? boardData.workWeek.getBusinessDays(((Datetime)minStartDate[0].get('minimumDate')).dateGMT(), StartDate.dateGMT()) : boardData.workWeek.getBusinessDays(valueStreamStartDate.dateGMT(), StartDate.dateGMT());                                	                     
                }
                else if (!String.isBlank(boardData.FinalStartDate)) {
                        isFromStartDate = true;                       
                        //clone project Start date                      
                        StartDate = (DateTime)JSON.deserialize(boardData.FinalStartDate, DateTime.class);
                        StartDate = boardData.workWeek.getNextWorkingDay(StartDate); 
                        
                        AggregateResult[] groupedResultsMin = new List<AggregateResult>();
                        if (!sourceBoardId.isEmpty()) {
                            groupedResultsMin = [Select 
                                                        Min(leankor__StartDateTime__c) minimumDate,
                                                        Max(leankor__StartDateTime__c) maximumDate 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :sourceBoardId[0].Id
                                                        And leankor__IsRecordDeleted__c = False 
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                    With Security_Enforced];
                        }
                            
                        // getting diffrences between project start date and planGantt minimum date
                        if (groupedResultsMin.isEmpty()|| groupedResultsMin[0].get('minimumDate') == null) {
                        
                            if (boardData.sourceValueStreamId != null) {
                                groupedResultsMin = [Select 
                                                            Min(leankor__StartDateTime__c) minimumDate,
                                                            Max(leankor__StartDateTime__c) maximumDate
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = : boardData.sourceValueStreamId 
                                                            And leankor__IsRecordDeleted__c = False 
                                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                        With Security_Enforced];
                            }
                            else {
                                groupedResultsMin.clear();
                            }
                        }

            
                    dateDifference = boardData.workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).dateGMT(), StartDate.dateGMT());
                    
                    boardData.oldMinimumStart	= (Datetime)groupedResultsMin[0].get('minimumDate');	
                    boardData.oldMaximumStart	= (Datetime)groupedResultsMin[0].get('maximumDate');	
                } else {
                    //clone project Due date  
                    finalDate = (DateTime)JSON.deserialize(boardData.finalDate, DateTime.class);
                    finalDate = boardData.workWeek.getPreviousWorkingDay(finalDate);
                    
                    AggregateResult[] groupedResultsMax = new List<AggregateResult>();
                    if (!sourceBoardId.isEmpty()) {
                        groupedResultsMax = [Select
                                                    Max(leankor__DueDateTime__c) maximumDate, 
                                                    Min(leankor__StartDateTime__c) minimumDate
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c = :sourceBoardId[0].Id 
                                                    And leankor__IsRecordDeleted__c = False 
                                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                With Security_Enforced];
                    }

                    if (groupedResultsMax.isEmpty()|| groupedResultsMax[0].get('maximumDate') == null) {
                    
                        if (boardData.sourceValueStreamId != null) {
                            groupedResultsMax = [Select 
                                                        Max(leankor__DueDateTime__c) maximumDate,
                                                        Min(leankor__StartDateTime__c) minimumDate
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = : boardData.sourceValueStreamId 
                                                        And leankor__IsRecordDeleted__c = False 
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                    With Security_Enforced];
                        }
                        else {
                            groupedResultsMax.clear();
                        }
                    }
                    
                    dateDifference = boardData.workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).dateGMT(), finalDate.dateGMT());
                    boardData.oldMinimumStart	= (Datetime)groupedResultsMax[0].get('minimumDate');	
                    boardData.oldMaximumStart	= (Datetime)groupedResultsMax[0].get('maximumDate');
                }                                          
            }
            else {
                
                if (String.isNotBlank(boardData.projectBoardLaunchDate)) {   
                    // Project launch date become the start date of project 
                    boardData.FinalStartDate = boardData.projectBoardLaunchDate;
                    AggregateResult[] minStartDate = [Select Min(leankor__StartDateTime__c) minimumDate, 
                                                            Max(leankor__StartDateTime__c) maximumDate 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :boardData.sourceValueStreamId 
                                                            And leankor__IsRecordDeleted__c = False 
                                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                        With Security_Enforced];  
                                                            
                    leankor__ValueStream__c valueStream = [Select leankor__ProjectBoardLaunchDateTime__c 
                                                                From leankor__ValueStream__c 
                                                                Where Id=: boardData.sourceValueStreamId
                                                                With Security_Enforced];
                                                    
                    if (minStartDate[0].get('minimumDate') != null) {     
                        
                        boardData.oldMinimumStart	= (Datetime)minStartDate[0].get('minimumDate');	
                        boardData.oldMaximumStart	= (Datetime)minStartDate[0].get('maximumDate');									
                        DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
                        DateTime projectLaunchDate = valueStream.leankor__ProjectBoardLaunchDateTime__c ;               
                        if (projectLaunchDate != null) {
                            Integer numberOfDaysToAdd = boardData.workWeek.getBusinessDays(projectLaunchDate.dateGMT(), minimumStartDate.dateGMT());
                            Datetime tempFinalStartDate;
                            if (issevendays) {
                                tempFinalStartDate = numberOfDaysToAdd != 0 ?(((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class)).addDays(numberOfDaysToAdd)) : minimumStartDate.dateGMT();
                            }
                            else {
                                
                                tempFinalStartDate = numberOfDaysToAdd != 0 ? boardData.workWeek.nextBusinessDate((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class), numberOfDaysToAdd) : minimumStartDate.dateGMT();
                                if (numberOfDaysToAdd < 0 && projectLaunchDate > (DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class)) {
                                    tempFinalStartDate = boardData.workWeek.getPreviousWorkingDay(tempFinalStartDate);
                                }
                            }
                            
                            
                            if (projectLaunchDate.dateGMT() == minimumStartDate.dateGMT()) {
                                tempFinalStartDate = boardData.workWeek.nextBusinessDate((DateTime)JSON.deserialize(boardData.projectBoardLaunchDate, DateTime.class), numberOfDaysToAdd);
                            }
                            boardData.FinalStartDate = Json.serialize(tempFinalStartDate);
                        }		
                    }	  	                     
                }
                
                if (String.isNotBlank(boardData.FinalStartDate)) {
                    
                    isFromStartDate = true;
                    //clone project Start date                        
                    StartDate = (DateTime)JSON.deserialize(boardData.FinalStartDate, DateTime.class);
                    StartDate = boardData.workWeek.getNextWorkingDay(StartDate); // If occurred on holiday
                    
                    AggregateResult[] groupedResultsMin  =[Select Min(leankor__StartDateTime__c) minimumDate, 
                                                                    Max(leankor__StartDateTime__c) maximumDate 
                                                                From leankor__KanbanCard__c 
                                                                Where leankor__ValueStream__c = :boardData.sourceValueStreamId  
                                                                    And leankor__IsRecordDeleted__c = False 
                                                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                                    With Security_Enforced];
                    
                    dateDifference = boardData.workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).dateGMT(), StartDate.dateGMT());
                    boardData.oldMinimumStart	= (Datetime)groupedResultsMin[0].get('minimumDate');	
                    boardData.oldMaximumStart	= (Datetime)groupedResultsMin[0].get('maximumDate');									                            
                } else {
                            //clone project Due date   
                    finalDate = (DateTime)JSON.deserialize(boardData.finalDate, DateTime.class); 
                    finalDate = boardData.workWeek.getPreviousWorkingDay(finalDate);
                                                    
                        AggregateResult[] groupedResultsMax = [Select Max(leankor__DueDateTime__c) maximumDate,
                                                                        Min(leankor__StartDateTime__c) minimumDate 
                                                                    From leankor__KanbanCard__c 
                                                                    Where leankor__ValueStream__c = :boardData.sourceValueStreamId  
                                                                        And leankor__IsRecordDeleted__c = False 
                                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                                    With Security_Enforced];
                    
                    
                    dateDifference = boardData.workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).dateGMT(), finalDate.dateGMT());
                    boardData.oldMinimumStart	= (Datetime)groupedResultsMax[0].get('minimumDate');	
                    boardData.oldMaximumStart	= (Datetime)groupedResultsMax[0].get('maximumDate');
                }
            }
            
            
            List<RealTimeController.Kanban> newKanbanCards = new List<RealTimeController.Kanban>();		
            Map<String,Decimal> mapKanbanCardDifference = new Map<String,Decimal>();                                     
            
            List<KanbanCard> cardsToCheck = new List<KanbanCard>();
            KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
            Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
            List<String> cardIdList = new List<String>{boardData.sourceValueStreamId};
            KanbanController.FieldSetRecord singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(cardIdList, 'leankor__ValueStream__c');
            
            Set<String> cardLinksIds =  new set<String>();
            if (boardData.LinkCloneKanbanCardID != null && boardData.LinkCloneKanbanCardID != '') {
                cardLinksIds.add(boardData.LinkCloneKanbanCardID);
            }
            for (leankor__KanbanCard__c remoteKanbanCard : remoteKanbanCards) {
                if (boardData.stickerVerb == true) {
                    kanbanCardIdsForSticker.add(remoteKanbanCard.Id);
                }

                kanbanCardIdListForTask.add(remoteKanbanCard.Id);
                Integer startDateConstraintDifference = 0;
                Integer dueDateconstraintDifference = 0;
                String tempID = boardData.templateIDs.get(remoteKanbanCard.leankor__KanbanCardTemplate__c);
                String tempConstraintType;
                Datetime tempConstraintDate;

                //Changes : Check constraint setting enable or not.
                if (RealTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    for (leankor__ScheduleMode__c schedulemode : remoteKanbanCard.leankor__ScheduleModes__r) {
                        tempConstraintType = schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c;
                        tempConstraintDate = schedulemode.leankor__ConstraintDateTime__c;
                    }
                }
                
                    
                //If StartDate is not null then use time value from StartDate else pick from finalDate
                if (StartDate!=null) {
                    tempstartDateTime = DateTime.newInstanceGmt(remoteKanbanCard.leankor__StartDateTime__c.dateGmt(),remoteKanbanCard.leankor__StartDateTime__c.timeGmt());
                    tempDueDateTime = DateTime.newInstanceGmt(remoteKanbanCard.leankor__DueDateTime__c.dateGmt(),remoteKanbanCard.leankor__StartDateTime__c.timeGmt()); 
                } else {
                    tempstartDateTime = DateTime.newInstanceGmt(remoteKanbanCard.leankor__StartDateTime__c.dateGmt(),remoteKanbanCard.leankor__StartDateTime__c.timeGmt());
                    tempDueDateTime = DateTime.newInstanceGmt(remoteKanbanCard.leankor__DueDateTime__c.dateGmt(),remoteKanbanCard.leankor__StartDateTime__c.timeGmt()); 

                }
                                                            
                if (!issevendays) {   
                                                                    
                    if (dateDifference > 0) {                                
                            
                        if (isFromStartDate) {
                            tempstartDateTime = boardData.workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                        } else {
                            tempDueDateTime = boardData.workWeek.nextBusinessDate(tempDueDateTime, dateDifference);
                        }  
                        
                    } else {  
                        if (isFromStartDate) {
                            tempstartDateTime = boardData.workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                        } else {
                            tempDueDateTime = boardData.workWeek.nextBusinessDate(tempDueDateTime, dateDifference); 
                        }                                                                                                   
                    }  

                } else {

                
                    if (isFromStartDate) {
                        tempstartDateTime = boardData.workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                    } else {
                        tempDueDateTime = boardData.workWeek.nextBusinessDate(tempDueDateTime, dateDifference); 
                    }                       
                }  
                startDateConstraintDifference = tempConstraintDate != null ? (Date.newInstance(remoteKanbanCard.leankor__StartDateTime__c.year(),remoteKanbanCard.leankor__StartDateTime__c.month(),remoteKanbanCard.leankor__StartDateTime__c.day())).daysBetween(Date.newInstance(tempConstraintDate.year(),tempConstraintDate.month(),tempConstraintDate.day())) : 0;
                dueDateconstraintDifference = tempConstraintDate != null ? (Date.newInstance(remoteKanbanCard.leankor__DueDateTime__c.year(),remoteKanbanCard.leankor__DueDateTime__c.month(),remoteKanbanCard.leankor__DueDateTime__c.day())).daysBetween(Date.newInstance(tempConstraintDate.year(),tempConstraintDate.month(),tempConstraintDate.day())) : 0;

                mapKanbanCardDifference.put(remoteKanbanCard.Id,dateDifference);
                
                leankor.RealTimeController.Kanban newKanbanCard = new leankor.RealTimeController.Kanban();
                newKanbanCard.Id = remoteKanbanCard.Id;
                newKanbanCard.IsSuccessorRecalculate =  remoteKanbanCard.leankor__IsSuccessorRecalculate__c;
                    Set<String> weekDays = new Set<String>();
                    if (issevendays) {
                        if (remoteKanbanCard.leankor__Monday__c == false && remoteKanbanCard.leankor__Tuesday__c == false && remoteKanbanCard.leankor__Wednesday__c == false &&  remoteKanbanCard.leankor__Thursday__c == false &&  remoteKanbanCard.leankor__Friday__c == false &&  remoteKanbanCard.leankor__Saturday__c == false &&  remoteKanbanCard.leankor__Sunday__c == false) {
                            newKanbanCard.Monday = true;
                            newKanbanCard.Tuesday = true;
                            newKanbanCard.Wednesday = true;
                            newKanbanCard.Thursday = true;
                            newKanbanCard.Friday = true;
                            newKanbanCard.Saturday = true;
                            newKanbanCard.Sunday = true;
                        } else {
                            newKanbanCard.Monday = remoteKanbanCard.leankor__Monday__c;
                            newKanbanCard.Tuesday = remoteKanbanCard.leankor__Tuesday__c;
                            newKanbanCard.Wednesday = remoteKanbanCard.leankor__Wednesday__c;
                            newKanbanCard.Thursday = remoteKanbanCard.leankor__Thursday__c;
                            newKanbanCard.Friday = remoteKanbanCard.leankor__Friday__c;
                            newKanbanCard.Saturday = remoteKanbanCard.leankor__Saturday__c;
                            newKanbanCard.Sunday = remoteKanbanCard.leankor__Sunday__c;
                            newKanbanCard.WeekCalendar = remoteKanbanCard.leankor__WeekCalendar__c;
                            newKanbanCard.IsSuccessorRecalculate = (dateDifference !=0 ) ? true : remoteKanbanCard.leankor__IsSuccessorRecalculate__c;

                            weekDays.add(newKanbanCard.Monday == false ? 'Mon' : 'false');
                            weekDays.add(newKanbanCard.Tuesday == false ? 'Tue' : 'false');
                            weekDays.add(newKanbanCard.Wednesday == false ? 'Wed' : 'false');
                            weekDays.add(newKanbanCard.Thursday == false ? 'Thu' : 'false');
                            weekDays.add(newKanbanCard.Friday == false ? 'Fri' : 'false');
                            weekDays.add(newKanbanCard.Saturday == false ? 'Sat' : 'false');
                            weekDays.add(newKanbanCard.Sunday == false ? 'Sun' : 'false');
                        }
                    }    
                    Util.weekDays = weekDays;
                    newKanbanCard.OwnerId = remoteKanbanCard.OwnerId;
                    newKanbanCard.UrlLink =remoteKanbanCard.leankor__UrlLink__c;
                    newKanbanCard.GUID = remoteKanbanCard.Id+'-'+tempID+'-k';
                    newKanbanCard.Title= remoteKanbanCard.leankor__Title__c;
                    newKanbanCard.Name = remoteKanbanCard.Name;
                    newKanbanCard.Top = remoteKanbanCard.leankor__Top__c;
                    newKanbanCard.Bottom = remoteKanbanCard.leankor__Bottom__c;
                    newKanbanCard.Left = remoteKanbanCard.leankor__Left__c;
                    newKanbanCard.Width = remoteKanbanCard.leankor__Width__c;
                    newKanbanCard.Height = remoteKanbanCard.leankor__Height__c;
                    newKanbanCard.X = remoteKanbanCard.leankor__X__c;
                    newKanbanCard.Y = remoteKanbanCard.leankor__Y__c;
                    newKanbanCard.ValueStream = boardData.newValueStreamId;
                    newKanbanCard.TemplateID = tempID;
                    newKanbanCard.point = remoteKanbanCard.leankor__Point__c;
                    newKanbanCard.EffortRemaining = integer.valueof(remoteKanbanCard.leankor__EffortRemaining__c);
                    newKanbanCard.EstimatedDuration = remoteKanbanCard.leankor__EstimatedDuration__c;
                    newKanbanCard.Color = remoteKanbanCard.leankor__Color__c;  
                    
                    if (boardData.cloneCustomFields == null || boardData.cloneCustomFields) {
                        newKanbanCard.JSONDefinition = remoteKanbanCard.leankor__JSONDefinition__c;
                        newKanbanCard.JSONData = remoteKanbanCard.leankor__JSONData__c;
                    } else {
                        newKanbanCard.JSONDefinition = '{}';
                        newKanbanCard.JSONData = '{}';
                    }
                    
                    if (Util.weekDays.size() > 1) {
                        newKanbanCard.DueDate = boardData.workWeek.getNextWorkingDay(tempDueDateTime);
                        newKanbanCard.StartDate = boardData.workWeek.getNextWorkingDay(tempStartDateTime);
                    } else {
                        newKanbanCard.DueDate = tempDueDateTime;
                        newKanbanCard.StartDate = tempStartDateTime;
                    }
                    
                    boardData.dateList.add((String.isNotBlank(boardData.projectBoardLaunchDate)|| String.isNotBlank(boardData.FinalStartDate)) ? tempStartDateTime : tempDueDateTime);
                    
                    newKanbanCard.CardID = remoteKanbanCard.leankor__CardID__c; 
                    newKanbanCard.seriesNumber = Integer.valueOf(remoteKanbanCard.leankor__SeriesNumber__c); 
                    newKanbanCard.AcceptanceCriteria = remoteKanbanCard.leankor__AcceptanceCriteria__c; 
                    newKanbanCard.DurationUnits = remoteKanbanCard.leankor__DurationUnits__c;  
                    newKanbanCard.Priority = Integer.ValueOF(remoteKanbanCard.leankor__Priority__c); 
                    newKanbanCard.HarveyBall = String.ValueOF(remoteKanbanCard.leankor__PercentComplete2__c);//field for Harvay Ball in percentage 
                    newKanbanCard.Order = (remoteKanbanCard.leankor__Order__c == null ? 0 : Integer.ValueOF(remoteKanbanCard.leankor__Order__c));
                    newKanbanCard.DateColor = remoteKanbanCard.leankor__DateColor__c; //field for foreground color of Date value  
                    newKanbanCard.Description = remoteKanbanCard.leankor__DescriptionLong__c;
                    newKanbanCard.ValueStreamCardLink =  (boardData.linkCloneVSID == '' ? remoteKanbanCard.leankor__ValueStreamCardLink__c : (boardData.LinkCloneKanbanCardID == '' ? null : (remoteKanbanCard.RecordType.Name != 'MileStoneCard' && remoteKanbanCard.leankor__valuestream__r.leankor__boardtype__c != 'UberBoard') ? boardData.LinkCloneKanbanCardID : null));
                    newKanbanCard.ValueStreamLinkID = (boardData.linkCloneVSID == '' ? remoteKanbanCard.leankor__ValueStreamLink__c : boardData.linkCloneVSID);
                    newKanbanCard.Account = remoteKanbanCard.leankor__Account__c;
                    newKanbanCard.Contact = remoteKanbanCard.leankor__Contact__c;
                    newKanbanCard.CaseID = remoteKanbanCard.leankor__Case__c;
                    newKanbanCard.ZoneID = (boardData.zoneGUIDs.containsKey(remoteKanbanCard.leankor__ZoneGUID__c) == true ? boardData.zoneGUIDs.get(remoteKanbanCard.leankor__ZoneGUID__c) : '');
                    newKanbanCard.MCForceID =(boardData.newMCForceIDs.containsKey(remoteKanbanCard.leankor__MasterContainer__c) == true ? boardData.newMCForceIDs.get(remoteKanbanCard.leankor__MasterContainer__c):'');
                    newKanbanCard.SWForceID =(boardData.newSWForceIDs.containsKey(remoteKanbanCard.leankor__Swimlane__c) == true ? boardData.newSWForceIDs.get(remoteKanbanCard.leankor__Swimlane__c):'');
                    newKanbanCard.ZoneForceID =(boardData.newZoneForceIDs.containsKey(remoteKanbanCard.leankor__Zone__c) == true ? boardData.newZoneForceIDs.get(remoteKanbanCard.leankor__Zone__c):'');
                    newKanbanCard.Opportunity = remoteKanbanCard.leankor__Opportunity__c;
                    newKanbanCard.BoardType = remoteKanbanCard.leankor__valuestream__r.leankor__boardtype__c;
                    newKanbanCard.OnBudget = remoteKanbanCard.leankor__OnBudget__c;
                    newKanbanCard.OnQuality = remoteKanbanCard.leankor__OnQuality__c;
                    newKanbanCard.OnTime = remoteKanbanCard.leankor__OnTime__c; 
                    newKanbanCard.isAtRisk = remoteKanbanCard.leankor__IsAtRisk__c;
                    newKanbanCard.isOnHold = remoteKanbanCard.leankor__IsOnHold__c;
                    
                    if (remoteKanbanCard.RecordType.Name == 'ActivityCard')
                    {
                        newKanbanCard.ItemType = remoteKanbanCard.RecordType.Name;
                    } else if (remoteKanbanCard.RecordType.Name == 'MileStoneCard')
                    {
                        newKanbanCard.ItemType = remoteKanbanCard.RecordType.Name;
                    } else if (remoteKanbanCard.RecordType.Name == 'FolderCard')
                    {
                        newKanbanCard.ItemType = remoteKanbanCard.RecordType.Name;
                    }
            
                    // Calculation according to duration unit
                    Integer ED = integer.valueof(newKanbanCard.EstimatedDuration);
                    if (newKanbanCard.DurationUnits == 'Hours') {
                        if (math.mod(ED,8) > 0) {
                            ED= Integer.valueof(ED/8) + 1;
                        } else {
                            ED= Integer.valueof(ED/8);
                        }
                    } else if (newKanbanCard.DurationUnits == 'Years') {
                        ED= Integer.valueof(ED*365);
                    } else if (newKanbanCard.DurationUnits == 'Months') {
                        ED= Integer.valueof(ED*20);
                    } else if (newKanbanCard.DurationUnits == 'Minutes') {
                        integer temphours;
                        if (math.mod(ED,60) >0 ) {
                            temphours= Integer.valueof(ED/60) + 1;
                        } else {
                            temphours= Integer.valueof(ED/60);
                        }
                        if (math.mod(temphours,8) >0) {
                            ED= Integer.valueof(temphours/8) + 1;
                        } else {
                            ED= Integer.valueof(temphours/8);
                        }
                    } else if (newKanbanCard.DurationUnits == 'Weeks') {
                        if (issevendays) {
                            ED = Integer.valueof(ED*7);
                        } else {
                            ED = Integer.valueof(ED*5);
                        }
                    }

                    if (!isFromStartDate) {
                        
                        Datetime tempcalstartdate = newKanbanCard.DueDate;
                        if (newKanbanCard.DurationUnits == 'Years') {
                            tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(newKanbanCard.EstimatedDuration));
                            tempcalstartdate = tempcalstartdate +1 ;
                        } else if (newKanbanCard.DurationUnits == 'Months') {
                            tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(newKanbanCard.EstimatedDuration));
                            tempcalstartdate = tempcalstartdate +1 ;
                        } else {                                                         
                            // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                            ED = (ED == 0 ? 1: ED);                                                    
                            tempcalstartdate = boardData.workWeek.nextBusinessDate(tempcalstartdate, -(ED-1));      
                        }
                        newKanbanCard.StartDate = boardData.workWeek.getPreviousWorkingDay(tempcalstartdate);
                    } else if (isFromStartDate) {
                        Datetime tempcalDuedate = newKanbanCard.StartDate;
                        if (newKanbanCard.DurationUnits == 'Years') {
                            tempcalDuedate = tempcalDuedate.addYears(integer.valueof(newKanbanCard.EstimatedDuration));
                            tempcalDuedate = tempcalDuedate -1 ;
                        } else if (newKanbanCard.DurationUnits == 'Months') {
                            tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(newKanbanCard.EstimatedDuration));
                            tempcalDuedate = tempcalDuedate -1 ;
                        } else {
                            // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                            ED = (ED == 0 || ED == Null ? 1: ED); 
                            tempcalDuedate = boardData.workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                        }
                        newKanbanCard.DueDate = boardData.workWeek.getNextWorkingDay(tempcalDuedate);                    
                    }      
                Date tempCardDueDate = Date.newInstance(newKanbanCard.DueDate.year(), newKanbanCard.DueDate.month(), newKanbanCard.DueDate.day());
                Date tempCardStartdate = Date.newInstance(newKanbanCard.StartDate.year(), newKanbanCard.StartDate.month(), newKanbanCard.StartDate.day());
                
                mapcardduedate.put(remoteKanbanCard.Id,tempCardDueDate);
                mapcardstartedate.put(remoteKanbanCard.Id,tempCardStartdate);
                
                newKanbanCard.schedulemodeList = remoteKanbanCard.leankor__ScheduleModes__r;
                newKanbanCard.resourceAssignmentList = remoteKanbanCard.leankor__ResourceAssignments__r;
                
                newKanbanCard.HarveyBallDoneDate = remoteKanbanCard.leankor__HarveyBallDoneDate__c;
                newKanbanCard.PromiseCompletionDate = remoteKanbanCard.leankor__PromiseCompletionDate__c;
                    
                if (boardData.cloneCustomFields == true) {
                    if ((boardData.BoardType == 'UberBoard' || boardData.BoardType == 'Kanban Board')) {
                        Map<String, Object> fieldsToValue = remoteKanbanCard.getPopulatedFieldsAsMap();
                        newKanbanCard.kanbanCustomField = new leankor__KanbanCard__c();	
                        for (String singleFieldName : singleFieldSetRecord.allFields) {
                            if (fieldMapKanbanCardForClone.containsKey(singleFieldName.toLowerCase())) {
                                if (fieldsToValue.containsKey(singleFieldName)) {
                                    newKanbanCard.kanbanCustomField.put(singleFieldName, remoteKanbanCard.get(singleFieldName)); 
                                } 					   	
                            }
                        }                                
                    } else {
                        newKanbanCard.kanbanCustomField = new leankor__KanbanCard__c();							                                 
                        if (String.isNotBlank(remoteKanbanCard.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)) { 
                            
                            if (fieldSetMap.get(String.valueOf(remoteKanbanCard.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)) != null) {
                                
                                for (String  fields : singleFieldSetRecord.fieldSetAndFields.get(String.valueOf(remoteKanbanCard.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c))) {
                                    
                                    if (fieldMapKanbanCardForClone.containsKey(fields.toLowerCase())) {						   								   										   			    
                                        newKanbanCard.kanbanCustomField.put(fields, remoteKanbanCard.get(fields));     					   	
                                    } 						   		           							
                                } 
                            }   
                        }
                    }                            
                }
                
                newKanbanCard.ownerIsActive = remoteKanbanCard.Owner.IsActive;
                newKanbanCard.ConstraintDate = null;
                newKanbanCard.ConstraintType = null;
                if (String.isNotBlank(tempConstraintType) && RealTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    newKanbanCard.ConstraintType = scheduleConstraints.get(tempConstraintType).Id;
                    newKanbanCard.ConstraintDate = (new List<String>{'aslateaspossible','assoonaspossible'}.contains(tempConstraintType)) ? null : (new List<String>{'startnoearlierthan','startnolaterthan','muststarton'}.contains(tempConstraintType)) ? newKanbanCard.StartDate + startDateConstraintDifference : newKanbanCard.DueDate + dueDateconstraintDifference;
                }
                if (RealTimeController.ALLOW_SCHEDULING_CONSTRAINTS && String.isNotBlank(boardData.LinkCloneVSID) && String.isNotBlank(boardData.LinkCloneKanbanCardID) && remoteKanbanCard.RecordType.Name != 'MileStoneCard' && remoteKanbanCard.leankor__valuestream__r.leankor__boardtype__c != 'UberBoard') {
                    KanbanCard checkCard = new KanbanCard();
                    checkCard.Id = newKanbanCard.Id;
                    checkCard.name = newKanbanCard.Name;
                    checkCard.valueStream = boardData.newValueStreamId;
                    checkCard.startDateTime = newKanbanCard.StartDate;
                    checkCard.dueDateTime = newKanbanCard.DueDate;
                    checkCard.isUpdateValueStreamCardLink = true;
                    checkCard.valueStreamLink = newKanbanCard.ValueStreamLinkID;
                    checkCard.valueStreamCardLink = newKanbanCard.ValueStreamCardLink;
                    cardsToCheck.add(checkCard);
                }
                newKanbanCards.add(newKanbanCard);
                Util.weekDays.clear();
            }
            
            // Cleared to reduce the heap size
            //boardData.zoneGUIDs.clear();
            //boardData.newMCForceIDs.clear();
            //boardData.newSWForceIDs.clear();
            //boardData.newZoneForceIDs.clear();
            //boardData.templateIDs.clear();
            //fieldMapKanbanCardForClone.clear();
            
            if (!cardsToCheck.isEmpty()) {
                if (RealTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
                }
                if (!violationResult.isEmpty()) {
                    
                    leankor.RealTimeController.DirectLinkCardLog constraintViolation = new leankor.RealTimeController.DirectLinkCardLog();
                    constraintViolation.constraintCardName = violationResult.kanbanCardConstraint.kanbanCardRecord.current.name;
                    constraintViolation.boardName = violationResult.kanbanCardConstraint.kanbanCardRecord.current.boardName;
                    constraintViolation.currentCardName = violationResult.kanbanCardRecord.current.name;
                    constraintViolation.constraintDescription = violationResult.kanbanCardConstraint.scheduleModeRecord.constraintDescription;
                    constraintViolation.constraintCardId = violationResult.kanbanCardConstraint.kanbanCardRecord.current.Id;
                    constraintViolation.violatedBoardType = violationResult.kanbanCardConstraint.kanbanCardRecord.current.boardType;
                    constraintViolation.violatedBoardId = violationResult.kanbanCardConstraint.kanbanCardRecord.current.valueStream;
                    constraintViolation.projectID = violationResult.kanbanCardConstraint.kanbanCardRecord.current.projectID;
                    throw new Util.LeanException(Json.serialize(constraintViolation));
                }
            }
            
            remoteKanbanCards = leankor.RealTimeController.createKanbanCard(boardData.newValueStreamId, newKanbanCards, true);
            //newKanbanCards.clear(); 
            leankor.RealTimeController.updateIsSuccessorRecalculate(cardLinksIds);
            
            for (leankor__KanbanCard__c kanban : remoteKanbanCards) { 
                String oldKanbanID = (kanban.leankor__GUID__c).SubStringBefore('-');
                mapWithOldKanbanCard.put(oldKanbanID, kanban.Id);
            }
            boardData.kanbanCardOldAndNewIdMap.putAll(mapWithOldKanbanCard);
            
            List<Task> kanbanTaskList = new List<Task>();
            if (boardData.TaskVerb == true) {
                
                kanbanTaskList= [Select 
                                        ActivityDate,
                                        Description,
                                        Id,
                                        OwnerId,
                                        Priority,
                                        Status,
                                        Subject,
                                        WhatId,
                                        Owner.IsActive 
                                    From Task 
                                    Where What.Type = 'leankor__KanbanCard__c'
                                        And WhatId IN: kanbanCardIdListForTask 
                                        And IsDeleted = false 
                                    Order By CreatedDate ASC Nulls Last 
                                    limit 10000 All Rows];
            }
            //kanbanCardIdListForTask.clear();
            
            //Start of Clone Task
            if (boardData.TaskVerb == true) {              
                if (kanbanTaskList.size() > 0 ) {
                    List<Task> taskList = new List<Task>();
                    for (Task kanbanTask : kanbanTaskList) {
                        if (mapWithOldKanbanCard.containsKey(kanbanTask.WhatID) == true) {
                            Task task = new Task();
                                task.Priority = kanbanTask.Priority;
                                task.OwnerID = kanbanTask.Owner.IsActive ? kanbanTask.OwnerId : UserInfo.getUserId() ;
                                task.Subject = (kanbanTask.Subject == null ? '' : kanbanTask.Subject);
                                task.Status = kanbanTask.Status;
                                task.ActivityDate = (kanbanTask.ActivityDate == null ? (mapCardDueDate.get(kanbanTask.WhatId)) : (kanbanTask.ActivityDate + (Integer.ValueOf(mapKanbanCardDifference.get(kanbanTask.WhatId)))));                                            
                                datetime TskDuedate = Datetime.newInstance(task.ActivityDate.year(),task.ActivityDate.month(), task.ActivityDate.day(), 1, 1, 1);
                                
                                if (!isSevenDays) {
                                    if (isFromStartDate) {
                                        //Get Working days escaping non working days for Task
                                        task.ActivityDate = Util.readNextWorkingDate(boardData.workWeek,TskDuedate,task.ActivityDate);
                                    } else {
                                        task.ActivityDate = Util.readPreviousWorkingDate(boardData.workWeek,TskDuedate,task.ActivityDate);
                                    }
                                }
                                
                                if (task.ActivityDate > mapcardduedate.get(kanbanTask.WhatId) && newVStaskchecker) {
                                    task.ActivityDate = mapcardduedate.get(kanbanTask.WhatId);
                                } else if (task.ActivityDate < mapcardstartedate.get(kanbanTask.WhatId) && newVStaskchecker) {
                                    task.ActivityDate = mapcardstartedate.get(kanbanTask.WhatId);
                                }
                                
                                task.WhatID = mapWithOldKanbanCard.get(kanbanTask.WhatID);
                                task.Description = (kanbanTask.Description == null ? '' : kanbanTask.Description);
                                taskList.add(task);
                        }
                    }
                    
                    //kanbanTaskList.clear();
                    
                    Database.insert(taskList,true);
                        List<FeedItem> feeds = new List<FeedItem>();
                        for (Task task : taskList) {
                            FeedItem post = new FeedItem();
                            post.ParentID = task.Id;
                            post.Type = 'CreateRecordEvent';
                            feeds.add(post);
                        }
                        insert feeds;
                    }
                }
                //End of Task clone
            }
        }
        KanbanCardResponse kanbanCardResponse = new KanbanCardResponse();
        kanbanCardResponse.kanbanCardIdsForSticker = kanbanCardIdsForSticker;
        kanbanCardResponse.mapWithOldKanbanCard =  mapWithOldKanbanCard;
        return  KanbanCardResponse;
                    
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    In this method processing to clone Dependency records
	    Inputs:         BoardData inner class
	    Returns:        No output
	------------------------------------------------------------*/
    public static void cloneDependency(Boarddata boardData) {
        //Check CRUD / FLC behavior  
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isAccessible() ||
            !dependencyBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        // start cloning dependency
        List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>();  
        Set<String> oldKanbanCardIds;
        if (boardData.kanbanCardOldAndNewIdMap.size() > 0) {
            oldKanbanCardIds = boardData.kanbanCardOldAndNewIdMap.keySet();
        }

        List<leankor__Dependency__c> dependencies = [Select Id, 
                                                            leankor__LagLead__c, 
                                                            leankor__LagLeadUnit__c, 
                                                            leankor__GUID__c, 
                                                            leankor__ValueStream__c, 
                                                            leankor__KanbanCard__c, 
                                                            leankor__Predecessor__c, 
                                                            leankor__Predecessor__r.leankor__ValueStream__c, 
                                                            leankor__PredecessorType__c, 
                                                            leankor__Successor__c, 
                                                            leankor__Successor__r.leankor__ValueStream__c, 
                                                            leankor__SuccessorType__c 
                                                        From leankor__Dependency__c 
                                                        Where (leankor__Predecessor__c In :oldKanbanCardIds 
                                                                Or leankor__Successor__c In :oldKanbanCardIds) 
                                                            And leankor__Predecessor__r.leankor__ValueStream__c =:boardData.sourceValueStreamId
                                                            And leankor__Successor__r.leankor__ValueStream__c =:boardData.sourceValueStreamId 
                                                        With Security_Enforced
                                                        Limit 10000];
        
        if (dependencies.size()>0) {
            for (leankor__Dependency__c dependency : dependencies) {
                if ((boardData.kanbanCardOldAndNewIdMap.ContainsKey(dependency.leankor__Successor__c)) || (boardData.kanbanCardOldAndNewIdMap.ContainsKey(dependency.leankor__Predecessor__c))) {
                    leankor__Dependency__c newDependency = new leankor__Dependency__c();
                    newDependency.leankor__GUID__c = dependency.Id+'-'+System.now().getTime()+'-d';
                    newDependency.leankor__ValueStream__c = (boardData.newValueStreamId == dependency.leankor__ValueStream__c ? dependency.leankor__ValueStream__c : boardData.newValueStreamId);
                    newDependency.leankor__Predecessor__c =  (boardData.kanbanCardOldAndNewIdMap.ContainsKey(dependency.leankor__Predecessor__c) ? boardData.kanbanCardOldAndNewIdMap.get(dependency.leankor__Predecessor__c) : dependency.leankor__Predecessor__c);
                    newDependency.leankor__Successor__c = (boardData.kanbanCardOldAndNewIdMap.ContainsKey(dependency.leankor__Successor__c) ? boardData.kanbanCardOldAndNewIdMap.get(dependency.leankor__Successor__c) : dependency.leankor__Successor__c);
                    newDependency.leankor__SuccessorType__c = dependency.leankor__SuccessorType__c;
                    newDependency.leankor__LagLead__c = dependency.leankor__LagLead__c;
                    newDependency.leankor__LagLeadUnit__c = dependency.leankor__LagLeadUnit__c;
                    dependencyList.add(newDependency);
                }//End of If
            }//End of for loop
            try {
                Database.insert(dependencyList, false);
            } catch(Exception ex) {
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }//End of If
    }


    /*------------------------------------------------------------
	    Author:         Ramanand Kesharwani
	    Company:        Leankor
	    Description:    In this method processing to link folder Id to the project if project cloned successfully. 
	    Inputs:         BoardData inner class
	    Returns:        No output
	------------------------------------------------------------*/
    @TestVisible
    private void processAfterBoardCloningDone(BoardData boardData) {
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!projectRoomBehaviour.isAccessible() || 
           !projectRoomBehaviour.isUpdateable() ||
           !expenseBehaviour.isAccessible() || 
           !expenseBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior


        List<leankor__ProjectRoom__c> createdProjects = [Select Id,
                                                                leankor__Portfolio__c
                                                            From leankor__ProjectRoom__c
                                                            Where Id =: this.cloneProjectBoardRequest.relinkClonedProjectId
                                                                And leankor__Portfolio__c =: this.cloneProjectBoardRequest.targetFolderId
                                                            With Security_Enforced
                                                            Limit 1];
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
                throw new CloneProjectPlanGanttBatchException(ex.getMessage());
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
                List<leankor.ProjectBoardCarousel.PortfolioHierarchy> portfolioresult = new List<leankor.ProjectBoardCarousel.PortfolioHierarchy>(getMaxDateOfBoard(this.cloneProjectBoardRequest.relinkClonedProjectId));
                portfolioresult[0].verb = 'CloneProject';
                leankor.realtimeKanbanController.manageNavChange('LeankorNAV', JSON.serialize(portfolioresult[0]), this.cloneProjectBoardRequest.sessionID);   
            } catch(Exception ex) {
                System.debug('ERROR :: '+ex.getMessage());
            } 
        }
    }

    
    public static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getMaxDateOfBoard(Id projectRoomId) {
        leankor.ProjectBoardCarousel.portfoliodata portfolioData = new leankor.ProjectBoardCarousel.portfoliodata();
        portfolioData.navigationVerb = 'cloneProject';
        portfolioData.Id = projectRoomId;       
        return leankor.ProjectBoardCarousel.getPortHierarchy(portfolioData);        
    } 


	public static void updateProjectBoardStartAndEnddate(String sourceValueStreamId , String targetValueStreamId,
                                                            DateTime oldMinimumStart, DateTIme oldMaximumStart,
                                                            Util.WorkWeek workWeek, List<DateTime> dateList,
                                                            DateTime oldStartDateTime, DateTime oldEndDateTime, 
                                                            String finalStartDate ,String finalDate) {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        Integer difference;
        dateList.sort();
        leankor__ValueStream__c valueStreamWithNewDates = new leankor__ValueStream__c();
        leankor__valueStream__C sourceValueStream = [Select Id,
                                                            leankor__ScheduleBackward__c,
                                                            leankor__ProjectBoardStartDateTime__c,
                                                            leankor__ProjectBoardEndDateTime__c
                                                        From leankor__valueStream__c 
                                                        Where Id =: sourceValueStreamId
                                                        With Security_Enforced];

        if (realtimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
            if (oldMinimumStart != null && sourceValueStream.leankor__ProjectBoardStartDateTime__c != null && oldMaximumStart != null) {
                if (sourceValueStream.leankor__ScheduleBackward__c == true) {
                    difference = workWeek.getBusinessDays(oldMaximumStart.dateGMT(), sourceValueStream.leankor__ProjectBoardEndDateTime__c.dateGMT());
                    valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = workWeek.nextBusinessDate(dateList[dateList.size()-1], difference);
                } else {
                    difference = workWeek.getBusinessDays(oldMinimumStart.dateGMT(), sourceValueStream.leankor__ProjectBoardStartDateTime__c.dateGMT());
                    valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = workWeek.nextBusinessDate(dateList[0], difference );
                }
            }
        }
            
        AggregateResult[] kanbanCardDates = [Select Max(leankor__DueDateTime__c) maximumDueDate,
                                                    Min(leankor__StartDateTime__c) minimumStartDate 
                                                From leankor__kanbanCard__c 
                                                Where leankor__Valuestream__c =:targetValueStreamId];

        valueStreamWithNewDates.Id = targetValueStreamId;
        if (kanbanCardDates[0].get('minimumStartDate') != null && kanbanCardDates[0].get('maximumDueDate') != null && valueStreamWithNewDates != null && oldStartDateTime != null && oldEndDateTime != null) {
            valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c!= null ? valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c : DateTime.newInstanceGmt(workWeek.getNextWorkingDay((Datetime)kanbanCardDates[0].get('minimumStartDate')).dateGMT(), oldStartDateTime.timeGMT());
            valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c =  valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c != null ?  valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c : DateTime.newInstanceGmt(workWeek.getNextWorkingDay((Datetime)kanbanCardDates[0].get('maximumDueDate')).dateGMT(),oldEndDateTime.timeGMT());
        } else if (!String.isBlank(finalStartDate)) {
            DateTime projectBoardFinalStartDate = (DateTime)JSON.deserialize(finalStartDate, DateTime.class);
            if (valueStreamWithNewDates != null && projectBoardFinalStartDate != null && oldStartDateTime != null && oldEndDateTime != null) {
                valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = DateTime.newInstanceGmt(projectBoardFinalStartDate.dateGMT(),oldStartDateTime.timeGMT()); 
                valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = DateTime.newInstanceGmt(projectBoardFinalStartDate.dateGMT(),oldEndDateTime.timeGMT());
            }
        } else if (!String.isBlank(finalDate)) {
            DateTime projectBoardFinalDate = (DateTime)JSON.deserialize(finalDate, DateTime.class);
            if (valueStreamWithNewDates != null && projectBoardFinalDate != null && oldStartDateTime != null && oldEndDateTime != null) {
                valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = DateTime.newInstanceGmt(projectBoardFinalDate.dateGMT(),oldStartDateTime.timeGMT()); 
                valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = DateTime.newInstanceGmt(projectBoardFinalDate.dateGMT(),oldEndDateTime.timeGMT());
            }
        } else {
            if (valueStreamWithNewDates != null && workWeek != null) {
                valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = Util.readNextWorkingDateTime(workWeek,System.now()); 
                valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = Util.readNextWorkingDateTime(workWeek,System.now());
            }
        }
        update valueStreamWithNewDates;
        valueStreamWithNewDates.clear();
    }

    /*cloning Stickers*/
    public static void cloneStickers(BoardData boardData) {    
        //Check CRUD / FLC behavior 
        StickerBehavior stickerBehavior = new StickerBehavior();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        if (!stickerBehavior.isAccessible() ||
            !stickerBehavior.isCreateable() ||
            !stickerBehavior.isUpdateable() ||
            !attachmentBehaviour.isAccessible() ||
            !attachmentBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Sticker__c> newStickers = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> stickers= [Select Id, 
                                                    leankor__ValueStream__c,
                                                    Name,
                                                    OwnerId 
                                                From leankor__Sticker__c 
                                                Where leankor__ValueStream__c =: boardData.sourceValueStreamId 
                                                With Security_Enforced
                                                Limit 10000]; 
        if (stickers.Size() > 0) {
            Map<String,String> stickerIDs = new  Map<String,String>();
            for (leankor__Sticker__c sticker :stickers) {
                leankor__Sticker__c newSticker = new leankor__Sticker__c(leankor__ValueStream__c = boardData.newValueStreamId, Name = sticker.Id, OwnerId = sticker.OwnerId );
                newStickers.add(newSticker);
                stickerIDs.put(sticker.Id, sticker.Name);
            }
            try {
                DataBase.insert(newStickers,false); 
            } catch(DMLException ex) {
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            } 
            for (leankor__Sticker__c sticker : newStickers) {
                String stickerName = sticker.Name; 
                sticker.Name = stickerIDs.get(stickerName);
                stickerIDs.put(stickerName,sticker.Id);
            }
            try {
                DataBase.update(newStickers,false); 
            } catch(DMLException ex) {
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            List<Attachment> newAttchments = new List<Attachment>();
                                
            for (Attachment[] attachment : [Select Body,
                                                    BodyLength, 
                                                    ContentType, 
                                                    Description, 
                                                    Id, 
                                                    Name, 
                                                    OwnerId, 
                                                    ParentId 
                                            From Attachment 
                                            Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                And ParentId In :stickers 
                                            Limit 10000]) {
                for (Integer iCount = 0; iCount < attachment.size(); iCount++) {                           
                    Attachment newAttachment = new Attachment(
                        Name = attachment[iCount].Name,
                        ContentType = attachment[iCount].ContentType,
                        ParentID = stickerIDs.get(attachment[iCount].ParentId),
                        Body = attachment[iCount].Body
                    );
                    newAttchments.add(newAttachment);        
                }
            }                   
            
            try {
                DataBase.insert(newAttchments,true); 
            } catch(DMLException ex) {
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
    }


    public static void cloneMarkers(BoardData boardData) {
        //Check CRUD / FLC behavior 
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        if (!markerBehaviour.isAccessible() ||
            !markerBehaviour.isCreateable() ||
            !attachmentBehaviour.isAccessible() ||
            !attachmentBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        List<leankor__Marker__c> remoteMarkers = [Select Id,
                                                        leankor__Type__c,
                                                        leankor__UrlLink__c,
                                                        leankor__ZIndex__c,
                                                        leankor__TextLabel__c,
                                                        leankor__Bottom__c,
                                                        leankor__CmpID__c,
                                                        leankor__CSSLayout__c,
                                                        leankor__GUID2__c,
                                                        leankor__GUID__c,
                                                        leankor__Height__c,
                                                        leankor__JSONData__c,
                                                        leankor__JSONDefinition__c,
                                                        leankor__Left__c,
                                                        leankor__LockState__c,
                                                        leankor__Sticker__c,
                                                        leankor__Top__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        Name,OwnerId 
                                                    From leankor__Marker__c 
                                                    Where leankor__ValueStream__c =: boardData.sourceValueStreamId
                                                    With Security_Enforced
                                                    Limit 10000];
                    
        if (remoteMarkers.isEmpty() && boardData.BoardType == 'DashBoard') {
            remoteMarkers= RealTimeControllerHelper.readMarkers();
        }

        Map<String,String> oldMarkerIdMap = new Map<String,String>();
        Map<String,String> newMarkerIdMAP = new Map<String,String>();
        List<leankor__Marker__c> newMarkers = new List<leankor__Marker__c>();
        
        for (leankor__Marker__c remoteMarker : remoteMarkers) {
            String tempGUID = remoteMarker.Id+'-' + System.now().getTime() + '-m';
            
            leankor__Marker__c newMarker = new leankor__Marker__c();
            newMarker.leankor__GUID__c = tempGUID;
            newMarker.leankor__Type__c= remoteMarker.leankor__Type__c;
            newMarker.leankor__UrlLink__c= remoteMarker.leankor__UrlLink__c;
            newMarker.leankor__ZIndex__c = remoteMarker.leankor__ZIndex__c;
            newMarker.leankor__TextLabel__c = remoteMarker.leankor__TextLabel__c;
            newMarker.leankor__GUID2__c = tempGUID;
            newMarker.leankor__CmpID__c = remoteMarker.leankor__CmpID__c;
            newMarker.Name = remoteMarker.Name;
            newMarker.leankor__Top__c = remoteMarker.leankor__Top__c;
            newMarker.leankor__Bottom__c = remoteMarker.leankor__Bottom__c;
            newMarker.leankor__Left__c = remoteMarker.leankor__Left__c;
            newMarker.leankor__Width__c = remoteMarker.leankor__Width__c;
            newMarker.leankor__Height__c = remoteMarker.leankor__Height__c;
            newMarker.leankor__X__c = remoteMarker.leankor__X__c;
            newMarker.leankor__Y__c = remoteMarker.leankor__Y__c;
            newMarker.leankor__CSSLayout__c = remoteMarker.leankor__CSSLayout__c;
            newMarker.leankor__JSONDefinition__c = remoteMarker.leankor__JSONDefinition__c;
            newMarker.leankor__JSONData__c = remoteMarker.leankor__JSONData__c;
            newMarker.leankor__ValueStream__c = boardData.newValueStreamId;
            newMarker.leankor__Sticker__c = (remoteMarker.leankor__Sticker__c == ''? null : remoteMarker.leankor__Sticker__c);
            newMarker.leankor__ValueStreamLink__c = (remoteMarker.leankor__ValueStreamLink__c == null ? null :remoteMarker.leankor__ValueStreamLink__c);
            newMarker.leankor__LockState__c = remoteMarker.leankor__LockState__c;
            newMarker.leankor__ValueStreamCardLink__c = (remoteMarker.leankor__ValueStreamCardLink__c == null ? null : remoteMarker.leankor__ValueStreamCardLink__c );
            oldMarkerIdMap.put(remoteMarker.Id, tempGUID);
            newMarkers.add(newMarker);
        }
        
        try {
            DataBase.insert(newMarkers,true);
        } catch (DmlException e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }         
        for (leankor__Marker__c newMarker : newMarkers) {
            newMarkerIdMAP.put(newMarker.leankor__GUID2__c, newMarker.Id);
        }       

        List<Attachment> newAttachList = new List<Attachment>();
        Map<String,SObject> attachmentMap = new Map<String,SObject>();
        for (Attachment[] attachment : [Select Body, 
                                                ContentType, 
                                                Description, 
                                                Id, 
                                                Name, 
                                                OwnerId, 
                                                ParentId 
                                            From Attachment 
                                            Where Parent.Type IN :SETSTICKERSOBJECTS_CONST 
                                                And ParentId IN :RemoteMarkers 
                                            Limit 10000]) {
            for (Integer iCount = 0; iCount < attachment.size(); iCount++) {
                attachmentMap.put(attachment[iCount].ParentId, attachment[iCount]);

                String tempGUID = (oldMarkerIdMap.ContainsKey(attachment[iCount].ParentID) ? oldMarkerIdMap.get(attachment[iCount].ParentID) : '');
                String tempParentId = '';
                tempParentId = (newMarkerIdMAP.ContainsKey(tempGUID) ? newMarkerIdMAP.get(tempGUID) : '');
                if (tempParentId != null && tempParentId != '') {
                    Attachment newAttach = new Attachment();
                    newAttach.Name = attachment[iCount].Name;
                    newAttach.ContentType = attachment[iCount].ContentType;
                    newAttach.ParentID = tempParentId;
                    newAttach.Body = attachment[iCount].Body;
                    newAttachList.add(newAttach);
                }   
                                    
            }
        }

        if (newAttachList.size() >0) {
            try {
                Database.insert(newAttachList,true);
            } catch (DmlException e) {
			    throw new Util.LeanException('ERROR:' + e.getMessage()); 
            }
        }

    }

    public Class ChartJSON{
        String column;
        String columnLabel;
        String operator;
        String operatorLabel;
        String dataType;
        String value;
        String valueData;
    }

    public static void cloneCharts(BoardData boardData) {
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ChartBehaviour chartBehaviour = new ChartBehaviour(); 
        if (!valueStreamBehavior.isAccessible() ||
            !chartBehaviour.isAccessible() ||
            !chartBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }

        leankor__ValueStream__c newValueStream = [Select Id,
                                                        Name,
                                                        leankor__projectroom__c,
                                                        leankor__projectroom__r.Name 
                                                    From leankor__ValueStream__c 
                                                    Where Id =: boardData.newValueStreamId 
                                                    With Security_Enforced
                                                    Limit 1];
        String valueStreamName;
        String valueStreamRoomName;
        String roomId;
        String rollupId;
        
        valueStreamName = newValueStream.Name;
        valueStreamRoomName = newValueStream.leankor__projectroom__r.Name;
        roomId = newValueStream.leankor__projectroom__c;

        if (newValueStream.leankor__projectroom__c != null) {
            List<leankor__ValueStream__c> rollupVS = [Select Id 
                                                        From leankor__Valuestream__c 
                                                        Where leankor__Projectroom__c =: newValueStream.leankor__projectroom__c 
                                                            And leankor__BoardType__c = 'Plan Board' 
                                                        With Security_Enforced
                                                        Limit 1];
            if (rollupVS.size() > 0) {
                rollupId = rollupVS[0].Id;
            }
        }
        
        List<leankor__Chart__c> remoteCharts = [Select Id,
                                                        leankor__OnlyShowChart__c,
                                                        leankor__ChartURL__c,
                                                        leankor__CmpID__c,
                                                        leankor__DeveloperName__c,
                                                        leankor__Filter__c,leankor__Format__c,
                                                        leankor__GUID__c,
                                                        leankor__Height__c,
                                                        leankor__JSONData__c,
                                                        leankor__Left__c,
                                                        leankor__LockState__c,
                                                        leankor__ReportId__c,
                                                        leankor__Size__c,
                                                        leankor__Top__c,
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        Name,
                                                        OwnerId 
                                                    From leankor__Chart__c 
                                                    Where leankor__ValueStream__c =: boardData.sourceValueStreamId 
                                                    With Security_Enforced
                                                    Limit 10000];
        if (remoteCharts.size() == 0) {
            remoteCharts = [Select Id,
                                    leankor__OnlyShowChart__c,
                                    leankor__ChartURL__c,
                                    leankor__CmpID__c,
                                    leankor__DeveloperName__c,
                                    leankor__Filter__c,
                                    leankor__Format__c,
                                    leankor__GUID__c,
                                    leankor__Height__c,
                                    leankor__JSONData__c,
                                    leankor__Left__c,
                                    leankor__LockState__c,
                                    leankor__ReportId__c,
                                    leankor__Size__c,
                                    leankor__Top__c,
                                    leankor__ValueStream__c,
                                    leankor__Width__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    Name,OwnerId
                                From leankor__Chart__c 
                                Where leankor__ValueStream__c =:boardData.sourceValueStreamId
                                With Security_Enforced
                                Limit 10000];
        }

        List<leankor__Chart__c> newCharts = new List<leankor__Chart__c>();
        for (leankor__Chart__c chart : remoteCharts) {
            if (chart.leankor__ValueStream__c != null) {
                leankor__Chart__c newchart = new leankor__Chart__c();
                    newchart.Name = chart.Name;
                    newchart.leankor__DeveloperName__c = chart.leankor__DeveloperName__c;
                    newchart.leankor__Filter__c = chart.leankor__Filter__c;
                    newchart.leankor__Format__c = chart.leankor__Format__c;
                    newchart.leankor__GUID__c = chart.Id+'-'+System.Now().getTime()+'-c';
                    newchart.leankor__Height__c = chart.leankor__Height__c;
                    newchart.leankor__Left__c = chart.leankor__Left__c;
                    newchart.leankor__LockState__c = chart.leankor__LockState__c;
                    newchart.leankor__ReportId__c = chart.leankor__ReportId__c;
                    newchart.leankor__Top__c = chart.leankor__Top__c;
                    newchart.leankor__ValueStream__c = boardData.newValueStreamId;
                    newchart.leankor__Width__c = chart.leankor__Width__c;
                    newchart.leankor__X__c = chart.leankor__X__c;
                    newchart.leankor__Y__c = chart.leankor__Y__c;
                    newchart.leankor__CmpID__c =chart.leankor__CmpID__c;
                    newchart.leankor__Size__c = chart.leankor__Size__c;    
                    newchart.leankor__ChartURL__c = chart.leankor__ChartURL__c;
                    if (chart.leankor__JSONData__c != '' && chart.leankor__JSONData__c != null && chart.leankor__JSONData__c !='[{}]') {
                        List<ChartJSON> jsonLogs = (List<ChartJSON>)JSON.deserialize(chart.leankor__JSONData__c, List<ChartJSON>.class);
                        if (boardData.boardType=='DashBoard') {
                            for (ChartJSON log : jsonLogs) {
                                if (log.columnLabel.contains('ID')) {
                                    if (log.columnLabel.contains('Value Stream ID')) {
                                        log.value = rollupId;
                                    log.valueData = rollupId;
                                    } else if (log.columnLabel.contains('Project Room ID')) {
                                        log.value = roomId;
                                        log.valueData = roomId;
                                    }
                                } else if (log.columnLabel == 'Value Stream: Value Stream Name' || log.columnLabel == 'Value Stream Name' || (log.columnLabel.contains('Value Stream Name') && !log.columnLabel.contains('Project Room'))) { 
                                    log.value = 'Roll-Up('+valueStreamRoomName+')';
                                    log.valueData = 'Roll-Up('+valueStreamRoomName+')';
                                } else if (log.columnLabel == 'Project Room' || log.columnLabel == 'Project Room Name' || log.columnLabel.contains('Project Room')) {
                                    log.value = valueStreamRoomName;
                                    log.valueData = valueStreamRoomName;                         
                                }
                            }
                        } else {
                            for (ChartJSON log : jsonLogs) {
                                if (log.columnLabel == 'Value Stream: Value Stream Name' || log.columnLabel == 'Value Stream Name' || log.columnLabel.contains('Value Stream Name')) {
                                    log.value = valueStreamName;
                                    log.valueData = valueStreamName;
                                } else if (log.columnLabel == 'Project Room' || log.columnLabel == 'Project Room Name' || log.columnLabel.contains('Project Room')) {
                                    log.value = valueStreamRoomName;
                                    log.valueData = valueStreamRoomName;                         
                                }
                            }
                        }
                        newchart.leankor__JSONData__c = JSON.serialize(jsonLogs);
                    } else {
                        newchart.leankor__JSONData__c = chart.leankor__JSONData__c;   
                    }  
                    newchart.leankor__OnlyShowChart__c = chart.leankor__OnlyShowChart__c;  
                newCharts.add(Newchart);
            }
        }   
        try {
            Database.insert(newCharts, false); 
        } catch (DmlException e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());    
        }
    }


    public static void cloneFiles(BoardData boardData,  Map<String,String> mapWithOldKanbanCard) {
        //Check CRUD / FLC behavior 
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

    	List<FeedItem> feedItemList = new List<FeedItem>();
    	for (FeedItem feedInstance : RealTimeControllerHelper.readFeedItems(mapWithOldKanbanCard.keySet())) {	
			//Do not clone feed item which has deleted files
            if (String.isNotBlank(feedInstance.relatedRecordId)) {
	    		FeedItem feedItem  = new FeedItem();
	    		feedItem.body = '';
                
				feedItem.parentId = mapWithOldKanbanCard.get(feedInstance.parentId);


				feedItem.relatedRecordId = feedInstance.relatedRecordId;
				feedItemList.add(feedItem);
	    	}
    	}
    	Database.insert(feedItemList,true);
    }

    public static List<leankor__Zone__c> getZones(Set<String> boardId) {
        return [Select Id, 
                        leankor__OpportunityStageName__c, 
                        leankor__UrlLink__c, 
                        leankor__Bottom__c,
                        leankor__CardsPerRow__c,
                        leankor__CaseStatus__c, 
                        leankor__CmpID__c, 
                        leankor__CompletionRateUnits__c, 
                        leankor__CompletionRate__c, 
                        leankor__CSSLayout__c, 
                        leankor__DefaultHeight__c, 
                        leankor__DefaultWidth__c, 
                        leankor__EntryFlowName__c, 
                        leankor__ExitFlowName__c,
                        leankor__GUID__c, 
                        leankor__Height__c, 
                        leankor__Help__c, 
                        leankor__JSONDefinition__c, 
                        leankor__KanbanCardCount2__c, 
                        leankor__KanbanCardThroughput__c,
                        leankor__kanbanSequence__c, 
                        leankor__LeadTime__c, 
                        leankor__Left__c, 
                        leankor__Limit__c, 
                        leankor__Order__c, 
                        leankor__ParentZone__c, 
                        leankor__Swimlane__c, 
                        leankor__Title__c, 
                        leankor__Top__c,
                        leankor__ValueStreamCardLink__c, 
                        leankor__ValueStreamLink__c,
                        leankor__ValueStream__c,
                        leankor__Width__c, 
                        leankor__X__c,
                        leankor__Y__c,
                        leankor__zoneMode__c, 
                        leankor__ZoneTemplate__c, 
                        Name, 
                        OwnerId,
                        leankor__Unit__c 
                    From leankor__Zone__c 
                    Where leankor__ValueStream__c In :boardId
                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                    With Security_Enforced
                    Limit 10000];
    }


    public class CloneProjectPlanGanttBatchException extends Exception {}
   
}