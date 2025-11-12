@isTest
private class CreateTaskSFActionTest {
    @isTest
    private static void insertTaskActionTest(){
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Test-folder';
        insert folder;
        leankor__Projectroom__c project =  new leankor__Projectroom__c();
        project.Name = 'Test-Project';
        project.leankor__Portfolio__c = folder.Id;
        insert project;
        leankor__ValueStream__c board = new leankor__ValueStream__c();
        board.Name = 'Test-Board';
        board.leankor__BoardType__c = 'Kanban Board';
        board.leankor__projectroom__c = project.Id;
        insert board;
        leankor__kanbancard__c card =  new leankor__kanbancard__c();
        card.Name = 'Test-Card';
        card.leankor__GUID__c = TestDataFactory.createGuid();
        card.leankor__ValueStream__c = board.Id;
        insert card;
        List<leankor.CreateTaskSFAction.TaskDataRequest> requests = new List<leankor.CreateTaskSFAction.TaskDataRequest>();	
        List<leankor.CreateTaskSFAction.TaskDataRequest> results = new List<leankor.CreateTaskSFAction.TaskDataRequest>();	

        leankor.CreateTaskSFAction.TaskDataRequest request = new leankor.CreateTaskSFAction.TaskDataRequest();
        request.WhatId = card.Id;
        request.Description = 'Task is creating for testing';
        request.Subject = 'Demo-Task';
        request.Priority = 'High';
        requests.add(request);
        Test.startTest();
        results = leankor.CreateTaskSFAction.insertTaskAction(requests);
        System.assertEquals(requests.size(), results.size());
        Test.stopTest();
			 	

    }
}