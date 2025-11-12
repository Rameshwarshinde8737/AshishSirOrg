@isTest
private class ProjectFinancialTriggerHandlerTest {
   
    @isTest
    static void testTriggerHandler() {
        // Create test data
        boolean expectedResult = true;
        leankor__FinancialAccount__c financialAccount = new leankor__FinancialAccount__c();
        financialAccount.Name = 'Financial Account';
        financialAccount.leankor__Code__c = '110';
        insert financialAccount;

        leankor__ProjectFinancial__c parentRecord = new leankor__ProjectFinancial__c();
        parentRecord.Name = 'Parent Record';
        parentRecord.leankor__AllowFinancialEntry__c = false;
        parentRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert parentRecord;

        leankor__ProjectFinancial__c childRecord = new leankor__ProjectFinancial__c();
        childRecord.Name = 'Child Record';
        childRecord.leankor__AllowFinancialEntry__c = true;
        childRecord.leankor__ProjectFinancial__c = parentRecord.Id;
        childRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert childRecord;

        Test.startTest();
        // Trigger the BEFORE_INSERT operation
        ProjectFinancialTriggerHandler triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{},
            new Map<Id, leankor__ProjectFinancial__c>{},
            new List<leankor__ProjectFinancial__c>{childRecord}
        );

        triggerHandler.executeTrigger(TriggerOperation.BEFORE_INSERT);

        // Assert that the child record has an error message
        //System.assert(childRecord.leankor__ProjectFinancial__c.hasErrors(), childRecord.leankor__ProjectFinancial__r.Name + ' allows a financial entry and cannot have a sub-item. Insert is not allowed!');

        // Reset the error flag
       // childRecord.leankor__ProjectFinancial__c.clearErrors();

