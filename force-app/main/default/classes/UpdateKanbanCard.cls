/**
 * Company : Leankor
 * FILE : UpdateKanbanCard.cls
 * CLASS : UpdateKanbanCard
 * USAGE : Helper class of MultipleUpdateKanbanCardAction.cls.
 */
public with sharing class UpdateKanbanCard {

	// Default Constructor
    public UpdateKanbanCard() {

	}
	
	// Used to store the KC Id's when recordtype change. Based on that we need to create or delete Schedule mode
	public static Set<Id> createScheduleModeIds = new Set<Id>(); 
	public static Set<Id> deleteScheduleModeIds = new Set<Id>();

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to update kanban cards.
    Inputs:         MultipleUpdateKanbanCardAction.KanbanCardRequest request
    Returns:        -
    ------------------------------------------------------------*/
	public static void updateKanbanCards(MultipleUpdateKanbanCardAction.KanbanCardRequest request) {
		try {  	
			System.enqueueJob(new UpdateKanbanCardsQueueable(request));
		} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to update is IsScheduleRecalculate to true.
    Inputs:         Set<String> valueStreamIds
    Returns:        -
    ------------------------------------------------------------*/
	public static void updateValueStream(Set<String> valueStreamIds) {

		//Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

		List<leankor__ValueStream__c> vsList = [Select Id,
														leankor__IsScheduleRecalculate__c 
													From leankor__ValueStream__c 
													Where Id In :valueStreamIds
													With Security_Enforced
													Limit 10000];	
		
		for (leankor__ValueStream__c vs: vsList) {
			vs.leankor__IsScheduleRecalculate__c = true;
		}
		try {
			update vsList;
		} catch (Exception e) {
			throw new Util.LeanException('Error:' + e.getMessage());
		}          
	} 

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read kanban cards in map.
    Inputs:         List<String> kanbanCardIds, Map<Id, Util.WorkWeek> workWeekMap
    Returns:        Map<Id,leankor__KanbanCard__c>
    ------------------------------------------------------------*/
	public static Map<Id,leankor__KanbanCard__c> getKanbanCardMap(List<String> kanbanCardIds, Map<Id, Util.WorkWeek> workWeekMap) {
		Map<Id,leankor__KanbanCard__c> kanbanCardMap = new Map<Id,leankor__KanbanCard__c>();
		Map<Id, Boolean> vsMap = new Map<Id, Boolean>();

		for (leankor__KanbanCard__c kanban: readKanbanCards(kanbanCardIds)) {
			if (String.isNotBlank(kanban.leankor__Valuestream__c) && String.isNotBlank(kanban.leankor__ProjectRoom__c)) {
				kanbanCardMap.put(Kanban.Id, kanban);
				vsMap.put(kanban.leankor__ValueStream__c, kanban.leankor__valuestream__r.leankor__SevenDayWorkWeek__c);
			}
		}

		// Create the workweek instance and put into the map
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> blackoutMap = RealTimeControllerHelper.getBlackOutRecords(vsMap.keySet());
        for (Id vs : vsMap.keySet()) {
            Util.WorkWeek work = new Util.WorkWeek(vsMap.get(vs) ? 7: 5, blackoutMap.get(vs));
            workWeekMap.put(vs, work);
        }

        return kanbanCardMap; 
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Read kanban cards in list.
    Inputs:         List<String> kanbanCardIds
    Returns:        List<leankor__KanbanCard__c>
    ------------------------------------------------------------*/
	@TestVisible
	private static List<leankor__KanbanCard__c> readKanbanCards(List<String> kanbanCardIds) {
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!kanbanCardBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
		return [Select Id,
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
						leankor__ProjectRoom__c,
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
						Name,
						OwnerId,
						leankor__ValueStream__r.leankor__BoardType__c,
						(Select Id From leankor__PredecessorDependencies__r),
						(Select Id From leankor__SuccessorDependencies__r),
						(Select Id, leankor__AssignedTo__c From leankor__ResourceAssignments__r),
						(Select Id, leankor__Mode__c From leankor__ScheduleModes__r LIMIT 1),
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
					Limit 10000]; // Limit maximum this many record we can update at a time
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    used to create Schedule Mode for cards.
    Inputs:         Set<Id> cardIds
    Returns:        -
    ------------------------------------------------------------*/
	public static void createScheduleMode(Set<Id> cardIds) {
		//Check CRUD / FLC behavior
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		if(!scheduleModeBehavior.isCreateable()){
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		
		List<leankor__ScheduleMode__c> scheduleModeList = new List<leankor__ScheduleMode__c>();

		for (leankor__kanbancard__c kanaban : readKCScheduleMode(cardIds)) {
			leankor__ScheduleMode__c mode = new leankor__ScheduleMode__c ();                  
			mode.leankor__EffortUnits__c = kanaban.leankor__ValueStream__r.leankor__EffortUnits__c;
			mode.leankor__KanbanCard__c = kanaban.Id;
			mode.leankor__ManuallyScheduled__c = kanaban.leankor__ValueStream__r.leankor__ManuallyScheduled__c;
			mode.leankor__Mode__c = kanaban.leankor__ValueStream__r.leankor__Mode__c;
			mode.leankor__EffortActual__c = mode.leankor__Mode__c == 'EffortDriven' ? 1.0 : 0.0;
			scheduleModeList.add(mode);
		}
   
        try {
            DataBase.insert(scheduleModeList, true);
        } catch(DMLException ex) {
			throw ex;
        }
	}
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to read kanban card schedule mode.
    Inputs:         Set<Id> cardIds
    Returns:        List<leankor__kanbancard__c>
    ------------------------------------------------------------*/
	@TestVisible
	private static List<leankor__kanbancard__c> readKCScheduleMode(Set<Id> cardIds) { 
		return [Select Id,
						leankor__ValueStream__r.leankor__EffortUnits__c,
						leankor__ValueStream__r.leankor__ManuallyScheduled__c,
						leankor__ValueStream__r.leankor__Mode__c 
					From leankor__kanbancard__c 
					Where Id In :cardIds
					With Security_Enforced
					Limit 10000];
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to read Miniature Of Activity in map
    Inputs:         List<String> kanbanCardIds
    Returns:        Map<Id, leankor__KanbanCard__c>
    ------------------------------------------------------------*/
	public static Map<Id, leankor__KanbanCard__c> getMiniatureOfActivity(List<String> kanbanCardIds) {
		Map<Id, leankor__Kanbancard__c> miniatureMap = new Map<Id, leankor__Kanbancard__c>(); 
		
		for (leankor__KanbanCard__c kanban: readMiniatures(kanbanCardIds)) {
			miniatureMap.put(kanban.leankor__ValueStreamCardLink__c, kanban);								
		}

		return miniatureMap;
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to read Miniature Of Activity in list
    Inputs:         List<String> kanbanCardIds
    Returns:        List<leankor__KanbanCard__c>
    ------------------------------------------------------------*/
	@TestVisible
	private static List<leankor__KanbanCard__c> readMiniatures(List<String> kanbanCardIds) {
		return [Select Id, 
						leankor__ValueStreamCardLink__c,
						leankor__ValueStream__c
					From leankor__KanbanCard__c 
					Where leankor__ValueStreamCardLink__c In :kanbanCardIds 
						And leankor__ValueStreamCardLink__r.leankor__BoardType__c = 'UberBoard'
						And leankor__isRecordDeleted__c = false  
						And leankor__ValueStream__r.leankor__isRecordDeleted__c  = false
					With Security_Enforced
					Limit 50000];
	}	

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to delete Schedule Mode
    Inputs:         Set<Id> kanbanIdSet
    Returns:        -
    ------------------------------------------------------------*/
	public static void deleteScheduleModes(Set<Id> kanbanIdSet) {
		//Check CRUD / FLC behavior
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior(); 
		if (!scheduleModeBehavior.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();
        for (leankor__ScheduleMode__c scheduleMode : [Select Id, 
                                                            leankor__KanbanCard__c, 
                                                            leankor__ScheduleConstraint__c
															From leankor__ScheduleMode__c
															Where leankor__KanbanCard__c In :kanbanIdSet
														With Security_Enforced
                                                        Limit 10000]){

            scheduleMode.leankor__KanbanCard__c = null;
            scheduleMode.leankor__ScheduleConstraint__c = null;
            scheduleModes.add(scheduleMode);
		}
        
        if (!scheduleModes.isEmpty()) {
            try {
                update scheduleModes;
            } catch(DMLException ex) {
                System.debug('Error : while updating ScheduleMode '+ex.getMessage());
			}
        }
	}

	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Helper method for update kanban card
    Inputs:         leankor__Kanbancard__c kanban, leankor__Kanbancard__c request, Util.WorkWeek workWeek, Map<String, RecordType> recordTypeMap
    Returns:        -
    ------------------------------------------------------------*/
	public static void updateKanbanCardHelper(leankor__Kanbancard__c kanban, leankor__Kanbancard__c request, Util.WorkWeek workWeek, Map<String, RecordType> recordTypeMap) {
		String currentRecordType = kanban.RecordType.Name;
		String newRecordType = (String.isNotBlank(request.RecordTypeId) && recordTypeMap.containsKey(request.RecordTypeId)) 
							? recordTypeMap.get(request.RecordTypeId).Name : '';

		// check whether we need to change the record type
		if (kanban.leankor__BoardType__c == 'UberBoard' && String.isNotBlank(newRecordType)) {
			if (newRecordType == 'MileStoneCard' && currentRecordType == 'ActivityCard') {
				kanban.recordTypeId = request.RecordTypeId;
				currentRecordType = 'MileStoneCard';
				deleteScheduleModeIds.add(kanban.Id);
			} else if (newRecordType == 'FolderCard' && currentRecordType == 'ActivityCard' && kanban.leankor__PredecessorDependencies__r.size() == 0 && kanban.leankor__SuccessorDependencies__r.size() == 0) {
				// If activity has dependency in that case we can not convert that into AG.
				kanban.recordTypeId = request.RecordTypeId;
				currentRecordType = 'FolderCard';
				deleteScheduleModeIds.add(kanban.Id);
			} else if (newRecordType == 'ActivityCard' && currentRecordType == 'MileStoneCard') { 
				kanban.recordTypeId = request.RecordTypeId;
				currentRecordType = 'ActivityCard';
				createScheduleModeIds.add(kanban.Id);
			}
		}

		// Assign the new dates and get the next working day.
		kanban.leankor__StartDateTime__c = workWeek.getNextWorkingDay(request.leankor__StartDateTime__c == null ? kanban.leankor__StartDateTime__c : request.leankor__StartDateTime__c);
		kanban.leankor__DueDateTime__c = workWeek.getNextWorkingDay(request.leankor__DueDateTime__c == null ? kanban.leankor__DueDateTime__c : request.leankor__DueDateTime__c);
		
		// Calculation according schedule mode. But if record type changed we don't need to do that.
		if (currentRecordType == 'ActivityCard') {
			leankor__ScheduleMode__c scheduleMode = kanban.leankor__ScheduleModes__r.size() > 0 ? kanban.leankor__ScheduleModes__r : null;
			if (scheduleMode != null && scheduleMode.leankor__Mode__c == 'EffortDriven') {
				kanban.leankor__DueDateTime__c = workWeek.getKanbanCardDueDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__StartDateTime__c);
				kanban.leankor__EstimatedDuration__c =  kanban.leankor__EstimatedDuration__c;
				kanban.leankor__DurationUnits__c = kanban.leankor__DurationUnits__c;
				return;
			}
		}

		
		if ((kanban.leankor__StartDateTime__c > kanban.leankor__DueDateTime__c) 
			&& (request.leankor__EstimatedDuration__c == null || (request.leankor__DueDateTime__c != null && request.leankor__StartDateTime__c != null))) {
				kanban.leankor__DueDateTime__c = kanban.leankor__StartDateTime__c;
		}

		// Assign DurationUnit and EstimatedDuration
		kanban.leankor__DurationUnits__c = request.leankor__DurationUnits__c == null ? kanban.leankor__DurationUnits__c : String.valueOf(request.leankor__DurationUnits__c);
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

		if (!(request.leankor__DueDateTime__c != null && request.leankor__StartDateTime__c != null)) {
			if (currentRecordType == 'MileStoneCard') {
				kanban.leankor__EstimatedDuration__c = 0;
			} else {
				kanban.leankor__EstimatedDuration__c = request.leankor__EstimatedDuration__c == null ? kanban.leankor__EstimatedDuration__c : (request.leankor__EstimatedDuration__c == 0 ? 1 : request.leankor__EstimatedDuration__c);
			}
		}

		// If RecordType is FolderCard then we are not updating Estimated Duration more than one.   
		if (currentRecordType == 'FolderCard') {
			kanban.leankor__EstimatedDuration__c = 1;
		}

		// Calculate new DueDate or StartDate based on the request
		if (request.leankor__StartDateTime__c == null && request.leankor__DueDateTime__c != null) {
			kanban.leankor__StartDateTime__c = workWeek.getKanbanCardStartDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c == 0 ? 1 : kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__DueDateTime__c);
		} else {
			kanban.leankor__DueDateTime__c = WorkWeek.getKanbanCardDueDate(Integer.valueOf(kanban.leankor__EstimatedDuration__c == 0 ? 1 : kanban.leankor__EstimatedDuration__c), kanban.leankor__DurationUnits__c, kanban.leankor__StartDateTime__c);
		}
		
		// Calculate Date and ED for milestone
		if (currentRecordType == 'MileStoneCard') {
			kanban.leankor__EstimatedDuration__c = 0;
			kanban.leankor__StartDateTime__c = kanban.leankor__DueDateTime__c;
		}

		// Assign the new start and due date
		//kanban.leankor__StartDate__c = kanban.leankor__StartDateTime__c.date();
		//kanban.leankor__DueDate__c = kanban.leankor__DueDateTime__c.date();
	}
	
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    Method calls getConstraintViolation method from KanbanController class to check if updated card violates any constraints
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
				checkCard.valueStream = req.leankor__ValueStream__c;
				checkCard.startDateTime = req.leankor__StartDateTime__c;
				checkCard.dueDateTime = req.leankor__DueDateTime__c;
				checkCard.estimatedDuration = req.leankor__EstimatedDuration__c; 
				checkCard.boardType = req.leankor__ValueStream__r.leankor__BoardType__c;

				if (updatedCardLink == true && String.isNotBlank(req.leankor__ValueStreamLink__c) && String.isNotBlank(req.leankor__ValueStreamCardLink__c)) {
					checkCard.isUpdateValueStreamCardLink = true;
					checkCard.valueStreamLink = req.leankor__ValueStreamLink__c;
					checkCard.valueStreamCardLink = req.leankor__ValueStreamCardLink__c;
				}

				checkCard.notCheckConstraintOnParent = false;

				
				cardsToCheck.add(checkCard);
			}  

			violationResult = KanbanController.getConstraintViolation(cardsToCheck, checkDepConst);
		} 
		return violationResult;
	} 
}