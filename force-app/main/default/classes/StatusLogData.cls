public class StatusLogData {
	
    @AuraEnabled
    public String id { get; set; }
    
    @AuraEnabled
    public String onBudget { get; set; }
    
    @AuraEnabled
    public String onQuality { get; set; }
    
    @AuraEnabled
    public String onTime { get; set; }
    
    @AuraEnabled
    public String percentComplete { get; set; }
    
    @AuraEnabled
    public String detail { get; set; }
    
    @AuraEnabled
    public String kanbanCard { get; set; }
    
    @AuraEnabled
    public String createdDate { get; set; }
    
    // Constructor
    public StatusLogData() {
        // Initialize properties if needed
    }
}