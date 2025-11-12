/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class FinancialDataTableController {	

	@TestVisible	
	private Class Row {
		public String name;
		public String apiName;
		public String dataType;
		public Boolean editable;
		
		public Row(String name, String apiName, String dataType, Boolean editable) {
			this.name = name;
			this.apiName = apiName;
			this.dataType = dataType;
			this.editable = editable;
		}

		public Row(String name, String apiName, String dataType) {
			this.apiName = apiName;
			this.name = name;
			this.dataType = dataType;
		}
	}

	// deprecate
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static String getProjectLabel(String projectId) {
        if ((String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')
            &&(Util.getSObjectName(projectId) != 'leankor__ValueStream__c')
            &&(Util.getSObjectName(projectId) != 'leankor__KanbanCard__c')){
                throw new Util.LeanException('Error: Invalid input');
           }
        
		// select the query depending on the sObject type of the projectId parameter
		// supported sObject types are leankor__ProjectRoom__c, leankor__ValueStream__c, leankor__KanbanCard__c
		switch on Util.getSObjectName(projectId) {
			when 'leankor__ProjectRoom__c' {
				return [Select Name 
							From leankor__ProjectRoom__c 
							Where Id =:projectId
							With Security_Enforced].Name;
			}
			when 'leankor__ValueStream__c' {
				return [Select leankor__ProjectRoom__r.Name 
							From leankor__ValueStream__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ProjectRoom__r.Name;
			}
			when 'leankor__KanbanCard__c' {
				return [Select leankor__ValueStream__r.leankor__ProjectRoom__r.Name 
							From leankor__KanbanCard__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ValueStream__r.leankor__ProjectRoom__r.Name;
			}
			when else {
				return '';
			}
		}
	}
	
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static List<leankor__Expense__c> updateRecords(List<leankor__Expense__c> expenses, String id, String fieldSetName, List<String> whereClause) {
		//Added Security code for sentize user Input
		for (leankor__Expense__c expensesRecord : expenses) {
            if (String.isNotBlank(expensesRecord.id) && Util.getSObjectName(expensesRecord.id) != 'leankor__Expense__c'){
                throw new Util.LeanException('Error: Invalid input');
            }
        }
		//Check CRUD / FLC behavior
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!expenseBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
		
		update expenses;
		List<leankor__Expense__c> refreshExpenses = getExpenses(id, fieldSetName, whereClause);
		return refreshExpenses;
	}

	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static List<leankor__Expense__c> deleteRecord(String recordId, String projectId, String fieldSetName, List<String> whereClause) {
		//Added Security code for sentize user Input
		if (String.isNotBlank(recordId) && Util.getSObjectName(recordId) != 'leankor__Expense__c'){
			throw new Util.LeanException('Error: Invalid input');
		}
        
		//Check CRUD / FLC behavior
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!expenseBehaviour.isDeletable()) {
            throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
		
		List<leankor__Expense__c> deleteExpense = [Select Id 
														From leankor__Expense__c 
														Where Id =:recordId
														With Security_Enforced]; 
		try {
		    delete deleteExpense;
		} catch (DmlException e) {
		    throw new Util.LeanException('ERROR:' + e.getMessage()); 	
		}
		List<leankor__Expense__c> refreshExpenses = getExpenses(projectId, fieldSetName, whereClause);
		return refreshExpenses;
	}
	
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static List<RecordType> getRecordTypes() {
		return [Select Id, 
						toLabel(Name) 
					From RecordType 
					Where SobjectType = 'leankor__Expense__c' 
						And IsActive = true];
	}

	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    @TestVisible
    global static List<leankor__Expense__c> getExpenses(String id, String fieldSetName, List<String> whereClause) {    	
		//Added Security code for sentize user Input
		if((String.isNotBlank(id) && Util.getSObjectName(id) != 'leankor__ValueStream__c')
		&&(Util.getSObjectName(id) != 'leankor__KanbanCard__c')
		&&(Util.getSObjectName(id) != 'leankor__ProjectRoom__c')){
			throw new Util.LeanException('Error: Invalid input');
	   }
		String objectField = '';
		List<sObject> expense = new List<sObject>();
		// select the fieldname for WHERE clause depending on the sObject type of the id parameter
		// supported sObject types are leankor__ProjectRoom__c, leankor__ValueStream__c, leankor__KanbanCard__c
		// default sObject type is leankor__Project__c
		switch on Util.getSObjectName(id) {
			when 'leankor__ValueStream__c' {
				objectField = 'leankor__ProjectBoard__c';
			}
			when 'leankor__KanbanCard__c' {
				objectField = 'leankor__KanbanCard__c';
			}
			when else {
				objectField = 'leankor__Project__c';
			}
		}
	
		//List<String> whereClauseStuff = new List<String>{'WHERE leankor__Project__c = \'' + id + '\''};
		List<String> whereClauseStuff = new List<String>{'WHERE ' + objectField + ' = \'' + id + '\''};
    	whereClauseStuff.addAll(whereClause);
    	String dynamicWhere = String.join(whereClauseStuff, ' AND ') + ' ORDER BY leankor__Date__c, leankor__Category__c, leankor__ExpenseSubCategory__c, leankor__ExpenseAccount__c ';
    	leankor.DescribeSchema ds = new leankor.DescribeSchema();
		if(fieldSetName != null && fieldSetName != ''){
			expense = (List<leankor__Expense__c>) ds.dynamicFieldQuery('leankor__Expense__c', new Set<String>(getFieldNames(fieldSetName)), dynamicWhere);
		}
        //Add isAccessible() check
        return expense;
    }

	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static String getFolderId(String projectId) {
		//Added Security code for sentize user Input
		if((String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')
		&&(Util.getSObjectName(projectId) != 'leankor__ValueStream__c')
		&&(Util.getSObjectName(projectId) != 'leankor__KanbanCard__c')){
			throw new Util.LeanException('Error: Invalid input');
	    }
		// select the query depending on the sObject type of the projectId parameter
		// supported sObject types are leankor__ProjectRoom__c, leankor__ValueStream__c, leankor__KanbanCard__c
		switch on Util.getSObjectName(projectId) {
			when 'leankor__ProjectRoom__c' {
				return [Select leankor__Portfolio__c 
							From leankor__ProjectRoom__c 
							Where Id =:projectId
							With Security_Enforced].leankor__Portfolio__c;
			}
			when 'leankor__ValueStream__c' {
				return [Select leankor__ProjectRoom__r.leankor__Portfolio__c
							From leankor__ValueStream__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ProjectRoom__r.leankor__Portfolio__c;		
			}
			when 'leankor__KanbanCard__c' {
				return [Select leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c 
							From leankor__KanbanCard__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c;
			}
			when else {
				return '';
			}
		}
	}

	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    @TestVisible
    global static String getRows(String fieldSetName) {
	    leankor.DescribeSchema ds = new leankor.DescribeSchema();
		List<Schema.FieldSetMember> fieldSetFields = ds.getFieldSetFields('leankor__Expense__c', fieldSetName);
		Map<String, Schema.SObjectField> fieldMap = ds.getObjectFields('leankor__Expense__c');
		List<Row> rows = new List<Row>();
		Boolean editable;
		for(Schema.FieldSetMember field : fieldSetFields) {
			String dataType = getLightningDatatypeEquivalent(field);
			leankor__Expense__c newExpense = new leankor__Expense__c();
			if(fieldMap.containsKey(field.getFieldPath())) {
				editable = fieldMap.get(field.getFieldPath()).getDescribe().isUpdateable();
			} else {
				editable = false;
			}
		    rows.add(new Row(field.getLabel(), field.getFieldPath(), dataType, editable));
		}
		return JSON.serialize(rows);
	}

    @TestVisible
    public static String getLightningDatatypeEquivalent(Schema.FieldSetMember field) {
			String dataType;
			switch on field.getType() {
			    when String {
			    	dataType = 'text';
			    }
			    when Boolean {
			    	dataType = 'boolean';
			    }	
			    when Currency {
			    	dataType = 'currency';
			    }
			    when Date {
			    	dataType = 'date-local';
			    }
			    when DateTime {
			    	dataType = 'date';
			    }
			    when Email {
			    	dataType = 'email';
			    }
			    //Missing Location
			    /*
			    when Location {

			    }*/
			    when Integer {
			    	dataType = 'number';
			    }
			    when Percent {
			    	dataType = 'percent';
			    }
			    when Phone {
			    	dataType = 'phone';
			    }
			    when TextArea {
			    	dataType = 'text';
			    }
			    when URL {
			    	dataType = 'url';
			    }
			    when else {
			    	dataType = 'misc';
			    }
			}
		return dataType;
			}

    @TestVisible
    public static List<String> getLightningDatatypeEquivalents(List<Schema.FieldSetMember> fieldSetFields) {
    	List<String> dataTypes = new List<String>();
    	for(Schema.FieldSetMember field : fieldSetFields) {
			dataTypes.add(getLightningDatatypeEquivalent(field));
		}
    	return dataTypes;
	}

	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    @TestVisible
    global static String getDatePicklist(String fieldSetName) {
	    leankor.DescribeSchema ds = new leankor.DescribeSchema();
		List<Schema.FieldSetMember> fieldSetFields = ds.getFieldSetFields('leankor__Expense__c', fieldSetName);
		//Map<String, Schema.SObjectField> fieldMap = ds.getObjectFields('leankor__Expense__c');
		List<Row> rows = new List<Row>();
		/*for(Schema.FieldSetMember field : fieldSetFields) {
			switch on field.getType() {
			    when Date {
			    	rows.add(new Row(field.getLabel(), field.getFieldPath(), 'date-local'));
			    }
			    when DateTime {
			    	rows.add(new Row(field.getLabel(), field.getFieldPath(), 'date'));
			    }
			}
		}*/
		return JSON.serialize(rows);
	}

	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    @TestVisible
    global static List<String> getFieldNames(String fieldSetName) {
	    leankor.DescribeSchema ds = new leankor.DescribeSchema();
		List<Schema.FieldSetMember> fieldSetFields = ds.getFieldSetFields('leankor__Expense__c', fieldSetName);
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember field : fieldSetFields) {  
		    fieldNames.add(field.getFieldPath());
		}
		return fieldNames;
	}

	//09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    @TestVisible
    global static List<String> getFieldDataTypes(String fieldSetName) {
	    leankor.DescribeSchema ds = new leankor.DescribeSchema();
		List<Schema.FieldSetMember> fieldSetFields = ds.getFieldSetFields('leankor__Expense__c', fieldSetName);
		List<String> dataTypes = getLightningDatatypeEquivalents(fieldSetFields);
		return dataTypes;
	}

	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static String getProjectCurrencyIsoCode(String projectId) {
		String projectCurrencyIsoCode = '';
		if (UserInfo.isMultiCurrencyOrganization()) {
			// change the value of projectId depending on the sObject type of the projectId parameter
			projectId = getProjectId(projectId);

			leankor__ProjectRoom__c projectCurrency = Database.query('Select CurrencyIsoCode From leankor__ProjectRoom__c Where Id = :projectId');
			if (projectCurrency != null)  {
				projectCurrencyIsoCode = (String)projectCurrency.get('CurrencyIsoCode');
			}
		}
		return projectCurrencyIsoCode;
	}

	// Create a set of forecast records by cloning existing records
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static List<leankor__Expense__c> cloneForecastRecords(String projectId, Date forecastDate) {
		
		//Check CRUD / FLC behavior
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!expenseBehaviour.isCreateable() ||
			!expenseBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
		
		// change the value of projectId depending on the sObject type of the projectId parameter
		projectId = getProjectId(projectId);

		Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();
		Boolean currentForecastFound = true;
		List<SObject> clonedForecasts = new List<SObject>();
		List<SObject> currentForecasts = readRecords(projectId, true, true, false, true); // get current forecast items
		
		// if no record is queried
		if (currentForecasts.isEmpty()) {
			currentForecasts = readRecords(projectId, true, false, false, false); // get original budget items
			currentForecastFound = false;
		}		

		List<leankor__ExpenseResourceAssignment__c> expenseResourceAssignments = new List<leankor__ExpenseResourceAssignment__c>();

		// key = leankor__Category__c + leankor__ExpenseSubCategory__c + leankor__ExpenseAccount__c
		Map<String, SObject> resourceFinancialForecasts = calculateProjectFinancials(projectId, isMultiCurrency, expenseResourceAssignments);

		if (!currentForecasts.isEmpty() || !resourceFinancialForecasts.isEmpty()) {			
			Set<String> accountForecasts = new Set<String>();				
			String expenseKey = '';	

			List<Id> forecastIds = new List<Id>(); // to hold clonedForecasts Ids

			//--- create a map of ProjectFinancials with Id as the key
			List<leankor__ProjectFinancial__c> projectFinancialRecords = new List<leankor__ProjectFinancial__c>
				([Select Id, 
						Name,
						leankor__Project__c,
						leankor__Project__r.leankor__Portfolio__c
					From leankor__ProjectFinancial__c
					Where leankor__Project__c = :projectId
						And leankor__ProjectFinancial__c.leankor__AllowFinancialEntry__c = true
					With Security_Enforced
					Limit 50000]);

			//--- remove orphaned records
			Map<Id, leankor__ProjectFinancial__c> projectFinancials = new Map<Id, leankor__ProjectFinancial__c>();
			for (leankor__ProjectFinancial__c projectFinancialRecord : projectFinancialRecords) {
				if (projectFinancialRecord.leankor__Project__c != null
				&& projectFinancialRecord.leankor__Project__r.leankor__Portfolio__c != null) {
					projectFinancials.put(projectFinancialRecord.Id, projectFinancialRecord);
				}
			}
			//---

			Savepoint sp = Database.setSavepoint();				
			try {								
				// create a list of cloned forecast
				for (SObject currentForecast : currentForecasts) {
					// clone forecast records that are not generated by the system
					if (!(Boolean)currentForecast.get('leankor__IsGenerated__c')) {					
						Date currentForecastDate = (Date)currentForecast.get('leankor__Date__c');
						String currentForecastCategory = (String)currentForecast.get('leankor__Category__c');
						String currentForecastExpenseSubCategory = (String)currentForecast.get('leankor__ExpenseSubCategory__c');
						String currentForecastExpenseAccount = (String)currentForecast.get('leankor__ExpenseAccount__c');
						String currentForecastProjectFinancial = (String)currentForecast.get('leankor__ProjectFinancial__c');

						// expenseKey = String.valueOf(currentForecastDate.year())
						// 	+ String.valueOf(currentForecastDate.month())
						// 	+ (String.isBlank(currentForecastCategory) ? '' : currentForecastCategory)
						// 	+ (String.isBlank(currentForecastExpenseSubCategory) ? '' : currentForecastExpenseSubCategory)
						// 	+ (String.isBlank(currentForecastExpenseAccount) ? '' : currentForecastExpenseAccount);

						expenseKey = String.valueOf(currentForecastDate.year())
							+ String.valueOf(currentForecastDate.month())
							+ (String.isBlank(currentForecastProjectFinancial) ? '' : currentForecastProjectFinancial);
						
						SObject clonedForecast = new leankor__Expense__c();

						Boolean isContainsKey = resourceFinancialForecasts.containsKey(expenseKey);
						
						clonedForecast.put('leankor__ExpenseAmount__c', isContainsKey 
							? (Decimal)resourceFinancialForecasts.get(expenseKey).get('leankor__ExpenseAmount__c') 
							: (Decimal)currentForecast.get('leankor__ExpenseAmount__c'));

						clonedForecast.put('leankor__ExpenseAllocationHours__c', isContainsKey 
							? (Decimal)resourceFinancialForecasts.get(expenseKey).get('leankor__ExpenseAllocationHours__c') 
							: (Decimal)currentForecast.get('leankor__ExpenseAllocationHours__c'));

						clonedForecast.put('leankor__ExpenseHours__c', isContainsKey 
							? (Decimal)resourceFinancialForecasts.get(expenseKey).get('leankor__ExpenseHours__c') 
							: (Decimal)currentForecast.get('leankor__ExpenseHours__c'));															

						//clonedForecast.put('leankor__IsGenerated__c', resourceFinancialForecasts.containsKey(expenseKey) 
						//	? true : false);
	
						if (isMultiCurrency) {
                            clonedForecast.put('CurrencyIsoCode', isContainsKey 
								? (String)resourceFinancialForecasts.get(expenseKey).get('CurrencyIsoCode')
								: (String)currentForecast.get('CurrencyIsoCode'));
						}						
												
						clonedForecast.put('Name', (String)currentForecast.get('Name'));
						clonedForecast.put('RecordTypeId', (Id)currentForecast.get('RecordTypeId'));
						clonedForecast.put('leankor__ApprovingManager__c', (Id)currentForecast.get('leankor__ApprovingManager__c'));
						clonedForecast.put('leankor__Chargeable__c', (Boolean)currentForecast.get('leankor__Chargeable__c')); 
						clonedForecast.put('leankor__ContactSubmittingExpense__c', (Id)currentForecast.get('leankor__ContactSubmittingExpense__c')); 
						clonedForecast.put('leankor__Date__c', (Date)currentForecast.get('leankor__Date__c')); 
						clonedForecast.put('leankor__DeliveredProduct__c', (Id)currentForecast.get('leankor__DeliveredProduct__c')); 
						clonedForecast.put('leankor__ExpenseCode__c', (String)currentForecast.get('leankor__ExpenseCode__c'));
						clonedForecast.put('leankor__IncludesTax__c', (Boolean)currentForecast.get('leankor__IncludesTax__c')); 
						clonedForecast.put('leankor__Invoiced__c', (Boolean)currentForecast.get('leankor__Invoiced__c')); 
						clonedForecast.put('leankor__KanbanCard__c', (Id)currentForecast.get('leankor__KanbanCard__c')); 
						clonedForecast.put('leankor__LongDescription__c', (String)currentForecast.get('leankor__LongDescription__c')); 
						clonedForecast.put('leankor__PaymentNotes__c', (String)currentForecast.get('leankor__PaymentNotes__c')); 
						clonedForecast.put('leankor__PaymentReceived__c', (Boolean)currentForecast.get('leankor__PaymentReceived__c')); 
						clonedForecast.put('leankor__PersonSubmittingExpense__c', (Id)currentForecast.get('leankor__PersonSubmittingExpense__c')); 
						clonedForecast.put('leankor__PlannedExpense__c', (Id)currentForecast.get('leankor__PlannedExpense__c')); 
						clonedForecast.put('leankor__Portfolio__c', (Id)currentForecast.get('leankor__Portfolio__c')); 
						clonedForecast.put('leankor__ProjectBoard__c', (Id)currentForecast.get('leankor__ProjectBoard__c')); 
						clonedForecast.put('leankor__Project__c', (Id)currentForecast.get('leankor__Project__c')); 
						clonedForecast.put('leankor__Reimbursable__c', (Boolean)currentForecast.get('leankor__Reimbursable__c')); 
						clonedForecast.put('leankor__IsCapEx__c',  (Boolean)currentForecast.get('leankor__IsCapEx__c')); 
						clonedForecast.put('leankor__Category__c', currentForecastCategory); 
						clonedForecast.put('leankor__ExpenseSubCategory__c', currentForecastExpenseSubCategory); 
						clonedForecast.put('leankor__ExpenseAccount__c', currentForecastExpenseAccount); 
						clonedForecast.put('leankor__ProjectFinancial__c', currentForecastProjectFinancial); 
						clonedForecast.put('leankor__Plan__c', true);
						clonedForecast.put('leankor__IsForecast__c', true);
						clonedForecast.put('leankor__IsPrevForecast__c', false);
						clonedForecast.put('leankor__IsCurrForecast__c', true);
						clonedForecast.put('leankor__ForecastDate__c', forecastDate);
						clonedForecast.put('leankor__OriginalPlannedExpense__c', currentForecastFound 
							? (Id)currentForecast.get('leankor__OriginalPlannedExpense__c') : (Id)currentForecast.get('Id'));	
						clonedForecasts.add(clonedForecast);
						
						accountForecasts.add(expenseKey);
					}
				}				
				// add non-existing calculated monthly financial resources to clonedForecasts 
				Id recordTypeId = recordTypeIdNameMap().get('ProjectExpense');
												
				for (String resourceFinancialForecast : resourceFinancialForecasts.keySet()) {
					if (!accountForecasts.contains(resourceFinancialForecast)) {						
						SObject clonedForecast = resourceFinancialForecasts.get(resourceFinancialForecast);
						// String clonedForecastName = (String)clonedForecast.get('leankor__Category__c');

						String clonedForecastName = '';
						String projectFinancialId = (String)clonedForecast.get('leankor__ProjectFinancial__c');

						if (String.isNotBlank(projectFinancialId) && projectFinancials.containsKey(projectFinancialId)) { 
							clonedForecastName = projectFinancials.get(projectFinancialId).Name;
						} else {
							clonedForecast.put('leankor__ProjectFinancial__c', null);
						}
						
						clonedForecast.put('Name', String.isBlank(clonedForecastName) ? 'Undefined Account' : clonedForecastName);
						clonedForecast.put('RecordTypeId', recordTypeId);
						clonedForecast.put('leankor__Plan__c', true);
						clonedForecast.put('leankor__IsForecast__c', true);
						clonedForecast.put('leankor__IsPrevForecast__c', false);
						clonedForecast.put('leankor__IsCurrForecast__c', true);
						clonedForecast.put('leankor__IsGenerated__c', true);
						clonedForecast.put('leankor__ForecastDate__c', forecastDate);
						clonedForecasts.add(clonedForecast);
					}
				}		                    
				
				List<leankor__Expense__c> previousForecasts = readRecords(projectId, true, true, true, false); // get previous forecast items
				for (Integer i = 0; i < previousForecasts.size(); i++) {
					previousForecasts[i].leankor__Plan__c = true;
					previousForecasts[i].leankor__IsForecast__c = true;
					previousForecasts[i].leankor__IsPrevForecast__c = false;
					previousForecasts[i].leankor__IsCurrForecast__c = false;	
				}
				
				// update the list of existing forecast 
				if (currentForecastFound && !currentForecasts.isEmpty()) {
					for (SObject currentForecast : currentForecasts) {
						currentForecast.put('leankor__Plan__c', true);
						currentForecast.put('leankor__IsForecast__c', true);
						currentForecast.put('leankor__IsPrevForecast__c', true);
						currentForecast.put('leankor__IsCurrForecast__c', false);
					}
					update currentForecasts;
				}
				
				if (!previousForecasts.isEmpty()) {
					update previousForecasts;
				}

				if (!clonedForecasts.isEmpty()) {
					insert clonedForecasts;

					Map<String, Id> clonedForecastRecords = new Map<String, Id>();

					for (SObject obj : clonedForecasts) {				
						String projectFinancial = (String)obj.get('leankor__ProjectFinancial__c');
						String clonedForecastDate = String.valueOf((Date)obj.get('leankor__Date__c'));
						String clonedForecastKey = String.isBlank(projectFinancial) 
								? clonedForecastDate 
								: clonedForecastDate + projectFinancial;

						clonedForecastRecords.put(clonedForecastKey, obj.Id);

						forecastIds.add(obj.Id);
					}
					
					for (leankor__ExpenseResourceAssignment__c expenseResourceAssignment : expenseResourceAssignments) {
						String expenseResourceAssignmentDate = String.valueOf(expenseResourceAssignment.leankor__Date__c);
						expenseResourceAssignment.leankor__Expense__c = expenseResourceAssignment.leankor__ProjectFinancial__c != null 
								&& projectFinancials.containsKey(expenseResourceAssignment.leankor__ProjectFinancial__c)
								? clonedForecastRecords.get(expenseResourceAssignmentDate + expenseResourceAssignment.leankor__ProjectFinancial__c)
								: clonedForecastRecords.get(expenseResourceAssignmentDate);
					}

					insert expenseResourceAssignments;
				}			
			} catch(DmlException e) {
				Database.rollback(sp);		
			    throw e;
			} catch(Exception e) {
				throw e; 
			}

			//Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in try/Catch block.
			try{
				if (!clonedForecasts.isEmpty()) {
					leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
						
					pe.leankor__EventCategory__c = 'Creating';
					pe.leankor__EventName__c = 'EndCreateProjectFinancialForecast';
					pe.leankor__IsAPIGenerated__c = false;  // set true if coming from Leankor API
					pe.leankor__ProjectID__c = projectId; //{Project Id, force.com ID, of the forecasted expense};
					pe.leankor__UserID__c = UserInfo.getUserId();
					pe.leankor__JSONPayload__c = JSON.serialize(forecastIds); // List of forecast Ids
				
					// Call method to publish events
					Database.SaveResult pe_result = EventBus.publish(pe);
					// quick error processing, no need to Rollback
					if (!pe_result.isSuccess()){
						for(Database.Error err : pe_result.getErrors()) {
							System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
						}
						// continue on because a failed platform event is no big deal ; do NOT rollback
					}
				}
			}catch(Exception ex){
				System.debug('ERROR :: '+ex.getMessage());
			}
		}

		return clonedForecasts;
	}

	private static Map<String, Id> recordTypeIdNameMap(){
		Map<String, Id> recordTypeMap = new Map<String, Id>();
		for (RecordType record : [Select DeveloperName,
										Id 
									From RecordType 
									Where SobjectType = 'leankor__Expense__c' 
										And IsActive = true]) {
			recordTypeMap.put(record.DeveloperName, record.Id);
		}
		return recordTypeMap;	
	}

	// queries and returns unique forecast dates in a given project
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static List<Date> getForecastDates(Id projectId) {
		List<Date> forecastDates = new List<Date>();
		try {
			// change the value of projectId depending on the sObject type of the projectId parameter
			projectId = getProjectId(projectId);

			AggregateResult[] groupedResults = [Select leankor__ForecastDate__c
													From leankor__Expense__c
													Where leankor__IsForecast__c = true
														And leankor__Project__c =:projectId
													With Security_Enforced
													Group By leankor__ForecastDate__c
													Order By leankor__ForecastDate__c Desc];						
			for (AggregateResult ar : groupedResults)  {
			    forecastDates.add((Date)ar.get('leankor__ForecastDate__c'));
			}
		} catch (Exception e) {		
			throw e; 
		}
		
		return forecastDates;
	}

	// calculates project monthly financials and returns a map of the financials
	// Only accommodating the Days unit for now
	// TODO: Minutes, Hours, Weeks, Months, Years
	@TestVisible
	public static Map<String, SObject> calculateProjectFinancials(Id projectId, Boolean isMultiCurrency, List<leankor__ExpenseResourceAssignment__c> expenseResourceAssignments) {
		Map<String, SObject> financialRecords = new Map<String, SObject>();
		
		leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
		Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 
		    ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
		Integer workingHoursPerDay = leanConstant.leankor__WorkingHoursPerDay__c == null || leanConstant.leankor__WorkingHoursPerDay__c < 0
		    ? 8 : leanConstant.leankor__WorkingHoursPerDay__c.intValue();
				
		// utility for calculating 5-day workweek
		Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
			    
		Map<Id, SObject> resourceCurrencies = new Map<Id, SObject>();
		Map<Id, SObject> projectCurrencies = new Map<Id, SObject>();
		Map<String, SObject> currencyTypes = new Map<String, SObject>();
		SObject corporateCurrencyType;

		String projectCurrencyCode = '';
		String corporateCurrencyCode = '';
		Double projectCurrencyRate = 1;
		Double corporateCurrencyRate = 1;
							
		try {		    
			if (isMultiCurrency) {
				resourceCurrencies = new Map<Id, SObject>(Database.query
						('Select' 
							+ ' Id, '
							+ ' CurrencyIsoCode'
							+ ' From leankor__ResourceAssignment__c' 
							+ ' Where leankor__KanbanCard__r.leankor__isRecordDeleted__c = false'
							+ ' And leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c = :projectId'
							+ ' And (leankor__ExternalHourlyRate__c > 0 Or leankor__InternalHourlyRate__c > 0)'
							+ ' Limit 50000'));
				
				projectCurrencies = new Map<Id, SObject>(Database.query
						('Select' 
							+ ' Id,'
							+ ' CurrencyIsoCode' 
							+ ' From leankor__ProjectRoom__c' 
							+ ' Where Id = :projectId'
							+ ' Limit 1'));
							                                                            				 
				 currencyTypes = getCurrencyTypes();
				 if (projectCurrencies.containsKey(projectId)) {				 	
				 	projectCurrencyCode = (String)projectCurrencies.get(projectId).get('CurrencyIsoCode');
				 	projectCurrencyRate = currencyTypes.containsKey(projectCurrencyCode) ? (Double)currencyTypes.get(projectCurrencyCode).get('ConversionRate') : 1;
				 }
                 
				 
				 corporateCurrencyType = getCorporateCurrencyType(currencyTypes);
				 if (corporateCurrencyType != null) {
				 	corporateCurrencyCode = (String)corporateCurrencyType.get('IsoCode');
				 	corporateCurrencyRate = (Double)corporateCurrencyType.get('ConversionRate');
				 }
			}

			//--- create a map of ProjectFinancials with Name as the key
			List<leankor__ProjectFinancial__c> projectFinancialRecords = new List<leankor__ProjectFinancial__c>
				([Select Id, 
						Name,
						leankor__Project__c,
						leankor__Project__r.leankor__Portfolio__c
					From leankor__ProjectFinancial__c
					Where leankor__Project__c =:projectId
						And leankor__ProjectFinancial__c.leankor__AllowFinancialEntry__c = true
					With Security_Enforced
					Order By leankor__Sequence__c
					Limit 50000]);

			//--- remove orphaned records					
			Map<String, Id> projectFinancials = new Map<String, Id>();
			for (leankor__ProjectFinancial__c projectFinancialRecord : projectFinancialRecords) {
				if (projectFinancialRecord.leankor__Project__c != null
				&& projectFinancialRecord.leankor__Project__r.leankor__Portfolio__c != null) {
					projectFinancials.put(projectFinancialRecord.Name, projectFinancialRecord.Id);
				}
			}
			//---

			//--- replace ResourceAssignment.ProjectFinancial with the ProjectFinancial.ProjectFinancial based on the searched Name
			//--- process only non-orphaned/not soft deleted records
			List<leankor__ResourceAssignment__c> resourceAssignmentRecords = new List<leankor__ResourceAssignment__c>
				([Select Id,
							Name, 
							leankor__KanbanCard__c, 
							leankor__KanbanCard__r.leankor__DurationUnits__c,
							leankor__KanbanCard__r.leankor__EstimatedDuration__c,
							leankor__KanbanCard__r.leankor__StartDateTime__c, 
							leankor__KanbanCard__r.leankor__DueDateTime__c,
							leankor__KanbanCard__r.leankor__ValueStream__c,
							leankor__KanbanCard__r.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,
							leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
							leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c,
							leankor__AssignedTo__c, 
							leankor__PercentAllocation__c, 
							leankor__ExpenseCategory__c, 
							leankor__ExpenseSubCategory__c,
							leankor__ExpenseAccount__c,
							leankor__ExternalHourlyRate__c, 
							leankor__InternalHourlyRate__c,
							leankor__ResourceType__c,
							leankor__ProjectFinancial__c,
							leankor__ProjectFinancial__r.Name,
							leankor__Quantity__c,
							leankor__Amount__c,
							leankor__CompletedDate__c,
							leankor__PercentCompleted__c
						From leankor__ResourceAssignment__c 
						Where leankor__KanbanCard__r.leankor__isRecordDeleted__c = false
							And leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c =:projectId 
							And (leankor__ExternalHourlyRate__c > 0 Or leankor__InternalHourlyRate__c > 0) 
						With Security_Enforced
						Order By leankor__KanbanCard__r.leankor__StartDateTime__c 
						Limit 50000]);

			List<leankor__ResourceAssignment__c> resourceAssignments = new List<leankor__ResourceAssignment__c>();
			for (leankor__ResourceAssignment__c resourceAssignmentRecord : resourceAssignmentRecords) {
				if (resourceAssignmentRecord.leankor__KanbanCard__r.leankor__ValueStream__c != null
				&& resourceAssignmentRecord.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
				&& resourceAssignmentRecord.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c != null) {
					
					Id projectFinancialId = resourceAssignmentRecord.leankor__ProjectFinancial__c;
					if (projectFinancialId != null) {
						projectFinancialId = projectFinancials.get(resourceAssignmentRecord.leankor__ProjectFinancial__r.Name);
					}

					resourceAssignmentRecord.leankor__ProjectFinancial__c = projectFinancialId;
					resourceAssignments.add(resourceAssignmentRecord);
				}
			}
			//---

			for (leankor__ResourceAssignment__c resourceAssignment : resourceAssignments) {
				If (String.isNotBlank(resourceAssignment.leankor__AssignedTo__c) 
				|| String.isNotBlank(resourceAssignment.leankor__ResourceType__c)
				&& String.isNotBlank(resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__c)
				&& String.isNotBlank(resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c)
				&& String.isNotBlank(resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c)) {
			         	
					
					String resourceCurrencyCode = '';
					Double resourceCurrencyRate = 1;
					
					if (isMultiCurrency && resourceCurrencies.containsKey(resourceAssignment.Id)) {
						resourceCurrencyCode = (String)resourceCurrencies.get(resourceAssignment.Id).get('CurrencyIsoCode');
				 		resourceCurrencyRate = currencyTypes.containsKey(resourceCurrencyCode) ? (Double)currencyTypes.get(resourceCurrencyCode).get('ConversionRate') : 1;						
					}
					
					// Only accommodating the Days unit and InternalHourlyRate for now
					// TODO: Minutes, Hours, Weeks, Months, Years
					Decimal allocatedLaborHoursPerDay = (resourceAssignment.leankor__PercentAllocation__c / 100) * workingHoursPerDay;					
					Decimal allocatedLaborCostPerDay = allocatedLaborHoursPerDay
						* (resourceAssignment.leankor__InternalHourlyRate__c == null ? 0 : resourceAssignment.leankor__InternalHourlyRate__c)
						/ resourceCurrencyRate
						* projectCurrencyRate;

				    Date kanbanCardStartDate = resourceAssignment.leankor__KanbanCard__r.leankor__StartDateTime__c.date();
				    Date kanbanCardDueDate = resourceAssignment.leankor__KanbanCard__r.leankor__DueDateTime__c.date();		
																							
					// iterate the day transactions
					while (kanbanCardStartDate <= kanbanCardDueDate) {

						// iterate the month transactions
					    Integer forecastMonth = kanbanCardStartDate.month();
						Integer kanbanCardMonth = forecastMonth;

						Date dateForecast = date.newinstance(kanbanCardStartDate.year(), forecastMonth, 1);

						String expenseKey = String.valueOf(kanbanCardStartDate.year())
							+ forecastMonth
							+ resourceAssignment.leankor__ProjectFinancial__c;

						Decimal numberOfWorkingDays = 0;
						while (kanbanCardMonth == forecastMonth) {
							if (resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c || workWeek.isWorkingDay(kanbanCardStartDate)) {
					        	numberOfWorkingDays++;
					        	// workWeek.isWorkingDay(resourceAssignment.leankor__KanbanCard__r.leankor__StartDateTime__c.format('EEEE'))) {
					        			        	
					            // calculate expense amount
								SObject expense = new leankor__Expense__c();
								expense.put('leankor__Date__c', date.newinstance(kanbanCardStartDate.year(), kanbanCardStartDate.month(), 1)); // always day 1 of month						
			                    expense.put('leankor__Portfolio__c', resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c);
			                    expense.put('leankor__Project__c', resourceAssignment.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__ProjectRoom__c);		                    
			                    expense.put('leankor__Category__c', resourceAssignment.leankor__ExpenseCategory__c);
			                    expense.put('leankor__ExpenseSubCategory__c', resourceAssignment.leankor__ExpenseSubCategory__c);
			                    expense.put('leankor__ExpenseAccount__c', resourceAssignment.leankor__ExpenseAccount__c);
			                    expense.put('leankor__ExpenseAmount__c', allocatedLaborCostPerDay);
			                    expense.put('leankor__ExpenseAllocationHours__c', allocatedLaborHoursPerDay);
			                    expense.put('leankor__ExpenseHours__c', workingHoursPerDay);
								expense.put('leankor__ProjectFinancial__c', resourceAssignment.leankor__ProjectFinancial__c);
								
								if (isMultiCurrency) {
									expense.put('CurrencyIsoCode', projectCurrencyCode);
								}
											
					        	if (financialRecords.containsKey(expenseKey)) {					        		
					        		financialRecords.get(expenseKey).put('leankor__ExpenseAmount__c', (Decimal)financialRecords.get(expenseKey).get('leankor__ExpenseAmount__c') 
					        			+ (Decimal)expense.get('leankor__ExpenseAmount__c'));					        		
					        		financialRecords.get(expenseKey).put('leankor__ExpenseAllocationHours__c', (Decimal)financialRecords.get(expenseKey).get('leankor__ExpenseAllocationHours__c') 
					        			+ (Decimal)expense.get('leankor__ExpenseAllocationHours__c'));
					        		financialRecords.get(expenseKey).put('leankor__ExpenseHours__c', (Decimal)financialRecords.get(expenseKey).get('leankor__ExpenseHours__c') 
					        			+ (Decimal)expense.get('leankor__ExpenseHours__c'));
					        	} else {
					        		financialRecords.put(expenseKey, expense);		        		
					        	}
					        }

					        kanbanCardStartDate = kanbanCardStartDate.addDays(1);    
							kanbanCardMonth = kanbanCardStartDate.month(); 

					    	if (kanbanCardStartDate > kanbanCardDueDate) {
					    		break;
					    	}
						}

						leankor__ExpenseResourceAssignment__c expenseResourceAssignment = new leankor__ExpenseResourceAssignment__c(
							leankor__ResourceAssignment__c = resourceAssignment.Id,
							leankor__ProjectFinancial__c = resourceAssignment.leankor__ProjectFinancial__c,
							leankor__ResourceType__c = resourceAssignment.leankor__ResourceType__c,
							leankor__AssignedTo__c = resourceAssignment.leankor__AssignedTo__c,
							leankor__ExternalHourlyRate__c = resourceAssignment.leankor__ExternalHourlyRate__c,
							leankor__InternalHourlyRate__c = resourceAssignment.leankor__InternalHourlyRate__c,
							leankor__Quantity__c = resourceAssignment.leankor__Quantity__c,
							leankor__Amount__c = resourceAssignment.leankor__Amount__c,
							leankor__CompletedDate__c = resourceAssignment.leankor__CompletedDate__c,
							leankor__PercentAllocation__c = resourceAssignment.leankor__PercentAllocation__c,
							leankor__PercentCompleted__c = resourceAssignment.leankor__PercentCompleted__c,
							leankor__WorkingHoursPerDay__c = workingHoursPerDay,
							leankor__Date__c = dateForecast,
							leankor__StartDateTime__c = resourceAssignment.leankor__KanbanCard__r.leankor__StartDateTime__c,
							leankor__DueDateTime__c = resourceAssignment.leankor__KanbanCard__r.leankor__DueDateTime__c,
							leankor__ResourceCurrencyRate__c = resourceCurrencyRate,
							leankor__ResourceCurrencyCode__c = resourceCurrencyCode,
							leankor__ProjectCurrencyRate__c = projectCurrencyRate,
							leankor__ProjectCurrencyCode__c = projectCurrencyCode,
							leankor__NumberOfWorkingDays__c = numberOfWorkingDays);

						expenseResourceAssignments.add(expenseResourceAssignment);
					}

				//}
            	}
			}
		} catch (Exception e) {		
			throw e; 
		}

		return financialRecords;
	}
	
	// Queries project financial records filtered by the project id and status fields
	// Returns a list of financial records
	@TestVisible
	public static List<leankor__Expense__c> readRecords(Id projectId, Boolean isPlanning, Boolean isForecast, Boolean isPrevForecast, Boolean isCurrForecast) {	
/*
		return  
			[Select 
					Id, 
					Name, 
					RecordTypeId, 
					leankor__ApprovingManager__c, 
					leankor__Category__c, 
					leankor__Chargeable__c, 
					leankor__ContactSubmittingExpense__c, 
					leankor__Date__c, 
					leankor__DeliveredProduct__c, 
					leankor__ExpenseAmount__c, 
					leankor__ExpenseCode__c, 
					leankor__ExpenseNumber__c, 
					leankor__IncludesTax__c, 
					leankor__Invoiced__c, 
					leankor__KanbanCard__c, 
					leankor__LongDescription__c, 
					leankor__PaymentNotes__c, 
					leankor__PaymentReceived__c, 
					leankor__PersonSubmittingExpense__c, 
					leankor__Plan__c, 
					leankor__PlannedExpense__c, 
					leankor__Portfolio__c, 
					leankor__ProjectBoard__c, 
					leankor__Project__c, 
					leankor__Reimbursable__c, 
					leankor__ForecastDate__c, 
					leankor__IsCurrForecast__c, 
					leankor__IsApproved__c, 
					leankor__IsForecast__c, 
					leankor__IsPrevForecast__c, 
					leankor__IsCapEx__c, 
					leankor__ExpenseSubCategory__c, 
					leankor__ExpenseAccount__c, 
					leankor__OriginalPlannedExpense__c 
				From leankor__Expense__c
				Where leankor__Project__c = :projectId
					And leankor__Plan__c = :isPlanning
					And leankor__IsForecast__c = :isForecast
					And leankor__IsPrevForecast__c = :isPrevForecast
					And leankor__IsCurrForecast__c = :isCurrForecast];
*/
		return Database.query
			('Select ' 
				+ String.join(new List<String>(new DescribeSchema().getObjectFields('leankor__Expense__c').keyset()), ', ') 
				+ ' From leankor__Expense__c' 
				+ ' Where leankor__Project__c = :projectId'
				+ ' And leankor__Plan__c = :isPlanning'
				+ ' And leankor__IsForecast__c = :isForecast'
				+ ' And leankor__IsPrevForecast__c = :isPrevForecast'
				+ ' And leankor__IsCurrForecast__c = :isCurrForecast');			
	}
	
	// Queries project financial records filtered by the project id
	// Returns a list of financial records
	@TestVisible
	public static List<leankor__Expense__c> readRecords(Id projectId) {
		return Database.query
			('Select ' 
				+ String.join(new List<String>(new DescribeSchema().getObjectFields('leankor__Expense__c').keyset()), ', ') 
				+ ' From leankor__Expense__c' 
				+ ' Where leankor__Project__c = :projectId');			
	}
		
	// Queries CurrencyType records in a multi-currency org
	// Returns a map of currency types
	@TestVisible
	private static Map<String, SObject> getCurrencyTypes() {
		Map<String, SObject> currencyTypes = new Map<String, SObject>();
		try {
			// query CurrencyType regardless of status
			List<SObject> currencyTypeRecords = Database.query('Select ISOCode, DecimalPlaces, ConversionRate, IsActive, IsCorporate From CurrencyType');
			for (SObject currencyTypeRecord : currencyTypeRecords) {
				//currencyRate.put((String)currencyType.get('IsoCode'), (Double)currencyType.get('ConversionRate'));
				currencyTypes.put((String)currencyTypeRecord.get('IsoCode'), currencyTypeRecord);
			}
		} catch (Exception e) {		
			throw e; 
		}		
		return currencyTypes;
	}

	// Gets the corporate currency from a given map of currency types
	// Returns an SObject of currency type
	@TestVisible
	private static SObject getCorporateCurrencyType(Map<String, SObject> currencyTypes) {
		SObject corporateCurrencyType;
		try {
			for (String currencyType : currencyTypes.keySet()) {			
				if ((Boolean)currencyTypes.get(currencyType).get('IsCorporate')) {
					corporateCurrencyType = currencyTypes.get(currencyType);
					break;
				}
			}	
		} catch (Exception e) {		
			throw e; 
		}
		return corporateCurrencyType;
	}

	// Gets the project id given a string record id of an SObject
	// Returns a project id of the SObject
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static String getProjectId(String projectId) {
		//Added Security code for sentize user Input
		if ((String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')
            &&(Util.getSObjectName(projectId) != 'leankor__ValueStream__c')
            &&(Util.getSObjectName(projectId) != 'leankor__KanbanCard__c')){
                throw new Util.LeanException('Error: Invalid input');
        }

		// select the query depending on the sObject type of the projectId parameter
		// supported sObject types are leankor__ProjectRoom__c, leankor__ValueStream__c, leankor__KanbanCard__c
		switch on Util.getSObjectName(projectId) {
			when 'leankor__ProjectRoom__c' {
				return [Select Id 
							From leankor__ProjectRoom__c 
							Where Id =:projectId
							With Security_Enforced].Id;
			}
			when 'leankor__ValueStream__c' {
				return [Select leankor__ProjectRoom__c 
							From leankor__ValueStream__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ProjectRoom__c;		
			}
			when 'leankor__KanbanCard__c' {
				return [Select leankor__ValueStream__r.leankor__ProjectRoom__c 
							From leankor__KanbanCard__c 
							Where Id =:projectId
							With Security_Enforced].leankor__ValueStream__r.leankor__ProjectRoom__c;
			}
			when else {
				return '';
			}
		}
	}

	// Gets the project financial info such as 
	//    project name, project id, valuestream id and kanbancard id given a string record id of an SObject
	// Returns a json string
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
	@TestVisible
	global static String getProjectInfo(String recordId) {
		//Added Security code for sentize user Input
		if ((String.isNotBlank(recordId) && Util.getSObjectName(recordId) != 'leankor__ProjectRoom__c')
            &&(Util.getSObjectName(recordId) != 'leankor__ValueStream__c')
            &&(Util.getSObjectName(recordId) != 'leankor__KanbanCard__c')){
                throw new Util.LeanException('Error: Invalid input');
        }
		Map<String, String> mapProjectInfo = new Map<String, String>();

		String folderId = '';
		String folderName = '';
		String projectId = '';
		String projectName = '';
		String valueStreamId = '';
		String valueStreamName = '';
		String kanbanCardId = '';
		String kanbanCardName = '';

		// select the query depending on the sObject type of the recordId parameter
		// supported sObject types are leankor__ProjectRoom__c, leankor__ValueStream__c, leankor__KanbanCard__c
		switch on Util.getSObjectName(recordId) {
			when 'leankor__ProjectRoom__c' {
				leankor__ProjectRoom__c projectRoom = 
					[Select Id, 
							Name, 
							leankor__Portfolio__c, 
							leankor__Portfolio__r.Name 
						From leankor__ProjectRoom__c 
						Where Id =:recordId
						With Security_Enforced];
				
				if (projectRoom != null) {
					folderId = projectRoom.leankor__Portfolio__c;
					folderName = projectRoom.leankor__Portfolio__r.Name;
					projectId = projectRoom.Id;
					projectName = projectRoom.Name;
				}
			}
			when 'leankor__ValueStream__c' {
				leankor__ValueStream__c valueStream = 
					[Select Id, 
							Name, 
							leankor__ProjectRoom__c, 
							leankor__ProjectRoom__r.Name, 
							leankor__ProjectRoom__r.leankor__Portfolio__c, 
							leankor__ProjectRoom__r.leankor__Portfolio__r.Name 
						From leankor__ValueStream__c 
						Where Id =:recordId
						With Security_Enforced];

				if (valueStream != null) {
					folderId = valueStream.leankor__ProjectRoom__r.leankor__Portfolio__c;
					folderName = valueStream.leankor__ProjectRoom__r.leankor__Portfolio__r.Name;
					projectId = valueStream.leankor__ProjectRoom__c;
					projectName = valueStream.leankor__ProjectRoom__r.Name;
					valueStreamId = valueStream.Id;
					valueStreamName = valueStream.Name;
				}
			}
			when 'leankor__KanbanCard__c' {
				leankor__KanbanCard__c kanbanCard = 
					
				[Select Id, 
						Name,
						leankor__ValueStream__c,
						leankor__ValueStream__r.Name,
						leankor__ValueStream__r.leankor__ProjectRoom__c,
						leankor__ValueStream__r.leankor__ProjectRoom__r.Name,
						leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c,
						leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__r.Name
					From leankor__KanbanCard__c 
					Where Id =:recordId
					With Security_Enforced];

				if (kanbanCard != null) {
					folderId = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c;
					folderName = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__r.Name;
					projectId = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
					projectName = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__r.Name;
					valueStreamId = kanbanCard.leankor__ValueStream__c;
					valueStreamName = kanbanCard.leankor__ValueStream__r.Name;
					kanbanCardId = kanbanCard.Id;
					kanbanCardName = kanbanCard.Name;
				}
			}
		}
		
		mapProjectInfo.put('folderId', folderId);
		mapProjectInfo.put('folderName', folderName);
		mapProjectInfo.put('projectId', projectId);
		mapProjectInfo.put('projectName', projectName);
		mapProjectInfo.put('valueStreamId', valueStreamId);
		mapProjectInfo.put('valueStreamName', valueStreamName);
		mapProjectInfo.put('kanbanCardId', kanbanCardId);
		mapProjectInfo.put('kanbanCardName', kanbanCardName);

		return JSON.serialize(mapProjectInfo);
	}

    //public class FinancialDataTableControllerException extends Exception {}
	
	// 29/09/2020 - This method used for get custom labels translation values lightning component.
	//09/09/2021 : Changes Public method to Global for release update.
	@AuraEnabled
    global static Map<String, String> getLabelsForConsumers(List<String> componentName) {
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar'};
		for (String customLabel : componentName) {
			consumers.add(customLabel);
		}
        return leankor.LabelProvider.getLabelsForConsumers(consumers);
    }
    
    //16/Aug/2023 : Method for cloning the ProjectFinancial Record on target Project while clone Project from UI.
	public static Map<String, String> createProjectFinancial(String sourceProjectId, String targetProjectId, Boolean cloneCustomFields){
		if (!leankor__ProjectFinancial__c.sObjectType.getDescribe().isAccessible() ||
			!leankor__ProjectFinancial__c.sObjectType.getDescribe().isCreateable() ||
			!leankor__ProjectFinancial__c.sObjectType.getDescribe().isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		Set<Schema.DisplayType> allowedDataTypes = new Set<Schema.DisplayType>{
																			Schema.DisplayType.BOOLEAN,
																			Schema.DisplayType.CURRENCY,
																			Schema.DisplayType.DATE,
																			Schema.DisplayType.DOUBLE,
																			Schema.DisplayType.PICKLIST,
																			Schema.DisplayType.REFERENCE,
																			Schema.DisplayType.STRING,
																			Schema.DisplayType.URL,
																			Schema.DisplayType.PERCENT,
                                                                            Schema.DisplayType.DATETIME
																			};

		Map<String, String> oldToNewIdMap = new Map<String, String>();
		String customFields = '';
		if (cloneCustomFields == true) {
			Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__ProjectFinancial__c');
			Boolean isFirst = true;
			for (String singleCustomField : fieldMapKanbanCardForClone.keySet()) {
				Schema.SObjectField field = fieldMapKanbanCardForClone.get(singleCustomField);
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				if(allowedDataTypes.contains(fieldDescribe.getType()) && fieldDescribe.isUpdateable()){
					if (isFirst) {
						customFields += ',';
					}
					customFields =  customFields + singleCustomField +',';
					isFirst = false;
				}
			}
			
			if (!String.isBlank(customFields)) {
				customFields = customFields.removeEnd(',');
			}
		}
		String dynamicQuery = 'Select Id, ' + 
									'Name, ' + 
									'leankor__AllowFinancialEntry__c, ' + 
									'leankor__FinancialAccount__c, ' + 
									'leankor__FinancialBreakdownStructure__c, ' + 
									'leankor__Order__c, ' + 
									'leankor__ProjectFinancial__c, ' + 
									'leankor__Project__c, ' + 
									'leankor__Sequence__c ' + customFields +
									' From leankor__ProjectFinancial__c ' + 
									'Where leankor__Project__c = :sourceProjectId ' + 
									'Limit 50000';

		List<leankor__ProjectFinancial__c> projectFinancialRecords = Database.query(dynamicQuery);
		
		List<leankor__ProjectFinancial__c> targetProjectFinancialList = new List<leankor__ProjectFinancial__c>();
		for(leankor__ProjectFinancial__c sourceProjectFinancialRecord :projectFinancialRecords){
			leankor__ProjectFinancial__c targetProjectFinancial = new leankor__ProjectFinancial__c();
			targetProjectFinancial.Name = sourceProjectFinancialRecord.Name;
			targetProjectFinancial.leankor__AllowFinancialEntry__c = sourceProjectFinancialRecord.leankor__AllowFinancialEntry__c;
			targetProjectFinancial.leankor__FinancialAccount__c = sourceProjectFinancialRecord.leankor__FinancialAccount__c != null ? sourceProjectFinancialRecord.leankor__FinancialAccount__c : null;
			targetProjectFinancial.leankor__FinancialBreakdownStructure__c = String.isNotBlank(sourceProjectFinancialRecord.leankor__FinancialBreakdownStructure__c) ? sourceProjectFinancialRecord.leankor__FinancialBreakdownStructure__c : '';
			targetProjectFinancial.leankor__Order__c = sourceProjectFinancialRecord.leankor__Order__c != null ? sourceProjectFinancialRecord.leankor__Order__c : null;
			//05/Sep/2023 : Here we are set null because Parent PF & Child Pf Should in same Project, and Parend PF is not cloned yet.
			targetProjectFinancial.leankor__ProjectFinancial__c = null;
            targetProjectFinancial.leankor__Project__c = String.isNotBlank(sourceProjectFinancialRecord.leankor__Project__c) ? targetProjectId : '';
			targetProjectFinancial.leankor__Sequence__c = sourceProjectFinancialRecord.leankor__Sequence__c != null ? sourceProjectFinancialRecord.leankor__Sequence__c : null;
			
			targetProjectFinancial.leankor__ReferenceSourceId__c = sourceProjectFinancialRecord.Id;
			
			if(!String.isBlank(customFields)){
			Map<String, Object> fieldsToValue = sourceProjectFinancialRecord.getPopulatedFieldsAsMap();
                for (String key : fieldsToValue.keySet()) {	
					//if(key.containsIgnoreCase('test')){	
						if((!key.containsIgnoreCase('leankor__')) && (key.containsIgnoreCase('__c'))){						
				    	targetProjectFinancial.put(key, fieldsToValue.get(key));	
					}			
			    }
			}

			targetProjectFinancialList.add(targetProjectFinancial);
		}
		try{
			if(targetProjectFinancialList.size()>0){
				insert targetProjectFinancialList;
				for(Integer i = 0; i < projectFinancialRecords.size(); i++){
					oldToNewIdMap.put(projectFinancialRecords[i].Id, targetProjectFinancialList[i].Id);
				}
                
                //05/Sep/2023 : Updating ProjectFinancial field with newly cloned Parent PF record.
				List<leankor__ProjectFinancial__c> updateProjectFinancial = new List<leankor__ProjectFinancial__c>();
				for(Integer i = 0; i < projectFinancialRecords.size(); i++){
					if(projectFinancialRecords[i].leankor__ProjectFinancial__c != null){
						leankor__ProjectFinancial__c financialRecord = new leankor__ProjectFinancial__c();
						financialRecord.Id = targetProjectFinancialList[i].Id;
						financialRecord.leankor__ProjectFinancial__c = oldToNewIdMap.get(projectFinancialRecords[i].leankor__ProjectFinancial__c);
						updateProjectFinancial.add(financialRecord);
					}
				}
				update updateProjectFinancial;
			}
		}catch(Exception e ){
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return oldToNewIdMap;
	}

	public static Map<String, String> getNewProjectFinancial(String valueStreamId){
		String projectId = '';
		Map<String, String> referenceMap = new Map<String, String>();

		if(String.isNotBlank(valueStreamId)) {
            projectId = [Select Id, 
                                Name, 
                                leankor__ProjectRoom__r.Id 
                            From leankor__ValueStream__c 
                            Where Id =: valueStreamId 
                                And leankor__isRecordDeleted__c = false
							With Security_Enforced].leankor__ProjectRoom__r.Id;
        }

		for(leankor__ProjectFinancial__c projectFinancialRecords : [Select Id,
																			leankor__ReferenceSourceId__c,
																			leankor__ProjectFinancial__c,
																			leankor__Project__c
																		From leankor__ProjectFinancial__c
																		Where leankor__Project__c =: projectId
																		With Security_Enforced
																		Limit 50000]){
			referenceMap.put(projectFinancialRecords.leankor__ReferenceSourceId__c, projectFinancialRecords.Id);
		}
		return referenceMap;
	}
}