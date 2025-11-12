@isTest
global class TestPlanGanttController {

    @TestSetup
    static void setupTestData() {
        leankor__Portfolio__c folder = new leankor__Portfolio__c(Name = 'TestFolder');
        insert folder;

        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'TestProject', leankor__ProjectLaunchDateTime__c = System.now() + 5, leankor__Portfolio__c = folder.Id);
        insert project;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'TestBoard', leankor__ProjectRoom__c = project.Id, leankor__BoardType__c = 'plan Board', leankor__IsTemplateBoard__c = false, leankor__SevenDayWorkWeek__c = true, leankor__isRecordDeleted__c = false);
        insert valueStream;

        leankor__LeanConstants__c leanConstant = new leankor__LeanConstants__c(leankor__AllowSchedulingConstraints__c = true);
        insert leanConstant;

        leankor__mastercontainer__c newMC = new leankor__mastercontainer__c();
        newMC.name = 'Test MC';
        newMC.leankor__Valuestream__c = valueStream.Id;
        newMC.leankor__Type__c = 'Backlog';
        insert newMC;
        
        leankor__KanbanCard__c kanbanRecord = new leankor__KanbanCard__c();
        kanbanRecord.leankor__ValueStream__c = valueStream.Id;
        kanbanRecord.Name = 'Test C1';
        kanbanRecord.leankor__Title__c = 'Test Card';
        kanbanRecord.leankor__MasterContainer__c = newMC.Id;
        kanbanRecord.leankor__EstimatedDuration__c = 100;
        kanbanRecord.leankor__DurationUnits__c = 'Days';
        kanbanRecord.leankor__StartDateTime__c = System.now();
        kanbanRecord.OwnerId = UserInfo.getUserId();
        insert kanbanRecord;

        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        for (Integer kanbanCardCount = 1; kanbanCardCount <= 10; kanbanCardCount++) {
            leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c(
                Name = 'kanbanCardRecord ' + kanbanCardCount + ' for ValueStream ' + valueStream.Name,
                RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId(),
                leankor__GUID__c = testDataFactory.createGuid(),
                leankor__ValueStream__c = valueStream.Id,
                leankor__StartDateTime__c = Date.today(),
                leankor__DueDateTime__c = Date.today().addDays(5),
                leankor__PercentComplete2__c = 50,
                leankor__EstimatedDuration__c = 3,
                leankor__DurationUnits__c = 'Days',
                leankor__CardId__c = 'CardId',
                leankor__Priority__c = 1,
                leankor__DescriptionLong__c = 'Description for Card ',
                leankor__ValueStreamCardLink__c = kanbanRecord.Id,
                OwnerId = UserInfo.getUserId(),
                leankor__Monday__c = false,
                leankor__Tuesday__c = false,
                leankor__Wednesday__c = false,
                leankor__Thursday__c = false,
                leankor__Friday__c = false,
                leankor__Saturday__c = false,
                leankor__Sunday__c = false
            );
            kanbanCardList.add(kanbanCardRecord);
        }
        insert kanbanCardList;
        
		User user = leankor.TestDataFactory.createStandardUser('Lean123');
        user.ManagerId = UserInfo.getUserID();
        update user;

        leankor__ScheduleConstraint__c scheduleConstraint = new leankor__ScheduleConstraint__c();
        scheduleConstraint.leankor__Description__c = 'mustfinishon';
        scheduleConstraint.leankor__Type__c = 'mustfinishon';
        insert scheduleConstraint;
        
        List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();
        for (leankor__KanbanCard__c kanbancard : kanbanCardList) {
            leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c(
                leankor__KanbanCard__c = kanbancard.Id,
                leankor__EffortActual__c = 2,
                leankor__EffortUnits__c = 'Days',
                leankor__ManuallyScheduled__c = false,
                leankor__ScheduleConstraint__c = scheduleConstraint.Id,
                leankor__ConstraintDateTime__c = Date.today().addDays(5),
                leankor__Mode__c = 'EffortDriven'
            );
            scheduleModes.add(scheduleMode);
        }
        insert scheduleModes;
    }

    @isTest
    private static void readAllPlanBoardCardsTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];
        leankor__ProjectScheduleBaseline__c projectScheduleBaseLine = new leankor__ProjectScheduleBaseline__c(
            leankor__Title__c = 'title',
            leankor__ProjectBoard__c = valueStream.Id
        );
        insert projectScheduleBaseLine;

        Test.startTest();
        PlanGanttController.GanttResourcesSchedulerInfo result = PlanGanttController.readAllPlanBoardCards(valueStream.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    private static void readAllPlanBoardCardsWithoutBaseLineDataTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];
     
        Test.startTest();
        PlanGanttController.GanttResourcesSchedulerInfo result = PlanGanttController.readAllPlanBoardCards(valueStream.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }
   
    @isTest
    private static void readPlanGanttAssociatedDataTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        Test.startTest();
        PlanGanttController.MiniatureandResource result = PlanGanttController.readPlanGanttAssociatedData(valueStream.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    private static void readScheduleModeAndDescriptionDataTest() {
        leankor__ValueStream__c valueStream = [Select Id 
                                                From leankor__ValueStream__c 
                                                Limit 1];

        Test.startTest();
        Map<Id, leankor.PlanGanttController.DescriptionScheduleData> result = PlanGanttController.readScheduleModeAndDescriptionData(valueStream.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest
    private static void getResourcesTest() {
        List<leankor__KanbanCard__c> kanbanCardList = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Limit 1];
        Set<String> kanbanCardIds = new Set<String>();
        
        for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
            kanbanCardIds.add(kanbanCard.Id);
        }
        
        leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c(
            leankor__KanbanCard__c = kanbanCardList[0].Id,
            leankor__PercentAllocation__c = 1,
            leankor__ExpenseCategory__c = 'Labor',
            leankor__ExpenseSubCategory__c = 'Internal Employee',
            leankor__ExpenseAccount__c = 'Engineers',
            leankor__ExternalHourlyRate__c = 1,
            leankor__InternalHourlyRate__c = 1,
            leankor__AssignedTo__c = UserInfo.getUserId()
        );
        insert testResourceAssignment;

        Test.startTest();
        List<leankor.PlanGanttController.ResourceAssignment> resources = leankor.PlanGanttController.getResources(kanbanCardIds);
        Test.stopTest();

         System.assertNotEquals(null, resources, 'Resources should not be null');
        System.assertEquals(1, resources.size(), 'Resources size should be 1');
    }

    @isTest
    private static void getResourcesWithResourceType() {
       List<leankor__KanbanCard__c> kanbanCardList = [Select Id 
                                                        From leankor__KanbanCard__c 
                                                        Limit 1];
        Set<String> kanbanCardIds = new Set<String>();

        for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
            kanbanCardIds.add(kanbanCard.Id);
        }

        leankor__ResourceType__c resourceType = new leankor__ResourceType__c();
        resourceType.Name = 'IT';
        resourceType.leankor__InternalHourlyRate__c = 50;
        resourceType.leankor__ExternalHourlyRate__c = 60;  
        insert resourceType;
        
        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
        resourceAssignment.leankor__KanbanCard__c = kanbanCardList[0].Id;
        resourceAssignment.leankor__ResourceType__c = resourceType.Id;
        resourceAssignment.leankor__PercentCompleted__c = 50;
        resourceAssignment.leankor__PercentAllocation__c = 60;
        insert resourceAssignment;

        Test.startTest();
        List<leankor.PlanGanttController.ResourceAssignment> resources = leankor.PlanGanttController.getResources(kanbanCardIds);
        Test.stopTest();
         System.assertNotEquals(0, resources.size(), 'Resources list should be empty');  
    }

    @isTest
    private static void getResourcesTestWithoutActivity() {
        Set<String> kanbanCardIds = new Set<String>();

        Test.startTest();
        List<leankor.PlanGanttController.ResourceAssignment> resources = leankor.PlanGanttController.getResources(kanbanCardIds);
        Test.stopTest();

        System.assertEquals(0, resources.size(), 'Resources list should be empty');   
    }

    @isTest
    private static void getUserTest() {
        Set<String> userIdSet = new Set<String>();
        for (User user : [Select Id From User]) {
            userIdSet.add(user.Id);
        }

        Test.startTest();
        List<leankor.PlanGanttController.UserData> users = leankor.PlanGanttController.getUserdata(new List<String>(userIdSet));
        Test.stopTest();
         System.assertNotEquals(null, users, 'Users should not be null');
        System.assertNotEquals(0, users.size(), 'Users size should not be zero');
    }

    @isTest
    private static void hasSeventyPercentDueDateTest() {
        leankor__kanbanCard__c kanbanCard = [Select Id, Name, leankor__StartDateTime__c, leankor__DueDateTime__c From leankor__kanbanCard__c Limit 1];
        Integer firstDayOfWeek = 1;
        Util.WorkWeek workWeekObj = new Util.WorkWeek(firstDayOfWeek, 5);

        Test.startTest();
        Boolean result = PlanGanttController.hasSeventyPercentDueDate(kanbanCard, workWeekObj);
        Test.stopTest();
         System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    private static void readMiniatureDataWithoutActivityTest() {
        Set<String> activitiesId = new Set<String>();

        Test.startTest();
        List<leankor.PlanGanttController.Miniature> result = PlanGanttController.readMiniatureData(activitiesId);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Result size should not be zero');
    }

    @isTest
    private static void readMiniatureDataTest() {
        List<leankor__ValueStream__c> valueStreams = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Limit 1];
        Set<String> activitiesId = new Set<String>();

        for (leankor__ValueStream__c valueStream : valueStreams) {
            activitiesId.add(valueStream.id);
        }   
        
        Test.startTest();
        List<leankor.PlanGanttController.Miniature> result = PlanGanttController.readMiniatureData(activitiesId);
        Test.stopTest();
          System.assertEquals(0, result.size(), 'Result size should  be zero');
    }
}