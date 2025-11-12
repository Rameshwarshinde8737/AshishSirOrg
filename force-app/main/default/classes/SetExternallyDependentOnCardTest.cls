@isTest
public class  SetExternallyDependentOnCardTest{

      @isTest
      static void testExternalDependentforCard()
      {
         Test.startTest();
         
         List<leankor__Portfolio__c>  folder = leankor.TestDataFactory.createFolder('Folder',1);
         
         //creating projects 
         List<leankor__ProjectRoom__c> project1 =  leankor.TestDataFactory.createProjects('Project',folder,1);
         List<leankor__ProjectRoom__c> project2 =  leankor.TestDataFactory.createProjects('Project',folder,2);
         
         System.Assert(project1.size() != 0);
         
         //creating valuestreams 
         List<leankor__ValueStream__c> PlanBoard1 = leankor.TestDataFactory.createValueStream(project1,'UberBoard',null);
         List<leankor__ValueStream__c> PlanBoard2 = leankor.TestDataFactory.createValueStream(project2,'UberBoard',null);
         
         System.Assert(PlanBoard1.size() != 0);    
         
         //creating template for valuestreams 
         leankor__KanbanCardTemplate__c kc1 = leankor.TestDataFactory.createKanbanCardTemplate(PlanBoard1[0]);
         leankor__KanbanCardTemplate__c kc2 = leankor.TestDataFactory.createKanbanCardTemplate(PlanBoard2[0]);
         
         System.Assert(kc1 != null);
         
         //creating activity groups
         List<leankor__KanbanCard__c> kanbanlistGroup1 = leankor.TestDataFactory.createActivityGroups(PlanBoard1[0],kc1,5);
         List<leankor__KanbanCard__c> kanbanlist1Group2 = leankor.TestDataFactory.createActivityGroups(PlanBoard2[0],kc2,5);
         
         
         //creating activities 
         List<leankor__KanbanCard__c> kanbanlist1 = leankor.TestDataFactory.createChildActivity(PlanBoard1[0],kc1,kanbanlistGroup1,5);
         List<leankor__KanbanCard__c> kanbanlist2 = leankor.TestDataFactory.createChildActivity(PlanBoard2[0],kc2,kanbanlist1Group2,5);
         
         
         
         System.Assert(kanbanlist1 != null);
         
         List<leankor__Dependency__c> dplist = new List<leankor__Dependency__c>();
         
         for(Integer i=0;i <kanbanlist1Group2.size() ; i++)
         {
           leankor__Dependency__c dp = new leankor__Dependency__c();
           
           dp.leankor__Successor__c = kanbanlist1[i].Id;
           dp.leankor__Predecessor__c = kanbanlist1Group2[i].Id;
           dp.leankor__GUID__c = kanbanlist1[i].Id+''+kanbanlist1Group2[i].Id;
           dplist.add(dp);
         }
         
         for(Integer i=0;i<kanbanlistGroup1.size(); i++)
         {
           leankor__Dependency__c dp = new leankor__Dependency__c();
           
           dp.leankor__Successor__c = kanbanlistGroup1[i].Id;
           dp.leankor__Predecessor__c = kanbanlist2[i].Id;
           dp.leankor__GUID__c = kanbanlistGroup1[i].Id+''+kanbanlist2[i].Id;
           dplist.add(dp);
         }
         
         insert dplist;
           
         System.Assert([Select Id from leankor__Dependency__c].size()>0);
         
         List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
         for(Integer i = 0; i < 5; i++)
         {
                leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                ag.Name = 'Activity ' + i;
                ag.RecordTypeId = leankor.TestDataFactory.getRecordType('leankor__KanbanCard__c','foldercard').Id;
                ag.leankor__ValueStream__c = PlanBoard1[0].Id;
                ag.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);               
                ag.leankor__ValueStreamCardLink__c = kanbanlistGroup1[i].Id;             
                kclist.add(ag);
         }
         insert kclist;
           
         ScheduleExternalDependentOnCard URTC = new ScheduleExternalDependentOnCard();
         SchedulableContext sc;
         URTC.execute(sc);              
         
         Test.stopTest();              
         
         List<leankor__KanbanCard__c> klist = [Select Id , leankor__isExternallyDependent__c from leankor__KanbanCard__c where Id IN : kclist];
         System.Assert(klist[0].leankor__isExternallyDependent__c);                
      }
       
}