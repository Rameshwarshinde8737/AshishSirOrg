/**************************************************************************
	* Company     : Leankor
 	* Description : Test class for DeleteKanbanCardAction.
 	* Usage	      : 
 	* None        : 
 **************************************************************************/ 
@isTest
private class DeleteKanbanCardActionTest {
	
	@isTest static void deleteKanbanCardProcessTest() {
		leankor__KanbanCard__c testRecord = new leankor__KanbanCard__c();
		testRecord.Name = 'Hello World';
		testRecord.leankor__GUID__c = '1';
		insert testRecord;

		leankor__ResourceAssignment__c rec = new leankor__ResourceAssignment__c();
		rec.leankor__KanbanCard__c = testRecord.Id;

		insert rec;

		DeleteKanbanCardAction.KanbanCardRequest kanbanCardRequest = new DeleteKanbanCardAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCards = new List<leankor__KanbanCard__c>{testRecord};
		List<DeleteKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<DeleteKanbanCardAction.KanbanCardRequest>{kanbanCardRequest};
		List<DeleteKanbanCardAction.KanbanCardResult> kanbanCardResults = DeleteKanbanCardAction.deleteKanbanCardProcess(kanbanCardRequests);

		Boolean actual = [Select leankor__isRecordDeleted__c 
													From leankor__KanbanCard__c 
													Where leankor__GUID__c = '1' 
													Limit 1].leankor__isRecordDeleted__c;
		Boolean expected = true;
		System.assertEquals(expected, actual, 'Method Executed Successfully.');
	}

	
	@isTest static void deleteKanbanCardProcessWBSAndSequenceNumber() {
		leankor__KanbanCard__c testRecord = new leankor__KanbanCard__c();
		testRecord.Name = 'Hello World';
		testRecord.leankor__GUID__c = '1';
		insert testRecord;

		leankor__ResourceAssignment__c rec = new leankor__ResourceAssignment__c();
		rec.leankor__KanbanCard__c = testRecord.Id;

		insert rec;

		DeleteKanbanCardAction.KanbanCardRequest kanbanCardRequest = new DeleteKanbanCardAction.KanbanCardRequest();
		kanbanCardRequest.kanbanCards = new List<leankor__KanbanCard__c>{testRecord};
		kanbanCardRequest.generateWorkBreakdownStructure = true; 
		List<DeleteKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<DeleteKanbanCardAction.KanbanCardRequest>{kanbanCardRequest};
		List<DeleteKanbanCardAction.KanbanCardResult> kanbanCardResults = DeleteKanbanCardAction.deleteKanbanCardProcess(kanbanCardRequests);

		Boolean actual = [Select leankor__isRecordDeleted__c 
													From leankor__KanbanCard__c 
													Where leankor__GUID__c = '1' 
													Limit 1].leankor__isRecordDeleted__c;
		Boolean expected = true;
		System.assertEquals(expected, actual, 'Method Executed Successfully.');
	}
}