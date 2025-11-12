@isTest
private class PageSetupControllerTest {
    private static  String thisPageName { get; set; }
    private static final String NAMESPACE_PREFIX = 'leankor';
    private static final String VERSION = 'v55.0';
  
    @TestSetup
    static void setUpData(){
        Profile profileAdmin = [Select Id 
                                    From Profile 
                                    Where Name = 'System Administrator' 
                                    Limit 1];
        Profile profileUser = [Select Id 
                                    From Profile 
                                    Where Name='Standard User' 
                                    Limit 1];
        User userIsActive = new User( Alias = 'testLean', 
                                      Email = 'testLean@gmail.com',
                                      EmailEncodingKey ='UTF-8', 
                                      LastName ='Test', 
                                      LanguageLocaleKey ='en_US', 
                                      LocaleSidKey ='en_US', 
                                      ProfileId = profileUser.Id, 
                                      TimeZoneSidKey ='America/Los_Angeles', 
                                      UserName = 'testLean@gmail.com',
                                      isActive = true);
        insert  userIsActive;
        User userIsActiveManager = new User( ManagerID = userIsActive.id, // provide a value for Manager here
                                             Alias = 'dummyLen', 
                                             Email = 'dummyLean@gmail.com',
                                             EmailEncodingKey ='UTF-8', 
                                             LastName ='Testing', 
                                             LanguageLocaleKey ='en_US', 
                                             LocaleSidKey ='en_US', 
                                             ProfileId = profileUser.Id, 
                                             TimeZoneSidKey ='America/Los_Angeles', 
                                             UserName = 'dummyLean@gmail.com',
                                             isActive = true);
        insert  userIsActiveManager;
        User userActives = new User(Alias = 'Leantest', 
                                     Email = 'Leantest@gmail.com',
                                     EmailEncodingKey ='UTF-8', 
                                     LastName ='Testing', 
                                     LanguageLocaleKey ='en_US', 
                                     LocaleSidKey ='en_US', 
                                     ProfileId = profileAdmin.Id, 
                                     TimeZoneSidKey ='America/Los_Angeles', 
                                     UserName = 'Leantest@gmail.com',
                                     isActive = true);
        insert userActives;
        User userActivation = new User(Alias = 'Leankor', 
                                     Email = 'testLeankor@gmail.com',
                                     EmailEncodingKey ='UTF-8', 
                                     LastName ='Testing', 
                                     LanguageLocaleKey ='en_US', 
                                     LocaleSidKey ='en_US', 
                                     ProfileId = profileAdmin.Id, 
                                     TimeZoneSidKey ='America/Los_Angeles', 
                                     UserName = 'testLeankor@gmail.com',
                                     isActive = true);
        insert userActivation;
        User userInActiveManager = new User( ManagerID = userActivation.id, // provide a value for Manager here
                                             Alias = 'gNagar', 
                                             Email = 'bPatidar@gmail.com',
                                             EmailEncodingKey ='UTF-8', 
                                             LastName ='Testing', 
                                             LanguageLocaleKey ='en_US', 
                                             LocaleSidKey ='en_US', 
                                             ProfileId = profileUser.Id, 
                                             TimeZoneSidKey ='America/Los_Angeles', 
                                             UserName = 'gNagar@gmail.com',
                                             isActive = false);
        insert  userInActiveManager;
        
        leankor__ValueStream__c valueStream = new ValueStream__c();
        valueStream.Name = 'Test ValueStream';
        valueStream.leankor__BoardType__c = 'Kanban Board';
        insert valueStream;
        
        PageSetupController.thisValueStream = valueStream;
    }

