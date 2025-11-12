public class IssueLogResponse {
    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public String subject { get; set; }

    @AuraEnabled
    public String detail { get; set; }

    @AuraEnabled
    public String kanbanCardId { get; set; }

    @AuraEnabled
    public String logTime { get; set; }

    @AuraEnabled
    public String probability { get; set; }

    @AuraEnabled
    public String statusType { get; set; }

    @AuraEnabled
    public String taskId { get; set; }

    @AuraEnabled
    public String weight { get; set; }

    @AuraEnabled
    public Boolean resolved { get; set; }

    @AuraEnabled
    public String resolvedTime { get; set; }

    @AuraEnabled
    public Decimal score { get; set; }

    @AuraEnabled
    public String taskDueDate { get; set; }

    @AuraEnabled
    public String assignedTo { get; set; }

    @AuraEnabled
    public String smallPhotoUrl { get; set; }

    @AuraEnabled
    public String riskMitigation { get; set; }

    /** IssueLogResponse Constructor */
    public IssueLogResponse() {
        // Initialize default values
        id = null;
        subject = '';
        detail = '';
        kanbanCardId = '';
        logTime = '';
        probability = '';
        statusType = '';
        taskId = '';
        weight = '';
        resolved = false;
        resolvedTime = '';
        score = 0.0;
        taskDueDate = '';
        assignedTo = '';
        smallPhotoUrl = '';
        riskMitigation = '';
    }
}