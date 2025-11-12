@isTest
public class CreateKanbanBoardRaSmTest {
    @isTest
    static void testBatchExecution() {
        // Create a test user to assign as Owner
        User testUser = new User();
        testUser.Alias = 'tuser';
        testUser.Email = 'testuser@example.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = UserInfo.getProfileId();
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'testuser_' + System.currentTimeMillis() + '@example.com';
        insert testUser;

        // Create Valuestream with board type other than UberBoard
        leankor__Valuestream__c valueStream = new leankor__Valuestream__c();
        valueStream.Name = 'Test Stream';
        valueStream.leankor__boardtype__c = 'KanbanBoard';
        insert valueStream;

        // Create test Kanban Cards
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        for (Integer i = 0; i < 5; i++) {
            leankor__KanbanCard__c cards = new leankor__KanbanCard__c();
            cards.Name = 'Card ' + i;
            cards.leankor__PercentComplete2__c = 100;
            cards.OwnerId = testUser.Id;
            cards.leankor__Valuestream__c = valueStream.Id;
            cards.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCardList.add(cards);
        }
        insert kanbanCardList;

        Test.startTest();
        CreateKanbanBoardRaSm batch = new CreateKanbanBoardRaSm();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Assert related records
        List<leankor__ResourceAssignment__c> raList = [Select Id, 
                                                                leankor__KanbanCard__c,
                                                                leankor__CompletedDate__c 
                                                            From leankor__ResourceAssignment__c];
        System.assertEquals(5, raList.size(), 'All Kanban Cards should create ResourceAssignments');

        List<leankor__ScheduleMode__c> smList = [Select Id,
                                                        leankor__KanbanCard__c 
                                                    From leankor__ScheduleMode__c];
        System.assertEquals(5, smList.size(), 'All Kanban Cards should create ScheduleModes');

        // Check updated HarveyBallDoneDate
        List<leankor__KanbanCard__c> updatedCards = [Select Id,
                                                            leankor__HarveyBallDoneDate__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__HarveyBallDoneDate__c != NULL];
        System.assertEquals(5, updatedCards.size(), 'HarveyBallDoneDate should be updated');
    }

    @isTest
    static void testUberBoardExclusion() {
        // Card with UberBoard should be skipped
        leankor__Valuestream__c uberStream = new leankor__Valuestream__c();
        uberStream.Name = 'Uber Stream';
        uberStream.leankor__boardtype__c = 'UberBoard';
        insert uberStream;

        leankor__KanbanCard__c card = new leankor__KanbanCard__c();
        card.Name = 'UberCard';
        card.leankor__PercentComplete2__c = 100;
        card.OwnerId = UserInfo.getUserId();
        card.leankor__Valuestream__c = uberStream.Id;
        insert card;

        Test.startTest();
        CreateKanbanBoardRaSm batch = new CreateKanbanBoardRaSm();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<leankor__ResourceAssignment__c> raList = [Select Id 
                                                            From leankor__ResourceAssignment__c 
                                                            Where leankor__KanbanCard__c = :card.Id];
        System.assertEquals(0, raList.size(), 'UberBoard card should be skipped');
    }
}