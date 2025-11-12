global with sharing class DependencyRequest {
    @AuraEnabled
    public List<leankor__Dependency__c> dependencyList;
    @AuraEnabled
    public List<leankor__KanbanCard__c> affectedWorkItems;
    @AuraEnabled
    public List<leankor__ValueStream__c> updatePlanningMode;
    @AuraEnabled
    public List<String> workItemIds;  
    @AuraEnabled
    public String verb;
    @AuraEnabled
    public String sessionId;
	@AuraEnabled
    public List<String> valueStreamIds;
}