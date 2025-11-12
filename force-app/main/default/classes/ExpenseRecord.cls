global with sharing class ExpenseRecord {
    global string SelectedId {get;set;}
    global string RoomID {get; set;}    
    global ExpenseRecord (ApexPages.StandardController controller){}
    global static string getExpenseID(){return null;}    
    global static List<leankor__Expense__c> getExpense(){return null ;}    
    global static string getObjectId(){return null;}
    global static string getDurableIdforProject(){return null;}
    global static string getDurableIdforportfolio(){return null;}
    global static string getPortfolioId(){return null;}
    global static string getPortfolioName(){return null;}
    global static string getRoomName(){return null;}
    global static string getRoomID(){return null;}    
}