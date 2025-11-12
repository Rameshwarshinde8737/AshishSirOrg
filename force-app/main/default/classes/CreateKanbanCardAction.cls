/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateKanbanCardAction.cls
* CLASS: CreateKanbanCardAction
* USAGE: manages to Create Card .
*/

global with sharing class CreateKanbanCardAction {

	// We are not updating leankor__IsSuccessorRecalculate__c for parent folder at KCupdatePvcard so we have to do that here.
	private static Set<String> folderCards = new Set<String>();
	
    /*-------------------------------------------------------------------------------
	Company: 		Leankor
	Description: 	This is execute method for Invocable Method which contain defination on API calls.
	Inputs: 		List<KanbanCardRequest> requests
	Returns: 		List<KanbanCardResult> results
	--------------------------------------------------------------------------------*/
    @InvocableMethod
    global static List<KanbanCardResult> CreateKanbanCardProcess(List<KanbanCardRequest> requests) {
		 // Added Security code for sentize user Input(
		for (KanbanCardRequest createRequests : requests) {
			if ((String.isNotBlank(createRequests.ValueStreamCardLink) && Util.getSObjectName(createRequests.ValueStreamCardLink) != 'leankor__KanbanCard__c')
			|| (String.isNotBlank(createRequests.ValueStreamLinkID) && Util.getSObjectName(createRequests.ValueStreamLinkID) != 'leankor__ValueStream__c')
			/*|| (String.isNotBlank(createRequests.Account) && Util.getSObjectName(createRequests.Account) != 'Account')
			|| (String.isNotBlank(createRequests.Opportunity) && Util.getSObjectName(createRequests.Opportunity) != 'Opportunity')
			|| (String.isNotBlank(createRequests.Contact) && Util.getSObjectName(createRequests.Contact) != 'Contact')
			|| (String.isNotBlank(createRequests.CaseID) && Util.getSObjectName(createRequests.CaseID) != 'Case')
			|| (String.isNotBlank(createRequests.ZoneForceID) && Util.getSObjectName(createRequests.ZoneForceID) != 'leankor__Zone__c')
			|| (String.isNotBlank(createRequests.MCForceID) && Util.getSObjectName(createRequests.MCForceID) != 'leankor__MasterContainer__c')
			|| (String.isNotBlank(createRequests.SWForceID) && Util.getSObjectName(createRequests.SWForceID) != 'leankor__ValueStream__c')
			|| (String.isNotBlank(createRequests.LinkedBoardId) && Util.getSObjectName(createRequests.LinkedBoardId) != 'leankor__ValueStream__c')
			|| (String.isNotBlank(createRequests.LinkedCardId) && Util.getSObjectName(createRequests.LinkedCardId) != 'leankor__KanbanCard__c')*/
			){
				
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		List<KanbanCardResult> results = new List<KanbanCardResult>();
	    KanbanCardResult result = new KanbanCardResult();
		result.CreatedKanbanCardList = new List<leankor__KanbanCard__c>();

		List<KanbanCardRequest> kanbanCardRequestList = new List<KanbanCardRequest>();
		List<MultipleCreateKanbanCardAction.KanbanCardRequest> kanbanSobjectRequest = new List<MultipleCreateKanbanCardAction.KanbanCardRequest>();
    	List <leankor.realTimeController.bulkStreaming> someJSONLogList = new List <leankor.realTimeController.bulkStreaming>();	   	
    	List<leankor.RealTimeController.Kanban> createNewKanbanCardsList = new List<leankor.RealTimeController.Kanban>(); 
		List<leankor__KanbanCard__c>  kanbanCardList = new List<leankor__KanbanCard__c>(); 
		leankor.RealTimeController.flowWithGSForAPI = true;
		Set<String> valueStreamIds = new Set<String>();
		Boolean generateWorkBreakdownStructure;

        for (KanbanCardRequest request : requests) {
			// Separating the request based on sObject or normal.
			if (request.KanbanCardList == null) {
				kanbanCardRequestList.add(request);	
			} else {
				leankor.MultipleCreateKanbanCardAction.KanbanCardRequest requestInstance = new leankor.MultipleCreateKanbanCardAction.KanbanCardRequest();
				requestInstance.Title = request.Title;
				requestInstance.CategoryName = request.CategoryName;
				requestInstance.OwnerID = request.OwnerID;
				requestInstance.ProjectBoardName = request.ProjectBoardName;
				requestInstance.kanbanCardRequests = request.KanbanCardList;
				requestInstance.sendBroadcastMessage = true;
				kanbanSobjectRequest.add(requestInstance);
			}
			generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;
		}
		
		// Calling helper method
		if (kanbanCardRequestList.size() > 0) {
			createNewKanbanCardsList.addAll(createKanbanCard(kanbanCardRequestList)); 
		}

		// Calling the CreateKanbanCard.createKanbanCard method for sObject request
		if (kanbanSobjectRequest.size() > 0) {
			result.CreatedKanbanCardList.addAll(leankor.CreateKanbanCard.createKanbanCard(kanbanSobjectRequest));
		}
    	
		// Create the savepoint 
    	Savepoint sp = Database.setSavepoint();
    	try {  		
			if (createNewKanbanCardsList.size() > 0) {
    			List<realTimeController.Kanban> kanbanCards =new List<realTimeController.Kanban>();
				for (leankor.RealTimeController.Kanban remoteKanbanInstance : createNewKanbanCardsList) {
					if (remoteKanbanInstance.ItemType == 'ActivityCard' && (remoteKanbanInstance.BoardType != 'UberBoard' || remoteKanbanInstance.autoAssignResource)) {
						leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c (
														leankor__AssignedTo__c = remoteKanbanInstance.OwnerID,
														leankor__PercentAllocation__c = 100,
														leankor__PercentCompleted__c = Integer.valueof(remoteKanbanInstance.HarveyBall),
														leankor__CompletedDate__c = (Integer.valueof(remoteKanbanInstance.HarveyBall) == 100 ? remoteKanbanInstance.DueDate : null) 
													);			
						remoteKanbanInstance.resourceAssignmentList = new List<leankor__ResourceAssignment__c> {ra};  			
					}
					if (remoteKanbanInstance.ItemType == 'ActivityCard') {
						leankor__ScheduleMode__c sm = new leankor__ScheduleMode__c(OwnerId = remoteKanbanInstance.OwnerID);
						remoteKanbanInstance.schedulemodeList = new List<leankor__ScheduleMode__c>{sm};
					}
					kanbanCards.add(remoteKanbanInstance);
				}
			
				// Create the card
				kanbanCardList = leankor.RealTimeController.CreateKanbanCards('', kanbanCards);

				// Make leankor__IsSuccessorRecalculate__c = true for folder cards
				leankor.RealTimeController.updateIsSuccessorRecalculate(folderCards);

				for (leankor__KanbanCard__c kanban : kanbanCardList) { 
					leankor.RealTimeController.Kanban remoteKanbanNew = new leankor.RealTimeController.Kanban();
					remoteKanbanNew.Id= kanban.Id;
					remoteKanbanNew.ValueStreamCardLink = (kanban.leankor__ValueStreamCardLink__c == null ? '' : kanban.leankor__ValueStreamCardLink__c);
					remoteKanbanNew.ValueStreamLinkID = (kanban.leankor__ValueStreamLink__c == null ? '' : kanban.leankor__ValueStreamLink__c);
					remoteKanbanNew.ValueStream = kanban.leankor__ValueStream__c == null?'':kanban.leankor__ValueStream__c;
					remoteKanbanNew.flowWithGS = true;

					leankor.realTimeController.bulkStreaming someJSONLog = new leankor.realTimeController.bulkStreaming();    
					someJSONLog.SomeJSONData = JSON.Serialize(remoteKanbanNew);
					someJSONLog.VSID = kanban.leankor__ValueStream__c;
					someJSONLog.Verb = 'CreateKanbanCard';
					someJSONLog.SessionID = UserInfo.getSessionId(); 
					someJSONLogList.add(someJSONLog);
					// Add the new created card into result instance.
					result.KanbanCardId = kanban.Id;
					valueStreamIds.add(kanban.leankor__ValueStream__c);
					result.CreatedKanbanCardList.add(kanban);
				}

        		results.add(result); 

				if (generateWorkBreakdownStructure == true) {
					CreateKanbanCardsQueueable.updateProjectWBS(valueStreamIds);
				}
				
				// Tilak Raj Mahale:08.06.2020 -Calling new method to send broadcast.
				leankor.realtimeController.sendBroadcast(someJSONLogList, 'CreateKanbanCard');
			}

			return results;
    	} catch(Exception e) {
    		Database.rollback(sp);
			throw new Util.LeanException('ERROR:' + e.getMessage());
    	}
	}    
	
    
    public static List<leankor.RealTimeController.Kanban> createKanbanCard(List<KanbanCardRequest> requests) {
		UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
		Set<Id> requestBoardIds = new Set<Id>();
		Set<String> requestLinkedNames = new Set<String>();
		Set<String> requestLinkedIds = new Set<String>();
		Set<String> requestCardCategory = new Set<String>();
    	Set<String> requestMCNames = new Set<String>();
		Set<String> requestProjectBoardNames = new Set<String>();	
		Set<Id> boardIdSet = new Set<Id> ();
		List<string> ownerIds = new List<string>();	
		List<leankor.RealTimeController.Kanban> kanbanCardList = new List<leankor.RealTimeController.Kanban>();  
		List<leankor__ValueStream__c> projectBoardList = new List<leankor__ValueStream__c> ();
	    List <leankor__KanbanCard__c> linkedCardList = new List <leankor__KanbanCard__c>();
		Map<String, leankor__ValueStream__c> projectBoardIdMap = new Map <String, leankor__ValueStream__c>();  
		Map<String, List<leankor__ValueStream__c>> projectBoardNameMap = new Map <String, List<leankor__ValueStream__c>>(); 
		Map<String, List<leankor__Kanbancard__c>> linkedCardNameMap = new Map <String, List<leankor__Kanbancard__c>>();
		Map<String, leankor__Kanbancard__c> linkedCardIdMap = new Map <String, leankor__Kanbancard__c>(); 
		Map<Id, List<leankor__Zone__c>> vsZoneMap = new Map <Id, List<leankor__Zone__c>>();     
		Map<String, leankor__KanbanCardTemplate__c> kanbanTemplateMap = new Map <String, leankor__KanbanCardTemplate__c>();    
		Map<Id, List<leankor__ProjectScheduleBlackout__c>> blackOutMap = new Map<Id, List<leankor__ProjectScheduleBlackout__c>>(); 

    	try {
	    	for (KanbanCardRequest request : requests) {
				if (String.isNotBlank(request.CategoryName)) { 
					requestCardCategory.add(request.CategoryName);
	    		}
				if (String.isNotBlank(request.ProjectBoardName)) { 
					requestProjectBoardNames.add(request.ProjectBoardName);
				}
				if (String.isNotBlank(request.ProjectBoardId)) { 
					requestBoardIds.add(request.ProjectBoardId); 
				}
				if (String.isNotBlank(request.LinkedCardName)) { 
					requestLinkedNames.add(request.LinkedCardName);
				}	
	    		if (String.isNotBlank(request.LinkedBoardName)) { 
	    			requestLinkedNames.add(request.LinkedBoardName);
	    		}	
	    		if (String.isNotBlank(request.LinkedRoomName)) { 
	    			requestLinkedNames.add(request.LinkedRoomName);
	    		}
	    		if (String.isNotBlank(request.LinkedFolderName)) { 
	    			requestLinkedNames.add(request.LinkedFolderName);
	    		}
	    		if (String.isNotBlank(request.MCName)) { 
	    			requestMCNames.add(request.MCName);
	    		}
	    		if (String.isNotBlank(request.LinkedBoardId)) { 
	    			requestLinkedIds.add(request.LinkedBoardId);
	    		}
	    		if (String.isNotBlank(request.LinkedCardId)) { 
	    			requestLinkedIds.add(request.LinkedCardId);
	    		}	  	    		
	    		ownerIds.add(request.OwnerID);	    			  	    		
			}
			
	    	// Get the user data
			Map<String, User> userData = new Map<String, User>([Select Id,
																		IsActive,
																		Name 
																	From User 
																	Where Id In: ownerIds]);
			
			// Get the value stream maps
			getValueStreamMap(requestBoardIds, requestProjectBoardNames, projectBoardIdMap, projectBoardNameMap);	
	    
			// Get VS => leankor__KanbanCardTemplate__c map  
            for (leankor__KanbanCardTemplate__c template : readKanbanCardTemplate(requestBoardIds)) {				
				// Here key is made of (valueStreamId+Name). Case when card are create on same board with different category.											
		    	kanbanTemplateMap.put(template.leankor__ValueStream__c + template.Name, template);
				if (!kanbanTemplateMap.containsKey(template.leankor__ValueStream__c)) {
					// For assigning default category of that board.
					kanbanTemplateMap.put(template.leankor__ValueStream__c, template); 
				}				
			}	
			
			// Get linked card map
			getLinkedCardMap(requestLinkedNames, requestLinkedIds, linkedCardIdMap, linkedCardNameMap);

			// Get the VS => ZoneList map
			vsZoneMap = getVsZoneMap(requestBoardIds);
    
			// Get the blackout records
			blackOutMap = leankor.RealTimeControllerHelper.getBlackOutRecords(requestBoardIds);

			Boolean addedLinkFlag;
			List<leankor__KanbanCard__c> addedLinkCards = new List<leankor__KanbanCard__c>();

			// Process the request			
	    	for (KanbanCardRequest request : requests) {
				addedLinkFlag = false;
				leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();

				leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban(); 
				
				// Get the Value stream of the current KC
				leankor__ValueStream__c currentVS = getCurrentValueStream(request, projectBoardIdMap, projectBoardNameMap);  
				
				String strGUID = ResourceGanttController.createGuid().replace('-','');
				remoteKanban.GUID = strGUID;
				remoteKanban.ID = strGUID;
				remoteKanban.CardID = (request.CardID==null?'':request.CardID);
				remoteKanban.Name = request.Title;
				remoteKanban.point = (request.Point==null?1 :request.Point);
				remoteKanban.Top = (request.Top == null ? 2100 : request.Top);
				remoteKanban.Bottom = (request.Bottom == null ? 0 : request.Bottom);
				remoteKanban.Left = (request.Left == null ? 2100 : request.Left);    
				remoteKanban.X = (request.X == null ? 0 :request.X);
				remoteKanban.Y = (request.Y == null ? 0 : request.Y);
				remoteKanban.Description = (request.Description == null ? '' : request.Description.unescapeHtml4());
				remoteKanban.BoardType = currentVS.leankor__BoardType__c;
				remoteKanban.AutoAssignResource = currentVS.leankor__ProjectRoom__r.leankor__AutoAssignResource__c;
				remoteKanban.DurationUnits = (request.DurationUnits == null ? 'Days' : request.DurationUnits);
				remoteKanban.ValueStream = currentVS.Id;

				// Assign the selected Kanban Template
				leankor__KanbanCardTemplate__c category = kanbanTemplateMap.containsKey(currentVS.Id + request.CategoryName) ? kanbanTemplateMap.get(currentVS.Id + request.CategoryName) : kanbanTemplateMap.get(currentVS.Id);										
		        remoteKanban.Title = (category.Name == null ? request.CategoryName : category.Name);
				remoteKanban.Width = (category.leankor__Width__c == null ? 170 : category.leankor__Width__c); 
				remoteKanban.Height = (category.leankor__Height__c == null ? 85 : category.leankor__Height__c); 
				remoteKanban.JSONDefinition = category.leankor__JSONDefinition__c;
				remoteKanban.JSONData = category.leankor__JSONData__c;
		        remoteKanban.TemplateID = category.Id;
		        remoteKanban.Color = category.leankor__Color__c;
				
				// Create the work week instance
				Util.WorkWeek workWeek = new Util.WorkWeek(currentVS.leankor__SevenDayWorkWeek__c ? 7 : 5, blackOutMap.get(currentVS.Id));

				// Set ED, Dates and RecordType for the KC
				createKanbanCardHelper(remoteKanban, request, currentVS, workWeek);

		        remoteKanban.Priority = (request.Priority == null ? 4 : request.Priority);
				remoteKanban.OwnerID = userData.containsKey(request.OwnerID) ? request.OwnerID : UserInfo.getUserId();
		        remoteKanban.HarveyBall = (request.HarveyBall == null ? '0':String.ValueOf(request.HarveyBall));
				remoteKanban.Account = (request.Account == null ? '' : request.Account );
				remoteKanban.Opportunity = (request.Opportunity == null ? '' : request.Opportunity);
				remoteKanban.Contact = (request.Contact == null ? '' : request.Contact);
				remoteKanban.CaseID = (request.CaseId == null ? '' : request.CaseId);
				remoteKanban.Order = request.Order != null ? request.Order :currentVS.leankor__Kanbans__r.size() + 2;
				remoteKanban.OnBudget = (request.OnBudget == null ? 'Green' :  request.OnBudget);
				remoteKanban.OnQuality = (request.OnQuality == null ? 'Green' :  request.OnQuality);
				remoteKanban.OnTime = (request.OnTime == null ? 'Green' :  request.OnTime);
				remoteKanban.UrlLink = request.UrlLink;
				remoteKanban.AcceptanceCriteria =(request.AcceptanceCriteria==null ? '' :request.AcceptanceCriteria);
				remoteKanban.flowWithGS = true;              
				remoteKanban.OwnerIsActive = userData.containsKey(request.OwnerId) ? userData.get(request.OwnerId).IsActive : true;
				
				// Process the linking on the card
				processLinkingOnTheCard(remoteKanban, request, linkedCardIdMap, linkedCardNameMap);

				// If card created has a link to a card, a kanban card object is created and added to a list to be passed to check for constraint violation
				if (String.isNotBlank(remoteKanban.ValueStreamCardLink) && String.isNotBlank(remoteKanban.ValueStreamLinkID)) {
					addedLinkFlag = true;
					kanban.Name = remoteKanban.Name;
					kanban.leankor__ValueStream__c = currentVS.Id;
					kanban.leankor__StartDateTime__c = remoteKanban.StartDate;
					kanban.leankor__DueDateTime__c = remoteKanban.DueDate;
					kanban.leankor__EstimatedDuration__c = remoteKanban.EstimatedDuration;
					kanban.leankor__ValueStreamLink__c = remoteKanban.ValueStreamLinkID;
					kanban.leankor__ValueStreamCardLink__c = remoteKanban.ValueStreamCardLink;
					addedLinkCards.add(kanban); 
				}

				// Assignment of zone for each card. 
				if ((currentVS.leankor__BoardType__c == 'Kanban Board' || currentVS.leankor__BoardType__c == 'Plan Board')) { 					
					leankor__Zone__c zone = processZoneForKanbanRequest(request, vsZoneMap.get(currentVS.Id));
					remoteKanban.ZoneID = zone.leankor__GUID__c;
					remoteKanban.ZoneForceID = zone.Id;
					remoteKanban.SWForceID = zone.leankor__Swimlane__c;
					remoteKanban.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
				}
				   	       	
				remoteKanban.HarveyBallDoneDate = (request.HarveyBallDoneDate != null)?(request.HarveyBallDoneDate):(request.HarveyBall == 100 ? System.today() :  request.HarveyBallDoneDate);  
				remoteKanban.PromiseCompletionDate = (request.PromiseCompletionDate != null)?(request.PromiseCompletionDate):(request.HarveyBall == 100 ? System.now() :  request.PromiseCompletionDate);
				
				kanbanCardList.add(remoteKanban);

			}

			KanbanController.KanbanCardConstraintViolation constraintsViolated = new KanbanController.KanbanCardConstraintViolation();
			// Calls to check if any card created violates any constraints when adding a link to another card
			if (!addedLinkCards.isEmpty()) {
				constraintsViolated = CreateKanbanCard.checkConstraintValidation(addedLinkCards, addedLinkFlag);
			}

			if (!constraintsViolated.isEmpty()) {
				throw new Util.LeanException('Error: ' + constraintsViolated); 
			} 

			return kanbanCardList;	            
    	} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
    	}
	}


	@TestVisible
	private static void createKanbanCardHelper(leankor.RealTimeController.Kanban remoteKanban, KanbanCardRequest request, leankor__ValueStream__c valueStream, Util.WorkWeek workWeek) {
		// Get the next working day
		remoteKanban.StartDate = workWeek.getNextWorkingDay(request.StartDate == null ? System.now() : request.StartDate);
		remoteKanban.DueDate = workWeek.getNextWorkingDay(request.DueDate == null ? System.now() : request.DueDate);

		// Throw an error when start date fall after due date
		if ((remoteKanban.StartDate > remoteKanban.DueDate) 
			&& (request.EstimatedDuration == null || (request.StartDate != null && request.DueDate != null))) {
			remoteKanban.DueDate = remoteKanban.StartDate;
		}
		
		// To creating AG and mileStone on gantt.
		if (String.isNotBlank(request.RecordTypeName)) {
			if (request.RecordTypeName.equalsIgnoreCase('ActivityCard')) {
				remoteKanban.ItemType = 'ActivityCard';
			} else if (request.RecordTypeName.equalsIgnoreCase('MileStoneCard')) {
				remoteKanban.ItemType = 'MileStoneCard';
			} else if (request.RecordTypeName.equalsIgnoreCase('FolderCard')) {
				remoteKanban.ItemType = 'FolderCard';
			} else {
				throw new Util.LeanException('Error: wrong record type name provided');
			}
		} else {
			remoteKanban.ItemType = 'ActivityCard';
		}

		// Throw and exception when user trying to create AG on non-uber board
		if (valueStream.leankor__BoardType__c != 'UberBoard' && remoteKanban.ItemType == 'FolderCard') {
			throw new Util.LeanException('Error: You can\'t create the Activity Group on this board');
		}
		
		// Assigning the estimate duration for the Card
		if (remoteKanban.ItemType == 'MileStoneCard') {
			remoteKanban.EstimatedDuration = 0;
			remoteKanban.StartDate = (request.DueDate != null ? remoteKanban.DueDate : remoteKanban.StartDate);
		} else if (remoteKanban.ItemType == 'FolderCard') {
			remoteKanban.EstimatedDuration = 1;
		} else {
			remoteKanban.EstimatedDuration = (request.StartDate != null && request.DueDate != null)	
					? workWeek.getBusinessDays(remoteKanban.StartDate.date(), remoteKanban.DueDate.date()) + 1
					: (request.EstimatedDuration != null ? request.EstimatedDuration : workWeek.getBusinessDays(remoteKanban.StartDate.date(), remoteKanban.DueDate.date()) + 1);
			
			remoteKanban.EstimatedDuration = (remoteKanban.EstimatedDuration > 0) ? remoteKanban.EstimatedDuration : 1;
		}

		if (request.StartDate == null && request.DueDate != null) {
			// If due date and ED given then calculate the start date. Backword calculation
			remoteKanban.StartDate = workWeek.getKanbanCardStartDate(Integer.valueOf(remoteKanban.EstimatedDuration == 0 ? 1 : remoteKanban.EstimatedDuration), remoteKanban.DurationUnits, remoteKanban.DueDate);
		} else {
			remoteKanban.DueDate = workWeek.getKanbanCardDueDate(Integer.valueOf(remoteKanban.EstimatedDuration == 0 ? 1 : remoteKanban.EstimatedDuration), remoteKanban.DurationUnits, remoteKanban.StartDate);
		}

		if (valueStream.leankor__BoardType__c != 'UberBoard') {
			remoteKanban.EffortRemaining = integer.valueof(request.EffortRemaining == null ? remoteKanban.EstimatedDuration :request.EffortRemaining);
		}
	}
	

	@TestVisible
	private static void getValueStreamMap(Set<Id> requestBoardIds, Set<String> requestProjectBoardNames, Map<String, leankor__ValueStream__c> projectBoardIdMap, Map<String, List<leankor__ValueStream__c>> projectBoardNameMap) {
		List<leankor__ValueStream__c> valueStreamList = readProjectBoards(requestBoardIds, requestProjectBoardNames);
		requestBoardIds.clear();

		Integer index = 0;
		while (index < valueStreamList.size()) {
			if (valueStreamList.get(index).leankor__ProjectRoom__c == null) {
				valueStreamList.remove(index);
			} else {
				// Putting the values into map when Project room is not deleted. 
				leankor__ValueStream__c vs = valueStreamList.get(index);
				requestBoardIds.add(vs.Id);						
				projectBoardIdMap.put(vs.Id, vs);
				
				List <leankor__ValueStream__c> tempBoards = projectBoardNameMap.containsKey(vs.name) ? projectBoardNameMap.get(vs.name) : new List <leankor__ValueStream__c>();
				tempBoards.add(vs);
				projectBoardNameMap.put(vs.name,tempBoards); 
				index ++;
			}
		}
	}


	@TestVisible
	private static List<leankor__ValueStream__c> readProjectBoards(Set<Id> requestBoardIds, Set<String> requestProjectBoardNames) {
		return [Select
					Id, 
					Name, 
					leankor__ProjectRoom__c,         
					leankor__ProjectRoom__r.name, 
					leankor__ProjectRoom__r.leankor__portfolio__r.Name,
					(Select Id  
						From leankor__Kanbans__r 
						Where leankor__IsRecordDeleted__c = false), 
					leankor__SevenDayWorkWeek__c, 
					leankor__BoardType__c,
					leankor__ProjectRoom__r.leankor__AutoAssignResource__c
				From leankor__ValueStream__c 
				Where leankor__IsRecordDeleted__c = false 
					And (Id In: requestBoardIds 
						Or Name In: requestProjectBoardNames) 
				With Security_Enforced
				Limit 50000];
	}


	@TestVisible
	private static leankor__ValueStream__c getCurrentValueStream(KanbanCardRequest request, Map<String, leankor__ValueStream__c> projectBoardIdMap, Map<String, List<leankor__ValueStream__c>> projectBoardNameMap) {
		leankor__ValueStream__c valueStream;

		if (String.isNotBlank(request.ProjectBoardID) && projectBoardIdMap.containsKey(request.ProjectBoardID)) {
			valueStream = projectBoardIdMap.get(request.ProjectBoardID);
		} else {
			if (projectBoardNameMap.get(request.ProjectBoardName) == null) {
				throw new Util.LeanException('No board record found by given Project Board Name or Id');
			}
			
			for (leankor__ValueStream__c vsInstance : projectBoardNameMap.get(request.ProjectBoardName)) {
				if (vsInstance.name == request.ProjectBoardName && vsInstance.leankor__ProjectRoom__r.name == request.ProjectRoomName && vsInstance.leankor__ProjectRoom__r.leankor__portfolio__r.Name == request.ProjectFolderName) {
					valueStream = vsInstance;
					break;
				} else if (vsInstance.name == request.ProjectBoardName && vsInstance.leankor__ProjectRoom__r.name == request.ProjectRoomName && String.isBlank(request.ProjectFolderName)) {
					valueStream = vsInstance;
					break;
				} else if (vsInstance.name == request.ProjectBoardName && String.isBlank(request.ProjectRoomName) && String.isBlank(request.ProjectFolderName)) {
					valueStream = vsInstance;
					break;
				}
			}
		}
		if (valueStream == null) {
			throw new Util.LeanException('No board record found by given Project Board Name or Id');
		}

		return valueStream;
	}	


	@TestVisible
	private static void processLinkingOnTheCard(leankor.RealTimeController.Kanban remoteKanban, KanbanCardRequest request, Map<String, leankor__Kanbancard__c> linkedCardIdMap, Map<String, List<leankor__Kanbancard__c>> linkedCardNameMap) {
		leankor__KanbanCard__c kanbanCard; 
		if (remoteKanban.BoardType != 'UberBoard' && remoteKanban.ItemType == 'MileStoneCard') {
			remoteKanban.ValueStreamCardLink = '';
			remoteKanban.ValueStreamLinkID = '';
		} else if (String.isNotBlank(request.LinkedCardId) && linkedCardIdMap.containsKey(request.LinkedCardId)) {
			kanbanCard = linkedCardIdMap.get(request.LinkedCardId);
		} else if (String.isNotBlank(request.LinkedCardName) && linkedCardNameMap.containsKey(request.LinkedCardName)) {
			for (leankor__KanbanCard__c kanInstance : linkedCardNameMap.get(request.LinkedCardName)) {
				if (kanInstance.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name == request.LinkedFolderName && kanInstance.leankor__ValueStream__r.leankor__ProjectRoom__r.Name == request.LinkedRoomName && kanInstance.leankor__ValueStream__r.name == request.LinkedBoardName && kanInstance.name == request.LinkedCardName) {
					kanbanCard = kanInstance;
					break;
				} else if ( String.isBlank(request.LinkedFolderName) && kanInstance.leankor__ValueStream__r.leankor__ProjectRoom__r.Name == request.LinkedRoomName && kanInstance.leankor__ValueStream__r.name == request.LinkedBoardName && kanInstance.name == request.LinkedCardName) {
					kanbanCard = kanInstance;
					break;
				} else if ( String.isBlank(request.LinkedFolderName) &&  String.isBlank(request.LinkedRoomName) && kanInstance.leankor__ValueStream__r.name == request.LinkedBoardName && kanInstance.name == request.LinkedCardName) {
					kanbanCard = kanInstance;
					break;
				} else if ( String.isBlank(request.LinkedFolderName) &&  String.isBlank(request.LinkedRoomName) &&  String.isBlank(request.LinkedBoardName) && kanInstance.name == request.LinkedCardName) {
					kanbanCard = kanInstance;
					break;
				}
			}
		}

		if (kanbanCard != null) {
			if (remoteKanban.BoardType == 'UberBoard' && kanbanCard.RecordType.Name == 'FolderCard' && remoteKanban.ValueStream == kanbanCard.leankor__ValueStream__c) {
				remoteKanban.ValueStreamCardLink = kanbanCard.Id;
				remoteKanban.ValueStreamLinkID = kanbanCard.leankor__ValueStream__c;
				folderCards.add(kanbanCard.Id);
			} else if (remoteKanban.BoardType != 'UberBoard' && kanbanCard.RecordType.Name != 'FolderCard' && !(kanbanCard.leankor__BoardType__c != 'UberBoard' && kanbanCard.RecordType.Name == 'MilstoneCard')) {
				remoteKanban.ValueStreamCardLink = kanbanCard.Id;
				remoteKanban.ValueStreamLinkID = kanbanCard.leankor__ValueStream__c;
			}
		}
	}


	@TestVisible
	private static void getLinkedCardMap(Set<String> requestLinkedNames, Set<String> requestLinkedIds,  Map<String, leankor__Kanbancard__c> linkedCardIdMap, Map<String, List<leankor__Kanbancard__c>> linkedCardNameMap) {
		leankor__ScheduleMode__c schedule;
	
		// Mapping for linking cards.
		for (leankor__Kanbancard__c kanban : readLinkedCards(requestLinkedNames, requestLinkedIds)) {
			schedule = kanban.leankor__ScheduleModes__r.size() > 0 ? kanban.leankor__ScheduleModes__r : null;
			if (!(schedule != null && schedule.leankor__Mode__c == 'EffortDriven' && kanban.leankor__BoardType__c == 'UberBoard')) {
				linkedCardIdMap.put(kanban.Id, kanban);
				List <leankor__KanbanCard__c> kanList = linkedCardNameMap.containsKey(kanban.Name) ? linkedCardNameMap.get(kanban.Name) : new List <leankor__KanbanCard__c>();
				kanList.add(kanban);   
				linkedCardNameMap.put(kanban.Name, kanList);
			}	
		}
	}


	@TestVisible
	private static List<leankor__KanbanCard__c> readLinkedCards(Set<String> requestLinkedNames, Set<String> requestLinkedIds) {
		return [Select 
					Id, 
					Name, 
					leankor__ValueStream__c, 
					leankor__ValueStream__r.name, 
					leankor__ValueStream__r.leankor__ProjectRoom__c,
					leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name, 
					leankor__ValueStream__r.leankor__ProjectRoom__r.Name,
					leankor__BoardType__c,
					leankor__IsSuccessorRecalculate__c,
					RecordType.Name,
					leankor__ValueStream__r.leankor__PortfolioMode__c,
					(Select Id, 
							leankor__Mode__c 
						From leankor__ScheduleModes__r
						Limit 1) 
				From leankor__Kanbancard__c 
				Where leankor__isRecordDeleted__c = false 
					And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
					And ((Id In: requestLinkedIds 
							Or (Id In: requestLinkedIds
								And leankor__ValueStream__r.Id In: requestLinkedIds)
						) Or (Name In: requestLinkedNames 
							Or leankor__ValueStream__r.Name In: requestLinkedNames 
							Or  leankor__ValueStream__r.Id In: requestLinkedIds
							Or leankor__ValueStream__r.leankor__ProjectRoom__r.Name In: requestLinkedNames 
							Or leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__r.Name In: requestLinkedNames
						))
				With Security_Enforced
				Limit 50000];
	}


	@TestVisible
	private static List<leankor__KanbanCardTemplate__c> readKanbanCardTemplate(Set<Id> boardIdSet) {
		return [Select 
					Id, 
					Name, 
					leankor__Color__c, 
					leankor__Height__c,  
					leankor__JSONData__c, 
					leankor__JSONDefinition__c, 
					leankor__Width__c, 
					leankor__ValueStream__c, 
					leankor__Title__c 
				From leankor__KanbanCardTemplate__c
				Where leankor__ValueStream__c In: boardIdSet 
					And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
				With Security_Enforced  
				Order By leankor__Title__c ASC 
				Limit 50000];
	}
	

	@TestVisible
	private static Map<Id, List<leankor__Zone__c>> getVsZoneMap(Set<Id> boardIdSet) {
		Map<Id, List<leankor__Zone__c>> vsZoneMap = new Map<Id, List<leankor__Zone__c>>();

		for (leankor__Zone__c zone: readZones(boardIdSet)) {
			List<leankor__Zone__c> zoneList = vsZoneMap.ContainsKey(zone.leankor__ValueStream__c) ? vsZoneMap.get(zone.leankor__ValueStream__c) : new List<leankor__Zone__c> ();
			zoneList.add(zone);
			vsZoneMap.put(zone.leankor__ValueStream__c, zoneList);	
		}

		return vsZoneMap;
	}


	@TestVisible
	private static List<leankor__Zone__c> readZones(Set<Id> boardIdSet) {
		return [Select
					Id, 
					Name, 
					leankor__GUID__c, 
					leankor__Swimlane__c, 
					leankor__Swimlane__r.name, 
					leankor__Swimlane__r.leankor__MasterContainer__c, 
					leankor__Swimlane__r.leankor__MasterContainer__r.name,
					leankor__valuestream__c, 
					leankor__valuestream__r.leankor__BoardType__c 
				From leankor__Zone__c
				Where leankor__ValueStream__c In: boardIdSet
				With Security_Enforced
				Limit 10000];
	}


    // This is helping method of processSobjectList method to process the zone.
    public static leankor__Zone__c processZoneForCard (leankor__KanbanCard__c kanban, List <leankor__Zone__c> zoneList) {
		leankor__Zone__c cardZone = new leankor__Zone__c();
			
    	for (leankor__Zone__c zone: zoneList) {
			if ((kanban.leankor__ZoneGUID__c == zone.leankor__GUID__c) || (kanban.leankor__Zone__c == zone.Id)) {
               	cardZone = zone;
                break;
			} else if (kanban.leankor__Swimlane__c == zone.leankor__Swimlane__c && String.isBlank(kanban.leankor__ZoneGUID__c) && String.isBlank(kanban.leankor__Zone__c)) {
				cardZone = zone;
        		break;
			} else if (kanban.leankor__MasterContainer__c == zone.leankor__Swimlane__r.leankor__MasterContainer__c  && String.isBlank(kanban.leankor__ZoneGUID__c) && String.isBlank(kanban.leankor__Zone__c) && String.isBlank(kanban.leankor__Swimlane__c)) {
				cardZone = zone;
                break;
			} else if (zone.leankor__Swimlane__r.leankor__MasterContainer__r.name == 'Backlog' ) {
				cardZone = zone;
            }
		}
		
	    return cardZone;
    }
	
	
    //This is helping method of createKanbanCard method to process the zone.
    public static leankor__Zone__c processZoneForKanbanRequest (KanbanCardRequest request, List <leankor__Zone__c> zoneList) {
		leankor__Zone__c cardZone = new leankor__Zone__c();	
		
    	for (leankor__Zone__c zone: zoneList) {
			if ((request.zoneID == zone.leankor__GUID__c) || (request.ZoneForceID == zone.Id)) {
				cardZone = zone;
                    break;
			} else if (request.SWForceID == zone.leankor__Swimlane__c && String.isBlank(request.zoneID) && String.isBlank(request.ZoneForceID)) {
				cardZone = zone;
				break;
			} else if (request.MCForceID == zone.leankor__Swimlane__r.leankor__MasterContainer__c  && String.isBlank(request.zoneID) && String.isBlank(request.ZoneForceID) && String.isBlank(request.SWForceID)) {
				cardZone = zone;
				break;
			} else if (zone.name == request.ZoneName && zone.leankor__Swimlane__r.name == request.SWName && zone.leankor__Swimlane__r.leankor__MasterContainer__r.name == request.MCName) {
				cardZone = zone;
				break;	
			} else if (String.isBlank(request.ZoneName) && zone.leankor__Swimlane__r.name == request.SWName && zone.leankor__Swimlane__r.leankor__MasterContainer__r.name == request.MCName) {
				cardZone = zone;
				break;	
			} else if (String.isBlank(request.ZoneName) && String.isBlank(request.SWName)  && zone.leankor__Swimlane__r.leankor__MasterContainer__r.name == request.MCName) {
				cardZone = zone;
				break;	
			} else if (zone.leankor__Swimlane__r.leankor__MasterContainer__r.name == 'Backlog' ) {
				cardZone = zone;
			}
		}  

	    return cardZone;
    }
	
	
    // Input Invocable variable for API call.
    global class KanbanCardRequest {   
		@InvocableVariable(label = 'GUID' description = 'External Id for kanban card.')
		global String GUID;
		@InvocableVariable(label = 'Title' description = 'Title that appears on the front of the Card' required=true)
		global String Title;
		@InvocableVariable(label = 'Top' description = 'Top screen coordinate of the Card' )
		global Decimal Top;
		@InvocableVariable(label = 'Bottom' description = 'Bottom screen coordinate of the Card.')
		global Decimal Bottom;
		@InvocableVariable(label = 'Left' description = 'Left screen coordinate of the Card.')
		global Decimal Left;
		@InvocableVariable(label = 'X' description = 'X coordinate of the Card.')
		global Decimal X;
		@InvocableVariable(label = 'Y' description = 'Y coordinate of the Card.')
		global Decimal Y;
		@InvocableVariable(label = 'Custom fields' description = 'The custom field definitions in JSON format.')
		global String JSONDefinition; 
		@InvocableVariable(label = 'Custom field values' description = 'The Category applied to the new Card.')
		global String JSONData; 
		@InvocableVariable(label = 'Category Name' description = 'The Category applied to the new Card.' required=true )
		global String CategoryName;       
		@InvocableVariable(label = 'Description' description = 'A long description of the Card.' )
		global String Description;
		@InvocableVariable(label = 'Acceptance Criteria' description = 'A long Acceptance Criteria of the Card.' )
		global String AcceptanceCriteria;
		@InvocableVariable(label = 'Point' description = 'Point on card for agile Board.')
		global Decimal Point;
		@InvocableVariable(label = 'Effort Remaining' description = 'Effort Remaining on card .')
		global Decimal EffortRemaining;            
		@InvocableVariable(label = 'DueDate' description = 'Due Date of the Card')
		global DateTime DueDate;
		@InvocableVariable(label = 'EstimatedDuration' description = 'The numerical duration or effort of the work.')
		global Decimal EstimatedDuration;
		@InvocableVariable(label = 'DurationUnits' description = 'Must be either Minutes, Days, Months or Years.')
		global String DurationUnits;    
		@InvocableVariable(label = 'Priority' description = 'Must be 3 for lowest priority and 1 for highest priority.')
		global Integer Priority;    
		@InvocableVariable(label = 'OwnerID' description = 'This is the Owner of the Card. The ID is at the end of the URL when viewing the User record in Setup.' required=true)
		global ID OwnerID;
		@InvocableVariable(label = 'Percent Complete' description = 'The percent of a Card that is completed. Represented as a decimal value of 0, 0.25, 0.5, 0.75 or 1.' )
		global Decimal HarveyBall;  
		@InvocableVariable(label = 'Linked Kanban Card Id' description = 'The Card ID to which this card is linked.')
		global String ValueStreamCardLink;
		@InvocableVariable(label = 'Linked Project Board Id' description = 'The Project Board ID on which the Linked Kanban Card is located.')
		global String ValueStreamLinkID;
		@InvocableVariable(label = 'Account ID' description = 'The ID of the Account linked to this Card.' )
		global String Account;
		@InvocableVariable(label = 'Opportunity ID' description = 'The ID of the Opportunity linked to this Card.')
		global String Opportunity;
		@InvocableVariable(label = 'Contact ID' description = 'The ID of the Contact linked to this Card.')
		global String Contact;
		@InvocableVariable(label = 'Case ID' description = 'The ID of the Case linked to this card.')
		global String CaseID;
		@InvocableVariable(label = 'Order' description = 'The Card order in the column on the Board. ')
		global Decimal Order;
		@InvocableVariable(label = 'Zone GUID' description = 'The unique ID of the column in which the Card resides. ')
		global String ZoneID;
		@InvocableVariable(label = 'Zone ID' description = 'The unique ID of the Zone in which the Card resides. ')
		global String ZoneForceID;
		@InvocableVariable(label = 'MC ID ' description = 'The unique ID of the MC in which the Card resides. ')
		global String MCForceID;
		@InvocableVariable(label = 'SW ID' description = 'The unique ID of the SW in which the Card resides. ')
		global String SWForceID;    
		@InvocableVariable(label = 'OnBudget' description = 'Does the Card represent work that is on Budget? Green, Amber or Red.')
		global String OnBudget;
		@InvocableVariable(label = 'OnQuality' description = 'Does the Card represent work that is on Quality? Green, Amber or Red.')
		global String OnQuality;
		@InvocableVariable(label = 'OnTime' description = 'Does the Card represent work that is on Time? Green, Amber or Red.')
		global String OnTime;        
		@InvocableVariable(label = 'Start Date' description = 'The Start Date of the work represented by the Card.')
		global DateTime StartDate;
		@InvocableVariable(label = 'Project Board Name' description = 'String name of selected Project Board.' required=true)
		global String ProjectBoardName;
		@InvocableVariable(label = 'Project Folder Name' description = 'Name of the Folder where its Room would located.')
		global String ProjectFolderName;
		@InvocableVariable(label = 'Project Room Name' description = 'String name of selected Project Room in which the Board resides.')
		global String ProjectRoomName;
		@InvocableVariable(label = 'Project Board Id' description = 'The ID of the selected Project Board. This is not required if you specify the Room and Board Names')
		global String ProjectBoardId;
		@InvocableVariable(label = 'URL Link' description = 'URL For Link to Card ')
		global String UrlLink;    
		@InvocableVariable(label = 'Master Container Name' description = 'Name of Master container for new kanban card.')
		global String MCName;
		@InvocableVariable(label = 'Swimlane Name' description = 'Name of Swimlane for new kanban card.')
		global String SWName;
		@InvocableVariable(label = 'Column Name' description = 'Name of column for new kanban card.')
		global String ZoneName;
		// Linked Folder, Linked Room, Linked Board, Linked Card
		@InvocableVariable(label = 'Linked Folder Name' description = 'Name of the Linked Folder where Linked Room would located.')
		global String LinkedFolderName; 
		@InvocableVariable(label = 'Linked Room Name' description = 'Name of the Link Project Room where Linked Board is located.')
		global String LinkedRoomName;
		@InvocableVariable(label = 'Linked Board Name' description = 'Name of the Link Board to Linked .')
		global String LinkedBoardName;
		@InvocableVariable(label = 'Link Board Id' description = 'ID of the Link Board to Linked with merge Cards.')
		global String LinkedBoardId;        
		@InvocableVariable(label = 'Linked Card Name' description = 'Name of Link Kanban Card Which to linked.')
		global String LinkedCardName;
		@InvocableVariable(label = 'Linked Card ID' description = 'Card ID of Link Kanban Card Which to linked.')
		global String LinkedCardId;
		@InvocableVariable(label = 'User Defined Card ID' description = 'card ID which will show on card records')
		global String CardId;
		@InvocableVariable(label = 'HarveyBall Done Date' description = 'HarveyBall status complete Date')
		global Date HarveyBallDoneDate;
		@InvocableVariable(label = 'Promise Completion Date ' description = 'Promise Completion Date of card')
		global DateTime PromiseCompletionDate;       
		@InvocableVariable(label = 'Kanban Card List ' description = 'List of Kanban Card as Input')
		global List <leankor__KanbanCard__c> KanbanCardList;  	              
		@InvocableVariable(label = 'Record Type Name' description = 'Record Type Name of the card')
		global String RecordTypeName;     
		@InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false;
    }
	
	
	// Output Invocable variable for API call.
    global class KanbanCardResult {    
        @InvocableVariable(label = 'Kanban Card Id' description = 'Id of new Kanban Card')
        global Id KanbanCardId;
        @InvocableVariable(label = 'List of new Created Kanban Cards' description = 'List of new Kanban Cards')
        global List<leankor__KanbanCard__c> CreatedKanbanCardList;      
    }
}