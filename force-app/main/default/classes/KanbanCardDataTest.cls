@isTest
public class KanbanCardDataTest {

    @isTest
    static void testKanbanCardData() {
        // Create test records for the leankor.ProjectBoardCarousel.Card (assuming it's a valid SObject or Apex class)
        // Mocking Child Records
        List<leankor.ProjectBoardCarousel.Card> childRecords = new List<leankor.ProjectBoardCarousel.Card>();
        
        leankor.ProjectBoardCarousel.Card childCard1 = new leankor.ProjectBoardCarousel.Card();
        childCard1.Id = '001';
        childCard1.Name = 'Test Child Card 1';
        childRecords.add(childCard1);
        
        leankor.ProjectBoardCarousel.Card childCard2 = new leankor.ProjectBoardCarousel.Card();
        childCard2.Id = '002';
        childCard2.Name = 'Test Child Card 2';
        childRecords.add(childCard2);
        
        // Initialize KanbanCardData instance
        KanbanCardData kanbanCardData = new KanbanCardData();
        kanbanCardData.Name = 'Test Kanban Card';
        kanbanCardData.ChildRecords = childRecords;
        kanbanCardData.ChildCount = childRecords.size();
        kanbanCardData.Color = 'Red';
        kanbanCardData.PriorityIndex = 1;
        kanbanCardData.Id = '003';

        // Assert that values are correctly assigned
        System.assertEquals('Test Kanban Card', kanbanCardData.Name, 'The Name should be Test Kanban Card');
        System.assertEquals(2, kanbanCardData.ChildCount, 'The ChildCount should be 2');
        System.assertEquals('Red', kanbanCardData.Color, 'The Color should be Red');
        System.assertEquals(1, kanbanCardData.PriorityIndex, 'The PriorityIndex should be 1');
        System.assertEquals('003', kanbanCardData.Id, 'The Id should be 003');
        
        // Assert the child records
        System.assertEquals(2, kanbanCardData.ChildRecords.size(), 'There should be 2 child records');
        System.assertEquals('Test Child Card 1', kanbanCardData.ChildRecords[0].Name, 'The first child record should be Test Child Card 1');
        System.assertEquals('Test Child Card 2', kanbanCardData.ChildRecords[1].Name, 'The second child record should be Test Child Card 2');
    }
}