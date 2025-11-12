/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestScheduledCardDueDateChatter.cls
 * CLASS: TestScheduledCardDueDateChatter
 */
@isTest
global class TestScheduledCardDueDateChatter {
	private static testMethod void test(){
    Test.startTest();
		String scheduledTime = '0 0 23 1 1 ? '+(Date.today().year()+1);
		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
		kanban.Name = 'testScheduledApexFromTestMethod';
		insert kanban;
        
		PushTopic pushTopic = new PushTopic();
		pushTopic.Name = 'RTValueStream';
		pushTopic.Query = 'Select Id, Name From leankor__ValueStream__c';
		pushTopic.ApiVersion = 38.0;
		pushTopic.NotifyForOperationCreate = true;
		pushTopic.NotifyForOperationUpdate = true;
		pushTopic.NotifyForOperationUndelete = true;
		pushTopic.NotifyForOperationDelete = true;
		pushTopic.NotifyForFields = 'Referenced';
	
		try{
			insert pushTopic;
		} catch(DMLException ex){
			System.debug('Error: ' +Ex.getMessage());
		}
        String jobId = System.schedule('testBasicScheduledApex-'+System.now().getTime(), scheduledTime, new leankor.ScheduledCardDueDateChatter());
        String jobId1 = System.schedule('scheduledToDeletePushTopic-'+System.now().getTime(), scheduledTime, new leankor.scheduledToDeletePushTopic());
        String scheduledModeRecord = System.schedule('scheduledModeRecord-'+System.now().getTime(), scheduledTime, new leankor.scheduledModeRecord());
        String ScheduledPlanGanttRecord= System.schedule('ScheduledPlanGanttRecord-'+System.now().getTime(), scheduledTime, new leankor.ScheduledPlanGanttRecord()); 
		System.assertNotEquals('testScheduledApexFromTestMethodUpdated', [Select Id, Name From leankor__Kanbancard__c Where Id = :kanban.Id].Name);
		System.assertEquals('testScheduledApexFromTestMethod', [Select Id, Name From leankor__Kanbancard__c Where Id = :kanban.Id].Name);	
		Test.stopTest();
	}
}