    private class LeankorNavHttpResponse implements HttpCalloutMock {
     public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":432,"totalSize":432,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"attributes":{"type":"ExternalString","url":"/services/data/'+VERSION+'/tooling/sobjects/ExternalString/1010W000003H7APQA0"},"Id":"1010W000003H7APQA0","Name":"AccessBoardPermissionError"}]}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    @isTest
     private static void leankornavPageTest(){
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        ApexPages.StandardController scontroller1 = new ApexPages.StandardController(valueStream);
        PageReference pref = new PageReference('LeankorNav');
        pref.getParameters().put('id','/apex/leankor__leankornav?clc=0&isdtp=p1&ltn_app_id=06md0000001qxofaaw&nonce=4c3019907e71a693c41b5b5c5e85f4cb3e3248c2a4df2b51154c7914d62c03bf&sfdciframehost=web&sfdciframeorigin=https%3a%2f%2fleanbr2-dev-ed.lightning.force.com&tour=');
        Test.setCurrentPage(pref);
		String thisUrl = ApexPages.currentPage().getParameters().get('id');
        System.assert(thisUrl.containsIgnoreCase('/leankor__'));
        thisUrl = thisUrl.split('/leankor__')[1];
        thisPageName = thisUrl;
        System.assert(thisPageName.containsIgnoreCase('?'));
        thisPageName = thisPageName.substringBefore('?');
        System.assertEquals('leankornav', thisPageName);
    }

    @isTest
    private static void kanbanBoardTest(){
        leankor__Portfolio__c folder = new leankor__Portfolio__c(Name = 'folder');
        insert folder;
        leankor__ProjectRoom__c project = new leankor__projectRoom__c(name = 'project',leankor__Portfolio__c=folder.Id,leankor__DueDate__c = system.today(),leankor__ProjectLaunchDateTime__c=System.now()+10);
        insert project;
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'Project Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = project.Id);
        insert valueStream;
        ApexPages.StandardController scontroller1 = new ApexPages.StandardController(valueStream);
        PageReference pref = new PageReference('kanbanboard');
        pref.getParameters().put('id','/apex/leankor__kanbanboard?id='+valueStream.id+'&islightning=true');
        Test.setCurrentPage(pref);
	
		String thisUrl = ApexPages.currentPage().getParameters().get('id');
        System.assert(thisUrl.containsIgnoreCase('/leankor__'));
        thisUrl = thisUrl.split('/leankor__')[1];
        thisPageName = thisUrl;
        System.assert(thisPageName.containsIgnoreCase('?'));
        thisPageName = thisPageName.substringBefore('?');
        System.assertEquals('kanbanboard', thisPageName);
    }

   
    @isTest
    private static void getPreferenceTest(){
        String boardType ='leankor__leankornav';
        Test.startTest();
        PageSetupController.getPreference(boardType);
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
        System.assert(realTimeController.getPreference(preferenceObj) != null);
       Test.stopTest();
     }
     
    @isTest
    private static void getPreferenceTest2(){
        String boardType = 'kanbanboard';
        leankor__Portfolio__c folder = new leankor__Portfolio__c(Name = 'folder');
        insert folder;
        leankor__ProjectRoom__c project = new leankor__projectRoom__c(name = 'project',leankor__Portfolio__c=folder.Id,leankor__DueDate__c = system.today(),leankor__ProjectLaunchDateTime__c=System.now()+10);
        insert project;
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'Project Board',leankor__BoardType__c='Kanban Board',leankor__ProjectRoom__c = project.Id);
        insert valueStream;
        PageSetupController.thisValueStream = valueStream;
        Test.startTest();
        System.assert(PageSetupController.getPreference(boardType) != null);
        System.assert(PageSetupController.getBoardPreference(boardType) != null);
       Test.stopTest();
    }
    
    @isTest
    private static void getMyWorkItemListTest(){
        System.assert(PageSetupController.getMyWorkItemList()!=null);
    }   
    
    @isTest
    private static void checkManagerUserTest1(){
        User isActiveUser = [Select Id,
                                    ManagerId
                                From User
                                Where Username = 'testLean@gmail.com' 
                                Limit 1];                    
        System.runAs(isActiveUser) {
            Test.startTest();
            System.assertEquals(true, PageSetupController.checkManagerUser());
            Test.stopTest();
        }

    }

    @isTest
    private static void checkManagerUserTest2(){
        User isActiveUser = [Select Id,
                                    ManagerId
                                From User
                                Where Username = 'Leantest@gmail.com' 
                                Limit 1];                      
        System.runAs(isActiveUser) {
            Test.startTest();
            System.assertEquals(false, PageSetupController.checkManagerUser());
            Test.stopTest();
        }
    }

