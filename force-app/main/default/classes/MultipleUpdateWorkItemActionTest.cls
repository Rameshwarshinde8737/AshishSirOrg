@isTest
private class MultipleUpdateWorkItemActionTest {
    
    @TestSetup
	private static void setupTestData(){
		/* This sets up the Account and Contact data to be used by the Community User
		*  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
		*/
		//Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        //Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);

		leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.id; 
		valueStream.leankor__BoardType__C = 'Kanban Board';
		insert valueStream;

		leankor__ValueStream__c ganttBoard = new leankor__ValueStream__c();
		ganttBoard.Name =  'Testing gantt'; 
		ganttBoard.leankor__ProjectRoom__c = project.id; 
		ganttBoard.leankor__BoardType__C = 'UberBoard';
		insert ganttBoard;

        leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name= 'Test MC';
		newMC.leankor__ValueStream__c= valueStream.id;
		insert newMC ;

        leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c= newMC.id;
		newSw.leankor__ValueStream__c = valueStream.id;
		insert newSw; 

        leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__Swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        List<leankor__KanbanCardTemplate__c> kanbanTemplatesList = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
		kanbanTemplate.leankor__Height__c =120; 
		kanbanTemplate.leankor__CSSLayout__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c ='Default';
		kanbanTemplatesList.add(kanbanTemplate);

		insert kanbanTemplatesList;

        List<leankor__ProjectScheduleBlackout__c> blackOutsList = new List<leankor__ProjectScheduleBlackout__c>();
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today() + 20;
		blackOut.leankor__ProjectBoard__c = valueStream.Id;
		blackOut.leankor__StartDate__c = System.Today() + 18;
		blackOutsList.add(blackOut);

		insert blackOutsList;

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
		for(Integer i=1 ; i<=2000 ;i++){			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Kanban';
			kanbanCard.leankor__Title__c = 'Test Card '+i;
			kanbanCard.leankor__MasterContainer__c = newMC.Id;
			kanbanCard.leankor__Swimlane__c = newSw.Id;
			kanbanCard.leankor__Zone__c = zone.Id;
			kanbanCard.leankor__DurationUnits__c ='Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			KanbanCard.OwnerId = UserInfo.getUserId();
			KanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			}else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}  
			kanbanCardsList.add(KanbanCard);    
		}

		for(Integer i = 1; i <= 2000; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__KanbanCardTemplate__c = kanbanTemplate.Id;
			kanbanCard.leankor__ValueStream__c = ganttBoard.Id;
			kanbanCard.Name = 'Test Gantt Card';
			kanbanCard.leankor__Title__c = 'Test Gantt Card' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			if(Math.mod(i, 10) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
			} else if(Math.mod(i, 25) == 0) {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
			} else {
				kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
			}
            
			kanbanCardsList.add(kanbanCard);
		}
		
        insert kanbanCardsList;

        
		leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__AllowSchedulingConstraints__c = false;
        insert customSetting;

        List<leankor__ScheduleConstraint__c> scheduleConstraints = new List<leankor__ScheduleConstraint__c>();
        leankor__ScheduleConstraint__c startNoEarlier = new leankor__ScheduleConstraint__c();
        startNoEarlier.leankor__Description__c = 'startnoearlierthan';
        startNoEarlier.leankor__Type__c = 'startnoearlierthan';
        scheduleConstraints.add(startNoEarlier);
        
        leankor__ScheduleConstraint__c startNoLater = new leankor__ScheduleConstraint__c();
        startNoLater.leankor__Description__c = 'startnolaterthan';
        startNoLater.leankor__Type__c = 'startnolaterthan';
        scheduleConstraints.add(startNoLater);
        
        leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
        mustStartOn.leankor__Description__c = 'muststarton';
        mustStartOn.leankor__Type__c = 'muststarton';
        scheduleConstraints.add(mustStartOn);

        leankor__ScheduleConstraint__c finishNoEarlier = new leankor__ScheduleConstraint__c();
        finishNoEarlier.leankor__Description__c = 'finishnoearlierthan';
        finishNoEarlier.leankor__Type__c = 'finishnoearlierthan';
        scheduleConstraints.add(finishNoEarlier);

        leankor__ScheduleConstraint__c finishNoLater = new leankor__ScheduleConstraint__c();
        finishNoLater.leankor__Description__c = 'finishnolaterthan';
        finishNoLater.leankor__Type__c = 'finishnolaterthan';
        scheduleConstraints.add(finishNoLater);

        leankor__ScheduleConstraint__c mustFinishOn = new leankor__ScheduleConstraint__c();
        mustFinishOn.leankor__Description__c = 'mustfinishon';
        mustFinishOn.leankor__Type__c = 'mustfinishon';
        scheduleConstraints.add(mustFinishOn);

        insert scheduleConstraints;
		
	}

    @isTest
    private static void updateKanbanCardProcessTest(){
		
		List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
														leankor__ValueStream__c
													From leankor__KanbanCard__c
													Where Name = :'Test Kanban'
													Limit 50];

        // Check for update name 
        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        for(leankor__kanbanCard__c kanbanCard : kanbanCards){
           leankor__kanbanCard__c kc = new leankor__kanbanCard__c();
		    kc.Id = kanbanCard.Id;
            kc.Name = 'Updated Card';
            kc.leankor__StartDateTime__c = Date.today();
            kc.leankor__EstimatedDuration__c = 5;
			kc.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanCardsList.add(kc);
        }
		
		List<MultipleUpdateWorkItemAction.KanbanCardRequest> requests = new List<MultipleUpdateWorkItemAction.KanbanCardRequest>();
		MultipleUpdateWorkItemAction.KanbanCardRequest request = new MultipleUpdateWorkItemAction.KanbanCardRequest();
		request.kanbancardList = kanbanCardsList;
		request.sendBroadcastMessage = true;
		requests.add(request);
		Test.startTest();
		System.assert(MultipleUpdateWorkItemAction.updateKanbanCardProcess(requests).size()!= 0);
        Test.stopTest();
    }

}