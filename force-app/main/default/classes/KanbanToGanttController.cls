/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: KanbanToGanttController.cls
 * CLASS: KanbanToGanttController
 */
Global with sharing class KanbanToGanttController 
{
	//RS 27.06.2018 For getting milestoneObject from visualforce component 
	Public Static leankor__kanbancard__c milestoneObj {get; set;}
    Public static Map<String, Schema.SObjectField> fieldMapKanbanCardForClone;
    Public static Map<Id, leankor__KanbanCard__C> kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__C>();
	Global KanbanToGanttController(){
	
	}  
	    Global  KanbanToGanttController(ApexPages.StandardController controller){ }
    private static List<String> resoruceList;
    //
    // This Inner Method Is Use for Master Records needed on Load of Gantt Board
    //
    
    Global class MasterContainer{
        @AuraEnabled Global String Id;
        @AuraEnabled Global String CardID;
        @AuraEnabled Global String UrlLink;
        @AuraEnabled Global String ForceID;
        @AuraEnabled Global String Name;
        @AuraEnabled Global String Color;
        @AuraEnabled Global String CmpID;
        @AuraEnabled Global String GUID;
        @AuraEnabled Global Decimal Height;
        @AuraEnabled Global Boolean isCardAvailable;
        @AuraEnabled Global Decimal Left;
        @AuraEnabled Global Decimal Limits;
        @AuraEnabled Global Decimal Order;
        @AuraEnabled Global String Title;
        @AuraEnabled Global Decimal Top;
        @AuraEnabled Global String Type;
        @AuraEnabled Global String ValueStreamID;
        @AuraEnabled Global String ValueStream;
        @AuraEnabled Global Decimal Width;
        @AuraEnabled Global Decimal CardPerRow;  
        @AuraEnabled Global String Help;
        @AuraEnabled Global Integer Bottom;
        @AuraEnabled Global Integer X;
        @AuraEnabled Global Integer Y;
        @AuraEnabled Global String EntryFlowName;
        @AuraEnabled Global String ExitFlowName;
        @AuraEnabled Global String VSLink; // drill down to another detail level of the value stream
        @AuraEnabled Global String ZoneMode;
        @AuraEnabled Global String KanbanSequence;
        @AuraEnabled Global String ValueStreamLinkID;
        @AuraEnabled Global String ValueStreamCardLink;
        @AuraEnabled Global String ValueStreamLinkBoardType;
        @AuraEnabled Global Integer DefaultHeight;
        @AuraEnabled Global Integer DefaultWidth;
        @AuraEnabled Global String ZoneStatus;
        @AuraEnabled Global Decimal TaskLimit;
        @AuraEnabled Global String ParentZone;
        @AuraEnabled Global String Swimlane;
        @AuraEnabled Global Decimal CardsPerRow;
        @AuraEnabled Global String CaseStatus;
        @AuraEnabled Global String CompletionRateUnits;
        @AuraEnabled Global Integer CompletionRate;
        @AuraEnabled Global String CSSLayout;
        @AuraEnabled Global String JSONData;
        @AuraEnabled Global String JSONDefinition;
        @AuraEnabled Global Integer KanbanCardCount;
        @AuraEnabled Global Integer KanbanCardThroughput;
        @AuraEnabled Global Integer LeadTime;
        @AuraEnabled Global String ZoneTemplate;
        @AuraEnabled Global String OwnerID;
        @AuraEnabled Global String State;
        @AuraEnabled Global String ZoneID;
        @AuraEnabled Global String ZoneGUID;
        @AuraEnabled Global String MCForceID;
        @AuraEnabled Global String SWForceID;
        @AuraEnabled Global String ZoneForceID;
        @AuraEnabled Global String Base64Drawing;
        @AuraEnabled Global String Base64FileType;
        @AuraEnabled Global String TemplateID; // kanban card template Force.com id
        @AuraEnabled Global String TemplateName;
        @AuraEnabled Global Decimal Point;
        @AuraEnabled Global Decimal EffortRemaining;
        @AuraEnabled Global Decimal EstimatedDuration; // new field to track if project/product on schedule;
        @AuraEnabled Global String DurationUnits; //EjB11: added durationUnits picklist string
        @AuraEnabled Global Integer Priority; //EjB14: added priority
        @AuraEnabled Global String HarveyBall;
        @AuraEnabled Global String DateColor;
        @AuraEnabled Global String Description;
        @AuraEnabled Global String KanbanUrl;
        @AuraEnabled Global String Account;
        @AuraEnabled Global String Contact;
        @AuraEnabled Global String CaseID;
        @AuraEnabled Global String AccountName;
        @AuraEnabled Global String ContactName;
        @AuraEnabled Global String CaseSubject;
        @AuraEnabled Global String CasePriority;
        @AuraEnabled Global Boolean CaseTrigger;
        @AuraEnabled Global Boolean SevenDayWorkWeek;
        @AuraEnabled Global String ZoneTitle;
        @AuraEnabled Global String LeavedZoneTitle;
        @AuraEnabled Global Decimal PercentDone;
        @AuraEnabled Global String LastModifiedDate;
        @AuraEnabled Global String CreateDate;
        @AuraEnabled Global String Extensions;
        @AuraEnabled Global String LeavedZoneID;
        @AuraEnabled Global Boolean leaf;
        @AuraEnabled Global Boolean expanded;
        @AuraEnabled Global String ResourceId;
        @AuraEnabled Global List<MasterContainer> children;
        @AuraEnabled Global String StartDate;
        @AuraEnabled Global String DueDate;
        @AuraEnabled Global String ItemType;
        @AuraEnabled Global String Opportunity;
        @AuraEnabled Global String OpportunityName;
        @AuraEnabled Global String SmallPhotoUrl;
        @AuraEnabled Global String BoardType;
        @AuraEnabled Global String OnBudget;
        @AuraEnabled Global String OnQuality;
        @AuraEnabled Global String OnTime;
        @AuraEnabled Global String OwnerName;
        @AuraEnabled Global String Subject;
        @AuraEnabled Global String Status;
        @AuraEnabled Global String WhatId;
        @AuraEnabled Global String KanbanCardName;
        @AuraEnabled Global String ValueStreamName;
        @AuraEnabled Global String ProjectRoomName;
        @AuraEnabled Global String ProjectRoomID;
        @AuraEnabled Global String ValueStreamCardLinkName;
        @AuraEnabled Global String ValueStreamLinkIDName;
        @AuraEnabled Global String CreatedDate;  
        @AuraEnabled Global String AgilePointSequnece;
        @AuraEnabled Global Boolean VSTaskDueDateCheck;
        @AuraEnabled Global Boolean isMilestone;
        @AuraEnabled Global String AcceptanceCriteria;
        @AuraEnabled Global String TaskId;
        @AuraEnabled Global Decimal Units;
        @AuraEnabled Global Decimal Effort;
        @AuraEnabled Global String EffortUnit;
        @AuraEnabled Global Boolean ManuallyScheduled;
        @AuraEnabled Global String SchedulingMode;
        @AuraEnabled Global String SchedulingModeId;
        @AuraEnabled Global Boolean IsRecalculate;
        @AuraEnabled Global Boolean IsExternallyDependent;
        @AuraEnabled Global DateTime BaselineStartDate;
        @AuraEnabled Global DateTime BaselineEndDate;
        @AuraEnabled Global Boolean IsSuccessorRecalculate;
        @AuraEnabled Global String ParentProjectRoomID;
        @AuraEnabled Global String parentId;                          
        @AuraEnabled Global Integer SACount; 
        //*****SS 20.06.2018*****//
        //These variable will hold last element's id from a list.
        @AuraEnabled Global String lastCardid;
        @AuraEnabled Global String lastTaskid;
        //*****SS 20.06.2018*****//
        @AuraEnabled Public Boolean isLinked;
        @AuraEnabled Public String parentProjectRoomName;  
        //RS 16/11/2018
        @AuraEnabled Public Boolean isDependencyAckRecalculate;  
        /*SS 30.11.2018*/
        //With card need to show FSL data count
        @AuraEnabled Public Integer workOrderCount;
        @AuraEnabled Public Integer serviceAppointmentCount;
        @AuraEnabled Public DateTime fslSchedStartDateTime;
        @AuraEnabled Public DateTime fslSchedDueDateTime;
        /*SS 12.01.2019*///Fields are added leankor__HarveyBallDoneDate__c,leankor__PromiseCompletionDate__c
        //These fields are handled on PDG, in case of UpdateCardRecords() method, they pass sobject Field
        @AuraEnabled Public Date HarveyBallDoneDate;
        @AuraEnabled Public DateTime PromiseCompletionDate;
        /*SS 31.01.2019*/
        //ON RM for showing halo of misaligned activity UI needs min and max date of miniatures
        @AuraEnabled Public DateTime minStartDate;
        @AuraEnabled Public DateTime maxDueDate;
        //RS 14.04.2019 Added field for FSL  
        @AuraEnabled Public String saAppointmentNumber ;
        //Date : 09/05/19
        @AuraEnabled Public Boolean hasEditAccess;      
        // Date: 22/05/2019
        @AuraEnabled Public String timeToProjectLaunch;   
        // Date: 27/05/2019
        @AuraEnabled Public Boolean isAtRisk;
        @AuraEnabled Public Boolean isOnHold;
        //Date :12/11/19
        @AuraEnabled Public Boolean isScheduleRecalculate;
        //Date :13/01/2021 : Changes for Constraint.
        @AuraEnabled Public String ConstraintType;
        @AuraEnabled Public DateTime ConstraintDate; 
        @AuraEnabled Public Boolean ReadOnly;
        @AuraEnabled Public Boolean ScheduleBackwards;
        //27/05/2022 : Changes Get all data in CH with showfield.
        @AuraEnabled Public Boolean showField;
        //17/06/2022 : Changes for Constring in CH.
        @AuraEnabled Public String masterContainerId;
        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
        @AuraEnabled Public Boolean isConstraintRecalculate;
        //22/Feb/2023 : Both variable added for showing parent Card Constraint data in CV
        @AuraEnabled Public DateTime parentCardConstraintDate;
        @AuraEnabled Public String parentCardConstraintType;
        //Pratiksha : 06/Oct/2023 : Variable created for WeekCalendar functionality.
        @AuraEnabled Public Boolean Monday;
        @AuraEnabled Public Boolean Tuesday;
        @AuraEnabled Public Boolean Wednesday;   
        @AuraEnabled Public Boolean Thursday;
        @AuraEnabled Public Boolean Friday;
        @AuraEnabled Public Boolean Saturday;
        @AuraEnabled Public Boolean Sunday;
        @AuraEnabled Public String weekCalendar;
        //Pratiksha : 25/Nov/2023 : Variable added for PDG onload method.
        @AuraEnabled Public Boolean isShowWeekCalendar;
    }
    //
    // This Inner Method Is Use Resource Records On Load.
    //
    Global class CardResource{
        Global String Id;
        Global String Name;
        Global String SmallPhotoUrl;
        
        Global CardResource(String Id,String Name,string SmallPhotoUrl){
            this.Id = Id;
            this.Name = Name; 
            this.SmallPhotoUrl = SmallPhotoUrl;  
        }
    }
    //
    // This Inner Method Is Use Resource Records On Load.
    //
    Global class ResourceScheduler{
        Global List<MasterContainer> CardGanttLog;
        Global List<MasterContainer> taskGanttLog;
        Global Set<CardResource> CardResources;       
        //*****SS 20.06.2018*****//
        //Added variables and constructor for recursive call of GetKanbanCardsByResource() method      
        Global String lastCardId;
        Global String lastTaskId;
        Global Boolean hasMoreCard;
        Global Boolean hasMoreTask;
        Global ResourceScheduler(List<MasterContainer> CardGanttLog,List<MasterContainer> taskGanttLog,Set<CardResource> CardResources){
            Integer cardListSize = CardGanttLog.size();
            Integer taskListSize = taskGanttLog.size();
            this.CardGanttLog = CardGanttLog;
            this.taskGanttLog = taskGanttLog;
            this.CardResources = CardResources; 
            //Id of last Card from list.
            this.lastCardId = cardListSize!=0?CardGanttLog[cardListSize -1].Id:'';
            //Indicates that there are more records to get
            this.hasMoreCard = !(cardListSize<9999);
            //Id of last Task from list.
            this.lastTaskId = taskListSize!=0?taskGanttLog[taskListSize-1].Id:'';
            //Indicates that there are more records to get
            this.hasMoreTask = !(taskListSize<9999);
        }
        //*****SS 20.06.2018*****//
        Global ResourceScheduler(List<MasterContainer> CardGanttLog,Set<CardResource> CardResources){
      //  Global ResourceScheduler(List<MasterContainer> CardGanttLog){
            this.CardGanttLog = CardGanttLog; 
            this.CardResources = CardResources; 
        }
    }
    //
    // This Inner Method Is Use Resource Records and Gantt Old records On Load.
    //
    Global class CalenderResourceScheduler{
        Global Set<CardResource> CardResources;
        Global List<MasterContainer> CalenderCardView;      
        Global List<MasterContainer> CalenderTaskView;
        Global CalenderResourceScheduler(Set<CardResource> CardResources,List<MasterContainer> CalenderCardView){
            this.CardResources = CardResources;
            this.CalenderCardView = CalenderCardView;   
        }
         Global CalenderResourceScheduler(Set<CardResource> CardResources,List<MasterContainer> CalenderCardView,List<MasterContainer> CalenderTaskView){
            this.CardResources = CardResources;
            this.CalenderCardView = CalenderCardView;
            this.CalenderTaskView = CalenderTaskView;   
        }
        //Date: 17/06/2019 - Add to return the project board launch.
    	public String projectBoardLaunchDate;
        public String lastSetBaselineId;

        //Pratiksha : 25/01/2022 : Changes for adding the parent node in CV for Constraint.
        public GanttTaskBoard.ValueStreamPlanning valueStreamPlanning;
        public CalenderResourceScheduler(Set<CardResource> CardResources, GanttTaskBoard.ValueStreamPlanning valueStreamPlanning, List<MasterContainer> CalenderTaskView){
            this.CardResources = CardResources;
            this.valueStreamPlanning = valueStreamPlanning;
            this.CalenderTaskView = CalenderTaskView;   
    }

    }

    //
    // This Method Is Use to Get All Needed records On Load.
    // INPUT: VSID,And BoardType(for Zone display)
    // OUTPUT: list of Zone,KanbanCard,MC,Task ON load of calender View.

    @RemoteAction
    global static CalenderResourceScheduler getResources(String valueStreamId, String boardType) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        resoruceList = new List<String>();
        List<MasterContainer> allTaskList = new List<MasterContainer>();    
        Set<CardResource> cardResources = new Set<CardResource>();
        List<MasterContainer> masterContainerList = new List<MasterContainer>();
        CalenderResourceScheduler calenderResourceScheduler = new CalenderResourceScheduler(cardResources, masterContainerList, allTaskList);
        //11/06/2022 : changes for added minimum and maxinmum SD and DD in board dates when constraint is disable.
        Datetime maxTempDate;
        Datetime minTempDate;
        Integer remoteKanbansSize; 
        RealTimeControllerHelper.updateProjectBoardDates(new Set<String>{valueStreamId});
        //Pratiksha : 25/01/2022 : Changes for adding the parent node in CV for Constraint.
        List<leankor__ValueStream__c> valueStreams = [Select Id,
                                                            Name,
                                                            leankor__ProjectBoardLaunchDateTime__c,
                                                            leankor__ProjectRoom__c,
                                                            leankor__ProjectBoardStartDateTime__c,
                                                            leankor__ProjectBoardEndDateTime__c,
                                                            leankor__ScheduleBackward__c
                                                        From leankor__ValueStream__c
                                                        Where Id = :valueStreamId
                                                            And leankor__IsRecordDeleted__c = false
                                                        Limit 1];   
        
        if (valueStreams.isEmpty()) {
            return calenderResourceScheduler;
        } else {
            if (String.isBlank(valueStreams[0].leankor__ProjectRoom__c)) {
                return calenderResourceScheduler;
            }
        }

        List<leankor__Zone__c> remoteZones = [Select Id,
                                                leankor__Swimlane__r.leankor__MasterContainer__c,
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
                                                leankor__Left__c,leankor__Limit__c,
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
                                                OwnerId 
                                            From leankor__Zone__c where leankor__ValueStream__c = :valueStreamId  
                                            Order By leankor__Order__c Asc
                                            Limit 50000];
                                            
        Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
        List<leankor__KanbanCard__c> remoteKanbans = new List<leankor__KanbanCard__c>();
        List<leankor__ProjectScheduleBaseline__c> lastSetBaseline = new List<leankor__ProjectScheduleBaseline__c>();                       

        //getting last set base line record
        lastSetBaseline = [Select Id 
                                From leankor__ProjectScheduleBaseline__c 
                                Where leankor__ProjectBoard__c = :valueStreamId 
                                Order By CreatedDate Desc 
                                Limit 1];

        //List<leankor__Kanbancard__c> kanbanCards = new List<leankor__Kanbancard__c>();

        //filters  added to KanbanCard query to exclude records from either soft deleted kanbancard or Valuestream
        //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add in query for getting on constraint data on load of kanbanBoard.
        if (lastSetBaseline.size() > 0) {
            remoteKanbans = [Select Id,
                                    leankor__UrlLink__c,
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                    (Select Id,
                                            leankor__ManuallyScheduled__c,
                                            leankor__EffortActual__c,
                                            leankor__EffortUnits__c,
                                            leankor__Mode__c,
                                            leankor__ConstraintDateTime__c,
                                            leankor__ScheduleConstraint__r.leankor__Type__c
                                            //leankor__ReadOnly__c
                                        From leankor__ScheduleModes__r 
                                        Limit 1),
                                    (Select leankor__DueDateTime__c,
                                            leankor__StartDateTime__c 
                                        From leankor__Kanban_Card_Baselines__r 
                                        Where leankor__ProjectScheduleBaseline__c = :lastSetBaseline[0].Id 
                                        Limit 1),
                                    leankor__IsSuccessorRecalculate__c,
                                    leankor__CardID__c,
                                    leankor__KanbanCardTemplate__r.Name,
                                    leankor__KanbanCardTemplate__r.leankor__Color__c,
                                    leankor__ValueStreamLink__r.Name,
                                    leankor__ValueStreamCardLink__r.Name,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,
                                    Name,
                                    leankor__Order__c,
                                    leankor__Opportunity__c,
                                    leankor__Opportunity__r.Name,
                                    leankor__Account__r.Id,
                                    leankor__Account__r.Name,
                                    leankor__Actual_Time_Taken__c,
                                    leankor__Bottom__c,
                                    leankor__Budgeted_Time__c,
                                    leankor__Case__c,
                                    leankor__Case__r.Id,
                                    leankor__Case__r.Subject,
                                    leankor__Case__r.Status,
                                    leankor__Case__r.Priority,
                                    leankor__Case__r.CaseNumber,
                                    leankor__Color__c,
                                    leankor__CompletionVariance__c,
                                    leankor__CmpID__c,
                                    leankor__Contact__r.Id,
                                    leankor__Contact__r.Name,
                                    leankor__CSSLayout__c,
                                    leankor__DateColor__c,
                                    leankor__Description__c,
                                    leankor__AcceptanceCriteria__c,
                                    leankor__DescriptionLong__c,
                                    leankor__DueDate__c,
                                    leankor__DurationUnits__c,
                                    leankor__ActualDuration__c,
                                    leankor__EstimatedDuration__c,
                                    leankor__GUID__c,
                                    leankor__HarveyBallDoneDate__c,
                                    leankor__Height__c,
                                    leankor__IsCompletedOnTime__c,
                                    //leankor__JSONData__c,
                                    //leankor__JSONDefinition__c,
                                    leankor__KanbanCardTemplate__c,
                                    leankor__Left__c,
                                    leankor__PercentComplete2__c,
                                    leankor__Priority__c,
                                    leankor__StartDate__c,
                                    leankor__State__c,
                                    leankor__Title__c,
                                    leankor__Top__c,leankor__ValueStream__c,
                                    leankor__ValueStreamCardLink__c,
                                    leankor__ValueStreamLink__c,
                                    leankor__Width__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    leankor__ZoneGUID__c,
                                    OwnerID,
                                    Owner.Name,
                                    leankor__valueStream__r.leankor__BoardType__c,
                                    leankor__ValueStreamLink__r.leankor__BoardType__c,
                                    leankor__ValueStreamCardLink__r.leankor__BoardType__c,
                                    leankor__DueDateTime__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__StartDateTime__c,
                                    leankor__Point__c,
                                    leankor__EffortRemaining__c,
                                    leankor__ValueStream__r.leankor__DisableTaskAsMiniature__c,
                                    leankor__IsAtRisk__c,
                                    leankor__IsOnHold__c,
                                    RecordType.Name,
                                    leankor__ProjectRoom__c,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__WeekCalendar__c										
                                From leankor__KanbanCard__c where leankor__ValueStream__c = :valueStreamId 
                                    And leankor__IsRecordDeleted__c = false
                                Order By leankor__StartDate__c Limit 50000];
           
        } else {
            remoteKanbans = [Select Id,
                                    leankor__UrlLink__c,
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                    (Select Id,
                                            leankor__ManuallyScheduled__c,
                                            leankor__EffortActual__c,
                                            leankor__EffortUnits__c,
                                            leankor__Mode__c,
                                            leankor__ConstraintDateTime__c,
                                            leankor__ScheduleConstraint__r.leankor__Type__c
                                           // leankor__ReadOnly__c  
                                        From leankor__ScheduleModes__r 
                                        Limit 1),
                                    leankor__IsSuccessorRecalculate__c,
                                    leankor__CardID__c,
                                    leankor__KanbanCardTemplate__r.Name,
                                    leankor__KanbanCardTemplate__r.leankor__Color__c,
                                    leankor__ValueStreamLink__r.Name,
                                    leankor__ValueStreamCardLink__r.Name,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,Name,
                                    leankor__Order__c,leankor__Opportunity__c,
                                    leankor__Opportunity__r.Name,
                                    leankor__Account__r.Id,
                                    leankor__Account__r.Name,
                                    leankor__Actual_Time_Taken__c,
                                    leankor__Bottom__c,
                                    leankor__Budgeted_Time__c,
                                    leankor__Case__c,
                                    leankor__Case__r.Id,
                                    leankor__Case__r.Subject,
                                    leankor__Case__r.Status,
                                    leankor__Case__r.Priority,
                                    leankor__Case__r.CaseNumber,
                                    leankor__Color__c,
                                    leankor__CompletionVariance__c,
                                    leankor__CmpID__c,
                                    leankor__Contact__r.Id,
                                    leankor__Contact__r.Name,
                                    leankor__CSSLayout__c,
                                    leankor__DateColor__c,
                                    leankor__Description__c,
                                    leankor__AcceptanceCriteria__c,
                                    leankor__DescriptionLong__c,
                                    leankor__DueDate__c,
                                    leankor__DurationUnits__c,
                                    leankor__ActualDuration__c,
                                    leankor__EstimatedDuration__c,
                                    leankor__GUID__c,
                                    leankor__HarveyBallDoneDate__c,
                                    leankor__Height__c,
                                    leankor__IsCompletedOnTime__c,
                                    //leankor__JSONData__c,
                                    //leankor__JSONDefinition__c,
                                    leankor__KanbanCardTemplate__c,
                                    leankor__Left__c,
                                    leankor__PercentComplete2__c,
                                    leankor__Priority__c,
                                    leankor__StartDate__c,
                                    leankor__State__c,
                                    leankor__Title__c,
                                    leankor__Top__c,
                                    leankor__ValueStream__c,
                                    leankor__ValueStreamCardLink__c,
                                    leankor__ValueStreamLink__c,
                                    leankor__Width__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    leankor__ZoneGUID__c,
                                    OwnerID,
                                    Owner.Name,
                                    leankor__valueStream__r.leankor__BoardType__c,
                                    leankor__ValueStreamLink__r.leankor__BoardType__c,
                                    leankor__ValueStreamCardLink__r.leankor__BoardType__c,
                                    leankor__DueDateTime__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__StartDateTime__c,
                                    leankor__Point__c,
                                    leankor__EffortRemaining__c,
                                    leankor__ValueStream__r.leankor__DisableTaskAsMiniature__c,
                                    leankor__IsAtRisk__c,
                                    leankor__IsOnHold__c,
                                    RecordType.Name,
                                    leankor__ProjectRoom__c,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__WeekCalendar__c										
                                From leankor__KanbanCard__c 
                                Where leankor__ValueStream__c = :valueStreamId 
                                    And leankor__IsRecordDeleted__c = false
                            Order By leankor__StartDate__c 
                            Limit 50000];
        }

        /*
        for (leankor__Kanbancard__c kanbanCard : kanbanCards) {
            if (String.isNotBlank(kanbanCard.leankor__ProjectRoom__c)) {
                remoteKanbans.add(kanbanCard);
            }
        }
        */
        //22/Feb/2023 : Changes added for showing parent Card Constraint data in CV.
        Map<String, leankor__ScheduleMode__c> cardLinkScheduleMode;
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            cardLinkScheduleMode = leankor.RealTimeControllerHelper.getParentCardConstraintData(remoteKanbans);
        }
        remoteKanbansSize = remoteKanbans.size();
        if(remoteKanbansSize>0){
            AggregateResult aggregateResult = [Select 
                                                    MIN(leankor__StartDateTime__c) MinDate, 
                                                    MAX(leankor__DueDateTime__c) MaxDate 
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c =: valueStreamId 
                                                    And leankor__isRecordDeleted__c = false 
                                                    And leankor__ValueStream__r.leankor__isRecordDeleted__c = false];
            minTempDate = (DateTime)aggregateResult.get('MinDate');
            maxTempDate = (DateTime)aggregateResult.get('MaxDate');
        }
        //query task records and put results in a list        	
        List<Task> taskRecords = [Select Id,
                                        Priority,
                                        OwnerId,
                                        Subject,
                                        Status,
                                        ActivityDate,
                                        WhatId,
                                        Description,
                                        Owner.Name,
                                        LastModifiedDate,
                                        CreatedDate 
                                    From Task Where WhatId In :remoteKanbans 
                                        And What.Type = 'leankor__KanbanCard__c' 
                                        And IsDeleted = false 
                                    Order By CreatedDate Asc 
                                    Limit 50000 
                                    All Rows];
  
        //find all Task records under each KanbanCard Record       	
        for (Task task : taskRecords) {
            List<Task> taskList = taskMap.containsKey(task.WhatId) ? taskMap.get(task.WhatId) : new List<Task>();
            taskList.add(task);	
            taskMap.put(task.WhatId, taskList);
        }
           
        Integer noZoneIdCount = 0, tempCount = 0, count = 0, countSwimlane = 0;
        DateTime minSDZone, minEDZone, minSDCard, minEDCard, minSDSwim, minEDSwim;

        if (boardType == 'Kanban Board' || boardType == 'Plan Board') {
            List<leankor__MasterContainer__c> remoteMasterContainers = [Select Id,
                                                                            Name,
                                                                            leankor__Color__c,
                                                                            leankor__CmpID__c,
                                                                            leankor__GUID__c,
                                                                            leankor__Height__c,
                                                                            leankor__IsCardAvailable__c,
                                                                            leankor__Left__c,
                                                                            leankor__Limit__c,
                                                                            leankor__Order__c,
                                                                            leankor__Title__c,
                                                                            leankor__Top__c,
                                                                            leankor__Type__c,
                                                                            leankor__ValueStream__c,
                                                                            leankor__Width__c 
                                                                        From leankor__MasterContainer__c 
                                                                        Where leankor__ValueStream__c = :valueStreamId 
                                                                        Order By leankor__Order__c Asc 
                                                                        Limit 50000];

            List<leankor__Swimlane__c> remoteSwimlanes = [Select Id,
                                                                Name,
                                                                leankor__CardPerRow__c,
                                                                leankor__Color__c,
                                                                leankor__CmpID__c,
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
                                                                leankor__Width__c 
                                                            From leankor__Swimlane__c 
                                                            Where leankor__ValueStream__c = :valueStreamId
                                                            Order By leankor__Order__c Asc 
                                                            Limit 50000];

            for (leankor__MasterContainer__c remoteMasterContainer : remoteMasterContainers) {
                countSwimlane = 0; count = 0;
                MasterContainer masterContainer = new MasterContainer();

                masterContainer.Id = remoteMasterContainer.Id;
                masterContainer.Name = remoteMasterContainer.Name;
                masterContainer.IsCardAvailable = false;
                masterContainer.Color = remoteMasterContainer.leankor__Color__c;
                masterContainer.Type = remoteMasterContainer.leankor__Type__c;
                masterContainer.Limits = remoteMasterContainer.leankor__Limit__c;
                masterContainer.Title = remoteMasterContainer.leankor__Title__c;
                masterContainer.Top = Integer.valueOf(remoteMasterContainer.leankor__Top__c);
                masterContainer.Left = Integer.valueOf(remoteMasterContainer.leankor__Left__c);
                masterContainer.Width = Integer.valueOf(remoteMasterContainer.leankor__Width__c);
                masterContainer.Height = Integer.valueOf(remoteMasterContainer.leankor__Height__c);
                masterContainer.ValueStreamID = remoteMasterContainer.leankor__ValueStream__c;
                masterContainer.CmpID = remoteMasterContainer.leankor__CmpID__c;
                masterContainer.GUID = remoteMasterContainer.leankor__GUID__c;
                masterContainer.Order = remoteMasterContainer.leankor__Order__c;
                masterContainer.ItemType = 'MC';
                masterContainer.StartDate = '';
                masterContainer.DueDate = '';     

                List<MasterContainer> masterContainerSwimlanes = new List<MasterContainer>();

                for (leankor__Swimlane__c remoteSwimlane : remoteSwimlanes) {
                    Integer count1 = 0; 

                    if (remoteMasterContainer.Id == remoteSwimlane.MasterContainer__c) {
                        countSwimlane++;
                        MasterContainer masterContainerSwimlane = new MasterContainer();

                        masterContainerSwimlane.Id = remoteSwimlane.id;
                        masterContainerSwimlane.ForceID = remoteSwimlane.id;
                        masterContainerSwimlane.Name = remoteSwimlane.name;
                        masterContainerSwimlane.Title = remoteSwimlane.leankor__Title__c;
                        masterContainerSwimlane.Top = Integer.valueOf(remoteSwimlane.leankor__Top__c);
                        masterContainerSwimlane.Left = Integer.valueOf(remoteSwimlane.leankor__Left__c);
                        masterContainerSwimlane.Width = Integer.valueOf(remoteSwimlane.leankor__Width__c);
                        masterContainerSwimlane.Height = Integer.valueOf(remoteSwimlane.leankor__Height__c);
                        masterContainerSwimlane.Color = remoteSwimlane.leankor__Color__c;
                        masterContainerSwimlane.ValueStreamID = remoteSwimlane.leankor__ValueStream__c;
                        masterContainerSwimlane.CmpID = remoteSwimlane.leankor__CmpID__c;
                        masterContainerSwimlane.GUID = remoteSwimlane.leankor__GUID__c;
                        masterContainerSwimlane.CardPerRow = remoteSwimlane.leankor__CardPerRow__c;
                        masterContainerSwimlane.Help = remoteSwimlane.leankor__Help__c;
                        masterContainerSwimlane.isCardAvailable = remoteSwimlane.leankor__isCardAvailable__c;
                        masterContainerSwimlane.Limits = Integer.valueOf(remoteSwimlane.leankor__Limit__c);
                        masterContainerSwimlane.Order = Integer.valueOf(remoteSwimlane.leankor__Order__c);
                        masterContainerSwimlane.ItemType = 'SWIM';
                        masterContainerSwimlane.StartDate = '';
                        masterContainerSwimlane.DueDate = '';

                        List<MasterContainer> masterContainerZones = new List<MasterContainer>();  
                        
                        for (leankor__Zone__c remoteZone : remoteZones) {
                            if (remoteZone.leankor__Swimlane__c == remoteSwimlane.Id) {
                                noZoneIdCount++;
                                MasterContainer masterContainerZone = new MasterContainer();

                                masterContainerZone.Id = remoteZone.Id;
                                masterContainerZone.ZoneGUID = remoteZone.leankor__GUID__c;
                                masterContainerZone.MCforceID = remoteZone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                masterContainerZone.SWforceID = remoteZone.leankor__Swimlane__c;
                                masterContainerZone.ZoneForceID = remoteZone.ID;
                                masterContainerZone.Name = remoteZone.Name;
                                masterContainerZone.leaf = false;
                                masterContainerZone.Title = remoteZone.leankor__Title__c;
                                masterContainerZone.Top = Integer.valueOf(remoteZone.leankor__Top__c);
                                masterContainerZone.Bottom = Integer.valueOf(remoteZone.leankor__Bottom__c);
                                masterContainerZone.Left = Integer.valueOf(remoteZone.leankor__Left__c);
                                masterContainerZone.Width = Integer.valueOf(remoteZone.leankor__Width__c);
                                masterContainerZone.Height = Integer.valueOf(remoteZone.leankor__Height__c);
                                masterContainerZone.X = Integer.valueOf(remoteZone.leankor__x__c);
                                masterContainerZone.Y = Integer.valueOf(remoteZone.leankor__Y__c);
                                masterContainerZone.JSONDefinition = remoteZone.leankor__JSONDefinition__c;
                                masterContainerZone.ValueStreamCardLink = (remoteZone.leankor__ValueStreamCardLink__c == null ? '' : remoteZone.leankor__ValueStreamCardLink__c);
                                masterContainerZone.ValueStreamLinkID = (remoteZone.leankor__ValueStreamLink__c==null?'':remoteZone.leankor__ValueStreamLink__c);
                                masterContainerZone.ValueStreamID = remoteZone.leankor__ValueStream__c;
                                masterContainerZone.CmpID = remoteZone.leankor__CmpID__c;
                                masterContainerZone.GUID = remoteZone.leankor__GUID__c;
                                masterContainerZone.CaseStatus = (remoteZone.leankor__CaseStatus__c==null?'':remoteZone.leankor__CaseStatus__c);  
                                masterContainerZone.EntryFlowName = remoteZone.leankor__EntryFlowName__c;
                                masterContainerZone.ExitFlowName = remoteZone.leankor__ExitFlowName__c;
                                masterContainerZone.ZoneMode = remoteZone.leankor__ZoneMode__c;
                                masterContainerZone.KanbanSequence = remoteZone.leankor__KanbanSequence__c;
                                masterContainerZone.DefaultHeight = Integer.valueOf(remoteZone.leankor__DefaultHeight__c);
                                masterContainerZone.DefaultWidth = Integer.valueOf(remoteZone.leankor__DefaultWidth__c);
                                masterContainerZone.TaskLimit = remoteZone.leankor__Limit__c;
                                masterContainerZone.Order = remoteZone.leankor__Order__c;
                                masterContainerZone.ParentZone = remoteZone.leankor__ParentZone__c;
                                masterContainerZone.Swimlane = remoteZone.leankor__Swimlane__c;
                                masterContainerZone.CardsPerRow = remoteZone.leankor__CardsPerRow__c;
                                masterContainerZone.Help = remoteZone.leankor__Help__c;
                                masterContainerZone.CompletionRateUnits = remoteZone.leankor__CompletionRateUnits__c;
                                masterContainerZone.CompletionRate = Integer.valueOf(remoteZone.leankor__CompletionRate__c);
                                masterContainerZone.CSSLayout = remoteZone.leankor__CSSLayout__c;
                                masterContainerZone.KanbanCardCount = Integer.valueOf(remoteZone.leankor__KanbanCardCount2__c);
                                masterContainerZone.KanbanCardThroughput = Integer.valueOf(remoteZone.leankor__KanbanCardThroughput__c);
                                masterContainerZone.LeadTime = Integer.valueOf(remoteZone.leankor__LeadTime__c);
                                masterContainerZone.ZoneTemplate = remoteZone.leankor__ZoneTemplate__c;
                                masterContainerZone.Limits = Integer.valueOf(remoteZone.leankor__Limit__c);
                                masterContainerZone.ItemType = 'ZONE';
                                masterContainerZone.Color ='#CCCCCC';

                                Decimal tempOrderValue = 1.0;
                                List<MasterContainer> kanbanCardList = new List<MasterContainer>();

                                tempCount = 0;

                                for (Integer kbPointer = 0; kbPointer < remoteKanbans.size();) {                            
                                    if (remoteZone.leankor__GUID__c == remoteKanbans[kbPointer].leankor__ZoneGUID__c) {
                                        if (tempCount == 0) {
                                            if (remoteKanbans[kbPointer].leankor__StartDateTime__c <= remoteKanbans[kbPointer].leankor__DueDateTime__c) {
                                                minSDCard = remoteKanbans[kbPointer].leankor__StartDateTime__c;
                                                minEDCard = remoteKanbans[kbPointer].leankor__DueDateTime__c;
                                                tempCount++;
                                            }
                                        }

                                        if (remoteKanbans[kbPointer].leankor__StartDateTime__c < minSDCard) minSDCard = remoteKanbans[kbPointer].leankor__StartDateTime__c;
                                        if (remoteKanbans[kbPointer].leankor__DueDateTime__c > minEDCard) minEDCard = remoteKanbans[kbPointer].leankor__DueDateTime__c;

                                        MasterContainer masterContainerKanbanCard = new MasterContainer();
                                        
                                        masterContainerKanbanCard.Id = remoteKanbans[kbPointer].id;
                                        masterContainerKanbanCard.CardID = remoteKanbans[kbPointer].leankor__CardID__c;
                                        masterContainerKanbanCard.ForceID = remoteKanbans[kbPointer].id;
                                        masterContainerKanbanCard.Name = remoteKanbans[kbPointer].name;
                                        masterContainerKanbanCard.EstimatedDuration = remoteKanbans[kbPointer].leankor__EstimatedDuration__c;

                                        if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Days') masterContainerKanbanCard.DurationUnits = 'd';
                                        else if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Weeks') masterContainerKanbanCard.DurationUnits = 'w';
                                        else if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Hours') masterContainerKanbanCard.DurationUnits = 'h';
                                        else if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Months') masterContainerKanbanCard.DurationUnits = 'mo';
                                        else if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Years') masterContainerKanbanCard.DurationUnits = 'y';
                                        else if (remoteKanbans[kbPointer].leankor__DurationUnits__c == 'Minutes') masterContainerKanbanCard.DurationUnits = 'mi';

                                        masterContainerKanbanCard.PercentDone = remoteKanbans[kbPointer].leankor__PercentComplete2__c;
                                        masterContainerKanbanCard.DueDate = (String)JSON.Deserialize(JSON.Serialize(remoteKanbans[kbPointer].leankor__DueDateTime__c),String.class);
                                        masterContainerKanbanCard.StartDate = remoteKanbans[kbPointer].leankor__StartDateTime__c <= remoteKanbans[kbPointer].leankor__DueDateTime__c ? 
                                                                (String)JSON.Deserialize(JSON.Serialize(remoteKanbans[kbPointer].leankor__StartDateTime__c),String.class) :
                                                                masterContainerKanbanCard.DueDate;
                                        masterContainerKanbanCard.Leaf = true;
                                        masterContainerKanbanCard.Title = remoteKanbans[kbPointer].leankor__KanbanCardTemplate__r.Name;
                                        masterContainerKanbanCard.Top = Integer.valueOf(remoteKanbans[kbPointer].leankor__Top__c);
                                        masterContainerKanbanCard.Point = remoteKanbans[kbPointer].leankor__point__c;
                                        masterContainerKanbanCard.EffortRemaining = integer.valueof(remoteKanbans[kbPointer].leankor__EffortRemaining__c);
                                        masterContainerKanbanCard.Bottom = Integer.valueOf(remoteKanbans[kbPointer].leankor__Bottom__c);
                                        masterContainerKanbanCard.Left = Integer.valueOf(remoteKanbans[kbPointer].leankor__Left__c);
                                        masterContainerKanbanCard.Width = Integer.valueOf(remoteKanbans[kbPointer].leankor__Width__c);
                                        masterContainerKanbanCard.Height = Integer.valueOf(remoteKanbans[kbPointer].leankor__Height__c);
                                        masterContainerKanbanCard.X = Integer.valueOf(remoteKanbans[kbPointer].leankor__x__c);
                                        masterContainerKanbanCard.Y = Integer.valueOf(remoteKanbans[kbPointer].leankor__Y__c);
                                        //masterContainerKanbanCard.JSONData = remoteKanbans[kbPointer].leankor__JSONData__c;
                                        masterContainerKanbanCard.MCForceID = remoteKanbans[kbPointer].leankor__MasterContainer__c;
                                        masterContainerKanbanCard.SWForceID = remoteKanbans[kbPointer].leankor__Swimlane__c;
                                        masterContainerKanbanCard.ZoneForceID = remoteKanbans[kbPointer].leankor__Zone__c;
                                        //masterContainerKanbanCard.JSONDefinition = remoteKanbans[kbPointer].leankor__JSONDefinition__c;
                                        masterContainerKanbanCard.State = remoteKanbans[kbPointer].leankor__State__c;
                                        masterContainerKanbanCard.ZoneID = (remoteKanbans[kbPointer].leankor__ZoneGUID__c == null ? '' : remoteKanbans[kbPointer].leankor__ZoneGUID__c);
                                        masterContainerKanbanCard.TemplateID = (remoteKanbans[kbPointer].leankor__KanbanCardTemplate__c == null ? '' : remoteKanbans[kbPointer].leankor__KanbanCardTemplate__c);
                                        masterContainerKanbanCard.TemplateName = remoteKanbans[kbPointer].leankor__KanbanCardTemplate__r.Name;
                                        masterContainerKanbanCard.Color = remoteKanbans[kbPointer].leankor__KanbanCardTemplate__r.leankor__Color__c;
                                        masterContainerKanbanCard.Priority = Integer.valueOf(remoteKanbans[kbPointer].leankor__Priority__c);
                                        masterContainerKanbanCard.HarveyBall = String.valueOf(remoteKanbans[kbPointer].leankor__PercentComplete2__c);
                                        masterContainerKanbanCard.DateColor = remoteKanbans[kbPointer].leankor__DateColor__c;
                                        masterContainerKanbanCard.Description = remoteKanbans[kbPointer].leankor__DescriptionLong__c;
                                        masterContainerKanbanCard.AcceptanceCriteria = remoteKanbans[kbPointer].leankor__AcceptanceCriteria__c;
                                        masterContainerKanbanCard.ValueStreamCardLink = (remoteKanbans[kbPointer].leankor__ValueStreamCardLink__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamCardLink__c);
                                        masterContainerKanbanCard.ValueStreamLinkID = (remoteKanbans[kbPointer].leankor__ValueStreamLink__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamLink__c);
                                        masterContainerKanbanCard.ParentProjectRoomID = (remoteKanbans[kbPointer].leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                                        masterContainerKanbanCard.ValueStreamCardLinkName = (remoteKanbans[kbPointer].leankor__ValueStreamCardLink__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamCardLink__r.Name); 
                                        masterContainerKanbanCard.ValueStreamLinkIDName = (remoteKanbans[kbPointer].leankor__ValueStreamLink__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamLink__r.Name);
                                        masterContainerKanbanCard.ValueStreamLinkBoardType = (remoteKanbans[kbPointer].leankor__ValueStreamLink__c == null ? '' : remoteKanbans[kbPointer].leankor__ValueStreamLink__r.leankor__BoardType__c);
                                        masterContainerKanbanCard.Account = (remoteKanbans[kbPointer].leankor__Account__r.Id == null ? '' : remoteKanbans[kbPointer].leankor__Account__r.Id);
                                        masterContainerKanbanCard.Contact = (remoteKanbans[kbPointer].leankor__Contact__r.Id == null ? '' : remoteKanbans[kbPointer].leankor__Contact__r.Id);
                                        masterContainerKanbanCard.CaseID = (remoteKanbans[kbPointer].leankor__Case__r.Id == null ? '' : remoteKanbans[kbPointer].leankor__Case__r.Id);
                                        masterContainerKanbanCard.Opportunity = (remoteKanbans[kbPointer].leankor__Opportunity__c == null ? '' : remoteKanbans[kbPointer].leankor__Opportunity__c);
                                        masterContainerKanbanCard.OpportunityName = (remoteKanbans[kbPointer].leankor__Opportunity__c == null ? '' : remoteKanbans[kbPointer].leankor__Opportunity__r.Name);                                                     
                                        masterContainerKanbanCard.ValueStreamID = remoteKanbans[kbPointer].leankor__ValueStream__c;
                                        masterContainerKanbanCard.CmpID = remoteKanbans[kbPointer].leankor__CmpID__c;
                                        masterContainerKanbanCard.GUID = remoteKanbans[kbPointer].leankor__GUID__c;
                                        masterContainerKanbanCard.OwnerID = remoteKanbans[kbPointer].OwnerID;
                                        masterContainerKanbanCard.AccountName = (remoteKanbans[kbPointer].leankor__Account__r.Name == null ? '' : remoteKanbans[kbPointer].leankor__Account__r.Name);
                                        masterContainerKanbanCard.ContactName = (remoteKanbans[kbPointer].leankor__Contact__r.Name == null ? '' : remoteKanbans[kbPointer].leankor__Contact__r.Name);
                                        masterContainerKanbanCard.CaseSubject = (remoteKanbans[kbPointer].leankor__Case__c == null ? '' : (remoteKanbans[kbPointer].leankor__Case__r.Subject == null ? 'Case : '+remoteKanbans[kbPointer].leankor__Case__r.CaseNumber :remoteKanbans[kbPointer].leankor__Case__r.Subject));                
                                        masterContainerKanbanCard.CaseStatus = (remoteKanbans[kbPointer].leankor__Case__r.Status == null ? '' : remoteKanbans[kbPointer].leankor__Case__r.Status);  
                                        masterContainerKanbanCard.CasePriority = (remoteKanbans[kbPointer].leankor__Case__r.Priority == null ? '' : remoteKanbans[kbPointer].leankor__Case__r.Priority); 
                                        masterContainerKanbanCard.CaseTrigger = false;
                                        masterContainerKanbanCard.ZoneTitle = '';
                                        masterContainerKanbanCard.LeavedZoneTitle = '';
                                        masterContainerKanbanCard.Base64Drawing = '';
                                        masterContainerKanbanCard.Base64FileType = ''; 
                                        masterContainerKanbanCard.KanbanUrl = '';
                                        masterContainerKanbanCard.ItemType = remoteKanbans[kbPointer].RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC' ; 
                                        masterContainerKanbanCard.BoardType = 'Kanban Board';
                                        masterContainerKanbanCard.Order = (remoteKanbans[kbPointer].leankor__Order__c == null ? tempOrderValue : remoteKanbans[kbPointer].leankor__Order__c); 
                                        masterContainerKanbanCard.OnBudget = remoteKanbans[kbPointer].leankor__OnBudget__c;
                                        masterContainerKanbanCard.OnQuality = remoteKanbans[kbPointer].leankor__OnQuality__c;
                                        masterContainerKanbanCard.OnTime = remoteKanbans[kbPointer].leankor__OnTime__c;
                                        masterContainerKanbanCard.OwnerName = remoteKanbans[kbPointer].Owner.Name;
                                        masterContainerKanbanCard.IsSuccessorRecalculate = remoteKanbans[kbPointer].leankor__IsSuccessorRecalculate__c;
                                        masterContainerKanbanCard.UrlLink = remoteKanbans[kbPointer].leankor__UrlLink__c;
                                        masterContainerKanbanCard.isAtRisk = remoteKanbans[kbPointer].leankor__IsAtRisk__c;
                                        masterContainerKanbanCard.isOnHold = remoteKanbans[kbPointer].leankor__IsOnHold__c;
                                        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
                                        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                        	masterContainerKanbanCard.isConstraintRecalculate = remoteKanbans[kbPointer].leankor__IsConstraintRecalculate__c;
                                        }

                                        //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for getting Constraint data on load of kanbanBoard;
                                        if (remoteKanbans[kbPointer].leankor__ScheduleModes__r != null && remoteKanbans[kbPointer].leankor__ScheduleModes__r.size() > 0) {
                                            masterContainerKanbanCard.SchedulingModeId = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].Id;
                                            masterContainerKanbanCard.ManuallyScheduled = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                                            masterContainerKanbanCard.Effort = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                                            masterContainerKanbanCard.EffortUnit = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                                            masterContainerKanbanCard.SchedulingMode = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__Mode__c;
                                            //Changes : Check constraint setting enable or not.
                                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                                masterContainerKanbanCard.ConstraintType = (remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c)) ? remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : '';
                                                masterContainerKanbanCard.ConstraintDate = (remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null) ? remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                                            }
                                            //masterContainerKanbanCard.ReadOnly = remoteKanbans[kbPointer].leankor__ScheduleModes__r[0].leankor__ReadOnly__c;
                                        }
                                        
                                        if (remoteKanbans[kbPointer].leankor__Kanban_Card_Baselines__r.size() > 0){
                                            masterContainerKanbanCard.BaselineStartDate = remoteKanbans[kbPointer].leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                                            masterContainerKanbanCard.BaselineEndDate = remoteKanbans[kbPointer].leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c; 
                                        }
                                        //22/Feb/2023 : Changes added for showing parent Card Constraint data in CV.
                                        if(String.isNotBlank(remoteKanbans[kbPointer].leankor__ValueStreamCardLink__c) &&(remoteKanbans[kbPointer].leankor__ValueStreamCardLink__r.leankor__BoardType__c =='UberBoard' || remoteKanbans[kbPointer].leankor__ValueStreamCardLink__r.leankor__BoardType__c =='Plan Board') && (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS)){
                                            leankor__ScheduleMode__c scheduleModeRecord = cardLinkScheduleMode.get(remoteKanbans[kbPointer].leankor__ValueStreamCardLink__c);
                                            masterContainerKanbanCard.parentCardConstraintType = String.isNotBlank(scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c) ? scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c : '';
                                            masterContainerKanbanCard.parentCardConstraintDate = scheduleModeRecord.leankor__ConstraintDateTime__c!= null  ? scheduleModeRecord.leankor__ConstraintDateTime__c : null;
                                        }

                                        //Pratiksha : 18/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                                        if(remoteKanbans[kbPointer].leankor__Monday__c == false && remoteKanbans[kbPointer].leankor__Tuesday__c == false && remoteKanbans[kbPointer].leankor__Wednesday__c == false &&  remoteKanbans[kbPointer].leankor__Thursday__c == false &&  remoteKanbans[kbPointer].leankor__Friday__c == false &&  remoteKanbans[kbPointer].leankor__Saturday__c == false &&  remoteKanbans[kbPointer].leankor__Sunday__c == false){
                                            masterContainerKanbanCard.Monday = true;
                                            masterContainerKanbanCard.Tuesday = true;
                                            masterContainerKanbanCard.Wednesday = true;
                                            masterContainerKanbanCard.Thursday = true;
                                            masterContainerKanbanCard.Friday = true;
                                            masterContainerKanbanCard.Saturday = true;
                                            masterContainerKanbanCard.Sunday = true;
                                        }else{
                                            //Pratiksha : 12/Oct/2023 : Passing these week day onLoad on CV of KanbanBoard.
                                            masterContainerKanbanCard.Monday = remoteKanbans[kbPointer].leankor__Monday__c;
                                            masterContainerKanbanCard.Tuesday = remoteKanbans[kbPointer].leankor__Tuesday__c;
                                            masterContainerKanbanCard.Wednesday = remoteKanbans[kbPointer].leankor__Wednesday__c;
                                            masterContainerKanbanCard.Thursday = remoteKanbans[kbPointer].leankor__Thursday__c;
                                            masterContainerKanbanCard.Friday = remoteKanbans[kbPointer].leankor__Friday__c;
                                            masterContainerKanbanCard.Saturday = remoteKanbans[kbPointer].leankor__Saturday__c;
                                            masterContainerKanbanCard.Sunday = remoteKanbans[kbPointer].leankor__Sunday__c;
                                            masterContainerKanbanCard.weekCalendar = remoteKanbans[kbPointer].leankor__WeekCalendar__c;
                                        }
                                        kanbanCardList.add(masterContainerKanbanCard);

                                        if (remoteKanbans[kbPointer].OwnerId != null){
                                            resoruceList.add(remoteKanbans[kbPointer].OwnerId);
                                        }
                                        if (taskMap.get(remoteKanbans[kbPointer].Id) != null && taskMap.ContainsKey(remoteKanbans[kbPointer].Id)) {
                                            List<Task> tempTaskList = taskMap.get(remoteKanbans[kbPointer].Id);

                                            if (tempTaskList.Size() > 0) {
                                                if (remoteKanbans[kbPointer].leankor__ValueStream__r.leankor__DisableTaskAsMiniature__c == true) {
                                                    MasterContainer masterContainerTask = new MasterContainer();

                                                    masterContainerTask.Name = 'Tasks for ' + masterContainerKanbanCard.Name;
                                                    masterContainerTask.Id = masterContainerKanbanCard.Id + '-T';
                                                    masterContainerTask.ValueStreamID = valueStreamId;
                                                    masterContainerTask.Leaf = false;
                                                    masterContainerTask.Title = 'Tasks for ' + masterContainerKanbanCard.Name;
                                                    masterContainerTask.Order = (masterContainerKanbanCard.Order == null ? (tempOrderValue + 0.3) : masterContainerKanbanCard.Order + 0.3);
                                                    masterContainerTask.expanded = true;
                                                    masterContainerTask.ItemType = 'Ghost';
                                                    masterContainerTask.Color ='#CCCCCC';                                                                                                                                                 
                                                    masterContainerTask.StartDate = masterContainerKanbanCard.StartDate;
                                                    masterContainerTask.DueDate = masterContainerKanbanCard.DueDate;
                                                    masterContainerTask.children = getAllTask(tempTaskList);
                                                    
                                                    kanbanCardList.add(masterContainerTask);

                                                } else {                                                
                                                    allTaskList.addAll(getAllTask(tempTaskList));
                                                }
                                            } 	
                                        }
                                        tempOrderValue++;
                                        remoteKanbans.remove(kbPointer);
                                    }else {
                                        kbPointer++;
                                    }
                                } 

                                masterContainerZone.StartDate = String.valueOf(json.deserialize(JSON.Serialize(minSDCard), String.class));
                                masterContainerZone.DueDate = String.valueOf(json.deserialize(JSON.Serialize(minEDCard), String.class));
                                masterContainerZone.children = kanbanCardList;
                                masterContainerZone.expanded = true;
                                masterContainerZones.add(masterContainerZone);

                                if (count1 == 0 && minSDCard != null && minEDCard != null) {
                                    minSDZone = minSDCard;
                                    minEDZone = minEDCard;
                                    count1++;
                                }
                                
                                if (minSDCard<minSDZone) minSDZone = minSDCard;
                                if (minEDCard>minEDZone) minEDZone = minEDCard;

                                minSDCard = null;
                                minEDCard = null;
                            }
                        }

                        masterContainerSwimlane.StartDate = String.valueOf(JSON.deserialize(JSON.Serialize(minSDZone), String.class));
                        masterContainerSwimlane.DueDate = String.valueOf(JSON.deserialize(JSON.Serialize(minEDZone), String.class));
                
                        masterContainerSwimlane.children = masterContainerZones;
                        masterContainerSwimlane.leaf = false;
                        masterContainerSwimlane.expanded = true;
                        masterContainerSwimlanes.add(masterContainerSwimlane);

                        if (count == 0 && minSDZone != null && minEDZone != null) {
                            minSDSwim = minSDZone;
                            minEDSwim = minEDZone;
                            count++;
                        }

                        if (minSDZone < minSDSwim) minSDSwim = minSDZone;
                        if (minEDZone > minEDSwim) minEDSwim = minEDZone;

                        minSDZone = null;
                        minEDZone = null;   
                    }
                }

                masterContainer.StartDate = String.valueOf(JSON.deserialize(JSON.Serialize(minSDSwim), String.class));
                masterContainer.DueDate = String.valueOf(JSON.deserialize(JSON.Serialize(minEDSwim), String.class));
                minSDSwim = null;
                minEDSwim = null;

                if (countSwimlane == 1) { 
                    if (masterContainerSwimlanes[0].children.size() > 1) {
                        masterContainer.children=masterContainerSwimlanes[0].children;
                    } else {
                        masterContainer.ZoneForceID =masterContainerSwimlanes[0].children[0].ZoneForceID;
                        masterContainer.SWforceID =masterContainerSwimlanes[0].children[0].SWforceID;
                        masterContainer.MCforceID =masterContainerSwimlanes[0].children[0].MCforceID;
                        masterContainer.GUID =masterContainerSwimlanes[0].children[0].GUID;
                        masterContainer.children=masterContainerSwimlanes[0].children[0].children;
                    }

                } else{
                    masterContainer.children = masterContainerSwimlanes;

                    if (countSwimlane > 1) {
                        for (MasterContainer s : masterContainerSwimlanes){
                            if (s.children.size() == 1){
                                s.ZoneForceID = s.children[0].ZoneForceID;
                                s.SWforceID = s.children[0].SWforceID;
                                s.MCforceID = s.children[0].MCforceID;
                                s.GUID = s.children[0].GUID;
                                s.children = s.children[0].children;
                            }
                        }
                    }
                }
                    
                masterContainer.expanded = true;
                masterContainer.leaf = false;

                masterContainerList.add(masterContainer);
            }
        
            // Changes : RK : 17/11/2020 - Clearing list to decreese heap size. 
            remoteMasterContainers.clear();
            remoteSwimlanes.clear();
        } else if (boardType == 'Whiteboard' || boardType == 'Dashboard') {
            noZoneIdCount = 0;
            
            for (leankor__Zone__c remoteZone : remoteZones) {
                noZoneIdCount++;
                MasterContainer masterContainerZone = new MasterContainer();

                masterContainerZone.Id = remoteZone.Id;
                masterContainerZone.ZoneGUID = remoteZone.leankor__GUID__c;
                masterContainerZone.MCforceID = (remoteZone.leankor__Swimlane__r.leankor__MasterContainer__c == null ? '' : remoteZone.leankor__Swimlane__r.leankor__MasterContainer__c);
                masterContainerZone.SWforceID = (remoteZone.leankor__Swimlane__c == null ? '' : remoteZone.leankor__Swimlane__c);
                masterContainerZone.ZoneForceID = remoteZone.ID;
                masterContainerZone.Name = remoteZone.Name;                        
                masterContainerZone.Leaf = false;
                masterContainerZone.Title = remoteZone.leankor__Title__c;
                masterContainerZone.Top = Integer.valueOf(remoteZone.leankor__Top__c);
                masterContainerZone.Bottom = Integer.valueOf(remoteZone.leankor__Bottom__c);
                masterContainerZone.Left = Integer.valueOf(remoteZone.leankor__Left__c);
                masterContainerZone.Width = Integer.valueOf(remoteZone.leankor__Width__c);
                masterContainerZone.Height = Integer.valueOf(remoteZone.leankor__Height__c);
                masterContainerZone.X = Integer.valueOf(remoteZone.leankor__x__c);
                masterContainerZone.Y = Integer.valueOf(remoteZone.leankor__Y__c);
                masterContainerZone.JSONDefinition = remoteZone.leankor__JSONDefinition__c;
                masterContainerZone.ValueStreamCardLink = (remoteZone.leankor__ValueStreamCardLink__c == null ? '' : remoteZone.leankor__ValueStreamCardLink__c);
                masterContainerZone.ValueStreamLinkID = (remoteZone.leankor__ValueStreamLink__c == null ? '' : remoteZone.leankor__ValueStreamLink__c);
                masterContainerZone.ValueStreamId = remoteZone.leankor__ValueStream__c;
                masterContainerZone.CmpID = remoteZone.leankor__CmpID__c;
                masterContainerZone.GUID = remoteZone.leankor__GUID__c;
                masterContainerZone.CaseStatus = (remoteZone.leankor__CaseStatus__c == null ? '' : remoteZone.leankor__CaseStatus__c);  
                masterContainerZone.EntryFlowName = remoteZone.leankor__EntryFlowName__c;
                masterContainerZone.ExitFlowName = remoteZone.leankor__ExitFlowName__c;
                masterContainerZone.ZoneMode = remoteZone.leankor__ZoneMode__c;
                masterContainerZone.KanbanSequence = remoteZone.leankor__KanbanSequence__c;
                masterContainerZone.DefaultHeight = Integer.valueOf(remoteZone.leankor__DefaultHeight__c);
                masterContainerZone.DefaultWidth = Integer.valueOf(remoteZone.leankor__DefaultWidth__c);
                masterContainerZone.TaskLimit = remoteZone.leankor__Limit__c;
                masterContainerZone.Order = remoteZone.leankor__Order__c;
                masterContainerZone.ParentZone = remoteZone.leankor__ParentZone__c;
                masterContainerZone.Swimlane = remoteZone.leankor__Swimlane__c;
                masterContainerZone.CardsPerRow = remoteZone.leankor__CardsPerRow__c;
                masterContainerZone.Help = remoteZone.leankor__Help__c;
                masterContainerZone.CompletionRateUnits = remoteZone.leankor__CompletionRateUnits__c;
                masterContainerZone.CompletionRate = Integer.valueOf(remoteZone.leankor__CompletionRate__c);
                masterContainerZone.CSSLayout = remoteZone.leankor__CSSLayout__c;
                masterContainerZone.KanbanCardCount = Integer.valueOf(remoteZone.leankor__KanbanCardCount2__c);
                masterContainerZone.KanbanCardThroughput = Integer.valueOf(remoteZone.leankor__KanbanCardThroughput__c);
                masterContainerZone.LeadTime=Integer.valueOf(remoteZone.leankor__LeadTime__c);
                masterContainerZone.ZoneTemplate = remoteZone.leankor__ZoneTemplate__c;
                masterContainerZone.ItemType = 'ZONE';
                masterContainerZone.Color ='#CCCCCC';

                List<MasterContainer> kanbanCardList = new List<MasterContainer>();
                Decimal tempOrder = 1.0;

                tempCount = 0;

                for (leankor__KanbanCard__c remoteKanban : remoteKanbans) {
                    if(remoteZone.leankor__GUID__c == remoteKanban.leankor__ZoneGUID__c) {
                        if (tempCount == 0){
                            if (remoteKanban.leankor__StartDateTime__c <= remoteKanban.leankor__DueDateTime__c) {
                                minSDCard = remoteKanban.leankor__StartDateTime__c;
                                minEDCard = remoteKanban.leankor__DueDateTime__c;
                                tempCount++;
                            }
                        }

                        if (remoteKanban.leankor__StartDateTime__c < minSDCard) minSDCard = remoteKanban.leankor__StartDateTime__c;
                        if (remoteKanban.leankor__DueDateTime__c > minEDCard) minEDCard = remoteKanban.leankor__DueDateTime__c;

                        MasterContainer masterContainerKanbanCard = new MasterContainer();

                        masterContainerKanbanCard.Id = remoteKanban.id;
                        masterContainerKanbanCard.ForceID = remoteKanban.id;
                        masterContainerKanbanCard.Name = remoteKanban.name;
                        masterContainerKanbanCard.EstimatedDuration = remoteKanban.leankor__EstimatedDuration__c;

                        if (remoteKanban.leankor__DurationUnits__c == 'Days') masterContainerKanbanCard.DurationUnits = 'd';
                        else if (remoteKanban.leankor__DurationUnits__c == 'Weeks') masterContainerKanbanCard.DurationUnits = 'w';
                        else if (remoteKanban.leankor__DurationUnits__c == 'Hours') masterContainerKanbanCard.DurationUnits = 'h';
                        else if (remoteKanban.leankor__DurationUnits__c == 'Months') masterContainerKanbanCard.DurationUnits = 'mo';
                        else if (remoteKanban.leankor__DurationUnits__c == 'Years') masterContainerKanbanCard.DurationUnits = 'y';
                        else if (remoteKanban.leankor__DurationUnits__c == 'Minutes') masterContainerKanbanCard.DurationUnits = 'mi';
                        
                        masterContainerKanbanCard.DueDate = (String)JSON.Deserialize(JSON.Serialize(remoteKanban.leankor__DueDateTime__c), String.class);
                        masterContainerKanbanCard.StartDate = remoteKanban.leankor__StartDateTime__c <= remoteKanban.leankor__DueDateTime__c 
                            ? (String)JSON.Deserialize(JSON.Serialize(remoteKanban.leankor__StartDateTime__c), String.class) 
                            : masterContainerKanbanCard.DueDate;
                        
                        masterContainerKanbanCard.PercentDone = remoteKanban.leankor__PercentComplete2__c;
                        masterContainerKanbanCard.Leaf = true;
                        masterContainerKanbanCard.CardID = remoteKanban.leankor__CardID__c;
                        masterContainerKanbanCard.Title = remoteKanban.leankor__KanbanCardTemplate__r.Name;
                        masterContainerKanbanCard.Point = remoteKanban.leankor__point__c;
                        masterContainerKanbanCard.EffortRemaining = Integer.valueof(remoteKanban.leankor__EffortRemaining__c);
                        masterContainerKanbanCard.Top = Integer.valueOf(remoteKanban.leankor__Top__c);
                        masterContainerKanbanCard.Bottom = Integer.valueOf(remoteKanban.leankor__Bottom__c);
                        masterContainerKanbanCard.Left = Integer.valueOf(remoteKanban.leankor__Left__c);
                        masterContainerKanbanCard.Width = Integer.valueOf(remoteKanban.leankor__Width__c);
                        masterContainerKanbanCard.Height = Integer.valueOf(remoteKanban.leankor__Height__c);
                        masterContainerKanbanCard.X = Integer.valueOf(remoteKanban.leankor__x__c);
                        masterContainerKanbanCard.Y = Integer.valueOf(remoteKanban.leankor__Y__c);
                        //masterContainerKanbanCard.JSONData = remoteKanban.leankor__JSONData__c;
                        //masterContainerKanbanCard.JSONDefinition = remoteKanban.leankor__JSONDefinition__c;
                        masterContainerKanbanCard.State = remoteKanban.leankor__State__c;
                        masterContainerKanbanCard.ZoneID = (remoteKanban.leankor__ZoneGUID__c == null ? '' : remoteKanban.leankor__ZoneGUID__c);
                        masterContainerKanbanCard.MCForceID = (remoteKanban.leankor__MasterContainer__c == null ? '' : remoteKanban.leankor__MasterContainer__c);
                        masterContainerKanbanCard.SWForceID = (remoteKanban.leankor__Swimlane__c == Null ? '' : remoteKanban.leankor__Swimlane__c);
                        masterContainerKanbanCard.ZoneForceID = (remoteKanban.leankor__Zone__c == Null ? '' : remoteKanban.leankor__Zone__c);
                        masterContainerKanbanCard.TemplateID = (remoteKanban.leankor__KanbanCardTemplate__c == null ? '' : remoteKanban.leankor__KanbanCardTemplate__c);
                        masterContainerKanbanCard.TemplateName = remoteKanban.leankor__KanbanCardTemplate__r.Name;
                        masterContainerKanbanCard.Color = remoteKanban.leankor__KanbanCardTemplate__r.leankor__Color__c;
                        masterContainerKanbanCard.Priority = Integer.valueOf(remoteKanban.leankor__Priority__c);
                        masterContainerKanbanCard.HarveyBall = String.valueOf(remoteKanban.leankor__PercentComplete2__c);
                        masterContainerKanbanCard.DateColor = remoteKanban.leankor__DateColor__c;
                        masterContainerKanbanCard.Description = remoteKanban.leankor__DescriptionLong__c;
                        masterContainerKanbanCard.AcceptanceCriteria = remoteKanban.leankor__AcceptanceCriteria__c;
                        masterContainerKanbanCard.ValueStreamCardLink = (remoteKanban.leankor__ValueStreamCardLink__c == null ? '' : remoteKanban.leankor__ValueStreamCardLink__c);
                        masterContainerKanbanCard.ValueStreamLinkID = (remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__c);
                        masterContainerKanbanCard.ParentProjectRoomID = (remoteKanban.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                        masterContainerKanbanCard.ValueStreamCardLinkName = (remoteKanban.leankor__ValueStreamCardLink__c == null ? '' : remoteKanban.leankor__ValueStreamCardLink__r.Name); 
                        masterContainerKanbanCard.ValueStreamLinkIDName = (remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.Name);
                        masterContainerKanbanCard.ValueStreamLinkBoardType = (remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.leankor__BoardType__c);
                        masterContainerKanbanCard.Account = (remoteKanban.leankor__Account__r.Id == null ? '' : remoteKanban.leankor__Account__r.Id);
                        masterContainerKanbanCard.Contact = (remoteKanban.leankor__Contact__r.Id == null ? '' : remoteKanban.leankor__Contact__r.Id);
                        masterContainerKanbanCard.CaseID = (remoteKanban.leankor__Case__r.Id == null ? '' : remoteKanban.leankor__Case__r.Id);
                        masterContainerKanbanCard.Opportunity = (remoteKanban.leankor__Opportunity__c == null ? '' : remoteKanban.leankor__Opportunity__c);
                        masterContainerKanbanCard.OpportunityName = (remoteKanban.leankor__Opportunity__c == null ? '' : remoteKanban.leankor__Opportunity__r.Name);
                        masterContainerKanbanCard.ValueStreamID = remoteKanban.leankor__ValueStream__c;
                        masterContainerKanbanCard.CmpID = remoteKanban.leankor__CmpID__c;
                        masterContainerKanbanCard.GUID = remoteKanban.leankor__GUID__c;
                        masterContainerKanbanCard.OwnerID = remoteKanban.OwnerID;
                        masterContainerKanbanCard.AccountName = (remoteKanban.leankor__Account__r.Name == null ? '' : remoteKanban.leankor__Account__r.Name);
                        masterContainerKanbanCard.ContactName = (remoteKanban.leankor__Contact__r.Name == null ? '' : remoteKanban.leankor__Contact__r.Name);
                        masterContainerKanbanCard.CaseSubject= (remoteKanban.leankor__Case__c == null ? '' : (remoteKanban.leankor__Case__r.Subject == null ? 'Case : '+remoteKanban.leankor__Case__r.CaseNumber :remoteKanban.leankor__Case__r.Subject));                
                        masterContainerKanbanCard.CaseStatus = (remoteKanban.leankor__Case__r.Status == null ? '' : remoteKanban.leankor__Case__r.Status);  
                        masterContainerKanbanCard.CasePriority = (remoteKanban.leankor__Case__r.Priority == null ? '' : remoteKanban.leankor__Case__r.Priority); 
                        masterContainerKanbanCard.CaseTrigger = false;
                        masterContainerKanbanCard.ZoneTitle = '';
                        masterContainerKanbanCard.LeavedZoneTitle = '';
                        masterContainerKanbanCard.Base64Drawing = '';
                        masterContainerKanbanCard.Base64FileType = ''; 
                        masterContainerKanbanCard.KanbanUrl = '';
                        masterContainerKanbanCard.ItemType = remoteKanban.RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC' ;
                        masterContainerKanbanCard.BoardType = 'Whiteboard';
                        masterContainerKanbanCard.Order = tempOrder;
                        masterContainerKanbanCard.OnBudget = remoteKanban.leankor__OnBudget__c;
                        masterContainerKanbanCard.OnQuality = remoteKanban.leankor__OnQuality__c;
                        masterContainerKanbanCard.OnTime = remoteKanban.leankor__OnTime__c;
                        masterContainerKanbanCard.OwnerName = remoteKanban.Owner.Name;
                        
                        //sending to UI IsSuccessorRecalculate field value
                        masterContainerKanbanCard.IsSuccessorRecalculate = remoteKanban.leankor__IsSuccessorRecalculate__c;
                        masterContainerKanbanCard.UrlLink = remoteKanban.leankor__UrlLink__c;
                        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
                        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                        	masterContainerKanbanCard.isConstraintRecalculate = remoteKanban.leankor__IsConstraintRecalculate__c;
                        }

                        //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for getting constraint data on load.
                        if (remoteKanban.leankor__ScheduleModes__r != null && remoteKanban.leankor__ScheduleModes__r.size() > 0) {
                            masterContainerKanbanCard.SchedulingModeId = remoteKanban.leankor__ScheduleModes__r[0].Id;
                            masterContainerKanbanCard.ManuallyScheduled = remoteKanban.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                            masterContainerKanbanCard.Effort = remoteKanban.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                            masterContainerKanbanCard.EffortUnit = remoteKanban.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                            masterContainerKanbanCard.SchedulingMode = remoteKanban.leankor__ScheduleModes__r[0].leankor__Mode__c;
                            //Changes : Check constraint setting enable or not.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                masterContainerKanbanCard.ConstraintDate = remoteKanban.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                                masterContainerKanbanCard.ConstraintType = remoteKanban.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                            }
                           // masterContainerKanbanCard.ReadOnly = remoteKanban.leankor__ScheduleModes__r[0].leankor__ReadOnly__c;
                        }
                        
                        masterContainerKanbanCard.isAtRisk = remoteKanban.leankor__IsAtRisk__c;
                        masterContainerKanbanCard.isOnHold = remoteKanban.leankor__IsOnHold__c;

                        if (remoteKanban.leankor__Kanban_Card_Baselines__r.size() > 0) {
                            masterContainerKanbanCard.BaselineStartDate = remoteKanban.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                            masterContainerKanbanCard.BaselineEndDate = remoteKanban.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c; 
                        }

                        //Pratiksha : 12/Oct/2023 : Passing these week day onLoad on CV of WhiteBoard/DashBoard.
                        masterContainerKanbanCard.Monday = remoteKanban.leankor__Monday__c;
                        masterContainerKanbanCard.Tuesday = remoteKanban.leankor__Tuesday__c;
                        masterContainerKanbanCard.Wednesday = remoteKanban.leankor__Wednesday__c;
                        masterContainerKanbanCard.Thursday = remoteKanban.leankor__Thursday__c;
                        masterContainerKanbanCard.Friday = remoteKanban.leankor__Friday__c;
                        masterContainerKanbanCard.Saturday = remoteKanban.leankor__Saturday__c;
                        masterContainerKanbanCard.Sunday = remoteKanban.leankor__Sunday__c;
                        masterContainerKanbanCard.weekCalendar = remoteKanban.leankor__WeekCalendar__c;

                        kanbanCardList.add(masterContainerKanbanCard);

                        if (remoteKanban.OwnerId != null) {
                            resoruceList.add(remoteKanban.OwnerId);
                        }

                        if (taskMap.get(remoteKanban.Id) != null && taskMap.ContainsKey(remoteKanban.Id)) {
                            //List<MasterContainer> KCTaskList = new List<MasterContainer>();
                            List<Task> tempTaskList = taskMap.get(remoteKanban.Id);

                            if (tempTaskList.Size() > 0) {
                                if (remoteKanban.leankor__ValueStream__r.leankor__DisableTaskAsMiniature__c == true) {
                                    MasterContainer masterContainerTask = new MasterContainer();
                                    
                                    masterContainerTask.Name = 'Tasks for ' + masterContainerKanbanCard.Name;
                                    masterContainerTask.Id = masterContainerKanbanCard.Id + '-T';
                                    masterContainerTask.ValueStreamID = valueStreamId;
                                    masterContainerTask.leaf = false;
                                    masterContainerTask.Title = 'Tasks for ' + masterContainerKanbanCard.Name;
                                    masterContainerTask.Order = (masterContainerKanbanCard.Order + 0.3);
                                    masterContainerTask.expanded = true;
                                    masterContainerTask.ItemType = 'Ghost';
                                    masterContainerTask.Color = '#CCCCCC';                                                                                                                                                 
                                    masterContainerTask.StartDate = masterContainerKanbanCard.StartDate;
                                    masterContainerTask.DueDate = masterContainerKanbanCard.DueDate;
                                    masterContainerTask.children = getAllTask(tempTaskList);

                                    kanbanCardList.add(masterContainerTask);
                                } else {
                                    allTaskList.addAll(getAllTask(tempTaskList));
                                }                                                                 
                            }
                        }

                        tempOrder++;
                    }
                }

                masterContainerZone.StartDate = String.valueOf(JSON.deserialize(JSON.Serialize(minSDCard),String.class));
                masterContainerZone.DueDate = String.valueOf(JSON.deserialize(JSON.Serialize(minEDCard),String.class));
                masterContainerZone.children = kanbanCardList;
                masterContainerZone.expanded = true;
                masterContainerList.add(masterContainerZone);

                if (count == 0 ) {
                    minSDZone = minSDCard;
                    minEDZone = minEDCard;
                    count++;
                }
                
                if (minSDCard<minSDZone) minSDZone = minSDCard;
                if (minEDCard>minEDZone) minEDZone = minEDCard;

                minSDCard = null;
                minEDCard = null;
            }

            Integer flag = 0, tempCount_c = 0;
            DateTime minSDCard_c, minEDCard_c;
            List<MasterContainer> noZoneKanbanCardList = new List<MasterContainer>();
            MasterContainer noZone = new MasterContainer();
            Decimal tempOrder = 0.0;
            
            for (leankor__KanbanCard__c remoteKanban: remoteKanbans) {
                if ((remoteKanban.leankor__ZoneGUID__c == null || remoteKanban.leankor__ZoneGUID__c == '') && remoteKanban.leankor__ValueStream__c == valueStreamId) {
                    flag = 1;

                    if (tempCount_c == 0) {
                        if (remoteKanban.leankor__StartDateTime__c <= remoteKanban.leankor__DueDateTime__c) {
                            minSDCard_c = remoteKanban.leankor__StartDateTime__c;
                            minEDCard_c = remoteKanban.leankor__DueDateTime__c;
                            tempCount_c++;
                        }
                    }

                    if (remoteKanban.leankor__StartDateTime__c < minSDCard_c) minSDCard_c = remoteKanban.leankor__StartDateTime__c;
                    if (remoteKanban.leankor__DueDateTime__c > minEDCard_c) minEDCard_c = remoteKanban.leankor__DueDateTime__c;

                    MasterContainer noZoneMasterContainer = new MasterContainer();

                    noZoneMasterContainer.Id = remoteKanban.Id;
                    noZoneMasterContainer.ForceID = remoteKanban.Id;
                    noZoneMasterContainer.Name = remoteKanban.name;
                    noZoneMasterContainer.EstimatedDuration = remoteKanban.leankor__EstimatedDuration__c;

                    if (remoteKanban.leankor__DurationUnits__c == 'Days') noZoneMasterContainer.DurationUnits = 'd';
                    else if (remoteKanban.leankor__DurationUnits__c == 'Weeks') noZoneMasterContainer.DurationUnits = 'w';
                    else if (remoteKanban.leankor__DurationUnits__c == 'Hours') noZoneMasterContainer.DurationUnits = 'h';
                    else if (remoteKanban.leankor__DurationUnits__c == 'Months') noZoneMasterContainer.DurationUnits = 'mo';
                    else if (remoteKanban.leankor__DurationUnits__c == 'Years') noZoneMasterContainer.DurationUnits = 'y';
                    else if (remoteKanban.leankor__DurationUnits__c == 'Minutes') noZoneMasterContainer.DurationUnits = 'mi';

                    noZoneMasterContainer.PercentDone = remoteKanban.leankor__PercentComplete2__c;                            
                    noZoneMasterContainer.DueDate = (String)JSON.Deserialize(JSON.Serialize(remoteKanban.leankor__DueDateTime__c), String.class);
                    noZoneMasterContainer.StartDate = remoteKanban.leankor__StartDateTime__c <= remoteKanban.leankor__DueDateTime__c 
                                            ? (String)JSON.Deserialize(JSON.Serialize(remoteKanban.leankor__StartDateTime__c), String.class) 
                                            : noZoneMasterContainer.DueDate;
                    noZoneMasterContainer.Leaf = true;
                    noZoneMasterContainer.Title = remoteKanban.leankor__KanbanCardTemplate__r.Name;
                    noZoneMasterContainer.CardID = remoteKanban.leankor__CardID__c;
                    noZoneMasterContainer.Point = remoteKanban.leankor__Point__c;
                    noZoneMasterContainer.EffortRemaining = Integer.valueof(remoteKanban.leankor__EffortRemaining__c);
                    noZoneMasterContainer.Top = Integer.valueOf(remoteKanban.leankor__Top__c);
                    noZoneMasterContainer.Bottom = Integer.valueOf(remoteKanban.leankor__Bottom__c);
                    noZoneMasterContainer.Left = Integer.valueOf(remoteKanban.leankor__Left__c);
                    noZoneMasterContainer.Width = Integer.valueOf(remoteKanban.leankor__Width__c);
                    noZoneMasterContainer.Height = Integer.valueOf(remoteKanban.leankor__Height__c);
                    noZoneMasterContainer.X = Integer.valueOf(remoteKanban.leankor__x__c);
                    noZoneMasterContainer.Y = Integer.valueOf(remoteKanban.leankor__Y__c);
                    //noZoneMasterContainer.JSONData = remoteKanban.leankor__JSONData__c;
                    //noZoneMasterContainer.JSONDefinition = remoteKanban.leankor__JSONDefinition__c;
                    noZoneMasterContainer.State = remoteKanban.leankor__State__c;
                    noZoneMasterContainer.ZoneID = (remoteKanban.leankor__ZoneGUID__c == null ? '' : remoteKanban.leankor__ZoneGUID__c);
                    noZoneMasterContainer.TemplateID = (remoteKanban.leankor__KanbanCardTemplate__c == null ? '' : remoteKanban.leankor__KanbanCardTemplate__c);
                    noZoneMasterContainer.TemplateName = remoteKanban.leankor__KanbanCardTemplate__r.Name == null ? '' : remoteKanban.leankor__KanbanCardTemplate__r.Name;
                    noZoneMasterContainer.Color = remoteKanban.leankor__KanbanCardTemplate__r.leankor__Color__c;
                    noZoneMasterContainer.Priority = Integer.valueOf(remoteKanban.leankor__Priority__c);
                    noZoneMasterContainer.HarveyBall = String.valueOf(remoteKanban.leankor__PercentComplete2__c);
                    noZoneMasterContainer.DateColor = remoteKanban.leankor__DateColor__c;
                    noZoneMasterContainer.Description = remoteKanban.leankor__DescriptionLong__c;
                    noZoneMasterContainer.AcceptanceCriteria = (remoteKanban.leankor__AcceptanceCriteria__c == null ? '' : remoteKanban.leankor__AcceptanceCriteria__c);
                    noZoneMasterContainer.ValueStreamCardLink= (remoteKanban.leankor__ValueStreamCardLink__c == null ? '' : remoteKanban.leankor__ValueStreamCardLink__c);
                    noZoneMasterContainer.ValueStreamLinkID=(remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__c);
                    noZoneMasterContainer.ParentProjectRoomID = (remoteKanban.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                    noZoneMasterContainer.ValueStreamCardLinkName = (remoteKanban.leankor__ValueStreamCardLink__c == null ? '' : remoteKanban.leankor__ValueStreamCardLink__r.Name); 
                    noZoneMasterContainer.ValueStreamLinkIDName = (remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.Name);
                    noZoneMasterContainer.ValueStreamLinkBoardType = (remoteKanban.leankor__ValueStreamLink__c == null ? '' : remoteKanban.leankor__ValueStreamLink__r.leankor__BoardType__c);
                    noZoneMasterContainer.Account = (remoteKanban.leankor__Account__r.Id == null ? '' : remoteKanban.leankor__Account__r.Id);
                    noZoneMasterContainer.Contact = (remoteKanban.leankor__Contact__r.Id == null ? '' : remoteKanban.leankor__Contact__r.Id);
                    noZoneMasterContainer.CaseID = (remoteKanban.leankor__Case__r.Id == null ? '' : remoteKanban.leankor__Case__r.Id);
                    noZoneMasterContainer.ValueStreamID = remoteKanban.leankor__ValueStream__c;
                    noZoneMasterContainer.CmpID = remoteKanban.leankor__CmpID__c;
                    noZoneMasterContainer.GUID = remoteKanban.leankor__GUID__c;
                    noZoneMasterContainer.OwnerID = remoteKanban.OwnerID;
                    noZoneMasterContainer.Opportunity = (remoteKanban.leankor__Opportunity__c == null ? '' : remoteKanban.leankor__Opportunity__c);
                    noZoneMasterContainer.OpportunityName= (remoteKanban.leankor__Opportunity__c == null ? '' : remoteKanban.leankor__Opportunity__r.Name);
                    noZoneMasterContainer.AccountName = (remoteKanban.leankor__Account__r.Name == null ? '' : remoteKanban.leankor__Account__r.Name);
                    noZoneMasterContainer.ContactName = (remoteKanban.leankor__Contact__r.Name == null ? '' : remoteKanban.leankor__Contact__r.Name);
                    noZoneMasterContainer.CaseSubject= (remoteKanban.leankor__Case__c == null ? '' : (remoteKanban.leankor__Case__r.Subject == null ? 'Case : ' + remoteKanban.leankor__Case__r.CaseNumber : remoteKanban.leankor__Case__r.Subject));                
                    noZoneMasterContainer.CaseStatus = (remoteKanban.leankor__Case__r.Status == null ? '' : remoteKanban.leankor__Case__r.Status);  
                    noZoneMasterContainer.CasePriority = (remoteKanban.leankor__Case__r.Priority == null ? '' : remoteKanban.leankor__Case__r.Priority); 
                    noZoneMasterContainer.CaseTrigger = false;
                    noZoneMasterContainer.ZoneTitle = '';
                    noZoneMasterContainer.LeavedZoneTitle = '';
                    noZoneMasterContainer.Base64Drawing = '';
                    noZoneMasterContainer.Base64FileType = ''; 
                    noZoneMasterContainer.KanbanUrl = '';
                    noZoneMasterContainer.ItemType = remoteKanban.RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC' ;                            
                    noZoneMasterContainer.Order = tempOrder;
                    noZoneMasterContainer.OnBudget = remoteKanban.leankor__OnBudget__c;
                    noZoneMasterContainer.OnQuality = remoteKanban.leankor__OnQuality__c;
                    noZoneMasterContainer.OnTime = remoteKanban.leankor__OnTime__c;
                    noZoneMasterContainer.OwnerName = remoteKanban.Owner.Name;                            
                    noZoneMasterContainer.IsSuccessorRecalculate = remoteKanban.leankor__IsSuccessorRecalculate__c;
                    noZoneMasterContainer.UrlLink = remoteKanban.leankor__UrlLink__c;
                    noZoneMasterContainer.isAtRisk =remoteKanban.leankor__IsAtRisk__c;
                    noZoneMasterContainer.isOnHold =remoteKanban.leankor__IsOnHold__c;
                    //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
                    if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    	noZoneMasterContainer.isConstraintRecalculate = remoteKanban.leankor__IsConstraintRecalculate__c;
                    }
                    //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for getting constraint data on load of board.
                    if (remoteKanban.leankor__ScheduleModes__r != null && remoteKanban.leankor__ScheduleModes__r.size() > 0) {
                        noZoneMasterContainer.SchedulingModeId = remoteKanban.leankor__ScheduleModes__r[0].Id;
                        noZoneMasterContainer.ManuallyScheduled = remoteKanban.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                        noZoneMasterContainer.Effort = remoteKanban.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                        noZoneMasterContainer.EffortUnit = remoteKanban.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                        noZoneMasterContainer.SchedulingMode = remoteKanban.leankor__ScheduleModes__r[0].leankor__Mode__c;
                        //Changes : Check constraint setting enable or not.
                        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                            noZoneMasterContainer.ConstraintDate = remoteKanban.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
                            noZoneMasterContainer.ConstraintType = remoteKanban.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                        }
                       // noZoneMasterContainer.ReadOnly = remoteKanban.leankor__ScheduleModes__r[0].leankor__ReadOnly__c;
                    }
                    
                    if (remoteKanban.leankor__Kanban_Card_Baselines__r.size() >0 ) {
                        noZoneMasterContainer.BaselineStartDate = remoteKanban.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
                        noZoneMasterContainer.BaselineEndDate = remoteKanban.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c; 
                    }

                     //Pratiksha : 12/Oct/2023 : Passing these week day onLoad on CV of WhiteBoard/DashBoard.
                    noZoneMasterContainer.Monday = remoteKanban.leankor__Monday__c;
                    noZoneMasterContainer.Tuesday = remoteKanban.leankor__Tuesday__c;
                    noZoneMasterContainer.Wednesday = remoteKanban.leankor__Wednesday__c;
                    noZoneMasterContainer.Thursday = remoteKanban.leankor__Thursday__c;
                    noZoneMasterContainer.Friday = remoteKanban.leankor__Friday__c;
                    noZoneMasterContainer.Saturday = remoteKanban.leankor__Saturday__c;
                    noZoneMasterContainer.Sunday = remoteKanban.leankor__Sunday__c;
                    noZoneMasterContainer.weekCalendar = remoteKanban.leankor__WeekCalendar__c;

                    noZoneKanbanCardList.add(noZoneMasterContainer);
                    
                    if (remoteKanban.OwnerId != null) {
                        resoruceList.add(remoteKanban.OwnerId);
                    }

                    if (taskMap.get(remoteKanban.Id) != null && taskMap.ContainsKey(remoteKanban.Id)) {                                
                        //List<MasterContainer> KCTaskList = new List<MasterContainer>();
                        List<Task> tempTaskList = taskMap.get(remoteKanban.Id);

                        if (tempTaskList.Size() > 0) {
                            if (remoteKanban.leankor__ValueStream__r.leankor__DisableTaskAsMiniature__c == true) {
                                    MasterContainer masterContainerTask = new MasterContainer();

                                    masterContainerTask.Name = 'Tasks for ' + noZoneMasterContainer.Name;
                                    masterContainerTask.Id= noZoneMasterContainer.Id + '-T';
                                    masterContainerTask.ValueStreamID = valueStreamId;
                                    masterContainerTask.Leaf = false;
                                    masterContainerTask.Title = 'Tasks for ' + noZoneMasterContainer.Name;
                                    masterContainerTask.expanded = true;
                                    masterContainerTask.ItemType = 'Ghost';
                                    masterContainerTask.Color = '#CCCCCC';
                                    masterContainerTask.Order = (noZoneMasterContainer.Order + 0.3);                                                                 
                                    masterContainerTask.StartDate = noZoneMasterContainer.StartDate;
                                    masterContainerTask.DueDate = noZoneMasterContainer.DueDate;
                                    masterContainerTask.children = getAllTask(tempTaskList);
                                    
                                    noZoneKanbanCardList.add(masterContainerTask);
                            }else{
                                allTaskList.addAll(getAllTask(tempTaskList));
                            }
                        
                        }
                    }

                    tempOrder++;
                    
                    if (flag==1) {
                        //Pratiksha  11/08/2021 : Changes for bug fixes of internationlization on WB & DB.
                        //noZone.Name = 'No Zone';
                        noZone.Name = System.Label.leankor.NoZone;
                        noZone.Id = 'RandomId' + noZoneIdCount;
                        noZone.ValueStreamID = valueStreamId;
                        noZone.leaf = false;
                        noZone.Title = 'No Zone';
                        noZone.expanded = true;
                        noZone.ItemType= 'NOZONE';
                        noZone.Color = '#CCCCCC';
                        flag++;
                    }
                }
            }
            if (flag != 0) {
                if (minSDCard_c<minSDZone) minSDZone = minSDCard_c;
                if (minEDCard_c>minEDZone) minEDZone = minEDCard_c;

                noZone.children = noZoneKanbanCardList;						
                noZone.StartDate = String.valueOf(json.deserialize(JSON.Serialize(minSDCard_c), String.class));
                noZone.DueDate = String.valueOf(json.deserialize(JSON.Serialize(minEDCard_c), String.class));
                masterContainerList.add(noZone);   
            }                        
        }
        
        if (remoteZones.size() == 0 && remoteKanbansSize == 0) {
            MasterContainer noZone = new MasterContainer();

            //Pratiksha  11/08/2021 : Changes for bug fixes of internationlization on WB & DB.
            //noZone.Name = 'No Zone';
            noZone.Name = System.Label.leankor.NoZone;
            noZone.Id = 'RandomId' + noZoneIdCount;
            noZone.ValueStreamID = valueStreamId;
            noZone.leaf = false;
            noZone.Title = 'No Zone';
            noZone.expanded = true;
            noZone.ItemType = 'NOZONE';
            noZone.Color = '#CCCCCC';
            noZone.children = new List<MasterContainer>();

            masterContainerList.add(noZone);
        }

        // Changes : RK : 17/11/2020 - Clearing list to decreese heap size. 
        remoteZones.clear();
        remoteKanbans.clear();
        //kanbancards.clear();
        Boolean currentRecords = true;
        List<User> userList = [Select Id,
                                        Name,
                                        SmallPhotoURL 
                                    From User 
                                    Where Id In :resoruceList 
                                    Limit 50000];

        Id userId = UserInfo.getUserId();

        for (User userdata : userList) {
            if (userdata.Id == userId) {
                currentRecords = false;
                break;
            }
        }

        if (currentRecords) {
            user addUserList = [Select Id,
                                        Name,
                                        SmallPhotoURL 
                                    From User 
                                    Where Id = :userId];

            userList.add(addUserList);
        }

        for (User user : userList) {
            CardResource tempResource = new CardResource(user.Id, user.Name, user.SmallPhotoUrl);
            cardResources.add(tempResource);
        }

        resoruceList.clear();


        //Pratiksha : 25/01/2022 : Changes for adding the parent node in CV for Constraint.
        CalenderResourceScheduler schedulerRecord;
            GanttTaskBoard.ValueStreamPlanning valueStreamPlanning = new GanttTaskBoard.ValueStreamPlanning();
            valueStreamPlanning.Name = valueStreams[0].Name;
         //Pratiksha : 11/06/2022 : Changes to add the StartDate and DueDate in ValueStream in both case costraint enable and disable.
            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            valueStreamPlanning.StartDate = (String)JSON.Deserialize(JSON.Serialize(valueStreams[0].leankor__ProjectBoardStartDateTime__c), String.class);
            valueStreamPlanning.DueDate = (String)JSON.Deserialize(JSON.Serialize(valueStreams[0].leankor__ProjectBoardEndDateTime__c), String.class);
            }else{
                valueStreamPlanning.StartDate = (String)JSON.Deserialize(JSON.Serialize(minTempDate), String.class);
                valueStreamPlanning.DueDate = (String)JSON.Deserialize(JSON.Serialize(maxTempDate), String.class);
            }    
            valueStreamPlanning.ItemType = 'Board';
            valueStreamPlanning.ScheduleBackwards = valueStreams[0].leankor__ScheduleBackward__c;
            valueStreamPlanning.Id = valueStreams[0].Id;
            valueStreamPlanning.children = masterContainerList;

            schedulerRecord = new CalenderResourceScheduler(cardResources, valueStreamPlanning, allTaskList); 
             //24/06/2022 Changes for projectLaunch date with time should be show  in CV.
            schedulerRecord.projectBoardLaunchDate =  valueStreams[0].leankor__ProjectBoardLaunchDateTime__c != null ? JSON.serialize(valueStreams[0].leankor__ProjectBoardLaunchDateTime__c) : '';
            //schedulerRecord.projectBoardLaunchDate =  valueStreams[0].leankor__ProjectBoardLaunchDateTime__c != null ? JSON.serialize(valueStreams[0].leankor__ProjectBoardLaunchDateTime__c.date()+'') : '';
            schedulerRecord.lastSetBaselineId = lastSetBaseline.size() > 0 ? (String)lastSetBaseline[0].Id : '';
        return schedulerRecord;                                 
    }
    
    // getting task
    public static List<MasterContainer> getAllTask(List<Task> tempTaskList){	
	 
	 List<MasterContainer> KCTaskList = new List<MasterContainer>();	 
	 for(Task t : tempTaskList){	 
			MasterContainer KCTask = new MasterContainer();
			KCTask.Id = t.Id;
			
			Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
			Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);                                                 
			
			KCTask.StartDate = String.valueOfGmt(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
			KCTask.DueDate = String.valueOfGmt(Datetime.newInstanceGmt(tempActivityDate.year(),tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
			KCTask.EstimatedDuration = 1;
			KCTask.DurationUnits = 'd';
			KCTask.OwnerID = t.OwnerID;
			KCTask.OwnerName = t.Owner.Name;                                                  
			KCTask.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
			KCTask.Subject = t.Subject;
			KCTask.Name = t.Subject;
			KCTask.Status =  t.Status;
			KCTask.PercentDone = (t.Status == 'Completed' ? 100 : 0);
			KCTask.Description = t.Description;
			KCTask.CreatedDate = String.valueOfGmt(t.CreatedDate);
			KCTask.WhatId = t.WhatId;
			KCTask.ItemType='Task';
			KCTask.expanded = false;
			KCTask.leaf = true;
			if(t.OwnerId != null)
			{
				resoruceList.add(t.OwnerId);
			}
			KCTaskList.add(KCTask);		
		}
		
		return KCTaskList;
	}

	
	//***** SS 20.06.2018 *****//
	public static List<String> UserStandard;
    public static List<String> UserNonStandard;
    public static boolean IscurrentUserPartner = false;
    public static Date beginDateForSearchCardsAndTask;
    public static Date endDateForSearchCardsAndTask;
    public static MasterContainer filterData;
    public static List<leankor__KanbanCard__c> AddVSCard;
	
	
	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	List Of all KanbanCard and task Sorted by OwnerIDs
    Inputs: 		List of Resource Ids, and Json string
	Returns: 		ResourceScheduler object which contains list of 
					Cards, Task filtered by Resource
	------------------------------------------------------------*/
	@RemoteAction
    Global Static ResourceScheduler getKanbanCardsByResource(List<String> ResourceIDs,String ValueStreamID){
        if(ResourceIDs.size()>0){
            for(String resourceId : resourceIDs){
                if (String.isNotBlank(resourceId) && Util.getSObjectName(resourceId) != 'User') {
                    System.debug('Error: Invalid input');
                    throw new Util.LeanException('Error: Invalid input');
                }
            }
        }
    
        filterData = (MasterContainer)JSON.deserialize(ValueStreamID,MasterContainer.class);
        beginDateForSearchCardsAndTask = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.StartDate), DateTime.class));
        endDateForSearchCardsAndTask = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.DueDate), DateTime.class));
        Integer returnCardListSize=0;
        /*
        *Modified By :Ashutosh Gour
        *Modification : Modification for making SOQL selective and remove negative selection.
        */
        //List<User> PartnerUser =[SELECT Id FROM User WHERE Usertype != 'Standard' AND ID IN :ResourceIDs];
        List<User> PartnerUser = new List<User>();
        for(User partner: [SELECT Id,Usertype FROM User WHERE ID IN :ResourceIDs]){
            if(partner.Usertype != 'Standard'){
                PartnerUser.add(partner);
            }
        }
        List<User> AdminUser = [SELECT Id FROM User WHERE Usertype = 'Standard' AND ID IN :ResourceIDs limit 49999];
        if(Userinfo.getUserType()!='Standard')
        {
            UserNonStandard = new List<String> ();
            UserStandard = new List<String> ();
            IscurrentUserPartner = true;
            
            /*
            *Modified By :Ashutosh Gour
            *Modification : Modification for making SOQL selective and remove negative selection.
            */
            //UserNonStandard = [SELECT Id,Usertype FROM User WHERE ID IN :ResourceIDs AND Usertype != 'Standard' LIMIT 49999]; 
            for(User pUser : [SELECT Id,Usertype FROM User WHERE Id IN :ResourceIDs LIMIT 49999]){
                if(pUser.Usertype != 'Standard'){
                    UserNonStandard.add(PUser.ID);
                }
            }
            for(User Usercheck :AdminUser){
                    UserStandard.add(Usercheck.ID);
            }   
        }
        if(IscurrentUserPartner){
            ResourceIDs.clear();
            IF(UserNonStandard != null && UserNonStandard.size() > 0){
                ResourceIDs.addall(UserNonStandard);
            }
        }
        
        List<MasterContainer> ReturnList = New List<MasterContainer>();
        List<MasterContainer> returnedCards = getAssociatedCardsOfResources(ResourceIds);
        if(returnedCards != null)
        {
            ReturnList.addAll(returnedCards);
        }
        
        List<MasterContainer> taskLogList=  new List<MasterContainer>();
        List<MasterContainer> returnedTasks = getAssociatedTaskOfResources(ResourceIds, AddVSCard);
        if(returnedTasks != null)
        {
        taskLogList.addAll(returnedTasks);
        }
        
        if(IscurrentUserPartner){
            ResourceIDs.addall(UserStandard);
        }
        Set<CardResource> cardResources = new Set<CardResource>();
        if(filterData.lastCardId =='' || filterData.lastTaskId == '')
        {
	        List<User> UserList = [SELECT Id,Name,SmallPhotoURL FROM User WHERE Id IN :ResourceIDs LIMIT 49999];
	        for(User u : UserList){
	            CardResource tempResource = new CardResource(u.Id,u.Name,u.SmallPhotoUrl);
	            cardResources.add(tempResource);
	        }
        }
        return (new ResourceScheduler(ReturnList,taskLogList,cardResources));
    }
    
    
    /*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	List Of all KanbanCard Filtered by ResourceIds
    Inputs: 		List of Resource Ids
	Returns: 		List<MasterContainer>
	------------------------------------------------------------*/
    private static List<MasterContainer> getAssociatedCardsOfResources(List<String> ResourceIds){
        if(filterData.lastCardId==null) {
        return new List<MasterContainer>();
        }
        String lastCardId=filterData.lastCardId;
        // yj 13.01.2017 we added filter leankor__MasterContainer__r.leankor__Type__c != 'Template' in kanban cards query for prevent cards on RS in calender View of kanban board
        //List<leankor__KanbanCard__c> AddVSCard = new List<leankor__KanbanCard__c>();
        AddVSCard = new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> CardsList = new List<leankor__KanbanCard__c>();
        if(String.isBlank(lastCardId))
        {
        /*
        *Modified By :Ashutosh Gour
        *Modification : Modification for making SOQL selective and remove negative selection.
        */
        /*
         CardsList =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
                                                leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
                                                Where leankor__ValueStream__C != Null AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                                                and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                AND OwnerID IN : ResourceIDs AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                                                AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask and leankor__StartDate__c <=: endDateForSearchCardsAndTask) OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask and leankor__DueDate__c >= : beginDateForSearchCardsAndTask) OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) ORDER BY Id, CreatedDate ASC   limit 9999];
        */
        for (leankor__KanbanCard__c card : [SELECT 
                                                Id,
                                                OwnerID,
                                                leankor__valueStream__r.leankor__BoardType__c,
                                                leankor__DueDateTime__C,
                                                leankor__ValueStream__c,
                                                Name,
                                                leankor__EstimatedDuration__c,
                                                leankor__DurationUnits__c,
                                                leankor__StartDateTime__c,
                                                leankor__ValueStream__r.leankor__ProjectRoom__c ,
                                                leankor__MasterContainer__r.leankor__Type__c
                                            FROM leankor__KanbanCard__c 
                                            WHERE RecordType.Name = 'ActivityCard' 
                                                AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                AND OwnerID IN: ResourceIDs 
                                                AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog', 'Archive', 'Regular')
                                                AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask 
                                                    AND leankor__StartDate__c <=: endDateForSearchCardsAndTask) 
                                                OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask 
                                                    AND leankor__DueDate__c >= : beginDateForSearchCardsAndTask) 
                                                OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask 
                                                    AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) 
                                            ORDER BY Id, CreatedDate ASC   
                                            LIMIT 9999]) {
            if(card.leankor__ValueStream__C != null && card.leankor__Valuestream__r.leankor__projectroom__c != null){
                CardsList.add(card);
            }
        }                                        
                                                
        
        if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
            
            
            /*AddVSCard =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
                        leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
                        Where leankor__ValueStream__C = :filterData.ValueStreamID AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                        and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                        AND OwnerID IN : UserStandard AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                        AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask and leankor__StartDate__c <=: endDateForSearchCardsAndTask) OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask and leankor__DueDate__c >= : beginDateForSearchCardsAndTask) OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) ORDER BY Id, CreatedDate ASC   limit 9999];
            */
            for(leankor__KanbanCard__c VSCard :[SELECT 
                                                    Id,
                                                    OwnerID,
                                                    leankor__valueStream__r.leankor__BoardType__c,
                                                    leankor__DueDateTime__C,
                                                    leankor__ValueStream__c,
                                                    Name,
                                                    leankor__EstimatedDuration__c,
                                                    leankor__DurationUnits__c,
                                                    leankor__StartDateTime__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                    leankor__MasterContainer__r.leankor__Type__c
                                                FROM leankor__KanbanCard__c 
                                                WHERE leankor__ValueStream__C = :filterData.ValueStreamID 
                                                    AND RecordType.Name = 'ActivityCard' 
                                                    AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                    AND OwnerID IN : UserStandard 
                                                    AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                                                    AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask 
                                                            AND leankor__StartDate__c <=: endDateForSearchCardsAndTask) 
                                                        OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask 
                                                            AND leankor__DueDate__c >= : beginDateForSearchCardsAndTask) 
                                                        OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask 
                                                            AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) 
                                                ORDER BY Id, CreatedDate ASC   
                                                LIMIT 9999]){
                if (VSCard.leankor__Valuestream__r.leankor__projectroom__c != null ) {
                    AddVSCard.add(VSCard);
                }
            }            
            CardsList.addall(AddVSCard); 
        }
        }
        else{
          
          /*  CardsList =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
                                                leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
                                                Where leankor__ValueStream__C != Null AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                                                and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                AND OwnerID IN : ResourceIDs AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                                                AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask and leankor__StartDate__c <=: endDateForSearchCardsAndTask) OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask and leankor__DueDate__c >= : beginDateForSearchCardsAndTask) OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) AND id >: lastCardId ORDER BY Id, CreatedDate ASC   limit 9999];
            */
            for (leankor__KanbanCard__c card : [SELECT 
                                                Id,
                                                OwnerID,
                                                leankor__valueStream__r.leankor__BoardType__c,
                                                leankor__DueDateTime__C,
                                                leankor__ValueStream__c,
                                                Name,
                                                leankor__EstimatedDuration__c,
                                                leankor__DurationUnits__c,
                                                leankor__StartDateTime__c,
                                                leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                leankor__MasterContainer__r.leankor__Type__c
                                            FROM leankor__KanbanCard__c 
                                            WHERE RecordType.Name = 'ActivityCard' 
                                                AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                AND OwnerID IN : ResourceIDs 
                                                AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                                                AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask 
                                                        AND leankor__StartDate__c <=: endDateForSearchCardsAndTask) 
                                                    OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask 
                                                        AND leankor__DueDate__c >= : beginDateForSearchCardsAndTask) 
                                                    OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask 
                                                        AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) 
                                                AND id >: lastCardId 
                                            ORDER BY Id, CreatedDate ASC
                                            LIMIT 9999]) {
                if(card.leankor__ValueStream__C != null && card.leankor__Valuestream__r.leankor__projectroom__c != null){
                    CardsList.add(card);
                }
                                                
            }                                    
        
            if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
              
               /* AddVSCard =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
                            leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
                            Where leankor__ValueStream__C = :filterData.ValueStreamID AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                            and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                            AND OwnerID IN : UserStandard AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                            AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask and leankor__StartDate__c <=: endDateForSearchCardsAndTask) OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask and leankor__DueDate__c >= : beginDateForSearchCardsAndTask) OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) AND id >: lastCardId ORDER BY Id, CreatedDate ASC   limit 9999];
                */
                for(leankor__KanbanCard__c VSCard : [SELECT
                                                        Id,
                                                        OwnerID,
                                                        leankor__valueStream__r.leankor__BoardType__c,
                                                        leankor__DueDateTime__C,
                                                        leankor__ValueStream__c,
                                                        Name,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__DurationUnits__c,
                                                        leankor__StartDateTime__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                        leankor__MasterContainer__r.leankor__Type__c
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__ValueStream__C = :filterData.ValueStreamID 
                                                        AND RecordType.Name = 'ActivityCard' 
                                                        AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
                                                        AND OwnerID IN : UserStandard 
                                                        AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                                                        AND ((leankor__StartDate__c >= : beginDateForSearchCardsAndTask 
                                                                AND leankor__StartDate__c <=: endDateForSearchCardsAndTask) 
                                                            OR (leankor__DueDate__c <= : endDateForSearchCardsAndTask 
                                                                AND leankor__DueDate__c >= : beginDateForSearchCardsAndTask) 
                                                            OR(leankor__StartDate__c <= : beginDateForSearchCardsAndTask 
                                                                AND leankor__DueDate__c >= : endDateForSearchCardsAndTask)) 
                                                        AND id >: lastCardId 
                                                    ORDER BY Id, CreatedDate ASC   
                                                    LIMIT 9999]){
                    if (VSCard.leankor__Valuestream__r.leankor__projectroom__c != null ) {
                            AddVSCard.add(VSCard);
                    }

                }            
                CardsList.addall(AddVSCard); 
       
            }
        }
        List<MasterContainer> ReturnList = New List<MasterContainer>();
        Map<String,leankor__KanbanCard__c> MapOfKanbanCard = new Map<String,leankor__KanbanCard__c>();               
        for(leankor__KanbanCard__c KnbnCard : CardsList)
        {       
                MapOfKanbanCard.Put(KnbnCard.ID,KnbnCard); 
                MasterContainer card = New MasterContainer ();
                Card.ID = KnbnCard.ID ;
                card.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                card.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__C);
                card.ResourceId = KnbnCard.OwnerID ;
                card.Name = KnbnCard.Name;                       
                Card.ValueStreamID = KnbnCard.leankor__ValueStream__c;
                Card.ProjectRoomID = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
                card.EstimatedDuration=KnbnCard.leankor__EstimatedDuration__c;
                if(KnbnCard.leankor__DurationUnits__c=='Days') card.DurationUnits='d';
                else if(KnbnCard.leankor__DurationUnits__c=='Weeks') card.DurationUnits='w';
                else if(KnbnCard.leankor__DurationUnits__c=='Hours') card.DurationUnits='h';
                else if(KnbnCard.leankor__DurationUnits__c=='Months') card.DurationUnits='mo';
                else if(KnbnCard.leankor__DurationUnits__c=='Years') card.DurationUnits='y';
                else if(KnbnCard.leankor__DurationUnits__c=='Minutes') card.DurationUnits='mi';
                card.leaf=true;
                  card.ItemType='KC';
                  card.BoardType =(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :KnbnCard.leankor__valueStream__r.leankor__BoardType__c));              
            ReturnList.Add(card);
        }
        return ReturnList;
    }
    
    
    /*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	List Of all Task associated with active KanbanCards Filtered by ResourceIds
    Inputs: 		List of Resource Ids, and KanbanCard records of Partner User
	Returns: 		List<MasterContainer>
	------------------------------------------------------------*/
    private static List<MasterContainer> getAssociatedTaskOfResources(List<String> ResourceIds, List<leankor__KanbanCard__c> AddVSCard){
        if(filterData.lastTaskId==null) {
        return new List<MasterContainer>();
        }
        String lastTaskId=filterData.lastTaskId;
        List<Task> TaskList = new List<Task>();
        List<MasterContainer> ReturnList= new List<MasterContainer>();
        List<leankor__KanbanCard__c > cardsList = new List<leankor__KanbanCard__c >();
        if(!String.isBlank(lastTaskId))
        {
        try{
            //SS 19.03.2018
            //Modified query for retriving task records including archived records                       
            /*
            *Modified By :Ashutosh Gour
            *Modification : Modification for making SOQL selective and remove negative selection.
            */
            /*TaskList =[select Id,Priority,OwnerID,Subject,
                      Status,ActivityDate,WhatID,
                      Description,Owner.Name,LastModifiedDate from Task  
                      where (OwnerId IN :ResourceIDs And What.type = 'leankor__KanbanCard__c'
                      AND  ActivityDate >= : beginDateForSearchCardsAndTask and ActivityDate <=: endDateForSearchCardsAndTask AND IsDeleted = false) 
                      AND WhatId in 
                          (   
                          	  Select ID 
                              from leankor__KanbanCard__c where leankor__Valuestream__c != NULL 
                              and leankor__Valuestream__r.leankor__ProjectRoom__C != NULL 
                              AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
                              AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                              AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                          ) 
                      AND id >: lastTaskId ORDER BY Id, CreatedDate ASC  
                      limit 9999 All Rows];*/
            List<Id> kcList = new List<Id>();
            for(leankor__KanbanCard__c kc : [SELECT 
                                                Id,
                                                leankor__Valuestream__c,
                                                leankor__Valuestream__r.leankor__ProjectRoom__C
                                            FROM leankor__KanbanCard__c 
                                            WHERE leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                AND leankor__valuestream__r.leankor__boardtype__c IN('Kanban Board','Card Hierarchy','Plan Board','DashBoard','UberBoard') 
                                                AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                           ]){
                if(kc.leankor__Valuestream__c != null && kc.leankor__Valuestream__r.leankor__ProjectRoom__C != null ){
                    kcList.add(kc.Id);
                }
            }
            TaskList =[SELECT
                            Id,
                            Priority,
                            OwnerID,
                            Subject,
                            Status,
                            ActivityDate,
                            WhatID,
                            Description,
                            Owner.Name,
                            LastModifiedDate 
                        FROM Task  
                        WHERE (OwnerId IN :ResourceIDs 
                            AND What.type = 'leankor__KanbanCard__c'
                            AND  ActivityDate >= : beginDateForSearchCardsAndTask 
                            AND ActivityDate <=: endDateForSearchCardsAndTask AND IsDeleted = false) 
                        AND WhatId IN :kcList                         
                        AND id >: lastTaskId 
                        ORDER BY Id, CreatedDate ASC  
                        LIMIT 9999 All Rows];
            if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                List<Task> Taskpartner =[SELECT 
                                            Id,
                                            Priority,
                                            OwnerID,
                                            Subject,
                                            Status,
                                            ActivityDate,
                                            WhatID,
                                            Description,
                                            Owner.Name,                                        
                                            LastModifiedDate 
                                        FROM Task  
                                        WHERE (OwnerId IN :UserStandard 
                                            AND What.type = 'leankor__KanbanCard__c' 
                                            AND WhatID IN :AddVSCard 
                                            AND IsDeleted = false)
                                            AND id >: lastTaskId ORDER BY Id, CreatedDate ASC  
                                        LIMIT 9999 All Rows];
                                        
                TaskList.addall(Taskpartner);
            }
            
        }catch(Exception ex){
            System.debug(ex.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        
        List<String> tempCardID = New List<String>();
        for(task LogTask :TaskList){
            tempCardID.add(LogTask.WhatID);
        }

        if(tempCardID.size()>0)
        {
            /*
            *Modified By :Ashutosh Gour
            *Modification : Modification for making SOQL selective and remove negative selection.
            */
         /*    CardsList = [Select ID ,leankor__ValueStream__c
                          from leankor__KanbanCard__c Where Id IN: tempCardID and leankor__Valuestream__c != NULL 
                          and leankor__Valuestream__r.leankor__ProjectRoom__C != NULL 
                          AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
                          AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                          AND leankor__MasterContainer__r.leankor__Type__c != 'Template' ORDER BY Id, CreatedDate ASC   limit 49999];*/
            for(leankor__KanbanCard__c cards : [SELECT 
                                                Id,
                                                leankor__Valuestream__c,
                                                leankor__Valuestream__r.leankor__ProjectRoom__C
                                            FROM leankor__KanbanCard__c 
                                            WHERE leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                AND leankor__valuestream__r.leankor__boardtype__c IN('Kanban Board','Whiteboard','Card Hierarchy','Plan Board','DashBoard','UberBoard') 
                                                AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                                            ORDER BY Id, CreatedDate ASC  
                                            LIMIT 49999]){
                    if(cards.leankor__Valuestream__c != null && cards.leankor__Valuestream__r.leankor__ProjectRoom__C != null ){
                        CardsList.add(cards);
                    }
                }
        }
        if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
            TaskList.clear();
            //SS 19.03.2018
            //Modified query for retriving task records including archived records
            TaskList =[SELECT 
                            Id,
                            Priority,
                            OwnerID,
                            Subject,
                            Status,
                            ActivityDate,
                            WhatID,
                            Description,
                            Owner.Name,
                            LastModifiedDate
                      FROM Task  
                      WHERE (OwnerId IN :ResourceIDs 
                        AND WhatID IN :CardsList 
                        AND What.type = 'leankor__KanbanCard__c'
                        AND ActivityDate >= : beginDateForSearchCardsAndTask 
                        AND ActivityDate <=: endDateForSearchCardsAndTask 
                        AND IsDeleted = false)
                        AND id >: lastTaskId 
                    ORDER BY Id, CreatedDate ASC  
                    LIMIT 9999 All Rows];          
            List<leankor__Kanbancard__c> VScards = [SELECT 
                                                        Id 
                                                    FROM leankor__Kanbancard__c 
                                                    WHERE leankor__valuestream__c =:filterData.ValueStreamID 
                                                AND leankor__Valuestream__r.leankor__Istemplateboard__c = false 
                                                        AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                                                    ORDER BY Id, CreatedDate ASC   
                                                    LIMIT 9999];
            //SS 19.03.2018
            //Modified query for retriving task records including archived records
            List<Task> Taskstandard =[SELECT 
                                            Id,
                                            Priority,
                                            OwnerID,
                                            Subject,
                                            Status,
                                            ActivityDate,
                                            WhatID,
                                            Description,
                                            Owner.Name,
                                            LastModifiedDate 
                                        FROM Task  
                                        WHERE (OwnerId IN :UserStandard 
                                            AND What.type = 'leankor__KanbanCard__c' 
                                            AND WhatID IN :VScards
                                            AND IsDeleted = false) 
                                            AND id >: lastTaskId 
                                        ORDER BY Id, CreatedDate ASC  
                                        LIMIT 9999 All Rows];
            
            TaskList.addall(Taskstandard);           
         }
        }
        else{
            try{
                //SS 19.03.2018
                //Modified query for retriving task records including archived records                       
                /*
                *Modified By :Ashutosh Gour
                *Modification : Modification for making SOQL selective and remove negative selection.
                */                 
                /*TaskList =[select Id,Priority,OwnerID,Subject,
                          Status,ActivityDate,WhatID,
                          Description,Owner.Name,LastModifiedDate from Task  
                          where (OwnerId IN :ResourceIDs And What.type = 'leankor__KanbanCard__c'
                          AND  ActivityDate >= : beginDateForSearchCardsAndTask and ActivityDate <=: endDateForSearchCardsAndTask AND IsDeleted = false) 
                          AND WhatId in 
                          (   
                          	  Select ID 
                              from leankor__KanbanCard__c Where leankor__Valuestream__c != NULL 
                              and leankor__Valuestream__r.leankor__ProjectRoom__C != NULL 
                              AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
                              AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                              AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                          )
                          ORDER BY Id,CreatedDate limit 9999 All Rows];*/
                List<Id> kcList = new List<Id>();
                for(leankor__KanbanCard__c kc : [SELECT 
                                                    Id,
                                                    leankor__Valuestream__c,
                                                    leankor__Valuestream__r.leankor__ProjectRoom__C
                                                FROM leankor__KanbanCard__c 
                                                WHERE leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                    AND leankor__valuestream__r.leankor__boardtype__c IN(   'Kanban Board','Whiteboard','Card Hierarchy','Plan Board','DashBoard','UberBoard') 
                                                    AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular')
                            ]){
                    if(kc.leankor__Valuestream__c != null && kc.leankor__Valuestream__r.leankor__ProjectRoom__C != null ){
                        kcList.add(kc.Id);
                    }
                }
                TaskList = [SELECT 
                                    Id,
                                    Priority,
                                    OwnerID,
                                    Subject,
                                    Status,
                                    ActivityDate,
                                    WhatID,
                                    Description,
                                    Owner.Name,
                                    LastModifiedDate 
                                FROM Task  
                                WHERE (OwnerId IN :ResourceIDs 
                                    AND What.type = 'leankor__KanbanCard__c'
                                    AND  ActivityDate >= : beginDateForSearchCardsAndTask 
                                    AND ActivityDate <=: endDateForSearchCardsAndTask 
                                    AND IsDeleted = false) 
                                    AND WhatId IN :kcList   
                                ORDER BY Id,CreatedDate 
                                LIMIT 9999 All Rows];
                if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
                    //SS 19.03.2018
                    //Modified query for retriving task records including archived records
                    List<Task> Taskpartner =[SELECT 
                                                    Id,
                                                    Priority,
                                                    OwnerID,
                                                    Subject,
                                                    Status,
                                                    ActivityDate,
                                                    WhatID,
                                                    Description,
                                                    Owner.Name,
                                                    LastModifiedDate 
                                                FROM Task  
                                                WHERE( OwnerId IN :UserStandard 
                                                    AND What.type = 'leankor__KanbanCard__c' 
                                                    AND WhatID IN :AddVSCard 
                                                    AND IsDeleted = false )
                                                LIMIT 9999 All Rows];
                                            
                    TaskList.addall(Taskpartner);
                }
                
            }catch(Exception ex){
                System.debug(ex.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            
            List<String> tempCardID = New List<String>();
            for(task LogTask :TaskList){
                tempCardID.add(LogTask.WhatID);
            }

            if(tempCardID.size()>0)
            {
                /*
                *Modified By :Ashutosh Gour
                *Modification : Modification for making SOQL selective and remove negative selection.
                */
                /*
                 cardsList = [Select ID ,leankor__ValueStream__c
                              from leankor__KanbanCard__c Where Id IN: tempCardID and leankor__Valuestream__c != NULL 
                              and leankor__Valuestream__r.leankor__ProjectRoom__C != NULL 
                              AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
                              AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                              AND leankor__MasterContainer__r.leankor__Type__c != 'Template' ORDER BY Id, CreatedDate ASC   limit 49999];*/
                for (leankor__KanbanCard__c cards : [SELECT 
                                                        ID ,
                                                        leankor__ValueStream__c,
                                                        leankor__Valuestream__r.leankor__ProjectRoom__C
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE Id IN: tempCardID 
                                                        AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                        AND leankor__valuestream__r.leankor__boardtype__c  IN ('Kanban Board','Whiteboard','UberBoard','Card Hierarchy','Plan Board','DashBoard') 
                                                        AND leankor__MasterContainer__r.leankor__Type__c  IN('Backlog','Archive','Regular') 
                                                    ORDER BY Id, CreatedDate ASC   limit 49999]) {
                    if (cards.leankor__Valuestream__c != null && cards.leankor__Valuestream__r.leankor__ProjectRoom__C != null ) {
                        cardsList.add(cards);
            }
                }
            }
            if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
                TaskList.clear();
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                TaskList =[SELECT 
                                Id,
                                Priority,
                                OwnerID,
                                Subject,
                                Status,
                                ActivityDate,
                                WhatID,
                                Description,
                                Owner.Name,
                                LastModifiedDate
                            FROM Task  
                            WHERE (OwnerId IN :ResourceIDs 
                                AND WhatID IN :CardsList 
                                AND What.type = 'leankor__KanbanCard__c'
                                AND ActivityDate >= : beginDateForSearchCardsAndTask 
                                AND ActivityDate <=: endDateForSearchCardsAndTask 
                                AND IsDeleted = false)
                            LIMIT 9999 All Rows];          
                          
                List<leankor__Kanbancard__c> VScards = [SELECT 
                                                        Id
                                                    FROM leankor__Kanbancard__c 
                                                    WHERE leankor__valuestream__c = :filterData.ValueStreamID 
                                                        AND leankor__Valuestream__r.leankor__Istemplateboard__c = false 
                                                        AND leankor__MasterContainer__r.leankor__Type__c IN('Backlog','Archive','Regular') 
                                                    ORDER BY Id, CreatedDate ASC   
                                                    LIMIT 9999];
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                List<Task> Taskstandard =[SELECT 
                                                Id,
                                                Priority,
                                                OwnerID,
                                                Subject,
                                                Status,
                                                ActivityDate,
                                                WhatID,
                                                Description,
                                                Owner.Name,
                                                LastModifiedDate 
                                            FROM Task  
                                            WHERE (OwnerId IN :UserStandard 
                                                AND What.type = 'leankor__KanbanCard__c' 
                                                AND WhatID IN :VScards
                                                AND IsDeleted = false) 
                                            LIMIT 9999 All Rows];
                
                TaskList.addall(Taskstandard);           
             }
        }
         
         Map<String,leankor__KanbanCard__c> MapOfKanbanCard =new Map<String,leankor__KanbanCard__c>();
         for(leankor__KanbanCard__c k :cardsList){
             MapOfKanbanCard.put(k.ID,k);
         }  
         for(Task t : TaskList){                        
             
            if(t.whatID != Null && MapOfKanbanCard.ContainsKey(t.WhatId)){
                Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
                Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate)  ;// - 1
                
                MasterContainer card = New MasterContainer ();
                leankor__KanbanCard__c tempVSRecord = new leankor__KanbanCard__c();                                                                        
                    
                    tempVSRecord = (MapOfKanbanCard.containsKey(t.WhatID) ? MapOfKanbanCard.get(t.WhatID): (new leankor__Kanbancard__c()) );                    
                                                             
                    if(tempVSRecord != null)
                    {
                        card.ID = t.ID;               
                        card.ValueStreamID = String.IsEmpty(tempVSRecord.leankor__ValueStream__c) ? '' : tempVSRecord.leankor__ValueStream__c;
                        card.StartDate = JSON.Serialize(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
                        card.DueDate =  JSON.Serialize(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
                        card.ResourceId = t.OwnerID ;
                        card.Name = t.Subject;                    
                        card.EstimatedDuration = 1;
                        card.DurationUnits = 'd';
                        card.OwnerID = t.OwnerID;
                        card.OwnerName = t.Owner.Name;               
                        card.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
                        card.Subject = t.Subject;
                        card.Status =  t.Status;
                        card.Description = t.Description;
                        card.WhatId = t.WhatId;
                        card.ItemType='Task';
                        card.expanded = false;
                        card.leaf = true;               
                        ReturnList.Add(card);
                    }
            }
        }
        return ReturnList;
    }
	
	
	
	
	//*****SS 20.06.2018*****//
	//Commented this method after Error out issue (Heap Size) when we have bulk data more then 20K
    //
    // This Method Is Use Resource(RS) Records On Load.
    // INPUT: List of OwnerID for Getting all KanbanCards and All Task
    // OUTPUT: List Of all KanbanCard and task Shorted by OwnerIDs.
    //   
    /** YJ - 13 Nov 2017
    * Modified method for lazy loading on RS in CV
    * Added filter StartDate and DueDate
    * Reduce unnecessary field for increase performance 
	*/     
	/*     
    @RemoteAction
    Global Static ResourceScheduler getKanbanCardsByResource(List<String> ResourceIDs,String ValueStreamID){
			
		MasterContainer filterData = (MasterContainer)JSON.deserialize(ValueStreamID,MasterContainer.class);
		
		Date beginDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.StartDate), DateTime.class));
        Date endDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.DueDate), DateTime.class));
		
		
		//List<User> PartnerUser =[SELECT Id FROM User WHERE Usertype != 'Standard' AND ID IN :ResourceIDs];
        List<User> AdminUser = [SELECT Id FROM User WHERE Usertype = 'Standard' AND ID IN :ResourceIDs limit 49999];
		List<String> UserStandard;
		List<String> UserNonStandard;
		boolean IscurrentUserPartner = false;
		
        if(Userinfo.getUserType()!='Standard')
        {
        	UserNonStandard = new List<String> ();
        	UserStandard = new List<String> ();
			IscurrentUserPartner = true;
			
			for(User PUser : [SELECT Id FROM User WHERE Usertype != 'Standard' AND ID IN :ResourceIDs limit 49999]){
					UserNonStandard.add(PUser.ID);
			}
            for(User Usercheck :AdminUser){
					UserStandard.add(Usercheck.ID);
			}   
		}
        if(IscurrentUserPartner){
			ResourceIDs.clear();
			IF(UserNonStandard != null && UserNonStandard.size() > 0){
				ResourceIDs.addall(UserNonStandard);
			}
		}
	    // yj 13.01.2017 we added filter leankor__MasterContainer__r.leankor__Type__c != 'Template' in kanban cards query for prevent cards on RS in calender View of kanban board
	    List<leankor__KanbanCard__c> AddVSCard = new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> CardsList =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
            									leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
        										Where leankor__ValueStream__C != Null AND  leankor__Valuestream__r.leankor__projectroom__c != null 
        										and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
        										AND OwnerID IN : ResourceIDs AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
        										AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate)) limit 49999];
        										
        
        if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
        	
            AddVSCard =[Select Id,OwnerID,leankor__valueStream__r.leankor__BoardType__c,leankor__DueDateTime__C,leankor__ValueStream__c,Name,leankor__EstimatedDuration__c,leankor__DurationUnits__c,
            			leankor__StartDateTime__c,leankor__ValueStream__r.leankor__ProjectRoom__c from leankor__KanbanCard__c 
            			Where leankor__ValueStream__C = :filterData.ValueStreamID AND  leankor__Valuestream__r.leankor__projectroom__c != null 
            			and RecordType.Name = 'ActivityCard' AND leankor__valueStream__r.leankor__Istemplateboard__c = false 
            			AND OwnerID IN : UserStandard AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
            			AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate)) limit 49999endDateForSearchCardsAndTask        			
			CardsList.addall(AddVSCard); 
			
	    }
	    List<MasterContainer> ReturnList = New List<MasterContainer>();
        Map<String,leankor__KanbanCard__c> MapOfKanbanCard = new Map<String,leankor__KanbanCard__c>();               
        for(leankor__KanbanCard__c KnbnCard : CardsList)
        {		
        	    MapOfKanbanCard.Put(KnbnCard.ID,KnbnCard); 
        	
				MasterContainer card = New MasterContainer ();
				Card.ID = KnbnCard.ID ;
	            card.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
	            card.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__C);
	            card.ResourceId = KnbnCard.OwnerID ;
	            card.Name = KnbnCard.Name;                       
	            Card.ValueStreamID = KnbnCard.leankor__ValueStream__c;
	            Card.ProjectRoomID = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
	            card.EstimatedDuration=KnbnCard.leankor__EstimatedDuration__c;
				if(KnbnCard.leankor__DurationUnits__c=='Days') card.DurationUnits='d';
				else if(KnbnCard.leankor__DurationUnits__c=='Weeks') card.DurationUnits='w';
				else if(KnbnCard.leankor__DurationUnits__c=='Hours') card.DurationUnits='h';
				else if(KnbnCard.leankor__DurationUnits__c=='Months') card.DurationUnits='mo';
				else if(KnbnCard.leankor__DurationUnits__c=='Years') card.DurationUnits='y';
				else if(KnbnCard.leankor__DurationUnits__c=='Minutes') card.DurationUnits='mi';
	            card.leaf=true;
	              card.ItemType='KC';
	              card.BoardType =(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :KnbnCard.leankor__valueStream__r.leankor__BoardType__c));              
	        ReturnList.Add(card);
	    }
	    List<Task> TaskList = new List<Task>();
	    try{
            //SS 19.03.2018
         	//Modified query for retriving task records including archived records                       
            TaskList =[select Id,Priority,OwnerID,Subject,
            		  Status,ActivityDate,WhatID,
            		  Description,Owner.Name,LastModifiedDate from Task  
            		  where (OwnerId IN :ResourceIDs And What.type = 'leankor__KanbanCard__c'
            		  AND  ActivityDate >= : beginDate and ActivityDate <=: endDate AND IsDeleted = false) 
            		  limit 49999 All Rows];
            
            if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
            	//SS 19.03.2018
         		//Modified query for retriving task records including archived records
                List<Task> Taskpartner =[select Id,Priority,OwnerID,
                						Subject,Status,ActivityDate,
                						WhatID,Description,Owner.Name,
                						LastModifiedDate from Task  
                						where (OwnerId IN :UserStandard AND What.type = 'leankor__KanbanCard__c' AND WhatID IN :AddVSCard AND IsDeleted = false)
                						limit 49999 All Rows];
                						
	            TaskList.addall(Taskpartner);
	        }
	        
	    }catch(Exception ex){
	        System.debug(ex.getMessage());
	    }
	    
		List<String> tempCardID = New List<String>();
        for(task LogTask :TaskList){
	        tempCardID.add(LogTask.WhatID);
	    }
        CardsList.clear();
        
        if(tempCardID.size()>0)
        {
       		 CardsList = [Select ID ,leankor__ValueStream__c
       		 			  from leankor__KanbanCard__c Where Id IN: tempCardID and leankor__Valuestream__c != NULL 
       		 			  and leankor__Valuestream__r.leankor__ProjectRoom__C != NULL 
       		 			  AND leankor__valuestream__r.leankor__Istemplateboard__c = false  
       		 			  AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
       		 			  AND leankor__MasterContainer__r.leankor__Type__c != 'Template' limit 49999];
        }
        	
        if(UserStandard != null && UserStandard.size()>0 && IscurrentUserPartner){
	        TaskList.clear();
	        //SS 19.03.2018
        	//Modified query for retriving task records including archived records
	        TaskList =[select Id,Priority,OwnerID,
	        		  Subject,Status,ActivityDate,
	        		  WhatID,Description,Owner.Name,LastModifiedDate
	        		  from Task  where (OwnerId IN :ResourceIDs AND WhatID IN :CardsList AND What.type = 'leankor__KanbanCard__c'
	        		  AND ActivityDate >= : beginDate AND ActivityDate <=: endDate AND IsDeleted = false)
	        		  limit 9999 All Rows];        	       
	        
	        List<leankor__Kanbancard__c> VScards = [select Id From leankor__Kanbancard__c 
	        									where leankor__valuestream__c = :filterData.ValueStreamID 
	        									AND leankor__Valuestream__r.leankor__Istemplateboard__c = false 
	        									AND leankor__MasterContainer__r.leankor__Type__c != 'Template'];
			//SS 19.03.2018
         	//Modified query for retriving task records including archived records
			List<Task> Taskstandard =[select Id,Priority,OwnerID,Subject,
									  Status,ActivityDate,WhatID,Description,
									  Owner.Name,LastModifiedDate from Task  
									  where (OwnerId IN :UserStandard AND What.type = 'leankor__KanbanCard__c' AND WhatID IN :VScards
									  AND IsDeleted = false) limit 49999 All Rows];
	        
	        TaskList.addall(Taskstandard);           
         }
         for(leankor__KanbanCard__c k :CardsList){
	         MapOfKanbanCard.put(k.ID,k);
	     }  
	     
	     
         for(Task t : TaskList){         	         	
         	 
            if(t.whatID != Null && MapOfKanbanCard.ContainsKey(t.WhatId)){
	            Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
	            Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate)  ;// - 1
	            
	            MasterContainer card = New MasterContainer ();
	            leankor__KanbanCard__c tempVSRecord = new leankor__KanbanCard__c();	                	                	                               
	                
	                tempVSRecord = (MapOfKanbanCard.containsKey(t.WhatID) ? MapOfKanbanCard.get(t.WhatID): (new leankor__Kanbancard__c()) );	                
	                	                	                 
	                if(tempVSRecord != null)
	                {
		                card.ID = t.ID;	              
		                card.ValueStreamID = String.IsEmpty(tempVSRecord.leankor__ValueStream__c) ? '' : tempVSRecord.leankor__ValueStream__c;
		                card.StartDate = JSON.Serialize(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
		                card.DueDate =  JSON.Serialize(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
		                card.ResourceId = t.OwnerID ;
		                card.Name = t.Subject;                    
		                card.EstimatedDuration = 1;
		                card.DurationUnits = 'd';
		                card.OwnerID = t.OwnerID;
		                card.OwnerName = t.Owner.Name;               
		                card.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
		                card.Subject = t.Subject;
		                card.Status =  t.Status;
		                card.Description = t.Description;
		                card.WhatId = t.WhatId;
		                card.ItemType='Task';
		                card.expanded = false;
		                card.leaf = true;               
		            	ReturnList.Add(card);
	                }
	        }
	    } 
	     	    
        if(IscurrentUserPartner){
	        ResourceIDs.addall(UserStandard);
	    }
        List<User> UserList = [Select Id,Name,SmallPhotoURL from User Where Id IN :ResourceIDs LIMIT 49999];
	    Set<CardResource> cardResources = new Set<CardResource>();
        for(User u : UserList){
	        CardResource tempResource = new CardResource(u.Id,u.Name,u.SmallPhotoUrl);
	        cardResources.add(tempResource);
	    }
	    
	    return (new ResourceScheduler(ReturnList,cardResources));
	}*/   
    //
    // This Method Is Use get Zone Records On Load.
    // INPUT: GUID form KanbanCard.
    // OUTPUT : Zone records for input GUID
    //       
    @RemoteAction
    Global static MasterContainer getZoneRecord(String requestedID){
        leankor__Zone__c Zone =[SELECT 
                                    Id,
                                    leankor__Swimlane__r.leankor__MasterContainer__c,
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
                                    OwnerId 
								FROM leankor__Zone__c 
								WHERE leankor__GUID__C =:requestedID  
								LIMIT 1];
        MasterContainer CardZone = new MasterContainer();
        CardZone.Id=Zone.Id;
        CardZone.UrlLink =Zone.leankor__UrlLink__c;
        CardZone.Title=Zone.leankor__Title__c;
        CardZone.Top=Integer.valueOf(Zone.leankor__Top__c);
        CardZone.Bottom=Integer.valueOf(Zone.leankor__Bottom__c);
        CardZone.Left=Integer.valueOf(Zone.leankor__Left__c);
        CardZone.Width=Integer.valueOf(Zone.leankor__Width__c);
        CardZone.Height=Integer.valueOf(Zone.leankor__Height__c);
        CardZone.X=Integer.valueOf(Zone.leankor__x__c);
        CardZone.Y=Integer.valueOf(Zone.leankor__Y__c);
        CardZone.DefaultHeight=Integer.valueOf(Zone.leankor__DefaultHeight__c);
        CardZone.DefaultWidth=Integer.valueOf(Zone.leankor__DefaultWidth__c);
        CardZone.Name=Zone.Name;
        CardZone.leaf=false;
        CardZone.JSONDefinition=Zone.leankor__JSONDefinition__c;
        CardZone.ValueStreamCardLink=(Zone.leankor__ValueStreamCardLink__c==null?'':Zone.leankor__ValueStreamCardLink__c);
        CardZone.ValueStreamLinkID=(Zone.leankor__ValueStreamLink__c==null?'':Zone.leankor__ValueStreamLink__c);
        CardZone.ValueStreamId=Zone.leankor__ValueStream__c;
        CardZone.ValueStream=Zone.leankor__ValueStream__c;
        CardZone.CmpID=Zone.leankor__CmpID__c;
        CardZone.GUID=Zone.leankor__GUID__c;
        CardZone.MCforceID = (Zone.leankor__Swimlane__r.leankor__MasterContainer__c ==Null?'':Zone.leankor__Swimlane__r.leankor__MasterContainer__c);
        CardZone.SWforceID = (Zone.leankor__Swimlane__c == Null ?'' :Zone.leankor__Swimlane__c);
        CardZone.ZoneForceID = Zone.ID;
        CardZone.OwnerID=Zone.OwnerID;
        CardZone.CaseStatus=(Zone.leankor__CaseStatus__c==null?'':Zone.leankor__CaseStatus__c);  
        CardZone.EntryFlowName=Zone.leankor__EntryFlowName__c;
        CardZone.ExitFlowName=Zone.leankor__ExitFlowName__c;
        CardZone.ZoneMode=Zone.leankor__ZoneMode__c;
        CardZone.KanbanSequence=Zone.leankor__KanbanSequence__c;
        CardZone.TaskLimit=Zone.leankor__Limit__c;
        CardZone.Order=Zone.leankor__Order__c;
        CardZone.ParentZone=Zone.leankor__ParentZone__c;
        CardZone.Swimlane=Zone.leankor__Swimlane__c;
        CardZone.CardsPerRow=Zone.leankor__CardsPerRow__c;
        CardZone.Help=Zone.leankor__Help__c;
        CardZone.CompletionRateUnits=Zone.leankor__CompletionRateUnits__c;
        CardZone.CompletionRate=Integer.valueOf(Zone.leankor__CompletionRate__c);
        CardZone.CSSLayout=Zone.leankor__CSSLayout__c;
        CardZone.KanbanCardCount=Integer.valueOf(Zone.leankor__KanbanCardCount2__c);
        CardZone.KanbanCardThroughput=Integer.valueOf(Zone.leankor__KanbanCardThroughput__c);
        CardZone.LeadTime=Integer.valueOf(Zone.leankor__LeadTime__c);
        CardZone.ZoneTemplate=Zone.leankor__ZoneTemplate__c;
        CardZone.ItemType='ZONE';
        CardZone.Color ='#CCCCCC';               
        return CardZone;
    }
		//
		// This Methord is use for Get all Value stream with respected kanbancards to task Owner to owner cards VSID 
		// INPUT : VSID for current board
		// OUTPUT : Set Of valueStream ID 
		//
		@RemoteAction
		global static Set<String> getAllValueStreamID(String VSID){
            if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
		   
		    return getAllValueStreamIDForStreaming(VSID);
		}//End of Method
		
		
		/****Start
   		SS 10.07.2018
   		//This method is commented due to modification for preventing soql query exception 
   		****/
		/*//05.12.2017 - modified SOQL query for improve performance
		@ReadOnly
		@RemoteAction
		Global static Set<String> getAllValueStreamIDForStreaming(String VSID)
		{
		    Set<String> VSIDSet = new Set<String>();
		    Set<String> WhatIdSet = new Set<String>();
		    Set<String> userSet = new Set<String>();
		    //Date MinStatedate =system.today(); //not using anywhere
		    //Date MaxDuedate = System.Today()+1;//not using anywhere
		    
		    List<leankor__KanbanCard__c> AllCards = [Select ID,
		    									  OwnerID 
		    									  From leankor__KanbanCard__c 
		    									  Where leankor__ValueStream__c =:VSID 
		    									  AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
		    									  AND leankor__IsRecordDeleted__c = false limit 49999];		   
		    for(leankor__KanbanCard__C k : AllCards)
		    {
		        userSet.add(k.OwnerId);
		        //MinStatedate = (k.leankor__StartDate__c >= MinStatedate ? MinStatedate : k.leankor__StartDate__c);//not using anywhere
		        //MaxDuedate = (k.leankor__DueDate__c <= MaxDuedate ? MaxDuedate : k.leankor__DueDate__c);//not using anywhere
		        
		    }
		    // yj-28.03.2018 query task records and put results in a list  
		    List<Task> Tasks = [select Id,OwnerID from Task where  WhatId IN : AllCards AND What.Type = 'leankor__KanbanCard__c' And IsDeleted = false limit 49999 All Rows];
		    for(Task t : Tasks){
		            userSet.add(t.OwnerId);
		        }
		    
		    AllCards.clear();
		 
		    AllCards = [Select ID,OwnerID,leankor__ValueStream__c From leankor__KanbanCard__c 
		    			Where leankor__ValueStream__r.leankor__Istemplateboard__c = false 
		    			AND OwnerId IN :userSet 
		    			AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
		   				AND leankor__IsRecordDeleted__c = false limit 49999];
		    
		    for(leankor__KanbanCard__C k : AllCards)
		    {
		        VSIDSet.add(k.leankor__ValueStream__C);
		    }
		    //SS 19.03.2018
         	//Modified query for retriving task records including archived records
		    List<Task> TaskList =[select Id,OwnerID,WhatId from Task  where (OwnerId IN :userSet AND What.type = 'leankor__KanbanCard__c' 
		    					 AND IsDeleted = false) limit 49999 All Rows];
		    for(Task t : TaskList){
		        WhatIdSet.add(t.WhatId);
		    }
		    AllCards.clear();
		    AllCards = [Select ID,OwnerID,leankor__ValueStream__c 
		    			From leankor__KanbanCard__c
		    			Where leankor__ValueStream__r.leankor__Istemplateboard__c = false AND Id IN :WhatIdSet
		    		    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
		   				AND leankor__IsRecordDeleted__c = false limit 49999];
		   				
		    for(leankor__KanbanCard__C k : AllCards)
		    {
		        VSIDSet.add(k.leankor__ValueStream__C);
		    }		    
		    VSIDSet.remove(VSID);		    
		    return VSIDSet;
		}//End of Method
		*/
   
		/*------------------------------------------------------------
		Author: 		Suraj Sen
		Company: 		Leankor
		Description: 	get List Of userIds referenced in current board either for Task/KanbanCard
	    Inputs: 		VSID
		Returns: 		Set<String>    [List of user ids]
		------------------------------------------------------------*/
		@RemoteAction
		global static Set<String> readUsersRefInBoard(String VSID)
		{
            if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
		    Set < String > userSet = new Set < String > ();
			//Query users which are owner of cards in current board
			List < User > cardOwnerList = [SELECT 
                                                id 
                                            FROM User 
                                            WHERE id IN(SELECT 
                                                                OwnerId
                                                            FROM leankor__KanbanCard__c 
                                                            WHERE leankor__ValueStream__c = : VSID 
                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
											                    AND leankor__IsRecordDeleted__c = false)
                                            LIMIT 49999];
			for (User user: cardOwnerList)
			{
				userSet.add(user.Id);
			}
			//Query task to get TaskOwnerIds of current board's cards 
			List < AggregateResult > taskOwnerList = [SELECT 
                                                            OwnerId 
                                                        FROM Task 
                                                        WHERE WhatId IN(SELECT Id 
                                                                            FROM leankor__KanbanCard__c 
                                                                            WHERE leankor__ValueStream__c = : VSID 
                                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
						                                                        AND leankor__IsRecordDeleted__c = false)
                                                            AND What.Type = 'leankor__KanbanCard__c' And IsDeleted = false 
                                                            GROUP BY OwnerId 
                                                            LIMIT 49999 All Rows];
			for (AggregateResult t: taskOwnerList)
			{
				userSet.add((String)t.get('OwnerId'));
			}
			return userSet;
		}
		
		/*------------------------------------------------------------
		Author: 		Suraj Sen
		Company: 		Leankor
		Description: 	get all whatIds of user's Task 
	    Inputs: 		userIds
		Returns: 		Set<String>    [List of whatIdSet ids]
		------------------------------------------------------------*/
		@RemoteAction
		global static Set<String> readAllTaskOfUsers(List<String> userIds)
		{
            if(userIds.size()>0){
                for(String userId : userIds){
                    if (String.isNotBlank(userId) && Util.getSObjectName(userId) != 'User') {
                        System.debug('Error: Invalid input');
                        throw new Util.LeanException('Error: Invalid input');
                    }
                }
            }
		    Set < String > whatIdSet = new Set < String > ();
			//AggregateQuery is causing exception in case of more task so used sObject query
			//Query task to get TaskOwnerIds of current board's cards 
			/*List < AggregateResult > TaskList = [select WhatId from Task 
												where(OwnerId IN: userIds AND WhatId!=null AND What.type = 'leankor__KanbanCard__c' AND IsDeleted = false) 
												GROUP BY WhatId limit 49999 All Rows];
			for (AggregateResult t: TaskList)
			{
				whatIdSet.add((String)t.get('WhatId'));
			}*/
			List < Task > TaskList = [SELECT WhatId 
                                            FROM Task 
                                            WHERE(OwnerId IN: userIds 
                                                AND What.type = 'leankor__KanbanCard__c' 
                                                AND IsDeleted = false) 
                                            LIMIT 49999 All Rows];
			for (Task t: TaskList)
			{
				whatIdSet.add(t.WhatId);
			}
			return whatIdSet;
		}
		
		/*------------------------------------------------------------
		Author: 		Suraj Sen
		Company: 		Leankor
		Description: 	get all vsIds for Streaming 
	    Inputs: 		VSID, userIds, whatIdSet
		Returns: 		Set<String>    [List of vs ids]
		------------------------------------------------------------*/
		@RemoteAction
		global static Set<String> readAllVSIdsForStreaming(String VSID, List<String> userIds, List<String> whatIds)
		{
            if(userIds.size()>0 || whatIds.size()>0){
                for(String userId : userIds){
                    if (String.isNotBlank(userId) && Util.getSObjectName(userId) != 'User') {
                        System.debug('Error: Invalid input');
                        throw new Util.LeanException('Error: Invalid input');
                    }
                }
                for(String whatId : whatIds){
                    if (String.isNotBlank(whatId) && Util.getSObjectName(whatId) != 'leankor__KanbanCard__c') {
                        System.debug('Error: Invalid input');
                        throw new Util.LeanException('Error: Invalid input');
                    }
                }
            }
		    Set < String > vsIDSet = new Set < String > ();
			List < leankor__ValueStream__c > vsIds = [SELECT 
                                                        Id,
                                                        Name
                                                    FROM leankor__ValueStream__c 
                                                    WHERE Id IN( SELECT leankor__ValueStream__c 
                                                                    FROM leankor__KanbanCard__c
                                                                    WHERE (OwnerId IN :userIds  OR Id in : whatIds) 
                                                                        AND leankor__IsRecordDeleted__c = false) 
                                                        AND leankor__Istemplateboard__c = false 
                                                        AND leankor__IsRecordDeleted__c = false 
                                                    LIMIT 49999];
			for (leankor__ValueStream__c vs: vsIds)
			{
				vsIDSet.add(vs.Id);
			}		   
			vsIDSet.remove(VSID); 
		    return vsIDSet;
		}
		/*------------------------------------------------------------
		Author: 		Suraj Sen
		Company: 		Leankor
		Description: 	List Of all Task associated with active KanbanCards Filtered by ResourceIds
	    Inputs: 		vsId
		Returns: 		Set<String>    [List of vsIds]
		------------------------------------------------------------*/
		@ReadOnly
		@RemoteAction
		Global static Set<String> getAllValueStreamIDForStreaming(String VSID)
		{ 
            if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
		    Set < String > vsIDSet = new Set < String > ();
			Set < String > whatIdSet = new Set < String > ();
			Set < String > userSet = new Set < String > ();
			//Query users which are owner of cards in current board
			List < User > cardOwnerList = [SELECT 
                                                id 
                                            FROM User 
                                            WHERE id IN(SELECT 
                                                                OwnerId
                                                            FROM leankor__KanbanCard__c
                                                            WHERE leankor__ValueStream__c = : VSID 
                                                            AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
											AND leankor__IsRecordDeleted__c = false)limit 49999];
			for (User user: cardOwnerList)
			{
				userSet.add(user.Id);
			}
			//Query task to get TaskOwnerIds of current board's cards 
			List < Task > taskOwnerList = [SELECT 
                                                OwnerId 
                                            FROM Task 
                                            WHERE WhatId IN(SELECT 
                                                                    Id 
                                                                FROM leankor__KanbanCard__c 
                                                                WHERE leankor__ValueStream__c = : VSID 
                                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
						                                            AND leankor__IsRecordDeleted__c = false)
                                                AND What.Type = 'leankor__KanbanCard__c' 
                                                AND IsDeleted = false 
                                                LIMIT 49999 All Rows];
			for (Task t: taskOwnerList){
				userSet.add(t.OwnerId);
			}
			
			//Query all task of users(Referenced in current board either as owner of card/task). 
        /*
        *Modified By :Ashutosh Gour
        *Modification : Modification for making SOQL selective and remove negative selection.
        */
        //	List < Task > TaskList = [SELECT Id, OwnerID, WhatId from Task where(OwnerId IN: userSet AND WhatId!=null AND What.type = 'leankor__KanbanCard__c'
		//				                AND IsDeleted = false) limit 49999 All Rows];
            List < Task > TaskList = new List< Task >();
            for(TASK  t : [SELECT 
                                Id,
                                OwnerID, 
                                WhatId
                            FROM Task
                            WHERE(OwnerId IN: userSet 
                                AND What.type = 'leankor__KanbanCard__c'
                                AND IsDeleted = false) 
                            LIMIT 49999 ]) {
                if (t.WhatId != null) {
                    TaskList.add(t);
                }
                
            }
			for (Task t: TaskList)
			{
				whatIdSet.add(t.WhatId);
			}
			
			//query for all vsIds filtered by where clause query for cards in whatIdset or there ownerIds are in userSet
			List < leankor__ValueStream__c > vsIds = [SELECT 
                                                        Id,
                                                        Name 
                                                    FROM leankor__ValueStream__c 
                                                    WHERE Id IN( SELECT 
                                                                        leankor__ValueStream__c 
                                                                    FROM leankor__KanbanCard__c
                                                                    WHERE (OwnerId IN :userSet  
                                                                            OR Id in : whatIdSet)
                                                                        AND leankor__IsRecordDeleted__c = false)
                                                        AND leankor__Istemplateboard__c = false 
                                                        AND leankor__IsRecordDeleted__c = false
                                                        LIMIT 49999];
			System.debug(Limits.getQueryRows());		
			for (leankor__ValueStream__c vs: vsIds)
			{
				vsIDSet.add(vs.Id);
			}		   
			vsIDSet.remove(VSID); 
		    return vsIDSet;
		}//End of Method
		
   		/****End
   		SS 10.07.2018 
   		****/
		//inner class		
		global class CloneCardData
		{		   		   		   
		   global String BoardId;	    	
		   global string someJSONData;		   
           global Boolean isActivityGroup;         
		   global String ItemType; 		  
		   global List<leankor.RealTimeController.Dependency> dependencyList;
		   global List<String> cardIdlist;		   	    	
		   global String folderId;		   	    	
		   global String newData;		   	    	
           global MasterContainer Activity;
           global list<leankor.GanttTaskBoard.ResourceAssignment> ResourceAssignmentData;
		}				
						
		
		/*-------------------------------------------------------------------------------------------------------
        Company: Leankor
        Method : cloneActivityGroup
        Inputs : object of CloneCardData inner class
        Outputs : CloneCardData which contains clone dependency, kanbanCard and resource list. 
        Description : Activity Group , Activity and Milestone cloning on plangantt. 
        -------------------------------------------------------------------------------------------------------*/
        @RemoteAction 
        global static CloneCardData cloneActivityGroup(CloneCardData clonecard, String sessionId){    
            System.debug(clonecard);
            Map<Id,leankor__KanbanCard__c> remoteKanbanCards;

            CloneCardData result = new CloneCardData();   
            Set <String> activityIds = new Set <String> ();        
            Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([Select 
                                                                            Id, 
                                                                            Name, 
                                                                            SobjectType 
                                                                        From RecordType 
                                                                        Where SobjectType = 'leankor__KanbanCard__c']);
                                            
            remoteKanbanCards = new Map<Id,leankor__KanbanCard__c>([Select 
                                                                        Id,
                                                                        (Select
                                                                            Id,
                                                                            leankor__ManuallyScheduled__c,
                                                                            leankor__Mode__c,
                                                                            leankor__EffortUnits__c,
                                                                            leankor__EffortActual__c,
                                                                            leankor__KanbanCard__c,
                                                                            leankor__KanbanCard__r.leankor__valuestream__c,
                                                                            leankor__ConstraintDateTime__c,
                                                                            leankor__ScheduleConstraint__r.leankor__Type__c
                                                                        From leankor__ScheduleModes__r 
                                                                        Limit 1),
                                                                        (Select 
                                                                                Id,
                                                                                leankor__AssignedTo__c,
                                                                                leankor__AssignedTo__r.IsActive,
                                                                                leankor__KanbanCard__c,
                                                                                leankor__CompletedDate__c,
                                                                                leankor__KanbanCard__r.leankor__valuestream__c,
                                                                                leankor__PercentAllocation__c,
                                                                                leankor__PercentCompleted__c,
                                                                                Name,
                                                                                leankor__ResourceType__c,
                                                                                leankor__ProjectFinancial__c,
                                                                            leankor__ResourceType__r.Name 
                                                                        From leankor__ResourceAssignments__r),
                                                                            leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                                            leankor__valuestream__r.leankor__boardtype__c,
                                                                            leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                                            leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                                                            RecordType.Name,leankor__CardID__c,
                                                                            leankor__Point__c,leankor__EffortRemaining__c,
                                                                            leankor__MasterContainer__c,leankor__Swimlane__c,
                                                                            leankor__Zone__c,leankor__UrlLink__c,leankor__Account__c,
                                                                            leankor__ActualDuration__c,
                                                                            leankor__Actual_Time_Taken__c,
                                                                            leankor__Bottom__c,leankor__Budgeted_Time__c,
                                                                            leankor__Case__c,leankor__CmpID__c,
                                                                            leankor__Color__c,
                                                                            leankor__CompletionVariance__c,
                                                                            leankor__Contact__c,
                                                                            leankor__CSSLayout__c,
                                                                            leankor__DateColor__c,
                                                                            leankor__DescriptionLong__c,
                                                                            leankor__AcceptanceCriteria__c,
                                                                            leankor__Description__c,
                                                                            leankor__DueDate__c,
                                                                            leankor__DurationUnits__c,
                                                                            leankor__EstimatedDuration__c,
                                                                            leankor__GUID__c,
                                                                            leankor__HarveyBallDoneDate__c,
                                                                            leankor__Height__c,
                                                                            leankor__IsCompletedOnTime__c,
																			leankor__KanbanCardTemplate__c,
                                                                            leankor__Left__c,leankor__Opportunity__c,
                                                                            leankor__Order__c,leankor__PercentComplete2__c,
                                                                            leankor__Priority__c,
                                                                            leankor__StartDate__c,
                                                                            leankor__State__c,leankor__Title__c,
                                                                            leankor__Top__c,
                                                                            leankor__ValueStreamCardLink__c,
                                                                            leankor__ValueStreamLink__c,
                                                                            leankor__ValueStream__c,
                                                                            leankor__Width__c,
                                                                            leankor__X__c,
                                                                            leankor__Y__c,
                                                                            leankor__ZoneGUID__c,
                                                                            Name,OwnerId,
                                                                            leankor__StartDateTime__C,
                                                                            leankor__DueDateTime__c,
                                                                            leankor__OnBudget__c,
                                                                            leankor__OnQuality__c,
                                                                            leankor__OnTime__c,
                                                                            leankor__PromiseCompletionDate__c,
                                                                            leankor__IsAtRisk__c,
                                                                            leankor__IsOnHold__c,
                                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                                            leankor__TimeToProjectLaunch__c,
                                                                            leankor__Monday__c,
                                                                            leankor__Tuesday__c,
                                                                            leankor__Wednesday__c,
                                                                            leankor__Thursday__c,
                                                                            leankor__Friday__c,
                                                                            leankor__Saturday__c,
                                                                            leankor__Sunday__c,
                                                                            leankor__WeekCalendar__c
                                                                        From leankor__KanbanCard__c 
                                                                        Where Id In :clonecard.cardIdlist
                                                                        With Security_Enforced
                                                                        Order By leankor__Order__c Desc  Nulls Last 
                                                                        Limit 9999]);
            
            KanbanController.FieldSetRecord singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(clonecard.cardIdlist, 'leankor__KanbanCard__c');
            singleFieldSetRecord.fieldSetAndFields.clear();
            
            if(singleFieldSetRecord.allFields.size() > 0) {
                String soql ='Select Id'+ singleFieldSetRecord.allFieldsInStringFormat + ' From leankor__KanbanCard__c Where Id In :clonecard.cardIdlist Limit 50000';
                kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__c>((List<leankor__KanbanCard__c>)Database.query(soql));
            }
           
            
            /* Cloning the card and query on new card with schedule mode */
            //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for impelementing constraint feature
            List<leankor__KanbanCard__c> newClonedKanbanCard =	[Select
                                                                    Id,
                                                                    (Select 
                                                                            Id,
                                                                            leankor__ManuallyScheduled__c,
                                                                            leankor__Mode__c,
                                                                            leankor__EffortUnits__c,
                                                                            leankor__EffortActual__c,
                                                                            leankor__KanbanCard__c,
                                                                            leankor__KanbanCard__r.leankor__valuestream__c,
                                                                            leankor__ConstraintDateTime__c,
                                                                            //leankor__ReadOnly__c,
								                                            leankor__ScheduleConstraint__r.leankor__Type__c 
                                                                        From leankor__ScheduleModes__r
                                                                        Limit 1),
                                                                    (Select 
                                                                            Id,
                                                                            leankor__AssignedTo__c,
                                                                            leankor__KanbanCard__c,
                                                                            leankor__CompletedDate__c,
                                                                            leankor__KanbanCard__r.leankor__valuestream__c,
                                                                            leankor__PercentAllocation__c,
                                                                            leankor__PercentCompleted__c,
                                                                            Name,
                                                                            leankor__ResourceType__c,
                                                                            leankor__ResourceType__r.Name 
                                                                        From leankor__ResourceAssignments__r),
																	 leankor__ValueStream__r.leankor__ProjectRoom__c,
																	 leankor__valuestream__r.leankor__boardtype__c,
																	 leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
																	 leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
																	 RecordType.Name,leankor__CardID__c,
																	 leankor__Point__c,leankor__EffortRemaining__c,
																	 leankor__MasterContainer__c,leankor__Swimlane__c,
																	 leankor__Zone__c,leankor__UrlLink__c,leankor__Account__c,
																	 leankor__ActualDuration__c,
																	 leankor__Actual_Time_Taken__c,
																	 leankor__Bottom__c,leankor__Budgeted_Time__c,
																	 leankor__Case__c,leankor__CmpID__c,
																	 leankor__Color__c,
																	 leankor__CompletionVariance__c,
																	 leankor__Contact__c,
																	 leankor__KanbanCardTemplate__r.Name,
																	 leankor__CSSLayout__c,
																	 leankor__DateColor__c,
																	 leankor__DescriptionLong__c,
																	 leankor__AcceptanceCriteria__c,
																	 leankor__Description__c,
																	 leankor__DueDate__c,
																	 leankor__DurationUnits__c,
																	 leankor__EstimatedDuration__c,
																	 leankor__GUID__c,
																	 leankor__HarveyBallDoneDate__c,
																	 leankor__Height__c,
																	 leankor__IsCompletedOnTime__c,
																	 //leankor__JSONData__c,
																	 //leankor__JSONDefinition__c,
																	 leankor__KanbanCardTemplate__c,
																	 leankor__Left__c,leankor__Opportunity__c,
																	 leankor__Order__c,leankor__PercentComplete2__c,
																	 leankor__Priority__c,
																	 leankor__StartDate__c,
																	 leankor__State__c,leankor__Title__c,
																	 leankor__Top__c,
																	 leankor__ValueStreamCardLink__c,
																	 leankor__ValueStreamLink__c,
																	 leankor__ValueStream__c,
																	 leankor__Width__c,
																	 leankor__X__c,
																	 leankor__Y__c,
																	 leankor__ZoneGUID__c,
																	 Name,OwnerId, Owner.Name,
																	 leankor__KanbanCardTemplate__r.leankor__Color__c,
																	 leankor__ValueStream__r.leankor__Isrecalculate__c,
																	 leankor__StartDateTime__C,
																	 leankor__IsExternallyDependent__c,
																	 leankor__IsSuccessorRecalculate__c,
																	 leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c,
																	 leankor__DueDateTime__c,
																	 leankor__OnBudget__c,
																	 leankor__OnQuality__c,
																	 leankor__ValueStreamCardLink__r.Name,
																	 leankor__ValueStreamLink__r.Name,
																	 leankor__ValueStreamLink__r.leankor__BoardType__c,
																	 leankor__OnTime__c,
																	 leankor__PromiseCompletionDate__c,
																	 leankor__IsAtRisk__c,
																	 leankor__IsOnHold__c,
																	leankor__TimeToProjectLaunch__c,
                                                                    leankor__Monday__c,
                                                                    leankor__Tuesday__c,
                                                                    leankor__Wednesday__c,
                                                                    leankor__Thursday__c,
                                                                    leankor__Friday__c,
                                                                    leankor__Saturday__c,
                                                                    leankor__Sunday__c,
                                                                    leankor__WeekCalendar__c 
																	//* calling createCard method in query*/
																	 //RS 28/11/2019 Removed allUserMap variable 
																	 //FROM leankor__KanbanCard__c Where Id IN : createCard(remoteKanbanCards,clonecard,allUserMap)
                                                                From leankor__KanbanCard__c 
                                                                Where Id In :createCard(remoteKanbanCards.values(),clonecard)
                                                                With Security_Enforced
                                                                Order By leankor__Order__c Desc  Nulls Last 
                                                                Limit 9999]; 
								 
            // Relinking the cards after clone
            List<leankor__KanbanCard__c> kanbanCardList =  linkKanbanCards(newClonedKanbanCard);
            // Creating the map for parent cards
            Map<String, List<leankor__Kanbancard__c>> mapOfListCards = leankor.GanttTaskBoard.createMapOfListCards(kanbanCardList);
	            
            String oldFolderId;                    
            String newFolderId;
            // Find and assign new folder Id
            
            if(clonecard.folderId != null && clonecard.folderId != ''){
                for(leankor__KanbanCard__c knbnCard : newClonedKanbanCard ){ 
                    // Adding card Id's into set so that we can retrive resource.
                    activityIds.add(knbnCard.Id);                   
                    if((knbnCard.leankor__GUID__C).SubStringBefore('-') == clonecard.folderId){
                        oldFolderId = knbnCard.leankor__GUID__C.SubStringBefore('-') ; 
                        newFolderId = string.valueof(knbnCard.Id);
      					leankor.KanbanToGanttController.MasterContainer kanbanCardWrapper = new leankor.KanbanToGanttController.MasterContainer(); 
			            kanbanCardWrapper.Id=knbnCard.Id;
			            kanbanCardWrapper.Name=knbnCard.Name;                  
			            kanbanCardWrapper.isMilestone = (recordTypeMap.get(knbnCard.RecordTypeId).Name == 'MilestoneCard' ? true : false);                        
			            kanbanCardWrapper.Title=knbnCard.leankor__Title__c;
			            kanbanCardWrapper.ValueStreamID=knbnCard.leankor__ValueStream__c;
			            kanbanCardWrapper.CmpID=knbnCard.leankor__CmpID__c;
			            kanbanCardWrapper.GUID=knbnCard.leankor__GUID__c;
			            kanbanCardWrapper.Order=knbnCard.leankor__Order__c;
			            kanbanCardWrapper.StartDate =  JSON.Serialize(knbnCard.leankor__StartDateTime__c);
			            kanbanCardWrapper.DueDate =  JSON.Serialize(knbnCard.leankor__DueDateTime__c);
			            kanbanCardWrapper.PercentDone=KnbnCard.leankor__PercentComplete2__c;
			            kanbanCardWrapper.leaf=(recordTypeMap.get(knbnCard.RecordTypeId).Name == 'FolderCard' ? false : true);
			            kanbanCardWrapper.EstimatedDuration = KnbnCard.leankor__EstimatedDuration__c;                 
			            //Date :11/10/19  change DurationUnits string value.          
			            kanbanCardWrapper.DurationUnits = KnbnCard.leankor__DurationUnits__c == 'Days' ? 'Days' :(KnbnCard.leankor__DurationUnits__c == 'Weeks' ? 'Weeks' : (KnbnCard.leankor__DurationUnits__c == 'Hours' ? 'Hours': (KnbnCard.leankor__DurationUnits__c == 'Months' ? 'Months' : (KnbnCard.leankor__DurationUnits__c == 'Years' ? 'Years' : 'Minutes'))));
			            kanbanCardWrapper.CardID=knbnCard.leankor__CardID__c;                    
			            kanbanCardWrapper.EffortRemaining = integer.valueof(KnbnCard.leankor__EffortRemaining__c);                   
			            kanbanCardWrapper.ForceID=(knbnCard.ID == null ? '' :knbnCard.ID);                  
			            kanbanCardWrapper.TemplateID=(KnbnCard.leankor__KanbanCardTemplate__c==null?'':KnbnCard.leankor__KanbanCardTemplate__c);
			            kanbanCardWrapper.TemplateName=KnbnCard.leankor__KanbanCardTemplate__r.Name;                  
			            kanbanCardWrapper.Priority=Integer.valueOf(KnbnCard.leankor__Priority__c);
			            kanbanCardWrapper.HarveyBall=string.valueOf(KnbnCard.leankor__PercentComplete2__c);                   
			            kanbanCardWrapper.Description=KnbnCard.leankor__DescriptionLong__c;               
			            kanbanCardWrapper.ValueStreamCardLink=(KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__c);
			            kanbanCardWrapper.ValueStreamLinkID=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__c);
			            kanbanCardWrapper.ValueStreamCardLinkName = (KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__r.Name); 
			            kanbanCardWrapper.ValueStreamLinkIDName = (KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.Name);
			            kanbanCardWrapper.ValueStreamLinkBoardType=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);                                           
			            kanbanCardWrapper.OwnerID=KnbnCard.OwnerID;   
			            kanbanCardWrapper.KanbanUrl='';
			            kanbanCardWrapper.BoardType = KnbnCard.leankor__ValueStream__r.leankor__Boardtype__c;
			            kanbanCardWrapper.OnBudget = KnbnCard.leankor__OnBudget__c;
			            kanbanCardWrapper.OnQuality = KnbnCard.leankor__OnQuality__c;
			            kanbanCardWrapper.OnTime = KnbnCard.leankor__OnTime__c;
			            kanbanCardWrapper.OwnerName = KnbnCard.Owner.Name;                   
			            kanbanCardWrapper.ItemType= recordTypeMap.get(knbnCard.RecordTypeId).Name;
			            //kanbanCardWrapper.JSONDefinition = KnbnCard.leankor__JSONDefinition__c;
			            //kanbanCardWrapper.JSONData = KnbnCard.leankor__JSONData__c;
                        kanbanCardWrapper.JSONDefinition = null;
                        kanbanCardWrapper.JSONData = null;
			            kanbanCardWrapper.Color = (KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c==null?'':KnbnCard.leankor__kanbanCardTemplate__r.leankor__Color__c);
				        kanbanCardWrapper.isAtRisk = KnbnCard.leankor__IsAtRisk__c;
				        kanbanCardWrapper.isOnHold = KnbnCard.leankor__IsOnHold__c;
				        kanbanCardWrapper.timeToProjectLaunch = (String.isNotBlank(String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c))) ? String.valueOf(KnbnCard.leankor__TimeToProjectLaunch__c.intValue()): '';
			            // For Icon and type was not getting updated of linked activity after move card template MC to another MC
			            if (kanbanCardWrapper.ItemType == 'MilestoneCard' && kanbanCardWrapper.EstimatedDuration != 0) {
			                kanbanCardWrapper.ItemType =  'ActivityCard';                                    
		                }							    
				       
			            kanbanCardWrapper.IsRecalculate = knbnCard.leankor__Valuestream__r.leankor__Isrecalculate__c;
			            kanbanCardWrapper.IsExternallyDependent = KnbnCard.leankor__IsExternallyDependent__c; 
			             // adding leankor__IsSuccessorRecalculate__c field for Recalculation of linked activity
			            kanbanCardWrapper.IsSuccessorRecalculate = KnbnCard.leankor__IsSuccessorRecalculate__c; 
				        //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for impelementing constraint feature on cloning activity  
			            if(KnbnCard.leankor__ScheduleModes__r.size()>0){
			                kanbanCardWrapper.ManuallyScheduled = KnbnCard.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
			                kanbanCardWrapper.SchedulingMode= KnbnCard.leankor__ScheduleModes__r[0].leankor__Mode__c;
			                kanbanCardWrapper.EffortUnit = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
			                kanbanCardWrapper.Effort = KnbnCard.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
			                kanbanCardWrapper.SchedulingModeId = KnbnCard.leankor__ScheduleModes__r[0].Id;
                            //Changes : Check constraint setting enable or not.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                kanbanCardWrapper.ConstraintType = (KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c)) ? KnbnCard.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : '';
                                kanbanCardWrapper.ConstraintDate = (KnbnCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null) ? KnbnCard.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                            }
                            //kanbanCardWrapper.ReadOnly = KnbnCard.leankor__ScheduleModes__r[0].leankor__ReadOnly__c;
			            }
			            if(KnbnCard.leankor__Kanban_Card_Baselines__r.size()>0){
			                kanbanCardWrapper.BaselineStartDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__StartDateTime__c;
			                kanbanCardWrapper.BaselineEndDate = KnbnCard.leankor__Kanban_Card_Baselines__r[0].leankor__DueDateTime__c;                       
			            } 
                        //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar.
				        kanbanCardWrapper.Monday = KnbnCard.leankor__Monday__c;
                        kanbanCardWrapper.Tuesday = KnbnCard.leankor__Tuesday__c;
                        kanbanCardWrapper.Wednesday = KnbnCard.leankor__Wednesday__c;
                        kanbanCardWrapper.Thursday = KnbnCard.leankor__Thursday__c;
                        kanbanCardWrapper.Friday = KnbnCard.leankor__Friday__c;
                        kanbanCardWrapper.Saturday = KnbnCard.leankor__Saturday__c;
                        kanbanCardWrapper.Sunday = KnbnCard.leankor__Sunday__c;
                        kanbanCardWrapper.weekCalendar = KnbnCard.leankor__WeekCalendar__c;
				        Map<String, FieldServiceUtilityController.RecordDetails> fslInfo = new Map<String, FieldServiceUtilityController.RecordDetails>(); 
				        // Geting the data for AG and his child cards
				        kanbanCardWrapper.children = (recordTypeMap.get(knbnCard.RecordTypeId).Name == 'FolderCard' ? leankor.GanttTaskBoard.childcardsRecursive(KnbnCard.Id, mapOfListCards, recordTypeMap, fslInfo) : new List<leankor.KanbanToGanttController.MasterContainer>()); 
	                    result.Activity = kanbanCardWrapper;                                                
                   }                       
                }
            }   
	            
            //cloning dependancy        
            List<CloneCardData> cloneCards = new List<CloneCardData>();
            cloneCards.add(clonecard);
            result.dependencyList = cloneDependency(newClonedKanbanCard, remoteKanbanCards.values(), cloneCards);

            User UserName = [Select Id,
                                    Name 
                                From User 
                                Where Id = :userinfo.getUserID()];
            string someJSONData = '{"oldFolderId" : "'+oldFolderId+'","valueStreamId" :"'+ clonecard.BoardId+'","newFolderId" :"'+ newfolderId +'"}';
            try {
                leankor.RealTimeController.KanbanStateChange(clonecard.BoardId, 'CloneGanttTask', sessionId, someJSONData);
            } catch (Exception e){
                System.debug('ERROR: while : broadcasting ' + e.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage());
            }
            
            result.ResourceAssignmentData = leankor.GanttTaskBoard.getResources(activityIds);			
			result.someJSONData = 'success';									
			result.newData = someJSONData;									
			result.folderId = newfolderId;	                              
                        
            return result;
        }
		
        @AuraEnabled
        public static CloneCardRecord cloneActivityGroup(CloneCardRecord cloneCard ,String sessionId){
            System.debug(cloneCard);
            System.debug(sessionId);
           // try {
                CloneCardData cloneCardData = new CloneCardData();
                cloneCardData.Activity = cloneCard.Activity;
                cloneCardData.boardId = cloneCard.BoardId;
                CloneCardData.cardIdlist = cloneCard.cardIdlist;
                cloneCardData.dependencyList = cloneCard.dependencyList;
                cloneCardData.ResourceAssignmentData = cloneCard.ResourceAssignmentData;
                cloneCardData.someJSONData = cloneCard.someJSONData;
                cloneCardData.newData = cloneCard.newData;
                cloneCardData.folderId = cloneCard.folderId;
                cloneCardData.isActivityGroup = cloneCard.isActivityGroup;
                cloneCardData.ItemType = cloneCard.itemType;
                
                cloneCardData = cloneActivityGroup(cloneCardData,sessionId);

                CloneCardRecord cloneCardRecord = new CloneCardRecord();
                cloneCardRecord.Activity = cloneCardData.Activity;
                System.debug(cloneCardRecord.Activity);
                cloneCardRecord.boardId = cloneCardData.BoardId;
                cloneCardRecord.cardIdlist = cloneCardData.cardIdlist;
                cloneCardRecord.dependencyList = cloneCardData.dependencyList;
                cloneCardRecord.ResourceAssignmentData = cloneCardData.ResourceAssignmentData;
                cloneCardRecord.someJSONData = cloneCardData.someJSONData;
                cloneCardRecord.newData = cloneCardData.newData;
                cloneCardRecord.folderId = cloneCardData.folderId;
                cloneCardRecord.isActivityGroup = cloneCardData.isActivityGroup;
                cloneCardRecord.ItemType = cloneCardData.itemType;

                return cloneCardRecord;
          /*  } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }*/
        }
							    
	    //this method for cloning card and perfrom insertion operation for AG   
	    //RS 28/11/2019 Removed allUserMap variable
	    //public static List<leankor__KanbanCard__c> createCard(List<leankor__KanbanCard__c> RemoteKanbanCards,CloneCardData clonecard,Map<Id,User> allUserMap)
	    public static List<leankor__KanbanCard__c> createCard(List<leankor__KanbanCard__c> RemoteKanbanCards,CloneCardData clonecard)
        {    	 
            // List<String> NewKanbanCards=new List<String>();
            List<realTimeController.Kanban> NewKanbanCards= new List<realTimeController.Kanban>();
            Integer i=1;	 	 	
            Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();

            for(leankor__KanbanCard__c RemoteKanban : RemoteKanbanCards){
                leankor.RealTimeController.Kanban NewKanban = new leankor.RealTimeController.Kanban();
                NewKanban.Id = RemoteKanban.Id;
                // yj : 06 Nov. 2017 checking user is active or not. No Need to add code here
                //NewKanban.OwnerId = allUserMap.get(RemoteKanban.OwnerId).IsActive ? RemoteKanban.OwnerId : UserInfo.getUserId();
                //NewKanban.OwnerId = allUserMap.containsKey(RemoteKanban.OwnerId) ? UserInfo.getUserId() : RemoteKanban.OwnerId;
                // yj : 06 Nov. 2017 
                NewKanban.OwnerId = RemoteKanban.OwnerId;                           
                NewKanban.UrlLink =RemoteKanban.leankor__UrlLink__c;
                NewKanban.GUID = RemoteKanban.Id+'-'+system.now().gettime()+i;
                NewKanban.Title= RemoteKanban.leankor__Title__c;
                NewKanban.Name = RemoteKanban.Name;
                NewKanban.Top = RemoteKanban.leankor__Top__c;
                NewKanban.Bottom = RemoteKanban.leankor__Bottom__c;
                NewKanban.Left = RemoteKanban.leankor__Left__c;
                NewKanban.Width = RemoteKanban.leankor__Width__c;
                NewKanban.Height = RemoteKanban.leankor__Height__c;
                NewKanban.X = RemoteKanban.leankor__X__c;
                NewKanban.Y = RemoteKanban.leankor__Y__c;
                NewKanban.ValueStream = clonecard.BoardId;
                NewKanban.TemplateID = RemoteKanban.leankor__KanbanCardTemplate__c;
                NewKanban.point = RemoteKanban.leankor__Point__c;
                NewKanban.EffortRemaining = integer.valueof(RemoteKanban.leankor__EffortRemaining__c);
                NewKanban.EstimatedDuration = RemoteKanban.leankor__EstimatedDuration__c;
                NewKanban.Color = RemoteKanban.leankor__Color__c;
                //NewKanban.JSONDefinition = RemoteKanban.leankor__JSONDefinition__c;
                //NewKanban.JSONData = RemoteKanban.leankor__JSONData__c;                        
                NewKanban.CardID = RemoteKanban.leankor__CardID__c; 
                NewKanban.AcceptanceCriteria = RemoteKanban.leankor__AcceptanceCriteria__c; 
                NewKanban.DueDate = RemoteKanban.leankor__DueDateTime__c;
                NewKanban.StartDate = RemoteKanban.leankor__StartDateTime__c;
                NewKanban.DurationUnits = RemoteKanban.leankor__DurationUnits__c;
                NewKanban.Priority = Integer.ValueOF(RemoteKanban.leankor__Priority__c); 
                NewKanban.HarveyBall = String.ValueOF(RemoteKanban.leankor__PercentComplete2__c);                                                         
                NewKanban.DateColor = RemoteKanban.leankor__DateColor__c; 
                NewKanban.Description = RemoteKanban.leankor__DescriptionLong__c;
                NewKanban.ValueStreamCardLink =  RemoteKanban.leankor__ValueStreamCardLink__c; 
                NewKanban.ValueStreamLinkID = RemoteKanban.leankor__ValueStreamLink__c; 
                NewKanban.Account = RemoteKanban.leankor__Account__c;
                NewKanban.Contact = RemoteKanban.leankor__Contact__c;
                NewKanban.CaseID = RemoteKanban.leankor__Case__c;                           
                NewKanban.Opportunity = RemoteKanban.leankor__Opportunity__C;
                NewKanban.BoardType = RemoteKanban.leankor__valuestream__r.leankor__boardtype__c;
                NewKanban.OnBudget = RemoteKanban.leankor__OnBudget__c;
                NewKanban.OnQuality = RemoteKanban.leankor__OnQuality__c;
                NewKanban.OnTime = RemoteKanban.leankor__OnTime__c; 
                NewKanban.Order = (RemoteKanban.leankor__Order__C == null ? 0 : Integer.ValueOF(RemoteKanban.leankor__Order__c)); 
                NewKanban.isAtRisk = RemoteKanban.leankor__IsAtRisk__c;
                NewKanban.isOnHold = RemoteKanban.leankor__IsOnHold__c;
                // checking for recordtype of card
                if(RemoteKanban.RecordType.Name == 'ActivityCard')
                {
                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                }else if(RemoteKanban.RecordType.Name == 'MileStoneCard')
                {
                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                }else if(RemoteKanban.RecordType.Name == 'FolderCard')
                {
                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                    NewKanban.Order = NewKanban.Order + 0.1;	                
                }				         
                NewKanban.schedulemodeList = RemoteKanban.leankor__ScheduleModes__r;
                NewKanban.resourceAssignmentList = RemoteKanban.leankor__ResourceAssignments__r;
                NewKanban.checkcloneProject = 'StopOriginalkanbanCardUpdate';                      
                //cloning harveyballdonedate  
                //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for impelementing constraint feature for clone card
                NewKanban.HarveyBallDoneDate = RemoteKanban.leankor__HarveyBallDoneDate__c;                  
                NewKanban.PromiseCompletionDate = RemoteKanban.leankor__PromiseCompletionDate__c;                  
                //Changes : Check Constraint setting is enable of not.
                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    for (leankor__ScheduleMode__c scheduleMode : RemoteKanban.leankor__ScheduleModes__r) {
                        NewKanban.ConstraintDate =  (ScheduleMode.leankor__ConstraintDateTime__c != null)?ScheduleMode.leankor__ConstraintDateTime__c : null;
                        NewKanban.ConstraintType =  (ScheduleMode.leankor__ScheduleConstraint__r != null)?scheduleConstraints.get(ScheduleMode.leankor__ScheduleConstraint__r.leankor__Type__c).Id:null;                                
                    }
                }
                if(kanbaCardIdandFields.size()>0){
                    if(kanbaCardIdandFields.containsKey(RemoteKanban.Id)){
                        
                        NewKanban.kanbanCustomField = kanbaCardIdandFields.get(RemoteKanban.Id);
                        NewKanban.kanbanCustomField.Id = null;
                    }
                }
                //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar.
                NewKanban.Monday = RemoteKanban.leankor__Monday__c;
                NewKanban.Tuesday = RemoteKanban.leankor__Tuesday__c;
                NewKanban.Wednesday = RemoteKanban.leankor__Wednesday__c;
                NewKanban.Thursday = RemoteKanban.leankor__Thursday__c;
                NewKanban.Friday = RemoteKanban.leankor__Friday__c;
                NewKanban.Saturday = RemoteKanban.leankor__Saturday__c;
                NewKanban.Sunday = RemoteKanban.leankor__Sunday__c;
                NewKanban.weekCalendar = RemoteKanban.leankor__WeekCalendar__c;

                // Date : 22/10/19 using wrapper class instance instead of Serialization.              
                //NewKanbanCards.add(JSON.Serialize(NewKanban));
                NewKanbanCards.add(NewKanban);
                i++;
            }
            //RS 28/11/2019 Removed allUserMap variable   
            //return leankor.realTimeController.createKanbanCard(clonecard.BoardId,NewKanbanCards,true,allUserMap);
            return leankor.realTimeController.createKanbanCard(clonecard.BoardId,NewKanbanCards,true);	    	     							   	   	                        	
	    }
        
        

    public static List<leankor.RealTimeController.Dependency> cloneDependency(List<leankor__KanbanCard__c> kanbanlist,
                                                                        List<leankor__KanbanCard__c> RemoteKanbanCards,
                                                                        List<CloneCardData> clonecard) {
        //Check CRUD / FLC behavior   
		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
		if (
			!dependencyBehaviour.isAccessible() ||
			!dependencyBehaviour.isCreateable()
		) {
			System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior

        List<String> boardIds = new List<String>();
        for (CloneCardData data : clonecard) {
            boardIds.add(String.escapeSingleQuotes(data.BoardId));
        }

	        //Start of clone Dependency.
	        Map<String,String> mapKanbanCard = new Map<String,String>();       
	        List<leankor__Dependency__c> DependencyList = new List<leankor__Dependency__c>();        
        List<leankor__Dependency__c> DependList = [SELECT Id,
                                                        leankor__GUID__c,
                                                        leankor__ValueStream__c,
                                                        leankor__LagLead__c,
                                                        leankor__LagLeadUnit__c,
                                                        leankor__KanbanCard__c,
	        										    leankor__Predecessor__c,
                                                        leankor__Predecessor__r.leankor__ValueStream__c,
	        										    leankor__PredecessorType__c,leankor__Successor__c,
                                                        leankor__Successor__r.leankor__ValueStream__c,
	        										    leankor__SuccessorType__c 
                                                    FROM leankor__Dependency__c 
                                                    WHERE (leankor__Predecessor__c IN: RemoteKanbanCards 
                                                            OR leankor__Successor__c IN: RemoteKanbanCards) 
                                                        AND leankor__Predecessor__r.leankor__ValueStream__c IN: boardIds 
                                                        AND leankor__Successor__r.leankor__ValueStream__c IN: boardIds
                                                    LIMIT 9999]; 
        
	        // maping new kanban card ID with old kanban card ID
        if (DependList.size() > 0) {
            for (leankor__KanbanCard__c kanban : kanbanlist) { 
		            String oldKanbanID = (kanban.leankor__GUID__C).SubStringBefore('-');
		            mapKanbanCard.put(oldKanbanID, kanban.Id);
		        }
	        
            for (leankor__Dependency__c dp : DependList) {
                if ((mapKanbanCard.ContainsKey(dp.leankor__Successor__c)) || (mapKanbanCard.ContainsKey(dp.leankor__Predecessor__c))) {
	                    leankor__Dependency__c d = new leankor__Dependency__c(
	                    leankor__GUID__c = dp.Id+'-'+System.Now().getTime()+'-d', // Need to make dynamic GUID.
	                    leankor__ValueStream__c = dp.leankor__Predecessor__r.leankor__ValueStream__C,
	                    leankor__Predecessor__c =  (mapKanbanCard.ContainsKey(dp.leankor__Predecessor__c) ? mapKanbanCard.get(dp.leankor__Predecessor__c) : dp.leankor__Predecessor__c),
	                    leankor__Successor__c = (mapKanbanCard.ContainsKey(dp.leankor__Successor__c) ? mapKanbanCard.get(dp.leankor__Successor__c) : dp.leankor__Successor__c),
	                    leankor__SuccessorType__c = dp.leankor__SuccessorType__c,
	                    leankor__LagLead__c = dp.leankor__LagLead__c,
						leankor__LagLeadUnit__c = dp.leankor__LagLeadUnit__c
					  //leankor__LagLeadDuration__c = dp.leankor__LagLeadDuration__c
	                    );
	                    DependencyList.add(d);
	                }
	            }

            try {
	                Database.insert(DependencyList,false);
            } catch(Exception ex) {
	                System.debug('Error : '+ex.getMessage());
                    //25/04/2023 : We are Throwing Exception
			        throw new Util.LeanException('ERROR:' + ex.getMessage());
	            }
	        }
	        
	           List<leankor.RealTimeController.Dependency> jsonDependencyList = new List<leankor.RealTimeController.Dependency>();
        for (leankor__Dependency__c Dep : DependencyList) {
			     leankor.RealTimeController.Dependency Dependency = new leankor.RealTimeController.Dependency();
				 String Type = Dep.leankor__SuccessorType__c;
				 Dependency.Id = Dep.leankor__GUID__c;
				 Dependency.FromId = Dep.leankor__Predecessor__c;
				 Dependency.FromVSID = Dep.leankor__ValueStream__C;
				 Dependency.To = Dep.leankor__Successor__c;
				 Dependency.ToVSID = Dep.leankor__ValueStream__C;
				 Dependency.Lag = Integer.valueof(Dep.leankor__LagLead__c);
				 Dependency.LagUnit = Dep.leankor__LagLeadUnit__c;
				 Dependency.Type = (Type == 'Start To Start' ? 0 : (Type == 'Start To Finish' ? 1 : (Type == 'Finish To Start' ? 2 : 3)));
			  // Dependency.LagLeadDuration = Dep.leankor__LagLeadDuration__c;
				 
				 jsonDependencyList.add(Dependency);		   
			   }	       	        
	        return jsonDependencyList;	        
	        //End of clone Dependency.                    				  
	    }	    
		public static List<leankor__KanbanCard__c> linkKanbanCards(List<leankor__KanbanCard__c> kclist1)
		{        
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
            
            Integer updatedCards = 0;        
	        leankor__KanbanCard__c emptyKanbanCard = new leankor__KanbanCard__c();	 	 										       			
	        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();           			
			for (leankor__KanbanCard__c newKanbanCard: kclist1)
			{
				String kanbanCardGUID = (newKanbanCard.leankor__GUID__c).SubStringBefore('-');
				if (String.isNotBlank(kanbanCardGUID))
				{
					targetKanbanCards.put(kanbanCardGUID, newKanbanCard);
				}
			}	            
			for (leankor__KanbanCard__c newKanbanCard : kclist1)
	 		{ 				
		    	// Is card's project board the same as card's link project board?
		    	if(String.isNotBlank(newKanbanCard.leankor__ValueStreamCardLink__c))
				{
					leankor__KanbanCard__c targetKanbanCard = targetKanbanCards.get(newKanbanCard.leankor__ValueStreamCardLink__c);
	                if (targetKanbanCard != emptyKanbanCard && targetKanbanCard != null)
	                { 							 					
	 					newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCard.Id;
	 					newKanbanCard.leankor__ValueStreamLink__c = newKanbanCard.leankor__ValueStream__c;
						updatedCards++;
	                }
				} 				
	 		}	  		
			if (updatedCards > 0)
		 	{
		 		update kclist1;		 				 			 		
		 	}				  		
	 		return updatedCards > 0 ? kclist1 : new List<leankor__KanbanCard__c>();
		}	    	       
				
		//getting all Task of kanban board cards on calender view due to increase performance
		//14.sep.2017
		@RemoteAction
		global static list<leankor.realTimeController.TaskData> getTaskDataOnCV(list<String> kclist)
		{
            for(String card : kclist){
                if (String.isNotBlank(card) && Util.getSObjectName(card) != 'leankor__KanbanCard__c') {
                    System.debug('Error: Invalid input');
                    throw new Util.LeanException('Error: Invalid input');
                }
            }
			List < leankor.realTimeController.TaskData > taskList = new List < leankor.realTimeController.TaskData > ();
		    //SS 19.03.2018
         	//Modified query for retriving task records including archived records
		    List<Task> gettaskList = [SELECT 
                                            Subject,
                                            LastModifiedDate,
                                            Owner.Name,
                                            CreatedDate,
                                            ActivityDate,
                                            Description,
		    						        Id,
                                            OwnerId,
                                            status,
                                            Priority,
                                            WhatId 
                                        FROM Task 
                                        WHERE (WhatId IN: kclist 
                                                AND What.Type = 'leankor__KanbanCard__c' 
                                                AND IsDeleted = false)
                                        LIMIT 49999 All Rows];
		   
			Map<Id,Integer> map_feed = leankor.KanbanController.getTaskChatterCounts(gettaskList);
			
			for(Task t : gettaskList)
			{ 
				leankor.realTimeController.TaskData taskInstance = new leankor.realTimeController.TaskData(); 
				
				taskInstance.Subject = t.Subject;
				taskInstance.Id = t.Id;	
				taskInstance.Priority = t.Priority;	
				taskInstance.OwnerId  = t.OwnerId;	
				taskInstance.Description = t.Description;	
				taskInstance.WhatId = t.WhatId;	
				taskInstance.status = t.status;	
				taskInstance.OwnerName = t.Owner.Name;
				taskInstance.CreatedDate = String.valueOfGmt(t.CreatedDate);
				taskInstance.ItemType='Task';				
				taskInstance.leaf = true;
				taskInstance.TaskChatterCount = map_feed.get(t.Id) == null ? 0 : map_feed.get(t.Id);
				
				Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
				Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);                                                 
			
				taskInstance.StartDate = Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01);
				taskInstance.DueDate = Datetime.newInstanceGmt(tempActivityDate.year(),tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01);
				
				taskList.add(taskInstance);
			}
			return taskList; 
		}
		//14.sep.2017    	
		/*
		@RemoteAction
		global static Set<String> getMiniature(ID VSID)
		{
			List<leankor__KanbanCard__c> KcList = [select Id from leankor__KanbanCard__c where leankor__ValueStream__c =: VSID  Limit 49999];
                
           Set<String> listofminiature = new Set<String>();
           for(leankor__KanbanCard__c kc  : [SELECT leankor__ValueStreamCardLink__c FROM leankor__KanbanCard__c where leankor__ValueStreamCardLink__c IN :KcList AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
           																							AND leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
           																							AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
           																							AND leankor__isRecordDeleted__c = false limit 49999]){
            listofminiature.add(kc.leankor__ValueStreamCardLink__c);
           
           
           }
           return listofminiature;		
			
		}
		*/
        //SS 07.03.2018 
		//Added for lightning Project Board action on KanbanCard layout
        //09/09/2021 : Changes Public method to Global for release update.
		@AuraEnabled
	    global static String getProjectBoardUrl(String kanbanCardId) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
		   leankor__KanbanCard__c kb=[SELECT 
                                        leankor__BoardType__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c
                                    FROM leankor__KanbanCard__c
                                    WHERE id =:kanbanCardId LIMIT 1];
		   String visualForcePageName='';
		   String pageUrl='';
		   if(kb.leankor__BoardType__c=='UberBoard')
		   {
		   		visualForcePageName='leankor__GanttView';
		   		pageUrl= '/apex/' + visualForcePageName + '?fid='+kb.leankor__ValueStream__r.leankor__ProjectRoom__c + '&btype=projectgantt&Id=' + kb.leankor__ValueStream__c + '&cardid=' + kanbanCardId+'&isLightning=true';
		   }
		   else
		   {
		       if(kb.leankor__BoardType__c=='Whiteboard' ||kb.leankor__BoardType__c=='DashBoard')
			   {
			   		visualForcePageName='leankor__VisualKanban';
			   }
			   else if(kb.leankor__BoardType__c=='Kanban Board' || kb.leankor__BoardType__c=='Plan Board')
			   {
			   		visualForcePageName='leankor__KanbanBoard';
			   }
			   else if(kb.leankor__BoardType__c=='Portfolio View')
			   {
			   		visualForcePageName='leankor__PortfolioView';
			   }
			   else if(kb.leankor__BoardType__c=='Card Hierarchy')
			   {
			   		visualForcePageName='leankor__CardHierarchy';
			   }
			   	pageUrl='/apex/' + visualForcePageName + '?Id=' + kb.leankor__ValueStream__c + '&cardid=' + kanbanCardId+'&isLightning=true';
		   }
	       return pageUrl;
	    }              
	    /*------------------------------------------------------------
	    Author:         Rahul Solanki
	    Company:        Leankor
	    Description:    Get url of milestone 
	    Inputs:         -
	    Returns:        string
	    ------------------------------------------------------------*/
        Public Static String getMilestoneCardUrl(){    
		    leankor__KanbanCard__c  kanbanCards = new leankor__KanbanCard__c();
		    String milestoneURL;
		    try{
                /*
                *Modified By :Ashutosh Gour
                *Modification : Modification for making SOQL selective and remove negative selection.
                */
		       /* kanbanCards= [Select Id,leankor__BoardType__c,Recordtype.Name,leankor__ValueStream__c,leankor__ProjectRoom__c,
		        					leankor__ValueStream__r.leankor__ProjectRoom__c
		                            From leankor__KanbanCard__c where id = : milestoneObj.Id 
		                            AND RecordType.Name = 'MileStoneCard' AND leankor__Valuestream__c != null Limit 1];                   
		         */
                for (leankor__KanbanCard__c kc : [ SELECT 
                                                    Id,
                                                    leankor__BoardType__c,
                                                    Recordtype.Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ProjectRoom__c,
		        					                leankor__ValueStream__r.leankor__ProjectRoom__c
		                                        FROM leankor__KanbanCard__c 
                                                WHERE id = : milestoneObj.Id 
		                                            AND RecordType.Name = 'MileStoneCard']) {
                    if (kc.leankor__Valuestream__c != null ) {
                        kanbanCards = kc;
                        break;
                    }
                }
		        String baseUrl = 'https://' + DomainCreator.getOrgMyDomainHostname()
                ;          
		        ApexPage Pages = [SELECT NamespacePrefix FROM ApexPage WHERE Name = 'GanttView' limit 1];
		        string namespace = Pages.NamespacePrefix;		                  
		       
		        String visualforcepage = namespace + '__VisualKanban';                             
		        String boardType  = kanbanCards.leankor__BoardType__c;
		        
		        if(boardType== 'Kanban Board'){
		            visualforcepage = namespace + '__CalenderView';
		        }else if(boardType== 'UberBoard'){    
		            visualforcepage = namespace + '__GanttView'; 
		        }           
		        
		        if (visualforcepage == namespace + '__GanttView') { 
		          milestoneURL= baseUrl +'/apex/'+ visualforcepage + '?fid='+kanbanCards.leankor__ValueStream__r.leankor__ProjectRoom__c +'&btype=projectgantt&Id='+kanbanCards.leankor__ValueStream__c+'&cardid='+kanbanCards.Id+'';
		        }else {
		          milestoneURL= baseUrl +'/apex/'+ visualforcepage + '?Id='+kanbanCards.leankor__ValueStream__c +'&isFiltered=false'+'&cardid='+kanbanCards.Id+'';
		        }     
		         
		        return milestoneURL;		         
		    
		    }catch(Exception e){
		        system.debug(e);
		        //return milestoneURL;   
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage()); 
		    }
	 
		}
		/*------------------------------------------------------------
	    Author:         Rahul Solanki
	    Company:        Leankor
	    Description:    Get TimeZone of org 
	    Inputs:         -
	    Returns:        string
	    ------------------------------------------------------------*/
		Public Static String getOrgTimeZone(){
			/****SS 10.07.2018  <--Start -->
				Modified for getting Organization time zone with GMT value
			****/
			//TimeZone tz =  UserInfo.getTimeZone();
			Organization orgInfo = [SELECT TimeZoneSidKey FROM Organization LIMIT 1];
			TimeZone orgTimeZone = TimeZone.getTimeZone(orgInfo.TimeZoneSidKey);
			Long miliSecondValue = orgTimeZone.getOffset(DateTime.Now()); 
			//DateTime orgOffsetTime  = DateTime.valueOf(miliSecondValue);
			String gmtValue;
			DateTime dbDateTime = milestoneObj.DueDateTime__c!=null?milestoneObj.DueDateTime__c:System.now();
			/*if(orgOffsetTime.timeGmt().hour()>12)
			{
				Time endTime =  Time.newInstance(23, 59, 59, 999);
				Time offsetTime = orgOffsetTime.TimeGMt();
				Integer tempHour = (endTime.hour()- offsetTime.hour());
				Integer tempMin = (endTime.minute()-offsetTime.minute());
				
				Time tempTime  = Time.newInstance(tempHour,tempMin,0,0);
				Time tempGmtTime  = tempTime.addMinutes(1);
				DateTime dtOne = DateTime.newInstanceGmt(Date.Today(),tempGmtTime);
				gmtValue = '-'+dTone.formatGMT('HH:mm');
			}*/
			
			if(miliSecondValue < 0)
			{
				miliSecondValue = miliSecondValue*-1;
				DateTime orgDateTime  = DateTime.valueOf(miliSecondValue);
				gmtValue = '-'+String.valueOf(orgDateTime.formatGMT('HH:mm'));
			}
			else{
				DateTime orgDateTime  = DateTime.valueOf(miliSecondValue);
				gmtValue = '+'+String.valueOf(orgDateTime.formatGMT('HH:mm'));
			}
			//return string.ValueOf(tz.getDisplayName() + ' (' + UserInfo.getTimeZone() + ')');
			return String.ValueOf(' '+dbDateTime.format('EEE, MMM d yyyy HH:mm:ss',orgTimeZone.getId())+' (GMT '+gmtValue+')'+' '+orgTimeZone.getDisplayName() + ' (' + orgTimeZone + ')');
			
			/****SS 10.07.2018  <--Start -->
				Modified for getting Organization time zone with GMT value
			****/ 
		 }              
         
        //09/09/2021 : Changes Public method to Global for release update.
        @AuraEnabled(cacheable=true)
        global static Map<String, String> getLabelsForConsumers(String componentName) {
            Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', componentName};
            Map<String, String> returnMap = new Map<String, String>();  

            returnMap = LabelProvider.getLabelsForConsumers(consumers);
            return returnMap;
        }
        
       /* public PageReference redirect() {
            PageReference result;
            String thisUrl = ApexPages.currentPage().getUrl();
            if(thisUrl.containsIgnoreCase('/leankor__')){
                thisUrl = thisUrl.split('/leankor__')[1];
            } else if(thisUrl.containsIgnoreCase('apex/')){
                thisUrl =thisUrl.split('apex/')[1];
            }
            String[] pageUrlSplitId = thisUrl.split('\\?');
            if(pageUrlSplitId[0].equals('CardHierarchy')){
               result = Page.leankor__CardHierarchyView;
                Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
                result.getParameters().put('Id', pageParameters.get('Id'));
                result.getParameters().put('cardid', pageParameters.get('cardid'));
                result.getParameters().put('isLightning', pageParameters.get('isLightning'));
                result.setRedirect(true);
            }

            if(pageUrlSplitId[0].equals('CalenderView')){
                result=Page.leankor__CalendarView;
                Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
                result.getParameters().put('Id', pageParameters.get('Id'));
                result.getParameters().put('isFiltered', pageParameters.get('isFiltered'));
                result.getParameters().put('isLightning', pageParameters.get('isLightning'));
                result.setRedirect(true);
            }
            return result;
        }*/
      /*  public PageReference redirect() {
            String thisUrl = ApexPages.currentPage().getUrl();
            System.debug('thisUrl => '+thisUrl);
            if(thisUrl.containsIgnoreCase('/leankor__')){
                thisUrl = thisUrl.split('/leankor__')[1];
            } else if(thisUrl.containsIgnoreCase('apex/')){
                thisUrl =thisUrl.split('apex/')[1];
            }
            String[] pageUrlSplitId = thisUrl.split('\\?');
            if(pageUrlSplitId[0].equals('CardHierarchy')){
                String thisUrlValue = ApexPages.currentPage().getUrl();
                String[] pageUrlSplitIdValue = thisUrlValue.split('cardid=');
                String test = '/apex/leankor__CardHierarchyView?cardid='+pageUrlSplitIdValue[1];
                return new PageReference(test);
            }

        
            if(pageUrlSplitId[0].equals('CalenderView')){
                String thisUrlValue = ApexPages.currentPage().getUrl();
                String[] pageUrlSplitIdValue = thisUrlValue.split('Id=');
            return new PageReference('/apex/leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);
            }
           return null;
        }*/

        public PageReference redirectToNewCV(){
            String networkId = Network.getNetworkId();
            if(networkId != null){
                //14/Jan/2023 : Changes added for fixing the issue of Package not installing on Org where digital Experience is not enabled.
                sObject tempNetwork = Database.query('Select Id, UrlPathPrefix From Network Where Id = :networkId Limit 1');
                String thisUrlValue = ApexPages.currentPage().getUrl();
                System.debug('thisUrlValue '+thisUrlValue);
                String[] pageUrlSplitIdValue = thisUrlValue.split('Id=');
                System.debug('tempNetwork '+tempNetwork.get('UrlPathPrefix'));
                System.debug('## '+tempNetwork.get('UrlPathPrefix')+'leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);
                return new PageReference(tempNetwork.get('UrlPathPrefix')+'leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);

                //NetWork network = [Select Id, UrlPathPrefix From Network Where Id = : Network.getNetworkId() Limit 1];
                //String thisUrlValue = ApexPages.currentPage().getUrl();
                //String[] pageUrlSplitIdValue = thisUrlValue.split('Id=');
                //return new PageReference(network.UrlPathPrefix+'leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);
            }else{
                String thisUrlValue = ApexPages.currentPage().getUrl();
                System.debug('thisUrlValue =>'+thisUrlValue);
                String[] pageUrlSplitIdValue = thisUrlValue.split('Id=');
                System.debug('result=> '+'/apex/leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);
                return new PageReference('/apex/leankor__CalendarView?Id='+pageUrlSplitIdValue[1]);
        	}
        }
        public PageReference redirectToNewCH(){
            String thisUrlValue = ApexPages.currentPage().getUrl();
            System.debug('thisUrlValue'+thisUrlValue);
            String[] pageUrlSplitIdValue = thisUrlValue.split('cardid=');
            String test = '/apex/leankor__CardHierarchyView?cardid='+pageUrlSplitIdValue[1];
            System.debug('test =>'+test);
            return new PageReference(test);
        }

       
}