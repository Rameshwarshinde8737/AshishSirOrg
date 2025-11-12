@isTest
private with sharing class UpdateWorkItemActionTest {
    

    @isTest
    private static void UpdateKanbanCardProcessTest(){ 

        Test.startTest();
            leankor__ProjectRoom__c insertroom = new leankor__ProjectRoom__c(Name ='testRoom');
            insert insertroom;
            
            leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = insertroom.ID);
            Insert vStream;

            leankor__KanbanCardTemplate__c temp =new leankor__KanbanCardTemplate__c (Name = 'test_temp', leankor__Valuestream__c =vStream.Id,leankor__Title__C ='test_temp');
            insert temp;

            leankor__Kanbancard__c newcard =new leankor__Kanbancard__c(Name = 'testkanaban12',leankor__title__c ='test_title',leankor__ValueStream__c = vStream.ID ,leankor__KanbanCardTemplate__c =temp.ID,leankor__GUID__C ='305ee49a-test-4df-bf76-8a080880611', leankor__StartDate__c = System.today(), leankor__DueDate__c = System.today() + 10, leankor__StartDateTime__c = System.now(), leankor__DueDateTime__c = System.now() + 10, RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId());
            insert newcard;
            List<leankor.UpdateWorkItemAction.KanbanCardRequest> updatedatas  = new List<leankor.UpdateWorkItemAction.KanbanCardRequest>();
            leankor.UpdateWorkItemAction.KanbanCardRequest updatedata  = new leankor.UpdateWorkItemAction.KanbanCardRequest();
            updatedata.ID =newcard.ID;
            updatedata.CategoryName='test_temp';
            updatedata.Title ='updatetitle';
            updatedata.Name = 'Demo records';
            updatedatas.add(updatedata);
            leankor.UpdateWorkItemAction.UpdateKanbanCardProcess(updatedatas);
        Test.stopTest();

        leankor__KanbanCard__c oldKanbanCardRecords = [Select 
                                                            Id,
                                                            Name,
                                                            leankor__Title__c,
                                                            leankor__Description__c,
                                                            leankor__KanbanCardTemplate__r.Name
                                                            From leankor__KanbanCard__c 
                                                            Limit 1];

        System.assert(oldKanbanCardRecords.Name == 'Demo records');
    }
}