global with sharing class ScheduleSetActivityTracker implements Schedulable {
	global void execute(SchedulableContext sc) {
		SetActivityTracker setActivityTracker = new SetActivityTracker();
		database.executebatch(setActivityTracker, 2000);
	}
}