@isTest
public class SuccessorCardsQeueuableTest {
	
	static testmethod void testQueueable() {
        
        User systemAdmin = leankor.TestDataFactory.createSystemUser('leankor2');
        User communityUser1 = leankor.TestDataFactory.createCommunityUser('Communi');
        System.runAs(systemAdmin){
        	leankor.TestDataFactory.assignpermissionSet('Visual_Lean_Customer_Community_User',communityUser1);
        }
        
        User u = leankor.TestDataFactory.createStandardUser('leankor1');
        System.runAs(systemAdmin){
            leankor.TestDataFactory.assignpermissionSet('Visual_lean_user',u);
        }
        
        List<leankor__Portfolio__c> folders = leankor.TestDataFactory.createFolder('Test Folder', 5);
        List<leankor__ProjectRoom__c> projects = leankor.TestDataFactory.createProjects('Test Project', folders, 5);     
        List<leankor__ValueStream__c> vStreams = leankor.TestDataFactory.createValueStream(projects, 'UberBoard', u);  
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(vStreams[0]);
        List<leankor__KanbanCard__c> kanbanCardList = leankor.TestDataFactory.createKanbanCard(vStreams[0], template, 10, null, u);

        List<leankor__KanbanCard__c> updateKanbans = [Select Id, 
																RecordTypeId 
															From leankor__KanbanCard__c 
															Where leankor__ValueStream__c = :vStreams[0].Id];
        
        for (leankor__KanbanCard__c kb : updateKanbans) {
            kb.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
        }
        update updateKanbans;

        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        
        leankor__Dependency__c dep1 = new leankor__Dependency__c();
        dep1.leankor__Predecessor__c = kanbanCardList[0].Id;
        dep1.leankor__Successor__c = kanbanCardList[1].Id;
        dep1.leankor__ValueStream__c = vStreams[0].Id;
        dep1.leankor__GUID__c = 'Test1';
        dependencies.add(dep1);
        
        leankor__Dependency__c dep2 = new leankor__Dependency__c();
        dep2.leankor__Predecessor__c = kanbanCardList[0].Id;
        dep2.leankor__Successor__c = kanbanCardList[2].Id;
        dep2.leankor__ValueStream__c = vStreams[0].Id;
        dep2.leankor__GUID__c = 'Test2';
        dependencies.add(dep2);
        
        leankor__Dependency__c dep3 = new leankor__Dependency__c();
        dep3.leankor__Predecessor__c = kanbanCardList[1].Id;
        dep3.leankor__Successor__c = kanbanCardList[2].Id;
        dep3.leankor__ValueStream__c = vStreams[0].Id;
        dep3.leankor__GUID__c = 'Test3';
        dependencies.add(dep3);
        
        leankor__Dependency__c dep4 = new leankor__Dependency__c();
        dep4.leankor__Predecessor__c = kanbanCardList[1].Id;
        dep4.leankor__Successor__c = kanbanCardList[3].Id;
        dep4.leankor__ValueStream__c = vStreams[0].Id;
        dep4.leankor__GUID__c = 'Test4';
        dependencies.add(dep4);
        
        insert dependencies;
        
        List<leankor__KanbanCard__c> predecessors = new List<leankor__KanbanCard__c>();
        predecessors.add(kanbanCardList[0]);
        predecessors.add(kanbanCardList[1]);
        
        Set<String> valueStreamIds = new Set<String>();
        valueStreamIds.add(vStreams[0].Id);
        Test.startTest();
        System.runAs(communityUser1){
            SuccessorCardsQeueuable queueJobFlow = new SuccessorCardsQeueuable(predecessors, valueStreamIds, UserInfo.getSessionId(), true);
            SuccessorCardsQeueuable queueJobNonFlow = new SuccessorCardsQeueuable(predecessors, valueStreamIds, UserInfo.getSessionId());
            
            System.enqueueJob(queueJobFlow);
            System.enqueueJob(queueJobNonFlow);
            
            List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                                leankor__IsOnHold__c 
                                                            From leankor__KanbanCard__c 
                                                            Where Id = :predecessors.get(0).Id 
                                                            Limit 49999];
            
            System.assert(kanbanCards[0].leankor__IsOnHold__c == false);
            
        }
        System.runAs(u){
            SuccessorCardsQeueuable queueJobFlow = new SuccessorCardsQeueuable(predecessors, valueStreamIds, UserInfo.getSessionId(), true);
            SuccessorCardsQeueuable queueJobNonFlow = new SuccessorCardsQeueuable(predecessors, valueStreamIds, UserInfo.getSessionId());
            
            System.enqueueJob(queueJobFlow);
            System.enqueueJob(queueJobNonFlow);
            
            List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                                leankor__IsOnHold__c 
                                                            From leankor__KanbanCard__c 
                                                            Where Id = :predecessors.get(0).Id 
                                                            Limit 49999];
            
            System.assert(kanbanCards[0].leankor__IsOnHold__c == false);
			
        }
        Test.stopTest();
	}
}