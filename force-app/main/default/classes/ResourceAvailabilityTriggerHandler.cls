public with sharing class ResourceAvailabilityTriggerHandler {

	private boolean bypassTrigger = false;

	final List<leankor__GlobalWorkHour__c> newRecords;
	final Map<Id, leankor__GlobalWorkHour__c> oldMap;

	public ResourceAvailabilityTriggerHandler(List<leankor__GlobalWorkHour__c> newRecords, Map<Id, leankor__GlobalWorkHour__c> oldMap) {
		this.newRecords = newRecords;
		this.oldMap = oldMap;		
	}

	/*set this flag to TRUE if you need to bypass this trigger*/
	public void setBypassTrigger(boolean bypass){
		this.bypassTrigger = bypass;
	}

	public boolean getBypassTrigger(){
		return bypassTrigger;
	}

	/*Triggers before insert*/
	public void onBeforeInsert() {
		if (bypassTrigger) return;		

		validateForInDateRange(this.newRecords);

	}

	/*Triggers before update*/
	public void onBeforeUpdate() {
		if (bypassTrigger) return;

		validateForInDateRange(this.newRecords);
	

	}

	@TestVisible
	private static void validateForInDateRange(List<leankor__GlobalWorkHour__c> workHoursForValidate){
		List<leankor__GlobalWorkHour__c> workHourList = new List<leankor__GlobalWorkHour__c>();
		

		for(leankor__GlobalWorkHour__c w : workHoursForValidate){
			workHourList.add(w);
		}

		if(workHourList.isEmpty()) 	return;


		List<leankor__GlobalWorkHour__c> raList = [SELECT Id, leankor__StartDate__c, leankor__EndDate__c FROM leankor__GlobalWorkHour__c where Id NOT IN : workHourList];
		
		for(leankor__GlobalWorkHour__c w : workHoursForValidate){
				//check if there are records in the list with overlapping start/end date
				List<leankor__GlobalWorkHour__c> newRecordList = isDateRangeInList(w.leankor__StartDate__c, w.leankor__EndDate__c, workHourList);
				List<leankor__GlobalWorkHour__c> existingRecordList = isDateRangeInList(w.leankor__StartDate__c, w.leankor__EndDate__c, raList);			

				//if there is no overlapping records, add it to a new list
				if(newRecordList.size() > 1 || existingRecordList.size() > 0){
					w.addError('Start date or end date is already scheduled');
				}
		}
	}


	@TestVisible
	private static List<leankor__GlobalWorkHour__c> isDateRangeInList(Date startDate, Date endDate, List<leankor__GlobalWorkHour__c> raList){
		List<leankor__GlobalWorkHour__c> updatableWorkHourList = new List<leankor__GlobalWorkHour__c>();

		for(leankor__GlobalWorkHour__c w : raList){

			//Make sure updated or new records does not have overlapping date ranges
			if((startDate >= w.leankor__StartDate__c && startDate <= w.leankor__EndDate__c) ||
				(endDate >= w.leankor__StartDate__c && endDate <= w.leankor__EndDate__c) ||
				(w.leankor__StartDate__c <= startDate && w.leankor__StartDate__c >= endDate) ||
				w.leankor__EndDate__c >= startDate && w.leankor__EndDate__c <= endDate) {

				updatableWorkHourList.add(w);				
			}
		}

		return updatableWorkHourList;

	}


}