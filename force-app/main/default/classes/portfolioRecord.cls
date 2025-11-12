public class portfolioRecord {
    
    @AuraEnabled
    public string Id{ get; set;}
    @AuraEnabled
    public string Name{ get; set;}
    @AuraEnabled
    public string ParentPortfolio{ get; set;}
    @AuraEnabled
    public string type{ get; set;}
    @AuraEnabled
    public String PlanBoardID {get; set;}
    @AuraEnabled
    public String navigationVerb{get; set;} 
    @AuraEnabled
    public string methodName{get; set;}
    @AuraEnabled
    public string sourceProjectId{get; set;}
    @AuraEnabled
    public Boolean planGantt{get; set;}   
    @AuraEnabled    
    public boolean hasEditAccess{get; set;}
    @AuraEnabled
    public boolean hasReadAccess{get; set;}
    @AuraEnabled
    public boolean hasDeleteAccess{get; set;}  
}