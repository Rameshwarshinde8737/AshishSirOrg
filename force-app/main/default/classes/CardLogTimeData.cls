global class CardLogTimeData {
    @AuraEnabled
    public String id { get; set; }

    @AuraEnabled
    public String logTime { get; set; }

    @AuraEnabled
    public String description { get; set; }

    @AuraEnabled
    public String duration { get; set; }

    @AuraEnabled
    public Decimal estimation { get; set; }

    @AuraEnabled
    public String subject { get; set; }

    @AuraEnabled
    public String taskId { get; set; }

    @AuraEnabled
    public Decimal hours { get; set; }

    @AuraEnabled
    public String kanbanCardId { get; set; }

    @AuraEnabled
    public String taskDueDate { get; set; }

    @AuraEnabled
    public String assignedTo { get; set; }

    @AuraEnabled
    public String assignedAUser { get; set; }

    @AuraEnabled
    public String assignedAUserName { get; set; }

    // Default constructor
    global CardLogTimeData() {}

    // Parameterized constructor
    global CardLogTimeData(
        String id,
        String logTime,
        String description,
        String duration,
        Decimal estimation,
        String subject,
        String taskId,
        Decimal hours,
        String kanbanCardId,
        String taskDueDate,
        String assignedTo,
        String assignedAUser,
        String assignedAUserName
    ) {
        this.id = id;
        this.logTime = logTime;
        this.description = description;
        this.duration = duration;
        this.estimation = estimation;
        this.subject = subject;
        this.taskId = taskId;
        this.hours = hours;
        this.kanbanCardId = kanbanCardId;
        this.taskDueDate = taskDueDate;
        this.assignedTo = assignedTo;
        this.assignedAUser = assignedAUser;
        this.assignedAUserName = assignedAUserName;
    }
}