/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class LeankorOperationController {

    global LeankorOperationController(ApexPages.StandardController controller) {}
    
    global class KanbanCardResponse {
        public List<KanbanCard__c> kanbanCards;
        public List<ScheduleMode__c> scheduleModes;
        public List<GanttTaskBoard.ResourceAssignment> resourceAssignments;
        public Map<Id, leankor__KanbanCard__c> customFields;
        public List<leankor__Sticker__c> stickers;
    }

    private class KanbanCardPayload {
        public List<ScheduleMode__c> scheduleModes;
        public List<GanttTaskBoard.ResourceAssignment> resourceAssignments;
        public Map<Id, leankor__KanbanCard__c> customFields;
        public Set<KanbanCard.KanbanCardPayload> kanbanCards;
        public Set<Id> valueStreamIds;
        public List<Id> workItemIds;
        public List<leankor__Sticker__c> stickers;
    }

    
    @RemoteAction
    global static KanbanCardResponse createKanbanCards(MultipleCreateKanbanCardAction.KanbanCardRequest request) {
        
        KanbanCardResponse response = new KanbanCardResponse();
        List<leankor__KanbanCard__c> kanbanCardListResult = new  List<leankor__KanbanCard__c>();
        // Collect related records in a single query to avoid SOQL in loops
        List<Id> kanbanCardIds = new List<Id>();
        Integer projectBoardWorkFieldSetList;
        Set<KanbanCard.KanbanCardPayload> kanbanCards = new Set<KanbanCard.KanbanCardPayload>();
        KanbanCardPayload kanbanCardPayload = new KanbanCardPayload();
        Set<Id> valueStreamIds = new Set<Id>();
        List<LeankorOperationController.UpdateStack> manageWorkItemHistory = new List<LeankorOperationController.UpdateStack>();
        RealTimeController.isCalledAPI = false; // This prevents the asynchronous execution of enterTheZoneBulkify() and updateActivityPercentageComplete() methods from createKanbanCardsQueueable, ensuring they execute synchronously.
        Savepoint savePoint = Database.setSavepoint();
        try {
            // Call the Queueable method
            List<leankor__KanbanCard__c> kanbanCardList = CreateKanbanCardsQueueable.createKanbanCard(request);
            
            for (KanbanCard__c kanbanCard : kanbanCardList) {
                kanbanCardIds.add(kanbanCard.Id);
                valueStreamIds.add(kanbanCard.leankor__ValueStream__c);
            }

            for(leankor__KanbanCard__c kanbanCard : KanbanCard.readKanbanCards(new Set<Id>(kanbanCardIds))) {
                KanbanCard.KanbanCardPayload kanbanCardPayloadData = new KanbanCard.KanbanCardPayload();
                kanbanCardPayloadData.Id = kanbanCard.Id;
                kanbanCardPayloadData.Name = kanbanCard.Name;
                kanbanCardPayloadData.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
                kanbanCardPayloadData.GUID = kanbanCard.leankor__GUID__c;
                kanbanCardPayloadData.Order = kanbanCard.leankor__Order__c;
                kanbanCardPayloadData.StartDate = kanbanCard.leankor__StartDateTime__c;
                kanbanCardPayloadData.DueDate = kanbanCard.leankor__DueDateTime__c;
                kanbanCardPayloadData.PercentDone =  kanbanCard.leankor__PercentComplete2__c;
                kanbanCardPayloadData.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
                kanbanCardPayloadData.DurationUnits = kanbanCard.leankor__DurationUnits__c;
                kanbanCardPayloadData.CardID = kanbanCard.leankor__CardId__c;
                kanbanCardPayloadData.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
                kanbanCardPayloadData.Priority = Integer.valueOf(kanbanCard.leankor__Priority__c);
                kanbanCardPayloadData.Description = kanbanCard.leankor__DescriptionLong__c;
                kanbanCardPayloadData.ValueStreamCardLink = kanbanCard.leankor__ValueStreamCardLink__c;
                kanbanCardPayloadData.ValueStreamLinkID = kanbanCard.leankor__ValueStreamLink__c;
                kanbanCardPayloadData.OwnerID = kanbanCard.OwnerId;
                kanbanCardPayloadData.ItemType = kanbanCard.RecordType.Name;
                kanbanCardPayloadData.Color = kanbanCard.leankor__kanbanCardTemplate__r.Color__c;
                kanbanCardPayloadData.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c;
                kanbanCardPayloadData.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;
                kanbanCardPayloadData.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
                kanbanCardPayloadData.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c;
                kanbanCardPayloadData.isConstraintRecalculate = kanbanCard.leankor__IsConstraintRecalculate__c;
                kanbanCardPayloadData.valueStreamId = kanbanCard.leankor__ValueStream__c;
                kanbanCardPayloadData.Monday = kanbanCard.leankor__Monday__c;
                kanbanCardPayloadData.Tuesday = kanbanCard.leankor__Tuesday__c;
                kanbanCardPayloadData.Wednesday = kanbanCard.leankor__Wednesday__c;
                kanbanCardPayloadData.Thursday = kanbanCard.leankor__Thursday__c;
                kanbanCardPayloadData.Friday = kanbanCard.leankor__Friday__c;
                kanbanCardPayloadData.Saturday = kanbanCard.leankor__Saturday__c;
                kanbanCardPayloadData.Sunday = kanbanCard.leankor__Sunday__c;
                kanbanCardPayloadData.weekCalendar = kanbanCard.leankor__WeekCalendar__c;

                kanbanCards.add(kanbanCardPayloadData);

                leankor__KanbanCard__c tempKanbanCard = new leankor__KanbanCard__c(Id = kanbanCard.Id, leankor__GUID__c = kanbanCard.leankor__GUID__c);
                kanbanCardListResult.add(tempKanbanCard);

                LeankorOperationController.UpdateStack updateStack = new LeankorOperationController.UpdateStack();
                updateStack.Id = kanbanCard.Id;
                updateStack.ItemType = kanbanCard.RecordType.Name;
                updateStack.Name = kanbanCard.Name;
                updateStack.valueStreamId = kanbanCard.leankor__ValueStream__c;
                manageWorkItemHistory.add(updateStack);
            }

            if (!kanbanCardIds.isEmpty()) {

                projectBoardWorkFieldSetList = [Select count()
                                                        From leankor__ProjectBoardWorkFieldSet__c
                                                        Where leankor__ProjectBoard__c In :valueStreamIds
                                                        With Security_Enforced
                                                        Limit 1];
                                                        
                response.scheduleModes = GanttTaskBoard.getScheduleMode(kanbanCardIds);
                response.resourceAssignments = GanttTaskBoard.getResourceAssignmentBulkify(kanbanCardIds);
                                                      
                if(projectBoardWorkFieldSetList > 0) {
                    response.customFields = LeankorFieldSetController.readCardsFieldSetData(kanbanCardIds);
                }
            }
            
            response.kanbanCards = kanbanCardListResult;

            kanbanCardPayload.kanbanCards = kanbanCards;
            kanbanCardPayload.scheduleModes = response.scheduleModes;
            kanbanCardPayload.resourceAssignments = response.resourceAssignments;
            kanbanCardPayload.customFields = response.customFields;
            kanbanCardPayload.valueStreamIds = valueStreamIds;

            String jsonStr = JSON.serialize(kanbanCardPayload);
            sendBroadcast(request.verb, jsonStr, request.sessionId);
            createRealtimeTracker(request.verb, manageWorkItemHistory); 
            kanbanCardList.clear();

        } catch (Exception e) {
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        return response;
    }


    public static void sendBroadcast(String verb, String jsonPayLoad, String sessionId) {

        //Instance to hold List of broadcast events
		List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
        try {
            broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(verb, jsonPayLoad, sessionId));
            if (broadcastEvents.size() > 0) {
                LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @RemoteAction
    global static List<leankor__KanbanCard__c> updateWorkItems(WorkSchedule request) {
        Savepoint savePoint = Database.setSavepoint();
        try {
            if (!request.workItems.isEmpty()) {
                KanbanCard.updateKanbanCards(request.workItems);
                String jsonStr;

                if (!String.isBlank(request.payloadString)) {
                    jsonStr = request.payloadString;                    
                } else {
                    jsonStr = JSON.serialize(request.workItems);    
                }
                sendBroadcast(request.verb, jsonStr, request.sessionId);
            	createRealtimeTracker(request.verb, request.manageWorkItemHistory); 
            }
        } catch(Exception e) {
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return request.workItems;
    }

    private static void createRealtimeTracker(String verb, List<UpdateStack> manageWorkItemHistory) {
        List<leankor__RealtimeTracker__c> realtimeTrackerList = new List<leankor__RealtimeTracker__c>(); 
        String jsonString;
        for(Integer count = 0; count < manageWorkItemHistory.size(); count++){
            leankor.realTimeController.JSONGroup myJSONGroup = new leankor.realTimeController.JSONGroup();
            leankor__RealtimeTracker__c realtimeTracker = new leankor__RealtimeTracker__c();
            realtimeTracker.leankor__ValueStream__c = String.isBlank(manageWorkItemHistory[count].valueStreamId) ? null : manageWorkItemHistory[count].valueStreamId;
            realtimeTracker.leankor__KanbanVerb__c = verb;
            jsonString = Json.serialize(manageWorkItemHistory[count]);
            if (!leankor.realTimeController.putJSONGroup(jsonString, myJSONGroup)){
                    leankor__RealtimeTracker__c realTimeRecord = leankor.GenericStreamingController.createRTForSelectedData(jsonString, realtimeTracker);
                    if(realTimeRecord != null){
                        realtimeTrackerList.add(realTimeRecord);            
                    }
            }else {
                realtimeTrackerList.add(GenericStreamingController.assignJsonData(realtimeTracker,myJSONGroup));
            }
	    }
        List<Database.SaveResult> realTimeTrackerSaveResult = OpenTaskRestriction.insertRealTimeTrackers(realtimeTrackerList); 
    }

    @RemoteAction
    global static KanbanCardResponse updateWorkItemsPercentCompletion(WorkSchedule request) {
        KanbanCardResponse response = new KanbanCardResponse();
        Set<Id> valueStreamIds = new Set<Id>();
        List<Id> kanbanCardIds = new List<Id>();
        Set<KanbanCard.KanbanCardPayload> kanbanCards = new Set<KanbanCard.KanbanCardPayload>();
        KanbanCardPayload kanbanCardPayload = new KanbanCardPayload();
        Savepoint savePoint = Database.setSavepoint();
        try {
        
            for (KanbanCard__c kanbanCard : request.workItems) {
                kanbanCardIds.add(kanbanCard.Id);
                valueStreamIds.add(kanbanCard.leankor__ValueStream__c);

                KanbanCard.KanbanCardPayload kanbanCardPayloadData = new KanbanCard.KanbanCardPayload();
                kanbanCardPayloadData.Id = kanbanCard.Id;
                kanbanCardPayloadData.StartDate = kanbanCard.leankor__StartDateTime__c == null ? null :kanbanCard.leankor__StartDateTime__c;
                kanbanCardPayloadData.DueDate = kanbanCard.leankor__DueDateTime__c == null ? null :kanbanCard.leankor__DueDateTime__c;
                kanbanCardPayloadData.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
                kanbanCardPayloadData.DurationUnits = kanbanCard.leankor__DurationUnits__c;
                kanbanCardPayloadData.PercentDone =  kanbanCard.leankor__PercentComplete2__c;
            
                kanbanCards.add(kanbanCardPayloadData);
            }
            
            List<FeedItem> feeds = prepareFeedRecords(request.workItems, kanbanCardIds);
            if (!request.workItems.isEmpty()) {
                request.affectedWorkItems.addAll(request.workItems);
                KanbanCard.updateKanbanCards(request.affectedWorkItems);

	            if (!feeds.isEmpty()) {
	                OpenFeedItemRestriction.createFeedItems(feeds);
	            }
	            ProjectBoardCarousel.updateActivityPercentageComplete(kanbanCardIds);
	            createRealtimeTracker(request.verb, request.manageWorkItemHistory); 

	            response.kanbanCards = request.workItems;
	            response.resourceAssignments = GanttTaskBoard.getResourceAssignmentBulkify(kanbanCardIds);

                kanbanCardPayload.kanbanCards = kanbanCards;
                kanbanCardPayload.valueStreamIds = valueStreamIds;
                kanbanCardPayload.resourceAssignments = response.resourceAssignments;
                kanbanCardPayload.workItemIds = request.workItemIds;
                String jsonStr = JSON.serialize(kanbanCardPayload);
	            sendBroadcast(request.verb, jsonStr, request.sessionId);
            }

            return response;
        }catch(Exception e){
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }

    private static List<FeedItem> prepareFeedRecords(List<leankor__KanbanCard__c> workItems, List<Id> kanbanCardIds) {
        List<FeedItem> feeds = new List<FeedItem>();
        String leankorBaseURL = Util.getDomainUrl();
        List<leankor__Subscriber__c > listOfSubscribers = new List<leankor__Subscriber__c>();
        Map<Id, leankor__KanbanCard__c> existingKanbanCards = new Map<Id, leankor__KanbanCard__c>();

        if (!kanbanCardIds.isEmpty()) {
            existingKanbanCards = KanbanCard.getExistingKanbanCards(new Set<Id>(kanbanCardIds));
            Subscriber subscriber = new Subscriber();
            listOfSubscribers = subscriber.getSubscribers(kanbanCardIds);
        }

        List<String> userIds = new List<String>();
        if (!listOfSubscribers.isEmpty()) {
            for (leankor__Subscriber__c subscriber : listOfSubscribers) {
                userIds.add(subscriber.leankor__SubscriberID__c);
            } 
            Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
            Map<Id, Id> networkMemberMap = new Map<Id, Id>();
            String networkId = Network.getNetworkId();      
            Boolean isNetworkAvailable = (Type.forName('Schema.NetworkMember') != null);
            if (isNetworkAvailable) {
                OpenFeedItemRestriction.readNetworkMember(userIds, networkMemberMap);
            }   
            
            for (leankor__KanbanCard__c kanbanCard : workItems) {
                leankor__KanbanCard__c existingKanbanCard = existingKanbanCards.get(kanbanCard.Id);
                if (existingKanbanCard != null) {    
                    if ((existingKanbanCard.leankor__PercentComplete2__c != kanbanCard.leankor__PercentComplete2__c) && kanbanCard.leankor__PercentComplete2__c == 100) {
                        kanbanCard.leankor__HarveyBallDoneDate__c = System.today();
                        kanbanCard.leankor__PromiseCompletionDate__c = System.now();
                        String linkUrlTemp = OpenFeedItemRestriction.createKanbanCardURL(existingKanbanCard, leankorBaseURL);
                        for (leankor__Subscriber__c subscriber : listOfSubscribers) {
                            if (((subscriber.leankor__SubscriberId__c != realtimeController.USER_ID_CONST) || (subscriber.leankor__SubscriberId__c == realtimeController.USER_ID_CONST && listOfSubscribers.size() == 1)) && kanbanCard.Id == subscriber.leankor__KanbanCard__c) {
                                if (assigneeIds.contains(subscriber.leankor__SubscriberId__c)) {
                                    if (subscriber.leankor__PercentDone__c == true) {
                                        FeedItem post = new FeedItem();
                                        post.ParentID = subscriber.leankor__SubscriberId__c;
                                        
                                        if (isNetworkAvailable && subscriber.leankor__SubscriberID__r.UserType != 'Standard') {                            
                                            post.put('NetworkScope', networkMemberMap.get(subscriber.leankor__SubscriberId__c));
                                        }
                                        
                                        if (String.isNotBlank(networkId)) {
                                            post.put('Visibility','AllUsers');
                                        }
                                        post.Title = existingKanbanCard.Name;
                                        post.LinkUrl = linkUrlTemp + kanbanCard.Id;
                                    
                                        List<String> customlabelsParam = new List<String>();
                                        customlabelsParam.add(''+existingKanbanCard.recordType.Name);
                                        customlabelsParam.add('-'+existingKanbanCard.Name);
                                        customlabelsParam.add(''+kanbanCard.leankor__PercentComplete2__c);
                                        String LabelsWithParameter = String.format(System.Label.leankor.CardStatusDone, customlabelsParam);
                                        post.Body = LabelsWithParameter;
                                        post.Body += '\n\n' + existingKanbanCard.leankor__ProjectRoom__c + ' / ' + existingKanbanCard.leankor__ValueStream__r.Name;
                                        
                                        feeds.add(post);
                                    } 
                                }
                            } 
                        }
                    }
                }
            }
        }
        return feeds;
    }

    global class UpdateStack{
        public String id;
        public String itemType;
        public String name;
        public String dl;
        public String valueStreamId;
    }

    @RemoteAction
    global static KanbanCardResponse updateWorkSchedule(WorkSchedule request){
        KanbanCardResponse response = new KanbanCardResponse();
        Set<Id> valueStreamIds = new Set<Id>();
        Set<KanbanCard.KanbanCardPayload> kanbanCards = new Set<KanbanCard.KanbanCardPayload>();
        List<leankor__KanbanCard__c> kanbanCardListResult = new  List<leankor__KanbanCard__c>();
        KanbanCardPayload kanbanCardPayload = new KanbanCardPayload();
        Map<Id, String> recordTypeMap = Util.getRecordTypeMap();
        Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{String.valueOf(request.workItemIds)},'KC');
        Map<Id, leankor__KanbanCard__c> existingKanbanCards = readKanbanCards(new Set<Id>(request.workItemIds));
        Set<Id> resourceIds = new Set<Id>();
        List<leankor__KanbanCard__c> listOfCards = new List<leankor__KanbanCard__c>();
            
        Set<Id> ownerIds = new Set<Id>();
        for (KanbanCard__c kanbanCard : request.workItems) {
            valueStreamIds.add(kanbanCard.leankor__ValueStream__c);

            if (kanbanCard.OwnerId != null) {
                ownerIds.add(kanbanCard.OwnerId);
            }

            if (!existingKanbanCards.isEmpty()) {
                if(recordTypeMap.get(kanbanCard.recordTypeId) == 'ActivityCard' && existingKanbanCards.containsKey(kanbanCard.Id)) {
                    leankor__KanbanCard__c existingCard = existingKanbanCards.get(kanbanCard.Id);
                    listOfCards.add(existingCard);
                    resourceIds.add(existingCard.OwnerId);
                }
            }
        }
       
        Savepoint savePoint = Database.setSavepoint();
        try {
            if (!request.workItems.isEmpty()) {
                List<FeedItem> feeds = prepareFeedRecords(request.workItems, request.workItemIds); // Prepare feed record for subscribers if the card's percent complete is updated to 100%.
                List<leankor__ResourceAssignment__c> resourceAssignmentRecords = createDefaultResourceAssignment(listOfCards, resourceIds);//Create default resource assignment if milestone duration is updated > 0 and AssignActivity Resource is true on the project.
                request.affectedWorkItems.addAll(request.workItems);
                KanbanCard.updateKanbanCards(request.affectedWorkItems);
                
                if (!ownerIds.isEmpty()) {
                    Subscriber subscriber = new Subscriber();
                    List <leankor__Subscriber__c> listOfSubscribers = subscriber.getSubscribers(request.workItemIds);
                    if (listOfSubscribers.size() > 0) {
                        feeds.addAll(generateSubscriberOnOwnerChange(request.workItems, request.workItemIds, ownerIds, valueStreamIds));// On card owner update, query subscribers, use preferences or defaults to upsert subscribers, and prepare feed records if FollowOnChatter criteria match.
                    }
                }

                if (!request.resourceAssignments.isEmpty() || !resourceAssignmentRecords.isEmpty()) {
                    request.resourceAssignments.addAll(resourceAssignmentRecords);
                    ResourceAssignment.upsertResourceAssignments(request.resourceAssignments);
                }
                
                if (!request.newResourceAssignments.isEmpty()) {
                    multipleResourceAssignmentActivity(request.workItemIds, request.newResourceAssignments, new Set<Id>(request.resourceTypeIds), new Set<Id>(request.resourceIds));
                }
                
                if (!feeds.isEmpty()) {
	                OpenFeedItemRestriction.createFeedItems(feeds);
	            }

                if(!request.scheduleMode.isEmpty()){
                    response.scheduleModes = ScheduleMode.updateScheduleModes(request.scheduleMode);
                }

                if(!request.updatePlanningMode.isEmpty()){
                    ValueStream.updateValueStream(request.updatePlanningMode);
                }

                if (!request.stickers.isEmpty() || request.isStickerChanged) {
                    KanbanCardSticker.upsertKanbanCardStickers(new Set<leankor__KanbanCardSticker__c>(request.stickers), new Set<Id>(request.workItemIds));
                    response.stickers = new List<leankor__Sticker__c>();
                    kanbanCardPayload.stickers = response.stickers;
                }
               
                createRealtimeTracker(request.verb, request.manageWorkItemHistory);
                response.resourceAssignments = new List<GanttTaskBoard.ResourceAssignment>();
                if (!request.workItemIds.isEmpty()) {
                    response.resourceAssignments = GanttTaskBoard.getResourceAssignmentBulkify(request.workItemIds);
                }
                
                if (!request.stickers.isEmpty()) {
                    response.stickers = realTimeController.getKanbanCardStickers(request.workItemIds);
                    kanbanCardPayload.stickers = response.stickers;
                }

                for (leankor__KanbanCard__c kanbanCard : KanbanCard.readKanbanCards(new Set<Id>(request.workItemIds))) {
                    KanbanCard.KanbanCardPayload kanbanCardPayloadData = new KanbanCard.KanbanCardPayload();
                    kanbanCardPayloadData.Id = kanbanCard.Id;
                    kanbanCardPayloadData.Name = kanbanCard.Name;
                    kanbanCardPayloadData.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
                    kanbanCardPayloadData.GUID = kanbanCard.leankor__GUID__c;
                    kanbanCardPayloadData.Order = kanbanCard.leankor__Order__c;
                    kanbanCardPayloadData.StartDate = kanbanCard.leankor__StartDateTime__c;
                    kanbanCardPayloadData.DueDate = kanbanCard.leankor__DueDateTime__c;
                    kanbanCardPayloadData.PercentDone =  kanbanCard.leankor__PercentComplete2__c;
                    kanbanCardPayloadData.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
                    kanbanCardPayloadData.DurationUnits = kanbanCard.leankor__DurationUnits__c;
                    kanbanCardPayloadData.CardID = kanbanCard.leankor__CardId__c;
                    kanbanCardPayloadData.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
                    kanbanCardPayloadData.Priority = Integer.valueOf(kanbanCard.leankor__Priority__c);
                    kanbanCardPayloadData.Description = kanbanCard.leankor__DescriptionLong__c;
                    kanbanCardPayloadData.ValueStreamCardLink = kanbanCard.leankor__ValueStreamCardLink__c;
                    kanbanCardPayloadData.ValueStreamLinkID = kanbanCard.leankor__ValueStreamLink__c;
                    kanbanCardPayloadData.OwnerID = kanbanCard.OwnerId;
                    kanbanCardPayloadData.OwnerName = kanbanCard.Owner.Name;
                    kanbanCardPayloadData.ItemType = kanbanCard.RecordType.Name;
                    kanbanCardPayloadData.Color = kanbanCard.leankor__kanbanCardTemplate__r.Color__c;
                    kanbanCardPayloadData.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c;
                    kanbanCardPayloadData.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;
                    kanbanCardPayloadData.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
                    kanbanCardPayloadData.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c;
                    kanbanCardPayloadData.isConstraintRecalculate = kanbanCard.leankor__IsConstraintRecalculate__c;
                    kanbanCardPayloadData.valueStreamId = kanbanCard.leankor__ValueStream__c;
                    kanbanCardPayloadData.Monday = kanbanCard.leankor__Monday__c;
                    kanbanCardPayloadData.Tuesday = kanbanCard.leankor__Tuesday__c;
                    kanbanCardPayloadData.Wednesday = kanbanCard.leankor__Wednesday__c;
                    kanbanCardPayloadData.Thursday = kanbanCard.leankor__Thursday__c;
                    kanbanCardPayloadData.Friday = kanbanCard.leankor__Friday__c;
                    kanbanCardPayloadData.Saturday = kanbanCard.leankor__Saturday__c;
                    kanbanCardPayloadData.Sunday = kanbanCard.leankor__Sunday__c;
                    kanbanCardPayloadData.weekCalendar = kanbanCard.leankor__WeekCalendar__c;
                    kanbanCardPayloadData.isAtRisk = kanbanCard.leankor__IsAtRisk__c;
                    FieldServiceUtilityController.RecordDetails fslData = fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id) : null;
                    kanbanCardPayloadData.workOrderCount = fslData != null ? fslData.workOrderCount : 0;
                    kanbanCardPayloadData.serviceAppointmentCount = fslData != null ? (fslData.serviceAppointmentCount != null ? fslData.serviceAppointmentCount : null) : 0;
                    kanbanCardPayloadData.fslSchedStartDateTime = fslData != null ? fslData.fslSchedStartDateTime : null;
                    kanbanCardPayloadData.fslSchedDueDateTime = fslData != null ? fslData.fslSchedDueDateTime : null;
                    kanbanCards.add(kanbanCardPayloadData);    
                    kanbanCardListResult.add(kanbanCard);
                }
                
                Integer projectBoardWorkFieldSetList = [Select count()
                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                            Where leankor__ProjectBoard__c In :valueStreamIds
                                                            With Security_Enforced
                                                            Limit 1];

                if (projectBoardWorkFieldSetList > 0) {
                    response.customFields = LeankorFieldSetController.readCardsFieldSetData(request.workItemIds);
                }
                response.kanbanCards = kanbanCardListResult;
                kanbanCardPayload.scheduleModes = response.scheduleModes;
                kanbanCardPayload.kanbanCards = kanbanCards;
                kanbanCardPayload.valueStreamIds = valueStreamIds;
                kanbanCardPayload.resourceAssignments = response.resourceAssignments;
                kanbanCardPayload.customFields = response.customFields;
                kanbanCardPayload.workItemIds = request.workItemIds;
                String jsonStr = JSON.serialize(kanbanCardPayload);
	            sendBroadcast(request.verb, jsonStr, request.sessionId);
            }
        } catch (Exception e) {
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        return response;
    }

    private static Map<Id, leankor__KanbanCard__c> readKanbanCards(Set<Id> kanbanCards){
        return new Map<Id, leankor__KanbanCard__c>([Select Id, 
                                                            OwnerId, 
                                                            leankor__PercentComplete2__c, 
                                                            leankor__DueDateTime__c
                                                        From leankor__KanbanCard__c
                                                        Where Id In :kanbanCards
                                                            And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__AutoAssignResource__c = true
                                                            And recordType.Name = 'MileStoneCard'
                                                        With Security_Enforced
                                                        Limit 10000]);
    }

    @TestVisible
    private static List<leankor__ResourceAssignment__c> createDefaultResourceAssignment(List<leankor__KanbanCard__c> listOfCards, Set<Id> resourceIds){
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        if (listOfCards.isEmpty()) {
            return resourceAssignmentList;
        }
        if (!listOfCards.isEmpty()) {
            Map<Id, leankor__Resource__c> resourceTypesMap = Resource.readResource(resourceIds);
            for(leankor__kanbancard__c card : listOfCards) {    
                // creating RA for only activity card
                leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
                resourceAssignment.leankor__KanbanCard__c = card.Id;
                resourceAssignment.leankor__AssignedTo__c = card.OwnerId;
                resourceAssignment.leankor__PercentAllocation__c = 100;
                resourceAssignment.leankor__PercentCompleted__c = card.leankor__PercentComplete2__c;
                resourceAssignment.leankor__CompletedDate__c = resourceAssignment.leankor__PercentCompleted__c == 100 ? card.leankor__dueDate__c : null;
                Map<String, Object> mapResourceAsignment = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resourceAssignment));
                if (resourceTypesMap.containsKey(card.OwnerId)) {
                    leankor__Resource__c assignedResource = resourceTypesMap.get(card.OwnerId);            
                    Map<String, Object> mapResource = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(assignedResource));
                                    
                    mapResourceAsignment.put('leankor__ExpenseAccount__c', mapResource.get('leankor__ExpenseAccount__c'));       		
                    mapResourceAsignment.put('leankor__ExpenseSubCategory__c', mapResource.get('leankor__ExpenseSubCategory__c'));       		
                    mapResourceAsignment.put('leankor__ExpenseCategory__c', mapResource.get('leankor__ExpenseCategory__c'));       		
                    mapResourceAsignment.put('leankor__ExternalHourlyRate__c', mapResource.get('leankor__ExternalHourlyRate__c'));       		
                    mapResourceAsignment.put('leankor__InternalHourlyRate__c', mapResource.get('leankor__InternalHourlyRate__c')); 
                    mapResourceAsignment.put('CurrencyIsoCode', Resource.IS_MULTI_CURRENCY_ORGANIZATION ? mapResource.get('CurrencyIsoCode') : '');	
                    mapResourceAsignment.put('leankor__ProjectFinancial__c', mapResource.get('leankor__ProjectFinancial__c'));     
                } else {
                    mapResourceAsignment.put('leankor__ExpenseAccount__c', null);       		
                    mapResourceAsignment.put('leankor__ExpenseSubCategory__c', null);       		
                    mapResourceAsignment.put('leankor__ExpenseCategory__c', null);       		
                    mapResourceAsignment.put('leankor__ExternalHourlyRate__c', 0);       		
                    mapResourceAsignment.put('leankor__InternalHourlyRate__c', 0); 						
                    mapResourceAsignment.put('CurrencyIsoCode', Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Util.getCurrencyIsoCode(new leankor__Resource__c()) : '');
                    mapResourceAsignment.put('leankor__ProjectFinancial__c', null);
                }
                resourceAssignment = (leankor__ResourceAssignment__c)JSON.deserialize(JSON.serialize(mapResourceAsignment), leankor__ResourceAssignment__c.class);
                resourceAssignmentList.add(resourceAssignment);
            }
        }
        
        return resourceAssignmentList;
    }

    private class BroadcastData{
        private List<String> workItemIds;
        private List<String> valueStreamIds;
    }

    @RemoteAction
    global static List<leankor__KanbanCard__c> deleteWorkItems(DeleteWorkItem request){
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior(); 
        
        if (!timeCardBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        List<leankor__TimeCard__c> timeCards = new List<leankor__TimeCard__c>();
        List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();        
        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>(); 
        BroadcastData broadcastData = new BroadcastData();
                
        Savepoint savePoint = Database.setSavepoint();
        try {
            if (!request.workItems.isEmpty()) {
                Subscriber subscriberInstance = new Subscriber();
                List<leankor__Subscriber__c> subscribers = subscriberInstance.getSubscribers(request.workItemIds);
                for (leankor__Subscriber__c subscriber: subscribers) {
                    subscriber.leankor__Moved__c = false;
                    subscriber.leankor__PercentDone__c = false;
                    subscriber.leankor__CardPastDueDate__c = false;
                    subscriber.leankor__TaskPastDueDate__c = false;
                    subscriber.leankor__isTaskCompleted__c = false;
                }

                List<leankor__Dependency__c> dependencies = [Select Id, 
                                                                leankor__Predecessor__c, 
                                                                leankor__Successor__c,
                                                                leankor__ValueStream__c
                                                            From leankor__Dependency__c 
                                                            Where leankor__Successor__c In :request.workItemIds 
                                                                Or leankor__Predecessor__c In :request.workItemIds
                                                            With Security_Enforced
                                                            Limit 10000];

                Set<String> dependentCardIdSet = new Set<String>();
                if (dependencies.size() > 0) {
                    for (leankor__Dependency__c dependency : dependencies) {
                        //Get dependent card's Id for checking their's EDA updation
                        if (!request.workItemIds.contains(dependency.leankor__Predecessor__c)) {
                            dependentCardIdSet.add(dependency.leankor__Predecessor__c);
                        }
                        if (!request.workItemIds.contains(dependency.leankor__Successor__c)) {
                            dependentCardIdSet.add(dependency.leankor__Successor__c);
                        }
                        //Changes added for soft deleting Dependency records.
                        dependency.leankor__Predecessor__c = null;
                        dependency.leankor__Successor__c = null;
                        dependency.leankor__ValueStream__c = null;

                    }
                }

                for (leankor__ValueStream__c valueStream : [Select Id,
                                                                    leankor__ProjectRoomLink__c,
                                                                    leankor__ValueStreamCardLink__c,
                                                                    leankor__ValueStreamLink__c 
                                                                From leankor__ValueStream__c 
                                                                Where leankor__ValueStreamCardLink__c In :request.workItemIds
                                                                With Security_Enforced]) { 
                    valueStream.leankor__ProjectRoomLink__c = null;         
                    valueStream.leankor__ValueStreamCardLink__c = null;
                    valueStream.leankor__ValueStreamLink__c = null;
                    valueStreams.add(valueStream);
                }  

                for (leankor__TimeCard__c timeCard: [Select Id,
                                                            leankor__KanbanCard__c
                                                        From leankor__TimeCard__c 
                                                        Where leankor__KanbanCard__c In :request.workItemIds 
                                                        With Security_Enforced
                                                        Limit 10000]) {
                    timeCard.leankor__KanbanCard__c = null;
                    timeCards.add(timeCard);
                }

                for (leankor__KanbanCard__c linkedCard : [Select Id,
                                                                leankor__ValueStream__c,
                                                                leankor__GUID__c,
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStreamLink__c 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__ValueStreamCardLink__c In :request.workItemIds
                                                                And leankor__ValueStream__r.leankor__BoardType__c In ('Kanban Board','Whiteboard','DashBoard','Plan Board')
                                                            With Security_Enforced]) {

                    linkedCard.leankor__ValueStreamCardLink__c = null;
                    linkedCard.leankor__ValueStreamLink__c = null;
                    linkedCards.add(linkedCard);
                }
            

                String result = GanttTaskBoard.deleteActivityBaseline(request.workItemIds);
            
                if (!valueStreams.isEmpty()) {
                    valueStreams.addAll(request.updatePlanningMode);
                    ValueStream.updateValueStream(valueStreams);
                }

                if (!timeCards.isEmpty()) {
                    update timeCards;
                }

                if (!request.workItems.isEmpty()) {
                    linkedCards.addAll(request.workItems);
                    KanbanCard.updateKanbanCards(linkedCards);
                }

                leankor.GanttTaskBoard.DeleteScheduleMode(request.workItemIds);
                leankor.GanttTaskBoard.DeleteResourceAssignment(request.workItemIds);
                
                if (!subscribers.isEmpty()) {
                    Subscriber.upsertSubscribers(subscribers);
                }
                
                if (!dependencies.isEmpty()) {
                    Dependency.updateDependency(dependencies);
                }

                if (dependentCardIdSet.size() > 0) {
                    leankor.RealTimeController.KanbanCardsData dependentCards  = RealTimeControllerHelper.updateExternallyDependentCards(dependentCardIdSet);
                    if (dependentCards.kanbanCards.size() > 0) {
                        KanbanCard.updateKanbanCards(dependentCards.kanbanCards);
                    }
                }
                createRealtimeTracker(request.verb, request.manageWorkItemHistory);
                broadcastData.valueStreamIds = request.valueStreamIds;
                broadcastData.workItemIds = request.workItemIds;
                String jsonStr = JSON.serialize(broadcastData);
                sendBroadcast(request.verb, jsonStr, request.sessionId);
            }
        } catch(Exception e) {
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return request.workItems;
    }

    @RemoteAction
    global static List<leankor__KanbanCard__c> updateAffectedWorkItems(DeleteWorkItem request){
        BroadcastData broadcastData = new broadcastData();
        Savepoint savePoint = Database.setSavepoint();
        try {
            if(!request.workItems.isEmpty()){
                KanbanCard.updateKanbanCards(request.workItems);
            }
            if(request.verb != null){
                broadcastData.workItemIds = request.workItemIds;
                broadcastData.valueStreamIds = request.valueStreamIds;
                String jsonStr = JSON.serialize(broadcastData);
                sendBroadcast(request.verb, jsonStr, request.sessionId);
            }
        } catch(Exception e){
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        return request.workItems;
    }

    @RemoteAction
    global static List<leankor__dependency__c> manageDependency(DependencyRequest request){
        DependencyBroadcast dependencyBroadcast = new DependencyBroadcast();
        Map<String, List<leankor__Dependency__c>> valueStreamToDependenciesMap = new Map<String, List<leankor__Dependency__c>>();

        Savepoint savePoint = Database.setSavepoint();
        for (leankor__Dependency__c dependency : request.dependencyList) { 
            if (!valueStreamToDependenciesMap.containsKey(dependency.leankor__ValueStream__c)) {
                valueStreamToDependenciesMap.put(dependency.leankor__ValueStream__c, new List<leankor__Dependency__c>());
            }
            valueStreamToDependenciesMap.get(dependency.leankor__ValueStream__c).add(dependency);
        }

        try {
            if(!request.dependencyList.isEmpty()) {
                Schema.Sobjectfield externField = leankor__Dependency__c.Fields.leankor__GUID__c;
                Database.upsert(request.dependencyList, externField, true); 

                if(!request.affectedWorkItems.isEmpty()){
                    KanbanCard.updateKanbanCards(request.affectedWorkItems);
                }
                
                if(!request.updatePlanningMode.isEmpty()){
                    ValueStream.updateValueStream(request.updatePlanningMode);
                }

                // Prepare and send broadcast
                dependencyBroadcast.valueStreamIds = request.valueStreamIds;
                dependencyBroadcast.dependencyList = request.dependencyList;
                dependencyBroadcast.workItemIds = request.workItemIds;
                sendBroadcast(request.verb, JSON.serialize(dependencyBroadcast), request.sessionId);

                List<leankor__RealtimeTracker__c> realtimeTrackerList = new List<leankor__RealtimeTracker__c>();
                
                // Process dependencies grouped by ValueStream
                for (String valueStreamId : valueStreamToDependenciesMap.keySet()) {
                    List<leankor__Dependency__c> dependencies = valueStreamToDependenciesMap.get(valueStreamId);
                    List<Id> dependencyIds = new List<Id>();

                    for (leankor__Dependency__c dependency : dependencies) {
                        dependencyIds.add(dependency.Id);
                    }

                    // Serialize dependency IDs once per ValueStream
                    String jsonString = JSON.serialize(dependencyIds);
                    leankor.realTimeController.JSONGroup myJSONGroup = new leankor.realTimeController.JSONGroup();
                    leankor__RealtimeTracker__c realtimeTracker = new leankor__RealtimeTracker__c();
                    realtimeTracker.leankor__KanbanVerb__c = request.verb;
                    realtimeTracker.leankor__ValueStream__c = valueStreamId;

                    if (!leankor.realTimeController.putJSONGroup(jsonString, myJSONGroup)) {
                        leankor__RealtimeTracker__c realTimeRecord = leankor.GenericStreamingController.createRTForSelectedData(jsonString, realtimeTracker);
                        if (realTimeRecord != null) {
                            realtimeTrackerList.add(realTimeRecord);
                        }
                    } else {
                        realtimeTrackerList.add(GenericStreamingController.assignJsonData(realtimeTracker, myJSONGroup));
                    }
                }

                // Insert all RealTimeTracker records in one go
                if (!realtimeTrackerList.isEmpty()) {
                    List<Database.SaveResult> realTimeTrackerSaveResult = OpenTaskRestriction.insertRealTimeTrackers(realtimeTrackerList);
                }
            }
        }catch(Exception e) {
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        return request.dependencyList;
    }

    private class DependencyBroadcast{
        private List<String> valueStreamIds;
        private List<leankor__Dependency__c> dependencyList;
        private List<String> workItemIds;
    }
    @RemoteAction
    global static List<leankor__Filter__c> readProjectBoardViews(List<leankor__ValueStream__c> valueStreams) {
        Set<leankor__ValueStream__c> setValueStreams = new Set<leankor__ValueStream__c>(valueStreams);  
        List<leankor__Filter__c> filters = new List<leankor__Filter__c >([Select Id,
                                                                                    Name,
                                                                                    CreatedDate,
                                                                                    leankor__CurrentView__c
                                                                                From leankor__Filter__c
                                                                                Where leankor__ValueStream__c = :setValueStreams
                                                                                    And leankor__User__c = :UserInfo.getUserId()
                                                                                With Security_Enforced
                                                                                Order By CreatedDate Desc, Name Asc
                                                                                Limit 50000]);

        return  filters;                                                                           
    }

    @RemoteAction
    global static List<leankor__Filter__c> updateProjectBoardViews(List<leankor__Filter__c> filters) {
        Filter filter = new Filter();
        String userId;
        Id valueStreamId;
        if(!filters.isEmpty()){
            leankor__Filter__c currentFilter = filters[0];
            valueStreamId = String.escapeSingleQuotes(currentFilter.leankor__ValueStream__c);
            userId = String.escapeSingleQuotes(currentFilter.leankor__User__c);
            String dynamicQuery = 'Select Id, Name, leankor__CurrentView__c ' +
                                        'From leankor__Filter__c ' +
                                        'Where leankor__User__c = \'' + userId + '\'' +
                                        'And leankor__ValueStream__c = \'' + valueStreamId + '\'';

            List<leankor__Filter__c> filterToUpdate = filter.readFilters(dynamicQuery);
            for (Integer index = 0; index < filterToUpdate.size(); index++){
                if (filterToUpdate[index].Id != currentFilter.Id) {
                    filterToUpdate[index].leankor__CurrentView__c = false;
                } else {
                    filterToUpdate[index] = currentFilter;
        		}
            }
            List<leankor__Filter__c> updatedFilters = filter.updateFilters(filterToUpdate);
        }
        
        String dynamicQuery = 'Select Id, leankor__BoardURL__c, leankor__OwnerData__c,' +
                                    'leankor__CategoryData__c, leankor__FeatureData__c, leankor__PercentCompleteRangeFilter__c,'+
                                    'leankor__PortfolioLinkData__c, leankor__PriorityData__c,leankor__StickerData__c,'+
                                    'leankor__CurrentView__c, leankor__DefaultFilter__c, Name,leankor__FilterON__c,'+
                                    'leankor__GanttDividerSize__c,leankor__HideSchedule__c,leankor__MiniatureName__c,'+
                                    'OwnerId, leankor__User__c, leankor__ValueStream__c, leankor__VisibleColumnWidth__c '+
                                    'From leankor__Filter__c ' +
                                    'Where leankor__CurrentView__c = True ' +
                                    'And leankor__User__c = \'' + userId + '\''+
                                'And leankor__ValueStream__c = \'' + valueStreamId + '\''+
                                'Order By CreatedDate Desc ' +
                                'Limit 1';

        return filter.readFilters(dynamicQuery);
    }

    @RemoteAction
    global static List<leankor__Filter__c> createProjectBoardViews(List<leankor__Filter__c> filters) {
        Filter filter = new Filter();
        String userId;
        Id valueStreamId;
        if(!filters.isEmpty()){
            leankor__Filter__c currentFilter = filters[0];
            valueStreamId = String.escapeSingleQuotes(currentFilter.leankor__ValueStream__c);
            userId = String.escapeSingleQuotes(currentFilter.leankor__User__c);
            String dynamicQuery = 'Select Id, Name, leankor__CurrentView__c ' +
                                        'From leankor__Filter__c ' +
                                        'Where leankor__User__c = \'' + userId + '\'' +
                                        'And leankor__ValueStream__c = \'' + valueStreamId + '\'';

            List<leankor__Filter__c> filterToUpdate = filter.readFilters(dynamicQuery);
            for (leankor__Filter__c filterRecord : filterToUpdate) {
                // Update all filters except the one with leankor__CurrentView__c = true
                filterRecord.leankor__CurrentView__c = false;
        }
            filterToUpdate.addAll(filters);
            List<leankor__Filter__c> updatedFilters = filter.createFilters(filterToUpdate);
        }
        // Query and return the created Filter records where CurrentView = TRUE for the logged-in user
        String dynamicQuery = 'Select Id, leankor__BoardURL__c, leankor__OwnerData__c,' +
                                    'leankor__CategoryData__c, leankor__FeatureData__c, leankor__PercentCompleteRangeFilter__c,'+
                                    'leankor__PortfolioLinkData__c, leankor__PriorityData__c,leankor__StickerData__c,'+
                                    'leankor__CurrentView__c, leankor__DefaultFilter__c, Name,leankor__FilterON__c,'+
                                    'leankor__GanttDividerSize__c,leankor__HideSchedule__c,leankor__MiniatureName__c,'+
                                    'OwnerId, leankor__User__c, leankor__ValueStream__c, leankor__VisibleColumnWidth__c '+
                                'From leankor__Filter__c ' +  
                                'Where leankor__CurrentView__c = True ' +
                                'And leankor__User__c = \'' + userId + '\''+
                                'And leankor__ValueStream__c = \'' + valueStreamId + '\''+
                                'Order By CreatedDate Desc ' +
                                'Limit 1';

        // Call the readFilters method to execute the query
        return filter.readFilters(dynamicQuery);
    }

    @RemoteAction
    global static List<leankor__Filter__c> readFilterRecords(List<Id> filterIds) {
        Filter filter = new Filter();
        if (filterIds.isEmpty()) {
            return new List<leankor__Filter__c>();
        }
        return filter.readFilters(filterIds);                                            
    }
    
    public static List<FeedItem> generateSubscriberOnOwnerChange(List<leankor__KanbanCard__c> kanbanCards, List<Id> workItemIds, Set<Id> ownerIds, Set<Id> valueStreamOwners) {
        UserBehaviour userBehaviour = new userBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__Subscriber__c> subscriberRecords = new List<leankor__Subscriber__c>();
        List<FeedItem> feeds = new List<FeedItem>();

        // Map to hold preferences by ValueStream and OwnerId for quick lookup
        Map<String, leankor__Preference__c> preferenceMap = new Map<String, leankor__Preference__c>();
        if (!valueStreamOwners.isEmpty()) {
            for(leankor__Preference__c  preference : [Select Id, 
                                                                leankor__CardPastDueDate__c, 
                                                                leankor__Moved__c, 
                                                                leankor__PercentDone__c, 
                                                                leankor__isTaskCompleted__c, 
                                                                leankor__TaskPastDueDate__c, 
                                                                leankor__ValueStream__c, 
                                                                OwnerId,
                                                                leankor__FollowOnChatter__c 
                                                            From leankor__Preference__c 
                                                        Where leankor__ValueStream__c In :valueStreamOwners 
                                                            And OwnerId In :ownerIds
                                                        With Security_Enforced
                                                        Limit 10000]){

                String key = preference.leankor__ValueStream__c + '-' + preference.OwnerId;
                preferenceMap.put(key, preference);
            }
        }

        Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
        Map<Id, String> recordTypeMap = Util.getRecordTypeMap();
        Map<Id, leankor__KanbanCard__c> existingKanbanCards = KanbanCard.getExistingKanbanCards(new Set<Id>(workItemIds));
        String leankorBaseURL = Util.getDomainUrl();
        Map<Id,Id> networkMemberMap = new Map<Id,Id>();
        String networkId = Network.getNetworkId();
        Boolean isNetworkAvailable = (Type.forName('Schema.NetworkMember') != null);
        if (isNetworkAvailable) {
            leankor.OpenFeedItemRestriction.readNetworkMember(new List<Id>(ownerIds), networkMemberMap);
        }
        // Prepare the Subscriber records for insertion
        if (!ownerIds.isEmpty()) {
            Map<Id,User> userMap = new Map<Id,User> ([Select Id, 
                                                                UserType 
                                                            From User 
                                                            Where Id In :ownerIds 
                                                            Limit 10000]);

            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                String key = kanbanCard.leankor__ValueStream__c + '-' + kanbanCard.OwnerId;
                leankor__Subscriber__c subscriber;

                // Check if preference exists for the current ValueStream and OwnerId
                if (preferenceMap.containsKey(key)) {
                    leankor__Preference__c preference = preferenceMap.get(key);
                    
                    if ((assigneeIds.contains(kanbanCard.OwnerId)) && (preference.leankor__FollowOnChatter__c == 'all' || (preference.leankor__FollowOnChatter__c).contains(kanbanCard.leankor__KanbanCardTemplate__c))) { 
                        leankor__KanbanCard__c existingKanbanCard = existingKanbanCards.get(kanbanCard.Id);
                        String linkUrlTemp = OpenFeedItemRestriction.createKanbanCardURL(existingKanbanCard, leankorBaseURL);
                        FeedItem post = new FeedItem();
                        post.ParentId = kanbanCard.OwnerId;
                        post.Title = kanbanCard.Name;
                        post.LinkUrl = linkUrlTemp + kanbanCard.Id;
                        
                        if (isNetworkAvailable && userMap.get(kanbanCard.OwnerId).UserType != 'Standard') {                            
                            post.put('NetworkScope', networkMemberMap.get(kanbanCard.OwnerId));  
                        }
                        if (String.isNotBlank(networkId)) {
                            post.put('Visibility','AllUsers');
                        }
                        if (recordTypeMap.get(kanbanCard.recordTypeId) == 'MileStone') {
                            post.Body = UserInfo.getName() + ' has assigned you as owner of milestone "' + kanbanCard.Name + '". Click this link to go to the project board. ' + '\n\n' + existingKanbanCard.leankor__ProjectRoom__c + ' / ' + existingKanbanCard.leankor__ValueStream__r.Name;
                        } else {
                            post.Body = UserInfo.getName() + ' has assigned you as owner of card "' + kanbanCard.Name + '". Click this link to go to the project board. ' + '\n\n' + existingKanbanCard.leankor__ProjectRoom__c + ' / ' + existingKanbanCard.leankor__ValueStream__r.Name;
                        }
                        feeds.add(post);
                    }

                    // Create subscriber based on the found preference
                    subscriber = new leankor__Subscriber__c(
                        Name = kanbanCard.Id,
                        leankor__KanbanCard__c = kanbanCard.Id,
                        leankor__SubscriberID__c = kanbanCard.OwnerId,
                        leankor__SubscriberKey__c = kanbanCard.Id + '-' + kanbanCard.OwnerId,
                        leankor__Moved__c = preference.leankor__Moved__c,
                        leankor__PercentDone__c = preference.leankor__PercentDone__c,
                        leankor__CardPastDueDate__c = preference.leankor__CardPastDueDate__c,
                        leankor__isTaskCompleted__c = preference.leankor__isTaskCompleted__c,
                        leankor__TaskPastDueDate__c = preference.leankor__TaskPastDueDate__c
                    );
                } else {
                    // Create a subscriber with default values if no preference is found
                    subscriber = new leankor__Subscriber__c(
                        Name = kanbanCard.Id,
                        leankor__KanbanCard__c = kanbanCard.Id,
                        leankor__SubscriberID__c = kanbanCard.OwnerId,
                        leankor__SubscriberKey__c = kanbanCard.Id + '-' + kanbanCard.OwnerId,
                        leankor__Moved__c = false,
                        leankor__PercentDone__c = true,
                        leankor__CardPastDueDate__c = true,
                        leankor__TaskPastDueDate__c = true,
                        leankor__isTaskCompleted__c = true
                    );
                }
                subscriberRecords.add(subscriber);
            }
        }

        if (!subscriberRecords.isEmpty()) {
	        Subscriber.upsertSubscribers(subscriberRecords);
	    }
        return feeds;
    }

    private static List<leankor__ResourceAssignment__c> multipleResourceAssignmentActivity(List<String> workItemIds, List<leankor__ResourceAssignment__c> resourceAssignments, Set<Id> resourceTypeIds, Set<Id> resourceIds) {

        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for (leankor__ResourceAssignment__c resourceAssignment : [Select Id,
                                                                        leankor__KanbanCard__c,
                                                                        leankor__AssignedTo__c,
                                                                        leankor__ResourceType__c,
                                                                        leankor__ProjectFinancial__c
                                                                    From leankor__ResourceAssignment__c 
                                                                    Where leankor__KanbanCard__c In: workItemIds 
                                                                    With Security_Enforced
                                                                    Limit 10000]) {
            resourceAssignment.leankor__KanbanCard__c = null;
            resourceAssignment.leankor__AssignedTo__c = null;
            resourceAssignment.leankor__ResourceType__c = null;
            resourceAssignment.leankor__ProjectFinancial__c = null;
            resourceAssignmentList.add(resourceAssignment);
        }

        Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds); 
        Map<Id, leankor__ResourceType__c> mapOfResourceType = ResourceType.readResourceType(resourceTypeIds); 
        for (leankor__ResourceAssignment__c request : resourceAssignments) {
            if (mapOfResourceType.containsKey(request.leankor__ResourceType__c) || (request.leankor__ResourceType__c != null ? Id.valueOf(request.leankor__ResourceType__c).getSObjectType().getDescribe().getName() == 'leankor__ResourceType__c' : false)) {
                request = ResourceType.IS_MULTI_CURRENCY_ORGANIZATION ? ResourceType.setResourceAccounts(request.leankor__ResourceType__c, mapOfResourceType, request, true) : ResourceType.setResourceAccounts(request.leankor__ResourceType__c, mapOfResourceType, request);                    
            } else {
                request = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(request.leankor__AssignedTo__c, resourceTypes, request, true) : Resource.setResourceAccounts(request.leankor__AssignedTo__c, resourceTypes, request); 
            }        
            resourceAssignmentList.add(request);
        }

        if (resourceAssignmentList.size() > 0) {
            ResourceAssignment.upsertResourceAssignments(resourceAssignmentList);
        }

        leankor.ProjectBoardCarousel.raPercentageCompleteChanged(workItemIds);

        return resourceAssignmentList;
    }
}