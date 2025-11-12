/**
* Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
* FILE:  TestGanttTaskBoard.cls
* CLASS: TestGanttTaskBoard
* USAGE: Testing of managing to Get record of Card for Gantt boards  .
*/
@isTest
global class TestGanttTaskBoard{
    @isTest private static void createMapOfListCardsTest() {
        leankor__Kanbancard__c card = new leankor__Kanbancard__c();
        card.leankor__GUID__c = '0';
        leankor__Kanbancard__c link = new leankor__Kanbancard__c();
        link.leankor__GUID__c = '1';
        List<leankor__Kanbancard__c> listCards = new List<leankor__Kanbancard__c>();
        listCards.add(card);
        listCards.add(link);
        insert listCards;
        listCards.get(0).leankor__ValueStreamCardLink__c = listCards.get(1).Id;
        Map<String, List<leankor__Kanbancard__c>> mapOfListCards = GanttTaskBoard.createMapOfListCards(listCards);
        System.assert(!mapOfListCards.isEmpty());
    }

    @isTest private static void fixCardDatesCardsQueryTest() {
        leankor__KanbanCard__c testActvity = new leankor__Kanbancard__c();
        try {
            insert testActvity;
        } catch (DmlException e) {
            System.debug(e);
        }

        Set<Id> testActivityIds = new Set<Id>();
        testActivityIds.add(testActvity.id);

        System.assert(!GanttTaskBoard.fixCardDatesCardsQuery(testActivityIds).isEmpty());
    }

    @isTest private static void fixCardDatesSuccessorCardsQueryTest() {
        leankor__Kanbancard__c testKanbanCard = new leankor__Kanbancard__c();
        try {
            insert testKanbanCard;
        } catch (DmlException e) {
            System.debug(e);
        }

        Set<Id> testKanbanCardIds = new Set<Id>();
        testKanbanCardIds.add(testKanbanCard.id);

        System.assert(!GanttTaskBoard.fixCardDatesSuccessorCardsQuery(testKanbanCardIds).isEmpty());
    }

    @isTest private static void getNonWorkingDaysAmountTest() {
        DateTime startDateTime = DateTime.newInstance(2018 , 10, 1);
        DateTime dueDateTime = DateTime.newInstance(2018 , 10, 7);
        Integer firstDayOfWeek = 1;

        Util.WorkWeek workWeekObj = new Util.WorkWeek(firstDayOfWeek, 5);

        Integer expected = 2;
        Integer actual = GanttTaskBoard.getNonWorkingDaysAmount(startDateTime, dueDateTime, workWeekObj);

        System.assertEquals(expected, actual);
    }

    @isTest private static void getAllDependentCardIdsTest4ParamEmpty() {
        Set<Id> emptySet = new Set<Id>();
        Set<Id> dependentCardIds = GanttTaskBoard.getAllDependentCardIds(new List<leankor__Dependency__c>(), emptySet, new Map<Id, GanttTaskboard.MiniatureCard>(), new Set<Id>());
        System.assert(dependentCardIds.isEmpty());
    }

    @isTest private static void getAllDependentCardIdsTest6ParamEmpty() {
        Set<Id> emptySet = new Set<Id>();
        Set<Id> dependentCardIds = GanttTaskBoard.getAllDependentCardIds(new List<leankor__Dependency__c>(), emptySet, new Set<Id>(), new Map<Id, GanttTaskboard.MiniatureCard>(), new Set<Id>(), false);
        System.assert(dependentCardIds.isEmpty());
    }

    //Tests to see if the card is remove at every recurse to prevent recursion on that particular id
    @isTest private static void getAllDependentCardIdsTest6ParamExcludeManualPaths() {
        leankor__Kanbancard__c testDataKanbanCard = new leankor__Kanbancard__c();
        insert testDataKanbanCard;
        Set<Id> kanbanCardIds = new Set<Id>();
        kanbanCardIds.add(testDataKanbanCard.id);
        Set<Id> scheduleModeIds = new Set<Id>();
        scheduleModeIds.add(testDataKanbanCard.id);
        Boolean excludeManualPaths = true;
        Set<Id> dependentCardIds = GanttTaskBoard.getAllDependentCardIds(new List<leankor__Dependency__c>(), kanbanCardIds, scheduleModeIds, new Map<Id, GanttTaskboard.MiniatureCard>(), new Set<Id>(), excludeManualPaths);
        System.assert(dependentCardIds.isEmpty());
    }

    @isTest private static void getAllDependentCardIdsTest4Param() {
        leankor__Kanbancard__c pred = new leankor__Kanbancard__c(leankor__GUID__c = '1');
        insert pred;
        leankor__Kanbancard__c succ = new leankor__Kanbancard__c(leankor__GUID__c = '2');
        insert succ;
        Set<Id> kanbanCardIds = new Set<Id>();
        kanbanCardIds.add(pred.id);
        leankor__Dependency__c dep = new leankor__Dependency__c(leankor__Predecessor__c = pred.id, leankor__Successor__c = succ.id);
        insert dep;
        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        dependencies.add(dep);
        Boolean excludeManualPaths = true;
        List<id> dependentCardIds = new List<id>(GanttTaskBoard.getAllDependentCardIds(dependencies, kanbanCardIds, new Map<Id, GanttTaskboard.MiniatureCard>(), new Set<Id>()));        
        System.assert(dependentCardIds[0] == succ.id);
    }

    @isTest private static void getAllDependentCardIdsTest6Param() {
        leankor__Kanbancard__c pred = new leankor__Kanbancard__c(leankor__GUID__c = '1');
        insert pred;
        leankor__Kanbancard__c succ = new leankor__Kanbancard__c(leankor__GUID__c = '2');
        insert succ;
        Set<Id> kanbanCardIds = new Set<Id>();
        kanbanCardIds.add(pred.id);
        leankor__Dependency__c dep = new leankor__Dependency__c(leankor__Predecessor__c = pred.id, leankor__Successor__c = succ.id);
        insert dep;
        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        dependencies.add(dep);
        Boolean excludeManualPaths = true;
        List<id> dependentCardIds = new List<id>(GanttTaskBoard.getAllDependentCardIds(dependencies, kanbanCardIds, new Set<Id>(), new Map<Id, GanttTaskboard.MiniatureCard>(), new Set<Id>(), excludeManualPaths));        
        System.assert(dependentCardIds[0] == succ.id);
    }

    @isTest private static void getAllDependentCardIdsTest4ParamCircular() {
        leankor__Kanbancard__c pred = new leankor__Kanbancard__c(leankor__GUID__c = '1');
        insert pred;
        leankor__Kanbancard__c succ = new leankor__Kanbancard__c(leankor__GUID__c = '2', leankor__ValueStreamCardLink__c = pred.id);
        insert succ;
        Set<Id> kanbanCardIds = new Set<Id>();
        kanbanCardIds.add(pred.id);
        Set<Id> kanbanCardGroupIds = new Set<Id>();
        //kanbanCardGroupIds.add(pred.id);
        leankor__Dependency__c dep = new leankor__Dependency__c(leankor__Predecessor__c = pred.id, leankor__Successor__c = succ.id);
        insert dep;
        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        dependencies.add(dep);
        List<id> dependentCardIds = new List<id>(GanttTaskBoard.getAllDependentCardIds(dependencies, kanbanCardIds, new Map<Id, GanttTaskboard.MiniatureCard>(), kanbanCardGroupIds));        
        System.assert(dependentCardIds.size() == 1);
    }

    @isTest private static void getAllDependentCardIdsTest6ParamCircular() {
        leankor__Kanbancard__c pred = new leankor__Kanbancard__c(leankor__GUID__c = '1');
        insert pred;
        leankor__Kanbancard__c succ = new leankor__Kanbancard__c(leankor__GUID__c = '2', leankor__ValueStreamCardLink__c = pred.id);
        insert succ;
        Set<Id> kanbanCardIds = new Set<Id>();
        kanbanCardIds.add(pred.id);
        Set<Id> kanbanCardGroupIds = new Set<Id>();
        //kanbanCardGroupIds.add(pred.id);
        leankor__Dependency__c dep = new leankor__Dependency__c(leankor__Predecessor__c = pred.id, leankor__Successor__c = succ.id);
        insert dep;
        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        dependencies.add(dep);
        Boolean excludeManualPaths = true;
        List<id> dependentCardIds = new List<id>(GanttTaskBoard.getAllDependentCardIds(dependencies, kanbanCardIds, new Set<Id>(), new Map<Id, GanttTaskboard.MiniatureCard>(), kanbanCardGroupIds, excludeManualPaths));        
        System.assert(dependentCardIds.size() == 1);
    }
    
        public Static User getUserdata(){
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            
            User userInstance = new User(Alias = 'surya', Email='surya@testing.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='surya@testing21.com');
            
            insert userInstance;
            return userInstance;
         }
         
          global static testmethod void TestGanttTaskBoard()
         {
            Test.startTest();  
           
            User userInstance = TestGanttTaskBoard.getUserdata();  
        	//To create Folders and Projects. 
            list<leankor__Portfolio__c> folders = TestDataFactory.createFolder('Folders',1);
            list<leankor__ProjectRoom__c> projects= TestDataFactory.createProjects('Projects',folders,3);
          
            //To create UberBoard,KanbanBoard,PlanBoard   
            List<leankor__ValueStream__c> boardlist = new List<leankor__ValueStream__c>();
            List<string> boardListId = new List<string>();
               
            leankor__ValueStream__c UB = new leankor__ValueStream__c(Name='UberBoard',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projects[0].ID);
            leankor__ValueStream__c UB1 = new leankor__ValueStream__c(Name='UberBoard1',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projects[1].ID);
            leankor__ValueStream__c UB2 = new leankor__ValueStream__c(Name='UberBoard1',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projects[2].ID);
            leankor__ValueStream__c KB = new leankor__ValueStream__c(Name = 'Kanban Board',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projects[0].ID);
          
          	boardlist.add(UB);
          	boardlist.add(UB1);
          	boardlist.add(KB);
          	
            insert boardlist;
         	
         	//To add boardId in list
         	boardListId.add(UB.Id);
         	
         	//To create ProjectLaunchBehaviour
         	leankor.TestDataFactory.createLeanModules();
            List<leankor__ProjectLaunchBehavior__c> projectLaunchBehavior= TestDataFactory.createProjectLaunchBehavior(projects);   
            
            //To create KanbanCardTemplate
            leankor__KanbanCardTemplate__c kanbanCardTemp = TestDataFactory.createKanbanCardTemplate(UB);
            leankor__KanbanCardTemplate__c kanbanCardTemp1 = TestDataFactory.createKanbanCardTemplate(UB1);
            leankor__KanbanCardTemplate__c kanbanCardTemp2 = TestDataFactory.createKanbanCardTemplate(UB2);
           
            //To create Activity  
            List<leankor__KanbanCard__c> activities =  TestDataFactory.createChildActivity(UB,kanbanCardTemp,Null,1);
            
            //To create milestone
            List<leankor__KanbanCard__c> Milestones = TestDataFactory.createChildMilestone(UB,kanbanCardTemp,Null,1);
           
            //To create ActivityGroup
            List<leankor__KanbanCard__c> activityGroup = TestDataFactory.createActivityGroups(UB,kanbanCardTemp,1);
            List<leankor__KanbanCard__c> activityGroup1 = TestDataFactory.createActivityGroups(UB1,kanbanCardTemp1,1);
            List<leankor__KanbanCard__c> activityGroup2 = TestDataFactory.createActivityGroups(UB2,kanbanCardTemp2,1);
            
            //To create Child Activity  
            List<leankor__KanbanCard__c> childActivities =  TestDataFactory.createChildActivity(UB,kanbanCardTemp,activityGroup,1);
            List<leankor__KanbanCard__c> childActivities1 =  TestDataFactory.createChildActivity(UB1,kanbanCardTemp1,activityGroup1,1);
            List<leankor__KanbanCard__c> childActivities2 =  TestDataFactory.createChildActivity(UB2,kanbanCardTemp2,activityGroup2,1);
          
            //To create Childmilestone
            //List<leankor__KanbanCard__c> childMilestones= TestDataFactory.createChildMilestone(UB,kanbanCardTemp,activityGroup,1);
            //List<leankor__KanbanCard__c> childMilestones1= TestDataFactory.createChildMilestone(UB1,kanbanCardTemp1,activityGroup1,1);
            //List<leankor__KanbanCard__c> childMilestones2= TestDataFactory.createChildMilestone(UB2,kanbanCardTemp2,activityGroup2,1);
           
            //To create kanbanCards for Kanban Board
            List<leankor__KanbanCard__c> kbCard = TestDataFactory.createKanbanCard(KB,kanbanCardTemp,1,childActivities,userInstance);
           
            //To create ScheduleMode
            List<leankor__ScheduleMode__c> sm = TestDataFactory.createScheduleMode(activities,1);
            List<leankor__ScheduleMode__c> sm1 = TestDataFactory.createScheduleMode(childActivities1,1);
            List<leankor__ScheduleMode__c> sm2 = TestDataFactory.createScheduleMode(childActivities2,1);
           
            //To create Dependency
            list<leankor__Dependency__c> dependencyList = new list<leankor__Dependency__c>();
            
            leankor__Dependency__c dependency = new leankor__Dependency__c(leankor__Predecessor__c=childActivities[0].Id,leankor__Successor__c=childActivities1[0].Id,leankor__GUID__c='Dep'+ system.Now().getTime(),leankor__valuestream__c = UB.id );
            //leankor__Dependency__c dependency1 = new leankor__Dependency__c(leankor__Predecessor__c=childActivities1[1].Id,leankor__Successor__c=childActivities2[0].Id,leankor__GUID__c='Dep'+ system.Now().addDays(1),leankor__valuestream__c = UB1.id );
          	leankor__Dependency__c dependency2 = new leankor__Dependency__c(leankor__Predecessor__c=childActivities1[0].Id,leankor__Successor__c=childActivities2[0].Id,leankor__GUID__c='Dep'+ system.Now().addDays(2),leankor__valuestream__c = UB1.id );
          
          	dependencyList.add(dependency);
         	//dependencyList.add(dependency1);
         	dependencyList.add(dependency2);
         	
            insert dependencyList;
            
            // To call getPlanGanttCards method for testing 
            GanttTaskBoard.getPlanGanttCards(boardListId);
            
            //To delete all the cards
            List<leankor__KanbanCard__c> kbList1 = new  List<leankor__KanbanCard__c>();
            kblist1.addAll(activities);
            kblist1.addAll(Milestones);
            kblist1.addAll(childActivities);
            kblist1.addAll(childActivities1);
            kblist1.addAll(childActivities2);
            kblist1.addAll(activityGroup);
            kblist1.addAll(activityGroup1);
            kblist1.addAll(activityGroup2);
            //kblist1.addAll(childmilestones);
            //kblist1.addAll(childmilestones1);
            //kblist1.addAll(childmilestones2);
            Delete kbList1;
           
            GanttTaskBoard.getPlanGanttCards(boardListId);
            
            Delete boardlist;
            try{
            GanttTaskBoard.getPlanGanttCards(new List<String>{'00Dd0000001h60X'});
            }
            catch(exception e)
            {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }
            
            boardListId.clear();
            GanttTaskBoard.getPlanGanttCards(boardListId);
           
            Test.stopTest();  
         	
        }  
        
        public static testmethod void testBaseLine(){
            
            Test.startTest();  
            
            //User userInstance = TestGanttTaskBoard.getUserdata(); 
            User userInstance = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
            system.runAs(userInstance){
            
            //To create Folders and Projects. 
            list<leankor__Portfolio__c> folders = TestDataFactory.createFolder('Folders',1);
            list<leankor__ProjectRoom__c> projects= TestDataFactory.createProjects('Projects',folders,1);
            
            //To create UberBoard,KanbanBoard,PlanBoard   
            List<leankor__ValueStream__c> boardlist = new List<leankor__ValueStream__c>();
            List<string> boardIdList = new List<string>();   
             
            leankor__ValueStream__c UB = new leankor__ValueStream__c(Name='UberBoard',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projects[0].ID);
            leankor__ValueStream__c KB = new leankor__ValueStream__c(Name = 'Kanban Board',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projects[0].ID);
            leankor__ValueStream__c PB = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c = 'Plan Board',leankor__ProjectRoom__c = projects[0].ID);
            boardlist.add(UB);
            boardlist.add(KB);
            boardlist.add(PB);
                
            insert boardlist;
             
            for (leankor__ValueStream__c bl : boardlist){
                 boardIdList.add(bl.id);
                } 
            
            //To create ProjectLaunchBehaviour
            leankor.TestDataFactory.createLeanModules();
            List<leankor__ProjectLaunchBehavior__c> projectLaunchBehavior= TestDataFactory.createProjectLaunchBehavior(projects);   
            system.assert(projectLaunchBehavior.size() !=0);
            //To create KanbanCardTemplate
            leankor__KanbanCardTemplate__c kanbanCardTemp = TestDataFactory.createKanbanCardTemplate(UB);
            
            //To create ActivityGroup
            List<leankor__KanbanCard__c> activityGroup = TestDataFactory.createActivityGroups(UB,kanbanCardTemp,1);
            //system.assert(activityGroup.size()==1);
            
            //To create Activity  
            List<leankor__KanbanCard__c> activities =  TestDataFactory.createChildActivity(UB,kanbanCardTemp,activityGroup,1);
            
            //To create ChildActivityGroup 
            List<leankor__KanbanCard__c> childActivityGroup = TestDataFactory.createChildActivityGroups(UB,kanbanCardTemp,1,activityGroup);
            
            //To create milestone
            //List<leankor__KanbanCard__c> childmilestones= TestDataFactory.createChildMilestone(UB,kanbanCardTemp,activityGroup,1);
            
            //To create Baseline on Board 
            List<String>  baselineOnBoard = TestDataFactory.createBaselineOnBoard(boardlist);
            system.assert(baselineOnBoard.size()>0);
            List<GanttTaskBoard.Baseline> bllist= GanttTaskBoard.setBaseLineOnBoard(baselineOnBoard);
                
            //To create Baseline on Activity 
            List<String> createBaselineOnactiv =  TestDataFactory.createBaselineOnActivity(activityGroup,bllist);
            string result = GanttTaskBoard.setBaseLineOnActivity(createBaselineOnactiv);
            system.assert(result == 'success');
            
            List<leankor.GanttTaskBoard.Baseline> history = GanttTaskBoard.getBaseLineHistory(boardIdList);
            try{
                List<leankor.GanttTaskBoard.Baseline> baseLineHistory = GanttTaskBoard.getBaseLineHistory(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
            system.assert(history.size()>0);
            
            //To get baseline records.
       		List<String> peojectbaselineIds = new List<String>();
       		for(GanttTaskBoard.Baseline b : history){   		
       		   peojectbaselineIds.add(b.ProjectBaselineID);      		
       		}      		
       		List<GanttTaskBoard.Baseline> records = GanttTaskBoard.getActivityBaselineRecords(peojectbaselineIds);
       		
       		system.assert(records.size()>0);
               try{
                List<leankor.GanttTaskBoard.Baseline> baseLineRecord = GanttTaskBoard.getActivityBaselineRecords(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
       		
      		// 
      		List<String> actvityids = new List<String>();
      		for(leankor__KanbanCard__c k :activities)
      		{
      		 actvityids.add(k.id);
      		}
            //Date : 10/06/19 create BaseLine Records
            List<leankor__KanbanCardBaseline__c> kanbanCardBaselineList = new List<leankor__KanbanCardBaseline__c>();
            for(leankor__KanbanCard__c k : activities){ 
            leankor__KanbanCardBaseline__c kcb = new leankor__KanbanCardBaseline__c();                        
            kcb.leankor__KanbanCard__c = k.Id;
            kcb.leankor__StartDateTime__c = k.leankor__StartDateTime__c;
            kcb.leankor__DueDateTime__c = k.leankor__DueDateTime__c;
            kcb.leankor__DurationUnit__c = k.leankor__DurationUnits__c ;
            kcb.leankor__EstimatedDuration__c =  k.leankor__EstimatedDuration__c;
       		
            kanbanCardBaselineList.add(kcb);    
            }
            insert kanbanCardBaselineList;
       		GanttTaskBoard.deleteActivityBaseline(actvityids);
            try{
                String deleteActivityBaseline = leankor.GanttTaskBoard.deleteActivityBaseline(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        
         }
            Test.stopTest();  
 		 }  
        
        
        
		public static testmethod void resAssignAndSchMode(){
       	
            Test.startTest();  
           
            User userInstance = TestGanttTaskBoard.getUserdata(); 
            
	        // Date 10/05/2019 - To create Folders and Projects. 
	        list<leankor__Portfolio__c> folders;
	        list<leankor__ProjectRoom__c> projects;
	        //To create UberBoard,KanbanBoard,PlanBoard   
	        List<leankor__ValueStream__c> boardlist; 
             
	        //system.runAs(userInstance){
            
	            folders = TestDataFactory.createFolder('Folders', 1);
	            projects= TestDataFactory.createProjects('Projects', folders, 1);
	            
            //To create UberBoard,KanbanBoard,PlanBoard   
	            boardlist = new List<leankor__ValueStream__c>();
	            
            List<string> boardListId = new List<string>();
               
            leankor__ValueStream__c UB = new leankor__ValueStream__c(Name='UberBoard',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projects[0].ID);
            leankor__ValueStream__c KB = new leankor__ValueStream__c(Name = 'Kanban Board',leankor__BoardType__c = 'Kanban Board',leankor__ProjectRoom__c = projects[0].ID);
            leankor__ValueStream__c PB = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c = 'Plan Board',leankor__ProjectRoom__c = projects[0].ID);
            boardlist.add(UB);
            boardlist.add(KB);
            boardlist.add(PB);
            boardListId.add(UB.Id);
            boardListId.add(KB.Id);
            boardListId.add(PB.Id);
            insert boardlist;
            
            //To create ProjectLaunchBehaviour
            leankor.TestDataFactory.createLeanModules();
            List<leankor__ProjectLaunchBehavior__c> projectLaunchBehavior= TestDataFactory.createProjectLaunchBehavior(projects);   
            system.assert(projectLaunchBehavior.size() !=0);
            
            //To create KanbanCardTemplate
            leankor__KanbanCardTemplate__c kanbanCardTemp = TestDataFactory.createKanbanCardTemplate(UB);
           
            //To create Activity  
            List<leankor__KanbanCard__c> activities =  TestDataFactory.createChildActivity(UB,kanbanCardTemp,Null,1);
            
            List<String> activitiesId = new List<string>();
            for(leankor__KanbanCard__c k :activities){
             activitiesId.add(k.Id);
            }
            
            //To create ActivityKb  
            List<leankor__KanbanCard__c> activitiesKb =  TestDataFactory.createChildActivity(KB,kanbanCardTemp,Null,1);
            
            //To create ActivityGroup
            List<leankor__KanbanCard__c> activityGroup = TestDataFactory.createActivityGroups(UB,kanbanCardTemp,1);
            //system.assert(activityGroup.size()==1);
            
            //To create Child Activity  
            List<leankor__KanbanCard__c> childActivities =  TestDataFactory.createChildActivity(UB,kanbanCardTemp,activityGroup,1);
            
            //To create ChildActivityGroup 
            List<leankor__KanbanCard__c> childActivityGroup = TestDataFactory.createChildActivityGroups(UB,kanbanCardTemp,1,activityGroup);
            
            //To create Childmilestone
            //List<leankor__KanbanCard__c> childMilestones= TestDataFactory.createChildMilestone(UB,kanbanCardTemp,activityGroup,1);
            
            //To create kanbanCards for Kanban Board
            List<leankor__KanbanCard__c> kbCard = TestDataFactory.createKanbanCard(KB,kanbanCardTemp,1,activities,userInstance);
            
            //To create Milestone
             //List<leankor__KanbanCard__c> kbCard1 = TestDataFactory.createChildMilestone(UB,kanbanCardTemp,Null,1);
            
            //To create ResourceAssignment
            list<leankor__ResourceAssignment__c> resourceAssign = TestDataFactory.createResourceAssignment(activities,userInstance,1);
            
            //To create ScheduleMode
            List<leankor__ScheduleMode__c> sm = TestDataFactory.createScheduleMode(activities,1);
            List<leankor__ScheduleMode__c> sm1 = TestDataFactory.createScheduleMode(childActivities,1);
            
            // creating data for Schedulemodes 
	        List<leankor.GanttTaskBoard.ScheduleMode> SMlist = new List<leankor.GanttTaskBoard.ScheduleMode>();        
	        leankor.GanttTaskBoard.ScheduleMode SMInstance = new leankor.GanttTaskBoard.ScheduleMode();
	        SMInstance.ActivityId = activities[0].Id;
	        SMInstance.SchedulingModeId = sm[0].id;
	        SMInstance.ManuallyScheduled = true;
	        SMlist.add(SMInstance);
            
            //To create Baseline on Board 
            list<leankor__ProjectScheduleBaseline__c> baselineList = new List<leankor__ProjectScheduleBaseline__c>(); 
    		 
       		for(leankor__ValueStream__c v : boardlist){
       		leankor__ProjectScheduleBaseline__c PSB = new leankor__ProjectScheduleBaseline__c();
			PSB.leankor__Title__c ='title';
			PSB.leankor__ProjectBoard__c = v.Id;
       		baselineList.add(PSB); 
       		}
       		insert baselineList;
       		
            //To create Baseline on Activity 
            List<leankor__KanbanCard__c> kbList = new  List<leankor__KanbanCard__c>();
            kblist.addAll(activities);
            kblist.addAll(childActivities);
            
            list<leankor__KanbanCardBaseline__c> KanbanCardBaselineList = new list<leankor__KanbanCardBaseline__c>();
            for(leankor__KanbanCard__c k : kbList){ 
			leankor__KanbanCardBaseline__c KCB = new leankor__KanbanCardBaseline__c();
			
			KCB.leankor__ProjectScheduleBaseline__c = baselineList[0].Id;
			KCB.leankor__KanbanCard__c = k.Id;
			KCB.leankor__StartDateTime__c = k.leankor__StartDateTime__c;
			KCB.leankor__DueDateTime__c = k.leankor__DueDateTime__c;
		    KCB.leankor__DurationUnit__c = k.leankor__DurationUnits__c ;
			KCB.leankor__EstimatedDuration__c =  k.leankor__EstimatedDuration__c;
						
			KanbanCardBaselineList.add(KCB);	
			}
            insert KanbanCardBaselineList;
            
            //To call method getAllPlanBoardcards for testing
            leankor.GanttTaskBoard.GanttResourcesScheduler result = new leankor.GanttTaskBoard.GanttResourcesScheduler();
            result = leankor.GanttTaskBoard.getAllPlanBoardcards(projects[0].Id);
            
            //To create data for Resource Assignment
            List<leankor.GanttTaskBoard.ResourceAssignment> resourceAssignlist = new List<leankor.GanttTaskBoard.ResourceAssignment>();          
            
            leankor.GanttTaskBoard.ResourceAssignment resourceAssignInstance = new leankor.GanttTaskBoard.ResourceAssignment();
          	resourceAssignInstance.TaskId = activities[0].Id;
         	resourceAssignInstance.Units = 50.0;
         	resourceAssignInstance.ResourceId = UserInfo.getUserId();
	     	resourceAssignInstance.Id = resourceAssign[0].Id;
	     	resourceAssignInstance.PercentCompleted = 50.0; 
	     	resourceAssignlist.add(resourceAssignInstance);    
            
            //To store ResourceAssignment ids in the list
            list<string> resourceAssignlistId = new  list<string>();
            for(leankor__ResourceAssignment__c raRecord :resourceAssign){
            resourceAssignlistId.add(raRecord.Id);
            }
            
            //To call methods for testing 
            GanttTaskBoard.getAllResources(UB.Id); 
            GanttTaskBoard.CreateResourceAssignment(resourceAssignlist);
            GanttTaskBoard.updateResourceAssignment(resourceAssignlist);
            //GanttTaskBoard.DeleteResourceAssignment(resourceAssignlistId);
            GanttTaskBoard.CreateDefaultResourceAssignment(activities);
            GanttTaskBoard.getResourceAssignment(activities[0].Id);
            GanttTaskBoard.CreateScheduleMode(activities);
            //GanttTaskBoard.getScheduleMode(activities);
            GanttTaskBoard.UpdateScheduleMode(SMlist);
            GanttTaskBoard.DeleteScheduleMode(activitiesId);
            GanttTaskBoard.DeleteResourceAssignment(resourceAssignlistId);
            resourceAssignlistId.clear();

            /*try{
                String record  = leankor.GanttTaskBoard.DeleteResourceAssignment(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }*/
            try{
                list<leankor.GanttTaskBoard.ResourceAssignment> resourceAssignmentData = leankor.GanttTaskBoard.getResourceAssignment('00Dd0000001h60X');
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }
            /*try{
                String record = leankor.GanttTaskBoard.DeleteScheduleMode(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }*/
            try{
                List<leankor__ScheduleMode__c> scheduleMOdeRecord = leankor.GanttTaskBoard.getScheduleMode(new List<String>{'00Dd0000001h60X'});
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }
            try{
                List<leankor.GanttTaskBoard.ResourceAssignment> resourceData = leankor.GanttTaskBoard.getAllResources('00Dd0000001h60X');
            }catch (Exception e) {
                System.Assert(e.getMessage().contains('Error: Invalid input'));
            }
            
            
            resourceAssignlist.clear();
            //GanttTaskBoard.updateResourceAssignment(resourceAssignlist);
            
            SMlist.clear();
            leankor.GanttTaskBoard.ScheduleMode SMInstance1 = new leankor.GanttTaskBoard.ScheduleMode();
	        SMInstance1.ActivityId = activities[0].Id;	        
	        SMInstance1.SchedulingModeId = null;
            SMInstance1.ManuallyScheduled = false;
	        SMlist.add(SMInstance1);
	        GanttTaskBoard.UpdateScheduleMode(SMlist);
            
            list<String> jsonString = new list<string>();
            leankor.GanttTaskBoard.ResourceAssignment RA1 = new leankor.GanttTaskBoard.ResourceAssignment();		        
	        RA1.Units = 50.0;
	        RA1.ResourceId = UserInfo.getUserId();		        
	        RA1.PercentCompleted = 50.0;
	       	  
	       	jsonString.add(JSON.serialize(RA1)); 
	       	
	       	//To add Id of kanbanCard in the List 
            List<String> kanbancardIdlist = new List<String>();
            for(leankor__KanbanCard__c kbRecord :activities){
              kanbancardIdlist.add(kbRecord.Id);
            }
            
            //To call method for testing 
            GanttTaskBoard.multiActivityUpdateRA(kanbancardIdlist,jsonString);
            
            try{
                List<leankor.GanttTaskBoard.ResourceAssignment> resourceAssignmentRecord = leankor.GanttTaskBoard.multiActivityUpdateRA(new List<String>{'00Dd0000001h60X'},jsonString); // input is dummy id, need to get exception
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
       		GanttTaskBoard.updateMultipleRA(kanbancardIdlist,UserInfo.getUserId());
	        //}
			
            Test.stopTest();  
        }
        
        public static testmethod void getPortAndCardData(){
            //To get User data
            User userData = [SELECT Id,SmallPhotoUrl,Name FROM User where ID=:Userinfo.getUserId()];
              
	       	//Date: 10/05/2019 - To Create Folder  
	        leankor__Portfolio__c folder;
            
	        System.runAs(userData) {
	            
	            folder = new leankor__Portfolio__c(Name = 'folderName');
            insert folder;
            
            //To Create ChildFolder 
            list<leankor__Portfolio__c > folderList = new list<leankor__Portfolio__c>();
            for(integer i=0;i<52;i++){
               leankor__Portfolio__c folder1 = new leankor__Portfolio__c(Name = 'childFolderName'+i,leankor__ParentPortfolio__c= folder.Id);
               folderList.add(folder1);
            }
            insert folderList ;
            
            //To Create Project 
            List<leankor__ProjectRoom__c> projectList = new list<leankor__ProjectRoom__c>();
            for(integer i=0;i<50;i++){
                leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name ='projectName'+i , leankor__Portfolio__c = folder.Id,leankor__IsTemplateProject__c=false);
                projectList.add(project);           
            }
            
            //-------
            Integer isTemplateProjectTrueCount=5;
            for(integer i=0;i<isTemplateProjectTrueCount;i++){
                leankor__ProjectRoom__c project1 = new leankor__ProjectRoom__c(Name ='projectName'+i , leankor__Portfolio__c = folder.Id,leankor__IsTemplateProject__c=true);
                projectList.add(project1); 
            }
            
            //--------
            Integer leanPortfolioNullCount=5;
            for(integer i=0;i<leanPortfolioNullCount;i++){
                leankor__ProjectRoom__c project2 = new leankor__ProjectRoom__c(Name ='projectName'+i , leankor__Portfolio__c =null,leankor__IsTemplateProject__c=false);
                projectList.add(project2); 
            }
            
            insert projectList;  
            
            //---------
            GanttTaskBoard.childPortfolioHierarchy(folder.Id,folderList,projectList);
            
            //To Create ValueStream 
            list<leankor__ValueStream__c> valueStreamList = new list<leankor__ValueStream__c>();
            for(leankor__ProjectRoom__c projectRecord :  projectList){
                leankor__ValueStream__c UB = new leankor__ValueStream__c(Name='UberBoard',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = projectRecord.ID,leankor__IsTemplateBoard__c = false,OwnerId=Userinfo.getUserId(), leankor__SevenDayWorkWeek__c = true,leankor__isRecordDeleted__c = false);
                valueStreamList.add(UB);
                leankor__ValueStream__c PB = new leankor__ValueStream__c(Name='PlanBoard',leankor__BoardType__c='Plan Board',leankor__ProjectRoom__c = projectRecord.ID,leankor__IsTemplateBoard__c = false,OwnerId=Userinfo.getUserId(), leankor__SevenDayWorkWeek__c = true, leankor__isRecordDeleted__c = false);
                valueStreamList.add(PB);    
            }   
            insert valueStreamList;
        
           //To Create Module 
			List<leankor__Module__c> leanModule = new List<leankor__Module__c>();

        	leankor__Module__c m1 = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true,Name = 'Plan (Gantt)'); 
        	leanModule.add(m1);
        	leankor__Module__c m2 = new leankor__Module__c(leankor__BoardType__c = '_System_PlanBoard',leankor__Order__c = 2,leankor__SetUp__c = true,Name = 'Roll Up'); 
        	leanModule.add(m2);
        	 
 			insert leanModule;
            
            //To Create Project Launch Behavior 
            List<leankor__ProjectLaunchBehavior__c> projectLaunchBehaviorList = new List<leankor__ProjectLaunchBehavior__c>();
             
            Integer count=0;
            for(leankor__ProjectRoom__c PR : projectList){
            	count++;
            	for(leankor__Module__c module :leanModule ){
                leankor__ProjectLaunchBehavior__c projectLaunchBehavior = new leankor__ProjectLaunchBehavior__c(leankor__Module__c = module.Id,leankor__OneClicklaunch__c = true,leankor__OpenNewTab__c = true,leankor__Project__c = PR.ID);
                projectLaunchBehaviorList.add(projectLaunchBehavior);  
            	}
            	if(count==30){  
          					  break;  
        					 } 
            }                 
            insert projectLaunchBehaviorList;
        
            //To Create kanbanCard Template 
            list<leankor__KanbanCardTemplate__c> templateList = new list<leankor__KanbanCardTemplate__c>();
            for(leankor__ValueStream__c valueStreamRecord : valueStreamList)
            {
            leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c(Name = 'Default',leankor__Title__c = 'Default',leankor__Height__c = 120,leankor__Color__c = '#bdbffc',leankor__Width__c = 170,leankor__ValueStream__c=valueStreamRecord.Id);
            templateList.add(template);
            }
            insert templateList;
          
            //To Create Master Container 
            list<leankor__MasterContainer__c> masterContainerList = new list<leankor__MasterContainer__c>();
             integer j =0;
            for(leankor__ValueStream__c valueStreamRecord : valueStreamList){
	              	if(valueStreamRecord.leankor__BoardType__c=='Plan Board'){       
                leankor__MasterContainer__c Mc = new leankor__MasterContainer__c (leankor__Valuestream__C = valueStreamRecord.id,leankor__IsCardAvailable__c=true,Name = 'zone',leankor__GUID__c = 'test-1234-'+j+system.now(),leankor__Type__c  = 'Regular' );
                masterContainerList.add(Mc);
                j++;
                }
            }
            insert masterContainerList;
        
            //To Create KanbanCard
            List<leankor__KanbanCard__c> activitykanbanCardList = new List<leankor__KanbanCard__c>(); 
            Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            integer z=1;
            
            for(leankor__ValueStream__c valueStreamRecord : valueStreamList){
                 for(Integer i = 0; i < 10; i++){
                    leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                    ag.Name = 'Activity ' + i;
                    ag.RecordTypeId = recType;
                    ag.leankor__ValueStream__c = valueStreamRecord.Id;
                    ag.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);
                    ag.leankor__CardID__c = String.valueOf(i);
                    ag.leankor__Title__c = 'Activity ' + i;
                    ag.leankor__Priority__c = z;
                    ag.leankor__ValueStreamCardLink__c =null;
                    ag.leankor__KanbanCardTemplate__c = templateList[0].Id;
                    ag.leankor__StartDate__c = System.today();
                    ag.leankor__DueDate__c = System.today().addDays(i);
                    ag.leankor__StartDateTime__c = system.now();
                    ag.leankor__DueDateTime__c = system.now().addDays(i);
                    ag.leankor__PercentComplete2__c = 0;
                    ag.leankor__isRecordDeleted__c = false;
                    ag.leankor__DurationUnits__c  = 'Minutes';
                    ag.leankor__EstimatedDuration__c= 60;
                    ag.leankor__MasterContainer__c=masterContainerList[0].Id;
                    if (i == 1) {
                        ag.leankor__Monday__c = false;
                        ag.leankor__Tuesday__c = false;
                        ag.leankor__Wednesday__c = false;
                        ag.leankor__Thursday__c = false;
                        ag.leankor__Friday__c = false;
                        ag.leankor__Saturday__c = false;
                        ag.leankor__Sunday__c = false;
                    }
                    activitykanbanCardList.add(ag);
                    if(z>4)z=1; 
            }
            }
            insert activitykanbanCardList;
            system.assert(activitykanbanCardList.size()>0);
            
            //To call getPortfolioHierarchy method for Testing 
            leankor.GanttTaskBoard.GetPortfolioresource gf = GanttTaskBoard.getPortfolioHierarchy(folder.Id);
            
            //To check whether the data created and data returned from method is equal or not. 
            System.assertEquals(folder.Name,gf.Datalog.Foldername);
            System.assertEquals(folder.Id,gf.Datalog.FolderID);
            System.assertEquals(1,gf.Datalog.FolderLevel);
            System.assertEquals(folderList.size()+projectList.size()-isTemplateProjectTrueCount-leanPortfolioNullCount,gf.Hierarchyrecords.size());
            System.assertEquals(userData.Id,gf.UserRecords[0].Id);
            System.assertEquals(userData.Name,gf.UserRecords[0].Name);
            System.assertEquals(userData.SmallPhotoUrl,gf.UserRecords[0].SmallPhotoUrl);
             
	            System.assertEquals(gf.DataLog.hasReadAccess, true);
	            System.assertEquals(gf.DataLog.hasEditAccess, true);
	            System.assertEquals(gf.DataLog.hasDeleteAccess, true);
	             
            //To create Json Data 
            BooLean isStream = true;    
            List<String> JSONdata = new List<String>();
            
            for(integer i=0;i<50;i++){
            String JSON_1 = '{"ID":"'+activitykanbanCardList[i].Id+'","Name":"kanban1","EstimatedDuration":1,"PercentDone":20,"CardID":1,"DurationUnits":"days","IsExternallyDependent":false,"IsSuccessorRecalculate":false,"Order":1,"duedate":'+JSON.Serialize(System.Now().addDays(i))+',"startdate":'+JSON.Serialize(System.Now().addDays(-i))+'}';
            JSONdata.add(JSON_1);
            } 
            
            //To add Id of kanbanCard in the List 
            List<String> kanbancardIdlist = new List<String>();
            for(leankor__KanbanCard__c kbRecord :activitykanbanCardList){
              kanbancardIdlist.add(kbRecord.Id);
            }
            
            //To call updateCardData method for Testing  
            List <leankor__Kanbancard__c> upCard = GanttTaskBoard.updateCardData(kanbancardIdlist,JSONdata,isStream); 
            try{
                List <leankor__Kanbancard__c> result = GanttTaskBoard.updateCardData(new List<String>{'00Dd0000001h60X'},JSONdata,isStream); 
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Invalid input'));
            }
             
             for(leankor__Kanbancard__c k: upCard){
               System.assertEquals(1,k.leankor__EstimatedDuration__C); 
             }
            JSONdata.clear(); 
            GanttTaskBoard.updateCardData(kanbancardIdlist,JSONdata,isStream);  
            
            //To call getPortHierarchy method for testing
            leankor.ProjectBoardCarousel.portfoliodata port = new leankor.ProjectBoardCarousel.portfoliodata();
            port.Id = folder.Id;
            Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> getPortHierarchyInstance = leankor.GanttTaskBoard.getPortHierarchy(port);
            
            //To call getPortHierarchy method for testing
            leankor.ProjectBoardCarousel.portfoliodata port1 = new leankor.ProjectBoardCarousel.portfoliodata();
            port1.Id = folderList[0].Id;
            leankor.GanttTaskBoard.getPortHierarchy(port1);
            
            /*To create document data
			Document documentObj = new Document();
			documentObj.Body = Blob.valueOf('Some DocumentText');
			documentObj.ContentType = 'application/pdf';
			documentObj.DeveloperName = 'my_document';
			documentObj.IsPublic = true;
			documentObj.Name = 'PlanGanttPrintLogo';
			//documentObj.FolderId = [select id from folder where name = 'VisualLean_CoreDocs'].id;
			insert documentObj;
            */
            leankor.GanttTaskBoard.getCustomerLogo();
            //leankor.GanttTaskBoard.getMiniatureVS(upCard[0].leankor__Valuestream__c);
            try{
            	leankor.ViewGanttController.checkAccessForBoards(kanbancardIdlist); 
            }catch (Exception e) {
            	System.Assert(e.getMessage().contains('Invalid input'));
        	}
            leankor.RealTimeControllerHelper.getViolatedActivities(); 
            

			//Creating task
			Task testTask = new Task();

           //Creating miniature
           testTask.WhatId = activitykanbanCardList[1].id;
           testTask.ActivityDate = activitykanbanCardList[1].leankor__StartDate__c;
           activitykanbanCardList[1].leankor__ValueStreamCardLink__c = activitykanbanCardList[0].id;
			activitykanbanCardList[0].RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();

           activitykanbanCardList[4].leankor__ValueStreamCardLink__c = activitykanbanCardList[3].id;

           activitykanbanCardList[5].RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
           activitykanbanCardList[6].leankor__ValueStreamCardLink__c = activitykanbanCardList[5].id;
           activitykanbanCardList[6].RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
           activitykanbanCardList[6].leankor__ValueStreamCardLink__c = activitykanbanCardList[7].Id;
                
           leankor__dependency__c dependency1 = new leankor__dependency__c();
           dependency1.leankor__GUID__c = 'dep1';
           dependency1.leankor__ValueStream__c = activitykanbanCardList[6].leankor__ValueStream__c;
           dependency1.leankor__Predecessor__c = activitykanbanCardList[1].Id;
           dependency1.leankor__Successor__c = activitykanbanCardList[6].Id;
           insert dependency1;
           
           List<leankor__ScheduleMode__c> listSchedualMode = new List<leankor__ScheduleMode__c>();
           for (Integer i=1; i <= 5; i++) {
                leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
                scheduleMode.leankor__KanbanCard__c = activitykanbanCardList[i].Id;
                scheduleMode.leankor__ManuallyScheduled__c = true;
                scheduleMode.leankor__Mode__c ='Normal';
                scheduleMode.leankor__EffortActual__c = 2;
                scheduleMode.leankor__EffortUnits__c = 'Days';
                listSchedualMode.add(scheduleMode);     
           }
           insert listSchedualMode;
                
           List<leankor__Kanbancard__c> updateKanbanCardList = new List<leankor__Kanbancard__c>();
           updateKanbanCardList.add(activitykanbanCardList[0]);
           updateKanbanCardList.add(activitykanbanCardList[1]);
           updateKanbanCardList.add(activitykanbanCardList[2]);
           updateKanbanCardList.add(activitykanbanCardList[3]);
           updateKanbanCardList.add(activitykanbanCardList[4]);
           updateKanbanCardList.add(activitykanbanCardList[5]);
           updateKanbanCardList.add(activitykanbanCardList[6]);

           update updateKanbanCardList;

           insert testTask;

 		   List<Id> methodParameter = new List<Id>();
           methodParameter.add(updateKanbanCardList[0].id); // activity
           methodParameter.add(updateKanbanCardList[3].id); // activity
           methodParameter.add(updateKanbanCardList[5].id); // milestone
                              
           leankor.GanttTaskBoard.fixCardDatesToActivity(methodParameter);   
            try{
                List<leankor.GanttTaskBoard.KanbanCard> record = leankor.GanttTaskBoard.fixCardDatesToActivity(new List<String>{'00Dd0000001h60X'});   
            } catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
	    }//Ends  
         
	       //Date: 10/05/2019 - New Standard users are created for security testing
	       User u1 =  leankor.TestDataFactory.createStandardUser('test12');
	       User u2 =  leankor.TestDataFactory.createStandardUser('test23');
	       User u3 =  leankor.TestDataFactory.createStandardUser('test34');
     
	   	   //Sharing the record with users
	   	   List<String> shareFolderList =  new List<String>();
	   	   shareFolderList.add(folder.Id);
           System.debug(Schema.getGlobalDescribe().get('leankor__Portfolio__share'));
           //if(Schema.getGlobalDescribe().get('leankor__Portfolio__share').newSObject()!=null){
           		Boolean isReadonly = leankor.TestDataFactory.shareRecord(u1, shareFolderList, 'leankor__Portfolio__share','Read');
           		Boolean isReadWrite = leankor.TestDataFactory.shareRecord(u2, shareFolderList,'leankor__Portfolio__share','Edit');
          // }	 
          if(isReadonly){  	   	   	  						               
	       System.runAs(u1) {
	       		List<leankor__Portfolio__c> folderList = [Select Id from leankor__Portfolio__c where name='folderName' limit 9999];
		   			System.debug(folderList.size());
		   			System.assertEquals(1, folderList.size());	
		       		//To call getPortfolioHierarchy method for Testing 
		            leankor.GanttTaskBoard.GetPortfolioresource gf = GanttTaskBoard.getPortfolioHierarchy(folder.Id);
		            //To check whether the data created and data returned from method is equal or not. 
		            System.assertEquals(gf.DataLog.hasReadAccess, true);
		            System.assertEquals(gf.DataLog.hasEditAccess, false);
		            System.assertEquals(gf.DataLog.hasDeleteAccess, false);
		       }
          } 
          if(isReadWrite){         
	       System.runAs(u2) {
	       		List<leankor__Portfolio__c> folderList = [Select Id from leankor__Portfolio__c where name='folderName' limit 9999];
	   			System.assertEquals(1, folderList.size());	
	       		//To call getPortfolioHierarchy method for Testing 
	            leankor.GanttTaskBoard.GetPortfolioresource gf = GanttTaskBoard.getPortfolioHierarchy(folder.Id);
	            //To check whether the data created and data returned from method is equal or not. 
	            System.assertEquals(gf.DataLog.hasReadAccess, true);
	            System.assertEquals(gf.DataLog.hasEditAccess, true);
	            System.assertEquals(gf.DataLog.hasDeleteAccess, false);
	       }
          }
          if(!isReadWrite && !isReadonly){
	       		List<leankor__Portfolio__c> folderList = [Select Id from leankor__Portfolio__c where name='folderName' limit 9999];
		   	System.assertEquals(1, folderList.size());	
          	leankor.GanttTaskBoard.GetPortfolioresource gf = GanttTaskBoard.getPortfolioHierarchy(folder.Id);
          	 System.assertEquals(gf.DataLog.hasReadAccess, true);
		            System.assertEquals(gf.DataLog.hasEditAccess, true);
		            System.assertEquals(gf.DataLog.hasDeleteAccess, true);
		}
		}

/*
     Date : 18/04/19
     To Cover readRelatedRecordCount method for risk ,chatter,files count.   
   */
    private static testMethod void readRelatedRecordCountTest(){
    	Test.startTest();
	        User user = leankor.TestDataFactory.createStandardUser('leankor1');
			List<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
	        List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
	        List<leankor__ValueStream__c> valueStream = leankor.TestDataFactory.createValueStream(project, 'Plan Board', user);       
	        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valueStream[0]);
	        List<leankor__KanbanCard__c> agList = leankor.TestDataFactory.createActivityGroups(valueStream[0], template, 5);
	        List<leankor__KanbanCard__c> activityList =leankor.TestDataFactory.createChildActivity(valueStream[0], template, agList, 5);
	        List<FeedItem> kanbanFeedList= new List<FeedItem>();
	        List<leankor__IssueLog__c> riskList =new List<leankor__IssueLog__c>();
	        List<String> cardIds=new List<String>();

            for (Integer i = 0; i < activityList.size(); i++) {
                Task task = new Task();
                task.Subject  = 'Task on matching card';
                task.Status   = 'Not Started';
                task.Priority = 'Normal';
                task.WhatId   = activityList[i].Id;
                insert task;
            }
    
        
	        for (leankor__KanbanCard__c kanban : activityList) {
	        	FeedItem feed = new FeedItem ();
	           	feed.parentid = kanban.id;
	           	feed.type = 'ContentPost';
	           	feed.Body = 'Hello';        		
	         	kanbanFeedList.add(feed);

	         	leankor__IssueLog__c risk= new leankor__IssueLog__c();
	            risk.leankor__kanbancard__c=kanban.id;
	         	risk.leankor__StatusType__c='Risk';
	         	risk.leankor__Probability__c='Likely';
	         	risk.leankor__LogTime__c=system.now();
	         	risk.leankor__Detail__c='ghj';
	         	riskList.add(risk);
	         	cardIds.add(kanban.id);
	        }
        
        	for (leankor__KanbanCard__c kanban : activityList) {
	        	FeedItem feed = new FeedItem ();
	           	feed.parentid = kanban.id;
	           	feed.type = 'ContentPost';
	           	feed.Body = 'Hello';        		
	         	kanbanFeedList.add(feed);

	         	leankor__IssueLog__c risk= new leankor__IssueLog__c();
	            risk.leankor__kanbancard__c=kanban.id;
	         	risk.leankor__StatusType__c='Risk';
	         	risk.leankor__Probability__c='Likely';
	         	risk.leankor__LogTime__c=system.now();
	         	risk.leankor__Detail__c='ghj';
	         	riskList.add(risk);
	         	cardIds.add(kanban.id);
	        }
        
	        insert kanbanFeedList;
	        insert riskList;       

	        system.assert(leankor.GanttTaskBoard.readRelatedRecordCount(cardIds)!=null);

	     Test.stopTest();
         
     }
     
		private static testMethod void readGanttTasksTest(){
			Test.startTest();        
			leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(name = 'testProject');
			insert sourceProject;
					               
			leankor__ValueStream__c planGanttBoard = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = sourceProject.Id,leankor__IsTemplateBoard__c = false);         
			insert planGanttBoard;
			
			List<String> ls = new List<String>();
					           
			leankor__KanbanCard__c kanban1 = new leankor__KanbanCard__c();
			kanban1.Name = 'Folder 1';
			kanban1.leankor__ValueStream__c = planGanttBoard.Id;
			kanban1.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();     
			insert kanban1;
			ls.add(kanban1.Id);
					   		               
			leankor__KanbanCard__c kanban2 = new leankor__KanbanCard__c();
			kanban2.Name = 'Activity 1';
			kanban2.leankor__ValueStream__c = planGanttBoard.Id;
			kanban2.leankor__GUID__c = leankor.TestDataFactory.createGuid();
			kanban2.leankor__ValueStreamCardLink__c = 	kanban1.Id;
			kanban2.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();     
			insert kanban2;
			ls.add(kanban2.Id);
					           
			leankor__KanbanCard__c kanban3 = new leankor__KanbanCard__c();
			kanban3.Name = 'Activity 2';
			kanban3.leankor__ValueStream__c = planGanttBoard.Id;
			kanban3.leankor__GUID__c = leankor.TestDataFactory.createGuid();
			kanban3.leankor__ValueStreamCardLink__c = 	kanban1.Id;
			kanban3.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();     
			insert kanban3;
			ls.add(kanban3.Id);
			
			leankor__Dependency__c dep = new leankor__Dependency__c();
			dep.leankor__Predecessor__c = kanban2.Id;
			dep.leankor__Successor__c = kanban3.Id;
			insert dep;
			
			leankor.KanbanToGanttController.CloneCardData clone = new leankor.KanbanToGanttController.CloneCardData();
			clone.ItemType = 'foldercard';
			clone.BoardId = planGanttBoard.ID;
			clone.folderId = kanban1.ID;
			clone.cardIdlist = new List<String>();
			clone.cardIdlist.addall(ls);
			
			// checking ActivityGroup cloning                           
	        leankor.KanbanToGanttController.CloneCardData clonecard = leankor.KanbanToGanttController.cloneActivityGroup(clone,UserInfo.getSessionId());
			
			string someJSONData = '{"oldFolderId" : "'+kanban1.ID+'","valueStreamId" :"'+ planGanttBoard.ID +'","newFolderId" :"'+ clonecard.folderId +'"}';
			
			leankor.KanbanToGanttController.CloneCardData clonecard2 = leankor.GanttTaskBoard.readGanttTasks(someJSONData);
            System.assert(clonecard2.Activity != null);
					               
			Test.stopTest();
		}	     
        private static testMethod void getAllScheduleModeTest(){
            leankor__ProjectRoom__c sourceProject = new leankor__projectRoom__c(name = 'testProject');
            insert sourceProject;                                              
            leankor__ValueStream__c vsList = new leankor__ValueStream__c(Name = 'Plan Board',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = sourceProject.Id,leankor__IsTemplateBoard__c = false);         
            insert vsList;                                         
            List<String> vsids=new List<String> ();
             vsids.add(vsList.id);
            leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
            kanban.Name = 'kc1';
            kanban.leankor__ValueStream__c = vsList.Id;            
            insert kanban;
            List<leankor__ScheduleMode__c> scheduleMode = new List<leankor__ScheduleMode__c>();
            for(Integer i=0;i<=3;i++){
                leankor__ScheduleMode__c sch=new leankor__ScheduleMode__c();          
                sch.leankor__Mode__c ='Normal';
                sch.leankor__EffortActual__c=50;
                sch.leankor__EffortUnits__c= 'Months';
                sch.leankor__KanbanCard__c=kanban.id;
                scheduleMode.add(sch);
            }
            insert scheduleMode;
            System.assert(leankor.GanttTaskBoard.getAllScheduleMode(vsids)!=null);
            
        try{
            List<leankor.GanttTaskBoard.ScheduleMode> scheduleModeRecord = leankor.GanttTaskBoard.getAllScheduleMode(new List<String>{'00Dd0000001h60X'}); // input is dummy id, need to get exception
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        }
        /*
            Date : 10/06/19 
            To cover getAllStickersByBoardIds method .
        */        
         private static testMethod void getAllStickersByBoardIdsTest(){
            //create Standard user.
            User user = leankor.TestDataFactory.createStandardUser('lean');
            //create Folders.
            List<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
           //create Projects
            List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
            List<leankor__ValueStream__c> valueStream = leankor.TestDataFactory.createValueStream(project, 'UberBoard', user);       
            leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valueStream[0]);
            List<leankor__KanbanCard__c> agList = leankor.TestDataFactory.createActivityGroups(valueStream[0], template, 2);
            List<leankor__KanbanCard__c> activityList =leankor.TestDataFactory.createChildActivity(valueStream[0], template, agList, 2);
            //create kanbancard records.
            List<leankor__KanbanCard__c> kanbancardList = leankor.TestDataFactory.createKanbanCard(valueStream[0],template,4,activityList,user);
            //add valueStreamIds in List of String.
            List<String> vsIds=new List<String>();
            for(leankor__ValueStream__c vs:valueStream){
               vsIds.add(vs.Id);
            } 
            //create sticker record.
            leankor__Sticker__c  sticker =new leankor__Sticker__c();
            sticker.name='Force.com';
            sticker.leankor__ValueStream__c=valueStream[0].id;
            insert sticker;
            //create KanbancardSticker records.
            List<leankor__KanbanCardSticker__c>  kcStickerList=new List<leankor__KanbanCardSticker__c>();
            for(leankor__KanbanCard__c kc:kanbancardList){
                leankor__KanbanCardSticker__c kcs =new leankor__KanbanCardSticker__c();
                kcs.leankor__KanbanCard__c=kc.id;
                kcs.leankor__Sticker__c=sticker.id;
                kcStickerList.add(kcs);
            }   
            insert kcStickerList;
            Test.startTest();
                System.assert(leankor.GanttTaskBoard.getAllStickersByBoardIds(vsIds)!=null);
                try{
                    List<leankor.GanttTaskBoard.Sticker> result = leankor.GanttTaskBoard.getAllStickersByBoardIds(new List<String>{'00Dd0000001h60X'});
                } catch (Exception e) {
                    System.Assert(e.getMessage().contains('Invalid input'));
                }
                System.assert(leankor.GanttTaskBoard.partition(kanbancardList,0,2)!=null);
            Test.stopTest();
     
         }
         /*
          Date : 12/06/19
          To cover readExternallyDependentVSIds method.
         */
         private static testMethod void readExternallyDependentVSIdsTest(){
            //create Standard user.
            User user = leankor.TestDataFactory.createStandardUser('lean');
            //create Folders.
            List<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
           //create Projects
            List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 1);        
            //create valueStream records.
            List<leankor__ValueStream__c> valueStreams = leankor.TestDataFactory.createValueStream(project, 'UberBoard', user); 
            leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valueStreams[0]);
            List<leankor__KanbanCard__c> agList = leankor.TestDataFactory.createActivityGroups(valueStreams[0], template, 2);
            List<leankor__KanbanCard__c> activityList =leankor.TestDataFactory.createChildActivity(valueStreams[0], template, agList, 2);
            leankor__Dependency__c dependency =new leankor__Dependency__c();
            dependency.leankor__Successor__c = activityList[0].id;
            dependency.leankor__Predecessor__c =  activityList[1].id;
            dependency.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            insert dependency;
            List<String> vsIds =new List<String>();
            for(leankor__ValueStream__c vs :valueStreams){
               vsIds.add(vs.id);
            }
            System.assert(leankor.GanttTaskBoard.readExternallyDependentVSIds(vsIds)!=null);          
         } 
         /*
            Date :12/06/19
            To Cover readSuccessorDependencyForRecalculate method
         */
         private static testMethod void readSuccessorDependencyForRecalculateTest(){
            //create Standard user.
            User user = leankor.TestDataFactory.createStandardUser('lean');
            //create Folders.
            List<leankor__Portfolio__c> folder = leankor.TestDataFactory.createFolder('Test Folder', 1);
            ///create Projects
            List<leankor__ProjectRoom__c> project = leankor.TestDataFactory.createProjects('Test Project', folder, 3);
            //create valueStream records.
            List<leankor__ValueStream__c> valueStreams = leankor.TestDataFactory.createValueStream(project, 'UberBoard', user); 
            leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valueStreams[0]);
           // create kanban cards.          
           Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();                       
           Set<String> cardsIds =new Set<String>();
           List<leankor__KanbanCard__c> kbList =new List<leankor__KanbanCard__c>();
           for(leankor__ValueStream__c vs :valueStreams){
                leankor__KanbanCard__c kb = new leankor__KanbanCard__c();             
                    kb.Name = 'Activity ';
                    kb.RecordTypeId = recType;
                    kb.leankor__ValueStream__c =  vs.id;               
                    kb.leankor__GUID__c = leankor.TestDataFactory.createGuid();                                   
                    kb.leankor__Title__c = 'Activity ' ;
                    kb.leankor__Priority__c = 0;                
                    kb.leankor__KanbanCardTemplate__c = template.Id;
                    kb.leankor__StartDate__c = System.today();
                    kb.leankor__DueDate__c = System.today().addDays(5);
                    kb.leankor__PercentComplete2__c = 50;   
                    kb.leankor__IsexternallyDependent__c  =true;               
                    kb.OwnerId=user.id;
                    kbList.add(kb);
	
           
           }
           insert kbList;                                                                                       
            for(leankor__KanbanCard__c kb :kblist){
                cardsIds.add(kb.id);
            }           
            leankor__Dependency__c dependency =new leankor__Dependency__c();
            dependency.leankor__Successor__c = kbList[0].id;
            dependency.leankor__Predecessor__c =  kbList[1].id;
            dependency.leankor__GUID__c = leankor.TestDataFactory.createGuid();
            dependency.leankor__ValueStream__c=valueStreams[1].id;               
            insert dependency;                      
            Test.startTest();
                System.assert(leankor.GanttTaskBoard.readSuccessorDependencyForRecalculate(cardsIds)!=null);
            Test.stopTest();
         }

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover  updateCardRecords  Method inside GanttTaskBoard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private  static void updateCardRecordsTest(){
        Test.startTest();
            user userRecod = [Select Id 
                                From User 
                                Where Id =: UserInfo.getUserId()];
            List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
            List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
            List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', userRecod);    
            leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
            List<leankor__KanbanCard__c> kanbancardList=leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,null,userRecod);
            
            List<Sobject> objRecord = new List<Sobject>();                                            
            for(leankor__KanbanCard__c singleRecord:kanbancardList){
                singleRecord.leankor__StartDate__c = null;
                singleRecord.leankor__DueDate__c = null;
                Sobject singleobjRecord = singleRecord;
                objRecord.add(singleobjRecord);
            }
            List<sObject> listOfId = leankor.GanttTaskBoard.updateCardRecords(objRecord);
            System.assert(listOfId.size()>0);
        Test.stopTest();   
    }

    /*
    @isTest
    static void testReadAllPlanBoardCardsWithAllData() {

        leankor__LeanConstants__c leanConstant = new leankor__LeanConstants__c(leankor__AllowSchedulingConstraints__c = true);
        insert leanConstant;
    
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project Name';
        projectRecord.leankor__ProjectLaunchDateTime__c = System.now() + 5;
        insert projectRecord;
    
        List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
        for (Integer valueStreamCount = 1; valueStreamCount <= 5; valueStreamCount++) {
            leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
            valueStreamRecord.Name = 'valueStream Record ' + valueStreamCount;
            valueStreamRecord.leankor__ProjectRoom__c = projectRecord.Id;
            valueStreamRecord.leankor__isRecordDeleted__c = false;
            valueStreamRecord.leankor__BoardType__c = 'UberBoard';
            valueStreamRecord.leankor__ScheduleBackward__c = true;
            valueStreamRecord.leankor__ProjectBoardStartDateTime__c = System.now();
            valueStreamRecord.leankor__ProjectBoardEndDateTime__c = System.now() + 5;
            valueStreamList.add(valueStreamRecord);
        }
        insert valueStreamList;
    
        leankor__ProjectScheduleBaseline__c projectScheduleBaseline = new leankor__ProjectScheduleBaseline__c();
        projectScheduleBaseline.leankor__Title__c = 'title';
        projectScheduleBaseline.leankor__ProjectBoard__c = valueStreamList[0].Id;
        insert projectScheduleBaseline;
    
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        for (leankor__ValueStream__c valueStream : valueStreamList) {
            for (Integer kanbanCardcardCount = 1; kanbanCardcardCount <= 5; kanbanCardcardCount++) {
                leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
                kanbanCardRecord.Name = 'kanbanCardRecord ' + kanbanCardcardCount + ' for ValueStream ' + valueStream.Name;
                kanbanCardRecord.leankor__GUID__c = testDataFactory.createGuid();
                kanbanCardRecord.leankor__ValueStream__c = valueStream.Id;
                kanbanCardRecord.leankor__StartDateTime__c = Date.today();
                kanbanCardRecord.leankor__DueDateTime__c = Date.today().addDays(5);
                kanbanCardRecord.leankor__PercentComplete2__c = 50;
                kanbanCardRecord.leankor__EstimatedDuration__c = 3;
                kanbanCardRecord.leankor__DurationUnits__c = 'Days';
                kanbanCardRecord.leankor__CardId__c = 'CardId';
                kanbanCardRecord.leankor__Priority__c = 1;
                kanbanCardRecord.leankor__DescriptionLong__c = 'Description for Card ';
                kanbanCardRecord.OwnerId = UserInfo.getUserId();
                kanbanCardRecord.leankor__Monday__c = false;
                kanbanCardRecord.leankor__Tuesday__c = false;
                kanbanCardRecord.leankor__Wednesday__c = false;
                kanbanCardRecord.leankor__Thursday__c = false;
                kanbanCardRecord.leankor__Friday__c = false;
                kanbanCardRecord.leankor__Saturday__c = false;
                kanbanCardRecord.leankor__Sunday__c = false;
                kanbanCardList.add(kanbanCardRecord);
            }
        }
        insert kanbanCardList;
    
        List<leankor__KanbanCardBaseline__c> KanbanCardBaselineList = new List<leankor__KanbanCardBaseline__c>();
        for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
            leankor__KanbanCardBaseline__c kanbanCardBaseline = new leankor__KanbanCardBaseline__c();
            kanbanCardBaseline.leankor__ProjectScheduleBaseline__c = projectScheduleBaseline.Id;
            kanbanCardBaseline.leankor__KanbanCard__c = kanbanCard.Id;
            kanbanCardBaseline.leankor__StartDateTime__c = kanbanCard.leankor__StartDateTime__c;
            kanbanCardBaseline.leankor__DueDateTime__c = kanbanCard.leankor__DueDateTime__c;
            kanbanCardBaseline.leankor__DurationUnit__c = kanbanCard.leankor__DurationUnits__c;
            kanbanCardBaseline.leankor__EstimatedDuration__c = kanbanCard.leankor__EstimatedDuration__c;
            KanbanCardBaselineList.add(kanbanCardBaseline);
        }
        insert KanbanCardBaselineList;
    
        List<leankor__ScheduleMode__c> scheduleModeList = new List<leankor__ScheduleMode__c>();
        for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
            for (Integer i = 0; i < 5; i++) {
                leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
                scheduleMode.leankor__KanbanCard__c = kanbanCard.Id;
                scheduleMode.leankor__EffortActual__c = 2;
                scheduleMode.leankor__EffortUnits__c = 'Days';
                scheduleMode.leankor__ManuallyScheduled__c = false;
                scheduleMode.leankor__Mode__c = 'EffortDriven';
                scheduleModeList.add(scheduleMode);
            }
        }
        insert scheduleModeList;

        Test.startTest();
    
        GanttTaskBoard.GanttResourcesSchedulerInfo result = GanttTaskBoard.readAllPlanBoardCards(projectRecord.Id);

        System.assertNotEquals(null, result);
    
        Test.stopTest();
    }
    */
    /*
    @isTest
    static void testReadAllPlanBoardCardsWithoutBaseLine() {
        
        leankor__LeanConstants__c leanConstant = new leankor__LeanConstants__c(leankor__AllowSchedulingConstraints__c = true);
        insert leanConstant;
    
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project Name';
        projectRecord.leankor__ProjectLaunchDateTime__c = System.now() + 5;
        insert projectRecord;
    
        List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
        for (Integer valueStreamCount = 1; valueStreamCount <= 5; valueStreamCount++) {
            leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
            valueStreamRecord.Name = 'valueStream Record ' + valueStreamCount;
            valueStreamRecord.leankor__ProjectRoom__c = projectRecord.Id;
            valueStreamRecord.leankor__isRecordDeleted__c = false;
            valueStreamRecord.leankor__BoardType__c = 'UberBoard';
            valueStreamRecord.leankor__ScheduleBackward__c = true;
            valueStreamRecord.leankor__ProjectBoardStartDateTime__c = System.now();
            valueStreamRecord.leankor__ProjectBoardEndDateTime__c = System.now() + 5;
            valueStreamList.add(valueStreamRecord);
        }
        insert valueStreamList;
    
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        for (leankor__ValueStream__c valueStream : valueStreamList) {
            for (Integer kanbanCardcardCount = 1; kanbanCardcardCount <= 5; kanbanCardcardCount++) {
                leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
                kanbanCardRecord.Name = 'kanbanCardRecord ' + kanbanCardcardCount + ' for ValueStream ' + valueStream.Name;
                kanbanCardRecord.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
                kanbanCardRecord.leankor__GUID__c = testDataFactory.createGuid();
                kanbanCardRecord.leankor__ValueStream__c = valueStream.Id;
                kanbanCardRecord.leankor__StartDateTime__c = Date.today();
                kanbanCardRecord.leankor__DueDateTime__c = Date.today().addDays(5);
                kanbanCardRecord.leankor__PercentComplete2__c = 50;
                kanbanCardRecord.leankor__EstimatedDuration__c = 3;
                kanbanCardRecord.leankor__DurationUnits__c = 'Days';
                kanbanCardRecord.leankor__CardId__c = 'CardId';
                kanbanCardRecord.leankor__Priority__c = 1;
                kanbanCardRecord.leankor__DescriptionLong__c = 'Description for Card ';
                kanbanCardRecord.OwnerId = UserInfo.getUserId();
                kanbanCardRecord.leankor__Monday__c = true;
                kanbanCardRecord.leankor__Tuesday__c = true;
                kanbanCardRecord.leankor__Wednesday__c = true;
                kanbanCardRecord.leankor__Thursday__c = true;
                kanbanCardRecord.leankor__Friday__c = true;
                kanbanCardRecord.leankor__Saturday__c = true;
                kanbanCardRecord.leankor__Sunday__c = true;
                kanbanCardList.add(kanbanCardRecord);
            }
        }
        insert kanbanCardList;
    
        List<leankor__ScheduleMode__c> scheduleModeList = new List<leankor__ScheduleMode__c>();
        for (leankor__KanbanCard__c kannbanCard : kanbanCardList) {
            for (Integer i = 0; i < 5; i++) {
                leankor__ScheduleMode__c  scheduleMode = new leankor__ScheduleMode__c();
                scheduleMode.leankor__KanbanCard__c = kannbanCard.Id;
                scheduleMode.leankor__EffortActual__c = 2;
                scheduleMode.leankor__EffortUnits__c = 'Days';
                scheduleMode.leankor__ManuallyScheduled__c = false;
                scheduleMode.leankor__Mode__c = 'EffortDriven';
                scheduleModeList.add(scheduleMode);
            }
        }
        insert scheduleModeList;

        Test.startTest();

        GanttTaskBoard.GanttResourcesSchedulerInfo result = GanttTaskBoard.readAllPlanBoardCards(projectRecord.Id);
    
        System.assertNotEquals(null, result);
    
        Test.stopTest();
    }
    */
    /*
    @isTest
    static void testReadAllPlanBoardCardsWithoutActivities() {

        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project Name';
        projectRecord.leankor__ProjectLaunchDateTime__c = null;
        insert projectRecord;
    
        List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
        for (Integer valueStreamCount = 1; valueStreamCount <= 5; valueStreamCount++) {
            leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
            valueStreamRecord.Name = 'valueStream Record ' + valueStreamCount;
            valueStreamRecord.leankor__ProjectRoom__c = projectRecord.Id;
            valueStreamRecord.leankor__isRecordDeleted__c = false;
            valueStreamRecord.leankor__BoardType__c = 'UberBoard';
            valueStreamRecord.leankor__ScheduleBackward__c = true;
            valueStreamRecord.leankor__ProjectBoardEndDateTime__c = System.now() + 5;
            valueStreamList.add(valueStreamRecord);
        }
        insert valueStreamList;

        Test.startTest();

        GanttTaskBoard.GanttResourcesSchedulerInfo result = GanttTaskBoard.readAllPlanBoardCards(projectRecord.Id);
    
        System.assertNotEquals(null, result);
    
        Test.stopTest();
    }
    */

    @isTest
    static void readMiniatureDataTest() {
        leankor__projectRoom__c project1 = new leankor__projectRoom__c();
        project1.Name = 'pro1';
        insert project1;
        
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__BoardType__c = 'Plan Board';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
        leankor__valueStream__c valueStream2= new leankor__valueStream__c();
        valueStream2.Name = 'vs2';
        valueStream2.leankor__ProjectRoom__c = project1.Id;
        valueStream2.leankor__isRecordDeleted__c = false;
        valueStream2.leankor__IsTemplateBoard__c = false;
        valueStream2.leankor__BoardType__c = 'Plan Board';
        insert valueStream2;
            
		leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
        masterContainer1.Name = 'ms1';
        masterContainer1.leankor__valueStream__c = valueStream1.Id;
        masterContainer1.leankor__Type__c = 'template1';
        insert masterContainer1;
        
        leankor__KanbanCard__c kanbanCard1 = new leankor__kanbanCard__c();
        kanbanCard1.Name = 'kanbanCard1';
        kanbanCard1.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard1.leankor__isRecordDeleted__c = false;
        kanbanCard1.leankor__GUID__c = System.today() + 'kanbanCard1';
        insert kanbanCard1;
        
        leankor__KanbanCard__c kanbanCard2 = new leankor__kanbanCard__c();
        kanbanCard2.Name = 'kanbanCard2';
        kanbanCard2.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard2.leankor__isRecordDeleted__c = false;
        kanbanCard2.leankor__GUID__c = System.today() + 'kanbanCard2';
        insert kanbanCard2;

        leankor__KanbanCard__c kanbanCard3 = new leankor__kanbanCard__c();
        kanbanCard3.Name = 'kanbanCard3';
        kanbanCard3.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard3.leankor__ValueStreamCardLink__c = kanbanCard1.Id;
        kanbanCard3.leankor__isRecordDeleted__c = false;
        kanbanCard3.leankor__GUID__c = System.today() + 'kanbanCard3';
        insert kanbanCard3;
        
        leankor__KanbanCard__c kanbanCard4 = new leankor__kanbanCard__c();
        kanbanCard4.Name = 'kanbanCard4';
        kanbanCard4.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard4.leankor__ValueStreamCardLink__c = kanbanCard2.Id;
        kanbanCard4.leankor__isRecordDeleted__c = false;
        kanbanCard4.leankor__GUID__c = System.today() + 'kanbanCard4';
        insert kanbanCard4;

        Test.startTest();
        List<leankor.GanttTaskBoard.Miniature> result = GanttTaskBoard.readMiniatureData(new Set<String>{kanbanCard1.Id, kanbanCard2.Id});
        Test.stopTest();

        System.assert(result != null);
    }
    
    @isTest
    static void getPortfolioHierarchyExpandedTest() {
        leankor__portfolio__c portfolio1 = new leankor__portfolio__c();
        portfolio1.Name = 'port1';
        insert portfolio1;
        
        leankor__projectRoom__c project1 = new leankor__projectRoom__c();
        project1.Name = 'pro1';
        project1.leankor__Portfolio__c = portfolio1.Id;
        insert project1;
        
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__ProjectRoom__c = project1.Id;
        valueStream1.leankor__BoardType__c = 'UberBoard';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
		leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
        masterContainer1.Name = 'ms1';
        masterContainer1.leankor__valueStream__c = valueStream1.Id;
        masterContainer1.leankor__Type__c = 'template1';
        insert masterContainer1;
        
        leankor__KanbanCard__c kanbanCard1 = new leankor__kanbanCard__c();
        kanbanCard1.Name = 'kanbanCard1';
        kanbanCard1.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard1.leankor__isRecordDeleted__c = false;
        kanbanCard1.RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        kanbanCard1.leankor__GUID__c = System.today() + 'kanbanCard1';
        insert kanbanCard1;
        
        leankor__Module__c module = new leankor__Module__c();
        module.Name ='Plan (Gantt)';
        module.leankor__BoardType__c = '_System_UberBoard';
        insert module;
        
        leankor__ProjectLaunchBehavior__c ProjectLaunch = new leankor__ProjectLaunchBehavior__c();       
		ProjectLaunch.leankor__Module__c = module.ID;
		ProjectLaunch.leankor__OneClicklaunch__c = true;
		ProjectLaunch.leankor__OpenNewTab__c = true;
		ProjectLaunch.leankor__Project__c = project1.Id;
		insert ProjectLaunch;
        
        Test.startTest();
        leankor.GanttTaskBoard.GetPortfolioresource result = GanttTaskBoard.getPortfolioHierarchyExpanded((String)portfolio1.Id);
        Test.stopTest();

        System.assert(result.DataLog.Foldername==portfolio1.Name);
    }
    
    @isTest
    static void childcardsTest() {
        Test.startTest();
        List<leankor.KanbanToGanttController.MasterContainer> result = GanttTaskBoard.childcards(new List<leankor__kanbanCard__c>(), new Map<Id, RecordType>());
        Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getFilterRecordForMUltipleBoardTest1() {
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__BoardType__c = 'UberBoard';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
        Test.startTest();
        Map<Id, GanttTaskBoard.FilterRecordForMUltipleBoard> result = GanttTaskBoard.getFilterRecordForMUltipleBoard(valueStream1.Id, true);
        Test.stopTest();

        System.assert(result.get(valueStream1.Id).Name=='valueStream1');
    }
    
    @isTest
    static void getFilterRecordForMUltipleBoardTest2() {
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__BoardType__c = 'UberBoard';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
        Test.startTest();
        Map<Id, GanttTaskBoard.FilterRecordForMUltipleBoard> result = GanttTaskBoard.getFilterRecordForMUltipleBoard(valueStream1.Id, false);
        Test.stopTest();

        System.assert(result.get(valueStream1.Id).Name==null);
    }
    
    @isTest
    static void getAllDependentCardIdsTest() {
        leankor__KanbanCard__c predecessor = new leankor__KanbanCard__c();
        predecessor.Name = 'Predecessor Card';
        predecessor.leankor__GUID__c = 'helo1';
        
        leankor__KanbanCard__c successor = new leankor__KanbanCard__c();
        successor.Name = 'Successor Card';
        successor.leankor__GUID__c = 'helo2';
        
        leankor__KanbanCard__c linkedCard = new leankor__KanbanCard__c();
        linkedCard.Name = 'Linked Card';
        linkedCard.leankor__GUID__c = 'hel21';
        
        insert new List<leankor__KanbanCard__c>{predecessor, successor, linkedCard};

        successor.leankor__ValueStreamCardLink__c = linkedCard.Id;
        update successor;

        leankor__Dependency__c dep = new leankor__Dependency__c();
        dep.leankor__Predecessor__c = predecessor.Id;
        dep.leankor__Successor__c = successor.Id;
        insert dep;

        List<leankor__Dependency__c> dependencies = [Select Id, 
                                                     			leankor__Predecessor__c, 
                                                     			leankor__Successor__c, 
                                                     			leankor__Successor__r.leankor__ValueStreamCardLink__c 
                                                     		From leankor__Dependency__c];
        
        Set<Id> kanbanCardIds = new Set<Id>{predecessor.Id};

        Map<Id, leankor__KanbanCard__c> kanbanCardMap = new Map<Id, leankor__KanbanCard__c>(
            [Select Id 
             	From leankor__KanbanCard__c
             	Where Id IN :kanbanCardIds]
        );
        
        Set<Id> kanbanCardGroupIds = new Set<Id>();

        Test.startTest();
        Set<Id> result = GanttTaskBoard.getAllDependentCardIds(dependencies, kanbanCardIds, kanbanCardMap, kanbanCardGroupIds);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should contain one dependent card');
        System.assert(result.contains(successor.Id), 'Result should contain successor card Id');
        System.assert(kanbanCardGroupIds.contains(successor.Id), 'GroupIds should contain successor');
        System.assert(kanbanCardGroupIds.contains(linkedCard.Id), 'GroupIds should contain linked card Id');
    }

    @isTest
    static void getChatterCommentsTest() {
        leankor__KanbanCard__c kanbanCard1 = new leankor__kanbanCard__c();
        kanbanCard1.Name = 'kanbanCard1';
        kanbanCard1.leankor__isRecordDeleted__c = false;
        kanbanCard1.leankor__GUID__c = System.today() + 'kanbanCard1';
        insert kanbanCard1;
        
        leankor__KanbanCard__c kanbanCard2 = new leankor__kanbanCard__c();
        kanbanCard2.Name = 'kanbanCard2';
        kanbanCard2.leankor__isRecordDeleted__c = false;
        kanbanCard2.leankor__GUID__c = System.today() + 'kanbanCard2';
        insert kanbanCard2;

        List<String> records = new List<String>{kanbanCard1.Id, kanbanCard2.Id};
        GanttTaskBoard.ChatterDataRecord data = new GanttTaskBoard.ChatterDataRecord();
        data.recordIds = records;

        Test.startTest();
        GanttTaskBoard.ChatterDataResponse result = GanttTaskBoard.getChatterComments(data);
        Test.stopTest();

        System.assert(result.valueStreamIds==null);
    }
    
    @isTest
    static void updateKanbanCardsTest1() {
        
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__BoardType__c = 'Plan Board';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
        leankor__valueStream__c valueStream2 = new leankor__valueStream__c();
        valueStream2.Name = 'valueStream2';
        valueStream2.leankor__isRecordDeleted__c = false;
        valueStream2.leankor__IsTemplateBoard__c = false;
        valueStream2.leankor__BoardType__c = 'Plan Board';
        insert valueStream2;
        
        leankor__KanbanCard__c kanbanCard1 = new leankor__kanbanCard__c();
        kanbanCard1.Name = 'kanbanCard1';
        kanbanCard1.leankor__IsOnHold__c = true;
        kanbanCard1.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard1.leankor__isRecordDeleted__c = false;
        kanbanCard1.leankor__GUID__c = System.today() + 'kanbanCard1';
        insert kanbanCard1;
        
        leankor__KanbanCard__c kanbanCard2 = new leankor__kanbanCard__c();
        kanbanCard2.Name = 'kanbanCard2';
        kanbanCard2.leankor__IsOnHold__c = true;
        kanbanCard2.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard2.leankor__isRecordDeleted__c = false;
        kanbanCard2.leankor__GUID__c = System.today() + 'kanbanCard2';
        insert kanbanCard2;

        leankor__KanbanCard__c kanbanCard3 = new leankor__kanbanCard__c();
        kanbanCard3.Name = 'kanbanCard3';
        kanbanCard3.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard3.leankor__ValueStreamCardLink__c = kanbanCard1.Id;
        kanbanCard3.leankor__isRecordDeleted__c = false;
        kanbanCard3.leankor__GUID__c = System.today() + 'kanbanCard3';
        insert kanbanCard3;
        
        leankor__KanbanCard__c kanbanCard4 = new leankor__kanbanCard__c();
        kanbanCard4.Name = 'kanbanCard4';
        kanbanCard4.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard4.leankor__ValueStreamCardLink__c = kanbanCard2.Id;
        kanbanCard4.leankor__isRecordDeleted__c = false;
        kanbanCard4.leankor__GUID__c = System.today() + 'kanbanCard4';
        insert kanbanCard4;
        

        GanttTaskBoard.ActivityWrapper activityWrapper = new GanttTaskBoard.ActivityWrapper();
        activityWrapper.activity = new List<leankor__KanbanCard__c>{kanbanCard1, kanbanCard2};
        activityWrapper.boardType = 'UberBoard';
        
        Test.startTest();
        String result = GanttTaskBoard.updateKanbanCards(activityWrapper);
        Test.stopTest();

		List<String> deserializedList = (List<String>) JSON.deserialize(result, List<String>.class);

        System.assert(deserializedList[0]==kanbanCard1.Id);
    }
    
    @isTest
    static void updateKanbanCardsTest2() {
        
        leankor__valueStream__c valueStream1 = new leankor__valueStream__c();
        valueStream1.Name = 'valueStream1';
        valueStream1.leankor__isRecordDeleted__c = false;
        valueStream1.leankor__BoardType__c = 'Plan Board';
        valueStream1.leankor__IsTemplateBoard__c = false;
        insert valueStream1;
        
        leankor__valueStream__c valueStream2 = new leankor__valueStream__c();
        valueStream2.Name = 'valueStream2';
        valueStream2.leankor__isRecordDeleted__c = false;
        valueStream2.leankor__IsTemplateBoard__c = false;
        valueStream2.leankor__BoardType__c = 'Plan Board';
        insert valueStream2;
        
        leankor__KanbanCard__c kanbanCard1 = new leankor__kanbanCard__c();
        kanbanCard1.Name = 'kanbanCard1';
        kanbanCard1.leankor__IsOnHold__c = true;
        kanbanCard1.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard1.leankor__isRecordDeleted__c = false;
        kanbanCard1.leankor__GUID__c = System.today() + 'kanbanCard1';
        insert kanbanCard1;
        
        leankor__KanbanCard__c kanbanCard2 = new leankor__kanbanCard__c();
        kanbanCard2.Name = 'kanbanCard2';
        kanbanCard2.leankor__IsOnHold__c = true;
        kanbanCard2.leankor__ValueStream__c = valueStream1.Id;
        kanbanCard2.leankor__isRecordDeleted__c = false;
        kanbanCard2.leankor__GUID__c = System.today() + 'kanbanCard2';
        insert kanbanCard2;

        leankor__KanbanCard__c kanbanCard3 = new leankor__kanbanCard__c();
        kanbanCard3.Name = 'kanbanCard3';
        kanbanCard3.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard3.leankor__ValueStreamCardLink__c = kanbanCard1.Id;
        kanbanCard3.leankor__isRecordDeleted__c = false;
        kanbanCard3.leankor__GUID__c = System.today() + 'kanbanCard3';
        insert kanbanCard3;
        
        leankor__KanbanCard__c kanbanCard4 = new leankor__kanbanCard__c();
        kanbanCard4.Name = 'kanbanCard4';
        kanbanCard4.leankor__ValueStream__c = valueStream2.Id;
        kanbanCard4.leankor__ValueStreamCardLink__c = kanbanCard2.Id;
        kanbanCard4.leankor__isRecordDeleted__c = false;
        kanbanCard4.leankor__GUID__c = System.today() + 'kanbanCard4';
        insert kanbanCard4;
        

        GanttTaskBoard.ActivityWrapper activityWrapper = new GanttTaskBoard.ActivityWrapper();
        activityWrapper.activity = new List<leankor__KanbanCard__c>{kanbanCard1, kanbanCard2};
        activityWrapper.boardType = 'Kanban Board';
        
        Test.startTest();
        String result = GanttTaskBoard.updateKanbanCards(activityWrapper);
        Test.stopTest();

		List<String> deserializedList = (List<String>) JSON.deserialize(result, List<String>.class);

        System.assert(deserializedList[0]==kanbanCard1.Id);
    }
    
    @isTest
    static void readResourceTypeTest() {
        List<leankor__ResourceType__c>  resourceTypeList =new List<leankor__ResourceType__c>();
    	for (Integer i = 0; i < 5; i++) {
    		leankor__ResourceType__c  resourceType =new  leankor__ResourceType__c();
    		resourceType.Name = 'IT' + i;
    		resourceType.leankor__InternalHourlyRate__c = 50;
    		resourceType.leankor__ExternalHourlyRate__c = 60;   		    			
    		resourceTypeList.add(resourceType);
    	}    	
    	insert resourceTypeList;

        Test.startTest();
        GanttTaskBoard.RecordDetails result = GanttTaskBoard.readResourceTypes(2, 'T', 2);
        Test.stopTest();
        
        System.assert(result.Count==5);
        
    }
    
    @isTest
    static void getResourceAssignmentBulkfiedTest() {
        leankor__KanbanCard__c kanbanCard = new leankor__kanbanCard__c();
        kanbanCard.Name = 'kanbanCard';
        kanbanCard.leankor__isRecordDeleted__c = false;
        kanbanCard.leankor__GUID__c = System.today() + 'kc1';
        insert kanbanCard;

		leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
		testResourceAssignment.leankor__KanbanCard__c = kanbanCard.Id;
		testResourceAssignment.leankor__PercentAllocation__c = 1;
		testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
		testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
		testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
		testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
		testResourceAssignment.leankor__InternalHourlyRate__c = 1;
		testResourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
		insert testResourceAssignment;
        
        Test.startTest();
        Map<String, List<leankor__ResourceAssignment__c>> result = GanttTaskBoard.getResourceAssignmentBulkfied(kanbanCard.Id);
        Test.stopTest();

        System.assert(result.get(kanbanCard.Id)[0].Id==testResourceAssignment.Id);
    }
    
    @isTest
    static void getAllScheduleModesTest() {
        leankor__valueStream__c valueStream = new leankor__valueStream__c();
        valueStream.Name = 'vs';
        insert valueStream;
        
        leankor__kanbanCard__c kanbanCard = new leankor__kanbanCard__c();
        kanbanCard.Name = 'kc';
        kanbanCard.leankor__GUID__c = 'kc1144';
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        insert kanbanCard;
        
        List<leankor__kanbanCard__c> kanbanCardsList = new List<leankor__kanbanCard__c>();
        for (Integer i = 0; i < 10; i++) {
            leankor__kanbanCard__c kanban = new leankor__kanbanCard__c();
            kanban.Name = 'kc' + i;
            kanban.leankor__GUID__c = 'kc1' + i;
            kanban.leankor__ValueStream__c = valueStream.Id;
            kanban.leankor__ValuestreamCardLink__c = kanbanCard.Id;
            kanbanCardsList.add(kanban);
        }
        insert kanbanCardsList;
        
        leankor__ScheduleConstraint__c mustStartOn = new leankor__ScheduleConstraint__c();
        mustStartOn.leankor__Description__c = 'muststarton';
        mustStartOn.leankor__Type__c = 'muststarton';
        insert mustStartOn;
        
        List<leankor__ScheduleMode__c> scheduleModeList = new List<leankor__ScheduleMode__c>();
        for (leankor__KanbanCard__c kanban : kanbanCardsList) {
            leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
            scheduleMode.leankor__KanbanCard__c = kanban.Id;
            scheduleMode.leankor__ScheduleConstraint__c = mustStartOn.Id;
            scheduleMode.leankor__ConstraintDateTime__c = kanban.leankor__StartDateTime__c;
            scheduleModeList.add(scheduleMode);
        }
        insert scheduleModeList;
        
        Test.startTest();
        Map<Id, GanttTaskBoard.ScheduleMode> result = GanttTaskBoard.getAllScheduleModes(new List<String>{valueStream.Id});
        Test.stopTest();

        System.assert(result.get(kanbanCardsList[0].Id).SchedulingModeId==scheduleModeList[0].Id);
    }
    
    @isTest
    static void getAllCardsTest() {
        leankor__valueStream__c valueStream = new leankor__valueStream__c();
        valueStream.Name = 'valueStream';
        insert valueStream;
        
        List<leankor__kanbanCard__c> kanbanCardsList = new List<leankor__kanbanCard__c>();
        for (Integer i = 0; i < 10; i++) {
            leankor__kanbanCard__c kanbanCard = new leankor__kanbanCard__c();
            kanbanCard.Name = 'kc' + i;
            kanbanCard.leankor__GUID__c = 'kc1' + i;
            kanbanCard.leankor__ValueStream__c = valueStream.Id;
            kanbanCardsList.add(kanbanCard);
        }
        insert kanbanCardsList;
        
        Test.startTest();
        List<leankor__kanbanCard__c> result = GanttTaskBoard.getAllCards(new Set<Id>{valueStream.Id});
        Test.stopTest();

        System.assert(result[0].Id==kanbanCardsList[0].Id);
    }
    
    @isTest
    static void getAllCardsWithBaseline() {
        leankor__valueStream__c valueStream = new leankor__valueStream__c();
        valueStream.Name = 'valueStream';
        insert valueStream;
        
        List<leankor__kanbanCard__c> kanbanCardsList = new List<leankor__kanbanCard__c>();
        for (Integer i = 0; i < 10; i++) {
            leankor__kanbanCard__c kanban = new leankor__kanbanCard__c();
            kanban.Name = 'kc' + i;
            kanban.leankor__GUID__c = 'kc1' + i;
            kanban.leankor__ValueStream__c = valueStream.Id;
            kanbanCardsList.add(kanban);
        }
        insert kanbanCardsList;
        
        list<leankor__KanbanCardBaseline__c> kanbanCardBaselineList = new list<leankor__KanbanCardBaseline__c>();
        for (leankor__KanbanCard__c kanban : kanbanCardsList) { 
			leankor__KanbanCardBaseline__c kanbanCardBaseline = new leankor__KanbanCardBaseline__c();
			kanbanCardBaseline.leankor__KanbanCard__c = kanban.Id;
			kanbanCardBaseline.leankor__StartDateTime__c = kanban.leankor__StartDateTime__c;
			kanbanCardBaseline.leankor__DueDateTime__c = kanban.leankor__DueDateTime__c;
		    kanbanCardBaseline.leankor__DurationUnit__c = kanban.leankor__DurationUnits__c ;
			kanbanCardBaseline.leankor__EstimatedDuration__c =  kanban.leankor__EstimatedDuration__c;
			kanbanCardBaselineList.add(kanbanCardBaseline);	
		}
        insert kanbanCardBaselineList;
        
        Test.startTest();
        List<leankor__kanbanCard__c> result = GanttTaskBoard.getAllCardsWithBaseline(kanbanCardBaselineList[0].Id, new Set<Id>{valueStream.Id});
        Test.stopTest();

        System.assert(result[0].Id==kanbanCardsList[0].Id);
    }
    
    @isTest
    static void getUserDataTest() {
        Profile profile = [Select Id 
                     	From Profile 
                     	Where Name='Standard User'];
        
        User user1 = new User();
        user1.Alias = 'leankor1';
        user1.Email='leankor1@leankor.com';
		user1.EmailEncodingKey='UTF-8';
        user1.LastName='Leankor1';
        user1.LanguageLocaleKey='en_US';
        user1.LocaleSidKey='en_US';
        user1.ProfileId = profile.Id;
        user1.TimeZoneSidKey='America/Los_Angeles';
        user1.UserName='leankor1@leankor.com';
        insert user1;
        
        Test.startTest();
        List<GanttTaskBoard.UserData> result = GanttTaskBoard.getUserdata(new Set<Id>{user1.Id});
        Test.stopTest();

        System.assert(result[0].Id==UserInfo.getUserId());
    }
    
    @isTest
    static void readStickersOldTest() {
        Test.startTest();
        List<leankor__Sticker__c> result = GanttTaskBoard.readStickersOld(null, new List<String>());
        Test.stopTest();

        System.assert(result.size()==0);
    }
    
    @isTest
    static void readStickersTest() {
        Test.startTest();
        List<leankor__Sticker__c> result = GanttTaskBoard.readStickers(null, new List<String>());
        Test.stopTest();

        System.assert(result.size()==0);
    }
    
    @isTest
    static void readAllPlanBoardCardsTest() {
        Test.startTest();
        GanttTaskBoard.GanttResourcesSchedulerInfo result = GanttTaskBoard.readAllPlanBoardCards(null);
        Test.stopTest();

        System.assert(result.ActivityRecords==null);
    }
    
    @isTest
    static void childcardsRecursiveTest() {
        Test.startTest();
        List<leankor.KanbanToGanttController.MasterContainer> result = GanttTaskBoard.childcardsRecursive(null, null, null);
        Test.stopTest();

        System.assert(result.size()==0);
    }
    
    @isTest
    static void getMiniatureVSTest() {
        Test.startTest();
        Set<String> result = GanttTaskBoard.getMiniatureVS(null);
        Test.stopTest();

        System.assert(result.size()==0);
    }
    
    @isTest
    static void standardControllerConstructorTest() {
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c();
        project.Name = 'Test Project';
        insert project;

        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(project);
        GanttTaskBoard board = new GanttTaskBoard(stdController);
        Test.stopTest();

        System.assertNotEquals(null, board, 'GanttTaskBoard should be initialized with StandardController');
    }

    @isTest
    static void utilConstructorTest() {
        Test.startTest();
        Util mockUtil = new Util();
        GanttTaskBoard board = new GanttTaskBoard(mockUtil);
        Test.stopTest();

        System.assertNotEquals(null, board, 'GanttTaskBoard should be initialized with Util');
    }

    @isTest
    static void noArgConstructorTest() {
        Test.startTest();
        GanttTaskBoard board = new GanttTaskBoard();
        Test.stopTest();

        System.assertNotEquals(null, board, 'GanttTaskBoard should be initialized with no-arg constructor');
    }
 	
    @isTest
    static void getResourceTest() {
        List<leankor__ResourceType__c>  resourceTypeList = new List<leankor__ResourceType__c>();

        for (Integer i = 0; i < 5; i++) {
            leankor__ResourceType__c  resourceType = new leankor__ResourceType__c();
            resourceType.Name = 'IT' + i;
            resourceType.leankor__InternalHourlyRate__c = 50;
            resourceType.leankor__ExternalHourlyRate__c = 60;   		    			
            resourceTypeList.add(resourceType);
        }    	
        insert resourceTypeList; 
        
        List<leankor__kanbanCard__c> kanbanCardList = new List<leankor__kanbanCard__c>();
        for (Integer i = 0; i < 5; i++) {
            leankor__KanbanCard__c testRecord = new leankor__KanbanCard__c();
            testRecord.Name = 'Hello World' + i;
            testRecord.leankor__GUID__c = 'test' + i;
            kanbanCardList.add(testRecord);
        }
		insert kanbanCardList;
        
		List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for (Integer i = 0; i < 5; i++) {
            leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
            testResourceAssignment.leankor__KanbanCard__c = kanbanCardList[i].Id;
            testResourceAssignment.leankor__PercentAllocation__c = 1;
            testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
            testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
            testResourceAssignment.leankor__InternalHourlyRate__c = 1;
            testResourceAssignment.leankor__ResourceType__c = resourceTypeList[i].Id;
            testResourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignmentList.add(testResourceAssignment);
        }
		insert resourceAssignmentList;

		Set<String> activityIds = new Set<String>();

        for (leankor__kanbanCard__c kanban : kanbanCardList) {
            activityIds.add(kanban.Id);
        }

        Test.startTest();
        List<leankor.GanttTaskBoard.ResourceAssignment> result = GanttTaskBoard.getResources(activityIds);
        Test.stopTest();

        System.assert(result.size()==5);
    }
    
    @isTest
    static void getResourceAssignmentBulkifyTest() {
        List<leankor__ResourceType__c>  resourceTypeList = new List<leankor__ResourceType__c>();

        for (Integer i = 0; i < 5; i++) {
            leankor__ResourceType__c  resourceType = new  leankor__ResourceType__c();
            resourceType.Name='IT' + i;
            resourceType.leankor__InternalHourlyRate__c = 50;
            resourceType.leankor__ExternalHourlyRate__c = 60;   		    			
            resourceTypeList.add(resourceType);
        }    	
        insert resourceTypeList; 
        
        List<leankor__kanbanCard__c> kanbanCardList = new List<leankor__kanbanCard__c>();
        for (Integer i = 0; i < 5; i++) {
            leankor__KanbanCard__c KanbanCard = new leankor__KanbanCard__c();
            KanbanCard.Name = 'Hello World' + i;
            KanbanCard.leankor__GUID__c = 'test' + i;
            kanbanCardList.add(KanbanCard);
        }
		insert kanbanCardList;
        
		List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();

        for (Integer i = 0; i < 5; i++) {
            leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
            testResourceAssignment.leankor__KanbanCard__c = kanbanCardList[i].Id;
            testResourceAssignment.leankor__PercentAllocation__c = 1;
            testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
            testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
            testResourceAssignment.leankor__InternalHourlyRate__c = 1;
            testResourceAssignment.leankor__ResourceType__c = resourceTypeList[i].Id;
            testResourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignmentList.add(testResourceAssignment);
        }
		insert resourceAssignmentList;
        
		List<String> activityIds = new List<String>();

        for (leankor__kanbanCard__c kanban : kanbanCardList) {
            activityIds.add(kanban.Id);
        }
        
        Test.startTest();
        List<GanttTaskBoard.ResourceAssignment> result = GanttTaskBoard.getResourceAssignmentBulkify(activityIds);
        Test.stopTest();

        System.assert(result.size()==5);
    }
    
    @isTest
    static void getMiniatureValueStreamTest() {
        Test.startTest();
        Set<String> result = GanttTaskBoard.getMiniatureValueStream(null);
        Test.stopTest();

        System.assert(result.size()==0);
    }
    
    @isTest
    static void getProjectsTest() {
        Test.startTest();
        Set<leankor.ProjectBoardCarousel.PortfolioHierarchy> result = GanttTaskBoard.getProjects();
        Test.stopTest();

        System.assert(result!=null);
    }
    
    @isTest
    static void getCustomerLogoTest() {
        // Folder data is not insertable;
        /*Folder folder = new Folder(
            Name = 'VisualLean_CoreDocs',
            DeveloperName = 'VisualLean_CoreDocs',
            AccessType = 'Public',
            Type = 'Document'
        );
        insert folder;
        
        Document doc = new Document(
            Name = 'Test Logo',
            DeveloperName = 'PlanGanttPrintLogo',
            Body = Blob.valueOf('TestLogoContent'),
            ContentType = 'image/png',
            Type = 'png'
        );
        insert doc;
*/
        Test.startTest();
        Document result = GanttTaskBoard.getCustomerLogo();
        Test.stopTest();

        System.assert(result.Name == null);
        
    }
        
}