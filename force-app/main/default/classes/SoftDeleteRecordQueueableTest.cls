/**
 * Company : Leankor
 * FILE: SoftDeleteRecordQueueableTest.cls
 * CLASS: SoftDeleteRecordQueueableTest.cls        
 */
@isTest
private class SoftDeleteRecordQueueableTest{

    @testSetup
    private static void testData() {
       
        leankor__ProjectRoom__c projectRecord1 = new leankor__ProjectRoom__c();
        projectRecord1.Name = 'Demo Project Name1';

        insert projectRecord1;
        
        List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();

        for (Integer valuStreamCount = 1; valuStreamCount <= 5; valuStreamCount++) {
            leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
            valueStreamRecord.Name = 'valueStream Record ' + valuStreamCount;
            valueStreamRecord.leankor__ProjectRoom__c = projectRecord1.Id;
            valueStreamRecord.leankor__isRecordDeleted__c = false;
            valueStreamList.add(valueStreamRecord);
        }
        
        insert valueStreamList;
        
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        
        for (leankor__ValueStream__c valueStream : valueStreamList) {

            for (Integer  kanbanCardcardCount = 1;  kanbanCardcardCount <= 800;  kanbanCardcardCount++) {
                leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
                kanbanCardRecord.Name = 'kanbanCardRecord ' + kanbanCardcardCount + ' for ValueStream ' + valueStream.Name;
                kanbanCardRecord.leankor__GUID__c = testDataFactory.createGuid();
                kanbanCardRecord.leankor__ValueStream__c = valueStream.Id;
                kanbanCardRecord.leankor__isRecordDeleted__c = false;
                kanbanCardList.add(kanbanCardRecord);
            }
        }
        
        insert kanbanCardList;
    }

    @isTest
    static void testExecute() {
        
            Test.startTest();

            leankor__ProjectRoom__c projectRecord2 = new leankor__ProjectRoom__c();
            projectRecord2.Name = 'Demo Project Name2';
    
            insert projectRecord2;

            List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
    
            for (Integer valuStreamCount = 1; valuStreamCount <= 5; valuStreamCount++) {
                leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
                valueStreamRecord.Name = 'valueStream Record ' + valuStreamCount;
                valueStreamRecord.leankor__ProjectRoom__c = projectRecord2.Id;
                valueStreamRecord.leankor__isRecordDeleted__c = false;
                valueStreamList.add(valueStreamRecord);
            }
            
            insert valueStreamList;
            
            List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
            
            for (leankor__ValueStream__c valueStream : valueStreamList) {

                for (Integer  kanbancardCount = 1; kanbancardCount <= 800; kanbancardCount++) {
                    leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
                    kanbanCardRecord.Name = 'kanbanCardRecord ' + kanbancardCount + ' for ValueStream ' + valueStream.Name;
                    kanbanCardRecord.leankor__GUID__c = testDataFactory.createGuid();
                    kanbanCardRecord.leankor__ValueStream__c = valueStream.Id;
                    kanbanCardRecord.leankor__isRecordDeleted__c = false;
                    kanbanCardList.add(kanbanCardRecord);
                }
            }
            
            insert kanbanCardList;

        List<leankor__ProjectRoom__c> projectRooms = [Select Id 
                                                       From leankor__ProjectRoom__c
                                                       Where Name In ('Demo Project Name1','Demo Project Name2')];

        List<String> projectRoomIds = new List<String>();
        
        for (leankor__ProjectRoom__c projectRoom : projectRooms) {
            projectRoomIds.add(projectRoom.Id);
        }

        SoftDeleteRecordQueueable SoftDeleteRecordQueueableInstance = new SoftDeleteRecordQueueable(projectRoomIds);
 
        id jobId = System.enqueueJob(SoftDeleteRecordQueueableInstance);

        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job ID should not be null');

    }
}