public class BoardOnLoadConfigDetails {
    
    @AuraEnabled public String boardName{ get; set; }
    @AuraEnabled public String valueStreamId{ get; set; }
    @AuraEnabled public List<String> remoteCardIDs{ get; set; }

    // ---- Outputs ----
    @AuraEnabled public List<leankor__KanbanCardTemplate__c> kanbanCardTemplates{ get; set; }
    @AuraEnabled public leankor__Preference__c preference{ get; set; }
    @AuraEnabled  public List<leankor.RealTimeController.Kanban> kanbanBoardCards{ get; set; }
    @AuraEnabled public RealTimeController.GlueforceData glueforceData{ get; set; }
    @AuraEnabled public KanbanController.SprintDetail sprintDetails{ get; set; }

}