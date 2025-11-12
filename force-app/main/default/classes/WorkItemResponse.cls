global with sharing class WorkItemResponse {
    @AuraEnabled
    public List<leankor__KanbanCard__c> kanbanCards { get; set; }

    @AuraEnabled
    public List<leankor__ScheduleMode__c> scheduleModes { get; set; }

    @AuraEnabled
    public List<GanttTaskBoard.ResourceAssignment> resourceAssignments { get; set; }

    @AuraEnabled
    public Map<Id, leankor__KanbanCard__c> customFields { get; set; }

    @AuraEnabled
    public Set<Id> valueStreamIds { get; set; }

    // Constructor
    // Initializing collections in the constructor is a common practice to ensure they are always ready for use, 
    //   especially in object-oriented programming
    // Initializing variables in the constructor ensures they have default values, 
    //   and to prevent NullPointerExceptions
    public WorkItemResponse() {
        kanbanCards = new List<leankor__KanbanCard__c>();
        scheduleModes = new List<ScheduleMode__c>();
        resourceAssignments = new List<GanttTaskBoard.ResourceAssignment>();
        customFields = new Map<Id, leankor__KanbanCard__c>();    
        valueStreamIds = new Set<Id>();
    }
}