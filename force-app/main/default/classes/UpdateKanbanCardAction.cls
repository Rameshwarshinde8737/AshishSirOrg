/************************************************************
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  UpdateKanbanCardAction.cls
* CLASS: UpdateKanbanCardAction
* USAGE: manages to Upadte Record of Card .
*************************************************************/

global with sharing class UpdateKanbanCardAction {
	
	// This variable is using for collecting all subItems only for OnHold Update.
	public Static Set<leankor__kanbanCard__c> childrens = new Set<leankor__kanbanCard__c>();
	// Used to store the KC Id's when recordtype change. Based on that we need to create or delete Schedule mode
	private static Set<Id> createSMIds = new Set<Id>();
	private static Set<Id> deleteSMIds = new Set<Id>();


	@InvocableMethod
	global static void  UpdateKanbanCardProcess(List<KanbanCardRequest> requests) {
		for (KanbanCardRequest request : requests) {
			if (String.isNotBlank(request.Id) && (Util.getSObjectName(request.Id) != 'leankor__KanbanCard__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.ValueStreamCardLink) && (Util.getSObjectName(request.ValueStreamCardLink) != 'leankor__KanbanCard__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.OwnerID) && (Util.getSObjectName(request.OwnerID) != 'User')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.ValueStreamLinkID) && (Util.getSObjectName(request.ValueStreamLinkID) != 'leankor__ValueStream__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		updateKanbanCard(requests);         
	}


	//AuraEnabled accesor method
	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static leankor__KanbanCard__c getKanbanCard(Id kanbanCardId) {
		if (String.isNotBlank(kanbanCardId) && (Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
        // Perform isAccessible() checks here
		return [Select Id,
						leankor__Title__c, 
						leankor__StartDate__c, 
						leankor__StartDateTime__c, 
						leankor__DueDate__c, 
						leankor__DueDateTime__c 
					From leankor__KanbanCard__c 
					Where Id =: kanbanCardId
					With Security_Enforced
					Limit 50000];
	}
	
	
	// AuraEnabled lightning method to update kanban card
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	global static void UpdateKanbanCardLightning(String stringRequest) {
		List<KanbanCardRequest> requests = new List<KanbanCardRequest>();
		try {
			KanbanCardRequest request = (KanbanCardRequest) JSON.deserialize(stringRequest, KanbanCardRequest.class);
			if (String.isNotBlank(request.Id) && (Util.getSObjectName(request.Id) != 'leankor__KanbanCard__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.ValueStreamCardLink) && (Util.getSObjectName(request.ValueStreamCardLink) != 'leankor__KanbanCard__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.OwnerID) && (Util.getSObjectName(request.OwnerID) != 'User')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			if (String.isNotBlank(request.ValueStreamLinkID) && (Util.getSObjectName(request.ValueStreamLinkID) != 'leankor__ValueStream__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
			requests.add(request);
			updateKanbanCard(requests);
		} catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
	}
		

	// This methord is use to manage bulk records .
	public static void updateKanbanCard(List<KanbanCardRequest> requests) {
		//Check CRUD / FLC behavior
		ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

		if (!resourceAssignmentBehavior.isUpdateable() ||
			!scheduleModeBehavior.isCreateable() ||
			!scheduleModeBehavior.isDeletable() ||
			!kanbanCardBehaviour.isDeletable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

		Set<Id> valueStreamIds = new Set<Id>();
		Set<Id> linkCardIds = new Set<Id>();
		List<String> categoryNames = new List<String>();
		List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
		List<String> kanbanCardIds = new List<String>();
		List<Id> ownerIds = new List<Id>();
		List<String> jsonListData = new List<String>(); 
		Map<String, leankor__KanbanCardTemplate__c> categoryMap = new Map<String, leankor__KanbanCardTemplate__c>();
		Map<String, leankor__KanbanCard__c> kanbanCardMap = new Map<String, leankor__KanbanCard__c>();
		Map<Id, List<leankor__ProjectScheduleBlackout__c>> blackOutMap = new Map<Id, List<leankor__ProjectScheduleBlackout__c>>();
		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
		Util.WorkWeek workWeek;
		List<leankor__KanbanCard__c> updateKCList = new List<leankor__KanbanCard__c>();
		leankor.RealtimeController.flowWithGSForAPI = true;
		leankor.RealtimeController.updateTaskDatesWeekCalendar = true;
		//Getting kanban card id or getting card url.
		for (KanbanCardRequest request : requests) {
			String tempKanbanId = request.Id;
			if (String.isBlank(request.Id)) {
				tempKanbanId = request.CardURL.substringAfter('cardid=') ;
			}
			ownerIds.add(request.OwnerID);
			kanbanCardIds.add(tempKanbanId);
			categoryNames.add(request.CategoryName);
			linkCardIds.add(request.ValueStreamCardLink);
		}
			
		//Get the kanban card records from database
		List<leankor__Kanbancard__c> KanbanCardRecordList = readKanbanCards(kanbanCardIds);
		for (leankor__Kanbancard__c kc : KanbanCardRecordList) {
			valueStreamIds.add(kc.leankor__ValueStream__c);
			kanbanCardMap.put(kc.Id,kc);
		}   
			
		//Get Miniature of activity.
		Map<Id, leankor__kanbancard__c> miniatureMap = getMiniatureOfActivity(kanbanCardIds);
		Map<string, User> userData = new Map<string, User>([Select Id, 
																	IsActive, 
																	Name 
																From User 
																Where Id In: ownerIds]);
			
		//maping between valuestream id and kanbancardtemplate
		for (leankor__KanbanCardTemplate__c category : readKanbanCardTemplate(valueStreamIds, categoryNames)) {
			categoryMap.put(category.leankor__ValueStream__c, category);
		}    
			
		//Get the blackout records 
		blackOutMap = leankor.RealTimeControllerHelper.getBlackOutRecords(valueStreamIds);
			
		//Create the record type map
		for (RecordType recordType: [Select Id, 
												Name 
											From RecordType 
											Where SobjectType = 'leankor__KanbanCard__c' 
											Limit 1000]) {
			recordTypeMap.put(recordType.Name, recordType);
		}
			
		//Get linked cards
		Map<Id, leankor__kanbancard__c> linkedKanbanCardsMap = getLinkedKanbanCard(linkCardIds);
			   
		Boolean scheduledChangeFlag;
		Boolean updatedCardLinkFlag;
		List<leankor__KanbanCard__c> changedDatesCards = new List<leankor__KanbanCard__c>();

		// Process the request   
		for (KanbanCardRequest request : requests) {	 
			scheduledChangeFlag = false; 
			updatedCardLinkFlag = false;
				
			String kcId = String.isNotEmpty(request.Id) ? request.Id : request.CardURL.substringAfter('cardid=');
			leankor__KanbanCard__c kanban = kanbanCardMap.get(kcId); 
			Integer oldEstimatedDuration = Integer.valueOf(kanban.leankor__EstimatedDuration__c);
			String oldDurationUnits = kanban.leankor__DurationUnits__c;
			Integer oldPercentComplete = Integer.valueOf(kanban.leankor__PercentComplete2__c);
			Datetime oldStartDateTIme = kanban.leankor__StartDateTime__c;
			Datetime oldDueDateTIme = kanban.leankor__DueDateTime__c;
			Id oldValueStreamCardLink = kanban.leankor__ValueStreamCardLink__c;
			leankor__KanbanCardTemplate__c Category = categoryMap.get(kanban.leankor__ValueStream__c);
			// Updating rsesource assignment record assignTo field according to owner Id                     
			if (kanban.leankor__BoardType__c != 'UberBoard' && request.OwnerID != null && kanban.OwnerId != request.OwnerID) {
				for (leankor__ResourceAssignment__c base : kanban.leankor__ResourceAssignments__r) {	                        	                      
					base.leankor__AssignedTo__c = request.OwnerID; 	                                                                    
			        resourceAssignmentList.add(base);
			 	}
			}

			kanban.leankor__CardID__c = (request.CardID == null ? kanban.leankor__CardID__c : request.CardID) ;
			kanban.leankor__Point__c =  (request.Point == null ? kanban.leankor__Point__c : request.Point); 			 
			kanban.leankor__Title__c = (Category.Name == null ? kanban.leankor__Title__c : Category.Name); 
			kanban.Name =  (request.Title == null ? kanban.Name : request.Title);
			kanban.leankor__Top__c = (request.Top == null ? kanban.leankor__Top__c : request.Top);
			kanban.leankor__Bottom__c = (request.Bottom == null ? kanban.leankor__Bottom__c : request.Bottom);
			kanban.leankor__Left__c = (request.Left == null ? kanban.leankor__Left__c : request.Left);
			kanban.leankor__Width__c = (request.Width == null ? (Category.leankor__Width__c == null ? kanban.leankor__Width__c : Category.leankor__Width__c) :request.Width);
			kanban.leankor__Height__c = (request.Height == null ? (Category.leankor__Height__c == null ? kanban.leankor__Height__c : Category.leankor__Height__c) : request.Height); 
			kanban.leankor__X__c = (request.X == null ? kanban.leankor__X__c : request.X);
			kanban.leankor__Y__c = (request.Y == null ? kanban.leankor__Y__c : request.Y);
				//06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
				//kanban.leankor__JSONDefinition__c = (request.JSONDefinition == null ? (kanban.leankor__JSONDefinition__c == null ? Category.leankor__JSONDefinition__c : kanban.leankor__JSONDefinition__c) : request.JSONDefinition);
				//kanban.leankor__JSONData__c =(request.JSONData == null ? (kanban.leankor__JSONData__c == null ? Category.leankor__JSONData__c : kanban.leankor__JSONData__c) : request.JSONData);
			kanban.leankor__KanbanCardTemplate__c = Category.Id;
			kanban.leankor__color__c = Category.leankor__Color__c; 
			kanban.leankor__AcceptanceCriteria__c = (request.AcceptanceCriteria == null ? (kanban.leankor__AcceptanceCriteria__c == null ? '' : kanban.leankor__AcceptanceCriteria__c) : request.AcceptanceCriteria);
			kanban.leankor__DescriptionLong__c = (request.Description == null ? (kanban.leankor__DescriptionLong__c == null ? '' : kanban.leankor__DescriptionLong__c) : request.Description.unescapeHtml4());
			Set<String> weekDays = new Set<String>();
			if (kanban.leankor__valueStream__r.leankor__SevenDayWorkWeek__c) {
				//Pratiksha : 13/Oct/2023 : Changes for WeekCalendar
				if (kanban.leankor__Monday__c == false && kanban.leankor__Tuesday__c == false && kanban.leankor__Wednesday__c == false &&  kanban.leankor__Thursday__c == false && kanban.leankor__Friday__c == false &&  kanban.leankor__Saturday__c == false &&  kanban.leankor__Sunday__c == false){
					kanban.leankor__Monday__c = true;
					kanban.leankor__Tuesday__c = true;
					kanban.leankor__Wednesday__c = true;
					kanban.leankor__Thursday__c = true;
					kanban.leankor__Friday__c = true;
					kanban.leankor__Saturday__c = true;
					kanban.leankor__Sunday__c = true;
				} else {
					/*kanban.leankor__Monday__c = kanbanCardMap.values().leankor__Monday__c;
					kanban.leankor__Tuesday__c = kanbanCardMap.values().leankor__Tuesday__c;
					kanban.leankor__Wednesday__c = kanbanCardMap.values().leankor__Wednesday__c;
					kanban.leankor__Thursday__c = kanbanCardMap.values().leankor__Thursday__c;
					kanban.leankor__Friday__c = kanbanCardMap.values().leankor__Friday__c;
					kanban.leankor__Saturday__c = kanbanCardMap.values().leankor__Saturday__c;
					kanban.leankor__Sunday__c = kanbanCardMap.values().leankor__Sunday__c;
					kanban.leankor__weekCalendar__c = kanbanCardMap.values().leankor__WeekCalendar__c;*/
		
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
	
			workWeek = new Util.WorkWeek(Kanban.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c ? 7: 5, blackOutMap.get(Kanban.leankor__ValueStream__c));
			/* Calling helper Method to calculate StartDate, DueDate, EstimateDuration and RecordType.
				If folderCard have child record then we are not updating this fields.
	   			If Activity/Milestone have miniature in that case we not updating this fields. */
			if (!((miniatureMap.containsKey(kanban.Id) && kanban.leankor__BoardType__c == 'UberBoard'))) {
				updateKanbanCardHelper(kanban, request, workWeek, recordTypeMap);
			}
				
			// If dates are being changed, scheduledChangeFlag is set to true, so the card can be checked for constraint violation
			if (request.StartDate != null || request.DueDate != null || request.EstimatedDuration != null) {
				if(request.StartDate != kanban.leankor__StartDateTime__c || request.DueDate != kanban.leankor__DueDateTime__c || request.EstimatedDuration != kanban.leankor__EstimatedDuration__c){
					scheduledChangeFlag = true;
				}
			}
			
			kanban.leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(kanban.leankor__StartDateTime__c), DateTime.class));
			kanban.leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(kanban.leankor__DueDateTime__c), DateTime.class));
			kanban.leankor__EffortRemaining__c = integer.valueof(request.EffortRemaining == null ? kanban.leankor__EffortRemaining__c : request.EffortRemaining);
			kanban.leankor__Priority__c = (request.Priority == null ? Integer.ValueOf(kanban.leankor__Priority__c) : request.Priority);
				
			// Before assign the ownerId check if user is active or not.
			if (userData.containsKey(request.OwnerId)) {	
				kanban.OwnerID = userData.get(request.OwnerId).IsActive ? request.OwnerId : UserInfo.getUserId();
			} else {
				kanban.OwnerID = (request.OwnerID == null ? kanban.OwnerID : request.OwnerID);
			}
				
			// Do not need to update the percente complete of AG.
			kanban.leankor__PercentComplete2__c = (request.HarveyBall == null || kanban.RecordType.name == 'FolderCard' ? Integer.ValueOf(kanban.leankor__PercentComplete2__c) : Integer.ValueOf(request.HarveyBall));	
				

			// Link the card - We can't perform linking on milestone if board is not UberBoard.			
			if (!(kanban.RecordType.Name == 'MileStoneCard' && kanban.leankor__BoardType__c != 'UberBoard')) {					
				if (String.isNotBlank(request.ValueStreamCardLink) && linkedKanbanCardsMap.containsKey(request.ValueStreamCardLink)) {
					leankor__KanbanCard__c linkedCard = linkedKanbanCardsMap.get(request.ValueStreamCardLink);
					kanban.leankor__ValueStreamCardLink__c = request.ValueStreamCardLink;
					kanban.leankor__ValueStreamLink__c = linkedCard.leankor__ValueStream__c;
				} else if (String.isBlank(request.ValueStreamCardLink) && String.isNotBlank(request.ValueStreamLinkID)) {
					kanban.leankor__ValueStreamCardLink__c = null;
					kanban.leankor__ValueStreamLink__c = request.ValueStreamLinkID;
				} else if (String.isNotBlank(request.ValueStreamCardLink) && String.isNotBlank(request.ValueStreamLinkID)) {
					kanban.leankor__ValueStreamCardLink__c = request.ValueStreamCardLink;
					kanban.leankor__ValueStreamLink__c = request.ValueStreamLinkID;
				}
			}
				
			// If updated card has a new link to a card, updatedCardLinkFlag and scheduledChangeFlag are set to true
			if (String.isNotBlank(kanban.leankor__ValueStreamCardLink__c) && String.isNotBlank(kanban.leankor__ValueStreamLink__c)) {
				updatedCardLinkFlag = true;
				scheduledChangeFlag = true;
			}
			
			kanban.leankor__Account__c = (request.Account == null ? kanban.leankor__Account__c : request.Account);
			kanban.leankor__Opportunity__c = (request.Opportunity == null ? kanban.leankor__Opportunity__c : request.Opportunity );
			kanban.leankor__Contact__c = (request.Contact == null ? kanban.leankor__Contact__c: request.Contact);
			kanban.leankor__Case__c = (request.CaseId == null ? kanban.leankor__Case__c : request.CaseId);
			kanban.leankor__Order__c = (request.Order == null ? (kanban.leankor__Order__c == null ? 0 : kanban.leankor__Order__c) : request.Order);
			kanban.leankor__OnBudget__c = (request.OnBudget == null ? (kanban.leankor__OnBudget__c == null ? 'Green' : kanban.leankor__OnBudget__c) : request.OnBudget);
			kanban.leankor__OnQuality__c = (request.OnQuality == null ? (kanban.leankor__OnQuality__c == null ? 'Green' : kanban.leankor__OnQuality__c ) : request.OnQuality);
			kanban.leankor__OnTime__c = (request.OnTime == null ? (kanban.leankor__OnTime__c == null ? 'Green' : kanban.leankor__OnTime__c ) : request.OnTime);				 
			kanban.leankor__UrlLink__c = String.isEmpty(request.URLlink) ? kanban.leankor__UrlLink__c : request.URLlink; 
			kanban.leankor__State__c = (kanban.leankor__ZoneGUID__c == null ? 'nozone' : 'inzone');
			kanban.Name = (request.Name == null ? kanban.Name : request.Name);
			
			if (request.IsAtRisk != null) {
				kanban.leankor__IsAtRisk__c = request.IsAtRisk ;
			}
			if (request.IsOnHold!= null) {	 		 
			  	kanban.leankor__IsOnHold__c = request.IsOnHold;		 		
			}
			
			//Updating Harveyball Status and Percent Completion	                    
			if (request.HarveyBallDoneDate != null) {
				kanban.leankor__HarveyBallDoneDate__c = request.HarveyBallDoneDate;
			} else {
				kanban.leankor__HarveyBallDoneDate__c = (oldPercentComplete != request.HarveyBall && request.HarveyBall == 100) ? System.today() :  kanban.leankor__HarveyBallDoneDate__c;
			}
				
			if (request.PromiseCompletionDate != null) {
				kanban.leankor__PromiseCompletionDate__c = request.PromiseCompletionDate;
			} else {
				kanban.leankor__PromiseCompletionDate__c = (oldPercentComplete != request.HarveyBall && request.HarveyBall == 100) ? System.now() : kanban.leankor__PromiseCompletionDate__c;
			}
				
			//Update isSuccessorRecalculate of KC item if it has successor items
			if (kanban.leankor__PredecessorDependencies__r.size()>0) {
				kanban.leankor__IsSuccessorRecalculate__c = true;
			}

			// 24/04/2023 IsConstraintRecalculate value will be True if Changes Start Date or Due Date or Estimation duration or Duration Unit
			// 24/04/2023 if parent card inside in  PG or Rollup board it's IsConstraintRecalculate Value also will be true
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
			
			// Add to list of cards with changed dates if schedule being changed 
			if (scheduledChangeFlag == true && (kanban.RecordType.Name == 'MileStoneCard' || kanban.RecordType.Name == 'ActivityCard')) {
				changedDatesCards.add(kanban);
			} 	
		} 	
		KanbanController.KanbanCardConstraintViolation constraintsViolated = new KanbanController.KanbanCardConstraintViolation();
		// Calls to check if any card updated violates any constraints
		if (!changedDatesCards.isEmpty()) {
			constraintsViolated = UpdateKanbanCard.checkConstraintValidation(changedDatesCards, updatedCardLinkFlag);
		}

		if (!constraintsViolated.isEmpty()) {
			throw new Util.LeanException('Error: ' + constraintsViolated);
		} else { 
			Savepoint sp = Database.setSavepoint();
			try {
			//update Resource Assignment when owner of card will be change
			if (resourceAssignmentList.size() > 0) {
				update resourceAssignmentList;
			}

			// Create Schedule mode 
			if (createSMIds.size() > 0) {
				leankor.UpdateKanbanCard.createScheduleMode(createSMIds);
			}
 
			// Delete schedule mode
			if (deleteSMIds.size() > 0) {
				leankor.UpdateKanbanCard.deleteScheduleModes(deleteSMIds);
			}


			/** --------------- onHold ---------------------------------------- */
			//Date :20/06/19
			//Currently OnHold is not updating subActivity, subActivityGroup from API
			if (updateKCList[0].leankor__IsOnHold__c != null) {
				leankor.GanttTaskBoard.ActivityWrapper activityWrapper =new leankor.GanttTaskBoard.ActivityWrapper ();
				activityWrapper.activity=new List<leankor__KanbanCard__c>(); 						
                Boolean isFolderCard =false;
				List<leankor__KanbanCard__c> folderItems = new List<leankor__KanbanCard__c>();
				
                for (leankor__KanbanCard__c kcItem : [Select Id,
																leankor__BoardType__c,
				 												RecordType.Name, leankor__IsOnHold__c,
                												leankor__ValueStream__c 
															From leankor__KanbanCard__c 
															Where Id IN: updateKCList 
															With Security_Enforced
															Limit 10000]) {
                	if (kcItem.RecordType.name.equals('FolderCard')) {
						isFolderCard= true;
						folderItems.add(kcItem);
					}
                	activityWrapper.activity.add(kcItem);				  		
				}
                if (updateKCList.size() >0 &&  activityWrapper.activity[0].leankor__BoardType__c == 'UberBoard') {
					activityWrapper.boardType='UberBoard';
					activityWrapper.valueStreamId= activityWrapper.activity[0].leankor__ValueStream__c;
					activityWrapper.sessionID=UserInfo.getSessionId();
			    } else {
					activityWrapper.boardType='Kanban Board';
					activityWrapper.valueStreamId= activityWrapper.activity[0].leankor__ValueStream__c;
					activityWrapper.sessionID=UserInfo.getSessionId();			    
			    }
				//If item as successors on PG then update OnHOld for successor Items.
				List<leankor__Dependency__c> dependency = [Select Id 
																From leankor__Dependency__c 
																Where leankor__Predecessor__c In:activityWrapper.activity  
																	And leankor__Predecessor__r.leankor__ValueStream__r.leankor__BoardType__c = 'UberBoard' 
																With Security_Enforced
																Limit 1];
				
				if (dependency.size() > 0) {
					 Set<String> tempVS = new Set<String>{activityWrapper.valueStreamId};
                     System.enqueueJob(new SuccessorCardsQeueuable(activityWrapper.activity,tempVS, activityWrapper.sessionID,true));
				}
				  
          		//If card is folderCard then grab all subItems as well for OnHold update.
          		if (isFolderCard) {
					List<leankor__kanbanCard__c> subItems= new List<leankor__kanbanCard__c>();

					for (leankor__kanbanCard__c kbCard:[Select Id,
																	Name,
																	leankor__IsOnHold__c,
																	leankor__ValueStream__c,
																	leankor__BoardType__c,
																	leankor__ValueStreamCardLink__c,
																	RecordType.Name 
															From leankor__KanbanCard__c 
															Where leankor__BoardType__c = 'UberBoard' 
																And leankor__ValueStream__c In : valueStreamIds
																And leankor__IsRecordDeleted__c = false
															With Security_Enforced]) {

                   		if (kbCard.leankor__ValueStreamCardLink__c != null) {
                   			subItems.add(kbCard);
						}			
                   	}
					for (leankor__KanbanCard__c folder : folderItems) {
						Map<String,List<leankor__KanbanCard__c>> mapOfKanbanCard=new Map<String,List<leankor__KanbanCard__c>>();
						mapOfKanbanCard.put(folder.Id,subItems);
						//Get all children Items
						childActivity(folder.Id,updateKCList[0].leankor__IsOnHold__c,mapOfKanbanCard);
					}
                   
					if (childrens.size() > 0) {
						activityWrapper.activity.addAll(childrens);
					}
				}

                leankor.GanttTaskBoard.updateKanbanCards(activityWrapper);
			}    
			// Update the KC record and send broadcast
			leankor.RealtimeController.BulkStreaming stream = new leankor.RealtimeController.BulkStreaming();
			stream.Verb = 'UpdateKanbanCard';
			stream.SessionID = UserInfo.getSessionId();
			stream.kanbansObjectList = updateKCList;
			leankor.realtimeController.manageBulkStreaming(stream, true);

        } catch (Exception e) {
		  	Database.rollback(sp);
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }
	
    }
	
	
	// Get all subItems of FolderCard(Currently using this method only for OnHold)
    public static void childActivity(String kbId, Boolean isOnHold, Map<String, List<leankor__KanbanCard__c>> mapOfkanbanCards) {	          	         
		List<leankor__KanbanCard__c> kanbanList=mapOfkanbanCards.get(kbId);

		for (leankor__KanbanCard__c kb : mapOfkanbanCards.get(kbId)) {
			if (kbId.equals(kb.leankor__ValueStreamCardLink__c)) {
				kb.leankor__IsOnHold__c=isOnHold;
				if (kb.RecordType.Name=='FolderCard') {
					childrens.add(kb);			       
					Map<String, List<leankor__KanbanCard__c>> kbmap = new  Map<String, List<leankor__KanbanCard__c>>();
					kbmap.put(kb.Id,kanbanList);
					childActivity(kb.Id,isonHold,kbmap);
				} else {
					childrens.add(kb);	
				}
			}
		} 
	}


	@TestVisible
	private static Map<Id, leankor__kanbancard__c> getLinkedKanbanCard(Set<Id> cardIds) {
		Map<Id, leankor__KanbanCard__c> linkedCardMap = new Map<Id, leankor__KanbanCard__c>();
		// Get the milestone and AG and cards from other boards
		linkedCardMap.putAll([Select Id,
										leankor__ValueStream__c
									From leankor__KanbanCard__c
									Where Id In: cardIds 
										And ((recordtype.Name != 'ActivityCard' And leankor__BoardType__c = 'UberBoard')
											OR (recordtype.Name = 'ActivityCard' And leankor__BoardType__c != 'UberBoard'))
									With Security_Enforced
									Limit 50000]);

		// Get the activities those are not effort driven.
		linkedCardMap.putAll([Select Id,
										leankor__ValueStream__c
									From leankor__KanbanCard__c
									Where Id In (Select 
													leankor__KanbanCard__c 
												From leankor__ScheduleMode__c
												Where leankor__KanbanCard__c In: cardIds 
													And leankor__Mode__c != 'EffortDriven') 
									With Security_Enforced
									Limit 50000]);
	
		return linkedCardMap;
	}
	

	@TestVisible
	private static List<leankor__KanbanCard__c> readKanbanCards(List<String> kanbanCardIds) {
		return [Select Id,
					(Select Id From leankor__PredecessorDependencies__r),
					(Select Id From leankor__SuccessorDependencies__r),
					leankor__UrlLink__c, 
					leankor__BoardType__c, 
					leankor__MasterContainer__c,
					leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
					leankor__Zone__c, 
					leankor__Swimlane__c,
					leankor__Point__c, 
					leankor__CardID__c,
					leankor__AcceptanceCriteria__c, 
					leankor__Account__c,
					leankor__Bottom__c, 
					leankor__Case__c,
					leankor__Color__c, 
					leankor__Contact__c,  
					leankor__DescriptionLong__c,
					leankor__DueDateTime__c,
					leankor__DueDate__c, 
					leankor__DurationUnits__c,
					leankor__EstimatedDuration__c, 
					leankor__EffortRemaining__c,
					leankor__GUID__c, 
					leankor__HarveyBallDoneDate__c,
					leankor__Height__c, 
					//leankor__JSONData__c, 
					//leankor__JSONDefinition__c,
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
					leankor__ValueStreamCardLink__r.RecordType.Name,
					leankor__ValueStreamLink__c,
					leankor__ValueStream__c, 
					leankor__Width__c, 
					leankor__X__c,
					leankor__Y__c, 
					leankor__ZoneGUID__c, 
					leankor__IsOnHold__c, 
					leankor__IsAtRisk__c,
					Name,
					OwnerId, 
					leankor__ValueStream__r.leankor__BoardType__c,
					(Select Id, leankor__AssignedTo__c From leankor__ResourceAssignments__r),
					(Select Id, leankor__Mode__c From leankor__ScheduleModes__r Limit 1),
					RecordType.Name,
					RecordTypeId,
					leankor__IsConstraintRecalculate__c,
					leankor__ValueStreamLink__r.leankor__BoardType__c,
                	leankor__Monday__c,
                    leankor__Tuesday__c,
                    leankor__Wednesday__c,
                    leankor__Thursday__c,
                    leankor__Friday__c,
                    leankor__Saturday__c,
                    leankor__Sunday__c,
                    leankor__WeekCalendar__c
				From leankor__KanbanCard__c 
				Where Id In: kanbanCardIds 
				And leankor__isRecordDeleted__c = false 
				Limit 50000];
	}


	@TestVisible
	private static List<leankor__KanbanCardTemplate__c> readKanbanCardTemplate(Set<Id> valueStreamIds, List<String> categoryNames) {
		return [Select Id,
						Name,
						leankor__Color__c,
						leankor__Height__c,
						//leankor__JSONData__c, 
						//leankor__JSONDefinition__c,
						leankor__Width__c,
						leankor__ValueStream__c,
						leankor__Title__c 
					From leankor__KanbanCardTemplate__c 
					Where Name In: categoryNames 
						And leankor__ValueStream__c In: valueStreamIds 
					With Security_Enforced
					Limit 50000];
	}


	@TestVisible
	private static Map<Id, leankor__KanbanCard__c> getMiniatureOfActivity(List<String> kanbanCardIds) {
		Map<Id, leankor__Kanbancard__c> miniatureMap = new Map<Id, leankor__Kanbancard__c>(); 
		
		for (leankor__KanbanCard__c kanban: readMiniatures(kanbanCardIds)) {
			miniatureMap.put(kanban.leankor__ValueStreamCardLink__c, kanban);								
		}

		return miniatureMap;
	}


	@TestVisible
	private static List<leankor__KanbanCard__c> readMiniatures(List<String> kanbanCardIds) {
		return [Select Id, 
						leankor__ValueStreamCardLink__c,
						leankor__ValueStream__c
					From leankor__KanbanCard__c 
					Where leankor__ValueStreamCardLink__c In: kanbanCardIds 
						And leankor__ValueStreamCardLink__r.leankor__BoardType__c = 'UberBoard'
						And leankor__isRecordDeleted__c = false  
						And leankor__ValueStream__r.leankor__isRecordDeleted__c  = false
					With Security_Enforced
					Limit 50000];
	}	


	@TestVisible
	private static void updateKanbanCardHelper(leankor__Kanbancard__c kanban, KanbanCardRequest request, Util.WorkWeek workWeek, Map<String, RecordType> recordTypeMap) {
		String currentRecordType = kanban.RecordType.Name;
		String newRecordType = (request.RecordTypeName != null && recordTypeMap.containsKey(request.RecordTypeName)) ? request.RecordTypeName : '';

		kanban.leankor__StartDateTime__c = (request.StartDate == null ? (kanban.leankor__StartDateTime__c == null ? System.Now() : kanban.leankor__StartDateTime__c) : request.StartDate );
		kanban.leankor__DueDateTime__c = (request.DueDate == null ? kanban.leankor__DueDateTime__c : request.DueDate);
		
		// If start date is after due date then assign start date into due date.
		if ((kanban.leankor__StartDateTime__c > kanban.leankor__DueDateTime__c)
				&& (request.EstimatedDuration == null || (request.DueDate != null && request.StartDate != null))) {
			kanban.leankor__DueDateTime__c = kanban.leankor__StartDateTime__c;
		}

		// Escaping the non- working days
		kanban.leankor__StartDateTime__c =  workWeek.getNextWorkingDay(kanban.leankor__StartDateTime__c);
		kanban.leankor__DueDateTime__c = workWeek.getNextWorkingDay(kanban.leankor__DueDateTime__c);

		
		if (kanban.leankor__BoardType__c == 'UberBoard' && String.isNotBlank(newRecordType)) {
			if (newRecordType == 'MileStoneCard' && currentRecordType == 'ActivityCard') {
				kanban.RecordTypeId = recordTypeMap.get(newRecordType).Id;
				currentRecordType = 'MileStoneCard';
				deleteSMIds.add(kanban.Id);
			} else if (newRecordType == 'FolderCard' && currentRecordType == 'ActivityCard' && kanban.leankor__PredecessorDependencies__r.size() == 0 && kanban.leankor__SuccessorDependencies__r.size() == 0) {
				// If activity has dependency in that case we can not convert that into AG.
				kanban.RecordTypeId = recordTypeMap.get(newRecordType).Id;
				currentRecordType = 'FolderCard';
				deleteSMIds.add(kanban.Id);
			} else if (newRecordType == 'ActivityCard' && currentRecordType == 'MileStoneCard') { 
				kanban.RecordTypeId = recordTypeMap.get(newRecordType).Id;
				currentRecordType = 'ActivityCard';
				createSMIds.add(kanban.Id);
			}
		}

		// Calucation according schedule mode. But if record type changed we don't need to do that.
		if (currentRecordType == 'ActivityCard') {
			leankor__ScheduleMode__c scheduleMode = kanban.leankor__ScheduleModes__r.size() > 0 ? kanban.leankor__ScheduleModes__r : null;
			if (scheduleMode != null && scheduleMode.leankor__Mode__c == 'EffortDriven') {
				kanban.leankor__DueDateTime__c = workWeek.getKanbanCardDueDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__StartDateTime__c);
				kanban.leankor__EstimatedDuration__c =  kanban.leankor__EstimatedDuration__c;
				kanban.leankor__DurationUnits__c = kanban.leankor__DurationUnits__c;
				return;
			}
		}

		kanban.leankor__DurationUnits__c = (request.DurationUnits == null ? kanban.leankor__DurationUnits__c : request.DurationUnits);
		kanban.leankor__EstimatedDuration__c = workWeek.getBusinessDays(kanban.leankor__StartDateTime__c.date(), kanban.leankor__DueDateTime__c.date()) + 1;
		if (kanban.leankor__valueStream__r.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
			Integer index = 0;
			Integer count = 0;
			DateTime tempStartDate = kanban.leankor__StartDateTime__c;
			while (index < kanban.leankor__EstimatedDuration__c) {
				if (!(Util.weekDays.contains((tempStartDate).format('E')))) {
					count++;
				}
				index++;
				tempStartDate = tempStartDate.addDays(1);
			}
			kanban.leankor__EstimatedDuration__c = count;
		}

		if (!(request.DueDate != null && request.StartDate != null)) {
			if (currentRecordType == 'MileStoneCard') {
				kanban.leankor__EstimatedDuration__c = 0;
			} else {
				kanban.leankor__EstimatedDuration__c = request.EstimatedDuration == null ? kanban.leankor__EstimatedDuration__c : request.EstimatedDuration == 0 ? 1 : request.EstimatedDuration;
			}
		}
		// If RecordType is FolderCard then we are not updating Estimated Duration more than one.   
		if (currentRecordType == 'FolderCard') {
			kanban.leankor__EstimatedDuration__c = 1;
		} 

		if (request.StartDate == null && request.DueDate != null) {
			kanban.leankor__StartDateTime__c = workWeek.getKanbanCardStartDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c == 0 ? 1 : kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__DueDateTime__c);
		} else {
			kanban.leankor__DueDateTime__c = WorkWeek.getKanbanCardDueDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c == 0 ? 1 : kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__StartDateTime__c);
		}
		if (currentRecordType == 'MileStoneCard') {
			kanban.leankor__EstimatedDuration__c = 0;
			kanban.leankor__StartDateTime__c = kanban.leankor__DueDateTime__c;
		}
	}

	
	// Input Invocable variable for API calls
	global class KanbanCardRequest { 
	    @InvocableVariable(label='AcceptanceCriteria' description='Kanban Card Record for Acceptance Criteria.')
	    global String AcceptanceCriteria;
	    @InvocableVariable(label='Custom Card Id' description='Custom Card Id.')
	    global String CardID;  
	    @InvocableVariable(label='Kanban Card Id' description='Kanban Card Record Id.' required=true)
	    global String Id;
	    @InvocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
	    global String CardURL;
	    @InvocableVariable(label='Title' description='The title that appears on the front of the Card.')
	    global String Title;
	    @InvocableVariable(label='Point' description='Point of the Card.' )
	    global Decimal Point;
	    @InvocableVariable(label='Top' description='Top screen coordinate of the Card.' )
	    global Decimal Top;
	    @InvocableVariable(label='Bottom' description='Bottom screen coordinate of the Card.')
	    global Decimal Bottom;
	    @InvocableVariable(label='Left' description='Left screen coordinate of the Card.')
	    global Decimal Left;
	    @InvocableVariable(label='Width' description='Width of the Card (only applies to Whiteboard).')
	    global Decimal Width;
	    @InvocableVariable(label='Height' description='Height of the Card (only applies to Whiteboard).')
	    global Decimal Height;  
	    @InvocableVariable(label='X' description='X coordinate of the Card.')
	    global Decimal X;
	    @InvocableVariable(label='Y' description='Y coordinate of the Card.')
	    global Decimal Y;
	    @InvocableVariable(label='Custom fields' description='The custom field definitions in JSON format.')
	    global String JSONDefinition; 
	    @InvocableVariable(label='Custom field values' description='The Category applied to the new Card.')
	    global String JSONData;   
	    @InvocableVariable(label='Category Name' description='Template Name for New Card' required=true)
	    global String CategoryName;   
	    @InvocableVariable(label='Description' description='A long description of the Card.' )
	    global String Description;
	    @InvocableVariable(label='Due Date' description='Due Date of the Card')
	    global DateTime DueDate;
	    @InvocableVariable(label='EstimatedDuration' description='The numerical duration or effort of the work.')
	    global Decimal EstimatedDuration;
	    @InvocableVariable(label='EffortRemaining' description='Effort Remaining on card.')
	    global Integer EffortRemaining;
	    @InvocableVariable(label='DurationUnits' description='Must be either Minutes, Days, Months or Years.')
	    global String DurationUnits;    
	    @InvocableVariable(label='Priority' description='Must be 0 for lowest priority and 2 for highest priority.')
	    global Integer Priority;    
	    @InvocableVariable(label='OwnerID' description='Must be 0 for lowest priority and 2 for highest priority.')
	    global ID OwnerID;
	    @InvocableVariable(label='Percent Complete' description='The percent of a Card that is completed. Represented as a value of 1, 25, 50, 75 or 100' )
	    global Decimal HarveyBall;  
	    @InvocableVariable(label='Linked Kanban Card Id' description='The Card ID to which this card is linked.')
	    global String ValueStreamCardLink;
	    @InvocableVariable(label='Linked Project Board Id' description='The Project Board ID on which the Linked Kanban Card is located.')
	    global String ValueStreamLinkID;   
	    @InvocableVariable(label='Account ID' description='The ID of the Account linked to this Card.' )
	    global String Account;
	    @InvocableVariable(label='Opportunity ID' description='The ID of the Opportunity linked to this Card.')
	    global String Opportunity;
	    @InvocableVariable(label='Contact ID' description='The ID of the Contact linked to this Card.')
	    global String Contact;
	    @InvocableVariable(label='Case ID' description='The ID of the Case linked to this card.')
	    global String CaseID;
	    @InvocableVariable(label='Order' description='The Card order in the column on the Board.')
	    global Decimal Order;
	    @InvocableVariable(label='OnBudget' description='Does the Card represent work that is on Budget? Green, Amber or Red.')
	    global String OnBudget;
	    @InvocableVariable(label='OnQuality' description='Does the Card represent work that is on Quality? Green, Amber or Red.')
	    global String OnQuality;
	    @InvocableVariable(label='OnTime' description='Does the Card represent work that is on Time? Green, Amber or Red.')
	    global String OnTime;
	    @InvocableVariable(label='URL Link' description='URL link field in kanbanCard')
	    global String URLlink;	    
	    @InvocableVariable(label='Start Date' description='The Start Date of the work represented by the Card.')
	    global DateTime StartDate;
	    @InvocableVariable(label='HarveyBall Done Date' description='HarveyBall status complete Date')
        global Date HarveyBallDoneDate;
        @InvocableVariable(label='Promise Completion Date ' description='Promise Completion Date of card')
    	global DateTime PromiseCompletionDate;	    
    	@InvocableVariable(label='Is Kanban Card At Risk' description='check AtRisk  of card')
    	global Boolean IsAtRisk;	
    	@InvocableVariable(label='Is Kanban Card On Hold' description='check OnHold of card')
    	global Boolean IsOnHold;	        
        @InvocableVariable(label='Name' description='Name of kanban card')
		global String Name; 
		@InvocableVariable(label='Record Type Name' description='Kanban Card RecordType Name.')
	    global String RecordTypeName;
	}

	// 29/09/2020 - This method used for get custom labels translation values lightning component. 
	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static Map<String, String> getLabelsForConsumers(String componentName) {
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', componentName};
        
        return leankor.LabelProvider.getLabelsForConsumers(consumers);
    }
}