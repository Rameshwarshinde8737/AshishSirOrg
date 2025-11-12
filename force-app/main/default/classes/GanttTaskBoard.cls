/**
* Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
* FILE:  GanttTaskBoard.cls
* CLASS: GanttTaskBoard
* USAGE: manages to Get record of Card for Gantt boards  .
*/
global with sharing class GanttTaskBoard {
    
    //Set to private static so can only be used in this class
    private static DescribeSchema ganttTaskBoardDescribeSchema = new DescribeSchema();
   
    public static List<leankor__VisualLeanUIItemSetting__mdt> UIItemSettings = leankor.RealTimeController.getVisualLeanUIItemSettings();
    public static List<leankor__VisualLeanUIHeaderSetting__mdt> UIHeaderSettings = leankor.RealTimeController.getVisualLeanUIHeaderSettings();
    public static Map<String, Schema.SObjectField> fieldMapKanbanCard = ganttTaskBoardDescribeSchema.getObjectFields('leankor__KanbanCard__c');
    public static Map<String, Schema.FieldSet> fieldSetMap = ganttTaskBoardDescribeSchema.getFieldSets('leankor__KanbanCard__c');
    
    // Date 12.04.2019 : Used in readGanttTasks to get child of AG that are added in childcardsRecursive method.
    public static set<String> cloneAGCardIds = new set<String>();
    
    global GanttTaskBoard(ApexPages.StandardController controller) {}
    
    public GanttTaskBoard(Util controller){}
    global GanttTaskBoard(){
    
    }
    global class GanttResourcesScheduler 
    {
        global List<leankor.KanbanToGanttController.MasterContainer> Activity;
        global List<leankor.GanttTaskBoard.Miniature> Miniature;
        global List<leankor.GanttTaskBoard.UserData> UserRecords;
        global leankor.GanttTaskBoard.OnloadData DataLog;
        global String MaxDate;
        global String MinDate;
        global String ProjectName;
        global String ProjectId;
        global Integer WorkingHoursPerDay;
        global list<leankor.GanttTaskBoard.ResourceAssignment> ResourceAssignmentData;
        public boolean isDependencyAckRecalculate; 
        //RS 22.04.2019 Added variable to check HasEditAccess
        public boolean hasEditAccess;  
        // Date: 22/05/2019 Added variable for project launch date
        public String projectLaunchDate;
        //Date: 13.08.2018 Need to update baseLine data in Filter.FeatureData on load 
        public String lastSetBaselineId;
        public List<KanbanController.CreateFilter> Filters;
        public List <User> FilterUserRecords;
        public List<leankor__KanbanCardTemplate__c> KanbanCardTemplates;
        public GanttTaskBoard.ValueStreamPlanning ActivityRecords;

        public DateTime projectBoardEndDateTime;
        public DateTime projectBoardStartDateTime;
        public Boolean scheduleBackward;
    }
    
    public class ValueStreamPlanning {
        public String Name;
        public String Id;
        public String StartDate;
        public String DueDate;
        public String ItemType;
        public Boolean ScheduleBackwards;
        public List<leankor.KanbanToGanttController.MasterContainer> children;
        public String folderName;
    }
 
    
    global class LeanException extends Exception {}
    
    @RemoteAction
    global static GanttResourcesScheduler getAllPlanBoardcards(String roomId){ 
        GanttResourcesScheduler result = new GanttResourcesScheduler();
        return result;
    }

    public class GanttTask {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Title;
        @AuraEnabled
        public String GUID;
        @AuraEnabled
        public Decimal Order;
        @AuraEnabled
        public String StartDate;
        @AuraEnabled
        public String DueDate;
        @AuraEnabled
        public Decimal PercentDone;
        @AuraEnabled
        public Decimal EstimatedDuration;
        @AuraEnabled
        public String DurationUnits; 
        @AuraEnabled
        public String CardID;
        @AuraEnabled
        public String TemplateID;
        @AuraEnabled
        public Integer Priority;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String ValueStreamCardLink;
        @AuraEnabled
        public String ValueStreamLinkID;
        @AuraEnabled
        public String OwnerID;
        @AuraEnabled
        public String ItemType;
        @AuraEnabled
        public String Color;
        @AuraEnabled
        public Boolean IsExternallyDependent;
        @AuraEnabled
        public Boolean IsSuccessorRecalculate;
        @AuraEnabled
        public Date HarveyBallDoneDate;
        @AuraEnabled
        public DateTime PromiseCompletionDate;
        @AuraEnabled
        public Boolean isConstraintRecalculate;
        @AuraEnabled
        public Boolean ManuallyScheduled;
        @AuraEnabled
        public String SchedulingMode;
        @AuraEnabled
        public String EffortUnit;
        @AuraEnabled
        public Decimal Effort;
        @AuraEnabled
        public String SchedulingModeId;
        @AuraEnabled
        public String ConstraintType;
        @AuraEnabled
        public DateTime ConstraintDate;
        @AuraEnabled
        public DateTime BaselineStartDate;
        @AuraEnabled
        public DateTime BaselineEndDate;
        @AuraEnabled
        public Integer workOrderCount;
        @AuraEnabled
        public Integer serviceAppointmentCount;
        @AuraEnabled
        public DateTime fslSchedStartDateTime;
        @AuraEnabled
        public DateTime fslSchedDueDateTime;
        @AuraEnabled
        public Boolean Monday;
        @AuraEnabled
        public Boolean Tuesday;
        @AuraEnabled
        public Boolean Wednesday;   
        @AuraEnabled
        public Boolean Thursday;
        @AuraEnabled
        public Boolean Friday;
        @AuraEnabled
        public Boolean Saturday;
        @AuraEnabled
        public Boolean Sunday;
        @AuraEnabled
        public String weekCalendar;
    }

    public class ValueStreamPlanningInfo {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String StartDate;
        @AuraEnabled
        public String DueDate;
        @AuraEnabled
        public String ItemType;
        @AuraEnabled
        public Boolean ScheduleBackwards;
        @AuraEnabled
        public List<leankor.GanttTaskBoard.GanttTask> children;
        @AuraEnabled
        public String folderName;
        @AuraEnabled
         public decimal differenceCount;
    }

    global class GanttResourcesSchedulerInfo {
        @AuraEnabled
        global List<leankor.GanttTaskBoard.Miniature> Miniature;
        @AuraEnabled
        global List<leankor.GanttTaskBoard.UserData> UserRecords;
        @AuraEnabled
        global List<leankor.GanttTaskBoard.ResourceAssignment> ResourceAssignmentData;
        @AuraEnabled
        public Boolean hasEditAccess;  
        @AuraEnabled
        public String projectLaunchDate;
        @AuraEnabled
        public String lastSetBaselineId;
        @AuraEnabled
        public GanttTaskBoard.ValueStreamPlanningInfo ActivityRecords;
        @AuraEnabled
        public boolean isShowCategoryColor;
        @AuraEnabled
        public boolean sevenDayWorkWeek;
    }


    @RemoteAction   
    @AuraEnabled 
    global static GanttResourcesSchedulerInfo readAllPlanBoardCards(String roomId) {

        if (String.isNotBlank(roomId) && Util.getSObjectName(roomId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ProjectRoomBehaviour projectRoomBehaviour =  new ProjectRoomBehaviour();
        
        if (!valueStreamBehavior.isAccessible() 
        || !projectLaunchBehavior.isAccessible() 
        || !kanbanCardBehaviour.isAccessible() 
        || !scheduleModeBehavior.isAccessible() 
        || !projectRoomBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        GanttResourcesSchedulerInfo result = new GanttResourcesSchedulerInfo();

        try {
            List<leankor__ValueStream__c> planBoards = [Select Id,
                                                                Name,
                                                                leankor__BoardType__c, 
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__IsShowCategoryColor__c,
                                                                leankor__ProjectRoom__c,
                                                                UserRecordAccess.HasEditAccess,
                                                                leankor__ProjectBoardStartDateTime__c,
                                                                leankor__ProjectBoardEndDateTime__c,
                                                                leankor__ScheduleBackward__c,
                                                                leankor__ProjectRoom__r.Name,
                                                                leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c,
                                                                (Select Id
                                                                    From Project_Schedule_Baselines__r
                                                                    Order By CreatedDate Desc
                                                                    Limit 1)        
                                                            From leankor__ValueStream__c 
                                                            Where ID = :roomId
                                                           // Where leankor__BoardType__c = :'UberBoard' 
                                                               // And leankor__ProjectRoom__c = :roomId
                                                                And leankor__isRecordDeleted__c = false  
                                                            Order By CreatedDate 
                                                            Limit 1];  

            if (!planBoards.isEmpty()) {
                Set<Id> valuestreamIds = new Set<Id>{planBoards[0].Id};
                Set<String> activityIds = new Set<String>();
                Set<Id> userIds = new Set<Id>();
                Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{String.valueOf(planBoards[0].Id)}, 'Valuestream');
                Integer fslDataInfoSize = fslDataInfo.size();
                Id lastSetBaselineId = planBoards[0].Project_Schedule_Baselines__r.size() > 0 
                    ? planBoards[0].Project_Schedule_Baselines__r[0].Id
                    : null;

                GanttTaskBoard.ValueStreamPlanningInfo valueStreamPlanning = new GanttTaskBoard.ValueStreamPlanningInfo();   
                valueStreamPlanning.children = new List<leankor.GanttTaskBoard.GanttTask>(); 
                for (leankor__Kanbancard__c kanbanCard : lastSetBaselineId != null ? getAllCardsWithBaseline(lastSetBaselineId, valuestreamIds) : getAllCards(valuestreamIds)) {
                    userIds.add(kanbanCard.OwnerId);
                    activityIds.add(kanbanCard.Id);
                    leankor.GanttTaskBoard.GanttTask kanbanCardData = new leankor.GanttTaskBoard.GanttTask();         
                    kanbanCardData.Id = kanbanCard.Id;
                    kanbanCardData.Name = kanbanCard.Name;                                 
                    kanbanCardData.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
                    kanbanCardData.GUID = kanbanCard.leankor__GUID__c;
                    kanbanCardData.Order = kanbanCard.leankor__Order__c;
                    kanbanCardData.StartDate = Json.Serialize(kanbanCard.leankor__StartDateTime__c);
                    kanbanCardData.DueDate = Json.Serialize(kanbanCard.leankor__DueDateTime__c);
                    kanbanCardData.PercentDone = kanbanCard.leankor__PercentComplete2__c;
                    kanbanCardData.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;                 
                    kanbanCardData.DurationUnits = kanbanCard.leankor__DurationUnits__c == 'Days' ? 'd' :(kanbanCard.leankor__DurationUnits__c == 'Weeks' ? 'w' : (kanbanCard.leankor__DurationUnits__c == 'Hours' ? 'h': (kanbanCard.leankor__DurationUnits__c == 'Months' ? 'mo' : (kanbanCard.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
                    kanbanCardData.CardId = kanbanCard.leankor__CardId__c;                    
                    kanbanCardData.TemplateId = (kanbanCard.leankor__KanbanCardTemplate__c == null ? '' : kanbanCard.leankor__KanbanCardTemplate__c);
                    kanbanCardData.Priority = Integer.valueOf(kanbanCard.leankor__Priority__c);
                    kanbanCardData.Description = kanbanCard.leankor__DescriptionLong__c;               
                    kanbanCardData.ValueStreamCardLink = (kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c);
                    kanbanCardData.ValueStreamLinkId = (kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c);
                    kanbanCardData.OwnerId = kanbanCard.OwnerId;   
                    kanbanCardData.ItemType = kanbanCard.RecordType.Name;
                    kanbanCardData.Color = (kanbanCard.leankor__kanbanCardTemplate__r.Color__c == null ? '' : kanbanCard.leankor__kanbanCardTemplate__r.Color__c);
                    kanbanCardData.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c; 
                    kanbanCardData.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c; 
                    kanbanCardData.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
                    kanbanCardData.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c;             
                    
                    if (kanbanCardData.ItemType == 'MileStoneCard' && kanbanCardData.EstimatedDuration != 0) {
                        kanbanCardData.ItemType = 'ActivityCard';
                    }
                            
                    if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                        kanbanCardData.isConstraintRecalculate = kanbanCard.leankor__IsConstraintRecalculate__c;
                    }

                    if (kanbanCard.leankor__ScheduleModes__r.size() > 0) {
                        kanbanCardData.ManuallyScheduled = kanbanCard.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                        kanbanCardData.SchedulingMode = kanbanCard.leankor__ScheduleModes__r[0].leankor__Mode__c;
                        kanbanCardData.EffortUnit = kanbanCard.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                        kanbanCardData.Effort = kanbanCard.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                        kanbanCardData.SchedulingModeId = kanbanCard.leankor__ScheduleModes__r[0].Id;
                        
                        if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                            kanbanCardData.ConstraintDate = kanbanCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                            kanbanCardData.ConstraintType = kanbanCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                        }
                    }

                    if (kanbanCard.leankor__Kanban_Card_Baselines__r.size() > 0) {
                        kanbanCardData.BaselineStartDate = kanbanCard.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                        kanbanCardData.BaselineEndDate = kanbanCard.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c;                       
                    }
                    
                    if (fslDataInfoSize > 0 && fslDataInfo.containsKey(kanbanCard.Id)) {
                        FieldServiceUtilityController.RecordDetails recordDetail = fslDataInfo.get(kanbanCard.Id);
                        kanbanCardData.workOrderCount = recordDetail.workOrderCount;
                        kanbanCardData.serviceAppointmentCount = recordDetail.serviceAppointmentCount != null ? recordDetail.serviceAppointmentCount : 0;
                        kanbanCardData.fslSchedStartDateTime = recordDetail.fslSchedStartDateTime;
                        kanbanCardData.fslSchedDueDateTime = recordDetail.fslSchedDueDateTime;
                    } else {
                        kanbanCardData.workOrderCount = 0;
                        kanbanCardData.serviceAppointmentCount = 0;
                        kanbanCardData.fslSchedStartDateTime = null;
                        kanbanCardData.fslSchedDueDateTime = null;
                    }

                    if (kanbanCard.leankor__Monday__c 
                    || kanbanCard.leankor__Tuesday__c 
                    || kanbanCard.leankor__Wednesday__c 
                    || kanbanCard.leankor__Thursday__c 
                    || kanbanCard.leankor__Friday__c 
                    || kanbanCard.leankor__Saturday__c 
                    || kanbanCard.leankor__Sunday__c) {
                        kanbanCardData.Monday = kanbanCard.leankor__Monday__c;
                        kanbanCardData.Tuesday  = kanbanCard.leankor__Tuesday__c;
                        kanbanCardData.Wednesday = kanbanCard.leankor__Wednesday__c;
                        kanbanCardData.Thursday = kanbanCard.leankor__Thursday__c;
                        kanbanCardData.Friday = kanbanCard.leankor__Friday__c;
                        kanbanCardData.Saturday = kanbanCard.leankor__Saturday__c;
                        kanbanCardData.Sunday = kanbanCard.leankor__Sunday__c;
                    } else {
                        kanbanCardData.Monday = true;
                        kanbanCardData.Tuesday = true;
                        kanbanCardData.Wednesday = true;
                        kanbanCardData.Thursday = true;
                        kanbanCardData.Friday = true;
                        kanbanCardData.Saturday = true;
                        kanbanCardData.Sunday = true;
                    }

                    kanbanCardData.weekCalendar = kanbanCard.leankor__WeekCalendar__c;
                    valueStreamPlanning.children.add(kanbanCardData);
                }

                Datetime maxTempDate;
                Datetime minTempDate;

                if (activityIds.isEmpty()) {
                    maxTempDate = System.now();
                    minTempDate = System.now();
                } else {
                    AggregateResult aggregateResult = [Select 
                                                            Min(leankor__StartDateTime__c) MinDate, 
                                                            Max(leankor__DueDateTime__c) MaxDate 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c In :valuestreamIds 
                                                            And leankor__isRecordDeleted__c = false 
                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false];
                                                        
                    minTempDate = (DateTime)aggregateResult.get('MinDate');
                    maxTempDate = (DateTime)aggregateResult.get('MaxDate');
                }
                
                valueStreamPlanning.Name = planBoards[0].Name;
                valueStreamPlanning.ItemType = 'Board';
                valueStreamPlanning.Id = planBoards[0].Id;
                
                if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    valueStreamPlanning.StartDate = Json.Serialize(planBoards[0].leankor__ProjectBoardStartDateTime__c);
                    valueStreamPlanning.DueDate = Json.Serialize(planBoards[0].leankor__ProjectBoardEndDateTime__c);
                } else {
                    valueStreamPlanning.StartDate = Json.Serialize(minTempDate);
                    valueStreamPlanning.DueDate = Json.Serialize(maxTempDate);
                }

                valueStreamPlanning.ScheduleBackwards = planBoards[0].leankor__ScheduleBackward__c;
                valueStreamPlanning.folderName = planBoards[0].leankor__ProjectRoom__r.Name;
                result.ActivityRecords = valueStreamPlanning;
                result.Miniature = readMiniatureData(activityIds);
                result.UserRecords = leankor.GanttTaskBoard.getUserdata(userIds);  
                result.ResourceAssignmentData = getResources(activityIds);
                result.SevenDayWorkWeek = planBoards[0].leankor__SevenDayWorkWeek__c;
                result.isShowCategoryColor = planBoards[0].leankor__IsShowCategoryColor__c == null ? false : planBoards[0].leankor__IsShowCategoryColor__c;
                result.hasEditAccess = planBoards[0].UserRecordAccess.HasEditAccess; 
                result.projectLaunchDate = planBoards[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c != null 
                    ? Json.serialize(planBoards[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c) 
                    : '';
                result.lastSetBaselineId = lastSetBaselineId != null ? (String)lastSetBaselineId : '';
            }
        } catch(Exception ex) {
            throw new LeanException('The project associated to this board has been removed');
        }
        return result;
    }

    global class Miniature {
        global string Id; 
        global string Name ;
        global string State ;
        global string CardId ;
        global String DueDate;
        global String StartDate;
        global string ProjectName;
        global string BoardName;
        global string ValueStreamID;
        global string BoardType; 
        //SS 22.10.2018
        //Needs to check isSuccessor of Miniature on load of board
        public boolean IsSuccessorRecalculate; 
        //RS 16.11.2018 Added field for relaxing rules
        Public Boolean isDependencyAckRecalculate ; 
        public String OwnerId; 
         // Date: 11/04/19
        public Decimal PercentDone; 
        //Date :23/04/19 
        public Boolean isDueDatePercentComplete;
        //Date : 09/09/19
        public String Title;
        String valueStreamLinkedBoardId;

        //22/feb/2023 : Both variable added for showing constraint type and constraint date of miniture.
        String ConstraintType;
        DateTime ConstraintDate;
    }

    
    global static List<leankor.GanttTaskBoard.Miniature> getMiniatureData(List<leankor__KanbanCard__c> allMiniaturecards){
        for(leankor__KanbanCard__c allMiniaturecard : allMiniaturecards){
            if(String.isNotBlank(allMiniaturecard.Id) && Util.getSObjectName(allMiniaturecard.Id) != 'leankor__KanbanCard__c'){
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<leankor.GanttTaskBoard.Miniature> result = new List<leankor.GanttTaskBoard.Miniature>();
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();

        Map<Id,Boolean> vsMap = new Map<Id,Boolean>();
      
        for(leankor__KanbanCard__c kanban : allMiniaturecards){
            vsMap.put(kanban.leankor__ValueStream__c, kanban.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c);
        }
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackOutMap =  leankor.RealTimeControllerHelper.getBlackOutRecords(vsMap.keySet());

        Map<Id, leankor.Util.WorkWeek> vsWorkWeekMap = new Map<Id, leankor.Util.WorkWeek>();
        for(Id key: vsMap.keySet()){
            leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(firstDayOfWeek, vsMap.get(key) ? 7: 5, vsBlackOutMap.get(key));
            vsWorkWeekMap.put(key, workWeek);
        }

        for(leankor__Kanbancard__c kcCard : allMiniaturecards){
            leankor.GanttTaskBoard.Miniature miniatureLog = new leankor.GanttTaskBoard.Miniature();
                miniatureLog.Id = kcCard.ID;
                miniatureLog.Name = kcCard.Name ;
                //miniatureLog.State = kcCard.leankor__PercentComplete2__c == 0 ? System.Label.leankor.NotStarted : (kcCard.leankor__PercentComplete2__c < 100 ? System.Label.leankor.InProgress : System.Label.leankor.Done);
                miniatureLog.CardId = kcCard.leankor__ValueStreamCardLink__c;
                miniatureLog.DueDate = Json.Serialize(kcCard.leankor__DueDateTime__c);
                miniatureLog.StartDate = Json.Serialize(kcCard.leankor__StartDateTime__c);
                miniatureLog.ProjectName = kcCard.leankor__Projectroom__c;
                miniatureLog.BoardName = kcCard.leankor__ValueStream__r.Name;
                miniatureLog.BoardType = kcCard.leankor__ValueStream__r.leankor__BoardType__c;
                miniatureLog.ValueStreamID = kcCard.leankor__ValueStream__c;
                //Add IsSuccessor value of miniature to response data
                miniatureLog.IsSuccessorRecalculate = kcCard.leankor__IsSuccessorRecalculate__c;
                miniatureLog.OwnerId = kcCard.OwnerId;
                miniatureLog.PercentDone = kcCard.leankor__PercentComplete2__c;
                miniatureLog.isDueDatePercentComplete = hasSeventyPercentDueDate(kcCard, vsWorkWeekMap.get(kcCard.leankor__ValueStream__c));    
                miniatureLog.Title = kcCard.leankor__KanbanCardTemplate__r.leankor__Title__c;  
                //miniatureLog.valueStreamLinkedBoardId = kcCard.leankor__ValueStreamLink__c;
                
                if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    miniatureLog.ConstraintType = String.isNotBlank(kcCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c) ? kcCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : null;
                    miniatureLog.ConstraintDate = kcCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null ? kcCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                }

            result.add(miniatureLog);        
        }
        return result;
    }


    public static List<leankor.GanttTaskBoard.Miniature> readMiniatureData(Set<String> activityIds) {
        List<leankor.GanttTaskBoard.Miniature> result = new List<leankor.GanttTaskBoard.Miniature>();

        if(activityIds.isEmpty()) {
            return result;
        }

        List<leankor__KanbanCard__c> miniatures = new List<leankor__KanbanCard__c>(); 
        List<String> boardTypeFilter = new List<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
        
		for (leankor__KanbanCard__c miniature : [Select Id, 
                                                        Name, 
                                                        OwnerId, 
                                                        leankor__PercentComplete2__c, 
                                                        leankor__ValueStreamCardLink__c, 
                                                        leankor__IsSuccessorRecalculate__c, 
                                                        leankor__StartDateTime__c, 
                                                        leankor__DueDateTime__c, 
                                                        leankor__ValueStream__c, 
                                                        leankor__Projectroom__c, 
                                                        leankor__ValueStream__r.Name, 
                                                        leankor__ValueStream__r.leankor__BoardType__c,
                                                        leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                                        leankor__KanbanCardTemplate__r.leankor__Title__c,
                                                        leankor__MasterContainer__r.leankor__Type__c,
                                                        (Select Id,
                                                                leankor__ConstraintDateTime__c,
                                                                leankor__ScheduleConstraint__r.leankor__Type__c
                                                            From leankor__ScheduleModes__r 
                                                            Limit 1)
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStreamCardLink__c In :activityIds
                                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                        And leankor__isRecordDeleted__c = false 
                                                        And leankor__BoardType__c In :boardTypeFilter
                                                        And (
                                                                (leankor__ValueStream__r.leankor__IsTemplateBoard__c = false And leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = false)
                                                                Or (leankor__ValueStream__r.leankor__IsTemplateBoard__c = true And leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = true)
                                                            )	
                                                    Limit 50000]){

            if(miniature.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                && miniature.leankor__ValueStream__c != null 
                && miniature.leankor__ProjectRoom__c != null){
                miniatures.add(miniature);
            }
        }

        
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();

        Map<Id, Boolean> valueStreamMap = new Map<Id, Boolean>();
      
        for (leankor__KanbanCard__c kanban : miniatures) {
            valueStreamMap.put(kanban.leankor__ValueStream__c, kanban.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c);
        }
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackOutMap =  leankor.RealTimeControllerHelper.getBlackOutRecords(valueStreamMap.keySet());

        Map<Id, leankor.Util.WorkWeek> vsWorkWeekMap = new Map<Id, leankor.Util.WorkWeek>();
        
        for (Id key : valueStreamMap.keySet()) {
            leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(firstDayOfWeek, valueStreamMap.get(key) ? 7 : 5, vsBlackOutMap.get(key));
            vsWorkWeekMap.put(key, workWeek);
        }

        for (leankor__Kanbancard__c miniature : miniatures) {
            leankor.GanttTaskBoard.Miniature miniatureLog = new leankor.GanttTaskBoard.Miniature();
            miniatureLog.Id = miniature.ID;
            miniatureLog.Name = miniature.Name ;
            miniatureLog.CardId = miniature.leankor__ValueStreamCardLink__c;
            miniatureLog.DueDate = Json.Serialize(miniature.leankor__DueDateTime__c);
            miniatureLog.StartDate = Json.Serialize(miniature.leankor__StartDateTime__c);
            miniatureLog.ProjectName = miniature.leankor__Projectroom__c;
            miniatureLog.BoardName = miniature.leankor__ValueStream__r.Name;
            miniatureLog.BoardType = miniature.leankor__ValueStream__r.leankor__BoardType__c;
            miniatureLog.ValueStreamID = miniature.leankor__ValueStream__c;
            miniatureLog.IsSuccessorRecalculate = miniature.leankor__IsSuccessorRecalculate__c;
            miniatureLog.OwnerId = miniature.OwnerId;
            miniatureLog.PercentDone = miniature.leankor__PercentComplete2__c;
            miniatureLog.isDueDatePercentComplete = hasSeventyPercentDueDate(miniature, vsWorkWeekMap.get(miniature.leankor__ValueStream__c));    
            miniatureLog.Title = miniature.leankor__KanbanCardTemplate__r.leankor__Title__c;  
                
            if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                miniatureLog.ConstraintType = String.isNotBlank(miniature.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c) ? miniature.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : null;
                miniatureLog.ConstraintDate = miniature.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null ? miniature.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
            }
            result.add(miniatureLog);        
        }
        return result;
    }
    /*------------------------------------------------------------   
    Company:        Leankor
    Description:    Use to Miniature Due Date percent  .
    Inputs:         leankor__Kanbancard__c        
    Return:         Boolean
    Date :          23/04/19 
    ------------------------------------------------------------*/     
   /**public static Boolean hasSeventyPercentDueDate(leankor__Kanbancard__c kanbancard, Integer firstDayOfWeek, final Date DATEMONDAY){
       Integer  dateDifference=0 ;
       Integer  currentStartDifference=0;
       Boolean isDueDatePercentComplete;
       Decimal dueDatePercent=0;                             
       //get Diff. b/w Start Date and Due Date.
        dateDifference= Util.getWorkingDays(kanbancard.leankor__StartDateTime__c,kanbancard.leankor__DueDateTime__c,kanbancard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, firstDayOfWeek, DATEMONDAY);                      
        System.debug(' Diff  '+dateDifference);
        //Get diff. b/w Start date and current Date .
        if(system.now()>=kanbancard.leankor__StartDateTime__c){
                currentStartDifference= Util.getWorkingDays(kanbancard.leankor__StartDateTime__c,system.now(),kanbancard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, firstDayOfWeek, DATEMONDAY);                               
        }else{
                currentStartDifference=0;           
        } 
        System.debug(' current diff '+currentStartDifference);  
        //calculate percent b/w current date Diff. and start due date diff.            
        dueDatePercent=(currentStartDifference>dateDifference||dateDifference==0)?100:(currentStartDifference*100)/dateDifference;                     
        System.debug('percent  '+dueDatePercent);                                                           
        //check Boolean  true if dueDatePercent >=70%
        isDueDatePercentComplete= dueDatePercent>=70?true:false; 
      return isDueDatePercentComplete;
   } */

    //Date: 11/14/2019 
    public static Boolean hasSeventyPercentDueDate(leankor__Kanbancard__c kanbancard, Util.WorkWeek workWeekObj){
        
        Integer dateDifference;
        Integer currentStartDifference;
        Decimal dueDatePercent;        

        dateDifference = Math.abs(workWeekObj.getBusinessDays(kanbancard.leankor__StartDateTime__c.date(), kanbancard.leankor__DueDateTime__c.date()));

        //Get diff. b/w Start date and current Date .
        if(System.now() >= kanbancard.leankor__StartDateTime__c){
            currentStartDifference = Math.abs(workWeekObj.getBusinessDays(kanbancard.leankor__StartDateTime__c.date(), System.today()));                               
        }else{       
            currentStartDifference = 0;           
        }   
    
        //calculate percent b/w current date Diff. and start due date diff.            
        dueDatePercent = (currentStartDifference > dateDifference || dateDifference == 0) ? 100 : (currentStartDifference*100)/dateDifference;                     

        //If dueDatePercent >= 70% then returns true else false
        return (dueDatePercent >= 70);
    } 
    

    // Get resources from dependent boards's activity IDs. 
    public static List<leankor.GanttTaskBoard.ResourceAssignment> getResources(Set<String> activityIds){
        List<leankor.GanttTaskBoard.ResourceAssignment> resources = new List<leankor.GanttTaskBoard.ResourceAssignment>();

        if (activityIds.isEmpty()) {
            return resources;
        }

        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!resourceAssignmentBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
                
        for (leankor__ResourceAssignment__c resourceAssignment : [Select Id, 
                                                                        leankor__AssignedTo__c, 
                                                                        leankor__AssignedTo__r.name, 
                                                                        leankor__KanbanCard__c, 
                                                                        leankor__PercentAllocation__c, 
                                                                        Name,
                                                                        leankor__ResourceType__c,
                                                                        leankor__ResourceType__r.Name,
                                                                        leankor__PercentCompleted__c
                                                                    From leankor__ResourceAssignment__c 
                                                                    Where leankor__KanbanCard__c In :activityIds 
                                                                    Limit 50000]) {

            if (resourceAssignment.leankor__ResourceType__c != null || resourceAssignment.leankor__AssignedTo__c != null) {
                leankor.GanttTaskBoard.ResourceAssignment resource = new leankor.GanttTaskBoard.ResourceAssignment();
                resource.Id = resourceAssignment.Id;
                resource.Name = resourceAssignment.Name;
                resource.TaskId = resourceAssignment.leankor__KanbanCard__c;
                resource.Units = resourceAssignment.leankor__PercentAllocation__c;
                resource.ResourceId = resourceAssignment.leankor__AssignedTo__c;
                resource.OwnerName = String.isBlank(resourceAssignment.leankor__ResourceType__r.Name) 
                    ? resourceAssignment.leankor__AssignedTo__r.name
                    : resourceAssignment.leankor__ResourceType__r.Name;
                resource.ResourceTypeId = resourceAssignment.leankor__ResourceType__c;
                resource.resourceType = String.IsBlank(resourceAssignment.leankor__ResourceType__c) 
                    ? 'Leankor'
                    : 'ResourceType';
                resource.PercentCompleted = resourceAssignment.leankor__PercentCompleted__c;
                resources.add(resource);
            }                   
        }
	
		// returns the FSL resource on PG
        if (KanbanController.checkFSLManageApp() && KanbanController.checkFieldExistInSobject()) {
            List<String> kanbanCardIds = new List<String>(activityIds);
            
            for (KanbanController.FieldServiceLigtning fslRecord : KanbanController.getServiceAppointmentRecords(kanbanCardIds)) {
                if (fslRecord.Resources != null) {
                    for (KanbanController.RelatedRecord relatedRecord : fslRecord.Resources) {
                        ResourceAssignment resourceAssignment = new ResourceAssignment();
                        resourceAssignment.Name  = relatedRecord.Name;
                        resourceAssignment.ownerName = relatedRecord.Name;
                        resourceAssignment.ResourceId = relatedRecord.Id;
                        resourceAssignment.activityId = fslRecord.cardId;
                        resourceAssignment.resourceType = 'FSL';
                        resourceAssignment.SmallPhotoUrl = relatedRecord.SmallPhotoUrl;
                        resourceAssignment.appointmentNumber = fslRecord.appointmentNumber;
                        resourceAssignment.workOrderNumber = fslRecord.workOrderNumber;
                        resourceAssignment.startDateTime = fslRecord.startDateTime;
                        resourceAssignment.dueDateTime = fslRecord.dueDateTime;
                        resources.add(resourceAssignment);
                    } 
                } 
            } 
        }

        return resources;
    }
    
    //
    /*Instead of 'childcards' we are calling 'childcardsRecursive' to give show 'Sub Activity Group' on 'Plan Gantt' board while reloading the board.
    Didn't update 'childcards' because it was already in managed package.*/
    //
    global static List<leankor.KanbanToGanttController.MasterContainer> childcards(List<leankor__KanbanCard__c> listofcards,Map<Id,RecordType> recordtype ){
        list<leankor.KanbanToGanttController.MasterContainer> MClist = new list<leankor.KanbanToGanttController.MasterContainer>();     
            return MClist;
    }

    //Should deprecate this method with signature String, List<leankor__KanbanCard__c>, Map<Id,RecordType> and use String, Map<String, List<leankor__KanbanCard__c>>, Map<Id,RecordType> from now on
     //commented on 10/06/19 
    global static List<leankor.KanbanToGanttController.MasterContainer> childcardsRecursive(String KanbancardId,List<leankor__KanbanCard__c> listofcards,Map<Id,RecordType> recordtype){
        if (String.isNotBlank(KanbancardId) && Util.getSObjectName(KanbancardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        for(leankor__KanbanCard__c card : listofcards){
            if (String.isNotBlank(card.Id) && Util.getSObjectName(card.Id) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
       
        list<leankor.KanbanToGanttController.MasterContainer> MClist = new list<leankor.KanbanToGanttController.MasterContainer>();     
        
        //Added check to list size to immediately return so methods like readCardsFSLInfo do not need to be called
        if(listofcards.size() == 0) {
            return MClist;
        }

        //SS 31.12.2018
        //If Fsl is enabled then get FSL data count for cards(activity)         
        Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{listofcards[0].leankor__Valuestream__c},'Valuestream');     
        for(leankor__KanbanCard__c knbnCard : listofcards){  
            if(knbnCard.leankor__ValueStreamCardLink__c == KanbancardId){
                leankor.KanbanToGanttController.MasterContainer KC=new leankor.KanbanToGanttController.MasterContainer();
                    KC.Id=knbnCard.Id;
                    KC.Name=knbnCard.Name;         
                    KC.isMilestone = (recordtype.get(knbnCard.RecordTypeId).Name == 'MilestoneCard' ? true : false);                       
                    KC.Title=knbnCard.leankor__Title__c;               
                    KC.ValueStreamID=knbnCard.leankor__ValueStream__c;
                    KC.CmpID=knbnCard.leankor__CmpID__c;
                    KC.GUID=knbnCard.leankor__GUID__c;
                    KC.Order=knbnCard.leankor__Order__c;
                    KC.StartDate =  JSON.Serialize(knbnCard.leankor__StartDateTime__c);
                    KC.DueDate =  JSON.Serialize(knbnCard.leankor__DueDateTime__c);
                    KC.PercentDone=KnbnCard.leankor__PercentComplete2__c;
                    KC.leaf=(recordtype.get(knbnCard.RecordTypeId).Name == 'FolderCard' ? false : true);
                    KC.EstimatedDuration = KnbnCard.leankor__EstimatedDuration__c ;
                    KC.DurationUnits = KnbnCard.leankor__DurationUnits__c == 'Days' ? 'd' :(KnbnCard.leankor__DurationUnits__c == 'Weeks' ? 'w' : (KnbnCard.leankor__DurationUnits__c == 'Hours' ? 'h': (KnbnCard.leankor__DurationUnits__c == 'Months' ? 'mo' : (KnbnCard.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
                    KC.CardID=knbnCard.leankor__CardID__c;
                    KC.Title=KnbnCard.leankor__KanbanCardTemplate__r.Name;
                    KC.EffortRemaining = integer.valueof(KnbnCard.leankor__EffortRemaining__c);
                    KC.State=KnbnCard.leankor__State__c;
                    KC.ForceID=(knbnCard.id == null ? '' :knbnCard.ID);         
                    KC.TemplateID=(KnbnCard.leankor__KanbanCardTemplate__c==null?'':KnbnCard.leankor__KanbanCardTemplate__c);
                    KC.TemplateName=KnbnCard.leankor__KanbanCardTemplate__r.Name;              
                    KC.Priority=Integer.valueOf(KnbnCard.leankor__Priority__c);
                    KC.HarveyBall=string.valueOf(KnbnCard.leankor__PercentComplete2__c);             
                    KC.Description=KnbnCard.leankor__DescriptionLong__c;           
                    KC.ValueStreamCardLink=(KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__c);
                    KC.ValueStreamLinkID=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__c);
                    KC.ValueStreamCardLinkName = (KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__r.Name); 
                    KC.ValueStreamLinkIDName = (KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.Name);
                    KC.ValueStreamLinkBoardType=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);
                    KC.ValueStreamID=KnbnCard.leankor__ValueStream__c;
                    KC.OwnerID=KnbnCard.OwnerID;
                    KC.KanbanUrl='';
                    KC.BoardType =KnbnCard.leankor__ValueStream__r.leankor__Boardtype__c;
                    KC.Order = KnbnCard.leankor__Order__c;
                    KC.OnBudget = KnbnCard.leankor__OnBudget__c;
                    KC.OnQuality = KnbnCard.leankor__OnQuality__c;
                    KC.OnTime = KnbnCard.leankor__OnTime__c;
                    // Date: 27/05/2019
					KC.isAtRisk = KnbnCard.leankor__IsAtRisk__c;
					KC.isOnHold = KnbnCard.leankor__IsOnHold__c;
                    KC.OwnerName = KnbnCard.Owner.Name;
                    KC.ItemType= recordtype.get(knbnCard.RecordTypeId).Name;                                 
                    KC.IsRecalculate = knbnCard.leankor__Valuestream__r.leankor__Isrecalculate__c;
                    KC.IsExternallyDependent = KnbnCard.leankor__IsExternallyDependent__c;
                    //KC.JSONDefinition = KnbnCard.leankor__JSONDefinition__c;
                    //KC.JSONData = KnbnCard.leankor__JSONData__c;   
                    KC.Color = (KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c==null?'':KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c);   
                    KC.ProjectRoomID= KnbnCard.leankor__Valuestream__r.leankor__ProjectRoom__c;   
                     // adding leankor__IsSuccessorRecalculate__c field for Recalculation of linked activity               
                    KC.IsSuccessorRecalculate = KnbnCard.leankor__IsSuccessorRecalculate__c;                   
                    if(KnbnCard.leankor__ScheduleModes__r.size()>0) {
                        KC.ManuallyScheduled = KnbnCard.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;//KnbnCard.leankor__ValueStream__r.leankor__ManuallyScheduled__c;
                        KC.SchedulingMode= KnbnCard.leankor__ScheduleModes__r[0].leankor__Mode__c;//KnbnCard.leankor__ValueStream__r.leankor__Mode__c;
                        KC.EffortUnit = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                        KC.Effort = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                        KC.SchedulingModeId = KnbnCard.leankor__ScheduleModes__r[0].Id;
                        //Changes : Check constraint setting enable or not.
                        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                            KC.ConstraintDate = KnbnCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                            KC.ConstraintType = KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                        }
                    }
                    if(KnbnCard.leankor__Kanban_Card_Baselines__r != null && KnbnCard.leankor__Kanban_Card_Baselines__r.size()>0){
                            KC.BaselineStartDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                            KC.BaselineEndDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c;                       
                    } 
                    //RS 19/12/2018 Added for relaxing rules 
                    KC.isDependencyAckRecalculate = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c;
                    //SS 30.11.2018
                    //Add FSL data count details with Activity data
                    KC.workOrderCount = fslDataInfo.containsKey(KnbnCard.Id) ? fslDataInfo.get(KnbnCard.Id).workOrderCount : 0;
                    KC.serviceAppointmentCount = fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).serviceAppointmentCount!=null ? fslDataInfo.get(KnbnCard.Id).serviceAppointmentCount   : null ) : 0;
                    kc.fslSchedStartDateTime = fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).fslSchedStartDateTime!=null ? fslDataInfo.get(KnbnCard.Id).fslSchedStartDateTime : null  ) : null;
                    kc.fslSchedDueDateTime =  fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).fslSchedDueDateTime!=null ? fslDataInfo.get(KnbnCard.Id).fslSchedDueDateTime: null ): null;         
                    
                    kc.HarveyBallDoneDate = knbnCard.leankor__HarveyBallDoneDate__c;
                    kc.PromiseCompletionDate = knbnCard.leankor__PromiseCompletionDate__c;             
                    
                    //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                    if(knbnCard.leankor__Monday__c == false && knbnCard.leankor__Tuesday__c == false && knbnCard.leankor__Wednesday__c == false &&  knbnCard.leankor__Thursday__c == false &&  knbnCard.leankor__Friday__c == false &&  knbnCard.leankor__Saturday__c == false &&  knbnCard.leankor__Sunday__c == false){
                        kc.Monday = true;
                        kc.Tuesday = true;
                        kc.Wednesday = true;
                        kc.Thursday = true;
                        kc.Friday = true;
                        kc.Saturday = true;
                        kc.Sunday = true;
                    }else{  
	                    //Pratiksha : 10/Oct/2023 : Passing these week day onLoad on PDG.
	                    kc.Monday = knbnCard.leankor__Monday__c;
	                    kc.Tuesday  = knbnCard.leankor__Tuesday__c;
	                    kc.Wednesday = knbnCard.leankor__Wednesday__c;
	                    kc.Thursday = knbnCard.leankor__Thursday__c;
	                    kc.Friday = knbnCard.leankor__Friday__c;
	                    kc.Saturday = knbnCard.leankor__Saturday__c;
	                    kc.Sunday = knbnCard.leankor__Sunday__c;
	                    kc.weekCalendar = knbnCard.leankor__WeekCalendar__c;
                    }
                    KC.children = (recordtype.get(knbnCard.RecordTypeId).Name == 'FolderCard' ? childcardsRecursive(knbnCard.Id,listofcards,recordtype) : new List<leankor.KanbanToGanttController.MasterContainer>());                   

                MClist.add(KC);
            }
        }
        return MClist;
    }

    // Creates a map containing a string key and a list value pair. The list contains kanbanCards with the same
    // ValueStreamCardLink field value
    public static Map<String, List<leankor__Kanbancard__c>> createMapOfListCards(List<leankor__Kanbancard__c> listCards) {
        Map<String, List<leankor__Kanbancard__c>> mapOfListCards = new Map<String, List<leankor__Kanbancard__c>>();             
        for(leankor__Kanbancard__c card : listCards) {
            String stringId;
            // Does not put key : value pair if ValueStreamCardLink is null
            if(card.leankor__ValueStreamCardLink__c == null) {
                continue;
            } else {
                stringId = card.leankor__ValueStreamCardLink__c;
            }
            // Checks if that particular value in the map is null, i.e. has a list
            // if it does, we simply just add the value to the list, otherwise,
            // we create a new list with that card in it
            if(mapOfListCards.get(stringId) != null) {
                mapOfListCards.get(stringId).add(card);
            } else {
                List<leankor__Kanbancard__c> subListCards = new List<leankor__Kanbancard__c>();
                subListCards.add(card);
                mapOfListCards.put(stringId, subListCards);
            }
        }
        return mapOfListCards;
    }

    //Method override for childsCardsRecursive method
    public static List<leankor.KanbanToGanttController.MasterContainer> childCardsRecursive(String valueStreamCardLinkId, Map<String, List<leankor__KanbanCard__c>> mapOfListCards, Map<Id,RecordType> recordtype, Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo){
        list<leankor.KanbanToGanttController.MasterContainer> kanbanCardWrappers = new list<leankor.KanbanToGanttController.MasterContainer>();     
        
        if(mapOfListCards.size() == 0 || mapOfListCards.get(valueStreamCardLinkId) == null) {
            return kanbanCardWrappers;
        }

        for(leankor__Kanbancard__c kanbanCard : mapOfListCards.get(valueStreamCardLinkId)) {
            leankor.KanbanToGanttController.MasterContainer kanbanCardWrapper=new leankor.KanbanToGanttController.MasterContainer();
            // Add card ids to set cloneAGCardIds
            cloneAGCardIds.add(kanbanCard.Id);
            kanbanCardWrapper.Id=kanbanCard.Id;
            kanbanCardWrapper.Name=kanbanCard.Name;         
            kanbanCardWrapper.isMilestone = (recordtype.get(kanbanCard.RecordTypeId).Name == 'MilestoneCard' ? true : false);                       
            kanbanCardWrapper.Title=kanbanCard.leankor__Title__c;               
            kanbanCardWrapper.ValueStreamID=kanbanCard.leankor__ValueStream__c;
            kanbanCardWrapper.CmpID=kanbanCard.leankor__CmpID__c;
            kanbanCardWrapper.GUID=kanbanCard.leankor__GUID__c;
            kanbanCardWrapper.Order=kanbanCard.leankor__Order__c;
            kanbanCardWrapper.StartDate =  JSON.Serialize(kanbanCard.leankor__StartDateTime__c);
            kanbanCardWrapper.DueDate =  JSON.Serialize(kanbanCard.leankor__DueDateTime__c);
            kanbanCardWrapper.PercentDone=kanbanCard.leankor__PercentComplete2__c;
            kanbanCardWrapper.leaf=(recordtype.get(kanbanCard.RecordTypeId).Name == 'FolderCard' ? false : true);
            kanbanCardWrapper.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c ;
            kanbanCardWrapper.DurationUnits = kanbanCard.leankor__DurationUnits__c == 'Days' ? 'd' :(kanbanCard.leankor__DurationUnits__c == 'Weeks' ? 'w' : (kanbanCard.leankor__DurationUnits__c == 'Hours' ? 'h': (kanbanCard.leankor__DurationUnits__c == 'Months' ? 'mo' : (kanbanCard.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
            kanbanCardWrapper.CardID=kanbanCard.leankor__CardID__c;
            kanbanCardWrapper.Title=kanbanCard.leankor__KanbanCardTemplate__r.Name;
            kanbanCardWrapper.EffortRemaining = integer.valueof(kanbanCard.leankor__EffortRemaining__c);
            kanbanCardWrapper.State=kanbanCard.leankor__State__c;
            kanbanCardWrapper.ForceID=(kanbanCard.id == null ? '' :kanbanCard.ID);         
            kanbanCardWrapper.TemplateID=(kanbanCard.leankor__KanbanCardTemplate__c==null?'':kanbanCard.leankor__KanbanCardTemplate__c);
            kanbanCardWrapper.TemplateName=kanbanCard.leankor__KanbanCardTemplate__r.Name;              
            kanbanCardWrapper.Priority=Integer.valueOf(kanbanCard.leankor__Priority__c);
            kanbanCardWrapper.HarveyBall=string.valueOf(kanbanCard.leankor__PercentComplete2__c);             
            kanbanCardWrapper.Description=kanbanCard.leankor__DescriptionLong__c;           
            kanbanCardWrapper.ValueStreamCardLink=(kanbanCard.leankor__ValueStreamCardLink__c==null?'':kanbanCard.leankor__ValueStreamCardLink__c);
            kanbanCardWrapper.ValueStreamLinkID=(kanbanCard.leankor__ValueStreamLink__c==null?'':kanbanCard.leankor__ValueStreamLink__c);
            kanbanCardWrapper.ValueStreamCardLinkName = (kanbanCard.leankor__ValueStreamCardLink__c==null?'':kanbanCard.leankor__ValueStreamCardLink__r.Name); 
            kanbanCardWrapper.ValueStreamLinkIDName = (kanbanCard.leankor__ValueStreamLink__c==null?'':kanbanCard.leankor__ValueStreamLink__r.Name);
            kanbanCardWrapper.ValueStreamLinkBoardType=(kanbanCard.leankor__ValueStreamLink__c==null?'':kanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c);
            kanbanCardWrapper.ValueStreamID=kanbanCard.leankor__ValueStream__c;
            kanbanCardWrapper.OwnerID=kanbanCard.OwnerID;
            kanbanCardWrapper.KanbanUrl='';
            kanbanCardWrapper.BoardType =kanbanCard.leankor__ValueStream__r.leankor__Boardtype__c;
            kanbanCardWrapper.Order = kanbanCard.leankor__Order__c;
            kanbanCardWrapper.OnBudget = kanbanCard.leankor__OnBudget__c;
            kanbanCardWrapper.OnQuality = kanbanCard.leankor__OnQuality__c;
            kanbanCardWrapper.OnTime = kanbanCard.leankor__OnTime__c;
            // Date: 27/05/2019
			kanbanCardWrapper.isAtRisk = kanbanCard.leankor__IsAtRisk__c;
			kanbanCardWrapper.isOnHold = kanbanCard.leankor__IsOnHold__c;
            kanbanCardWrapper.OwnerName = kanbanCard.Owner.Name;
            kanbanCardWrapper.ItemType= recordtype.get(kanbanCard.RecordTypeId).Name;                                 
            kanbanCardWrapper.IsRecalculate = kanbanCard.leankor__Valuestream__r.leankor__Isrecalculate__c;
            kanbanCardWrapper.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c;
            //With CustomField lazy load we dont need to provide these values on Load
            //kanbanCardWrapper.JSONDefinition = kanbanCard.leankor__JSONDefinition__c;
            // kanbanCardWrapper.JSONData = kanbanCard.leankor__JSONData__c;   
            kanbanCardWrapper.Color = (kanbanCard.leankor__kanbanCardTemplate__r.leankor__Color__c==null?'':kanbanCard.leankor__kanbanCardTemplate__r.leankor__Color__c);   
            kanbanCardWrapper.ProjectRoomID= kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__c;   
             // adding leankor__IsSuccessorRecalculate__c field for Recalculation of linked activity               
            kanbanCardWrapper.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;                   
            if(kanbanCard.leankor__ScheduleModes__r.size()>0) {
                kanbanCardWrapper.ManuallyScheduled = kanbanCard.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;//kanbanCard.leankor__ValueStream__r.leankor__ManuallyScheduled__c;
                kanbanCardWrapper.SchedulingMode= kanbanCard.leankor__ScheduleModes__r[0].leankor__Mode__c;//kanbanCard.leankor__ValueStream__r.leankor__Mode__c;
                kanbanCardWrapper.EffortUnit = kanbanCard.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                kanbanCardWrapper.Effort = kanbanCard.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                kanbanCardWrapper.SchedulingModeId = kanbanCard.leankor__ScheduleModes__r[0].Id;
                //Changes added for Readonly field should be show in Sub-activity.
				//kanbanCardWrapper.ReadOnly = kanbanCard.leankor__ScheduleModes__r[0].leankor__ReadOnly__c;

                //Changes : Check constraint setting enable or not.
                if( realTimeController.ALLOW_SCHEDULING_CONSTRAINTS ){
                    kanbanCardWrapper.ConstraintDate = kanbanCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                    kanbanCardWrapper.ConstraintType = kanbanCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                }
            }
            if(kanbanCard.leankor__Kanban_Card_Baselines__r != null && kanbanCard.leankor__Kanban_Card_Baselines__r.size()>0){
                kanbanCardWrapper.BaselineStartDate = kanbanCard.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                kanbanCardWrapper.BaselineEndDate = kanbanCard.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c;                       
            } 
            kanbanCardWrapper.isDependencyAckRecalculate = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c;
            kanbanCardWrapper.workOrderCount = fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).workOrderCount : 0;
            kanbanCardWrapper.serviceAppointmentCount = fslDataInfo.containsKey(kanbanCard.Id) ? ( fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount!=null ? fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount   : null ) : 0;
            kanbanCardWrapper.fslSchedStartDateTime = fslDataInfo.containsKey(kanbanCard.Id) ? ( fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime!=null ? fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime : null  ) : null;
            kanbanCardWrapper.fslSchedDueDateTime =  fslDataInfo.containsKey(kanbanCard.Id) ? ( fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime!=null ? fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime: null ): null;         
            
            kanbanCardWrapper.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
            kanbanCardWrapper.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c; 
             //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
             if(kanbanCard.leankor__Monday__c == false && kanbanCard.leankor__Tuesday__c == false && kanbanCard.leankor__Wednesday__c == false &&  kanbanCard.leankor__Thursday__c == false &&  kanbanCard.leankor__Friday__c == false &&  kanbanCard.leankor__Saturday__c == false &&  kanbanCard.leankor__Sunday__c == false){
                kanbanCardWrapper.Monday = true;
                kanbanCardWrapper.Tuesday = true;
                kanbanCardWrapper.Wednesday = true;
                kanbanCardWrapper.Thursday = true;
                kanbanCardWrapper.Friday = true;
                kanbanCardWrapper.Saturday = true;
                kanbanCardWrapper.Sunday = true;
            }else{            
                //Pratiksha : 10/Oct/2023 : Passing these week day onLoad on PDG.
                kanbanCardWrapper.Monday = kanbanCard.leankor__Monday__c;
                kanbanCardWrapper.Tuesday  = kanbanCard.leankor__Tuesday__c;
                kanbanCardWrapper.Wednesday = kanbanCard.leankor__Wednesday__c;
                kanbanCardWrapper.Thursday = kanbanCard.leankor__Thursday__c;
                kanbanCardWrapper.Friday = kanbanCard.leankor__Friday__c;
                kanbanCardWrapper.Saturday = kanbanCard.leankor__Saturday__c;
                kanbanCardWrapper.Sunday = kanbanCard.leankor__Sunday__c;
                kanbanCardWrapper.weekCalendar = kanbanCard.leankor__WeekCalendar__c;
            }
            kanbanCardWrapper.children = (recordtype.get(kanbanCard.RecordTypeId).Name == 'FolderCard' ? childcardsRecursive(kanbanCard.Id, mapOfListCards, recordtype, fslDataInfo) : new List<leankor.KanbanToGanttController.MasterContainer>());                   

            kanbanCardWrappers.add(kanbanCardWrapper);
        }

        return kanbanCardWrappers;
    }

    global Class GetPortfolioresource{
        global Set<leankor.GanttTaskBoard.PortfolioHierarchy> Hierarchyrecords;
        global List<leankor.GanttTaskBoard.UserData> UserRecords;
        global leankor.GanttTaskBoard.OnloadData DataLog;
    }
    global class OnloadData {
        global string Foldername;
        global String FolderID;
        global Integer FolderLevel;
        global List<leankor.ResourceGanttController.ResourceCalendar> defaultResourceHours;
        //RS 06/05/2019 Added for security role
        public boolean hasReadAccess;
        public boolean hasEditAccess;
        public boolean hasDeleteAccess; 
    }
    global class PortfolioHierarchy {
        Global String Id;
        Global String CardID;
        Global String UrlLink;
        Global String ForceID;
        Global String Name;
        Global String Color;
        Global String CmpID;
        Global String GUID;
        Global Decimal Height;
        Global Boolean isCardAvailable;
        Global Decimal Left;
        Global Decimal Limits;
        Global Decimal Order;
        Global String Title;
        Global Decimal Top;
        Global String Type;
        Global String ValueStreamID;
        Global String ValueStream;
        Global Decimal Width;
        Global Decimal CardPerRow;  
        Global String Help;
        Global Integer Bottom;
        Global Integer X;
        Global Integer Y;
        Global String EntryFlowName;
        Global String ExitFlowName;
        Global String VSLink; // drill down to another detail level of the value stream
        Global String ZoneMode;
        Global String KanbanSequence;
        Global String ValueStreamLinkID;
        Global String ValueStreamCardLink;
        Global String ValueStreamLinkBoardType;
        Global Integer DefaultHeight;
        Global Integer DefaultWidth;
        Global String ZoneStatus;
        Global Decimal TaskLimit;
        Global String ParentZone;
        Global String Swimlane;
        Global Decimal CardsPerRow;
        Global String CaseStatus;
        Global String CompletionRateUnits;
        Global Integer CompletionRate;
        Global String CSSLayout;
        Global String JSONData;
        Global String JSONDefinition;
        Global Integer KanbanCardCount;
        Global Integer KanbanCardThroughput;
        Global Integer LeadTime;
        Global String ZoneTemplate;
        Global String OwnerID;
        Global String State;
        Global String ZoneID;
        Global String ZoneGUID;
        Global String MCForceID;
        Global String SWForceID;
        Global String ZoneForceID;
        Global String Base64Drawing;
        Global String Base64FileType;
        Global String TemplateID; // kanban card template Force.com id
        Global String TemplateName;
        Global Decimal Point;
        Global Decimal EffortRemaining;
        Global Decimal EstimatedDuration; // new field to track if project/product on schedule;
        Global String DurationUnits; //EjB11: added durationUnits picklist string
        Global Integer Priority; //EjB14: added priority
        Global String HarveyBall;
        Global String DateColor;
        Global String Description;
        Global String KanbanUrl;
        Global String Account;
        Global String Contact;
        Global String CaseID;
        Global String AccountName;
        Global String ContactName;
        Global String CaseSubject;
        Global String CasePriority;
        Global boolean CaseTrigger;
        Global boolean SevenDayWorkWeek;
        Global String ZoneTitle;
        Global String LeavedZoneTitle;
        Global Decimal PercentDone;
        Global String LastModifiedDate;
        Global String CreateDate;
        Global String Extensions;
        Global String LeavedZoneID;
        Global Boolean leaf;
        Global Boolean expanded;
        Global String ResourceId;
        Global Set<leankor.GanttTaskBoard.PortfolioHierarchy> children;
        Global String StartDate;
        Global String DueDate;
        Global String ItemType;
        Global String Opportunity;
        Global String OpportunityName;
        Global String SmallPhotoUrl;
        Global String BoardType;
        Global String OnBudget;
        Global String OnQuality;
        Global String OnTime;
        Global String OwnerName;
        Global String Subject;
        Global String Status;
        Global String WhatId;
        Global String KanbanCardName;
        Global String ValueStreamName;
        Global String ProjectRoomName;
        Global String ProjectRoomID;
        Global String ValueStreamCardLinkName;
        Global String ValueStreamLinkIDName;
        Global String CreatedDate;  
        Global String AgilePointSequnece;
        Global Boolean VSTaskDueDateCheck;
        Global String AcceptanceCriteria;
        Global String ParentPortfolio;
        Global DateTime MinDate;
        Global DateTime MaxDate;
        Global Integer BudgetedTime = 0;
        Global Integer BudgetTimeComplete = 0 ;
        Global Integer BudgetTimeRemaining = 0 ;
        Global Decimal AllBudgetedTime=0.0 ;
        Global Decimal AllBudgetTimeComplete=0.0;
        Global Decimal AllBudgetTimeRemaining=0.0;
        Global string PlanBoardID ;
        Global String BoardMaxDueDate;       
        //RS 06/05/2019 Added for security role
        public boolean hasReadAccess;
        public boolean hasEditAccess;
        public boolean hasDeleteAccess;       
        //Date :17/07/19 
        public String projectLaunchDate;    
    }
   public static map<string,leankor.GanttTaskBoard.PortfolioHierarchy> PlanroomMapData = new map<String,leankor.GanttTaskBoard.PortfolioHierarchy>();    
    
    /***
     * Company : Leankor
     * Description : This Method will return Portfolio Hierarchy Expanded form.
     * Input :  String Parent Folder Id.
     * Output : GanttTaskBoard.GetPortfolioresource.
    */
    @RemoteAction
    global static leankor.GanttTaskBoard.GetPortfolioresource getPortfolioHierarchyExpanded(String parentID) {
        if (String.isNotBlank(parentID) && Util.getSObjectName(parentID) != 'leankor__Portfolio__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !valueStreamBehavior.isAccessible() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            return new leankor.GanttTaskBoard.GetPortfolioresource();
        }
        //Check CRUD / FLC behavior 

        List<string> userId = new List<string>(); 
        
        Map<string,leankor__ProjectLaunchBehavior__c> isUberBoardVS = new Map<string,leankor__ProjectLaunchBehavior__c>();
        Map <Id,AggregateResult> cardDueDatesMap = new Map<Id,AggregateResult >();
        
        Map <Id,AggregateResult> activityDueDatesMap = new Map < Id,AggregateResult >();
        
        Map <String,leankor__Valuestream__c> vsProjectRoomMap = new Map<String,leankor__Valuestream__c>(); 
        
        list<leankor__Portfolio__c> portfolioLogs= [Select Id,
                                                        Name,
                                                        leankor__ParentPortfolio__c,
                                                        leankor__PortfolioNumber__c,
                                                        UserRecordAccess.HasReadAccess,
                                                        UserRecordAccess.HasEditAccess,
                                                        UserRecordAccess.HasDeleteAccess,
                                                        (Select Id
                                                                From leankor__ChildPortfolios__r),
                                                        (Select Id
                                                                From leankor__ProjectRooms__r) 
                                                    From leankor__Portfolio__c 
                                                    //Where leankor__ParentPortfolio__c =: ParentID 
                                                    Order By Name ASC Limit 50000]; // WHERE leankor__ParentPortfolio__c =:ParentID (Nov-30-2016) 
        
        list<leankor__ProjectRoom__c> roomLogs =   [Select  Id,
                                                         Name,
                                                         leankor__ProjectManager__r.Name,
                                                         leankor__Portfolio__c,
                                                         leankor__DueDate__c,
                                                         UserRecordAccess.HasReadAccess,
                                                         UserRecordAccess.HasEditAccess,
                                                         UserRecordAccess.HasDeleteAccess,
                                                         leankor__ProjectLaunchDateTime__c
                                                    From leankor__ProjectRoom__c 
                                                    Where leankor__IsTemplateProject__c = false 
                                                            //And leankor__Portfolio__c =: ParentID 
                                                        And leankor__Portfolio__c In: portfolioLogs
                                                        Order By Name ASC limit 50000]; 
                    
        for(leankor__ProjectLaunchBehavior__c projLaunchBehavLog : [Select leankor__Project__c,leankor__Module__c,leankor__Module__r.Name From leankor__ProjectLaunchBehavior__c Where leankor__Module__r.Name = 'Plan (Gantt)' And leankor__Project__c IN :roomLogs Limit 49999])
        {
            isUberBoardVS.put(projLaunchBehavLog.leankor__Project__c,projLaunchBehavLog);       
        }                    
        //get all project boards 
        //27/Jan/2023 : We added Limit in this query to resovle the issue :Too many query rows.
        List<leankor__Valuestream__C> listOfBoards =   [Select Id,
                                                            leankor__BoardType__c,
        												    leankor__ProjectRoom__c,
        												    Name,
        												    OwnerId
                                                       From leankor__ValueStream__c 
                                                       Where (leankor__BoardType__c = 'UberBoard' 
                                                    	Or leankor__BoardType__c = 'Plan Board') 
                                                    	And leankor__IsTemplateBoard__c = false 
                                                    	And leankor__ProjectRoom__c IN :roomLogs
                                                    	And leankor__IsRecordDeleted__c = false
                                                       Limit 50000];       
        for(leankor__Valuestream__c valueStreamRecord :listOfBoards){       
            if (isUberBoardVS.containsKey(valueStreamRecord.leankor__ProjectRoom__c) && valueStreamRecord.leankor__BoardType__c == 'UberBoard'){
                vsProjectRoomMap.put(valueStreamRecord.leankor__ProjectRoom__c,valueStreamRecord);
                userId.add(valueStreamRecord.OwnerId);
            }else if (!isUberBoardVS.containsKey(valueStreamRecord.leankor__ProjectRoom__c) && valueStreamRecord.leankor__BoardType__c == 'Plan Board') {
                vsProjectRoomMap.put(valueStreamRecord.leankor__ProjectRoom__c,valueStreamRecord);
                userId.add(valueStreamRecord.OwnerId);
            }               
        }
        
        AggregateResult[] cardDueDates = [Select leankor__Valuestream__r.leankor__ProjectRoom__c, 
        										 leankor__Valuestream__r.leankor__BoardType__c,
        										Min(leankor__StartDateTime__c), 
        										Max(leankor__DueDateTime__c)
        									From leankor__KanbanCard__c
        									Where leankor__Valuestream__c IN: listOfBoards 
                                            And leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                            And leankor__IsRecordDeleted__c = false
                                            And leankor__ValueStream__r.IsRecordDeleted__c = false 
                                            And leankor__MasterContainer__r.leankor__Type__c != 'Template'
                                            Group By leankor__Valuestream__r.leankor__ProjectRoom__c, leankor__Valuestream__r.leankor__BoardType__c limit 49999];
        
        
        //Add aggregate results to a Map
        for (AggregateResult aggregateRecord: cardDueDates){
            String pRoom = (String)aggregateRecord.get('leankor__ProjectRoom__c');
            if (isUberBoardVS.containsKey(pRoom) && (String)aggregateRecord.get('leankor__BoardType__c') == 'UberBoard') {
                cardDueDatesMap.put((String)aggregateRecord.get('leankor__ProjectRoom__c'), aggregateRecord);
            } else if (!isUberBoardVS.containsKey(pRoom) && (String)aggregateRecord.get('leankor__BoardType__c') == 'Plan Board') {
                cardDueDatesMap.put((String)aggregateRecord.get('leankor__ProjectRoom__c'), aggregateRecord);
            }
        }
        
        //If Plan Gantt and Roll up both available, use only Plan Gantt for the % calculation.
        AggregateResult[] activityDueDates = [Select leankor__Valuestream__r.leankor__ProjectRoom__c, 
        											leankor__Valuestream__r.leankor__BoardType__c ,
        											Sum(leankor__BudgetTimeComplete__c), 
        											Sum(leankor__BudgetTimeRemaining__c), 
        											Sum(leankor__Budgeted_Time__c)
									            From leankor__KanbanCard__c
									            Where leankor__Valuestream__c IN: listOfBoards 
                                                And leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                                And leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                                                And RecordType.name = 'ActivityCard' 
                                                And leankor__IsRecordDeleted__c = false 
                                                And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false                
									            Group BY leankor__Valuestream__r.leankor__ProjectRoom__c, leankor__Valuestream__r.leankor__BoardType__c 
									            Limit 49999];
        //Add aggregate results to a Map
        for (AggregateResult aggregateRecord: activityDueDates){
            String pRoom = (String)aggregateRecord.get('leankor__ProjectRoom__c');
            if (isUberBoardVS.containsKey(pRoom) && (String)aggregateRecord.get('leankor__BoardType__c') == 'UberBoard') {
                activityDueDatesMap.put((String)aggregateRecord.get('leankor__ProjectRoom__c'), aggregateRecord);
            }else if (!isUberBoardVS.containsKey(pRoom) && (String)aggregateRecord.get('leankor__BoardType__c') == 'Plan Board') {
                activityDueDatesMap.put((String)aggregateRecord.get('leankor__ProjectRoom__c'), aggregateRecord);
            }

        }                       
        leankor.GanttTaskBoard.GetPortfolioresource resultList = new leankor.GanttTaskBoard.GetPortfolioresource ();              
        resultList.Hierarchyrecords = leankor.GanttTaskBoard.ganttChildPortfolioHierarchy(parentID, portfolioLogs, roomLogs,cardDueDatesMap,activityDueDatesMap,vsProjectRoomMap);     
        resultList.UserRecords = leankor.GanttTaskBoard.getUserdata(userId);       
        leankor__Portfolio__c currentfolderData =[Select Id,Name,leankor__ParentPortfolio__c,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess From leankor__Portfolio__c Where Id = :ParentID]; 
        leankor.GanttTaskBoard.OnloadData loadData = new leankor.GanttTaskBoard.OnloadData();      
        loadData.Foldername = currentfolderData.Name;
        loadData.FolderID = ParentID;
        loadData.FolderLevel = (currentfolderData.leankor__ParentPortfolio__c == null ? 1: 2);      
        loadData.hasReadAccess = currentfolderData.UserRecordAccess.HasReadAccess;
		loadData.hasEditAccess = currentfolderData.UserRecordAccess.HasEditAccess;
		loadData.hasDeleteAccess = currentfolderData.UserRecordAccess.HasDeleteAccess;      
        resultList.DataLog= loadData ;              
        return resultList;
    }

    //RS 06/05/2019 Modified for security role
    @RemoteAction
    global static leankor.GanttTaskBoard.GetPortfolioresource getPortfolioHierarchy(String ParentID) {
        if (String.isNotBlank(parentID) && Util.getSObjectName(parentID) != 'leankor__Portfolio__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !valueStreamBehavior.isAccessible() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<string> userId = new List<string>(); 
        
        Map<string,leankor__ProjectLaunchBehavior__c> isUberBoardVS = new Map<string,leankor__ProjectLaunchBehavior__c>();
        Map <Id,AggregateResult> cardDueDatesMap = new Map<Id,AggregateResult > ();
        
        Map <Id,AggregateResult> activityDueDatesMap = new Map < Id,AggregateResult > ();
        
        Map <String,leankor__Valuestream__c> vsProjectRoomMap = new Map<String,leankor__Valuestream__c> (); 
        
        list<leankor__Portfolio__c> portfolioLogs= [select Id,Name,leankor__ParentPortfolio__c,leankor__PortfolioNumber__c,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess from leankor__Portfolio__c where leankor__ParentPortfolio__c =: ParentID ORDER BY Name ASC limit 49999]; // WHERE leankor__ParentPortfolio__c =:ParentID (Nov-30-2016) 
        
        list<leankor__ProjectRoom__c> roomLogs = [select Id,Name,leankor__ProjectManager__r.Name,leankor__Portfolio__c,leankor__DueDate__c,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,leankor__ProjectLaunchDateTime__c from leankor__ProjectRoom__c WHERE leankor__IsTemplateProject__c = false AND leankor__Portfolio__c =: ParentID ORDER BY Name ASC limit 49999]; 
                    
        for(leankor__ProjectLaunchBehavior__c projLaunchBehavLog : [SELECT leankor__Project__c,leankor__Module__c,leankor__Module__r.Name FROM leankor__ProjectLaunchBehavior__c where leankor__Module__r.Name = 'Plan (Gantt)' AND leankor__Project__c IN :roomLogs limit 49999])
        {
            isUberBoardVS.put(projLaunchBehavLog.leankor__Project__c,projLaunchBehavLog);       
        }                    
        //get all project boards
        List<leankor__Valuestream__C> listOfBoards =[SELECT Id,leankor__BoardType__c,
        												 leankor__ProjectRoom__c,
        												 Name,
        												 OwnerId
                                                    FROM leankor__ValueStream__c 
                                                    WHERE (leankor__BoardType__c = 'UberBoard' 
                                                    	OR leankor__BoardType__c = 'Plan Board') 
                                                    	AND leankor__IsTemplateBoard__c = false 
                                                    	AND leankor__ProjectRoom__c IN :roomLogs
                                                    	AND leankor__IsRecordDeleted__c = false];       
        for(leankor__Valuestream__c v :listOfBoards){       
            if (isUberBoardVS.containsKey(v.leankor__ProjectRoom__c) && v.leankor__BoardType__c == 'UberBoard'){
                vsProjectRoomMap.put(v.leankor__ProjectRoom__c,v);
                userId.add(v.OwnerId);
            }else if (!isUberBoardVS.containsKey(v.leankor__ProjectRoom__c) && v.leankor__BoardType__c == 'Plan Board') {
                vsProjectRoomMap.put(v.leankor__ProjectRoom__c,v);
                userId.add(v.OwnerId);
            }               
        }
        
        AggregateResult[] cardDueDates = [SELECT leankor__Valuestream__r.leankor__ProjectRoom__c, 
        										leankor__Valuestream__r.leankor__BoardType__c,
        										MIN(leankor__StartDateTime__c), 
        										MAX(leankor__DueDateTime__c)
        									FROM leankor__KanbanCard__c
        									WHERE leankor__Valuestream__c IN: listOfBoards AND
            									leankor__Valuestream__r.leankor__IsTemplateBoard__c = false AND
            									leankor__IsRecordDeleted__c = false AND
            									leankor__ValueStream__r.IsRecordDeleted__c = false AND
                leankor__MasterContainer__r.leankor__Type__c != 'Template'
                GROUP BY leankor__Valuestream__r.leankor__ProjectRoom__c, leankor__Valuestream__r.leankor__BoardType__c limit 49999];
        
        
        //Add aggregate results to a Map
        for (AggregateResult r: cardDueDates){
            String pRoom = (String)r.get('leankor__ProjectRoom__c');
            if (isUberBoardVS.containsKey(pRoom) && (String)r.get('leankor__BoardType__c') == 'UberBoard') {
                cardDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            } else if (!isUberBoardVS.containsKey(pRoom) && (String)r.get('leankor__BoardType__c') == 'Plan Board') {
                cardDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            }
        }
        
        //If Plan Gantt and Roll up both available, use only Plan Gantt for the % calculation.
        AggregateResult[] activityDueDates = [SELECT leankor__Valuestream__r.leankor__ProjectRoom__c, 
        											leankor__Valuestream__r.leankor__BoardType__c ,
        											SUM(leankor__BudgetTimeComplete__c), 
        											SUM(leankor__BudgetTimeRemaining__c), 
        											SUM(leankor__Budgeted_Time__c)
									            FROM leankor__KanbanCard__c
									            WHERE leankor__Valuestream__c IN: listOfBoards AND
									            	leankor__Valuestream__r.leankor__IsTemplateBoard__c = false AND
									                leankor__MasterContainer__r.leankor__Type__c != 'Template' AND
									                RecordType.name = 'ActivityCard' AND
									                leankor__IsRecordDeleted__c = false AND
									                leankor__ValueStream__r.leankor__IsRecordDeleted__c = false                
									            GROUP BY leankor__Valuestream__r.leankor__ProjectRoom__c, leankor__Valuestream__r.leankor__BoardType__c 
									            limit 49999];
        //Add aggregate results to a Map
        for (AggregateResult r: activityDueDates){
            String pRoom = (String)r.get('leankor__ProjectRoom__c');
            if (isUberBoardVS.containsKey(pRoom) && (String)r.get('leankor__BoardType__c') == 'UberBoard') {
                activityDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            }else if (!isUberBoardVS.containsKey(pRoom) && (String)r.get('leankor__BoardType__c') == 'Plan Board') {
                activityDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            }

        }                       
        leankor.GanttTaskBoard.GetPortfolioresource resultList = new leankor.GanttTaskBoard.GetPortfolioresource ();              
        
        resultList.Hierarchyrecords = leankor.GanttTaskBoard.ganttChildPortfolioHierarchy(ParentID, portfolioLogs, roomLogs,cardDueDatesMap,activityDueDatesMap,vsProjectRoomMap);     
        resultList.UserRecords = leankor.GanttTaskBoard.getUserdata(userId);       
        leankor__Portfolio__c currentfolderData =[select ID,Name,leankor__ParentPortfolio__c,UserRecordAccess.HasReadAccess,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess from leankor__Portfolio__c where ID = :ParentID]; 
        leankor.GanttTaskBoard.OnloadData loadData = new leankor.GanttTaskBoard.OnloadData();      
        loadData.Foldername = currentfolderData.Name;
        loadData.FolderID = ParentID;
        loadData.FolderLevel = (currentfolderData.leankor__ParentPortfolio__c == null ? 1: 2);      
        loadData.hasReadAccess = currentfolderData.UserRecordAccess.HasReadAccess;
		loadData.hasEditAccess = currentfolderData.UserRecordAccess.HasEditAccess;
		loadData.hasDeleteAccess = currentfolderData.UserRecordAccess.HasDeleteAccess;      
        resultList.DataLog= loadData ;              
        return resultList;
    }    
    
    //RS 06/05/2019 Modified for security role
    public static Set<leankor.GanttTaskBoard.PortfolioHierarchy> ganttChildPortfolioHierarchy(String parentId,
                                                                                    list<leankor__Portfolio__c> ListOfPortfolio,
                                                                                    list<leankor__ProjectRoom__c> RoomRecords,
                                                                                    Map < Id, AggregateResult > cardDueDatesMap, Map < Id, AggregateResult > activityDueDatesMap,
                                                                                    Map <String,leankor__Valuestream__c> vsProjectRoomMap)
    {        
        Set<leankor.GanttTaskBoard.PortfolioHierarchy> SetofchildPortfolio  = new Set<leankor.GanttTaskBoard.PortfolioHierarchy>();
        
        for(leankor__ProjectRoom__c roomlog :RoomRecords){
            if(roomlog.leankor__Portfolio__c == parentId){
                leankor.GanttTaskBoard.PortfolioHierarchy obj_roomchild = new leankor.GanttTaskBoard.PortfolioHierarchy();
                obj_roomchild.Id = roomlog.Id;
                obj_roomchild.Name = roomlog.Name;
                obj_roomchild.ItemType= 'Activity';
                obj_roomchild.ParentPortfolio = roomlog.leankor__Portfolio__c;
                obj_roomchild.leaf = true;              
                obj_roomchild.OwnerID = roomlog.leankor__ProjectManager__c;
                obj_roomchild.OwnerName = (roomlog.leankor__ProjectManager__r.name != null ? roomlog.leankor__ProjectManager__r.name : '');
                obj_roomchild.PercentDone = 0;
                obj_roomchild.BoardMaxDueDate = String.Valueof(roomlog.leankor__DueDate__c);   
                obj_roomchild.hasReadAccess = roomlog.UserRecordAccess.HasReadAccess;
				obj_roomchild.hasEditAccess = roomlog.UserRecordAccess.HasEditAccess;
				obj_roomchild.hasDeleteAccess = roomlog.UserRecordAccess.HasDeleteAccess;  
				//Date :18/08/22 : Launch date should be show mid of day.
				obj_roomchild.projectLaunchDate =  roomlog.leankor__ProjectLaunchDateTime__c!=null?JSON.serialize(roomlog.leankor__ProjectLaunchDateTime__c):'';
                leankor__Valuestream__c vs = vsProjectRoomMap.get(roomlog.Id);

                if(vs != null)
                {
                    obj_roomchild.PlanBoardID = vs.Id;
                }                           

                //Add MIN/MAX dates to the project hierarchy record
                AggregateResult res = cardDueDatesMap.get(roomlog.Id);                              
                if (res != null){
                    obj_roomchild.StartDate = JSON.Serialize(res.get('expr0'));
                    obj_roomchild.DueDate = JSON.Serialize((DateTime)res.get('expr1'));
                }
                //Add budget dates dates to the project hierarchy record
                res = activityDueDatesMap.get(roomlog.Id);
                
                if (res != null) {
                    obj_roomchild.AllBudgetedTime = (Decimal)res.get('expr2');
                    obj_roomchild.AllBudgetTimeComplete = (Decimal)res.get('expr0');
                    obj_roomchild.AllBudgetTimeRemaining = (Decimal)res.get('expr1');

                    if (obj_roomchild.AllBudgetedTime != 0) {
                        obj_roomchild.PercentDone = (obj_roomchild.AllBudgetedTime - obj_roomchild.AllBudgetTimeRemaining) * 100 / obj_roomchild.AllBudgetedTime;
                    }
                }
                SetofchildPortfolio.add(obj_roomchild);                     
            }
        }
        for(leankor__Portfolio__c childOfPF : ListOfPortfolio){

            if(childOfPF.leankor__ParentPortfolio__c ==parentId){
                leankor.GanttTaskBoard.PortfolioHierarchy obj_childPF = new leankor.GanttTaskBoard.PortfolioHierarchy();
                obj_childPF.Name = childOfPF.Name;
                obj_childPF.ID = childOfPF.ID;
                obj_childPF.ItemType= 'Folder';
                obj_childPF.leaf= False;
                obj_childPF.expanded = False;
                obj_childPF.ParentPortfolio = childOfPF.leankor__ParentPortfolio__c;
                obj_childPF.children = childOfPF.leankor__ChildPortfolios__r.size() > 0 || childOfPF.leankor__ProjectRooms__r.size() > 0 ? leankor.GanttTaskBoard.ganttChildPortfolioHierarchy(childOfPF.ID,ListOfPortfolio,RoomRecords,cardDueDatesMap,activityDueDatesMap,vsProjectRoomMap) : new Set<leankor.GanttTaskBoard.PortfolioHierarchy>();
                obj_childPF.hasReadAccess = childOfPF.UserRecordAccess.HasReadAccess;
				obj_childPF.hasEditAccess = childOfPF.UserRecordAccess.HasEditAccess;
				obj_childPF.hasDeleteAccess = childOfPF.UserRecordAccess.HasDeleteAccess;
                SetofchildPortfolio.add(obj_childPF);  
                
                /*obj_childPF.children = leankor.GanttTaskBoard.ganttChildPortfolioHierarchy(childOfPF.ID,ListOfPortfolio,RoomRecords,cardDueDatesMap,activityDueDatesMap,vsProjectRoomMap);                              
                DateTime childMinDateTime,childMaxDateTime;                
                    for(leankor.GanttTaskBoard.PortfolioHierarchy childs : obj_childPF.children){ 
                        if(childs.StartDate != '' && childs.DueDate != '' && childs.StartDate != null && childs.DueDate !=null){
                            if(childMinDateTime == null && childMaxDateTime== null){
                                childMinDateTime = (DateTime)JSON.deserialize(childs.StartDate,Datetime.class);
                                childMaxDateTime = (DateTime)JSON.deserialize(childs.DueDate,Datetime.class);
                            }
                            else {                          
                                if(childMinDateTime > (DateTime)JSON.deserialize(childs.StartDate,Datetime.class)){
                                    childMinDateTime = DateTime.valueof(JSON.deserialize(childs.StartDate,Datetime.class));                                         
                                }
                                if(childMaxDateTime < (DateTime)JSON.deserialize(childs.DueDate,Datetime.class)){
                                    childMaxDateTime = DateTime.valueof(JSON.deserialize(childs.DueDate,Datetime.class));  
                                }
                            }
                        }                   
                    }                   
                    if(childMinDateTime != null && childMaxDateTime != null){                   
                        obj_childPF.StartDate=JSON.Serialize(childMinDateTime);
                        obj_childPF.DueDate=JSON.Serialize(childMaxDateTime);                
                    }else{
                        obj_childPF.StartDate='';
                        obj_childPF.DueDate='';
                    }                 
                 */                               
            }
        }       
        return SetofchildPortfolio;
    }


    //  
    global static Set<leankor.GanttTaskBoard.PortfolioHierarchy> childPortfolioHierarchy(String parentId,list<leankor__Portfolio__c> ListOfPortfolio,list<leankor__ProjectRoom__c> RoomRecords){        
       return new Set<leankor.GanttTaskBoard.PortfolioHierarchy>(); 
    }

    
    // 
    global class UserData{
        global String Id;
        global String SmallPhotoUrl;
        global String Name;
    }  


    global static List<UserData> getUserdata(List<String> UserIDs){
        //Check CRUD / FLC behavior 
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<UserData> resultUsers = new List<UserData>();   
        List<User> userList = [Select Id, 
                                        SmallPhotoUrl, 
                                        Name 
                                    From User 
                                    Where Id In :UserIDs 
                                        Or Id = :Userinfo.getUserId() 
                                    Limit 1];

        for (User userLog : userList) {
            UserData userData = new UserData();
            userData.Id = userLog.Id;
            userData.SmallPhotoUrl = userLog.SmallPhotoUrl;
            userData.Name = userLog.Name;
            resultUsers.Add(userData);
        }   
        return resultUsers;
    }


    //SS 04.01.2019
    //To Do : Modified UpdateCardData
    @RemoteAction
    global static List <leankor__Kanbancard__c> updateCardData(List < String > getId, List < String > UpdateJSON, Boolean isStream) {
        for(String cardId : getId){
            if (String.isNotBlank(cardId) && Util.getSObjectName(cardId) != 'leankor__Kanbancard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        Map<Id,leankor__Kanbancard__c> kanbanCardMap = new Map<Id,leankor__Kanbancard__c>([SELECT Id,leankor__Valuestream__c,
       																						leankor__HarveyBallDoneDate__c,
       																						leankor__PromiseCompletionDate__c,
       																						leankor__IsSuccessorRecalculate__c,
       																						leankor__DueDate__c,
                                                                                    		leankor__CardID__c,
                                                                                    		leankor__DueDateTime__c, 
                                                                                    		leankor__DurationUnits__c, 
                                                                                    		leankor__EstimatedDuration__c, 
                                                                                    		leankor__Order__c, 
                                                                                    		leankor__PercentComplete2__c,
                                                                                    		leankor__StartDateTime__c, 
                                                                                    		leankor__StartDate__c 
                                                                                    	FROM leankor__Kanbancard__c 
                                                                                        WHERE Id IN: getId 
                                                                                            AND leankor__IsRecordDeleted__c = false 
                                                                                            AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                                                    	LIMIT 9999]);
        List<leankor__KanbanCard__c> updateList = new List<leankor__KanbanCard__c>();
        for(String JSONobject : UpdateJSON)
        {
            leankor.realTimeController.Kanban request = (leankor.realtimeController.Kanban) JSON.deserialize(JSONobject,(leankor.realtimeController.Kanban.Class));
            if(kanbanCardMap.containsKey(request.Id)){
                leankor__KanbanCard__c kcRecord = kanbanCardMap.get(request.Id);
                if(request.CardID !='' && request.CardID != null){
                kcRecord.leankor__CardID__c = request.CardID;
                }
            
                if(request.DueDate != null){                   
                kcRecord.leankor__DueDateTime__c = request.DueDate;
                kcRecord.leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(request.DueDate),DateTime.class));                       
                }

                /*if(request.DueDate!= Null){                      
                    kcRecord.leankor__DueDate__c =     ;                  
                }*/

                if(request.EstimatedDuration != null){                   
                kcRecord.leankor__EstimatedDuration__C = request.EstimatedDuration;                 
                }

                if(String.isNotBlank(request.DurationUnits)){
                kcRecord.leankor__DurationUnits__c = request.DurationUnits;
                }

                if(request.Order != null){
                kcRecord.leankor__Order__C = request.Order;
                }

                if(request.StartDate != null){                       
                     kcRecord.leankor__StartDateTime__C = request.StartDate;
                     kcRecord.leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(request.StartDate),DateTime.class));
                }                 

                /*if(request.StartDate!= Null){                    
                    kcRecord.leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(request.StartDate),DateTime.class));                      
                }*/

                if(request.PercentDone != null){   
                    kcRecord.leankor__HarveyBallDoneDate__c = (kcRecord.leankor__PercentComplete2__c != request.PercentDone.intValue() && request.PercentDone.intValue() == 100) ? System.today() :  kcRecord.leankor__HarveyBallDoneDate__c;           
                    kcRecord.leankor__PromiseCompletionDate__c = (kcRecord.leankor__PercentComplete2__c != request.PercentDone.intValue() && request.PercentDone.intValue() == 100) ? System.now() :  kcRecord.leankor__PromiseCompletionDate__c;                                            
                    
                    kcRecord.leankor__PercentComplete2__c = request.PercentDone.intValue();                                                          
                }

                if(request.IsExternallyDependent != null){
                    kcRecord.leankor__IsExternallyDependent__c = request.IsExternallyDependent;
                }

                if(request.IsSuccessorRecalculate != null){  
                     // updating false again leankor__IsSuccessorRecalculate__c field after recalcute linked activity                     
                   kcRecord.leankor__IsSuccessorRecalculate__c = request.IsSuccessorRecalculate;             
                }
                if(request.isConstraintRecalculate != null){  
                    // updating false again leankor__IsSuccessorRecalculate__c field after recalcute linked activity                     
                  kcRecord.leankor__IsConstraintRecalculate__c = request.isConstraintRecalculate;             
               }

                updateList.add(kcRecord);
            }
        }
        try {
            Database.update(updateList,true);
        } catch (DmlException e) {
            System.debug('Error : '+e.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage()); 
        }
        return updatelist;
   }
            
                   
   global  class  ResourceAssignment{
    @AuraEnabled
	    global string Id;
	    global string Name;
        @AuraEnabled
	    global string TaskId;
	    global string resourceGUID;
        @AuraEnabled
	    global string ResourceId;
        @AuraEnabled
	    global decimal Units;
	    global string ownerId;
	    global string ownerName;
	    global Decimal PercentCompleted;
	    global String verb;
	    global string activityId; 
	    global string resourceType ;
	    global String SmallPhotoUrl;
	    global String appointmentNumber;
	    global String workOrderNumber;
	    global DateTime startDateTime;
	    global DateTime dueDateTime;
	    //Date 17/09/19
	    public String resourceTypeId;
	    public String TempUUID;
        global Decimal PercentCompletedOfKanbanCard;
        
    }
    
    @remoteaction
    global static list<ResourceAssignment> CreateResourceAssignment(list<ResourceAssignment> listRSA){
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior 

        list<ResourceAssignment> result = new list<ResourceAssignment>();
        list<leankor__ResourceAssignment__c>  insertLog = new list<leankor__ResourceAssignment__c>();
        List<Id> kanbancard = new List<Id>();
        Set<Id> resourceTypeIds =new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();

        try {       

            for (ResourceAssignment rsa : listRSA) {
            	//Date :17/09/19
            	if(String.isNotBlank(rsa.resourceTypeId)){
            		resourceTypeIds.add(rsa.resourceTypeId);
            		
            	}else{           		
                resourceIds.add(rsa.ResourceId);
                }
            }    

            //Date :17/09/19
            Map<Id, leankor__ResourceType__c> mapOfResourceType =new   Map<Id, leankor__ResourceType__c>();
            Map<Id, leankor__Resource__c> resourceTypes =new  Map<Id, leankor__Resource__c>();

            if(resourceTypeIds.size()>0){
            	       mapOfResourceType = ResourceType.readResourceType(resourceTypeIds);     
            } else{
            // gets the latest resource record of each user 
            		 resourceTypes = Resource.readResource(resourceIds); 
            }    

            for(ResourceAssignment ra : listRSA) {
                leankor__ResourceAssignment__c rsa = new leankor__ResourceAssignment__c();
                rsa.leankor__KanbanCard__c = ra.TaskId;
                rsa.leankor__AssignedTo__c = ra.ResourceId;
                rsa.leankor__PercentAllocation__c = ra.Units;                              
            	//Date :17/09/19
                rsa.leankor__ResourceType__c= ra.resourceTypeId; 

            	if(mapOfResourceType.containsKey(ra.resourceTypeId)){
            		System.debug(mapOfResourceType);
            		rsa = ResourceType.IS_MULTI_CURRENCY_ORGANIZATION ? ResourceType.setResourceAccounts(ra.resourceTypeId, mapOfResourceType, rsa, true) : ResourceType.setResourceAccounts(ra.resourceTypeId, mapOfResourceType, rsa); 
            	}else{
					rsa = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(ra.ResourceId, resourceTypes, rsa, true) : Resource.setResourceAccounts(ra.ResourceId, resourceTypes, rsa);                    
                }
            	System.debug(rsa); 
                insertLog.add(rsa);
                kanbancard.add(rsa.leankor__KanbanCard__c);//adding kanban card Ids.
            }

            DataBase.insert(insertLog,true);
             //update percentage completed on activity as per RA.
            leankor.ProjectBoardCarousel.raPercentageCompleteChanged(kanbancard);
			// Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
            Map<Id, leankor__KanbanCard__c> kcMap = new Map<Id, leankor__KanbanCard__c>
                ([SELECT 
                        Id, 
                        leankor__PercentComplete2__c, 
                        Name 
                    FROM leankor__KanbanCard__c 
                    WHERE Id IN : kanbancard
                        AND leankor__isRecordDeleted__c = false
                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                ]);
                                
            for(leankor__ResourceAssignment__c raData :insertLog) {
            	System.debug(raData);
                ResourceAssignment resultlog = new ResourceAssignment();
                resultlog.Id  = raData.Id;
                resultlog.Name  = raData.Name;
                resultlog.TaskId  = raData.leankor__KanbanCard__c;
                resultlog.Units  = raData.leankor__PercentAllocation__c;
                resultlog.ResourceId  = raData.leankor__AssignedTo__c;
                resultlog.PercentCompleted = kcMap.get(raData.leankor__KanbanCard__c).leankor__PercentComplete2__c;           
                resultlog.resourceType = String.IsNotBlank(RAdata.leankor__ResourceType__c)? 'ResourceType':'Leankor';//RS 27.4.2018  
                //Date :17/09/19  
                resultlog.resourceTypeId= RAdata.leankor__ResourceType__c; 
                if(mapOfResourceType.containsKey(RAdata.leankor__ResourceType__c)){
                	resultlog.ownerName=mapOfResourceType.get(RAdata.leankor__ResourceType__c).Name; 
                }                
                result.add(resultlog);
            }       
    	  } catch(Exception ex) {
            System.debug('Error in CreateResourceAssignment(): ' + ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }       
        
        return result;
    }
    
    @remoteaction
    global static string  DeleteResourceAssignment(List<String> ResourceID) {
        //In this method we are receiving ResourceID or GUID so that we have not added input validation code.
        //Check CRUD / FLC behavior 
        String result;
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !resourceAssignmentBehavior.isAccessible() || 
            !resourceAssignmentBehavior.isUpdateable() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        List<leankor__ResourceAssignment__c> resourceAssignments = [Select Id, 
                                                                        leankor__AssignedTo__c, 
                                                                        leankor__KanbanCard__c,
                                                                        leankor__ResourceType__c,
                                                                        leankor__ProjectFinancial__c
                                                                    From leankor__ResourceAssignment__c 
                                                                    Where (Id In :resourceId Or leankor__KanbanCard__r.leankor__GUID__c In :resourceId) 
                                                                    Limit 10000];
        List<Id> kanbancard = new List<Id>();
        for(leankor__ResourceAssignment__c resourceAssignment : resourceAssignments) {
            kanbancard.add(resourceAssignment.leankor__KanbanCard__c);
        
            resourceAssignment.leankor__KanbanCard__c = null;
            resourceAssignment.leankor__AssignedTo__c = null;
            resourceAssignment.leankor__ResourceType__c = null;
            resourceAssignment.leankor__ProjectFinancial__c = null;
        }
                  
        try{
            update resourceAssignments;
        }catch(DMLException ex){
            System.debug('Error : while updating Resource '+ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
            
        }
        
        try{
            leankor.ProjectBoardCarousel.raPercentageCompleteChanged(kanbancard);      
            List<leankor__KanbanCard__c> kclist= [SELECT Id,leankor__PercentComplete2__c,Name FROM leankor__KanbanCard__c WHERE Id IN : kanbancard limit 1];   
        
            if(kclist.size() > 0) {
                result = String.Valueof(kclist[0].leankor__PercentComplete2__c);
            }
            return result;
        }catch(Exception ex){
        
         // return 'failed';
         //25/04/2023 : We are Throwing Exception
         throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
           
    }

    @AuraEnabled
    public static  List<ResourceAssignmentResponse>  getResourceAssignments(String taskId){
        List<ResourceAssignmentResponse> response =  new List<ResourceAssignmentResponse>();
        List<ResourceAssignment> resourceAssignments = getResourceAssignment(taskId);
        for (ResourceAssignment ra : resourceAssignments) {
            ResourceAssignmentResponse assignmentResponse = new ResourceAssignmentResponse();
            assignmentResponse.id = ra.Id;
            assignmentResponse.name = ra.Name;
            assignmentResponse.taskId = ra.TaskId;
            assignmentResponse.resourceGUID = ra.resourceGUID;
            assignmentResponse.resourceId = ra.ResourceId;
            assignmentResponse.units = ra.Units;
            assignmentResponse.ownerId = ra.ownerId;
            assignmentResponse.ownerName = ra.ownerName;
            assignmentResponse.percentCompleted = ra.PercentCompleted;
            assignmentResponse.verb = ra.verb;
            assignmentResponse.activityId = ra.activityId;
            assignmentResponse.resourceType = ra.resourceType;
            assignmentResponse.smallPhotoUrl = ra.SmallPhotoUrl;
            assignmentResponse.appointmentNumber = ra.appointmentNumber;
            assignmentResponse.workOrderNumber = ra.workOrderNumber;
            assignmentResponse.startDateTime = ra.startDateTime;
            assignmentResponse.dueDateTime = ra.dueDateTime;
            assignmentResponse.resourceTypeId = ra.resourceTypeId;
            assignmentResponse.tempUUID = ra.TempUUID;
            assignmentResponse.percentCompletedOfKanbanCard = ra.PercentCompletedOfKanbanCard;
            
            // Add the populated response to the list
            response.add(assignmentResponse);

        }
        return response;
    }
    
     /*------------------------------------------------------------
        Description:    Get Resource Assignment Records of Card
        Inputs:         TaskId
        Returns:        List<ResourceAssignment>
        ------------------------------------------------------------*/
    @remoteaction
    @AuraEnabled(cacheable=true)
    global static list<ResourceAssignment>  getResourceAssignment(String TaskId){
        if (String.isNotBlank(TaskId) && Util.getSObjectName(TaskId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!resourceAssignmentBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        list<ResourceAssignment> result = new list<ResourceAssignment>();
        //SS 26.04.2018
        //Query for ResourceAssigment in Soql for loop.
        for(leankor__ResourceAssignment__c RaLog :[SELECT 
                                                        Id, 
                                                        leankor__AssignedTo__c,
                                                        leankor__AssignedTo__r.name,
                                                        leankor__KanbanCard__c,
                                                        leankor__PercentAllocation__c,
                                                        Name,
                                                        OwnerId,
                                                        leankor__ResourceType__c ,
                                                        leankor__ResourceType__r.Name,
                                                   		leankor__PercentCompleted__c 
                                                    FROM leankor__ResourceAssignment__c 
                                                    WHERE leankor__KanbanCard__c = :TaskId 
													LIMIT 49999 ])
        {
        	if(RaLog.leankor__ResourceType__c!=null || RaLog.leankor__AssignedTo__c !=null){
            ResourceAssignment ResulRaLog = new ResourceAssignment();
            ResulRaLog.Id  = RaLog.Id;
            ResulRaLog.Name  = RaLog.Name;
            ResulRaLog.TaskId  = RaLog.leankor__KanbanCard__c;
            ResulRaLog.Units  = RaLog.leankor__PercentAllocation__c;
            ResulRaLog.ResourceId  = RaLog.leankor__AssignedTo__c;
	            ResulRaLog.resourceType = String.IsNotBlank(RaLog.leankor__ResourceType__c)? 'ResourceType':'Leankor';
            //ResulRaLog.ownerId = RaLog.ownerId;
            //Date :17/09/19      
            ResulRaLog.OwnerName =String.isNotBlank(RaLog.leankor__ResourceType__c)? RaLog.leankor__ResourceType__r.Name:RaLog.leankor__AssignedTo__r.name ;                                  
           	System.debug(RaLog.leankor__ResourceType__c);
           	ResulRaLog.resourceTypeId=RaLog.leankor__ResourceType__c; 
            ResulRaLog.PercentCompleted = RaLog.leankor__PercentCompleted__c;
            result.add(ResulRaLog);
            }
           
          }
        //SS 26.04.2018
            //RS 17.4.2018 For fsl resources 
            //Boolean fsl = KanbanController.checkFSLManageApp();
            //RS 05/12/2018  Due to 'Availability of FSL features in Leankor application' feature have to add this condition
            Boolean fsl = KanbanController.checkFSLManageApp() ? KanbanController.checkFieldExistInSobject() : false;
       
            if(fsl){
                List<String> kanbanCardIds = new  List<String>();
                kanbanCardIds.add(TaskId);
            //SS 28.04.2018
            //Iterate over list returned from getServiceAppointmentRecords
            for(KanbanController.FieldServiceLigtning fslRecord : KanbanController.getServiceAppointmentRecords(kanbanCardIds))
            {
                    if(fslRecord.Resources != null){
                     for(KanbanController.RelatedRecord r : fslRecord.Resources){
                        ResourceAssignment ResulRaLog1 = new ResourceAssignment();
                        //ResulRaLog1.Id  = r.Id;
                        ResulRaLog1.Name  = r.Name;
                        ResulRaLog1.ownerName = r.Name;
                        ResulRaLog1.ResourceId = r.Id;
                        ResulRaLog1.activityId = fslRecord.cardId;
                        ResulRaLog1.resourceType = 'FSL';
                        ResulRaLog1.SmallPhotoUrl = r.SmallPhotoUrl;
                        ResulRaLog1.appointmentNumber = fslRecord.appointmentNumber;
                        ResulRaLog1.workOrderNumber = fslRecord.workOrderNumber;
                            //ss 27.04.2018 commented for serviceCRewMember
                            //if resource type is crew member then add start/end date of crew member record
                            //else use start/due date of service appointment 
                            /*if(r.type=='CrewMember')
                            {
                                ResulRaLog1.startDateTime = DateTime.valueOf(r.startDate);
                                ResulRaLog1.dueDateTime = DateTime.valueOf(r.endDate);
                            }
                            else{
                                ResulRaLog1.startDateTime = fslRecord.startDateTime;
                                ResulRaLog1.dueDateTime = fslRecord.dueDateTime;
                            }*/
                            //ss 27.04.2018 commented for serviceCRewMember
                        ResulRaLog1.startDateTime = fslRecord.startDateTime;
                        ResulRaLog1.dueDateTime = fslRecord.dueDateTime;
                        result.add(ResulRaLog1);                    
                     } 
                    } 
                
                } 
            }
        return result;
    }
    
    // Overload getResourceAssignment Method Based on List of Ids
    @remoteaction
    global static List<ResourceAssignment> getResourceAssignmentBulkify(List<String> taskIds){
        for(String taskId : taskIds){
            if (String.isNotBlank(taskId) && Util.getSObjectName(taskId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!resourceAssignmentBehavior.isAccessible()) {
            new List<ResourceAssignment>();
        }
        //Check CRUD / FLC behavior
        List<ResourceAssignment> result = new List<ResourceAssignment>();
        List<leankor__ResourceAssignment__c> resourceList = [Select 
                                                            Id, 
                                                            leankor__AssignedTo__c,
                                                            leankor__AssignedTo__r.Name,
                                                            leankor__KanbanCard__c,
                                                            leankor__PercentAllocation__c,
                                                            Name,
                                                            OwnerId,
                                                            leankor__ResourceType__c ,
                                                            leankor__ResourceType__r.Name 
                                                    From leankor__ResourceAssignment__c 
                                                    Where leankor__KanbanCard__c IN:taskIds limit 49999 ];
        for(leankor__ResourceAssignment__c resourceRecord:resourceList){
            if(resourceRecord.leankor__ResourceType__c!=null || resourceRecord.leankor__AssignedTo__c !=null){
                ResourceAssignment singleResourceAssignment = new ResourceAssignment();
                singleResourceAssignment.Id  = resourceRecord.Id;
                singleResourceAssignment.Name  = resourceRecord.Name;
                singleResourceAssignment.TaskId  = resourceRecord.leankor__KanbanCard__c;
                singleResourceAssignment.Units  = resourceRecord.leankor__PercentAllocation__c;
                singleResourceAssignment.ResourceId  = resourceRecord.leankor__AssignedTo__c;
                singleResourceAssignment.resourceType = String.IsNotBlank(resourceRecord.leankor__ResourceType__c)? 'ResourceType':'Leankor';   
                singleResourceAssignment.OwnerName =String.isNotBlank(resourceRecord.leankor__ResourceType__c)? resourceRecord.leankor__ResourceType__r.Name:resourceRecord.leankor__AssignedTo__r.name ;                                  
                System.debug(resourceRecord.leankor__ResourceType__c);
                singleResourceAssignment.resourceTypeId=resourceRecord.leankor__ResourceType__c; 
                result.add(singleResourceAssignment);
            }

        }
            // Due to 'Availability of FSL features in Leankor application' feature have to add this condition
            Boolean fsl = KanbanController.checkFSLManageApp() ? KanbanController.checkFieldExistInSobject() : false;
       
            if(fsl){
                List<String> kanbanCardIds = new  List<String>();
                kanbanCardIds.addAll(taskIds);
            //Iterate over list returned from getServiceAppointmentRecords
                for(KanbanController.FieldServiceLigtning fslRecord : KanbanController.getServiceAppointmentRecords(kanbanCardIds)){
                    if(fslRecord.Resources != null){
                        for(KanbanController.RelatedRecord relatedRecords : fslRecord.Resources){
                            ResourceAssignment singleResourceAssignment = new ResourceAssignment();
                            singleResourceAssignment.Name  = relatedRecords.Name;
                            singleResourceAssignment.ownerName = relatedRecords.Name;
                            singleResourceAssignment.ResourceId = relatedRecords.Id;
                            singleResourceAssignment.activityId = fslRecord.cardId;
                            singleResourceAssignment.resourceType = 'FSL';
                            singleResourceAssignment.SmallPhotoUrl = relatedRecords.SmallPhotoUrl;
                            singleResourceAssignment.appointmentNumber = fslRecord.appointmentNumber;
                            singleResourceAssignment.workOrderNumber = fslRecord.workOrderNumber;
                            singleResourceAssignment.startDateTime = fslRecord.startDateTime;
                            singleResourceAssignment.dueDateTime = fslRecord.dueDateTime;
                            result.add(singleResourceAssignment);                    
                        } 
                    } 
                }
            }
        return result;
    }


    @remoteaction
    global static string  updateResourceAssignment(list<ResourceAssignment> listRSA) {     
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isUpdateable() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__ResourceAssignment__c> result = new List<leankor__ResourceAssignment__c>();                
        List<Id> activityIds = new List<Id>();
		Set<Id> resourceIds = new Set<Id>();
		//Date :18/09/19 To do ResourceType.
		Set<Id> resourceTypeIds =new Set<Id>();	
		Map<Id, leankor__Resource__c> resourceTypes =new  Map<Id, leankor__Resource__c>();
		Map<Id, leankor__ResourceType__c> mapOfResourceType =new   Map<Id, leankor__ResourceType__c>();	 
		try {        
			for (ResourceAssignment rsa : listRSA) {
				if(string.isNotBlank(rsa.resourceTypeId)){
					resourceTypeIds.add(rsa.resourceTypeId);
				}else{
				resourceIds.add(rsa.ResourceId);
			    }
            }			
	
            if(resourceTypeIds.size()>0){
            	   	mapOfResourceType = ResourceType.readResourceType(resourceTypeIds);     
            } else{
            	 	resourceTypes = Resource.readResource(resourceIds); 
            }                                             		   		   		   					                                                
	        for(ResourceAssignment raData :listRSA) {
				leankor__ResourceAssignment__c baseResource = new leankor__ResourceAssignment__c();            
				baseResource.Id = raData.Id;
				if(String.isNotBlank(RAdata.ResourceId)){
					baseResource.leankor__AssignedTo__c = raData.ResourceId; 
				}				           
				baseResource.leankor__PercentAllocation__c = raData.Units;
				baseResource.leankor__KanbanCard__c = raData.TaskId;
				//Date :18/09/19 To do ResourceType.
				if(String.isNotBlank(RAdata.resourceTypeId)){
					baseResource.leankor__ResourceType__c=raData.resourceTypeId;
				}
				if(mapOfResourceType.containsKey(raData.resourceTypeId)){
					baseResource = ResourceType.IS_MULTI_CURRENCY_ORGANIZATION ? ResourceType.setResourceAccounts(raData.resourceTypeId, mapOfResourceType, baseResource, true) : ResourceType.setResourceAccounts(raData.resourceTypeId, mapOfResourceType, baseResource);
				}else{				
					baseResource = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(raData.ResourceId, resourceTypes, baseResource, true) : Resource.setResourceAccounts(raData.ResourceId, resourceTypes, baseResource);
				}	             
				activityIds.add(baseResource.leankor__KanbanCard__c);                                                               
				result.add(baseResource); 
	        }

            update result;  
            
            // update percentage completion on activity as per RA        
            leankor.ProjectBoardCarousel.raPercentageAllocatedChanged(activityIds);       
            
            List<leankor__KanbanCard__c> kclist = 
                                                [SELECT 
                                                        Id,
                                                        leankor__PercentComplete2__c,
                                                        Name 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE Id IN :activityIds
                                                ];
            
            return String.Valueof(kclist[0].leankor__PercentComplete2__c);

        } catch(Exception ex) {
            System.debug('Error in updateResourceAssignment(): ' + ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
    }
    
    global class ScheduleMode{
        global String SchedulingModeId;
        global string SchedulingMode;
        global boolean ManuallyScheduled;
        global decimal Effort;
        global string EffortUnit;
        global string ActivityId;
        global string ConstraintType;
        global string ConstraintDate;
        global boolean ReadOnly;
        global String parentCardConstraintType;
        global DateTime parentCardConstraintDate;
    }
    
    global static List<leankor__ScheduleMode__c> CreateScheduleMode(List<leankor__kanbancard__c> Listofcards){
        for(leankor__kanbancard__c listofcard : Listofcards){
            if (String.isNotBlank(listofcard.Id) && Util.getSObjectName(listofcard.Id) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !scheduleModeBehavior.isAccessible() || 
            !scheduleModeBehavior.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        // removing milestone filter for preventing creating SM for milestone
        List<leankor__ScheduleMode__c> ListSCM = new List<leankor__ScheduleMode__c>();
		//15/11/2021 : Changes : For Constraint we are not creating schedulemode for Activity Group.
        List<leankor__kanbancard__c> allcard = [Select 
                                                    Id,
                                                    leankor__GUID__c,
                                                    Recordtype.Name,
                                                    leankor__ValueStream__r.leankor__EffortUnits__c,
                                                    leankor__ValueStream__r.leankor__ManuallyScheduled__c,
                                                    leankor__ValueStream__r.leankor__Mode__c 
                                                From leankor__kanbancard__c 
                                                Where Id IN :Listofcards 
                                                    And (recordtype.name ='ActivityCard' 
                                                    Or recordtype.name ='MileStoneCard' )
                                                   // Or recordtype.name ='FolderCard') 
                                                LIMIT 9999] ; 

        //for(leankor__kanbancard__c Cardlog : Listofcards)
        //{
            for(leankor__kanbancard__c activitylog : allcard){
            
                    leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c ();                  
                    scheduleMode.leankor__EffortUnits__c = activitylog.leankor__ValueStream__r.leankor__EffortUnits__c;
                    scheduleMode.leankor__KanbanCard__c = activitylog.ID;
                    if(CreateGanttItemAction.calledFromMPPImport == true) {
                        scheduleMode.leankor__ManuallyScheduled__c = CreateGanttItemAction.kanbanCardManuallyScheduledMap.get(activitylog.leankor__GUID__c);
                    } else {
                        scheduleMode.leankor__ManuallyScheduled__c = activitylog.leankor__ValueStream__r.leankor__ManuallyScheduled__c;
                }
                    scheduleMode.leankor__Mode__c = activitylog.leankor__ValueStream__r.leankor__Mode__c;
                    scheduleMode.leankor__EffortActual__c = scheduleMode.leankor__Mode__c == 'EffortDriven' ? 1.0 : 0.0;
                    scheduleMode.leankor__ScheduleConstraint__c = null;
                    scheduleMode.leankor__ConstraintDateTime__c = null;
                    ListSCM.add(scheduleMode);
                }
        //}
        try{
            DataBase.insert(ListSCM,true);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return  ListSCM;
    }


    @remoteaction
    global static string DeleteScheduleMode(List<String> ActivityId) {
          //In this method we are receiving ResourceID or GUID so that we have not added input validation code.
        //Check CRUD / FLC behavior 
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (
            !scheduleModeBehavior.isAccessible() || 
            !scheduleModeBehavior.isUpdateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
    	List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();
        for (leankor__ScheduleMode__c scheduleMode : [Select Id, 
                                                    leankor__KanbanCard__c, 
                                                            leankor__ScheduleConstraint__c
                                                        From leankor__ScheduleMode__c 
                                                        Where leankor__KanbanCard__c In :ActivityId 
                                                            Or leankor__KanbanCard__r.leankor__GUID__c In :ActivityId 
                                                        Limit 10000]){

            scheduleMode.leankor__KanbanCard__c = null;
            scheduleMode.leankor__ScheduleConstraint__c = null;
            scheduleModes.add(scheduleMode);
        }
        
        if (!scheduleModes.isEmpty()) {
        try{
                update scheduleModes;
        }catch(DMLException ex){
                System.debug('Error : while updating ScheduleMode '+ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        }
        return 'success';
    }


    global static void CreateDefaultResourceAssignment(List<leankor__kanbancard__c> Listofcards){
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__ResourceAssignment__c> RsaLog = new List<leankor__ResourceAssignment__c>();
        for(leankor__kanbancard__c Cards : Listofcards) {    
            // creating RA for only activity card
            if(Cards.RecordtypeId == Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId())
            {
                leankor__ResourceAssignment__c Rsa = new leankor__ResourceAssignment__c();
                RSA.leankor__KanbanCard__c = Cards.Id;
                RSA.leankor__AssignedTo__c = Cards.OwnerId;
                RSA.leankor__PercentAllocation__c = 100;
                RsaLog.add(RSA);
            }
        }
        if(RsaLog.size()>0) {
        insert RsaLog;
        }
    }


    @remoteaction
    global static List<ScheduleMode> UpdateScheduleMode(List<ScheduleMode> Listofcards){
        //Check CRUD / FLC behavior 
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (
            !scheduleModeBehavior.isAccessible() ||
            !scheduleModeBehavior.isUpdateable() ||
            !scheduleModeBehavior.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = new  Map<String, leankor__ScheduleConstraint__c>();
        scheduleConstraints = getScheduleConstraints();
        List<leankor__ScheduleMode__c> ListSCM = new List<leankor__ScheduleMode__c>();
        for(ScheduleMode Cardlog : Listofcards){
            leankor__ScheduleMode__c SCM = new leankor__ScheduleMode__c ();
            SCM.leankor__EffortActual__c = Cardlog.Effort;
            SCM.leankor__EffortUnits__c = Cardlog.EffortUnit;
            SCM.leankor__KanbanCard__c = Cardlog.ActivityId;
            SCM.leankor__ManuallyScheduled__c = Cardlog.ManuallyScheduled;
            SCM.leankor__Mode__c = Cardlog.SchedulingMode;
            SCM.ID = Cardlog.SchedulingModeId;
            if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS ){
                SCM.leankor__ConstraintDateTime__c = Cardlog.ConstraintDate != null && String.isNotBlank(Cardlog.ConstraintDate) ? DateTime.newInstance(Long.valueOf(Cardlog.ConstraintDate)) : null;
                SCM.leankor__ScheduleConstraint__c = Cardlog.ConstraintType != null && String.isNotBlank(Cardlog.ConstraintType) ? scheduleConstraints.get(Cardlog.ConstraintType).Id : null;
                /*if(String.isNotBlank(Cardlog.ConstraintDate)){
                    SCM.leankor__ConstraintDateTime__c =  DateTime.newInstance(Long.valueOf(Cardlog.ConstraintDate));
                }
                if(String.isNotBlank(Cardlog.ConstraintType)){
                    SCM.leankor__ScheduleConstraint__c =  scheduleConstraints.get(Cardlog.ConstraintType).Id;
                }*/
            }
            if(Cardlog.ConstraintType != null && String.isNotBlank(Cardlog.ConstraintType)){
                SCM.leankor__ScheduleConstraint__c = scheduleConstraints.get(Cardlog.ConstraintType).Id;
            }else {
                SCM.leankor__ScheduleConstraint__c = null;
            }
            ListSCM.add(SCM);
        }
        try{
            DataBase.upsert(ListSCM,true);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return new list<ScheduleMode>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        
        return  Listofcards;
    }

    @AuraEnabled
    public static List<ScheduleModeInfo> updateScheduleModes(List<ScheduleModeInfo> scheduleModesData) {
        // Convert ScheduleModeData to ScheduleMode
        List<ScheduleMode> listOfCards = new List<ScheduleMode>();
        
        for (ScheduleModeInfo data : scheduleModesData) {
            ScheduleMode card = new ScheduleMode();
            card.Effort = data.effort;
            card.EffortUnit = data.effortUnit;
            card.ActivityId = data.activityId;
            card.ManuallyScheduled = data.manuallyScheduled;
            card.SchedulingMode = data.schedulingMode;
            card.SchedulingModeId = data.schedulingModeId;
            card.ConstraintDate = data.constraintDate;
            card.ConstraintType = data.constraintType;
            listOfCards.add(card);
        }
        
        // Call the existing method
        List<ScheduleMode> updatedCards = UpdateScheduleMode(listOfCards);
        
        // Convert back to ScheduleModeData
        List<ScheduleModeInfo> response = new List<ScheduleModeInfo>();
        
        for (ScheduleMode card : updatedCards) {
            ScheduleModeInfo data = new ScheduleModeInfo();
            data.effort = card.Effort;
            data.effortUnit = card.EffortUnit;
            data.activityId = card.ActivityId;
            data.manuallyScheduled = card.ManuallyScheduled;
            data.schedulingMode = card.SchedulingMode;
            data.schedulingModeId = card.SchedulingModeId;
            data.constraintDate = card.ConstraintDate;
            data.constraintType = card.ConstraintType;
            response.add(data);
        }
        
        return response;
    }


     
    /*------------------------------------------------------------
    Author:         Yash Jain
    Company:        Leankor
    Description:    getting all schedule mode data.
    Inputs:         leankor__ValueStream__c Ids
    Returns:        List<ScheduleMode>
    ------------------------------------------------------------*/ 
    @Remoteaction
    global static List<ScheduleMode> getAllScheduleMode(List<String> valueStreamIds){
        for(String valueStreamId : valueStreamIds){
            if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
		leankor__ScheduleMode__c scheduleModeRecord = new leankor__ScheduleMode__c();
        Map<String, leankor__ScheduleMode__c> cardLinkScheduleMode;
        List<ScheduleMode> scheduleModeList = new List<ScheduleMode>(); 
        try{
            for(leankor__ScheduleMode__c SCM : [SELECT Id,
                                                    leankor__KanbanCard__c,
                                                    leankor__Mode__c,
                                                    leankor__EffortUnits__c,
                                                    leankor__EffortActual__c,
                                                    Name,
                                                    leankor__ManuallyScheduled__c
                                                    //leankor__ReadOnly__c
                                                FROM leankor__ScheduleMode__c 
                                                WHERE leankor__KanbanCard__r.leankor__ValueStream__c IN: valueStreamIds 
                                                LIMIT 49999]){
                
                ScheduleMode sMode = new ScheduleMode();
                
                sMode.SchedulingModeId = SCM.Id;
                sMode.SchedulingMode = SCM.leankor__Mode__c;
                sMode.ManuallyScheduled = SCM.leankor__ManuallyScheduled__c;
                sMode.Effort = SCM.leankor__EffortActual__c;
                sMode.EffortUnit = SCM.leankor__EffortUnits__c;
                sMode.ActivityId = SCM.leankor__KanbanCard__c;
                //sMode.ReadOnly = SCM.leankor__ReadOnly__c;
                scheduleModeList.add(sMode);
            
            }
        }catch(Exception ex){
            //return new  List<ScheduleMode>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return scheduleModeList;
    }


    //
    @remoteaction
    global static List<leankor__ScheduleMode__c> getScheduleMode(List<String> ListofID) {
        for(String CardId : ListofID){
            if (String.isNotBlank(CardId) && Util.getSObjectName(CardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ScheduleMode__c> SCMLog;

        //Changes : Check constraint setting enable or not.
        if( realTimeController.ALLOW_SCHEDULING_CONSTRAINTS )
        {
            SCMLog = [SELECT Id,
                                                    leankor__KanbanCard__c,
                                                    leankor__Mode__c,
                                                    leankor__EffortUnits__c,
                                                    leankor__EffortActual__c,
                                                    Name,
                                                    leankor__ManuallyScheduled__c,
                                                    leankor__ConstraintDateTime__c,
                                                    leankor__ScheduleConstraint__r.leankor__Type__c
                                                    //leankor__ReadOnly__c
                                                FROM leankor__ScheduleMode__c 
                                                WHERE leankor__KanbanCard__c IN: ListofID 
                      LIMIT 50000];
        }else{
            SCMLog = [SELECT Id,
                            leankor__KanbanCard__c,
                            leankor__Mode__c,
                            leankor__EffortUnits__c,
                            leankor__EffortActual__c,
                            Name,
                            leankor__ManuallyScheduled__c
                            //leankor__ReadOnly__c
                        FROM leankor__ScheduleMode__c 
                        WHERE leankor__KanbanCard__c IN: ListofID 
                        LIMIT 50000];
        }
        
        return SCMLog;  
    }
    

    @Remoteaction
    global static List<ResourceAssignment> multiActivityUpdateRA(List<String> activityIds,List<String> RAJsonString) {
        for(String activityId : activityIds){
            if (String.isNotBlank(activityId) && Util.getSObjectName(activityId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        ResourceTypeBehaviour resourceTypeBehaviour = new ResourceTypeBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !resourceTypeBehaviour.isAccessible() ||
            !resourceTypeBehaviour.isDeletable() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isCreateable() ||
            !resourceAssignmentBehavior.isUpdateable() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<ResourceAssignment> RAlist = new List<ResourceAssignment>();
        List<leankor__ResourceAssignment__c> finalresult = new List<leankor__ResourceAssignment__c>();
        List<String> tempUUIDValues = new List<String>(); 
        List<leankor__ResourceAssignment__c> resourceLogs = new List<leankor__ResourceAssignment__c>();  
        for (leankor__ResourceAssignment__c resourceAssignment : [Select Id,
                                                                        leankor__KanbanCard__c,
                                                                        leankor__AssignedTo__c,
                                                                        leankor__ResourceType__c,
                                                                        leankor__ProjectFinancial__c
                                                                    From leankor__ResourceAssignment__c 
                                                                    Where leankor__KanbanCard__c In: activityIds 
                                                                    Limit 10000]) {
            resourceAssignment.leankor__KanbanCard__c = null;
            resourceAssignment.leankor__AssignedTo__c = null;
            resourceAssignment.leankor__ResourceType__c = null;
            resourceAssignment.leankor__ProjectFinancial__c = null;
            resourceLogs.add(resourceAssignment);
        }
        if (resourceLogs.size()>0){
            update resourceLogs;
        }
        //Date: 17/10/2019 -  Getting the resource types.
        /*Map <Id, leankor__ResourceType__c> mapOfResourceType = new Map<Id, leankor__ResourceType__c>([SELECT Id, 
                                                                                                            Name,
                                                                                                            leankor__ExpenseAccount__c,
                                                                                                            leankor__ExpenseCategory__c,
                                                                                                            leankor__ExpenseSubCategory__c,
                                                                                                            leankor__ExternalHourlyRate__c,
                                                                                                            leankor__InternalHourlyRate__c
                                                                                                        FROM leankor__ResourceType__c LIMIT 9999]);  */     
        
        Set<Id> resourceTypeIds =new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();
        List<ResourceAssignment> ResourceAssignmentList = new List<ResourceAssignment>();
        for(String resourceData : RAJsonString){
            ResourceAssignment request = (ResourceAssignment)JSON.deserialize(resourceData, ResourceAssignment.Class);
            if(String.isNotBlank(request.resourceTypeId)){
            	resourceTypeIds.add(request.resourceTypeId);
            }
            if(String.isNotBlank(request.ResourceId)){           		
                resourceIds.add(request.ResourceId);
            }
            ResourceAssignmentList.add(request);
        }

        Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds); 
        Map <Id, leankor__ResourceType__c> mapOfResourceType = ResourceType.readResourceType(resourceTypeIds); 
         
        for(String act : activityIds)
        {
           for(ResourceAssignment request : ResourceAssignmentList)
           {
              leankor__ResourceAssignment__c result = new leankor__ResourceAssignment__c();                         
              result.leankor__KanbanCard__c = act;
              result.leankor__PercentAllocation__c = request.units;
              result.leankor__AssignedTo__c = request.ResourceId;
              result.leankor__PercentCompleted__c = request.PercentCompleted;
                //Date: 17/10/2019 -  To update the resource type            
                if(mapOfResourceType.containsKey(request.resourceTypeId) || (request.resourceTypeId != null ? Id.valueOf(request.resourceTypeId).getSObjectType().getDescribe().getName() == 'leankor__ResourceType__c' : false)){
                    if(!mapOfResourceType.containsKey(request.resourceTypeId)){
                     
                        continue;
                    }    
                    result.leankor__ResourceType__c = request.resourceTypeId;
                    result = ResourceType.IS_MULTI_CURRENCY_ORGANIZATION ? ResourceType.setResourceAccounts(request.resourceTypeId, mapOfResourceType, result, true) : ResourceType.setResourceAccounts(request.resourceTypeId, mapOfResourceType, result);                    
           		} else{
					result = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(request.ResourceId, resourceTypes, result, true) : Resource.setResourceAccounts(request.ResourceId, resourceTypes, result); 
           		}        
               	tempUUIDValues.add(request.TempUUID);   
                finalresult.add(result);
        }               
        	}               
        try{
            if(finalresult.size()>0)
            {
                DataBase.insert(finalresult,true);
            }
        }catch(Exception ex){
            System.debug('Error : '+ex.getMessage());
            //return new list<ResourceAssignment>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        } 
        
      //update percentage completed on activity depend on RA.
        leankor.ProjectBoardCarousel.raPercentageCompleteChanged(activityIds);
        
        Map<Id,leankor__KanbanCard__c> kcMap = new Map<Id,leankor__KanbanCard__c>([SELECT Id,leankor__PercentComplete2__c,Name FROM leankor__KanbanCard__c WHERE Id IN : activityIds]);   
        Integer count = 0;    
        for(leankor__ResourceAssignment__c RaLog :finalresult) {
            ResourceAssignment ResulRaLog = new ResourceAssignment();
            ResulRaLog.Id  = RaLog.Id;
            ResulRaLog.Name  = RaLog.Name;
            ResulRaLog.TaskId  = RaLog.leankor__KanbanCard__c;
            ResulRaLog.Units  = RaLog.leankor__PercentAllocation__c;
            ResulRaLog.ResourceId  = RaLog.leankor__AssignedTo__c;
            ResulRaLog.PercentCompletedOfKanbanCard = kcMap.get(RaLog.leankor__KanbanCard__c).leankor__PercentComplete2__c;
            ResulRaLog.PercentCompleted = RaLog.leankor__PercentCompleted__c;
            ResulRaLog.resourceTypeId = RaLog.leankor__ResourceType__c;
            //SS 21.10.2019
            //If ResourceType is assigned then need to send ResourceType name as Ownername to show on Gantt
            if(String.isNotBlank(RaLog.leankor__ResourceType__c) && mapOfResourceType.containsKey(RaLog.leankor__ResourceType__c)){
            	ResulRaLog.OwnerName = ((leankor__ResourceType__c)mapOfResourceType.get(RaLog.leankor__ResourceType__c)).Name;
            }
            
            ResulRaLog.TempUUID = tempUUIDValues.get(count);   
            
            
            count++;
            RAlist.add(ResulRaLog);
            
        }
        
        
        return RAlist;            
    }         


    // 31.01.2017 this method is for getting miniature valuestream Id on plangantt board for using broadcasting
    // this method is global because broadcasting work on Iframe if we put public then broadcasting will not work on Iframe.
    @remoteaction 
    global static Set<String> getMiniatureValueStream(String ganttID) {
        if (String.isNotBlank(ganttID) && Util.getSObjectName(ganttID) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !valueStreamBehavior.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        if(String.isEmpty(ganttID))
        {
            return new Set<String>();
        }   
           
        List<leankor__KanbanCard__c> listofcards;
        Set<Id> idlist = new set<Id>();
        Boolean flag = false;   
        //String ProjectId;
              
        for(leankor__KanbanCard__c kanbanCard : [SELECT Id,
                                                        leankor__ValueStream__c,
                                                        leankor__Projectroom__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__ValueStream__c =: ganttID 
                                                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                        AND leankor__isRecordDeleted__c = false 
									                LIMIT 49999]){
            if(kanbanCard.leankor__Valuestream__c != Null && kanbanCard.leankor__Projectroom__c != Null) {   
                idlist.add(kanbanCard.Id);
                if(kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c){
                   flag = true;
                }
                //ProjectId = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
            }                   
       }
              
        Set<String> miniaturevaluestream = new Set<String>();
        if(flag) {      
            listofcards = [SELECT Id,
                                    leankor__ValueStream__c 
                                    FROM leankor__KanbanCard__c 
                                    WHERE leankor__ValueStreamCardLink__c IN : idlist
                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                        And leankor__isRecordDeleted__c = false 
                                    LIMIT 50000];

        }else {
            List<String> masterContainerTypeFilters = new List<String>{'Archive', 'Backlog', 'Regular'};       
            listofcards = [SELECT Id,
                                    leankor__ValueStream__c 
                                FROM leankor__KanbanCard__c 
                                WHERE leankor__ValueStreamCardLink__c IN: idlist
                                    AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                    AND leankor__isRecordDeleted__c = false 
                                    AND leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                    AND leankor__MasterContainer__r.leankor__Type__c IN: masterContainerTypeFilters 
                                LIMIT 50000];
        }
       
        //getting project Id
        leankor__ValueStream__c VsProject = [SELECT leankor__ProjectRoom__c FROM leankor__ValueStream__c WHERE Id =: ganttID AND leankor__IsRecordDeleted__c = false LIMIT 49999];
       
        for(leankor__ValueStream__c vs : [SELECT Id FROM leankor__ValueStream__c WHERE leankor__ProjectRoom__c =: VsProject.leankor__ProjectRoom__c]) {
                miniaturevaluestream.add(vs.Id);
        }
        
        for(leankor__KanbanCard__c loc : listofcards) {   
                miniaturevaluestream.add(loc.leankor__ValueStream__c);       
        } 
        /*SS 10.09.2018*/
        //Add dependent VS and its miniature  VS for Broadcasting
        //Set<String> tempVSIds = readDependentValueStreamsIds(new Set<String> {ganttID});
        Set<String> tempVSIds = getExternallyDependentVSIds(new Set<String> {ganttID});
        miniaturevaluestream.addAll(tempVsIds);
        for(leankor__KanbanCard__c kcData : [SELECT leankor__ValueStream__c 
                                                FROM leankor__KanbanCard__c 
                                                WHERE leankor__ValueStreamLink__c IN: tempVSIds 
                                                    AND leankor__IsRecordDeleted__c  = false 
                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                LIMIT 49999]){
            miniaturevaluestream.add(kcData.leankor__ValueStream__c);
       } 
        //Add depedent valuestreamIds for broadcasting
       //miniaturevaluestream.addAll(readDependentValueStreamsIds(new Set<String> {ganttID})); 
       // miniaturevaluestream.addall(KanbanToGanttController.getAllValueStreamID(ganttID));     
       return miniaturevaluestream;         
     }
     
     
    @RemoteAction
    global static List<ResourceAssignment> getAllResources(string VSId){
        if (String.isNotBlank(VSId) && Util.getSObjectName(VSId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!resourceAssignmentBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        //On Broadcast need to provide ResourceType info as well 
        //Earlier it was missed to implement
            List<leankor__ResourceAssignment__c> allResources = [SELECT Id,
                                                                        Name,
                                                                        leankor__PercentAllocation__c,
                                                                        leankor__KanbanCard__c,
                                                                        leankor__AssignedTo__c,
                                                                        leankor__ResourceType__c,
                                                                        leankor__ResourceType__r.Name,
                                                                        leankor__AssignedTo__r.Name,
                                                                        owner.Name
                                                                    FROM leankor__ResourceAssignment__c 
                                                                    WHERE leankor__KanbanCard__r.leankor__ValueStream__c =: VSId 
                                                                        AND leankor__KanbanCard__r.Recordtype.name = 'Activitycard' 
                                                                    LIMIT 49999];
        
         List<leankor.GanttTaskboard.ResourceAssignment> allResourcesData = new List<leankor.GanttTaskboard.ResourceAssignment>();
        
         for(leankor__ResourceAssignment__c resourceAssignment : allResources){
         leankor.GanttTaskboard.ResourceAssignment resourceData = new leankor.GanttTaskboard.ResourceAssignment();
          resourceData.Id = resourceAssignment.Id;
          resourceData.Units = resourceAssignment.leankor__PercentAllocation__c;
          resourceData.TaskId = resourceAssignment.leankor__KanbanCard__c;
          resourceData.ResourceId = resourceAssignment.leankor__AssignedTo__c;
          resourceData.Name = resourceAssignment.Name;
          resourceData.ownerName = String.isNotBlank(resourceAssignment.leankor__ResourceType__c) ? resourceAssignment.leankor__ResourceType__r.Name : resourceAssignment.leankor__AssignedTo__r.Name;
          resourceData.resourceTypeId = resourceAssignment.leankor__ResourceType__c;
          resourceData.resourceType = String.IsNotBlank(resourceAssignment.leankor__ResourceType__c)? 'ResourceType':'Leankor'; 
          allResourcesData.add(resourceData);
          
         }
        return allResourcesData;
        
        }
     
    //----------------
    @RemoteAction
    global static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getProjects()
    {
            return new Set<ProjectBoardCarousel.PortfolioHierarchy>();
    }
    //----------------
    

    // lazy loading on projectdependency
    @RemoteAction
    global static Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getPortHierarchy(leankor.ProjectBoardCarousel.portfoliodata port) {
        if (String.isNotBlank(port.Id) && Util.getSObjectName(port.Id) != 'Leankor__Portfolio__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (
            !portfolioBehaviour.isAccessible() ||
            !projectRoomBehaviour.isAccessible() ||
            !projectLaunchBehavior.isAccessible() ||
            !valueStreamBehavior.isAccessible() 
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Set<ProjectBoardCarousel.PortfolioHierarchy> portfolioHierarchySet = new Set<ProjectBoardCarousel.PortfolioHierarchy>();
        Set<String> ganttProjectSet = new Set<String>();
        Map<String, String> valuestreamIds = new Map<String, String>();
        //get all parent level Leankor__Portfolio__c records
        List<Leankor__Portfolio__c> portfolioList = [SELECT Id,Name,Leankor__ParentPortfolio__c FROM Leankor__Portfolio__c where Leankor__ParentPortfolio__c =: port.Id ORDER BY Name ASC limit 49999];
        //get all Project rooms
        List<Leankor__ProjectRoom__c> roomList = new List<Leankor__ProjectRoom__c>();
        for(Leankor__ProjectRoom__c room:  [SELECT Id,
    											Name,
    											Leankor__Portfolio__c,
    											Leankor__ProjectManager__c,
    											Leankor__DueDate__c,
    											Leankor__ProjectManager__r.name 
				                            FROM Leankor__ProjectRoom__c 
				                            WHERE Leankor__IsTemplateProject__c = false AND 
				                            	Leankor__Portfolio__c =: port.Id
				                            ORDER BY Name ASC 
				                            limit 49999]){
            if(room.Leankor__Portfolio__c != null){
                roomList.add(room);
            }
        }                           

        //if there is no portfolio to display return empty set
        if(portfolioList.isEmpty() && roomList.isEmpty())
        {
            return portfolioHierarchySet;
        }
        
        //Keep a track of _System_UberBoard records
        for(leankor__ProjectLaunchBehavior__c b : [SELECT leankor__Project__c,leankor__Project__r.Name 
                                            FROM leankor__ProjectLaunchBehavior__c 
                                            WHERE leankor__Module__r.leankor__BoardType__c = '_System_UberBoard' AND leankor__Project__c IN: roomList]){
            ganttProjectSet.add(b.leankor__Project__c);
        }
        
        //get all project boards
        for(leankor__Valuestream__c vs :[SELECT Id, leankor__ProjectRoom__c 
        								FROM leankor__ValueStream__c 
                                        WHERE leankor__BoardType__c = 'UberBoard' 
                                            AND leankor__IsRecordDeleted__c = false 
                                            AND leankor__ProjectRoom__c IN: roomList 
        								LIMIT 49999]){
           valuestreamIds.put(vs.leankor__ProjectRoom__c, vs.Id);
        }                   
        //Go though the top level portfolio and add to the hierarchy

        portfolioHierarchySet.addAll(addChildNodes(port.Id, portfolioList, roomList,ganttProjectSet,valuestreamIds));
                        
        return portfolioHierarchySet;
    }


    public static Set<ProjectBoardCarousel.PortfolioHierarchy> addChildNodes(Id parentId, List<leankor__Portfolio__c> portfolioList, List<leankor__ProjectRoom__c> roomList,Set<String> ganttProjectSet,Map<String, String> valuestreamIds){
        Set<ProjectBoardCarousel.PortfolioHierarchy> portfolioHierarchySet = new Set<ProjectBoardCarousel.PortfolioHierarchy>();
        //Add projects to the top level portfolio
        portfolioHierarchySet.addAll(addProjects(parentId, roomList,ganttProjectSet,valuestreamIds));
        //Iterate child portfolio and add to the hierarchy
        for(leankor__Portfolio__c p : portfolioList) {

            if(p.leankor__ParentPortfolio__c == parentId) {
                ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchy = new ProjectBoardCarousel.PortfolioHierarchy();
                portfolioHierarchy.Id = p.Id;
                portfolioHierarchy.Name = p.Name ;
                portfolioHierarchy.RoomType = 'Portfolio'; 
                portfolioHierarchy.ParentPortfolio = p.leankor__ParentPortfolio__c; 
                portfolioHierarchy.ChildRecords = new Set<ProjectBoardCarousel.PortfolioHierarchy>();
                
                portfolioHierarchySet.add(portfolioHierarchy);
            } 
        }   
        return portfolioHierarchySet;
    }


    public static Set<ProjectBoardCarousel.PortfolioHierarchy> addProjects(Id parentId, List<leankor__ProjectRoom__c> roomList,Set<String> ganttProjectSet,Map<String, String> valuestreamIds){
        Set<ProjectBoardCarousel.PortfolioHierarchy> portfolioHierarchySet = new Set<ProjectBoardCarousel.PortfolioHierarchy>();

        //Iterate all projects and add to the hierarchy
        for(leankor__ProjectRoom__c r : roomList) {

        	//Date 08/05/19 check valueStream id in valuestreamIds  map . 
            if(r.leankor__Portfolio__c == parentId && ganttProjectSet.contains(r.Id) &&  valuestreamIds.containsKey(r.Id)) {
                ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchy = new ProjectBoardCarousel.PortfolioHierarchy();
                portfolioHierarchy.Id = r.Id;
                portfolioHierarchy.Name = r.Name ;
                portfolioHierarchy.RoomType = 'Room';
                portfolioHierarchy.leaf = true;
                portfolioHierarchy.ParentPortfolio = r.leankor__Portfolio__c; 
                portfolioHierarchy.BoardId = valuestreamIds.get(r.Id);                  
                portfolioHierarchySet.add(portfolioHierarchy);
            }
        }
        return portfolioHierarchySet;
    } 


    /*
    method : getPlanGanttCards
    class : GanttTaskBoard
    Input Parameter : List of selected project boards(PlanGantt) Ids.
    Return :inner class(GanttResourcesScheduler) object.
    */      
    public static set<String> Dependentvaluestream; 
    @RemoteAction @ReadOnly
    global static GanttResourcesScheduler getPlanGanttCards(List<String> boardIds) {  
        for(String boardId : boardIds){
            if (String.isNotBlank(boardId) && Util.getSObjectName(boardId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        } 
        //Check CRUD / FLC behavior
        RecordTypeBehaviour recordTypeBehaviour = new RecordTypeBehaviour();
        KanbanCardBehaviour KanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !recordTypeBehaviour.isAccessible() || 
            !KanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
 
        List<leankor.KanbanToGanttController.MasterContainer> activityList = new List<leankor.KanbanToGanttController.MasterContainer>();    
        GanttResourcesScheduler finalProjectDepResult = new GanttResourcesScheduler();
        Set<String> valuestreamIDs = new Set<String>(boardIds);

        if(valuestreamIDs.size() == 0 || valuestreamIDs.contains(null)){ 
            return new GanttResourcesScheduler();
        }      
         
        List<leankor__KanbanCard__c> listofcards = getPlanBoardKanbanCards('',valuestreamIDs);
        Map<String, List<leankor__Kanbancard__c>> mapOfListCards = createMapOfListCards(listofcards);
        
        //If Fsl is enabled then get FSL data count for cards(activity)         
        Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>(valuestreamIDs),'Valuestream');
        //mapping recordtype with recordtypeId
        Map<Id,RecordType> recordtypes = new Map <Id,RecordType>(
                                                                [SELECT 
                                                                        Id, 
                                                                        Name, 
                                                                        SobjectType 
                                                                    FROM RecordType 
                                                                    WHERE SobjectType = 'leankor__KanbanCard__c' 
                                                                    LIMIT 49999]
                                                            );        
        Set<String> ActivityId = new Set<String>();
        List<string> userIds = new List<string>();
        GanttResourcesScheduler result;
        List <leankor.KanbanToGanttController.MasterContainer> MClist;
        leankor.KanbanToGanttController.MasterContainer  MClistParent;           
        Datetime MaxTempDate,MinTempDate;
        Boolean flag = true;
        //RS 13/03/2019 To reduce loop in UI code sending isAck of project 
        Boolean isAck; 
        Boolean hasEditAccess;
        
        if(listofcards.isEmpty()){
            MaxTempDate = system.now();
            MinTempDate = system.now();
        }
		/*SS 12.01.2019*/
        // If there are card/Activity exist on the board then grab the min and max date. 
		else {
         	// Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
            AggregateResult ag = [SELECT 
                                        MIN(leankor__StartDateTime__c) MinDate, 
                                        MAX(leankor__DueDateTime__c) MaxDate 
                                    FROM leankor__KanbanCard__c 
                                    WHERE leankor__ValueStream__c IN : valuestreamIDs 
                                        AND leankor__isRecordDeleted__c = false 
                                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false];
                                        //AND leankor__ValueStream__c != Null]; //Non-selective query (!=, Null)
            MinTempDate = (DateTime)ag.get('MinDate');
            MaxTempDate = (DateTime)ag.get('MaxDate');
        }
        try{  
            //Date : 09/05/19 get valustream data from without sharing class.
            List<leankor__ValueStream__c> ValueStreams = RealTimeControllerHelper.readPlanBoard(valuestreamIDs);

          	List<String> vsIds=new List<String>();
            vsIds.addAll(valuestreamIDs);
          	//Date : 09/05/19 check security of valuestream.
           	Map <String, UserRecordAccess> recordAccessMap =  ProjectBoardCarousel.readRecordSecurity(vsIds);

            //Now we are only passing single VS id to this method, not all board's data is retriving in one transcation on PDG
            //This loop iterate over single valuestreamId

            //Non-selective SOQL for loop (!=, Null)
			/*for(leankor__ValueStream__c v : [Select 
                    Id,
                    leankor__Isrecalculate__c,
                    leankor__ProjectRoom__c,
                    leankor__ProjectRoom__r.name,
                    leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c,
                    leankor__SevenDayWorkWeek__c ,
                    UserRecordAccess.HasEditAccess 
                From leankor__ValueStream__c 
                Where ID In : ValuestreamIDs 
                    And leankor__Boardtype__c = 'UberBoard' 
                    And leankor__ProjectRoom__c != Null 
                    And leankor__IsTemplateBoard__c = false]){*/
            for(leankor__ValueStream__c v : ValueStreams){                                  
                MClist = new List < leankor.KanbanToGanttController.MasterContainer>();
                MClistParent =  new leankor.KanbanToGanttController.MasterContainer();                        
                
                //RS 13/03/2019 To reduce loop in UI code sending isAck of project 
                isAck = v.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c;
                
                for (leankor__KanbanCard__c knbnCard: listofcards){    
                    if(knbnCard.leankor__Valuestream__c == v.Id){
                        userIds.add(KnbnCard.OwnerID);
                        //RS 30/07/2018 Linking Card to Gantt's Milestone
                        //if (knbnCard.RecordType.Name == 'ActivityCard'){
                            ActivityId.add(knbnCard.id);                
                        //}                                                         
                        if(knbnCard.leankor__ValueStreamCardLink__c == null){                  
                            leankor.KanbanToGanttController.MasterContainer KC = new leankor.KanbanToGanttController.MasterContainer();
                            KC.Id = knbnCard.Id;
                            KC.Name = knbnCard.Name;                            
                            KC.Title = knbnCard.leankor__Title__c;     
                            KC.ValueStreamID = knbnCard.leankor__ValueStream__c;           
                            KC.GUID = knbnCard.leankor__GUID__c;
                            KC.Order = knbnCard.leankor__Order__c;
                            KC.StartDate = JSON.Serialize(knbnCard.leankor__StartDateTime__c);
                            KC.DueDate = JSON.Serialize(knbnCard.leankor__DueDateTime__c);
                            KC.PercentDone = KnbnCard.leankor__PercentComplete2__c;
                            KC.leaf = (knbnCard.RecordType.Name == 'FolderCard' ? false : true);
                            KC.EstimatedDuration = KnbnCard.leankor__EstimatedDuration__c;
                            KC.DurationUnits = KnbnCard.leankor__DurationUnits__c == 'Days' ? 'd' :(KnbnCard.leankor__DurationUnits__c == 'Weeks' ? 'w' : (KnbnCard.leankor__DurationUnits__c == 'Hours' ? 'h': (KnbnCard.leankor__DurationUnits__c == 'Months' ? 'mo' : (KnbnCard.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
                            KC.CardID = knbnCard.leankor__CardID__c;                                                           
                            KC.ForceID = (knbnCard.ID == null ? '' : knbnCard.ID);                  
                            KC.TemplateID = (KnbnCard.leankor__KanbanCardTemplate__c == null ? '' : KnbnCard.leankor__KanbanCardTemplate__c);
                            KC.TemplateName = KnbnCard.leankor__KanbanCardTemplate__r.Name;                    
                            KC.HarveyBall = string.valueOf(KnbnCard.leankor__PercentComplete2__c);           
                            KC.Description = KnbnCard.leankor__DescriptionLong__c;
                            KC.ValueStreamCardLink = (KnbnCard.leankor__ValueStreamCardLink__c == null ? '' : KnbnCard.leankor__ValueStreamCardLink__c);
                            KC.ValueStreamLinkID = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__c);
                            KC.ValueStreamCardLinkName = (KnbnCard.leankor__ValueStreamCardLink__c == null ? '' : KnbnCard.leankor__ValueStreamCardLink__r.Name);
                            KC.ValueStreamLinkIDName = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__r.Name);
                            KC.ValueStreamLinkBoardType = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);          
                            KC.ValueStreamID = KnbnCard.leankor__ValueStream__c;                   
                            KC.OwnerID = KnbnCard.OwnerID;                  
                            KC.KanbanUrl = '';                  
                            KC.BoardType = KnbnCard.leankor__ValueStream__r.leankor__Boardtype__c;                    
                            KC.OnBudget = KnbnCard.leankor__OnBudget__c;
                            KC.OnQuality = KnbnCard.leankor__OnQuality__c;
                            KC.OnTime = KnbnCard.leankor__OnTime__c;
                            KC.OwnerName = KnbnCard.Owner.Name;
                            KC.ProjectRoomID= KnbnCard.leankor__Valuestream__r.leankor__ProjectRoom__c;
                            KC.Priority=Integer.valueOf(KnbnCard.leankor__Priority__c);
                            //With CustomField lazy load we dont need to provide these values on Load
                            //KC.JSONDefinition = KnbnCard.leankor__JSONDefinition__c;
                            //KC.JSONData = KnbnCard.leankor__JSONData__c;
                            // Date: 27/05/2019
                            KC.isAtRisk = KnbnCard.leankor__IsAtRisk__c;
                            KC.isOnHold = KnbnCard.leankor__IsOnHold__c;
                                // Date: 22/05/2019
                                KC.timeToProjectLaunch = (String.isNotBlank(String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c))) ? String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c.intValue()): '';
                    
                            for (leankor__ScheduleMode__c schedulemodes: KnbnCard.leankor__ScheduleModes__r) {
                                KC.ManuallyScheduled = schedulemodes.leankor__ManuallyScheduled__c; 
                                KC.SchedulingMode = schedulemodes.leankor__Mode__c; 
                                KC.EffortUnit = schedulemodes.leankor__EffortUnits__c;
                                KC.Effort = schedulemodes.leankor__EffortActual__c;
                                KC.SchedulingModeId = schedulemodes.Id;
                               //Changes added for Readonly field was not showing PDG. 
								//KC.ReadOnly = schedulemodes.leankor__ReadOnly__c; 
                                
                                //Changes : Check constraint custom setting is enable or not.
                                if( realTimeController.ALLOW_SCHEDULING_CONSTRAINTS ){
                                    KC.ConstraintDate = schedulemodes.leankor__ConstraintDateTime__c;
                                    KC.ConstraintType = schedulemodes.leankor__ScheduleConstraint__r.leankor__Type__c;
                                }
                            }
                            KC.ItemType = knbnCard.RecordType.Name;
                            if (KC.ItemType == 'MilestoneCard' && KC.EstimatedDuration != 0) {
                                KC.ItemType = 'ActivityCard';
                                ActivityId.add(knbnCard.id);
                            }                           
                            KC.children = (knbnCard.RecordType.Name == 'FolderCard' ? childcardsRecursive(knbnCard.Id, mapOfListCards, recordtypes, fslDataInfo) : new List<leankor.KanbanToGanttController.MasterContainer>());
                            KC.IsRecalculate = v.leankor__Isrecalculate__c;
                            KC.IsExternallyDependent = KnbnCard.leankor__IsExternallyDependent__c;
                            KC.IsSuccessorRecalculate = KnbnCard.leankor__IsSuccessorRecalculate__c;
                            //RS 16/11/2018 Added for relaxing rules 
                            KC.isDependencyAckRecalculate = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c;
                            //Add FSL data count details with Activity data
                            KC.workOrderCount = fslDataInfo.containsKey(KnbnCard.Id) ? fslDataInfo.get(KnbnCard.Id).workOrderCount : 0;
                            KC.serviceAppointmentCount = fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).serviceAppointmentCount!=null ? fslDataInfo.get(KnbnCard.Id).serviceAppointmentCount   : null ) : 0;
                            KC.fslSchedStartDateTime = fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).fslSchedStartDateTime!=null ? fslDataInfo.get(KnbnCard.Id).fslSchedStartDateTime : null  ) : null;
                            KC.fslSchedDueDateTime =  fslDataInfo.containsKey(KnbnCard.Id) ? ( fslDataInfo.get(KnbnCard.Id).fslSchedDueDateTime!=null ? fslDataInfo.get(KnbnCard.Id).fslSchedDueDateTime: null ): null;
                            KC.HarveyBallDoneDate = KnbnCard.leankor__HarveyBallDoneDate__c;
                            KC.PromiseCompletionDate = KnbnCard.leankor__PromiseCompletionDate__c; 
                            //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                            	KC.isConstraintRecalculate = KnbnCard.leankor__IsConstraintRecalculate__c;
                            }

                            //Pratiksha : 18/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                            if(knbnCard.leankor__Monday__c == false && knbnCard.leankor__Tuesday__c == false && knbnCard.leankor__Wednesday__c == false &&  knbnCard.leankor__Thursday__c == false &&  knbnCard.leankor__Friday__c == false &&  knbnCard.leankor__Saturday__c == false &&  knbnCard.leankor__Sunday__c == false){
                                KC.Monday = true;
                                KC.Tuesday = true;
                                KC.Wednesday = true;
                                KC.Thursday = true;
                                KC.Friday = true;
                                KC.Saturday = true;
                                KC.Sunday = true;
                            }else{
                                //Pratiksha : 10/Oct/2023 : Passing these week day onLoad on PDG.
                                KC.Monday = knbnCard.leankor__Monday__c;
                                KC.Tuesday  = knbnCard.leankor__Tuesday__c;
                                KC.Wednesday = knbnCard.leankor__Wednesday__c;
                                KC.Thursday = knbnCard.leankor__Thursday__c;
                                KC.Friday = knbnCard.leankor__Friday__c;
                                KC.Saturday = knbnCard.leankor__Saturday__c;
                                KC.Sunday = knbnCard.leankor__Sunday__c;
                                KC.weekCalendar = knbnCard.leankor__WeekCalendar__c;
                                KC.isShowWeekCalendar = v.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                            }
                            KC.SevenDayWorkWeek = v.leankor__SevenDayWorkWeek__c;
                            MClist.add(KC);                     
                        }
                    }
                
                }  // end for
                
                MClistParent.Name = v.leankor__ProjectRoom__r.name;
                MClistParent.Id= v.Id;
                MClistParent.ProjectRoomID = v.leankor__ProjectRoom__c;            
                //Pratiksha : 07/03/2022 : Changes to add the StartDate and DueDate in ValueStream in both case costraint enable and disable.
                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                MClistParent.DueDate = JSON.Serialize(v.leankor__ProjectBoardEndDateTime__c);
                MClistParent.StartDate = JSON.Serialize(v.leankor__ProjectBoardStartDateTime__c);
                }else{
                    // Changes for Project startDate and dueDate showing current date at PDG when activities and milestone are not available
                    MClistParent.DueDate = JSON.Serialize(MaxTempDate);
                    MClistParent.StartDate = JSON.Serialize(MinTempDate);
                }        
                
                MClistParent.ScheduleBackwards = v.leankor__ScheduleBackward__c; 
                   
                MClistParent.ItemType = 'Board';
                MClistParent.children = MClist;
                MClistParent.Status = '';
                MClistParent.SevenDayWorkWeek = v.leankor__SevenDayWorkWeek__c;                                                                                    
                MClistParent.IsRecalculate = v.leankor__Isrecalculate__c;                                                                                    
                // Date: 22/05/2019
                MClistParent.timeToProjectLaunch =  JSON.serialize(v.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c);
                                                                                                    
                //RS 16/11/2018 Added for relaxing rules 
                MClistParent.isDependencyAckRecalculate = v.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c;                                                                                    
                                                                                            
               //Date: 09/05/19 
                hasEditAccess=recordAccessMap.get(v.id).HasEditAccess;                                                                                 
                //Date :12/11/19
                MClistParent.isScheduleRecalculate = v.IsScheduleRecalculate__c!= null? v.IsScheduleRecalculate__c:false;  
                MClistParent.isShowWeekCalendar = v.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c; 
                activityList.add(MClistParent);                                                                                 
                flag = true;                                                    
            }
            finalProjectDepResult.Activity = activityList;
            //getting miniatures for selected and dependent projects
            
            //SS 22.10.2018
            //Added IsSuccessorRecalculate field in query
            //Non-selective query (!=, Null)
            /*List<leankor__KanbanCard__c> listofminiature = [
                Select Id, 
                    Name, 
                    OwnerId,
                    leankor__PercentComplete2__c,  
                    leankor__ValueStreamCardLink__c, 
                    leankor__EstimatedDuration__C, 
                    leankor__StartDateTime__c, 
                    leankor__DueDateTime__c, 
                    leankor__ValueStream__c, 
                    leankor__Projectroom__c, 
                    leankor__IsSuccessorRecalculate__c,
                    leankor__ValueStream__r.Name, 
                    leankor__ValueStream__r.leankor__BoardType__c,                   
                    leankor__DurationUnits__c,                                                                                     
                    leankor__ValueStream__r.leankor__SevenDayWorkWeek__c
                From leankor__KanbanCard__c 
                Where leankor__ValueStreamCardLink__c In: ActivityId 
                    And leankor__ValueStream__c != Null 
                    And leankor__BoardType__c !='UberBoard' 
                    And leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                    And leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                    And leankor__ProjectRoom__c != Null 
                Limit 50000];
            finalProjectDepResult.Miniature = getMiniatureData(listofminiature); */
            
            // Tilak Raj Mahale:08.06.2020 - We are no longer considering the project for template condition from now on only valueStreams
            //finalProjectDepResult.Miniature = getMiniatureData(RealTimeControllerHelper.getMiniatureCards(ActivityId, false));  
            finalProjectDepResult.Miniature = getMiniatureData(leankor.RealTimeControllerHelper.getMiniatureCards(activityId));
            
            finalProjectDepResult.UserRecords = getUserData(userIds);
            finalProjectDepResult.ResourceAssignmentData = getResources(ActivityId);               
            
            //getting business hour data and storing into datalog
            leankor.GanttTaskBoard.OnloadData loaddata = new leankor.GanttTaskBoard.OnloadData();           
            loaddata.defaultResourceHours = leankor.ResourceGanttController.getBusinessHourData();           
            finalProjectDepResult.DataLog = loaddata;
            
            //getting working hours per day from lean constant
            Integer hours = leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c == null ? 0 :Integer.valueof(leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c);        
            finalProjectDepResult.WorkingHoursPerDay = (hours <= 0 ? 8 :(hours > 24 ? 24 :hours)); 
                                                 
            //RS 13/03/2019 To reduce loop in UI code sending isAck of project  
            finalProjectDepResult.isDependencyAckRecalculate = isAck ; 
            //Date :26/04/19
            finalProjectDepResult.hasEditAccess = hasEditAccess;
            finalProjectDepResult.projectLaunchDate = ValueStreams[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c!=null ? JSON.serialize(ValueStreams[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c.date()+''):'';
        }catch (Exception e){           
            System.debug('++++ Exception -  Heap Size+++++ ' + Limits.getHeapSize());
            System.debug('ERROR: ' + e);
            //return new GanttResourcesScheduler();
            throw new LeanException('Exception Error: ' + e.getMessage());
        }
        if(finalProjectDepResult.Activity.size()==0){
            throw new LeanException('Associated Project is either removed or has become Template');
            //return null;        
        }                                   
        return finalProjectDepResult;      
    }   

	/***
     * Company : Leankor
     * Description : This Method used get Filter records for multiple boards.
     * Input :  List of CreateFilter "List<CreateFilter>" inner class Object.
     * Output : List of created/updated Filter record if form of list of CreateFilter "List<CreateFilter>" inner class Object.
    */
    @RemoteAction
    global static Map<Id, FilterRecordForMUltipleBoard> getFilterRecordForMUltipleBoard(String boardId, Boolean isAllFilterDataRequired){
        if (String.isNotBlank(boardId) && Util.getSObjectName(boardId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        Map<Id, FilterRecordForMUltipleBoard> filterRecordForMUltipleBoardMap = new Map<Id, FilterRecordForMUltipleBoard>();
        Map<Id, leankor__ValueStream__c> valueStreamMap = new Map<Id, leankor__ValueStream__c>([Select Id, Name From leankor__ValueStream__c Where Id = : boardId Limit 50000]);
        
        FilterRecordForMUltipleBoard filterRecordForMUltipleBoard = new FilterRecordForMUltipleBoard();
        if( isAllFilterDataRequired == true )
        {
            filterRecordForMUltipleBoard.Filters = KanbanController.getFilterRecords(boardId);
            filterRecordForMUltipleBoard.FilterUserRecords = KanbanController.getFilteredUsers(boardId);
            filterRecordForMUltipleBoard.KanbanCardTemplates = RealtimeController.getKanbanCardTemplates(boardId);
            filterRecordForMUltipleBoard.Name = valueStreamMap.get(boardId).Name;
            filterRecordForMUltipleBoard.AllStickers = RealtimeController.getAllStickers(boardId);
            filterRecordForMUltipleBoardMap.put(boardId, filterRecordForMUltipleBoard);
        }else
        {
            filterRecordForMUltipleBoard.Filters = KanbanController.getFilterRecords(boardId);
            filterRecordForMUltipleBoardMap.put(boardId, filterRecordForMUltipleBoard);   
        }
        return filterRecordForMUltipleBoardMap;
    }
  
    global class FilterRecordForMUltipleBoard {
        public List<KanbanController.CreateFilter> Filters;
        public List <User> FilterUserRecords;
        public List<leankor__KanbanCardTemplate__c> KanbanCardTemplates;
        public String Name;
        public List<leankor__Sticker__c> AllStickers;
   }




    // get valuestream ids from dependent boards by list of dependency records
   /* public static Set<String> getValuestreambyDependency(Set<String> ValuestreamIDs,List<leankor__Dependency__c> filterDependency){
        
        Set<String> ValuestreamIDs1 = new Set<String>();
        for(leankor__Dependency__C d : filterDependency){                                                           
            if(ValuestreamIDs.contains(d.leankor__Predecessor__r.leankor__ValueStream__c) || ValuestreamIDs.contains(d.leankor__Successor__r.leankor__ValueStream__c)){                            
                if(d.leankor__Successor__r.leankor__ValueStream__c != null  && !ValuestreamIDs.contains(d.leankor__Successor__r.leankor__ValueStream__c)){
                    ValuestreamIDs1.add(d.leankor__Successor__r.leankor__ValueStream__c);
                }             
                if(d.leankor__Predecessor__r.leankor__ValueStream__c != null  && !ValuestreamIDs.contains(d.leankor__Predecessor__r.leankor__ValueStream__c)){
                    ValuestreamIDs1.add(d.leankor__Predecessor__r.leankor__ValueStream__c);
                }                        
            }               
        }           
        if(ValuestreamIDs1.size()>0){
            Dependentvaluestream.addall(ValuestreamIDs1);               
            getValuestreambyDependency(Dependentvaluestream,filterDependency);
        }                             
        return Dependentvaluestream;       
    }*/
    /* End of External Project Dependency*/
    
    /* Start of Baseline feature apex Methods 
    *  method : setBaseLineOnBoard
    *  class : GanttTaskBoard
    *  Input Parameter : List of project Ids.
    */ 
    
    global class Baseline
    {
        global String Title;
        global String ProjectBoardID;
        global String ProjectBaselineID;
        global string KanbanCardID;
        global DateTime BaselineStartDate;
        global DateTime BaselineEndDate;
        global String DurationUnit;
        global Decimal EstimatedDuration;
        global DateTime CreatedDate;        
        public Boolean isCriticalPath;
        public Decimal totalSlack;
        public Decimal sequence;
        public String WBSCode;

    }
    
    //firstly user set base with title
    @remoteaction
    global static List<Baseline> setBaseLineOnBoard(List<String> SomeJSONData) {
        //Check CRUD / FLC behavior 
        ProjectScheduleBaselineBehaviour ProjectScheduleBaselineBehaviour = new ProjectScheduleBaselineBehaviour();
        if (
            !ProjectScheduleBaselineBehaviour.isAccessible() ||
            !ProjectScheduleBaselineBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        list<leankor__ProjectScheduleBaseline__c> baselineList = new List<leankor__ProjectScheduleBaseline__c>();
        
        list<Baseline> result = new List<Baseline>();
        
        //UI send data for ProjectScheduleBaseline and inserting records.
        for(String js : SomeJSONData)
        {   
            //deserialize json string to our inner class object.
            leankor.GanttTaskBoard.Baseline BL = (leankor.GanttTaskBoard.Baseline)JSON.deserialize(js,leankor.GanttTaskBoard.Baseline.class); 
                        
            leankor__ProjectScheduleBaseline__c PSB = new leankor__ProjectScheduleBaseline__c();
            PSB.leankor__Title__c = BL.title;
            PSB.leankor__ProjectBoard__c = BL.ProjectBoardId;
            
            baselineList.add(PSB);  
        }
        
        // inserting Project schedule baseline records associate with project board ID.
        try{
            insert baselineList;
        }catch(Exception ex){           
            //return new List<Baseline>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        
        //after insertion records return data with baseline record id
        for(leankor__ProjectScheduleBaseline__c p : baselineList){
        
            Baseline ps = new Baseline();
            ps.title = p.leankor__Title__c;
            ps.ProjectBoardId = p.leankor__ProjectBoard__c;
            ps.ProjectBaselineID = p.Id;
            result.add(ps);
        }
        return result;
    }
    

    @AuraEnabled
    public static List<leankor__ProjectScheduleBaseline__c> setBaseLineOnBoard( List<leankor__ProjectScheduleBaseline__c> baselineList){
               System.debug('baselineList: ' + baselineList);

        ProjectScheduleBaselineBehaviour ProjectScheduleBaselineBehaviour = new ProjectScheduleBaselineBehaviour();
        if (
            !ProjectScheduleBaselineBehaviour.isAccessible() ||
            !ProjectScheduleBaselineBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
          try{
            insert baselineList;
        }catch(Exception ex){           
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return baselineList;
    }

    @AuraEnabled
    public static string setBaseLineOnActivity(List<leankor__KanbanCardBaseline__c> kanbanCardBaselineList){
        System.debug('kanbanCardBaselineList: ' + kanbanCardBaselineList);

        KanbanCardBaselineBehaviour kanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();
       if (
            !kanbanCardBaselineBehaviour.isAccessible() ||
            !kanbanCardBaselineBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
         try {
            insert kanbanCardBaselineList;
        } catch(Exception ex) {           
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return 'success';
    }

     // set baseline in all activity in valuestream board (uberBoard)
    @remoteaction
    global static String setBaseLineOnActivity(List<String> SomeJSONData){
        //Check CRUD / FLC behavior 
        KanbanCardBaselineBehaviour KanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();
        if (
            !KanbanCardBaselineBehaviour.isAccessible() ||
            !KanbanCardBaselineBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
 
        List<leankor__KanbanCardBaseline__c> KanbanCardBaselineList = new List<leankor__KanbanCardBaseline__c>();
        
        List<Baseline> result = new List<Baseline>();
        
        //UI send data for KanbanCardBaseline and inserting records.
        for(String js : SomeJSONData) {   
            //deserialize json string to our inner class object.
            leankor.GanttTaskBoard.Baseline BL = (leankor.GanttTaskBoard.Baseline)JSON.deserialize(js,leankor.GanttTaskBoard.Baseline.class); 
                        
            leankor__KanbanCardBaseline__c KCB = new leankor__KanbanCardBaseline__c();
            
            KCB.leankor__ProjectScheduleBaseline__c = BL.ProjectBaselineID;
            KCB.leankor__KanbanCard__c = BL.KanbanCardID;
            KCB.leankor__StartDateTime__c = BL.BaselineStartDate;
            KCB.leankor__DueDateTime__c = BL.BaselineEndDate;
            KCB.leankor__DurationUnit__c = BL.DurationUnit;
            KCB.leankor__EstimatedDuration__c = BL.EstimatedDuration;
            KCB.leankor__IsCriticalPath__c = BL.isCriticalPath;
            KCB.leankor__TotalSLack__c = BL.totalSlack;
            KCB.leankor__Sequence__c = BL.sequence;
            KCB.leankor__WBSCode__c = BL.WBSCode; 
            KanbanCardBaselineList.add(KCB);    
        }
        
        //inserting kanban card base line records associate with kanban card ID and ProjectScheduleBaseline ID.
        try{
            insert KanbanCardBaselineList;
        }catch(Exception ex){           
            //return 'failed';
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        
        return 'success';
    }  

     
    // getting history of set baseline according to valuestream Ids. 
    
    @remoteaction
    global static List<Baseline> getBaseLineHistory(List<String> valuestreamIds) {
        for(String valuestreamId : valuestreamIds){
            if (String.isNotBlank(valuestreamId) && Util.getSObjectName(valuestreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        ProjectScheduleBaselineBehaviour ProjectScheduleBaselineBehaviour = new ProjectScheduleBaselineBehaviour();
        if (!ProjectScheduleBaselineBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<Baseline> result = new List<Baseline>();
        
        try
        {   
            for(leankor__ProjectScheduleBaseline__c p : [SELECT Id, 
                                                                leankor__ProjectBoard__c, 
                                                                leankor__Title__c, 
                                                                CreatedDate 
                                                            FROM leankor__ProjectScheduleBaseline__c 
                                                            WHERE leankor__ProjectBoard__c IN: valuestreamIds
                                                            ORDER BY CreatedDate ASC 
                                                            LIMIT 49999]){ 
                Baseline bl = new Baseline();
                bl.Title = p.leankor__Title__c;
                bl.ProjectBoardID = p.leankor__ProjectBoard__c;
                bl.ProjectBaselineID = p.Id;
                bl.CreatedDate = p.CreatedDate;
                
                result.add(bl);
            }           
        }catch(Exception ex){           
            //return new List<Baseline>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return result;
    }


    @AuraEnabled
    public static List<leankor__ProjectScheduleBaseline__c> getBaseLineHistoryData(List<String> valuestreamIds) {
         for(String valuestreamId : valuestreamIds){
            if (String.isNotBlank(valuestreamId) && Util.getSObjectName(valuestreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        ProjectScheduleBaselineBehaviour ProjectScheduleBaselineBehaviour = new ProjectScheduleBaselineBehaviour();
        if (!ProjectScheduleBaselineBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        try
        {   
           
           List<leankor__ProjectScheduleBaseline__c> projectScheduleBaseLine = [Select Id, 
                                                                                        leankor__ProjectBoard__c, 
                                                                                        leankor__Title__c, 
                                                                                        CreatedDate 
                                                                                    From leankor__ProjectScheduleBaseline__c 
                                                                                    Where leankor__ProjectBoard__c IN: valuestreamIds
                                                                                    Order BY CreatedDate ASC 
                                                                                    Limit 49999];
            return projectScheduleBaseLine;
        } catch(Exception ex) {           
            //return new List<Baseline>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
     
       
    }
     

    //getting activity baseline records according to ProjectScheduleBaseline Ids means user select set baseline. 
    @remoteaction
    global static List<Baseline> getActivityBaselineRecords(List<String> ProjectScheduleBaselineIDs) {
        for(String ProjectScheduleBaselineID : ProjectScheduleBaselineIDs){
            if (String.isNotBlank(ProjectScheduleBaselineID) && Util.getSObjectName(ProjectScheduleBaselineID) != 'leankor__ProjectScheduleBaseline__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        KanbanCardBaselineBehaviour KanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();
        if (!KanbanCardBaselineBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior3

        List<Baseline> result = new List<Baseline>();
        
        try
        {
            for(leankor__KanbanCardBaseline__c k : [SELECT Id,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__DurationUnit__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__KanbanCard__c,
                                                        leankor__ProjectScheduleBaseline__c 
                                                    FROM leankor__KanbanCardBaseline__c 
                                                    WHERE leankor__ProjectScheduleBaseline__c IN: ProjectScheduleBaselineIDs 
                                                    LIMIT 49999]){ 
                
                Baseline bl = new Baseline();
                                                
                bl.ProjectBaselineID = k.leankor__ProjectScheduleBaseline__c;
                bl.KanbanCardID = k.leankor__KanbanCard__c;
                bl.BaselineStartDate = k.leankor__StartDateTime__c;
                bl.BaselineEndDate = k.leankor__DueDateTime__c;
                bl.DurationUnit = k.leankor__DurationUnit__c;
                bl.EstimatedDuration = k.leankor__EstimatedDuration__c;
                
                result.add(bl);
            }           
        }catch(Exception ex){           
            //return new List<Baseline>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return result;
    }
     

    @AuraEnabled
    public static List<leankor__KanbanCardBaseline__c> getActivityBaselineRecord(List<String> ProjectScheduleBaselineIDs){
        System.debug(ProjectScheduleBaselineIDs);
        KanbanCardBaselineBehaviour kanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();
        if (!kanbanCardBaselineBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        try {
            List<leankor__KanbanCardBaseline__c> kanbanCardBaseLine =  [Select  Id,
                                                                                    leankor__StartDateTime__c,
                                                                                    leankor__DueDateTime__c,
                                                                                    leankor__DurationUnit__c,
                                                                                    leankor__EstimatedDuration__c,
                                                                                    leankor__KanbanCard__c,
                                                                                    leankor__ProjectScheduleBaseline__c 
                                                                                From leankor__KanbanCardBaseline__c 
                                                                                Where leankor__ProjectScheduleBaseline__c IN: ProjectScheduleBaselineIDs 
                                                                                Limit 49999];
                                                                                System.debug(kanbanCardBaseLine);
            return kanbanCardBaseLine;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //deleting activity baseline record when we delete activty.
    @remoteaction
    global static String deleteActivityBaseline(List<String> activityIds) {
        for(String activityId : activityIds){
            if (String.isNotBlank(activityId) && Util.getSObjectName(activityId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        KanbanCardBaselineBehaviour KanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();
        if (
            !KanbanCardBaselineBehaviour.isAccessible() ||
            !KanbanCardBaselineBehaviour.isUpdateable()   
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior3

        try {
            List<leankor__KanbanCardBaseline__c> kanbanCardbaseLineList = [Select Id,
                                                                                    leankor__KanbanCard__c,
                                                                                    leankor__ProjectScheduleBaseline__c
                                                                                From leankor__KanbanCardBaseline__c
                                                                                Where leankor__KanbanCard__c In :activityIds
                                                                                Limit 10000];

            for (leankor__KanbanCardBaseline__c kanbanCardbaseLine : kanbanCardbaseLineList) {
                kanbanCardbaseLine.leankor__KanbanCard__c = null;
                kanbanCardbaseLine.leankor__ProjectScheduleBaseline__c = null;
            }       
            if (!kanbanCardbaseLineList.isEmpty()) {
                update kanbanCardbaseLineList;
            }      
        }catch(Exception ex){           
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return 'success';
    }
        

    //RS 13/07/2018 changed its return from string to list<leankor__ResourceAssignment__c>
    public static List<leankor__ResourceAssignment__c> updateMultipleRA(List<String> cardsId, String OwnerId) { 
        //Check CRUD / FLC behavior 
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();      
        if (
            !resourceAssignmentBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        List<leankor__ResourceAssignment__c> result = new List<leankor__ResourceAssignment__c>();                

        Set<Id> resourceIds = new Set<Id>();
        resourceIds.add(OwnerId);
    
        // gets the latest resource record of each user 
        Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds);  

        List<leankor__ResourceAssignment__c> ResourceLogs =
                                                        [SELECT 
                                                                Id,
                                                                leankor__AssignedTo__c,
                                                                leankor__KanbanCard__c 
                                                            FROM leankor__ResourceAssignment__c 
                                                            WHERE leankor__KanbanCard__c IN: cardsId 
                                                            LIMIT 10000
                                                        ];
        
        for (leankor__ResourceAssignment__c RAdata : ResourceLogs) {
            leankor__ResourceAssignment__c baseResource = new leankor__ResourceAssignment__c();            
            baseResource.Id = RAdata.Id;
            baseResource.leankor__AssignedTo__c = OwnerId;                         
            baseResource.leankor__KanbanCard__c = RAdata.leankor__KanbanCard__c;

            baseResource = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(OwnerId, resourceTypes, baseResource, true) : Resource.setResourceAccounts(OwnerId, resourceTypes, baseResource);
            				                                                                                               
            result.add(baseResource); 
        }
        
        return result;      
    }
    
    /***
    * method : getCustomerLogo
    * return : document object (customer logo)
    * description :  get customer logo from document object and convert as required format and pass to UI
    * Note : we can't pass directly body because getting  "Remoting Exception: Error parsing json respons"  
    */
    @RemoteAction
    global static Document getCustomerLogo(){   
        List<Document> customerlogo =  [SELECT body,
                                                ContentType,
                                                Name,
                                                Type 
                                            FROM Document 
                                            WHERE DeveloperName = 'PlanGanttPrintLogo' 
                                                AND Folder.DeveloperName = 'VisualLean_CoreDocs' 
                                            LIMIT 1];       
        Document logo = new Document();         
        if(customerlogo.size()>0){
            try{    
                logo.Name = customerlogo[0].Name;
                logo.type =  customerlogo[0].Type;
                logo.ContentType = customerlogo[0].ContentType;
                logo.Description = EncodingUtil.Base64Encode(customerlogo[0].body);
            }catch(Exception ex){
                //return new Document();
                //25/04/2023 : We are Throwing Exception
                throw new Util.LeanException('ERROR:' + ex.getMessage()); 
            }   
        }   
        return logo;           
    }
    
    /*------------------------------------------------------------
    Author:         Yash Jain
    Company:        Leankor
    Description:    Stickers
    Inputs:         List of ValueStream Ids
    Returns:        map of stickers according Kanban Ids
    ------------------------------------------------------------*/
    
    global class Sticker{
        
        global String Id;
        global List<leankor__Sticker__c> KanbanStickers;
        
        global Sticker(String Id, List<leankor__Sticker__c> KanbanStickers){
            this.Id = Id;
            this.KanbanStickers = KanbanStickers;
        } 
    }


    @ReadOnly
    @RemoteAction
    Global Static List<Sticker> getAllStickersByBoardIds(List<String> valueStreamIds) {   
        for(String valueStreamId : valueStreamIds){
            if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour(); 
        StickerBehavior stickerBehavior = new StickerBehavior(); 
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardStickerBehaviour.isAccessible() ||
            !stickerBehavior.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        Map<String,List<String>> mapKanbanSticker = new Map<String,List<String>>();
        List< String > KanbanIDs = new List <String> ();
        Set<String> stickerIDs = new Set<String>();
        
        //getting kanbanCard sticker according valuestreams
        for (leankor__KanbanCard__C k: [SELECT Id, 
	        								Name, 
	        								(SELECT leankor__Sticker__c, leankor__KanbanCard__c FROM leankor__KanbanCard__c.leankor__KanbanCardStickers__r KanbanCardStickers)
	        							FROM leankor__KanbanCard__C 
	        							WHERE leankor__ValueStream__c IN : valueStreamIds 
                                            AND leankor__IsRecordDeleted__c = false 
                                            AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
	        							LIMIT 9999]) {
            if(k.leankor__KanbanCardStickers__r != null && k.leankor__KanbanCardStickers__r.size() > 0){
                KanbanIDs.add(k.Id);
            }
            List<String> kStickers = new List<String>();
            for (leankor__KanbanCardSticker__c kcs: k.leankor__KanbanCardStickers__r) {
                kStickers.add(kcs.leankor__Sticker__C);
                stickerIDs.addAll(kStickers);
            }
            mapKanbanSticker.put(k.Id, kStickers);
        }
        
        //getting Attachment        
        List<leankor__Sticker__c> TempStickers = [SELECT Id, Name, (SELECT Id, ContentType FROM Attachments WHERE ParentID IN :stickerIDs) FROM leankor__Sticker__c WHERE Id IN :stickerIDs LIMIT 9999];            
        Map<ID,Attachment> mapAttachment = new Map<ID,Attachment>([SELECT Id, Description FROM Attachment WHERE ParentID IN :TempStickers LIMIT 9999]);     
        
        for (leankor__Sticker__c skr: TempStickers){         
            
            for (Attachment att: skr.Attachments){               
                att.Description = ''; // Using Base64.          
            }
        }
        
        Map<ID,leankor__Sticker__c > mapSticker = new Map<ID,leankor__Sticker__c > ();
        mapSticker.putAll(TempStickers);   
       
        List<Sticker> finalStickerMap = new List<Sticker>(); 
        
        //making Map according Kanban Card Ids
        for (String kanbanID: KanbanIDs) {
            List<String> localStickers = mapKanbanSticker.get(kanbanID);
            List<leankor__Sticker__c> tempStickers1 = new List < leankor__Sticker__c > ();
            if (localStickers.Size() > 0) {
                for (String sid: localStickers) {
                    tempStickers1.add(mapSticker.get(sid));
                }
            }
            
            Sticker Stickerdata = new Sticker(kanbanID,tempStickers1);
            
            finalStickerMap.add(Stickerdata);
        }
        
        return finalStickerMap;
    }

    
    //YJ 15.11.2017
    public static List<leankor__KanbanCard__c> getPlanBoardKanbanCards(String BaseLineId , Set<String> ValuestreamIDs) {  
        //Check CRUD / FLC behavior     
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        DescribeSchema describeSchema = new DescribeSchema();
        List<leankor__KanbanCard__c> boardKanbanCards = new List<leankor__KanbanCard__c>();
        Set<String> allOtherFields = new Set<String>();
        
        String result = '';
        
        if(ValuestreamIDs.size() > 0  && ValuestreamIDs != null){
              String VSIDIdList = '';
  
              for(String t : ValuestreamIDs){
                  VSIDIdList =  VSIDIdList + '\''+ t + '\',';
              }
  
              //result = '(' + VSIDIdList.substring(0,VSIDIdList.length() - 1) + ')';
              result = VSIDIdList.lastIndexOf(',') > 0 ? '(' + VSIDIdList.substring(0,VSIDIdList.lastIndexOf(',')) + ')' : VSIDIdList ;
        } 
        
        
        
        //Yj 15.11.2017 added kanbanCardJSONUpdator instantiation
        KanbanCardJSONUpdator kanbanCardJSONUpdator = new KanbanCardJSONUpdator();  
        
        //Yj 15.11.2017
        try{
            Set<String> allFields = fieldMapKanbanCard.keyset();

            //Use allOtherFields because the allFields set is read-only
            allOtherFields.addAll(allFields);
            //SS 28.05.2017
            //----------adding Name of refrenceObject----------------
            //Add name of reference object for dynamic query
            Set<String> referenceFieldNames = describeSchema.getReferenceFieldName(fieldMapKanbanCard);
            allOtherFields.addAll(referenceFieldNames); 
            //SS 28.05.2017
            //Add all fields not obtained through the schema describe such as the dot
            //quantified fields.
            /*allOtherFields.add('KanbanCardTemplate__r.Name');
            allOtherFields.add('Owner.Name');
            allOtherFields.add('RecordType.Name');
            allOtherFields.add('CreatedBy.Name');
            allOtherFields.add('LastModifiedBy.Name');
            allOtherFields.add('ValueStreamCardLink__r.Name');
            allOtherFields.add('ValueStreamLink__r.Name');
            allOtherFields.add('ValueStream__r.Name');
            allOtherFields.add('Contact__r.Name');
            allOtherFields.add('Account__r.Name');
            allOtherFields.add('Opportunity__r.Name');
            allOtherFields.add('leankor__MasterContainer__r.Name'); // Added missing fields
            allOtherFields.add('leankor__Swimlane__r.Name');// Added missing fields
            allOtherFields.add('leankor__Zone__r.Name');// Added missing fields
            allOtherFields.add('Case__r.CaseNumber');
            */
            allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__Color__c');
            allOtherFields.add('leankor__Opportunity__r.StageName');
            allOtherFields.add('leankor__ValueStreamLink__r.leankor__BoardType__c');
            allOtherFields.add('leankor__ValueStream__r.leankor__Boardtype__c');
            allOtherFields.add('leankor__Case__r.Subject');
            allOtherFields.add('leankor__Case__r.Status');
            allOtherFields.add('leankor__Case__r.Priority');
            allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__FieldSetName__c');
            allOtherFields.add('leankor__Valuestream__r.leankor__Isrecalculate__c');
           //Changes : Check constraint setting enable or not.
            if( realTimeController.ALLOW_SCHEDULING_CONSTRAINTS == true ){
                allOtherFields.add('(SELECT Id, leankor__EffortActual__c, leankor__EffortUnits__c, leankor__ManuallyScheduled__c, leankor__Mode__c, Name, leankor__ConstraintDateTime__c, leankor__ScheduleConstraint__c, leankor__ScheduleConstraint__r.leankor__Type__c FROM leankor__ScheduleModes__r limit 1)');
            }else{
                allOtherFields.add('(SELECT Id, leankor__EffortActual__c, leankor__EffortUnits__c, leankor__ManuallyScheduled__c, leankor__Mode__c, Name FROM leankor__ScheduleModes__r limit 1)');
            }
            allOtherFields.add('leankor__Valuestream__r.leankor__ProjectRoom__c');
            //RS 16.11.2018 For relaxing rules  
            allOtherFields.add('leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c');
            if(!String.isEmpty(BaseLineId))
            {
                allOtherFields.add('(SELECT leankor__DueDateTime__c,leankor__StartDateTime__c FROM leankor__Kanban_Card_Baselines__r WHERE leankor__ProjectScheduleBaseline__c = ' + '\'' + BaseLineId + '\'' + ' limit 1)');
            }                             
                    
            if(String.isNotEmpty(result))
            {                             
                //RS 23/09/2019 Commented for Lazy Load - Custom Fields                         
                //boardKanbanCards = kanbanCardJSONUpdator.updateCardJSONData(kanbanCardJSONUpdator.updateCardJSONDefinitions(describeSchema.dynamicFieldQuery('leankor__KanbanCard__c', allOtherFields, 'WHERE leankor__ValueStream__c IN  ' +  result + ' AND leankor__KanbanCard__c.leankor__isRecordDeleted__c = false'), UIHeaderSettings, UIItemSettings, fieldMapKanbanCard), fieldMapKanbanCard, fieldSetMap);
                boardKanbanCards = describeSchema.dynamicFieldQuery('leankor__KanbanCard__c', allOtherFields, 'WHERE leankor__ValueStream__c IN  ' +  result + ' AND leankor__KanbanCard__c.leankor__isRecordDeleted__c = false');
            }                             
                    
        } catch (Exception e) {
            System.debug(e);
            boardKanbanCards = new List<leankor__KanbanCard__c>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage()); 
        }
        return boardKanbanCards;
    }
                 
    
    
     /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    realTimeController.KanbanCardData
    Inputs:         Set<String> cardIds
    Returns:        returns all external dependent cards from PG
    ------------------------------------------------------------*/
   /* public static realTimeController.KanbanCardData  readSuccessorCardsForRecalculate(Set<String> cardIds)
    {      
        realTimeController.KanbanCardData kanbanData = new realTimeController.KanbanCardData();
        try{
        List<leankor__KanbanCard__c> updateKanbanCards = new List<leankor__KanbanCard__c>();
            Set<String> tempDepIds = new Set<String>();
              //Call for reading all n level related ExternallyDependentCardids
              tempDepIds = RealTimeControllerHelper.readExternallyDependentCardsId(cardIds);
            for(String cardId :tempDepIds)
            {
                if(updateKanbanCards.size()<9900)
                {
                    leankor__KanbanCard__c knbnCard = new leankor__KanbanCard__c();
                    knbnCard.Id = cardId;
                knbnCard.leankor__IsSuccessorRecalculate__c = true;
                updateKanbanCards.add(knbnCard);
            }
                else{
                   throw new leankor.GanttTaskBoard.LeanException('Error : Too many Depedency records');
        }
            }
            
            kanbanData.cardList = updateKanbanCards;
            //assign all externally dependentCard's id to list
            kanbanData.externallyDependentCardIds=tempDepIds;
        }catch (Exception e){           
            System.debug('ERROR:' + e.getMessage());
            throw new leankor.GanttTaskBoard.LeanException('Error : '+e.getMessage());
        }
        return kanbanData;     
    }*/
    
    public static RealTimeControllerHelper.DependencyMap  readSuccessorDependencyForRecalculate(Set<String> cardIds)
    {      
        return RealTimeControllerHelper.readExternallyDependentCards(cardIds);
    }
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds
    Inputs:         Set<String> valueStreamIds
    Returns:        returns all external dependent valuestreamIds
    Date :          07.09.2018
    ------------------------------------------------------------*/
   /* public static Set<String> readDependentValueStreamsIds(Set<String> vsIDs){
        Set<String> valueStreamIDs;
        try{
            valueStreamIDs = new Set<String>(vsIDs);
            List<leankor__Dependency__c> filterDependency = new List<leankor__Dependency__c>();       
            //filtering dependency if predecessor and successor valuestream is different.               
            for(leankor__Dependency__c d:[SELECT leankor__Predecessor__r.leankor__ValueStream__c,
                                                             leankor__Successor__r.leankor__ValueStream__c 
                                                             FROM leankor__Dependency__c 
                                                             Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard' 
                                                                   and leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
                                                                   and leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
                                                                   and leankor__valuestream__r.leankor__isRecordDeleted__c = false
                                                                   limit 49999])
            {
                if(d.leankor__Predecessor__r.leankor__ValueStream__c != d.leankor__Successor__r.leankor__ValueStream__c)
                {
                    filterDependency.add(d);
                }
            }                  
            //calling getValuestreambyDependency method for getting dependent boards valuestream.
            Dependentvaluestream = new set<String>();
            valueStreamIDs.addAll(getValuestreambyDependency(ValuestreamIDs,filterDependency));    
            Dependentvaluestream.clear();
        }
        catch(Exception ex){
            System.debug('Error :'+ex);
            return new Set<String>();
        }
    return valueStreamIDs;
    } */        
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds
    Inputs:         Set<String> valueStreamIds
    Returns:        returns all external dependent valuestreamIds
    Date :          07.09.2018
    ------------------------------------------------------------*/
    /*public static Set<String> readSuccessorDependentValueStreamsIds(Set<String> vsIDs){
        Set<String> valueStreamIDs;
        try{
            valueStreamIDs = new Set<String>(vsIDs);
            List<leankor__Dependency__c> filterDependency = new List<leankor__Dependency__c>();       
            //filtering dependency if predecessor and successor valuestream is different.               
            for(leankor__Dependency__c d:[SELECT leankor__Predecessor__r.leankor__ValueStream__c,
                                                             leankor__Successor__r.leankor__ValueStream__c 
                                                             FROM leankor__Dependency__c 
                                                             Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard' 
                                                                   and leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
                                                                   and leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null ])
            {
                if(d.leankor__Predecessor__r.leankor__ValueStream__c != d.leankor__Successor__r.leankor__ValueStream__c)
                {
                    filterDependency.add(d);
                }
            }                  
            //calling getValuestreambyDependency method for getting dependent boards valuestream.
            Dependentvaluestream = new set<String>();
            valueStreamIDs.addAll(getValuestreambyDependency(ValuestreamIDs,filterDependency));    
            Dependentvaluestream.clear();
        }
        catch(Exception ex){
            System.debug('Error :'+ex);
            return new Set<String>();
        }
    return valueStreamIDs;
    }      */   
        
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds
    Inputs:         Set < String > boardIds
    Output:         Set < String >
    Returns:        returns all externally dependent valuestreamIds
    Date :          24.09.2018
    ------------------------------------------------------------*/
    public static Set < String > getExternallyDependentVSIds(Set < String > boardIds){
        GanttTaskBoard.Dependentvaluestream= new Set<String>();
        Set<String> dependentVSIds  = new Set<String> ();
        List < AggregateResult > externallyDependentValuestreams = readExternallyDependentValueStreams();
        dependentVSIds.addAll(getDependentValuestreamIds(boardIds, externallyDependentValuestreams));
        return dependentVSIds;
    }         
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds on load of PDG 
                    for recursive data (For PDG error out issue with Bulk Data)
    Inputs:         List < String > boardIds
    Output:         Set < String >
    Returns:        returns all externally dependent valuestreamIds
    Date :          20.12.2018
    ------------------------------------------------------------*/
    @RemoteAction
    Global static Set<String> readExternallyDependentVSIds(List < String > boardIds){
        Set<String> relatedVSIds =new Set<String>(boardIds); 
        relatedVSIds.addAll(getExternallyDependentVSIds(new Set<String>(boardIds)));
        RealTimeControllerHelper.updateProjectBoardDates(relatedVSIds);
        return relatedVSIds;
    } 
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds
    Inputs:         --
    Output:         List < AggregateResult >
    Returns:        returns all externally dependent dependency record 
                    grouped by their pred. and Suc.'s valuestreamIds
    Date :          24.09.2018
    ------------------------------------------------------------*/   
    public static List < AggregateResult > readExternallyDependentValueStreams() {
        // Date: 03/05/2019
        // To get the record without sharing inforcement.
		return  leankor.RealTimeControllerHelper.readExternallyDependentValueStreams_Helper();
    }
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get All dependent ValuestreamIds
    Inputs:         Set < String > valuestreamIDs, List < AggregateResult > externallyDependentValuestreams
    Output:         Set < String >
    Returns:        returns all related externally dependent valuestreamIds
    Date :          24.09.2018
    ------------------------------------------------------------*/
    public static Set < String > getDependentValuestreamIds(Set < String > valuestreamIDs, List < AggregateResult > externallyDependentValuestreams) {
        Set < String > ValuestreamIDs1 = new Set < String > ();
        for (AggregateResult d: externallyDependentValuestreams) {
            if (ValuestreamIDs.contains(String.valueOf(d.get('PredecessorVS'))) || ValuestreamIDs.contains(String.valueOf(d.get('SuccessorVS')))) {
                if (d.get('SuccessorVS') != null && !ValuestreamIDs.contains(String.valueOf(d.get('SuccessorVS')))) {
                    ValuestreamIDs1.add(String.valueOf(d.get('SuccessorVS')));
                }
                if (d.get('PredecessorVS') != null && !ValuestreamIDs.contains(String.valueOf(d.get('PredecessorVS')))) {
                    ValuestreamIDs1.add(String.valueOf(d.get('PredecessorVS')));
                }
            }
        }
        if (ValuestreamIDs1.size() > 0) {
            try {
                GanttTaskBoard.Dependentvaluestream.addall(ValuestreamIDs1);
                //Call method recursively till all n level's relateddependent VSids are retrieved
                getDependentValuestreamIds(GanttTaskBoard.Dependentvaluestream, externallyDependentValuestreams);
            } catch (Exception ex) {
                system.debug(ex);
                throw new leankor.GanttTaskBoard.LeanException('Error : Too many dependencies');
            }
        }
        return GanttTaskBoard.Dependentvaluestream;
    }   


    /*------------------------------------------------------------
    Author:         Suraj Sen, Rahul Solanki
    Company:        Leankor
    Description:    get All linked card's ValuestreamIds for broadcast subscription
    Inputs:         String boardId
    Output:         Set < String >
    Returns:        returns all related externally dependent valuestreamIds
    Date :          24.09.2018
    ------------------------------------------------------------*/
    //SS 24.1.2020
    //Modifications in this method for filtering null condition from the query result has not done in this method, 
    //as this is not being used anywhere.
    @RemoteAction
    global static Set<String> getMiniatureVS(String boardId){
        if (String.isNotBlank(boardId) && Util.getSObjectName(boardId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour KanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !valueStreamBehavior.isAccessible() ||
            !KanbanCardBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        String projectRoomId ;
        Boolean flag = false;
        Set < String > miniaturevaluestream = new Set < String > ();
        //List<Leankor__ValueStream__c> vsList = new List<Leankor__ValueStream__c>();
        //List will have values only when current project is Template
        List<Leankor__Valuestream__c> vsRecord = [SELECT id,
        											Leankor__ProjectRoom__c, 
        											Leankor__ProjectRoom__r.Leankor__IsTemplateProject__c 
        										FROM Leankor__ValueStream__c 
        										WHERE Id  = :boardId AND 
        											//Leankor__ProjectRoom__c != null AND 
        											Leankor__isRecordDeleted__c  = false AND 
        											Leankor__ProjectRoom__r.Leankor__IsTemplateProject__c = true 
        										limit 1];
        if(vsRecord.size()>0 && String.isNotBlank(vsRecord[0].Leankor__ProjectRoom__c))
        {
            flag = true;
            projectRoomId = vsRecord[0].Leankor__ProjectRoom__c;
        }
        Set<Id> vsIds = new Set<Id>();
        if(flag)
        {
            //This query returns valuestream of child Valuestream (whose card's are linked to this board's card)
            for(Leankor__KanbanCard__c kc: [SELECT Leankor__ValueStreamLink__c, Leankor__ValueStream__c, Leankor__ProjectRoom__c, Leankor__ValueStream__r.Leankor__boardType__c FROM Leankor__KanbanCard__c WHERE Leankor__Valuestream__c = :boardId and  Leankor__IsRecordDeleted__c = false LIMIT 49999]){
                if(kc.Leankor__ValueStream__c != Null && kc.Leankor__ProjectRoom__c != null && kc.Leankor__ValueStream__r.Leankor__boardType__c != 'UberBoard'){
                    vsIds.add(kc.Leankor__ValueStreamLink__c);
                }
            }
            if(!vsIds.isEmpty()){
                for(Leankor__ValueStream__c vs: [SELECT Id, Leankor__BoardType__c, Leankor__ProjectRoom__c FROM Leankor__Valuestream__c WHERE Id IN: vsIds AND Leankor__IsRecordDeleted__c = false LIMIT 49999]){
                    if(vs.Leankor__BoardType__c != 'UberBoard' && vs.Leankor__ProjectRoom__c!= null){
                        miniaturevaluestream.add(vs.Id);
                    }
                }
            }
            
            //This query returns valuestream of parent Valuestream (with whom card of current board are linked)\
            vsIds = new Set<Id>();
            for(Leankor__KanbanCard__c kc: [SELECT Leankor__ValueStream__c, Leankor__ProjectRoom__c, Leankor__ValueStream__r.Leankor__boardType__c FROM Leankor__KanbanCard__c WHERE Leankor__ValuestreamLink__c = :boardId AND Leankor__IsRecordDeleted__c = false LIMIT 49999]){
                if(kc.Leankor__ProjectRoom__c != null && kc.Leankor__ValueStream__r.Leankor__boardType__c != 'UberBoard'){
                    vsIds.add(kc.Leankor__ValueStream__c);
                }
            }
            if(!vsIds.isEmpty()){
                for(Leankor__Valuestream__c linkedVS: [SELECT Id, Leankor__BoardType__c FROM Leankor__ValueStream__c WHERE Id IN: vsIds AND Leankor__IsRecordDeleted__c = false and Leankor__ProjectRoom__c =: projectRoomId  limit 49999]){
                    if(linkedVS.Leankor__BoardType__c != 'UberBoard'){
                        miniaturevaluestream.add(linkedVS.Id);
                    }
                }
            }
        }
        else{
            //This query returns valuestream of child Valuestream (whose card's are linked to this board's card)
            for(Leankor__KanbanCard__c kc: [SELECT Leankor__ValueStreamLink__c, Leankor__ValueStream__c, Leankor__ProjectRoom__c, Leankor__MasterContainer__r.Leankor__Type__c, Leankor__ValueStream__r.Leankor__boardType__c FROM Leankor__KanbanCard__c WHERE Leankor__Valuestream__c = :boardId AND Leankor__IsRecordDeleted__c = false AND Leankor__Valuestream__r.Leankor__IsTemplateBoard__c = false LIMIT 49999]){
                if(kc.Leankor__ValueStream__c != Null && kc.Leankor__ProjectRoom__c != null && kc.Leankor__MasterContainer__r.Leankor__Type__c != 'Template' && kc.Leankor__ValueStream__r.Leankor__boardType__c != 'UberBoard'){
                    vsIds.add(kc.Leankor__ValueStreamLink__c);
                }
            }
            if(!vsIds.isEmpty()){
                for(Leankor__Valuestream__c vs: [SELECT Id, Leankor__BoardType__c, Leankor__ProjectRoom__c FROM Leankor__Valuestream__c WHERE Id IN: vsIds AND Leankor__IsRecordDeleted__c = false LIMIT 49999]){
                    if(vs.Leankor__BoardType__c != 'UberBoard' && vs.Leankor__ProjectRoom__c!= null){
                        miniaturevaluestream.add(vs.Id);
                    }
                }
            }

            //This query returns valuestream of parent Valuestream (with whom card of current board are linked)
            for(Leankor__KanbanCard__c kc: [SELECT Leankor__ValueStream__c, Leankor__ProjectRoom__c, Leankor__MasterContainer__r.Leankor__Type__c, Leankor__ValueStream__r.Leankor__boardType__c FROM Leankor__KanbanCard__c WHERE Leankor__ValuestreamLink__c = :boardId AND Leankor__IsRecordDeleted__c = false AND Leankor__Valuestream__r.Leankor__IsTemplateBoard__c = false LIMIT 49999]){
                if(kc.Leankor__ProjectRoom__c != null && kc.Leankor__MasterContainer__r.Leankor__Type__c != 'Template' && kc.Leankor__ValueStream__r.Leankor__boardType__c != 'UberBoard'){
                    vsIds.add(kc.Leankor__ValueStream__c);
                }
            }
            if(!vsIds.isEmpty()){
                for(Leankor__Valuestream__c linkedVS: [SELECT Id, Leankor__BoardType__c, Leankor__ProjectRoom__c FROM Leankor__ValueStream__c WHERE Id IN: vsIds AND Leankor__IsRecordDeleted__c = false LIMIT 49999]){
                    if(linkedVS.Leankor__BoardType__c != 'UberBoard' &&  linkedVS.Leankor__ProjectRoom__c!= null) {
                        miniaturevaluestream.add(linkedVS.Id);
                    }
                }
            }
        }
        return miniaturevaluestream; 
    }

    @TestVisible
    private static Map<Id, leankor__KanbanCard__c> fixCardDatesCardsQuery(final Set<Id> activityIds) {
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        return new Map<Id, leankor__KanbanCard__c>(
            [SELECT
                Id,
                Name,
                leankor__StartDate__c,
                leankor__StartDateTime__c,
                leankor__DueDate__c,
                leankor__DueDateTime__c,
                leankor__IsSuccessorRecalculate__c,
                leankor__ValueStream__c,
                Recordtype.Name,
                leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                leankor__DurationUnits__c,
                leankor__EstimatedDuration__c,
                OwnerId,
                (SELECT
                    Id,
                    leankor__StartDate__c,
                    leankor__StartDateTime__c,
                    leankor__DueDate__c,
                    leankor__DueDateTime__c,
                    leankor__IsSuccessorRecalculate__c,
                    leankor__ValueStream__c,
                    leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                    leankor__DurationUnits__c,
                    leankor__EstimatedDuration__c,
                    OwnerId,
                    leankor__ValueStreamCardLink__r.leankor__IsSuccessorRecalculate__c,
                    leankor__Monday__c,
                    leankor__Tuesday__c,
                    leankor__Wednesday__c,
                    leankor__Thursday__c,
                    leankor__Friday__c,
                    leankor__Saturday__c,
                    leankor__Sunday__c,
                    leankor__WeekCalendar__c,
                    leankor__BoardType__c
                FROM leankor__Kanban_Cards__r
                WHERE leankor__isRecordDeleted__c = false
                ORDER BY leankor__StartDateTime__c)
            FROM leankor__KanbanCard__c
            WHERE Id IN : activityIds
                AND leankor__isRecordDeleted__c = false
            ORDER BY leankor__StartDateTime__c
            LIMIT 9999]
        );      
    }
    
    /*SS 30.10.2018*/
    //All rows will get all archived and deleted records
    // so put filter IsDeleted=false, It will get only non deleted Task records.
    @TestVisible
    private static List<Task> fixCardDatesTasksQuery(final Set<Id> whatIds) {
        //Check CRUD / FLC behavior 
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if(!taskBehaviour.isAccessible()){
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        return [SELECT
                    Id, 
                    ActivityDate,
                    WhatId
                FROM Task 
                WHERE WhatId IN: whatIds 
                    AND isDeleted = false 
                ORDER BY ActivityDate
                All Rows];      
    }

    @TestVisible
    private static List<leankor__Dependency__c> fixCardDatesSuccessorQuery(final Set<Id> valueStreamIds) {
        //Check CRUD / FLC behavior 
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        return [SELECT
                 Id,
                 leankor__Predecessor__c,
                 leankor__Predecessor__r.Name,
                 leankor__Predecessor__r.leankor__ValueStream__c,
                 leankor__Predecessor__r.leankor__ValueStreamCardLink__c,
                 leankor__Successor__c,
                 leankor__Successor__r.Name,
                 leankor__Successor__r.leankor__ValueStreamCardLink__c,
                 leankor__Successor__r.leankor__ValueStream__c,
                 leankor__ValueStream__c
            FROM leankor__Dependency__c
            WHERE leankor__ValueStream__c In : valueStreamIds
            	AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                AND leankor__Predecessor__r.leankor__isRecordDeleted__c = False
                AND leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = False
                AND leankor__Successor__r.leankor__isRecordDeleted__c = False
                AND leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = False
            LIMIT 9999];       
    }

    @TestVisible
    private static List<leankor__Kanbancard__c> fixCardDatesSuccessorCardsQuery(final Set<Id> successorIds) {
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        return [SELECT Id,
                    leankor__IsSuccessorRecalculate__c,
                    leankor__StartDate__c,
                    leankor__StartDateTime__c,
                    leankor__DueDate__c,
                    leankor__DueDateTime__c,
                    leankor__DurationUnits__c,
                    leankor__EstimatedDuration__c,
                    leankor__BoardType__c,
                    leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                    leankor__Valuestream__c,
                    leankor__ValueStreamCardLink__c,
                    leankor__ValueStreamCardLink__r.leankor__BoardType__c
                FROM leankor__Kanbancard__c
                WHERE Id IN : successorIds
                    AND leankor__isRecordDeleted__c = false
                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                LIMIT 9999];
    }

    @TestVisible
    private static List<leankor__Kanbancard__c> fixCardDatesValueStreamCardLinkCardsQuery(final Set<Id> valueStreamCardLinkCardsId) {
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        return [SELECT
                    leankor__IsSuccessorRecalculate__c,
                    leankor__ValueStream__c
                FROM leankor__Kanbancard__c
                WHERE Id IN : valueStreamCardLinkCardsId
                    AND leankor__isRecordDeleted__c = false
                    AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                LIMIT 9999];
    }

    @TestVisible
    private static List<leankor__ScheduleMode__c> fixCardDatesScheduleModeQuery(final Set<Id> mapDependencyCardIds) {
        //Check CRUD / FLC behavior 
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        return [SELECT
                    leankor__KanbanCard__c
                FROM leankor__ScheduleMode__c
                WHERE leankor__KanbanCard__c IN : mapDependencyCardIds
                    AND leankor__ManuallyScheduled__c = true
                LIMIT 9999];
    }

    global class KanbanCard {
        public List<MiniatureCard> miniatureCards;
        public List<MiniatureCard> miniatureSuccessorCards;
    }
    
    public class MiniatureCard{
        public String Id {get; set;}
        public DateTime StartDate {get; set;}
        public DateTime DueDate {get; set;}
        public Boolean IsSuccessorRecalculate {get; set;}
        public String ValueStreamID {get; set;}
        public Boolean hasDependency {get; set;} {hasDependency = false;}
        public String OwnerId {get; set;}
    }

    //Need to deprecate this as there was a change in logic that no longer requires this class
    private class TaskPlan {
        public leankor__KanbanCard__c activity {get; set;}
        public Util.WorkWeek workWeekObj {get; set;}
    }

    public static Integer getNonWorkingDaysAmount(DateTime startDateTime, DateTime dueDateTime, Util.WorkWeek workWeekObj) {
        DateTime first = startDateTime;
        DateTime second = dueDateTime;
        //Switch dates if due date is less than start date
        if(dueDateTime < startDateTime) {
            first = dueDateTime;
            second = startDateTime;
        }

        Integer nonWorkingDayCounter = 0;
        while(first <= second) {
            if(!workWeekObj.isWorkingDay(first.format('EEEE'))){
                nonWorkingDayCounter++;
            }
            first = first.addDays(1);
        }
        return nonWorkingDayCounter;
    }

     // vj Date :19/12/19 No longer use.
    /*public static Integer getNonWorkingDaysDateAmount(Date startDate, Date dueDate, Util.WorkWeek workWeekObj) {
        Date first = startDate;
        Date second = dueDate;
        DateTime firstDateTime = DateTime.newInstance(first.year(), first.month(), first.day());
        //Switch dates if due date is less than start date
        if(dueDate < startDate) {
            first = dueDate;
            second = startDate;
        }

        Integer nonWorkingDayCounter = 0;
        while(first <= second) {
            if(!workWeekObj.isWorkingDay(firstDateTime.format('EEEE'))){
                nonWorkingDayCounter = nonWorkingDayCounter + 1;
            }
            firstDateTime = firstDateTime.addDays(1);       
            first = first.addDays(1);
        }
        return nonWorkingDayCounter;
    }*/

    private static Integer calculateEstimatedDuration(leankor__Kanbancard__c miniature, Util.WorkWeek workWeekObj) {
        Integer estimatedDuration;
        if(miniature.leankor__DurationUnits__c != 'Days') {
            estimatedDuration = (miniature.leankor__StartDate__c.daysBetween(miniature.leankor__DueDate__c) + 1) - getNonWorkingDaysAmount(miniature.leankor__StartDateTime__c, miniature.leankor__DueDateTime__c, workWeekObj);
        } else {
            estimatedDuration = miniature.leankor__EstimatedDuration__c.intValue();
        }
        return estimatedDuration;
    }

    // Date: 12/11/2019 - Parameter has changed
    //private static void fixCardDatesForwardMovement(leankor__KanbanCard__c activity, leankor__KanbanCard__c miniature, Util.WorkWeek workWeekObj) {
    private static void fixCardDatesForwardMovement(leankor__KanbanCard__c miniature, Util.WorkWeek workWeekObj) {
        Integer ED = 0; 
        //Get the estimate duration of card.
        if(miniature.leankor__DurationUnits__c != 'Days') {
            ED = workWeekObj.getBusinessDays(miniature.leankor__StartDate__c, miniature.leankor__DueDate__c);
        } else {
            ED = miniature.leankor__EstimatedDuration__c.intValue()-1;
        }
        //Make adjustments if start date lands on a non working day
        miniature.leankor__StartDateTime__c = workWeekObj.getNextWorkingDay(miniature.leankor__StartDateTime__c);
        // Set the due date for miniature
        miniature.leankor__DueDateTime__c = workWeekObj.nextBusinessDate(miniature.leankor__StartDateTime__c, ED);

        /*Integer estimatedDuration = calculateEstimatedDuration(miniature, workWeekObj);
        //Check if a seven day work week
        if(activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {
            miniature.leankor__DueDateTime__c = miniature.leankor__StartDateTime__c.addDays(estimatedDuration - 1);
        }else {
            //Make adjustments if start date lands on a non working day
            if(!workWeekObj.isWorkingDay(miniature.leankor__StartDateTime__c.format('EEEE'))) {
                miniature.leankor__StartDateTime__c = Util.WorkWeek.readNextWorkingDateTime(workWeekObj, miniature.leankor__StartDateTime__c);
            }
            //Calculate due date
            miniature.leankor__DueDateTime__c = miniature.leankor__StartDateTime__c;
            //Add duration one day at a time
            for(Integer i = 0; i<estimatedDuration - 1; i++) {
                miniature.leankor__DueDateTime__c = miniature.leankor__DueDateTime__c.addDays(1);
                if(!workWeekObj.isWorkingDay(miniature.leankor__DueDateTime__c.format('EEEE'))) {
                    //Make adjustments if start date lands on a non working day
                    miniature.leankor__DueDateTime__c = Util.WorkWeek.readNextWorkingDateTime(workWeekObj, miniature.leankor__DueDateTime__c);
                }
            }
        }*/
    }

    // Date: 12/11/2019 - Parameter has changed
    //private static void fixCardDatesBackwardMovement(leankor__KanbanCard__c activity, leankor__KanbanCard__c miniature, Util.WorkWeek workWeekObj) {
    private static void fixCardDatesBackwardMovement(leankor__KanbanCard__c miniature, Util.WorkWeek workWeekObj) {
        
        // Date: 11/11/2019 - Changes related to blackout.
        Integer ED = 0; 
        //Get the estimate duration of card.
        if(miniature.leankor__DurationUnits__c != 'Days') {
            ED = workWeekObj.getBusinessDays(miniature.leankor__StartDate__c, miniature.leankor__DueDate__c);
        } else {
            ED = miniature.leankor__EstimatedDuration__c.intValue()-1;
        }
        //Make adjustments if start date lands on a non working day
        miniature.leankor__DueDateTime__c = workWeekObj.getPreviousWorkingDay(miniature.leankor__DueDateTime__c);
        // Set the due date for miniature
        miniature.leankor__StartDateTime__c = workWeekObj.nextBusinessDate(miniature.leankor__DueDateTime__c, -ED);

        /*Integer estimatedDuration = calculateEstimatedDuration(miniature, workWeekObj);
        //Check if a seven day work week
        if(activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {
            miniature.leankor__StartDateTime__c = miniature.leankor__DueDateTime__c.addDays(-(estimatedDuration - 1));
        }else {
            //Make adjustments if due date lands on a non working day
            if(!workWeekObj.isWorkingDay(miniature.leankor__DueDateTime__c.format('EEEE'))) {
                miniature.leankor__DueDateTime__c = Util.WorkWeek.readPreviousWorkingDateTime(workWeekObj, miniature.leankor__DueDateTime__c);
            }
            //Calculate start date
            miniature.leankor__StartDateTime__c = miniature.leankor__DueDateTime__c;
            //Subtract duration one day at a time
            for(Integer i = 0; i<estimatedDuration - 1; i++) {
                miniature.leankor__StartDateTime__c = miniature.leankor__StartDateTime__c.addDays(-1);
                if(!workWeekObj.isWorkingDay(miniature.leankor__StartDateTime__c.format('EEEE'))) {
                    //Make adjustments if start date lands on a non working day
                    miniature.leankor__StartDateTime__c = Util.WorkWeek.readPreviousWorkingDateTime(workWeekObj, miniature.leankor__StartDateTime__c);
                }
            }
        }*/           
    }           

    @TestVisible
    private static Integer fixCardDatesCalculateDateDifference(leankor__KanbanCard__c activity, List<leankor__KanbanCard__c> miniatures, Util.WorkWeek workWeekObj) {
        DateTime oldMiniatureStartDateTime = miniatures[0].leankor__StartDateTime__c;
        DateTime oldMiniatureDueDateTime;
        DateTime oldActivityStartDateTime = activity.leankor__StartDateTime__c;
        DateTime oldActivityDueDateTime = activity.leankor__DueDateTime__c;

        Date newMiniatureStartDate = Date.newInstance(oldMiniatureStartDateTime.year(), oldMiniatureStartDateTime.month(), oldMiniatureStartDateTime.day());
        Date newMiniatureDueDate;
        Date newActivityStartDate = Date.newInstance(oldActivityStartDateTime.year(), oldActivityStartDateTime.month(), oldActivityStartDateTime.day());
        Date newActivityDueDate = Date.newInstance(oldActivityDueDateTime.year(), oldActivityDueDateTime.month(), oldActivityDueDateTime.day());            
        
        //Integer dateDifference = newMiniatureStartDate.daysBetween(newActivityStartDate) - getNonWorkingDaysAmount(oldMiniatureStartDateTime, oldActivityStartDateTime, workWeekObj);
        Integer dateDifference = newMiniatureStartDate.daysBetween(newActivityStartDate);
        
        if(getNonWorkingDaysAmount(oldMiniatureStartDateTime, oldActivityStartDateTime, workWeekObj) > 0) {
            dateDifference = newMiniatureStartDate.daysBetween(newActivityStartDate) - getNonWorkingDaysAmount(oldMiniatureStartDateTime, oldActivityStartDateTime, workWeekObj);
        }
        
        for (leankor__Kanbancard__c miniature : miniatures) {
            if (oldMiniatureDueDateTime != null && oldMiniatureDueDateTime < miniature.leankor__DueDateTime__c) {
                oldMiniatureDueDateTime = miniature.leankor__DueDateTime__c;
            } else if (oldMiniatureDueDateTime == null){
                oldMiniatureDueDateTime = miniature.leankor__DueDateTime__c;
            }
        }
        newMiniatureDueDate = Date.newInstance(oldMiniatureDueDateTime.year(), oldMiniatureDueDateTime.month(), oldMiniatureDueDateTime.day());
        if (activity.Recordtype.Name == 'MileStoneCard' || dateDifference < 0) {
            //dateDifference = newMiniatureDueDate.daysBetween(newActivityDueDate) - getNonWorkingDaysAmount(oldMiniatureDueDateTime, oldActivityDueDateTime, workWeekObj);
            dateDifference = newMiniatureDueDate.daysBetween(newActivityDueDate);
        }
        return dateDifference;
    }

    /* This function takes last element as pivot, 
       places the pivot element at its correct 
       position in sorted array, and places all 
       smaller (smaller than pivot) to left of 
       pivot and all greater elements to right 
       of pivot */
    public static Integer partition(List<leankor__Kanbancard__c> dateTimeArray, Integer low, Integer high){

        DateTime pivot = dateTimeArray[high].leankor__DueDateTime__c;  
        Integer i = (low-1); // index of smaller element 
        for (Integer j=low; j<high; j++) 
        { 
            // If current element is smaller than or 
            // equal to pivot 
            if (dateTimeArray[j].leankor__DueDateTime__c <= pivot) 
            { 
                i++; 
  
                // swap dateTimeArray[i] and dateTimeArray[j] 
                DateTime temp = dateTimeArray[i].leankor__DueDateTime__c; 
                dateTimeArray[i].leankor__DueDateTime__c = dateTimeArray[j].leankor__DueDateTime__c; 
                dateTimeArray[j].leankor__DueDateTime__c = temp; 
            } 
        } 
  
        // swap dateTimeArray[i+1] and dateTimeArray[high] (or pivot) 
        DateTime temp = dateTimeArray[i+1].leankor__DueDateTime__c; 
        dateTimeArray[i+1].leankor__DueDateTime__c = dateTimeArray[high].leankor__DueDateTime__c; 
        dateTimeArray[high].leankor__DueDateTime__c = temp; 
  
        return i+1; 
    } 
  
  
    /* The main function that implements QuickSort() 
      arr[] --> Array to be sorted, 
      low  --> Starting index, 
      high  --> Ending index */
    public static void dueDateTimeCardSort(List<leankor__Kanbancard__c> arr, Integer low, Integer high) { 
        if (low < high){ 
            /* pi is partitioning index, arr[pi] is  
              now at right place */
            Integer pi = partition(arr, low, high); 
  
            // Recursively sort elements before 
            // partition and after partition 
            dueDateTimeCardSort(arr, low, pi-1); 
            dueDateTimeCardSort(arr, pi+1, high); 
        } 
    }

    // vj Date :19/12/19 No longer use.
    /*public static Integer getDateGap(Date first, Date second, Util.WorkWeek workWeekObj) {
        Integer daysBetweenCount = first.daysBetween(second);
        Integer nonWorkingDaysCount = getNonWorkingDaysDateAmount(first, second, workWeekObj);
        Integer dateGapCount;
        if(daysBetweenCount > 0) {
            dateGapCount = daysBetweenCount - nonWorkingDaysCount;
        } else if(daysBetweenCount < 0) {
            dateGapCount = daysBetweenCount + nonWorkingDaysCount;
        } else {
            dateGapCount = 0;
        }
        return dateGapCount;
    }*/
    // vj Date :19/12/19 No longer use. 
   /* public static Date addWorkingDays(Date dateValue, Integer workingDaysCount, Util.WorkWeek workWeekObj) {
        //Return if there is no gap
        if (workingDaysCount == 0) {
            return dateValue;
        }

        //Allocate memory
        Date adjustedDateValue = dateValue;
        Integer loopCounter = Math.abs(workingDaysCount);
        Integer addDaysValue;

        //Set addDaysValue to add or subtract one day
        if (workingDaysCount > 0) {
            addDaysValue = 1;
        } else if (workingDaysCount < 0) {
            addDaysValue = -1;
        }

        DateTime adjustedDateTimeValue = DateTime.newInstance(adjustedDateValue.year(), adjustedDateValue.month(), adjustedDateValue.day());

        //Calculate adjusted DateTime value
        for(Integer i = 0; i < loopCounter; i++) {
            adjustedDateValue = adjustedDateValue.addDays(addDaysValue);
            adjustedDateTimeValue = DateTime.newInstance(adjustedDateValue.year(), adjustedDateValue.month(), adjustedDateValue.day());
            //Moving forward
            if(addDaysValue > 0 && !workWeekObj.isWorkingDay(adjustedDateTimeValue.format('EEEE'))) {
                adjustedDateValue = Util.WorkWeek.readNextWorkingDate(workWeekObj, adjustedDateTimeValue, adjustedDateValue);
            }
            //Moving backward
            else if(addDaysValue < 0 && !workWeekObj.isWorkingDay(adjustedDateTimeValue.format('EEEE'))) {
                adjustedDateValue = Util.WorkWeek.readPreviousWorkingDate(workWeekObj, adjustedDateTimeValue, adjustedDateValue);
            }
        }

        return adjustedDateValue;
    }*/

    public static DateTime addWorkingDaysTime(DateTime dateTimeValue, Integer workingDaysCount, Util.WorkWeek workWeekObj) {
        //Return if there is no gap
        if (workingDaysCount == 0) {
            return dateTimeValue;
        }

        //Allocate memory
        DateTime adjustedDateTimeValue = dateTimeValue;
        Integer loopCounter = Math.abs(workingDaysCount);
        Integer addDaysValue;

        //Set addDaysValue to add or subtract one day
        if (workingDaysCount > 0) {
            addDaysValue = 1;
        } else if (workingDaysCount < 0) {
            addDaysValue = -1;
        }

        //Calculate adjusted DateTime value
        for(Integer i = 0; i < loopCounter; i++) {
            adjustedDateTimeValue = adjustedDateTimeValue.addDays(addDaysValue);
            //Moving forward
            if(addDaysValue > 0 && !workWeekObj.isWorkingDay(adjustedDateTimeValue.format('EEEE'))) {
                adjustedDateTimeValue = Util.WorkWeek.readNextWorkingDateTime(workWeekObj, adjustedDateTimeValue);
            }
            //Moving backward
            else if(addDaysValue < 0 && !workWeekObj.isWorkingDay(adjustedDateTimeValue.format('EEEE'))) {
                adjustedDateTimeValue = Util.WorkWeek.readPreviousWorkingDateTime(workWeekObj, adjustedDateTimeValue);
            }
        }

        return adjustedDateTimeValue;
    }

    //NOTE SOME TASK CALCULATIONS ARE NOW OBSOLETE IN FAVOUR OF THE NEW ALGORITHM e.g. any calculation using taskGap, etc.
    @RemoteAction
    global static List<leankor.GanttTaskBoard.KanbanCard> fixCardDatesToActivity(final List<Id> activityIds) {
        for(Id activityId : activityIds){
            if (String.isNotBlank(activityId) && Util.getSObjectName(activityId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<leankor.GanttTaskBoard.KanbanCard> responseKanbanCardList = new List<leankor.GanttTaskBoard.KanbanCard>();
        List<leankor.GanttTaskBoard.MiniatureCard> miniatureCards = new List<leankor.GanttTaskBoard.MiniatureCard>();
        List<leankor.GanttTaskBoard.MiniatureCard> miniatureSuccessorCards = new List<leankor.GanttTaskBoard.MiniatureCard>();
        
        if(activityIds.isEmpty() || activityIds == null){
            return responseKanbanCardList;
        }
        
        Set<Id> miniatureIds = new Set<Id>(); // To add the miniature Ids.
        List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>(); // Add card affter miniature date updated
        Map<Id, GanttTaskBoard.TaskPlan> dateDifferenceMap = new Map<Id, GanttTaskBoard.TaskPlan>();
        List<String> jsonDataList = new List<String>();
        Set<Id> valueStreamIds = new Set<Id>(); // To add the miniature's  value stream

        Map<Id, leankor__KanbanCard__c> cards = fixCardDatesCardsQuery(new Set<Id>(activityIds)); // Get the activity
        Set<id> valueStreamCardLinkCardIds = new Set<id>();

        Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;
        Integer firstDayOfWeek = firstDay == null || firstDay < 0  || firstDay > 6 ? 1 : firstDay.intValue();
        
        //Test implementation for bulk data broadcast
        Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
        
        //NOT BULKIFIED FIRST DATE USED FOR TASK CALCULATION
        Date firstMiniatureStartDate; // First miniature start date before update 
        Date firstMiniatureStartDateAdjusted; // First miniature start date after update 
        
        //Used for successor calculation
        DateTime firstMiniatureStartDateTimeAdjusted; // First miniature start datetime after update 
        Util.WorkWeek nonBulkWorkWeekObj;

        // Date: 12/11/2019 ---------------------
        Set<Id> valueStreamSet = new Set<Id>();
        valueStreamSet.addAll(cards.keySet());
        //------------------------------

        //NOT BULKIFIED FIRST DATE USED FOR TASK CALCULATION
        for (Id key : cards.keySet()) {

            if (cards.get(key).leankor__Kanban_Cards__r.isEmpty()) {
                continue;
            }
            Datetime firstMiniatureStartDateTime = cards.get(key).leankor__Kanban_Cards__r[0].leankor__StartDateTime__c;
            firstMiniatureStartDate = Date.newInstance(firstMiniatureStartDateTime.year(), firstMiniatureStartDateTime.month(), firstMiniatureStartDateTime.day());
            //nonBulkWorkWeekObj = new Util.WorkWeek(firstDayOfWeek, cards.get(key).leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5);

            //Date: 12/11/2019 - Miniature value stream's are added into set  -------------------
            for(leankor__KanbanCard__c miniature : cards.get(key).leankor__Kanban_Cards__r){
                valueStreamSet.add(miniature.leankor__ValueStream__c);
            }
            //--------------------
            break;
        }

        // Date: 12/11/2019 ------------------------
        // Get the blackout records of related value stream.
        Map<Id, Util.WorkWeek> vsWorkWeekMap = new Map<Id, Util.WorkWeek>();
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackOutMap = leankor.RealTimeControllerHelper.getBlackOutRecords(valueStreamSet);

        for(Id key : cards.keySet()) {

            leankor__KanbanCard__c activity = cards.get(key);
            // Not considering blackout on the plan gantt for miniature date updates.
            Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5, vsBlackOutMap.get(activity.leankor__ValueStream__c));
            vsWorkWeekMap.put(activity.leankor__ValueStream__c, workWeek);

            if (cards.get(key).leankor__Kanban_Cards__r.isEmpty()) {
                continue;
            }
            
            for(leankor__KanbanCard__c miniature : cards.get(key).leankor__Kanban_Cards__r){
                // In calculation miniature board is seven or five day workweek depends upon the plan Gantt(Activity) workweek.
                Util.WorkWeek work = new Util.WorkWeek(firstDayOfWeek, activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5, vsBlackOutMap.get(miniature.leankor__ValueStream__c));
                vsWorkWeekMap.put(miniature.leankor__ValueStream__c, work);
            }
            break;
        }
        // Later used to create workWeek instance for successor.
        Boolean pgIsSevenDayWorkWeek = false;
        // Miniature >> ValueStream map that used for task date calculation
        Map<Id, Id> cardVSMap = new Map<Id, Id>();
        //----------------------

        //Integer dateDifference;
        for(Id key : cards.keySet()) {
            leankor__KanbanCard__c activity = cards.get(key);

            // Date: 12/11/2019 - changes for blackout ---------------------------
            pgIsSevenDayWorkWeek = activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
            Util.WorkWeek miniatureWorkWeek;
            Util.WorkWeek activityWorkWeek = vsWorkWeekMap.get(activity.leankor__ValueStream__c);
            //Util.WorkWeek workWeekObj = new Util.WorkWeek(firstDayOfWeek, activity.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5);
            //*-------------------

            List<leankor__KanbanCard__c> miniatures = activity.leankor__Kanban_Cards__r;
            if (miniatures.isEmpty()) {
                continue;
            }

            //NOT BULKIFIED FIRST DATE USED FOR TASK CALCULATION
            //nonBulkWorkWeekObj = workWeekObj; 
            nonBulkWorkWeekObj = activityWorkWeek; // Activity workweek later used for successor and Task date calculation.
                        
            //NOT BULKIFIED FIRST DATE USED FOR TASK CALCULATION

            if (activity.Recordtype.Name == 'MileStoneCard') {
                dueDateTimeCardSort(miniatures, 0, miniatures.size() - 1);
            }

            //Calculate date difference between activity and miniatures
            //Integer dateDifference = fixCardDatesCalculateDateDifference(activity, miniatures, workWeekObj);
            //activity.leankor__IsSuccessorRecalculate__c = true;
            
            Integer gap;
            DateTime previous;
            Integer miniaturesSize = miniatures.size();

            // Calculation of miniature dates    
            for(Integer i = 0; i < miniaturesSize; i++) {

                // Get the workWeek instance for current miniatures
                miniatureWorkWeek = vsWorkWeekMap.get(miniatures[i].leankor__ValueStream__c);
                cardVSMap.put(miniatures[i].Id, miniatures[i].leankor__ValueStream__c);
                
                Set<String> weekDays = new Set<String>();
                if(pgIsSevenDayWorkWeek == true){
                    if(miniatures[i].leankor__Monday__c == false && miniatures[i].leankor__Tuesday__c == false && miniatures[i].leankor__Wednesday__c == false &&  miniatures[i].leankor__Thursday__c == false &&  miniatures[i].leankor__Friday__c == false &&  miniatures[i].leankor__Saturday__c == false &&  miniatures[i].leankor__Sunday__c == false){
                        miniatures[i].leankor__Monday__c = true;
                        miniatures[i].leankor__Tuesday__c = true;
                        miniatures[i].leankor__Wednesday__c = true;
                        miniatures[i].leankor__Thursday__c = true;
                        miniatures[i].leankor__Friday__c = true;
                        miniatures[i].leankor__Saturday__c = true;
                        miniatures[i].leankor__Sunday__c = true;
                    }else{
                        weekDays.add(miniatures[i].leankor__Monday__c == false ? 'Mon' : 'false');
                        weekDays.add(miniatures[i].leankor__Tuesday__c == false ? 'Tue' : 'false');
                        weekDays.add(miniatures[i].leankor__Wednesday__c == false ? 'Wed' : 'false');
                        weekDays.add(miniatures[i].leankor__Thursday__c == false ? 'Thu' : 'false');
                        weekDays.add(miniatures[i].leankor__Friday__c == false ? 'Fri' : 'false');
                        weekDays.add(miniatures[i].leankor__Saturday__c == false ? 'Sat' : 'false');
                        weekDays.add(miniatures[i].leankor__Sunday__c == false ? 'Sun' : 'false');
                    }
                }
                Util.weekDays = weekDays;

                if(activity.Recordtype.Name == 'MileStoneCard') {
                    Integer index = miniaturesSize - 1 - i;
                    if(miniatures.indexOf(miniatures[index]) == miniaturesSize - 1) {
                        
                        previous = miniatures[index].leankor__DueDateTime__c; // Using previous on the next iteration
                        miniatures[index].leankor__DueDateTime__c = activity.leankor__DueDateTime__c;
                        fixCardDatesBackwardMovement(miniatures[index], miniatureWorkWeek);
                    } else {
                        
                        // Find gap between previous and current card due* date 
                        gap = activityWorkWeek.getBusinessDays(previous.date(), miniatures[index].leankor__DueDateTime__c.date());
                        previous = miniatures[index].leankor__DueDateTime__c; // Using previous on the next iteration

                        if(gap<0){
                            // Add the gap into previous card's updated due date to get new due date for current card.
                            miniatures[index].leankor__DueDateTime__c = activityWorkWeek.nextBusinessDate(miniatures[index+1].leankor__DueDateTime__c, gap);
                            fixCardDatesBackwardMovement(miniatures[index], miniatureWorkWeek);
                        }

                        if (gap == 0) {
                            // Assign previous card updated date due* to current card
                            miniatures[index].leankor__DueDateTime__c = miniatures[index+1].leankor__DueDateTime__c;
                            fixCardDatesBackwardMovement(miniatures[index], miniatureWorkWeek);
                        }
                    }
                
                //Activity card type
                } else {

                    if(miniatures.indexOf(miniatures[i]) == 0){

                        previous = miniatures[i].leankor__StartDateTime__c; //Using previous on the next iteration
                        miniatures[i].leankor__StartDateTime__c = activity.leankor__StartDateTime__c;
                        fixCardDatesForwardMovement(miniatures[i], miniatureWorkWeek);
                    }else {
                        // Find gap between previous and current card start* date 
                        gap = activityWorkWeek.getBusinessDays(previous.date(), miniatures[i].leankor__StartDateTime__c.date());
                        previous = miniatures[i].leankor__StartDateTime__c; //Using previous on the next iteration

                        if(gap > 0){
                            // Add the gap into previous card's updated start date to get new start date for current card.
                            miniatures[i].leankor__StartDateTime__c = activityWorkWeek.nextBusinessDate(miniatures[i-1].leankor__StartDateTime__c,gap);
                            fixCardDatesForwardMovement(miniatures[i], miniatureWorkWeek);
                        }

                        if (gap == 0) {
                            // Assign previous card updated date start* to current card
                            miniatures[i].leankor__StartDateTime__c = miniatures[i-1].leankor__StartDateTime__c;
                            fixCardDatesForwardMovement(miniatures[i], miniatureWorkWeek);
                        }
                    }
                }

                /** Date: 12/11/2019 - changes for blackout
                if(activity.Recordtype.Name == 'MileStoneCard') {
                    Integer index = miniaturesSize - 1 - i;
                    if(miniatures.indexOf(miniatures[index]) == miniaturesSize - 1) {
                        //Using previous on the next iteration
                        previous = miniatures[index].leankor__DueDateTime__c;
                        miniatures[index].leankor__DueDateTime__c = activity.leankor__DueDateTime__c;
                        fixCardDatesBackwardMovement(activity, miniatures[index], workWeekObj);

                    } else {
                        //find gap
                        gap = previous.date().daysBetween(miniatures[index].leankor__DueDateTime__c.date());
                        DateTime first = miniatures[index].leankor__DueDateTime__c;
                        //move to second date of miniatures[index] by gap and save
                        miniatures[index].leankor__DueDateTime__c.addDays(-gap);
                        Integer nonWorkingDaysCount = Math.abs(getNonWorkingDaysAmount(first, previous, workWeekObj));
                        //Using previous on the next iteration
                        previous = miniatures[index].leankor__DueDateTime__c;
                        if (gap < 0) {
                            Integer absGap = Math.abs(gap);
                            miniatures[index].leankor__DueDateTime__c = miniatures[index+1].leankor__DueDateTime__c;
                            for(Integer j = 0; j<absGap - nonWorkingDaysCount; j++) {
                                miniatures[index].leankor__DueDateTime__c = miniatures[index].leankor__DueDateTime__c.addDays(-1);
                                if(!workWeekObj.isWorkingDay(miniatures[index].leankor__DueDateTime__c.format('EEEE'))) {
                                    //Make adjustments if start date lands on a non working day
                                    miniatures[index].leankor__DueDateTime__c = Util.WorkWeek.readPreviousWorkingDateTime(workWeekObj, miniatures[index].leankor__DueDateTime__c);
                                }
                            }
                            fixCardDatesBackwardMovement(activity, miniatures[index], workWeekObj);
                        }

                        if (gap == 0) {
                            miniatures[index].leankor__DueDateTime__c = miniatures[index+1].leankor__DueDateTime__c;
                            fixCardDatesBackwardMovement(activity, miniatures[index], workWeekObj);
                        }

                    }
                //Activity card type
                } else {
                    if(miniatures.indexOf(miniatures[i]) == 0) {
                        //Using previous on the next iteration
                        previous = miniatures[i].leankor__StartDateTime__c;
                        miniatures[i].leankor__StartDateTime__c = activity.leankor__StartDateTime__c;
                        fixCardDatesForwardMovement(activity, miniatures[i], workWeekObj);
                    }else {
                        //find gap
                        gap = previous.date().daysBetween(miniatures[i].leankor__StartDateTime__c.date());
                        DateTime first = miniatures[i].leankor__StartDateTime__c;
                        //move to second date of miniatures[i] by gap and save
                        miniatures[i].leankor__StartDateTime__c.addDays(gap);
                        Integer nonWorkingDaysCount = Math.abs(getNonWorkingDaysAmount(previous, first, workWeekObj));
                        //Using previous on the next iteration
                        previous = miniatures[i].leankor__StartDateTime__c;
                        if (gap > 0) {
                            miniatures[i].leankor__StartDateTime__c = miniatures[i-1].leankor__StartDateTime__c;
                            for(Integer j = 0; j<gap - nonWorkingDaysCount; j++) {
                                miniatures[i].leankor__StartDateTime__c = miniatures[i].leankor__StartDateTime__c.addDays(1);
                                if(!workWeekObj.isWorkingDay(miniatures[i].leankor__StartDateTime__c.format('EEEE'))) {
                                    //Make adjustments if start date lands on a non working day
                                    miniatures[i].leankor__StartDateTime__c = Util.WorkWeek.readNextWorkingDateTime(workWeekObj, miniatures[i].leankor__StartDateTime__c);
                                }
                            }
                            fixCardDatesForwardMovement(activity, miniatures[i], workWeekObj);
                        }
                        if (gap == 0) {
                            miniatures[i].leankor__StartDateTime__c = miniatures[i-1].leankor__StartDateTime__c;
                            fixCardDatesForwardMovement(activity, miniatures[i], workWeekObj);
                        }
                    }
                }
                 */

                miniatures[i].leankor__StartDate__c = miniatures[i].leankor__StartDateTime__c.date();
                miniatures[i].leankor__DueDate__c = miniatures[i].leankor__DueDateTime__c.date();

                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    miniatures[i].leankor__IsConstraintRecalculate__c = true;
                }
                miniatureIds.add(miniatures[i].Id);
                //miniatures[i].leankor__IsSuccessorRecalculate__c= true;
                /*
                if(miniatures[i].leankor__ValueStreamCardLink__c != null) {
                    //Only update for Gantt or Rollup board
                    if(miniatures[i].leankor__ValueStreamCardLink__r.leankor__BoardType__c == 'Plan Board' || miniatures[i].leankor__ValueStreamCardLink__r.leankor__BoardType__c == 'UberBoard') {
                        valueStreamCardLinkCardIds.add(miniatures[i].leankor__ValueStreamCardLink__c);
                        //miniatures[i].leankor__ValueStreamCardLink__r.leankor__IsSuccessorRecalculate__c = true;
                    }
                }*/

                updateCards.add(miniatures[i]);
                
                //after Updation need to send data in form of Helper class
                leankor.GanttTaskBoard.MiniatureCard miniatureData = new leankor.GanttTaskBoard.MiniatureCard();
                miniatureData.Id = miniatures[i].Id;
                miniatureData.StartDate = miniatures[i].leankor__StartDateTime__c;
                miniatureData.DueDate = miniatures[i].leankor__DueDateTime__c;
                //miniatureData.IsSuccessorRecalculate = true;
                miniatureData.ValueStreamID = miniatures[i].leankor__ValueStream__c;
                miniatureData.OwnerId = miniatures[i].OwnerId;
                //responseKanbanCardList.add(miniatureData);
                //Add miniature card data in response
                miniatureCards.add(miniatureData);

                //Test implementation for bulk data broadcast
                jsonDataList = broadcastContentMap.containsKey(miniatures[i].leankor__ValueStream__c) ? broadcastContentMap.get(miniatures[i].leankor__ValueStream__c) : new List<String>();
                jsonDataList.add(miniatures[i].Id);
                broadcastContentMap.put(miniatures[i].leankor__ValueStream__c, jsonDataList);
                //jsonDataList.add(JSON.serialize(miniatureData));

                GanttTaskBoard.TaskPlan dateDifferenceTaskPlan = new GanttTaskBoard.TaskPlan();
                dateDifferenceTaskPlan.activity = activity;
                //dateDifferenceTaskPlan.workWeekObj = workWeekObj;
                dateDifferenceTaskPlan.workWeekObj = activityWorkWeek;
                //Need to deprecate dateDifferenceTaskPlan since there is no use for contents anymore (changed behavior)
                dateDifferenceMap.put(miniatures[i].Id, dateDifferenceTaskPlan);
               
                valueStreamIds.add(miniatures[i].leankor__ValueStream__c);
            }
            Util.weekDays.clear();
            //after Updation need to send data in form of Helper class
            leankor.GanttTaskBoard.MiniatureCard activityData = new leankor.GanttTaskBoard.MiniatureCard();
            activityData.Id = activity.Id;
            activityData.StartDate = activity.leankor__StartDateTime__c;
            activityData.DueDate = activity.leankor__DueDateTime__c;
            //activityData.IsSuccessorRecalculate = true;
            activityData.ValueStreamID = activity.leankor__ValueStream__c;
            activityData.OwnerId = activity.OwnerId;
            //responseKanbanCardList.add(activityData);
            //Add activity card data in response
            miniatureCards.add(activityData);
            for (leankor__KanbanCard__c updateCard : updateCards) {
                firstMiniatureStartDateAdjusted = Date.newInstance(updateCard.leankor__StartDateTime__c.year(), updateCard.leankor__StartDateTime__c.month(), updateCard.leankor__StartDateTime__c.day());
                firstMiniatureStartDateTimeAdjusted = updateCard.leankor__StartDateTime__c;
                break;
            }

            //Need to Update IsSuccessor of Activity
            updateCards.add(activity);

            //Implementation for bulk data broadcast
            jsonDataList = broadcastContentMap.containsKey(activity.leankor__ValueStream__c) ? broadcastContentMap.get(activity.leankor__ValueStream__c) : new List<String>();
            jsonDataList.add(activity.Id);
            broadcastContentMap.put(activity.leankor__ValueStream__c, jsonDataList);
            //jsonDataList.add(JSON.serialize(activityData));

        }

        //--------------------------- SUCCESSOR
        //Dependency query
        List<leankor__Dependency__c> dependencies = fixCardDatesSuccessorQuery(valueStreamIds);
        Set<Id> mapDependencyCardIds = new Set<Id>();
        for (leankor__Dependency__c dependency : dependencies) {
        	if(String.isNotBlank(dependency.leankor__Predecessor__r.leankor__ValueStream__c) && String.isNotBlank(dependency.leankor__Successor__r.leankor__ValueStream__c)){
           		mapDependencyCardIds.add(dependency.leankor__Successor__c);
        	}
        }
        List<leankor__ScheduleMode__c> scheduleModeRecords = fixCardDatesScheduleModeQuery(mapDependencyCardIds);
        Set<Id> scheduledModeIds = new Set<Id>();
        for (leankor__ScheduleMode__c scheduleModeRecord : scheduleModeRecords) {
           scheduledModeIds.add(scheduleModeRecord.leankor__KanbanCard__c);
        }
        //Creating map to easily find miniatures for hasDependency set true
        /*Map<Id, GanttTaskBoard.KanbanCard> responseKanbanCardMap = new Map<Id, GanttTaskboard.KanbanCard>();
        for(GanttTaskBoard.KanbanCard responseKanbanCard : responseKanbanCardList) {
            responseKanbanCardMap.put(responseKanbanCard.Id, responseKanbanCard);
        } */
        //Changed response object for GS broadcast
        Map<Id, GanttTaskBoard.MiniatureCard> responseKanbanCardMap = new Map<Id, GanttTaskboard.MiniatureCard>();
        for(GanttTaskBoard.MiniatureCard responseKanbanCard : miniatureCards) {
            responseKanbanCardMap.put(responseKanbanCard.Id, responseKanbanCard);
        }     
        //Get successor ids
        Set<Id> successorIds = new Set<Id>();
        if(!dependencies.isEmpty()) {
            Set<Id> kanbanCardGroupIds = new Set<Id>(miniatureIds);
            successorIds = getAllDependentCardIds(dependencies, miniatureIds, responseKanbanCardMap, kanbanCardGroupIds);
            //Remove activities and miniatures that we are already updating
            //Also remove manually scheduled cards and their paths
            successorIds.removeAll(scheduledModeIds);
            Set<Id> scehduleModeDependencySuccessorIds = getAllDependentCardIds(dependencies, miniatureIds, new Map<Id, GanttTaskboard.MiniatureCard>(), kanbanCardGroupIds);
            Set<Id> nonManualDependencySuccessorIds = getAllDependentCardIds(dependencies, miniatureIds, scheduledModeIds, new Map<Id, GanttTaskboard.MiniatureCard>(), kanbanCardGroupIds, true);
            scehduleModeDependencySuccessorIds.removeAll(nonManualDependencySuccessorIds);
            successorIds.removeAll(scehduleModeDependencySuccessorIds);
            successorIds.removeAll(miniatureIds);
            successorIds.removeAll(new Set<Id>(activityIds));
        }

        //Replace list with the updated hasDependency values
        //responseKanbanCardList = responseKanbanCardMap.values();
        miniatureCards = responseKanbanCardMap.values();

        //Query successor cards
        List<leankor__Kanbancard__c> successorCards = fixCardDatesSuccessorCardsQuery(successorIds);
        if(!successorCards.isEmpty()) {
            DateTime previousCardDate = successorCards[0].leankor__StartDateTime__c;
            Integer workingDaysCount = 0;
            //Integer daysBetweenTask;
            //Integer nonWorkingDaysTaskCount;

            for(Integer i = 0; i < successorCards.size(); i++) {

                Util.WorkWeek successorWorkWeek = vsWorkWeekMap.get(successorCards[i].leankor__ValueStream__c); 

                cardVSMap.put(successorCards[i].Id, successorCards[i].leankor__ValueStream__c);
                
                //Calculate estimated duration before moving dates
                Integer ED;
                if(successorCards[i].leankor__DurationUnits__c != 'Days') {
                    ED = successorWorkWeek.getBusinessDays(successorCards[i].leankor__StartDate__c, successorCards[i].leankor__DueDate__c);
                } else {
                    ED = successorCards[i].leankor__EstimatedDuration__c.intValue()-1;
                }
                
                //Calculate start date
                if (i == 0) {

                    Date startDate = successorCards[0].leankor__StartDateTime__c.dateGmt();
                    // Get the working days difference between miniature and current card start date.
                    workingDaysCount = successorWorkWeek.getBusinessDays(firstMiniatureStartDate, startDate);
                    // Add those many days to updated current card start date.
                    successorCards[0].leankor__StartDateTime__c = successorWorkWeek.nextBusinessDate(firstMiniatureStartDateTimeAdjusted, workingDaysCount);
                }else {
                    Date startDate = successorCards[i].leankor__StartDateTime__c.dateGmt();
                    // Get the working days difference between previous and current card start date.
                    workingDaysCount = successorWorkWeek.getBusinessDays(previousCardDate.date(), startDate);
                    previousCardDate = successorCards[i].leankor__StartDateTime__c;
                    // Add those many days to into previous card updated start date to get start date of the current card.
                    successorCards[i].leankor__StartDateTime__c = successorWorkWeek.nextBusinessDate(successorCards[i-1].leankor__StartDateTime__c, workingDaysCount);
                }

                //Calculate due date
                successorCards[i].leankor__DueDateTime__c = successorWorkWeek.nextBusinessDate(successorCards[i].leankor__StartDateTime__c, ED);

                successorCards[i].leankor__StartDate__c = successorCards[i].leankor__StartDateTime__c.date();
                successorCards[i].leankor__DueDate__c = successorCards[i].leankor__DueDateTime__c.date();
            }

            /** Date: 12/11/2019 - changes for blackout
            for(Integer i = 0; i < successorCards.size(); i++) {
                //Calculate estimated duration before moving dates
                Integer estimatedDuration;
                if(successorCards[i].leankor__DurationUnits__c != 'Days') {
                    estimatedDuration = (successorCards[i].leankor__StartDate__c.daysBetween(successorCards[i].leankor__DueDate__c) + 1) - getNonWorkingDaysAmount(successorCards[i].leankor__StartDateTime__c, successorCards[i].leankor__DueDateTime__c, nonBulkWorkWeekObj);
                } else {
                    estimatedDuration = successorCards[i].leankor__EstimatedDuration__c.intValue();
                }
                //Calculate start date
                if (i == 0) {
                    Date startDate = Date.newInstance(successorCards[0].leankor__StartDateTime__c.year(), successorCards[0].leankor__StartDateTime__c.month(), successorCards[0].leankor__StartDateTime__c.day());
                    workingDaysCount = getDateGap(firstMiniatureStartDate, startDate, nonBulkWorkWeekObj);
                    //System.debug('My working day count: ' + workingDaysCount);
                    successorCards[0].leankor__StartDateTime__c = addWorkingDaysTime(firstMiniatureStartDateTimeAdjusted, workingDaysCount, nonBulkWorkWeekObj);
                    //System.debug('My Start date: ' + successorCards[0].leankor__StartDateTime__c);
                    //System.debug('My firstMiniatureStartDateTimeAdjusted: ' + firstMiniatureStartDateTimeAdjusted);
                    //Date finalStartDate = Date.newInstance(successorCards[0].leankor__StartDateTime__c.year(), successorCards[0].leankor__StartDateTime__c.month(), successorCards[0].leankor__StartDateTime__c.day()); 
                }else {
                    Date startDate = Date.newInstance(successorCards[i].leankor__StartDateTime__c.year(), successorCards[i].leankor__StartDateTime__c.month(), successorCards[i].leankor__StartDateTime__c.day());
                    workingDaysCount = getDateGap(previousCardDate.date(), startDate, nonBulkWorkWeekObj);
                    previousCardDate = successorCards[i].leankor__StartDateTime__c;
                    //Date startDateMoved = Date.newInstance(successorCards[i-1].leankor__StartDateTime__c.year(), successorCards[i-1].leankor__StartDateTime__c.month(), successorCards[i-1].leankor__StartDateTime__c.day());
                    successorCards[i].leankor__StartDateTime__c = addWorkingDaysTime(successorCards[i-1].leankor__StartDateTime__c, workingDaysCount, nonBulkWorkWeekObj);
                    //Date finalStartDate = Date.newInstance(successorCards[i].leankor__StartDateTime__c.year(), successorCards[i].leankor__StartDateTime__c.month(), successorCards[i].leankor__StartDateTime__c.day());
                }
                //Calculate due date
                successorCards[i].leankor__DueDateTime__c = successorCards[i].leankor__StartDateTime__c;
                //Add duration one day at a time
                for(Integer j = 0; j<estimatedDuration - 1; j++) {
                    successorCards[i].leankor__DueDateTime__c = successorCards[i].leankor__DueDateTime__c.addDays(1);
                    if(!nonBulkWorkWeekObj.isWorkingDay(successorCards[i].leankor__DueDateTime__c.format('EEEE'))) {
                        //Make adjustments if start date lands on a non working day
                        successorCards[i].leankor__DueDateTime__c = Util.WorkWeek.readNextWorkingDateTime(nonBulkWorkWeekObj, successorCards[i].leankor__DueDateTime__c);
                    }
                }
                successorCards[i].leankor__StartDate__c = successorCards[i].leankor__StartDateTime__c.date();
                successorCards[i].leankor__DueDate__c = successorCards[i].leankor__DueDateTime__c.date();
            }
             */

        }

        //Set IsSuccessorRecalculate value to true
        for(leankor__Kanbancard__c successorCard : successorCards) {
            //after Updation need to send data for GS broadcast
            leankor.GanttTaskBoard.MiniatureCard ssrCard = new leankor.GanttTaskBoard.MiniatureCard();
            ssrCard.Id = successorCard.Id;
            ssrCard.ValueStreamID = successorCard.leankor__ValueStream__c;
            
            //responseKanbanCardList.add(miniatureData);
            //Add miniature card data in response
            miniatureSuccessorCards.add(ssrCard);
            
            //successorCard.leankor__IsSuccessorRecalculate__c = true;
            jsonDataList = broadcastContentMap.containsKey(successorCard.leankor__ValueStream__c) ? broadcastContentMap.get(successorCard.leankor__ValueStream__c) : new List<String>();
            jsonDataList.add(successorCard.Id);
            broadcastContentMap.put(successorCard.leankor__ValueStream__c, jsonDataList);
            if(successorCard.leankor__ValueStreamCardLink__c != null) {
                //Only update for Gantt or Rollup board
                if(successorCard.leankor__ValueStreamCardLink__r.leankor__BoardType__c == 'Plan Board' || successorCard.leankor__ValueStreamCardLink__r.leankor__BoardType__c == 'UberBoard') {
                    valueStreamCardLinkCardIds.add(successorCard.leankor__ValueStreamCardLink__c);
                    //successorCard.leankor__ValueStreamCardLink__r.leankor__IsSuccessorRecalculate__c = true;
                }
            }
            //For task updation
            dateDifferenceMap.put(successorCard.Id, new GanttTaskBoard.TaskPlan());
        }
        //--------------------------- SUCCESSOR

        //ValueStreamCardLinkCards

        List<leankor__Kanbancard__c> valueStreamCardLinkCards = fixCardDatesValueStreamCardLinkCardsQuery(valueStreamCardLinkCardIds);
        for (leankor__Kanbancard__c valueStreamCardLinkCard : valueStreamCardLinkCards) {
            valueStreamCardLinkCard.leankor__IsSuccessorRecalculate__c = true;
        }
        //ValueStreamCardLinkCards
        
        if (dateDifferenceMap.keySet().isEmpty()) {
            return responseKanbanCardList;
        }

        List<Task> tasks = fixCardDatesTasksQuery(dateDifferenceMap.keyset());
        if(!tasks.isEmpty()) {
            Date previousTaskDate = tasks[0].ActivityDate;
            Integer daysBetweenTask;
            Integer nonWorkingDaysTaskCount;
            Integer workingDaysCount = 0;
            leankor.Util.WorkWeek taskWorkWeek;

            for(Integer i = 0; i < tasks.size(); i++) {

                // Get the work week for the task 
                taskWorkWeek = vsWorkWeekMap.get(cardVSMap.get(tasks[i].WhatId)); 

                if (i == 0) {
                    //workingDaysCount = getDateGap(firstMiniatureStartDate, tasks[0].ActivityDate, nonBulkWorkWeekObj);
                    //tasks[0].ActivityDate = addWorkingDays(firstMiniatureStartDateAdjusted, workingDaysCount, nonBulkWorkWeekObj);
                    workingDaysCount = taskWorkWeek.getBusinessDays(firstMiniatureStartDate, tasks[0].ActivityDate);
                    tasks[0].ActivityDate = (taskWorkWeek.nextBusinessDate(firstMiniatureStartDateAdjusted, workingDaysCount)).dateGmt();
                }else {
                    //workingDaysCount = getDateGap(previousTaskDate, tasks[i].ActivityDate, nonBulkWorkWeekObj);
                    //previousTaskDate = tasks[i].ActivityDate;
                    //tasks[i].ActivityDate = addWorkingDays(tasks[i-1].ActivityDate, workingDaysCount, nonBulkWorkWeekObj);
                    workingDaysCount = taskWorkWeek.getBusinessDays(previousTaskDate, tasks[i].ActivityDate);
                    previousTaskDate = tasks[i].ActivityDate;
                    tasks[i].ActivityDate = (taskWorkWeek.nextBusinessDate(tasks[i-1].ActivityDate, workingDaysCount)).dateGmt();
                }
            }
        }

        GanttTaskBoard.KanbanCard responseData = new GanttTaskBoard.KanbanCard();
        if(miniatureCards.size()>0){

            responseData.miniatureCards = miniatureCards;
        }
        
        if(miniatureSuccessorCards.size()>0){
            responseData.miniatureSuccessorCards = miniatureSuccessorCards;
        }
        responseKanbanCardList.add(responseData);
        //responseKanbanCardList = setFixCardDatesAccordingToActivityUpdateRecords(updateCards, successorCards, tasks, responseKanbanCardList);
        responseKanbanCardList = setFixCardDatesAccordingToActivityUpdateRecords(updateCards, successorCards, valueStreamCardLinkCards, tasks, responseKanbanCardList);
        
        //Broadcast for valuestreamcardlink
        for(leankor__Kanbancard__c valuestreamcardlink : valueStreamCardLinkCards){
            jsonDataList = broadcastContentMap.containsKey(valuestreamcardlink.leankor__ValueStream__c) ? broadcastContentMap.get(valuestreamcardlink.leankor__ValueStream__c) : new List<String>();
            jsonDataList.add(valuestreamcardlink.Id);
            broadcastContentMap.put(valuestreamcardlink.leankor__ValueStream__c, jsonDataList);
            
             //after Updation need to send data for GS broadcast
            leankor.GanttTaskBoard.MiniatureCard vscardlinkCards = new leankor.GanttTaskBoard.MiniatureCard();
            vscardlinkCards.Id = valuestreamcardlink.Id;
            vscardlinkCards.ValueStreamID = valuestreamcardlink.leankor__ValueStream__c;           
            
            //Added miniature's successor's parent card data in response
            miniatureSuccessorCards.add(vscardlinkCards);
        }       
        
        system.debug('broadcastContentMap = ' + broadcastContentMap);
        
        //Send broadcast in Pushtopic of Updated miniature cards 
        if(responseKanbanCardList[0].miniatureCards.size()>0){
            //leankor.GenericStreamingController.createRTForMultipleBoards('UpdateMultipleKanbanCards', jsonDataList, UserInfo.getSessionId());
            leankor.GenericStreamingController.tempCreateRTForMultipleBoards('UpdateMultipleKanbanCards', broadcastContentMap, UserInfo.getSessionId());
        }
        return responseKanbanCardList;
    }

    @TestVisible
    private static Integer divideCeiling(Integer x, Integer y) {
        return Math.ceil(Decimal.valueOf(x).divide(y, 1)).intValue();
    }

    @TestVisible
    private static List<leankor.GanttTaskBoard.KanbanCard> setFixCardDatesAccordingToActivityUpdateRecords(List<leankor__KanbanCard__c> updateCards, List<leankor__KanbanCard__c> successorCards, List<leankor__KanbanCard__c> valueStreamCardLinkCards, List<Task> tasks, List<leankor.GanttTaskBoard.KanbanCard> responseKanbanCardList){
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();     
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        /*
        Integer kanbanCardtypeSize = updateCards.size() + successorCards.size();
        Integer taskTypeSize = tasks.size();

        //Can only have 10 chunks with 200 records per chunk
        if(divideCeiling(kanbanCardtypeSize, 200) + divideCeiling(taskTypeSize, 200) > 10) {
            List<leankor__KanbanCard__c> kanbanCardBlock = new List<leankor__Kanbancard__c>();
            kanbanCardBlock.addAll(updateCards);
            kanbanCardBlock.addAll(successorCards);
            Savepoint updateSavepoint = Database.setSavepoint();
            try {
                DataBase.update(kanbanCardBlock);
                DataBase.update(tasks);
            }catch (DmlException e) {
                System.debug(e);
                Database.rollback(updateSavepoint);
                //Return blank list if exception
                return new List<leankor.GanttTaskBoard.KanbanCard>();
            }
        
        }else {
            List<SObject> allUpdateRecords = new List<SObject>();
            //Add cards into update block
            for(leankor__KanbanCard__c updateCard : updateCards) {
                allUpdateRecords.add(updateCard);
            }

            //Add dependent cards into update block
            for(leankor__KanbanCard__c successorCard : successorCards) {
                allUpdateRecords.add(successorCard);
            }

            //Add tasks into update block
            for(Task task : tasks) {
                allUpdateRecords.add(task);
            }
            try {
                DataBase.update(allUpdateRecords);
            }catch (DmlException e) {
                System.debug(e);
                //Return blank list if exception
                return new List<leankor.GanttTaskBoard.KanbanCard>();
            }
        }
        */
        //Make a set so that we don't add duplicate cards
        Set<leankor__KanbanCard__c> kanbanCardBlockSet = new Set<leankor__Kanbancard__c>();
        kanbanCardBlockSet.addAll(updateCards);
        kanbanCardBlockSet.addAll(successorCards);
        kanbanCardBlockSet.addAll(valueStreamCardLinkCards);
        //Copy set items into list since update takes in a list type not a set
        List<leankor__KanbanCard__c> kanbanCardBlockList = new List<leankor__KanbanCard__c>(kanbanCardBlockSet);
        Savepoint updateSavepoint = Database.setSavepoint();
        try {
            DataBase.update(kanbanCardBlockList);
            leankor.OpenTaskRestriction.updateTask(tasks);
        }catch (DmlException e) {
            System.debug(e);
            Database.rollback(updateSavepoint);
            //Return blank list if exception
            //return new List<leankor.GanttTaskBoard.KanbanCard>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage()); 
        } 
                
        //No exceptions just return the original
        return responseKanbanCardList;
    }

    // kanbanCardGroupIds - circular reference is not allowed, this is used to determine if there is one
    // Look at runtime later on because dependency list is always being looped on
    public static Set<Id> getAllDependentCardIds(List<leankor__Dependency__c> dependencies, Set<Id> kanbanCardIds, Map<Id, GanttTaskboard.MiniatureCard> responseKanbanCardMap, Set<Id> kanbanCardGroupIds) {
        if (kanbanCardIds.isEmpty()) {
           return kanbanCardIds;
        }
        Set<Id> newIds = new Set<Id>();
        for (leankor__Dependency__c dependency : dependencies) {
           if(kanbanCardIds.contains(dependency.leankor__Predecessor__c) && dependency.leankor__Successor__c != null) {
               newIds.add(dependency.leankor__Successor__c);

               // circular reference logic
               kanbanCardGroupIds.add(dependency.leankor__Successor__c);
               if (dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c != null && !kanbanCardGroupIds.contains(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c)) {
                   //newIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
                   kanbanCardGroupIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
               }

               if(responseKanbanCardMap.containsKey(dependency.leankor__Predecessor__c)) {
                   GanttTaskboard.MiniatureCard tempCard = responseKanbanCardMap.get(dependency.leankor__Predecessor__c);
                   //tempCard.hasDependency = true;
                   responseKanbanCardMap.put(dependency.leankor__Predecessor__c, tempCard);
               }
           }
        }
        newIds.addAll(getAllDependentCardIds(dependencies, newIds, responseKanbanCardMap, kanbanCardGroupIds));
        return newIds;
    }

	/*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    get all affected successor card ids of predecessor items
    Inputs:         List<leankor__Dependency__c> dependencies, Set<Id> kanbanCardIds, Map<Id, leankor__KanbanCard__c> kanbanCardMap, Set<Id> kanbanCardGroupIds
    Returns:        Set<Id>
    ------------------------------------------------------------*/
    public static Set<Id> getAllDependentCardIds(List<leankor__Dependency__c> dependencies, Set<Id> kanbanCardIds, Map<Id, leankor__KanbanCard__c> kanbanCardMap, Set<Id> kanbanCardGroupIds) {
        if (kanbanCardIds.isEmpty()) {
           return kanbanCardIds;
        }
        Set<Id> newIds = new Set<Id>();
        for (leankor__Dependency__c dependency : dependencies) {
        	System.debug(dependency);
           if(kanbanCardIds.contains(dependency.leankor__Predecessor__c) && dependency.leankor__Successor__c != null) {
               newIds.add(dependency.leankor__Successor__c);

               // circular reference logic
               kanbanCardGroupIds.add(dependency.leankor__Successor__c);
               if (dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c != null && !kanbanCardGroupIds.contains(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c)) {
                   //newIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
                   kanbanCardGroupIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
               }

               if(kanbanCardMap.containsKey(dependency.leankor__Predecessor__c)) {
                   leankor__KanbanCard__c tempCard = kanbanCardMap.get(dependency.leankor__Predecessor__c);
                   //tempCard.hasDependency = true;
                   kanbanCardMap.put(dependency.leankor__Predecessor__c, tempCard);
               }
           }
        }
        newIds.addAll(getAllDependentCardIds(dependencies, newIds, kanbanCardMap, kanbanCardGroupIds));
        System.debug(newIds);
        return newIds;
    }

    //Overloaded method removes manual paths based on boolean value, must pass in manually scheduled ids
    public static Set<Id> getAllDependentCardIds(List<leankor__Dependency__c> dependencies, Set<Id> kanbanCardIds, Set<Id> scheduleModeIds, Map<Id, GanttTaskboard.MiniatureCard> responseKanbanCardMap, Set<Id> kanbanCardGroupIds, Boolean excludeManualPaths) {
        //Remove manual paths if set
        if(excludeManualPaths) {
            for(Id kanbanCardId : kanbanCardIds) {
                if(scheduleModeIds.contains(kanbanCardId)) {
                    kanbanCardIds.remove(kanbanCardId);
                }
            }
        }
        if (kanbanCardIds.isEmpty()) {
           return kanbanCardIds;
        }
        Set<Id> newIds = new Set<Id>();
        for (leankor__Dependency__c dependency : dependencies) {
           if(kanbanCardIds.contains(dependency.leankor__Predecessor__c) && dependency.leankor__Successor__c != null) {
               newIds.add(dependency.leankor__Successor__c);

               // circular reference logic
               kanbanCardGroupIds.add(dependency.leankor__Successor__c);
               if (dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c != null && !kanbanCardGroupIds.contains(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c)) {
                   //newIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
                   kanbanCardGroupIds.add(dependency.leankor__Successor__r.leankor__ValueStreamCardLink__c);
               }

               if(responseKanbanCardMap.containsKey(dependency.leankor__Predecessor__c)) {
                   GanttTaskboard.MiniatureCard tempCard = responseKanbanCardMap.get(dependency.leankor__Predecessor__c);
                   //tempCard.hasDependency = true;
                   responseKanbanCardMap.put(dependency.leankor__Predecessor__c, tempCard);
               }
           }
        }
        newIds.addAll(getAllDependentCardIds(dependencies, newIds, scheduleModeIds, responseKanbanCardMap, kanbanCardGroupIds, excludeManualPaths));
        return newIds;
    }
    
    @AuraEnabled
    @RemoteAction
    global static List<sObject> updateCardRecords(List<sObject> kcJSON) {
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        if(!checkKanbanCardBehaviour.isAccessible() ||
            !checkKanbanCardBehaviour.isUpdateable()){
                System.debug('Error: No access to records');
                throw new Util.LeanException('Error: No access to records');
        }
        // Tilak Raj Mahale: 18.06.2020 - To remove duplicate records from the list
        Map<Id, sObject> kanbanMap = new Map<Id, sObject>();
        Map<Id, sObject> kanbanRecords = new Map<Id, sObject>();
        Map<Id,leankor__KanbanCard__c> oldKanbanCard;
        for (sObject sObj: kcJSON) {
            kanbanMap.put(sObj.Id, sObj);
            if(Util.getSObjectName(sObj.Id) == 'leankor__kanbancard__c'){
                kanbanRecords.put(sObj.Id, sObj);
            }
        }

        if(kanbanRecords.size()>0){
            oldKanbanCard = new Map<Id,leankor__KanbanCard__c>([Select 
                                                                    Id,
                                                                    Name,
                                                                    leankor__StartDateTime__c,
                                                                    leankor__StartDate__c,
                                                                    leankor__DueDateTime__c, 
                                                                    leankor__DueDate__c,
                                                                    leankor__EstimatedDuration__c
                                                                From leankor__KanbanCard__c
                                                                Where Id In : kanbanRecords.keySet()]);
        }

        // 17/05/2023 IF we getting Null value from UI end for Following Fields so we set old values of the KanbanCards
        if(kanbanRecords.size()>0){
            for(sObject singleKanbanCard : kanbanMap.values()){
                if(Util.getSObjectName(singleKanbanCard.Id) == 'leankor__kanbancard__c'){
                    if(singleKanbanCard.get('leankor__StartDateTime__c') == null){
                        singleKanbanCard.put('leankor__StartDateTime__c',  oldKanbanCard.get(singleKanbanCard.Id).leankor__StartDateTime__c);
                    }
                    if(singleKanbanCard.get('leankor__StartDate__c') == null){
                        singleKanbanCard.put('leankor__StartDate__c',  oldKanbanCard.get(singleKanbanCard.Id).leankor__StartDate__c);
                    }
                    if(singleKanbanCard.get('leankor__DueDateTime__c') == null){
                        singleKanbanCard.put('leankor__DueDateTime__c',  oldKanbanCard.get(singleKanbanCard.Id).leankor__DueDateTime__c);
                    }
                    if(singleKanbanCard.get('leankor__DueDate__c') == null){
                        singleKanbanCard.put('leankor__DueDate__c',  oldKanbanCard.get(singleKanbanCard.Id).leankor__DueDate__c);
                    }
                }
            }
        }

        try{
            update kanbanMap.values();
        }
        catch(System.DmlException e){ 
            System.debug('ERROR: ' + e.getMessage());   
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());          
        }
        
        return kcJSON;
    }
    
      // Date : 10/04/19
    global class RecordCount{
            public Integer chattersCount;
            public Integer filesCount;
            public Integer riskCount;
                            
            RecordCount(){
                chattersCount=0;
                filesCount=0;
                riskCount=0;
            }
        } 

    /*
    Date : 10/04/19
    Used to count  risk,chatter,file records .
    */
    @RemoteAction
    global static Map<String ,RecordCount> readRelatedRecordCount(List<String> ids){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour(); 
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !issueLogBehaviour.isAccessible() ||
            !taskBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List <RecordCount> returnList = new List <RecordCount>();
        //To map  card id with inner class RecordCount.
        Map<String, RecordCount> mapOfRecord = new Map<String, RecordCount>();                   
        try{
            // To count number of chatter and file records  based on Kanbancards id.            
            //for(AggregateResult  feedItem: [Select count(Id)chatter,count(RelatedRecordId)file, ParentId From leankor__KanbanCard__Feed  Where ParentId  IN:kanbanCards GROUP BY ParentId  Limit 9999]){                               
            for(AggregateResult  feedItem: [SELECT 
                                                count(Id)chatter,
                                                count(RelatedRecordId)file, 
                                                ParentId 
                                            FROM leankor__KanbanCard__Feed  
                                            WHERE ParentId IN (SELECT Id 
                                                                FROM leankor__KanbanCard__c 
                                                                WHERE (Id IN: Ids OR 
                                                                    leankor__ValueStream__c IN: ids) 
                                                                    AND leankor__IsRecordDeleted__c = false 
                                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false) 
                                            GROUP BY ParentId  
                                            LIMIT 49999]){
                RecordCount recordCount = new RecordCount();
                recordCount.chattersCount = Integer.valueOf(feedItem.get('chatter'));                 
                recordCount.filesCount = Integer.valueOf(feedItem.get('file'));
                String cardId = String.valueOf(feedItem.get('ParentId'));   
                mapOfRecord.put(cardId,recordCount);                                                   
            }   
            // To count only unresolved number of Risk records based on KanbanCards id.                 
            //for(AggregateResult   issueLog : [Select count(Id)risk, leankor__kanbancard__c From  leankor__IssueLog__c Where leankor__kanbancard__c =: kanbanCards AND leankor__Resolved__c = FALSE GROUP BY leankor__kanbancard__c Limit 9999]){                 
            for(AggregateResult   issueLog : [SELECT 
                                                    count(Id)risk, 
                                                    leankor__kanbancard__c 
                                                FROM  leankor__IssueLog__c 
                                                WHERE leankor__kanbancard__c IN (SELECT Id 
                                                                                FROM leankor__KanbanCard__c 
                                                                                WHERE (id IN: Ids 
                                                                                        OR leankor__ValueStream__c IN: ids) 
                                                                                    AND leankor__IsRecordDeleted__c = false 
                                                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false) 
                                                    AND leankor__Resolved__c = FALSE 
                                                GROUP BY leankor__kanbancard__c 
                                                LIMIT 9999]){
                RecordCount recordCount = mapOfRecord.containsKey(String.valueOf(issueLog.get('leankor__kanbancard__c'))) ? mapOfRecord.get(String.valueOf(issueLog.get('leankor__kanbancard__c')))  : new RecordCount();
                recordCount.riskCount = Integer.valueOf(issueLog.get('risk'));
                String cardId = String.valueOf(issueLog.get('leankor__kanbancard__c'));
                mapOfRecord.put(cardId,recordCount);
            }
            // Date: 28/08/2019 - Realated to return the task with chatter count.    
            //if(kanbanCards[0].leankor__BoardType__c != 'UberBoard'){
                List<String> boardTypeFilters = new List<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
                // Geting the task.
                List<Task> taskList = [SELECT Id FROM Task WHERE WhatId In (SELECT Id 
                                                                                FROM leankor__KanbanCard__c 
                                                                                WHERE (id IN: Ids OR leankor__ValueStream__c IN: ids) 
                                                                                    AND leankor__IsRecordDeleted__c = false 
                                                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                                                                    AND leankor__BoardType__c in : boardTypeFilters) 
                                        LIMIT 9999];
                if(taskList.size()>0){
                    Map<Id,Integer> mapFeed = leankor.kanbanController.getTaskChatterCounts(taskList);
                    for(Id tsk : mapFeed.keyset()){
                        RecordCount recordCount = mapOfRecord.containsKey(tsk) ? mapOfRecord.get(tsk) : new RecordCount();
                        recordCount.chattersCount = mapFeed.get(tsk);
                        mapOfRecord.put(tsk,recordCount);
                    }
                }		            	                    
            //}
                                        
        }catch(Exception ex){
            System.debug(ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
    
        return mapOfRecord;                         
    }

    @AuraEnabled
    public static Map<String ,RecordCountData> fatchRelatedRecordCount(List<String> ids) {
        // Fetch record counts
        Map<String, RecordCount> mapOfRecord = readRelatedRecordCount(ids); 
        
        // Final result wrapper map
        Map<String, RecordCountData> mapOFRecordCount = new Map<String, RecordCountData>();

        for (String recId : mapOfRecord.keySet()) {
            RecordCount rc = mapOfRecord.get(recId);

            // Initialize wrapper
            RecordCountData rcData = new RecordCountData();

            // Assuming RecordCount has fields chatterCount, fileCount, riskCount
            rcData.chattersCount = rc.chattersCount;
            rcData.filesCount    = rc.filesCount;
            rcData.riskCount     = rc.riskCount;

            mapOFRecordCount.put(recId, rcData);
        }
        return mapOFRecordCount;
    }


    global class ChatterDataRecord {
        public List<String> recordIds;
        public String recordType;
        public List<String> valueStreamIds; 
        public String verb;
        public String sessionId;
    }
    
    global class ChatterDataResponse {
        public Map<String, RecordCount> recordCountMap = new Map<String, RecordCount>();
        public Map<String, FieldServiceUtilityController.RecordDetails> fslRecordCountMap = new Map<String, FieldServiceUtilityController.RecordDetails>();
        public List<Id> valueStreamIds;
    }
    
    @RemoteAction
    global static GanttTaskBoard.ChatterDataResponse getChatterComments(ChatterDataRecord chatterDataRecord) {
    
        // Check CRUD / FLS behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        
        if (!kanbanCardBehaviour.isAccessible() || !issueLogBehaviour.isAccessible() || !taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        // Check CRUD / FLS behavior
    
        GanttTaskBoard.ChatterDataResponse responseInstance = new GanttTaskBoard.ChatterDataResponse();
        Map<String, RecordCount> recordCountMap = new Map<String, RecordCount>();
        Map<String, FieldServiceUtilityController.RecordDetails> fslRecordCountMap = new Map<String, FieldServiceUtilityController.RecordDetails>();
    
        recordCountMap = readRelatedRecordCount(chatterDataRecord.recordIds);
        fslRecordCountMap = FieldServiceUtilityController.readCardsFSLInfo(chatterDataRecord.recordIds, chatterDataRecord.recordType);
        
        responseInstance.recordCountMap = recordCountMap;
        responseInstance.valueStreamIds = chatterDataRecord.valueStreamIds;
        
        String jsonResponse = JSON.serialize(responseInstance);
        LeankorOperationController.sendBroadcast(chatterDataRecord.verb, jsonResponse, chatterDataRecord.sessionId);
        
        responseInstance.fslRecordCountMap = fslRecordCountMap;
        return responseInstance;
    }

        
        
    Global class CloningData{
        public string newFolderId;
        public string oldFolderId;
        public string valueStreamID; 
        //public Boolean isNav;
    }

    @RemoteAction
    Global static KanbanToGanttController.CloneCardData readGanttTasks(string ganttData) {

        CloningData cloneData = (CloningData)JSON.deserialize(ganttData, CloningData.class);
        KanbanToGanttController.CloneCardData result = new KanbanToGanttController.CloneCardData();
        Set < String > activityIds = new Set < String > ();                
        Map < Id,RecordType > recordTypeMap = new Map < Id, RecordType > ([SELECT 
                                                                                Id, 
                                                                                Name, 
                                                                                SobjectType 
                                                                            FROM RecordType 
                                                                            WHERE SobjectType = 'leankor__KanbanCard__c']);
        
        // Add value stream Id into a set
        Set<String> valuestreamIDs = new Set<String>();
        valuestreamIDs.add(String.escapeSingleQuotes(cloneData.valueStreamId));
        // Creating the map for parent cards
        Map < String,List < leankor__Kanbancard__c >> mapOfListCards = leankor.GanttTaskBoard.createMapOfListCards(getPlanBoardKanbanCards('', valuestreamIDs));
    
        if (string.isNotBlank(cloneData.newFolderId)) {
    
            //for (leankor__KanbanCard__c knbnCard: listOfKanbancards  ) {
            for (leankor__KanbanCard__c knbnCard: RealTimeControllerHelper.readGanttTaskRecords(cloneData.newFolderId)) {
                // Adding card Id's into set so that we can retrive resource.
                activityIds.add(knbnCard.Id);                  
                if ((knbnCard.leankor__GUID__C).SubStringBefore('-') == cloneData.oldFolderId) {
                    
                    leankor.KanbanToGanttController.MasterContainer kanbanCardWrapper = new leankor.KanbanToGanttController.MasterContainer();
                    kanbanCardWrapper.Id = knbnCard.Id;
                    kanbanCardWrapper.Name = knbnCard.Name;
                    kanbanCardWrapper.isMilestone = (recordTypeMap.get(knbnCard.RecordTypeId).Name == 'MilestoneCard' ? true : false);
                    kanbanCardWrapper.Title = knbnCard.leankor__Title__c;
                    kanbanCardWrapper.ValueStreamID = knbnCard.leankor__ValueStream__c;
                    kanbanCardWrapper.CmpID = knbnCard.leankor__CmpID__c;
                    kanbanCardWrapper.GUID = knbnCard.leankor__GUID__c;
                    kanbanCardWrapper.Order = knbnCard.leankor__Order__c;
                    kanbanCardWrapper.StartDate = JSON.Serialize(knbnCard.leankor__StartDateTime__c);
                    kanbanCardWrapper.DueDate = JSON.Serialize(knbnCard.leankor__DueDateTime__c);
                    kanbanCardWrapper.PercentDone = KnbnCard.leankor__PercentComplete2__c;
                    kanbanCardWrapper.leaf = (recordTypeMap.get(knbnCard.RecordTypeId).Name == 'FolderCard' ? false : true);
                    kanbanCardWrapper.EstimatedDuration = KnbnCard.leankor__EstimatedDuration__c;
                    kanbanCardWrapper.DurationUnits = KnbnCard.leankor__DurationUnits__c == 'Days' ? 'd' : (KnbnCard.leankor__DurationUnits__c == 'Weeks' ? 'w' : (KnbnCard.leankor__DurationUnits__c == 'Hours' ? 'h' : (KnbnCard.leankor__DurationUnits__c == 'Months' ? 'mo' : (KnbnCard.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
                    kanbanCardWrapper.CardID = knbnCard.leankor__CardID__c;
                    kanbanCardWrapper.EffortRemaining = integer.valueof(KnbnCard.leankor__EffortRemaining__c);
                    kanbanCardWrapper.ForceID = (knbnCard.ID == null ? '' : knbnCard.ID);
                    kanbanCardWrapper.TemplateID = (KnbnCard.leankor__KanbanCardTemplate__c == null ? '' : KnbnCard.leankor__KanbanCardTemplate__c);
                    kanbanCardWrapper.TemplateName = KnbnCard.leankor__KanbanCardTemplate__r.Name;
                    kanbanCardWrapper.Priority = Integer.valueOf(KnbnCard.leankor__Priority__c);
                    kanbanCardWrapper.HarveyBall = string.valueOf(KnbnCard.leankor__PercentComplete2__c);
                    kanbanCardWrapper.Description = KnbnCard.leankor__DescriptionLong__c;
                    kanbanCardWrapper.ValueStreamCardLink = (KnbnCard.leankor__ValueStreamCardLink__c == null ? '' : KnbnCard.leankor__ValueStreamCardLink__c);
                    kanbanCardWrapper.ValueStreamLinkID = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__c);
                    kanbanCardWrapper.ValueStreamCardLinkName = (KnbnCard.leankor__ValueStreamCardLink__c == null ? '' : KnbnCard.leankor__ValueStreamCardLink__r.Name);
                    kanbanCardWrapper.ValueStreamLinkIDName = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__r.Name);
                    kanbanCardWrapper.ValueStreamLinkBoardType = (KnbnCard.leankor__ValueStreamLink__c == null ? '' : KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);
                    kanbanCardWrapper.OwnerID = KnbnCard.OwnerID;
                    kanbanCardWrapper.KanbanUrl = '';
                    kanbanCardWrapper.BoardType = KnbnCard.leankor__ValueStream__r.leankor__Boardtype__c;
                    kanbanCardWrapper.OnBudget = KnbnCard.leankor__OnBudget__c;
                    kanbanCardWrapper.OnQuality = KnbnCard.leankor__OnQuality__c;
                    kanbanCardWrapper.OnTime = KnbnCard.leankor__OnTime__c;
                    kanbanCardWrapper.OwnerName = KnbnCard.Owner.Name;
                    kanbanCardWrapper.ItemType = recordTypeMap.get(knbnCard.RecordTypeId).Name;
                    kanbanCardWrapper.JSONDefinition = KnbnCard.leankor__JSONDefinition__c;
                    kanbanCardWrapper.JSONData = KnbnCard.leankor__JSONData__c;
                    kanbanCardWrapper.Color = (KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c == null ? '' : KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c);
                    kanbanCardWrapper.isAtRisk = KnbnCard.leankor__IsAtRisk__c;
                    kanbanCardWrapper.isOnHold = KnbnCard.leankor__IsOnHold__c;
                    kanbanCardWrapper.timeToProjectLaunch = (String.isNotBlank(String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c))) ? String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c.intValue()): '';
                    
                    // For Icon and type was not getting updated of linked activity after move card template MC to another MC
                    if (kanbanCardWrapper.ItemType == 'MilestoneCard' && kanbanCardWrapper.EstimatedDuration != 0) {
                        kanbanCardWrapper.ItemType = 'ActivityCard';
                    }
    
                    kanbanCardWrapper.IsRecalculate = knbnCard.leankor__Valuestream__r.leankor__Isrecalculate__c;
                    kanbanCardWrapper.IsExternallyDependent = KnbnCard.leankor__IsExternallyDependent__c;
                    // adding leankor__IsSuccessorRecalculate__c field for Recalculation of linked activity
                    kanbanCardWrapper.IsSuccessorRecalculate = KnbnCard.leankor__IsSuccessorRecalculate__c;
    
                    if (KnbnCard.leankor__ScheduleModes__r.size() > 0) {
                        kanbanCardWrapper.ManuallyScheduled = KnbnCard.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c; //KnbnCard.leankor__ValueStream__r.leankor__ManuallyScheduled__c;
                        kanbanCardWrapper.SchedulingMode = KnbnCard.leankor__ScheduleModes__r[0].leankor__Mode__c; //KnbnCard.leankor__ValueStream__r.leankor__Mode__c;
                        kanbanCardWrapper.EffortUnit = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                        kanbanCardWrapper.Effort = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                        kanbanCardWrapper.SchedulingModeId = KnbnCard.leankor__ScheduleModes__r[0].Id;
                        //Changes : Check constraint setting is enable or not. 
                        if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                            kanbanCardWrapper.ConstraintType = (KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c)) ? KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : '';
                            kanbanCardWrapper.ConstraintDate = (KnbnCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null) ? KnbnCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                        }
					}
                    if (KnbnCard.leankor__Kanban_Card_Baselines__r.size() > 0) {
                        kanbanCardWrapper.BaselineStartDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                        kanbanCardWrapper.BaselineEndDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c;
                    }
    
                    Map < String,FieldServiceUtilityController.RecordDetails > fslInfo = new Map < String,FieldServiceUtilityController.RecordDetails > ();
                    kanbanCardWrapper.children = leankor.GanttTaskBoard.childcardsRecursive(KnbnCard.Id, mapOfListCards, recordTypeMap, fslInfo);
                    
                     //Pratiksha : 24/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                    if(KnbnCard.leankor__Monday__c == false && KnbnCard.leankor__Tuesday__c == false && KnbnCard.leankor__Wednesday__c == false &&  KnbnCard.leankor__Thursday__c == false &&  KnbnCard.leankor__Friday__c == false &&  KnbnCard.leankor__Saturday__c == false &&  KnbnCard.leankor__Sunday__c == false){
                        kanbanCardWrapper.Monday = true;
                        kanbanCardWrapper.Tuesday = true;
                        kanbanCardWrapper.Wednesday = true;
                        kanbanCardWrapper.Thursday = true;
                        kanbanCardWrapper.Friday = true;
                        kanbanCardWrapper.Saturday = true;
                        kanbanCardWrapper.Sunday = true;
                    }else{            
                        kanbanCardWrapper.Monday = KnbnCard.leankor__Monday__c;
                        kanbanCardWrapper.Tuesday  = KnbnCard.leankor__Tuesday__c;
                        kanbanCardWrapper.Wednesday = KnbnCard.leankor__Wednesday__c;
                        kanbanCardWrapper.Thursday = KnbnCard.leankor__Thursday__c;
                        kanbanCardWrapper.Friday = KnbnCard.leankor__Friday__c;
                        kanbanCardWrapper.Saturday = KnbnCard.leankor__Saturday__c;
                        kanbanCardWrapper.Sunday = KnbnCard.leankor__Sunday__c;
                        kanbanCardWrapper.weekCalendar = KnbnCard.leankor__WeekCalendar__c;
                    }
                    result.Activity = kanbanCardWrapper;  
                }
            }
        }
        
        activityIds.addAll(cloneAGCardIds);
        cloneAGCardIds.clear();
        // In case of Leankor Nav we dont need the dependencies of the cards
        if(!ganttData.contains('isLeankorNav')){
            result.dependencyList = readCardsDependency(activityIds, cloneData.valueStreamId);
        }
        result.ResourceAssignmentData = leankor.GanttTaskBoard.getResources(activityIds);
        return result;
    }

    public static List < leankor.RealTimeController.Dependency > readCardsDependency(Set < string > activityIds, string valueStream) {
        //Check CRUD / FLC behavior 
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isAccessible()) {
                System.debug('Error: No access to records');
                throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
    
        List < leankor__Dependency__c > dependencyList = [SELECT Id, 
                                                                leankor__GUID__c, 
                                                                leankor__ValueStream__c,
                                                                leankor__LagLead__c, leankor__LagLeadUnit__c,
                                                                leankor__KanbanCard__C,
                                                                leankor__Predecessor__c,
                                                                leankor__Predecessor__r.leankor__ValueStream__C,
                                                                leankor__PredecessorType__c, leankor__Successor__c,
                                                                leankor__Successor__r.leankor__ValueStream__C,
                                                                leankor__SuccessorType__c
                                                        FROM leankor__Dependency__c 
                                                        WHERE (leankor__Predecessor__c IN: activityIds 
                                                            OR leankor__Successor__c IN: activityIds)
                                                            AND leankor__Predecessor__r.leankor__ValueStream__C = : valueStream 
                                                            AND leankor__Successor__r.leankor__ValueStream__C = : valueStream 
                                                            AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = False
                                                            AND leankor__Predecessor__r.leankor__isRecordDeleted__c = False
                                                            AND leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = False
                                                            AND leankor__Successor__r.leankor__isRecordDeleted__c = False
                                                            AND leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = False
                                                        lIMIT 9999];
        
        List < leankor.RealTimeController.Dependency > jsonDependencyList = new List < leankor.RealTimeController.Dependency > ();
        
        for (leankor__Dependency__c dep: dependencyList) {
            if(dep.leankor__Predecessor__r.leankor__ValueStream__C !=null && dep.leankor__Successor__r.leankor__ValueStream__C!=null){
                leankor.RealTimeController.Dependency Dependency = new leankor.RealTimeController.Dependency();
                String Type = dep.leankor__SuccessorType__c;
                Dependency.Id = dep.leankor__GUID__c;
                Dependency.FromId = dep.leankor__Predecessor__c;
                Dependency.FromVSID = dep.leankor__ValueStream__C;
                Dependency.To = dep.leankor__Successor__c;
                Dependency.ToVSID = dep.leankor__ValueStream__C;
                Dependency.Lag = Integer.valueof(dep.leankor__LagLead__c);
                Dependency.LagUnit = dep.leankor__LagLeadUnit__c;
                Dependency.Type = (Type == 'Start To Start' ? 0 : (Type == 'Start To Finish' ? 1 : (Type == 'Finish To Start' ? 2 : 3)));
             // Dependency.LagLeadDuration = dep.leankor__LagLeadDuration__c;
        
                jsonDependencyList.add(Dependency);
            }
        }
        
        return jsonDependencyList;
    }

    global  class ActivityWrapper{
        public List<leankor__Kanbancard__c> activity;
        public String boardType;
        public String valueStreamId;
        public String sessionID;
    }
    
    /*------------------------------------------------------------
    Company:        Leankor
    Description:    update miniature item's onHold and their successor's OnHold
    Inputs:         ActivityWrapper activityWrapper
    Returns:        String (serialized sync card ids)-
    Date : 			17/06/2019
    ------------------------------------------------------------*/
    @RemoteAction
    global static String updateKanbanCards (ActivityWrapper activityWrapper){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable()
        ) {
                System.debug('Error: No access to update records');
                throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<String> jsonDataList = new List<String>();
        String kanbanVerb='OnHoldItemsFalse';
        Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
        try{       	
            if(activityWrapper.activity.size()<0){
                return 'No cards updated';
            }	
            update activityWrapper.activity;
            if(activityWrapper.boardType=='UberBoard'){
                Map<Id,leankor__Kanbancard__c> actMap = new Map<Id,leankor__Kanbancard__c> (activityWrapper.activity);
                List<String> miniatureBoardTypes = new List<String> {'Kanban Board', 'Whiteboard', 'Plan Board', 'DashBoard'};
                List<leankor__KanbanCard__c> hasMiniature = [SELECT Id 
                                                            FROM leankor__KanbanCard__c  
                                                            WHERE leankor__ValueStreamCardLink__c IN: actMap.keySet() 
                                                                AND leankor__IsRecordDeleted__c = false 
                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                                                AND leankor__ValueStream__r.leankor__BoardType__c IN: miniatureBoardTypes 
                                                            LIMIT 1];
                if(!Test.isRunningTest() && hasMiniature.size()>0){
                    System.enqueueJob(new MiniatureCardsQueueable(activityWrapper));
                }
            }
            else if(activityWrapper.boardType=='Kanban Board'){
                Set<String> successorIds = new Set<String>();  
                List<leankor__KanbanCard__c> successors = new List<leankor__KanbanCard__c>(); 
                SuccessorCardsQeueuable successorQeueuable = new SuccessorCardsQeueuable(activityWrapper.activity, new Set<String>{activityWrapper.valueStreamId}, activityWrapper.sessionID);
                for(Id recordId : successorQeueuable.getSuccessors()){
                    successors.add(new leankor__KanbanCard__c(Id=recordId, leankor__IsOnHold__c=activityWrapper.activity[0].leankor__IsOnHold__c));
                    successorIds.add(recordId);
                }
                if(successors.size()>0){
                update successors;
                jsonDataList.addAll(successorIds);
                }
            }
            for(leankor__KanbanCard__c activity : activityWrapper.activity){
                jsonDataList.add(activity.Id);
                //Date :09/10/19 changes for onhold broadcast.
                if(activity.leankor__IsOnHold__c==true){
                    kanbanVerb='OnHoldItemsTrue';
                }
                broadcastContentMap.put(activityWrapper.valueStreamId, jsonDataList);
            }
            leankor.GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, activityWrapper.sessionID);
            System.debug('Update Limits:'+ Limits.getDmlStatements());
            
        }catch(Exception ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return JSON.serialize(jsonDataList);
    }
    	
    /*
        Date : 17/09/19
        To get resourceType records.
    */
    @RemoteAction
    global static RecordDetails readResourceTypes(Integer offsetSize, String filterValue, Integer limits){
        //Check CRUD / FLC behavior 
        ResourceTypeBehaviour resourceTypeBehaviour = new ResourceTypeBehaviour();
        if (!resourceTypeBehaviour.isAccessible()) {
                System.debug('Error: No access to records');
                throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        String filterVal = '%' + filterValue + '%'; // It can be '' or any string.
        Integer  count =[SELECT count() FROM leankor__ResourceType__c WHERE Name LIKE: filterVal];
        List<leankor__ResourceType__c> resourceTypeList = [SELECT Id, 
                                                                Name 
                                                            FROM leankor__ResourceType__c 
                                                            WHERE Name LIKE: filterVal ORDER BY Name ASC 
                                                            LIMIT : limits OFFSET : offsetSize];       	       	
        RecordDetails records = new RecordDetails();
        Records.Count = count;
        Records.OffsetSize = offsetSize;
        Records.ResourceTypes =resourceTypeList ;
        return records;        
    }
    
        //Date :17/09/19
        Global class RecordDetails {
        	Integer Count;
       		Integer OffsetSize;        	   	 
        	List<leankor__ResourceType__c> ResourceTypes;
        }

    Public static Map<String, leankor__ScheduleConstraint__c> getScheduleConstraints(){
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = new  Map<String, leankor__ScheduleConstraint__c>();
        for(leankor__ScheduleConstraint__c scheduleConstraint : [Select Id, Name, leankor__Description__c, leankor__Type__c From leankor__ScheduleConstraint__c Limit 10000]){
            scheduleConstraints.put(scheduleConstraint.leankor__Type__c, scheduleConstraint);
        }
        return scheduleConstraints;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Create Schedule Planning Configuration Record.
     Input       : List SchedulePlanningConfiguration Object.
     Output      : List SchedulePlanningConfiguration Object.
     --------------------------------------------------------------------------------*/ 
 /*   @RemoteAction
    global static List<leankor__SchedulePlanningConfiguration__c> createSchedulePlanningConfigurations(List<leankor__SchedulePlanningConfiguration__c> schedulePlanningConfigurations){

        try {
            insert schedulePlanningConfigurations;
        } catch (DMLException e) {
            System.debug('ERROR :: '+e.getMessage());
            throw new Util.LeanException('Error : ' + e.getmessage());
        }

        return schedulePlanningConfigurations;
    }*/

    @RemoteAction
    global static Map<String, List<leankor__ResourceAssignment__c>> getResourceAssignmentBulkfied(String kanbanCardIds){
        if (String.isNotBlank(kanbanCardIds) && Util.getSObjectName(kanbanCardIds) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        Map<String, List<leankor__ResourceAssignment__c>> resourceAssignmentMap = new Map<String, List<leankor__ResourceAssignment__c>>();
        List<leankor__ResourceAssignment__c> resourceList = [Select 
                                                                Id, 
                                                                leankor__AssignedTo__c,
                                                                leankor__AssignedTo__r.Name,
                                                                leankor__KanbanCard__c,
                                                                leankor__PercentAllocation__c,
                                                                Name,
                                                                OwnerId,
                                                                leankor__ResourceType__c ,
                                                                leankor__ResourceType__r.Name 
                                                        From leankor__ResourceAssignment__c 
                                                        Where leankor__KanbanCard__c = : kanbanCardIds 
                                                        Limit 50000 ];

        for(leankor__ResourceAssignment__c resource : resourceList ){
            if(resourceAssignmentMap.containsKey(resource.leankor__KanbanCard__c)){
                resourceAssignmentMap.get(resource.leankor__KanbanCard__c).add(resource);
            }else{
                resourceAssignmentMap.put(resource.leankor__KanbanCard__c , new List<leankor__ResourceAssignment__c>{resource});
            }
        }
        return resourceAssignmentMap;                                       
    }

    public static Map<Id,ScheduleMode> getAllScheduleModes(List<String> valueStreamIds){
        for(String valueStreamId : valueStreamIds){
            if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
		leankor__ScheduleMode__c scheduleModeRecord = new leankor__ScheduleMode__c();
        Map<String, leankor__ScheduleMode__c> cardLinkScheduleMode = new Map<String, leankor__ScheduleMode__c>();
        Map<Id,ScheduleMode> scheduleModeList = new Map<Id,ScheduleMode>();
        try{
            List<leankor__KanbanCard__C> cards = [Select Id,
                                                         leankor__ValuestreamCardLink__c,
                                                         leankor__ValueStreamLink__r.leankor__BoardType__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c In : valueStreamIds
                                                    Limit 50000];
            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                cardLinkScheduleMode = leankor.RealTimeControllerHelper.getParentCardConstraintData(cards);
            }
            for(leankor__ScheduleMode__c scm : [Select Id,
                                                       leankor__KanbanCard__c,
                                                       leankor__Mode__c,
                                                       leankor__EffortUnits__c,
                                                       leankor__EffortActual__c,
                                                       Name,
                                                       leankor__ManuallyScheduled__c,
                                                       leankor__KanbanCard__r.leankor__ValuestreamCardLink__c,
                                                       leankor__ScheduleConstraint__r.leankor__Type__c,
                                                       leankor__ConstraintDateTime__c 
                                                From leankor__ScheduleMode__c 
                                                Where leankor__KanbanCard__r.leankor__ValueStream__c IN: valueStreamIds 
                                                Limit 50000]){
                
                ScheduleMode sMode = new ScheduleMode();
                
                sMode.SchedulingModeId = scm.Id;
                sMode.SchedulingMode = scm.leankor__Mode__c;
                sMode.ManuallyScheduled = scm.leankor__ManuallyScheduled__c;
                sMode.Effort = scm.leankor__EffortActual__c;
                sMode.EffortUnit = scm.leankor__EffortUnits__c;
                sMode.ActivityId = scm.leankor__KanbanCard__c;
                if(scm.leankor__KanbanCard__r.leankor__ValuestreamCardLink__c!=null && cardLinkScheduleMode.containsKey(scm.leankor__KanbanCard__r.leankor__ValuestreamCardLink__c)){
                    scheduleModeRecord =  cardLinkScheduleMode.get(scm.leankor__KanbanCard__r.leankor__ValuestreamCardLink__c) ;
                    sMode.parentCardConstraintType = String.isNotBlank(scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c) ? scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c : null;
                    sMode.parentCardConstraintDate = scheduleModeRecord.leankor__ConstraintDateTime__c!= null  ? scheduleModeRecord.leankor__ConstraintDateTime__c : null;
                }
                sMode.ConstraintDate = String.valueof(scm.leankor__ConstraintDateTime__c);
                sMode.ConstraintType = scm.leankor__ScheduleConstraint__r.leankor__Type__c;
                scheduleModeList.put(sMode.ActivityId, sMode);
            }
        }catch(Exception ex){
            //return new  Map<Id,ScheduleMode>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return scheduleModeList;
    }


    private static List<leankor__KanbanCard__c> getAllCards(Set<Id> valuestreamIds) {  
        return [ Select Id,
                        Name,
                        RecordType.Name,
                        leankor__Title__c,
                        leankor__GUID__c,
                        leankor__Order__c,
                        leankor__StartDateTime__c,
                        leankor__DueDateTime__c,
                        leankor__PercentComplete2__c,
                        leankor__EstimatedDuration__c,
                        leankor__DurationUnits__c,
                        leankor__CardID__c,
                        leankor__KanbanCardTemplate__c,
                        leankor__Priority__c,
                        leankor__DescriptionLong__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        OwnerID,
                        leankor__kanbanCardTemplate__r.Color__c,
                        leankor__KanbanCardTemplate__r.Name,
                        leankor__IsAtRisk__c,
                        leankor__IsOnHold__c,
                        leankor__IsExternallyDependent__c,
                        leankor__IsSuccessorRecalculate__c,
                        leankor__IsConstraintRecalculate__c,
                        leankor__HarveyBallDoneDate__c,
                        leankor__PromiseCompletionDate__c,
                        (Select Id, 
                                leankor__ManuallyScheduled__c,
                                leankor__Mode__c,
                                leankor__EffortUnits__c,
                                leankor__EffortActual__c,
                                leankor__ConstraintDateTime__c,
                                leankor__ScheduleConstraint__r.leankor__Type__c
                            From leankor__ScheduleModes__r 
                            Limit 1),
                        leankor__Monday__c,
                        leankor__Tuesday__c,
                        leankor__Wednesday__c,
                        leankor__Thursday__c,
                        leankor__Friday__c,
                        leankor__Saturday__c,
                        leankor__Sunday__c,
                        leankor__WeekCalendar__c
                    From leankor__KanbanCard__c
                    Where leankor__ValueStream__c In :valuestreamIds
                        And leankor__isRecordDeleted__c = false
                    Limit 50000
        ];
    }

    private static List<leankor__KanbanCard__c> getAllCardsWithBaseline(Id baseLineId, Set<Id> valuestreamIds) {  
        return [ Select Id,
                        Name,
                        RecordType.Name,
                        leankor__Title__c,
                        leankor__GUID__c,
                        leankor__Order__c,
                        leankor__StartDateTime__c,
                        leankor__DueDateTime__c,
                        leankor__PercentComplete2__c,
                        leankor__EstimatedDuration__c,
                        leankor__DurationUnits__c,
                        leankor__CardID__c,
                        leankor__KanbanCardTemplate__c,
                        leankor__Priority__c,
                        leankor__DescriptionLong__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        OwnerID,
                        leankor__kanbanCardTemplate__r.Color__c,
                        leankor__KanbanCardTemplate__r.Name,
                        leankor__IsAtRisk__c,
                        leankor__IsOnHold__c,
                        leankor__IsExternallyDependent__c,
                        leankor__IsSuccessorRecalculate__c,
                        leankor__IsConstraintRecalculate__c,
                        leankor__HarveyBallDoneDate__c,
                        leankor__PromiseCompletionDate__c,
                        (Select Id, 
                                leankor__ManuallyScheduled__c,
                                leankor__Mode__c,
                                leankor__EffortUnits__c,
                                leankor__EffortActual__c,
                                leankor__ConstraintDateTime__c,
                                leankor__ScheduleConstraint__r.leankor__Type__c
                            From leankor__ScheduleModes__r 
                            Limit 1),
                        (Select leankor__DueDateTime__c, 
                                leankor__StartDateTime__c
                            From leankor__Kanban_Card_Baselines__r
                            Where leankor__ProjectScheduleBaseline__c = :baseLineId 
                            Limit 1),
                        leankor__Monday__c,
                        leankor__Tuesday__c,
                        leankor__Wednesday__c,
                        leankor__Thursday__c,
                        leankor__Friday__c,
                        leankor__Saturday__c,
                        leankor__Sunday__c,
                        leankor__WeekCalendar__c
                    From leankor__KanbanCard__c
                    Where leankor__ValueStream__c In :valuestreamIds
                        And leankor__isRecordDeleted__c = false
                    Limit 50000
        ];
    }


    private static List<UserData> getUserdata(Set<Id> userIds) {

        for(String userId : UserIDs) {
            if (String.isNotBlank(userId) && Util.getSObjectName(userId) != 'User') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        //Check CRUD / FLC behavior 
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<UserData> resultUsers = new List<UserData>();   
        List<User> userList = [Select Id, 
                                        SmallPhotoUrl, 
                                        Name 
                                    From User 
                                    Where Id In :userIds 
                                        Or Id = :UserInfo.getUserId() 
                                    Limit 1];

        for (User userLog : userList) {
            UserData userData = new UserData();
            userData.Id = userLog.Id;
            userData.SmallPhotoUrl = userLog.SmallPhotoUrl;
            userData.Name = userLog.Name;
            resultUsers.add(userData);
        }

        return resultUsers;
    }


    @remoteAction 
    global static List<leankor__Sticker__c> readStickersOld(Id valueStreamId, List<String> kanbanList) {

        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        for (String kanbanCardId : kanbanList) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<leankor__Sticker__c> myStickers = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> stickerIds2 = new List<leankor__Sticker__c>();
        Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>(); 
        Set<Id> stickerIds = new Set<Id>();

        for (leankor__KanbanCardSticker__c[] stickers : [Select leankor__Sticker__c 
                                                                From leankor__KanbanCardSticker__c 
                                                                Where leankor__KanbanCard__c In :kanbanList 
                                                                Limit 50000]) {
                for (Integer iCount = 0; iCount < stickers.size(); iCount++) {
                    stickerIds.add(stickers[iCount].leankor__Sticker__c);
                }
        }

        if(kanbanList.isEmpty()) {

        }

        return myStickers;
    }

    @RemoteAction
    global static List<leankor__Sticker__c> readStickers(Id valueStreamId, List<String> kanbanCardList) {

        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        for (String kanbanCardId : kanbanCardList) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<leankor__Sticker__c> myStickers = new List<leankor__Sticker__c>();
        Set<Id> stickerIds = new Set<Id>();
        Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>(); 

        try {

            // Get Sticker Ids related to Kanban Cards
            if (!kanbanCardList.isEmpty()) {
                for (leankor__KanbanCardSticker__c sticker : [Select leankor__Sticker__c 
                                                                From leankor__KanbanCardSticker__c 
                                                                Where leankor__KanbanCard__c In :kanbanCardList 
                                                                Limit 50000]) {
                    stickerIds.add(sticker.leankor__Sticker__c);
                }
            }

            // Get Stickers based on Value Stream Id
            List<leankor__Sticker__c> allStickers = [Select Id, 
                                                            Name, 
                                                            leankor__ValueStream__c,
                                                            (Select Id, 
                                                                    ContentType, 
                                                                    Description 
                                                                From Attachments 
                                                                Where ParentId In :stickerIds)
                                                        From leankor__Sticker__c
                                                        Where (leankor__ValueStream__c = :valueStreamId Or leankor__ValueStream__c = null)
                                                            And LastModifiedDate >= :realTimeController.LASTMODIFIEDDATETIME_CONST
                                                        Limit 50000];

            for (leankor__Sticker__c sticker : allStickers) {
                if (!sticker.Attachments.isEmpty()) {
                    for (Attachment attachment : sticker.Attachments) {
                        attachment.Description = EncodingUtil.Base64Encode(attachment.Body);
                        attachment.Name = sticker.Id;
                        mapAttachments.put(attachment.Id, attachment);
                    }
                    myStickers.add(sticker);
                }
            }

        } catch (Exception e) {
            System.debug('ERROR: while getting attachment to Sticker: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getMessage());
        }

        return myStickers;
    }

}