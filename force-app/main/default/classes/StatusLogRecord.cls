public class StatusLogRecord {
    
    @AuraEnabled
    public List<KanbanController.StatusLogs> statusLogs { get; set; }
    
    @AuraEnabled
    public Map<Id, leankor__KanbanCard__c> kanbanCards { get; set; }
    
    // Constructor
    public StatusLogRecord() {
        this.statusLogs = new List<KanbanController.StatusLogs>();
        this.kanbanCards = new Map<Id, leankor__KanbanCard__c>();
    }

}