/**
Copyright 2012-2016 Leankor. All rights reserved
Company    :    Leankor  
Description:    Test class to Batch Apex class for update kanbancard for recordtypeid as default activitycard after updating version from 1.188
Test Class :    CreateUberBoardTest
-----------------------------------------------------------------------------
*/
@isTest
global class CreateUberBoardTest{
  static testMethod void testCreateUberBoard()
  {
     Test.startTest();
     leankor__Portfolio__c  folder = new leankor__Portfolio__c(Name = 'kanban Folder');
     insert folder;
     List<leankor__ProjectRoom__c> projectlist = new List<leankor__ProjectRoom__c>();
     for(Integer i=1 ;i<1000;i++)
     {
       leankor__ProjectRoom__c project =  new leankor__ProjectRoom__c
   											(Name = 'kanban Room'+''+i,
   											leankor__Portfolio__c = folder.Id
   											);
       projectlist.add(project);      
     }
     insert projectlist;    
     
     /*List<leankor__ValueStream__c> planganttlsit = new List<leankor__ValueStream__c>();
     
     for(leankor__ProjectRoom__c pr : projectlist)
     {
     leankor__ValueStream__c kanbanBoard = new leankor__ValueStream__c
     										(leankor__BoardType__c = 'UberBoard',
     										leankor__ProjectRoom__c = pr.Id, 
     										Name = 'Plan Board(' + pr .Name + ')'
     										);         
     planganttlsit.add(kanbanBoard);
     }
     insert planganttlsit;
     */  
     CreateUberBoard CUB = new CreateUberBoard();
     database.executebatch(CUB,1000);        	 
     Test.stopTest();
   
     List<leankor__valuestream__c> vslist = [Select Id from leankor__valuestream__c where leankor__BoardType__c = 'UberBoard'];
     System.Assert(vslist.Size()!=0);
     
     List<leankor__KanbanCardTemplate__c> KCT = [SELECT Id FROM  leankor__KanbanCardTemplate__c where leankor__valuestream__c IN : vslist];
	 System.Assert(KCT.Size()!=0);   
  }
}