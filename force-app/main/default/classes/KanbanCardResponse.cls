public class KanbanCardResponse {
    @AuraEnabled 
    public string Name { get; set; }
    @AuraEnabled 
    public list<leankor.ProjectBoardCarousel.Card> ChildRecords { get; set; }
    @AuraEnabled 
    public integer ChildCount { get; set; }
    @AuraEnabled 
    public string Color { get; set; }
    @AuraEnabled 
    public Integer PriorityIndex { get; set; }
    @AuraEnabled 
    public String Id { get; set; }
}