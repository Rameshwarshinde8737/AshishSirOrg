@isTest
private class MultipleBroadcastMessageSFActionTest {
    @isTest private static void testBroadcastProcess(){
		leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;
        
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name = 'Testing board', leankor__projectroom__c = project.Id, leankor__BoardType__c = 'UberBoard');
		insert valueStream;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c(
		    leankor__JSONDefinition__c = '',
		    leankor__JSONData__c = '',
		    leankor__Width__c = 170,
		    leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
		    leankor__CSSLayout__c = '',
		    leankor__Color__c = '#bdbffc',
		    leankor__ValueStream__c = valueStream.Id,
		    Name = 'Default',
		    leankor__Title__c ='Default'
		);
		insert kanbanTemplate;

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		for(Integer count = 1; count<=50 ; count++){			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.leankor__Title__c = 'Test Card '+count;
			kanbanCard.leankor__EstimatedDuration__c = 5 + count;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now().addDays(count);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(count<=20){
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}else if(count>20 && count<40){
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			}else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			}
			kanbanCards.add(KanbanCard);
            
		}
        insert kanbanCards;
		List<leankor__KanbanCard__c> updateCards = new List<leankor__KanbanCard__c>();
		List<MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest> broadcastRequests = new List<MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest>();
        List<String> recordIds = new List<String>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
            kanbanCard.Name = kanbanCard.Name + 'updated';
            if(kanbanCard.leankor__Title__c == 'Test Card 2'){
                kanbanCard.leankor__HarveyBallDoneDate__c = Date.today().addDays(5);
                kanbanCard.leankor__PromiseCompletionDate__c = Date.today().addDays(3);
                kanbanCard.leankor__ValueStreamCardLink__C = kanbanCards.get(0).Id;
            }
            recordIds.add(kanbanCard.Id);
            updateCards.add(kanbanCard);
        }
        update updateCards;
        List<MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest> result = new List<MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest>();
        MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest broadcastRequest = new MultipleBroadcastMessageSFAction.MultipleBroadcastMessageRequest();
        broadcastRequest.verb = 'UpdateMultipleKanbanCard';
        broadcastRequest.recordIds = recordIds;
        broadcastRequests.add(broadcastRequest);
        Test.startTest();
        result = MultipleBroadcastMessageSFAction.sendBroadcastNotificationProcess(broadcastRequests);
        Test.stopTest();
		List<leankor__RealtimeTracker__c> realtimeTrackers = [Select Id, 
                                                                    leankor__KanbanVerb__c 
                                                                From leankor__RealtimeTracker__c 
                                                                Limit 9999];
		System.assert(realtimeTrackers.size() > 0);
		System.assertEquals('UpdateMultipleKanbanCard', realtimeTrackers[0].leankor__KanbanVerb__c);
        System.assertEquals(broadcastRequests.size(), result.size());
    }
}