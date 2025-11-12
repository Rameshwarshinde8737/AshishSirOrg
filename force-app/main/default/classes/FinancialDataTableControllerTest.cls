@isTest
private class FinancialDataTableControllerTest {

	private static leankor__Expense__c createTestExpenseRecord(Date dateInput, String nameInput) {
		leankor__Expense__c testExpense = new leankor__Expense__c();
		testExpense.leankor__Date__c = dateInput;
		testExpense.Name = nameInput;
		insert testExpense;
		return testExpense;
	}

	private static leankor__Expense__c createTestExpenseRecord(Date dateInput, String nameInput, String projectId) {
		leankor__Expense__c testExpense = new leankor__Expense__c();
		testExpense.leankor__Date__c = dateInput;
		testExpense.Name = nameInput;
		testExpense.leankor__Project__c = projectId;
		insert testExpense;
		return testExpense;
	}

	private static leankor__Expense__c createTestExpenseRecord(Date dateInput, String nameInput, String projectId, Boolean isPlan, Boolean isForecast, Boolean isPrevious, Boolean isCurrent, Date forecastDate) 
	{
		leankor__Expense__c testExpense = new leankor__Expense__c();
		testExpense.leankor__Date__c = dateInput;
		testExpense.Name = nameInput;
		testExpense.leankor__Project__c = projectId;
		testExpense.leankor__Plan__c = isPlan;
		testExpense.leankor__isForecast__c = isForecast;
		testExpense.leankor__IsPrevForecast__c = isPrevious;
		testExpense.leankor__IsCurrForecast__c = isCurrent;
		testExpense.leankor__ForecastDate__c = forecastDate;
		List<RecordType> recordTypes = FinancialDataTableController.getRecordTypes();
		if(!recordTypes.isEmpty()) {
			testExpense.RecordTypeId = recordTypes[0].id;
		}
		insert testExpense;
		return testExpense;
	}

	private static leankor__Portfolio__c createTestFolderRecord(String nameInput) {
		leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
		testFolder.Name = nameInput;
		insert testFolder;
		return testFolder;
	}

	private static leankor__ProjectRoom__c createTestProjectRecord(String nameInput) {
		leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
		testProject.Name = nameInput;
		insert testProject;
		return testProject;
	}

	private static leankor__ProjectRoom__c createTestProjectRecord(String nameInput, String folderId) {
		leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
		testProject.Name = nameInput;
		testProject.leankor__Portfolio__c = folderId;
		insert testProject;
		return testProject;
	}

	private static leankor__ValueStream__c createTestValueStreamRecord(String nameInput, String projectRoomId) {
		leankor__ValueStream__c testValueStream = new leankor__ValueStream__c();
		testValueStream.Name = nameInput;
		testValueStream.leankor__SevenDayWorkWeek__c = true;
		testValueStream.leankor__ProjectRoom__c = projectRoomId;
		insert testValueStream;
		return testValueStream;
	}

	private static leankor__KanbanCard__c createTestKanbanCardRecord(String nameInput, String valueStreamId) {
		leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c();
		testKanbanCard.Name = nameInput;
		testKanbanCard.leankor__DurationUnits__c = 'Days';
		testKanbanCard.leankor__EstimatedDuration__c = 1;
		testKanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
		testKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
		testKanbanCard.leankor__ValueStream__c = valueStreamId;
		testKanbanCard.leankor__isRecordDeleted__c = false;
		insert testKanbanCard;
		return testKanbanCard;
	}

	private static leankor__ResourceAssignment__c createTestResourceAssignmentRecord(String kanbanCardId) {
		leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
		testResourceAssignment.leankor__KanbanCard__c = kanbanCardId;
		testResourceAssignment.leankor__PercentAllocation__c = 1;
		testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
		testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
		testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
		testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
		testResourceAssignment.leankor__InternalHourlyRate__c = 1;
		testResourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
		insert testResourceAssignment;
		return testResourceAssignment;
	}

