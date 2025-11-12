/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestScheduledTaskDueDateChatter.cls
 * CLASS: TestScheduledTaskDueDateChatter
 */
@isTest
global class TestScheduledTaskDueDateChatter {
	@isTest
	private static  void TestTaskDueDateChatter() { 
        Test.startTest();
	    String sch = '0 0 23 1 1 ? '+(Date.today().year()+1);
	    leankor__ProjectRoom__c project =  new leankor__ProjectRoom__c(Name = 'kanban Room');
     	insert project;
      	//inserting valuestream and boardtype 'kanban board'
	    leankor__ValueStream__c kanbanBoard = new leankor__ValueStream__c(Name = 'kanban Board',leankor__ProjectRoom__c = project.Id);
	    insert kanbanBoard;
	    //inserting card in kanban board
	    List<leankor__Kanbancard__c> kclist = new  List<leankor__Kanbancard__c>();
	    for (integer i=1; i<20; i++) {
      		leankor__Kanbancard__c kanban = new leankor__Kanbancard__c();
		    kanban.Name = 'testScheduledApexFromTestMethod'+i;
		    kanban.leankor__valuestream__c = kanbanBoard.id;
		    kanban.leankor__GUID__c = 'system'+''+system.now()+i;
		    kclist.add(kanban);
		}
	    insert kclist;
        // adding 10 task per kanban card in kanban board
        List<Task> tsklist = new List<Task>();
        for (leankor__Kanbancard__c kc : kclist) {
            for (Integer i=1; i<10; i++) {
        		Task tsk = new Task();
            	tsk.Priority = 'Normal';
            	tsk.Status = 'Not Started';
            	tsk.ActivityDate = system.today();
            	tsk.WhatId = kc.id;
            	tsklist.add(tsk);
            }     
	    }
	    insert tsklist;     
        String jobId = System.schedule('testBasicScheduledApex',sch,new ScheduledTaskDueDateChatter());
	  	String jobIdSecond = System.schedule('testBasicScheduledApexSecond',sch,new ScheduledToDeleteStreamingChannel());
		String jobIdThird = System.schedule('testBasicScheduledApexThird',sch,new SchedulePurgeSoftDeletedRecords());

   		Test.stopTest();
   	  	System.assert([Select Id, 
								Name 
							From leankor__Kanbancard__c 
							Where Id In : kclist].size()!=0);      
   	}
}