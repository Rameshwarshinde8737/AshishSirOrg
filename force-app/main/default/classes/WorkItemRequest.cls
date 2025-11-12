global with sharing class WorkItemRequest {
    @AuraEnabled
    public List<leankor__KanbanCard__c> kanbanCardRequests { get; set; }
    
    @AuraEnabled
    public Boolean sendBroadcastMessage { get; set; }
    
   @AuraEnabled
    public String projectId { get; set; }
    
    @AuraEnabled
    public String projectEventCustomPayload { get; set; }
    
    @AuraEnabled
    public String title { get; set; }
    
    @AuraEnabled
    public String categoryName { get; set; }
    
    @AuraEnabled
    public Id ownerId { get; set; }
    
    @AuraEnabled
    public String projectBoardName { get; set; }
    
    @AuraEnabled
    public String sessionId { get; set; }
    
    @AuraEnabled
    public String verb { get; set; }



    // Constructor
    // Initializing collections in the constructor is a common practice to ensure they are always ready for use, 
    //   especially in object-oriented programming
    // Initializing variables in the constructor ensures they have default values, 
    //   and to prevent NullPointerExceptions
    public WorkItemRequest() {
        kanbanCardRequests = new List<leankor__KanbanCard__c>();
        sendBroadcastMessage = false;
       projectId = '';
        projectEventCustomPayload = '';
        title = '';
        categoryName = '';         
        ownerId = UserInfo.getUserId();                      
        projectBoardName = ''; 
        sessionId = '';
        verb = '';
    } 
}