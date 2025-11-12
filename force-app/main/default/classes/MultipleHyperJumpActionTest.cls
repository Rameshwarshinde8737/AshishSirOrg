/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for MultipleHyperJumpAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
public class MultipleHyperJumpActionTest {

    @TestSetup
    static void makeData() {
		Id activityCard = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        List<leankor__Portfolio__c> folderList = TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = TestDataFactory.createProjects('Test Project', folderList, 1);     
        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c sourceProjectBoard1 = new leankor__ValueStream__c(Name = 'Source Board 1',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(sourceProjectBoard1);
        leankor__ValueStream__c sourceProjectBoard2 = new leankor__ValueStream__c(Name = 'Source Board 2',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(sourceProjectBoard2);
        leankor__ValueStream__c targetProjectBoard1 = new leankor__ValueStream__c(Name = 'Target Board 1',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(targetProjectBoard1);
        leankor__ValueStream__c targetProjectBoard2 = new leankor__ValueStream__c(Name = 'Target Board 2',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = projectList[0].Id);        
        valueStreams.add(targetProjectBoard2);
        insert valueStreams; 
        leankor__KanbanCardTemplate__c targetBoardTemplate1 = TestDataFactory.createKanbanCardTemplate(targetProjectBoard1);         
        leankor__KanbanCardTemplate__c targetBoardTemplate2 = TestDataFactory.createKanbanCardTemplate(targetProjectBoard2);
        List<leankor__masterContainer__c> masterContainers = new list<leankor__masterContainer__c>();
        leankor__MasterContainer__c targetBoardMasterContainer1 = new leankor__MasterContainer__c(
                                                                                Name= 'masterContainer', 
            																	leankor__GUID__c = TestDataFactory.createGuid(),
                                                                                leankor__ValueStream__c = targetProjectBoard1.Id,
                                                                                leankor__order__c =0.0,
                                                                                leankor__Type__c ='backlog'
                                                                                );
        masterContainers.add(targetBoardMasterContainer1);
        leankor__MasterContainer__c targetBoardMasterContainer2 = new leankor__MasterContainer__c(
                                                                                Name= 'masterContainer', 
            																	leankor__GUID__c = TestDataFactory.createGuid(),
                                                                                leankor__ValueStream__c = targetProjectBoard2.Id,
                                                                                leankor__order__c =0.0,
                                                                                leankor__Type__c ='backlog'
                                                                                );
        masterContainers.add(targetBoardMasterContainer2);
        insert masterContainers; 
        List<leankor__swimlane__c> swimlanes = new list<leankor__swimlane__c>();
        leankor__swimlane__c targetBoardSwimlane1 =new leankor__swimlane__c(
                                                    Name ='swimlane test',
                                                    leankor__MasterContainer__c = targetBoardMasterContainer1.ID,
                                                    leankor__order__c =0.0,
                                                    leankor__ValueStream__c = targetProjectBoard1.Id);
        swimlanes.add(targetBoardSwimlane1);
        leankor__swimlane__c targetBoardSwimlane2 =new leankor__swimlane__c(
                                                    Name ='swimlane test',
                                                    leankor__MasterContainer__c = targetBoardMasterContainer2.ID,
                                                    leankor__order__c =0.0,
                                                    leankor__ValueStream__c = targetProjectBoard2.Id);
        swimlanes.add(targetBoardSwimlane2);
        insert swimlanes; 
            
        List<leankor__Zone__c> zones = new list<leankor__Zone__c>();
        leankor__Zone__c targetBoardZone1 = new leankor__Zone__c(
                                                Name = 'kanban test3',
                                                leankor__GUID__c = TestDataFactory.createGuid(),
                                                leankor__CmpID__c = 'my-CMPID-zone-test3',
                                                leankor__swimlane__c = targetBoardSwimlane1.ID,
                                                leankor__ValueStream__c = targetProjectBoard1.Id);
        zones.add(targetBoardZone1);
        leankor__Zone__c targetBoardZone2 = new leankor__Zone__c(
                                                Name = 'kanban test3',
                                                leankor__GUID__c = TestDataFactory.createGuid(),
                                                leankor__CmpID__c = 'my-CMPID-zone-test1',
                                                leankor__swimlane__c = targetBoardSwimlane2.ID,
                                                leankor__ValueStream__c = targetProjectBoard1.Id);
        zones.add(targetBoardZone2);
        insert zones; 
        
        List<leankor__KanbanCard__c> KanbanCards = new List<leankor__KanbanCard__c>();
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
		KanbanCards.add(testKanbanCard);

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
		KanbanCards.add(testanotherKanbanCard);

        // Create 2000 cards to test
        for (Integer count = 1; count <= 2000; count++) {
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'KanbanCard----1'+count;
            kanbanCard.leankor__DurationUnits__c = 'Days';
            kanbanCard.leankor__EstimatedDuration__c = 1;
            kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
            kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
            kanbanCard.leankor__ValueStream__c = sourceProjectBoard2.Id;
            kanbanCard.leankor__isRecordDeleted__c = false;
            kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCard.RecordTypeId = activityCard;
            KanbanCards.add(kanbanCard);
        }
        insert KanbanCards;

    }

    //move 2 cards with Name "nameInput" from sourceProjectBoard1 to targetProjectBoard1
    @isTest
    static void testMultipleHyperJump() {
        leankor__ValueStream__c projectOne = [Select Id 
                                            From leankor__ValueStream__c 
                                            Where Name = 'Source Board 1' 
                                            Limit 1];
        System.assert(null != projectOne, 'Method Executed Successfully.');        
        
        leankor__ValueStream__c projectTwo = [Select Id 
                                            From leankor__ValueStream__c 
                                            Where Name = 'Target Board 1' 
                                            Limit 1];
        System.assert(null != projectTwo, 'Method Executed Successfully.');
        
        //verify that 2 cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select Id 
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c  = :projectOne.Id 
                                                    And recordtype.name = 'ActivityCard' 
                                                    And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];

        System.assertEquals(kanbanCardsInit.size(), 2, 'Method Executed Successfully.');
        
        MultipleHyperJumpAction.MultipleHyperJumpRequest request = new MultipleHyperJumpAction.MultipleHyperJumpRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = [Select Id 
                                    From leankor__ValueStream__c 
                                    Where Name = 'Target Board 1'].Id;

        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                        And leankor__ValueStream__c  = :projectTwo.Id].Id;

        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test3'].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        List<MultipleHyperJumpAction.MultipleHyperJumpRequest> requests = new List<MultipleHyperJumpAction.MultipleHyperJumpRequest>();
        requests.add(request);
        Test.startTest();
        MultipleHyperJumpAction.hyperJumpKanbanCardProcess(requests);         
        Test.stopTest();
        
        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> kanbanCards2 = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectTwo.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
                                                
        System.assertEquals(kanbanCards2.size(), 2, 'Method Executed Successfully.'); 
        
		//verify that no cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsFinal = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];

        System.assertEquals(kanbanCardsFinal.size(), 0, 'Method Executed Successfully.');        
        
    }


    //move 2 cards with Name "nameInput" from sourceProjectBoard1 to targetProjectBoard1
    @isTest
    static void testTwoThousandCardsHyperJump() {
        leankor__ValueStream__c projectOne = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Source Board 2' 
                                                Limit 1];
        System.assert(null != projectOne, 'Method Executed Successfully.');        
        
        leankor__ValueStream__c projectTwo = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Target Board 2' 
                                                Limit 1];
        System.assert(null != projectTwo, 'Method Executed Successfully.');
        
