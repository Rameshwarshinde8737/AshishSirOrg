/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for HyperJumpWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private class HyperJumpWorkItemActionTest {

    @isTest
    static void hyperjumpToBoardTest() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
		
		List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
		targetBoard.Name = 'Target board';
		targetBoard.leankor__ProjectRoom__c = project.Id;
        targetBoard.leankor__SevenDayWorkWeek__c = true;
		targetBoard.leankor__BoardType__c = 'Kanban Board';
        boards.add(targetBoard);

        leankor__ValueStream__c sourceBoard = new leankor__ValueStream__c();
		sourceBoard.Name = 'Source board';
		sourceBoard.leankor__ProjectRoom__c = project.Id;
        sourceBoard.leankor__SevenDayWorkWeek__c = true;
		sourceBoard.leankor__BoardType__c = 'Kanban Board';
		boards.add(sourceBoard);
        insert boards;

        leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name= 'Test MC';
		newMC.leankor__ValueStream__c = targetBoard.Id;
		insert newMC ;
		
		leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c = newMC.Id;
		newSw.leankor__ValueStream__c = targetBoard.Id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name = 'Test Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = System.now() +'Test Zone';
		zone.leankor__Y__c = 49.0;
		zone.leankor__Swimlane__c = newSw.Id;
		zone.leankor__ValueStream__c = targetBoard.Id;
		insert zone;

        List<leankor__KanbanCardTemplate__c> template = new List<leankor__KanbanCardTemplate__c>();
        leankor__KanbanCardTemplate__c sourceBoardTemplate = new leankor__KanbanCardTemplate__c();
        sourceBoardTemplate.Name = 'Default';
        sourceBoardTemplate.leankor__Title__c = 'Default';
        sourceBoardTemplate.leankor__Height__c = 120;
        sourceBoardTemplate.leankor__Color__c = '#bdbffc';
        sourceBoardTemplate.leankor__Width__c = 170;
        sourceBoardTemplate.leankor__ValueStream__c = sourceBoard.Id;
        template.add(sourceBoardTemplate);
        leankor__KanbanCardTemplate__c targetBoardTemplate = new leankor__KanbanCardTemplate__c();
        targetBoardTemplate.Name = 'Default';
        targetBoardTemplate.leankor__Title__c = 'Default';
        targetBoardTemplate.leankor__Height__c = 120;
        targetBoardTemplate.leankor__Color__c = '#bdbffc';
        targetBoardTemplate.leankor__Width__c = 170;
        targetBoardTemplate.leankor__ValueStream__c = targetBoard.Id;
        template.add(targetBoardTemplate);
        insert template;
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'KanbanCard----1';
        kanbanCard.leankor__DurationUnits__c = 'Days';
        kanbanCard.leankor__EstimatedDuration__c = 1;
        //kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
        //kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
        kanbanCard.leankor__StartDateTime__c = System.Now(); 
        kanbanCard.leankor__DueDateTime__c = System.Now().addDays(1);
        kanbanCard.leankor__StartDate__c = System.today();
        kanbanCard.leankor__DueDate__c = System.today() + 1;
        kanbanCard.leankor__ValueStream__c = sourceBoard.Id;
        kanbanCard.leankor__isRecordDeleted__c = false;
        kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCard;
        
        List<leankor.HyperJumpWorkItemAction.HyperJumpRequest> hyperJumpRequests = new List<leankor.HyperJumpWorkItemAction.HyperJumpRequest>();
        List<leankor.HyperJumpWorkItemAction.HyperJumpRequest> result = new List<leankor.HyperJumpWorkItemAction.HyperJumpRequest>();

        leankor.HyperJumpWorkItemAction.HyperJumpRequest hyperJumpRequest = new leankor.HyperJumpWorkItemAction.HyperJumpRequest();
            hyperJumpRequest.KanbanCardID = kanbanCard.Id;
            hyperJumpRequest.KanbanName = 'KanbanCard----1';
            hyperJumpRequest.OldVSName = 'Source board';
            hyperJumpRequest.NewPRName = 'Test';
            hyperJumpRequest.NewVSName = 'Target board';
            hyperJumpRequest.BoardType = 'Kanban Board';
            hyperJumpRequest.TemplateName = 'Default';

        hyperJumpRequests.add(hyperJumpRequest);
       	Test.StartTest();
        result = leankor.HyperJumpWorkItemAction.HyperjumpToBoard(hyperJumpRequests);
        System.assertEquals(hyperJumpRequests.size(), result.size(), 'Method Executed Successfully.');
        Test.StopTest();
    }


    @isTest
    static void hyperjumpToBoardWBSAndSequenceNumber() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
		
		List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c targetBoard = new leankor__ValueStream__c();
		targetBoard.Name = 'Target board';
		targetBoard.leankor__ProjectRoom__c = project.Id;
        targetBoard.leankor__SevenDayWorkWeek__c = true;
		targetBoard.leankor__BoardType__c = 'Kanban Board';
        boards.add(targetBoard);

        leankor__ValueStream__c sourceBoard = new leankor__ValueStream__c();
		sourceBoard.Name = 'Source board';
		sourceBoard.leankor__ProjectRoom__c = project.Id;
        sourceBoard.leankor__SevenDayWorkWeek__c = true;
		sourceBoard.leankor__BoardType__c = 'Kanban Board';
		boards.add(sourceBoard);
        insert boards;

        leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name= 'Test MC';
		newMC.leankor__ValueStream__c = targetBoard.Id;
		insert newMC ;
		
		leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c = newMC.Id;
		newSw.leankor__ValueStream__c = targetBoard.Id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name = 'Test Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = System.now() +'Test Zone';
		zone.leankor__Y__c = 49.0;
		zone.leankor__Swimlane__c = newSw.Id;
		zone.leankor__ValueStream__c = targetBoard.Id;
		insert zone;

        List<leankor__KanbanCardTemplate__c> template = new List<leankor__KanbanCardTemplate__c>();
        leankor__KanbanCardTemplate__c sourceBoardTemplate = new leankor__KanbanCardTemplate__c();
        sourceBoardTemplate.Name = 'Default';
        sourceBoardTemplate.leankor__Title__c = 'Default';
        sourceBoardTemplate.leankor__Height__c = 120;
        sourceBoardTemplate.leankor__Color__c = '#bdbffc';
        sourceBoardTemplate.leankor__Width__c = 170;
        sourceBoardTemplate.leankor__ValueStream__c = sourceBoard.Id;
        template.add(sourceBoardTemplate);
        leankor__KanbanCardTemplate__c targetBoardTemplate = new leankor__KanbanCardTemplate__c();
        targetBoardTemplate.Name = 'Default';
        targetBoardTemplate.leankor__Title__c = 'Default';
        targetBoardTemplate.leankor__Height__c = 120;
        targetBoardTemplate.leankor__Color__c = '#bdbffc';
        targetBoardTemplate.leankor__Width__c = 170;
        targetBoardTemplate.leankor__ValueStream__c = targetBoard.Id;
        template.add(targetBoardTemplate);
        insert template;
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'KanbanCard----1';
        kanbanCard.leankor__DurationUnits__c = 'Days';
        kanbanCard.leankor__EstimatedDuration__c = 1;
        //kanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
        //kanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
        kanbanCard.leankor__StartDateTime__c = System.Now(); 
        kanbanCard.leankor__DueDateTime__c = System.Now().addDays(1);
        kanbanCard.leankor__StartDate__c = System.today();
        kanbanCard.leankor__DueDate__c = System.today() + 1;
        kanbanCard.leankor__ValueStream__c = sourceBoard.Id;
        kanbanCard.leankor__isRecordDeleted__c = false;
        kanbanCard.leankor__GUID__c = TestDataFactory.createGuid();
        insert kanbanCard;
        
        List<leankor.HyperJumpWorkItemAction.HyperJumpRequest> hyperJumpRequests = new List<leankor.HyperJumpWorkItemAction.HyperJumpRequest>();
        List<leankor.HyperJumpWorkItemAction.HyperJumpRequest> result = new List<leankor.HyperJumpWorkItemAction.HyperJumpRequest>();

        leankor.HyperJumpWorkItemAction.HyperJumpRequest hyperJumpRequest = new leankor.HyperJumpWorkItemAction.HyperJumpRequest();
            hyperJumpRequest.KanbanCardID = kanbanCard.Id;
            hyperJumpRequest.KanbanName = 'KanbanCard----1';
            hyperJumpRequest.OldVSName = 'Source board';
            hyperJumpRequest.NewPRName = 'Test';
            hyperJumpRequest.NewVSName = 'Target board';
            hyperJumpRequest.BoardType = 'Kanban Board';
            hyperJumpRequest.TemplateName = 'Default';

        hyperJumpRequests.add(hyperJumpRequest);
       	Test.StartTest();

        hyperJumpRequest.generateWorkBreakdownStructure = true;
        result = leankor.HyperJumpWorkItemAction.HyperjumpToBoard(hyperJumpRequests);
        System.assertEquals(hyperJumpRequests.size(), result.size(), 'Method Executed Successfully.');
        Test.StopTest();
    }
}