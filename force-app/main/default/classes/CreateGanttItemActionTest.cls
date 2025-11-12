@isTest
public class CreateGanttItemActionTest{
    
    @testSetup 
	private static void setupTestData() {
        
        //ValueStream created for testing
        leankor__ValueStream__c valuestream = new leankor__ValueStream__c(Name = 'myValueStream',leankor__SevenDayWorkWeek__c= false);
        insert valuestream; 
        leankor__kanbanCard__c card = new leankor__KanbanCard__c();
        card.Name = 'kb card';
        card.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        card.leankor__ValueStream__c = valuestream.Id;
        card.leankor__IsRecordDeleted__c= false;
        card.leankor__ZoneGUID__C = leankor.TestDataFactory.createGuid();
        card.leankor__Description__c = 'Kanban cards';
        insert card;
        List<leankor__kanbanCard__c> kanbanList = new List<leankor__KanbanCard__c>();
        List<leankor__ScheduleMode__c> listOfSchedule = new List<leankor__ScheduleMode__c>();
        for(Integer count=0; count<=10; count++){
            leankor__kanbanCard__c kanbancard = new leankor__KanbanCard__c();
            kanbancard.Name = 'kb';
            kanbancard.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            kanbancard.leankor__ValueStream__c = valuestream.Id;
            kanbancard.leankor__IsRecordDeleted__c= false;
            kanbancard.leankor__ZoneGUID__C = leankor.TestDataFactory.createGuid();
            kanbancard.leankor__Description__c = 'Kanban cards';
            kanbanList.add(kanbancard);
        }
        insert kanbanList;
        for(leankor__kanbanCard__c kanbanCard : kanbanList){
            leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
            scheduleMode.leankor__KanbanCard__C = kanbanCard.Id;
            listOfSchedule.add(scheduleMode);
        }
        insert listOfSchedule;
        leankor__Dependency__c dependency = new leankor__Dependency__c(leankor__ValueStream__c = valuestream.Id);
        insert dependency;
    }

