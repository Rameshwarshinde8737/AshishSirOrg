public class FieldSetJsonResponse {
    @AuraEnabled
    public String fieldSetName { get; set; }
    
    @AuraEnabled
    public String fieldSetAPIName { get; set; }
    
    @AuraEnabled
    public String fieldSetJson { get; set; } // Renamed from fieldSetJSON

   
    public FieldSetJsonResponse(String fieldSetName, String fieldSetAPIName) {
        this.fieldSetName = fieldSetName;
        this.fieldSetAPIName = fieldSetAPIName;
    }

   
    public FieldSetJsonResponse(String fieldSetName, String fieldSetAPIName, String fieldSetJson) {
        this.fieldSetName = fieldSetName;
        this.fieldSetAPIName = fieldSetAPIName;
        this.fieldSetJson = fieldSetJson; // Changed name here
    }
}