@isTest
private class CreateScheduleModeRecordsQueueableTest {
    
    @testSetup
    private static void testData(){
        
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name='Demo Project Name';
        insert projectRecord;
        
        leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
        valueStreamRecord.Name ='ps create';
        valueStreamRecord.leankor__ProjectRoom__c = projectRecord.Id;
        valueStreamRecord.leankor__BoardType__c = 'Kanban Board';
        valueStreamRecord.leankor__SevenDayWorkWeek__c = true;
        valueStreamRecord.leankor__IsTemplateBoard__c = false;
        insert valueStreamRecord;
        
        leankor__MasterContainer__c  masterContainerRecord = new leankor__MasterContainer__c ();
        masterContainerRecord.Name = 'master c';
        masterContainerRecord.leankor__Type__c = 'Archive';
        masterContainerRecord.leankor__GUID__c = TestDataFactory.createGuid();
        insert masterContainerRecord;
        
        List<leankor__KanbanCard__c> listKanbanCard = new List<leankor__KanbanCard__c>();
        for(Integer count=1;count<=2023;count++){
            leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
            kanbanCardRecord.Name = 'kb'+count;
            kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCardRecord.leankor__ValueStream__c = valueStreamRecord.Id;
            kanbanCardRecord.leankor__MasterContainer__c = masterContainerRecord.Id;
            kanbanCardRecord.leankor__ValueStreamCardLink__c = null;
            kanbanCardRecord.leankor__DueDateTime__c = system.now().addDays(1);
            kanbanCardRecord.leankor__DurationUnits__c = 'Days';
            kanbanCardRecord.leankor__EstimatedDuration__c = 1;
            kanbanCardRecord.leankor__isRecordDeleted__c = false;
            kanbanCardRecord.leankor__StartDate__c = System.Today();
            kanbanCardRecord.leankor__DueDate__c = System.Today().addDays(1);
            kanbanCardRecord.RecordTypeId = Schema.Sobjecttype.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            listKanbanCard.add(kanbanCardRecord);
        }
        insert listKanbanCard;  
    }
    @istest static void executeTest(){

        CreateScheduleModeRecordsQueueable scheduleModeRecordsQueueable = new CreateScheduleModeRecordsQueueable();	
        Test.startTest();
        Id jobId = System.enqueueJob(new CreateScheduleModeRecordsQueueable());
        System.assert(jobId != null);
        Test.stopTest(); 
        AsyncApexJob jobInfo = [Select Status,
                                       NumberOfErrors 
                                  From AsyncApexJob 
                                  Where Id=:jobId];
       }    
}