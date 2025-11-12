@isTest
public class TimeSheetTest {
    @TestSetup
    static void testSetup(){
        User systemAdmin = leankor.TestDataFactory.createSystemUser('sysUser');
        User communityUser1 = leankor.TestDataFactory.createCommunityUser('cUser');
        User standardUser1 = leankor.TestDataFactory.createStandardUser('sUser');

        System.runAs(systemAdmin) {
            leankor.TestDataFactory.assignpermissionSet('Visual_Lean_Customer_Community_User', communityUser1);
            leankor.TestDataFactory.assignpermissionSet('Visual_lean_user', standardUser1);
        }

        List<leankor__TimeSheet__c> testTimeSheets = new List<leankor__TimeSheet__c>();        
        List<leankor__TimeCard__c> testTimeCards = new List<leankor__TimeCard__c>();
    
        leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
        approvalNullTimeSheet.Name = 'testTimeSheet-1';
        approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
        approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
        approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
        approvalNullTimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
        testTimeSheets.add(approvalNullTimeSheet);

        leankor__TimeSheet__c timeSheetWithApproval = new leankor__TimeSheet__c();
        timeSheetWithApproval.Name = 'testTimeSheet-2';
        timeSheetWithApproval.leankor__StartDateTime__c = System.now();
        timeSheetWithApproval.leankor__EndDateTime__c = System.now()+7;
        timeSheetWithApproval.leankor__Resource__c = UserInfo.getUserId();
        timeSheetWithApproval.leankor__ApprovalHistoryStatus__c = 'pending';
        testTimeSheets.add(timeSheetWithApproval);

        leankor__TimeSheet__c approvalNullTimeSheet2 = new leankor__TimeSheet__c();
        approvalNullTimeSheet2.Name = 'testTimeSheet-3';
        approvalNullTimeSheet2.leankor__StartDateTime__c = System.now();
        approvalNullTimeSheet2.leankor__EndDateTime__c = System.now()+7;
        approvalNullTimeSheet2.leankor__Resource__c = UserInfo.getUserId();
        testTimeSheets.add(approvalNullTimeSheet2);

        insert testTimeSheets;

        leankor__TimeCard__c testTimeCard1 = new leankor__TimeCard__c();
        testTimeCard1.leankor__AssignedTo__c = UserInfo.getUserId();
        testTimeCard1.leankor__Assign_a_User__c = UserInfo.getUserId();
        testTimeCard1.leankor__Date__c = System.now().date()+1;
        testTimeCard1.leankor__Duration__c = 'Hours';
        testTimeCard1.leankor__Estimation__c = 1.0;
        testTimeCard1.leankor__Hours__c = 1.0;
        testTimeCard1.leankor__IsBillable__c = false;
        testTimeCard1.leankor__LogTime__c = System.now().date()+1;
        testTimeCard1.leankor__TimeScheduleType__c = 'Regular';
        testTimeCard1.leankor__TimeSheet__c = approvalNullTimeSheet.Id;
        testTimeCards.add(testTimeCard1);

        leankor__TimeCard__c testTimeCard2 = new leankor__TimeCard__c();
        testTimeCard2.leankor__AssignedTo__c = UserInfo.getUserId();
        testTimeCard2.leankor__Assign_a_User__c = UserInfo.getUserId();
        testTimeCard2.leankor__Date__c = System.now().date()+1;
        testTimeCard2.leankor__Duration__c = 'Hours';
        testTimeCard2.leankor__Estimation__c = 1.0;
        testTimeCard2.leankor__Hours__c = 1.0;
        testTimeCard2.leankor__IsBillable__c = false;
        testTimeCard2.leankor__LogTime__c = System.now().date()+1;
        testTimeCard2.leankor__TimeScheduleType__c = 'Regular';
        testTimeCard2.leankor__TimeSheet__c = timeSheetWithApproval.Id;
        testTimeCards.add(testTimeCard2);

        leankor__TimeCard__c testTimeCard3 = new leankor__TimeCard__c();
        testTimeCard3.leankor__AssignedTo__c = UserInfo.getUserId();
        testTimeCard3.leankor__Assign_a_User__c = UserInfo.getUserId();
        testTimeCard3.leankor__Date__c = System.now().date()+1;
        testTimeCard3.leankor__Duration__c = 'Hours';
        testTimeCard3.leankor__Estimation__c = 1.0;
        testTimeCard3.leankor__Hours__c = 1.0;
        testTimeCard3.leankor__IsBillable__c = false;
        testTimeCard3.leankor__LogTime__c = System.now().date()+1;
        testTimeCard3.leankor__TimeScheduleType__c = 'Regular';
        testTimeCard3.leankor__TimeSheet__c = approvalNullTimeSheet2.Id;
        testTimeCards.add(testTimeCard3);
        insert testTimeCards;
        
        /*Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(approvalNullTimeSheet.Id);
        request.setNextApproverIds(new Id[] { UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);*/
        
        User testUser = new User();
        testUser.Alias = 'testusr';
        testUser.Email = 'testuser@example.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'User';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = [Select Id From Profile Where Name = 'Standard User' Limit 1].Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'timeSheetTest@example.com';
        insert testUser;
        
        leankor__ValueStream__c valueStream1 = new leankor__ValueStream__c();
        valueStream1.Name = 'Test';
        insert valueStream1;
        
        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.OwnerId = UserInfo.getUserId();
        filterRec.leankor__BoardURL__c = timeSheetWithApproval.Id;
        filterRec.leankor__FeatureData__c = 'Test Feature Data';
        filterRec.leankor__User__c = UserInfo.getUserId();
        filterRec.leankor__ValueStream__c = valueStream1.Id;
        insert filterRec;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
    }

