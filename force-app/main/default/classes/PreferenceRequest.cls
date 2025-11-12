public class PreferenceRequest {
    @AuraEnabled
    public String id {set;get;}
    
    @AuraEnabled
    public String name{set;get;}
    
    @AuraEnabled
    public String guid{set;get;}
    
    @AuraEnabled
    public String currentUser{set;get;}
    
    @AuraEnabled
    public String followOnChatter{set;get;}
    
    @AuraEnabled
    public String subscribeToCard{set;get;}
    
    @AuraEnabled
    public String valueStream{set;get;}
    @AuraEnabled
    public Boolean ownerEditCard{set;get;}
    
    @AuraEnabled
    public Boolean ownerMoveCard{set;get;}
    
    @AuraEnabled
    public String valueStreamOwner{set;get;}
    
    @AuraEnabled
    public List<String> categories{set;get;}
    
    @AuraEnabled
    public Boolean cardPastDueDate{set;get;}
    @AuraEnabled
    public Boolean taskPastDueDate{set;get;}
    
    @AuraEnabled
    public Boolean isTaskCompleted{set;get;}
    
    @AuraEnabled
    public Boolean moved{set;get;}
    
    @AuraEnabled
    public Boolean percentDone{set;get;}
    
    @AuraEnabled
    public Integer flag{set;get;}
    
    @AuraEnabled
    public String derivedFrom{set;get;}
    
    @AuraEnabled
    public Decimal ganttDividerSize{set;get;}

    // Constructor to initialize fields
    public PreferenceRequest() {
       
    }
}