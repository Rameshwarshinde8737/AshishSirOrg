@isTest
private class ApprovalProcessSFActionTest {

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
        List<ApprovalProcessSFAction.ApprovalProcessRequest> requests = new List<ApprovalProcessSFAction.ApprovalProcessRequest>();
        ApprovalProcessSFAction.ApprovalProcessRequest request = new ApprovalProcessSFAction.ApprovalProcessRequest();
        request.recordIdRequest = approvalTimeSheet.Id;
        request.commentsRequest = 'I want to approval ';
        request.approverIdRequest = UserInfo.getUserID();
        request.processTypeRequest = 'Approve';
        requests.add(request);
        Test.StartTest();
        List<ApprovalProcessSFAction.ApprovalProcessRequest> approvalProces = ApprovalProcessSFAction.approvalProcess(requests);
        System.AssertEquals(requests.size(),approvalProces.size());
        Test.StopTest();
    }
}