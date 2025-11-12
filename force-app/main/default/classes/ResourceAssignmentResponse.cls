public class ResourceAssignmentResponse {
    
    @AuraEnabled 
    public String id { get; set; }
    
    @AuraEnabled 
    public String name { get; set; }
    
    @AuraEnabled 
    public String taskId { get; set; }
    
    @AuraEnabled 
    public String resourceGUID { get; set; }
    
    @AuraEnabled 
    public String resourceId { get; set; }
    
    @AuraEnabled 
    public Decimal units { get; set; }
    
    @AuraEnabled 
    public String ownerId { get; set; }
    
    @AuraEnabled 
    public String ownerName { get; set; }
    
    @AuraEnabled 
    public Decimal percentCompleted { get; set; }
    
    @AuraEnabled 
    public String verb { get; set; }
    
    @AuraEnabled
    public String activityId { get; set; }
    
    @AuraEnabled 
    public String resourceType { get; set; }
    
    @AuraEnabled 
    public String smallPhotoUrl { get; set; }
    
    @AuraEnabled 
    public String appointmentNumber { get; set; }
    
    @AuraEnabled 
    public String workOrderNumber { get; set; }
    
    @AuraEnabled 
    public DateTime startDateTime { get; set; }
    
    @AuraEnabled 
    public DateTime dueDateTime { get; set; }
    
    @AuraEnabled 
    public String resourceTypeId { get; set; }
    
    @AuraEnabled 
    public String tempUUID { get; set; }
    
    @AuraEnabled 
    public Decimal percentCompletedOfKanbanCard { get; set; }

    // Constructor with initialized values
    public ResourceAssignmentResponse() {
        
    }
}