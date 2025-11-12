public class SubscriberWrapper {
    @AuraEnabled
    public String Id { get; set; }
    
    @AuraEnabled
    public String Name { get; set; }
    
    @AuraEnabled
    public String KanbanID { get; set; }
    
    @AuraEnabled
    public String SubscriberID { get; set; }
    
    @AuraEnabled
    public Boolean KanbanMove { get; set; }
    
    @AuraEnabled
    public Boolean PercentDone { get; set; }
    
    @AuraEnabled
    public Boolean isTaskCompleted { get; set; }
    
    @AuraEnabled
    public Boolean CardPastDueDate { get; set; }
    
    @AuraEnabled
    public Boolean TaskPastDueDate { get; set; }
    
    @AuraEnabled
    public Integer Flag { get; set; }
    
    @AuraEnabled
    public String Preference { get; set; }

    // Default Constructor
    public SubscriberWrapper() {}

    // Parameterized Constructor
   /* public SubscriberWrapper(
        String Id, 
        String Name, 
        String KanbanID, 
        String SubscriberID, 
        Boolean KanbanMove, 
        Boolean PercentDone, 
        Boolean isTaskCompleted, 
        Boolean CardPastDueDate, 
        Boolean TaskPastDueDate, 
        Integer Flag, 
        String Preference
    ) {
        this.Id = Id;
        this.Name = Name;
        this.KanbanID = KanbanID;
        this.SubscriberID = SubscriberID;
        this.KanbanMove = KanbanMove;
        this.PercentDone = PercentDone;
        this.isTaskCompleted = isTaskCompleted;
        this.CardPastDueDate = CardPastDueDate;
        this.TaskPastDueDate = TaskPastDueDate;
        this.Flag = Flag;
        this.Preference = Preference;
    }*/
}