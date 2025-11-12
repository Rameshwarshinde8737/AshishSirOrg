public class ProjectRoomHierarchyData {
    @AuraEnabled
 	public string Id{get; set;}
    @AuraEnabled
    public string name{get; set;}
    @AuraEnabled
    public String boardType{get; set;}
    @AuraEnabled
    public boolean leaf{get; set;}
    @AuraEnabled
    public List<ProjectRoomHierarchyData> childRecords{get; set;}
    @AuraEnabled
    public string cssLayout{get; set;}
    @AuraEnabled
    public String roomId{get; set;}
    @AuraEnabled
    public string valueStreamLinkID{get; set;}
    @AuraEnabled
    public string valueStreamCardLink{get; set;}
    @AuraEnabled
    public string kanbanCardId{get; set;}
    @AuraEnabled
    public String urlLink{get; set;}
    @AuraEnabled
    public boolean hasEditAccess{get; set;}
    @AuraEnabled
    public boolean hasReadAccess{get; set;}
    @AuraEnabled
    public boolean hasDeleteAccess{get; set;}
    @AuraEnabled
    public boolean disableCalendarView{get; set;}
}