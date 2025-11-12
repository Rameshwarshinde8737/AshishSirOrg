/**
 * Company : Leankor
 * FILE : CreateKanbanCardsQueueable.cls
 * CLASS : CreateKanbanCardsQueueable
 * USAGE : Create kanbanCards Records.
 */

public with sharing class CreateKanbanCardsQueueable implements Queueable { 
	
	public static final Integer BROADCAST_REQUEST_LIMIT = 40;

    // We are not updating leankor__IsSuccessorRecalculate__c for parent folder at updateParentCards(). So we have to do that here.
	private static Set<String> folderCards = new Set<String>();
	public static List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();

	private MultipleCreateKanbanCardAction.KanbanCardRequest request;
	// This variable will manage calling of queueables in execute method, if true then will call for create required records and if false then will create remaining records for Kanaban cards. 
	private Boolean isFirstCallToCreate = false;
	public static List<RealTimeController.ZoneKanbanAction> zoneKanbanActions = new List<RealTimeController.ZoneKanbanAction>();
	public static List<Id> kanbancardLinkIds = new List<Id>();

	public List<RealTimeController.ZoneKanbanAction> tempZoneKanbanActions = new List<RealTimeController.ZoneKanbanAction>();
	public List<Id> tempKanbancardLinkIds = new List<Id>();

	private Set<String> valueStreamIds;

	// Parameterized Constructor to initialize kanbancards records. 
	public CreateKanbanCardsQueueable(MultipleCreateKanbanCardAction.KanbanCardRequest request, Boolean isFirstCallToCreate) {
		this.request = request;
		this.isFirstCallToCreate = isFirstCallToCreate;
	}

	// Parameterized Constructor to initialize remaining records to second queueable call. 
	public CreateKanbanCardsQueueable(List<RealTimeController.ZoneKanbanAction> zoneKanbanActions, List<Id> kanbancardLinkIds, Set<String> valueStreamIds, MultipleCreateKanbanCardAction.KanbanCardRequest request) {
		this.request = request;
		this.valueStreamIds = valueStreamIds;
		this.tempZoneKanbanActions = zoneKanbanActions;
		this.tempKanbancardLinkIds = kanbancardLinkIds;
	}

	public void execute(QueueableContext context) {
		
		if (this.isFirstCallToCreate) {
			// created required records for kanban cards.
			RealTimeController.isCalledAPI = true;
			createKanbanCard(this.request);
			
		} else {
			if (request.generateWorkBreakdownStructure == true) {
				updateProjectWBS(valueStreamIds);
			}

			// created remaining records for kanban cards. 
			createRemainingRecords(this.tempZoneKanbanActions, this.tempKanbancardLinkIds);
		}
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to create bulk kanban cards. 
    Inputs:         Object of MultipleCreateKanbanCardAction.KanbanCardRequest class.
    Returns:        List of Kanban Card.
    ------------------------------------------------------------*/
	public static List<leankor__KanbanCard__c> createKanbanCard(MultipleCreateKanbanCardAction.KanbanCardRequest request) {
		UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
		Set<String> boardIds = new Set<String>();
		Set<String> ownerIds = new Set<String>();  
		Set<String> linkedCardIds = new Set<String>();
		Map<Id, List<leankor__Zone__c>> vsZoneMap;
		Map<Id, leankor__KanbanCard__c> linkedCardMap;
		Map<String, leankor__KanbanCardTemplate__c> kanbanTemplateMap;
		Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackoutMap;
		Map<String, Integer> cardOrderMap = new Map <String,Integer>();
		Map<String, leankor__ValueStream__c> boardMap = new Map<String, leankor__ValueStream__c>();
		Map<Id, Util.WorkWeek> workWeekMap = new Map<Id, Util.WorkWeek>();
		List<leankor__KanbanCard__c> newKanbanCardList = new List<leankor__KanbanCard__c>();
		List<RealTimeController.Kanban> kanbanList = new List<RealTimeController.Kanban>();

		RealTimeController.flowWithGSForAPI = true;
		String projectId;
		String projectEventCustomPayload;
		Map<String, List<String>> broadcastContentMap =  new Map<String, List<String>>();
		Set<String> broadcastingBoardIds = new Set<String>();
		List<Id> kanbanCardIds = new List<Id>();

		// used for broadcast.
		List<RealTimeController.bulkStreaming> bulkStreams = new List<RealTimeController.bulkStreaming>();

		for (leankor__KanbanCard__c kanban : request.kanbanCardRequests) {
			if (String.isNotBlank(kanban.leankor__ValueStream__c)) { 
				boardIds.add(kanban.leankor__ValueStream__c); 
			}	
			if (String.isNotBlank(kanban.leankor__ValueStreamCardLink__c)) {
				linkedCardIds.add(kanban.leankor__ValueStreamCardLink__c);
			}
			ownerIds.add(kanban.OwnerID);	
		}

		if (String.isNotBlank(request.OwnerID)) {
			ownerIds.add(request.ownerID);
		}

		if (String.isNotBlank(request.ProjectBoardName)) {
			boardIds.add(request.projectBoardName);
		}

		if (String.isNotBlank(request.projectId)) {
			projectId = request.projectId;
		}

		if (String.isNotBlank(request.projectEventCustomPayload)) {
			projectEventCustomPayload = request.projectEventCustomPayload;
		}
		
		// Get Linked Card map
		linkedCardMap = CreateKanbanCard.getLinkedCardMap(linkedCardIds);
		// Get the value streams
		valueStreams = CreateKanbanCard.readProjectBoards(boardIds, boardMap, cardOrderMap);
		// Get the template map
		kanbanTemplateMap = CreateKanbanCard.readKanbanCardTemplates(boardIds);
		// Get the zone map
		vsZoneMap = CreateKanbanCard.getBoardZones(boardIds);
		// Get the blackout map 
		vsBlackoutMap = CreateKanbanCard.getBlackoutRecords(boardIds);
		// Create the work week instance for each valuestream
		Util.WorkWeek workWeek;

		for (String board : boardIds) {
			workWeek = new Util.WorkWeek(boardMap.get(board).leankor__SevenDayWorkWeek__c ? 7 : 5, vsBlackoutMap.get(board));
			workWeekMap.put(board, workWeek);
		}
		
		// Create the user map.
		Map <String, User> userMap = new Map<String, User>([Select Id, 
																IsActive, 
																Name 
															From User 
															Where (Id In: ownerIds
																And IsActive = :true)
															Limit 10000]);
		// Create the record type map
		Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([Select Id, 
																		Name 
																	From RecordType
																	Where SobjectType = 'leankor__KanbanCard__c' 
																	Limit 1000]);				
		
		Boolean addedLinkFlag;
		List<leankor__KanbanCard__c> addedLinkCards = new List<leankor__KanbanCard__c>();
															
		// Process the request
		//for (MultipleCreateKanbanCardAction.KanbanCardRequest request: kanbanCardRequest) {
		for (leankor__KanbanCard__c kanban : request.kanbanCardRequests) {
			addedLinkFlag = false;
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();

			RealTimeController.Kanban remoteKanban = new RealTimeController.Kanban();
			
			// Get the Value stream of the current KC
			leankor__ValueStream__c currentVS =  String.isNotBlank(kanban.leankor__ValueStream__c) && boardMap.containsKey(kanban.leankor__ValueStream__c)
										? boardMap.get(kanban.leankor__ValueStream__c)
										: (boardMap.containsKey(request.projectBoardName) ? boardMap.get(request.projectBoardName) : null);
			if (currentVS == null) {
				throw new Util.LeanException('No board found by Given Board name or Id');
			}

			remoteKanban.ID = ResourceGanttController.createGuid().replace('-','');
			remoteKanban.GUID = remoteKanban.ID;
			remoteKanban.CardID = (kanban.leankor__CardID__c == null ? '' :kanban.leankor__CardID__c);
			remoteKanban.Name = String.isNotBlank(kanban.Name) 
						? kanban.Name 
						:(String.isBlank(kanban.leankor__Title__c) ? (String.isNotBlank(request.title) ? request.title : '') :kanban.leankor__Title__c);
			remoteKanban.point = (kanban.leankor__Point__c==null?1 :kanban.leankor__Point__c);
			remoteKanban.Top = (kanban.leankor__Top__c == null ? 2100 : kanban.leankor__Top__c);
			remoteKanban.Bottom = (kanban.leankor__Bottom__c == null ? 0 : kanban.leankor__Bottom__c);
			remoteKanban.Left = (kanban.leankor__Left__c == null ? 2100 : kanban.leankor__Left__c);    
			remoteKanban.X = (kanban.leankor__X__c == null ? 0 :kanban.leankor__X__c);
			remoteKanban.Y = (kanban.leankor__Y__c == null ? 0 : kanban.leankor__Y__c);
			remoteKanban.ValueStream = currentVS.Id;

			// Assign the Kanban Template
			leankor__KanbanCardTemplate__c category = (String.isNotBlank(kanban.leankor__KanbanCardTemplate__c) && kanbanTemplateMap.containsKey(kanban.leankor__KanbanCardTemplate__c) &&  kanbanTemplateMap.get(kanban.leankor__KanbanCardTemplate__c).leankor__ValueStream__c == remoteKanban.ValueStream )
						? kanbanTemplateMap.get(kanban.leankor__KanbanCardTemplate__c) 
						: ( // Assign the category by template name or assign the default category
							kanbanTemplateMap.containsKey(remoteKanban.ValueStream+request.categoryName) 
							? kanbanTemplateMap.get(remoteKanban.ValueStream+request.categoryName)
							: kanbanTemplateMap.get(remoteKanban.ValueStream)
						); 
			remoteKanban.Title = (category.Name != null ? category.Name : request.categoryName);
			remoteKanban.Width = (category.leankor__Width__c == null ? 170 : category.leankor__Width__c);   
			remoteKanban.Height = (category.leankor__Height__c == null ? 85 : category.leankor__Height__c);
			remoteKanban.JSONDefinition = category.leankor__JSONDefinition__c;
			remoteKanban.JSONData = category.leankor__JSONData__c; 
			remoteKanban.TemplateID = category.Id;
			remoteKanban.Color = category.leankor__Color__c; 
			// If name is blank then assign the title of the card into name.   
			remoteKanban.Name = String.isBlank(remoteKanban.Name) ? remoteKanban.Title : remoteKanban.Name;
			remoteKanban.Description = (kanban.leankor__DescriptionLong__c == null ? '' : kanban.leankor__DescriptionLong__c);
			remoteKanban.DurationUnits = (kanban.leankor__DurationUnits__c == null ? 'Days' : String.valueOf(kanban.leankor__DurationUnits__c));

			// Set ED, Dates and RecordType for the KC
			CreateKanbanCard.createKanbanCardHelper(remoteKanban, kanban, currentVS, recordTypeMap, workWeekMap.get(currentVS.Id));
			
			remoteKanban.Priority = integer.valueOf((kanban.leankor__Priority__c == null ? 4 : kanban.leankor__Priority__c));
			remoteKanban.OwnerID = String.isNotBlank(kanban.OwnerID) && userMap.containsKey(kanban.OwnerID) 
								? kanban.OwnerID 
								: String.isNotBlank(request.OwnerID) && userMap.containsKey(request.OwnerID) ? request.OwnerID : UserInfo.getUserId(); 
				remoteKanban.HarveyBall =  Kanban.leankor__PercentComplete2__c ==null ? '0' : String.valueOf(Kanban.leankor__PercentComplete2__c.intValue());
				
				// Link the card	
				if (currentVS.leankor__BoardType__c != 'UberBoard' && remoteKanban.ItemType == 'MileStoneCard') {
					remoteKanban.ValueStreamCardLink = '';
					remoteKanban.ValueStreamLinkID = '';
				} else if (String.isNotBlank(kanban.leankor__ValueStreamCardLink__c) && linkedCardMap.containsKey(kanban.leankor__ValueStreamCardLink__c)) {
					leankor__KanbanCard__c linkedCard = linkedCardMap.get(kanban.leankor__ValueStreamCardLink__c);
					if (currentVS.leankor__BoardType__c == 'UberBoard' && linkedCard.RecordType.Name == 'FolderCard' && currentVS.Id == linkedCard.leankor__ValueStream__c) {
						remoteKanban.ValueStreamCardLink = kanban.leankor__ValueStreamCardLink__c;
						remoteKanban.ValueStreamLinkID = linkedCard.leankor__ValueStream__c;
						folderCards.add(linkedCard.Id);
					} else if (currentVS.leankor__BoardType__c != 'UberBoard' && linkedCard.RecordType.Name != 'FolderCard' && !(linkedCard.leankor__BoardType__c != 'UberBoard' && linkedCard.RecordType.Name == 'MileStoneCard')) {
						remoteKanban.ValueStreamCardLink = kanban.leankor__ValueStreamCardLink__c;
						remoteKanban.ValueStreamLinkID = linkedCard.leankor__ValueStream__c;
					}
				} else if (String.isBlank(kanban.leankor__ValueStreamCardLink__c) && String.isNotBlank(kanban.leankor__ValueStreamLink__c)) {
					remoteKanban.ValueStreamCardLink = '';
					remoteKanban.ValueStreamLinkID = kanban.leankor__ValueStreamLink__c;
				}

				// If card created has a link to a card, a kanban card object is created and added to a list to be passed to check for constraint violation
				if (String.isNotBlank(remoteKanban.ValueStreamCardLink) && String.isNotBlank(remoteKanban.ValueStreamLinkID)) {
					addedLinkFlag = true;
					kanbanCard.Name = remoteKanban.Name;
					kanbanCard.leankor__ValueStream__c = currentVS.Id;
					kanbanCard.leankor__StartDateTime__c = remoteKanban.StartDate;
					kanbanCard.leankor__DueDateTime__c = remoteKanban.DueDate;
					kanbanCard.leankor__EstimatedDuration__c = remoteKanban.EstimatedDuration;
					kanbanCard.leankor__ValueStreamLink__c = remoteKanban.ValueStreamLinkID;
					kanbanCard.leankor__ValueStreamCardLink__c = remoteKanban.ValueStreamCardLink;
					addedLinkCards.add(kanbanCard); 
				} 

				remoteKanban.Account = (kanban.leankor__Account__c == null ? '' : kanban.leankor__Account__c );
				remoteKanban.Opportunity = (kanban.leankor__Opportunity__c == null ? '' : kanban.leankor__Opportunity__c );
				remoteKanban.Contact = (kanban.leankor__Contact__c == null ? '' : kanban.leankor__Contact__c);
				remoteKanban.CaseID = (kanban.leankor__Case__c == null ? '' : kanban.leankor__Case__c);
				// Assigned the order and put the next value for next card for same value stream
				remoteKanban.Order = ((kanban.leankor__Order__c != null && kanban.leankor__Order__c > 0) || RealTimeController.isCalledAPI == false) ? kanban.leankor__Order__c : cardOrderMap.get(remoteKanban.ValueStream)+2; 
			cardOrderMap.put(remoteKanban.ValueStream, (cardOrderMap.get(remoteKanban.ValueStream)+1));			
			remoteKanban.OnBudget = (kanban.leankor__OnBudget__c == null ? 'Green' :  String.valueOf(kanban.leankor__OnBudget__c));
			remoteKanban.OnQuality = (kanban.leankor__OnQuality__c == null ? 'Green' : String.valueOf(kanban.leankor__OnQuality__c));
			remoteKanban.OnTime = (kanban.leankor__OnTime__c == null ? 'Green' :  String.valueOf(kanban.leankor__OnTime__c));
			remoteKanban.UrlLink = kanban.leankor__UrlLink__c == null ? '': kanban.leankor__UrlLink__c;

			// Assign the zone of a card.
			if (vsZoneMap.get(remoteKanban.ValueStream) != null && (currentVS.leankor__BoardType__c == 'Kanban Board' || currentVS.leankor__BoardType__c == 'Plan Board')) {
				leankor__Zone__c zone = CreateKanbanCardAction.processZoneForCard(kanban, vsZoneMap.get(remoteKanban.ValueStream));
				remoteKanban.ZoneID =  zone.leankor__GUID__c ;
				remoteKanban.ZoneForceID =  zone.ID ;
				remoteKanban.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
				remoteKanban.SWForceID = zone.leankor__Swimlane__c ;
			}
			
			remoteKanban.BoardType = currentVS.leankor__BoardType__c;
			remoteKanban.autoAssignResource = currentVS.leankor__ProjectRoom__r.leankor__AutoAssignResource__c;	
			remoteKanban.AcceptanceCriteria =(kanban.leankor__AcceptanceCriteria__c==null ?'' :kanban.leankor__AcceptanceCriteria__c) ;
			remoteKanban.flowWithGS = true;  
			remoteKanban.HarveyBallDoneDate = (kanban.leankor__HarveyBallDoneDate__c != null)?(kanban.leankor__HarveyBallDoneDate__c) :(remoteKanban.HarveyBall == '100' ? System.today() : kanban.leankor__HarveyBallDoneDate__c);
			remoteKanban.PromiseCompletionDate =(kanban.leankor__PromiseCompletionDate__c != null)?(kanban.leankor__PromiseCompletionDate__c):(remoteKanban.HarveyBall == '100' ? System.now() : kanban.leankor__PromiseCompletionDate__c);			
			remoteKanban.ownerIsActive = userMap.containsKey(remoteKanban.OwnerID) ? userMap.get(remoteKanban.OwnerID).IsActive : true ;
			if (realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
				remoteKanban.isConstraintRecalculate = true;   
			}
			if (RealTimeController.isCalledAPI == false) {
				remoteKanban.Monday = kanban.leankor__Monday__c == null ? true : kanban.leankor__Monday__c;
                remoteKanban.Tuesday = kanban.leankor__Tuesday__c == null ? true : kanban.leankor__Tuesday__c;
                remoteKanban.Wednesday = kanban.leankor__Wednesday__c == null ? true : kanban.leankor__Wednesday__c;
                remoteKanban.Thursday = kanban.leankor__Thursday__c == null ? true : kanban.leankor__Thursday__c;
                remoteKanban.Friday = kanban.leankor__Friday__c == null ? true : kanban.leankor__Friday__c;
                remoteKanban.Saturday = kanban.leankor__Saturday__c == null ? true : kanban.leankor__Saturday__c;
                remoteKanban.Sunday = kanban.leankor__Sunday__c == null ? true : kanban.leankor__Sunday__c;
                remoteKanban.weekCalendar = String.isNotBlank(kanban.leankor__WeekCalendar__c) ? kanban.leankor__WeekCalendar__c : null;
			}
			// Assign the Resource and Schedule to new created Activity cards.
			CreateKanbanCard.createResourceAssignmentScheduleMode(remoteKanban);

			// Holding all kanban card in kanbanList.
			kanbanList.add(remoteKanban); 
		}
		
		request.kanbanCardRequests.clear();

		KanbanController.KanbanCardConstraintViolation constraintsViolated = new KanbanController.KanbanCardConstraintViolation();
		// Calls to check if any card created violates any constraints when adding a link to another card
		if (!addedLinkCards.isEmpty()) {
			constraintsViolated = CreateKanbanCard.checkConstraintValidation(addedLinkCards, addedLinkFlag);
		}

		if (!constraintsViolated.isEmpty()) {
			createProjectEvent(request.projectId, request.projectEventCustomPayload, JSON.serialize(constraintsViolated));
		} else {

			Savepoint sp = Database.setSavepoint();
			try {  	
				///Changes  - 08/12/2020 : Now we are chaining scheduled jobs in CreateKanbanCardsQueueable class.
				RealTimeController.flowWithGSForAPI = true;
				if (kanbanList.size() > 0) {
					// Create Kanban Cards.
					newKanbanCardList = RealTimeController.CreateKanbanCards('', kanbanList);
				}

				for (leankor__KanbanCard__c kanban : newKanbanCardList) { 
					broadcastingBoardIds.add(kanban.leankor__ValueStream__c);
					kanbanCardIds.add(kanban.Id);
				} 

				// updating IsSuccessorRecalculate of folder cards.
				RealTimeController.updateIsSuccessorRecalculate(folderCards);
				
				// Make the leankor__IsScheduleRecalculate__c to true for value stream.
				updateIsScheduleRecalculate(valueStreams);

				// Doing second queueable jobs to create remaining records.
				if (!Test.isRunningTest() && (!zoneKanbanActions.isEmpty() || !kanbancardLinkIds.isEmpty())) {
					System.enqueueJob(new CreateKanbanCardsQueueable(zoneKanbanActions, kanbancardLinkIds, broadcastingBoardIds, request));
				}

				if (request.sendBroadcastMessage == true) {
					
					if (kanbanCardIds.size() <= BROADCAST_REQUEST_LIMIT) {
						for (String valueStreamId : broadcastingBoardIds) {
							RealTimeController.bulkStreaming tempStreaming = new RealTimeController.bulkStreaming();
							RealTimeController.DirectLinkCardLog tempLog = new RealTimeController.DirectLinkCardLog();
							tempLog.cardIds = kanbanCardIds;
							tempLog.ValueStreamID = valueStreamId;
							tempLog.multipleAPIName = 'MultipleCreate';

							tempStreaming.VSID = valueStreamId;
							tempStreaming.Verb = 'ManageAffectedCards';
							tempStreaming.SessionID = UserInfo.getSessionId();
							tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
							bulkStreams.add(tempStreaming);
						}
					
						RealTimeController.sendBroadcast(bulkStreams, 'ManageAffectedCards');
					} else {
						broadcastContentMap.put('', new List<String>(broadcastingBoardIds));
						GenericStreamingController.sendBroadcastForBulkRecords('ManageBulkCards', broadcastContentMap, UserInfo.getSessionId());
					}
				}
		} catch(Exception e) {
				Database.rollback(sp);
				throw new Util.LeanException('ERROR:' + e.getMessage());
			}
			//Pratiksha : 13/Sep/2023 : We have moved this method in Another try/Catch block.
			createProjectEvent(request.projectId, request.projectEventCustomPayload, JSON.serialize(kanbanCardIds)); 
		}
		return newKanbanCardList;
	}


	@TestVisible
	private static void updateIsScheduleRecalculate(List<leankor__ValueStream__c> valueStreams) {
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		if (!valueStreamBehavior.isAccessible() ||
			!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');   
		}

		for (leankor__ValueStream__c vs : valueStreams) {
			vs.leankor__IsScheduleRecalculate__c = RealTimeController.isCalledAPI ? true : false;
		}
		try {
			Database.update(valueStreams);
		} catch (Exception exc) {
			throw exc;
        }
    }

	private static void createRemainingRecords(List<RealTimeController.ZoneKanbanAction> zoneKanbanActions, List<Id> kanbancardLinkIds) {
		
		// Perform long-running code
		RealTimeController.enterTheZoneBulkify(zoneKanbanActions);
		ProjectBoardCarousel.updateActivityPercentageComplete(kanbancardLinkIds);
	}

	private static void createProjectEvent(String projectId, String customPayload, String jsonPayload) {
		//Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
		try {
			if (String.isNotBlank(projectId) && Util.getSObjectName(projectId) == 'leankor__ProjectRoom__c') {
				leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
				projectEvent.leankor__ProjectID__c = projectId;
				projectEvent.leankor__UserID__c = UserInfo.getUserId();
				projectEvent.leankor__IsAPIGenerated__c = true;
				projectEvent.leankor__EventCategory__c = 'Creating';
				projectEvent.leankor__EventName__c = 'EndCreateWorkItem';
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
		} catch(Exception ex) {
			System.debug('ERROR :: '+ex.getMessage());
		}
	}


	public static void updateProjectWBS(Set<String> valueStreamIds) {
		if (!valueStreamIds.isEmpty()) {
			List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
			Map<Id, leankor__ValueStream__c> valueStreamMap;
			valueStreamMap = new Map<Id, leankor__ValueStream__c>([Select Id, 
																		leankor__BoardType__c 
																	From leankor__ValueStream__c 
																	Where Id In :valueStreamIds
																		And leankor__IsRecordDeleted__c = false
																	Limit 10000]);
			for (String valueStreamId : valueStreamIds) {
				if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) == 'leankor__ValueStream__c') {
					leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Id = valueStreamId, leankor__BoardType__c = valueStreamMap.get(valueStreamId).leankor__BoardType__c);
					valueStreams.add(valueStream);
				}
			}

			if (!valueStreams.isEmpty()) {
				List<MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest> requests = new List<MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest>();
				MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest request = new MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest();
				request.valueStreamRequests = valueStreams;
				request.syncProcess = false;
				requests.add(request);
				MultipleUpdateProjectWBSAction.updateProjectWBSProcess(requests);
			}
		}
	}
}