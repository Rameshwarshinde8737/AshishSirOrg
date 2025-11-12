/**
 * Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
 * FILE: KanbanCardTriggerHandlerTest.cls
 * CLASS: KanbanCardTriggerHandlerTest        
 */

@isTest
private class KanbanCardTriggerHandlerTest {

    static testMethod void KanbanCardTriggerHandlerTest() {
        KanbanCardTriggerHandler kanbanCardTrigger = new KanbanCardTriggerHandler(true, 100);

        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__DisableKanbanCardTrigger__c = false;
        customSetting.leankor__FirstInstall__c = true ;
        customSetting.leankor__DisableCaseTrigger__c= false;
        customSetting.leankor__DisableOpportunityTrigger__c= false;
        customSetting.leankor__AvoidTaskDueDateCheck__c = true;
        try {
	        insert customSetting;
	    }
	    Catch (Exception Ex) {
	        system.debug('Error:'+Ex.getMessage());
	    }

        //Data Creation
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
		insert testFolder;

        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
        prjRoom.Name = 'Test Room';
        prjRoom.leankor__Portfolio__c = testFolder.Id;
		insert prjRoom;   		
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myVS';
        valueStream.leankor__BoardType__c='Kanban Board';
        valueStream.leankor__ProjectRoom__c=prjRoom.Id;
        insert valueStream;
        
        leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
        templatecard.Name = 'default';
        templatecard.leankor__Valuestream__C = valueStream.id;
        insert templatecard;
        
        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c ();
        masterContainer.leankor__Valuestream__C = valueStream.id;
        masterContainer.leankor__Type__c='Backlog';
        masterContainer.leankor__IsCardAvailable__c=true;
        masterContainer.Name = 'zone';
        masterContainer.leankor__GUID__c = 'test-1234-'+system.now();
        insert masterContainer;
        
        leankor__Swimlane__c swimlane = new leankor__Swimlane__c ();
        swimlane.leankor__MasterContainer__c =masterContainer.id ;
        swimlane.leankor__Valuestream__C = valueStream.id;
        swimlane.Name =  'zone';
        swimlane.leankor__GUID__c = 'test-1234-'+system.now();
        insert swimlane;
        
        leankor__Zone__c testzone = New leankor__Zone__c();
        testzone.Name = 'test-zone';
        testzone.leankor__Valuestream__c =valueStream.id; 
        testzone.leankor__GUID__c = 'test-guid'+System.now().getTime();
        testzone.leankor__Swimlane__c =swimlane.Id;
        testzone.leankor__CaseStatus__c = 'None';
        insert testzone;
        
        leankor__Zone__c testzone1 = New leankor__Zone__c();
        testzone1.Name = 'test-zone1';
        testzone1.leankor__Valuestream__c =valueStream.id;
        testzone1.leankor__GUID__c = 'test-guid'+System.now().getTime();
        testzone1.leankor__Swimlane__c =swimlane.Id;
        testzone1.leankor__CaseStatus__c = 'None';
        insert testzone1;
        
        Test.startTest();
        leankor__KanbanCard__c kanbanCard = New leankor__KanbanCard__c();
        kanbanCard.Name = 'test';
        kanbanCard.leankor__Valuestream__c = valueStream.id;
        kanbanCard.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard.leankor__Swimlane__c=swimlane.Id;
        kanbanCard.leankor__EstimatedDuration__C=5;
        kanbanCard.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard.leankor__GUID__c = '305ee49a-8489-4091-bf76-8a07048066f8';
        kanbanCard.leankor__Zone__c=testzone.Id;
        insert kanbanCard; 
        
        leankor__KanbanCard__c kanbanCard1 = New leankor__KanbanCard__c();
        kanbanCard1.Name = 'test';
        kanbanCard1.leankor__Valuestream__c = valueStream.id;
        kanbanCard1.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard1.leankor__Swimlane__c=swimlane.Id;
        kanbanCard1.leankor__EstimatedDuration__C=5;
        kanbanCard1.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard1.leankor__GUID__c = '305ee49a-8489-4091-bf76-8a07048066f8';
    	insert kanbanCard1; 
    	
        leankor__KanbanCard__c kanbanCard2 = New leankor__KanbanCard__c();
        kanbanCard2.Name = 'test';
        kanbanCard2.leankor__Valuestream__c = valueStream.id;
        kanbanCard2.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard2.leankor__EstimatedDuration__C=5;
        kanbanCard2.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard2.leankor__GUID__c = '305ee49a-8489-4091-bf76-8a07048066f8';
    	insert kanbanCard2;
    	
        leankor__KanbanCard__c kanbanCard3 = New leankor__KanbanCard__c();
        kanbanCard3.Name = 'test';
        kanbanCard3.leankor__Valuestream__c = valueStream.id;
        kanbanCard3.leankor__MasterContainer__c = masterContainer.Id;
        kanbanCard3.leankor__Swimlane__c=swimlane.Id;
        kanbanCard3.leankor__EstimatedDuration__C=5;
        kanbanCard3.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard3.leankor__GUID__c = '305ee49a-8489-4091-bf76-8a07048066f8';
        kanbanCard3.leankor__Zone__c=testzone1.Id;
        insert kanbanCard3;
        Test.stopTest();

        List<leankor__KanbanCard__c> kanbanCards = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c =: valueStream.Id];
        System.assert(kanbanCards.size() > 0, 'Expected kanbanCards to contain elements, but it was empty.');

    }
}