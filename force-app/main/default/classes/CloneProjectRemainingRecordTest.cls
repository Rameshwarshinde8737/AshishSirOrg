@isTest
private class CloneProjectRemainingRecordTest {

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup 
	private static void setupTestData() {

        leankor__projectroom__c project = new leankor__projectroom__c(Name ='test');
        insert project;

        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id, leankor__BoardType__C = 'Plan Board');
		insert valueStream;

        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
		newMC.name= 'Test MC';
		newMC.leankor__Valuestream__c= valueStream.id;
		insert newMC ;
		
		leankor__swimlane__c  newSw = new  leankor__swimlane__c();
		newSw.name = 'Test SW';
		newSw.leankor__mastercontainer__c= newMC.id;
		newSw.leankor__Valuestream__c = valueStream.id;
		insert newSw;         

		leankor__Zone__c zone= new leankor__Zone__c();
		zone.name= 'Test Zone';
		zone.leankor__Width__c= 180.0;  
		zone.leankor__X__c = 767.0;
		zone.leankor__GUID__c = system.now() +'Test Zone';
		zone.leankor__Y__c= 49.0;
		zone.leankor__swimlane__c= newSw.id;
		zone.leankor__ValueStream__c = valueStream.Id;
		insert zone;

        leankor__Preference__c Preference = new leankor__Preference__c(
        Name = 'Preference',
        leankor__GUID__c = system.now()+'11',
        leankor__FollowOnChatter__c = 'all',
        leankor__SubscribeToCard__c = 'all',
        leankor__CardPastDueDate__c = false,
        leankor__Moved__c = false,
        leankor__PercentDone__c = true,
        leankor__TaskPastDueDate__c = true,
        leankor__isTaskCompleted__c =  true,
        leankor__ValueStream__c = valueStream.Id
        
        );
        insert Preference;

        List<leankor__KanbanCard__c>kanbanList = new List<leankor__KanbanCard__c>();
        for(Integer count=1; count<=6; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__ValueStream__c = valueStream.Id;
            kanbanCard.leankor__Title__c = 'Test Card '+count;
            kanbanCard.leankor__MasterContainer__c = newMC.Id;
            kanbanCard.leankor__Swimlane__c = newSw.Id;
            kanbanCard.leankor__Zone__c = zone.Id;
            kanbanCard.leankor__ZoneGUID__C = zone.leankor__GUID__c;
            kanbanCard.Name = 'Test C'+count;
            kanbanCard.leankor__EstimatedDuration__c = 5;
            kanbanCard.leankor__DurationUnits__c ='Days';
            kanbanCard.leankor__StartDateTime__c = System.now();
            KanbanCard.OwnerId = UserInfo.getUserId();
            kanbanCard.leankor__GUID__c =TestDataFactory.createGuid();
            kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanList.add(kanbanCard);
        }
        insert kanbanList;

        
        leankor__Sticker__c stick=new leankor__Sticker__c();
        stick.name='Sticker__Name';
        stick.leankor__ValueStream__c=valueStream.Id;
        insert stick;
        
        List<leankor__KanbanCardSticker__c>kanbancardStickerList = new List<leankor__KanbanCardSticker__c>();
        for(integer count=1; count<=5; count++){
            leankor__KanbanCardSticker__c kanSticker=new leankor__KanbanCardSticker__c();
            kanSticker.leankor__KanbanCard__c=kanbanList[count].Id;
            kanSticker.leankor__Sticker__c=stick.id;
            kanbancardStickerList.add(kanSticker);
        }
        insert kanbancardStickerList;
    }
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is calling cloneProjectRemainingRecord batch class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void cloneProjectRemainingRecordTest(){
        Boolean isClonedProjectRemaingRecord = true;
        List<leankor__KanbanCard__c > newKanbanCards = new List <leankor__KanbanCard__c>();
        String valueStreamId;
        List <Id> kanbanCardIdsForSticker = new List<Id>();
        Map<String,String> mapWithOldKanbanCard = new Map<String,String>();
        Boolean cardStickerVerb=true;

        leankor__ProjectRoom__c project  = [Select Id, 
												Name 
											From leankor__ProjectRoom__c 
											Where Name = 'test' Limit 1];

        leankor__ValueStream__c valueStream = [Select Id, 
													Name 
												From leankor__ValueStream__c 
												Where leankor__ProjectRoom__c = :project.Id];
        valueStreamId = Id.valueOf(valueStream.id);

        List<leankor__KanbanCardSticker__c>kanbanCardStickerList=[Select Id, 
                                                                      leankor__KanbanCard__c 
                                                                    From leankor__KanbanCardSticker__c];
        System.debug('inside test class'+kanbanCardStickerList.size());
        for(leankor__KanbanCardSticker__c singleInstance:kanbanCardStickerList){
            kanbanCardIdsForSticker.add(singleInstance.leankor__KanbanCard__c);
        }

        List<leankor__KanbanCard__c>kanbanCardList = [Select Id, 
														  Name,
                                                          leankor__ValueStream__c,
                                                          leankor__Title__c,
                                                          leankor__MasterContainer__c,
                                                          leankor__Swimlane__c,
                                                          leankor__Zone__c,
                                                          leankor__EstimatedDuration__c,
                                                          leankor__DurationUnits__c,
                                                          leankor__StartDateTime__c,
                                                          OwnerId,
                                                          leankor__GUID__c,
                                                          RecordTypeId
														From leankor__KanbanCard__c 
														Where leankor__ValueStream__c =: valueStream.Id];
        
        List<leankor__KanbanCard__c>kanbanList = new List<leankor__KanbanCard__c>();
        for(Integer count=1; count<=6; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.leankor__ValueStream__c = valueStream.Id;
            kanbanCard.leankor__Title__c = 'Test Card '+count;
            // kanbanCard.leankor__MasterContainer__c = newMC.Id;
            // kanbanCard.leankor__Swimlane__c = newSw.Id;
            // kanbanCard.leankor__Zone__c = zone.Id;
            kanbanCard.Name = 'Test C'+count;
            kanbanCard.leankor__EstimatedDuration__c = 5;
            kanbanCard.leankor__DurationUnits__c ='Days';
            kanbanCard.leankor__StartDateTime__c = System.now();
            KanbanCard.OwnerId = UserInfo.getUserId();
            kanbanCard.leankor__GUID__c =TestDataFactory.createGuid();
            kanbanCard.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
            kanbanList.add(kanbanCard);
        }
        insert kanbanList;
        for(Integer count=0; count<=3;count++){
            mapWithOldKanbanCard.put(kanbanCardIdsForSticker[count],kanbanList[count].id);
        }
        leankor__ProjectEvent__e pe;                       
        Test.startTest();	
            CloneProjectRemainingRecord instance =new CloneProjectRemainingRecord(kanbanCardList, valueStreamId, kanbanCardIdsForSticker, mapWithOldKanbanCard, cardStickerVerb, pe, null);
    		DataBase.executeBatch(instance);
            // when valueStream is blank
            valueStreamId='';
            CloneProjectRemainingRecord instance1 =new CloneProjectRemainingRecord(kanbanCardList, valueStreamId, kanbanCardIdsForSticker, mapWithOldKanbanCard, cardStickerVerb, pe, null);
    		DataBase.executeBatch(instance1); 	 
    	Test.stopTest();
        List<leankor__KanbanCardSticker__c>kanbanCardStickerList1=[Select Id, 
                                                                       leankor__KanbanCard__c 
                                                                    From leankor__KanbanCardSticker__c];
        // Checking 13 KanbanCardSticker
        System.assertEquals(13, kanbanCardStickerList1.size());	 
                                                        


    }

}