    @isTest
    private static void checkManagerUserTest3(){
        User isActiveUser = [Select Id,
                                    ManagerId
                                From User
                                Where Username = 'testLeankor@gmail.com' 
                                Limit 1];                     
        System.runAs(isActiveUser){
            Test.startTest();
            System.assertEquals(false, PageSetupController.checkManagerUser());
            Test.stopTest();
        }
    }

    
    @isTest
    private static void filteredWebLinktest() {
        // Prepare mock data
        List<WebLink> webLinks = new List<WebLink>{
            new WebLink(Url = '/flow/FlowA'),
            new WebLink(Url = '/flow/Namespace/FlowB'),
            new WebLink(Url = '/flow/Namespace/SubNamespace/FlowC'),
            new WebLink(Url = '/flow/FlowD?param=value'),
            new WebLink(Url = '/flow/Namespace/FlowE?param=value'),
            new WebLink(Url = '/flow/InactiveFlow') // Not in mockActiveFlowApiNames
        };
        
        // Mock active Flow API names
        Set<String> mockActiveFlowApiNames = new Set<String>{ 'FlowA', 'FlowB', 'FlowC', 'FlowD', 'FlowE' };
        List<WebLink> filteredWebLinks1 = PageSetupController.filteredWebLink(webLinks, '/flow/', mockActiveFlowApiNames);
        System.assertEquals(5, filteredWebLinks1.size(), 'Expected 5 filtered web links');
    }
    
    @isTest
    static void kanbanCardsAddFieldTest() {
        DateTime fixedStartDate = DateTime.newInstance(2024, 2, 10, 12, 0, 0);
        DateTime fixedEndDate = fixedStartDate.addDays(5);
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.leankor__ProjectBoardStartDateTime__c = fixedStartDate;
        valueStream.leankor__ProjectBoardEndDateTime__c = fixedEndDate;
        valueStream.leankor__ScheduleBackward__c = true;
        insert valueStream;
        
        Test.startTest();
        PageSetupController.ProjectBoardData result = PageSetupController.kanbanCardsAddField(valueStream.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.scheduleBackward, 'Schedule backward should be true');
        System.assertEquals(fixedStartDate,result.projectBoardStartDate, 'Project board start date should not be null');
        System.assertEquals(fixedEndDate,result.projectBoardEndDate, 'Project board end date should not be null');
    }
    
    @isTest
    static void getScheduleConstraintsTest() {
        List<ScheduleConstraint__c> expectedRecords = [Select Id, 
                                                                Name, 
                                                                leankor__Type__c, 
                                                                leankor__Description__c 
                                                            From ScheduleConstraint__c 
                                                            Limit 10000];
        
        Test.startTest();
        List<ScheduleConstraint__c> result = PageSetupController.getScheduleConstraints();
        Test.stopTest();
        
        System.assertEquals(expectedRecords.size(), result.size(), 'The number of records returned should match the expected count.');
    }
    
