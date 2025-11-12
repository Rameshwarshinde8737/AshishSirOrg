@isTest
private class LeankorViewControllerTest {
    @testSetup static void setupTestData() {
        String projectRoomId = createTestProjectRecord('Project', createTestFolderRecord('Folder').Id).id;
        createTestValueStreamRecord('Kanban', projectRoomId, 'Kanban Board');
        createTestValueStreamRecord('Gantt', projectRoomId, 'UberBoard');
    }


	private static leankor__Portfolio__c createTestFolderRecord(String nameInput) {
		leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
		testFolder.Name = nameInput;
		insert testFolder;
		return testFolder;
    }
    
    
	private static leankor__ProjectRoom__c createTestProjectRecord(String nameInput, String folderId) {
		leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
		testProject.Name = nameInput;
		testProject.leankor__Portfolio__c = folderId;
		insert testProject;
		return testProject;
	}


	private static leankor__ValueStream__c createTestValueStreamRecord(String nameInput, String projectRoomId, String boardType) {
		leankor__ValueStream__c testValueStream = new leankor__ValueStream__c();
		testValueStream.Name = nameInput;
		testValueStream.leankor__ProjectRoom__c = projectRoomId;
		testValueStream.leankor__BoardType__c = boardType;
		insert testValueStream;
		return testValueStream;
	}


    @isTest static void getGanttViewURLProjectRoomTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ProjectRoom__c Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getGanttViewURL(recordId)));
        Test.stopTest(); 
    }


    @isTest static void getGanttViewURLValueStreamTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'UberBoard' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getGanttViewURL(recordId)));
        Test.stopTest();
    }


    @isTest static void getKanbanViewURLTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'Kanban Board' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getKanbanViewURL(recordId)));
        Test.stopTest();
    }


    @isTest static void getCalendarViewURLTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'Kanban Board' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getCalendarViewURL(recordId)));
        Test.stopTest();
    }


    @isTest static void getDashboardViewURLTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'Kanban Board' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getDashboardViewURL(recordId)));
        Test.stopTest();
    }

  
    @isTest static void getWhiteboardViewURLTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'Kanban Board' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getWhiteboardViewURL(recordId)));
        Test.stopTest();
    }


    @isTest static void getResourceUtilizationViewURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getResourceUtilizationViewURL('')));
        Test.stopTest();
    }


    @isTest static void getResourceScheduleViewURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getResourceScheduleViewURL('')));
        Test.stopTest();
    }


    @isTest static void getCapacityPlanningViewURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getCapacityPlanningViewURL('')));
        Test.stopTest();
    }


    @isTest static void getPortfolioGanttViewURLPortfolioTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__Portfolio__c Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getPortfolioGanttViewURL(recordId)));
        Test.stopTest(); 
    }

    @isTest static void getPortfolioGanttViewURLProjectRoomTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ProjectRoom__c Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getPortfolioGanttViewURL(recordId)));
        Test.stopTest(); 
    }


    @isTest static void getPortfolioGanttViewURLValueStreamTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'UberBoard' Limit 1].Id;
        System.assert(String.isNotBlank(LeankorViewController.getPortfolioGanttViewURL(recordId)));
        Test.stopTest();
    }    

    
    @isTest static void getMyWorkViewURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getMyWorkViewURL()));
        Test.stopTest();
    }


    @isTest static void getLeankorNavViewURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getLeankorNavViewURL()));
        Test.stopTest();
    }

    
    @isTest static void readValueStreamTest() {
        Test.startTest();
        String recordId = [Select Id From leankor__ValueStream__c Where leankor__BoardType__c = 'UberBoard' Limit 1].Id;
        System.assert(LeankorViewController.readValueStream('UberBoard', 'Id', recordId) != null);
        Test.stopTest();
    }

    @isTest static void getDomainURLTest() {
        Test.startTest();
        System.assert(String.isNotBlank(LeankorViewController.getDomainURL()));
        Test.stopTest();
    }	
}