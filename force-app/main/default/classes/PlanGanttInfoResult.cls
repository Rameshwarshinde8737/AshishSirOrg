public class PlanGanttInfoResult {
    @AuraEnabled
    public String baseURL{get; set;}
    @AuraEnabled
    public List<CreateFilterRequest> filters;
    @AuraEnabled
    public List<User> filterUserRecords{get; set;}
    @AuraEnabled
    public Boolean isServiceAppointmentEnable{get; set;}
    @AuraEnabled
    public Boolean isFieldExist{get; set;}
    @AuraEnabled
    public User userLog{get; set;}
    @AuraEnabled
    public String orgBaseURL{get; set;}
    @AuraEnabled
    public List<PermissionSetAssignment> userPermissionSets{get; set;}
    @AuraEnabled
    public leankor__Preference__c preference{get; set;}
    @AuraEnabled
    public GanttTaskBoard.GetPortfolioresource getPortfolioresource{get; set;}
 
}