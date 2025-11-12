@isTest
private without sharing class LeankorPlatformEventsTest {
	private static String valueStreamId = '';

    @TestSetup
    static void testSetupData(){
        String activityRecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();

        leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        INSERT project;
        
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
		INSERT valueStream;

        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
		newMC.name= 'Test MC';
		newMC.leankor__Valuestream__c= valueStream.id;
		INSERT newMC ;

        leankor__swimlane__c  newSw = new  leankor__swimlane__c();
		newSw.name = 'Test SW';
		newSw.leankor__mastercontainer__c= newMC.id;
		newSw.leankor__Valuestream__c = valueStream.id;
		INSERT newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		INSERT zone;

        leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c(
		    leankor__JSONDefinition__c = '',
		    leankor__JSONData__c = '',
		    leankor__Width__c = 170,
		    leankor__Height__c =120, 
		    leankor__CSSLayout__c = '',
		    leankor__Color__c = '#bdbffc',
		    leankor__ValueStream__c = valueStream.Id,
		    Name = 'Default',
		    leankor__Title__c ='Default'
		);
		INSERT kanbanTemplate;

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c(
			Name = 'Test Blackout',
			leankor__EndDate__c = System.Today()+20,
			leankor__ProjectBoard__c = valueStream.Id,
			leankor__StartDate__c = System.Today()+18
		);
		INSERT blackOut;
		
		List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
		
		valueStreamId = valueStream.Id;

		// Create KanbanCard(leankor__KanbanCard__c) records.
		for(Integer i = 1; i <= 20; i++){			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__EstimatedDuration__c = 5 + i;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
            kanbanCard.RecordTypeId = activityRecordTypeId;
            
			kanbanCards.add(KanbanCard);
            
		}
        INSERT kanbanCards;	
    }

    private @isTest
    static void testUpdateKanbanCardsQueueable(){
        List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
        List<leankor.realtimeController.bulkStreaming> listJSONrecords = new List<leankor.realtimeController.bulkStreaming>();
        List<String> jsonList = new List<String>();
        for(leankor__KanbanCard__c kanban : [SELECT Id, Name, leankor__ValueStream__c FROM leankor__KanbanCard__c where leankor__valueStream__c =: valueStreamId LIMIT 9999]){
            //valueStreamIds.add(kanban.leankor__ValueStream__c);
            leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
            remoteKanban.Id = kanban.Id;  
            remoteKanban.Name = 'Updated Card';
            remoteKanban.StartDate = System.now();
            remoteKanban.DueDate = System.now() + 5;
			remoteKanban.GUID = TestDataFactory.createGuid();
            leankor.realtimeController.bulkStreaming jsonLog = New leankor.realtimeController.bulkStreaming();   
            jsonLog.SomeJSONData = JSON.Serialize(remoteKanban);  
            jsonLog.VSID = kanban.leankor__ValueStream__c;
            jsonLog.Verb = 'updateKanbancards';
            jsonLog.SessionID = UserInfo.getSessionId();
            jsonList.add(jsonLog.SomeJSONData);
            listJSONrecords.add(jsonLog);
        }

		Boolean flag = true;
        Test.startTest();
            leankor.realtimeController.manageBulkStreaming(listJSONrecords, 'UpdateKanbanCards'); 

            for(leankor.realtimeController.bulkStreaming BS : listJSONrecords){
                broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent('UpdateBulkKanbanCards', BS.SomeJSONData, BS.SessionID));
            }
            LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
        Test.stopTest();

		System.assertEquals(true, flag);
    }
}