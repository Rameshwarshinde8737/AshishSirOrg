@isTest
private class MergeProjectBoardSFActionTest {
   @isTest
   private static void mergeProjectBoardTest(){
    Test.StartTest();
    leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Test-folder';
        insert folder;
        leankor__ProjectRoom__c project =  new leankor__ProjectRoom__c();
        project.Name = 'Test-Project';
        project.leankor__Portfolio__c = folder.Id;
        insert project;
        leankor__ValueStream__c boardFirst = new leankor__ValueStream__c();
        boardFirst.Name = 'Test-Board';
        boardFirst.leankor__BoardType__c = 'Kanban Board';
        boardFirst.leankor__projectroom__c = project.Id;
        boardFirst.leankor__SevenDayWorkWeek__c = true;
        insert boardFirst;

        leankor__MasterContainer__c newMC = new leankor__MasterContainer__c();
		newMC.Name= 'Test-MC';
		newMC.leankor__ValueStream__c = boardFirst.Id;
        newMC.leankor__GUID__c = TestDataFactory.createGuid();
		insert newMC ;
		
		leankor__Swimlane__c  newSw = new  leankor__Swimlane__c();
		newSw.Name = 'Test-SW';
		newSw.leankor__MasterContainer__c = newMC.Id;
		newSw.leankor__ValueStream__c = boardFirst.Id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.Name = 'Test-Zone';
		zone.leankor__Width__c = 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = TestDataFactory.createGuid();
		zone.leankor__Y__c = 49.0;
		zone.leankor__Swimlane__c = newSw.Id;
		zone.leankor__ValueStream__c = boardFirst.Id;
		insert zone;


        List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
        for(Integer count = 0; count<5; count++){
            leankor__KanbanCard__c card =  new leankor__KanbanCard__c();
            card.Name = 'Test-Card-'+count;
            card.leankor__StartDateTime__c = System.Now();
            card.leankor__EstimatedDuration__c = 2;
            card.leankor__GUID__c = TestDataFactory.createGuid();
            card.leankor__ValueStream__c = boardFirst.Id;
            cards.add(card);
        }
        insert cards;

        leankor__ValueStream__c boardSecond = new leankor__ValueStream__c();
        boardSecond.Name = 'Demo-Board';
        boardSecond.leankor__BoardType__c = 'Kanban Board';
        boardSecond.leankor__projectroom__c = project.Id;
        boardSecond.leankor__SevenDayWorkWeek__c = true;
        insert boardSecond;

        leankor__MasterContainer__c newBoardMC = new leankor__MasterContainer__c();
        newBoardMC.Name= 'Demo-MC';
		newBoardMC.leankor__ValueStream__c = boardSecond.Id;
        newBoardMC.leankor__GUID__c = TestDataFactory.createGuid();
		insert newBoardMC ;
		
		leankor__Swimlane__c  newBoardSw = new  leankor__Swimlane__c();
		newBoardSw.Name = 'Demo-SW';
		newBoardSw.leankor__MasterContainer__c = newBoardMC.Id;
		newBoardSw.leankor__ValueStream__c = boardSecond.Id;
		insert newBoardSw;         

		leankor__Zone__c newBoardzone= new leankor__Zone__c();
		newBoardzone.Name = 'Demo-Zone';
		newBoardzone.leankor__Width__c = 180.0;  
		newBoardzone.leankor__X__c = 767.0;
		newBoardzone.leankor__GUID__c =  TestDataFactory.createGuid();
		newBoardzone.leankor__Y__c = 49.0;
		newBoardzone.leankor__Swimlane__c = newBoardSw.Id;
		newBoardzone.leankor__ValueStream__c = boardSecond.Id;
		insert newBoardzone;

        leankor__KanbanCard__c cardSecond =  new leankor__KanbanCard__c();
        cardSecond.Name = 'Demo-Card';
        cardSecond.leankor__StartDateTime__c = System.Now();
        cardSecond.leankor__EstimatedDuration__c = 2;
        cardSecond.leankor__GUID__c = TestDataFactory.createGuid();
        cardSecond.leankor__ValueStream__c = boardSecond.Id;
        insert cardSecond;

        List<leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest> requests = new List<leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest>();
        List<leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest> results = new List<leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest>();
        leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest request = new leankor.MergeProjectBoardSFAction.MergeProjectBoardRequest();
        request.SourceBoardName = 'Demo-Board';
        request.SourceRoomName = 'Test-Project';
        request.TargetBoardName = 'Test-Board';
        request.TargetRoomName = 'Test-Project';
        request.WithMC = true;
        request.initialDate = System.Now().addDays(2);
        requests.add(request);

        results = leankor.MergeProjectBoardSFAction.mergeProjectBoard(requests);
        System.assertEquals(requests.size(), results.size());
        Test.StopTest();
    }
}