/*
	* Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 	* FILE: TimeCardTriggerHandler.cls 
 	* CLASS: TimeCardTriggerHandler 
	* Date: 20/01/22	
*/
public with sharing class TimeCardTriggerHandler {

	final List<leankor__TimeCard__c> oldTimeCardRecords;

    public TimeCardTriggerHandler(List<leankor__TimeCard__c> oldRecords) {
        this.oldTimeCardRecords = oldRecords;
    }

    //If Time Card triggers for delete, a method is called to validate certain criteria before any further actions are performed on the record
    public void onBeforeDelete() {
        validateTimeSheet(this.oldTimeCardRecords);
    }

    //If Time Card triggers for update, a method is called to validate certain criteria before any further actions are performed on the record
    public void onBeforeUpdate() {
        validateTimeSheet(this.oldTimeCardRecords);
    }

    /*This method validates if the Time Card record(s) that caused the trigger is related to a Timesheet,
    * and if so, then checks if the Timesheet has been processed for approval yet.
    * If Timesheet has been processed for approval, an error is thrown since Time Cards cannot be updated/deleted at this stage.
    */
    @TestVisible
    private static void validateTimeSheet(List<leankor__TimeCard__c> timeCardsForValidate) {

        List<leankor__TimeCard__c> checkTimeCardList = [Select Id, 
                                                                leankor__TimeSheet__c,
                                                                leankor__TimeSheet__r.leankor__Resource__c,
                                                                leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c,
                                                                leankor__Assign_a_User__c 
                                                            From leankor__TimeCard__c
                                                            Where Id In : timeCardsForValidate
                                                            With Security_Enforced
                                                            Limit 50000];
        
        for (leankor__TimeCard__c timeCard : checkTimeCardList) {
            // Unsure about why Timesheet Resource needs to be the same as Timecard Assign a User; might need to remove later on
            if (timeCard.leankor__TimeSheet__c != null && (timeCard.leankor__TimeSheet__r.leankor__Resource__c == timeCard.leankor__Assign_a_User__c)) {
                if (!String.isBlank(timeCard.leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c)) {
                    throw new Util.LeanException('Error: Cannot update or delete time card from a timesheet that has already been processed.');
                }
            }
            
        }
		
    }

}