@isTest
public class SubscriberTest {
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

        // Create test Subscriber records
        List<leankor__Subscriber__c> subscribers = new List<leankor__Subscriber__c>();
        for (leankor__KanbanCard__c card : kanbanCardsList) {
            subscribers.add(new leankor__Subscriber__c(
                Name = 'Test Subscriber',
                leankor__KanbanCard__c = card.Id,
                leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid(),
                leankor__SubscriberId__c = UserInfo.getUserId(),
                leankor__Moved__c = false,
                leankor__PercentDone__c = false,
                leankor__CardPastDueDate__c = false,
                leankor__TaskPastDueDate__c = false,
                leankor__isTaskCompleted__c = false
            ));
        }
        insert subscribers;
    }

    @isTest
    static void testGetSubscribers() {
        // Retrieve test KanbanCard IDs
        Test.startTest();
        List<leankor__KanbanCard__c> kanbanCards = [Select 
                                                            Id 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__r.Name = :'Testing board'
                                                        Limit 3];
        List<Id> kanbanCardIds = new List<Id>();
        for (leankor__KanbanCard__c card : kanbanCards) {
            kanbanCardIds.add(card.Id);
        }

        // Instantiate the class and call getSubscribers
        Subscriber subscriberClass = new Subscriber();
        List<leankor__Subscriber__c> subscribers = subscriberClass.getSubscribers(kanbanCardIds);
        Test.stopTest();
        // Assertions
        System.assertEquals(3, subscribers.size(), 'Expected 3 subscribers to be returned');
    }

    @isTest
    static void testUpsertSubscribers() {
        // Prepare test subscribers
        Test.startTest();
        List<leankor__KanbanCard__c> kanbanCards = [Select 
                                                            Id 
                                                        From leankor__KanbanCard__c
                                                        Where Name =:'Test KanbanCard'
                                                        Limit 1];
        List<leankor__Subscriber__c> newSubscribers = new List<leankor__Subscriber__c>();
        for (Integer i = 0; i < 2; i++) {
            newSubscribers.add(new leankor__Subscriber__c(
                Name = 'New Test Subscriber ' + i,
                leankor__KanbanCard__c = kanbanCards[0].Id,
                leankor__SubscriberId__c = UserInfo.getUserId(),
                leankor__Moved__c = false,
                leankor__PercentDone__c = false,
                leankor__CardPastDueDate__c = false,
                leankor__TaskPastDueDate__c = false,
                leankor__isTaskCompleted__c = false,
                leankor__SubscriberKey__c = leankor.TestDataFactory.createGuid()
            ));
        }

        // Call createSubscribers
        List<leankor__Subscriber__c> insertedSubscribers = Subscriber.upsertSubscribers(newSubscribers);
        Test.stopTest();
        // Assertions
        System.assertEquals(2, insertedSubscribers.size(), 'Expected 2 subscribers to be created');
    }
}