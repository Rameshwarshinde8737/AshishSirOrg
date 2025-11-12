@isTest
private class LeankorExportProjectTest {
    
    // board types
    private static final String BOARD_TYPE_PG = 'UberBoard'; // actually Plan Gantt on UI
    
    // card types
    private static final String ACTIVITY = 'ActivityCard';
    private static final String ACTIVITYGROUP = 'FolderCard';
    
    private static final Map<String,Schema.RecordTypeInfo> KBC_TYPESNM = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName();
    
    // Valid profile values are System Administrator, Standard User
    static Map <String, Id> profileMap = new Map <String, Id>();   
	// valid role values are subject to change 
    static Map <String, Id> roleMap = new Map <String, Id>();    
    // the leankor permission set used for all new users
    static PermissionSet leankorPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Visual_Lean_Designer' LIMIT 1];
    
    public LeankorExportProjectTest(){
        createMapLookups();
    }
    
    // build PG
    private static leankor__ValueStream__c buildCrappyGantt(User myRunUser){
        // build the VS
        leankor__ProjectRoom__c pr = createProjectTestRecord('Second Crap Project');
        insert pr;
        leankor__ValueStream__c vs = createValueStreamTestRecord(pr.Id, BOARD_TYPE_PG);
        insert vs;

        // build the AG
        leankor__KanbanCardTemplate__c kct1 = createKanbanCardTemplateTestRecord('Work');
        insert kct1;
        leankor__KanbanCard__c ag1 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITYGROUP).getRecordTypeId(), 'My AG 1', 'GUID123', 0,myRunUser.Id, kct1.Id, null);
        insert ag1;

        // activity 1
        leankor__KanbanCard__c activity1 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITY).getRecordTypeId(), 'Some work 1', 'GUID456', 0,myRunUser.Id, kct1.Id, ag1);
        activity1.leankor__isRecordDeleted__c = true;
        insert activity1;
        // activity 2
        leankor__KanbanCard__c activity2 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITY).getRecordTypeId(), 'Some work 2', 'GUID789', 0,myRunUser.Id, kct1.Id, ag1);
        insert activity2;

        // dependencies
        leankor__Dependency__c dep1_2 = createDependencyTestRecord(vs.Id, activity1, activity2);
        insert dep1_2;

        return vs;
    }
    
    @isTest static void test() {
        User myRunUser;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> resultList;
		List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requestList = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest>();
        MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest oneRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
        leankor__ValueStream__c oneVS;
        
        if (profileMap.size() == 0) createMapLookups();
        
        System.runAs((myRunUser=buildUsers())){
            oneVS = buildCrappyGantt(myRunUser);
            oneRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
            oneRequest.vsId = oneVS.Id;
            oneRequest.fileName = 'LeankorExport2';
            requestList.add(oneRequest);
            resultList = LeankorExportProject.exportProjects(requestList);
        }
    }
    
    // sets up a single Project for insertion to database
    private static leankor__ProjectRoom__c createProjectTestRecord(String projName) {
        leankor__ProjectRoom__c projectTestRecord = new leankor__ProjectRoom__c(Name = projName);
        return projectTestRecord;
    }
    
    // sets up a single VS for insertion to database
    // boardType can be 'UberBoard' or 'Kanban Board'
    private static leankor__ValueStream__c createValueStreamTestRecord(String projectRoomId, String boardType) {
        leankor__ValueStream__c valueStreamTestRecord = new leankor__ValueStream__c();
        valueStreamTestRecord.leankor__ProjectRoom__c = projectRoomId;
        valueStreamTestRecord.leankor__BoardType__c = boardType;
        valueStreamTestRecord.leankor__isRecordDeleted__c = false;
        valueStreamTestRecord.leankor__IsTemplateBoard__c = false;
        return valueStreamTestRecord;
    }
    
    // sets up a single KBC for insertion to database
    // inputs include valuestream parent ID, short description of the work, a unique ID, percent complete whole number, the ID of assigned owner, Id of the Category/KCT
    private static leankor__KanbanCard__c createKanbanCardRecord(Id valueStreamId, Id recId, String name, String guid, Integer percentComplete, Id usr, Id kctId, leankor__KanbanCard__c parentAG) {
		leankor__KanbanCard__c kanbanCardTestRecord = new leankor__KanbanCard__c();
        kanbanCardTestRecord.RecordTypeId = recId;
		kanbanCardTestRecord.leankor__isRecordDeleted__c = false;
		kanbanCardTestRecord.leankor__ValueStream__c = valueStreamId;
		kanbanCardTestRecord.Name = name;
		kanbanCardTestRecord.leankor__GUID__c = guid;
		kanbanCardTestRecord.leankor__PercentComplete2__c = percentComplete;
        //kanbanCardTestRecord.OwnerId = usr;
        kanbanCardTestRecord.leankor__KanbanCardTemplate__c = kctId;
        if (parentAG != null){
            kanbanCardTestRecord.leankor__ValueStreamCardLink__c = parentAG.Id;
            kanbanCardTestRecord.leankor__ValueStreamLink__c = valueStreamId;
        }
        return kanbanCardTestRecord;
    }
    
    // sets up dependency
    private static leankor__Dependency__c createDependencyTestRecord(Id vsId, leankor__KanbanCard__c predecessor, leankor__KanbanCard__c successor){
        leankor__Dependency__c dep = new leankor__Dependency__c(leankor__Predecessor__c = predecessor.Id,
                                                                leankor__PredecessorType__c = 'Start To Finish',
                                                                leankor__Successor__c = successor.Id,
                                                                leankor__SuccessorType__c = 'Start To Finish',
                                                                leankor__LagLead__c = 0,
                                                                leankor__LagLeadUnit__c = 'Days',
                                                                leankor__ValueStream__c = vsId);
        return dep;
    }
    
    // sets up Category
    private static leankor__KanbanCardTemplate__c createKanbanCardTemplateTestRecord(String functionname){
        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(Name = functionname);
        return kct;
    }
    
    // build users
    private static User buildUsers(){
        User someUser = createUserRecord('joe@bloww.leankor.com', 'System Administrator', 'CEO');
        System.debug('aa  '+someUser);
        insert someUser;
        SYstem.debug('BB');
        PermissionSetAssignment someUserPerm = createLeankorPermissionSetAssignmentTestRecord(someUser.Id);
		insert someUserPerm;
        return someUser;
    }
    
        // sets up a Leankor Permission Set
    private static PermissionSetAssignment createLeankorPermissionSetAssignmentTestRecord(Id usr) {
        
        PermissionSetAssignment perm = new PermissionSetAssignment( PermissionSetId = leankorPermSet.Id,
                                                                    AssigneeId = usr);
        return perm;
    }
    
    private static User createUserRecord (String usrName, String profileName, String roleName){
		System.debug(profileMap);
        User usr = new User(LastName = 'Bourne',
                            FirstName='Jason',
                            Alias = 'JB',
                            Email = usrName,
                            Username = usrName,
                            ProfileId = profileMap.get(profileName),
                            //UserRoleId = roleMap.get(roleName),
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            isActive = true,
                            leankor__Rate__c = 1212 // secret key to filter out all non-test USERS because Test Classes have full visibility
                            );
        return usr;  
    }
    
    // set up the key profile and role maps
    private static void createMapLookups(){
        System.debug('createMapLookups');
        for (Profile myProfile : [SELECT Name, Id FROM Profile]){
            system.debug(myProfile);
            profileMap.put(myProfile.Name, myProfile.Id);
           // system.debug(myProfile.Name+'  $$ '+myProfile.Id);
        }
        for (UserRole myRole : [SELECT Name, Id FROM UserRole]){
            roleMap.put(myRole.Name, myRole.Id);
            //system.debug(myRole.Name+'  **  '+myRole.Id);
        }
        return;
    }
}