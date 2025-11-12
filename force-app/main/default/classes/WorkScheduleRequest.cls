global with sharing class WorkScheduleRequest {
    
     @AuraEnabled
    public List<leankor__KanbanCard__c> workItems { get; set; }
    @AuraEnabled
    public List<leankor__KanbanCard__c> affectedWorkItems { get; set; }
    @AuraEnabled
    public List<leankor__ScheduleMode__c> scheduleMode { get; set; }
    @AuraEnabled
    public List<leankor__ResourceAssignment__c> resourceAssignments { get; set; }
    @AuraEnabled
    public String verb { get; set; }
    @AuraEnabled
    public String sessionId { get; set; }
    @AuraEnabled
    public List<leankor__ValueStream__c> updatePlanningMode { get; set; }
    @AuraEnabled
    public String payloadString { get; set; }
    @AuraEnabled
    public List<Id> workItemIds { get; set; }
    @AuraEnabled
    public List<leankor__KanbanCardSticker__c> stickers { get; set; }
    @AuraEnabled
    public List<leankor__ResourceAssignment__c> newResourceAssignments { get; set; }
    @AuraEnabled
    public List<Id> resourceTypeIds { get; set; }
    @AuraEnabled
    public List<Id> resourceIds { get; set; }
    @AuraEnabled
    public List<Id> affectedWorkItemIds { get; set; }
    @AuraEnabled
    public Boolean isStickerChanged { get; set; }
    @AuraEnabled
    public List<String> valueStreamIds { get; set; }
 
    @AuraEnabled
    public List<LeankorOperationController.UpdateStack> manageWorkItemHistory { get; set; }
public WorkScheduleRequest() {
        workItems = new List<leankor__KanbanCard__c>();
        affectedWorkItems = new List<leankor__KanbanCard__c>();
        scheduleMode = new List<leankor__ScheduleMode__c>();
        resourceAssignments = new List<leankor__ResourceAssignment__c>();
        updatePlanningMode = new List<leankor__ValueStream__c>();
        workItemIds = new List<Id>();
        stickers = new List<leankor__KanbanCardSticker__c>();
        newResourceAssignments = new List<leankor__ResourceAssignment__c>();
        resourceTypeIds = new List<Id>();
        resourceIds = new List<Id>();
        affectedWorkItemIds = new List<Id>();
        valueStreamIds = new List<String>();
        manageWorkItemHistory = new List<LeankorOperationController.UpdateStack>();
    }
}