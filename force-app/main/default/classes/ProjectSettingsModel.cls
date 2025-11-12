public class ProjectSettingsModel {
    @AuraEnabled 
    public string defaultBoard{ get; set; }
    @AuraEnabled 
    public String moduleName{ get; set; }
    @AuraEnabled 
    public String moduleId{ get; set; }
    @AuraEnabled 
    public boolean oneClicklaunch{ get; set; }
    @AuraEnabled 
    public boolean openNewTab{ get; set; }
    @AuraEnabled 
    public string projectId{ get; set; }
    @AuraEnabled 
    public string viewType{ get; set; }
    @AuraEnabled 
    public String name{ get; set; }
    @AuraEnabled 
    public string defaultBoardType{ get; set; }
    @AuraEnabled 
    public string moduleBoardType{ get; set; }
    @AuraEnabled 
    public string urlLink{ get; set; }
    @AuraEnabled 
    public Boolean hasReadAccess{ get; set; }

}