global with sharing class PlanGanttController {
    

    global PlanGanttController(ApexPages.StandardController stanCon) {}
    public PlanGanttController(Util controller){}
    global PlanGanttController(){}


    global class GanttResourcesSchedulerInfo {
        public Boolean hasEditAccess;  
        public String projectLaunchDate;
        public String lastSetBaselineId;
        public String Name;
        public String Id;
        public DateTime StartDate;
        public DateTime DueDate;
        public String ItemType;
        public Boolean ScheduleBackwards;
        public List<KanbanCardData> children;
        public String folderName;
        private Boolean isScheduleRecalculate;
        private Boolean isRecalculate;
    }


    public class KanbanCardData {
        public String Id;
        public String Name;
        public String Title;
        public String GUID;
        public Decimal Order;
        public DateTime StartDate;
        public DateTime DueDate;
        public Decimal PercentDone;
        public Decimal EstimatedDuration;
        public String DurationUnits; 
        public String CardID;
        public String TemplateID;
        public Integer Priority;
        public String Description;
        public String ValueStreamCardLink;
        public String ValueStreamLinkID;
        public String OwnerID;
        public String ItemType;
        public String Color;
        public Boolean IsExternallyDependent;
        public Boolean IsSuccessorRecalculate;
        public Date HarveyBallDoneDate;
        public DateTime PromiseCompletionDate;
        public Boolean isConstraintRecalculate;
        public Boolean ManuallyScheduled;
        public String SchedulingMode;
        public String EffortUnit;
        public Decimal Effort;
        public String SchedulingModeId;
        public DateTime ConstraintDate;
        public String ConstraintType;
        public Boolean Monday;
        public Boolean Tuesday;
        public Boolean Wednesday;   
        public Boolean Thursday;
        public Boolean Friday;
        public Boolean Saturday;
        public Boolean Sunday;
        public String weekCalendar;
        public Integer workOrderCount;
        public Integer serviceAppointmentCount;
        public DateTime fslSchedStartDateTime;
        public DateTime fslSchedDueDateTime;
        public Integer seriesNumber;
    }


    public class ResourceAssignment {
	    public String Id;
	    public String TaskId;
        public String  Name;
	    public String ResourceId;
	    public Decimal Units;
	    public String ownerId;
	    public String ownerName;
	    public Decimal PercentCompleted;
	    public String activityId; 
	    public String resourceType ;
	    public String SmallPhotoUrl;
	    public String appointmentNumber;
	    public String workOrderNumber;
	    public DateTime startDateTime;
	    public DateTime dueDateTime;
	    public String resourceTypeId;
	    public String TempUUID;
        public Decimal PercentCompletedOfKanbanCard;
    }


    public class Miniature {
        public String Id; 
        public String Name ;
        public String CardId ;
        public String DueDate;
        public String StartDate;
        public String ProjectName;
        public String BoardName;
        public String ValueStreamID;
        public String BoardType; 
        public Boolean IsSuccessorRecalculate; 
        public Boolean isDependencyAckRecalculate ; 
        public String OwnerId; 
        public Decimal PercentDone; 
        public Boolean isDueDatePercentComplete;
        public String Title;
        public String valueStreamLinkedBoardId;
        public String ConstraintType;
        public DateTime ConstraintDate;
    }

    global class MiniatureandResource {
        public List<PlanGanttController.ResourceAssignment> resourceAssignmentData;
        public List<PlanGanttController.Miniature> miniatureData;
        public List<PlanGanttController.UserData> userRecords;
    }


    @RemoteAction    
    global static PlanGanttController.GanttResourcesSchedulerInfo readAllPlanBoardCards(String valueStreamId) {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        PlanGanttController.GanttResourcesSchedulerInfo valueStreamPlanning = new PlanGanttController.GanttResourcesSchedulerInfo();
        List<leankor__ValueStream__c> planBoards = [Select Id,
                                                            Name,
                                                            UserRecordAccess.HasEditAccess,
                                                            leankor__ProjectBoardStartDateTime__c,
                                                            leankor__ProjectBoardEndDateTime__c,
                                                            leankor__ScheduleBackward__c,
                                                            leankor__ProjectRoom__r.Name,
                                                            leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c,
                                                            leankor__IsScheduleRecalculate__c,
                                                            leankor__Isrecalculate__c,
                                                            (Select Id
                                                                From Project_Schedule_Baselines__r
                                                                Order By CreatedDate Desc
                                                                Limit 1)        
                                                        From leankor__ValueStream__c 
                                                        Where Id = :valueStreamId
                                                            And leankor__isRecordDeleted__c = false  
                                                        Order By CreatedDate 
                                                        Limit 1];  

        if (!planBoards.isEmpty()) {
            Set<Id> valuestreamIds = new Set<Id>{planBoards[0].Id};
            Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{String.valueOf(planBoards[0].Id)}, 'Valuestream');
            Integer fslDataInfoSize = fslDataInfo.size();
            Id lastSetBaselineId = planBoards[0].Project_Schedule_Baselines__r.size() > 0 ? planBoards[0].Project_Schedule_Baselines__r[0].Id : null;
            valueStreamPlanning.children = new List<KanbanCardData>();
            for (leankor__KanbanCard__c cardData : [Select Id,
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
                                                            leankor__SeriesNumber__c,
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
                                                        With Security_Enforced
                                                        Limit 50000]) {

                KanbanCardData card = new KanbanCardData();
                card.Id = cardData.Id;
                card.Name = cardData.Name;                                 
                card.Title = cardData.leankor__KanbanCardTemplate__r.Name;
                card.GUID = cardData.leankor__GUID__c;
                card.seriesNumber = Integer.valueOf(cardData.leankor__SeriesNumber__c); 
                card.Order = cardData.leankor__Order__c;
                card.StartDate = cardData.leankor__StartDateTime__c;
                card.DueDate = cardData.leankor__DueDateTime__c;
                card.PercentDone = cardData.leankor__PercentComplete2__c;
                card.EstimatedDuration = cardData.leankor__EstimatedDuration__c;                 
                card.DurationUnits = cardData.leankor__DurationUnits__c == 'Days' ? 'd' :(cardData.leankor__DurationUnits__c == 'Weeks' ? 'w' : (cardData.leankor__DurationUnits__c == 'Hours' ? 'h': (cardData.leankor__DurationUnits__c == 'Months' ? 'mo' : (cardData.leankor__DurationUnits__c == 'Years' ? 'y' : 'mi'))));
                card.CardId = cardData.leankor__CardId__c;                    
                card.TemplateId = (cardData.leankor__KanbanCardTemplate__c == null ? '' : cardData.leankor__KanbanCardTemplate__c);
                card.Priority = Integer.valueOf(cardData.leankor__Priority__c);
                card.Description = cardData.leankor__DescriptionLong__c;               
                card.ValueStreamCardLink = (cardData.leankor__ValueStreamCardLink__c == null ? '' : cardData.leankor__ValueStreamCardLink__c);
                card.ValueStreamLinkId = (cardData.leankor__ValueStreamLink__c == null ? '' : cardData.leankor__ValueStreamLink__c);
                card.OwnerId = cardData.OwnerId;   
                card.ItemType = cardData.RecordType.Name;
                card.Color = (cardData.leankor__kanbanCardTemplate__r.Color__c == null ? '' : cardData.leankor__kanbanCardTemplate__r.Color__c);
                card.IsExternallyDependent = cardData.leankor__IsExternallyDependent__c; 
                card.IsSuccessorRecalculate = cardData.leankor__IsSuccessorRecalculate__c; 
                card.HarveyBallDoneDate = cardData.leankor__HarveyBallDoneDate__c;
                card.PromiseCompletionDate = cardData.leankor__PromiseCompletionDate__c;   
                
                if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    card.isConstraintRecalculate = cardData.leankor__IsConstraintRecalculate__c;
                }

                if (cardData.leankor__ScheduleModes__r.size() > 0) {
                    card.ManuallyScheduled = cardData.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                    card.SchedulingMode = cardData.leankor__ScheduleModes__r[0].leankor__Mode__c;
                    card.EffortUnit = cardData.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                    card.Effort = cardData.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                    card.SchedulingModeId = cardData.leankor__ScheduleModes__r[0].Id;
                    
                    if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                        card.ConstraintDate = cardData.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                        card.ConstraintType = cardData.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                    }
                }

                if (cardData.leankor__Monday__c 
                || cardData.leankor__Tuesday__c 
                || cardData.leankor__Wednesday__c 
                || cardData.leankor__Thursday__c 
                || cardData.leankor__Friday__c 
                || cardData.leankor__Saturday__c 
                || cardData.leankor__Sunday__c) {
                    card.Monday = cardData.leankor__Monday__c;
                    card.Tuesday  = cardData.leankor__Tuesday__c;
                    card.Wednesday = cardData.leankor__Wednesday__c;
                    card.Thursday = cardData.leankor__Thursday__c;
                    card.Friday = cardData.leankor__Friday__c;
                    card.Saturday = cardData.leankor__Saturday__c;
                    card.Sunday = cardData.leankor__Sunday__c;
                } else {
                    card.Monday = true;
                    card.Tuesday = true;
                    card.Wednesday = true;
                    card.Thursday = true;
                    card.Friday = true;
                    card.Saturday = true;
                    card.Sunday = true;
                }

                if (fslDataInfoSize > 0 && fslDataInfo.containsKey(cardData.Id)) {
                    FieldServiceUtilityController.RecordDetails recordDetail = fslDataInfo.get(cardData.Id);
                    card.workOrderCount = recordDetail.workOrderCount;
                    card.serviceAppointmentCount = recordDetail.serviceAppointmentCount != null ? recordDetail.serviceAppointmentCount : 0;
                    card.fslSchedStartDateTime = recordDetail.fslSchedStartDateTime;
                    card.fslSchedDueDateTime = recordDetail.fslSchedDueDateTime;
                } else {
                    card.workOrderCount = 0;
                    card.serviceAppointmentCount = 0;
                    card.fslSchedStartDateTime = null;
                    card.fslSchedDueDateTime = null;
                }

                card.weekCalendar = cardData.leankor__WeekCalendar__c;
                valueStreamPlanning.children.add(card);
                cardData.clear();
            }
            Datetime maxTempDate;
            Datetime minTempDate;

            if (valueStreamPlanning.children.size() == 0) {
                maxTempDate = System.now();
                minTempDate = System.now();
            } else {
                AggregateResult aggregateResult = [Select Min(leankor__StartDateTime__c) MinDate, 
                                                            Max(leankor__DueDateTime__c) MaxDate 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c In :valuestreamIds 
                                                            And leankor__isRecordDeleted__c = false 
                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                        With Security_Enforced];
                                                    
                minTempDate = (DateTime)aggregateResult.get('MinDate');
                maxTempDate = (DateTime)aggregateResult.get('MaxDate');
            }
            
            valueStreamPlanning.Name = planBoards[0].Name;
            valueStreamPlanning.ItemType = 'Board';
            valueStreamPlanning.Id = planBoards[0].Id;
            if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                valueStreamPlanning.StartDate = planBoards[0].leankor__ProjectBoardStartDateTime__c;
                valueStreamPlanning.DueDate = planBoards[0].leankor__ProjectBoardEndDateTime__c;
            } else {
                valueStreamPlanning.StartDate = minTempDate;
                valueStreamPlanning.DueDate = maxTempDate;                
            }
            valueStreamPlanning.ScheduleBackwards = planBoards[0].leankor__ScheduleBackward__c;
            valueStreamPlanning.folderName = planBoards[0].leankor__ProjectRoom__r.Name;
            valueStreamPlanning.hasEditAccess = planBoards[0].UserRecordAccess.HasEditAccess; 
            valueStreamPlanning.projectLaunchDate = planBoards[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c != null 
            ? Json.serialize(planBoards[0].leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c) 
            : '';
            valueStreamPlanning.lastSetBaselineId = lastSetBaselineId != null ? (String)lastSetBaselineId : '';
            valueStreamPlanning.isScheduleRecalculate = planBoards[0].leankor__IsScheduleRecalculate__c;
            valueStreamPlanning.isRecalculate = planBoards[0].leankor__Isrecalculate__c;
            
        }
        return valueStreamPlanning;
    }

    @RemoteAction    
    global static leankor.PlanGanttController.MiniatureandResource readPlanGanttAssociatedData (String valueStreamId) {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Added Security code for sentize user Input
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }

        PlanGanttController.MiniatureandResource miniatureandResourceRecords = new PlanGanttController.MiniatureandResource();
        Set<String> valueStreamIds = new Set<String>{valueStreamId};
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                           OwnerId
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c In :valueStreamIds
                                                        With Security_Enforced
                                                        Limit 50000];
        Set<String> activityIds = new Set<String>();
        List<String> userIds = new List<String>();
        
        for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
            activityIds.add(kanbanCard.Id);
            userIds.add(kanbanCard.OwnerId);
        }

        miniatureandResourceRecords.miniatureData = PlanGanttController.readMiniatureData(activityIds);
        miniatureandResourceRecords.resourceAssignmentData = PlanGanttController.getResources(activityIds);
        miniatureandResourceRecords.userRecords = PlanGanttController.getUserdata(userIds);

        return miniatureandResourceRecords;

    }

      @AuraEnabled
    public static MiniatureandResourceData readPlanGanttAssociatedDataAura(String valueStreamId){
        try {
            leankor.PlanGanttController.MiniatureandResource data = readPlanGanttAssociatedData(valueStreamId);
            MiniatureandResourceData minitureResource = new MiniatureandResourceData();
            minitureResource.resourceAssignmentData = data.resourceAssignmentData;
            minitureResource.miniatureData = data.miniatureData;
            minitureResource.userRecords  = data.userRecords;
            return minitureResource;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    global class DescriptionScheduleData {
        public String description;
        public leankor__ScheduleMode__c scheduleMode;
    }
    
    @RemoteAction    
    global static Map<Id, leankor.PlanGanttController.DescriptionScheduleData> readScheduleModeAndDescriptionData (String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                            leankor__DescriptionLong__c,
                                                                (Select Id, 
                                                                leankor__ManuallyScheduled__c,
                                                                leankor__Mode__c,
                                                                leankor__EffortUnits__c,
                                                                leankor__EffortActual__c,
                                                                leankor__ConstraintDateTime__c,
                                                                leankor__ScheduleConstraint__r.leankor__Type__c
                                                                From leankor__ScheduleModes__r 
                                                                Limit 1)
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__c = :valueStreamId
                                                        With Security_Enforced
                                                        Limit 50000];

        Map<Id, leankor.PlanGanttController.DescriptionScheduleData> mapOfDescriptionScheduleData = new Map<Id, leankor.PlanGanttController.DescriptionScheduleData>();                                            

        for (leankor__KanbanCard__c kanbanCard :  kanbanCards) {
            PlanGanttController.DescriptionScheduleData descriptionScheduleData = new PlanGanttController.DescriptionScheduleData();
            descriptionScheduleData.description = kanbanCard.leankor__DescriptionLong__c;
            if (kanbanCard.leankor__ScheduleModes__r.size() > 0 ) {
                descriptionScheduleData.scheduleMode = kanbanCard.leankor__ScheduleModes__r;
            }

            mapOfDescriptionScheduleData.put(kanbanCard.Id, descriptionScheduleData);
        }

        return mapOfDescriptionScheduleData;
    }

     @AuraEnabled
    public static  Map<Id, ScheduleDescriptionData>  readScheduleModeAndDescriptionDataAura(String valueStreamId){
        try {
            Map<Id, leankor.PlanGanttController.DescriptionScheduleData> data = readScheduleModeAndDescriptionData(valueStreamId);

             Map<Id, ScheduleDescriptionData> result = new Map<Id, ScheduleDescriptionData>();
            for (Id cardId : data.keySet()) {
                leankor.PlanGanttController.DescriptionScheduleData  dataSchDes = data.get(cardId);

                ScheduleDescriptionData descriptionSchedule = new ScheduleDescriptionData();
                descriptionSchedule.description  = dataSchDes != null ? dataSchDes.description  : null;
                descriptionSchedule.scheduleMode = dataSchDes != null ? dataSchDes.scheduleMode : null;

                result.put(cardId, descriptionSchedule);
            }
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public static List<leankor.PlanGanttController.Miniature> readMiniatureData (Set<String> activityIds) {
        List<leankor.PlanGanttController.Miniature> result = new List<leankor.PlanGanttController.Miniature>();

        if (activityIds.isEmpty()) {
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
                                                    With Security_Enforced	
                                                    Limit 50000]) {

            if (miniature.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                && miniature.leankor__ValueStream__c != null 
                && miniature.leankor__ProjectRoom__c != null) {
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
            leankor.PlanGanttController.Miniature miniatureLog = new leankor.PlanGanttController.Miniature();
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

    public static Boolean hasSeventyPercentDueDate(leankor__Kanbancard__c kanbancard, Util.WorkWeek workWeekObj) {
        
        Integer dateDifference;
        Integer currentStartDifference;
        Decimal dueDatePercent;        

        dateDifference = Math.abs(workWeekObj.getBusinessDays(kanbancard.leankor__StartDateTime__c.date(), kanbancard.leankor__DueDateTime__c.date()));

        //Get diff. b/w Start date and current Date .
        if (System.now() >= kanbancard.leankor__StartDateTime__c) {
            currentStartDifference = Math.abs(workWeekObj.getBusinessDays(kanbancard.leankor__StartDateTime__c.date(), System.today()));                               
        } else {       
            currentStartDifference = 0;           
        }   
    
        //calculate percent b/w current date Diff. and start due date diff.            
        dueDatePercent = (currentStartDifference > dateDifference || dateDifference == 0) ? 100 : (currentStartDifference*100)/dateDifference;                     

        //If dueDatePercent >= 70% then returns true else false
        return (dueDatePercent >= 70);
    } 

    public static List<leankor.PlanGanttController.ResourceAssignment> getResources(Set<String> activityIds){

        List<leankor.PlanGanttController.ResourceAssignment> resources = new List<leankor.PlanGanttController.ResourceAssignment>();
        //return resources;
        
        if (activityIds.isEmpty()) {
            return resources;
        }
        
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
                                                                    With Security_Enforced
                                                                    Limit 50000]) {

            if (resourceAssignment.leankor__ResourceType__c != null || resourceAssignment.leankor__AssignedTo__c != null) {
                leankor.PlanGanttController.ResourceAssignment resource = new leankor.PlanGanttController.ResourceAssignment();
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

    global class UserData {
        global String Id;
        global String SmallPhotoUrl;
        global String Name;
    }  

    global static List<UserData> getUserdata (List<String> UserIDs) {
        //Check CRUD / FLC behavior 
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
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
    
    public static Map<String, Id> recordTypeIdNameMap() {
		Map<String, Id> recordTypeMap = new Map<String, Id>();
		for (RecordType record : [Select DeveloperName,
                                  		Id 
                                    From RecordType 
                                  	Where SobjectType = 'leankor__KanbanCard__c' 
                                  		And IsActive = true]) {
			recordTypeMap.put(record.DeveloperName, record.Id);
		}
		return recordTypeMap;	
	}

    public static Map<String, Id> getScheduleConstraintMap() {
		Map<String, Id> scheduleConstraints = new  Map<String, Id>();
        for (leankor__ScheduleConstraint__c scheduleConstraint : [Select Id, 
                                                                        Name, 
                                                                        leankor__Description__c, 
                                                                        leankor__Type__c 
                                                                    From leankor__ScheduleConstraint__c 
                                                                    With Security_Enforced
                                                                    Limit 10000]) {
            scheduleConstraints.put(scheduleConstraint.leankor__Type__c, scheduleConstraint.Id);
        }
        return scheduleConstraints;
    }
}