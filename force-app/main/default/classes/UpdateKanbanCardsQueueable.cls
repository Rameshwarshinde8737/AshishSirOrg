/**************************************************************************
 * Author   : Vijay Jayswal
 * Date     : 18/03/2020
 * Usage    : Queueable class to Update bulk kanbancards and prevent heap size and CPU timeout limits. 
 **************************************************************************/ 

public with sharing class UpdateKanbanCardsQueueable implements Queueable {

    private Boolean isSendBroadcastMessage;
    private realtimeController.bulkStreaming stream;
    MultipleUpdateKanbanCardAction.KanbanCardRequest request;
	private static final Integer BROADCAST_REQUEST_LIMIT = 40;

    public UpdateKanbancardsQueueable(realtimeController.bulkStreaming stream, Boolean sendBroadcastMessage) {
        this.stream = stream;
        this.isSendBroadcastMessage = sendBroadcastMessage;
    } 

	// We are not updating leankor__IsSuccessorRecalculate__c for parent folder at updateParentCards(). So we have to do that here.
	private static Set<String> folderCards = new Set<String>();
   
    public UpdateKanbancardsQueueable(MultipleUpdateKanbanCardAction.KanbanCardRequest request) {
        this.request = request;
    }

    public void execute(QueueableContext context) {
       	RealTimeController.flowWithGSForAPI = true;
		//02/June/2023 : We have added new variable for Hybrid constraint while update the card by using API.. 
		KanbanController.isCalledFromMultipleAPI = true;
		
    	updateKanbanCards(request);
	}

    public static void updateKanbanCards(MultipleUpdateKanbanCardAction.KanbanCardRequest request) {	
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible() ||
			!kanbanCardBehaviour.isUpdateable() || 
			!valueStreamBehavior.isUpdateable() ||
            !scheduleModeBehavior.isCreateable() ||
			!scheduleModeBehavior.isDeletable() ||
			!resourceAssignmentBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior

		Set<Id> ownerIds = new Set<Id>();
        Set<String> valueStreamIds = new Set<String>();
		Set<String> linkCardIds = new Set<String>();
		List<String> kanbanCardIds = new List<String>();
		Map<Id, Util.WorkWeek> workWeekMap = new Map<Id, Util.WorkWeek>();
		List<leankor__KanbanCard__c> updateKCList = new List<leankor__KanbanCard__c>();
		List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
		RealtimeController.flowWithGSForAPI = true;
		String projectId;
		String projectEventCustomPayload;
		Set<String> broadcastingBoardIds = new Set<String>();
		List<String> kanbanIds = new List<String>();
		// used for broadcast.
		List<RealTimeController.bulkStreaming> bulkStreams = new List<RealTimeController.bulkStreaming>();
		Map<String, List<String>> broadcastContentMap =  new Map<String, List<String>>();

						
		for (leankor__Kanbancard__c kcRequest : request.kanbancardList) {  
			ownerIds.add(kcRequest.OwnerID);                                                    
			kanbanCardIds.add(kcRequest.Id);                          
			if (String.isNotBlank(kcRequest.leankor__valueStreamCardLink__c)) {
				linkCardIds.add(kcRequest.leankor__valueStreamCardLink__c);
			}
		}

		if (String.isNotBlank(request.projectId)) {
			projectId = request.projectId;
		}
		
		if (String.isNotBlank(request.projectEventCustomPayload)) {
			projectEventCustomPayload = request.projectEventCustomPayload;
		}
		// Get kanban card map and workweek map
		Map<Id, leankor__KanbanCard__c> kanbanCardMap = UpdateKanbanCard.getKanbanCardMap(kanbanCardIds, workWeekMap);

		// Get linked kanbanCard map
		Map<Id, leankor__kanbancard__c> linkedKanbanCardsMap = CreateKanbanCard.getLinkedCardMap(linkCardIds); 
		linkCardIds.clear();

		// Get Miniature of activity.
		Map<Id, leankor__kanbancard__c> miniatureMap = UpdateKanbanCard.getMiniatureOfActivity(kanbanCardIds);
		kanbanCardIds.clear();

		// Create the user map         	            	
		Map<String,User> userData = new Map<String,User>([Select Id, 
																	IsActive, 
																	Name 
																From User 
																Where (Id In: ownerIds
																	And IsActive = true)
																Limit 10000]);				
		ownerIds.clear();
																																								
		// Create the record type map
		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>([Select Id, 
																						Name 
																					From RecordType 
																					Where SobjectType = 'leankor__KanbanCard__c' 
																					Limit 1000]);	

		leankor__KanbanCard__c kanban;
		Boolean scheduledChangeFlag = false;

		Boolean updatedCardLinkFlag;
		List<leankor__KanbanCard__c> changedDatesCards = new List<leankor__KanbanCard__c>();

		for (leankor__Kanbancard__c kcRequest : request.kanbancardList) {
			updatedCardLinkFlag = false;

			if (!KanbanCardMap.containsKey(kcRequest.Id)) {
				continue; // If wrong record Id provided in the request
			}
			// Get the KC record
			kanban = KanbanCardMap.get(kcRequest.Id);   

			Integer oldEstimatedDuration = Integer.valueOf(kanban.leankor__EstimatedDuration__c);
			String oldDurationUnits = kanban.leankor__DurationUnits__c;
			Datetime oldStartDateTIme = kanban.leankor__StartDateTime__c;
			Datetime oldDueDateTIme = kanban.leankor__DueDateTime__c;

			// Updating resources assignment record assignTo field according to owner Id.                     
			if (kanban.leankor__BoardType__c != 'UberBoard' && kcRequest.OwnerID != null && kanban.OwnerId != kcRequest.OwnerID) {  
				for (leankor__ResourceAssignment__c base : kanban.leankor__ResourceAssignments__r) {	                                                                     
					base.leankor__AssignedTo__c = (userData.containsKey(kcRequest.OwnerId) && userData.get(kcRequest.OwnerId).IsActive) ? kcRequest.OwnerID:UserInfo.getUserId();                                                                         
					resourceAssignmentList.add(base);
				}
			} 

			kanban.leankor__CardID__c = kcRequest.leankor__CardID__c == null ? kanban.leankor__CardID__c : kcRequest.leankor__CardID__c;
			kanban.leankor__Point__c =  kcRequest.leankor__Point__c == null ? kanban.leankor__Point__c : kcRequest.leankor__Point__c; 
			kanban.leankor__Title__c = kcRequest.leankor__Title__c == null ? kanban.leankor__Title__c : kcRequest.leankor__Title__c; 
			kanban.Name = kcRequest.Name == null ? kanban.Name : kcRequest.Name;
			kanban.leankor__Top__c = kcRequest.leankor__Top__c == null ? kanban.leankor__Top__c : kcRequest.leankor__Top__c;
			kanban.leankor__Bottom__c = kcRequest.leankor__Bottom__c == null ? kanban.leankor__Bottom__c : kcRequest.leankor__Bottom__c;
			kanban.leankor__Left__c = kcRequest.leankor__Left__c == null ? kanban.leankor__Left__c : kcRequest.leankor__Left__c;
			kanban.leankor__Width__c = kcRequest.leankor__Width__c == null ? kanban.leankor__Width__c : kcRequest.leankor__Width__c;
			kanban.leankor__Height__c = kcRequest.leankor__Height__c == null ? kanban.leankor__Height__c : kcRequest.leankor__Height__c; 
			kanban.leankor__X__c = kcRequest.leankor__X__c == null ? kanban.leankor__X__c : kcRequest.leankor__X__c;
			kanban.leankor__Y__c = kcRequest.leankor__Y__c == null ? kanban.leankor__Y__c : kcRequest.leankor__Y__c;
			kanban.leankor__JSONDefinition__c = kcRequest.leankor__JSONDefinition__c == null ? kanban.leankor__JSONDefinition__c :  kcRequest.leankor__JSONDefinition__c;
			kanban.leankor__JSONData__c = kcRequest.leankor__JSONData__c == null ? kanban.leankor__JSONData__c : kcRequest.leankor__JSONData__c;
			kanban.leankor__KanbanCardTemplate__c = String.IsNotBlank(kcRequest.leankor__KanbanCardTemplate__c) ? kcRequest.leankor__KanbanCardTemplate__c : kanban.leankor__KanbanCardTemplate__c;
			kanban.leankor__Color__c = String.IsNotBlank(kcRequest.leankor__Color__c) ? kcRequest.leankor__Color__c : kanban.leankor__Color__c; 
			kanban.leankor__AcceptanceCriteria__c = (kcRequest.leankor__AcceptanceCriteria__c == null ? (kanban.leankor__AcceptanceCriteria__c == null ? '' : kanban.leankor__AcceptanceCriteria__c) : kcRequest.leankor__AcceptanceCriteria__c);                
			kanban.leankor__DescriptionLong__c = (kcRequest.leankor__DescriptionLong__c == null ? (kanban.leankor__DescriptionLong__c == null ? '' : kanban.leankor__DescriptionLong__c) : kcRequest.leankor__DescriptionLong__c.unescapeHtml4());                                                       
			kanban.recordTypeId = kanban.RecordTypeId;
			
            Set<String> weekDays = new Set<String>();
			if (kanban.leankor__valueStream__r.leankor__SevenDayWorkWeek__c) {
				//Pratiksha : 13/Oct/2023 : Changes for WeekCalendar
				if (kanban.leankor__Monday__c == false && kanban.leankor__Tuesday__c == false && kanban.leankor__Wednesday__c == false &&  kanban.leankor__Thursday__c == false &&  kanban.leankor__Friday__c == false &&  kanban.leankor__Saturday__c == false &&  kanban.leankor__Sunday__c == false){
					kanban.leankor__Monday__c = true;
					kanban.leankor__Tuesday__c = true;
					kanban.leankor__Wednesday__c = true;
					kanban.leankor__Thursday__c = true;
					kanban.leankor__Friday__c = true;
					kanban.leankor__Saturday__c = true;
					kanban.leankor__Sunday__c = true;
				} else {
					kanban.leankor__Monday__c = kanban.leankor__Monday__c;
					kanban.leankor__Tuesday__c = kanban.leankor__Tuesday__c;
					kanban.leankor__Wednesday__c = kanban.leankor__Wednesday__c;
					kanban.leankor__Thursday__c = kanban.leankor__Thursday__c;
					kanban.leankor__Friday__c = kanban.leankor__Friday__c;
					kanban.leankor__Saturday__c = kanban.leankor__Saturday__c;
					kanban.leankor__Sunday__c = kanban.leankor__Sunday__c;
					kanban.leankor__weekCalendar__c = kanban.leankor__WeekCalendar__c;
				
					weekDays.add(kanban.leankor__Monday__c == false ? 'Mon' : 'false');
					weekDays.add(kanban.leankor__Tuesday__c == false ? 'Tue' : 'false');
					weekDays.add(kanban.leankor__Wednesday__c == false ? 'Wed' : 'false');
					weekDays.add(kanban.leankor__Thursday__c == false ? 'Thu' : 'false');
					weekDays.add(kanban.leankor__Friday__c == false ? 'Fri' : 'false');
					weekDays.add(kanban.leankor__Saturday__c == false ? 'Sat' : 'false');
					weekDays.add(kanban.leankor__Sunday__c == false ? 'Sun' : 'false');
				}
			}    
			Util.weekDays = weekDays;
			
			/* Calling helper Method to calculate StartDate, DueDate, EstimateDuration and RecordType.
					If folderCard have child record then we are not updating the this fields.
					If Activity/Milestone have miniature in that case we not updating this fields.*/
			if (!((miniatureMap.containsKey(kanban.Id) && kanban.leankor__BoardType__c == 'UberBoard'))) {
				UpdateKanbanCard.updateKanbanCardHelper(kanban, kcRequest, workWeekMap.get(kanban.leankor__ValueStream__c), recordTypeMap);
			}

			// Check weather dates changed on the card or not
			if ((kanban.leankor__StartDate__c != kanban.leankor__StartDateTime__c.date()) || (kanban.leankor__DueDate__c != kanban.leankor__DueDateTime__c.date())) {
				scheduledChangeFlag = true;
			}

			if (kcRequest.leankor__EstimatedDuration__c != null && (kcRequest.leankor__EstimatedDuration__c != kanban.leankor__EstimatedDuration__c) ) {
				scheduledChangeFlag = true;
			}

			// After checking schedule change assign the new dates on the card
			kanban.leankor__StartDate__c = kanban.leankor__StartDateTime__c.date();
			kanban.leankor__DueDate__c = kanban.leankor__DueDateTime__c.date();

			// Assign the owner of the card
			if (userData.containsKey(kcRequest.OwnerId)) { 
				kanban.OwnerID = userData.get(kcRequest.OwnerId).IsActive ? kcRequest.OwnerId : UserInfo.getUserId();
			} else {
				kanban.OwnerID = (kcRequest.OwnerID == null ? kanban.OwnerID : kcRequest.OwnerID);
			}
	
			// We can't perform linking on milestone if board is not UberBoard.
			if (!(kanban.RecordType.Name == 'MileStoneCard' && kanban.leankor__BoardType__c != 'UberBoard')) {					
				if (String.isNotBlank(kcRequest.leankor__ValueStreamCardLink__c) && linkedKanbanCardsMap.containsKey(kcRequest.leankor__ValueStreamCardLink__c)) {
					leankor__KanbanCard__c linkedCard = linkedKanbanCardsMap.get(kcRequest.leankor__ValueStreamCardLink__c);
					kanban.leankor__ValueStreamCardLink__c = kcRequest.leankor__ValueStreamCardLink__c;
					kanban.leankor__ValueStreamLink__c = linkedCard.leankor__ValueStream__c;
					
					if (linkedCard.RecordType.Name == 'FolderCard' && scheduledChangeFlag) {
						folderCards.add(kanban.leankor__ValueStreamCardLink__c);
					}
				} else if (String.isBlank(kcRequest.leankor__ValueStreamCardLink__c) && String.isNotBlank(kcRequest.leankor__ValueStreamLink__c)) {
					kanban.leankor__ValueStreamCardLink__c = null;
					kanban.leankor__ValueStreamLink__c = kcRequest.leankor__ValueStreamLink__c;
				} else if (String.isNotBlank(kcRequest.leankor__ValueStreamCardLink__c) && String.isNotBlank(kcRequest.leankor__ValueStreamLink__c)) {
					kanban.leankor__ValueStreamCardLink__c = kcRequest.leankor__ValueStreamCardLink__c;
					kanban.leankor__ValueStreamLink__c = kcRequest.leankor__ValueStreamLink__c;
				}
			}

			// If updated card has a new link to a card, updatedCardLinkFlag and scheduledChangeFlag are set to true
			if (String.isNotBlank(kanban.leankor__ValueStreamCardLink__c) && String.isNotBlank(kanban.leankor__ValueStreamLink__c)) {
				updatedCardLinkFlag = true;
				scheduledChangeFlag = true;
			}

			// If card have parent the we have to make leankor__IsScheduleRecalculate__c for parent. 
			if (kanban.leankor__ValueStreamCardLink__r.RecordType.Name == 'FolderCard' && scheduledChangeFlag) {
				folderCards.add(kanban.leankor__ValueStreamCardLink__c);
			}

			kanban.leankor__EffortRemaining__c = integer.valueof(kcRequest.leankor__EffortRemaining__c == null ? kanban.leankor__EffortRemaining__c : kcRequest.leankor__EffortRemaining__c);                  
			kanban.leankor__Priority__c = (kcRequest.leankor__Priority__c == null ? Integer.ValueOf(kanban.leankor__Priority__c) : Integer.ValueOf(kcRequest.leankor__Priority__c));                                              				
			kanban.leankor__Account__c = (kcRequest.leankor__Account__c == null ? kanban.leankor__Account__c : kcRequest.leankor__Account__c );
			kanban.leankor__Opportunity__c= (kcRequest.leankor__Opportunity__c == null ? kanban.leankor__Opportunity__c : kcRequest.leankor__Opportunity__c );
			kanban.leankor__Contact__c = (kcRequest.leankor__Contact__c == null ? kanban.leankor__Contact__c : kcRequest.leankor__Contact__c);
			kanban.leankor__Case__c = (kcRequest.leankor__Case__c == null ? kanban.leankor__Case__c : kcRequest.leankor__Case__c);
			kanban.leankor__Order__c = (kcRequest.leankor__Order__c == null ? (kanban.leankor__Order__c == null ? 0 : kanban.leankor__Order__c )  : kcRequest.leankor__Order__c);
			kanban.leankor__OnBudget__c = (kcRequest.leankor__OnBudget__c == null ? (kanban.leankor__OnBudget__c == null ? 'Green' : kanban.leankor__OnBudget__c ) :  String.valueOf(kcRequest.leankor__OnBudget__c));
			kanban.leankor__OnQuality__c = (kcRequest.leankor__OnQuality__c == null ? (kanban.leankor__OnQuality__c == null ? 'Green' : kanban.leankor__OnQuality__c ) : String.valueOf(kcRequest.leankor__OnQuality__c));
			kanban.leankor__OnTime__c = (kcRequest.leankor__OnTime__c == null ? (kanban.leankor__OnTime__c == null ?'Green' : kanban.leankor__OnTime__c )  :  String.valueOf(kcRequest.leankor__OnTime__c) );                
			kanban.leankor__UrlLink__c  = String.isEmpty(kcRequest.leankor__UrlLink__c) ? kanban.leankor__UrlLink__c : kcRequest.leankor__UrlLink__c;                                                         
			kanban.Name = kcRequest.Name == null ? kanban.Name : kcRequest.Name;

			// Updating Harveyball Status and Percent Completion.
			if (kcRequest.leankor__HarveyBallDoneDate__c != null) {
				kanban.leankor__HarveyBallDoneDate__c = kcRequest.leankor__HarveyBallDoneDate__c;
			} else {
				kanban.leankor__HarveyBallDoneDate__c = (Integer.valueOf(kanban.leankor__PercentComplete2__c) != Integer.valueOf(kcRequest.leankor__PercentComplete2__c) && kcRequest.leankor__PercentComplete2__c == 100) ? System.today() :  kanban.leankor__HarveyBallDoneDate__c;
			} 
			if (kcRequest.leankor__PromiseCompletionDate__c != null) {
				kanban.leankor__PromiseCompletionDate__c = kcRequest.leankor__PromiseCompletionDate__c;
			} else {
				kanban.leankor__PromiseCompletionDate__c = (Integer.valueOf(kanban.leankor__PercentComplete2__c) != Integer.valueOf(kcRequest.leankor__PercentComplete2__c) && kcRequest.leankor__PercentComplete2__c == 100) ? System.now() :  kanban.leankor__PromiseCompletionDate__c;
			} 

			// In case of folder card we don't need to update leankor__PercentComplete__c field 
			kanban.leankor__PercentComplete2__c = kcRequest.leankor__PercentComplete2__c == null || kanban.RecordType.Name == 'FolderCard' ? kanban.leankor__PercentComplete2__c : kcRequest.leankor__PercentComplete2__c;

			if (scheduledChangeFlag && (kanban.leankor__PredecessorDependencies__r.size() > 0)) {
				kanban.leankor__IsSuccessorRecalculate__c = true;
			}

			valueStreamIds.add(kanban.leankor__ValueStream__c);

			if (kanban.leankor__StartDateTime__c != oldStartDateTIme 
					|| kanban.leankor__DueDateTime__c != oldDueDateTIme 
					|| kanban.leankor__EstimatedDuration__c != oldEstimatedDuration
					|| kanban.leankor__DurationUnits__c != oldDurationUnits
			) {
					
					kanban.leankor__IsConstraintRecalculate__c = true;
					if (String.isNotBlank(kanban.leankor__ValueStreamCardLink__c)) {
						if (kanban.leankor__ValueStreamLink__r.leankor__BoardType__c == 'UberBoard' 
						|| kanban.leankor__ValueStreamLink__r.leankor__BoardType__c == 'Plan Board') {
							realTimeController.linkParentCardIds.add(kanban.leankor__ValueStreamCardLink__c);

						}
					}
			}		


			updateKCList.add(kanban);
			kanbanIds.add(kanban.id);
			broadcastingBoardIds.add(kanban.leankor__ValueStream__c);

			// Add to list of cards with changed dates if schedule being changed 
			if (scheduledChangeFlag == true && (kanban.RecordType.Name == 'MileStoneCard' || kanban.RecordType.Name == 'ActivityCard')) {
				changedDatesCards.add(kanban);
			}

		} // End of sObject loop
		
		// Clear the values that we did't needed anymore.
		request.kanbancardList.clear();
		KanbanCardMap.clear();
		workWeekMap.clear();
		linkedKanbanCardsMap.clear();
		miniatureMap.clear();

		KanbanController.KanbanCardConstraintViolation constraintsViolated = new KanbanController.KanbanCardConstraintViolation();
		// Calls to check if any card updated violates any constraints
		if (!changedDatesCards.isEmpty()) {
			constraintsViolated = UpdateKanbanCard.checkConstraintValidation(changedDatesCards, updatedCardLinkFlag);
		}

		if (!constraintsViolated.isEmpty()) {
			createProjectEvent(request.projectId, request.projectEventCustomPayload, JSON.serialize(constraintsViolated));	
		} else {

			Savepoint sp = Database.setSavepoint();
			try {
				// Update Resource Assignment when owner of card will be change.
				if (resourceAssignmentList.size() > 0) {
					Update resourceAssignmentList;
				}

				if (scheduledChangeFlag) {
					// Making the IsScheduleRecalculate of the ValueStream to TRUE.
					UpdateKanbanCard.updateValueStream(valueStreamIds);	
				}

                if (folderCards.size() > 0) {
				    // Make leankor__IsSuccessorRecalculate__c = true for folder cards
					RealTimeController.updateIsSuccessorRecalculate(folderCards);
				}
				
				valueStreamIds.clear();
				
				/* RK - 01/27/2021 - Changes : With the constraint feature now we are creating schedule mode record for all record types 
													so, now no need to delete/create schedule mode record whrd record type are changed. */
		
				// Create Schedule mode 
				/*if (UpdateKanbanCard.createScheduleModeIds.size() > 0) {
					UpdateKanbanCard.createScheduleMode(UpdateKanbanCard.createScheduleModeIds);
				}

				// Delete schedule mode
				if (UpdateKanbanCard.deleteScheduleModeIds.size() > 0) {
					UpdateKanbanCard.deleteScheduleModes(UpdateKanbanCard.deleteScheduleModeIds);
				}*/
				
				RealtimeController.bulkStreaming stream = new RealtimeController.bulkStreaming();
				stream.verb = 'UpdateKanbanCards';
				stream.sessionID = UserInfo.getSessionId();
				stream.kanbansObjectList = updateKCList;
				//Calling manageBulkStreaming to update the KC records
				realtimeController.manageBulkStreaming(stream, true);
				updateKCList.clear();
				if (request.sendBroadcastMessage == true) {
					if (kanbanIds.size() <= BROADCAST_REQUEST_LIMIT) {
						for (String valueStreamId : broadcastingBoardIds) {
							RealtimeController.bulkStreaming tempStreaming = new RealtimeController.bulkStreaming();
							RealtimeController.DirectLinkCardLog tempLog = new RealtimeController.DirectLinkCardLog();
							tempLog.cardIds = kanbanIds;
							tempLog.ValueStreamID = valueStreamId;
							templog.multipleAPIName = 'MultipleUpdate';

							tempStreaming.VSID = valueStreamId;
							tempStreaming.Verb = 'ManageAffectedCards';
							tempStreaming.SessionID = UserInfo.getSessionId();
							tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
							
							bulkStreams.add(tempStreaming);
						}            
						RealtimeController.sendBroadCast(bulkStreams, 'ManageAffectedCards');
					} else {
						broadcastContentMap.put('', new List<String>(broadcastingBoardIds));
						GenericStreamingController.sendBroadcastForBulkRecords('ManageBulkCards', broadcastContentMap, UserInfo.getSessionId());
					}                               
				}
				
				//------------------- BEGIN platform event broadcast
				// Calls method to create and publish Project Event for updaing cards
				//createProjectEvent(request.projectId, request.projectEventCustomPayload, JSON.serialize(kanbanIds));
				//------------------- END platform event broadcast
			} catch (Exception ex) {
				Database.rollback(sp);
				throw new Util.LeanException('ERROR:' + ex.getMessage());
			}	
			//Pratiksha : 13/Sep/2023 : We have moved this method in Another try/Catch block.
			createProjectEvent(request.projectId, request.projectEventCustomPayload, JSON.serialize(kanbanIds));
		}
	}

	private static void createProjectEvent(String projectId, String customPayload, String jsonPayload) {
		//Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
		try {
			if (String.isNotBlank(projectId) && Util.getSObjectName(projectId) == 'leankor__ProjectRoom__c') {
				leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
				projectEvent.leankor__ProjectID__c = projectId;
				projectEvent.leankor__UserID__c = UserInfo.getUserId();
				projectEvent.leankor__IsAPIGenerated__c = true;
				projectEvent.leankor__EventCategory__c = 'Updating';
				projectEvent.leankor__EventName__c = 'EndUpdateWorkItem';
				projectEvent.leankor__CustomPayload__c = customPayload;
				projectEvent.leankor__JSONPayload__c = jsonPayload;

				// Call method to publish events
				Database.SaveResult saveResult = EventBus.publish(projectEvent);
				// quick error processing, no need to Rollback
				if (!saveResult.isSuccess()) {
					for (Database.Error error : saveResult.getErrors()) {
						System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
					}
					// continue on because a failed platform event is no big deal ; do NOT rollback
				}
			}
		} catch (Exception ex) {
			System.debug('ERROR :: '+ex.getMessage());
		}	
	}	
}