	@isTest static void calculateProjectFinancialsTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
		String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
		leankor__ResourceAssignment__c testResourceAssignment = createTestResourceAssignmentRecord(kanbanCardId);
		List<leankor__ExpenseResourceAssignment__c> testExpenseResourceAssignments = new List<leankor__ExpenseResourceAssignment__c>();
		Map<String, SObject> projectFinancialCalculations = FinancialDataTableController.calculateProjectFinancials(projectRoomId, false, testExpenseResourceAssignments);
		System.assert(!projectFinancialCalculations.isEmpty());
	}

	@isTest static void rowThreeParameterConstructorTest() {
		FinancialDataTableController.Row threeParam = new FinancialDataTableController.Row('TestName', 'TestApiName', 'TestDataType');
		System.assert(threeParam != null);
	}
	
	// Tests a record update on the 'Name' field
	@isTest static void updateRecordsTest() {
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense');
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		testExpense.Name = 'Changed Name';
		List<leankor__Expense__c> expenses = new List<leankor__Expense__c>();
		expenses.add(testExpense);
		FinancialDataTableController.updateRecords(expenses, testProject.id, '', new List<String>());
		String expected = 'Changed Name';
		String actual = [SELECT Name FROM leankor__Expense__c WHERE Id =: testExpense.id LIMIT 1].Name;
		System.assertEquals(expected, actual);
	}
	
	// Tests if a record is deleted
	@isTest static void deleteRecordTest() {
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense');
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		FinancialDataTableController.deleteRecord(testExpense.id, testProject.id, 'leankor__ExpenseViewFieldSet', new List<String>());
		Boolean expected = true;
		Boolean actual = [SELECT Name FROM leankor__Expense__c WHERE Id =: testExpense.id].isEmpty();
		System.assertEquals(expected, actual);
	}

	// Tests if records are obtained
	@isTest static void getRecordTypesTest() {
		Boolean expected = false;
		Boolean actual = FinancialDataTableController.getRecordTypes().isEmpty();
		System.assertEquals(expected, actual);
	}
	
	// Tests if no records are obtained
	@isTest static void getExpensesTest() {
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense', testProject.id);
		Boolean expected = true;
		Boolean actual = FinancialDataTableController.getExpenses(testProject.id, '', new List<String>()).isEmpty();
		System.assertEquals(expected, actual);
	}

	// Tests if no records are obtained
	@isTest static void getExpensesValueStreamIdTest() {		
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;		
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense', projectRoomId);
		Boolean expected = true;
		Boolean actual = FinancialDataTableController.getExpenses(valueStreamId, '', new List<String>()).isEmpty();
		System.assertEquals(expected, actual);
	}

	// Tests if no records are obtained
	@isTest static void getExpensesKanbanCardIdTest() {		
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;		
		String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;		
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense', projectRoomId);
		Boolean expected = true;
		Boolean actual = FinancialDataTableController.getExpenses(kanbanCardId, '', new List<String>()).isEmpty();
		System.assertEquals(expected, actual);
	}
	
	// Tests if an id is obtained
	@isTest static void getFolderIdTest() {
		leankor__Portfolio__c testPortfolio = createTestFolderRecord('Test Folder');
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project', testPortfolio.id);
		String expected = testPortfolio.id;
		String actual = FinancialDataTableController.getFolderId(testProject.id);
		System.assertEquals(expected, actual);
	}

	// Tests if an id is obtained
	@isTest static void getFolderIdValueStreamIdTest() {
		leankor__Portfolio__c testPortfolio = createTestFolderRecord('Test Folder');
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project', testPortfolio.id);
		leankor__ValueStream__c testValueStream = createTestValueStreamRecord('Test Valuestream', testProject.id);		
		String expected = testPortfolio.id;
		String actual = FinancialDataTableController.getFolderId(testValueStream.id);
		System.assertEquals(expected, actual);
	}

	// Tests if an id is obtained
	@isTest static void getFolderIdKanbanCardIdTest() {
		leankor__Portfolio__c testPortfolio = createTestFolderRecord('Test Folder');
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project', testPortfolio.id);
		leankor__ValueStream__c testValueStream = createTestValueStreamRecord('Test Valuestream', testProject.id);
		leankor__KanbanCard__c testKanbanCard = createTestKanbanCardRecord('Test Kanban card', testValueStream.id);		
		String expected = testPortfolio.id;
		String actual = FinancialDataTableController.getFolderId(testKanbanCard.id);
		System.assertEquals(expected, actual);
	}

	// Tests if row headers are obtained
	@isTest static void getRowsTest() {
		DescribeSchema ds = new DescribeSchema();
		String fieldsetName = '';
		if(!ds.getFieldSets('leankor__Expense__c').isEmpty()) {
			Schema.FieldSet fieldset = ds.getFieldSets('leankor__Expense__c').values()[0];
			fieldsetName = fieldset.getNamespace() + '__' + fieldset.getName();
		}
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getRows(fieldsetName));
		System.assertEquals(expected, actual);
	}

	@isTest static void getDatePicklistTest() {
		String expected = '[]';
		String actual = FinancialDataTableController.getDatePicklist('');
		System.assertEquals(expected, actual);
	}
	
	@isTest static void getFieldNamesTest() {
		List<String> expected = new List<String>();
		List<String> actual = FinancialDataTableController.getFieldNames('');
		System.assertEquals(expected, actual);
	}

	@isTest static void getFieldDataTypesTest() {
		List<String> expected = new List<String>();
		List<String> actual = FinancialDataTableController.getFieldDataTypes('');
		System.assertEquals(expected, actual);
	}
	
	@isTest static void cloneForecastRecordsCurrentTest() {
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		leankor__Expense__c currentExpense = createTestExpenseRecord(Date.today(), 'Test Expense', testProject.id, true, true, false, true, Date.today());
		Boolean expected = false;
		Boolean actual = FinancialDataTableController.cloneForecastRecords(testProject.id, currentExpense.leankor__ForecastDate__c).isEmpty();
		System.assertEquals(expected, actual);
	}

	@isTest static void cloneForecastRecordsOriginalTest() {
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		leankor__Expense__c originalExpense = createTestExpenseRecord(Date.today(), 'Test Expense', testProject.id, true, false, false, false, Date.today());
		Boolean expected = false;
		Boolean actual = FinancialDataTableController.cloneForecastRecords(testProject.id, originalExpense.leankor__ForecastDate__c).isEmpty();
		System.assertEquals(expected, actual);
	}

	@isTest static void getForecastDatesTest() {
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense', testProject.id, false, true, false, false, Date.today());
		Boolean expected = false;
		Boolean actual = FinancialDataTableController.getForecastDates(testProject.id).isEmpty();
		System.assertEquals(expected, actual);
	}
	
	@isTest static void readRecordsTest() {
		leankor__ProjectRoom__c testProject = createTestProjectRecord('Test Project');
		leankor__Expense__c testExpense = createTestExpenseRecord(Date.today(), 'Test Expense', testProject.id, true, true, true, false, Date.today());
		Boolean expected = false;
		Boolean actual = FinancialDataTableController.readRecords(testProject.id, true, true, true, false).isEmpty();
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectInfoProjectIdTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;		
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectInfo(projectRoomId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectInfoValueStreamIdTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectInfo(valueStreamId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectInfoKanbanCardIdTest() {
		String folderId = createTestFolderRecord('Folder').Id;
		String projectRoomId = createTestProjectRecord('Project', folderId).id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
		String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectInfo(kanbanCardId));
		System.assertEquals(expected, actual);
	}	

	@isTest static void getProjectLabelProjectIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;		
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectLabel(projectRoomId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectLabelValueStreamIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;		
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectLabel(valueStreamId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectLabelKanbanCardIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
		String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectLabel(kanbanCardId));
		System.assertEquals(expected, actual);
	}	

	@isTest static void getProjectIdProjectIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;		
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectId(projectRoomId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectIdValueStreamIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;		
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectId(valueStreamId));
		System.assertEquals(expected, actual);
	}

	@isTest static void getProjectIdKanbanCardIdTest() {
		String projectRoomId = createTestProjectRecord('Project').id;
		String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
		String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
		Boolean expected = true;
		Boolean actual = String.isNotEmpty(FinancialDataTableController.getProjectId(kanbanCardId));
		System.assertEquals(expected, actual);
	}
}