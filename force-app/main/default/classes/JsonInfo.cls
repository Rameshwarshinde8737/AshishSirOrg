public class JsonInfo {
    @AuraEnabled
    public Map<String, Object> jsonDefinitions{ get; set; }
    @AuraEnabled 
    public String jsonData{ get; set; }
    @AuraEnabled
    public String fieldSetName{ get; set; }
    @AuraEnabled
    public String fieldSetAPIName{ get; set; }
    @AuraEnabled
    public Boolean autoCalculateTotals{ get; set; }
    @AuraEnabled
    public Boolean isReadOnly = false;

}