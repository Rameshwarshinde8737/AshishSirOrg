/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class GanttViewController {

    public static final Set<String> SCHEDULEMODES_CONST = new Set<String>{'FixedDuration', 'EffortDriven', 'DynamicAssignment'};
    public leankor__KanbanCardTemplate__c kanbanCardTemplate { get; private set; }
  
    public GanttViewController() {

  }
   
    public GanttViewController(ApexPages.StandardController stdController) {
    
    }
    public GanttViewController(Util controller) {}

    

    public PageReference Calendar_View() {    
        PageReference calendarView = new Pagereference('/apex/Test_Page');
    calendarView.setRedirect(false); 
        return calendarView;
    }

    global class PlanGanttRequest {
        public Boolean readRelatedCount = false;
        public Boolean readStickers = false;
        public String valueStreamId;
        public List<String> fieldsToQuery;
    }


    global class PlanGanttResult {   
        public list<leankor.GanttTaskBoard.ResourceAssignment> resourceAssignments;
        public Map<String, GanttTaskBoard.RecordCount> relatedCount;
        public RealTimeController.GlueforceData glueforceData;
        public Map<Id, List<leankor__Sticker__c>> stickerData;
        public Map<Id, leankor__KanbanCard__c> kanbanCardData;
    }

    @remoteAction
    global static PlanGanttResult readColumnsData(PlanGanttRequest planGanttRequest) {
        if (String.isNotBlank(planGanttRequest.valueStreamId) && Util.getSObjectName(planGanttRequest.valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        PlanGanttResult planGanttResult = new PlanGanttResult();
        Id valueStreamId = planGanttRequest.valueStreamId;

        if (planGanttRequest.readRelatedCount) {
            planGanttResult.relatedCount = GanttTaskBoard.readRelatedRecordCount(new List<String>{valueStreamId});
        }

        if (planGanttRequest.readStickers) {
            planGanttResult.stickerData = readKanbanCardStickers(new List<String>{valueStreamId}, new List<String>());
        }

        if (planGanttRequest.fieldsToQuery.size() > 0) {
            String baseQuery = 'Select ';

            // Loop through the fields and add them to the query
            for (Integer i = 0; i < planGanttRequest.fieldsToQuery.size(); i++) {
                baseQuery += planGanttRequest.fieldsToQuery[i];
                if (i < planGanttRequest.fieldsToQuery.size() - 1) {
                    baseQuery += ', ';
                }
            }

            // Add the object and any additional conditions to the query
            baseQuery += ' From leankor__KanbanCard__c Where leankor__ValueStream__c = :valueStreamId';
            List<leankor__KanbanCard__c> kanbanCards = Database.query(baseQuery);
            Map<Id, leankor__KanbanCard__c> kanbanCardMap = new Map<Id, leankor__KanbanCard__c>();
            kanbanCardMap.putAll(kanbanCards);
            planGanttResult.kanbanCardData = kanbanCardMap;
        }

        return planGanttResult;
    }

    global class PlanGanttRequestInfo {
        public String valueStreamId;
        public String userId;
        public String boardType;
        public String valueStreamIds;
        public realTimeController.Preference preference;
        public String folderId;
    }


    global class PlanGanttInfo {
        public String baseURL;
        public List<KanbanController.CreateFilter> filters;
        public List<User> filterUserRecords;
        public Boolean isServiceAppointmentEnable;
        public Boolean isFieldExist;
        public User userLog;
        public String orgBaseURL;
        public List<PermissionSetAssignment> userPermissionSets;
        public leankor__Preference__c preference;
        public GanttTaskBoard.GetPortfolioresource getPortfolioresource;
    }


    @remoteAction
    global static PlanGanttInfo readPlanGanttInfo(PlanGanttRequestInfo planGanttRequestInfo) {
        if (String.isNotBlank(planGanttRequestInfo.valueStreamId) && Util.getSObjectName(planGanttRequestInfo.valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        PlanGanttInfo planGanttInfo = new PlanGanttInfo();

        planGanttInfo.baseURL = RealTimeController.getBaseURL();
        planGanttInfo.userLog = getUserLog();
        planGanttInfo.filters = KanbanController.getFilterRecords(planGanttRequestInfo.valueStreamId);
        planGanttInfo.filterUserRecords = getFilteredUsers(planGanttRequestInfo.valueStreamId);
        planGanttInfo.isServiceAppointmentEnable = KanbanController.checkFSLManageApp();
        planGanttInfo.isFieldExist = KanbanController.checkFieldExistInSobject();
        planGanttInfo.orgBaseURL = RealTimeController.getOrgBaseURL();

        return planGanttInfo;
    }

    
    public static User getuserlog() {
        UserBehaviour userBehaviour = new UserBehaviour();
        if(!userBehaviour.isAccessible()){
            throw new Util.LeanException('Error: No access to records');
        }
        User user = [Select Id,
                            LocaleSidKey,
                            Name,
                            SmallPhotoUrl
                        From User 
                        Where Id = :UserInfo.getUserId()];

        return user;
    }

  
	public static List <User> getFilteredUsers(String valueStreamId){
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!taskBehaviour.isAccessible() ||
            !userBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        //Check CRUD / FLC behavior 
        
        Set<String> allRelatedUserID = new Set <String>();
        List<User> users = new List <User>();
		try {	
            List <leankor__KanbanCard__c> kanbans = [Select 
                                                        Id, 
                                                        OwnerID 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c = :valueStreamId 
                                                        And leankor__isRecordDeleted__c = false
                                                    With Security_Enforced
                                                    Limit 50000];
            if (kanbans.size() > 0) {
                for (leankor__KanbanCard__c kanban: kanbans) {
                    allRelatedUserID.add(kanban.OwnerId);
                }
            }
            
            List<leankor__ResourceAssignment__c> resourceAssignmentList = [Select Id, 
                                                                                    leankor__AssignedTo__c,
                                                                                    leankor__AssignedTo__r.name                                                        
                                                                                From leankor__ResourceAssignment__c 
                                                                                Where leankor__KanbanCard__c In :kanbans 
                                                                                    And leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c = 'UberBoard'
                                                                                With Security_Enforced
                                                                                Limit 50000 ];                 
            if(resourceAssignmentList.size() > 0) {
            	for(leankor__ResourceAssignment__c  resource:resourceAssignmentList){
            		 allRelatedUserID.add(resource.leankor__AssignedTo__c);
            	}
            }

            for(Task task : [Select Id, 
            					OwnerId
            				From Task 
                            Where What.Type = 'leankor__KanbanCard__c' 
                                And WhatId IN:kanbans 
                                And IsDeleted = false 
            				Limit 50000 All Rows]){
                allRelatedUserID.add(task.OwnerId);
            }            
            
            users = [Select Id, 
            				Name,
            				SmallPhotoUrl
            			From User 
                 		Where Id In :allRelatedUserID 
            			Limit 50000];
        } catch (QueryException ex) {
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return users;
    } 

    @TestVisible
    private static Map<Id, List<leankor__Sticker__c>> readKanbanCardStickers(List<Id> valueStreamIds, List<Id> kanbanCardIds) {
        StickerBehavior stickerBehavior = new StickerBehavior();
        if (!stickerBehavior.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        Map<Id, List<Id>> kanbanStickerMap = new Map<Id, List<Id>>();
        Set<Id> stickerIds = new Set<Id>(); // Using a Set to avoid duplicate sticker IDs
    
    // Fetching KanbanCardSticker records based on the provided ValueStream and KanbanCard IDs
       for (leankor__KanbanCardSticker__c kanbanCardSticker : [Select Id,
                                                                        leankor__KanbanCard__c,
                                                                        leankor__Sticker__c
                                                                    From leankor__KanbanCardSticker__c
                                                                    Where leankor__KanbanCard__r.leankor__ValueStream__c In :valueStreamIds
                                                                        Or leankor__KanbanCard__c In :kanbanCardIds
                                                                    With Security_Enforced]) {

            if (!kanbanStickerMap.containsKey(kanbanCardSticker.leankor__KanbanCard__c)) {
                kanbanStickerMap.put(kanbanCardSticker.leankor__KanbanCard__c, new List<Id>());   
            }
            kanbanStickerMap.get(kanbanCardSticker.leankor__KanbanCard__c).add(kanbanCardSticker.leankor__Sticker__c);
            stickerIds.add(kanbanCardSticker.leankor__Sticker__c);
        }
  
        // Fetching Sticker records based on the collected sticker IDs
        Map<Id, leankor__Sticker__c> mapSticker = new Map<Id, leankor__Sticker__c>();
        for (leankor__Sticker__c stickter : [Select Id, 
                                                    Name, 
                                                    (Select Id 
                                                        From Attachments) 
                                                From leankor__Sticker__c 
                                                Where Id In :stickerIds
                                                Order By Name 
                                                Limit 10000]) {         
            mapSticker.put(stickter.Id, stickter);
        }
        
        // Preparing the final map of Kanban cards to their associated stickers
        Map<Id, List<leankor__Sticker__c>> mapStickerPerCard = new Map<Id, List<leankor__Sticker__c>>();
        for (Id kanbanCardId : kanbanStickerMap.keySet()) {
            list<String> localStickerIds = kanbanStickerMap.get(kanbanCardId);
            List<leankor__Sticker__c> tempStickers = new List<leankor__Sticker__c>();
            if (localStickerIds.size() > 0) {
                for (String localStickerId : localStickerIds) {
                    leankor__Sticker__c sticker = mapSticker.get(localStickerId);
                    if (sticker != null) {
                        tempStickers.add(sticker);
                    }
                }
            }
            tempStickers.sort();
    
            List<leankor__Sticker__c> sortedList = new List<leankor__Sticker__c>();
    
            for (Integer count = tempStickers.size() - 1; count >= 0; count--) {
                if (tempStickers.get(count) != null && tempStickers.get(count).Attachments.size() > 0) {
                    sortedList.add(tempStickers.get(count));
                }
            }
    
            if (sortedList.size() > 0) {
                mapStickerPerCard.put(kanbanCardId, sortedList);
            }
        }
    
        return mapStickerPerCard;
    }
    
    public static leankor__KanbanCardTemplate__c getKanbanCardTemplates(Id valueStreamId) {

        List<leankor__KanbanCardTemplate__c> returnKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();

        List<leankor__ValueStream__c> valueStreams = [Select leankor__ProjectRoom__c
                                                        From leankor__ValueStream__c 
                                                        Where Id = :valueStreamId
                                                        With Security_Enforced
                                                        Limit 1];

        if (valueStreams.size() > 0) {
            returnKanbanCardTemplates = [Select Id, 
                                                leankor__ValueStream__c,
                                                Name, 
                                                leankor__AssetID__c, 
                                                leankor__CSSLayout__c, 
                                                leankor__Color__c, 
                                                leankor__Height__c, 
                                                leankor__Title__c, 
                                                leankor__width__c, 
                                                leankor__DerivedFrom__c, 
                                                leankor__DerivedFrom__r.leankor__ProjectRoom__c, 
                                                leankor__FieldSetName__c,
                                                leankor__WeekCalendar__c
                                            From leankor__KanbanCardTemplate__c 
                                            Where leankor__ValueStream__c = :valueStreamId
                                            With Security_Enforced
                                            Order By Name];  
        }
        if(returnKanbanCardTemplates.size() > 0) {
            returnKanbanCardTemplates.sort();
            return returnKanbanCardTemplates[0];
        }

        return null;
    }

    global class StickerData {
        @TestVisible
         List<leankor__Sticker__c> allStickers;
        @TestVisible
         Map<Id, List<leankor__Sticker__c>> kanbanCardStickers;
    }


    @remoteAction
    global static StickerData readStickerData(String valueStreamId, List<String> kanbanCardIds) {
         StickerData stickerData = new StickerData();

        if (valueStreamId != null) {
            stickerData.allStickers = getAllStickers(valueStreamId);
        } 

        if (!kanbanCardIds.isEmpty()) {
            stickerData.kanbanCardStickers = readKanbanCardStickers(new List<String>(), kanbanCardIds);
        }

        return stickerData;
    }


    /*
     * Remote web service for returning all the Kanban Card Stickers that are system-wide and all specifically linked to the Value Stream
     * INPUT: Value Stream ID
     * OUTPUT: Array of leankor__Sticker__c with sub-array Attachments
    */
    
    @TestVisible
    private static List<leankor__Sticker__c> getAllStickers(Id valueStreamId) {
        StickerBehavior stickerBehavior = new StickerBehavior();
        if (!stickerBehavior.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor__Sticker__c> myStickers = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> stickerIds = new List<leankor__Sticker__c>();
        Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>(); 
         
        try {
            List<leankor__Sticker__c> allStickerIds = [Select Id,
                                                                leankor__ValueStream__c
                                                            From leankor__Sticker__c
                                                            Where LastModifiedDate >= :RealTimeCOntroller.LASTMODIFIEDDATETIME_CONST
                                                            With Security_Enforced
                                                            Limit 50000];
                                                    
            for (leankor__Sticker__c allStickerId : allStickerIds) {
                if (allStickerId.leankor__ValueStream__c == null || allStickerId.leankor__ValueStream__c == valueStreamId) {
                    stickerIds.add(allStickerId);
                }
            }

            if (stickerIds.size() > 0) {
                for (List<leankor__Sticker__c> sticker : [Select Id, 
                                                                Name, 
                                                                (Select Id
                                                                    From Attachments 
                                                                    Where ParentId In :stickerIds) 
                                                            From leankor__Sticker__c 
                                                            Where Id In :stickerIds
                                                            Order By Name
                                                            Limit 50000]) {

					sticker.sort();
                    for (Integer count = 0; count < sticker.size(); count++) {
                        if(sticker[count].Attachments.size() > 0) {
                            myStickers.add(sticker[count]);
                        }  
                    } 
                }
            }
        } catch (Exception e) {
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return myStickers;
  }

	global class RealTimeTrackerInfomation {
        @TestVisible
    	Id valueStreamId;
        @TestVisible
    	String verb;
        @TestVisible
    	String clientSessionId;
    	//String jsonData;
	}

    /*------------------------------------------------------------------------------------------------------------------------
        Author:         Abhishek Joshi
        Company:        Leankor
        Description:    Adding realTimeTracker Records
        Inputs:         List of RealTimeTrackerInfomation 
        Returns:        return nothing
    ---------------------------------------------------------------------------------------------*/
    @RemoteAction
    global static void createRealtimeTrackerForHistory(List<RealTimeTrackerInfomation> realtimeTrackerRecords) {
        List<leankor__RealtimeTracker__c> realtimeTrackerList = new List<leankor__RealtimeTracker__c>();
        try {
            for(RealTimeTrackerInfomation singlerealtimeTrackerRecords : realtimeTrackerRecords) {
                leankor__RealtimeTracker__c singleRealtimeTracker = new leankor__RealtimeTracker__c();
                singleRealtimeTracker.leankor__KanbanVerb__c = String.isBlank(singlerealtimeTrackerRecords.verb) ? null : singlerealtimeTrackerRecords.verb;
                singleRealtimeTracker.leankor__SessionID__c = String.isBlank(singlerealtimeTrackerRecords.clientSessionId) ? null : singlerealtimeTrackerRecords.clientSessionId;
                singleRealtimeTracker.leankor__ValueStream__c = String.isBlank(singlerealtimeTrackerRecords.valueStreamId) ? null : singlerealtimeTrackerRecords.valueStreamId;
                realtimeTrackerList.add(singleRealtimeTracker);
            }
                OpenTaskRestriction.insertRealTimeTrackers(realtimeTrackerList);
        } catch (Exception e) {	
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }
}