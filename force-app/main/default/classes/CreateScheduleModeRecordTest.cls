/*---------------------------------------------------------------------------------------
Copyright 2012-2016 Leankor. All rights reserved
Author     :    Taresh Pandey
Company    :    Leankor  
Description:    Test class to test management to Get a record of Card for New Gantt Resource
Inputs     :    List of Kanban Cards        
Output      :  No. It will create SM, RSA for each card.
Test Class  :  CreateScheduleModeRecordTest
History     :
<Date>       <Authors Name>     <Brief Description of Change>
12/21/2016    Taresh Pandey       Initial copy
---------------------------------------------------------------------------------------*/
@isTest
private class CreateScheduleModeRecordTest{
static testmethod void CreateScheduleModeRecordTestMetohd(){
  
		//Creating project
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'Test Room');
		insert testFolder;

        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c(Name = 'Test Room', leankor__Portfolio__c = testFolder.Id);
		insert prjRoom;

		// Create kanban cards
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'myVS1',
        leankor__ProjectRoom__c = prjRoom.Id,
        leankor__Boardtype__c = 'UberBoard',
        leankor__IsTemplateBoard__c = false);
        insert valueStream;

		List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        for (Integer i=0; i < 10; i++) {
            kanbanCardList.add(new leankor__KanbanCard__c(Name = ('kname'+i),
            leankor__GUID__c = ('guid'+i),
            leankor__StartDate__c =system.today()+1,
            leankor__DueDate__c= system.today(), 
            leankor__ValueStream__c = valueStream.Id,
            RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId()));                             
        }
        insert kanbanCardList;

	 	Test.startTest();   
		CreateScheduleModeRecord createScheduleMode = new CreateScheduleModeRecord();
		database.executebatch(createScheduleMode); 
		Test.stopTest(); 
	
		List<leankor__ScheduleMode__c> schedules = [SELECT Id FROM  leankor__ScheduleMode__c];
		System.Assert(schedules.Size()!=0);
}
}