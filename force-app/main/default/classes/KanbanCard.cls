global with sharing class KanbanCard {

	//At UI side they just use StartDate and DueDate variable which holds DateTime value
	//KanbanCard's DueDate, StartDate field value are converted from dateTime to Date in apex code
	public Id id {get; set;}
	public Id valueStream {get; set;}
	public Id valueStreamLink {get; set;}
	public Id valueStreamCardLink {get; set;}
	public String name {get; set;}
	public DateTime startDateTime {get; set;}
	public DateTime dueDateTime {get; set;}
	public Double estimatedDuration {get; set;}
	public Boolean isSuccessorRecalculate {get; set;}
	public Boolean isScheduleBackward {get; set;}
	public Boolean isUpdateValueStreamCardLink {get {return isUpdateValueStreamCardLink != null && isUpdateValueStreamCardLink;} set;}
	public String boardType {get; set;}
	public String boardName {get; set;}
	public Boolean notCheckConstraintOnParent {get {return notCheckConstraintOnParent != null && notCheckConstraintOnParent;} set;}

	//Extra field added as pr UI requirement.
	public String itemType {get; set;}
	public String projectID {get; set;}

	//Default Constructor
	public KanbanCard() {
		
	}

	//Create stub method
	public void createKanbanCards() {
		//stub
	}

	//Read stub method
	public void readKanbanCards() {
		//stub
	}

	// locks all queried records for update
	// returns a list of KBC with its SM and successors, filtered by kanbanCardIds
	public static List<leankor__KanbanCard__c> readKanbanCards(Set<Id> kanbanCardIds) {
		// lock all records during this transaction
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                        Name,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__ValueStream__c,
														leankor__ValueStreamLink__c,
														leankor__ValueStreamCardLink__c,
														leankor__ValueStreamCardLink__r.leankor__ValueStream__c,
														leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
														leankor__ValueStream__r.leankor__BoardType__c,
														leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                                        (Select leankor__ManuallyScheduled__c,
                                                                leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                leankor__ScheduleConstraint__r.leankor__Description__c,
                                                                leankor__ConstraintDateTime__c
                                                            From leankor__ScheduleModes__r
                                                            Order By LastModifiedDate Desc 
                                                            Limit 1),
                                                        (Select leankor__Successor__c,
                                                                leankor__SuccessorType__c
                                                            From leankor__PredecessorDependencies__r),
                                                    	RecordTypeId,
                                                    	RecordType.Name,leankor__KanbanCardTemplate__r.Name,
														leankor__kanbanCardTemplate__r.Color__c,
														leankor__GUID__c,
														leankor__Order__c,
														leankor__PercentComplete2__c,
														leankor__EstimatedDuration__c,
														leankor__DurationUnits__c,
														leankor__CardId__c,
														leankor__KanbanCardTemplate__c,
														leankor__Priority__c,
														leankor__IsAtRisk__c,
														leankor__DescriptionLong__c,
														OwnerId,
														Owner.Name,
														leankor__IsExternallyDependent__c,
														leankor__IsSuccessorRecalculate__c,
														leankor__HarveyBallDoneDate__c,
														leankor__PromiseCompletionDate__c,
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
													Where Id In :kanbanCardIds
                                                        And leankor__IsRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
													With Security_Enforced
                                                    Limit 50000
                                                    For Update];

		// remove deleted records
		removeDeletedKanbanCards(kanbanCards);
		
        return kanbanCards;
    }

	// locks all queried records for update
	// returns a list of KBC with its SM and successors, filtered by kanbanCardIds and recordTypeNames
	public static List<leankor__KanbanCard__c> readKanbanCards(Set<Id> kanbanCardIds, Set<String> recordTypeNames) {
		// lock all records during this transaction
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                        Name,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__ValueStream__c,
														leankor__ValueStreamLink__c,
														leankor__ValueStreamCardLink__c,
														leankor__ValueStreamCardLink__r.leankor__ValueStream__c,
														leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
														leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
														leankor__ValueStream__r.leankor__BoardType__c,
														leankor__ValueStream__r.Name,
                                                        (Select leankor__ManuallyScheduled__c,
                                                                leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                toLabel(leankor__ScheduleConstraint__r.leankor__Description__c),
                                                                leankor__ConstraintDateTime__c
                                                            From leankor__ScheduleModes__r
                                                            Order By LastModifiedDate Desc 
                                                            Limit 1),
                                                        (Select leankor__Successor__c,
                                                                leankor__SuccessorType__c
                                                            From leankor__PredecessorDependencies__r),
                                                    	RecordTypeId,
                                                    	RecordType.Name
                                                    From leankor__KanbanCard__c
													Where Id In :kanbanCardIds
														And RecordType.Name In :recordTypeNames
                                                        And leankor__IsRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
													With Security_Enforced
                                                    Limit 50000
                                                    For Update];

		// remove deleted records
		removeDeletedKanbanCards(kanbanCards);

        return kanbanCards;
    }


	// overloaded, with a list parameter type
    public static List<leankor__KanbanCard__c> readKanbanCards(List<leankor__KanbanCard__c> workItems) {
		// lock all records during this transaction
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                        leankor__ValueStream__c,
														leankor__ValueStreamLink__c,
														leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
														leankor__ValueStreamLink__r.leankor__ProjectRoom__c
                                                    From leankor__KanbanCard__c 
                                                    Where Id In :workItems
                                                        And leankor__IsRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                    With Security_Enforced
                                                    Limit 50000
                                                    For Update];
		// remove deleted records
		removeDeletedKanbanCards(kanbanCards);

        return kanbanCards;
    }


	//Update method
	public static List<leankor__KanbanCard__c> updateKanbanCards(final List<leankor__KanbanCard__c> serverUpdateKanbanCards) {
		
		//Check CRUD / FLC behavior   
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!KanbanCardBehaviour.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior 
		
		try{
			Database.update(serverUpdateKanbanCards);
		}catch(Exception e) {
			//25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return serverUpdateKanbanCards;
	}


	//Delete stub method
	public void deleteKanbanCards() {
		//stub
	}


	// pass by reference
	public static void removeDeletedKanbanCards(List<leankor__KanbanCard__c> kanbanCards) {
		// remove deleted records
        for (Integer index = kanbanCards.size() - 1; index >= 0; index--) {
            leankor__KanbanCard__c kanbanCard = kanbanCards.get(index);
            if (kanbanCard.leankor__ValueStream__c == null 
            || kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c == null) {
                kanbanCards.remove(index);
            }
			if(kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? False : (kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c != kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c)){
				kanbanCard.leankor__ValueStreamLink__c = null;
				kanbanCard.leankor__ValueStreamCardLink__c = null;
			}
        }
	}

	public class KanbanCardPayload {
		
		public String Id;
        public String Name;
        public String Title;
        public String GUID;
        public Decimal Order;
        public DateTime StartDate;
        public DateTime DueDate;
        public Decimal PercentDone;
        public Decimal EstimatedDuration;
        public String DurationUnits; 
        public String CardID;
        public String TemplateID;
        public Integer Priority;
        public String Description;
        public String ValueStreamCardLink;
        public String ValueStreamLinkID;
        public String OwnerID;
        public String ItemType;
        public String Color;
        public Boolean IsExternallyDependent;
        public Boolean IsSuccessorRecalculate;
        public Date HarveyBallDoneDate;
        public DateTime PromiseCompletionDate;
        public Boolean isConstraintRecalculate;
        public Boolean Monday;
        public Boolean Tuesday;
        public Boolean Wednesday;   
        public Boolean Thursday;
        public Boolean Friday;
        public Boolean Saturday;
        public Boolean Sunday;
        public String weekCalendar;
		public String valueStreamId;
		public String OwnerName;
		public String SmallPhotoUrl;
		public Boolean isAtRisk; 
		public Integer workOrderCount;
        public Integer serviceAppointmentCount;
        public DateTime fslSchedStartDateTime;
        public DateTime fslSchedDueDateTime;
	}
	
	public static Map<Id, leankor__KanbanCard__c> getExistingKanbanCards(Set<Id> kanbanCardIds) {
		return new Map<Id, leankor__KanbanCard__c>([Select Id, 
                                                            Name,
                                                    	    recordType.Name,
                                                    	    leankor__ValueStream__r.leankor__BoardType__c,
                                                    	    leankor__ProjectRoom__c,
                                                    	    leankor__ValueStream__r.Name,
                                                    	    leankor__ValueStream__c,
                                                    	    leankor__PercentComplete2__c, 
                                                    	    leankor__HarveyBallDoneDate__c, 
                                                    	    leankor__PromiseCompletionDate__c,
                                                    	    leankor__ValueStream__r.leankor__projectRoom__c
                                                    	From leankor__KanbanCard__c 
                                                    	Where Id In :kanbanCardIds
														With Security_Enforced
                                                    	Limit 10000]);
	}
}