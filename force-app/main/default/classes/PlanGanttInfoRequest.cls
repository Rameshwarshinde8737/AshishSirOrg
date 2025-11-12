public class PlanGanttInfoRequest {
   @AuraEnabled
   public String valueStreamId {get; set;}
   @AuraEnabled
   public String userId{get; set;}
   @AuraEnabled
   public String boardType{get; set;}
    @AuraEnabled 
    public List<String> valueStreamIds { get; set; }   // ✅ FIXED
   @AuraEnabled
   public realTimeController.Preference preference{get; set;}
   @AuraEnabled
   public String folderId{get; set;}
 
}