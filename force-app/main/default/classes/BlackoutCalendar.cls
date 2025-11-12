global with sharing class BlackoutCalendar {
	public BlackoutCalendar(Util controller) {}
	
    @AuraEnabled(cacheable = true)
    @RemoteAction
    global static List<BlackoutCalendar__c> readBlackoutCalendars(){
        return [Select Id,
                        Name,
                        leankor__StartDate__c,
                        leankor__EndDate__c
                    From BlackoutCalendar__c 
                    With Security_Enforced
                    Order By leankor__StartDate__c
                    Limit 49999];
    }
}