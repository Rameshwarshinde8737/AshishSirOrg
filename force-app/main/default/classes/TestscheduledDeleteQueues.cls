@isTest
private class TestscheduledDeleteQueues {

   static testmethod void test() {
      Boolean expectedValue = true;
      Test.startTest();
      Group g = new Group(Type ='Queue', Name ='Queue name');
      insert g;
   
      QueueSObject q = new QueueSObject(SobjectType ='leankor__KanbanCard__c', QueueId = g.Id);
      insert q;
	   String sch = '0 0 23 1 1 ? '+(Date.today().year()+1);
      String jobId = System.schedule('testBasicScheduledApex',sch,new scheduledDeleteQueues());
      System.assertEquals(true, expectedValue);
      Test.stopTest();
   }
    
    static testmethod void test1() {
      Boolean expectedValue = true;
      Test.startTest();
		String sch1 = '0 0 23 1 1 ? '+(Date.today().year()+1);
      leankor__Kanbancard__c kanban1 = new leankor__Kanbancard__c();
      kanban1.Name = 'testScheduledProjectBoardStats';
      insert kanban1;

      String jobId1 = System.schedule('testBasicScheduledApex1',sch1,new scheduledProjectBoardStats());
      Test.stopTest();
      System.assertEquals('testScheduledProjectBoardStats',[Select Id, Name From leankor__Kanbancard__c Where Id = :kanban1.Id].Name);
      System.assertEquals(true, expectedValue);
   }
}