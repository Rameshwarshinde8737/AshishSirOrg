/**************************************************************************
 * Author     : Reynald Ocampo
 * Description: Sets the history of the users' activities on boards
 **************************************************************************/ 
global with sharing class SetActivityTracker implements Database.Batchable<sObject> {

	// note that variable naming standard is not followed due to Technical Debt in RealTimeTracker
	@TestVisible
	private class TrackerPackage {
		String Id;
		String Name;
		String Title;
		String ValueStreamName; // Hyper-arrive, from board
		String dl; // other info
	}

	@TestVisible
	private class ActivityTrackerDetail {
		private String detail;
		private String other;
		private Integer level;

		ActivityTrackerDetail(String detail, String other, Integer level){
			this.detail = detail;
			this.other = other;
			this.level = level;
		}
	}

	private Map<String, ActivityTrackerDetail> ACTIVITY_TRACKER_DETAILS = new Map<String, ActivityTrackerDetail>{
		'OpenValueStream' => new ActivityTrackerDetail('opened {boardType} "{boardName}"', '', 0), // ValueStream level
		'SetBaseline' => new ActivityTrackerDetail('set baseline "{itemTitle}" in {boardType} "{boardName}"', '', 1), // non-ValueStream level   
	    'CreateZone' => new ActivityTrackerDetail('created zone "{itemTitle}" in {boardType} "{boardName}"', '', 1), // non-ValueStream level          
	    'MoveZone' => new ActivityTrackerDetail('updated zone "{itemTitle}" in {boardType} "{boardName}"', '', 1), // non-ValueStream level         
        'DeleteZone' => new ActivityTrackerDetail('deleted zone "{itemTitle}" from {boardType} "{boardName}"', '', 1), // non-ValueStream level
        'CreateChart' => new ActivityTrackerDetail('created chart "{itemTitle}" in {boardType} "{boardName}"', '', 1), // non-ValueStream level
        'MoveChart' => new ActivityTrackerDetail('moved chart "{itemTitle}" in {boardType} "{boardName}"', '', 1), // non-ValueStream level
        'DeleteChart' => new ActivityTrackerDetail('deleted chart from {boardType} "{boardName}"', '', 1), // non-ValueStream level
	    'Hyper-arrive' => new ActivityTrackerDetail('hyperjumped {itemType} "{itemName}" from board "{boardNameFrom}" to board "{boardName}"', '', 2), // KBC level
		'CreateKanbanCard' => new ActivityTrackerDetail('created {itemType} "{itemName}" in {boardType} "{boardName}"', '', 2), // KBC level
		'UpdateKanbanCard' => new ActivityTrackerDetail('updated {itemType} "{itemName}" in {boardType} "{boardName}"', ' [changed "{itemField}"]', 2), // KBC level
		'MoveKanbanCard' => new ActivityTrackerDetail('moved {itemType} "{itemName}" in {boardType} "{boardName}"', '', 2), // KBC level
		'DeleteKanbanCard' => new ActivityTrackerDetail('deleted {itemType} "{itemName}" from {boardType} "{boardName}"', '', 2) // KBC level
	};

	private final Map<String, String> BOARD_TYPES = new Map<String, String> {
		'UberBoard' => 'Project Gantt', 
		'Kanban Board' => 'Kanban Board', 
		'Plan Board' => 'Rollup Board', 
		'DashBoard' => 'Dashboard',
		'Whiteboard' => 'Whiteboard'        
	};

	private final Map<String, String> ITEM_TYPES = new Map<String, String> {
		'ActivityCard' => 'activity',
		'MileStoneCard' => 'milestone', 
		'FolderCard' => 'activity group',
		'KanbanCard' => 'card'
	};

	private final Map<String, String> ITEM_FIELDS = new Map<String, String> {
		'Name' => 'Title',
		'desc' => 'Description', 
		'prio' => 'Priority',
		'SD' => 'Start Date',
		'DD' => 'Due Date',
		'cat' => 'Category',
		'own' => 'Owner',
		'PD' => 'Percent Complete',
		'sts' => 'Status'
     };

	global Database.QueryLocator start(final Database.BatchableContext bc) {		
		Set<String> activityDetailIds = ACTIVITY_TRACKER_DETAILS.keySet();
		Set<String> boardTypesIds = BOARD_TYPES.keySet();
		return Database.getQueryLocator(
            'Select ' +
			'Id, ' +
            'CreatedById, ' +
            'CreatedDate, ' +
            'CreatedBy.Name, ' +
            'leankor__KanbanVerb__c, ' +
            'leankor__ValueStream__c, ' +
            'leankor__ValueStream__r.Name, ' +
			'leankor__ValueStream__r.leankor__BoardType__c, ' +
			'leankor__ActivityTracked__c, ' +
            'leankor__JSONDataSmall__c, ' +
            'leankor__JSONDataSmall2__c, ' +
            'leankor__JSONDataSmall3__c, ' +
            'leankor__JSONDataSmall4__c, ' +
            'leankor__JSONDataSmall5__c, ' +
            'leankor__JSONDataSmall6__c, ' +
            'leankor__JSONDataSmall7__c, ' +
            'leankor__JSONDataSmall8__c ' +
            'From leankor__RealtimeTracker__c ' +
            'Where leankor__KanbanVerb__c In :activityDetailIds ' +
			'And leankor__ValueStream__r.leankor__BoardType__c In :boardTypesIds ' +
            'And leankor__ActivityTracked__c = false ' +
            'Order By CreatedDate Desc'
		);
	}


	global void execute(final Database.BatchableContext bc, final List<leankor__RealtimeTracker__c> realTimeTrackers) {
		//Check CRUD / FLC behavior
		RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
		ActivityTrackerBehaviour ActivityTrackerBehaviour = new ActivityTrackerBehaviour();
		if (!realtimeTrackerBehavior.isUpdateable() ||
			!ActivityTrackerBehaviour.isCreateable()) {
			System.abortJob(bc.getJobId());
		}
		//Check CRUD / FLC behavior

		Set<Id> kanbanCardIds = new Set<Id>();
    	List<leankor__ActivityTracker__c> activityTrackers = new List<leankor__ActivityTracker__c>();
	
		setActivityTrackerRecord(kanbanCardIds, activityTrackers, realTimeTrackers);
		setActivityTrackerRecord(kanbanCardIds, activityTrackers);

		if (activityTrackers.size() > 0) {
			Database.insert(activityTrackers, false); // allow partial insert
			Database.update(realtimeTrackers, false); // allow partial update
		}
    }

    global void finish(final Database.BatchableContext bc) {
    }

	// To fetch associated KBC records for more info
	// Note that recordtype name (MileStoneCard, ActivityCard, FolderCard) KBC name can be recorded into any of the JSONData fields of RealTimeTracker
	// If this is consistently done then there is no need to query the KanbanCard to get into the recordtype name or KBC name
	// KanbanCard reference is also added to the ActivityTracker which will allow more information for reporting purposes 
	// pass by reference
	@TestVisible
	private void setActivityTrackerRecord(Set<Id> kanbanCardIds, List<leankor__ActivityTracker__c> activityTrackers) {
		if (kanbanCardIds.size() > 0) {
			Map<Id, leankor__KanbanCard__c> kanbanCards = new Map<Id, leankor__KanbanCard__c>(
				[Select Id, 
						Name,
						RecordType.Name,
						leankor__BoardType__c
					From leankor__KanbanCard__c
					Where Id In :kanbanCardIds]);
				
			for (leankor__ActivityTracker__c activityTracker : activityTrackers) {
				if (activityTracker.leankor__KanbanCard__c != null && String.isNotBlank(activityTracker.leankor__ActivityDetail__c)) {
					leankor__KanbanCard__c kanbanCard = kanbanCards.get(activityTracker.leankor__KanbanCard__c);
					if (kanbanCard != null) {
		                String itemType = ITEM_TYPES.get((kanbanCard.RecordType.Name == 'ActivityCard' && kanbanCard.leankor__BoardType__c != 'UberBoard') ? 'KanbanCard' : kanbanCard.RecordType.Name);
						activityTracker.leankor__ActivityDetail__c = activityTracker.leankor__ActivityDetail__c.replace('{itemType}', String.isBlank(itemType) ? '' : itemType).replace('{itemName}', kanbanCard.Name);
					}
				}
			}
		}		
	}

	// overloaded
	// pass by reference
	@TestVisible
	private void setActivityTrackerRecord(Set<Id> kanbanCardIds, List<leankor__ActivityTracker__c> activityTrackers, List<leankor__RealTimeTracker__c> realTimeTrackers) {
		for (leankor__RealTimeTracker__c realTimeTracker : realTimeTrackers) {
            if (realTimeTracker.leankor__ValueStream__c != null) {
				Id kanbanCardId = null;
				String itemTitle = '';
				String itemField = '';
				String realTimeTrakerRecord = '';
				String boardNameFrom = '';
				String boardType = BOARD_TYPES.get(realTimeTracker.leankor__ValueStream__r.leankor__BoardType__c);
				ActivityTrackerDetail activityTrackerDetail = ACTIVITY_TRACKER_DETAILS.get(realTimeTracker.leankor__KanbanVerb__c);

				// all activities that are not ValueStream levels
				if (activityTrackerDetail != null && activityTrackerDetail.level > 0) {
					realTimeTrakerRecord = 
						(String.isBlank(realTimeTracker.leankor__JSONDataSmall__c) ? '' : realTimeTracker.leankor__JSONDataSmall__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall2__c) ? '' : realTimeTracker.leankor__JSONDataSmall2__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall3__c) ? '' : realTimeTracker.leankor__JSONDataSmall3__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall4__c) ? '' : realTimeTracker.leankor__JSONDataSmall4__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall5__c) ? '' : realTimeTracker.leankor__JSONDataSmall5__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall6__c) ? '' : realTimeTracker.leankor__JSONDataSmall6__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall7__c) ? '' : realTimeTracker.leankor__JSONDataSmall7__c) 
						+ ''
						+ (String.isBlank(realTimeTracker.leankor__JSONDataSmall8__c) ? '' : realTimeTracker.leankor__JSONDataSmall8__c); 

					if (String.isNotBlank(realTimeTrakerRecord)) {
						TrackerPackage tracker = (TrackerPackage)JSON.deserialize(realTimeTrakerRecord, TrackerPackage.class);
						// KBC level
						if (tracker.Id != null && activityTrackerDetail.level == 2) {
							// this object is used to fetch addtional KBC info which are currently not in RealTimeTracker
							// Id is expected to be of type KanbanCard object, otherwise an exception will occur during insert to ActivityTracker
							kanbanCardIds.add(tracker.Id);
							kanbanCardId = tracker.Id;
						}
						itemTitle = String.isBlank(tracker.Title) ? tracker.Name : tracker.Title;
						itemField = String.isBlank(tracker.dl) ? '' : tracker.dl;
						boardNameFrom = String.isBlank(tracker.ValueStreamName) ? '' : tracker.ValueStreamName;
					}
				}

				String activityDetail = realTimeTracker.CreatedBy.Name 
					+ ' ' +
					+ activityTrackerDetail.detail
						.replace('{itemTitle}', String.isBlank(itemTitle) ? '' : itemTitle)
						.replace('{boardType}', String.isBlank(boardType) ? '' : boardType)
						.replace('{boardName}', realTimeTracker.leankor__ValueStream__r.Name)
						.replace('{boardNameFrom}', boardNameFrom)
					+ ' at ' +
					+ realTimeTracker.CreatedDate.format()
					+ (String.isBlank(itemField) ? '' : activityTrackerDetail.other
						.replace('{itemField}', getActivityField(itemField)));

				try {
					leankor__ActivityTracker__c activityTracker = new leankor__ActivityTracker__c(
						leankor__ActivitySource__c = realTimeTracker.CreatedById,
						leankor__ActivityDateTime__c = realTimeTracker.CreatedDate,
						leankor__ActivityVerb__c = realTimeTracker.leankor__KanbanVerb__c,
						leankor__ValueStream__c = realTimeTracker.leankor__ValueStream__c,
						leankor__KanbanCard__c = kanbanCardId,
						leankor__ActivityDetail__c = activityDetail
					);

					activityTrackers.add(activityTracker);	
    			} catch(Exception e) {
                	if (kanbanCardId != null) {
                    	kanbanCardIds.remove(kanbanCardId);
                	}
					//25/04/2023 : We are Throwing Exception
					throw new SetActivityTrackerException('ERROR:' + e.getMessage());
            	}
				realTimeTracker.leankor__ActivityTracked__c = true;
            }
		}
	}

	//replaces detail with the equivalent field item from the map
	@TestVisible
    private String getActivityField(String stringField) {
		List<String> listFields = stringField.split(',');
        String activityField = '';
        for (String listField : listFields) {
            String itemField = ITEM_FIELDS.get(listField);
			activityField = activityField + (String.isBlank(itemField) ? '' : itemField) + ', ';        
        }
        return activityField.removeEnd(', ');
    }

	global class SetActivityTrackerException extends Exception{}
}