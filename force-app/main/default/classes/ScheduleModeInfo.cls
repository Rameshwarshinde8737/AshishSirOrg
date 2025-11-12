public class ScheduleModeInfo {
     @AuraEnabled
    public String schedulingModeId { get; set; }
    
    @AuraEnabled
    public String schedulingMode { get; set; }
    
    @AuraEnabled
    public Boolean manuallyScheduled { get; set; }
    
    @AuraEnabled
    public Decimal effort { get; set; }
    
    @AuraEnabled
    public String effortUnit { get; set; }
    
    @AuraEnabled
    public String activityId { get; set; }
    
    @AuraEnabled
    public String constraintType { get; set; }
    
    @AuraEnabled
    public String constraintDate { get; set; }
    
    @AuraEnabled
    public Boolean readOnly { get; set; }
    
    @AuraEnabled
    public String parentCardConstraintType { get; set; }
    
    @AuraEnabled
    public DateTime parentCardConstraintDate { get; set; }

    // Constructor
    public ScheduleModeInfo() {
        // Initialize default values if necessary
       // manuallyScheduled = false;
        //effort = 0;
       // effortUnit = '';
        //readOnly = false;
    }

}