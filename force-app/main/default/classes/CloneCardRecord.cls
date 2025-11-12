public class CloneCardRecord {
    @AuraEnabled
    public String BoardId { get; set; }

    @AuraEnabled
    public String someJSONData { get; set; }

    @AuraEnabled
    public Boolean isActivityGroup { get; set; }

    @AuraEnabled
    public String ItemType { get; set; }

    @AuraEnabled
    public List<leankor.RealTimeController.Dependency> dependencyList { get; set; }

    @AuraEnabled
    public List<String> cardIdlist { get; set; }

    @AuraEnabled
    public String folderId { get; set; }

    @AuraEnabled
    public String newData { get; set; }

    @AuraEnabled
    public  leankor.KanbanToGanttController.MasterContainer Activity { get; set; }

    @AuraEnabled
    public List<leankor.GanttTaskBoard.ResourceAssignment> ResourceAssignmentData { get; set; }


}