    @isTest
    static void getFilterRecordsTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];
        
        PageSetupController service = new PageSetupController();
        Test.startTest();
        String jsonResponse = service.getFilterRecords();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getFilterRecords should return a non-null JSON string.');
    }
    
    @isTest
    static void getFilteredUsersTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];
        
        Test.startTest();
        String jsonResponse = PageSetupController.getFilteredUsers();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getFilteredUsers should return a non-null JSON string.');
    }
    
    @isTest
    static void getDefaultLinkTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];

        Test.startTest();
        leankor.RealTimeController.DirectLinkCardLog defaultLink = PageSetupController.getDefaultLink();
        Test.stopTest();
        System.assertNotEquals(null, defaultLink, 'getDefaultLink should return a non-null DirectLinkCardLog.');
    }
    
    @isTest
    static void getBoardDependencyTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name,
                                               			leankor__BoardType__c
                                                    From ValueStream__c 
                                                    Limit 1];
        
        Test.startTest();
        String jsonResponse = PageSetupController.getBoardDependency();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getBoardDependency should return a non-null JSON string.');
    }
    
    @isTest
    static void getAllKanbanStickersTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];

        Test.startTest();
        String jsonResponse = PageSetupController.getAllKanbanStickers();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getAllKanbanStickers should return a non-null JSON string.');
    }
    
    @isTest
    static void getBoardScheduleModesTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];

        Test.startTest();
        String jsonResponse = PageSetupController.getBoardScheduleModes();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getBoardScheduleModes should return a non-null JSON string.');
    }
    
    @isTest
    static void getBoardScheduleModeTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];
        
        Test.startTest();
        String jsonResponse = PageSetupController.getBoardScheduleMode();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getBoardScheduleMode should return a non-null JSON string.');
    }
    
    @isTest
    static void getBoardSecurityTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];
        
        Test.startTest();
        String jsonResponse = PageSetupController.getBoardSecurity();
        Test.stopTest();
        System.assertNotEquals(null, jsonResponse, 'getBoardSecurity should return a non-null JSON string.');
    }
    
    @isTest
    static void urlWithLeankorPrefixTest() {
        PageReference pageRef = new PageReference('/leankor__MyPage?param=value');
        Test.setCurrentPage(pageRef);
        PageSetupController controller = new PageSetupController();
        controller.getThisPageName();
        System.assertEquals('mypage', PageSetupController.thisPageName, 'The page name should be "mypage" when the URL contains "/leankor__".');
    }
    
    @isTest
    static void urlWithApexPrefixForLeankormyworkTest() {
        PageReference pageRef = new PageReference('yg/apex/leankormywork');
        Test.setCurrentPage(pageRef);
        PageSetupController controller = new PageSetupController();
        controller.getThisPageName();
        System.assertEquals('leankornav', PageSetupController.thisPageName, 'When the URL is "/apex/leankormywork", the page name should be "leankornav".');
    }
    
    @isTest
    static void getCurrentUserRecordTest() {
        Test.startTest();
        User currentUser = PageSetupController.getCurrentUserRecord();
        Test.stopTest();
        System.assertNotEquals(null, currentUser, 'The current user record should not be null.');
        System.assertEquals(UserInfo.getUserId(), currentUser.Id, 'The returned user Id should match the current user Id.');
        System.assertNotEquals(null, currentUser.Username, 'The Username field should not be null.');
        System.assertNotEquals(null, currentUser.Name, 'The Name field should not be null.');
    }
    
    @isTest
    static void getUserPermissionSetAssignmentsTest() {
        User testUser = [Select Id From User Where Username Like 'testLean@gmail.com' Limit 1];
        
        Test.startTest();
        List<PermissionSetAssignment> psaList = PageSetupController.getUserPermissionSetAssignments(testUser.Id);
        Test.stopTest();
        System.assertNotEquals(null, psaList, 'The returned list should not be null.');
        System.assert(psaList.size() > 0, 'There should be at least one PermissionSetAssignment for the test user.');
        
        for (PermissionSetAssignment psa : psaList) {
            System.assertEquals(testUser.Id, psa.AssigneeId, 'Each PermissionSetAssignment should belong to the test user.');
        }
    }
    
    @isTest
    static void buildPageSetupInfo_GanttViewTest() {
        PageSetupController.thisValueStream = null;
        PageSetupController.thisPageName = 'SomeOtherPage';
         
        Test.startTest();
        PageSetupController.PageSetupInfo infoGantt = PageSetupController.buildPageSetupInfo('Page.ganttview');
        Test.stopTest();
        
        System.assertNotEquals(null, infoGantt, 'PageSetupInfo should not be null.');
        System.assertNotEquals(null, infoGantt.orgBaseURL, 'orgBaseURL should be set.');
        System.assertNotEquals(null, infoGantt.webLink, 'webLink should be set for ganttview.');
    }
    
    @isTest
    static void buildPageSetupInfo_LeanNavTest() {
        PageSetupController.thisPageName = 'Page.leankornav';
        
        Test.startTest();
        PageSetupController.PageSetupInfo infoNav = PageSetupController.buildPageSetupInfo('Page.leankornav');
        Test.stopTest();
        
        System.assertNotEquals(null, infoNav.newNavIntroDetails, 'newNavIntroDetails should be set for leankornav.');
        System.assertNotEquals(null, infoNav.packageVersion, 'packageVersion should be set for leankornav.');
    }
    
    @isTest
    static void buildPageSetupInfo_KanbanBoardTest() {
        PageSetupController.thisValueStream = [Select Id, Name From ValueStream__c Limit 1];
        PageSetupController.thisPageName = 'Page.kanbanboard';
        
        Test.startTest();
        PageSetupController.PageSetupInfo infoKanban = PageSetupController.buildPageSetupInfo('Page.kanbanboard');
        Test.stopTest();
        
        System.assertNotEquals(null, infoKanban.glueforceData, 'glueforceData should be set for kanbanboard.');
        System.assertNotEquals(null, infoKanban.defaultLink, 'defaultLink should be set for kanbanboard.');
        System.assertNotEquals(null, infoKanban.introDetails, 'introDetails should be set for kanbanboard.');
    }
    
    @isTest
    static void buildPageSetupInfo_CalendarViewTest() {
        PageSetupController.thisValueStream = [Select Id, Name From ValueStream__c Limit 1];
        PageSetupController.thisPageName = 'Page.calendarview';
        
        Test.startTest();
        PageSetupController.PageSetupInfo infoCalendar = PageSetupController.buildPageSetupInfo('Page.calendarview');
        Test.stopTest();
        
        System.assertNotEquals(null, infoCalendar.introDetails, 'introDetails should be set for calendarview.');
        System.assertNotEquals(null, infoCalendar.pageNamespace, 'pageNamespace should be set for calendarview.');
    }
    
    @isTest
    static void buildPageSetupInfo_CardHierarchyViewTest() {
        PageSetupController.thisValueStream = [Select Id, 
                                                        Name 
                                                    From ValueStream__c 
                                                    Limit 1];
        PageSetupController.thisPageName = 'cardhierarchyview';
        
        Test.startTest();
        PageSetupController.PageSetupInfo infoCardHierarchy = PageSetupController.buildPageSetupInfo('SomeOtherPage');
        Test.stopTest();
        
        System.assertNotEquals(null, infoCardHierarchy.kanbanCardRecords, 'kanbanCardRecords should be set for cardhierarchyview.');
        System.assert(infoCardHierarchy.kanbanCardRecords.size() <= 50000, 'The number of records should be limited to 50000.');
    }
    
    @isTest
    static void getPageSetupInfoLightningTest(){
        String result = PageSetupController.getPageSetupInfoLightning('calendarview');
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void constructorWithUtilTest() {
        Util dummyUtil = new Util();
        PageReference pageRef = new PageReference('/leankor__MyPage?param=value');
        Test.setCurrentPage(pageRef);
        PageSetupController.thisPageName = 'cardhierarchyview';
         
        PageSetupController controller = new PageSetupController(dummyUtil);
        
        System.assertNotEquals(null, controller.pageSetupInfo, 'pageSetupInfo should be set in the Util constructor.');
    }
    
    @isTest
    static void constructorWithStandardControllerValidTest() {
        // Query a valid ValueStream record from test data.
        leankor__ValueStream__c valueStream = [Select Id, 
                                                        Name 
                                                    From leankor__ValueStream__c 
                                                    Limit 1];

        ApexPages.StandardController standardController = new ApexPages.StandardController(valueStream);
        PageReference pageRef = new PageReference('/leankor__MyPage?param=value');
        Test.setCurrentPage(pageRef);
        PageSetupController controller = new PageSetupController(standardController);
        
        System.assertNotEquals(null, controller.pageSetupInfo, 'pageSetupInfo should be set in the StandardController constructor.');

    }
    
    @isTest
    static void constructorWithStandardSetControllerTest() {
        List<leankor__ValueStream__c> valueStreamList = [Select Id, 
                                                                    Name 
                                                                From leankor__ValueStream__c 
                                                                Limit 1];

        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(valueStreamList);
        PageReference pageRef = new PageReference('/leankor__MyPage?param=value');
        Test.setCurrentPage(pageRef);
        
        PageSetupController controller = new PageSetupController(standardSetController);
        
        System.assertNotEquals(null, controller.pageSetupInfo, 'pageSetupInfo should be set in the StandardSetController constructor.');
            
    }

}