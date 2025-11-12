@isTest
private class FixKanbanDataBatchTest {

    static testMethod void batchTest() {
        //Create User.
        User u = leankor.TestDataFactory.createStandardUser('Lean123');        
        //Create Folder.
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        //
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 2);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', u);                        
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> activityList=leankor.TestDataFactory.createActivityGroups(valuestreamlist[0],template,5);
        List<leankor__KanbanCard__c> activities =new List<leankor__KanbanCard__c>();
        leankor__KanbanCard__c  activitycard=new leankor__KanbanCard__c();
            activitycard.Name='kb1';
            activitycard.leankor__ValueStream__c=valuestreamlist[0].id;
            activitycard.leankor__IsExternallyDependent__c=true;
            activitycard.leankor__GUID__c=leankor.TestDataFactory.createguid();
       activities.add(activitycard);
       insert activities;     
        List<leankor__Dependency__c>  dependencyList =new List<leankor__Dependency__c>();                
         leankor__Dependency__c dep =new leankor__Dependency__c();
           dep.leankor__Predecessor__c=activityList[0].id;
           dep.leankor__Successor__c=activities[0].id;
           dep.leankor__GUID__c=leankor.TestDataFactory.createguid();
           dependencyList.add(dep);           
        insert dependencyList;
        Test.startTest();
            leankor.FixKanbanDataBatch batch = new leankor.FixKanbanDataBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        System.assertEquals([SELECT Id FROM leankor__KanbanCard__c WHERE Name = 'kb1' LIMIT 999].size(), 1);
    }
}