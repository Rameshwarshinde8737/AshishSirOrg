@isTest
private class ValueStreamTest {

	@isTest static leankor__ValueStream__c createExpected() {
		leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
		leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board');
        vStream.leankor__SprintStartDate__c = null;
        vStream.leankor__PointPicklist__c = ((leanConstant.leankor__PointSequence__c==null || leanConstant.leankor__PointSequence__c=='') ? '[]' :leanConstant.leankor__PointSequence__c);
        vStream.leankor__DaysPerSprint__c = null;
        vStream.leankor__IsAgile__c = false;
        vStream.leankor__Effortindicator__c = 'Days';
        vStream.leankor__TaskDateCheck__c =(!leanConstant.leankor__AvoidTaskDueDateCheck__c) ;
        vStream.leankor__DefaultCategory__c = null;
        vStream.leankor__DisableCalendarView__c = false;
        vStream.leankor__IsTemplateBoard__c = false;
        vStream.leankor__PortfolioMode__c = false;
        vStream.leankor__DisableTaskAsMiniature__c = false;
        vStream.leankor__SevenDayWorkWeek__c =false;
        vStream.leankor__DefaultOwnerID__c = userinfo.getuserID();
		try{
		    Database.insert(vStream);
		}catch(DMLException ex){
		    System.debug('Error : '+ex.getMessage());
		}

		return vStream;
	}

	@isTest static leankor__ValueStream__c createActual() {
		List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
		vsList.add(new ValueStream(ValueStream.KANBAN_BOARD).valueStream);
		
		List<leankor__ValueStream__c> result = leankor.ValueStream.createValueStream(vsList);
		leankor__ValueStream__c valueStreams = result.size() > 0 ? result[0] : new leankor__ValueStream__c();
		
		return valueStreams;
	}
	
	@isTest static void createValueStreamTest() {
		ValueStream testValueStream = new ValueStream(ValueStream.KANBAN_BOARD);
		
		List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
		vsList.add(testValueStream.valueStream);
		List<leankor__ValueStream__c> result = leankor.ValueStream.createValueStream(vsList);
		leankor__ValueStream__c valueStreams = result.size() > 0 ? result[0] : new leankor__ValueStream__c();
		System.assert(!String.isBlank(testValueStream.valueStream.id), 'Id of: ' + testValueStream.valueStream.id);
	}

	@isTest static void createCompareNotEqualsId() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertNotEquals(expected.id, actual.id);
	}

	@isTest static void createCompareName() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.Name, actual.Name);
	}

	@isTest static void createCompareBoardType() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__BoardType__c, actual.leankor__BoardType__c);
	}

	@isTest static void createCompareSprintStartDate() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__SprintStartDate__c, actual.leankor__SprintStartDate__c);
	}

	@isTest static void createComparePointPicklist() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__PointPicklist__c, actual.leankor__PointPicklist__c);
	}

	@isTest static void createCompareDaysPerSprint() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__DaysPerSprint__c, actual.leankor__DaysPerSprint__c);
	}

	@isTest static void createCompareIsAgile() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__IsAgile__c, actual.leankor__IsAgile__c);
	}

	@isTest static void createCompareEffortindicator() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__Effortindicator__c, actual.leankor__Effortindicator__c);
	}

	@isTest static void createCompareTaskDateCheck() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__TaskDateCheck__c, actual.leankor__TaskDateCheck__c);
	}
	
	@isTest static void createCompareDefaultCategory() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__DefaultCategory__c, actual.leankor__DefaultCategory__c);
	}
	
	@isTest static void createCompareDisableCalendarView() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__DisableCalendarView__c, actual.leankor__DisableCalendarView__c);
	}

	@isTest static void createCompareIsTemplateBoard() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__IsTemplateBoard__c, actual.leankor__IsTemplateBoard__c);
	}

	@isTest static void createComparePortfolioMode() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__PortfolioMode__c, actual.leankor__PortfolioMode__c);
	}

	@isTest static void createCompareDisableTaskAsMiniature() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__DisableTaskAsMiniature__c, actual.leankor__DisableTaskAsMiniature__c);
	}

	@isTest static void createCompareSevenDayWorkWeek() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__SevenDayWorkWeek__c, actual.leankor__SevenDayWorkWeek__c);
	}
	
	@isTest static void createCompareDefaultOwnerID() {
		leankor__ValueStream__c expected = createExpected();
		leankor__ValueStream__c actual = createActual();

		System.assertEquals(expected.leankor__DefaultOwnerID__c, actual.leankor__DefaultOwnerID__c);
	}
	
	
	 /*-----------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover updateValueStream Method inside  ValueStream Class
---------------------------------------------------------------------------------------*/ 
@isTest
private static void updateValueStreamTest(){

	leankor__ValueStream__c expected = createExpected();
	List<leankor__ValueStream__c> vSRecord = [Select Id,
													 Name, 
													 leankor__ValueStream__c.leankor__IsScheduleRecalculate__c 
												 From leankor__ValueStream__c];
	Test.startTest();
	List<leankor__ValueStream__c> valueStreamRecord = ValueStream.updateValueStream(vSRecord);
	System.assertEquals(valueStreamRecord[0].Name,'_System_Board');
	Test.stopTest(); 											 

}
/*-----------------------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover updateScheduleRecalculate Method inside  ValueStream Class
-----------------------------------------------------------------------------------------------*/ 
@isTest
private static void updateScheduleRecalculateTest(){

	leankor__ValueStream__c expected = createExpected();
	List<leankor__ValueStream__c> valueStreamRecord = [Select Id,
															  Name,
															  leankor__ValueStream__c.leankor__IsScheduleRecalculate__c 
														  From leankor__ValueStream__c];
	for(leankor__ValueStream__c vSRecord: valueStreamRecord){
		vSRecord.leankor__IsScheduleRecalculate__c=true;
	}
	update valueStreamRecord;

	Test.startTest();
	boolean valueStreamRecords = ValueStream.updateScheduleRecalculate(valueStreamRecord);
	System.assertEquals(valueStreamRecords, true);
	Test.stopTest(); 

}
/*------------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover readValueStreams Method inside  ValueStream Class
------------------------------------------------------------------------------------*/ 

@isTest
private static void readValueStreamsTest(){

	leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'TestFolder');
	insert testFolder;

	leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c(Name = 'TestProject', leankor__Portfolio__c = testFolder.Id);
	insert testProject;
	String projectRoomId= String.valueOf(testProject.id);
	
	leankor__ValueStream__c expected = createExpected();
	List<leankor__ValueStream__c> valueStreamRecord=[Select Id,
															Name,
															leankor__ValueStream__c.leankor__IsScheduleRecalculate__c 
														 From leankor__ValueStream__c];
	for(leankor__ValueStream__c vsRecord : valueStreamRecord){
		vsRecord.leankor__ProjectRoom__c=testProject.id;
	}
	update valueStreamRecord;
	Test.startTest();
	List<leankor__ValueStream__c> valueStreamRecords = ValueStream.readValueStreams(projectRoomId);
	System.assertEquals(valueStreamRecords[0].Name,'_System_Board');
	Test.stopTest(); 
	
 }

}