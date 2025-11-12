public class PortfolioHierarchyData{
    @AuraEnabled 
    public String Id { get; set; }
    @AuraEnabled 
    public String Name { get; set; }
    @AuraEnabled 
    public Boolean leaf { get; set; }
    @AuraEnabled 
    public String RoomType { get; set; }
    @AuraEnabled 
    public String ParentPortfolio { get; set; }
    @AuraEnabled 
    public List<PortfolioHierarchyData> ChildRecords { get; set; }
    @AuraEnabled 
    public String OwnerId { get; set; }
    @AuraEnabled 
    public Datetime MinDate { get; set; }
    @AuraEnabled 
    public Datetime MaxDate { get; set; }
    @AuraEnabled 
    public String StartDate { get; set; }
    @AuraEnabled 
    public String DueDate { get; set; }
    @AuraEnabled 
    public String OwnerName { get; set; }
    @AuraEnabled 
    public String BoardMaxDueDate { get; set; }
    @AuraEnabled 
    public Decimal PercentDone { get; set; }
    @AuraEnabled 
    public Decimal AllBudgetedTime { get; set; }
    @AuraEnabled 
    public Decimal AllBudgetTimeComplete { get; set; }
    @AuraEnabled 
    public Decimal AllBudgetTimeRemaining { get; set; }
    @AuraEnabled 
    public String BoardId { get; set; }
    @AuraEnabled 
    public String verb { get; set; }
    @AuraEnabled 
    public String RoomId { get; set; }


    @AuraEnabled 
    public Boolean hasEditAccess { get; set; }
    @AuraEnabled 
    public Boolean hasReadAccess { get; set; }
    @AuraEnabled 
    public Boolean hasDeleteAccess { get; set; }

    public PortfolioHierarchyData() {}
}