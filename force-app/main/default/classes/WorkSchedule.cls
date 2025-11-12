global with sharing class WorkSchedule{
    @AuraEnabled
    public List<leankor__KanbanCard__c> workItems;
    @AuraEnabled
    public List<leankor__KanbanCard__c> affectedWorkItems;
    @AuraEnabled
    public List<leankor__ScheduleMode__c> scheduleMode;
    @AuraEnabled
    public List<LeankorOperationController.UpdateStack> manageWorkItemHistory;
    @AuraEnabled
    public List<leankor__ResourceAssignment__c> resourceAssignments;
    @AuraEnabled
    public String verb;
    @AuraEnabled
    public String sessionId;
    @AuraEnabled
    public List<leankor__ValueStream__c> updatePlanningMode;
    @AuraEnabled
    public string payloadString;
    @AuraEnabled
    public List<Id> workItemIds;
    @AuraEnabled
    public List<leankor__KanbanCardSticker__c> stickers;
    @AuraEnabled
    public List<leankor__ResourceAssignment__c> newResourceAssignments;
    @AuraEnabled
    public List<Id> resourceTypeIds;
    @AuraEnabled
    public List<Id> resourceIds;
    @AuraEnabled
    public List<Id> affectedWorkItemIds;
    @AuraEnabled
    public Boolean isStickerChanged;
}