        //verify that 2000 cards are present on Source Board 2
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsInit.size(), 2000, 'Method Executed Successfully.');
        
        MultipleHyperJumpAction.MultipleHyperJumpRequest request = new MultipleHyperJumpAction.MultipleHyperJumpRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = projectTwo.Id;
        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                            And leankor__ValueStream__c  = :projectTwo.Id ].Id;

        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test1'].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        request.generateWorkBreakdownStructure = true;
        List<MultipleHyperJumpAction.MultipleHyperJumpRequest> requests = new List<MultipleHyperJumpAction.MultipleHyperJumpRequest>();
        requests.add(request);
        Test.startTest();
        MultipleHyperJumpAction.hyperJumpKanbanCardProcess(requests);         
        Test.stopTest();
        
        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> kanbanCards2 = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c  = :projectTwo.Id 
                                                            And recordtype.name = 'ActivityCard' 
                                                            And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCards2.size(), 2000, 'Method Executed Successfully.'); 
        
		//verify that no cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsFinal = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsFinal.size(), 0, 'Method Executed Successfully.');        
    }
    

    @isTest
    static void testHyperJumpWBSAndSequenceNumber() {
        leankor__ValueStream__c projectOne = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Source Board 2' 
                                                Limit 1];
        System.assert(null != projectOne, 'Method Executed Successfully.');        
        
        leankor__ValueStream__c projectTwo = [Select Id 
                                                From leankor__ValueStream__c 
                                                Where Name = 'Target Board 2' 
                                                Limit 1];
        System.assert(null != projectTwo, 'Method Executed Successfully.');
        
        //verify that 2000 cards are present on Source Board 2
        List<leankor__KanbanCard__c> kanbanCardsInit = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'
                                                    Limit 2000];
        System.assertEquals(kanbanCardsInit.size(), 2000, 'Method Executed Successfully.');
        
        MultipleHyperJumpAction.MultipleHyperJumpRequest request = new MultipleHyperJumpAction.MultipleHyperJumpRequest();
        request.kanbanCardRequests = kanbanCardsInit;
        request.sendBroadcastMessage = false;
        request.targetBoardId = projectTwo.Id;
        request.generateWorkBreakdownStructure = true;
        request.targetCategoryId = [Select Id 
                                        From leankor__KanbanCardTemplate__c 
                                        Where Name = 'Default' 
                                            And leankor__ValueStream__c  = :projectTwo.Id ].Id;

        request.targetZoneId = [Select Id 
                                    From leankor__Zone__c 
                                    Where leankor__CmpID__c = 'my-CMPID-zone-test1'].Id;
        request.targetLinkBoardId = null;
        request.targetLinkCardId = null;
        List<MultipleHyperJumpAction.MultipleHyperJumpRequest> requests = new List<MultipleHyperJumpAction.MultipleHyperJumpRequest>();
        requests.add(request);
        Test.startTest();
        MultipleHyperJumpAction.hyperJumpKanbanCardProcess(requests);         
        Test.stopTest();
        
        //verify that 2 cards are present on board 2
        List<leankor__KanbanCard__c> kanbanCards2 = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c  = :projectTwo.Id 
                                                            And recordtype.name = 'ActivityCard' 
                                                            And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCards2.size(), 2000, 'Method Executed Successfully.'); 
        
		//verify that no cards are present on board 1
        List<leankor__KanbanCard__c> kanbanCardsFinal = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  = :projectOne.Id 
                                                        And recordtype.name = 'ActivityCard' 
                                                        And leankor__ValueStream__r.leankor__BoardType__c = 'Kanban Board'];
        System.assertEquals(kanbanCardsFinal.size(), 0, 'Method Executed Successfully.');        
        
    }
}