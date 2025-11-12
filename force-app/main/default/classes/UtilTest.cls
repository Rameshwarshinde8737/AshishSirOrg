/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UtilTest {
   /*
    To cover Util class methods.
    DATE: 27/11/18
   
   */

    @testSetup 
    static void testData() {

        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
		List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);
		
        List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();
        List<leankor__MasterContainer__c> masterContainerList = new List<leankor__MasterContainer__c>();
        List<leankor__ProjectScheduleBlackout__c> blackoutList = new List<leankor__ProjectScheduleBlackout__c>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();    
        
        leankor__ValueStream__c valueStreamTest1 = new leankor__ValueStream__c();
        valueStreamTest1.Name = 'myValueStream1';
        valueStreamTest1.leankor__BoardType__C ='kanbanBoard';
        valueStreamTest1.leankor__ProjectRoom__C = projectList[0].Id;
        valueStreamTest1.leankor__SprintStartDate__c = DateTime.newInstance(2022, 08, 02, 0, 0, 0); 
        valueStreamTest1.leankor__DaysPerSprint__c = 2;
        valueStreamTest1.leankor__IsAgile__c = true;
        valueStreamTest1.leankor__SevenDayWorkWeek__c = true;
        valueStreamList.add(valueStreamTest1);
        
        
		leankor__ValueStream__c valueStreamTest2 = new leankor__ValueStream__c();
        valueStreamTest2.Name = 'myValueStream2';
        valueStreamTest2.leankor__BoardType__C ='kanbanBoard';
        valueStreamTest2.leankor__ProjectRoom__C = projectList[0].Id;
        valueStreamTest2.leankor__SprintStartDate__c = DateTime.newInstance(2022, 08, 03, 0, 0, 0); 
        valueStreamTest2.leankor__DaysPerSprint__c = 2;
        valueStreamTest2.leankor__IsAgile__c = true;
        valueStreamTest2.leankor__SevenDayWorkWeek__c = false;
        valueStreamList.add(valueStreamTest2);

        leankor__ValueStream__c valueStreamTest3 = new leankor__ValueStream__c();
        valueStreamTest3.Name = 'myValueStream3';
        valueStreamTest3.leankor__BoardType__C ='kanbanBoard';
        valueStreamTest3.leankor__ProjectRoom__C = projectList[0].Id;
        valueStreamTest3.leankor__SprintStartDate__c = DateTime.newInstance(2022, 08, 04, 0, 0, 0);
        valueStreamTest3.leankor__DaysPerSprint__c = 3;
        valueStreamTest3.leankor__IsAgile__c = true;
        valueStreamTest3.leankor__SevenDayWorkWeek__c = true;
        valueStreamList.add(valueStreamTest3);

        leankor__ValueStream__c valueStreamTest4 = new leankor__ValueStream__c();
        valueStreamTest4.Name = 'myValueStream4';
        valueStreamTest4.leankor__BoardType__C ='kanbanBoard';
        valueStreamTest4.leankor__ProjectRoom__C = projectList[0].Id;
        valueStreamTest4.leankor__SprintStartDate__c = DateTime.newInstance(2022, 08, 04, 0, 0, 0);
        valueStreamTest4.leankor__DaysPerSprint__c = 3;
        valueStreamTest4.leankor__IsAgile__c = true;
        valueStreamTest4.leankor__SevenDayWorkWeek__c = false;
        valueStreamList.add(valueStreamTest4);
        
         insert valueStreamList;

        leankor__ProjectScheduleBlackout__c blackOuts1 = new leankor__ProjectScheduleBlackout__c();
        blackOuts1.Name = 'Test Blackout1';
        blackOuts1.leankor__ProjectBoard__c = valueStreamTest1.Id;
        blackOuts1.leankor__EndDate__c = Date.newInstance(2022, 08, 04); 
        blackOuts1.leankor__StartDate__c = Date.newInstance(2022, 08, 03); 
        blackoutList.add(blackOuts1);

        leankor__ProjectScheduleBlackout__c blackOuts2 = new leankor__ProjectScheduleBlackout__c();
        blackOuts2.Name = 'Test Blackout2';
        blackOuts2.leankor__ProjectBoard__c = valueStreamTest2.Id;
        blackOuts2.leankor__EndDate__c = Date.newInstance(2022, 08, 05);
        blackOuts2.leankor__StartDate__c =Date.newInstance(2022, 08, 04);
       	blackoutList.add(blackOuts2);
        
        insert blackoutList;

        leankor__MasterContainer__c masterContainer1 = new leankor__MasterContainer__c();
        masterContainer1.Name= 'Test-MasterContainer';
        masterContainer1.leankor__ValueStream__c = valueStreamTest1.Id;
        masterContainer1.leankor__order__c =0.0;
        masterContainer1.leankor__Type__c ='Backlog';
        masterContainerList.add(masterContainer1);
        
        leankor__MasterContainer__c masterContainer2 = new leankor__MasterContainer__c();
        masterContainer2.Name= 'Test-MasterContainer2';
        masterContainer2.leankor__ValueStream__c = valueStreamTest2.Id;
        masterContainer2.leankor__order__c =0.0;
        masterContainer2.leankor__Type__c ='Backlog';
        masterContainer2.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        masterContainerList.add(masterContainer2);
        
        leankor__MasterContainer__c masterContainer3 = new leankor__MasterContainer__c();
        masterContainer3.Name= 'Test-MasterContainer3';
        masterContainer3.leankor__ValueStream__c = valueStreamTest3.Id;
        masterContainer3.leankor__order__c = 0.0;
        masterContainer3.leankor__Type__c ='Template';
        masterContainer3.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        masterContainerList.add(masterContainer3);
        
        leankor__MasterContainer__c masterContainer4 = new leankor__MasterContainer__c();
        masterContainer4.Name= 'Test-MasterContainer4';
        masterContainer4.leankor__ValueStream__c = valueStreamTest3.Id;
        masterContainer4.leankor__order__c = 0.0;
        masterContainer4.leankor__Type__c ='Backlog';
        masterContainer4.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        masterContainerList.add(masterContainer4);
        
        leankor__MasterContainer__c masterContainer5 = new leankor__MasterContainer__c();
        masterContainer5.Name= 'Test-MasterContainer5';
        masterContainer5.leankor__ValueStream__c = valueStreamTest4.Id;
        masterContainer5.leankor__order__c = 0.0;
        masterContainer5.leankor__Type__c ='Archive';
        masterContainer5.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
        masterContainerList.add(masterContainer5);
        
        insert masterContainerList;
       
       leankor__KanbanCard__c card1 = new leankor__Kanbancard__c ();
       card1.Name = 'Card1';
       card1.leankor__valuestream__c = valueStreamTest1.Id;
       card1.leankor__MasterContainer__c = masterContainer1.Id;
       card1.leankor__PercentComplete2__c = 50;
       card1.leankor__Point__c = 4; 
       card1.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card1);
        
       leankor__KanbanCard__c card2 = new leankor__Kanbancard__c ();
       card2.Name = 'Card2';
       card2.leankor__valuestream__c = valueStreamTest1.Id;
       card2.leankor__MasterContainer__c = masterContainer1.Id;
       card2.leankor__PercentComplete2__c = 100;
       card2.leankor__Point__c = 7; 
       card2.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card2);
        
        
        
        leankor__KanbanCard__c card3 = new leankor__Kanbancard__c ();
       card3.Name = 'Card3';
       card3.leankor__valuestream__c = valueStreamTest2.Id;
       card3.leankor__MasterContainer__c = masterContainer2.Id;
       card3.leankor__PercentComplete2__c = 100;
       card3.leankor__Point__c = 5; 
       card3.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card3);
        
        leankor__KanbanCard__c card4 = new leankor__Kanbancard__c ();
       card4.Name = 'Card4';
       card4.leankor__valuestream__c = valueStreamTest2.Id;
       card4.leankor__MasterContainer__c = masterContainer2.Id;
       card4.leankor__PercentComplete2__c = 100;
       card4.leankor__Point__c = 3; 
       card4.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card4);
        
      
          
       leankor__KanbanCard__c card5 = new leankor__Kanbancard__c ();
       card5.Name = 'Card5';
       card5.leankor__valuestream__c = valueStreamTest3.Id;
       card5.leankor__MasterContainer__c = masterContainer3.Id;
       card5.leankor__PercentComplete2__c = 25;
       card5.leankor__Point__c = 4; 
       card5.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card5);
        
         
          
       leankor__KanbanCard__c card6 = new leankor__Kanbancard__c ();
       card6.Name = 'Card6';
       card6.leankor__valuestream__c = valueStreamTest3.Id;
       card6.leankor__MasterContainer__c = masterContainer4.Id;
       card6.leankor__PercentComplete2__c = 100;
       card6.leankor__Point__c = 3; 
       card6.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card6);
        
       leankor__KanbanCard__c card7 = new leankor__Kanbancard__c ();
       card7.Name = 'Card7';
       card7.leankor__valuestream__c = valueStreamTest3.Id;
       card7.leankor__MasterContainer__c = masterContainer4.Id;
       card7.leankor__PercentComplete2__c = 75;
       card7.leankor__Point__c = 9; 
       card7.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card7);
        
       
        
       leankor__KanbanCard__c card8 = new leankor__Kanbancard__c ();
       card8.Name = 'Card8';
       card8.leankor__valuestream__c = valueStreamTest4.Id;
       card8.leankor__MasterContainer__c = masterContainer5.Id;
       card8.leankor__PercentComplete2__c = 75;
       card8.leankor__Point__c = 6; 
       card8.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card8);
        
       leankor__KanbanCard__c card9 = new leankor__Kanbancard__c ();
       card9.Name = 'Card9';
       card9.leankor__valuestream__c = valueStreamTest4.Id;
       card9.leankor__MasterContainer__c = masterContainer5.Id;
       card9.leankor__PercentComplete2__c = 99;
       card9.leankor__Point__c = 8; 
       card9.leankor__GUID__c = ResourceGanttController.createGuid().replace('-','');
       kanbanCardList.add(card9);

        insert kanbanCardList;
	}
    
    static testMethod void readNextWorkingDateTimeTest() {   	    	
         leankor.Util.WorkWeek workweek= new leankor.Util.WorkWeek(1,6);
         workweek.readWeekDays();
         workweek.readWorkingDays();
         workweek.readNonWorkingDays();
       //DateTime currentDateTime= Date.today(); 
       DateTime currentDateTime =DateTime.newInstanceGmt(2018,11,11);
       // To cover   readNextWorkingDateTime method.       
       System.assert(leankor.Util.readNextWorkingDateTime(workweek,currentDateTime)!=null);
       // To cover  readPreviousWorkingDateTime method.
       System.assert(leankor.Util.readPreviousWorkingDateTime(workweek,currentDateTime)!=null); 
       // To cover  readNextWorkingDate method.
       System.assert(leankor.Util.readNextWorkingDate(workweek,System.today())!=null);
       // To cover  readNextWorkingDate method.
       System.assert(leankor.Util.readNextWorkingDate(workweek,currentDateTime,System.today())!=null);
       // To cover  readPreviousWorkingDate method.
       System.assert(leankor.Util.readPreviousWorkingDate(workweek,currentDateTime,System.today())!=null);      
       // To cover  readPreviousWorkingDate method.
       System.assert(leankor.Util.readPreviousWorkingDate(workweek,System.today())!=null);                        
    }
	
    static testMethod void testparseWhereClause() {
        String clause = 'where name like \'%test\'';
        system.assertEquals('where name like \'%test\'', Util.parseWhereClause(clause));
    }	
    
    /** 
    // Date: 11/06/2019 - Test method for getWorkingDays method.
    static testMethod void getWorkingDaysTest(){
    	leankor.Util.getWorkingDays(System.now()-10, System.now()+20, false, 1, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-11, System.now()+20, false, 2, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-12, System.now()+20, false, 3, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-13, System.now()+20, false, 4, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-14, System.now()+20, false, 5, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-15, System.now()+20, false, 6, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-16, System.now()+20, false, 0, (Date)System.today());
    	leankor.Util.getWorkingDays(System.now()-16, System.now()+20, true, 0, (Date)System.today());
    }
    */
    
    @isTest
    Private static void readPackageVersionTest(){
        Test.startTest();
        String actualValue = Util.readPackageVersion();
        Test.stopTest();
        System.assertEquals('1.309',actualValue);
        System.assert(Util.readPackageVersion()!=null);
    }

    @isTest
    private static void testreadWorkItemPointsFirst(){

       leankor__ValueStream__c valueStream = [Select Id
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream1' Limit 1];

        Set<String> masterContainerTypeFilters = new Set<String>{'Archive', 'Backlog', 'Regular'};
        Test.StartTest();
        AggregateResult  projectBoardPoints = Util.readWorkItemPoints(valueStream.id, masterContainerTypeFilters);
        System.assertEquals( 4.0 , projectBoardPoints.get('uncompletedPoints'));
        System.assertEquals(11.0 , projectBoardPoints.get('totalPoints'));
        Test.StopTest();
    }
    
    @isTest
    private static void testreadWorkItemPointsSecond(){

       leankor__ValueStream__c valueStream = [Select Id
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream2' Limit 1];

        Set<String> masterContainerTypeFilters = new Set<String>{'Archive', 'Backlog', 'Regular'};
        Test.StartTest();
        AggregateResult  projectBoardPoints = Util.readWorkItemPoints(valueStream.id, masterContainerTypeFilters);
        System.assertEquals( 0.0 , projectBoardPoints.get('uncompletedPoints'));
        System.assertEquals(8.0 , projectBoardPoints.get('totalPoints'));
        Test.StopTest();
    }
    
    @isTest
    private static void testreadWorkItemPointsThird(){

       leankor__ValueStream__c valueStream = [Select Id
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream3' Limit 1];

        Set<String> masterContainerTypeFilters = new Set<String>{'Archive', 'Backlog', 'Regular'};
        Test.StartTest();
        AggregateResult  projectBoardPoints = Util.readWorkItemPoints(valueStream.id, masterContainerTypeFilters);
        System.assertEquals( 9.0 , projectBoardPoints.get('uncompletedPoints'));
        System.assertEquals(12.0 , projectBoardPoints.get('totalPoints'));
        Test.StopTest();
    }
    
    @isTest
    private static void testreadWorkItemPointsfourth(){

       leankor__ValueStream__c valueStream = [Select Id
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream4' Limit 1];

        Set<String> masterContainerTypeFilters = new Set<String>{'Archive', 'Backlog', 'Regular'};
        Test.StartTest();
        AggregateResult  projectBoardPoints = Util.readWorkItemPoints(valueStream.id, masterContainerTypeFilters);
        System.assertEquals( 14.0 , projectBoardPoints.get('uncompletedPoints'));
        System.assertEquals(14.0 , projectBoardPoints.get('totalPoints'));
        Test.StopTest();
    }

    @isTest
    Private static void testgetSprintEndDateFirst(){

        leankor__ValueStream__c valueStream = [Select Id,
                                                      leankor__SevenDayWorkWeek__c,
                                                      leankor__SprintStartDate__c,
                                                      leankor__DaysPerSprint__c
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream1'];
        Test.StartTest();
        DateTime sprintdateTime = Util.getSprintEndDate(valuestream);
        Date sprintdate = date.newinstance(sprintdateTime.year(), sprintdateTime.month(), sprintdateTime.day());
        System.assertEquals(Date.newInstance(2022, 08, 05), sprintdate);
        Test.StopTest();
    }
   
    @isTest
    Private static void testgetSprintEndDateSecond(){

        
        leankor__ValueStream__c valueStream = [Select Id,
                                                      leankor__SevenDayWorkWeek__c,
                                                      leankor__SprintStartDate__c,
                                                      leankor__DaysPerSprint__c
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream2'];
        Test.StartTest();
        DateTime sprintdateTime = Util.getSprintEndDate(valuestream);
        Date sprintdate = date.newinstance(sprintdateTime.year(), sprintdateTime.month(), sprintdateTime.day());
        System.assertEquals(Date.newInstance(2022, 08, 08), sprintdate);
    
        Test.StopTest();
    }

    @isTest
    Private static void testgetSprintEndDateThird(){

        
        leankor__ValueStream__c valueStream = [Select Id,
                                                      leankor__SevenDayWorkWeek__c,
                                                      leankor__SprintStartDate__c,
                                                      leankor__DaysPerSprint__c
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream3'];
        Test.StartTest();
        DateTime sprintdateTime = Util.getSprintEndDate(valuestream);
        Date sprintdate = date.newinstance(sprintdateTime.year(), sprintdateTime.month(), sprintdateTime.day());
        System.assertEquals(Date.newInstance(2022, 08, 06), sprintdate);
        Test.StopTest();
    }

    @isTest
    Private static void testgetSprintEndDateFourth(){
        
        leankor__ValueStream__c valueStream = [Select Id,
                                                      leankor__SevenDayWorkWeek__c,
                                                      leankor__SprintStartDate__c,
                                                      leankor__DaysPerSprint__c
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream4'];
        Test.StartTest();
        DateTime sprintdateTime = Util.getSprintEndDate(valuestream);
        Date sprintdate = date.newinstance(sprintdateTime.year(), sprintdateTime.month(), sprintdateTime.day());
        System.assertEquals(Date.newInstance(2022, 08, 08), sprintdate);
        Test.StopTest();
    }

    @isTest
    private static void isObjectAccessibleTest(){
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u1 = new User(Alias = 'leankor1', Email='leankor1@leankor.com',
						EmailEncodingKey='UTF-8', LastName='Leankor1', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,
						TimeZoneSidKey='America/Los_Angeles', UserName='leankor1@leankor.com');
        
		insert u1;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Visual_Lean_Designer'];
		insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );
      
        System.runAs(u1) {
              String sObjectName = 'leankor__KanbanCard__c';
            Boolean actualValue = Util.isObjectAccessible(sObjectName);
            System.assertEquals(true, actualValue);
        }
    }
    
    @isTest
    private static void getSObjectNameTestFirst(){
         leankor__ValueStream__c valueStream = [Select Id,
                                                      leankor__SevenDayWorkWeek__c,
                                                      leankor__SprintStartDate__c,
                                                      leankor__DaysPerSprint__c
                                                From leankor__ValueStream__c
                                                Where Name = 'myValueStream3'];
        String actualObjectName = Util.getSObjectName(valueStream.id);
        System.assertEquals('leankor__ValueStream__c', actualObjectName);
    }
    @isTest
    private static void getSObjectNameTestSecond(){
        String actualObjectName = Util.getSObjectName('');
        System.assertEquals('', actualObjectName);
    }
}