    @isTest
    static void readTimeSheetsTest(){
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        Test.startTest();
        System.runAs(standardUser) {
            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-1';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            approvalNullTimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
            insert approvalNullTimeSheet;

            System.assert( TimeSheet.readTimeSheets(new List<Id>{UserInfo.getUserId()}).size() > 0);

            try {
                List<leankor__TimeSheet__c> timeSheets =  TimeSheet.readTimeSheets(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
        System.runAs(communityUser) {
            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-1';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            approvalNullTimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
            insert approvalNullTimeSheet;

            System.assert( TimeSheet.readTimeSheets(new List<Id>{UserInfo.getUserId()}).size() > 0);

            try {
                List<leankor__TimeSheet__c> timeSheets =  TimeSheet.readTimeSheets(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
        
        Test.stopTest();
    }

    @isTest
    static void readTimeSheetsByIdsTest(){
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        List<leankor__TimeSheet__c> timeSheetIds = [Select Id 
                                                        from leankor__TimeSheet__c 
                                                        Where Name = 'testTimeSheet-1'];

        Test.startTest();
        System.runAs(standardUser) {
            System.assert( TimeSheet.readTimeSheetsByIds(new List<Id>{timeSheetIds[0].id}) != null);
            try {
                List<leankor__TimeSheet__c> timeSheets =  TimeSheet.readTimeSheetsByIds(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
        System.runAs(communityUser) {
            System.assert( TimeSheet.readTimeSheetsByIds(new List<Id>{timeSheetIds[0].id}) != null);
            try {
                List<leankor__TimeSheet__c> timeSheets =  TimeSheet.readTimeSheetsByIds(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
        
        Test.stopTest();
    }

    @isTest
    static void createTimeSheetsTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];
        
        Test.startTest();
        System.runAs(standardUser) {
            List<leankor__TimeSheet__c> testTimeSheets = new List<leankor__TimeSheet__c>();      
            List<leankor__TimeSheet__c> resultTimeSheets = new List<leankor__TimeSheet__c>();      
            
            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-3';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            testTimeSheets.add(approvalNullTimeSheet);
    
            leankor__TimeSheet__c timeSheetWithApproval = new leankor__TimeSheet__c();
            timeSheetWithApproval.Name = 'testTimeSheet-4';
            timeSheetWithApproval.leankor__StartDateTime__c = System.now();
            timeSheetWithApproval.leankor__EndDateTime__c = System.now()+7;
            timeSheetWithApproval.leankor__Resource__c = UserInfo.getUserId();
            timeSheetWithApproval.leankor__ApprovalHistoryStatus__c = 'pending';
            testTimeSheets.add(timeSheetWithApproval);

            resultTimeSheets = TimeSheet.createTimeSheets(testTimeSheets);

            System.assert(resultTimeSheets != null);
            System.assert(resultTimeSheets.size() == 2);
        }
        System.runAs(communityUser) {
            List<leankor__TimeSheet__c> testTimeSheets = new List<leankor__TimeSheet__c>();  
            List<leankor__TimeSheet__c> resultTimeSheets = new List<leankor__TimeSheet__c>();      

            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-3';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            testTimeSheets.add(approvalNullTimeSheet);
    
            leankor__TimeSheet__c timeSheetWithApproval = new leankor__TimeSheet__c();
            timeSheetWithApproval.Name = 'testTimeSheet-4';
            timeSheetWithApproval.leankor__StartDateTime__c = System.now();
            timeSheetWithApproval.leankor__EndDateTime__c = System.now()+7;
            timeSheetWithApproval.leankor__Resource__c = UserInfo.getUserId();
            timeSheetWithApproval.leankor__ApprovalHistoryStatus__c = 'pending';
            testTimeSheets.add(timeSheetWithApproval);

            resultTimeSheets = TimeSheet.createTimeSheets(testTimeSheets);

            System.assert(resultTimeSheets != null);
            System.assert(resultTimeSheets.size() == 2);
        }
        
        Test.stopTest();
    }

    @isTest
    static void updateTimeSheetsTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        List<leankor__TimeSheet__c> resulTimeSheet = new List<leankor__TimeSheet__c>();
        List<leankor__TimeSheet__c> timeSheet1 = new List<leankor__TimeSheet__c>();
        List<leankor__TimeSheet__c> timeSheet2 = new List<leankor__TimeSheet__c>();
        for (leankor__TimeSheet__c timeSheet : [Select Id, 
                                                    Name 
                                                    From leankor__TimeSheet__c 
                                                    Where Name In : new List<String>{'testTimeSheet-3','testTimeSheet-2'}])
        {
            if (timeSheet.Name == 'testTimeSheet-3') {
                timeSheet.leankor__StartDateTime__c = System.now();
                timeSheet.leankor__EndDateTime__c = System.now()+8;
                timeSheet.name = 'Updated'+timeSheet.Name; 
                timeSheet1.add(timeSheet);
            }
            if (timeSheet.Name == 'testTimeSheet-2') {
                timeSheet.leankor__StartDateTime__c = System.now()+2;
                timeSheet.leankor__EndDateTime__c = System.now()+4;
                timeSheet.name = 'Updated'+timeSheet.Name;   
                timeSheet2.add(timeSheet);
            }
        }

        Test.startTest();
        System.runAs(standardUser) {
            system.assert(TimeSheet.updateTimeSheets(timeSheet1).size() > 0);
        	system.assert(TimeSheet.updateTimeSheets(timeSheet2).size() == 0);
        }
        System.runAs(communityUser) {
            system.assert(TimeSheet.updateTimeSheets(timeSheet1).size() > 0);
        	system.assert(TimeSheet.updateTimeSheets(timeSheet2).size() == 0);
        }
        
        Test.stopTest();

    }

    @isTest
    static void deleteTimeSheetsTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        List<Id> testIds1 = new List<Id>();
        List<Id> testIds2 = new List<Id>();
        for (leankor__TimeSheet__c timeSheet : [Select Id,
                                                    Name 
                                                    From leankor__TimeSheet__c 
                                                    Where Name In : new List<String>{'testTimeSheet-3','testTimeSheet-2'}]) 
        {
            if (timesheet.Name == 'testTimeSheet-3') {
                testIds1.add(timeSheet.Id);
            }
            if (timesheet.Name == 'testTimeSheet-2') {
                testIds2.add(timeSheet.Id);
            }
        }

        Test.startTest();
        System.runAs(standardUser) {
            system.assert(TimeSheet.deleteTimeSheets(testIds1).size() > 0);
        	system.assert(TimeSheet.deleteTimeSheets(testIds2).size() == 0);
            try {
                List<Id> timeSheets =  TimeSheet.deleteTimeSheets(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
        System.runAs(communityUser) {
            system.assert(TimeSheet.deleteTimeSheets(testIds1).size() > 0);
        	system.assert(TimeSheet.deleteTimeSheets(testIds2).size() == 0);
            try {
                List<Id> timeSheets =  TimeSheet.deleteTimeSheets(new List<Id>{'00Dd0000001h60X'});
            }
            catch (Exception e) {
                System.Assert(e.getMessage().contains('Invalid input'));
            }
        }
       
        Test.stopTest();
    }

    @isTest
    static void getLastCreatedTimeSheetTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        Test.startTest();
		System.runAs(standardUser) {
            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-1';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            approvalNullTimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
            insert approvalNullTimeSheet;

            System.assert(timeSheet.getLastCreatedTimeSheet() != null);
        }
        System.runAs(communityUser) {
            leankor__TimeSheet__c approvalNullTimeSheet = new leankor__TimeSheet__c();
            approvalNullTimeSheet.Name = 'testTimeSheet-1';
            approvalNullTimeSheet.leankor__StartDateTime__c = System.now();
            approvalNullTimeSheet.leankor__EndDateTime__c = System.now()+7;
            approvalNullTimeSheet.leankor__Resource__c = UserInfo.getUserId();
            approvalNullTimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
            insert approvalNullTimeSheet;

            System.assert(timeSheet.getLastCreatedTimeSheet() != null);
        }

        Test.stopTest();
    }

    @isTest
    static void cloneTimeSheetsTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        List<leankor__TimeSheet__c> timeSheets = [Select Id, 
                                                            Name,
                                                            leankor__StartDateTime__c,
                                                            leankor__EndDateTime__c, 
                                                            leankor__Resource__c 
                                                        From leankor__TimeSheet__c 
                                                        Where Name In : new List<String>{'testTimeSheet-3','testTimeSheet-2'}];

        Test.startTest();
        System.runAs(standardUser){
            List<TimeSheet__c> resultTimeSheet = TimeSheet.cloneTimeSheets(timeSheets);
            System.assert(resultTimeSheet.size() > 0);

            List<leankor__TimeCard__c> resultTimeCard = [Select Id 
                                                            From leankor__TimeCard__c 
                                                            Where leankor__TimeSheet__c In : resultTimeSheet];

            System.assert(resultTimeCard.size() > 0);
        }
        
        Test.stopTest();
    }

    @isTest
    static void getTimeCardsTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        List<leankor__TimeSheet__c> timeSheets = [Select Id 
                                                        From leankor__TimeSheet__c 
                                                        Where Name In : new List<String>{'testTimeSheet-3','testTimeSheet-2'}];

        List<Id> timesheetIds = new List<Id>((new Map<Id, SObject>(timeSheets)).keySet());
        Test.startTest();
        System.runAs(standardUser){
            Map<Id, List<leankor__TimeCard__c>> result = TimeSheet.getTimeCards(timesheetIds);
            System.assert(result.size() > 0 );        
            System.assert(result.get(timeSheets[0].Id).Size() > 0 );        
            System.assert(result.get(timeSheets[1].Id).Size() > 0 );
        }
        
        System.runAs(communityUser){
            Map<Id, List<leankor__TimeCard__c>> result = TimeSheet.getTimeCards(timesheetIds);
            System.assert(result.size() > 0 );        
            System.assert(result.get(timeSheets[0].Id).Size() > 0 );        
            System.assert(result.get(timeSheets[1].Id).Size() > 0 );
        }
                
        Test.stopTest();
    }

    @isTest
    static void readTimeSheetsProcessApprovalsTest() {
        List<leankor__TimeSheet__c> timeSheets = [Select Id 
                                                        From leankor__timesheet__c 
                                                        Where Name ='testTimeSheet-1'];

        User testUser = [Select Id 
                            From User 
                            Where Alias = 'testusr' 
                            Limit 1];
                            
        List<ProcessInstance> processInstance = [Select Id,
                                                            Status,
                                                            (Select Id,
                                                                    ActorId
                                                                From WorkItems )
                                                        From ProcessInstance
                                                        Where TargetObjectId In:timeSheets Limit 1];
        List<String> approvalStatusList = new List<String>();

        if (!processInstance.isEmpty()) {
            approvalStatusList.add(processInstance[0].Status);
            String actorId = processInstance[0].Workitems[0].ActorId;
            Test.startTest();
            List<leankor__TimeSheet__c> resultTimeSheet = TimeSheet.readTimeSheetsProcessApprovals(actorId ,approvalStatusList);
            System.assert(resultTimeSheet.size() > 0);
            Test.stopTest();
        } else {
            List<leankor__TimeSheet__c> resultTimeSheet = TimeSheet.readTimeSheetsProcessApprovals(testUser.Id ,approvalStatusList);
            System.assert(resultTimeSheet.size() == 0);
        }
        
    }
/*
    public static testMethod void readTimeSheetsProcessInstancesTest() {
        List<leankor__TimeSheet__c> timeSheets = [Select Id From leankor__timesheet__c Where Name ='testTimeSheet-1'];
        List<ProcessInstance> processInstance = [Select Id,
                                                    Status,
                                                    (Select Id,
                                                            ActorId
                                                        From WorkItems )
                                                From ProcessInstance
                                                Where TargetObjectId In:timeSheets Limit 1];
        List<String> approvalStatusList = new List<String>();
        approvalStatusList.add(processInstance[0].Status);
        String actorId = processInstance[0].Workitems[0].ActorId;
        Test.startTest();
        Set<Id> resultProcessInstance = TimeSheet.readTimeSheetsProcessInstances(actorId ,approvalStatusList);
        System.assert(resultProcessInstance.size() > 0);
        Test.stopTest();
    }*/
    @isTest
    static void getFilterRecordValidTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        leankor__TimeSheet__c ts = [Select Id 
                                        From leankor__TimeSheet__c 
                                        Where name = 'testTimeSheet-2' 
                                        Limit 1];
        
        Test.startTest();
        System.runAs(standardUser) {
            leankor__Filter__c filterData = new leankor__Filter__c();
            filterData.Name = 'Test1';
            filterData.leankor__BoardURL__c = ts.Id;
            filterData.leankor__User__c = UserInfo.getUserId();
            insert filterData;

            List<leankor__Filter__c> filters = TimeSheet.getFilterRecord(ts.Id);

            System.assertNotEquals(null, filters, 'Expected non-null list of Filter records.');
        	System.assertEquals(1, filters.size(), 'Expected one Filter record returned.');
        }
        System.runAs(communityUser) {
        	leankor__Filter__c filterData = new leankor__Filter__c();
            filterData.Name = 'Test1';
            filterData.leankor__BoardURL__c = ts.Id;
            filterData.leankor__User__c = UserInfo.getUserId();
            insert filterData;

            List<leankor__Filter__c> filters1 = TimeSheet.getFilterRecord(ts.Id);

            System.assertNotEquals(null, filters1, 'Expected non-null list of Filter records.');
        	System.assertEquals(1, filters1.size(), 'Expected one Filter record returned.');
        }

        Test.stopTest();
    }

    @isTest
    static void upsertFilterRecordsValidTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.OwnerId = UserInfo.getUserId();
        filterRec.leankor__BoardURL__c = 'SomeBoardURL';
        filterRec.leankor__FeatureData__c = 'Test Feature Data';
        filterRec.leankor__User__c = UserInfo.getUserId();
        
        Test.startTest();
        System.runAs(standardUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            List<leankor__Filter__c> result = TimeSheet.upsertFilterRecords(filters);
            
            System.assertNotEquals(null, result[0].Id, 'Expected the filter record to have an Id after upsert.');
        }
        System.runAs(communityUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            List<leankor__Filter__c> result = TimeSheet.upsertFilterRecords(filters);
            
            System.assertNotEquals(null, result[0].Id, 'Expected the filter record to have an Id after upsert.');
        }

        Test.stopTest();
    }

    
    @isTest
    static void upsertFilterRecordsInvalidInputTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];
        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];
        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.OwnerId = UserInfo.getUserId();
        filterRec.leankor__BoardURL__c = 'SomeBoardURL';
        filterRec.leankor__FeatureData__c = 'Test Feature Data';
        filterRec.leankor__User__c = UserInfo.getUserId();
            
        filterRec.put('Id', '001000000000000AAA');
            
        Test.startTest();
        System.runAs(standardUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            Boolean exceptionThrown = false;
            try {
                TimeSheet.upsertFilterRecords(filters);
                System.assert(false, 'Expected Util.LeanException to be thrown for invalid input.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(
                    ex.getMessage().contains('Error: Invalid input'),
                    'Unexpected exception message: ' + ex.getMessage()
                );
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException to be thrown for invalid input.');
        }
        System.runAs(communityUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            Boolean exceptionThrown = false;
            try {
                TimeSheet.upsertFilterRecords(filters);
                System.assert(false, 'Expected Util.LeanException to be thrown for invalid input.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(
                    ex.getMessage().contains('Error: Invalid input'),
                    'Unexpected exception message: ' + ex.getMessage()
                );
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException to be thrown for invalid input.');
        }

        Test.stopTest();
    }

    @isTest
    static void upsertFilterRecordsDmlExceptionTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.OwnerId = UserInfo.getUserId();
        filterRec.leankor__BoardURL__c = 'SomeBoar';
        filterRec.leankor__User__c = UserInfo.getUserId();
        filterRec.leankor__ValueStream__c = '001000000000000AAA';

        Test.startTest();
        System.runAs(standardUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            Boolean exceptionThrown = false;
            try {
                TimeSheet.upsertFilterRecords(filters);
                System.assert(false, 'Expected Util.LeanException to be thrown due to DML exception.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage().contains('Exception Error:'), 'Unexpected exception message: ' + ex.getMessage());
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException to be thrown for DML exception.');
        }
        System.runAs(communityUser) {
            List<leankor__Filter__c> filters = new List<leankor__Filter__c>{ filterRec };
            
            Boolean exceptionThrown = false;
            try {
                TimeSheet.upsertFilterRecords(filters);
                
                System.assert(false, 'Expected Util.LeanException to be thrown due to DML exception.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage().contains('Exception Error:'), 'Unexpected exception message: ' + ex.getMessage());
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException to be thrown for DML exception.');
        }

        Test.stopTest();
    }
    /*
    @isTest
    static void deleteFilterRecordsValidTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        leankor__filter__c filterRec = [Select Id, 
                                                leankor__User__c, 
                                                leankor__ValueStream__c 
                                            From leankor__Filter__c 
                                            Limit 1];

        Test.startTest();
        System.runAs(standardUser) {
            Boolean result = TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });
            
            System.assert(result, 'Expected deleteFilterRecords to return true for valid input.');
            
            leankor__Filter__c updatedRec = [Select Id, 
                                                        leankor__User__c, 
                                                        leankor__ValueStream__c 
                                                    From leankor__Filter__c 
                                                    Limit 1];

            System.assertEquals(null, updatedRec.leankor__User__c, 'leankor__User__c should be null after deletion.');
            System.assertEquals(null, updatedRec.leankor__ValueStream__c, 'leankor__ValueStream__c should be null after deletion.');
        }
        System.runAs(communityUser) {
            Boolean result = TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });

            System.assert(result, 'Expected deleteFilterRecords to return true for valid input.');
            
            leankor__Filter__c updatedRec = [Select Id, 
                                                        leankor__User__c, 
                                                        leankor__ValueStream__c 
                                                    From leankor__Filter__c 
                                                    Limit 1];

            System.assertEquals(null, updatedRec.leankor__User__c, 'leankor__User__c should be null after deletion.');
            System.assertEquals(null, updatedRec.leankor__ValueStream__c, 'leankor__ValueStream__c should be null after deletion.');
        }

        Test.stopTest();
    }

    @isTest
    static void deleteFilterRecordsInvalidInputTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];

        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.Name = 'filterRecord';

        filterRec.put('Id', '001000000000000AAA');
        
        Test.startTest();
        System.runAs(standardUser) {
            Boolean exceptionThrown = false;
            try {
                TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });
                System.assert(false, 'Expected a Util.LeanException due to invalid input.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(
                    ex.getMessage().contains('Error: Invalid input'), 'Unexpected exception message: ' + ex.getMessage()
                );
            }

            System.assert(exceptionThrown, 'Expected Util.LeanException for invalid input.');
        }
        System.runAs(communityUser) {
            Boolean exceptionThrown = false;

            try {
                TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });
                System.assert(false, 'Expected a Util.LeanException due to invalid input.');
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(
                    ex.getMessage().contains('Error: Invalid input'), 'Unexpected exception message: ' + ex.getMessage()
                );
            }

            System.assert(exceptionThrown, 'Expected Util.LeanException for invalid input.');
        }

        Test.stopTest();
    }

    
    @isTest
	static void deleteFilterRecordsDmlExceptionTest() {
        User communityUser = [Select Id 
                                    From User 
                                    Where Alias = 'cUser'
                                    Limit 1];

        User standardUser = [Select Id 
                                    From User 
                                    Where Alias = 'sUser'
                                    Limit 1];
        
        leankor__Filter__c filterRec = new leankor__Filter__c();
        filterRec.Name = 'Test Filter';
        
        Test.startTest();
        
        System.runAs(standardUser) {
            Boolean exceptionThrown = false;

            try {
                TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage().contains('Exception Error:'), 'Unexpected exception message: ' + ex.getMessage());
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException for DML exception.');
        }
    
        System.runAs(communityUser) {
            Boolean exceptionThrown = false;

            try {
                TimeSheet.deleteFilterRecords(new List<leankor__Filter__c>{ filterRec });
            } catch (Util.LeanException ex) {
                exceptionThrown = true;
                System.assert(ex.getMessage().contains('Exception Error:'), 'Unexpected exception message: ' + ex.getMessage());
            }
            System.assert(exceptionThrown, 'Expected Util.LeanException for DML exception.');
        }

        Test.stopTest();
    }
    */
}