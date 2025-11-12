/**
* Copyright 2019-2020 Lucidsoft Inc. All rights reserved.
* FILE:  MultipleExportProjectBoardActionTest.cls
* CLASS: MultipleExportProjectBoardActionTest
* USAGE: Provides testing for exporting both Plan Gantt and Kanban Boards to JSON files that are "importable"
*/

@isTest
private class MultipleExportProjectBoardActionTest {
    
    // board types
    private static final String BOARD_TYPE_PG = 'UberBoard'; // actually Plan Gantt on UI
    private static final String BOARD_TYPE_KB = 'Kanban Board';
    private static final String BOARD_TYPE_RU = 'Plan Board'; // actually Rollup Board on UI
    private static final String BOARD_TYPE_WB = 'Whiteboard';

    // card types
    private static final String ACTIVITY = 'ActivityCard';
    private static final String ACTIVITYGROUP = 'FolderCard';
    private static final String MILESTONE = 'MileStoneCard';

    // resource types
    private static final String LABOR = 'Labor';

    // use KBC_TYPESID.get(ID from RecordTypeId).getDeveloperName() to get the string name of the Record Type
    // use KBC_TYPESNM.get(API Name).getRecordTypeId() to get the ID of the Record Type
    private static final Map<Id,Schema.RecordTypeInfo> KBC_TYPESID = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosById();
    private static final Map<String,Schema.RecordTypeInfo> KBC_TYPESNM = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName();
    private static final Map<String,Schema.RecordTypeInfo> RES_TYPESNM = Schema.SObjectType.leankor__Resource__c.getRecordTypeInfosByName();
    

    // Valid profile values are System Administrator, Standard User
    static Map <String, Id> profileMap = new Map <String, Id>();        
    // valid role values are subject to change 
    static Map <String, Id> roleMap = new Map <String, Id>();
    // the leankor permission set used for all new users
    static PermissionSet leankorPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Visual_Lean_Designer' LIMIT 1];

    Public MultipleExportProjectBoardActionTest(){
        createMapLookups();
    }

    @isTest static void runPositiveCases() {
        User myRunUser;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> resultList;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requestList = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest>(); 
        MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest oneRequest;
        leankor__ValueStream__c oneVS;

        if (profileMap.size() == 0) createMapLookups();

        System.runAs((myRunUser=buildUsers())){

            oneVS = buildGantt(myRunUser);

            // export PG
            oneRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
            oneRequest.vsId = oneVS.Id;
            oneRequest.fileName = 'LeankorExport1';
            requestList.add(oneRequest);
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts
            Boolean expected = true;
            Boolean actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

            // export again with JSON
            oneRequest.isReturnJSONString = true;
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts again
            actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

        }
        return;
    }

    @isTest static void runNegativeCases(){
        User myRunUser;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> resultList;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requestList = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest>(); 
        MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest oneRequest;
        leankor__ValueStream__c oneVS;

         if (profileMap.size() == 0) createMapLookups();

        System.runAs((myRunUser=buildUsers())){

            oneVS = buildCrappyGantt(myRunUser);

            // export PG
            oneRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
            oneRequest.vsId = oneVS.Id;
            oneRequest.fileName = 'LeankorExport2';
            requestList.add(oneRequest);
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts
            Boolean expected = true;
            Boolean actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

            // blow away VS and try to run again
            delete oneVS;
            oneRequest.fileName = 'LeankorExport3';
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts
            expected = false;
            actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

        }
        return;
    }


