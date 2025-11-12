global class KanbanCardTemplateRequest {
    @AuraEnabled
    public String id { get; set; }
    
    @AuraEnabled
    public String name { get; set; }
    
    @AuraEnabled
    public String title { get; set; }
    
    @AuraEnabled
    public String color { get; set; }
    
    @AuraEnabled
    public String cssLayout { get; set; }
    
    @AuraEnabled
    public Integer height { get; set; }
    
    @AuraEnabled
    public Integer width { get; set; }
    
    @AuraEnabled
    public String derivedFrom { get; set; }
    
    @AuraEnabled
    public String jsonData { get; set; }
    
    @AuraEnabled
    public String jsonDefinition { get; set; }
    
    @AuraEnabled
    public String valueStream { get; set; }
    
    @AuraEnabled
    public String startDate { get; set; }
    
    @AuraEnabled
    public String dueDate { get; set; }
    
    @AuraEnabled
    public Boolean entireRoom { get; set; }
    
    @AuraEnabled
    public Boolean entireOrg { get; set; }
    
    @AuraEnabled
    public Boolean entireBoard { get; set; }
    
    @AuraEnabled
    public String roomID { get; set; }
    
    @AuraEnabled
    public List<leankor.KanbanToGanttController.MasterContainer> children { get; set; }
    
    @AuraEnabled
    public Boolean expanded { get; set; }
    
    @AuraEnabled
    public String fieldSetName { get; set; }
    
    @AuraEnabled
    public String weekCalendar { get; set; }

    // Constructor with initialized values
    // @AuraEnabled
    // public KanbanCardTemplateRequest() {
    //     id = '';
    //     name = '';
    //     title = '';
    //     color = '';
    //     cssLayout = '';
    //     derivedFrom = '';
    //     jsonData = '{}';
    //     jsonDefinition = '{}';
    //     valueStream = '';
    //     entireRoom = false;
    //     entireOrg = false;
    //     entireBoard = false;
    //     roomID = '';
    //     children = new List<leankor.KanbanToGanttController.MasterContainer>();
    //     expanded = false;
    //     fieldSetName = '';
    //     weekCalendar = '';
    // }
}