/**
* Created by triestelaporte on 5/14/20.
* Modified by RBO on 6/15/20
*/
global inherited sharing class PageSetupController {
    public transient String pageSetupInfo { get; private set; }
    public transient String pageSetupInfoUtil { get; private set; }
    private transient List<leankor__ValueStream__c> valueStreamList { get; set; }
    public static transient String thisPageName { get; set; }
    public static transient leankor__ValueStream__c thisValueStream { get; set; }
    public PageSetupController(){}
    public PageSetupController(Util controller){
        getThisPageName();
        pageSetupInfo = JSON.serialize(buildPageSetupInfo('Page.' + thisPageName));
    }
    public PageSetupController (ApexPages.StandardController stanCon) {
        getThisPageName();
        thisValueStream =(leankor__ValueStream__c)stanCon.getRecord();
        if(String.isNotBlank(thisValueStream.Id) && 
        Util.getSObjectName(thisValueStream.Id) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        pageSetupInfo = JSON.serialize(buildPageSetupInfo('Page.' + thisPageName));
    }
    public PageSetupController (ApexPages.StandardSetController stanSetCon) {
        getThisPageName();
        pageSetupInfo = JSON.serialize(buildPageSetupInfo('Page.' + thisPageName));
    }
    
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static String getPageSetupInfoLightning (String pageName) {
        return JSON.serialize(buildPageSetupInfo('Page.' + pageName));
    }
   
    @TestVisible
    private static PageSetupInfo buildPageSetupInfo (String pageName) {
        PageSetupInfo returnInfo = new PageSetupInfo();
        
        returnInfo.orgBaseURL = realTimeController.getOrgBaseURL();
        returnInfo.baseUrlNew = realTimeController.getBaseURL();
        returnInfo.smallUrl = getCurrentUserRecord();
        returnInfo.userPermissionSetAssignments = getUserPermissionSetAssignments(returnInfo.smallUrl.Id);
        returnInfo.recordTypesMap = PlanGanttController.recordTypeIdNameMap();
        Set<String> mockActiveFlowApiName;
        if (pageName.equals('Page.ganttview')) {
            returnInfo.webLink =  filteredWebLink(getWebLink('leankor__KanbanCard__c'), '/flow/', mockActiveFlowApiName);
        }
        returnInfo.scheduleConstraintMap = PlanGanttController.getScheduleConstraintMap();
        if(pageName.equals('Page.leankornav') || pageName.equals('Page.leankormywork')){
            returnInfo.newNavIntroDetails = realTimeController.getIntroDetails('New Nav');
            returnInfo.projectNavIntroDetails = realTimeController.getIntroDetails('Project Nav');
            returnInfo.firstInstallValue = leankor__LeanConstants__c.getInstance().leankor__FirstInstall__c;
            returnInfo.packageVersion = Util.readPackageVersion();
        }

        if(pageName.equals('Page.kanbanboard') && thisValueStream!=null){
            returnInfo.checkFSLManageApp = KanbanController.checkFSLManageApp();
            returnInfo.isFieldExist = KanbanController.checkFieldExistInSobject();
            returnInfo.glueforceData = realTimeController.getGlueforceData(thisValueStream.Id);
            returnInfo.defaultLink = getDefaultLink();
            returnInfo.introDetails = realTimeController.getIntroDetails('Kanban Board');
         }

        if(pageName.equals('Page.calendarview') && thisValueStream!=null){
            returnInfo.introDetails = realTimeController.getIntroDetails('Calendar View');
            returnInfo.pageNamespace = realTimeController.getPageNamespace('CalendarView');
         }
        
        //Here LeankorBase stands for common Label category for all board
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', pageName};
            returnInfo.pageStrings = LabelProvider.getLabelsForConsumers(consumers);
            returnInfo.urlPathPrefix  = getUrlPathPrefix();
        
        PageSetupController.ConstraintData constraintData = new PageSetupController.ConstraintData();
        //Changes : Check constraint setting enable or not.
        if(thisValueStream != null && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            constraintData.scheduleConstraints = getScheduleConstraints();
        }

        returnInfo.constraintData = constraintData;
        if(thisValueStream != null && thisPageName != 'mytimesheet' && thisPageName != 'capacityplanning' && thisPageName != 'resourcemanagementview'){
            returnInfo.projectBoardData = kanbanCardsAddField(thisValueStream.Id);
        }
        returnInfo.isManager = checkManagerUser();

        if(thisPageName == 'cardhierarchyview' && thisValueStream != null){
            returnInfo.kanbanCardRecords = [Select Id, 
                                                    Name, 
                                                    ValueStream__c 
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c =: thisValueStream.Id
                                                    And leankor__IsRecordDeleted__c = false
                                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                With Security_Enforced
                                                Limit 50000];
        }
        return returnInfo;
    }
    
    public class PageSetupInfo {
        @AuraEnabled
        public String orgBaseURL { get; private set; }
        @AuraEnabled
        public String baseUrlNew { get; private set; }
        @AuraEnabled
        public Boolean firstInstallValue {
            get ;
            private set;
        }
        @AuraEnabled
        public String packageVersion {
            get ;
            private set;
        }
        @AuraEnabled
        public User smallUrl { get; private set; }
        @AuraEnabled
        public List<PermissionSetAssignment> userPermissionSetAssignments { get; private set; }
        @AuraEnabled
        public Map<String, String> pageStrings { get; private set; }
        @AuraEnabled
        public list<KanbanController.TimeCardDuration> timeCardDurationValues {
            get {
                return KanbanController.getTimeCardDurationValues();
            }
            private set;
        }
        @AuraEnabled
        public Boolean newNavIntroDetails {
            get;
            private set;
        }
        @AuraEnabled
        public Boolean projectNavIntroDetails {
            get ;
            private set;
        }
        @AuraEnabled
        public String baseURL {
            get {
                return realTimeController.getBaseURL();
            }
            private set;
        }
        
        @AuraEnabled
        public Boolean checkFSLManageApp {get; private set;}
        @AuraEnabled
        public Boolean isFieldExist {get; private set;}
        @AuraEnabled
        public realTimeController.GlueforceData glueforceData {get; private set;}
        @AuraEnabled
        public List<User> filteredUsers {get; private set;}
        @AuraEnabled
        public leankor.RealTimeController.DirectLinkCardLog defaultLink {get; private set;}
        @AuraEnabled
        public Boolean introDetails {get; private set;}
		@AuraEnabled
        public string pageNamespace{get; private set;}
        @AuraEnabled
        public string urlPathPrefix{get; private set;}
		@AuraEnabled
        public PageSetupController.ConstraintData constraintData {get; private set;}
        public ProjectBoardData projectBoardData {get; private set;}
        public Boolean isManager {get; private set;}
        public List<leankor__KanbanCard__c> kanbanCardRecords = new List<leankor__KanbanCard__c>();
        public Map<String, Id> recordTypesMap;
        public List<WebLink> webLink;
        public Map<String, Id> scheduleConstraintMap;
    }

    public static leankor__Preference__c getPreference(String boardType){
        switch on boardType {
            when 'leankor__leankornav', 'leankor__leankormywork' {
                processNavPreference();
                return null;
            }
            when else {
                return getBoardPreference(boardType);
            }
        }
    }
    public static leankor__Preference__c getBoardPreference(String pageName){
        realTimeController.Preference preferenceObj = new realTimeController.Preference();
        preferenceObj.Id = '';
        preferenceObj.Name = UserInfo.getUserName();
        preferenceObj.GUID = ResourceGanttController.createGuid();
        preferenceObj.FollowOnChatter = 'all';
        preferenceObj.SubscribeToCard = 'all';
        preferenceObj.ValueStream = thisValueStream.Id;
        preferenceObj.ownerEditCard = false;
        preferenceObj.ownerMoveCard = false;
        preferenceObj.valueStreamOwner = UserInfo.getName();
        preferenceObj.CurrentUser = UserInfo.getUserId();
        preferenceObj.CardPastDueDate = true;
        preferenceObj.TaskPastDueDate = true;
        preferenceObj.Moved = false;
        preferenceObj.PercentDone = true;
        
        if(!pageName.containsIgnoreCase('Gantt')){
            preferenceObj.isTaskCompleted =true;
        }
        return realTimeController.getPreference(preferenceObj);
    }
    
    private static void processNavPreference(){
        realTimeController.Preference preferenceObj = new realTimeController.Preference();
        preferenceObj.Id = '';
        preferenceObj.Name = UserInfo.getName();
        preferenceObj.GUID = ResourceGanttController.createGuid();
        preferenceObj.FollowOnChatter = 'none';
        preferenceObj.SubscribeToCard = 'none';
        preferenceObj.ValueStream = '';
        preferenceObj.CurrentUser = UserInfo.getUserId();
        preferenceObj.CardPastDueDate = false;
        preferenceObj.TaskPastDueDate = false;
        preferenceObj.Moved = false;
        preferenceObj.PercentDone = false;
        preferenceObj.isTaskCompleted =false;
        realTimeController.getPreference(preferenceObj);
    }

    @TestVisible
    private static List<PermissionSetAssignment> getUserPermissionSetAssignments (Id userId) {
        return [Select AssigneeId,
                        Id,
                        PermissionSetId,
                        PermissionSet.Name
                    From PermissionSetAssignment
                    Where AssigneeId = :userId
                    Limit 49999
        ];
    }
    
    public static User getCurrentUserRecord () {
        return [Select Alias,
                        CompanyName,
                        ContactId,
                        Country,
                        Department,
                        FirstName,
                        FullPhotoUrl,
                        Id,
                        LastLoginDate,
                        LastName,
                        LocaleSidKey,
                        Name,
                        SmallPhotoUrl,
                        Title,
                        Username,
                        UserRoleId,
                        UserType,
                        ManagerId,
                        UserPreferencesLightningExperiencePreferred
                    From User
                    Where Id = :UserInfo.getUserId()];
    }
            
    //from url get the current page name
    @TestVisible
    private void getThisPageName() {
        String thisUrl = ApexPages.currentPage().getUrl().toLowerCase();
        if(thisUrl.containsIgnoreCase('/leankor__')){
            thisUrl = thisUrl.split('/leankor__')[1];
        } else if(thisUrl.containsIgnoreCase('apex/')){
            thisUrl =thisUrl.split('apex/')[1];
        }
        thisPageName = thisUrl.equals('leankormywork')?'leankornav':thisUrl;
        if(thisPageName.containsIgnoreCase('?')){
            thisPageName = thisPageName.substringBefore('?');
        }
    }
    
    /***
     *  Below are methods created for KanbanBoard and CalendarView Page on load
     *  some of these can be used later for other board's as well 
    ***/
    /**Start**/
    public String getFilterRecords (){
        return JSON.serialize(KanbanController.getFilterRecords(thisValueStream.Id));
    }
    
    public static String getFilteredUsers (){
        return JSON.serialize(KanbanController.getFilteredUsers(thisValueStream.Id));
    }
    
    public static leankor.RealTimeController.DirectLinkCardLog getDefaultLink(){
        return realTimeController.getDefaultLink(thisValueStream.Id);
    }
    
    public static String getBoardDependency(){
        return JSON.serialize(leankor.realTimeController.getDependency(thisValueStream.Id, thisValueStream.leankor__BoardType__c, new List<String>()));
    }

    public static string getAllKanbanStickers(){
        return JSON.serialize(realTimeController.getAllStickers(thisValueStream.Id));
    }   
    public static String getBoardScheduleModes(){
        return JSON.serialize(GanttTaskBoard.getAllScheduleMode(new List<String>{thisValueStream.Id}));
    }

    public static String getBoardScheduleMode(){
        return JSON.serialize(GanttTaskBoard.getAllScheduleModes(new List<String>{thisValueStream.Id}));
    }

    public static String getBoardSecurity(){
        return JSON.serialize(realTimeController.getSecurity(thisValueStream.Id));
    }

    //Default MyWorkItems list for LeankorNav/Mywork on load
    public static String getMyWorkItemList(){
        return JSON.serialize(ProjectBoardCarousel.getMyWorkItemList('{"rangeStartDate":null,"rangeEndDate":null,"filterType":"WORKBYDUEDATE"}'));
    }

    public class CustomNetwork{
        public String Name;
        public String UrlPathPrefix;
    }
    
    /**Auth. Ramanand - This method used to return community UrlPathPrefix frefix if avaibale on community URL*/
    private static String getUrlPathPrefix(){
        CustomNetwork customNet;
        Id networkId = Network.getNetworkId();
        String urlPathPrefix;
        try {
        if(networkId != null){
                List<SObject> networkobjs;
                networkobjs = Database.query('Select Id, UrlPathPrefix from Network where id = : networkId Limit 1');

                String net = JSON.serialize(networkobjs[0]);
                customNet = (CustomNetwork)JSON.deserialize(net, CustomNetwork.class);

                if(customNet != null){
                    urlPathPrefix = customNet.UrlPathPrefix;
        }
            }
        } catch (Exception e) {
            urlPathPrefix = '';
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return urlPathPrefix;
    }

    public static List<ScheduleConstraint__c> getScheduleConstraints(){
        List<ScheduleConstraint__c> scheduleConstraints = new List<ScheduleConstraint__c>();
        scheduleConstraints = [Select Id, 
                                        Name, 
                                        leankor__Type__c, 
                                        leankor__Description__c 
                                    From ScheduleConstraint__c 
                                    With Security_Enforced
                                    Limit 10000];
        return scheduleConstraints;
    }
    public class ConstraintData {
        public List<ScheduleConstraint__c> scheduleConstraints = new List<ScheduleConstraint__c>();
    }
    public class ProjectBoardData{
        public  Boolean scheduleBackward;
        public  DateTime projectBoardStartDate;
        public  DateTime projectBoardEndDate;
     }
     /* This method used to return data startDate ,EndDate ,and scheduleBackward in Kanban Board and White Board*/
     public static ProjectBoardData kanbanCardsAddField(Id vsId){
        leankor__ValueStream__c valueStreams = [Select Id,
                                                    leankor__ProjectBoardStartDateTime__c,
                                                    leankor__ProjectBoardEndDateTime__c,
                                                    leankor__ScheduleBackward__c
                                                    From leankor__ValueStream__c 
                                                    Where Id =: vsId 
                                                    With Security_Enforced
                                                    Limit 1];                                                 
        ProjectBoardData kanbanCardsAddField = new ProjectBoardData();
        if(String.isNotBlank(valueStreams.Id)){
            kanbanCardsAddField.scheduleBackward = valueStreams.leankor__ScheduleBackward__c;
            kanbanCardsAddField.projectBoardStartDate = valueStreams.leankor__ProjectBoardStartDateTime__c;
            kanbanCardsAddField.projectBoardEndDate = valueStreams.leankor__ProjectBoardEndDateTime__c;
        }
        return kanbanCardsAddField;
    }

    public static Boolean checkManagerUser(){
        Boolean status = false;
        Set<Id> manager = new Set<Id>();
        List<User> listOfUsers = [Select Id,
                                         ManagerId 
                                     From User 
                                     Where isActive = true];
        for(User user : listOfUsers){
            manager.add(user.ManagerId);
        }
        if(manager.contains(UserInfo.getUserId())){
            return true; 
        } 
        return false;
    }    

    private static List<WebLink> getWebLink(String objectName) {
        List<WebLink> weblinkData = new List<WebLink>();
        try {
            weblinkData = [Select Id,
                                  MasterLabel,
                                  Url
                                From WebLink
                                Where PageOrSobjectType = :objectName
                                Order By MasterLabel Asc
                                Limit 50000];
        } catch (Exception e) {
            System.debug('Exception in getWebLink: ' + e.getMessage());
        }
        return weblinkData;
    }

    /*------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    This Method Filter the Active and Deactive Flow
	    Inputs:         List of webLinks, String filtered, Set of mockActiveFlowApiNames: This Set variable is used exclusively for test classes because DML operations on FlowDefinitionView are not allowed within test classes
	    Returns:        List of WebLink 
	------------------------------------------------------------*/
    @TestVisible
    private static List<WebLink> filteredWebLink(List<WebLink> webLinks, String filtered, Set<String> mockActiveFlowApiNames) {
        List<WebLink> filteredWebLinks = new List<WebLink>();
        try {
            Set<String> activeFlowApiNames = new Set<String>();
            if(mockActiveFlowApiNames == null){
                // Query all active flows and add to a set
                List<FlowDefinitionView> flowDefinitionViews = [Select ApiName
                                                                    From FlowDefinitionView
                                                                    Where ProcessType = 'Flow'
                                                                        And IsActive = true
                                                                    With Security_Enforced
                                                                    Limit 50000];
                for (FlowDefinitionView flowDefinition : flowDefinitionViews) {
                    activeFlowApiNames.add(flowDefinition.ApiName);
                }
            }
            else{
                activeFlowApiNames = mockActiveFlowApiNames;
            }
            
            // Filter the records
            for (WebLink webLink : webLinks) {
                if (webLink.Url != null && webLink.Url.contains(filtered)) {
                    Integer index = webLink.Url.indexOf(filtered);
                    if (index >= 0) {
                        String afterFlow = webLink.Url.substring(index + filtered.length());
                        
                        // Remove any query parameters or fragments
                        Integer paramIndex = afterFlow.indexOf('?');
                        if (paramIndex >= 0) {
                            afterFlow = afterFlow.substring(0, paramIndex);
                        }
                        paramIndex = afterFlow.indexOf('#');
                        if (paramIndex >= 0) {
                            afterFlow = afterFlow.substring(0, paramIndex);
                        }
                        paramIndex = afterFlow.indexOf('&');
                        if (paramIndex >= 0) {
                            afterFlow = afterFlow.substring(0, paramIndex);
                        }
                        
                        // Split the remaining string by '/'
                        List<String> segments = afterFlow.split('/');
                        String flowApiName;
                        if (segments.size() >= 1) {
                            // The flow API name is the last segment
                            flowApiName = segments[segments.size() - 1];
                        } else {
                            // Unexpected format, skip this record
                            continue;
                        }
                        
                        // Trim any whitespace
                        flowApiName = flowApiName.trim();
                        
                        // Add to the filteredWebLinks if the flow is active
                        if (flowApiName != '' && activeFlowApiNames.contains(flowApiName)) {
                            filteredWebLinks.add(webLink);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception in filteredWebLink: ' + e.getMessage());
        }
        return filteredWebLinks;
    }
}