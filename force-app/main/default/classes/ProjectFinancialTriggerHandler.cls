public with sharing class ProjectFinancialTriggerHandler {
	private boolean bypassTrigger = false;
	private final Map<Id, leankor__ProjectFinancial__c> newRecords;
	private final Map<Id, leankor__ProjectFinancial__c> oldRecords;
    private final List<leankor__ProjectFinancial__c> insertRecords;

    public ProjectFinancialTriggerHandler(Map<Id, leankor__ProjectFinancial__c> newRecords, Map<Id, leankor__ProjectFinancial__c> oldRecords, List<leankor__ProjectFinancial__c> insertRecords) {
		this.newRecords = newRecords;
		this.oldRecords = oldRecords;
        this.insertRecords = insertRecords;
    }


	/* set this flag to TRUE if you need to bypass this trigger*/
	public void setBypassTrigger(boolean bypass) {
		this.bypassTrigger = bypass;
	}


	public boolean getBypassTrigger() {
		return bypassTrigger;
	}


    public void executeTrigger(TriggerOperation triggerOperation) {
        if (!bypassTrigger) {
            switch on triggerOperation {
                when BEFORE_INSERT {
                    validateProjectFinancial(this.insertRecords);
                }
                when BEFORE_UPDATE {
                    validateAllowFinancialEntry(this.newRecords, this.oldRecords);
                    validateProjectFinancial(this.newRecords);
                    validateTransaction(this.newRecords, this.oldRecords);
                }
                when BEFORE_DELETE {
                    validateTransaction(this.oldRecords);
                }
            }
        }
    }


	@TestVisible
	private static void validateProjectFinancial(List<leankor__ProjectFinancial__c> newProjectFinancialRecords) {
        // validate associated records within the object
        Map<Id, leankor__ProjectFinancial__c> projectFinancialRecords = readProjectFinancialRecords(getProjectFinancialIds(newProjectFinancialRecords));
        for (leankor__ProjectFinancial__c newProjectFinancialRecord : newProjectFinancialRecords) {
            if (newProjectFinancialRecord.leankor__ProjectFinancial__c != null 
            && projectFinancialRecords.containsKey(newProjectFinancialRecord.leankor__ProjectFinancial__c)) {
                leankor__ProjectFinancial__c projectFinancialRecord = projectFinancialRecords.get(newProjectFinancialRecord.leankor__ProjectFinancial__c);
                if (projectFinancialRecord.leankor__AllowFinancialEntry__c) {
                    newProjectFinancialRecord.leankor__ProjectFinancial__c.addError(projectFinancialRecord.Name + ' allows a financial entry and cannot have a sub-item. Insert is not allowed!');
                }
            }
        }
    }
    

	@TestVisible
	private static void validateProjectFinancial(Map<Id, leankor__ProjectFinancial__c> newProjectFinancialRecords) {
        // validate associated records within the object
        Map<Id, leankor__ProjectFinancial__c> projectFinancialRecords = readProjectFinancialRecords(getProjectFinancialIds(newProjectFinancialRecords.values()));
        for (leankor__ProjectFinancial__c newProjectFinancialRecord : newProjectFinancialRecords.values()) {
            if (newProjectFinancialRecord.leankor__ProjectFinancial__c != null 
            && projectFinancialRecords.containsKey(newProjectFinancialRecord.leankor__ProjectFinancial__c)) {
                leankor__ProjectFinancial__c projectFinancialRecord = projectFinancialRecords.get(newProjectFinancialRecord.leankor__ProjectFinancial__c);
                if (projectFinancialRecord.leankor__AllowFinancialEntry__c) {
                    newProjectFinancialRecord.leankor__ProjectFinancial__c.addError(projectFinancialRecord.Name + ' allows a financial entry and cannot have a sub-item. Update is not allowed!');
                }
            }
        }
    }


	@TestVisible
	private static void validateAllowFinancialEntry(Map<Id, leankor__ProjectFinancial__c> newProjectFinancialRecords, Map<Id, leankor__ProjectFinancial__c> oldProjectFinancialRecords) {
        // validate associated records within the object
        Map<Id, List<leankor__ProjectFinancial__c>> projectFinancials = readProjectFinancials(oldProjectFinancialRecords.keySet());
        for (Id oldProjectFinancialRecordId : oldProjectFinancialRecords.keySet()) {
            leankor__ProjectFinancial__c oldProjectFinancialRecord = oldProjectFinancialRecords.get(oldProjectFinancialRecordId);
            leankor__ProjectFinancial__c newProjectFinancialRecord = newProjectFinancialRecords.get(oldProjectFinancialRecordId);

            if (newProjectFinancialRecord.leankor__AllowFinancialEntry__c <> oldProjectFinancialRecord.leankor__AllowFinancialEntry__c
            && projectFinancials.containsKey(oldProjectFinancialRecordId)) {
                newProjectFinancialRecord.leankor__AllowFinancialEntry__c.addError(oldProjectFinancialRecord.Name + ' has sub-items. Financial entry is not allowed!');
            }
        }
    }


	@TestVisible
	private static void validateTransaction(Map<Id, leankor__ProjectFinancial__c> oldProjectFinancialRecords) {
        // --- code validation to determine if this is a parent
        // --- do not allow deletion if it is a parent
        // validate associated records within the object
        Map<Id, List<leankor__ProjectFinancial__c>> projectFinancials = readProjectFinancials(oldProjectFinancialRecords.keySet());
        for (Id oldProjectFinancialRecordId : oldProjectFinancialRecords.keySet()) {
            if (projectFinancials.containsKey(oldProjectFinancialRecordId)) {
                leankor__ProjectFinancial__c oldProjectFinancialRecord = oldProjectFinancialRecords.get(oldProjectFinancialRecordId);
                oldProjectFinancialRecord.addError(oldProjectFinancialRecord.Name + ' has sub-items. Delete is not allowed!');
            }
        }
        // ---

        // validate associated expense records
        Map<Id, String> projectFinancialExpenseRecords = readExpenses(oldProjectFinancialRecords.keySet());
        for (Id projectFinancialExpenseRecordId : projectFinancialExpenseRecords.keySet()) {
            leankor__ProjectFinancial__c oldProjectFinancialRecord = oldProjectFinancialRecords.get(projectFinancialExpenseRecordId);
            oldProjectFinancialRecord.addError(oldProjectFinancialRecord.Name + ' has financial transactions. Delete is not allowed!');
        }
        // ---
    }


	@TestVisible
    private static void validateTransaction(Map<Id, leankor__ProjectFinancial__c> newProjectFinancialRecords, Map<Id, leankor__ProjectFinancial__c> oldProjectFinancialRecords) {
        // validate associated expense records
        Map<Id, String> projectFinancialExpenseRecords = readExpenses(oldProjectFinancialRecords.keySet());
        for (Id projectFinancialExpenseRecordId : projectFinancialExpenseRecords.keySet()) {
            leankor__ProjectFinancial__c newProjectFinancialRecord = newProjectFinancialRecords.get(projectFinancialExpenseRecordId);
            leankor__ProjectFinancial__c oldProjectFinancialRecord = oldProjectFinancialRecords.get(projectFinancialExpenseRecordId);

            if (newProjectFinancialRecord.leankor__ProjectFinancial__c <> oldProjectFinancialRecord.leankor__ProjectFinancial__c
            || newProjectFinancialRecord.leankor__AllowFinancialEntry__c <> oldProjectFinancialRecord.leankor__AllowFinancialEntry__c) {
                newProjectFinancialRecord.addError(oldProjectFinancialRecord.Name + ' has financial transactions. Update is not allowed!');
            }
        }
    }


	@TestVisible
	private static Set<Id> getProjectFinancialIds(List<leankor__ProjectFinancial__c> newProjectFinancialRecords) {
        Set<Id> storeProjectFinancialIds = new Set<Id>();
        
        for (leankor__ProjectFinancial__c newProjectFinancialRecord : newProjectFinancialRecords) {
            if (newProjectFinancialRecord.leankor__ProjectFinancial__c != null) {
                storeProjectFinancialIds.add(newProjectFinancialRecord.leankor__ProjectFinancial__c);
            }
        }

        return storeProjectFinancialIds;
    }


	@TestVisible
	private static Map<Id, leankor__ProjectFinancial__c> readProjectFinancialRecords(Set<Id> projectFinancialIds) {
        return new Map<Id, leankor__ProjectFinancial__c>([Select Id,
                                                                Name, 
                                                                leankor__ProjectFinancial__c,
                                                                leankor__AllowFinancialEntry__c
                                                            From leankor__ProjectFinancial__c 
                                                            Where Id In :projectFinancialIds
                                                            With Security_Enforced
                                                            Limit 50000]);
    }


	@TestVisible
	private static Map<Id, List<leankor__ProjectFinancial__c>> readProjectFinancials(Set<Id> projectFinancialIds) {
        Map<Id, List<leankor__ProjectFinancial__c>> projectFinancials = new Map<Id, List<leankor__ProjectFinancial__c>>();

        List<leankor__ProjectFinancial__c> projectFinancialRecords = [Select Id,
                                                                            Name, 
                                                                            leankor__ProjectFinancial__c,
                                                                            leankor__AllowFinancialEntry__c
                                                                        From leankor__ProjectFinancial__c 
                                                                        Where leankor__ProjectFinancial__c In :projectFinancialIds
                                                                        With Security_Enforced
                                                                        Limit 50000];

        for (leankor__ProjectFinancial__c projectFinancialRecord : projectFinancialRecords) {
            List<leankor__ProjectFinancial__c> storeProjectFinancials = new List<leankor__ProjectFinancial__c>();
            
            if (projectFinancials.containsKey(projectFinancialRecord.leankor__ProjectFinancial__c)) {
                storeProjectFinancials = projectFinancials.get(projectFinancialRecord.leankor__ProjectFinancial__c);
            }

            storeProjectFinancials.add(projectFinancialRecord);
            projectFinancials.put(projectFinancialRecord.leankor__ProjectFinancial__c, storeProjectFinancials);
        }

        return projectFinancials;
    }


	@TestVisible
	private static Map<Id, String> readExpenses(Set<Id> projectFinancialIds) {
        Map<Id, String> projectFinancialExpenseRecords = new Map<Id, String>();

        List<leankor__Expense__c> expenseRecords = [Select leankor__ProjectFinancial__r.Name, 
                                                            leankor__ProjectFinancial__c 
                                                        From leankor__Expense__c 
                                                        Where leankor__ProjectFinancial__c In :projectFinancialIds
                                                        With Security_Enforced];

        for (leankor__Expense__c expenseRecord : expenseRecords) {
            projectFinancialExpenseRecords.put(expenseRecord.leankor__ProjectFinancial__c, expenseRecord.leankor__ProjectFinancial__r.Name);
        }

        return projectFinancialExpenseRecords;
    }
}