    @isTest static void runKBCases(){
        User myRunUser;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> resultList;
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requestList = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest>(); 
        MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest oneRequest;
        leankor__ValueStream__c oneVS;

         if (profileMap.size() == 0) createMapLookups();

        System.runAs((myRunUser=buildUsers())){

            oneVS = buildKB(myRunUser);

            // export PG
            oneRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
            oneRequest.vsId = oneVS.Id;
            oneRequest.fileName = 'LeankorExport2';
            requestList.add(oneRequest);
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts
            Boolean expected = true;
            Boolean actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

            // blow away VS and try to run again
            delete oneVS;
            oneRequest.fileName = 'LeankorExport3';
            resultList = MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);

            // asserts
            expected = false;
            actual = resultList.get(0).status;
            System.assertEquals(expected, actual);

        }
        return;
    }

    // build PG
    private static leankor__ValueStream__c buildGantt(User myRunUser){
        // build the VS
        leankor__ProjectRoom__c pr = createProjectTestRecord('First Project');
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
        insert activity1;
        // activity 2
        leankor__KanbanCard__c activity2 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITY).getRecordTypeId(), 'Some work 2', 'GUID789', 0,myRunUser.Id, kct1.Id, ag1);
        insert activity2;

        // dependencies
        leankor__Dependency__c dep1_2 = createDependencyTestRecord(vs.Id, activity1, activity2);
        insert dep1_2;

        return vs;
    }

     // build PG
     private static leankor__ValueStream__c buildKB(User myRunUser){
        // build the VS
        leankor__ProjectRoom__c pr = createProjectTestRecord('Some KB Project');
        insert pr;
        leankor__ValueStream__c vs = createValueStreamTestRecord(pr.Id, BOARD_TYPE_KB);
        insert vs;

        leankor__KanbanCardTemplate__c kct1 = createKanbanCardTemplateTestRecord('Work');
        insert kct1;       
        // activity 1
        leankor__KanbanCard__c activity1 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITY).getRecordTypeId(), 'Some work 1', 'GUID456', 0,myRunUser.Id, kct1.Id, null);
        insert activity1;
        // activity 2
        leankor__KanbanCard__c activity2 = createKanbanCardRecord(vs.Id, KBC_TYPESNM.get(ACTIVITY).getRecordTypeId(), 'Some work 2', 'GUID789', 0,myRunUser.Id, kct1.Id, null);
        insert activity2;

        //resource 1
        leankor__Resource__c res1 = createResourceRecord(myRunUser);
        insert res1;
        // resource assignment to each KBC
        leankor__ResourceAssignment__c resAssignActivity1 = createAssignmentRecord(res1, activity1);
        leankor__ResourceAssignment__c resAssignActivity2 = createAssignmentRecord(res1, activity2);
        insert resAssignActivity1;
        insert resAssignActivity2;

        return vs;
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

    // set up the key profile and role maps
    private static void createMapLookups(){
        for (Profile myProfile : [SELECT Name, Id FROM Profile]){
            profileMap.put(myProfile.Name, myProfile.Id);
           // system.debug(myProfile.Name+'  $$ '+myProfile.Id);
        }
        for (UserRole myRole : [SELECT Name, Id FROM UserRole]){
            roleMap.put(myRole.Name, myRole.Id);
            //system.debug(myRole.Name+'  **  '+myRole.Id);
        }
        return;
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

    // sets up Category
    private static leankor__KanbanCardTemplate__c createKanbanCardTemplateTestRecord(String functionname){
        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(Name = functionname);
        return kct;
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

    // Valid profile values are System Administrator and Standard User
    // valid role values are CEO???
    // usrName must be an email format
    private static User createUserRecord (String usrName, String profileName, String roleName){

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

    //
    // Create a Resource record for later assignment by using the USER record created above
    //
    private static leankor__Resource__c createResourceRecord (User usr){
        leankor__Resource__c lr = new leankor__Resource__c( leankor__User__c = usr.Id,
                                                            RecordTypeId = RES_TYPESNM.get(LABOR).getRecordTypeId()
                                                            );
        return lr;
    }

    //
    // Create Resource Assignment between a Resource and KBC record
    //
    private static leankor__ResourceAssignment__c createAssignmentRecord(leankor__Resource__c res, leankor__KanbanCard__c kbc){
        leankor__ResourceAssignment__c lra = new leankor__ResourceAssignment__c (   leankor__KanbanCard__c = kbc.Id,
                                                                                    leankor__AssignedTo__c = res.leankor__User__c,
                                                                                    leankor__PercentAllocation__c = 1,
                                                                                    leankor__PercentCompleted__c = 0,
                                                                                    leankor__ResourceType__c = null

                                                                                    );
        return lra;
    }

        // sets up a Leankor Permission Set
    private static PermissionSetAssignment createLeankorPermissionSetAssignmentTestRecord(Id usr) {
        
        PermissionSetAssignment perm = new PermissionSetAssignment( PermissionSetId = leankorPermSet.Id,
                                                                    AssigneeId = usr);
        return perm;
    }

}