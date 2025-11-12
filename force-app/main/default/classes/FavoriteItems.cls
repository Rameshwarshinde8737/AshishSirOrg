public class FavoriteItems {
   
    @AuraEnabled
    public String recordId{ get; set; }
    @AuraEnabled
    public String id{ get; set; }
    @AuraEnabled
    public String boardId{ get; set; }
    @AuraEnabled
    public String projectId{ get; set; }
    @AuraEnabled
    public String type{ get; set; }
    @AuraEnabled
    public String boardType;
    @AuraEnabled
    public String name{ get; set; }
    @AuraEnabled
    public DateTime lastModifiedDate{ get; set; }
    @AuraEnabled
    public String  projectName{ get; set; }
    @AuraEnabled
    public String itemType{ get; set; }

}