    public static testMethod void testcreateGanttItemsByMpp(){
        leankor.CreateGanttItemAction.GanttItems ganttItems = new leankor.CreateGanttItemAction.GanttItems();
        leankor.CreateGanttItemAction.GanttItems ganttItemonlyValuestream = new leankor.CreateGanttItemAction.GanttItems();

        //ValueStream created for testing
        leankor__ValueStream__c vss = new leankor__ValueStream__c(Name = 'myStream',leankor__SevenDayWorkWeek__c= false);
        insert vss; 
        
        //Kanban Card Template created for testing
        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c(
            Name ='Template',
            leankor__Title__c = 'Template',
            leankor__color__c = '#fff',
            leankor__csslayout__c = '',
            leankor__height__c = 300,
            leankor__width__c = 300,
            leankor__jsondata__c = '{}',
            leankor__jsondefinition__c = '{}',
            leankor__valuestream__c = vss.Id 
        );        
        insert kanbanTemp;
        
        //Kanban Cards created for testing
        List<String> kanbans=new List<String>();
        List<leankor.KanbanToGanttController.MasterContainer> kcList = new List<leankor.KanbanToGanttController.MasterContainer>();
        for(integer i=0;i<10;i++){ 
            leankor.KanbanToGanttController.MasterContainer newKanban = new leankor.KanbanToGanttController.MasterContainer();
            newKanban.id = String.valueof(i+''+system.now());
            newKanban.GUID = (String.valueOf(system.now()+i));
            newKanban.ownerid = UserInfo.getUserId();       
            newKanban.name = 'Dummy card'; 
            newKanban.CardID = String.valueof(i);       
            newKanban.Point=0;
            newKanban.valueStreamId=vss.Id ;
            newKanban.EstimatedDuration=0; 
            newKanban.Color='#fff';
            newKanban.OnTime='Green';             
            newKanban.JSONData = '{}';   
            newKanban.JSONDefinition='{}';  
            newKanban.PercentDone=0;
            newKanban.Order=0;         
            newKanban.OnBudget='Green' ;
            newKanban.OnQuality='Green' ;
            newKanban.durationunits = 'Days';
            newKanban.estimatedDuration = 1;              
            newKanban.duedate = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            newKanban.startdate = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            newKanban.templateid =kanbanTemp.Id;
            newKanban.priority = 3;
            newKanban.ManuallyScheduled = true;
            newKanban.harveyBall = '100';
            newKanban.description = 'hello';
            newKanban.ItemType = 'ActivityCard';
            newKanban.parentId = 'root';
            kcList.add(newKanban);
            kanbans.add(JSON.Serialize(newKanban));
        }
        
        //Child cards created for testing
        Integer counter=11;
        for(leankor.KanbanToGanttController.MasterContainer  K : kcList){ 
            leankor.KanbanToGanttController.MasterContainer newKanban = new leankor.KanbanToGanttController.MasterContainer();
            newKanban.Id = String.valueof(counter+''+system.now());
            newKanban.GUID = (String.valueOf(system.now()+counter));
            newKanban.ManuallyScheduled = true;
            newKanban.ownerid = UserInfo.getUserId();       
            newKanban.name = 'Dummy card'; 
            newKanban.CardID = String.valueof(counter);       
            newKanban.Point=0;
            newKanban.valueStreamId=vss.Id;
            newKanban.EstimatedDuration=0; 
            newKanban.Color='#fff';
            newKanban.OnTime='#fff';             
            newKanban.JSONData = '{}';   
            newKanban.JSONDefinition='{}';  
            newKanban.PercentDone=0;
            newKanban.Order=0;         
            newKanban.OnBudget='#fff' ;
            newKanban.OnQuality='#fff' ;
            newKanban.durationunits = 'Days';
            newKanban.estimatedDuration = 1;              
            newKanban.duedate = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            newKanban.startdate = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            newKanban.templateid =kanbanTemp.Id;
            newKanban.priority = 3;
            newKanban.harveyBall = '100';
            newKanban.description = 'hello';
            newKanban.ItemType = 'MileStoneCard';
            newKanban.parentId = K.Id;     
            (counter=counter+1);
                kanbans.add(JSON.Serialize(newKanban));      
        }
        //Mapping for parent-child relationship and created dependency  
        List<String> DependencyArray = new List<String>();
        for(integer i=0;i<5;i++){
            leankor.RealTimeController.Dependency dp=new leankor.RealTimeController.Dependency();
            dp.Id=String.valueOf(System.Now()+i);
            dp.FromVSID= vss.id;
            dp.FromId= kcList[i].Id;
            dp.To= kcList[i+1].Id;
            dp.ToVSID= vss.id;
            dp.Type=1;
            dp.Lag=0;
            dp.LagUnit='Days';
          //dp.LagLeadDuration=0;
            dp.Type = 0; 
            DependencyArray.add(JSON.Serialize(dp)); 
        }
        //Attributes of GanttItems class intialized with data created for testing
        ganttItems.valueStreamId=vss.id;
        ganttItems.cardData=kanbans;
        ganttItems.dependencyData=DependencyArray;
        
        //Test createGanttItemsByMpp() to create cards and dependencies
        String resultString=leankor.CreateGanttItemAction.createGanttItemsByMpp(ganttItems); 
        System.assert(resultString.equals('Success'));

        ganttItemonlyValuestream.valueStreamId = vss.Id;
        ganttItemonlyValuestream.cardData = new List<String>();
        ganttItemonlyValuestream.dependencyData = new List<String>();
        String rollbackDatas = leankor.CreateGanttItemAction.createGanttItemsByMpp(ganttItemonlyValuestream);
        System.assert(resultString.equals('Success'));

        leankor.CreateGanttItemAction.addDependenciesToItems(vss.id, DependencyArray);
        List<leankor__Dependency__c> dependencylist = [Select Id 
                                                            From leankor__Dependency__c 
                                                            Where leankor__ValueStream__r.Id =: vss.id 
                                                            Limit 9999];
        System.assert(dependencylist.size()>0);
        String rollbackData = leankor.CreateGanttItemAction.rollbackGanttData(ganttItems);
        System.assert(rollbackData.equals('success'));

    }

