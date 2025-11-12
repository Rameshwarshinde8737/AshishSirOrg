/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MultipleCloneKanbanCardAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
public class MultipleCloneKanbanCardActionTest {

    @TestSetup
    static void makeData() {
		Id activityCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        List<leankor__Portfolio__c> folderList = TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = TestDataFactory.createProjects('Test Project', folderList, 1);      
        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c sourceProjectBoard1 = new leankor__ValueStream__c(Name = 'Source Board1',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(sourceProjectBoard1);
        leankor__ValueStream__c sourceProjectBoard2 = new leankor__ValueStream__c(Name = 'Source Board2',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(sourceProjectBoard2);
        leankor__ValueStream__c targetProjectBoard1 = new leankor__ValueStream__c(Name = 'Target Board1',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(targetProjectBoard1);
        leankor__ValueStream__c targetProjectBoard2 = new leankor__ValueStream__c(Name = 'Target Board2',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(targetProjectBoard2);
        insert valueStreams; 
        leankor__KanbanCardTemplate__c sourceBoardTemplate1 = TestDataFactory.createKanbanCardTemplate(sourceProjectBoard1);         
        leankor__KanbanCardTemplate__c sourceBoardTemplate2 = TestDataFactory.createKanbanCardTemplate(sourceProjectBoard2);         
        leankor__KanbanCardTemplate__c targetBoardTemplate1 = TestDataFactory.createKanbanCardTemplate(targetProjectBoard1);         
        leankor__KanbanCardTemplate__c targetBoardTemplate2 = TestDataFactory.createKanbanCardTemplate(targetProjectBoard2);         
        
        List<leankor__MasterContainer__c> masterContainers = new List<leankor__MasterContainer__c>();
        leankor__MasterContainer__c sourceBoardMasterContainer1 = new leankor__MasterContainer__c(
                                                                                Name= 'masterContainer', 
            																	leankor__GUID__c = TestDataFactory.createGuid(),
                                                                                leankor__ValueStream__c = sourceProjectBoard1.Id,
                                                                                leankor__order__c = 0.0,
                                                                                leankor__Type__c = 'backlog'
                                                                                );
        masterContainers.add(sourceBoardMasterContainer1); 
        leankor__MasterContainer__c sourceBoardMasterContainer2 = new leankor__MasterContainer__c(
                                                                        Name= 'masterContainer', 
                                                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                                                        leankor__ValueStream__c = sourceProjectBoard2.Id,
                                                                        leankor__order__c = 0.0,
                                                                        leankor__Type__c = 'backlog'
                                                                        );
        masterContainers.add(sourceBoardMasterContainer2);
        leankor__MasterContainer__c targetMasterContainer1 = new leankor__MasterContainer__c(
                                                                                Name= 'masterContainer', 
            																	leankor__GUID__c = TestDataFactory.createGuid(),
                                                                                leankor__ValueStream__c = sourceProjectBoard1.Id,
                                                                                leankor__order__c = 0.0,
                                                                                leankor__Type__c = 'backlog'
                                                                                );
        masterContainers.add(targetMasterContainer1); 
        leankor__MasterContainer__c targetMasterContainer2 = new leankor__MasterContainer__c(
                                                                        Name= 'masterContainer', 
                                                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                                                        leankor__ValueStream__c = sourceProjectBoard2.Id,
                                                                        leankor__order__c = 0.0,
                                                                        leankor__Type__c = 'backlog'
                                                                        );
        masterContainers.add(targetMasterContainer2);
        insert masterContainers;
        List<leankor__swimlane__c> swimlanes = new List<leankor__swimlane__c>();
        leankor__swimlane__c sourceSwimlane1 = new leankor__swimlane__c(
                                            Name = 'swimlane test',
                                            leankor__MasterContainer__c = sourceBoardMasterContainer1.ID,
                                            leankor__order__c = 0.0,
                                            leankor__ValueStream__c = sourceProjectBoard1.Id);
        swimlanes.add(sourceSwimlane1); 
        leankor__swimlane__c sourceSwimlane2 = new leankor__swimlane__c(
                                            Name = 'swimlane test',
                                            leankor__MasterContainer__c = sourceBoardMasterContainer2.ID,
                                            leankor__order__c = 0.0,
                                            leankor__ValueStream__c = sourceProjectBoard2.Id);
        swimlanes.add(sourceSwimlane2);
        leankor__swimlane__c targetSwimlane1 = new leankor__swimlane__c(
                                            Name = 'swimlane test',
                                            leankor__MasterContainer__c = targetMasterContainer1.ID,
                                            leankor__order__c = 0.0,
                                            leankor__ValueStream__c = targetProjectBoard1.Id);
        swimlanes.add(targetSwimlane1); 
        leankor__swimlane__c targetSwimlane2 = new leankor__swimlane__c(
                                            Name = 'swimlane test',
                                            leankor__MasterContainer__c = targetMasterContainer2.ID,
                                            leankor__order__c = 0.0,
                                            leankor__ValueStream__c = targetProjectBoard2.Id);
        swimlanes.add(targetSwimlane2);
        insert swimlanes;

        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        leankor__Zone__c sourceBoardZone1 = new leankor__Zone__c(
                                        Name = 'kanban test3',
                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                        leankor__CmpID__c = 'my-CMPID-zone-test1',
                                        leankor__swimlane__c = sourceSwimlane1.ID,
                                        leankor__ValueStream__c = sourceProjectBoard1.Id);
        zones.add(sourceBoardZone1); 
        leankor__Zone__c sourceBoardZone2 = new leankor__Zone__c(
                                        Name = 'kanban test3',
                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                        leankor__CmpID__c = 'my-CMPID-zone-test2',
                                        leankor__swimlane__c = sourceSwimlane2.ID,
                                        leankor__ValueStream__c = sourceProjectBoard2.Id);
        zones.add(sourceBoardZone2);
        leankor__Zone__c targetBoardZone1 = new leankor__Zone__c(
                                        Name = 'kanban test3',
                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                        leankor__CmpID__c = 'my-CMPID-zone-test3',
                                        leankor__swimlane__c = targetSwimlane1.ID,
                                        leankor__ValueStream__c = targetProjectBoard1.Id);
        zones.add(targetBoardZone1); 
        leankor__Zone__c targetBoardZone2 = new leankor__Zone__c(
                                        Name = 'kanban test3',
                                        leankor__GUID__c = TestDataFactory.createGuid(),
                                        leankor__CmpID__c = 'my-CMPID-zone-test4',
                                        leankor__swimlane__c = targetSwimlane2.ID,
                                        leankor__ValueStream__c = targetProjectBoard2.Id);
        zones.add(targetBoardZone2);
        insert zones;

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();    
        //Card 1
		leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c();
		testKanbanCard.Name = 'nameInput';
		testKanbanCard.leankor__DurationUnits__c = 'Days';
		testKanbanCard.leankor__EstimatedDuration__c = 1;
		testKanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
		testKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
		testKanbanCard.leankor__ValueStream__c = sourceProjectBoard1.Id;
        testKanbanCard.leankor__isRecordDeleted__c = false;
        testKanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        testKanbanCard.RecordTypeId = activityCard;
        kanbanCards.add(testKanbanCard);

        //Card 2
		leankor__KanbanCard__c testanotherKanbanCard = new leankor__KanbanCard__c();
		testanotherKanbanCard.Name = 'nameInput';
		testanotherKanbanCard.leankor__DurationUnits__c = 'Days';
		testanotherKanbanCard.leankor__EstimatedDuration__c = 1;
		testanotherKanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
		testanotherKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
		testanotherKanbanCard.leankor__ValueStream__c = sourceProjectBoard1.Id;
        testanotherKanbanCard.leankor__isRecordDeleted__c = false;
        testanotherKanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        testanotherKanbanCard.RecordTypeId = activityCard;
        kanbanCards.add(testanotherKanbanCard);
        
        // Create 1000 kanban cards
        for (Integer count = 1; count <= 1000; count++) {
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'card--'+count;
            kanbanCard.leankor__DurationUnits__c = 'Days';
            kanbanCard.leankor__EstimatedDuration__c = 1;
            kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
            kanbanCard.leankor__ValueStream__c = sourceProjectBoard2.Id;
            kanbanCard.leankor__isRecordDeleted__c = false;
            kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCard.RecordTypeId = activityCard;
            kanbanCards.add(kanbanCard);
        }
        insert kanbanCards;
    }

    //clone 2 cards with Name "nameInput" from sourceProjectBoard to targetProjectBoard
    @isTest
    static void testMultipleCardClone() {
        leankor__ValueStream__c projectOne = [Select Id 
                                            From leankor__ValueStream__c 
                                            Where Name = 'Source Board1' 
                                            Limit 1];
        System.assert(NULL != projectOne, 'Method Executed Successfully.');        
        
        leankor__ValueStream__c projectTwo = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Target Board1' 
                                                Limit 1];
        System.assert(NULL != projectTwo, 'Method Executed Successfully.');
        
        //verify that 2 cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsInit.size(), 2, 'Method Executed Successfully.');
        
        MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest request = new MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = projectTwo.Id;
        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                            And leankor__ValueStream__c  =: projectTwo.Id 
                                        Limit 1].Id;
        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test2' 
                                    Limit 1].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest> requests = new List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest>();
        requests.add(request);
        Test.startTest();
        MultipleCloneKanbanCardAction.cloneKanbanCardProcess(requests);         

        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectTwo.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        List<realTimeController.ZoneKanbanAction>zoneKanbanActionList = new List<realTimeController.ZoneKanbanAction>();
        for (leankor__kanbancard__c kanbanCard : clonedCards) {
            realTimeController.ZoneKanbanAction zoneKanbanAction = new realTimeController.ZoneKanbanAction();
            zoneKanbanAction.KanbanID = kanbanCard.Id;
            zoneKanbanAction.ZoneID = kanbanCard.leankor__ZoneGUID__C;
            zoneKanbanAction.SwimlaneID = '';
            zoneKanbanAction.MasterContainerID = '';
            zoneKanbanAction.VSID = kanbanCard.leankor__ValueStream__C;
            zoneKanbanAction.Action = 'Entered Zone';
            zoneKanbanAction.SessionID = UserInfo.getSessionId();
            zoneKanbanActionList.add(zoneKanbanAction);
        }
        Test.stopTest();    
        
    }


    @isTest
    static void testTwoThousandCardsToClone() {
        leankor__ValueStream__c projectOne = [Select Id
                                                From leankor__ValueStream__c 
                                                Where Name = 'Source Board2' 
                                                Limit 1];
        System.assert(null != projectOne, 'Method Executed Successfully.');        
        leankor__ValueStream__c projectTwo = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Target Board2' 
                                                Limit 1];
        System.assert(null != projectTwo, 'Method Executed Successfully.');
        //verify that 2 cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select  Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsInit.size(), 1000, 'Method Executed Successfully.');
        
        MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest request = new MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = projectTwo.Id;
        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                            And leankor__ValueStream__c  =: projectTwo.Id 
                                        Limit 1].Id;
        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test4' 
                                    Limit 1].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest> requests = new List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest>();
        requests.add(request);
        Test.startTest();
        MultipleCloneKanbanCardAction.cloneKanbanCardProcess(requests);         

        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectTwo.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        List<realTimeController.ZoneKanbanAction>zoneKanbanActionList = new List<realTimeController.ZoneKanbanAction>();
        for (leankor__kanbancard__c kanbanCard : clonedCards) {
            realTimeController.ZoneKanbanAction zoneKanbanAction = new realTimeController.ZoneKanbanAction();
            zoneKanbanAction.KanbanID = kanbanCard.Id;
            zoneKanbanAction.ZoneID = kanbanCard.leankor__ZoneGUID__C;
            zoneKanbanAction.SwimlaneID = '';
            zoneKanbanAction.MasterContainerID = '';
            zoneKanbanAction.VSID = kanbanCard.leankor__ValueStream__C;
            zoneKanbanAction.Action = 'Entered Zone';
            zoneKanbanAction.SessionID = UserInfo.getSessionId();
            zoneKanbanActionList.add(zoneKanbanAction);
        }
        Test.stopTest();       
    }


    @isTest
    static void testMultipleCardCloneWBS() {
        leankor__ValueStream__c projectOne = [Select Id 
                                            From leankor__ValueStream__c 
                                            Where Name = 'Source Board1' 
                                            Limit 1];
        System.assert(NULL != projectOne, 'Method Executed Successfully.');        
        
        leankor__ValueStream__c projectTwo = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Target Board1' 
                                                Limit 1];
        System.assert(NULL != projectTwo, 'Method Executed Successfully.');
        
        //verify that 2 cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsInit.size(), 2, 'Method Executed Successfully.');
        
        MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest request = new MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = projectTwo.Id;
        request.generateWorkBreakdownStructure = true;
        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                            And leankor__ValueStream__c  =: projectTwo.Id 
                                        Limit 1].Id;
        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test2' 
                                    Limit 1].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest> requests = new List<MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest>();
        requests.add(request);
        Test.startTest();
        MultipleCloneKanbanCardAction.cloneKanbanCardProcess(requests);         

        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> clonedCards = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectTwo.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        List<realTimeController.ZoneKanbanAction>zoneKanbanActionList = new List<realTimeController.ZoneKanbanAction>();
        for (leankor__kanbancard__c kanbanCard : clonedCards) {
            realTimeController.ZoneKanbanAction zoneKanbanAction = new realTimeController.ZoneKanbanAction();
            zoneKanbanAction.KanbanID = kanbanCard.Id;
            zoneKanbanAction.ZoneID = kanbanCard.leankor__ZoneGUID__C;
            zoneKanbanAction.SwimlaneID = '';
            zoneKanbanAction.MasterContainerID = '';
            zoneKanbanAction.VSID = kanbanCard.leankor__ValueStream__C;
            zoneKanbanAction.Action = 'Entered Zone';
            zoneKanbanAction.SessionID = UserInfo.getSessionId();
            zoneKanbanActionList.add(zoneKanbanAction);
        }
        Test.stopTest();       
    }
}