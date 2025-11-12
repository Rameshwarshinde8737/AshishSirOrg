@isTest
public class ResourceAssignmentTest {
    @testSetup
    static void setupTestData() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
		project.Name = 'Test';
        insert project;
        
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
		valueStream.Name =  'Testing board'; 
		valueStream.leankor__ProjectRoom__c = project.id; 
		valueStream.leankor__BoardType__c = 'UberBoard';
		insert valueStream;

        List<leankor__KanbanCard__c> kanbanCardsList = new List<leankor__KanbanCard__c>();
        kanbanCardsList.add(new leankor__KanbanCard__c(Name = 'Test KanbanCard'));
        for (Integer i = 1; i <= 3; i++) {			
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
			kanbanCard.leankor__ValueStream__c = valueStream.Id;
			kanbanCard.Name = 'Test Gantt';
			kanbanCard.leankor__Title__c = 'Test Gantt Card ' + i;
			kanbanCard.leankor__DurationUnits__c = 'Days';
			kanbanCard.leankor__StartDateTime__c = System.now();
			kanbanCard.leankor__DueDateTime__c = System.now().addDays(i);
			kanbanCard.OwnerId = UserInfo.getUserId();
			kanbanCard.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
			
            kanbanCardsList.add(kanbanCard);
        }

        insert kanbanCardsList;
    }

    @isTest
    static void testCreateResourceAssignment() {
        // Prepare test data
        List<leankor__KanbanCard__c> kanbanCards = [Select 
                                                        Id From leankor__KanbanCard__c
                                                        Where leankor__ValueStream__r.Name = :'Testing board'
                                                        Limit 2];
        List<leankor__ResourceAssignment__c> resourceAssignments = new List<leankor__ResourceAssignment__c>();
        for (leankor__KanbanCard__c card : kanbanCards) {
            resourceAssignments.add(new leankor__ResourceAssignment__c(
                leankor__KanbanCard__c = card.Id,
                leankor__AssignedTo__c = UserInfo.getUserId(), // Assuming a Resource assignment to the current user
                leankor__PercentAllocation__c = 100,
                leankor__PercentCompleted__c = 5
            ));
        }

        // Call the createResourceAssignment method
        List<leankor__ResourceAssignment__c> createdResourceAssignments = ResourceAssignment.upsertResourceAssignments(resourceAssignments);

        // Assertions
        System.assertEquals(2, createdResourceAssignments.size(), 'Expected 2 resource assignments to be created');
        
    }

}