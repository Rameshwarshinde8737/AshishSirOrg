/**
 * Company : Leankor
 * FILE : CreateKanbanCard.cls
 * CLASS : CreateKanbanCard
 * USAGE : Helper class of MultipleCreateKanbanCardAction.cls.
 */
public with sharing class CreateKanbanCard {

	// We are not updating leankor__IsSuccessorRecalculate__c for parent folder at updateParentCards(). So we have to do that here.
	private static Set<String> folderCards = new Set<String>();
	public static List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();

	
	// Default Constructor
    public CreateKanbanCard() {
		
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to move kanban cards.
    Inputs:         List<MultipleCreateKanbanCardAction.KanbanCardRequest> kanbanCardRequest
    Returns:        List<leankor__KanbanCard__c>
    ------------------------------------------------------------*/
	public static List<leankor__KanbanCard__c> createKanbanCard(List<MultipleCreateKanbanCardAction.KanbanCardRequest> kanbanCardRequest) {
		List<leankor__KanbanCard__c> newKanbanCardList = new List<leankor__KanbanCard__c>();
		for (MultipleCreateKanbanCardAction.KanbanCardRequest request : kanbanCardRequest) {
			// Calling the method and assigning the created card list to result
			newKanbanCardList.AddAll(createKanbanCard(request)); 
		}
		return newKanbanCardList;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Overloaded method of createKanbanCard.
    Inputs:         Object of MultipleCreateKanbanCardAction.KanbanCardRequest class.
    Returns:        List of Kanban Card.
    ------------------------------------------------------------*/
    public static List<leankor__KanbanCard__c> createKanbanCard(MultipleCreateKanbanCardAction.KanbanCardRequest request) {
		List<leankor__KanbanCard__c> newKanbanCardList = new List<leankor__KanbanCard__c>();

    	try {  	
			// Ramanand : 07/05/2021 - Changes: Insert platform event for multiple API's
			System.enqueueJob(new CreateKanbanCardsQueueable(request, true));
		} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		} 

		return newKanbanCardList;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Helper method for create kanban card.
    Inputs:         RealTimeController.Kanban remoteKanban, leankor__KanbanCard__c kanban, leankor__ValueStream__c valueStream, Map<Id,RecordType> recordTypeMap, Util.WorkWeek workWeek
    Returns:        -
    ------------------------------------------------------------*/
	public static void createKanbanCardHelper(RealTimeController.Kanban remoteKanban, leankor__KanbanCard__c kanban, leankor__ValueStream__c valueStream, Map<Id,RecordType> recordTypeMap, Util.WorkWeek workWeek) {
		// Get the next working day
		remoteKanban.StartDate = workWeek.getNextWorkingDay((kanban.leankor__StartDateTime__c == null ? System.now() : kanban.leankor__StartDateTime__c));
		remoteKanban.DueDate = workWeek.getNextWorkingDay((kanban.leankor__DueDateTime__c == null ? System.now() : kanban.leankor__DueDateTime__c));
		
		// Throw an error when start date fall after due date
		if ((remoteKanban.StartDate > remoteKanban.DueDate) 
			&& (kanban.leankor__EstimatedDuration__c == null || (kanban.leankor__DueDateTime__c != null && kanban.leankor__StartDateTime__c != null))) {
			//throw new Util.LeanException('Given start date fall after the due date.');
			remoteKanban.DueDate = remoteKanban.StartDate;
		}

		// Get the card and board record type
		if (String.isBlank(kanban.recordTypeId)) {
			remoteKanban.ItemType = 'ActivityCard';
		} else if (recordTypeMap.containsKey(kanban.recordTypeId)) {
			remoteKanban.ItemType = recordTypeMap.get(kanban.recordTypeId).Name;
		} else {
			throw new Util.LeanException('Wrong record type id provided'); 
		}

		// Throw and exception when user trying to create AG on non-uber board
		if (valueStream.leankor__BoardType__c != 'UberBoard' && remoteKanban.ItemType == 'FolderCard') {
			throw new Util.LeanException('You can\'t create the Activity Group on this board');
		}

		// Assigning the estimate duration for the Card
		if (remoteKanban.ItemType == 'MileStoneCard') {
			remoteKanban.EstimatedDuration = 0;
			remoteKanban.StartDate = kanban.leankor__DueDateTime__c != null ? remoteKanban.DueDate : remoteKanban.StartDate;
		} else if (remoteKanban.ItemType == 'FolderCard') {
			remoteKanban.EstimatedDuration = 1;
		} else {
			remoteKanban.EstimatedDuration = kanban.leankor__StartDateTime__c != null && kanban.leankor__DueDateTime__c != null
				? workWeek.getBusinessDays(remoteKanban.StartDate.date(), remoteKanban.DueDate.date()) + 1
				: kanban.leankor__EstimatedDuration__c != null ? kanban.leankor__EstimatedDuration__c: workWeek.getBusinessDays(remoteKanban.StartDate.date(), remoteKanban.DueDate.date()) + 1;        
			
			remoteKanban.EstimatedDuration = (remoteKanban.EstimatedDuration > 0) ? remoteKanban.EstimatedDuration : 1;
		}
		
		if (valueStream.leankor__BoardType__c != 'UberBoard') {
			remoteKanban.EffortRemaining = integer.valueof(kanban.leankor__EffortRemaining__c == null ? remoteKanban.EstimatedDuration :kanban.leankor__EffortRemaining__c);
		}

		if (kanban.leankor__StartDateTime__c == null && kanban.leankor__DueDateTime__c != null) {
			// If due date and ED given then calculate the start date. Backward calculation
			remoteKanban.StartDate = workWeek.getKanbanCardStartDate(Integer.valueOf(remoteKanban.EstimatedDuration == 0 ? 1 : remoteKanban.EstimatedDuration), remoteKanban.DurationUnits, remoteKanban.DueDate);
		} else {
			remoteKanban.DueDate = workWeek.getKanbanCardDueDate(Integer.valueOf(remoteKanban.EstimatedDuration), remoteKanban.DurationUnits, remoteKanban.StartDate);
		}		
	}


	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Create ResourceAssignment/ScheduleMode object instance.
    Inputs:         Object of RealTimeController.Kanban remoteKanban class.
    Returns:        -
    ------------------------------------------------------------*/
	public static void createResourceAssignmentScheduleMode(RealTimeController.Kanban remoteKanban) {

		if (remoteKanban.ItemType == 'ActivityCard' && (remoteKanban.BoardType != 'UberBoard' || remoteKanban.autoAssignResource)) {
			leankor__ResourceAssignment__c resourceAssignment = 
				new leankor__ResourceAssignment__c(
					leankor__AssignedTo__c = remoteKanban.OwnerID,
					leankor__PercentAllocation__c = 100,
					leankor__PercentCompleted__c = Integer.valueof(remoteKanban.HarveyBall),
					leankor__CompletedDate__c = (Integer.valueof(remoteKanban.HarveyBall) == 100 ? remoteKanban.DueDate : null) 
				);			
			remoteKanban.resourceAssignmentList = new List<leankor__ResourceAssignment__c> {resourceAssignment};  			
		}
		// RK - 01/27/2021 - Changes : With the constraint feature now we need schedule mode record for all record types. 
		//Changes : Check constraint setting enable or not.
		if (remoteKanban.ItemType != 'FolderCard') {
			leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c(OwnerId = remoteKanban.OwnerID);
			remoteKanban.schedulemodeList = new List<leankor__ScheduleMode__c>{scheduleMode};
		}	
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Project Boards.
    Inputs:         Set<String> boardIds, Map<String,leankor__ValueStream__c> boardMap, Map<String,Integer> cardOrderMap
    Returns:        List<leankor__ValueStream__c>.
    ------------------------------------------------------------*/
	public static List<leankor__ValueStream__c> readProjectBoards(Set<String> boardIds, Map<String,leankor__ValueStream__c> boardMap, Map<String,Integer> cardOrderMap) {
		List<leankor__ValueStream__c> valueStreams =
			[Select Id, 
					Name, 
					leankor__SevenDayWorkWeek__c, 
					leankor__BoardType__c, 
					leankor__ProjectRoom__c,
					leankor__ProjectRoom__r.leankor__AutoAssignResource__c,
					leankor__IsScheduleRecalculate__c,
					(Select Id 
						From leankor__Kanbans__r 
						Where leankor__IsRecordDeleted__c = false
					) 
				From leankor__ValueStream__c 
				Where (Id In :boardIds Or Name In :boardIds)
					And leankor__isRecordDeleted__c = false
				With Security_Enforced 
				Limit 50000];
		// Clear the board Id so that we can remove the boards name from this list.
		boardIds.clear();					
		// Remove items with leankor__ProjectRoom__c == null
		Integer index = 0;
		while (index < valueStreams.size()) {
			if (valueStreams.get(index).leankor__ProjectRoom__c == null) {
				valueStreams.remove(index);
			} else {
				leankor__ValueStream__c vs = valueStreams.get(index);
				boardMap.put(vs.Id, vs);
				boardMap.put(vs.name, vs);
				boardIds.add(vs.Id);
				cardOrderMap.put(vs.Id, vs.leankor__Kanbans__r.size());
				index++;
			}
		}

		return valueStreams;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Get Linked cards in map.
    Inputs:         Set<String> linkedCardIds
    Returns:        Map<Id, leankor__KanbanCard__c>.
    ------------------------------------------------------------*/
	public static Map<Id, leankor__KanbanCard__c> getLinkedCardMap(Set<String> linkedCardIds) {
		Map<Id, leankor__KanbanCard__c> linkedCardMap = new Map<Id, leankor__KanbanCard__c>();
		leankor__ScheduleMode__c schedule;

		for (leankor__KanbanCard__c kanban: readLinkedCards(linkedCardIds)) {
			schedule = kanban.leankor__ScheduleModes__r.size() > 0 ? kanban.leankor__ScheduleModes__r : null;
			if (!(schedule != null && schedule.leankor__Mode__c == 'EffortDriven' && kanban.leankor__BoardType__c == 'UberBoard')) {
				linkedCardMap.put(kanban.Id, kanban);
			}
		}

		return linkedCardMap;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Get Linked cards in list.
    Inputs:         Set<String> linkedCardIds
    Returns:        List<leankor__KanbanCard__c>.
    ------------------------------------------------------------*/
	@TestVisible
	private static List<leankor__KanbanCard__c> readLinkedCards(Set<String> linkedCardIds) {
		return [Select Id,
						leankor__ValueStream__c,
						RecordType.Name,
						leankor__BoardType__c,
						(Select Id, 
								leankor__Mode__c 
							From leankor__ScheduleModes__r
							Limit 1) 
				From leankor__KanbanCard__c
				Where Id In :linkedCardIds
					And leankor__isRecordDeleted__c = false
					And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
				With Security_Enforced
				Limit 50000];
	}
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Kanban Card Templates
    Inputs:         Set<String> boardIds
    Returns:        Map<String, leankor__KanbanCardTemplate__c>.
    ------------------------------------------------------------*/
	public static Map<String, leankor__KanbanCardTemplate__c> readKanbanCardTemplates(Set<String> boardIds) {
		Map<String, leankor__KanbanCardTemplate__c> kanbanTemplateMap = new Map <String, leankor__KanbanCardTemplate__c>();
		
		for (leankor__KanbanCardTemplate__c kanbanTemplate: 
			[Select Id, 
					Name, 
					leankor__Color__c, 
					leankor__Height__c, 
					leankor__JSONData__c, 
					leankor__JSONDefinition__c, 
					leankor__Width__c, 
					leankor__ValueStream__c, 
					leankor__Title__c 
				From leankor__KanbanCardTemplate__c
				Where leankor__ValueStream__c In :boardIds 
					And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
				With Security_Enforced
				Order By leankor__Title__c ASC 
				Limit 50000]) {
			
			kanbanTemplateMap.put(kanbanTemplate.Id, kanbanTemplate);
			// Here key is made of (valueStreamId+Name). Case when card are create on same board with different category.
			kanbanTemplateMap.put((kanbanTemplate.leankor__ValueStream__c + kanbanTemplate.Name), kanbanTemplate);
			// For Assignment of default Category.
			if (!kanbanTemplateMap.containsKey(kanbanTemplate.leankor__ValueStream__c)) {
				kanbanTemplateMap.put(kanbanTemplate.leankor__ValueStream__c, kanbanTemplate);
			}
		}	
		
		return kanbanTemplateMap;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Zones of Board.
    Inputs:         Set<String> boardIds
    Returns:        Map <Id, List<leankor__Zone__c>>.
    ------------------------------------------------------------*/
	public static Map <Id, List<leankor__Zone__c>> getBoardZones(Set<String> boardIds) {
		Map <Id, List<leankor__Zone__c>> vsZoneMap = new Map <Id, List<leankor__Zone__c>>();
		
		for (leankor__Zone__c zone : readZones(boardIds)) {
			List<leankor__Zone__c> zoneList = vsZoneMap.ContainsKey(zone.leankor__ValueStream__c) ? vsZoneMap.get(zone.leankor__ValueStream__c) : new List<leankor__Zone__c> ();
			zoneList.add(zone);
			vsZoneMap.put(zone.leankor__ValueStream__c,zoneList);
		}

		return vsZoneMap;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Zones.
    Inputs:         Set<String> boardIds
    Returns:        List<leankor__Zone__c>.
    ------------------------------------------------------------*/
	@TestVisible
	private static List<leankor__Zone__c> readZones(Set<String> boardIds) { 
		return [Select Id, 
						Name, 
						leankor__GUID__c, 
						leankor__Swimlane__c, 
						leankor__Swimlane__r.leankor__MasterContainer__c, 
						leankor__Swimlane__r.leankor__MasterContainer__r.name, 
						leankor__valuestream__c, 
						leankor__valuestream__r.leankor__BoardType__c 
					From leankor__Zone__c 
					Where leankor__ValueStream__c In :boardIds 
					With Security_Enforced
					Limit 50000];
	}
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Blackout Records.
    Inputs:         Set<String> boardIds
    Returns:        Map<Id, List<leankor__ProjectScheduleBlackout__c>>.
    ------------------------------------------------------------*/
	public static Map<Id, List<leankor__ProjectScheduleBlackout__c>> getBlackoutRecords(Set<String> boardIds) {
		Map<Id, List<leankor__ProjectScheduleBlackout__c>> vsBlackoutMap = new Map<Id, List<leankor__ProjectScheduleBlackout__c>>();

		for (leankor__ProjectScheduleBlackout__c blackOut: [Select Id,
																leankor__EndDate__c,
																leankor__StartDate__c,
																leankor__ProjectBoard__c
															From leankor__ProjectScheduleBlackout__c
															Where leankor__ProjectBoard__c In :boardIds
															With Security_Enforced
															Limit 1000]) {

			List<leankor__ProjectScheduleBlackout__c> blackOutList = vsBlackoutMap.containsKey(blackOut.leankor__ProjectBoard__c)
													? vsBlackoutMap.get(blackOut.leankor__ProjectBoard__c) 
													: new List<leankor__ProjectScheduleBlackout__c>();
			blackOutList.add(blackOut);
			vsBlackoutMap.put(blackOut.leankor__ProjectBoard__c, blackOutList);                                                
        }

		return vsBlackoutMap;   
	}
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Method calls getConstraintViolation method from KanbanController class to check if created card violates any constraints
    Inputs:         List<leankor__KanbanCard__c> checkConstraintsList, Boolean updatedCardLink
    Returns:        KanbanController.KanbanCardConstraintViolation
    ------------------------------------------------------------*/
	public static KanbanController.KanbanCardConstraintViolation checkConstraintValidation(List<leankor__KanbanCard__c> checkConstraintsList, Boolean updatedCardLink) {
		KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
		Boolean constraintsEnabled = Boolean.valueOf(leankor__LeanConstants__c.getInstance(UserInfo.getProfileId()).get('leankor__AllowSchedulingConstraints__c'));
		
		if (constraintsEnabled) {
			List<KanbanCard> cardsToCheck = new List<KanbanCard>();
			Boolean checkDepConst = false;

			for (leankor__KanbanCard__c req : checkConstraintsList) { 
				if (req.leankor__DueDateTime__c == null && req.leankor__StartDateTime__c == null && req.leankor__EstimatedDuration__c == null) {
					continue;
				}

				KanbanCard checkCard = new KanbanCard();
				checkCard.id = req.Id;
				checkCard.name = req.Name;
				checkCard.valueStream = req.leankor__ValueStream__c;
				checkCard.startDateTime = req.leankor__StartDateTime__c;
				checkCard.dueDateTime = req.leankor__DueDateTime__c; 
				checkCard.estimatedDuration = req.leankor__EstimatedDuration__c; 
				checkCard.boardType = req.leankor__ValueStream__r.leankor__BoardType__c;

				if (updatedCardLink == true) {
					checkCard.isUpdateValueStreamCardLink = true;
					checkCard.valueStreamLink = req.leankor__ValueStreamLink__c;
					checkCard.valueStreamCardLink = req.leankor__ValueStreamCardLink__c;
				}

				cardsToCheck.add(checkCard);
			}  

			violationResult = KanbanController.getConstraintViolation(cardsToCheck, checkDepConst);
		} 
		return violationResult;
	} 
}