/*---------------------------------------------------------------
Copyright 2012-2018 Leankor. All rights reserved
Author:         Rahul Solanki
Company:        Leankor
Description:    Helper class for realTimeController
-----------------------------------------------------------------*/
public without sharing class RealTimeControllerHelper {

    public static List<String> resoruceList;
    private  static List<Leankor__Portfolio__c> globalportfolioList = new List<Leankor__Portfolio__c>();
    public static Set<String> MASTERCONTAINERTYPEFILTERS_CONST = new Set<String>{'Archive', 'Backlog', 'Regular'};
    public static Set<String> BOARDTYPEFILTERS_CONST = new Set<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
    //29/07/2022 : Changes for showField on CH for Task.
	public static Boolean tempTask = false;
    
    // wrapper class for manageStateChange method
    public class ManageStateChangeWrapper {        
        public String linkedCardVerb = '';
        public String linkedVS = '';
        public String oldParentKC = '';
        public Boolean updateparent = false;
        public Boolean oldParent = false;
        public Id valueStreamID;
        public String verb;
        public List < String > listOfJson;
        public String sessionID;
        public leankor__Subscriber__c subscribers;
        public List < leankor__ScheduleMode__C > scheduleMode;
        public leankor__ResourceAssignment__c resourceAssignment;
        public List < Task > listOfUpdateTask;
        public List < EntitySubscription > entitySubscriptions;
        public List < leankor__KanbanCard__c > miniature;
        public EntitySubscriptionWrapper entitySubscriptionWrapperInstance;
        public List < leankor__kanbancard__c > kanbanCards;
        public List < Id > activityIds = new List < Id > ();
        public List < FeedItem > feeds;        
        public realTimeController.StateChangePackage stateChangePackageInstance;
        public List < leankor__ResourceAssignment__c > resourceAssignmentList;
        public Map < String,Schema.SObjectField > fieldMapKanbanCard;
        public String someJSONData;
        public Boolean leanFalse;
        public leankor__kanbancard__c kanbanCard;
        public List < leankor__Subscriber__c > listOfSubscribers;
        public Boolean isUpdateParentOnMove; // Tilak Raj Mahale:19.06.2020 - To update the parent records on the move.
    }


    // Rahul Solanki - Method for Move or Update KanbanCard
    public static ManageStateChangeWrapper moveOrUpdateKanbanCard(ManageStateChangeWrapper mscWrapperInstance) {
        String defaultRecordType;
        String milestoneCardID;
        String folderCardID; 
               
        // Declared the sObject to avoid null reference error
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        List < leankor__KanbanCard__c > kanbanCardList = new List < leankor__KanbanCard__c > ();         
               
        leankor.RealTimeController.StateChangePackage stateChangePackageInstance = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(mscWrapperInstance.SomeJSONData, realTimeController.StateChangePackage.class);
        mscWrapperInstance.stateChangePackageInstance = stateChangePackageInstance;               
        
        List<RecordType> cardRecordType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'leankor__Kanbancard__c'];

        for (RecordType rt: cardRecordType) {
            if (rt.Name == 'ActivityCard') {
                defaultRecordType = rt.ID;
            } else if (rt.Name == 'MileStoneCard') {
                milestoneCardID = rt.ID;
            } else if (rt.Name == 'FolderCard') {
                folderCardID = rt.ID;
            }
        }

        kanbanCard = [Select 
                            Id, 
                            Recordtype.Name, 
                            (Select 
                                    Id 
                                From leankor__PredecessorDependencies__r
                            ), 
                            leankor__TemplateBoard__c, 
                            leankor__BoardType__c,
                            leankor__MasterContainer__r.leankor__Type__c, 
                            leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__AutoAssignResource__c,
                            leankor__ValueStreamLink__c, 
                            leankor__ValueStreamCardLink__c, 
                            leankor__valuestream__r.leankor__SevenDayWorkWeek__c,
                            leankor__MasterContainer__c, 
                            leankor__Swimlane__c, 
                            leankor__Zone__c, 
                            leankor__CardID__c, 
                            leankor__DueDateTime__c,
                            leankor__GUID__c, 
                            Name, 
                            OwnerID, 
                            leankor__StartDate__c, 
                            leankor__StartDateTime__c, 
                            leankor__KanbanCardTemplate__c,
                            leankor__PromiseCompletionDate__c, 
                            leankor__HarveyBallDoneDate__c, 
                            leankor__PercentComplete2__c, 
                            leankor__Top__c, 
                            leankor__Left__c, 
                            leankor__ZoneGUID__c, 
                            leankor__ValueStream__c, 
                            leankor__ValueStream__r.Name,
                            leankor__ValueStream__r.leankor__IsRecordDeleted__c,
                            leankor__DueDate__c, 
                            leankor__Valuestream__r.leankor__TaskDatecheck__c, 
                            leankor__ProjectRoom__c,
                            leankor__IsExternallyDependent__c,
                            leankor__IsAtRisk__c, 
                            leankor__IsOnHold__c,
                            leankor__ValueStreamCardLink__r.RecordType.Name,
                            leankor__EstimatedDuration__c,
                            leankor__DurationUnits__c,
                            leankor__WeekCalendar__c,
                            leankor__Monday__c,
                            leankor__Tuesday__c,
                            leankor__Wednesday__c,
                            leankor__Thursday__c,
                            leankor__Friday__c,
                            leankor__Saturday__c,
                            leankor__Sunday__c
                        From leankor__KanbanCard__c 
                        Where leankor__GUID__c =: stateChangePackageInstance.GUID 
                        Limit 1];

        // If card is deleted
        if (String.isBlank(kanbanCard.Id)) {
            throw new GanttTaskBoard.LeanException('Card no longer exist. Please try again.');
        }

        List < leankor__Subscriber__c > listOfSubscribers = [Select Id, Name, leankor__KanbanCard__c, 
                                                            leankor__SubscriberID__c, leankor__Moved__c, leankor__PercentDone__c, 
                                                            leankor__CardPastDueDate__c, leankor__TaskPastDueDate__c, leankor__isTaskCompleted__c 
                                                            from leankor__Subscriber__c 
                                                            where leankor__KanbanCard__c = : kanbanCard.Id LIMIT 9999];

        mscWrapperInstance.kanbanCard = kanbanCard;
        mscWrapperInstance.stateChangePackageInstance = stateChangePackageInstance;
        mscWrapperInstance.listOfSubscribers = listOfSubscribers;

        // To create subscribers
        mscwrapperInstance.subscribers = createSubscriber(mscWrapperInstance);

        // To post chatter 
        mscwrapperInstance.feeds = postChatter(mscWrapperInstance);

        // To create KanbanCard object with all the updates it will just return KanbanCard object
        leankor__KanbanCard__c updateKanban = updateKanbanCardInstance(mscWrapperInstance);
        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
        if((updateKanban.leankor__StartDateTime__c != kanbanCard.leankor__StartDateTime__c || updateKanban.leankor__DueDateTime__c != kanbanCard.leankor__DueDateTime__c || updateKanban.leankor__DurationUnits__c != kanbanCard.leankor__DurationUnits__c || updateKanban.leankor__EstimatedDuration__c != kanbanCard.leankor__EstimatedDuration__c ) 
            && (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS == true) 
            && (stateChangePackageInstance.BoardType != 'UberBoard' || ProjectBoardCarousel.isConstraintRecalculateForActivityFromMyWork == true)
            && (leankor.RealTimeController.isConstraintRecalculateForChildCard == false)){
            updateKanban.leankor__IsConstraintRecalculate__c = true;
            leankor.RealTimeController.isConstraintRecalculateForChildCard = true;
            ProjectBoardCarousel.isConstraintRecalculateForActivityFromMyWork = false;
        }
        kanbanCardList.add(updateKanban); // added in List for builkify.

        if (stateChangePackageInstance.BoardType != 'UberBoard') {
            // This code is removing the Link between Child and Parent Card.
            List < leankor__KanbanCard__c > dataofLinkedCards = [SELECT 
                                                                    Id, 
                                                                    leankor__boardtype__c, 
                                                                    leankor__GUID__c, 
                                                                    leankor__Description__c, 
                                                                    leankor__ValueStreamCardLink__c, 
                                                                    leankor__ValueStreamLink__c 
                                                                FROM leankor__KanbanCard__c 
                                                                WHERE Id =: stateChangePackageInstance.Id 
                                                                LIMIT 1];
                                                                
            //Date :07/03/19 value of oldParent is  true when we are updating old parent.
            if (dataofLinkedCards[0].leankor__ValueStreamCardLink__c != NULL && dataofLinkedCards[0].leankor__ValueStreamCardLink__c != updateKanban.leankor__ValueStreamCardLink__c) {
                mscwrapperInstance.oldParent = true;
                mscwrapperInstance.oldParentKC = JSON.serialize(dataofLinkedCards);
                
            }
          
            // Tilak Raj Mahale: 19.06.2020 - Changes to update the parent card on move. 
            // Note*: mscWrapperInstance.isUpdateParentOnMove value updated in the updateKanbanCardInstance() method when this method called above to update the card record.
            if (updateKanban.leankor__ValueStreamCardLink__c != null && (mscWrapperInstance.verb == 'UpdateKanbanCard' || (mscWrapperInstance.verb == 'MoveKanbanCard' && mscWrapperInstance.isUpdateParentOnMove == true))) {
                mscWrapperInstance.updateparent = true;
    
            }
        }

        //  To create task
        mscWrapperInstance.listOfUpdateTask = updateTask(kanbanCard, stateChangePackageInstance);

        //yj-31.05.2017
        //----------------creating RA and SM when we convert milestone to activity
        if (stateChangePackageInstance.BoardType == 'UberBoard') {
            if (stateChangePackageInstance.ItemType == 'ActivityCard' && kanbanCard.RecordType.Name == 'MileStoneCard') {
                // To create scheduleMode
                //Pratiksha : 11/11/2021 : Changes for prevent Schedule mode record when Constraint setting is enable/disable.
              /*  if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS == false){
                    mscWrapperInstance.scheduleMode = CreateScheduleMode(kanbanCardList);
                }*/
                // To create ResourceAssignment
                if (kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__AutoAssignResource__c == true) {
                    mscWrapperInstance.resourceAssignment = createResourceAssignment(stateChangePackageInstance);
                }
            }
        }

        // Activity harvey status is updating
        if (Integer.valueof(kanbanCard.leankor__PercentComplete2__c) != Integer.valueof(stateChangePackageInstance.HarveyBall) && mscWrapperInstance.verb == 'UpdateKanbanCard') {
            mscWrapperInstance.activityIds.add(kanbanCard.Id);
        }

        if (stateChangePackageInstance.Boardtype != 'UberBoard') {
            if (stateChangePackageInstance.ValueStreamCardLink != null && stateChangePackageInstance.ValueStreamCardLink != '') {
                mscWrapperInstance.activityIds.add(stateChangePackageInstance.ValueStreamCardLink);
            }
        }
        
        // To send chatter when owner is changed
        mscWrapperInstance.feeds.addAll(ownerChangeChatter(mscWrapperInstance));

        if (stateChangePackageInstance.OwnerID != kanbanCard.OwnerID && stateChangePackageInstance.BoardType != 'UberBoard') {
            //updating RA onwer ID when we change onwer of kanban card
            mscWrapperInstance.activityIds.add(kanbanCard.Id);
            //Update RA of updated KanbanCard if owner is changed
            mscWrapperInstance.resourceAssignmentList = leankor.GanttTaskBoard.updateMultipleRA(new List<String>{kanbanCard.Id}, stateChangePackageInstance.OwnerID);
        }

        if (stateChangePackageInstance.TemplateID != updateKanban.leankor__KanbanCardTemplate__c) {
            mscWrapperInstance.entitySubscriptions = getEntitySubscription(stateChangePackageInstance);
        }

        // To create EntitySubscription
        mscWrapperInstance.entitySubscriptionWrapperInstance = createEntitySubscription(new List<leankor__KanbanCard__c> {updateKanban}, stateChangePackageInstance);
       
        // To delete miniature
        mscWrapperInstance.miniature = deleteMiniature(stateChangePackageInstance);
        mscWrapperInstance.kanbanCards = kanbanCardList;
        
        return mscWrapperInstance;    
    }

    
    // Rahul Solanki - Method for Move or Update zone
    public static List < leankor__Zone__c > moveOrUpdateZone(String someJSONData) {
        leankor.RealTimeController.StateChangePackage stateChangePackageInstance;
        List<leankor__Zone__c> zones = new List<leankor__Zone__c> ();
    
        try {
            stateChangePackageInstance = (realTimeController.StateChangePackage)JSON.deserialize(someJSONData, realTimeController.StateChangePackage.class);
    
            // Update zone if we get to this point without error
            leankor__Zone__c updateZone = new leankor__Zone__c (
                leankor__GUID__c = stateChangePackageInstance.GUID,
                leankor__Unit__c = stateChangePackageInstance.Unit,
                leankor__Title__c = stateChangePackageInstance.Title,
                Name = stateChangePackageInstance.Title,
                leankor__UrlLink__c = stateChangePackageInstance.URlLink,
                leankor__OpportunityStageName__c = stateChangePackageInstance.ZoneOpportunityStage,
                leankor__Top__c = stateChangePackageInstance.Top,
                leankor__Bottom__c = stateChangePackageInstance.Bottom,
                leankor__Left__c = stateChangePackageInstance.Left,
                leankor__Width__c = stateChangePackageInstance.Width,
                leankor__Height__c = stateChangePackageInstance.Height,
                leankor__X__c = stateChangePackageInstance.X,
                leankor__Y__c = stateChangePackageInstance.Y,
                leankor__ZoneMode__c = stateChangePackageInstance.ZoneMode,
                leankor__EntryFlowName__c = stateChangePackageInstance.EntryFlowName,
                leankor__ExitFlowName__c = stateChangePackageInstance.ExitFlowName,
                leankor__KanbanSequence__c = stateChangePackageInstance.KanbanSequence,
                leankor__ValueStreamLink__c = (stateChangePackageInstance.ValueStreamLinkID == '' ? null : stateChangePackageInstance.ValueStreamLinkID),
                leankor__ValueStreamCardLink__c = (stateChangePackageInstance.ValueStreamCardLink == '' ? null : stateChangePackageInstance.ValueStreamCardLink),
                leankor__DefaultWidth__c = stateChangePackageInstance.DefaultWidth,
                leankor__DefaultHeight__c = stateChangePackageInstance.DefaultHeight,
                leankor__CaseStatus__c = stateChangePackageInstance.ZoneStatus,
                leankor__CardsPerRow__c = stateChangePackageInstance.CardsPerRow,
                leankor__Help__c = stateChangePackageInstance.Help,
                leankor__Limit__c = stateChangePackageInstance.TaskLimit,
                leankor__Order__c = stateChangePackageInstance.Order,
                leankor__ParentZone__c = (stateChangePackageInstance.ParentZone != '' ? stateChangePackageInstance.ParentZone : null),
                leankor__Swimlane__c = (stateChangePackageInstance.Swimlane != '' ? stateChangePackageInstance.Swimlane : null)
            );

            zones.add(updateZone);

        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
    
        return zones;
    }


    // Rahul Solanki - Method for MoveMarker
    public static List <leankor__Marker__c> moveMarker(String someJSONData) {
        leankor.RealTimeController.Marker mcp;
        List<leankor__Marker__c> markers = new List<leankor__Marker__c>();
    
        try {
            mcp = (realTimeController.Marker)JSON.deserialize(someJSONData, realTimeController.Marker.class);
    
            // Update Marker if we get to this point without error
            leankor__Marker__c updateMarker = new leankor__Marker__c (
                leankor__GUID__c = mcp.GUID,
                leankor__GUID2__c = mcp.GUID,
                leankor__CmpID__c = mcp.CmpID,
                leankor__Top__c = mcp.Top,
                leankor__Bottom__c = mcp.Bottom,
                leankor__Left__c = mcp.Left,
                leankor__Width__c = mcp.Width,
                leankor__Height__c = mcp.Height,
                leankor__X__c = mcp.X,
                leankor__Y__c = mcp.Y,
                leankor__CSSLayout__c = mcp.CSSLayout,
                leankor__TextLabel__c = mcp.TextLabel,
                leankor__Type__c = mcp.Type,
                leankor__ZIndex__c = (mcp.ZIndex == null ? 120 : mcp.ZIndex),
                leankor__LockState__c = mcp.LockState,
                leankor__ValueStreamCardLink__c = (mcp.ValueStreamCardLink == '' ? null : mcp.ValueStreamCardLink),
                leankor__ValueStreamLink__c = (mcp.VSLink == '' ? null : mcp.VSLink),
                leankor__UrlLink__c = mcp.UrlLink
            );

            markers.add(updateMarker);

        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return markers;
    }


    // Rahul Solanki - Method for Move chart
    public static List < leankor__Chart__c > moveChart(String someJSONData) {
        leankor.RealTimeController.Chart mcp;
        List<leankor__Chart__c> charts = new List<leankor__Chart__c>();
    
        try {
            mcp = (leankor.RealTimeController.Chart)JSON.deserialize(someJSONData, realTimeController.Chart.class);
    
            // Update Chart if we get to this point without error
            // Date 25/02/19 id replace with Guid.
            leankor__Chart__c updateChart = new leankor__Chart__c (
                Name = mcp.Name,
                leankor__DeveloperName__c = mcp.DeveloperName,
                leankor__Filter__c = mcp.Filter,
                leankor__Format__c = mcp.Format,             
                // leankor__GUID__c = mcp.Id,
                leankor__GUID__c=mcp.Guid,
                leankor__Height__c = mcp.Height,
                leankor__Left__c = mcp.Left,
                leankor__LockState__c = mcp.LockState,
                leankor__ReportId__c = mcp.ReportID,
                leankor__Top__c = mcp.Top,
                leankor__ValueStream__c = (mcp.ValueStreamID == '' ? null : mcp.ValueStreamID),
                leankor__Width__c = mcp.Width,
                leankor__X__c = mcp.X,
                leankor__Y__c = mcp.Y,
                leankor__CmpID__c = mcp.CmpID,
                leankor__Size__c = mcp.Size,
                leankor__ChartURL__c = mcp.ChartURL,
                leankor__JSONData__c = mcp.JSONData,
                leankor__OnlyShowChart__C = mcp.OnlyShowChart
            );
    
            charts.add(updateChart);
    
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return charts;
    }


    // Rahul Solanki - Method for MoveActivity
    public static ManageStateChangeWrapper moveActivity(ManageStateChangeWrapper mscWrapperInstance) {
        leankor.RealTimeController.StateChangePackage stateChangePackageInstance;
        List<leankor__kanbancard__c> kanbanCardList = new List<leankor__Kanbancard__c>();
    
        try {
            stateChangePackageInstance = (realTimeController.StateChangePackage)JSON.deserialize(mscWrapperInstance.someJSONData, realTimeController.StateChangePackage.class);
            mscWrapperInstance.stateChangePackageInstance = stateChangePackageInstance;

            leankor__KanbanCard__c kanbanCard = [SELECT 
                                                    Id, 
                                                    leankor__DueDateTime__c, 
                                                    leankor__EstimatedDuration__c, 
                                                    leankor__StartDateTime__c, 
                                                    leankor__ValueStreamCardLink__c, 
                                                    Name, 
                                                    OwnerID, 
                                                    leankor__StartDate__c, 
                                                    leankor__KanbanCardTemplate__c, 
                                                    leankor__PromiseCompletionDate__c, 
                                                    leankor__HarveyBallDoneDate__c, 
                                                    leankor__Order__c, 
                                                    leankor__PercentComplete2__c, 
                                                    leankor__Top__c, 
                                                    leankor__Left__c, 
                                                    leankor__ZoneGUID__c, 
                                                    leankor__ValueStreamLink__c, 
                                                    leankor__ValueStream__c, 
                                                    leankor__ValueStream__r.Name 
                                                FROM leankor__KanbanCard__c 
                                                WHERE leankor__GUID__c =: stateChangePackageInstance.GUID 
                                                LIMIT 1];

            kanbanCard.leankor__ValueStreamLink__c = (stateChangePackageInstance.ValueStreamLinkID == '' || stateChangePackageInstance.ValueStreamLinkID == null ? null : stateChangePackageInstance.ValueStreamLinkID);
            kanbanCard.leankor__ValueStreamCardLink__c = (stateChangePackageInstance.ValueStreamCardLink == '' || stateChangePackageInstance.ValueStreamCardLink == null ? null : stateChangePackageInstance.ValueStreamCardLink);
            kanbanCard.leankor__DueDateTime__c = stateChangePackageInstance.Duedate;
            kanbanCard.leankor__StartDateTime__c = stateChangePackageInstance.StartDate;
            kanbanCard.leankor__EstimatedDuration__c = stateChangePackageInstance.EstimatedDuration;

            kanbanCardList.add(kanbanCard);
            mscWrapperInstance.kanbanCards = kanbanCardList;

        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return mscWrapperInstance;
    }


    // Rahul Solanki - Method for update task
    public static List<Task> updateTask(leankor__kanbancard__c kanbanCard, leankor.RealTimeController.StateChangePackage stateChangePackageInstance) {
        List<Task> oldtask;
        
        try {
            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
            Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
            Integer numOfDays = kanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5;
            Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, numOfDays);
        
            oldtask = [SELECT Id, ActivityDate, Description, WhatId FROM Task WHERE WhatId =: kanbanCard.Id AND IsDeleted = false LIMIT 49999 All Rows];
            
            //13/07/2022 : In case of null start date/due date it was throwing error.
            if (oldtask != null) {
                for (Task loopTask: oldtask) {
                	if(stateChangePackageInstance.StartDate != null && stateChangePackageInstance.Duedate != null){
                    if (date.newinstance((stateChangePackageInstance.StartDate).year(), (stateChangePackageInstance.StartDate).month(), (stateChangePackageInstance.StartDate).day()) != date.newinstance((kanbanCard.leankor__StartDateTime__c).year(), (kanbanCard.leankor__StartDateTime__c).month(), (kanbanCard.leankor__StartDateTime__c).day()) && date.newinstance((stateChangePackageInstance.Duedate).year(), (stateChangePackageInstance.Duedate).month(), (stateChangePackageInstance.Duedate).day()) != date.newinstance((kanbanCard.leankor__DueDateTime__c).year(), (kanbanCard.leankor__DueDateTime__c).month(), (kanbanCard.leankor__DueDateTime__c).day())) {
                        integer diff = (kanbanCard.leankor__StartDateTime__c.Date()).daysBetween(stateChangePackageInstance.StartDate.Date());
                        loopTask.ActivityDate = loopTask.ActivityDate + diff;
                    }
                   	}

                	if(stateChangePackageInstance.Duedate != null){
                    if (loopTask.ActivityDate > stateChangePackageInstance.Duedate && kanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                        loopTask.ActivityDate = date.newinstance((stateChangePackageInstance.Duedate).year(), (stateChangePackageInstance.Duedate).month(), (stateChangePackageInstance.Duedate).day());
                        }
                    } else if(stateChangePackageInstance.StartDate != null){
                        		if (loopTask.ActivityDate < stateChangePackageInstance.StartDate && kanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                        loopTask.ActivityDate = date.newinstance((stateChangePackageInstance.StartDate).year(), (stateChangePackageInstance.StartDate).month(), (stateChangePackageInstance.StartDate).day());
                    }
                    		}

                    if (kanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
                        DateTime taskDateTime = workWeek.getNextWorkingDay(DateTime.newInstance(loopTask.ActivityDate.year(), loopTask.ActivityDate.month(), loopTask.ActivityDate.day(), kanbanCard.leankor__StartDateTime__c.hour(), kanbanCard.leankor__StartDateTime__c.minute(), kanbanCard.leankor__StartDateTime__c.second()));
                        loopTask.ActivityDate = taskDateTime.date();
                    }

                    Datetime tskDuedate = Datetime.newInstance(loopTask.ActivityDate.year(), loopTask.ActivityDate.month(), loopTask.ActivityDate.day(), 1, 1, 1);
                    
                    if (!kanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {
                        loopTask.ActivityDate = Util.readNextWorkingDate(workWeek, tskDuedate, loopTask.ActivityDate);
                    }
                }
            }

        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return oldtask;
    }
    

    // Rahul Solanki - Helper method to create RealTimeTrackor records
    public static void realTimeTrackerHelper(ManageStateChangeWrapper mscWrapperInstance) {
        List<Database.SaveResult> realTimeSR;

        try {
            realTimeSR = leankor.GenericStreamingController.createRealtimeTracker(mscWrapperInstance.valueStreamID, mscWrapperInstance.verb, mscWrapperInstance.listOfJSON, mscWrapperInstance.sessionID);
            //Date 06/03/19 changes for single channel.
            /*  if (realTimeSR != null && mscWrapperInstance.linkedCardVerb != null && mscWrapperInstance.linkedCardVerb == 'CardHierarchyToOther' && mscWrapperInstance.linkedVS != mscWrapperInstance.valueStreamID && mscWrapperInstance.linkedVS != null) {             
                realTimeSR = leankor.GenericStreamingController.createRealtimeTracker(mscWrapperInstance.linkedVS, mscWrapperInstance.verb, mscWrapperInstance.listOfJSON, mscWrapperInstance.sessionID);
            }   */                   
            if (realTimeSR == null) {
                throw new GanttTaskBoard.LeanException('ERROR while insert realTimeTracker records');
            } 
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
    }


    // Rahul Solanki - method for MoveActivity
    public static leankor__Subscriber__c createSubscriber(ManageStateChangeWrapper mscWrapperInstance) {
        leankor__Subscriber__c subscribers;
        List <leankor__Preference__c> listOfPreference = new List<leankor__Preference__c>();
        leankor__Zone__c zone;
        
        try {
            //Checking listOfSubscribers record for card.
            if (mscWrapperInstance.listOfSubscribers.size() > 0) {
                //Checking card owner in DB and card owner in json is same or not.
                if (mscWrapperInstance.kanbanCard.OwnerID != mscWrapperInstance.stateChangePackageInstance.OwnerID) {
                    //if both owner is not same than fetch Preference for board of json card owner.
                    listOfPreference = [SELECT 
                                                Id, 
                                                leankor__CardPastDueDate__c, 
                                                leankor__DerivedFrom__c, 
                                                leankor__FollowOnChatter__c, 
                                                leankor__GUID__c, 
                                                leankor__Moved__c, 
                                                leankor__PercentDone__c, 
                                                leankor__SubscribeToCard__c, 
                                                leankor__TaskPastDueDate__c, 
                                                leankor__isTaskCompleted__c, 
                                                leankor__ValueStream__c, 
                                                Name, 
                                                OwnerId 
                                            FROM leankor__Preference__c 
                                            WHERE leankor__ValueStream__c =: mscWrapperInstance.kanbanCard.leankor__ValueStream__c 
                                                AND OwnerId =: mscWrapperInstance.stateChangePackageInstance.OwnerID 
                                            LIMIT 1];

                    // Checking preference created or not.
                    if (listOfPreference.size() > 0) {
                        // If created than updated subscriber for card.
                        subscribers = new leankor__Subscriber__c (
                            Name = mscWrapperInstance.kanbanCard.Id,
                            leankor__KanbanCard__c = mscWrapperInstance.kanbanCard.Id,
                            leankor__SubscriberID__c = mscWrapperInstance.stateChangePackageInstance.OwnerID,
                            leankor__SubscriberKey__c = mscWrapperInstance.kanbanCard.Id + '-' + mscWrapperInstance.stateChangePackageInstance.OwnerID,
                            leankor__Moved__c = listOfPreference[0].leankor__Moved__c,
                            leankor__PercentDone__c = listOfPreference[0].leankor__PercentDone__c,
                            leankor__CardPastDueDate__c = listOfPreference[0].leankor__CardPastDueDate__c,
                            leankor__isTaskCompleted__c = (listOfPreference[0].leankor__isTaskCompleted__c ? listOfPreference[0].leankor__isTaskCompleted__c : false),
                            leankor__TaskPastDueDate__c = listOfPreference[0].leankor__TaskPastDueDate__c
                        );
                    } else {
                        // If not have preference setting than subscribed using default values because of new card owner.
                        subscribers = new leankor__Subscriber__c (
                            Name = mscWrapperInstance.kanbanCard.Id,
                            leankor__KanbanCard__c = mscWrapperInstance.kanbanCard.Id,
                            leankor__SubscriberID__c = mscWrapperInstance.stateChangePackageInstance.OwnerID,
                            leankor__SubscriberKey__c = mscWrapperInstance.kanbanCard.Id + '-' + mscWrapperInstance.stateChangePackageInstance.OwnerID,
                            leankor__Moved__c = false,
                            leankor__PercentDone__c = true,
                            leankor__CardPastDueDate__c = true,
                            leankor__TaskPastDueDate__c = true,
                            leankor__isTaskCompleted__c = true
                        );
                    }
                }
            }
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());          
        }
        
        return subscribers;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    method for posting chatter
    Inputs:         ManageStateChangeWrapper mscWrapperInstance
    Returns:        List < FeedItem >
    ------------------------------------------------------------*/
    public static List<FeedItem> postChatter(ManageStateChangeWrapper mscWrapperInstance) {
        List<FeedItem> feeds = new List<FeedItem>();
        // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
        Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
        // Tilak:23.04.2020 - We need to provide the community networkId into the networkScope field of FeedItem object for external users.
        List<String> userIds = new List<String>();
        for (leankor__Subscriber__c sub : mscWrapperInstance.listOfSubscribers) {
            userIds.add(sub.leankor__SubscriberID__c);
        }
        
        // Create the user map
        Map<Id,User> userMap = new Map<Id,User> ([SELECT Id, UserType FROM User WHERE Id IN: userIds LIMIT 9999]);
        
        // Create the network member map.
        Map<Id,Id> networkMemberMap = new Map<Id,Id>();
        String networkId = Network.getNetworkId();
        // Checking if the NetworkMember available in the org or not.
        // If the communities are deactivated in the org then this object are unavailable.
        Boolean isNetworkAvailable =  (Type.forName('Schema.NetworkMember')!=null);
        if (isNetworkAvailable) {
            leankor.OpenFeedItemRestriction.readNetworkMember(userIds, networkMemberMap);
            }

        try {
            // if Harvey ball values gets change and set values is 100 then subscriber will send chatter message.
            if (mscWrapperInstance.kanbanCard.leankor__PercentComplete2__c != mscWrapperInstance.stateChangePackageInstance.HarveyBall && mscWrapperInstance.stateChangePackageInstance.HarveyBall == 100) {
                for (leankor__Subscriber__c sub: mscWrapperInstance.listOfSubscribers) {
                    if ((sub.leankor__SubscriberID__c != UserInfo.getUserId() && mscWrapperInstance.listOfSubscribers.size() > 0) || (sub.leankor__SubscriberID__c == UserInfo.getUserId() && mscWrapperInstance.listOfSubscribers.size() == 1)) {
                        if(assigneeIds.contains(sub.leankor__SubscriberID__c)) {
	                        if (sub.leankor__PercentDone__c == true) {
	                            //creating chatter feed for Harvey Ball done (Card is completed).
	                            FeedItem post = new FeedItem();
	                            post.ParentID = sub.leankor__SubscriberID__c;
	                            // For standard user we don't need to provide NetworkScope in the FeedItem object.
	                            if (isNetworkAvailable && userMap.containsKey(sub.leankor__SubscriberID__c) && userMap.get(sub.leankor__SubscriberID__c).UserType != 'Standard') {                            
	                                post.put('NetworkScope', networkMemberMap.get(sub.leankor__SubscriberID__c));
	                            }
	                            //For chatter post visibility for all users from community  
	                             if(String.isNotBlank(networkId)){
	                                post.put('Visibility','AllUsers');
	                             }
	                            post.Title = mscWrapperInstance.stateChangePackageInstance.Name;
	                            post.LinkUrl = mscWrapperInstance.stateChangePackageInstance.KanbanUrl + mscWrapperInstance.kanbanCard.Id;
                           
							   	List<String> customlabelsParam = new List<String>();
								customlabelsParam.add(''+mscWrapperInstance.stateChangePackageInstance.ItemType);
								customlabelsParam.add('-'+mscWrapperInstance.stateChangePackageInstance.Name);
								customlabelsParam.add(''+mscWrapperInstance.stateChangePackageInstance.HarveyBall);
								String LabelsWithParameter = String.format(System.Label.leankor.CardStatusDone,customlabelsParam);
								post.Body = LabelsWithParameter;
								post.Body += '\n\n' + mscWrapperInstance.kanbanCard.leankor__ProjectRoom__c + ' / ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name;
                            
	                            feeds.add(post);
	                        } // End of If
                        }
                    } // End of If
                } //End of For loop
            } else if (mscWrapperInstance.verb == 'MoveKanbanCard') {
                // Checking Card is moved or not, If moved than only can send chatter message for listOfSubscribers.
                for (leankor__Subscriber__c sub: mscWrapperInstance.listOfSubscribers) {
                    if ((sub.leankor__SubscriberID__c != UserInfo.getUserId() && mscWrapperInstance.listOfSubscribers.size() > 0) || (sub.leankor__SubscriberID__c == UserInfo.getUserId() && mscWrapperInstance.listOfSubscribers.size() == 1)) {
                        if(assigneeIds.contains(sub.leankor__SubscriberID__c)) {
	                        if (sub.leankor__Moved__c == true) {
	                            FeedItem post = new FeedItem();
	                            post.ParentID = sub.leankor__SubscriberID__c; // Parent Id always User ID. That will send message on user wall.
                            
	                            // For standard user we don't have to provide NetworkScope in feedItem object
	                            if (Type.forName('Schema.NetworkMember') != null && userMap.containsKey(sub.leankor__SubscriberID__c) && userMap.get(sub.leankor__SubscriberID__c).UserType != 'Standard') {                            
	                                post.put('NetworkScope', networkMemberMap.get(sub.leankor__SubscriberID__c));
	                            } 
	                            //For chatter post visibility for all users from community  
	                             if(String.isNotBlank(networkId)){
	                                post.put('Visibility','AllUsers');
	                             }
	                            post.LinkUrl = mscWrapperInstance.stateChangePackageInstance.KanbanUrl + mscWrapperInstance.kanbanCard.Id; // Complete URL for card.
	                            post.Title = mscWrapperInstance.stateChangePackageInstance.Name; // Subject in card.
	                            String cmpType = ((mscWrapperInstance.stateChangePackageInstance.BoardType == 'Kanban Board' ? 'column' : 'zone')); // For Kanban Board zone is column for user.

	                            //Checking ZoneId is avaiable or not
	                            if (mscWrapperInstance.stateChangePackageInstance.ZoneID != '' || mscWrapperInstance.stateChangePackageInstance.ZoneID != mscWrapperInstance.kanbanCard.leankor__ZONEGUID__C) {
	                                //Checking ZoneTitle in json.
	                                if (mscWrapperInstance.stateChangePackageInstance.ZoneTitle != '') {
	                                    //Message body(actual message) for user.
			
										List<String> customlabelsParam = new List<String>();
										customlabelsParam.add(''+mscWrapperInstance.stateChangePackageInstance.Name);
										customlabelsParam.add(''+mscWrapperInstance.kanbanCard.leankor__ValueStream__r.name);
										customlabelsParam.add(''+cmpType);
										customlabelsParam.add(''+mscWrapperInstance.stateChangePackageInstance.ZoneTitle);
										String LabelsWithParameter = String.format(System.Label.leankor.CardMovedStatus,customlabelsParam);
										post.body = LabelsWithParameter;
	                                } else {
	                                    post.Body = 'The card ' + mscWrapperInstance.stateChangePackageInstance.Name + ' has been moved on Project Board ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.name + '.';
	                                } //End of else
	                            } else if (mscWrapperInstance.stateChangePackageInstance.leavedZoneId != '') {
	                                post.Body = 'The card ' + mscWrapperInstance.stateChangePackageInstance.Name + ' has been moved out of ' + cmpType + ' ' + mscWrapperInstance.stateChangePackageInstance.LeavedZoneTitle + ' on Project Board ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name + '.';
	                            } else {
	                                post.Body = 'The card ' + mscWrapperInstance.stateChangePackageInstance.Name + ' has been moved on Project Board ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name + '.';
	                            } //End of else
	                            feeds.add(post); // added in List for builkify feed post.
	                        }
	                    }
	                }
	            }
            }
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        return feeds;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    method for owner change chatter
    Inputs:         ManageStateChangeWrapper mscWrapperInstance
    Returns:        List < FeedItem >
    ------------------------------------------------------------*/
    public static List < FeedItem > ownerChangeChatter(ManageStateChangeWrapper mscWrapperInstance) {

        List<FeedItem> ownerChangeFeeds = new List<FeedItem>();
        List<leankor__Preference__c> listOfPreference = [SELECT Id, leankor__CardPastDueDate__c, leankor__DerivedFrom__c, leankor__FollowOnChatter__c, leankor__GUID__c, leankor__Moved__c, leankor__PercentDone__c, leankor__SubscribeToCard__c, leankor__TaskPastDueDate__c, leankor__isTaskCompleted__c, leankor__ValueStream__c, Name, OwnerId FROM leankor__Preference__c where leankor__ValueStream__c = : mscWrapperInstance.kanbanCard.leankor__ValueStream__c and OwnerId = : mscWrapperInstance.stateChangePackageInstance.OwnerID limit 1];
        // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
        Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();

        try {
            // Create the user map
            Map<Id,User> userMap = new Map<Id,User> ([SELECT Id, UserType FROM User WHERE Id =: mscWrapperInstance.stateChangePackageInstance.OwnerID LIMIT 9999]);
            
            // Create the network member map.
            Map<Id,Id> networkMemberMap = new Map<Id,Id>();
            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Boolean isNetworkAvailable =  (Type.forName('Schema.NetworkMember')!=null);
            if (isNetworkAvailable) {
                leankor.OpenFeedItemRestriction.readNetworkMember(new List<Id>{mscWrapperInstance.stateChangePackageInstance.OwnerID}, networkMemberMap);
            }
            String networkId = Network.getNetworkId();
            //Checking card owner in DB and JSON same or not. If not same than need to send chatter message for new card owner.
            //August 4 2017 : put template condition for prevent email notification to user for template borad
            if (mscWrapperInstance.stateChangePackageInstance.OwnerID != mscWrapperInstance.kanbanCard.OwnerID && mscWrapperInstance.kanbanCard.leankor__TemplateBoard__c == mscWrapperInstance.leanFalse && mscWrapperInstance.kanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                if (listOfPreference.size() > 0) {
                    if(assigneeIds.contains(mscWrapperInstance.stateChangePackageInstance.OwnerID)) { 
	                    if (listOfPreference[0].leankor__FollowOnChatter__c == 'all' || (listOfPreference[0].leankor__FollowOnChatter__c).contains(mscWrapperInstance.kanbanCard.leankor__KanbanCardTemplate__c)) {
	                        FeedItem post = new FeedItem();
	                        post.ParentID = mscWrapperInstance.stateChangePackageInstance.OwnerID;
	                        // For standard user we don't need to provide NetworkScope in the FeedItem object.
	                        if (isNetworkAvailable && userMap.containsKey(mscWrapperInstance.stateChangePackageInstance.OwnerID) && userMap.get(mscWrapperInstance.stateChangePackageInstance.OwnerID).UserType != 'Standard') {                            
	                            post.put('NetworkScope', networkMemberMap.get(mscWrapperInstance.stateChangePackageInstance.OwnerID));  
	                        }
	                        //For chatter post visibility for all users from community  
	                        if(String.isNotBlank(networkId)){
	                            post.put('Visibility','AllUsers');
	                        }
	                        //23.08.2017 : provide project name and valuestream name and card name on emil notification
	                        post.Title = mscWrapperInstance.stateChangePackageInstance.Name;
	                        if (mscWrapperInstance.stateChangePackageInstance.ItemType.contains('MileStone')) {
	                            post.Body = UserInfo.getName() + ' has assigned you as owner of milestone "' + mscWrapperInstance.stateChangePackageInstance.Name + '". Click this link to go to the project board. ' + '\n\n' + mscWrapperInstance.kanbanCard.leankor__ProjectRoom__c + ' / ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name;
	                        } else {
	                            post.Body = UserInfo.getName() + ' has assigned you as owner of card "' + mscWrapperInstance.stateChangePackageInstance.Name + '". Click this link to go to the project board. ' + '\n\n' + mscWrapperInstance.kanbanCard.leankor__ProjectRoom__c + ' / ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name;
	                        }
	                        //End*****SS 26.06.2018*****//
	                        // rbo 05.11.17
	                        post.LinkUrl = mscWrapperInstance.stateChangePackageInstance.kanbanURL + mscWrapperInstance.kanbanCard.Id;
	                        ownerChangeFeeds.add(post);
	                    } //End of If
                    }
                } //End of If
            } //End of If
            //updating owner name of card so notification on home chatter tab
            if (mscWrapperInstance.stateChangePackageInstance.OwnerID != mscWrapperInstance.kanbanCard.OwnerID && mscWrapperInstance.stateChangePackageInstance.BoardType != 'UberBoard') {

                //1 Nov 2017 : put template condition for prevent email notification to user for template borad
                if (mscWrapperInstance.kanbanCard.leankor__TemplateBoard__c == mscWrapperInstance.leanFalse && mscWrapperInstance.kanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template') {

                    FeedItem post = new FeedItem();
                    if(assigneeIds.contains(mscWrapperInstance.stateChangePackageInstance.OwnerID)) { 
	                    post.ParentID = mscWrapperInstance.stateChangePackageInstance.OwnerID;
	                    //For standard user we dont to put the networkScope field
	                    if (isNetworkAvailable && userMap.containsKey(mscWrapperInstance.stateChangePackageInstance.OwnerID) && userMap.get(mscWrapperInstance.stateChangePackageInstance.OwnerID).UserType != 'Standard') {                            
	                        post.put('NetworkScope', networkMemberMap.get(mscWrapperInstance.stateChangePackageInstance.OwnerID));  
	                    }
	                    //For chatter post visibility for all users from community  
	                    if(String.isNotBlank(networkId)){
	                        post.put('Visibility','AllUsers');
	                    }
	                    //23.08.2017 : provide project name and valuestream name and card name on emil notification
	                    post.Title = mscWrapperInstance.stateChangePackageInstance.Name;

	                    if (mscWrapperInstance.stateChangePackageInstance.ItemType.contains('MileStone')) {
	                        post.Body = UserInfo.getName() + ' has assigned you as owner of milestone "' + mscWrapperInstance.stateChangePackageInstance.Name + '". Click this link to go to the project board. ' + '\n\n' + mscWrapperInstance.kanbanCard.leankor__ProjectRoom__c + ' / ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name;
	                    } else {
	                        post.Body = UserInfo.getName() + ' has assigned you as owner of card "' + mscWrapperInstance.stateChangePackageInstance.Name + '". Click this link to go to the project board. ' + '\n\n' + mscWrapperInstance.kanbanCard.leankor__ProjectRoom__c + ' / ' + mscWrapperInstance.kanbanCard.leankor__ValueStream__r.Name;
	                    }
	                    //End*****SS 26.06.2018*****//
	                    //
	                    post.LinkUrl = mscWrapperInstance.stateChangePackageInstance.kanbanURL + mscWrapperInstance.kanbanCard.Id;
	                    ownerChangeFeeds.add(post);
	                }
	            }
            }
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }

        return ownerChangeFeeds;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    Inner class for EntitySubscription as we are creating two types
    of EntitySubscription with and without community
    ------------------------------------------------------------*/
    public class EntitySubscriptionWrapper {
        public List < EntitySubscription > entitySubList;
        public List < sobject > entitySubSobjectList;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is for getting EntitySubscription
    Inputs:         realTimeController.StateChangePackage stateChangePackageInstance
    Returns:        List < EntitySubscription >
    ------------------------------------------------------------*/
    public static List < EntitySubscription > getEntitySubscription(realTimeController.StateChangePackage stateChangePackageInstance) {
        List <EntitySubscription> entitySubscriptions;
        try {
            entitySubscriptions = [SELECT Id FROM EntitySubscription WHERE ParentID =: stateChangePackageInstance.Id LIMIT 999];
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return entitySubscriptions;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is for creating EntitySubscription
    Inputs:         leankor__kanbancard__c updateKanban, realTimeController.StateChangePackage stateChangePackageInstance
    Returns:        EntitySubscriptionWrapper
    ------------------------------------------------------------*/
    public static EntitySubscriptionWrapper createEntitySubscription(List<leankor__kanbancard__c> updateKanbans, realTimeController.StateChangePackage stateChangePackageInstance) {
        EntitySubscriptionWrapper entitySubcription = new EntitySubscriptionWrapper();
        entitySubcription.entitySubList = new List <EntitySubscription>();
        entitySubcription.entitySubSobjectList = new List <EntitySubscription >();
        List<leankor__Preference__c> preferenceRecords = new List <leankor__Preference__c>();
        
        try {
            for (leankor__KanbanCard__c updateKanban : updateKanbans) {
            if (stateChangePackageInstance.TemplateID != updateKanban.leankor__KanbanCardTemplate__c) {

                preferenceRecords = [SELECT Id, leankor__CardPastDueDate__c, leankor__DerivedFrom__c, leankor__FollowOnChatter__c, leankor__GUID__c, leankor__Moved__c, leankor__PercentDone__c, leankor__SubscribeToCard__c, leankor__TaskPastDueDate__c, leankor__isTaskCompleted__c, leankor__ValueStream__c, Name, OwnerID FROM leankor__Preference__c where leankor__ValueStream__c = : updateKanban.leankor__ValueStream__c and OwnerID in(Select Id from User)Limit 9999];
                for (leankor__Preference__c p: preferenceRecords) {
                    //Checking preference setting
                    if (p.leankor__FollowOnChatter__c == 'all' || (p.leankor__FollowOnChatter__c).contains(updateKanban.leankor__KanbanCardTemplate__c)) {
                        if (Network.getnetworkid() != null) {
                            sobject entitySubsObject = New EntitySubscription();
                            entitySubsObject.put('ParentID', updateKanban.Id);
                            entitySubsObject.put('NetworkID', Network.getnetworkid());
                            entitySubsObject.put('SubscriberID', p.OwnerID);
                            entitySubcription.entitySubSobjectList.add(entitySubsObject);
                        } else {
                            EntitySubscription entitySub = new EntitySubscription(ParentID = updateKanban.Id, SubscriberId = p.OwnerID);
                            entitySubcription.entitySubList.add(entitySub);
                        }
                    } 
                } 
            } else {
                if (preferenceRecords.size() > 0) {
                    if (preferenceRecords[0].leankor__FollowOnChatter__c == 'all' || (preferenceRecords[0].leankor__FollowOnChatter__c).contains(updateKanban.leankor__KanbanCardTemplate__c)) {
                        if (Network.getnetworkid() != null) {
                            sobject entitySubsObject = New EntitySubscription();
                            entitySubsObject.put('ParentID', updateKanban.Id);
                            entitySubsObject.put('NetworkID', Network.getnetworkid());
                            entitySubsObject.put('SubscriberID', stateChangePackageInstance.OwnerID);
                            entitySubcription.entitySubSobjectList.add(entitySubsObject);
                        } else {
                            EntitySubscription entitySub = new EntitySubscription(ParentID = updateKanban.Id, SubscriberId = stateChangePackageInstance.OwnerID);
                            entitySubcription.entitySubList.add(entitySub);
                        }
                    } 
                } 
            } 
            }
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }

        return entitySubcription;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is for deleting miniature
    Inputs:         realTimeController.StateChangePackage stateChangePackageInstance
    Returns:        List < leankor__KanbanCard__c >
    ------------------------------------------------------------*/
    public static List < leankor__KanbanCard__c > deleteMiniature(realTimeController.StateChangePackage stateChangePackageInstance) {
        List < leankor__KanbanCard__c > miniaturelist = new List < leankor__KanbanCard__c > ();
        
        try {
            if (stateChangePackageInstance.deleteMiniature == true) {
                
                for (Leankor__KanbanCard__c m: [SELECT 
                                                    Id, 
                                                    Leankor__ValueStreamCardLink__c, 
                                                    Leankor__ValueStreamLink__c,
                                                    Leankor__valuestream__c 
                                                FROM Leankor__KanbanCard__c 
                                                WHERE Leankor__ValueStreamCardLink__c =: stateChangePackageInstance.Id]) {
                    
                    if(m.Leankor__valuestream__c != null){
                        m.Leankor__ValueStreamCardLink__c = null;
                        m.Leankor__ValueStreamLink__c = null;
                        miniaturelist.add(m);
                    }
                }
            }
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return miniaturelist;
    }

    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is for creating ResourceAssignment
    Inputs:         realTimeController.StateChangePackage stateChangePackageInstance
    Returns:        leankor__ResourceAssignment__c
    ------------------------------------------------------------*/
    public static leankor__ResourceAssignment__c createResourceAssignment(realTimeController.StateChangePackage stateChangePackageInstance) {
        leankor__ResourceAssignment__c rsa = new leankor__ResourceAssignment__c();
        Set<Id> resourceIds = new Set<Id>();
        
        try {
            resourceIds.add(stateChangePackageInstance.OwnerId);
            // gets the latest resource record of each user 
            Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds);  
            rsa.leankor__KanbanCard__c = stateChangePackageInstance.Id;
            rsa.leankor__AssignedTo__c = stateChangePackageInstance.OwnerId;
            rsa.leankor__PercentAllocation__c = 100;
            rsa.leankor__PercentCompleted__c = Integer.valueof(stateChangePackageInstance.HarveyBall);
            rsa.leankor__CompletedDate__c = rsa.leankor__PercentCompleted__c == 100 ? stateChangePackageInstance.DueDate : null;
                    
            rsa = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(stateChangePackageInstance.OwnerId, resourceTypes, rsa, true) : Resource.setResourceAccounts(stateChangePackageInstance.OwnerId, resourceTypes, rsa);                          
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        
        return rsa;
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is updating manageStateChangeWrapperInstance.kanbanCard Instance
    Inputs:         ManageStateChangeWrapper manageStateChangeWrapperInstance
    Returns:        leankor__kanbancard__c
    ------------------------------------------------------------*/
    public static leankor__kanbancard__c updateKanbanCardInstance(ManageStateChangeWrapper manageStateChangeWrapperInstance) {

        //ManageStateChangeWrapper  manageStateChangeWrapperInstance = new ManageStateChangeWrapper ();
        leankor__KanbanCard__c updateKanban;
        String defaultRecordType;
        String milestoneCardID;
        String folderCardID;
        
        try {
        List < RecordType > cardRecordType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'leankor__Kanbancard__c'];
        for (RecordType rt: cardRecordType) {
            if (rt.Name == 'ActivityCard') {
                defaultRecordType = rt.ID;
            } else if (rt.Name == 'MileStoneCard') {
                milestoneCardID = rt.ID;
            } else if (rt.Name == 'FolderCard') {
                folderCardID = rt.ID;
            }
        }

        /*SS 13.09.2018*/
        //Old kanban card data before updation to compare values for isSuccessorRecalculation
        leankor__KanbanCard__c oldKanbanValues = manageStateChangeWrapperInstance.kanbanCard;
        // update kanban card if we get to this point without error
        // need to pass null in ID / lookup values if '' comes in json.
        //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
            updateKanban = new leankor__KanbanCard__c(
                Id = (manageStateChangeWrapperInstance.stateChangePackageInstance.ID == null ? '' : manageStateChangeWrapperInstance.stateChangePackageInstance.ID),
                leankor__GUID__c = manageStateChangeWrapperInstance.stateChangePackageInstance.GUID,
                leankor__CardID__C = (manageStateChangeWrapperInstance.stateChangePackageInstance.CardID == null ? manageStateChangeWrapperInstance.kanbanCard.leankor__CardID__c : manageStateChangeWrapperInstance.stateChangePackageInstance.CardID),
                leankor__Point__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Point,
                leankor__EffortRemaining__c = manageStateChangeWrapperInstance.stateChangePackageInstance.EffortRemaining,
                leankor__UrlLink__c = manageStateChangeWrapperInstance.stateChangePackageInstance.UrlLink,
                leankor__Title__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Title,
                Name = manageStateChangeWrapperInstance.stateChangePackageInstance.Name, // don't want to do this anymore; name not same as title!
                leankor__Top__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Top,
                leankor__Bottom__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Bottom,
                leankor__Left__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Left,
                leankor__Width__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Width,
                leankor__Height__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Height,
                leankor__X__c = manageStateChangeWrapperInstance.stateChangePackageInstance.X,
                leankor__Y__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Y,
                leankor__State__c = manageStateChangeWrapperInstance.stateChangePackageInstance.State,
                leankor__ZoneGUID__c = manageStateChangeWrapperInstance.stateChangePackageInstance.ZoneID,
                leankor__MasterContainer__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.MCForceID == '' ? Null : manageStateChangeWrapperInstance.stateChangePackageInstance.MCForceID),
                leankor__Swimlane__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.SWForceID == '' ? Null : manageStateChangeWrapperInstance.stateChangePackageInstance.SWForceID),
                leankor__Zone__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.ZoneForceID == '' ? Null : manageStateChangeWrapperInstance.stateChangePackageInstance.ZoneForceID),
                leankor__DurationUnits__c = manageStateChangeWrapperInstance.stateChangePackageInstance.DurationUnits,
                leankor__EstimatedDuration__c = manageStateChangeWrapperInstance.stateChangePackageInstance.EstimatedDuration,
                leankor__Priority__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Priority,
                OwnerId = manageStateChangeWrapperInstance.stateChangePackageInstance.OwnerID,
                leankor__Color__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Color,
                leankor__KanbanCardTemplate__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.TemplateID == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.TemplateID),
                leankor__DescriptionLong__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Description,
                leankor__AcceptanceCriteria__c = manageStateChangeWrapperInstance.stateChangePackageInstance.AcceptanceCriteria,
                //leankor__JSONData__c = manageStateChangeWrapperInstance.stateChangePackageInstance.JSONData,
                //leankor__JSONDefinition__c = manageStateChangeWrapperInstance.stateChangePackageInstance.JSONDefinition,
                //leankor__Account__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.Account == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Account),
                //leankor__Contact__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.Contact == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Contact),
                //leankor__Case__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.CaseID == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.CaseID),
                leankor__HarveyBallDoneDate__c = ((manageStateChangeWrapperInstance.kanbanCard.leankor__PercentComplete2__c != manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall && manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall == 100) ? System.today() : manageStateChangeWrapperInstance.kanbanCard.leankor__HarveyBallDoneDate__c),
                leankor__PromiseCompletionDate__c = ((manageStateChangeWrapperInstance.kanbanCard.leankor__PercentComplete2__c != manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall && manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall == 100) ? System.now() : manageStateChangeWrapperInstance.kanbanCard.leankor__PromiseCompletionDate__c),
                leankor__Order__c = Integer.valueOf(manageStateChangeWrapperInstance.stateChangePackageInstance.Order),
                //leankor__Opportunity__C = (manageStateChangeWrapperInstance.stateChangePackageInstance.Opportunity == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Opportunity),
                leankor__StartDateTime__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.StartDate == null ? oldKanbanValues.leankor__StartDateTime__c : manageStateChangeWrapperInstance.stateChangePackageInstance.StartDate),
                leankor__DueDateTime__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.DueDate == null ? oldKanbanValues.leankor__DueDateTime__c : manageStateChangeWrapperInstance.stateChangePackageInstance.DueDate),
                
                // Date: 27/05/2019
                leankor__IsAtRisk__c = manageStateChangeWrapperInstance.stateChangePackageInstance.isAtRisk!=null ? manageStateChangeWrapperInstance.stateChangePackageInstance.isAtRisk : manageStateChangeWrapperInstance.kanbanCard.leankor__IsAtRisk__c,
                leankor__IsOnHold__c = manageStateChangeWrapperInstance.stateChangePackageInstance.isOnHold !=null? manageStateChangeWrapperInstance.stateChangePackageInstance.isOnHold : manageStateChangeWrapperInstance.kanbanCard.leankor__IsOnHold__c,

                leankor__OnBudget__c = manageStateChangeWrapperInstance.stateChangePackageInstance.OnBudget,
                leankor__OnQuality__c = manageStateChangeWrapperInstance.stateChangePackageInstance.OnQuality,
                leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize((manageStateChangeWrapperInstance.stateChangePackageInstance.StartDate == null ? oldKanbanValues.leankor__StartDate__c : manageStateChangeWrapperInstance.stateChangePackageInstance.StartDate)), DateTime.class)),
                leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize((manageStateChangeWrapperInstance.stateChangePackageInstance.DueDate == null ? oldKanbanValues.leankor__DueDate__c :manageStateChangeWrapperInstance.stateChangePackageInstance.DueDate)), DateTime.class)),
                leankor__OnTime__c = manageStateChangeWrapperInstance.stateChangePackageInstance.OnTime,
                leankor__IsExternallyDependent__c = manageStateChangeWrapperInstance.stateChangePackageInstance.IsExternallyDependent == null? oldKanbanValues.leankor__IsExternallyDependent__c : manageStateChangeWrapperInstance.stateChangePackageInstance.IsExternallyDependent,
            
                
                leankor__Monday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Monday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Monday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Monday__c,
                leankor__Tuesday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Tuesday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Tuesday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Tuesday__c,
                leankor__Wednesday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Wednesday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Wednesday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Wednesday__c,
                leankor__Thursday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Thursday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Thursday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Thursday__c,
                leankor__Friday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Friday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Friday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Friday__c,
                leankor__Saturday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Saturday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Saturday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Saturday__c,
                leankor__Sunday__c = manageStateChangeWrapperInstance.stateChangePackageInstance.Sunday !=null ? (manageStateChangeWrapperInstance.stateChangePackageInstance.Sunday == false ? false : true) : manageStateChangeWrapperInstance.kanbanCard.leankor__Sunday__c,
                leankor__WeekCalendar__c = String.isNotBlank(manageStateChangeWrapperInstance.stateChangePackageInstance.weekCalendar) ? manageStateChangeWrapperInstance.stateChangePackageInstance.weekCalendar : null);
                if(ProjectBoardCarousel.isCalledFromQuickAction) {
                    updateKanban.leankor__WeekCalendar__c = manageStateChangeWrapperInstance.kanbanCard.leankor__WeekCalendar__c;
                }
                
                Set<String> weekDays = new Set<String>();
                if(manageStateChangeWrapperInstance.kanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c == true){
                    weekDays.add(updateKanban.leankor__Monday__c == false ? 'Mon' : 'false');
                    weekDays.add(updateKanban.leankor__Tuesday__c == false ? 'Tue' : 'false');
                    weekDays.add(updateKanban.leankor__Wednesday__c == false ? 'Wed' : 'false');
                    weekDays.add(updateKanban.leankor__Thursday__c == false ? 'Thu' : 'false');
                    weekDays.add(updateKanban.leankor__Friday__c == false ? 'Fri' : 'false');
                    weekDays.add(updateKanban.leankor__Saturday__c == false ? 'Sat' : 'false');
                    weekDays.add(updateKanban.leankor__Sunday__c == false ? 'Sun' : 'false');
                }
                Util.weekDays = weekDays;
                
                if(manageStateChangeWrapperInstance.stateChangePackageInstance.Account!=null){
                    updateKanban.leankor__Account__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.Account == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Account);
                }
                if(manageStateChangeWrapperInstance.stateChangePackageInstance.Contact!=null){
                    updateKanban.leankor__Contact__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.Contact == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Contact);
                }
                if(manageStateChangeWrapperInstance.stateChangePackageInstance.CaseID!=null){
                    updateKanban.leankor__Case__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.CaseID == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.CaseID);
                }
                if(manageStateChangeWrapperInstance.stateChangePackageInstance.Opportunity!=null){
                    updateKanban.leankor__Opportunity__C = (manageStateChangeWrapperInstance.stateChangePackageInstance.Opportunity == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.Opportunity);
                }

        //DCO 10.8.17 missed the following code
        leankor.UpdateInjector updateInjector = new leankor.UpdateInjector();
        //updateKanban = updateInjector.updateKanbanCard(updateKanban, manageStateChangeWrapperInstance.stateChangePackageInstance.JSONData);
        // rbo 10.27.17
        updateKanban = updateInjector.updateKanbanCard(updateKanban, manageStateChangeWrapperInstance.stateChangePackageInstance.JSONData, manageStateChangeWrapperInstance.fieldMapKanbanCard);
        // rbo 10.27.17
        //DCO 10.8.17

        if (manageStateChangeWrapperInstance.stateChangePackageInstance.ItemType == 'FolderCard') {
            updateKanban.RecordTypeId = folderCardID;
        } else if (manageStateChangeWrapperInstance.stateChangePackageInstance.ItemType == 'MilestoneCard') {
            updateKanban.RecordTypeId = milestoneCardID;
        } else if (manageStateChangeWrapperInstance.stateChangePackageInstance.ItemType == 'ActivityCard') {
            updateKanban.RecordTypeId = defaultRecordType;
        }
        //if card is moving one place to another than link is updating which is DataBase
        //SS 08.10.2019    
        //if linked card is from softdeleted board or null or its project is null then remove linking
        if(String.isNotBlank(manageStateChangeWrapperInstance.kanbanCard.leankor__ValueStream__c) 
                && !manageStateChangeWrapperInstance.kanbanCard.leankor__ValueStream__r.leankor__IsRecordDeleted__c 
                && String.isNotBlank(manageStateChangeWrapperInstance.kanbanCard.leankor__ProjectRoom__c)){
        if (manageStateChangeWrapperInstance.verb == 'MoveKanbanCard') {
            updateKanban.leankor__ValueStreamCardLink__c = manageStateChangeWrapperInstance.kanbanCard.leankor__ValueStreamCardLink__c;
            updateKanban.leankor__ValueStreamLink__c = manageStateChangeWrapperInstance.kanbanCard.leankor__ValueStreamLink__c;
        } else {
            updateKanban.leankor__ValueStreamCardLink__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.ValueStreamCardLink == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.ValueStreamCardLink);
            updateKanban.leankor__ValueStreamLink__c = (manageStateChangeWrapperInstance.stateChangePackageInstance.ValueStreamLinkID == '' ? null : manageStateChangeWrapperInstance.stateChangePackageInstance.ValueStreamLinkID);
        }
        } else {
            updateKanban.leankor__ValueStreamCardLink__c=null;
            updateKanban.leankor__ValueStreamLink__c =null;
        }
        
        if (manageStateChangeWrapperInstance.kanbanCard.leankor__PercentComplete2__c != manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall) {
            updateKanban.leankor__PercentComplete2__c = manageStateChangeWrapperInstance.stateChangePackageInstance.HarveyBall;
        }

        
        //14.sep.2017 added for edit popup for due date in mywork
        if (manageStateChangeWrapperInstance.stateChangePackageInstance.Help == 'MyWorkCheck') {
            
            //RS 13/09/2018 USing GS To fix mywork broadcast issue when updating child broadcast should arive on parent plangantt
            if (manageStateChangeWrapperInstance.verb == 'UpdateKanbanCard' 
                    && updateKanban.leankor__ValueStreamCardLink__c!=null 
                    && updateKanban.leankor__ValueStreamCardLink__r.RecordType.Name!='FolderCard') {
                realTimeController.gskanbanCardIds.add(manageStateChangeWrapperInstance.stateChangePackageInstance.ValueStreamCardLink);        
            }
            
            //Update IsSueccessorRecalculate only when card has Successor dependency 
            if(manageStateChangeWrapperInstance.kanbanCard.leankor__PredecessorDependencies__r.size()>0){
            updateKanban.leankor__IsSuccessorRecalculate__c = true;
            }
            //parent is updating when we update activity from planGantt.
            if (updateKanban.leankor__ValueStreamCardLink__c != null && manageStateChangeWrapperInstance.Verb == 'UpdateKanbanCard' && manageStateChangeWrapperInstance.stateChangePackageInstance.BoardType == 'UberBoard') {
                //Not updating parent record if child record is from PlanGantt Board.
                if(manageStateChangeWrapperInstance.kanbanCard.leankor__BoardType__c != 'UberBoard') {
                manageStateChangeWrapperInstance.updateparent = true;
            }
        }
        }
        
        // Tilak Raj Mahale:19.06.2020 - We need to update the parent record when card moved from template MC to non-template or vise- versa.
        if (manageStateChangeWrapperInstance.stateChangePackageInstance.BoardType != 'UberBoard') {
            Boolean isScheduleRecalculateOnMove = false;
            Boolean hasNonTemplateMC = false;
            List<leankor__MasterContainer__c> masterContainerInfo = [SELECT Id, Name ,leankor__Type__c FROM MasterContainer__c WHERE Id =: updateKanban.leankor__MasterContainer__c LIMIT 1] ;
            
            if (masterContainerInfo.size() > 0) {
                if (masterContainerInfo[0].leankor__Type__c == 'Template' || oldKanbanValues.leankor__MasterContainer__r.leankor__Type__c == 'Template') {
                    if (masterContainerInfo[0].leankor__Type__c != oldKanbanValues.leankor__MasterContainer__r.leankor__Type__c) {
                        isScheduleRecalculateOnMove = true;
                        manageStateChangeWrapperInstance.isUpdateParentOnMove = true;
                    }
                }

                hasNonTemplateMC = (masterContainerInfo[0].leankor__Type__c != 'Template' ? true : false);
            }

            if ((hasNonTemplateMC && ((oldKanbanValues.leankor__DueDate__c != updateKanban.leankor__DueDate__c) || (oldKanbanValues.leankor__StartDate__c != updateKanban.leankor__StartDate__c) || (oldKanbanValues.leankor__ValueStreamCardLink__c != updateKanban.leankor__ValueStreamCardLink__c))) || isScheduleRecalculateOnMove) {
                if (String.isNotBlank(oldKanbanValues.leankor__ValueStreamCardLink__c)) {
                        Util.recalculateRecord.put(oldKanbanValues.leankor__ValueStreamCardLink__c, true);
                }
                if (String.isNotBlank(updateKanban.leankor__ValueStreamCardLink__c)) {
                        Util.recalculateRecord.put(updateKanban.leankor__ValueStreamCardLink__c, true);
                }
            }
        }
        //------------------------------------------------------------------------

        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }

        return updateKanban;
    }
    

    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    this method is updating harvey ball
    Inputs:         ManageStateChangeWrapper mscWrapperInstance
    Returns:        ManageStateChangeWrapper
    ------------------------------------------------------------*/
    public static ManageStateChangeWrapper updateHarveyBall(ManageStateChangeWrapper mscWrapperInstance) {
        List < leankor__kanbancard__c > kanbanCards = new List < leankor__Kanbancard__c > ();
        realTimeController.StateChangePackage stateChangePackageInstance;
        
        try {
            stateChangePackageInstance = (realTimeController.StateChangePackage)JSON.deserialize(mscWrapperInstance.SomeJSONData, realTimeController.StateChangePackage.class);
            leankor__KanbanCard__c kanbanCard = [select Id, 
                                                leankor__ValueStreamCardLink__c, Name, OwnerID, 
                                                leankor__StartDate__c, leankor__KanbanCardTemplate__c, 
                                                leankor__PromiseCompletionDate__c, leankor__HarveyBallDoneDate__c, 
                                                leankor__PercentComplete2__c, leankor__Top__c, leankor__Left__c, 
                                                leankor__ZoneGUID__c, leankor__ValueStream__c, leankor__ValueStream__r.Name, 
                                                leankor__ProjectRoom__c 
                                                from leankor__KanbanCard__c 
                                                where leankor__GUID__c = : stateChangePackageInstance.GUID limit 1];    

            List < leankor__Subscriber__c > listOfSubscribers = [Select Id, Name, 
                                                                leankor__KanbanCard__c, leankor__SubscriberID__c, 
                                                                leankor__Moved__c, leankor__PercentDone__c, 
                                                                leankor__CardPastDueDate__c, leankor__TaskPastDueDate__c, 
                                                                leankor__isTaskCompleted__c 
                                                                from leankor__Subscriber__c 
                                                                where leankor__KanbanCard__c = : kanbanCard.Id LIMIT 9999];

            // Tilak: 23.04.2020 - We need to provide the community networkId into the networkScope field of FeedItem object for external users.
            List<String> userIds = new List<String>();
            // Extract the user id from subscribers
            for (leankor__Subscriber__c sub : listOfSubscribers) {
                userIds.add(sub.leankor__SubscriberID__c);
            }
            // Create the user map
            Map<Id,User> userMap = new Map<Id,User> ([SELECT Id, UserType FROM User WHERE Id IN: userIds LIMIT 9999]);
            
            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Map<Id,Id> networkMemberMap = new Map<Id,Id>();
            String networkId = Network.getNetworkId();
            if (Type.forName('Schema.NetworkMember') != null) {
                leankor.OpenFeedItemRestriction.readNetworkMember(userIds, networkMemberMap);
                }
            // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
            Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
                                                                    
            List < FeedItem > feeds = new List < FeedItem > ();
            if (kanbanCard.leankor__PercentComplete2__c != stateChangePackageInstance.HarveyBall && stateChangePackageInstance.HarveyBall == 100) {
                for (leankor__Subscriber__c sub: listOfSubscribers) {
                    if ((sub.leankor__SubscriberID__c != UserInfo.getUserId() && listOfSubscribers.size() > 0) || (sub.leankor__SubscriberID__c == UserInfo.getUserId() && listOfSubscribers.size() == 1)) {
                        if(assigneeIds.contains(sub.leankor__SubscriberID__c)) {
	                        if (sub.leankor__PercentDone__c == true) {
	                            FeedItem post = new FeedItem();
	                            post.ParentID = sub.leankor__SubscriberID__c;
	                            // For standard user we don't have to provide network id in feedItem
	                            if (Type.forName('Schema.NetworkMember') != null && userMap.containsKey(sub.leankor__SubscriberID__c) && userMap.get(sub.leankor__SubscriberID__c).UserType != 'Standard') {                            
	                                post.put('NetworkScope', networkMemberMap.get(sub.leankor__SubscriberID__c));
	                            }
	                            //For chatter post visibility for all users from community  
	                             if(String.isNotBlank(networkId)){
	                                post.put('Visibility','AllUsers');
	                             }
	                            post.Title = stateChangePackageInstance.Name;
	                            post.LinkUrl = stateChangePackageInstance.KanbanUrl + kanbanCard.Id;
					
								List<String> customlabelsParam = new List<String>();
	                            customlabelsParam.add(''+stateChangePackageInstance.ItemType);
	                            customlabelsParam.add(''+stateChangePackageInstance.Name);
	                            customlabelsParam.add(''+stateChangePackageInstance.HarveyBall);
	                            String LabelsWithParameter = String.format(System.Label.leankor.CardStatusDone,customlabelsParam);
	                            post.Body = LabelsWithParameter;
	                            post.Body += '\n\n' + kanbanCard.leankor__ProjectRoom__c + ' / ' + kanbanCard.leankor__ValueStream__r.Name;
	                            feeds.add(post);
	                        } // End of If
                        }
                    } // End of If
                } //End of For loop
            }
                
            mscWrapperInstance.feeds = feeds;
            kanbanCard.leankor__HarveyBallDoneDate__c = ((kanbanCard.leankor__PercentComplete2__c != stateChangePackageInstance.HarveyBall && stateChangePackageInstance.HarveyBall == 100) ? System.today() : kanbanCard.leankor__HarveyBallDoneDate__c);
            kanbanCard.leankor__PromiseCompletionDate__c = ((kanbanCard.leankor__PercentComplete2__c != stateChangePackageInstance.HarveyBall && stateChangePackageInstance.HarveyBall == 100) ? System.now() : kanbanCard.leankor__PromiseCompletionDate__c);
            kanbanCard.leankor__PercentComplete2__c = stateChangePackageInstance.HarveyBall;
            kanbanCard.leankor__GUID__c = stateChangePackageInstance.GUID;
            kanbanCards.add(kanbanCard);

            mscWrapperInstance.activityIds.add(kanbanCard.Id);
            if (kanbanCard.leankor__ValueStreamCardLink__c != null) {
                mscWrapperInstance.activityIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }
            mscWrapperInstance.stateChangePackageInstance = stateChangePackageInstance;
            mscWrapperInstance.kanbanCards = kanbanCards;
        
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }

        return mscWrapperInstance;
    }


    /*public static Set<String> readDependentCards (Set<String> cardIds){
        Set<String> dependentCardIds = new Set<String>(); 
        try{
        Map<String, List<String>> dependencyMap  = new Map<String,List<String>>();
        for(leankor__Dependency__c de : [SELECT leankor__Predecessor__c,leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__c,leankor__Successor__r.leankor__ValueStream__c FROM leankor__Dependency__c  Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard'  and leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null  and leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null and leankor__Predecessor__r.leankor__IsExternallyDependent__c = true and leankor__Successor__r.leankor__IsExternallyDependent__c = true limit 49999]){
            if(de.leankor__Predecessor__r.leankor__ValueStream__c!=de.leankor__Successor__r.leankor__ValueStream__c)
            {/*
                List<String> depIds;
                depIds = dependencyMap.contains(de.leankor__Predecessor__c)?;
                dependencyMap.put(de.leankor__Predecessor__c, de.leankor__Successor__c);
                */
    /*            List<String> depIds = dependencyMap.containsKey(de.leankor__Predecessor__c) ? dependencyMap.get(de.leankor__Predecessor__c) : new List<String>();
                depIds.add(de.leankor__Successor__c);  
                dependencyMap.put(de.leankor__Predecessor__c, de.leankor__Successor__c);
            }
        }
        for(String activityId : cardIds)
        {
            for(String str : dependencyMap.keySet())
            {
                if(dependencyMap.keySet().contains(activityId) && str ==activityId){
                activityId = (String)dependencyMap.get(str);
                dependentCardIds.add(activityId);
                while(dependencyMap.keySet().contains(activityId)){
                activityId = (String)dependencyMap.get(activityId);
                dependentCardIds.add(activityId);
                }
            }
            }
        }
        }
        catch(Exception ex){
        System.debug('Error : '+ex);
        }
        return  dependentCardIds;   
    }*/
    
    
    public class ExternallyDependentCards{
        public String id;
        public String valueStreamID;
        public Boolean isExternallyDependent;
        public Boolean isSuccessorRecalculate;
        public Set<String> cardIds;
        public Set<String> externalIds;
        public String name;
    }


    /*------------------------------------------------------------
    @Author:         Suraj Sen
    @Company:        Leankor
    @Description:    Prepare data for broadcast of related dependency ids
    @Parameter:      List<leankor__KanbanCard__c> kanbanCards, Set<String> dependentCardIds
    @Returns:        List<leankor.realtimeController.bulkStreaming>
    @Date:           14.09.2018
    ------------------------------------------------------------*/
    // Method Commented on 12/06/19 
    /*public static List<leankor.realtimeController.bulkStreaming> getDependentCardsDataForStreaming (List<leankor__KanbanCard__c> kanbanCards, Set<String> dependentCardIds){
        List<leankor.realtimeController.bulkStreaming> bulkStreamingList = new List<leankor.realtimeController.bulkStreaming>(); 
        try{
        List<String> jsonList = new List<String>();
            for(leankor__KanbanCard__c kc : kanbanCards){
            ExternallyDependentCards remoteKanban  = new ExternallyDependentCards();
            remoteKanban.id = kc.Id;
            remoteKanban.valueStreamId = kc.leankor__ValueStream__c;
            remoteKanban.isExternallyDependent = kc.leankor__IsExternallyDependent__c;
            remoteKanban.isSuccessorRecalculate = kc.leankor__IsSuccessorRecalculate__c;
            remoteKanban.name = kc.Name;
            remoteKanban.cardIds = dependentCardIds;
            leankor.realtimeController.bulkStreaming jsonLog = New leankor.realtimeController.bulkStreaming();
            jsonLog.SomeJSONData = JSON.Serialize(remoteKanban);
            jsonLog.VSID = kc.leankor__ValueStream__C;
            jsonLog.Verb = 'ExternallyDependentCards';
            jsonLog.SessionID = userinfo.getsessionID();
            bulkStreamingList.add(jsonLog);
            }
        }
            catch(Exception ex){
            System.debug('Error : '+ex);
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());     
        }
        return  bulkStreamingList;  
    }
    */
    
    
    public static List<leankor.realtimeController.bulkStreaming> getDependentCardsDataForStreaming (Set<leankor__Dependency__c> dependencies){
        List<leankor.realtimeController.bulkStreaming> bulkStreamingList = new List<leankor.realtimeController.bulkStreaming>(); 
        
        try {
            List<String> jsonList = new List<String>();
            Set<String> dependencyVSIds = new Set<String>();
            String vsId;
            String cardId;

            for (leankor__Dependency__c dp  : dependencies) { 
                vsId = dp.leankor__ValueStream__c;          
                cardId = dp.leankor__Predecessor__c;  
                //Date 06/03/19 changes for single channel 
                if (String.isNotBlank(dp.leankor__ValueStream__c)) { 
                    dependencyVSIds.add(dp.leankor__ValueStream__c);  
                }         
            } 
            
            //for(String s : dependencyVSIds){            
                ExternallyDependentCards remoteKanban  = new ExternallyDependentCards();
                remoteKanban.id = cardId;
                remoteKanban.valueStreamID = vsId;             
                remoteKanban.externalIds =dependencyVSIds;          
               //Date 06/03/19 changes for single channel. 
                if(remoteKanban.externalIds.size()>0 || String.isNotBlank(remoteKanban.valueStreamID)|| String.isNotBlank(remoteKanban.id)){
                    //if(remoteKanban!=null){
                    leankor.realtimeController.bulkStreaming jsonLog = New leankor.realtimeController.bulkStreaming();
                    jsonLog.SomeJSONData = JSON.Serialize(remoteKanban);
                    jsonLog.VSID = vsId;
                    //jsonLog.Verb = 'GetDependency';
                    jsonLog.Verb = 'ManageDependency';
                    jsonLog.SessionID = userinfo.getsessionID();
                    bulkStreamingList.add(jsonLog);   
                }         
            //}
        }
        catch(Exception ex){
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }
        return  bulkStreamingList;  
    }
    
    
    /*------------------------------------------------------------
    @Author:         Suraj Sen
    @Company:        Leankor
    @Description:    This method is used to enlist all related card ids retrieved in dependency
    @Parameter:      Set<String> ids, Map<String, Set< String > > externalIdMap
    @Returns:        Set<String>
    @Date:           14.09.2018
    ------------------------------------------------------------*/
   //Commented on 12/06/19 method not using.
   /*  public static Set<String> getSuccessorIds(Set<String> ids, Map<String, Set< String > > externalIdMap)
    {
        Set<String> strList = new Set<String>();
        try{
            //externai id map contains predecessor as key and its respective successor id List in value
            for(String str : ids)
            {
                if(externalIdMap.size()>0 && externalIdMap.containsKey(str))
                {
                    Set<String> tempList = (Set<String>)externalIdMap.get(str);
                    strList.addAll(tempList );
                    if(tempList.size()>0)
                    {
                        //it may be possible successor can be predessor in other dependencies so retrieve all respective successors.
                        strList.addAll(getSuccessorIds(tempList,externalIdMap));
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Error : '+ex);
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }
    return strList;
    }*/
    
    /*------------------------------------------------------------
    @Author:         Suraj Sen
    @Company:        Leankor
    @Description:    read all external related dependent card ids 
    @Parameter:      Set<String> cardIds
    @Returns:        Set<String>
    @Date:           14.09.2018
    ------------------------------------------------------------*/
    //Commented on 12/06/19 method not using.
    /*public static Set<String> readExternallyDependentCardsId (Set<String> cardIds){
        Set<String> dependentCardIds = new Set<String>(); 
        try{
            Map<String, Set< String >> dependencyMap = new Map < String, Set< String >> ();
            Map<String, leankor__ValueStream__c> vsMap = new Map<String, leankor__ValueStream__c>([select id from leankor__Valuestream__c where id  in (select leankor__Valuestream__c from leankor__KanbanCard__c where id IN : cardIds and leankor__isRecordDeleted__c = false) and leankor__isRecordDeleted__c = false limit 49999]);
            
            
            //Get all externally dependent VS ids grouped by Prdecessor's and Sucessor's VS
            Set<String> relatedVSIds = GanttTaskBoard.getExternallyDependentVSIds(vsMap.keySet());
            //Retrieve all external dependencies
            //for(leankor__Dependency__c de : [SELECT leankor__Predecessor__c,leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__c,leankor__Successor__r.leankor__ValueStream__c FROM leankor__Dependency__c  Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard'  and leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null  and leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null and leankor__Predecessor__r.leankor__IsExternallyDependent__c = true and leankor__Successor__r.leankor__IsExternallyDependent__c = true limit 49999]){
            for(leankor__Dependency__c de : [SELECT leankor__Predecessor__c,leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__c,leankor__Successor__r.leankor__ValueStream__c 
                                                FROM leankor__Dependency__c  
                                                Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard'  
                                                      and leankor__valuestream__r.leankor__IsTemplateBoard__c = false
                                                      and leankor__valuestream__r.leankor__isRecordDeleted__c = false
                                                      and leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                                      and leankor__Successor__r.leankor__isRecordDeleted__c = false
                                                      and leankor__ValueStream__c in:relatedVSIds
                                                      limit 49999]){
                Set< String > depIds = dependencyMap.containsKey(de.leankor__Predecessor__c) ? dependencyMap.get(de.leankor__Predecessor__c) : new Set < String > ();
                depIds.add(de.leankor__Successor__c);
                dependencyMap.put(de.leankor__Predecessor__c, depIds);
            }
            GanttTaskBoard.Dependentvaluestream.clear();
            for(String activityId : cardIds)
            {
                for(String str : dependencyMap.keySet())
                {
                    //dependentCardIds.add(str);
                    Set< String > strValues;
                    if (dependencyMap.keySet().contains(activityId) && str == activityId) {
                        //Update IsSuccessorRecalculate only when card is externally dependent
                        strValues = (Set< String > )dependencyMap.get(str);
                        dependentCardIds.addAll(strValues);
                        //get all N level successors
                        Set<String> tempIds = getSuccessorIds(strValues, dependencyMap);
                        dependentCardIds.addAll(tempIds);
                    }
                }
            }
       }
        catch(Exception ex){
            System.debug('Error : '+ex);
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }
        return  dependentCardIds;   
    }

    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Read KanbanCard's Sticker with card info
    Inputs:         String VSID,List < realTimeController.ChatterFeedStats > cfs, List<User> users
    Returns:        GlueforceData
    Date:           24.8.18
    ------------------------------------------------------------*/  
    public static realTimeController.GlueforceData readCardsWithStickers(String VSID, List <realTimeController.ChatterFeedStats> cfs, List<User> users) {

        List <realTimeController.ChatterFeedStats> kcWithChatterInfo = (cfs != null) ? cfs : new List <realTimeController.ChatterFeedStats>();
        users = users != null ? users : new List<User>();
        try {
            List<realTimeController.ChatterFeedStats> tempChatterInfo = new List<realTimeController.ChatterFeedStats >();
            Map<String, List<String>> mapKanbanSticker = new Map <String, List<String>>();
            List<String> KanbanIDs = new List <String> ();
            Set<String> stickerIDs = new Set<String>();
            
            for (leankor__KanbanCard__c kanbanCard : [Select 
                                                            Id, 
                                                            Name, 
                                            (Select leankor__Sticker__c, 
                                                    leankor__KanbanCard__c 
                                                From leankor__KanbanCard__c.leankor__KanbanCardStickers__r KanbanCardStickers
                                            )
                                                      From leankor__KanbanCard__c 
                                                      Where leankor__ValueStream__c = :VSID 
                                                      And leankor__isRecordDeleted__c = false 
                                                      Limit 9999]) {
                if (kcWithChatterInfo.isEmpty()) {   
                    realTimeController.ChatterFeedStats cardInfo = new realTimeController.ChatterFeedStats();
                    cardInfo.Name = kanbanCard.Name;
                    cardInfo.Id = kanbanCard.Id;
                    tempChatterInfo.add(cardInfo);
                }
    
                KanbanIDs.add(kanbanCard.Id);
    
                List < String > kStickers = new List < String > ();
                if (kanbanCard.leankor__KanbanCardStickers__r != null) { // Null check for related list
                    for (leankor__KanbanCardSticker__c kcs : kanbanCard.leankor__KanbanCardStickers__r) {
                        kStickers.add(kcs.leankor__Sticker__c);
                    }
                }
                stickerIDs.addAll(kStickers);
                mapKanbanSticker.put(kanbanCard.Id, kStickers);
            }
    
            // Add any temporary chatter info
            if (!tempChatterInfo.isEmpty()) {
                kcWithChatterInfo.addAll(tempChatterInfo);
            }
    
            // Fetch stickers
            Map<Id, leankor__Sticker__c> mapSticker = new Map<Id, leankor__Sticker__c> ();
            for (leankor__Sticker__c skr : [Select 
                                                Id, 
                                                Name, 
                                                (Select 
                                                        Id, 
                                                        ContentType 
                                                From Attachments) 
                                            From leankor__Sticker__c 
                                            Where Id In :stickerIDs 
                                            Order By Name 
                                            Limit 10000]) {         
                for (Attachment att : skr.Attachments) {               
                    att.Description = ''; // Using Base64.
                }
                mapSticker.put(skr.Id, skr);
            }
    
            Map <Id, List<leankor__Sticker__c>> mapStickerPerCard = new Map <Id, List<leankor__Sticker__c>> ();
            for (String kanbanCardId : KanbanIDs) {
                List<String> localStickers = mapKanbanSticker.get(kanbanCardId);
                List<leankor__Sticker__c> tempStickers1 = new List <leankor__Sticker__c > ();
                
                // Null check for localStickers list
                if (localStickers != null && !localStickers.isEmpty()) {
                    for (String sid : localStickers) {
                        if (mapSticker.containsKey(sid)) { // Null check for mapSticker
                            tempStickers1.add(mapSticker.get(sid));
                        }
                    }
                }
    
                tempStickers1.sort();
    
                // Sort stickers by order with attachments
                List<leankor__Sticker__c> sortedList = new List<leankor__Sticker__c>();
                for (Integer count = tempStickers1.size() - 1; count >= 0; count--) {
                    if (tempStickers1.get(count).Attachments != null && !tempStickers1.get(count).Attachments.isEmpty()) {
                        sortedList.add(tempStickers1.get(count));
                    }
                }
    
                if (!sortedList.isEmpty()) {
                    mapStickerPerCard.put(kanbanCardId, sortedList);
                }
            }
    
            // Set Kanban stickers in ChatterFeedStats
            for (realTimeController.ChatterFeedStats c : kcWithChatterInfo) {
                if (mapStickerPerCard.containsKey(c.Id)) { // Null check for mapStickerPerCard
                    c.KanbanStickers = mapStickerPerCard.get(c.Id);
                } else {
                    c.KanbanStickers = new List<leankor__Sticker__c>(); // Default to an empty list if null
                }
            }
        }
        catch (Exception ex) {
            throw new GanttTaskBoard.LeanException('Error : ' + ex.getMessage());
        }
        
        realTimeController.GlueforceData gfData = new realTimeController.GlueforceData(kcWithChatterInfo, users);
        return gfData;
    }
    
    
    public class DependencyMap {
        public Set<String> dependentCardIds;
        //public Set<String> externalDependentIds;
        public Set<String> externallyDependentVSIds;
        public Set<leankor__Dependency__c> externalDependencies;
    }
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Read n level Dependency map for External Dependency
    Inputs:         Set<String> cardIds
    Returns:        DependencyMap 
                    response will include List of  ext. Dep. VSIds and dependency records for updation
    Date:           Created for Sprint 46, Commented on 12.17.2018
    ------------------------------------------------------------*/  
    public static DependencyMap readExternallyDependentCards(Set<String> cardIds){
        Set<String> dependentCardIds = new Set<String>(); 
        DependencyMap depMap = new DependencyMap();
        //try{
            depMap.dependentCardIds= new Set<String>();
            //depMap.externalDependentIds= new Set<String>();
            depMap.externalDependencies= new Set<leankor__Dependency__c>();
            depMap.externallyDependentVSIds= new Set<String>();
            
            Map<String, DependencyMap> dependencyMap = new Map < String, DependencyMap> ();
            Map<String, leankor__ValueStream__c> vsMap = new Map<String, leankor__ValueStream__c>([select id from leankor__Valuestream__c where id  in (select leankor__Valuestream__c from leankor__KanbanCard__c where id IN : cardIds and leankor__isRecordDeleted__c = false) and leankor__isRecordDeleted__c = false limit 49999]);
            
            //Get all externally dependent VS ids grouped by Prdecessor's and Sucessor's VS
            Set<String> relatedVSIds = GanttTaskBoard.getExternallyDependentVSIds(vsMap.keySet());
            depMap.externallyDependentVSIds.addAll(relatedVSIds);
            vsMap.clear();
        
            //Retrieve all external dependencies
            for(leankor__Dependency__c de : [SELECT 
                                                    leankor__Predecessor__c,
                                                    leankor__Predecessor__r.leankor__ValueStream__c, 
                                                    leankor__Successor__c,
                                                    leankor__Successor__r.leankor__ValueStream__c,
                                                    leankor__ValueStream__c 
                                                FROM leankor__Dependency__c  
                                                Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard'  
                                                      and leankor__valuestream__r.leankor__IsTemplateBoard__c = false
                                                      and leankor__valuestream__r.leankor__isRecordDeleted__c = false
                                                      and leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                                      and leankor__Successor__r.leankor__isRecordDeleted__c = false
                                                      and leankor__ValueStream__c in:relatedVSIds]){
                DependencyMap depenMap= dependencyMap.containsKey(de.leankor__Predecessor__c) ? dependencyMap.get(de.leankor__Predecessor__c) : new DependencyMap ();
                
                depenMap.dependentCardIds= dependencyMap.containsKey(de.leankor__Predecessor__c) ? dependencyMap.get(de.leankor__Predecessor__c).dependentCardIds : new Set<String>();
                //depenMap.externalDependentIds= dependencyMap.containsKey(de.leankor__Predecessor__c)? dependencyMap.get(de.leankor__Predecessor__c).externalDependentIds :new Set<String>();
                //depenMap.externalDependentIds= dependencyMap.containsKey(de.leankor__Predecessor__c)? dependencyMap.get(de.leankor__Predecessor__c).externalDependentIds :new Set<String>();
                depenMap.externalDependencies= dependencyMap.containsKey(de.leankor__Predecessor__c)? dependencyMap.get(de.leankor__Predecessor__c).externalDependencies :new Set<leankor__Dependency__c>();
                
                depenMap.dependentCardIds.add(de.leankor__Successor__c);    
                depenMap.externalDependencies.add(de);              
                dependencyMap.put(de.leankor__Predecessor__c, depenMap);    
                            
                /*Set< String > depIds = dependencyMap.containsKey(de.leankor__Predecessor__c) ? dependencyMap.get(de.leankor__Predecessor__c) : new Set < String > ();
                depIds.add(de.leankor__Successor__c);
                dependencyMap.put(de.leankor__Predecessor__c, depIds);*/
            }

            GanttTaskBoard.Dependentvaluestream.clear();
            for(String activityId : cardIds)
            {
                for(String str : dependencyMap.keySet())
                {
                    //dependentCardIds.add(str);
                    Set< String > strValues;
                    if (dependencyMap.keySet().contains(activityId) && str == activityId) {
                        //Update IsSuccessorRecalculate only when card is externally dependent
                        DependencyMap deps= dependencyMap.get(str);
                        for(leankor__Dependency__c dep : deps.externalDependencies){
                            if(dep.leankor__Predecessor__r.leankor__ValueStream__c!=dep.leankor__Successor__r.leankor__ValueStream__c && !leankor__LeanConstants__c.getInstance().leankor__DisableAutoTranslationOfActivity__c){
                                dep.leankor__IsDependencyRecalculate__c =true;
                                //depMap.externalDependentIds.add(dep.Id);
                                depMap.externalDependencies.add(dep);
                            }
                        }
                        depMap.dependentCardIds.addAll(deps.dependentCardIds);
                        strValues = (Set< String >)deps.dependentCardIds;
                        dependentCardIds.addAll(strValues);
                        //get all N level successors
                        DependencyMap updatedDependencyMap = getSuccessors(strValues, dependencyMap);
                        depMap.dependentCardIds.addAll(updatedDependencyMap.dependentCardIds);
                        depMap.externalDependencies.addAll(updatedDependencyMap.externalDependencies);
                        //depMap.externalDependentIds.addAll(updatedDependencyMap.externalDependentIds);
                        //Set<String> tempIds = getSuccessorIds(strValues, dependencyMap);;
                        //dependentCardIds.addAll(updatedDependencyMap.dependentCardIds);
                    }
                }
            }
            //depmap.externallyDependentVSIds = relatedVSIds;
       /*}
        catch(Exception ex){
            System.debug('Error : '+ex);
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }*/
        //depMap.externalDependentIds.clear();
        depMap.dependentCardIds.clear();
        return  depMap;   
    }
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Read n level Successors for External Dependency
    Inputs:         Set<String> ids, Map<String, DependencyMap> dependencyRecordsMap
    Returns:        DependencyMap 
                    response will include List of  ext. Dependency record Id and dependency records for updation
    Date:           Created for Sprint 46, Commented on 12.17.2018
    ------------------------------------------------------------*/
    public static DependencyMap getSuccessors(Set<String> ids, Map<String, DependencyMap> dependencyRecordsMap)
    {
        DependencyMap tempDepMap = new DependencyMap();
        tempDepMap.dependentCardIds= new Set<String>();
        //tempDepMap.externalDependentIds= new Set<String>();
        tempDepMap.externalDependencies= new Set<leankor__Dependency__c>();
        Set<String> strList = new Set<String>();
        //try{
            //externai id map contains predecessor as key and its respective successor id List in value
            for(String str : ids)
            {
                if(dependencyRecordsMap.size()>0 && dependencyRecordsMap.containsKey(str))
                {
                    //Update IsSuccessorRecalculate only when card is externally dependent
                    DependencyMap deps= dependencyRecordsMap.get(str);
                    for(leankor__Dependency__c dep : deps.externalDependencies){
                        if(dep.leankor__Predecessor__r.leankor__ValueStream__c!=dep.leankor__Successor__r.leankor__ValueStream__c){
                            //dep.leankor__IsDependencyRecalculate__c =true;
                            //tempDepMap.externalDependentIds.add(dep.leankor__Successor__c);
                            //tempDepMap.externalDependentIds.add(dep.Id);
                            tempDepMap.externalDependencies.add(dep);
                        }
                    }
                    Set<String> tempList = (Set<String>)dependencyRecordsMap.get(str).dependentCardIds;
                    strList.addAll(tempList);
                    if(tempList.size()>0)
                    {
                        //it may be possible successor can be predessor in other dependencies so retrieve all respective successors.
                        DependencyMap tempMap = getSuccessors(tempList,dependencyRecordsMap);
                        tempDepMap.dependentCardIds.addAll(tempMap.dependentCardIds);
                        //tempDepMap.externalDependentIds.addAll(tempMap.externalDependentIds);
                        tempDepMap.externalDependencies.addAll(tempMap.externalDependencies);
                        //strList.addAll(getSuccessorIds(tempList,dependencyRecordsMap));
                    }
                }
            }
        /*}
        catch(Exception ex)
        {
            System.debug('Error : '+ex);
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }*/
        
        return tempDepMap;
    }
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    We need to add ED successor board's VSIds in JSONdata for broadcast when Verb is ManageDependency
    Inputs:         ManageStateChangeWrapper mscWrapperInstance
    Returns:        -- 
    Date:           Created for Sprint 46, Commented on 12.17.2018
    ------------------------------------------------------------*/
    public static ManageStateChangeWrapper manageDependencies(ManageStateChangeWrapper mscWrapperInstance){
        leankor.RealTimeController.CardStreamingPackage cspInstance = (leankor.RealTimeController.CardStreamingPackage)JSON.deserialize(mscWrapperInstance.listOfJSON[0], leankor.RealTimeController.CardStreamingPackage.class);
        //Get N level external Dependent VSIds
        Set<String> dependentVSIds = GanttTaskBoard.getExternallyDependentVSIds(new Set<String>{cspInstance.ValueStream});
        String SomeJSONData = mscWrapperInstance.listOfJSON[0].removeEndIgnoreCase('}');
        SomeJSONData +=  ',"'+'externalIds'+'":'+json.serialize(dependentVSIds)+'}';
        //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
        Boolean isGSEnabled = false;
        if (isGSEnabled && dependentVSIds.size()>0) {
            realTimeController.externalCardIDs.addAll(dependentVSIds);        
        }            
        mscWrapperInstance.listOfJSON[0] = SomeJSONData;
        return mscWrapperInstance;
    }
    
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Update Pred/Succ activity when external dependent activity is deleted
    Inputs:         Set<String> 
    Returns:        sObject KanbanCard
    Date:           Created for Sprint 46, Commented on 12.17.2018
    ------------------------------------------------------------*/
    public static leankor.RealTimeController.KanbanCardsData updateExternallyDependentCards(Set<String> cardIds) {
        RealTimeController.KanbanCardsData kanbans = new RealTimeController.KanbanCardsData(); 
        //try{
        List<leankor__KanbanCard__c> kcList = new List<leankor__KanbanCard__c>();
            for(leankor__Dependency__c dep : [SELECT 
                                                Id, 
                                                leankor__predecessor__c, 
                                                leankor__Successor__c 
                                            FROM leankor__Dependency__c 
                                            WHERE (leankor__predecessor__c IN: cardIds OR leankor__Successor__c IN: cardIds)
                                                AND (leankor__predecessor__r.leankor__IsExternallyDependent__c = true 
                                                AND leankor__Successor__r.leankor__IsExternallyDependent__c = true) limit 49999]){
                if(cardIds.contains(dep.leankor__predecessor__c)){
                    cardIds.remove(dep.leankor__predecessor__c);
                } 
                if(cardIds.contains(dep.leankor__Successor__c)){
                    cardIds.remove(dep.leankor__Successor__c);
                }
            }
                for(String id : cardIds){
                kcList.add(new leankor__KanbanCard__c(
                                    Id = id,
                                    leankor__IsExternallyDependent__c = false));
                }
            kanbans.recordIds = cardIds.size()>0 ? cardIds: new Set<String>();
            kanbans.kanbanCards = kcList.size()>0 ? kcList : new List<leankor__KanbanCard__c>();
        /*} catch(Exception ex){
            System.debug('Error : '+ex.getMessage());
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage());
        }*/
        
        return kanbans;
    }
    
    
    public static List <leankor__kanbancard__c> readKcUpdatePvCards(Set<String > parentCardIds){
        List <leankor__kanbancard__c> kanbanList = new List <leankor__kanbancard__c>();
        
        for (leankor__kanbancard__c kanban : [SELECT 
                                                Id, 
                                                Recordtype.Name, 
                                                leankor__DueDate__c,
                                                leankor__StartDate__c,
                                                leankor__IsExternallyDependent__c,
                                                leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, 
                                                leankor__Budgeted_Time__c, 
                                                leankor__BudgetTimeComplete__c, 
                                                leankor__BudgetTimeRemaining__c, 
                                                leankor__DueDateTime__c, 
                                                leankor__Valuestream__r.leankor__PortfolioMode__c, 
                                                leankor__StartDateTime__c, 
                                                leankor__PercentComplete2__c, 
                                                leankor__CardID__c, 
                                                leankor__Point__c, 
                                                leankor__GUID__c, 
                                                leankor__KanbanCardTemplate__r.Name, 
                                                Name, 
                                                leankor__Top__c, 
                                                leankor__Bottom__c, 
                                                leankor__Left__c, leankor__Width__c, 
                                                leankor__Height__c, 
                                                leankor__X__c, 
                                                leankor__Y__c, 
                                                leankor__JSONDefinition__c, 
                                                leankor__JSONData__c, 
                                                leankor__KanbanCardTemplate__c, 
                                                leankor__color__c, 
                                                leankor__AcceptanceCriteria__c, 
                                                leankor__DescriptionLong__c, 
                                                leankor__EffortRemaining__c, 
                                                leankor__DurationUnits__c, 
                                                leankor__Priority__c, 
                                                OwnerID, 
                                                leankor__ValueStreamCardLink__c, 
                                                leankor__ValueStreamLink__c, 
                                                leankor__ValueStream__c, 
                                                leankor__Account__c, 
                                                leankor__Opportunity__c, 
                                                leankor__Contact__c, 
                                                leankor__Case__c, 
                                                leankor__Order__c, 
                                                leankor__OnBudget__c, 
                                                leankor__OnQuality__c, 
                                                leankor__OnTime__c, 
                                                leankor__ZoneGUID__c, 
                                                leankor__MasterContainer__c, 
                                                leankor__Swimlane__c, 
                                                leankor__Zone__c, 
                                                leankor__Valuestream__r.leankor__Boardtype__c, 
                                                leankor__ValueStreamLink__r.leankor__Boardtype__c,
                                                leankor__UrlLink__c,
                                                leankor__HarveyBallDoneDate__c,
                                                leankor__PromiseCompletionDate__c,
                                                leankor__Valuestream__r.leankor__TaskDatecheck__c,
                                                leankor__EstimatedDuration__c,
                                                leankor__IsSuccessorRecalculate__c,
                                                leankor__TemplateBoard__c,
                                                leankor__IsRecordDeleted__c,
                                                leankor__IsOnHold__c,
                                                leankor__IsAtRisk__c,
                                                leankor__ProjectRoom__c 
                                            FROM leankor__kanbancard__c
                                            WHERE /*(
                                                (leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                                 AND leankor__ValueStreamCardLink__c IN: parentCardIds 
                                                 AND leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                                                 )
                                                 OR
                                                 (leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c = false 
                                                 AND leankor__ValueStreamCardLink__c IN: parentCardIds  
                                                 )
                                                 OR
                                                 ( leankor__ValueStreamCardLink__c IN: parentCardIds 
                                                 AND leankor__ValueStreamCardLink__r.leankor__Boardtype__c = 'UberBoard'
                                                 AND leankor__isRecordDeleted__c = false)
                                             )*/
                                             (
                                                 Leankor__ValueStreamCardLink__c IN: parentCardIds 
                                                 AND Leankor__isRecordDeleted__c = false
                                                 AND Leankor__ValueStream__r.Leankor__isRecordDeleted__c = false
                                                 AND Leankor__MasterContainer__r.Leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST
                                                 AND (
                                                     (leankor__ValueStream__r.leankor__IsTemplateBoard__c = false AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = false)
                                                     OR (leankor__ValueStream__r.leankor__IsTemplateBoard__c = true AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = true)
                                                 )
                                             )
                                             OR 
                                             (   ID IN: parentCardIds 
                                                 AND (leankor__Valuestream__r.leankor__PortfolioMode__c = true 
                                                         OR leankor__Valuestream__r.leankor__Boardtype__c = 'Portfolio View' 
                                                         OR leankor__Valuestream__r.leankor__Boardtype__c = 'UberBoard'
                                                     )
                                                 AND leankor__isRecordDeleted__c = false
                                                 AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                             )
                                            LIMIT 49999]) {

            if(kanban.leankor__Valuestream__c != null && kanban.leankor__ProjectRoom__c != null){
                kanbanList.add(kanban);
            }
        }  

        return kanbanList;                          
    }
    
    
    // Date : 03/05/19 - Helper method of manageStateChange.
    public static leankor__kanbancard__c readLinkedCard(String  cardId){
        return  [Select leankor__ValueStreamCardLink__r.Name, 
                    leankor__ValueStreamCardLink__r.leankor__boardtype__c, 
                    leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c, 
                    leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                    leankor__ValueStreamLink__c, 
                    leankor__MasterContainer__r.leankor__Type__c 
                    from leankor__kanbancard__c 
                    where Id = :cardId  limit 1];
    }
    

    // Date : 03/05/19 - Helper method of removeLinkedCard
    public static List<leankor__KanbanCard__c>  readremoveLinkedCard(List<String> cardIds){
        //return    [SELECT Id FROM leankor__KanbanCard__c WHERE (leankor__GUID__c IN :cardIds OR leankor__ValueStream__r.leankor__ProjectRoom__c IN : cardIds)]; 
        List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
        if (cardIds.size() > 0) {
            cards = (cardIds[0] InstanceOf Id && Id.valueOf(cardIds[0]).getSObjectType().getDescribe().getName() == 'leankor__ProjectRoom__c')
                ? [SELECT Id FROM leankor__KanbanCard__c WHERE leankor__ValueStream__r.leankor__ProjectRoom__c IN: cardIds]
                : [SELECT Id FROM leankor__KanbanCard__c WHERE leankor__GUID__c IN: cardIds];
        }
        return cards;
    }


    //Date : 09/05/19 - Helper method of updateBulkCards 
    public static List<leankor__KanbanCard__c> readupdateBulkCard(List<String> cardIds) {
        return  [SELECT 
                    Id, 
                    leankor__TemplateBoard__c,
                    leankor__MasterContainer__r.leankor__Type__c,
                    leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                    leankor__ValueStreamLink__r.leankor__Boardtype__c, 
                    leankor__UrlLink__c, 
                    leankor__Zone__c, leankor__Point__c, 
                    leankor__CardID__c, 
                    leankor__AcceptanceCriteria__c, 
                    leankor__Account__c, 
                    leankor__ActualDuration__c, 
                    leankor__Actual_Time_Taken__c, 
                    leankor__Bottom__c, 
                    leankor__Budgeted_Time__c, 
                    leankor__BudgetTimeComplete__c, 
                    leankor__BudgetTimeRemaining__c, 
                    leankor__CardDetails__c, 
                    leankor__Case__c, 
                    leankor__CmpID__c,
                    leankor__Color__c, 
                    leankor__CompletionVariance__c, 
                    leankor__Contact__c, 
                    leankor__CSSLayout__c, 
                    leankor__DateColor__c, 
                    leankor__DescriptionLong__c, 
                    leankor__Description__c, 
                    leankor__DueDateTime__c, 
                    leankor__DueDate__c, 
                    leankor__DurationUnits__c, 
                    leankor__EstimatedDuration__c, 
                    leankor__EffortRemaining__c,
                    leankor__GUID__c, 
                    leankor__HarveyBallDoneDate__c, 
                    leankor__Height__c, 
                    leankor__IsCompletedOnTime__c, 
                    leankor__JSONData__c, 
                    leankor__JSONDefinition__c, 
                    leankor__KanbanCardTemplate__c, 
                    leankor__Left__c, 
                    leankor__OnBudget__c, 
                    leankor__OnQuality__c, 
                    leankor__OnTime__c, 
                    leankor__Opportunity__c, 
                    leankor__Order__c,
                    leankor__PercentComplete2__c, 
                    leankor__Priority__c, 
                    leankor__PromiseCompletionDate__c, 
                    leankor__StartDateTime__c, 
                    leankor__StartDate__c, 
                    leankor__State__c, 
                    leankor__Title__c, 
                    leankor__Top__c, 
                    leankor__ValueStreamCardLink__c, 
                    leankor__ValueStreamLink__c, 
                    leankor__ValueStream__c, 
                    leankor__Width__c, leankor__X__c, 
                    leankor__MasterContainer__C, 
                    leankor__Swimlane__c, leankor__Y__c, 
                    leankor__ZoneGUID__c, 
                    Name, OwnerId, LastModifiedDate, 
                    leankor__ValueStream__r.leankor__BoardType__C, 
                    leankor__KanbanCardTemplate__r.leankor__color__c,
                    leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                    leankor__Monday__c,
                    leankor__Tuesday__c,
                    leankor__Wednesday__c,
                    leankor__Thursday__c,
                    leankor__Friday__c,
                    leankor__Saturday__c,
                    leankor__Sunday__c
                FROM leankor__Kanbancard__c 
                WHERE Id IN: cardIds 
                    AND leankor__IsRecordDeleted__c = false
                ORDER BY leankor__Order__c
                LIMIT 9999]; // LIMIT 9999 because we only update this many record at a time.
    }
    
    
    // Date : 09/05/19 - Helper method of getTask 
    public static leankor__KanbanCard__c readTask(String kanbanId) {
        return [SELECT 
                    Id, 
                    Name, 
                    leankor__Valuestream__c, 
                    leankor__Valuestream__r.Name, 
                    leankor__Valuestream__r.leankor__ProjectRoom__c, 
                    leankor__Valuestream__r.leankor__ProjectRoom__r.Name 
                FROM leankor__kanbancard__c 
                WHERE Id =: kanbanId]; 
    }
    
    
    // Tilak Raj Mahale:23.04.2020 - To get data from without sharing
    public static String removeSubscriberHelper(String kanbanID, String subscriberId) {
        //Check CRUD / FLC behavior
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();
        if (
            !subscriberBehavior.isAccessible() ||
            !subscriberBehavior.isUpdateable()
        ) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        if (leankor__KanbanCardTemplate__c.sObjectType.getDescribe().isDeletable()) {
            List<leankor__Subscriber__c> subscribers = [Select Id,
                    leankor__KanbanCard__c, 
                    leankor__Preference__c, 
                                                                leankor__SubscriberId__c 
                                                            From leankor__Subscriber__c 
                                                            Where leankor__KanbanCard__c = :kanbanId
                                                                And leankor__SubscriberID__c = : subscriberId 
                                                            Limit 10000];

            for (leankor__Subscriber__c subscriber : subscribers) {
                subscriber.leankor__KanbanCard__c = null;
                subscriber.leankor__Preference__c = null;
                subscriber.leankor__SubscriberId__c = null;
            }
            if (!subscribers.isEmpty()) {
                try {
                    update subscribers;
                } catch (DmlException e) {
                    throw new Util.LeanException('ERROR:' + e.getMessage()); 
                }
            } else {
                return '';
            }
        }
        
        return 'success';
    }


    /**
     * Tilak Raj Mahale:15.05.2020 - To get the KC data from without sharing environment for new sObject RealTimeController.updateParentCards method.
     */
    public static List <leankor__kanbancard__c> getParentRecords(Set<String> parentCardIds, Map<Id, leankor.Util.WorkWeek> workWeekMap) {
        List<leankor__kanbancard__c> kanbanList = new List<leankor__kanbancard__c>();
        Map<Id, Boolean> vsMap = new Map<Id, Boolean>();
        List<String> MCTypeFilter = new List<String>{'Backlog', 'Regular', 'Archive'}; // In place of != 'Template'

        kanbanList = [SELECT 
                            Id,
                            leankor__BoardType__c, 
                            leankor__Budgeted_Time__c, 
                            leankor__BudgetTimeComplete__c, 
                            leankor__BudgetTimeRemaining__c, 
                            leankor__DueDate__c,
                            leankor__DueDateTime__c, 
                            leankor__DurationUnits__c, 
                            leankor__EstimatedDuration__c,
                            leankor__GUID__c,
                            leankor__HarveyBallDoneDate__c,
                            leankor__IsSuccessorRecalculate__c,
                            leankor__MasterContainer__r.leankor__Type__c,
                            leankor__PercentComplete2__c, 
                            leankor__ProjectRoom__c,
                            leankor__StartDate__c,
                            leankor__StartDateTime__c, 
                            leankor__TemplateBoard__c,                           
                            leankor__ValueStream__c, 
                            leankor__Valuestream__r.leankor__Boardtype__c, 
                            leankor__Valuestream__r.leankor__PortfolioMode__c, 
                            leankor__PromiseCompletionDate__c,
                            leankor__Valuestream__r.leankor__TaskDatecheck__c,
                            leankor__valuestream__r.leankor__SevenDayWorkWeek__c,
                            leankor__ValueStreamCardLink__c,
                            Recordtype.Name, 
                            leankor__IsConstraintRecalculate__c,
                            (SELECT 
                                    Id,
                                    Leankor__BudgetTimeRemaining__c,
                                    Leankor__Budgeted_Time__c,
                                    Leankor__DueDateTime__c,
                                    Leankor__PercentComplete2__c,
                                    Leankor__StartDateTime__c
                                FROM Leankor__Kanban_Cards__r 
                                WHERE Leankor__IsRecordDeleted__c = false
                                    AND Leankor__ValueStream__r.Leankor__isRecordDeleted__c = false 
                                    AND Leankor__MasterContainer__r.Leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST
                                    AND (
                                            (leankor__ValueStream__r.leankor__IsTemplateBoard__c = false AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = false)
                                            OR (leankor__ValueStream__r.leankor__IsTemplateBoard__c = true AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = true)
                                        )
                            )
                        FROM leankor__kanbanCard__c
                        WHERE Id IN: parentCardIds
                            AND (leankor__Valuestream__r.leankor__PortfolioMode__c = true 
                                    OR leankor__Valuestream__r.leankor__Boardtype__c = 'Portfolio View' 
                                    OR leankor__Valuestream__r.leankor__Boardtype__c = 'UberBoard') 
                            AND leankor__isRecordDeleted__c = false
                            AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                        LIMIT 49999];

        // Removing the cards if valuestream or project has been deleted
        Integer index = 0;
        while (index < kanbanList.size()) {
            leankor__kanbanCard__c kanban = kanbanList.get(index);
            if (String.isBlank(kanban.leankor__Valuestream__c) ||  String.isBlank(kanban.leankor__ProjectRoom__c)) {
                kanbanList.remove(index);
            } else {
                vsMap.put(kanban.leankor__ValueStream__c, kanban.leankor__valuestream__r.leankor__SevenDayWorkWeek__c);
                index++;
            }
        } 

        // Create the workweek instance and put into the map
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> blackoutMap = leankor.RealTimeControllerHelper.getBlackOutRecords(vsMap.keySet());
        for (Id vs : vsMap.keySet()) {
            leankor.Util.WorkWeek work = new leankor.Util.WorkWeek(vsMap.get(vs) ? 7: 5, blackoutMap.get(vs));
            workWeekMap.put(vs, work);
        }

        return kanbanList;                          
    }


    /**
     * Tilak Raj Mahale:15.05.2020 - To get the KC data from without sharing environment for new sObject RealTimeController.manageBulkStreaming method.
     */
    public static Map<Id, leankor__kanbanCard__c> readKanbanCardMap(List<leankor__KanbanCard__c> kanbanCards) {
        return new Map<Id, leankor__kanbanCard__c> (
            [Select 
                Id,
                leankor__GUID__c,
                leankor__BoardType__c,
                leankor__DueDate__c, 
                leankor__DueDateTime__c,
                leankor__IsSuccessorRecalculate__c,
                leankor__MasterContainer__c, 
                leankor__MasterContainer__r.leankor__Type__c,
                leankor__ProjectRoom__c,
                leankor__StartDate__c,
                leankor__StartDateTime__c, 
                leankor__TemplateBoard__c,
                leankor__ValueStream__c, 
                leankor__ValueStream__r.Name,                           
                leankor__ValueStreamCardLink__c,
                leankor__ValueStreamCardLink__r.leankor__BoardType__c,
                leankor__ValueStreamLink__c,
                leankor__ValueStream__r.leankor__BoardType__c, 
                leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c,
                leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,   
                leankor__ValueStream__r.leankor__TaskDatecheck__c,
                leankor__ValueStream__r.leankor__projectRoom__c, 
                leankor__ZoneGUID__c,
                leankor__Zone__c,
                Name, 
                OwnerId, 
                RecordType.Name,
                leankor__IsConstraintRecalculate__c,
                leankor__Monday__c,
                leankor__Tuesday__c,
                leankor__Wednesday__c,
                leankor__Thursday__c,
                leankor__Friday__c,
                leankor__Saturday__c,
                leankor__Sunday__c
            From leankor__kanbancard__c 
            Where Id In: kanbanCards
                And leankor__isRecordDeleted__c = false
                And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
            Limit 9999]
        );
    }









    /*********************** Salesforce Security ViewGanttController  - Methods ************************************/

    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    check access for miniature cards
    Inputs:         List<String> recordIds
    Returns:        List<CheckAccessWrapper>
    ------------------------------------------------------------*/
    public static List < leankor.ViewGanttController.CheckAccessWrapper > checkAccessForBoards(List < String > recordIds) {
        List < leankor.ViewGanttController.CheckAccessWrapper > acList = new List < leankor.ViewGanttController.CheckAccessWrapper > ();
        Map < Id,leankor__ProjectRoom__c > vsProMap = new Map < Id,leankor__ProjectRoom__c > ();
        List < String > projectIds = new List < String > ();
        List < String > folderIds = new List < String > ();
        Map < String,Boolean > proMap = new Map < String,Boolean > ();
        Map < String,Boolean > folMap = new Map < String,Boolean > ();
        List < String > allIds = new List < String > ();
        Map < String,Boolean > allObjMap = new Map < String,Boolean > ();

        try {
            List < leankor__ProjectRoom__c > prjList = [SELECT leankor__Portfolio__c, 
                                                            leankor__Portfolio__r.Name, 
                                                            Id, 
                                                            Name,
                                                            (SELECT Id, Name, leankor__ProjectRoom__c 
                                                                FROM leankor__Valuestreams__r 
                                                                WHERE Id IN: recordIds 
                                                                    AND leankor__IsRecordDeleted__c = false)
                                                        FROM leankor__ProjectRoom__c 
                                                        WHERE Id IN (SELECT leankor__ProjectRoom__c 
                                                                FROM leankor__Valuestream__c 
                                                                WHERE Id IN: recordIds 
                                                                    AND leankor__IsRecordDeleted__c = false)
                                                        LIMIT 49999];

            for (leankor__ProjectRoom__c pr: prjList) {
                projectIds.add(pr.Id);
                folderIds.add(pr.leankor__Portfolio__c);

                for (leankor__Valuestream__c vs: pr.leankor__Valuestreams__r) {
                    vsProMap.put(vs.Id, pr);
                }

            }
            /* RS 06/05/2019 Modified for security role 
            List < UserRecordAccess > userRecordPro = [SELECT RecordId, HasReadAccess
                FROM UserRecordAccess
                WHERE UserId = : userinfo.getuserid()
                    AND RecordId IN: projectIds];

            for (UserRecordAccess userPro: userRecordPro) {
                proMap.put(userPro.RecordId, userPro.HasReadAccess);
            }

            List < UserRecordAccess > userRecordPro1 = [SELECT RecordId, HasReadAccess
                FROM UserRecordAccess
                WHERE UserId = : userinfo.getuserid()
                    AND RecordId IN: folderIds];

            for (UserRecordAccess userPro: userRecordPro1) {
                folMap.put(userPro.RecordId, userPro.HasReadAccess);
            }
            
            */
            allIds.addAll(folderIds);
            allIds.addAll(projectIds);
            allIds.addAll(recordIds);
            
            List < UserRecordAccess > userRecordPro1 = [SELECT 
                                                            RecordId, 
                                                            HasReadAccess
                                                        FROM UserRecordAccess
                                                        WHERE UserId =: userinfo.getuserid()
                                                            AND RecordId IN: allIds];

            for (UserRecordAccess userPro: userRecordPro1) {
                allObjMap.put(userPro.RecordId, userPro.HasReadAccess);
            }
            
            for (String s: recordIds) {
                leankor.ViewGanttController.CheckAccessWrapper ac = new leankor.ViewGanttController.CheckAccessWrapper();
                String proId = vsProMap.get(s).Id;
                String folId = vsProMap.get(s).leankor__Portfolio__c;
                //ac.hasAccess = proMap.get(proId) ? folMap.get(folId) : proMap.get(proId);
                ac.hasAccess = allObjMap.get(s) ? (allObjMap.get(proId) ? allObjMap.get(folId) : allObjMap.get(proId)): allObjMap.get(s);
                ac.folder = vsProMap.get(s).leankor__Portfolio__r.Name;
                ac.project = vsProMap.get(s).Name;
                ac.valuestream = s;
                acList.add(ac);
            }

        } catch (Exception e) {
            throw new Util.LeanException('ERROR:' + e.getMessage()); 
        }

        return acList;
    }


    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Get list of activities whose dates are not equal 
                    with its miniatures min StartDate and max DueDate
                    Used on VF page PlanningModeViolations
    Inputs:         --
    Returns:        List<leankor__KanbanCard__c> 
    ------------------------------------------------------------*/
    public static List<leankor__KanbanCard__c> getViolatedActivities() {
        List<leankor__KanbanCard__c> returnKBData= new List<leankor__KanbanCard__c>();
        
        try {
            // Modify queries to fix 200k record issue
            List<AggregateResult> kcAgrChild = [SELECT Min(Leankor__StartDate__c) StartDate, 
                                                        Max(Leankor__DueDate__c) DueDate,
                                                        Leankor__ValuestreamCardLink__c ParentId 
                                                    FROM Leankor__KanbanCard__c 
                                                    WHERE Leankor__Valuestream__r.Leankor__BoardType__c IN: BOARDTYPEFILTERS_CONST 
                                                        AND Leankor__ValuestreamCardLink__r.Leankor__BoardType__c ='Uberboard' 
                                                        AND Leankor__IsRecordDeleted__c = false 
                                                        AND Leankor__Valuestream__r.Leankor__IsRecordDeleted__c = false 
                                                        AND Leankor__ValuestreamCardLink__r.RecordType.Name = 'ActivityCard' 
                                                    GROUP BY Leankor__ValuestreamCardLink__c 
                                                    LIMIT 49999];
            Map<String, AggregateResult> agDataMap = new Map<String, AggregateResult>();
            List<Id> parentCardIds = new List<Id>();

            for(AggregateResult ag : kcAgrChild){
                if(String.isNotBlank((String)ag.get('ParentId'))){
                    parentCardIds.add((String)ag.get('ParentId'));
                    agDataMap.put((String)ag.get('ParentId'), ag);
                }
            }

            List<leankor__KanbanCard__c> kcParent = [SELECT Id, 
                                                            Name, 
                                                            leankor__StartDateTime__c, 
                                                            leankor__DueDateTime__c, 
                                                            leankor__StartDate__c, 
                                                            leankor__ProjectRoom__c, 
                                                            leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__Portfolio__r.Name, 
                                                            leankor__Valuestream__c,leankor__Valuestream__r.Name,  
                                                            leankor__DueDate__c 
                                                        FROM leankor__kanbanCard__c 
                                                        WHERE Id IN: parentCardIds 
                                                            AND leankor__IsRecordDeleted__c = false 
                                                            AND leankor__Valuestream__r.leankor__IsRecordDeleted__c = false 
                                                        LIMIT 999];
            for (leankor__KanbanCard__c kcP : kcParent) {
                AggregateResult childData = agDataMap.get(kcP.Id);
                if ((childData.get('StartDate')!= kcp.leankor__StartDate__c) || (childData.get('DueDate')!= kcp.leankor__DueDate__c)) {
                    returnKBData.add(kcp);
                }
            }
        } catch(Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }

        return returnKBData;
    }


    /*
      Date :27/04/19 
    */
    public static List<leankor__ValueStream__c> readDefaultBoard(String  projectRoomID) {
        return [SELECT 
                    Id, 
                    leankor__UrlLink__c, 
                    leankor__BoardType__c, 
                    leankor__ValueStreamLink__c, 
                    leankor__ValueStreamCardLink__c, 
                    leankor__ProjectRoom__c, 
                    leankor__ProjectRoom__r.name,
                    Name, 
                    UserRecordAccess.HasEditAccess, 
                    UserRecordAccess.HasDeleteAccess,
                    UserRecordAccess.HasReadAccess,
                    leankor__DisableCalendarView__c 
                FROM leankor__ValueStream__c
                WHERE leankor__ProjectRoom__c =: projectRoomID 
                    AND leankor__IsRecordDeleted__c = false
                ORDER BY Name 
                LIMIT 49999];                                               
    }

    
    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Get the list of project for with Shring class.
    Inputs:         List<leankor__Portfolio__c>
    Returns:        List<leankor__ProjectRoom__c> 
    ------------------------------------------------------------*/

   
    public static List<leankor__ProjectRoom__c> getAllProjectOfFolderWithoutSharing(List<leankor__Portfolio__c> portfolioId) {
        return [Select 
                      Id, 
                      Name ,
                      UserRecordAccess.HasEditAccess 
                  From leankor__ProjectRoom__c 
                  Where leankor__Portfolio__c In :portfolioId 
                  Limit 10000];
    }
    
    
    public static List < leankor__KanbanCard__c > getKanbanCardsHelper(String valueStreamId) {
        List < leankor__KanbanCard__c > kanbanCards = new List < leankor__KanbanCard__c > ();
        leankor__valuestream__c vs = [SELECT leankor__boardtype__c FROM leankor__valuestream__c WHERE Id =: valueStreamId LIMIT 1];
        // yj 19.01.2017 check uberboard for added fiter for that card has set as schedule mode 'EffortDriven'
        // then that card should not make parent of any card.
        
        if (vs.Leankor__boardtype__c == 'UberBoard') {
            Set<Id> kcIds = new Set<Id>();
            for(Leankor__ScheduleMode__c sm: [SELECT Leankor__KanbanCard__c, 
                                                  Leankor__Mode__c 
                                                FROM Leankor__ScheduleMode__c
                                                WHERE Leankor__KanbanCard__r.Leankor__valuestream__c =: valueStreamId]){
                if(sm.Leankor__Mode__c != 'EffortDriven'){
                    kcIds.add(sm.Leankor__KanbanCard__c);
                }
            }

            if(!kcIds.isEmpty()){
                kanbanCards = 
                    [SELECT 
                            Id,
                            Name,
                            Leankor__CardID__c,
                            Leankor__AcceptanceCriteria__c,
                            Leankor__Title__c,
                            Leankor__ValueStream__c,
                        	(Select Id,
                                leankor__ConstraintDateTime__c,
                                leankor__ScheduleConstraint__r.leankor__Type__c
                            From leankor__ScheduleModes__r
                            Limit 1) 
                        FROM Leankor__KanbanCard__c
                        WHERE Leankor__ValueStream__c =: valueStreamId 
                            AND recordtype.name = 'ActivityCard' 
                            AND Id IN: kcIds
                            AND Leankor__isRecordDeleted__c = false
                            AND Leankor__ValueStream__r.Leankor__isRecordDeleted__c = false 
                        LIMIT 49999];
            }
            //RS 27.07.2018 Added a query for milestone linking on gantt. 
            List <leankor__KanbanCard__c> milestoneCards = 
                [SELECT 
                        Id,
                        Name,
                        leankor__CardID__c,
                        leankor__AcceptanceCriteria__c,
                        leankor__Title__c, 
                        leankor__ValueStream__c ,
                        (Select Id,
                                leankor__ConstraintDateTime__c,
                                leankor__ScheduleConstraint__r.leankor__Type__c
                            From leankor__ScheduleModes__r
                            Limit 1) 
                    FROM leankor__KanbanCard__c
                    WHERE leankor__ValueStream__c =: valueStreamId  
                        AND recordtype.name = 'MileStoneCard'
                        AND leankor__isRecordDeleted__c = false
                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                    LIMIT 49999];

            if (milestoneCards != null) {
                kanbanCards.addAll(milestoneCards);
            }
            
        } else {   
            kanbanCards = 
                [SELECT 
                        Id,
                        Name,
                        leankor__CardID__c,
                        leankor__AcceptanceCriteria__c,
                        leankor__Title__c, 
                        leankor__ValueStream__c
                    FROM leankor__KanbanCard__c
                    WHERE leankor__ValueStream__c =: valueStreamId  
                        AND recordtype.name = 'ActivityCard' 
                        AND leankor__isRecordDeleted__c = false
                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                    LIMIT 49999];
        }
        
        return kanbanCards;
    }
    
 
    public static List<leankor__ValueStream__c> readPlanBoard(Set<String> valuestreamIDs){
        // Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
        List <leankor__ValueStream__c> boardList = new List <leankor__ValueStream__c>();
        
        for(leankor__ValueStream__c vs: [SELECT 
                                            Id,
                                            leankor__Isrecalculate__c,
                                            leankor__ProjectRoom__c,
                                            leankor__ProjectRoom__r.name,
                                            leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c,
                                            leankor__SevenDayWorkWeek__c,
                                            leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c,
                                            UserRecordAccess.HasEditAccess ,
                                            IsScheduleRecalculate__c,
                                            leankor__ProjectBoardEndDateTime__c,
                                            leankor__ProjectBoardStartDateTime__c,
                                            leankor__ScheduleBackward__c,
                                            leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c
                                        FROM leankor__ValueStream__c 
                                        WHERE Id IN : valuestreamIDs 
                                            AND leankor__Boardtype__c = 'UberBoard' 
                                            //AND leankor__ProjectRoom__c != Null 
                                            AND leankor__IsTemplateBoard__c = false
                                            AND leankor__isRecordDeleted__c = false
                                        LIMIT 49999]){

            if(vs.leankor__ProjectRoom__c != null){
                boardList.add(vs);
            }       
        }
        
        return boardList;
    }


    public static leankor__ValueStream__c readTaskValueStream(String valueStreamId) {
        return [SELECT Name, leankor__ProjectRoom__c, leankor__projectroom__r.Name FROM leankor__ValueStream__c WHERE Id =: valueStreamId LIMIT 1];
    }


    /**
     * Tilak Raj Mahale: 08.06.2020 - We are no longer considering the project for template condition from now on we only considering value streams.
     */
    public static List<leankor__KanbanCard__c> getMiniatureCards(Set<String> activityIds) {
        List<leankor__KanbanCard__c> miniatures = new List<leankor__KanbanCard__c>(); 
        List<String> boardTypeFilter = new List<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
		//List<String> MCTypeFilter = new List<String>{'Backlog', 'Regular', 'Archive'};
         //22/feb/2023 : Changes added for showing constraint type and constraint date of miniture. so that we added Schedulemode in Query.
        for(leankor__KanbanCard__c miniature : [SELECT 
                                            Id, 
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
                                            leankor__EstimatedDuration__c,
                                            leankor__DurationUnits__c,                                                                                     
                                            leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                            leankor__KanbanCardTemplate__r.leankor__Title__c,
                                            leankor__MasterContainer__r.leankor__Type__c,
                                            (Select Id,
                                                    leankor__ConstraintDateTime__c,
                                                    leankor__ScheduleConstraint__r.leankor__Type__c
                                                From leankor__ScheduleModes__r 
                                                Limit 1),
                                            leankor__ValueStreamLink__c 
                                        FROM leankor__KanbanCard__c 
                                        WHERE leankor__ValueStreamCardLink__c IN: activityIds
                                            AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                            AND leankor__isRecordDeleted__c = false 
                                            AND leankor__BoardType__c IN : boardTypeFilter
                                            //AND leankor__MasterContainer__r.leankor__Type__c IN: MCTypeFilter
                                            AND (
                                                    (leankor__ValueStream__r.leankor__IsTemplateBoard__c = false AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = false)
                                                    OR (leankor__ValueStream__r.leankor__IsTemplateBoard__c = true AND leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = true)
                                                )	
                                        LIMIT 49999]){
                                            if(miniature.leankor__MasterContainer__r.leankor__Type__c != 'Template'){
                                                miniatures.add(miniature);
                                            }
                                        }
	   
		return miniatures;         
	}


    public static List<leankor__KanbanCard__c> readGanttTaskRecords(String recordId) {
        return [SELECT Id,
                (SELECT 
                    Id, 
                    leankor__ManuallyScheduled__c, 
                    leankor__Mode__c, 
                    leankor__EffortUnits__c, 
                    leankor__EffortActual__c, 
                    leankor__KanbanCard__c,
                    leankor__KanbanCard__r.leankor__valuestream__c,
					leankor__ConstraintDateTime__c,
					leankor__ScheduleConstraint__r.leankor__Type__c 
                    FROM leankor__ScheduleModes__r 
                    LIMIT 1
                ),
                (SELECT 
                    Id, 
                    leankor__AssignedTo__c, 
                    leankor__KanbanCard__c, 
                    leankor__CompletedDate__c,
                    leankor__KanbanCard__r.leankor__valuestream__c, 
                    leankor__PercentAllocation__c, 
                    leankor__PercentCompleted__c, 
                    Name 
                    FROM leankor__ResourceAssignments__r
                ),
                leankor__ValueStream__r.leankor__ProjectRoom__c,
                leankor__valuestream__r.leankor__boardtype__c,
                leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                RecordType.Name, leankor__CardID__c,
                leankor__EffortRemaining__c,
                leankor__CmpID__c,
                leankor__Color__c,
                leankor__DescriptionLong__c,
                leankor__Description__c,
                leankor__DueDate__c,
                leankor__DurationUnits__c,
                leankor__EstimatedDuration__c,
                leankor__GUID__c,
                leankor__HarveyBallDoneDate__c,
                leankor__IsCompletedOnTime__c,
                leankor__JSONData__c,
                leankor__JSONDefinition__c,
                leankor__KanbanCardTemplate__c,
                leankor__Order__c, leankor__PercentComplete2__c,
                leankor__Priority__c,
                leankor__StartDate__c,
                leankor__Title__c,
                leankor__ValueStreamCardLink__c,
                leankor__ValueStreamLink__c,
                leankor__ValueStream__c,
                Name, OwnerId,
                leankor__StartDateTime__C,
                leankor__DueDateTime__c,
                leankor__OnBudget__c,
                leankor__OnQuality__c,
                leankor__OnTime__c,
                leankor__PromiseCompletionDate__c,
                leankor__KanbanCardTemplate__r.Name,
                leankor__kanbanCardTemplate__r.leankor__Color__c,
                Owner.Name,
                leankor__Valuestream__r.leankor__Isrecalculate__c,
                leankor__IsExternallyDependent__c,
                leankor__IsSuccessorRecalculate__c,
                leankor__ValueStreamCardLink__r.Name,
                leankor__ValueStreamLink__r.Name,
                leankor__ValueStreamLink__r.leankor__BoardType__c,                                                                
                leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsDependencyAckRecalculate__c,
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
            FROM leankor__KanbanCard__c 
            WHERE Id =: recordId];
    }    

    /**
     * Refactored on: 08.06.2020 - This method used to read KC record in without sharing environment for RealTimeController.getKanbanCardRecord method.
    */
    public static leankor__KanbanCard__c readKanbanCardRecord(leankor.RealTimeController.Kanban remoteKanban, String boardVerb) {       
        String ownerId = UserInfo.getUserId();
        leankor__KanbanCard__c  kanbanCard = new leankor__KanbanCard__c();

        try {
            if (boardVerb == 'Lean' && remoteKanban.GUID != null) {
                kanbanCard = [Select leankor__CardID__c,
                                    (Select Id, 
                                            leankor__AssignedTo__c,
                                            leankor__PercentCompleted__c,
                                            leankor__PercentAllocation__c 
                                        From leankor__ResourceAssignments__r 
                                        Where leankor__AssignedTo__c = :ownerId),
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                    leankor__Opportunity__r.StageName,
                                    leankor__Zone__r.leankor__Title__c,
                                    leankor__IsExternallyDependent__c,
                                    leankor__ValueStream__r.leankor__TaskDateCheck__c,
                                    leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                    leankor__valueStream__r.leankor__ScheduleBackward__c,
                                    leankor__ValueStream__r.leankor__PointPicklist__c,
                                    leankor__MasterContainer__r.leankor__Type__c,
                                    leankor__Valuestream__r.leankor__IsTemplateBoard__c, 
                                    leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                                    leankor__IsSuccessorRecalculate__c,
                                    (Select Id,
                                            leankor__Mode__c,
                                            leankor__ManuallyScheduled__c,
                                            leankor__EffortActual__c,
                                            leankor__EffortUnits__c ,
                                            leankor__ConstraintDateTime__c,
                                            leankor__ScheduleConstraint__r.leankor__Type__c
                                        From leankor__ScheduleModes__r),
                                    leankor__ProjectRoom__c,
                                    leankor__Valuestream__r.Name,
                                    leankor__valuestream__r.leankor__boardtype__c,
                                    Recordtype.name,
                                    CreatedDate,
                                    leankor__TimeToProjectLaunch__c,
                                    leankor__ValueStreamLink__r.leankor__Boardtype__c,
                                    leankor__KanbanCardTemplate__r.leankor__color__c,
                                    leankor__AcceptanceCriteria__c,
                                    leankor__ValueStreamCardLink__r.Name,
                                    leankor__ValueStreamLink__r.Name,
                                    leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c, 
                                    leankor__Point__c,
                                    leankor__EffortRemaining__c,
                                    leankor__UrlLink__c,
                                    Id,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,
                                    leankor__StartDateTime__c,
                                    leankor__DueDateTime__c,
                                    leankor__Opportunity__c,
                                    leankor__Opportunity__r.Name,
                                    leankor__Account__c,
                                    leankor__Account__r.Name,
                                    leankor__ActualDuration__c,
                                    leankor__Actual_Time_Taken__c,
                                    leankor__Bottom__c,
                                    leankor__Budgeted_Time__c,
                                    leankor__Case__c,
                                    leankor__Case__r.Subject,
                                    leankor__Case__r.Status,
                                    leankor__Case__r.Priority,
                                    leankor__Case__r.CaseNumber,
                                    leankor__CmpID__c,
                                    leankor__CompletionVariance__c,
                                    leankor__Contact__c,
                                    leankor__Contact__r.Name,
                                    leankor__CSSLayout__c,
                                    leankor__DateColor__c,
                                    leankor__DescriptionLong__c,
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
                                    leankor__KanbanCardTemplate__r.Name,
                                    leankor__Left__c,
                                    leankor__PercentComplete2__c,
                                    leankor__Priority__c,
                                    leankor__PromiseCompletionDate__c,
                                    leankor__StartDate__c,
                                    leankor__State__c,
                                    leankor__Title__c,
                                    leankor__Top__c,
                                    leankor__ValueStreamCardLink__c,
                                    leankor__ValueStreamLink__c,
                                    leankor__ValueStream__c,
                                    leankor__Width__c,
                                    leankor__X__c, leankor__Y__c,
                                    leankor__ZoneGUID__c,
                                    Name,
                                    OwnerId,
                                    Owner.Name,
                                    SystemModstamp,
                                    leankor__Order__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__IsOnHold__c,
                                    leankor__IsAtRisk__c,
                                    leankor__Zone__r.Name,
                                    leankor__MasterContainer__r.Name,
                                    leankor__Swimlane__r.Name,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__WeekCalendar__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__valueStream__r.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c
                                From leankor__KanbanCard__c 
                                Where leankor__guid__c =: remoteKanban.Guid
                                    And leankor__IsRecordDeleted__c = false
                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                Limit 1];
                
                // temporary changes, needs to be removed as it is incorrect to query kc reocrd in case of deletion
            } else if (boardVerb == 'DeleteKanbanCard') {
                kanbanCard = [Select leankor__CardID__c,
                                    (Select Id,
                                            leankor__AssignedTo__c,
                                            leankor__PercentCompleted__c,
                                            leankor__PercentAllocation__c
                                        From leankor__ResourceAssignments__r 
                                        Where leankor__AssignedTo__c = :ownerId),
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                    leankor__Opportunity__r.StageName,
                                    leankor__Zone__r.leankor__Title__c,
                                    leankor__IsExternallyDependent__c,
                                    leankor__ValueStream__r.leankor__TaskDateCheck__c,
                                    leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                    leankor__valueStream__r.leankor__ScheduleBackward__c,
                                    leankor__ValueStream__r.leankor__PointPicklist__c,
                                    leankor__MasterContainer__r.leankor__Type__c,
                                    leankor__Valuestream__r.leankor__IsTemplateBoard__c, 
                                    leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                                    leankor__IsSuccessorRecalculate__c,
                                    leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c,
                                    (Select Id,
                                            leankor__Mode__c,
                                            leankor__ManuallyScheduled__c,
                                            leankor__EffortActual__c,
                                            leankor__EffortUnits__c,
                                            leankor__ConstraintDateTime__c,
                                            leankor__ScheduleConstraint__r.leankor__Type__c   
                                        From leankor__ScheduleModes__r), 
                                    leankor__ProjectRoom__c,
                                    leankor__Valuestream__r.Name,
                                    leankor__valuestream__r.leankor__boardtype__c, 
                                    Recordtype.Name, 
                                    CreatedDate, 
                                    leankor__TimeToProjectLaunch__c,
                                    leankor__ValueStreamLink__r.leankor__Boardtype__c, 
                                    leankor__KanbanCardTemplate__r.leankor__color__c, 
                                    leankor__AcceptanceCriteria__c, 
                                    leankor__ValueStreamCardLink__r.Name, 
                                    leankor__ValueStreamLink__r.Name, 
                                    leankor__Point__c, 
                                    leankor__EffortRemaining__c, 
                                    leankor__UrlLink__c, 
                                    Id, 
                                    leankor__MasterContainer__c, 
                                    leankor__Swimlane__c, 
                                    leankor__Zone__c, 
                                    leankor__StartDateTime__c, 
                                    leankor__DueDateTime__c, 
                                    leankor__Opportunity__c, 
                                    leankor__Opportunity__r.Name, 
                                    leankor__Account__c, 
                                    leankor__Account__r.Name, 
                                    leankor__ActualDuration__c, 
                                    leankor__Actual_Time_Taken__c, 
                                    leankor__Bottom__c, 
                                    leankor__Budgeted_Time__c, 
                                    leankor__Case__c, 
                                    leankor__Case__r.Subject, 
                                    leankor__Case__r.Status, 
                                    leankor__Case__r.Priority, 
                                    leankor__Case__r.CaseNumber, 
                                    leankor__CmpID__c, 
                                    leankor__CompletionVariance__c, 
                                    leankor__Contact__c, 
                                    leankor__Contact__r.Name, leankor__CSSLayout__c, 
                                    leankor__DateColor__c, 
                                    leankor__DescriptionLong__c, 
                                    leankor__Description__c, 
                                    leankor__DueDate__c, 
                                    leankor__DurationUnits__c, 
                                    leankor__EstimatedDuration__c, 
                                    leankor__GUID__c, 
                                    leankor__HarveyBallDoneDate__c, 
                                    leankor__Height__c, 
                                    leankor__IsCompletedOnTime__c, 
                                    leankor__KanbanCardTemplate__c, 
                                    leankor__KanbanCardTemplate__r.Name, 
                                    leankor__Left__c, 
                                    leankor__PercentComplete2__c, 
                                    leankor__Priority__c, 
                                    leankor__PromiseCompletionDate__c, 
                                    leankor__StartDate__c, 
                                    leankor__State__c, 
                                    leankor__Title__c, 
                                    leankor__Top__c, 
                                    leankor__ValueStreamCardLink__c, 
                                    leankor__ValueStreamLink__c, 
                                    leankor__ValueStream__c, 
                                    leankor__Width__c, 
                                    leankor__X__c, leankor__Y__c, 
                                    leankor__ZoneGUID__c, 
                                    Name, 
                                    OwnerId, 
                                    Owner.Name, 
                                    SystemModstamp,
                                    leankor__Order__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__IsOnHold__c,
                                    leankor__IsAtRisk__c,
                                    leankor__Zone__r.Name,
                                    leankor__MasterContainer__r.Name,
                                    leankor__Swimlane__r.Name,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__WeekCalendar__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__valueStream__r.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c
                                From leankor__KanbanCard__c 
                                Where Id = :remoteKanban.Id 
                                Limit 1];

            } else {
                    kanbanCard = [Select leankor__CardID__c,
                                        (Select Id,
                                                leankor__AssignedTo__c,
                                                leankor__PercentCompleted__c,
                                                leankor__PercentAllocation__c
                                            From leankor__ResourceAssignments__r 
                                            Where leankor__AssignedTo__c = :ownerId),
                                        leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                                        leankor__Opportunity__r.StageName,
                                        leankor__Zone__r.leankor__Title__c,
                                        leankor__IsExternallyDependent__c,
                                        leankor__ValueStream__r.leankor__TaskDateCheck__c,
                                        leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                        leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                        leankor__ValueStream__r.leankor__PointPicklist__c,
                                        leankor__MasterContainer__r.leankor__Type__c,
                                        leankor__Valuestream__r.leankor__IsTemplateBoard__c, 
                                        leankor__ValuestreamLink__r.leankor__IsTemplateBoard__c,
                                        leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                                        leankor__IsSuccessorRecalculate__c,
                                        (Select Id,
                                                leankor__Mode__c,
                                                leankor__ManuallyScheduled__c,
                                                leankor__EffortActual__c,
                                                leankor__EffortUnits__c,
                                                leankor__ConstraintDateTime__c,
                                                leankor__ScheduleConstraint__r.leankor__Type__c 
                                            From leankor__ScheduleModes__r), 
                                        leankor__ProjectRoom__c,
                                        leankor__Valuestream__r.Name,
                                        leankor__valuestream__r.leankor__boardtype__c, 
                                        Recordtype.Name, 
                                        CreatedDate, 
                                        leankor__TimeToProjectLaunch__c,
                                        leankor__ValueStreamLink__r.leankor__Boardtype__c, 
                                        leankor__KanbanCardTemplate__r.leankor__color__c, 
                                        leankor__AcceptanceCriteria__c, 
                                        leankor__ValueStreamCardLink__r.Name, 
                                        leankor__ValueStreamLink__r.Name, 
                                        leankor__Point__c, 
                                        leankor__EffortRemaining__c, 
                                        leankor__UrlLink__c, 
                                        Id, 
                                        leankor__MasterContainer__c, 
                                        leankor__Swimlane__c, 
                                        leankor__Zone__c, 
                                        leankor__StartDateTime__c, 
                                        leankor__DueDateTime__c, 
                                        leankor__Opportunity__c, 
                                        leankor__Opportunity__r.Name, 
                                        leankor__Account__c, 
                                        leankor__Account__r.Name, 
                                        leankor__ActualDuration__c, 
                                        leankor__Actual_Time_Taken__c, 
                                        leankor__Bottom__c, 
                                        leankor__Budgeted_Time__c, 
                                        leankor__Case__c, 
                                        leankor__Case__r.Subject, 
                                        leankor__Case__r.Status, 
                                        leankor__Case__r.Priority, 
                                        leankor__Case__r.CaseNumber, 
                                        leankor__CmpID__c, 
                                        leankor__CompletionVariance__c, 
                                        leankor__Contact__c, 
                                        leankor__Contact__r.Name, leankor__CSSLayout__c, 
                                        leankor__DateColor__c, 
                                        leankor__DescriptionLong__c, 
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
                                        leankor__KanbanCardTemplate__r.Name, 
                                        leankor__Left__c, 
                                        leankor__PercentComplete2__c, 
                                        leankor__Priority__c, 
                                        leankor__PromiseCompletionDate__c, 
                                        leankor__StartDate__c, 
                                        leankor__State__c, 
                                        leankor__Title__c, 
                                        leankor__Top__c, 
                                        leankor__ValueStreamCardLink__c, 
                                        leankor__ValueStreamLink__c, 
                                        leankor__ValueStream__c, 
                                        leankor__Width__c, 
                                        leankor__X__c, leankor__Y__c, 
                                        leankor__ZoneGUID__c, 
                                        Name, 
                                        OwnerId, 
                                        Owner.Name, 
                                        SystemModstamp,
                                        leankor__Order__c,
                                        leankor__OnBudget__c,
                                        leankor__OnQuality__c,
                                        leankor__OnTime__c,
                                        leankor__IsOnHold__c,
                                        leankor__IsAtRisk__c,
                                        leankor__Zone__r.Name,
                                        leankor__MasterContainer__r.Name,
                                        leankor__Swimlane__r.Name,
                                        leankor__IsConstraintRecalculate__c,
                                        leankor__WeekCalendar__c,
                                        leankor__Monday__c,
                                        leankor__Tuesday__c,
                                        leankor__Wednesday__c,
                                        leankor__Thursday__c,
                                        leankor__Friday__c,
                                        leankor__Saturday__c,
                                        leankor__Sunday__c,
                                        leankor__valueStream__r.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c
                                    From leankor__KanbanCard__c 
                                    Where Id = :remoteKanban.Id 
                                        And leankor__IsRecordDeleted__c = false
                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                    Limit 1];
            }           
        } catch (QueryException e) {
            return kanbanCard;
        }   
        
        return kanbanCard;      
    }


    /**
     * Refactored on: 08.06.2020 - This method used to read KC record in without sharing environment for RealTimeController.getKanbanCardData method.
    */
    public static List<leankor__KanbanCard__c> readKanbanCardData(List<String> kanbanIds , String boardVerb) {
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        String ownerId = userinfo.getUserId();

        if (boardVerb == 'MultipleDragDrop') {       
             kanbanCardList = [SELECT 
                                    Id,
                                    leankor__Order__c,
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                    leankor__GUID__C 
                                    FROM leankor__KanbanCard__c 
                                    WHERE Id IN : kanbanIds 
                                        AND leankor__IsRecordDeleted__c = false
                                        AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                    ORDER BY leankor__CardID__c  
                                    LIMIT 49999]; 
        } else {
            kanbanCardList = [SELECT 
                                    leankor__CardID__c, 
                                    (SELECT 
                                            Id, 
                                            leankor__AssignedTo__c,
                                            leankor__PercentCompleted__c,
                                            leankor__PercentAllocation__c 
                                        FROM leankor__ResourceAssignments__r 
                                        WHERE leankor__AssignedTo__c =: ownerId
                                    ),
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c, 
                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                    leankor__Opportunity__r.StageName,leankor__Zone__r.leankor__Title__c,
                                    leankor__IsExternallyDependent__c,
                                    leankor__ValueStream__r.leankor__TaskDateCheck__c,
                                    leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
                                    leankor__ValueStream__r.leankor__PointPicklist__c,
                                    leankor__MasterContainer__r.leankor__Type__c,
                                    leankor__Valuestream__r.leankor__IsTemplateBoard__c, 
                                    leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                                    leankor__IsSuccessorRecalculate__c,
                                    (SELECT 
                                            Id,
                                            leankor__Mode__c,
                                            leankor__ManuallyScheduled__c,
                                            leankor__EffortActual__c,
                                            leankor__EffortUnits__c,
											leankor__ConstraintDateTime__c,
											leankor__ScheduleConstraint__r.leankor__Type__c 
                                        FROM leankor__ScheduleModes__r
                                    ),
                                    leankor__ProjectRoom__c,
                                    leankor__Valuestream__r.Name,
                                    leankor__valuestream__r.leankor__boardtype__c, 
                                    Recordtype.Name, 
                                    CreatedDate, 
                                    leankor__TimeToProjectLaunch__c,
                                    leankor__ValueStreamLink__r.leankor__Boardtype__c, 
                                    leankor__KanbanCardTemplate__r.leankor__color__c, 
                                    leankor__AcceptanceCriteria__c, 
                                    leankor__ValueStreamCardLink__r.Name, 
                                    leankor__ValueStreamLink__r.Name, 
                                    leankor__Point__c, 
                                    leankor__EffortRemaining__c, 
                                    leankor__UrlLink__c, 
                                    Id, 
                                    leankor__MasterContainer__c, 
                                    leankor__Swimlane__c, 
                                    leankor__Zone__c, 
                                    leankor__StartDateTime__c, 
                                    leankor__DueDateTime__c, 
                                    leankor__Opportunity__c, 
                                    leankor__Opportunity__r.Name, 
                                    leankor__Account__c, 
                                    leankor__Account__r.Name, 
                                    leankor__ActualDuration__c, 
                                    leankor__Actual_Time_Taken__c, 
                                    leankor__Bottom__c, 
                                    leankor__Budgeted_Time__c, 
                                    leankor__Case__c, 
                                    leankor__Case__r.Subject, 
                                    leankor__Case__r.Status, 
                                    leankor__Case__r.Priority, 
                                    leankor__Case__r.CaseNumber, 
                                    leankor__CmpID__c, 
                                    leankor__CompletionVariance__c, 
                                    leankor__Contact__c, 
                                    leankor__Contact__r.Name, 
                                    leankor__CSSLayout__c, 
                                    leankor__DateColor__c, 
                                    leankor__DescriptionLong__c, 
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
                                    leankor__KanbanCardTemplate__r.Name, 
                                    leankor__Left__c, 
                                    leankor__PercentComplete2__c, 
                                    leankor__Priority__c, 
                                    leankor__PromiseCompletionDate__c, 
                                    leankor__StartDate__c, 
                                    leankor__State__c, 
                                    leankor__Title__c, 
                                    leankor__Top__c, 
                                    leankor__ValueStreamCardLink__c, 
                                    leankor__ValueStreamLink__c,
                                    leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c, 
                                    leankor__ValueStream__c, 
                                    leankor__Width__c, 
                                    leankor__X__c, 
                                    leankor__Y__c, 
                                    leankor__ZoneGUID__c, 
                                    Name, 
                                    OwnerId, 
                                    Owner.Name, 
                                    SystemModstamp,
                                    leankor__Order__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__IsOnHold__c,
                                    leankor__IsAtRisk__c,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__WeekCalendar__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__valueStream__r.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c
                                FROM leankor__KanbanCard__c 
                                WHERE Id IN: kanbanIds 
                                    AND leankor__IsRecordDeleted__c = false
                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                ORDER BY leankor__CardID__c 
                                LIMIT 49999];
        }
        
        return kanbanCardList;
    }
    
    
    // Get project card data
    public static Set<Id> getProjectCards(ProjectBoardCarousel.WorkFilter filterObj) {
        // Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
        Set<Id> projectRoomCard = new Set<Id>();

        for(Leankor__KanbanCard__c kc: [SELECT 
                                            Id,
                                            Leankor__Boardtype__c,
                                            Leankor__MasterContainer__r.Leankor__Type__c 
                                        FROM Leankor__KanbanCard__c 
                                        WHERE Leankor__ValueStream__r.Leankor__ProjectRoom__c =: filterObj.projectId 
                                            AND Leankor__ValueStream__r.Leankor__IsTemplateBoard__c = false 
                                            AND Leankor__IsRecordDeleted__c = false
                                            AND Leankor__ValueStream__r.Leankor__IsRecordDeleted__c = false
                                        LIMIT 49999]){

            if(kc.Leankor__Boardtype__c != 'UberBoard ' && kc.Leankor__MasterContainer__r.Leankor__Type__c != 'Template'){
                projectRoomCard.add(kc.Id);
            }
        }

        return projectRoomCard;     
    }
    
    
    // Method for getResources help to get not sharing data
    public static leankor.CardHierarchyController.CardHierarchyResourceScheduler getResources_Helper(String VSID,String KanbanID,String remoteVerb){
        //Date 22/07/19 add record id in set to avoid duplicate id.
        Set<String> VSIDs=new Set<String>();
        Set<String> ZoneIDs=new Set<String>();
        Set<String> KanbanBoardIDs=new Set<String>();
        List<leankor__KanbanCard__c> Cards = new List<leankor__KanbanCard__c>();      
        List<leankor__KanbanCard__c> RelatedCards = new List<leankor__KanbanCard__c>();   
        
        //18.12.2017 - for calendar new design
        resoruceList = new List<String>();
        Boolean calenderTaskAsMiniature = false;
        if (String.isNotBlank(VSID)) {
            
            leankor__ValueStream__c vs = [Select leankor__DisableTaskAsMiniature__c 
                                            from leankor__ValueStream__c 
                                            where Id =: VSID limit 1];
            calenderTaskAsMiniature = vs.leankor__DisableTaskAsMiniature__c == null ? false : vs.leankor__DisableTaskAsMiniature__c;
        } 
         
        //18.12.2017 - for calendar new design
        List<leankor.kanbanToGanttController.MasterContainer> AllTaskList = new List<leankor.kanbanToGanttController.MasterContainer>();
         
        if(remoteVerb == 'Card Hierarchy'){
            //SS 08.10.2019
            //Added condition to exclude to retrieve records whose valueStream is soft deleted
            RelatedCards = [Select Id, Name, leankor__CardID__c,
                                    leankor__ValueStream__C 
                                    from leankor__KanbanCard__c 
                                    Where (leankor__ValueStreamCardLink__c =:KanbanID 
                                    AND leankor__ValueStreamLink__c =:VSID)
                                    AND leankor__IsRecordDeleted__c=false
                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                 Limit 49999];  //AND ( RecordType.Name = 'ActivityCard' OR RecordType.Name ='MilestoneCard' )
        }else{
            //SS 08.10.2019
            //Added condition to exclude to retrieve records whose valueStream is soft deleted
            RelatedCards = [Select Id, Name,
                                leankor__CardID__c,
                                leankor__ValueStream__C 
                                from leankor__KanbanCard__c 
                                Where (Id =:KanbanID AND leankor__ValueStream__c =:VSID) 
                                    AND leankor__IsRecordDeleted__c=false
                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                Limit 49999]; //AND ( RecordType.Name = 'ActivityCard' OR RecordType.Name ='MilestoneCard' )
        }
        
        Set<String> tempVSIDs = new Set<String>();
        for(leankor__KanbanCard__c k : RelatedCards){
            tempVSIDs.add(k.leankor__ValueStream__C);
        }
        
        Set<String> AllRelatedCards = new Set<String>();
        // Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
        List<leankor__Dependency__c> dependencies = [SELECT Id, 
                                                    leankor__GUID__c,
                                                    leankor__Predecessor__r.leankor__ValueStream__c,
                                                    leankor__KanbanCard__c,
                                                    leankor__Successor__r.leankor__ValueStream__c,
                                                    leankor__KanbanCard__r.leankor__ValueStream__c,
                                                    leankor__Predecessor__c,
                                                    leankor__Successor__c,
                                                    leankor__ValueStream__c,
                                                    Name 
                                                FROM leankor__Dependency__c 
                                                WHERE (leankor__Predecessor__r.leankor__ValueStream__c  IN :tempVSIDs 
                                                    OR leankor__Successor__r.leankor__ValueStream__c IN :tempVSIDs 
                                                    OR leankor__ValueStream__c IN :tempVSIDs)
                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                    AND leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                                    AND leankor__Successor__r.leankor__isRecordDeleted__c = false
                                                    AND leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                    AND leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                LIMIT 49999];
        
                                                    
        Map<String,Set<String>> KanbanMap = new Map<String,Set<String>>(); 
        for(leankor__Dependency__C d : dependencies){
            tempVSIDs.add(d.leankor__ValueStream__c);
            if(d.leankor__KanbanCard__r.leankor__ValueStream__c != null){
                tempVSIDs.add(d.leankor__KanbanCard__r.leankor__ValueStream__c);
            }
            if(d.leankor__Successor__r.leankor__ValueStream__c != null){
                tempVSIDs.add(d.leankor__Successor__r.leankor__ValueStream__c);
            }
            if(d.leankor__Predecessor__r.leankor__ValueStream__c != null){
                tempVSIDs.add(d.leankor__Predecessor__r.leankor__ValueStream__c);
            }
        }
        
        
        dependencies = [SELECT Id, 
                                leankor__GUID__c,
                                leankor__KanbanCard__c,
                                leankor__Predecessor__c,
                                leankor__Successor__c,
                                leankor__ValueStream__c,
                                Name 
                            FROM leankor__Dependency__c 
                            WHERE (leankor__Predecessor__r.leankor__ValueStream__c IN :tempVSIDs 
                                OR leankor__Successor__r.leankor__ValueStream__c IN :tempVSIDs 
                                OR leankor__ValueStream__c IN :tempVSIDs)
                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                AND leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                AND leankor__Successor__r.leankor__isRecordDeleted__c = false
                                AND leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                AND leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                            LIMIT 49999];
                            
        //tempVSIDs.clear();                     
        for(leankor__Dependency__c dp : dependencies){
            if(KanbanMap.ContainsKey(dp.leankor__Predecessor__c) == true){
                Set<String> tempSet = KanbanMap.get(dp.leankor__Predecessor__c);
                tempSet.add(dp.leankor__Successor__c);
                KanbanMap.put(dp.leankor__Predecessor__c,tempSet);
            }else{
                Set<String> tempSet = new Set<String>();
                tempSet.add(dp.leankor__Successor__c);
                KanbanMap.put(dp.leankor__Predecessor__c,tempSet);
            }
            if(KanbanMap.ContainsKey(dp.leankor__Successor__c) == true){
                Set<String> tempSet = KanbanMap.get(dp.leankor__Successor__c);
                tempSet.add(dp.leankor__Predecessor__c);
                KanbanMap.put(dp.leankor__Successor__c,tempSet);
            }else{
                Set<String> tempSet = new Set<String>();
                tempSet.add(dp.leankor__Predecessor__c);
                KanbanMap.put(dp.leankor__Successor__c,tempSet);
            } 
        }
        
        for(leankor__KanbanCard__c k : RelatedCards){
            Set<String> kanbanIDs = new Set<String>();
            AllRelatedCards.add(k.Id);
            if(KanbanMap.ContainsKey(k.Id) == true){ 
                kanbanIDs =  KanbanMap.get(k.Id);   
                for(Integer j=0; j <5; j++){
                    for(Integer i=0; i < kanbanIDs.Size(); i++ ){
                        String tempString = (new list<string>(kanbanIDs))[i];
                        AllRelatedCards.add(tempString);
                        Set<String> tempIDs = KanbanMap.get(tempString);
                        kanbanIDs.addAll(tempIDs);
                    }
                 }
             }
         }
         
         //RS 25.06.2018 Added RecordType.Name in the query 
         /*Cards = [Select Id,
                        leankor__UrlLink__c,
                        (SELECT Id,
                            leankor__ManuallyScheduled__c,
                            leankor__EffortActual__c,
                            leankor__EffortUnits__c,
                            leankor__Mode__c 
                            From leankor__ScheduleModes__r limit 1),
                        leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                        leankor__CardID__c,
                        leankor__IsSuccessorRecalculate__c,
                        leankor__KanbanCardTemplate__r.leankor__color__c,
                        leankor__point__c,
                        leankor__EffortRemaining__c,
                        leankor__Valuestream__r.leankor__TaskDateCheck__c,
                        leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                        leankor__Valuestream__r.leankor__PointPicklist__c,
                        leankor__MasterContainer__c,
                        leankor__Swimlane__c,
                        leankor__Zone__c,
                        Name,
                        leankor__Order__c,
                        leankor__StartDateTime__c,
                        leankor__DueDateTime__c,
                        leankor__Opportunity__C,
                        leankor__Opportunity__r.Name,
                        leankor__Account__r.Id,
                        leankor__Account__r.Name,
                        leankor__Actual_Time_Taken__c,
                        leankor__Bottom__c,
                        leankor__Budgeted_Time__c,
                        leankor__Case__C,
                        leankor__Case__r.Id,
                        leankor__Case__r.Subject,
                        leankor__Case__r.Status,
                        leankor__Case__r.CaseNumber,
                        leankor__Case__r.Priority,
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
                        leankor__JSONData__c,
                        leankor__JSONDefinition__c,
                        leankor__KanbanCardTemplate__c,
                        leankor__KanbanCardTemplate__r.Name,
                        leankor__Left__c,
                        leankor__PercentComplete2__c,
                        leankor__Priority__c,
                        leankor__PromiseCompletionDate__c,
                        leankor__StartDate__c,
                        leankor__State__c,
                        leankor__Title__c,
                        leankor__Top__c,
                        leankor__ValueStream__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        leankor__Width__c,leankor__X__c,
                        leankor__Y__c,
                        leankor__ZoneGUID__c,
                        OwnerID,Owner.Name,
                        leankor__valueStream__r.leankor__BoardType__c,
                        leankor__ValueStreamLink__r.leankor__BoardType__c,
                        RecordType.Name,
                        leankor__IsAtRisk__c
                        From leankor__KanbanCard__c 
                        Where Id In :AllRelatedCards  
	                        And leankor__ValueStream__c!=null 
	                        And leankor__IsRecordDeleted__c=false
	                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                        Order By  leankor__StartDateTime__c Limit 49999];*/
         //SS 08.10.2019
         //Do not use null condition in Query , to prevent table scan                   
         //27/05/2022 : Changes for get all data in CH.              
        Set<String> successorRecalculateCardIds = new Set<String>(); 
         for(leankor__KanbanCard__c kc : [Select Id,
                                                    leankor__UrlLink__c,
                                                    (Select Id,
                                                        leankor__ManuallyScheduled__c,
                                                        leankor__EffortActual__c,
                                                        leankor__EffortUnits__c,
                                                        leankor__Mode__c,
                                                        leankor__ScheduleConstraint__r.leankor__Type__c,
                                                        leankor__ConstraintDateTime__c 
                                                        From leankor__ScheduleModes__r limit 1),
                                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                                    leankor__CardID__c,
                                                    leankor__IsSuccessorRecalculate__c,
                                                    leankor__KanbanCardTemplate__r.leankor__color__c,
                                                    leankor__point__c,
                                                    leankor__EffortRemaining__c,
                                                    leankor__Valuestream__r.leankor__TaskDateCheck__c,
                                                    leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                                                    leankor__Valuestream__r.leankor__PointPicklist__c,
                                                    leankor__MasterContainer__c,
                                                    leankor__Swimlane__c,
                                                    leankor__Zone__c,
                                                    Name,
                                                    leankor__Order__c,
                                                    leankor__StartDateTime__c,
                                                    leankor__DueDateTime__c,
                                                    leankor__Opportunity__C,
                                                    leankor__Opportunity__r.Name,
                                                    leankor__Account__r.Id,
                                                    leankor__Account__r.Name,
                                                    leankor__Actual_Time_Taken__c,
                                                    leankor__Bottom__c,
                                                    leankor__Budgeted_Time__c,
                                                    leankor__Case__C,
                                                    leankor__Case__r.Id,
                                                    leankor__Case__r.Subject,
                                                    leankor__Case__r.Status,
                                                    leankor__Case__r.CaseNumber,
                                                    leankor__Case__r.Priority,
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
                                                    leankor__JSONData__c,
                                                    leankor__JSONDefinition__c,
                                                    leankor__KanbanCardTemplate__c,
                                                    leankor__KanbanCardTemplate__r.Name,
                                                    leankor__Left__c,
                                                    leankor__PercentComplete2__c,
                                                    leankor__Priority__c,
                                                    leankor__PromiseCompletionDate__c,
                                                    leankor__StartDate__c,
                                                    leankor__State__c,
                                                    leankor__Title__c,
                                                    leankor__Top__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStreamCardLink__c,
                                                    leankor__ValueStreamLink__c,
                                                    leankor__Width__c,leankor__X__c,
                                                    leankor__Y__c,
                                                    leankor__ZoneGUID__c,
                                                    OwnerID,Owner.Name,
                                                    leankor__valueStream__r.leankor__BoardType__c,
                                                    leankor__ValueStreamLink__r.leankor__BoardType__c,
                                                    RecordType.Name,
                                                    leankor__IsAtRisk__c,
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
                                                Where (Id In :AllRelatedCards  
                                                    Or leankor__ValueStream__c =: VSID) 
                                                    And leankor__IsRecordDeleted__c=false
                                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                Order By  leankor__StartDateTime__c 
                                                Limit 50000]){
            //SS 08.10.2019
            //Exclude records with null Vs / Project                    
            if(String.isNotBlank(kc.leankor__ValueStream__c) && String.isNotBlank(kc.leankor__ProjectRoom__c)){
                cards.add(kc);
                //If successorRecalculate = true then add card id to set
                if(kc.leankor__IsSuccessorRecalculate__c){
                        successorRecalculateCardIds.add(kc.Id);
            }
                VSIDs.add(kc.leankor__ValueStream__c);
                ZoneIDs.add(kc.leankor__ZoneGUID__c);
                if(kc.leankor__valueStream__r.leankor__BoardType__c == 'Kanban Board' ||kc.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board'){
                    KanbanBoardIDs.add(kc.leankor__ValueStream__c);
                }
            }
         
         }
         /*SS 21.08.2018*/
         // Added variables for all vsIds and cards with isSuccessorRecalculate = true (required by the UI team for imroving performance) 
        // Set<String> successorRecalculateCardIds = new Set<String>();
         Set<String> relatedVSIds = new Set<String>();
         // Maping List of Task with KanbanCard Id       
         map<String,List<Task>> taskMap = new map<String,List<Task>>();
         
         // Query task records and put results in a list            
         List<Task> taskRecords = [Select 
                                        Id,
                                        Priority,
                                        OwnerID,
                                        Subject,
                                        Status,
                                        ActivityDate,
                                        WhatID,
                                        Description,
                                        Owner.Name,
                                        LastModifiedDate,
                                        CreatedDate 
                                    From Task 
                                    Where WhatID IN : Cards 
                                    AND What.Type = 'leankor__KanbanCard__c' 
                                    And IsDeleted = false 
                                    limit 49999 All Rows];
        // Find all Task records under each KanbanCard Record           
        for(Task t : taskRecords){
            List<Task> taskList = taskMap.containsKey(t.WhatId) ? taskMap.get(t.WhatId) : new List<Task>();
            taskList.add(t);
            taskMap.put(t.WhatId, taskList);
        }
        taskRecords.clear();
     /*   for(leankor__KanbanCard__c k: cards){
            //If successorRecalculate = true then add card id to set
            if(k.leankor__IsSuccessorRecalculate__c){
                 successorRecalculateCardIds.add(k.Id);
            }
            VSIDs.add(k.leankor__ValueStream__c);
            ZoneIDs.add(k.leankor__ZoneGUID__c);
            if(k.leankor__valueStream__r.leankor__BoardType__c == 'Kanban Board' ||k.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board'){
                KanbanBoardIDs.add(k.leankor__ValueStream__c);
            }
         }*/
         
         List<leankor__ValueStream__c> ValueStreams = [Select Id,
                                                    UserRecordAccess.hasEditAccess,
                                                    (select Id, 
                                                        name 
                                                        from leankor__Master_Containers__r),
                                                    leankor__BackgroundHeight__c,
                                                    leankor__BackgroundWidth__c,
                                                    leankor__BoardType__c,
                                                    leankor__CaseCardCategory__c,
                                                    leankor__CaseRecordType__c,
                                                    leankor__CaseSynchronization__c,
                                                    leankor__CaseType__c,
                                                    leankor__JSONSnapshot__c,
                                                    leankor__KanbanCardCount__c,
                                                    leankor__KanbanCardThroughput__c,
                                                    leankor__ProjectRoom__c,
                                                    leankor__ValueStreamCardLink__c,
                                                    leankor__ValueStreamLink__c,
                                                    leankor__ValueStreamTemplate__c,
                                                    Name, OwnerId,
                                                    leankor__ProjectBoardStartDateTime__c,
                                                    leankor__ProjectBoardEndDateTime__c,
                                                    leankor__ScheduleBackward__c,
                                                            leankor__ProjectBoardLaunchDateTime__c,
                                                            leankor__SevenDayWorkWeek__c,
                                                            leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c,
                                                        (Select Id,
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
                                                        leankor__LeadTime__c,leankor__Left__c,leankor__Limit__c,
                                                        leankor__Order__c,leankor__ParentZone__c,
                                                        leankor__Swimlane__c,leankor__Title__c,
                                                        leankor__Top__c,
                                                        leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,leankor__X__c,leankor__Y__c,
                                                        leankor__zoneMode__c,
                                                        leankor__ZoneTemplate__c,
                                                        Name,OwnerId,
                                                        leankor__Swimlane__r.leankor__MasterContainer__c 
                                                        FROM leankor__ValueStream__c.leankor__Zones__r 
                                                        where leankor__GUID__c In :ZoneIDs 
                                                        AND leankor__ValueStream__c!=null) 
                                                    FROM leankor__ValueStream__c where Id In :VSIDs and leankor__IsRecordDeleted__c=false];
                                                    
         List<leankor__MasterContainer__c> mContainers = [SELECT Id,
                                                        leankor__ValueStream__c,
                                                        Name,
                                                        (Select Id,
                                                            Name,
                                                            leankor__MasterContainer__c 
                                                            from leankor__MasterContainer__c.leankor__Swimlanes__r) 
                                                        FROM leankor__MasterContainer__c 
                                                        Where leankor__ValueStream__C in : KanbanBoardIDs Limit 49999];
                                                            
        Map<String,leankor.CardHierarchyController.TempMasterContainer> mcs = new Map<String,leankor.CardHierarchyController.TempMasterContainer>();
        for(leankor__MasterContainer__C m : mContainers){
            mcs.put(m.Id,(new leankor.CardHierarchyController.TempMasterContainer(m.Id,m.Name,m.leankor__ValueStream__C,m.leankor__Swimlanes__r.Size())));
        }
        mContainers.clear();
        List<leankor__Swimlane__c> swimlanes = [SELECT Id,
                                                leankor__ValueStream__c,
                                                Name,
                                                leankor__MasterContainer__c,
                                                (Select Id,
                                                    Name,
                                                    leankor__Swimlane__c 
                                                    from leankor__Swimlane__c.leankor__Zones__r) 
                                                FROM leankor__Swimlane__c 
                                                Where leankor__ValueStream__C in : KanbanBoardIDs  Limit 49999];
                                                
        Map<String,leankor.CardHierarchyController.TempMasterContainer> swims = new Map<String,leankor.CardHierarchyController.TempMasterContainer>();
        for(leankor__Swimlane__c s : swimlanes){
            swims.put(s.Id,(new leankor.CardHierarchyController.TempMasterContainer(s.Id,s.Name,s.leankor__MasterContainer__C,s.leankor__Zones__r.Size())));
        }
        swimlanes.clear();
        List<leankor.realTimeController.ProjectBoard> ProjectBoardList=new List<leankor.realTimeController.ProjectBoard>();
        Integer TempSize=ValueStreams.size(),noZoneIdCount=0;
         
        if(TempSize>0){
            DateTime  minSDZone,minEDZone;
            for(leankor__ValueStream__c VS : ValueStreams){
                /*SS 21.08.2018*/
                //Add vsId to set of String 
                relatedVSIds.add(VS.id);
                //hasReadAccess.add(VS.UserRecordAccess.HasReadAccess);
                noZoneIdCount++;
                leankor.realTimeController.ProjectBoard ProjectBoard=new leankor.realTimeController.ProjectBoard();
                ProjectBoard.Id=VS.Id;
                ProjectBoard.Name=VS.Name;
                List<leankor.KanbanToGanttController.MasterContainer> ZoneList=new List<leankor.KanbanToGanttController.MasterContainer>();
                List<leankor.KanbanToGanttController.MasterContainer> portfolioKanbanCardList=new List<leankor.KanbanToGanttController.MasterContainer>();
                // child MC->Zone->card->task
                DateTime minSDCard,minEDCard; Integer count=0;
                //27/05/2022 : Variable added for pass value in showFIled for Zone.
                Boolean temp = false;
                if(VS.leankor__BoardType__c == 'Kanban Board'|| VS.leankor__BoardType__c == 'Plan Board'){
                    for(leankor__MasterContainer__C m : VS.leankor__Master_Containers__r){
                        boolean singleMCflag= false;
                        leankor.KanbanToGanttController.MasterContainer cardMC =new leankor.KanbanToGanttController.MasterContainer();
                        cardMC.Id= m.Id;
                        cardMC.Name= m.Name;
                        cardMC.leaf=false;
                        List<leankor.KanbanToGanttController.MasterContainer> ListCardZone=new List<leankor.KanbanToGanttController.MasterContainer>();
                        for(leankor__Zone__C Zone : VS.leankor__Zones__r){
                            if(m.Id == Zone.leankor__Swimlane__r.leankor__MasterContainer__c){
                                String zName ='';
                                leankor.CardHierarchyController.TempMasterContainer tempSwim= swims.get(Zone.leankor__Swimlane__c);
                                if(tempSwim.ChildCount == 1){
                                    zName = tempSwim.Name;
                                    leankor.CardHierarchyController.TempMasterContainer tempMC= mcs.get(tempSwim.ParentID);
                                    if(tempMC.ChildCount == 1){
                                        zName = tempMC.Name;
                                        cardMC=new leankor.KanbanToGanttController.MasterContainer();
                                        singleMCflag=true;
                                    }
                                }else{
                                    zName = '';
                                }
                                leankor.KanbanToGanttController.MasterContainer CardZone=new leankor.KanbanToGanttController.MasterContainer();
                                CardZone.Id=Zone.Id;
                                CardZone.Name= (zName != '' ?zName :Zone.Name );
                                CardZone.leaf=false;
                                CardZone.Title=Zone.leankor__Title__c;
                                CardZone.Top=Integer.valueOf(Zone.leankor__Top__c);
                                CardZone.Bottom=Integer.valueOf(Zone.leankor__Bottom__c);
                                CardZone.Left=Integer.valueOf(Zone.leankor__Left__c);
                                CardZone.Width=Integer.valueOf(Zone.leankor__Width__c);
                                CardZone.Height=Integer.valueOf(Zone.leankor__Height__c);
                                CardZone.X=Integer.valueOf(Zone.leankor__x__c);
                                CardZone.Y=Integer.valueOf(Zone.leankor__Y__c);
                                CardZone.JSONDefinition=Zone.leankor__JSONDefinition__c;
                                CardZone.ValueStreamCardLink=(Zone.leankor__ValueStreamCardLink__c==null?'':Zone.leankor__ValueStreamCardLink__c);
                                CardZone.ValueStreamLinkID=(Zone.leankor__ValueStreamLink__c==null?'':Zone.leankor__ValueStreamLink__c);
                                CardZone.ValueStream = Zone.leankor__ValueStream__c;
                                CardZone.CmpID=Zone.leankor__CmpID__c;
                                CardZone.GUID=Zone.leankor__GUID__c;
                                CardZone.OwnerID=Zone.OwnerID;
                                CardZone.CaseStatus=(Zone.leankor__CaseStatus__c==null?'':Zone.leankor__CaseStatus__c);  
                                CardZone.EntryFlowName=Zone.leankor__EntryFlowName__c;
                                CardZone.ExitFlowName=Zone.leankor__ExitFlowName__c;
                                CardZone.ZoneMode=Zone.leankor__ZoneMode__c;
                                CardZone.KanbanSequence=Zone.leankor__KanbanSequence__c;
                                CardZone.DefaultHeight=Integer.valueOf(Zone.leankor__DefaultHeight__c);
                                CardZone.DefaultWidth=Integer.valueOf(Zone.leankor__DefaultWidth__c);
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
                                CardZone.ItemType = 'ZONE';
                                CardZone.Color  ='#CCCCCC';
                                //17/06/2022 : Changes for Constring in CH.
                                CardZone.masterContainerId = Zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                List<leankor.KanbanToGanttController.MasterContainer> KanbanCardList=new List<leankor.KanbanToGanttController.MasterContainer>();
                                Integer tempCount=0;
                                Decimal tempOrderValue = 1.0;
                             //   for(leankor__KanbanCard__c KnbnCard: Cards){
                                for(integer index = 0; index < cards.size();){                                   
 									if(Zone.leankor__GUID__c==cards[index].leankor__ZoneGUID__c){
                                        if(tempCount==0){
                                            if(cards[index].leankor__StartDateTime__c <= Cards[index].leankor__DueDateTime__c){
                                                minSDCard=cards[index].leankor__StartDateTime__c;
                                                minEDCard=cards[index].leankor__DueDateTime__c;
                                                tempCount++;
                                            }
                                        }
                                        if(cards[index].leankor__StartDate__c<minSDCard) 
                                            minSDCard=cards[index].leankor__StartDateTime__c;
                                        if(cards[index].leankor__DueDate__c>minEDCard) 
                                            minEDCard=cards[index].leankor__DueDateTime__c;
                                        leankor.KanbanToGanttController.MasterContainer KC=new leankor.KanbanToGanttController.MasterContainer();
                                        KC.Id=cards[index].id;
                                        KC.CardID=cards[index].leankor__CardID__c;
                                        KC.ForceID=cards[index].id;
                                        KC.Name=cards[index].name;
                                        KC.EstimatedDuration=cards[index].leankor__EstimatedDuration__c;
                                        KC.EffortRemaining = Integer.valueof(cards[index].leankor__EffortRemaining__c);
                                          if(cards[index].leankor__DurationUnits__c=='Days')       KC.DurationUnits='d';
                                        else if(cards[index].leankor__DurationUnits__c=='Weeks')   KC.DurationUnits='w';
                                        else if(cards[index].leankor__DurationUnits__c=='Hours')   KC.DurationUnits='h';
                                        else if(cards[index].leankor__DurationUnits__c=='Months')  KC.DurationUnits='mo';
                                        else if(cards[index].leankor__DurationUnits__c=='Years')   KC.DurationUnits='y';
                                        else if(cards[index].leankor__DurationUnits__c=='Minutes') KC.DurationUnits='mi';
                                       /* if(cards[index].leankor__StartDateTime__c <= Cards[index].leankor__DueDateTime__c){
                                            KC.StartDate = JSON.Serialize(cards[index].leankor__StartDateTime__c);
                                            KC.DueDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                                        }else{
                                            KC.StartDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                                            KC.DueDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                                        }*/ //Modified to simple SD 02-03-17
                                        /*SS 16.08.2018*/
                                        //With String class methods we are loosing TZ details 
                                        //So used serialize to encrypt DateTime value to String formate and 
                                        //deserialized for removing double code notation from String value
                                        /*KC.StartDate = cards[index].leankor__StartDateTime__c <= Cards[index].leankor__DueDateTime__c ? 
                                                                                String.valueofGmt(Cards[index].leankor__StartDateTime__c) :
                                                                                String.valueofGmt(Cards[index].leankor__DueDateTime__c);
                                        KC.DueDate = String.valueofGmt(cards[index].leankor__DueDateTime__c);*/
                                        KC.DueDate = (String)JSON.Deserialize(JSON.Serialize(Cards[index].leankor__DueDateTime__c),String.class);
                                        KC.StartDate = cards[index].leankor__StartDateTime__c <= Cards[index].leankor__DueDateTime__c ? 
                                                                (String)JSON.Deserialize(JSON.Serialize(Cards[index].leankor__StartDateTime__c),String.class) :
                                                                KC.DueDate;
                                        /*SS 16.08.2018*/                       
                                        KC.PercentDone=cards[index].leankor__PercentComplete2__c;
                                        KC.leaf=true;
                                        KC.Title=cards[index].leankor__KanbanCardTemplate__r.Name;
                                        KC.Top=Integer.valueOf(cards[index].leankor__Top__c);
                                        KC.Bottom=Integer.valueOf(cards[index].leankor__Bottom__c);
                                        KC.Left=Integer.valueOf(cards[index].leankor__Left__c);
                                        KC.Width=Integer.valueOf(cards[index].leankor__Width__c);
                                        KC.Height=Integer.valueOf(cards[index].leankor__Height__c);
                                        KC.X=Integer.valueOf(cards[index].leankor__x__c);
                                        KC.Y=Integer.valueOf(cards[index].leankor__Y__c);
                                        KC.JSONData=cards[index].leankor__JSONData__c;
                                        KC.JSONDefinition=cards[index].leankor__JSONDefinition__c;
                                        KC.State=cards[index].leankor__State__c;
                                        KC.ZoneID=(cards[index].leankor__ZoneGUID__c==null?'':Cards[index].leankor__ZoneGUID__c);
                                        KC.MCForceID = (cards[index].leankor__MasterContainer__c ==Null ? '' :Cards[index].leankor__MasterContainer__c);
                                        KC.SWForceID = (cards[index].leankor__Swimlane__c == Null ? '' :Cards[index].leankor__Swimlane__c);
                                        KC.ZoneForceID = (cards[index].leankor__Zone__c == Null ? '' :Cards[index].leankor__Zone__c);
                                        KC.TemplateID=(cards[index].leankor__KanbanCardTemplate__c==null?'':Cards[index].leankor__KanbanCardTemplate__c);
                                        KC.TemplateName=cards[index].leankor__KanbanCardTemplate__r.Name;
                                        KC.Color=cards[index].leankor__KanbanCardTemplate__r.leankor__color__c;
                                        kc.BoardType =(cards[index].leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(Cards[index].leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :Cards[index].leankor__valueStream__r.leankor__BoardType__c));
                                        KC.Priority=Integer.valueOf(cards[index].leankor__Priority__c);
                                        KC.HarveyBall=string.valueOf(cards[index].leankor__PercentComplete2__c);
                                        KC.DateColor=cards[index].leankor__DateColor__c;
                                        KC.Description=cards[index].leankor__DescriptionLong__c;
                                        KC.AcceptanceCriteria=cards[index].leankor__AcceptanceCriteria__c;
                                        KC.ValueStreamCardLink=(cards[index].leankor__ValueStreamCardLink__c==null?'':Cards[index].leankor__ValueStreamCardLink__c);
                                        KC.ValueStreamLinkID=(cards[index].leankor__ValueStreamLink__c==null?'':Cards[index].leankor__ValueStreamLink__c);
                                        KC.ParentProjectRoomID = (cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ?'':Cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                                        KC.ValueStreamLinkBoardType=(cards[index].leankor__ValueStreamLink__c==null?'':Cards[index].leankor__ValueStreamLink__r.leankor__BoardType__c);
                                        KC.Account=(cards[index].leankor__Account__r.Id==null?'':Cards[index].leankor__Account__r.Id);
                                        KC.Contact=(cards[index].leankor__Contact__r.Id==null?'':Cards[index].leankor__Contact__r.Id);
                                        KC.CaseID=(cards[index].leankor__Case__r.Id==null?'':Cards[index].leankor__Case__r.Id);
                                        //KC.VSID=cards[index].leankor__ValueStream__c;
                                        KC.ValueStream=cards[index].leankor__ValueStream__c;
                                        KC.CmpID=cards[index].leankor__CmpID__c;
                                        KC.GUID=cards[index].leankor__GUID__c;
                                        KC.OwnerID=cards[index].OwnerID;
                                        KC.OwnerName = cards[index].Owner.Name;
                                        KC.AcceptanceCriteria= cards[index].leankor__AcceptanceCriteria__c;
                                        if(cards[index].OwnerId != null){
                                            resoruceList.add(cards[index].OwnerId);
                                        }
                                        KC.Point = cards[index].leankor__point__c;
                                        if(cards[index].leankor__Valuestream__r.leankor__BoardType__c == 'Kanban Board'||Cards[index].leankor__Valuestream__r.leankor__BoardType__c == 'Plan Board'){
                                            KC.AgilePointSequnece = ((cards[index].leankor__Valuestream__r.leankor__PointPicklist__c == '' || Cards[index].leankor__Valuestream__r.leankor__PointPicklist__c == null) ? '[]' :Cards[index].leankor__Valuestream__r.leankor__PointPicklist__c);
                                        }
                                        KC.SevenDayWorkWeek = cards[index].leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
                                        KC.VSTaskDueDateCheck = cards[index].leankor__Valuestream__r.leankor__TaskDateCheck__c;
                                        KC.AccountName=(cards[index].leankor__Account__r.Name==null?'':Cards[index].leankor__Account__r.Name);
                                        KC.ContactName=(cards[index].leankor__Contact__r.Name==null?'':Cards[index].leankor__Contact__r.Name);
                                        KC.CaseSubject= (cards[index].leankor__Case__c == null ?'':(Cards[index].leankor__Case__r.Subject == null ? 'Case : '+Cards[index].leankor__Case__r.CaseNumber :Cards[index].leankor__Case__r.Subject));                
                                        KC.CaseStatus=(cards[index].leankor__Case__r.Status==null?'':Cards[index].leankor__Case__r.Status);  
                                        KC.CasePriority=(cards[index].leankor__Case__r.Priority==null?'':Cards[index].leankor__Case__r.Priority); 
                                        KC.CaseTrigger=false;
                                        KC.Opportunity=(cards[index].leankor__Opportunity__c==null?'':Cards[index].leankor__Opportunity__c);
                                        KC.OpportunityName=(cards[index].leankor__Opportunity__c==null?'':Cards[index].leankor__Opportunity__r.Name);
                                        KC.ZoneTitle='';
                                        KC.LeavedZoneTitle='';
                                        KC.Base64Drawing='';
                                        KC.Base64FileType=''; 
                                        KC.KanbanUrl='';
                                        //RS 25.06.2018 For milestone in card hirarchy 
                                        //KC.ItemType='KC';
                                        KC.ItemType= (cards[index].RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC');
                                        //05/09/2022 :Changes added for showing KanbanCard and its dependents cards on CH with showField.
                                        if(AllRelatedCards.contains(KC.id)){
                                            KC.showField = true;
                                            temp = true;
                                            tempTask = true;
                                        }
                                        Kc.Order = ( cards[index].leankor__Order__c == null ? tempOrderValue : Cards[index].leankor__Order__c); //Cards[index].leankor__Order__c;
                                        
                                        //sending to UI IsSuccessorRecalculate field value
                                        KC.IsSuccessorRecalculate = cards[index].leankor__IsSuccessorRecalculate__c;
                                        KC.UrlLink = cards[index].leankor__UrlLink__c;
                                        // Date : 17/06/19
                                        KC.isAtRisk =cards[index].leankor__IsAtRisk__c;
                                        //25/Nov/2023 :  passing isShowWeekCalendar field with KC record.
                                        KC.isShowWeekCalendar = VS.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                                        //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                                        if(cards[index].leankor__Monday__c == false && cards[index].leankor__Tuesday__c == false && cards[index].leankor__Wednesday__c == false &&  cards[index].leankor__Thursday__c == false &&  cards[index].leankor__Friday__c == false &&  cards[index].leankor__Saturday__c == false &&  cards[index].leankor__Sunday__c == false){
                                            KC.Monday = true;
                                            KC.Tuesday = true;
                                            KC.Wednesday = true;
                                            KC.Thursday = true;
                                            KC.Friday = true;
                                            KC.Saturday = true;
                                            KC.Sunday = true;
                                        }else{
                                            KC.Monday = cards[index].leankor__Monday__c;
                                            KC.Tuesday = cards[index].leankor__Tuesday__c;
                                            KC.Wednesday = cards[index].leankor__Wednesday__c;
                                            KC.Thursday = cards[index].leankor__Thursday__c;
                                            KC.Friday = cards[index].leankor__Friday__c;
                                            KC.Saturday = cards[index].leankor__Saturday__c;
                                            KC.Sunday = cards[index].leankor__Sunday__c;
                                            KC.weekCalendar = cards[index].leankor__WeekCalendar__c;
                                        }
                                        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                            KC.isConstraintRecalculate = cards[index].leankor__IsConstraintRecalculate__c;
                                        }
                                        //yj 16.08.2017 - giving schedule mode records on load.
                                        if(cards[index].leankor__ScheduleModes__r != null && Cards[index].leankor__ScheduleModes__r.size()>0)
                                        {
                                            KC.SchedulingModeId = cards[index].leankor__ScheduleModes__r[0].Id;
                                            KC.ManuallyScheduled = cards[index].leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                                            KC.Effort = cards[index].leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                                            KC.EffortUnit = cards[index].leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                                            KC.SchedulingMode = cards[index].leankor__ScheduleModes__r[0].leankor__Mode__c;
                                            //Changes : Check constraint setting enable or not.
                                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                        	    KC.ConstraintType = (cards[index].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(Cards[index].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c)) ? Cards[index].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : '';
                                                KC.ConstraintDate = (cards[index].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null) ? Cards[index].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                                            }
										}
                                        //yj 28.03.2018 get all Task Records under each Kanban Card 
                                        if(taskMap.get(cards[index].Id) != null && taskMap.get(Cards[index].Id).size()>0){
                                        //if(cards[index].tasks.size() > 0){
                                        
                                            //18.12.2017 - for calendar new design
                                            
                                            if(calenderTaskAsMiniature)
                                            {
                                                leankor.kanbanToGanttController.MasterContainer Task = new leankor.kanbanToGanttController.MasterContainer();
                                                Task.Name='Tasks for '+KC.Name;
                                                Task.Id= KC.Id+'-T';
                                                Task.ValueStreamID = VSID;
                                                Task.leaf=false;
                                                Task.Title='Tasks for '+KC.Name;
                                                Task.Order = ( KC.Order == null ? (tempOrderValue + 0.3) : KC.Order+0.3);
                                                Task.expanded=true;
                                                Task.ItemType='Ghost';
                                                Task.Color ='#CCCCCC';
                                                Task.StartDate = KC.StartDate;
                                                Task.DueDate = KC.DueDate;
                                                //yj 28.03.2018 get all Task Records under each Kanban Card
                                                Task.children = getAllTask_Helper(taskMap.get(Cards[index].Id));
                                                //Task.children = getAllTask(cards[index].tasks);
                                            KanbanCardList.add(Task);
                                            }else{                                                
                                                //AllTaskList.addAll(getAllTask(cards[index].tasks));
                                                AllTaskList.addAll(getAllTask_Helper(taskMap.get(Cards[index].Id)));
                                        }                              
                                        }                              
										//29/07/2022 : Changes for showField on CH for Task.                              
                                        tempTask = false;
                                        KanbanCardList.add(KC);
                                        tempOrderValue++;
                                        cards.remove(index);
                                       
                                    }else{
                                        index++;
                                    }
                                }
                                
                                //27/05/2022 :Changes added for showing Zone on CH with showField.
                                if(temp){
                                    CardZone.showField = true;
                                    temp= false;
                                }
                                CardZone.StartDate =  String.valueOf(json.deserialize(JSON.Serialize(minSDCard), String.class));
                                CardZone.DueDate =  String.valueOf(json.deserialize(JSON.Serialize(minEDCard), String.class));
                                CardZone.children=KanbanCardList;
                                CardZone.expanded=true;
                                if(singleMCflag){
                                    ZoneList.add(CardZone);
                                }else{
                                    ListCardZone.add(CardZone);
                                }
                                if(count==0){
                                    minSDZone=minSDCard;
                                    minEDZone=minEDCard;
                                    count++;
                                }
                                if(minSDCard<minSDZone) 
                                    minSDZone=minSDCard;
                                if(minEDCard>minEDZone) 
                                    minEDZone=minEDCard;
                            }
                        }
                        cardMC.StartDate =  String.valueOf(json.deserialize(JSON.Serialize(minSDCard), String.class));
						cardMC.DueDate  =  String.valueOf(json.deserialize(JSON.Serialize(minEDCard), String.class));
                        cardMC.children= ListCardZone;
                        cardMC.expanded=true;
                        if(ListCardZone.size()>0){
                            ZoneList.add(cardMC);
                        }
                    }
                }else if(VS.leankor__BoardType__c == 'WhiteBoard' || VS.leankor__BoardType__c == 'DashBoard'){
                    for(leankor__Zone__C Zone : VS.leankor__Zones__r){
                        String zName ='';
                        leankor.KanbanToGanttController.MasterContainer CardZone=new leankor.KanbanToGanttController.MasterContainer();
                        CardZone.Id=Zone.Id;
                        CardZone.Name= Zone.Name;
                        CardZone.leaf=false;
                        CardZone.Title=Zone.leankor__Title__c;
                        CardZone.Top=Integer.valueOf(Zone.leankor__Top__c);
                        CardZone.Bottom=Integer.valueOf(Zone.leankor__Bottom__c);
                        CardZone.Left=Integer.valueOf(Zone.leankor__Left__c);
                        CardZone.Width=Integer.valueOf(Zone.leankor__Width__c);
                        CardZone.Height=Integer.valueOf(Zone.leankor__Height__c);
                        CardZone.X=Integer.valueOf(Zone.leankor__x__c);
                        CardZone.Y=Integer.valueOf(Zone.leankor__Y__c);
                        CardZone.JSONDefinition=Zone.leankor__JSONDefinition__c;
                        CardZone.ValueStreamCardLink=(Zone.leankor__ValueStreamCardLink__c==null?'':Zone.leankor__ValueStreamCardLink__c);
                        CardZone.ValueStreamLinkID=(Zone.leankor__ValueStreamLink__c==null?'':Zone.leankor__ValueStreamLink__c);
                        CardZone.ValueStream = Zone.leankor__ValueStream__c;
                        CardZone.CmpID=Zone.leankor__CmpID__c;
                        CardZone.GUID=Zone.leankor__GUID__c;
                        CardZone.OwnerID=Zone.OwnerID;
                        CardZone.CaseStatus=(Zone.leankor__CaseStatus__c==null?'':Zone.leankor__CaseStatus__c);  
                        CardZone.EntryFlowName=Zone.leankor__EntryFlowName__c;
                        CardZone.ExitFlowName=Zone.leankor__ExitFlowName__c;
                        CardZone.ZoneMode=Zone.leankor__ZoneMode__c;
                        CardZone.KanbanSequence=Zone.leankor__KanbanSequence__c;
                        CardZone.DefaultHeight=Integer.valueOf(Zone.leankor__DefaultHeight__c);
                        CardZone.DefaultWidth=Integer.valueOf(Zone.leankor__DefaultWidth__c);
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
                        CardZone.ItemType = 'ZONE';
                        CardZone.Color  ='#CCCCCC';
                        List<leankor.KanbanToGanttController.MasterContainer> KanbanCardList=new List<leankor.KanbanToGanttController.MasterContainer>();
                        Integer tempCount=0;
                        Decimal tempOrderValue = 1.0;
                       // for(leankor__KanbanCard__c KnbnCard: Cards){
                        for(integer index = 0; index < cards.size();){
                            if(Zone.leankor__GUID__c==cards[index].leankor__ZoneGUID__c){
                                if(tempCount==0){
                                    if(cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c){
                                        minSDCard=cards[index].leankor__StartDateTime__c;
                                        minEDCard=cards[index].leankor__DueDateTime__c;
                                        tempCount++;
                                    }
                                }
                                if(cards[index].leankor__StartDate__c<minSDCard) 
                                    minSDCard=cards[index].leankor__StartDateTime__c;
                                if(cards[index].leankor__DueDate__c>minEDCard) 
                                    minEDCard=cards[index].leankor__DueDateTime__c;
                                leankor.KanbanToGanttController.MasterContainer KC=new leankor.KanbanToGanttController.MasterContainer();
                                KC.Id=cards[index].id;
                                KC.CardID=cards[index].leankor__CardID__c;
                                KC.ForceID=cards[index].id;
                                KC.Name=cards[index].name;
                                KC.EstimatedDuration=cards[index].leankor__EstimatedDuration__c;
                                KC.EffortRemaining = Integer.valueof(cards[index].leankor__EffortRemaining__c);
                                if(cards[index].leankor__DurationUnits__c=='Days')          KC.DurationUnits='d';
                                else if(cards[index].leankor__DurationUnits__c=='Weeks')    KC.DurationUnits='w';
                                else if(cards[index].leankor__DurationUnits__c=='Hours')    KC.DurationUnits='h';
                                else if(cards[index].leankor__DurationUnits__c=='Months')   KC.DurationUnits='mo';
                                else if(cards[index].leankor__DurationUnits__c=='Years')    KC.DurationUnits='y';
                                else if(cards[index].leankor__DurationUnits__c=='Minutes')  KC.DurationUnits='mi';
                               /* if(KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c){
                                    KC.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                                    KC.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                                }else{
                                    KC.StartDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                                    KC.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                                }*/ //Simplified SD 02-03-17
                                /*SS 16.08.2018*/
                                //With String class methods we are loosing TZ details 
                                //So used serialize to encrypt DateTime value to String formate and 
                                //deserialized for removing double code notation from String value
                                /*
                                KC.StartDate = KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c ? 
                                                                                String.valueofGmt(KnbnCard.leankor__StartDateTime__c) :
                                                                                String.valueofGmt(KnbnCard.leankor__DueDateTime__c);
                                KC.DueDate = String.valueofGmt(KnbnCard.leankor__DueDateTime__c);*/
                                KC.DueDate = (String)JSON.Deserialize(JSON.Serialize(cards[index].leankor__DueDateTime__c),String.class);
                                KC.StartDate = cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c ? 
                                                        (String)JSON.Deserialize(JSON.Serialize(cards[index].leankor__StartDateTime__c),String.class) :
                                                        KC.DueDate;
                                /*SS 16.08.2018*/
                                KC.PercentDone=cards[index].leankor__PercentComplete2__c;
                                KC.leaf=true;
                                KC.Title=cards[index].leankor__KanbanCardTemplate__r.Name;
                                KC.Top=Integer.valueOf(cards[index].leankor__Top__c);
                                KC.Bottom=Integer.valueOf(cards[index].leankor__Bottom__c);
                                KC.Left=Integer.valueOf(cards[index].leankor__Left__c);
                                KC.Width=Integer.valueOf(cards[index].leankor__Width__c);
                                KC.Height=Integer.valueOf(cards[index].leankor__Height__c);
                                KC.X=Integer.valueOf(cards[index].leankor__x__c);
                                KC.Y=Integer.valueOf(cards[index].leankor__Y__c);
                                KC.JSONData=cards[index].leankor__JSONData__c;
                                KC.JSONDefinition=cards[index].leankor__JSONDefinition__c;
                                KC.State=cards[index].leankor__State__c;
                                KC.ZoneID=(cards[index].leankor__ZoneGUID__c==null?'':cards[index].leankor__ZoneGUID__c);
                                KC.MCForceID = (cards[index].leankor__MasterContainer__c ==Null ? '' :cards[index].leankor__MasterContainer__c);
                                KC.SWForceID = (cards[index].leankor__Swimlane__c == Null ? '' :cards[index].leankor__Swimlane__c);
                                KC.ZoneForceID = (cards[index].leankor__Zone__c == Null ? '' :cards[index].leankor__Zone__c);
                                KC.TemplateID=(cards[index].leankor__KanbanCardTemplate__c==null?'':cards[index].leankor__KanbanCardTemplate__c);
                                KC.TemplateName=cards[index].leankor__KanbanCardTemplate__r.Name;
                                KC.Color=cards[index].leankor__KanbanCardTemplate__r.leankor__color__c;
                                kc.BoardType =(cards[index].leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(cards[index].leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :cards[index].leankor__valueStream__r.leankor__BoardType__c));
                                KC.Priority=Integer.valueOf(cards[index].leankor__Priority__c);
                                KC.HarveyBall=string.valueOf(cards[index].leankor__PercentComplete2__c);
                                KC.DateColor=cards[index].leankor__DateColor__c;
                                KC.Description=cards[index].leankor__DescriptionLong__c;
                                KC.AcceptanceCriteria=cards[index].leankor__AcceptanceCriteria__c;
                                KC.ValueStreamCardLink=(cards[index].leankor__ValueStreamCardLink__c==null?'':cards[index].leankor__ValueStreamCardLink__c);
                                KC.ValueStreamLinkID=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__c);
                                KC.ParentProjectRoomID = (cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ?'':cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                                KC.ValueStreamLinkBoardType=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__r.leankor__BoardType__c);
                                KC.Account=(cards[index].leankor__Account__r.Id==null?'':cards[index].leankor__Account__r.Id);
                                KC.Contact=(cards[index].leankor__Contact__r.Id==null?'':cards[index].leankor__Contact__r.Id);
                                KC.CaseID=(cards[index].leankor__Case__r.Id==null?'':cards[index].leankor__Case__r.Id);
                                //KC.VSID=cards[index].leankor__ValueStream__c;
                                KC.ValueStream=cards[index].leankor__ValueStream__c;
                                KC.CmpID=cards[index].leankor__CmpID__c;
                                KC.GUID=cards[index].leankor__GUID__c;
                                KC.OwnerID=cards[index].OwnerID;
                                KC.OwnerName = cards[index].Owner.Name;
                                KC.AcceptanceCriteria= cards[index].leankor__AcceptanceCriteria__c;
                                if(cards[index].OwnerId != null){
                                    resoruceList.add(cards[index].OwnerId);
                                }
                                KC.Point = cards[index].leankor__point__c;
                                if(cards[index].leankor__Valuestream__r.leankor__BoardType__c == 'Kanban Board' || cards[index].leankor__Valuestream__r.leankor__BoardType__c == 'Plan Board'){
                                    KC.AgilePointSequnece = ((cards[index].leankor__Valuestream__r.leankor__PointPicklist__c == '' || cards[index].leankor__Valuestream__r.leankor__PointPicklist__c == null) ? '[]' :cards[index].leankor__Valuestream__r.leankor__PointPicklist__c);
                                }
                                KC.SevenDayWorkWeek = cards[index].leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
                                KC.VSTaskDueDateCheck = cards[index].leankor__Valuestream__r.leankor__TaskDateCheck__c;
                                KC.AccountName=(cards[index].leankor__Account__r.Name==null?'':cards[index].leankor__Account__r.Name);
                                KC.ContactName=(cards[index].leankor__Contact__r.Name==null?'':cards[index].leankor__Contact__r.Name);
                                KC.CaseSubject= (cards[index].leankor__Case__c == null ?'':(cards[index].leankor__Case__r.Subject == null ? 'Case : '+cards[index].leankor__Case__r.CaseNumber :cards[index].leankor__Case__r.Subject));                
                                KC.CaseStatus=(cards[index].leankor__Case__r.Status==null?'':cards[index].leankor__Case__r.Status);  
                                KC.CasePriority=(cards[index].leankor__Case__r.Priority==null?'':cards[index].leankor__Case__r.Priority); 
                                KC.CaseTrigger=false;
                                KC.Opportunity=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__c);
                                KC.OpportunityName=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__r.Name);
                                KC.ZoneTitle='';
                                KC.LeavedZoneTitle='';
                                KC.Base64Drawing='';
                                KC.Base64FileType=''; 
                                KC.KanbanUrl='';
                                //05/07/2022 :Changes added for showing KanbanCard on CH with showField.
                                if(AllRelatedCards.contains(KC.id)){
                                    KC.showField = true;
                                    temp = true;
                                }
                                //*****SS 02.07.2018 *****//
                                //KC.ItemType='KC';
                                KC.ItemType= (cards[index].RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC');
                                //*****SS 02.07.2018 *****//
                                Kc.Order = ( cards[index].leankor__Order__c == null ? tempOrderValue : cards[index].leankor__Order__c); //cards[index].leankor__Order__c;
                                
                                //sending to UI IsSuccessorRecalculate field value
                                KC.IsSuccessorRecalculate = cards[index].leankor__IsSuccessorRecalculate__c;
                                KC.UrlLink = cards[index].leankor__UrlLink__c;
                                // Date : 17/06/19
                                KC.isAtRisk =cards[index].leankor__IsAtRisk__c;
                                //25/Nov/2023 :  passing isShowWeekCalendar field with KC record.
                                KC.isShowWeekCalendar = VS.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                                //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                                if(cards[index].leankor__Monday__c == false && cards[index].leankor__Tuesday__c == false && cards[index].leankor__Wednesday__c == false &&  cards[index].leankor__Thursday__c == false &&  cards[index].leankor__Friday__c == false &&  cards[index].leankor__Saturday__c == false &&  cards[index].leankor__Sunday__c == false){
                                    KC.Monday = true;
                                    KC.Tuesday = true;
                                    KC.Wednesday = true;
                                    KC.Thursday = true;
                                    KC.Friday = true;
                                    KC.Saturday = true;
                                    KC.Sunday = true;
                                }else{
                                    KC.Monday = cards[index].leankor__Monday__c;
                                    KC.Tuesday = cards[index].leankor__Tuesday__c;
                                    KC.Wednesday = cards[index].leankor__Wednesday__c;
                                    KC.Thursday = cards[index].leankor__Thursday__c;
                                    KC.Friday = cards[index].leankor__Friday__c;
                                    KC.Saturday = cards[index].leankor__Saturday__c;
                                    KC.Sunday = cards[index].leankor__Sunday__c;
                                    KC.weekCalendar = cards[index].leankor__WeekCalendar__c;
                                }
                                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                    KC.isConstraintRecalculate = cards[index].leankor__IsConstraintRecalculate__c;
                                }
                                //yj 16.08.2017 - giving schedule mode records on load.
                                if(cards[index].leankor__ScheduleModes__r != null && cards[index].leankor__ScheduleModes__r.size()>0)
                                {
                                    KC.SchedulingModeId = cards[index].leankor__ScheduleModes__r[0].Id;
                                    KC.ManuallyScheduled = cards[index].leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                                    KC.Effort = cards[index].leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                                    KC.EffortUnit = cards[index].leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                                    KC.SchedulingMode = cards[index].leankor__ScheduleModes__r[0].leankor__Mode__c;
                                }
                                
                                //yj 28.03.2018 get all Task Records under each Kanban Card 
                                if(taskMap.get(cards[index].Id) != null && taskMap.get(cards[index].Id).size()>0){
                                //if(cards[index].tasks.size() > 0){
                                        
                                    //18.12.2017 - for calendar new design
                                    if(calenderTaskAsMiniature)
                                    {
                                        leankor.kanbanToGanttController.MasterContainer Task = new leankor.kanbanToGanttController.MasterContainer();
                                        Task.Name='Tasks for '+KC.Name;
                                        Task.Id= KC.Id+'-T';
                                        Task.ValueStreamID = VSID;
                                        Task.leaf=false;
                                        Task.Title='Tasks for '+KC.Name;
                                        Task.Order = (KC.Order+0.3);
                                        Task.expanded=true;
                                        Task.ItemType='Ghost';
                                        Task.Color ='#CCCCCC';
                                        Task.StartDate = KC.StartDate;
                                        Task.DueDate = KC.DueDate;
                                        //yj 28.03.2018 get all Task Records under each Kanban Card
                                        Task.children = getAllTask_Helper(taskMap.get(cards[index].Id));
                                        //Task.children = getAllTask(cards[index].tasks);
                                    KanbanCardList.add(Task);
                                    }else{                                                
                                        //yj 28.03.2018 get all Task Records under each Kanban Card                                            
                                        //AllTaskList.addAll(getAllTask(cards[index].tasks));
                                        AllTaskList.addAll(getAllTask_Helper(taskMap.get(cards[index].Id)));



                                }                              
                                }                              
                                KanbanCardList.add(KC);
                                tempOrderValue++;
                                cards.remove(index);
                            }
                            else{
                                index++;
                            }
                        }
                        
                        CardZone.StartDate  =  String.valueOf(json.deserialize(JSON.Serialize(minSDCard), String.class));
                        CardZone.DueDate  =  String.valueOf(json.deserialize(JSON.Serialize(minEDCard), String.class));
                        CardZone.children=KanbanCardList;
                        CardZone.expanded=true;
                        //05/07/2022 :Changes added for showing Zone on CH with showField.
                        if(temp){
                            CardZone.showField = true;
                            temp = false;
                        }
                        ZoneList.add(CardZone);
                        if(count==0){
                            minSDZone=minSDCard;
                            minEDZone=minEDCard;
                            count++;
                        }
                        if(minSDCard<minSDZone) 
                            minSDZone=minSDCard;
                        if(minEDCard>minEDZone) 
                            minEDZone=minEDCard;
                    }               
                }
                integer flag=0,tempCount_c=0;
                DateTime minSDCard_c,minEDCard_c;
                List<leankor.KanbanToGanttController.MasterContainer> noZoneKanbanCardList=new List<leankor.KanbanToGanttController.MasterContainer>();
                leankor.KanbanToGanttController.MasterContainer noZone=new leankor.KanbanToGanttController.MasterContainer();
                Decimal tempOrder = 1.0;
                //for(leankor__KanbanCard__c KnbnCard: Cards){
                for(integer index = 0 ; index < cards.size();){
                    if((cards[index].leankor__ZoneGUID__c==null || cards[index].leankor__ZoneGUID__c=='' ) && cards[index].leankor__ValueStream__c==VS.Id && cards[index].leankor__valueStream__r.leankor__BoardType__c != 'Portfolio View'){
                        flag=1;
                        if(tempCount_c==0){
                            if(cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c){
                                minSDCard_c=cards[index].leankor__StartDateTime__c;
                                minEDCard_c=cards[index].leankor__DueDateTime__c;
                                tempCount_c++;
                            }
                        }
                        if(cards[index].leankor__StartDateTime__c<minSDCard_c)
                            minSDCard_c=cards[index].leankor__StartDateTime__c;
                        if(cards[index].leankor__DueDateTime__c>minEDCard_c)
                            minEDCard_c=cards[index].leankor__DueDateTime__c;
                        leankor.KanbanToGanttController.MasterContainer noZoneKC=new leankor.KanbanToGanttController.MasterContainer();
                            noZoneKC.Id=cards[index].id;
                            noZoneKC.CardID=cards[index].leankor__CardID__c;
                            noZoneKC.ForceID=cards[index].id;
                            noZoneKC.Name=cards[index].name;
                            noZoneKC.EstimatedDuration=cards[index].leankor__EstimatedDuration__c;
                            if(cards[index].leankor__DurationUnits__c=='Days')
                                noZoneKC.DurationUnits='d';

                            else if(cards[index].leankor__DurationUnits__c=='Weeks') 
                                noZoneKC.DurationUnits='w';
                            else if(cards[index].leankor__DurationUnits__c=='Hours') 
                                noZoneKC.DurationUnits='h';
                             else if(cards[index].leankor__DurationUnits__c=='Months')
                                noZoneKC.DurationUnits='mo';
                            else if(cards[index].leankor__DurationUnits__c=='Years') 
                                noZoneKC.DurationUnits='y';
                            else if(cards[index].leankor__DurationUnits__c=='Minutes') 
                                noZoneKC.DurationUnits='mi';
                           /* if(KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c){
                                noZoneKC.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                                noZoneKC.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                            }else{
                                noZoneKC.StartDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                                noZoneKC.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                            } */ //Simplified SD 02-03-17
                            /*SS 16.08.2018*/
                            //With String class methods we are loosing TZ details 
                            //So used serialize to encrypt DateTime value to String formate and 
                            //deserialized for removing double code notation from String value
                            /*
                            noZoneKC.StartDate = KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c ? 
                                                                                String.valueofGmt(KnbnCard.leankor__StartDateTime__c) :
                                                                                String.valueofGmt(KnbnCard.leankor__DueDateTime__c);
                            noZoneKC.DueDate = String.valueofGmt(KnbnCard.leankor__DueDateTime__c);*/
                            noZoneKC.DueDate = (String)JSON.Deserialize(JSON.Serialize(cards[index].leankor__DueDateTime__c),String.class);
                            noZoneKC.StartDate = cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c ? 
                                                    (String)JSON.Deserialize(JSON.Serialize(cards[index].leankor__StartDateTime__c),String.class) :
                                                    noZoneKC.DueDate;
                            /*SS 16.08.2018*/
                            noZoneKC.PercentDone=cards[index].leankor__PercentComplete2__c;
                            noZoneKC.leaf=true;
                            noZoneKC.Title=cards[index].leankor__KanbanCardTemplate__r.Name;
                            noZoneKC.Top=Integer.valueOf(cards[index].leankor__Top__c);
                            noZoneKC.Bottom=Integer.valueOf(cards[index].leankor__Bottom__c);
                            noZoneKC.Left=Integer.valueOf(cards[index].leankor__Left__c);
                            noZoneKC.Width=Integer.valueOf(cards[index].leankor__Width__c);
                            noZoneKC.Height=Integer.valueOf(cards[index].leankor__Height__c);
                            noZoneKC.X=Integer.valueOf(cards[index].leankor__x__c);
                            noZoneKC.Y=Integer.valueOf(cards[index].leankor__Y__c);
                            noZoneKC.JSONData=cards[index].leankor__JSONData__c;
                            noZoneKC.JSONDefinition=cards[index].leankor__JSONDefinition__c;
                            noZoneKC.State=cards[index].leankor__State__c;
                            noZoneKC.BoardType =(cards[index].leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(cards[index].leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :cards[index].leankor__valueStream__r.leankor__BoardType__c));
                            noZoneKC.ZoneID=(cards[index].leankor__ZoneGUID__c==null?'':cards[index].leankor__ZoneGUID__c);
                            noZoneKC.MCForceID = (cards[index].leankor__MasterContainer__c ==Null ? '' :cards[index].leankor__MasterContainer__c);
                            noZoneKC.SWForceID = (cards[index].leankor__Swimlane__c == Null ? '' :cards[index].leankor__Swimlane__c);
                            noZoneKC.ZoneForceID = (cards[index].leankor__Zone__c == Null ? '' :cards[index].leankor__Zone__c);
                            noZoneKC.TemplateID=(cards[index].leankor__KanbanCardTemplate__c==null?'':cards[index].leankor__KanbanCardTemplate__c);
                            noZoneKC.TemplateName=cards[index].leankor__KanbanCardTemplate__r.Name;
                            noZoneKC.Color=cards[index].leankor__KanbanCardTemplate__r.leankor__Color__c;
                            noZoneKC.Priority=Integer.valueOf(cards[index].leankor__Priority__c);
                            noZoneKC.HarveyBall=string.valueOf(cards[index].leankor__PercentComplete2__c);
                            noZoneKC.DateColor=cards[index].leankor__DateColor__c;
                            noZoneKC.Description=cards[index].leankor__DescriptionLong__c;
                            noZoneKC.AcceptanceCriteria=cards[index].leankor__AcceptanceCriteria__c;
                            noZoneKC.ValueStreamCardLink=(cards[index].leankor__ValueStreamCardLink__c==null?'':cards[index].leankor__ValueStreamCardLink__c);
                            noZoneKC.ValueStreamLinkID=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__c);
                            noZoneKC.ParentProjectRoomID = (cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ?'':cards[index].leankor__ValueStreamLink__r.leankor__ProjectRoom__c);
                            noZoneKC.ValueStreamLinkBoardType=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__r.leankor__BoardType__c);
                            noZoneKC.Opportunity=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__c);
                            noZoneKC.OpportunityName=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__r.Name);
                            noZoneKC.Account=(cards[index].leankor__Account__r.Id==null?'':cards[index].leankor__Account__r.Id);
                            noZoneKC.Contact=(cards[index].leankor__Contact__r.Id==null?'':cards[index].leankor__Contact__r.Id);
                            noZoneKC.CaseID=(cards[index].leankor__Case__r.Id==null?'':cards[index].leankor__Case__r.Id);
                            noZoneKC.ValueStream=cards[index].leankor__ValueStream__c;
                            noZoneKC.EffortRemaining = Integer.valueof(cards[index].leankor__EffortRemaining__c);
                            noZoneKC.CmpID=cards[index].leankor__CmpID__c;
                            noZoneKC.GUID=cards[index].leankor__GUID__c;
                            noZoneKC.OwnerID=cards[index].OwnerID;
                            noZoneKC.OwnerName = cards[index].Owner.Name;
                            if(cards[index].OwnerId != null){
                               resoruceList.add(cards[index].OwnerId);
                            }
                            noZoneKC.VSTaskDueDateCheck = cards[index].leankor__Valuestream__r.leankor__TaskDateCheck__c;
                            noZoneKC.AccountName=(cards[index].leankor__Account__r.Name==null?'':cards[index].leankor__Account__r.Name);
                            noZoneKC.ContactName=(cards[index].leankor__Contact__r.Name==null?'':cards[index].leankor__Contact__r.Name);
                            noZoneKC.CaseSubject = (cards[index].leankor__Case__c == null ?'':(cards[index].leankor__Case__r.Subject == null ? 'Case : '+cards[index].leankor__Case__r.CaseNumber :cards[index].leankor__Case__r.Subject));                
                            noZoneKC.CaseStatus=(cards[index].leankor__Case__r.Status==null?'':cards[index].leankor__Case__r.Status);  
                            noZoneKC.CasePriority=(cards[index].leankor__Case__r.Priority==null?'':cards[index].leankor__Case__r.Priority); 
                            noZoneKC.CaseTrigger=false;
                            noZoneKC.ZoneTitle='';
                            noZoneKC.LeavedZoneTitle='';
                            noZoneKC.Base64Drawing='';
                            noZoneKC.Base64FileType=''; 
                            noZoneKC.KanbanUrl='';
                        //*****SS 02.07.2018 *****//
                        //noZoneKC.ItemType='KC';
                        noZoneKC.ItemType= (cards[index].RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC');
                        //*****SS 02.07.2018 *****//
                            noZoneKc.Order = (cards[index].leankor__Order__c == null ? tempOrder :cards[index].leankor__Order__c);                                                   
                            //sending to UI IsSuccessorRecalculate field value
                            noZoneKc.IsSuccessorRecalculate = cards[index].leankor__IsSuccessorRecalculate__c;
                            noZoneKC.UrlLink = cards[index].leankor__UrlLink__c;
                            // Date : 17/06/19
                            noZoneKC.isAtRisk =cards[index].leankor__IsAtRisk__c;
                            //05/07/2022 :Changes added for showing KanbanCard on CH with showField.
                            if(AllRelatedCards.contains(cards[index].id) || KanbanMap.ContainsKey(cards[index].id)){
                                noZoneKC.showField = true;
                            }
                            //25/Nov/2023 :  passing isShowWeekCalendar field with KC record.
                            noZoneKC.isShowWeekCalendar = VS.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                            //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                            if(cards[index].leankor__Monday__c == false && cards[index].leankor__Tuesday__c == false && cards[index].leankor__Wednesday__c == false &&  cards[index].leankor__Thursday__c == false &&  cards[index].leankor__Friday__c == false &&  cards[index].leankor__Saturday__c == false &&  cards[index].leankor__Sunday__c == false){
                                noZoneKC.Monday = true;
                                noZoneKC.Tuesday = true;
                                noZoneKC.Wednesday = true;
                                noZoneKC.Thursday = true;
                                noZoneKC.Friday = true;
                                noZoneKC.Saturday = true;
                                noZoneKC.Sunday = true;
                            }else{
                                noZoneKC.Monday = cards[index].leankor__Monday__c;
                                noZoneKC.Tuesday = cards[index].leankor__Tuesday__c;
                                noZoneKC.Wednesday = cards[index].leankor__Wednesday__c;
                                noZoneKC.Thursday = cards[index].leankor__Thursday__c;
                                noZoneKC.Friday = cards[index].leankor__Friday__c;
                                noZoneKC.Saturday = cards[index].leankor__Saturday__c;
                                noZoneKC.Sunday = cards[index].leankor__Sunday__c;
                                noZoneKC.weekCalendar = cards[index].leankor__WeekCalendar__c;
                            }
                            //yj 16.08.2017 - giving schedule mode records on load.
                            if(cards[index].leankor__ScheduleModes__r != null && cards[index].leankor__ScheduleModes__r.size()>0)
                            {
                                noZoneKC.SchedulingModeId = cards[index].leankor__ScheduleModes__r[0].Id;
                                noZoneKC.ManuallyScheduled = cards[index].leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                                noZoneKC.Effort = cards[index].leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                                noZoneKC.EffortUnit = cards[index].leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                                noZoneKC.SchedulingMode = cards[index].leankor__ScheduleModes__r[0].leankor__Mode__c;
                            }                                                     
                            //yj 28.03.2018 get all Task Records under each Kanban Card                                                                                      
                            if(taskMap.get(cards[index].Id) != null && taskMap.get(cards[index].Id).size() > 0){
                                //18.12.2017 - for calendar new design
                                if(calenderTaskAsMiniature)
                                {
                                        leankor.kanbanToGanttController.MasterContainer Task = new leankor.kanbanToGanttController.MasterContainer();
                                    Task.Name='Tasks for '+noZoneKC.Name;
                                    Task.Id= noZoneKC.Id+'-T';
                                        Task.ValueStreamID = VSID;
                                    Task.leaf=false;
                                    Task.Title='Tasks for '+noZoneKC.Name;
                                    Task.expanded=true;
                                    Task.ItemType='Ghost';
                                    Task.Color ='#CCCCCC';
                                    Task.Order = (noZoneKC.Order+0.3);
                                    Task.StartDate = noZoneKC.StartDate;
                                    Task.DueDate = noZoneKC.DueDate;
                                        //yj 28.03.2018 get all Task Records under each Kanban Card
                                        Task.children = getAllTask_Helper(taskMap.get(cards[index].Id));
                                        //Task.children = getAllTask(cards[index].tasks);
                                       
                                noZoneKanbanCardList.add(Task);
                               }else{
                                    //yj 28.03.2018 get all Task Records under each Kanban Card 
                                    //AllTaskList.addAll(getAllTask(cards[index].tasks));
                                    AllTaskList.addAll(getAllTask_Helper(taskMap.get(cards[index].Id)));
                            }
                            }
                            tempOrder++;
                        noZoneKanbanCardList.add(noZoneKC);
                        if(flag==1){
                            noZone.Name='No Zone';
                            noZone.Id='RandomId'+noZoneIdCount;
                            noZone.leaf=false;
                            noZone.Title='No Zone';
                            noZone.expanded=true;
                            noZone.Color  ='#CCCCCC';
                            noZone.ItemType = 'NOZONE';
                            noZone.ValueStream=cards[index].leankor__ValueStream__c;
                            flag++;
                        }// end Of IF
                        cards.remove(index);
                    }else if((cards[index].leankor__ZoneGUID__c==null || cards[index].leankor__ZoneGUID__c=='' ) && cards[index].leankor__ValueStream__c==VS.Id && cards[index].leankor__valueStream__r.leankor__BoardType__c == 'Portfolio View'){
                        leankor.KanbanToGanttController.MasterContainer portKC=new leankor.KanbanToGanttController.MasterContainer();
                            portKC.Id=cards[index].id;
                            portKC.CardID =cards[index].leankor__CardID__c; 
                            portKC.ForceID=cards[index].id;
                            portKC.Name=cards[index].name;
                            portKC.EstimatedDuration=cards[index].leankor__EstimatedDuration__c;
                            if(cards[index].leankor__DurationUnits__c=='Days')       portKC.DurationUnits='d';
                            else if(cards[index].leankor__DurationUnits__c=='Weeks')    portKC.DurationUnits='w';
                            else if(cards[index].leankor__DurationUnits__c=='Hours')    portKC.DurationUnits='h';
                            else if(cards[index].leankor__DurationUnits__c=='Months')   portKC.DurationUnits='mo';
                            else if(cards[index].leankor__DurationUnits__c=='Years')    portKC.DurationUnits='y';
                            else if(cards[index].leankor__DurationUnits__c=='Minutes')  portKC.DurationUnits='mi';
                            /*if(cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c){
                                portKC.StartDate = JSON.Serialize(cards[index].leankor__StartDateTime__c);
                                portKC.DueDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                            }else{
                                portKC.StartDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                                portKC.DueDate = JSON.Serialize(cards[index].leankor__DueDateTime__c);
                            } */ //Simplified SD 02-03-17
                            portKC.StartDate = cards[index].leankor__StartDateTime__c <= cards[index].leankor__DueDateTime__c ? 
                                                                                String.valueofGmt(cards[index].leankor__StartDateTime__c) :
                                                                                String.valueofGmt(cards[index].leankor__DueDateTime__c);
                            portKC.DueDate = String.valueofGmt(cards[index].leankor__DueDateTime__c);
                            portKC.PercentDone=cards[index].leankor__PercentComplete2__c;
                            portKC.leaf=true;
                            portKC.Title=cards[index].leankor__Title__c;
                            portKC.Top=Integer.valueOf(cards[index].leankor__Top__c);
                            portKC.Bottom=Integer.valueOf(cards[index].leankor__Bottom__c);
                            portKC.Left=Integer.valueOf(cards[index].leankor__Left__c);
                            portKC.Width=Integer.valueOf(cards[index].leankor__Width__c);
                            portKC.Height=Integer.valueOf(cards[index].leankor__Height__c);
                            portKC.X=Integer.valueOf(cards[index].leankor__x__c);
                            portKC.BoardType =cards[index].leankor__valueStream__r.leankor__BoardType__c;
                            portKC.Y=Integer.valueOf(cards[index].leankor__Y__c);
                            portKC.JSONData=cards[index].leankor__JSONData__c;
                            portKC.JSONDefinition=cards[index].leankor__JSONDefinition__c;
                            portKC.State=cards[index].leankor__State__c;
                            portKC.ZoneID='';
                            portKC.TemplateID=(cards[index].leankor__KanbanCardTemplate__c==null?'':cards[index].leankor__KanbanCardTemplate__c);
                            portKC.TemplateName=cards[index].leankor__KanbanCardTemplate__r.Name;
                            portKC.Color=cards[index].leankor__Color__c;
                            portKC.Priority=Integer.valueOf(cards[index].leankor__Priority__c);
                            portKC.HarveyBall=string.valueOf(cards[index].leankor__PercentComplete2__c);
                            portKC.DateColor=cards[index].leankor__DateColor__c;
                            portKC.Description=cards[index].leankor__DescriptionLong__c;
                            portKC.AcceptanceCriteria=cards[index].leankor__AcceptanceCriteria__c;
                            PortKC.EffortRemaining = Integer.valueof(cards[index].leankor__EffortRemaining__c);
                            portKC.ValueStreamCardLink=(cards[index].leankor__ValueStreamCardLink__c==null?'':cards[index].leankor__ValueStreamCardLink__c);
                            portKC.ValueStreamLinkID=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__c);
                            portKC.ValueStreamLinkBoardType=(cards[index].leankor__ValueStreamLink__c==null?'':cards[index].leankor__ValueStreamLink__r.leankor__BoardType__c);
                            portKC.Opportunity=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__c);
                            portKC.OpportunityName=(cards[index].leankor__Opportunity__c==null?'':cards[index].leankor__Opportunity__r.Name);
                            portKC.Account=(cards[index].leankor__Account__r.Id==null?'':cards[index].leankor__Account__r.Id);
                            portKC.Contact=(cards[index].leankor__Contact__r.Id==null?'':cards[index].leankor__Contact__r.Id);
                            portKC.CaseID=(cards[index].leankor__Case__r.Id==null?'':cards[index].leankor__Case__r.Id);
                            portKC.ValueStream=cards[index].leankor__ValueStream__c;
                            portKC.CmpID=cards[index].leankor__CmpID__c;
                            portKC.GUID=cards[index].leankor__GUID__c;
                            portKC.OwnerID=cards[index].OwnerID;
                            portKC.OwnerName = cards[index].Owner.Name;
                            if(cards[index].OwnerId != null){
                                resoruceList.add(cards[index].OwnerId);
                            }
                            portKC.AccountName=(cards[index].leankor__Account__r.Name==null?'':cards[index].leankor__Account__r.Name);
                            portKC.ContactName=(cards[index].leankor__Contact__r.Name==null?'':cards[index].leankor__Contact__r.Name);
                            portKC.CaseSubject = (cards[index].leankor__Case__c == null ?'':(cards[index].leankor__Case__r.Subject == null ? 'Case : '+cards[index].leankor__Case__r.CaseNumber :cards[index].leankor__Case__r.Subject));                
                            portKC.CaseStatus=(cards[index].leankor__Case__r.Status==null?'':cards[index].leankor__Case__r.Status);  
                            portKC.CasePriority=(cards[index].leankor__Case__r.Priority==null?'':cards[index].leankor__Case__r.Priority); 
                            portKC.CaseTrigger=false;
                            portKC.ZoneTitle='';
                            portKC.LeavedZoneTitle='';
                            portKC.Base64Drawing='';
                            portKC.Base64FileType=''; 
                            portKC.KanbanUrl='';
                            //*****SS 02.07.2018 *****//
                            //portKC.ItemType='KC';
                            portKC.ItemType= (cards[index].RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC');
                            //*****SS 02.07.2018 *****//
                            portKC.Order = (cards[index].leankor__Order__c == null ? tempOrder :cards[index].leankor__Order__c);
                             // Date : 17/06/19
                            portKC.isAtRisk =cards[index].leankor__IsAtRisk__c;
                            //25/Nov/2023 :  passing isShowWeekCalendar field with KC record.
                            portKC.isShowWeekCalendar = VS.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                            //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                            if(cards[index].leankor__Monday__c == false && cards[index].leankor__Tuesday__c == false && cards[index].leankor__Wednesday__c == false &&  cards[index].leankor__Thursday__c == false &&  cards[index].leankor__Friday__c == false &&  cards[index].leankor__Saturday__c == false &&  cards[index].leankor__Sunday__c == false){
                                portKC.Monday = true;
                                portKC.Tuesday = true;
                                portKC.Wednesday = true;
                                portKC.Thursday = true;
                                portKC.Friday = true;
                                portKC.Saturday = true;
                                portKC.Sunday = true;
                            }else{
                                portKC.Monday = cards[index].leankor__Monday__c;
                                portKC.Tuesday = cards[index].leankor__Tuesday__c;
                                portKC.Wednesday = cards[index].leankor__Wednesday__c;
                                portKC.Thursday = cards[index].leankor__Thursday__c;
                                portKC.Friday = cards[index].leankor__Friday__c;
                                portKC.Saturday = cards[index].leankor__Saturday__c;
                                portKC.Sunday = cards[index].leankor__Sunday__c;
                                portKC.weekCalendar = cards[index].leankor__WeekCalendar__c;
                            }
                            
                            //yj 28.03.2018 get all Task Records under each Kanban Card                            
                            if(taskMap.get(cards[index].Id) != null && taskMap.get(cards[index].Id).size() > 0){
                                List<leankor.KanbanToGanttController.MasterContainer> KCTaskList = new List<leankor.KanbanToGanttController.MasterContainer>();
                                    leankor.KanbanToGanttController.MasterContainer Task = new leankor.KanbanToGanttController.MasterContainer();
                                    Task.Name='Tasks for '+portKC.Name;
                                    Task.Id= portKC.Id+'-T';
                                    Task.ValueStream = VSID;
                                    Task.leaf=false;
                                    Task.Title='Tasks for '+portKC.Name;
                                    Task.expanded=true;
                                    Task.ItemType='Ghost';
                                    Task.Color ='#CCCCCC';
                                    Task.Order = (portKC.Order+0.3);
                                    //yj 28.03.2018 get all Task Records under each Kanban Card
                                    for(Task t : taskMap.get(cards[index].Id)){
                                        leankor.KanbanToGanttController.MasterContainer KCTask = new leankor.KanbanToGanttController.MasterContainer();
                                        KCTask.Id = t.Id;
                                        Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
                                        Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate)  ; //- 1
                                        Date tempCRDate = Date.ValueOf(t.CreatedDate) ;
                                        KCTask.StartDate = JSON.Serialize(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
                                        KCTask.DueDate = JSON.Serialize(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
                                        KCTask.EstimatedDuration = 1;
                                        KCTask.DurationUnits = 'd';
                                        KCTask.OwnerID = t.OwnerID;
                                        if(t.OwnerId != null){
                                            resoruceList.add(t.OwnerId);
                                        }
                                        KCTask.OwnerName = t.Owner.Name;
                                        //KCTask.SmallPhotoUrl =  UserRecords.get(t.OwnerID);
                                        KCTask.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
                                        KCTask.Subject = t.Subject;
                                        KCTask.Name = t.Subject;
                                        KCTask.Status =  t.Status;
                                        KCTask.PercentDone = (t.Status == 'Completed' ? 100 : 0);
                                        KCTask.Description = t.Description;
                                        KCTask.CreatedDate =  JSON.Serialize(t.CreatedDate);//JSON.Serialize(Datetime.newInstanceGmt(tempCRDate.year(),tempCRDate.month(), tempCRDate.day(), 10, 01, 01));
                                        KCTask.WhatId = t.WhatId;
                                        KCTask.ItemType='Task';
                                        KCTask.expanded = false;
                                        KCTask.leaf = true;
                                        KCTaskList.add(KCTask);
                                    }
                                    Task.StartDate = portKC.StartDate;
                                    Task.DueDate = portKC.DueDate;
                                    Task.children = KCTaskList;
                                   // KCTaskList.clear();
                                noZoneKanbanCardList.add(Task);
                            }
                            tempOrder++;
                        portfolioKanbanCardList.add(portKC);
                        cards.remove(index);
                    }else{
                        index++;
                    }
                }
                if(flag!=0) {
                    if(minSDCard_c<minSDZone) 
                        minSDZone=minSDCard_c;
                    if(minEDCard_c>minEDZone) 
                        minEDZone=minEDCard_c;
                    noZone.children=noZoneKanbanCardList;
                   // noZoneKanbanCardList.clear();
                    noZone.StartDate= (String)JSON.Deserialize(JSON.Serialize(minSDCard_c),String.class);
                    noZone.DueDate= (String)JSON.Deserialize(JSON.Serialize(minEDCard_c),String.class);
                    ZoneList.add(noZone);   
                }
                if(ZoneList.size()>0){ 
                    ProjectBoard.children=ZoneList;
                }else{ 
                    ProjectBoard.children=portfolioKanbanCardList;
                }
                ProjectBoard.expanded=true;
                ProjectBoard.OwnerID=VS.OwnerID;
                ProjectBoard.CaseType=VS.leankor__CaseType__C;
                ProjectBoard.CaseCardCategory=VS.leankor__CaseCardCategory__C;
                ProjectBoard.CaseSynchronization=VS.leankor__CaseSynchronization__C;
                ProjectBoard.CaseRecordType=VS.leankor__CaseRecordType__C;
                ProjectBoard.BoardType=VS.leankor__BoardType__C;
                ProjectBoard.ValueStreamCardLink=VS.leankor__ValueStreamCardLink__C;
                ProjectBoard.ValueStreamLinkID=VS.leankor__ValueStreamLink__C;
                ProjectBoard.BackgroundHeight=Integer.valueOf(VS.leankor__BackgroundHeight__C);
                ProjectBoard.BackgroundWidth=Integer.valueOf(VS.leankor__BackgroundWidth__C);
                ProjectBoard.JSONSnapshot=VS.leankor__JSONSnapshot__C;
                ProjectBoard.KanbanCardCount=Integer.valueOf(VS.leankor__KanbanCardCount__C);
                ProjectBoard.KanbanCardThroughput=Integer.valueOf(VS.leankor__KanbanCardThroughput__C);
                ProjectBoard.ProjectRoom=VS.leankor__ProjectRoom__C;
                ProjectBoard.ValueStreamTemplate=VS.leankor__ValueStreamTemplate__C;
                ProjectBoard.ScheduleBackwards = VS.leankor__ScheduleBackward__c;
				ProjectBoard.projectBoardLaunchDate =JSON.serialize(VS.leankor__ProjectBoardLaunchDateTime__c);
                ProjectBoard.StartDate =  String.valueOf(json.deserialize(JSON.Serialize(VS.leankor__ProjectBoardStartDateTime__c), String.class));
                ProjectBoard.DueDate =  String.valueOf(json.deserialize(JSON.Serialize(VS.leankor__ProjectBoardEndDateTime__c), String.class));
                ProjectBoard.SevenDayWorkWeek =VS.leankor__SevenDayWorkWeek__c;
                //25/Nov/2023 :  passing isShowWeekCalendar field with KC record.
                ProjectBoard.isShowWeekCalendar = VS.leankor__ProjectRoom__r.leankor__IsShowWeekCalendar__c;
                //Pratiksha -07/03/2022 : changes for add the ItemType in CH.
                ProjectBoard.ItemType = 'Board';
                ProjectBoardList.add(ProjectBoard);
            }
        }else{}
        List<User> UserList = [Select Id,Name,SmallPhotoURL from User Where Id IN :resoruceList];
        Set<leankor.KanbanToGanttController.CardResource> cardResources = new Set<leankor.KanbanToGanttController.CardResource>();
        for(User u : UserList){
            leankor.KanbanToGanttController.CardResource tempResource = new leankor.KanbanToGanttController.CardResource(u.Id,u.Name,u.SmallPhotoURL);
            cardResources.add(tempResource);
        }
        
        leankor.CardHierarchyController.CardHierarchyResourceScheduler schedulerRecord = new leankor.CardHierarchyController.CardHierarchyResourceScheduler(cardResources,ProjectBoardList,AllTaskList);                  
        schedulerRecord.ResourceAssignmentData = leankor.GanttTaskBoard.getResources(AllRelatedCards);
        /*SS 21.08.2018*/
        //Assign set of vsIds and cardsIds(only those with isSuccessorRecalculate=true)
        schedulerRecord.relatedVSIds = relatedVSIds;
        schedulerRecord.successorRecalculateCardIds = successorRecalculateCardIds;    
         //Date 22/07/19 
        Map <String, UserRecordAccess> vsAccessMap = leankor.ProjectBoardCarousel.readRecordSecurity(new List<String>(VSIDs));
        Boolean hasEditAccessFlag = true;
        if(ValueStreams.size() > 0){
            for(leankor__ValueStream__c vs: ValueStreams){
                if(!vsAccessMap.get(vs.Id).HasEditAccess){  
                     hasEditAccessFlag = false;
                     break;
                }
            }  
        } 
        schedulerRecord.hasEditAccess = hasEditAccessFlag;
        //Date 27/11/19 To get ProjectScheduleBlackout records on CH.  
        List<String>  valueStreamList=new List<String>();
        valueStreamList.addAll(schedulerRecord.relatedVSIds);
        leankor.ProjectScheduleBlackout.Blackouts blackout=new leankor.ProjectScheduleBlackout.Blackouts();
        blackout.boardIds=valueStreamList;       
        schedulerRecord.projectScheduleBlackouts=leankor.ProjectScheduleBlackout.readProjectScheduleBlackouts(blackout);
        return schedulerRecord;
    }
    

    // Date : 03/05/2019 - Getting task, helper method of getAllTask
    public static List<leankor.KanbanToGanttController.MasterContainer> getAllTask_Helper(List<Task> tempTaskList) {    
        List<leankor.KanbanToGanttController.MasterContainer> KCTaskList = new List<leankor.KanbanToGanttController.MasterContainer>();  
        for (Task t : tempTaskList) {    
            leankor.KanbanToGanttController.MasterContainer KCTask = new leankor.KanbanToGanttController.MasterContainer();
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
			//29/07/2022 : Changes for showField on CH for Task.
            if(tempTask){
                KCTask.showField = true;
            }

            if (t.OwnerId != null) {
                resoruceList.add(t.OwnerId);
            }

            KCTaskList.add(KCTask);     
        }   

        return KCTaskList;
    }
    
    
    // Date:03/05/2019 - Helper method of getTaskDataByList to get data without sharing.
    public static Map<ID,leankor__Kanbancard__c> getTaskDataByList_Helper(set<string> CardsID, String projectId){

        if(projectId != null){
            return new Map<ID,leankor__Kanbancard__c>([SELECT 
                                                        Id, 
                                                        leankor__MasterContainer__r.leankor__Type__c,
                                                        Name,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.Name,
                                                        leankor__ValueStream__r.leankor__BoardType__C,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__C,
                                                        leankor__ProjectRoom__c, 
                                                        leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, 
                                                        leankor__ValueStream__r.UserRecordAccess.HasReadAccess 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE Id IN: CardsID 
                                                        AND leankor__ValueStream__r.leankor__ProjectRoom__c =: projectId
                                                    LIMIT 49999]);                                              
        }else{       
            return new Map<ID,leankor__Kanbancard__c>([SELECT 
                                                        Id,
                                                        Name,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.Name,
                                                        leankor__ValueStream__r.leankor__BoardType__C,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__C,
                                                        leankor__ProjectRoom__c, 
                                                        leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, 
                                                        leankor__ValueStream__r.UserRecordAccess.HasReadAccess 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE Id IN :CardsID 
                                                    LIMIT 49999]);
        }
    }
    
    
    // Query sObject records irrespective of security rule
    public static List<sObject> querySobjectRecords(String soqlString) {
        return Database.query(soqlString);
    }

    
    public static List < AggregateResult > readExternallyDependentValueStreams_Helper() {
        List < AggregateResult > externallyDependentValuestreams = 
            [SELECT 
                    leankor__Successor__r.leankor__ValueStream__c SuccessorVS, 
                    leankor__Predecessor__r.leankor__ValueStream__c PredecessorVS
                FROM leankor__Dependency__c 
                WHERE leankor__ValueStream__r.leankor__BoardType__c = 'UberBoard' 
                    AND leankor__Successor__r.leankor__IsexternallyDependent__c = true 
                    AND leankor__Predecessor__r.leankor__IsexternallyDependent__c = true
                    AND leankor__Predecessor__r.leankor__IsRecordDeleted__c = false
                    AND leankor__Successor__r.leankor__IsRecordDeleted__c = false
                    AND leankor__Successor__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                    AND leankor__Predecessor__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                    AND leankor__ValueStream__r.leankor__IsTemplateBoard__c = false
                GROUP BY leankor__Predecessor__r.leankor__ValueStream__c, 
                    leankor__Successor__r.leankor__ValueStream__c 
                LIMIT 49999];
                
        return externallyDependentValuestreams;
    }

    
    public static List<leankor__Dependency__c> deleteProjectRoom_Helper(String projectId) {
        return [SELECT 
                    Id, 
                    leankor__Predecessor__c,
                    leankor__Successor__c 
                FROM leankor__Dependency__c 
                WHERE leankor__valuestream__r.leankor__boardtype__c = 'UberBoard' 
                    AND (leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c =: projectId 
                    OR leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c =: projectId) 
                LIMIT 9999];
    }
    
    // Date:26/08/2021 modified This method and Filter out Template type Mastercountainer KanbanCards records 
    public static List<AggregateResult> getPortHierarchy_HelperForCards(List<leankor__Valuestream__c> boardList) {
        List<AggregateResult> aggregateResultList = new List<AggregateResult>();
        for(AggregateResult aggregateResultRecord :[SELECT 
                                                    leankor__Valuestream__r.leankor__ProjectRoom__c,
                                                    leankor__Valuestream__r.leankor__BoardType__c, 
                                                    leankor__MasterContainer__r.leankor__Type__c MasterContanerType,
                                                    MIN(leankor__StartDateTime__c), 
                                                    MAX(leankor__DueDateTime__c)
                                                FROM leankor__KanbanCard__c 
                                                WHERE leankor__Valuestream__c IN: boardList 
                                                    AND leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                                    //AND leankor__MasterContainer__r.leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST
                                                	AND leankor__isRecordDeleted__c = false
                                                    AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                    GROUP BY leankor__Valuestream__r.leankor__ProjectRoom__c, 
                                                            leankor__MasterContainer__r.leankor__Type__c, 
                                                            leankor__Valuestream__r.leankor__BoardType__c 
                                                LIMIT 50000]){
        
            if(aggregateResultRecord.get('MasterContanerType')!='Template'){
                aggregateResultList.add(aggregateResultRecord);
    		}
        }
        return aggregateResultList;
    
    }
    
    // Date:26/08/2021 modified This method and Filter out Template type Mastercountainer KanbanCards records 
    public static List<AggregateResult> getPortHierarchy_HelperForActivity(List<leankor__Valuestream__c> boardList) {
        List<AggregateResult> aggregateResultList = new List<AggregateResult>();
        for(AggregateResult aggregateResultRecord:[SELECT 
                                                        leankor__Valuestream__r.leankor__ProjectRoom__c,
                                                        leankor__Valuestream__r.leankor__BoardType__c, 
                                                        leankor__MasterContainer__r.leankor__Type__c MasterContanerType,
                                                        SUM(leankor__BudgetTimeComplete__c), 
                                                        SUM(leankor__BudgetTimeRemaining__c), 
                                                        SUM(leankor__Budgeted_Time__c)
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__Valuestream__c IN :boardList 
                                                        AND leankor__Valuestream__r.leankor__IsTemplateBoard__c = false 
                                                        //AND leankor__MasterContainer__r.leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST 
									                    AND RecordType.name = 'ActivityCard'
									                    AND leankor__isRecordDeleted__c = false
									                    AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                    GROUP BY leankor__Valuestream__r.leankor__ProjectRoom__c,
                                                            leankor__MasterContainer__r.leankor__Type__c,
                                                            leankor__Valuestream__r.leankor__BoardType__c 
                                                    LIMIT 50000]){
            if(aggregateResultRecord.get('MasterContanerType')!='Template'){
                aggregateResultList.add(aggregateResultRecord);
    		}
        }
        return aggregateResultList;                                          
    }
    

    public static void createKanbanCard_Helper(List<leankor__KanbanCard__c> newKanbanCards, Schema.Sobjectfield ExternField, Boolean flag) {
		
		//Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isCreateable() ||
			!kanbanCardBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
		
        Database.upsert(newKanbanCards, ExternField, flag);
    }
    
    public static leankor__valuestream__c createKanbanCard_Helper_Vs(String vsid) {
        return [SELECT 
                    leankor__ValueStreamLink__c, 
                    leankor__ValueStreamCardLink__c 
                FROM leankor__valuestream__c 
                WHERE Id =: vsid];
    }
    
    
    public static List<leankor__KanbanCard__c> reLinkProject_Helper(String Id) {
        return [SELECT 
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
                FROM leankor__KanbanCard__c
                WHERE leankor__ValueStream__r.leankor__ProjectRoom__c =: id
                    AND leankor__isRecordDeleted__c = false
                    AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false];
    }
    
    
    public static List<leankor__valuestream__c> readBoards(String projectId, List<String> boardType) {
        return [Select 
                    Id,
                    Name,
                    UserRecordAccess.HasEditAccess 
                From leankor__ValueStream__c 
                Where leankor__ProjectRoom__c = :ProjectId 
                    And leankor__BoardType__c In :boardType
                    And leankor__isRecordDeleted__c = false
                Limit 10000];
    }
    

    public static List<leankor__valuestream__c> readBoards(List<leankor__ProjectRoom__c> projectRoom) {
        return [Select  
                     Id,
                     Name,
                     UserRecordAccess.HasEditAccess                                                   
                  From leankor__ValueStream__c 
                  Where leankor__ProjectRoom__c In :projectRoom 
                     And leankor__isRecordDeleted__c = false                 
                  Limit 10000];
    }


    public static List<leankor__Portfolio__c> getAllChildFolders(List<String> parentPortfoliosList) {
        List<String> tempParentPortfolioList = new List<String>();
            
        for (leankor__Portfolio__c folder : [Select Id,
                                                   Name,
                                                   UserRecordAccess.HasEditAccess
                                               From leankor__Portfolio__c
                                               Where leankor__ParentPortfolio__c In :parentPortfoliosList 
                                               Limit 50000]) {  
            globalportfolioList.add(folder);
            tempParentPortfolioList.add(folder.Id);
        }
        
        if (tempParentPortfolioList.size() > 0) {
            getAllChildFolders(tempParentPortfolioList);
        } 

        return globalportfolioList; 
    }   
    

    public static List<FeedItem> readFeedItems(String vsid) {
        return [SELECT 
                    Id,
                    ParentId, 
                    RelatedRecordId 
                FROM FeedItem 
                WHERE ParentId IN (SELECT 
                                        Id 
                                    FROM leankor__KanbanCard__c  
                                    WHERE leankor__ValueStream__c =: vsId 
                                        AND leankor__IsRecordDeleted__c = false
                                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                    ) 
                    AND Type='ContentPost'];
    }

    public static List<FeedItem> readFeedItems(Set<String> recordIds) {
        return [Select Id,
                        ParentId, 
                        RelatedRecordId 
                    From FeedItem 
                    Where ParentId In (Select Id 
                                            From leankor__KanbanCard__c  
                                            Where Id In: recordIds 
                                                And leankor__IsRecordDeleted__c = false
                                                And leankor__ValueStream__r.leankor__isRecordDeleted__c = false) 
                        And Type ='ContentPost'];
    }
    
    
    /** Date: 04/06/2019 - Return the list of value stream. Because in case of standard user again standard board are creating. 
        Because query does't return any record in without sharing class. */
    public static List<leankor__ValueStream__c> getVSForCloneSystemBoard_Helper(String boardType) {
        List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
        
        if (boardType == 'Kanban Board') {
            vsList = [SELECT Id, Name, leankor__ProjectRoom__c, (SELECT Id,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__Type__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Master_Containers__r),(SELECT Id,leankor__CardPerRow__c,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__MasterContainer__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Swimlanes__r) From leankor__ValueStream__c Where Name ='_System_Board' and leankor__ProjectRoom__C =null and leankor__BoardType__c = 'Kanban Board' limit 1];
        } else if (boardType == 'Plan Board') {
            vsList = [SELECT Id, Name, leankor__ProjectRoom__c, (SELECT Id,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__Type__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Master_Containers__r),(SELECT Id,leankor__CardPerRow__c,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__MasterContainer__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Swimlanes__r) From leankor__ValueStream__c Where Name ='_System_PlanBoard' and leankor__ProjectRoom__C =null and leankor__BoardType__c = 'Plan Board' limit 1];
        } else if (boardType == 'DashBoard') {
            vsList = [SELECT Id, Name, leankor__ProjectRoom__c FROM leankor__ValueStream__c WHERE Name = '_System_DashBoard' and leankor__ProjectRoom__C =null and leankor__BoardType__c = 'DashBoard' limit 1];
        }

        return vsList;
    }


    public static leankor__ValueStream__c readsystemBoard() {
        return [SELECT 
                    Id,
                    leankor__DefaultCategory__c,
                    leankor__OpportunityCardCategory__c,
                    leankor__CaseCardCategory__c
                FROM leankor__ValueStream__c 
                WHERE Name = '_system_Board' 
                LIMIT 1];
    }


    public static List<leankor__KanbanCardTemplate__C> readkanbanCardTemplate() {
        return [SELECT 
                    Id,
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
                FROM leankor__KanbanCardTemplate__c 
                WHERE leankor__ValueStream__r.name ='_System_Board' 
                LIMIT 9999];
    }


    public static List<leankor__Marker__c>  readMarkers() {
        return [SELECT 
                    Id,
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
                    Name,
                    OwnerId 
                FROM leankor__Marker__c 
                WHERE leankor__ValueStream__r.Name = '_System_DashBoard' 
                    AND leankor__ValueStream__r.leankor__ProjectRoom__c = null 
                    AND leankor__ValueStream__r.leankor__BoardType__c = 'DashBoard' 
                LIMIT 9999] ;
    }
    
    
    public static void updateOperation_Helper(List<sObject> objList) {
        update objList;
    }

    
    public static List<leankor__ProjectRoom__c> readProjectRecord(List<String> recordIds){
        return [SELECT 
                    Id, 
                    Name, 
                    leankor__IsTemplateProject__c,
                    leankor__ProjectLaunchDateTime__c 
                FROM leankor__ProjectRoom__c 
                WHERE Id IN: recordIds];
    }

    
    /*--------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    getting quick actions  
    Inputs:         string recordUrl
    Returns:        string  
    ------------------------------------------------------------*/
    public static string getQuickActions(string recordUrl) {
        Http http = new Http(); 

        HttpRequest req = new HttpRequest();
        req.setEndpoint(recordUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        
        HttpResponse res = http.send(req);
        
        return res.getbody();
    }
    

    /*--------------------------------------------------------------
    Author:         Suraj Sen 
    Company:        Leankor
    Description:    get Folder record id from ValueStream
    Inputs:         Id recordId
    Returns:        string  (folder id)
    ------------------------------------------------------------*/
    public static String getFolderId(Id recordId) {
        String responseStr = '';
        
        try {
            String sObjectType = recordId.getSObjectType().getDescribe().getName();
            
            switch on sObjecttype {
                when 'leankor__Portfolio__c' {
                    responseStr = recordId;
                }
                when 'leankor__ProjectRoom__c' {
                    for (leankor__ProjectRoom__c projectRecord : [SELECT 
                                                                    leankor__Portfolio__c 
                                                                FROM leankor__ProjectRoom__c 
                                                                WHERE Id =: recordId 
                                                                LIMIT 1]) {
                        if (String.isNotBlank(projectRecord.leankor__Portfolio__c)) {
                            responseStr = projectRecord.leankor__Portfolio__c;
                        }
                    }
                }
                when 'leankor__ValueStream__c' {
                    for (leankor__ValueStream__c valueStreamRecord : [SELECT 
                                                                        leankor__ProjectRoom__c, 
                                                                        leankor__ProjectRoom__r.leankor__Portfolio__c 
                                                                    FROM leankor__ValueStream__c 
                                                                    WHERE Id =: recordId 
                                                                    LIMIT 1]) {
                        if (String.isNotBlank(valueStreamRecord.leankor__ProjectRoom__c) && String.isNotBlank(valueStreamRecord.leankor__ProjectRoom__r.leankor__Portfolio__c)){
                            responseStr = valueStreamRecord.leankor__ProjectRoom__r.leankor__Portfolio__c;
                        }
                    }
                }
            }
            
        } catch (Exception ex){
            throw new GanttTaskBoard.LeanException('Folder/Project does not exist.');
        }
        
        return responseStr; 
    }
    
    public static Map<Id, List<leankor__ProjectScheduleBlackout__c>> getBlackOutRecords(Set<Id> valuestream) {
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackOutMap = new Map<Id, List<leankor__ProjectScheduleBlackout__c>>();

        for (leankor__ProjectScheduleBlackout__c blackOut : [SELECT 
                                                                Id,
                                                                leankor__EndDate__c,
                                                                leankor__StartDate__c,
                                                                leankor__ProjectBoard__c
                                                            FROM leankor__ProjectScheduleBlackout__c
                                                            WHERE leankor__ProjectBoard__c IN: valuestream
                                                            LIMIT 9999]) {

            List<leankor__ProjectScheduleBlackout__c> blackOutList = vsBlackOutMap.containsKey(blackOut.leankor__ProjectBoard__c)
                                                    ? vsBlackOutMap.get(blackOut.leankor__ProjectBoard__c) 
                                                    : new List<leankor__ProjectScheduleBlackout__c>();
            blackOutList.add(blackOut);
            vsBlackOutMap.put(blackOut.leankor__ProjectBoard__c, blackOutList);                                                
        }

        return vsBlackOutMap;   
    }


    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Read Dependent Kanban on the board
                    (This method is specifically created for managing
                    ManageDependency broadcast on LeankorNAV)
    Inputs:         String valueStreamId
    Returns:        List<Kanban>
    ------------------------------------------------------------*/
    public static list<leankor__KanbanCard__c> readDependentNavKanbanCard(String valueStreamId) {
        return [SELECT 
                        Id, 
                        Name,
                        OwnerId,
                        Owner.Name,
                        leankor__BoardType__c, 
                        RecordType.Name, 
                        leankor__StartDateTime__c,
                        leankor__DueDateTime__c, 
                        leankor__ProjectRoom__c,
                        leankor__ValueStream__c,
                        leankor__Valuestream__r.Name,
                        leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, 
                        leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                        leankor__Valuestream__r.leankor__IsTemplateBoard__c,
                        leankor__ValueStream__r.leankor__TaskDateCheck__c,
                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                        leankor__MasterContainer__r.leankor__Type__c,
                        (SELECT 
                                leankor__AssignedTo__c
                            FROM leankor__ResourceAssignments__r 
                            WHERE leankor__AssignedTo__c =: UserInfo.getUserId()
                            LIMIT 2
                        )
                    FROM leankor__KanbanCard__c
                    WHERE Id IN: RealTimeControllerHelper.getDependentItems(valueStreamId) 
                        AND leankor__IsRecordDeleted__c = false
                    LIMIT 49999];
    }
    

    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Read Dependent KanbanItems on the board
                    String valueStreamId
    Returns:        List<Kanban>
    ------------------------------------------------------------*/
    public static Set < String > getDependentItems(String valueStreamId) {
        //To get EDA's data although it does not have any other dependency on same board
        Set<String> kanbanIDs = new Set<String>();
           
        for (leankor__Dependency__C dep: [SELECT 
                                            Id, 
                                            Name, 
                                            leankor__KanbanCard__c, 
                                            leankor__KanbanCard__r.leankor__ValueStream__c, 
                                            leankor__Successor__c, leankor__Successor__r.leankor__ValueStream__c, 
                                            leankor__Predecessor__c, leankor__Predecessor__r.leankor__ValueStream__c, 
                                            leankor__ValueStream__c from leankor__Dependency__C 
                                        WHERE (leankor__ValueStream__c =: valueStreamId 
                                            OR leankor__Successor__r.leankor__ValueStream__c =: valueStreamId)
                                            AND (leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                OR leankor__Successor__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                            )  
                                        LIMIT 49999]) {

            if (dep.leankor__KanbanCard__c != null && dep.leankor__KanbanCard__r.leankor__ValueStream__c == valueStreamId) {
                kanbanIDs.add(dep.leankor__KanbanCard__c);
            }

            if (dep.leankor__Successor__c != null && dep.leankor__Successor__r.leankor__ValueStream__c == valueStreamId) {
                kanbanIDs.add(dep.leankor__Successor__c);
            }

            if (dep.leankor__Predecessor__c != null && dep.leankor__Predecessor__r.leankor__ValueStream__c == valueStreamId) {
                kanbanIDs.add(dep.leankor__Predecessor__c);
            }
        } 

        return kanbanIDs;
    }

    

    public static Boolean insertKanbanCardTemplateRecords(List<leankor__KanbanCardTemplate__c> records) {
		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        if (!kanbanCardTemplateBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        try {
            DataBase.Insert(records, true);
            return true;
        } catch (DmlException exc) {
            throw new Util.LeanException('ERROR:' + exc.getMessage()); 
        }
    }



    public static Boolean updateKanbanCardTemplateRecords(List<leankor__KanbanCardTemplate__c> records) {
		
		//Check CRUD / FLC behavior
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        if (!kanbanCardTemplateBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
		
        try {
            DataBase.Update(records, false);
            return true;
        } catch (DmlException exc) {
            throw new Util.LeanException('ERROR:' + exc.getMessage()); 
        }
    }

    public static void updateProjectBoardDates(Set<String> valueSteamIds){
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__ValueStream__c> valueStreamRecord = new List<leankor__ValueStream__c>();
        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
        Set<Id> valueStreamRecordIds = new Set<Id>();
        for(leankor__ValueStream__c valueStream : [Select Id,Name,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ProjectBoardStartDateTime__c,
                                                                    leankor__valueStream__c.leankor__ProjectRoom__c
                                                                From leankor__ValueStream__c
                                                                Where Id In: valueSteamIds 
                                                                    And leankor__IsRecordDeleted__c = false]){
            if(leankor__valueStream__c.leankor__ProjectRoom__c != null){
                valueStreams.add(valueStream);
                valueStreamRecordIds.add(valueStream.Id);
            }
        }
            
        Map<Id,AggregateResult> aggregateResultMap = new Map<id,AggregateResult>([Select leankor__ValueStream__c Id, 
                                                                                                                    Max(leankor__DueDateTime__c) maximumDueDate, 
                                                                                                                    Min(leankor__StartDateTime__c) minimumStartDate 
                                                                                                                From leankor__kanbanCard__c 
                                                                                                                Where leankor__Valuestream__c In: valueStreamRecordIds 
                                                                                                                    And leankor__IsRecordDeleted__c = false
                                                                                                                Group By leankor__ValueStream__c]);  

       
        for(leankor__ValueStream__c valueStream : valueStreams){
            Boolean flag = false;
            if(aggregateResultMap.containsKey(valueStream.Id)){
                if(valueStream.leankor__ProjectBoardEndDateTime__c == null) {
                    valueStream.leankor__ProjectBoardEndDateTime__c = (Datetime)aggregateResultMap.get(valueStream.Id).get('maximumDueDate');
                    flag = true;
                }
                if(valueStream.leankor__ProjectBoardStartDateTime__c == null){
                    valueStream.leankor__ProjectBoardStartDateTime__c = (Datetime)aggregateResultMap.get(valueStream.Id).get('minimumStartDate');
                    flag = true;
                }
            } else {
                if(valueStream.leankor__ProjectBoardEndDateTime__c == null) {
                    valueStream.leankor__ProjectBoardEndDateTime__c = System.now();
                    flag = true;
                }
                if(valueStream.leankor__ProjectBoardStartDateTime__c == null){
                    valueStream.leankor__ProjectBoardStartDateTime__c = System.now();
                    flag = true;
                }
            } 
            
            if(flag){
                valueStreamRecord.add(valueStream);
            }
        }
        try{
            update valueStreamRecord;
        }catch(Exception e){
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }
    
    //24/feb/2023 : To get the constraint data of Parent card.
    public static Map<String, leankor__ScheduleMode__c> getParentCardConstraintData(List<leankor__KanbanCard__c> remoteKanbans){
        Map<String, leankor__ScheduleMode__c> cardLinkScheduleMode = new Map<String, leankor__ScheduleMode__c>();
        Set<String> cardLinkId = new Set<String>();
        for(integer count = 0; count<remoteKanbans.size();){ 
            if(String.isNotBlank(remoteKanbans[count].leankor__ValuestreamCardLink__c) &&(remoteKanbans[count].leankor__ValueStreamLink__r.leankor__BoardType__c =='UberBoard' || remoteKanbans[count].leankor__ValueStreamLink__r.leankor__BoardType__c == 'Plan Board')){
                cardLinkId.add(remoteKanbans[count].leankor__ValuestreamCardLink__c);
            }
            count++;
        }
        
        for(leankor__ScheduleMode__c cardLinkScheduleModeRecord : [Select Id,
                                                                    leankor__KanbanCard__c,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c
                                                                From leankor__ScheduleMode__c 
                                                                Where leankor__KanbanCard__c In : cardLinkId]){
            cardLinkScheduleMode.put(cardLinkScheduleModeRecord.leankor__KanbanCard__c,cardLinkScheduleModeRecord);
        }
        return cardLinkScheduleMode;
    }
    
    public static Set<Id> getAssigneeIds() {
        Set<Id> assigneeIds = new Set<Id> ();
        for(PermissionSetAssignment assignment : [SELECT Id, 
                                                          PermissionSetId, 
                                                          PermissionSet.Name, 
                                                          PermissionSetGroupId, 
                                                          AssigneeId, 
                                                          ExpirationDate, 
                                                          IsActive 
                                                          FROM PermissionSetAssignment
                                                          Where PermissionSet.NamespacePrefix = 'leankor']) {
            assigneeIds.add(assignment.AssigneeId);
        }
        return assigneeIds;
    }
    
    public static void cloneExpenseResourceAssignments(Set<Id> oldResourceAssignmentIds, List<leankor__ResourceAssignment__c> resourceAssignmentRecords, String valueStreamId) {
        if (!leankor__ExpenseResourceAssignment__c.sObjectType.getDescribe().isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        String projectId = '';
        Map<String, leankor__Expense__c> oldNewExpenseIdMap = new Map<String, leankor__Expense__c>();
        List<leankor__ExpenseResourceAssignment__c> eraRecordsToClone = new List<leankor__ExpenseResourceAssignment__c>();
        Map<String, leankor__ResourceAssignment__c> oldNewResourceAssignmentIdMap = new Map<String, leankor__ResourceAssignment__c>();

        if(String.isNotBlank(valueStreamId)) {
            projectId = [Select Id, 
                                Name, 
                                leankor__ProjectRoom__r.Id 
                            From leankor__ValueStream__c 
                            Where Id =: valueStreamId 
                                And leankor__isRecordDeleted__c = false].leankor__ProjectRoom__r.Id;
        }
        
        for(leankor__Expense__c expense : [Select Id, 
                                                Name, 
                                                leankor__ReferenceSourceId__c ,
                                                leankor__ProjectFinancial__c
                                            From leankor__Expense__c 
                                            Where leankor__Project__c =: projectId]) {
            oldNewExpenseIdMap.put(expense.leankor__ReferenceSourceId__c , expense);
        }

        for(leankor__ResourceAssignment__c resourceAssignment : resourceAssignmentRecords) {
            oldNewResourceAssignmentIdMap.put(resourceAssignment.leankor__ReferenceSourceId__c , resourceAssignment);
        }

        for(leankor__ExpenseResourceAssignment__c era : [Select leankor__Amount__c, 
                                                                leankor__AssignedTo__c, 
                                                                leankor__Expense__c, 
                                                                leankor__ExternalHourlyRate__c, 
                                                                leankor__InternalHourlyRate__c, 
                                                                leankor__Quantity__c, 
                                                                leankor__ResourceAssignment__c,
                                                                leankor__ResourceAssignment__r.leankor__KanbanCard__c, 
                                                                leankor__ResourceType__c, 
                                                                leankor__CompletedDate__c, 
                                                                leankor__PercentAllocation__c, 
                                                                leankor__PercentCompleted__c, 
                                                                leankor__ProjectFinancial__c, 
                                                                leankor__WorkingHoursPerDay__c, 
                                                                leankor__Date__c, 
                                                                leankor__StartDateTime__c, 
                                                                leankor__DueDateTime__c, 
                                                                leankor__ResourceCurrencyRate__c, 
                                                                leankor__ProjectCurrencyRate__c, 
                                                                leankor__ResourceCurrencyCode__c, 
                                                                leankor__ProjectCurrencyCode__c, 
                                                                leankor__NumberOfWorkingDays__c, 
                                                                Name, 
                                                                Id 
                                                            From leankor__ExpenseResourceAssignment__c
                                                            Where leankor__ResourceAssignment__c In: oldResourceAssignmentIds]) {

                if(oldNewResourceAssignmentIdMap.containsKey(era.leankor__ResourceAssignment__c) && oldNewExpenseIdMap.containsKey(era.leankor__Expense__c)) {
                    leankor__ExpenseResourceAssignment__c eraTemp = new leankor__ExpenseResourceAssignment__c();
                    eraTemp.leankor__Amount__c = era.leankor__Amount__c;
                    eraTemp.leankor__AssignedTo__c = era.leankor__AssignedTo__c;
                    eraTemp.leankor__Expense__c = oldNewExpenseIdMap.get(era.leankor__Expense__c).Id;
                    eraTemp.leankor__ExternalHourlyRate__c = era.leankor__ExternalHourlyRate__c;
                    eraTemp.leankor__InternalHourlyRate__c = era.leankor__InternalHourlyRate__c;
                    eraTemp.leankor__Quantity__c = era.leankor__Quantity__c;
                    eraTemp.leankor__ResourceAssignment__c = oldNewResourceAssignmentIdMap.get(era.leankor__ResourceAssignment__c).Id;
                    eraTemp.leankor__ResourceType__c = oldNewResourceAssignmentIdMap.get(era.leankor__ResourceAssignment__c).leankor__ResourceType__c;
                    eraTemp.leankor__CompletedDate__c = era.leankor__CompletedDate__c;
                    eraTemp.leankor__PercentAllocation__c = era.leankor__PercentAllocation__c;
                    eraTemp.leankor__PercentCompleted__c = era.leankor__PercentCompleted__c;
                    eraTemp.leankor__ProjectFinancial__c = oldNewExpenseIdMap.get(era.leankor__Expense__c).leankor__ProjectFinancial__c;
                    eraTemp.leankor__WorkingHoursPerDay__c = era.leankor__WorkingHoursPerDay__c;
                    eraTemp.leankor__Date__c = era.leankor__Date__c;
                    eraTemp.leankor__StartDateTime__c = era.leankor__StartDateTime__c;
                    eraTemp.leankor__DueDateTime__c = era.leankor__DueDateTime__c;
                    eraTemp.leankor__ResourceCurrencyRate__c = era.leankor__ResourceCurrencyRate__c;
                    eraTemp.leankor__ProjectCurrencyRate__c = era.leankor__ProjectCurrencyRate__c;
                    eraTemp.leankor__ResourceCurrencyCode__c = era.leankor__ResourceCurrencyCode__c;
                    eraTemp.leankor__ProjectCurrencyCode__c = era.leankor__ProjectCurrencyCode__c;
                    eraTemp.leankor__NumberOfWorkingDays__c = era.leankor__NumberOfWorkingDays__c;

                    eraRecordsToClone.add(eraTemp);
                }
            }

        insert eraRecordsToClone;
    }
}