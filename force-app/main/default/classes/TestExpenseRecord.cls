@isTest
public class TestExpenseRecord {
    public static testMethod void testExpenserecord()
    {
      leankor__Expense__c Exp = new leankor__Expense__c(name= 'new expense');
      insert Exp;
        ExpenseRecord Ex = new ExpenseRecord(new ApexPages.Standardcontroller(Exp)); 
        ExpenseRecord.getExpense();
        ex.SelectedId=leankor.ExpenseRecord.getExpenseID();
        ex.RoomID= leankor.ExpenseRecord.getRoomID();
        leankor.ExpenseRecord.getObjectId();        
        leankor.ExpenseRecord.getDurableIdforProject();        
        leankor.ExpenseRecord.getDurableIdforportfolio();
        leankor.ExpenseRecord.getPortfolioId();
        leankor.ExpenseRecord.getPortfolioName();    
        system.assert(leankor.ExpenseRecord.getRoomName()==null);
   }
}