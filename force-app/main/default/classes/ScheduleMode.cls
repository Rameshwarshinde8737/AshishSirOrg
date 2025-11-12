/* Copyright 2012-2021 Lucidsoft Inc. All rights reserved.
 * FILE: ScheduleMode.cls
 * CLASS: ScheduleMode
 * Description: Perform CRUD opeation on ScheduleMode
 */
public with sharing class ScheduleMode {
    public Id id {get; set;}
    public String constraintType {get; set;}
    public String constraintDescription {get; set;}
    public DateTime constraintDateTime {get; set;}
    public Boolean manuallyScheduled {get; set;}

    public Boolean isEmpty() {
        return String.isBlank(constraintType) && constraintDateTime == null;
    }

    // locks all queried records for update
    public static List<leankor__ScheduleMode__c> readScheduleModes(Set<Id> kanbanCardIds) {
        // lock all records during this transaction
        List<leankor__ScheduleMode__c> scheduleModes = [Select leankor__KanbanCard__c,
                                                            leankor__ManuallyScheduled__c,
                                                            leankor__ScheduleConstraint__c,
                                                            leankor__ConstraintDateTime__c,
                                                            leankor__ScheduleConstraint__r.leankor__Type__c,
                                                            leankor__ScheduleConstraint__r.leankor__Description__c,
                                                            leankor__KanbanCard__r.leankor__ValueStream__c,
                                                            leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                            CreatedDate
                                                        From leankor__ScheduleMode__c
                                                        Where leankor__KanbanCard__c In :kanbanCardIds
                                                            And leankor__KanbanCard__r.leankor__IsRecordDeleted__c = false
                                                            And leankor__KanbanCard__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                        With Security_Enforced
                                                        Limit 50000
                                                        For Update];

        // remove deleted records
        for (Integer index = scheduleModes.size() - 1; index >= 0; index--) {
            leankor__ScheduleMode__c scheduleMode = scheduleModes.get(index);
            if (scheduleMode.leankor__KanbanCard__r.leankor__ValueStream__c == null 
            || scheduleMode.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c == null) {
                scheduleModes.remove(index);
            }
        }
    
        return scheduleModes;
    }    
    
    //Update method
	public static List<leankor__ScheduleMode__c> updateScheduleModes(List<leankor__ScheduleMode__c> serverUpdateScheduleModes) {
		
		//Check CRUD / FLC behavior   
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		if (!scheduleModeBehavior.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior 
		
		try {
			Database.update(serverUpdateScheduleModes);
		}   catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return serverUpdateScheduleModes;
	}
}