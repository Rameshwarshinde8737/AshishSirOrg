/**
Copyright 2012-2016 Leankor. All rights reserved
Company    :    Leankor  
Description:    Test class to Batch Apex class for update kanbancard for recordtypeid as default activitycard after updating version from 1.188
Test Class :    UpdateRecordTypeforCardTest
-----------------------------------------------------------------------------
*/

@isTest
global class UpdateRecordTypeKCTest{

  @isTest
  static void testBatchApexforCard()
  {
     Test.startTest();
     leankor__Portfolio__c  folder = new leankor__Portfolio__c(Name = 'kanban Folder');
     insert folder;
     
     leankor__ProjectRoom__c project =  new leankor__ProjectRoom__c(Name = 'kanban Room',leankor__Portfolio__c = folder.Id);
     insert project;
     
     leankor__ValueStream__c kanbanBoard = new leankor__ValueStream__c(Name = 'kanban Board',leankor__ProjectRoom__c = project.Id);
     insert kanbanBoard;
     
     list<leankor__KanbanCard__c> kanbanlist = new list<leankor__KanbanCard__c>();
       
     for(Integer i=1 ; i<=200;i++)
     {
      leankor__KanbanCard__c card = new leankor__KanbanCard__c();
      card.Name = 'kanban'+''+i;
      card.leankor__Valuestream__c = kanbanBoard.Id;
      card.leankor__GUID__c = kanbanBoard.Id + '' +i;      
      kanbanlist.add(card);
     } 
     insert kanbanlist; 
     
     ScheduledRecordTypeKC URTC = new ScheduledRecordTypeKC();
     SchedulableContext sc;
     URTC.execute(sc);      	    
     Test.stopTest(); 
     
     leankor__KanbanCard__c KC = [SELECT Id,RecordtypeId,RecordType.Name ,leankor__ValueStream__c FROM leankor__KanbanCard__c where leankor__ValueStream__c != null Limit 1];
	 System.Assert(KC.RecordType.Name=='ActivityCard');
   
  }
}