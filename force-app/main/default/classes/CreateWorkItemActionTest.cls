/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for CreateWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest 
private class CreateWorkItemActionTest {
 
    @isTest
    private static void createKanbanCardProcess() {
		Test.StartTest();
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Test-folder';
        insert folder;

        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test-Project';
        project.leankor__Portfolio__c = folder.Id;
        insert project;
		
		List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name = 'Testing board';
		valueStream.leankor__ProjectRoom__c = project.Id;
		valueStream.leankor__BoardType__c = 'Kanban Board';
		boards.add(valueStream);

		leankor__ValueStream__c planGantt = new leankor__ValueStream__c();
		planGantt.Name = 'Testing gantt';
		planGantt.leankor__ProjectRoom__c = project.Id;
		planGantt.leankor__BoardType__c = 'UberBoard';
		boards.add(planGantt);
		insert boards;

		leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name = 'Test MC';
		newMC.leankor__ValueStream__c = valueStream.Id;
		insert newMC ;
		
		leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test SW';
		newSw.leankor__MasterContainer__c = newMC.Id;
		newSw.leankor__ValueStream__c = valueStream.Id;
		insert newSw;         

		leankor__Zone__c zone = new leankor__Zone__c();
		zone.Name = 'Test Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = System.now() +'Test Zone';
		zone.leankor__Y__c = 49.0;
		zone.leankor__Swimlane__c = newSw.Id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

		List<leankor__KanbanCardTemplate__c> cardTemplates = new List<leankor__KanbanCardTemplate__c>();
		leankor__KanbanCardTemplate__c kanbanTemplate = new leankor__KanbanCardTemplate__c();
		kanbanTemplate.leankor__JSONDefinition__c = '';
		kanbanTemplate.leankor__JSONData__c = '';
		kanbanTemplate.leankor__Width__c = 170;
		kanbanTemplate.leankor__Height__c = 120; 
		kanbanTemplate.leankor__CSSLayout__c = '';
		kanbanTemplate.leankor__Color__c = '#bdbffc';
		kanbanTemplate.leankor__ValueStream__c = valueStream.Id;
		kanbanTemplate.Name = 'Default';
		kanbanTemplate.leankor__Title__c = 'Default';
		cardTemplates.add(kanbanTemplate);

		leankor__KanbanCardTemplate__c ganttTemplate = new leankor__KanbanCardTemplate__c();
		ganttTemplate.leankor__JSONDefinition__c = '';
		ganttTemplate.leankor__JSONData__c = '';
		ganttTemplate.leankor__Width__c = 170;
		ganttTemplate.leankor__Height__c = 120; 
		ganttTemplate.leankor__CSSLayout__c = '';
		ganttTemplate.leankor__Color__c = '#bdbffc';
		ganttTemplate.leankor__ValueStream__c = planGantt.Id;
		ganttTemplate.Name = 'Default';
		ganttTemplate.leankor__Title__c = 'Default';
		cardTemplates.add(ganttTemplate);
		insert cardTemplates;

		leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
		blackOut.Name = 'Test Blackout';
		blackOut.leankor__EndDate__c = System.Today()+20;
		blackOut.leankor__ProjectBoard__c = valueStream.Id;
		blackOut.leankor__StartDate__c = System.Today()+18;
		insert blackOut;

        List<leankor.CreateWorkItemAction.KanbanCardRequest> kanbanCardRequests = new List<leankor.CreateWorkItemAction.KanbanCardRequest>();
        List<leankor.CreateWorkItemAction.KanbanCardRequest> result = new List<leankor.CreateWorkItemAction.KanbanCardRequest>();
        leankor.CreateWorkItemAction.KanbanCardRequest kanbanCardRequest = new leankor.CreateWorkItemAction.KanbanCardRequest();
        kanbanCardRequest.Title = 'KanbanCard-Example';
        kanbanCardRequest.CategoryName = 'Default';
        kanbanCardRequest.StartDate = System.Now();
        kanbanCardRequest.ZoneName = 'Test Zone';
        kanbanCardRequest.ProjectBoardName = 'Testing board';
        kanbanCardRequest.ProjectRoomName = 'Test-Project';
        kanbanCardRequest.EstimatedDuration = 2;
        kanbanCardRequests.add(kanbanCardRequest);
        result = leankor.CreateWorkItemAction.createKanbanCardProcess(kanbanCardRequests);
        System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');

		kanbanCardRequest.generateWorkBreakdownStructure = true; 
		kanbanCardRequests.add(kanbanCardRequest);
		result = leankor.CreateWorkItemAction.createKanbanCardProcess(kanbanCardRequests);
        System.assertEquals(kanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
		Test.StopTest();
    }
}