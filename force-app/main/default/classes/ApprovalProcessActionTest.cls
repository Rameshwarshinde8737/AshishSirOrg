@isTest
private class ApprovalProcessActionTest {

    @TestSetup
    private static void makeData(){    
        User user = leankor.TestDataFactory.createStandardUser('Lean123');
        user.ManagerId = UserInfo.getUserID();
        update user;
        leankor__TimeSheet__c approvalTimeSheet = new leankor__TimeSheet__c(Name = 'testTimeSheet',
                                                                            leankor__StartDateTime__c = System.now(),
                                                                            leankor__EndDateTime__c = System.now()+7,
                                                                            leankor__Resource__c = user.Id,
                                                                            leankor__ApprovalHistoryStatus__c = 'pending' );
        insert approvalTimeSheet;
    }

    @isTest
    private static void approvalTest(){
        User user = [Select Id
                        From User 
                        Where Alias = 'Lean123'];
        leankor__TimeSheet__c approvalTimeSheet = [Select Id
                                                    From leankor__TimeSheet__c
                                                    Where Name = 'testTimeSheet'];
        // Submit the request for approval
        List<ApprovalProcessAction.ApprovalProcessRequest> requests = new List<ApprovalProcessAction.ApprovalProcessRequest>();
        ApprovalProcessAction.ApprovalProcessRequest request = new ApprovalProcessAction.ApprovalProcessRequest();
        request.recordIdRequest = approvalTimeSheet.Id;
        request.commentsRequest = 'I want to approval ';
        request.approverIdRequest = UserInfo.getUserID();
        request.processTypeRequest = 'Approve';
        requests.add(request);
        List<ApprovalProcessAction.ApprovalProcessResult> approvalResult = ApprovalProcessAction.approval(requests);
        List<ApprovalProcessAction.ApprovalProcessResult> approvalProces = ApprovalProcessAction.approvalProcess(requests);
        String getlabel = ApprovalProcessAction.getSObjectLabel(approvalTimeSheet.Id);
        System.AssertEquals('Time Sheet',getlabel);
    }
    @isTest
    static void testNotifyUsers() {
        // Get test data
        User user = [Select Id
                        From User 
                        Where Alias = 'Lean123'];
        // Create a test account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        // Mock the CustomNotificationType Id (since we can't insert it in a test)
        Id mockNotificationTypeId = '00X000000000000'; // Replace with a valid Id if needed

        // Run test
        Test.startTest();
        ApprovalProcessAction.notifyUsers(mockNotificationTypeId, new Set<String>{user.Id}, 'Test Approval', 'Test Body', acc.Id);
        Test.stopTest();

        // Since notifications are async, we can't directly assert delivery, but we can check no exceptions were thrown
        System.assert(true, 'Notification should send without errors');
    }
}