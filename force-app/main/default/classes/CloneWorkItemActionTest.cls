/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for CloneWorkItemAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private class CloneWorkItemActionTest {
    
    private static testMethod void testCloneKanbanCards() {
        Test.StartTest();
        // creating source folder data
        leankor__Portfolio__c sourceFolder = new leankor__Portfolio__c(Name = 'sourceFolder');
        insert sourceFolder;
        // creating source project data
        leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(Name = 'sourceProject', leankor__Portfolio__c = sourceFolder.Id, leankor__DueDate__c = System.today().addDays(6));
        insert sourceProject;
        leankor__ValueStream__c projectBoard = new leankor__ValueStream__c(Name = 'Project Board', leankor__BoardType__c = 'Kanban Board', leankor__ProjectRoom__c = sourceProject.Id);        
        insert projectBoard;
        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'kanbanCard-Name';
        kanbanCard.leankor__ValueStream__c = projectBoard.Id;   
        kanbanCard.leankor__StartDateTime__c = System.now().addDays(1);
        kanbanCard.leankor__DueDateTime__c = System.now().addDays(4);
        KanbanCard.leankor__StartDate__c = System.today() +1;
        kanbanCard.leankor__DueDate__c = System.today()+4;
        insert kanbanCard;

        List<CloneWorkItemAction.CloneKanbanCardRequest> cloneKanbanCardRequests = new List<CloneWorkItemAction.CloneKanbanCardRequest>();
        CloneWorkItemAction.CloneKanbanCardRequest cloneKanbanCardRequest = new CloneWorkItemAction.CloneKanbanCardRequest();
        List<CloneWorkItemAction.CloneKanbanCardRequest> result = new List<CloneWorkItemAction.CloneKanbanCardRequest>();
        cloneKanbanCardRequest.FinalDate = System.now().addDays(6);
        cloneKanbanCardRequest.KanbanID = kanbanCard.Id;

        cloneKanbanCardRequests.add(cloneKanbanCardRequest);
        result = CloneWorkItemAction.cloneKanbanCards(cloneKanbanCardRequests);
        System.assertEquals(cloneKanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');

        cloneKanbanCardRequest.generateWorkBreakdownStructure = true;
        cloneKanbanCardRequests.add(cloneKanbanCardRequest);

        result = CloneWorkItemAction.cloneKanbanCards(cloneKanbanCardRequests);
        System.assertEquals(cloneKanbanCardRequests.size(), result.size(), 'Method Executed Successfully.');
        Test.StopTest();
    }
}