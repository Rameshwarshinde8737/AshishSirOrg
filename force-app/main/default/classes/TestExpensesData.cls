@isTest

public class TestExpensesData {
    public static testMethod void testExpensesData () {
     List<leankor__Expense__c> Explist = new List<leankor__Expense__c>();
           leankor__Expense__c Exp = new leankor__Expense__c();
           leankor__Portfolio__c Port = new leankor__Portfolio__c();
           port.name = 'Test portfolio';
           insert port; 
           Exp.name= 'new expense';
           Exp.leankor__ExpenseAmount__c = 500;
           insert Exp;
           Explist.add(Exp);
           leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name='PrjName',leankor__Portfolio__c=port.Id );
           insert project; 
           //system.assert(Explist !=null);
    // Portfolio 
            ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(Exp);
            ExpensesData Ex = new ExpensesData(controller); 
            PageReference pageRef = Page.ExpensesPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('RID',project.Id);
            Ex.RoomID = port.Id;
            ApexPages.Standardcontroller controllerSet = new ApexPages.Standardcontroller([select id, Name from leankor__Expense__c limit 999]);
            ExpensesData Ex1 = new ExpensesData(controllerSet); 
            leankor.ExpensesData.getDurableIdforportfolio();    
            List<leankor__Expense__c> getExpenses= leankor.ExpensesData.getExpenses();
            string ExpenseID = leankor.ExpensesData.getExpenseID();
          //FieldDefinition listofMetadataPrj11 =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Project__c'];
           leankor.ExpensesData.getObjectId();
           //FieldDefinition listofMetadataPrj =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Project__c'];
            string DurableIdforProject= leankor.ExpensesData.getDurableIdforProject();
          //FieldDefinition listofMetadataPort =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Portfolio__c'];  
           string getPortfolioId = leankor.ExpensesData.getPortfolioId();
           leankor.ExpensesData.getPortfolioName();    
           string RoomName = leankor.ExpensesData.getRoomName();
           Ex.RoomID=leankor.ExpensesData.getRoomID();
           system.assert(RoomName!=null);
             /*Integer Rt =[SELECT count() FROM RecordType WHERE SObjectType = 'leankor__Expense__c'];
             leankor.ExpenseData.getRecordTypeCount();
             //RecordType rts =[SELECT ID, name FROM RecordType WHERE SObjectType = 'leankor__Expense__c'];
               //leankor.ExpensesData.getRecordType();*/
    }
    public static testMethod void testExpensesDataAura () {
    	List<leankor__Portfolio__c> folderList=TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList=TestDataFactory.createProjects('Test Project', folderList, 1);
        String query='select Id from';
        List<leankor__Portfolio__c> folder = ExpensesData.querySalesforceRecord(query+' leankor__Portfolio__c limit 1');
    	System.assert(folder!=null);
    	List<leankor__ProjectRoom__c> project=ExpensesData.querySalesforceRecord(query+' leankor__ProjectRoom__c where leankor__Portfolio__c=\''+folder[0].Id+'\'');
    	System.assert(project!=null);
    	List<leankor__Expense__c> expList = TestDataFactory.createExpenses('Test Expense', 451, folder[0].Id, project[0].Id, 10);
    	ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(expList[0]);
        ExpensesData Ex = new ExpensesData(controller); 
        PageReference pageRef = Page.ExpensesPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('RID',project[0].Id);
    	List<String> fieldSetLabels=ExpensesData.getFieldSetLabels();
    	system.assert(fieldSetLabels!=null);
    	List<String> fieldSetAPINames=ExpensesData.getFieldSetAPIName();
    	system.assert(fieldSetAPINames!=null);
    	leankor__ProjectRoom__c currentProjectInfo=ExpensesData.getProject(project[0].Id);
    	system.assert(currentProjectInfo!=null);
    	List<sObject> recordsList=ExpensesData.getExpenseRecords(project[0].Id);
    	system.assert(recordsList!=null);
    	
    	leankor__Expense__c Exp = new leankor__Expense__c();
    	Exp.name= 'Test Expense';
       	Exp.leankor__ExpenseAmount__c = 111;
       	Exp.leankor__Project__c=project[0].Id;
       	Exp.leankor__Portfolio__c=folder[0].Id;
       	List<string> resultList=ExpensesData.saveExpense(Exp);
       	System.assert(resultList!=null);
        
        leankor__Expense__c Exp1 = new leankor__Expense__c();
        Exp1.name= 'Test Expense Error';
       	Exp1.leankor__Project__c=project[0].Id;
       	List<string> errorResultList=ExpensesData.saveExpense(Exp1);
        System.assert(errorResultList!=null);
       	
    }	
}