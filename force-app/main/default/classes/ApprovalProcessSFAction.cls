global with sharing class ApprovalProcessSFAction {
    global class ApprovalProcessRequest {   
        @InvocableVariable(label = 'Record ID' description = 'Record Id to process for approval.' required = true)
        global String recordIdRequest;

        @InvocableVariable(label = 'Comments' description = 'Comments.' required = false)
        global String commentsRequest;        

        @InvocableVariable(label = 'Approver ID' description = 'User Id of the approver.' required = true)
        global String approverIdRequest;

        @InvocableVariable(label = 'Process Type' description = 'The approval process type, for example Approve, Reject, Reassign or Recall.' required = true)
        global String processTypeRequest;

        @InvocableVariable(label = 'Notification Type ID' description = 'The custom notification type Id that is used for sending notification message.' required = false)
        global String notificationTypeIdRequest;
    }

    @InvocableMethod
    global static List<ApprovalProcessRequest> approvalProcess(List<ApprovalProcessRequest> requests) {
        List<ApprovalProcessAction.ApprovalProcessRequest> approvalProcessRequests = new List<ApprovalProcessAction.ApprovalProcessRequest>();
        for(ApprovalProcessRequest request : requests){
            ApprovalProcessAction.ApprovalProcessRequest approvalProcessRequest = new ApprovalProcessAction.ApprovalProcessRequest();
            approvalProcessRequest.recordIdRequest = request.recordIdRequest;
            approvalProcessRequest.commentsRequest = request.commentsRequest;
            approvalProcessRequest.approverIdRequest = request.approverIdRequest;
            approvalProcessRequest.processTypeRequest = request.processTypeRequest;
            approvalProcessRequest.notificationTypeIdRequest = request.notificationTypeIdRequest;
            
            approvalProcessRequests.add(approvalProcessRequest);
        }
        List<ApprovalProcessAction.ApprovalProcessResult> result = new List<ApprovalProcessAction.ApprovalProcessResult>();
        result = ApprovalProcessAction.approvalProcess(approvalProcessRequests);
        return requests;
    }
}