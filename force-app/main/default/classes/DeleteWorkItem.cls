global with sharing class DeleteWorkItem {
    @AuraEnabled
    public List<leankor__KanbanCard__c> workItems;
    @AuraEnabled
    public List<String> workItemIds;  
    @AuraEnabled
    public List<String> valueStreamIds;  
    @AuraEnabled
    public List<LeankorOperationController.UpdateStack> manageWorkItemHistory;
    @AuraEnabled
    public List<leankor__ValueStream__c> updatePlanningMode;
    @AuraEnabled
    public String verb;
    @AuraEnabled
    public String sessionId;
}