    @isTest
    private static void readGanttRecordsTest() {
        leankor__ValueStream__c valueStreamId = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'myValueStream' ];
        List<leankor__KanbanCard__c> kanbanCards = leankor.CreateGanttItemAction.readGanttRecords(valueStreamId.id);
        System.assert(kanbanCards.size()>0);
    }

    @isTest
    private static void prepareDependencyRecordsTest(){
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();
        leankor__ValueStream__c valueStreamId = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'myValueStream' ];
        List<leankor__KanbanCard__c> listOfCard = [Select Id,
                                                          Name,
                                                          leankor__ValueStream__c
                                                        From leankor__KanbanCard__c
                                                        Where Name = 'kb'];
        for(leankor__KanbanCard__c kanban : listOfCard){
            targetKanbanCards.put(String.valueOf(kanban.Id) ,kanban);
        }
        List<String> DependencyArray = new List<String>();
        for(integer i=0;i<5;i++){
            leankor.RealTimeController.Dependency dependency = new leankor.RealTimeController.Dependency();
            dependency.Id = String.valueOf(System.Now()+i);
            dependency.FromVSID = valueStreamId.id;
            dependency.FromId = listOfCard[i].Id;
            dependency.To = listOfCard[i+1].Id;
            dependency.ToVSID = valueStreamId.id;
            dependency.Type = 1;
            dependency.Lag = 0;
            dependency.LagUnit = 'Days';
          //dependency.LagLeadDuration = 0;
            dependency.Type = 0; 
            DependencyArray.add(JSON.Serialize(dependency)); 
        }
        
        List<leankor__Dependency__c> dependencyRecord =  leankor.CreateGanttItemAction.prepareDependencyRecords(valueStreamId.id, targetKanbanCards, DependencyArray);
        System.assert(dependencyRecord.size()>0);
        
        leankor.CreateGanttItemAction.createDependencyRecords(valueStreamId.id, targetKanbanCards, DependencyArray);
        List<leankor__Dependency__c> dependencylist = [Select Id 
                                                            From leankor__Dependency__c 
                                                            Where leankor__ValueStream__r.Id =: valueStreamId.id 
                                                            Limit 9999];
        System.assert(dependencylist.size()>0);
    }

    @isTest
    private static void removeMPPMapingTest(){
        leankor__ValueStream__c valueStreamId = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'myValueStream' 
                                                    Limit 1];
        leankor.CreateGanttItemAction.removeMPPMaping(String.valueOf(valueStreamId));
        List<leankor__KanbanCard__c> listOfCard = [Select Id
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__r.Id =: valueStreamId.Id]; 
        System.assert(listOfCard.size()>0);                               
        List<leankor__KanbanCard__c> listOfCards = [Select Id,
                                                          leankor__Description__c,
                                                          leankor__ZoneGUID__C
                                                    From leankor__KanbanCard__c
                                                    Where Name = 'kb']; 
        leankor.CreateGanttItemAction.removeMPPMaping(listOfCards);
        leankor__KanbanCard__c card = [Select Id,
                                              leankor__Description__c,
                                              leankor__ZoneGUID__C
                                            From leankor__KanbanCard__c
                                            Where Name = 'kb' 
                                            Limit 1];

        System.assertEquals(null, card.leankor__Description__c);
        System.assertEquals(null, card.leankor__ZoneGUID__C);
    }

    @isTest
    private static void deleteGanttSubItemsTest(){
        leankor__ValueStream__c valueStreamId = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Where Name = 'myValueStream' Limit 1];
        Test.startTest();                               
        leankor.CreateGanttItemAction.deleteGanttSubItems(valueStreamId.Id);
        Test.stopTest();
        List<leankor__ScheduleMode__c> scheduleModeList = [Select Id 
                                                                From leankor__ScheduleMode__c 
                                                                Where leankor__kanbanCard__c 
                                                                In (Select Id 
                                                                From leankor__kanbancard__c 
                                                                Where leankor__ValueStream__r.Id =: valueStreamId.Id)
                                                                Limit 9999];
        List<leankor__Dependency__c> dependencylist = [Select Id 
                                                            From leankor__Dependency__c 
                                                            Where leankor__ValueStream__r.Id =: valueStreamId.Id 
                                                            Limit 9999];
        System.assertEquals(0,scheduleModeList.size());
        System.assertEquals(0,dependencylist.size());

        Contact contct = new Contact(LastName = 'cont1');
        insert contct;
        ApexPages.currentPage().getParameters().put('isLightning', contct.Id);
        ApexPages.StandardController standrdcontroller = new ApexPages.standardController(contct);
        CreateGanttItemAction createGantt = new CreateGanttItemAction(standrdcontroller);
    }

    private static testMethod void createGanttItemsByMppTest(){
        leankor.CreateGanttItemAction.GanttItems ganttItemWithoputcard = new leankor.CreateGanttItemAction.GanttItems();
        List<leankor__KanbanCard__C> kanbanCards = [Select Id,
                                                           leankor__ZoneGUID__C,
                                                           leankor__ValueStream__C
                                                        From leankor__KanbanCard__C
                                                        Where Name = 'kb' 
                                                        Limit 2];

        List<String> DependencyArraylist = new List<String>();
        leankor.RealTimeController.Dependency dp = new leankor.RealTimeController.Dependency();
        dp.FromVSID= kanbanCards[0].leankor__ValueStream__C;
        dp.FromId = kanbanCards[0].leankor__ZoneGUID__C;
        dp.To = kanbanCards[1].leankor__ZoneGUID__C;
        dp.ToVSID= kanbanCards[0].leankor__ValueStream__C;
        dp.Type=1;
        dp.Lag=0;
        dp.LagUnit='Days';
      //dp.LagLeadDuration=0;
        dp.Type = 0; 
        DependencyArraylist.add(JSON.Serialize(dp)); 
        ganttItemWithoputcard.valueStreamId = kanbanCards[0].leankor__ValueStream__C;
        ganttItemWithoputcard.cardData = new List<String>();
        ganttItemWithoputcard.dependencyData = DependencyArraylist;
        String resultStringSecond = leankor.CreateGanttItemAction.createGanttItemsByMpp(ganttItemWithoputcard);
        System.assert(resultStringSecond.equals('Success'));
    }
    
    private static testMethod void linkGanttItemsTest(){
        Boolean flag = true;
        leankor.CreateGanttItemAction.GanttItems ganttItems = new leankor.CreateGanttItemAction.GanttItems();
        List<leankor__KanbanCard__C> kanbanCards = [Select Id,
                                                           leankor__ZoneGUID__C,
                                                           leankor__ValueStream__C,
                                                           leankor__Description__c
                                                        From leankor__KanbanCard__C
                                                        Where Name = 'kb' 
                                                        Limit 2];
        List<leankor__KanbanCard__C> parentCards = [Select Id,
                                                           leankor__ZoneGUID__C,
                                                           leankor__ValueStream__C,
                                                           leankor__Description__c
                                                     From leankor__KanbanCard__C
                                                     Where Name = 'kb card' 
                                                     Limit 1];
        Set<String> parentIds = new Set<String>();
        Map<String, leankor__KanbanCard__c> targetKanbanCard = new Map<String, leankor__KanbanCard__c>();
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();
        Map<String, leankor__KanbanCard__c> parentMap = new Map<String, leankor__KanbanCard__c>();
        for(leankor__KanbanCard__C card : kanbanCards){
            parentIds.add(card.Id);
            targetKanbanCards.put(card.Id, card);
            parentMap.put(parentCards[0].leankor__Description__c, parentCards[0]);
        }
        CreateGanttItemAction.linkGanttItems(String.valueOf(parentCards[0].leankor__ValueStream__C), targetKanbanCard, parentIds);
        System.assertEquals(flag, true);
        List<leankor__KanbanCard__c> cards = CreateGanttItemAction.linkGanttItems(String.valueOf(kanbanCards[0].leankor__ValueStream__C), targetKanbanCards, parentMap);
        System.assert(cards[0].leankor__ValueStreamLink__c != null);
    }

    @isTest
    static void rollbackGanttDataTest(){
        leankor__ValueStream__c valueStreamData = [Select Id 
                                                        From leankor__ValueStream__c
                                                        Limit 1];
        
        CreateGanttItemAction.GanttItems request = new CreateGanttItemAction.GanttItems();
        request.valueStreamId = valueStreamData.Id;
        
        Test.startTest();
        String result = CreateGanttItemAction.rollbackGanttData(request);
        Test.stopTest();
        
        List<leankor__KanbanCard__c> kanbanCardList = [Select Id 
                                     			            From leankor__KanbanCard__c];
        
        System.assert(kanbanCardList.size()==0);
        System.assert('Success'==result);
    }
}