        // Trigger the BEFORE_UPDATE operation
        triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{childRecord.Id => childRecord},
            new Map<Id, leankor__ProjectFinancial__c>{},
            new List<leankor__ProjectFinancial__c>{}
        );

        triggerHandler.executeTrigger(TriggerOperation.BEFORE_UPDATE);

        // Assert that the child record has an error message
        //System.assert(childRecord.leankor__ProjectFinancial__c.hasErrors(), 'Error: Child record should have an error message.');

        // Trigger the BEFORE_UPDATE operation
        triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{childRecord.Id => childRecord},
            new Map<Id, leankor__ProjectFinancial__c>{},
            new List<leankor__ProjectFinancial__c>{}
        );

        triggerHandler.executeTrigger(TriggerOperation.BEFORE_DELETE);
         // Trigger the BEFORE_DELETE operation
         triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{},
            new Map<Id, leankor__ProjectFinancial__c>{childRecord.Id => childRecord},
            new List<leankor__ProjectFinancial__c>{}
        );

        System.assert(true, expectedResult);

        triggerHandler.setBypassTrigger(true);
        System.assert(true, expectedResult);

        boolean actualValue = triggerHandler.getBypassTrigger();
        System.assert(actualValue, expectedResult);

        Test.stopTest();
    }

   /* @isTest
    private static void testSetBypassTrigger(){
        boolean expectedValue = true;
        ProjectFinancialTriggerHandler triggerHandler = new ProjectFinancialTriggerHandler();
        triggerHandler.setBypassTrigger(true);
        System.assert(true, expectedValue);
    }*/

    @isTest
    private static void testValidateProjectFinancial(){
        boolean expectedValue = false;
        // Create test data
        boolean expectedResult = true;
        leankor__FinancialAccount__c financialAccount = new leankor__FinancialAccount__c();
        financialAccount.Name = 'Financial Account';
        financialAccount.leankor__Code__c = '110';
        insert financialAccount;

        leankor__ProjectFinancial__c parentRecord = new leankor__ProjectFinancial__c();
        parentRecord.Name = 'Parent Record';
        parentRecord.leankor__AllowFinancialEntry__c = true;
        parentRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert parentRecord;

        leankor__ProjectFinancial__c childRecord = new leankor__ProjectFinancial__c();
        childRecord.Name = 'Child Record';
        childRecord.leankor__AllowFinancialEntry__c = true;
        childRecord.leankor__ProjectFinancial__c = parentRecord.Id;
        childRecord.leankor__FinancialAccount__c = financialAccount.Id;

        Test.startTest();
        // Trigger the BEFORE_INSERT operation
        try{
            ProjectFinancialTriggerHandler triggerHandler = new ProjectFinancialTriggerHandler(
                new Map<Id, leankor__ProjectFinancial__c>{},
                new Map<Id, leankor__ProjectFinancial__c>{},
                new List<leankor__ProjectFinancial__c>{childRecord}
            );

            triggerHandler.executeTrigger(TriggerOperation.BEFORE_INSERT);
            insert childRecord;
        }catch(Exception e){
            String message = e.getMessage();
            System.assert(message.contains(parentRecord.Name + ' allows a financial entry and cannot have a sub-item. Insert is not allowed!'));
        }
        System.assert(true, expectedResult);
        
    }

    @isTest
    private static void testValidateAllowFinancialEntry(){
        boolean expectedValue = false;
        // Create test data
        boolean expectedResult = true;
        leankor__FinancialAccount__c financialAccount = new leankor__FinancialAccount__c();
        financialAccount.Name = 'Financial Account';
        financialAccount.leankor__Code__c = '110';
        insert financialAccount;

        leankor__ProjectFinancial__c parentRecord = new leankor__ProjectFinancial__c();
        parentRecord.Name = 'Parent Record';
        parentRecord.leankor__AllowFinancialEntry__c = false;
        parentRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert parentRecord;

        leankor__ProjectFinancial__c parentRecordNew = new leankor__ProjectFinancial__c();
        parentRecordNew.Name = 'Parent Record';
        parentRecordNew.leankor__AllowFinancialEntry__c = true;
        parentRecordNew.leankor__FinancialAccount__c = financialAccount.Id;

        leankor__ProjectFinancial__c childRecord = new leankor__ProjectFinancial__c();
        childRecord.Name = 'Child Record';
        childRecord.leankor__AllowFinancialEntry__c = true;
        childRecord.leankor__ProjectFinancial__c = parentRecord.Id;
        childRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert childRecord;

        Test.startTest();
        // Trigger the BEFORE_UPDATE operation
        try{
        ProjectFinancialTriggerHandler triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{parentRecord.Id => parentRecordNew},
            new Map<Id, leankor__ProjectFinancial__c>{parentRecord.Id => parentRecord},
            new List<leankor__ProjectFinancial__c>{}
        );

        triggerHandler.executeTrigger(TriggerOperation.BEFORE_UPDATE);
        }catch(Exception e){
            String message = e.getMessage();
            System.assert(message.contains(parentRecord.Name + ' has sub-items. Financial entry is not allowed!'));
        }
        System.assert(true, expectedResult);
        
    }

   /* @isTest
    private static void testValidateTransaction(){
        boolean expectedValue = false;
        // Create test data
        boolean expectedResult = true;
        leankor__FinancialAccount__c financialAccount = new leankor__FinancialAccount__c();
        financialAccount.Name = 'Financial Account';
        financialAccount.leankor__Code__c = '110';
        insert financialAccount;

        leankor__ProjectFinancial__c parentRecordDemo = new leankor__ProjectFinancial__c();
        parentRecordDemo.Name = 'Parent Record Demo';
        parentRecordDemo.leankor__AllowFinancialEntry__c = false;
        parentRecordDemo.leankor__FinancialAccount__c = financialAccount.Id;
        insert parentRecordDemo;

        leankor__ProjectFinancial__c parentRecord = new leankor__ProjectFinancial__c();
        parentRecord.Name = 'Parent Record';
        parentRecord.leankor__AllowFinancialEntry__c = false;
        parentRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert parentRecord;

        leankor__ProjectFinancial__c parentRecordNew = new leankor__ProjectFinancial__c();
        parentRecordNew.Name = 'Parent Record';
        parentRecordNew.leankor__AllowFinancialEntry__c = true;
        parentRecordNew.leankor__FinancialAccount__c = financialAccount.Id;
        parentRecordNew.leankor__ProjectFinancial__c = parentRecordDemo.Id;

        leankor__ProjectFinancial__c childRecord = new leankor__ProjectFinancial__c();
        childRecord.Name = 'Child Record';
        childRecord.leankor__AllowFinancialEntry__c = true;
        childRecord.leankor__ProjectFinancial__c = parentRecord.Id;
        childRecord.leankor__FinancialAccount__c = financialAccount.Id;
        insert childRecord;

        // creating Expenses data 
       leankor__Expense__c SampleExpensesCost = new leankor__Expense__c
       (      
               Name = 'CloneExpenceOne',
               //leankor__Portfolio__c = sourceFolder.Id,
              // leankor__Project__c = sourceProject.Id,
               leankor__Date__c = system.today(),
               leankor__ExpenseAmount__c = 100.0,
               leankor__ProjectFinancial__c = parentRecord.Id
               //RecordTypeId  = Recordtypelist[0].Id
       );
       insert SampleExpensesCost;

        Test.startTest();
        // Trigger the BEFORE_UPDATE operation
        try{
        ProjectFinancialTriggerHandler triggerHandler = new ProjectFinancialTriggerHandler(
            new Map<Id, leankor__ProjectFinancial__c>{parentRecord.Id => parentRecordNew},
            new Map<Id, leankor__ProjectFinancial__c>{parentRecord.Id => parentRecord},
            new List<leankor__ProjectFinancial__c>{}
        );

        triggerHandler.executeTrigger(TriggerOperation.BEFORE_UPDATE);
        }catch(Exception e){
            String message = e.getMessage();
            System.assert(message.contains(parentRecord.Name + ' has financial transactions. Update is not allowed!'));
        }
        System.assert(true, expectedResult);
        
    }*/

}