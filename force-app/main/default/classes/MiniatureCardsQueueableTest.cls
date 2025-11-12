@isTest
public class MiniatureCardsQueueableTest {
    
    static testmethod void testQueueable() {
    	
    	User u = leankor.TestDataFactory.createStandardUser('leankor1');
        list<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 5);
        list<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 5);        
        list<leankor__ValueStream__c> vStream = leankor.TestDataFactory.createValueStream(project, 'Kanban Board', u);       
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStream[0]);
        List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStream[0], template, 10, null, u);
    	
    	GanttTaskBoard.ActivityWrapper wrapper = new GanttTaskBoard.ActivityWrapper();
        wrapper.activity = new List<leankor__Kanbancard__c>{kanbanCardList[0]};
    	wrapper.boardType = 'Kanban Board';
    	wrapper.valueStreamId = vStream[0].Id;
    	
    	
    	
    	leankor__KanbanCard__c card1 = new leankor__KanbanCard__c();
    	card1.leankor__ValueStreamCardLink__c = kanbanCardList[0].Id;
    	card1.leankor__GUID__c = leankor.TestDataFactory.createGUID();
        card1.leankor__ValueStream__c = vStream[0].Id;
    	insert card1;
    	
    	leankor__KanbanCard__c card2 = new leankor__KanbanCard__c();
    	card2.leankor__ValueStreamCardLink__c = kanbanCardList[0].Id;
    	card2.leankor__GUID__c = leankor.TestDataFactory.createGUID();
        card2.leankor__ValueStream__c = vStream[0].Id;
    	insert card2;
        
    	MiniatureCardsQueueable miniCardQue = new MiniatureCardsQueueable(wrapper);
		
		Test.startTest();        
        System.enqueueJob(miniCardQue);
        Test.stopTest(); 
		List<leankor__KanbanCard__c> kanbanCards = [Select Id 
														From leankor__KanbanCard__c 
														Where leankor__ValueStreamCardLink__c =: kanbanCardList[0].Id 
														Limit 49999];
		System.assert(kanbanCards.size() > 0);
    }
    

}