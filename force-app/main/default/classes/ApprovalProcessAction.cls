/***************************************************************************
 * Author     : Reynald Ocampo
 * Description: Process record for approval using Salesforce Approval engine
 ***************************************************************************/ 
global with sharing class ApprovalProcessAction {
    @InvocableMethod
    global static List<ApprovalProcessResult> approvalProcess(List<ApprovalProcessRequest> requests) {
        return approval(requests);
    }


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


    global class ApprovalProcessResult {
        @InvocableVariable(label = 'Record ID' description = 'Record Id successfully processed for approval.')
        global String recordIdResult;
    }


    // List of valid approval process types
    private static final List<String> PROCESS_TYPES = new List<String>{'Approve', 'Reject', 'Reassign', 'Recall'};


    /*---------------------------------------------------------------------------------------------------------
     Description : Process approval
     Input       : List of ApprovalProcessRequest
     Output      : List of ApprovalProcessResult
    ----------------------------------------------------------------------------------------------------------*/      
    public static List<ApprovalProcessResult> approval(List<ApprovalProcessRequest> requests) {  
        Map<Id, ProcessWorkItem> targetObjects = new Map<Id, ProcessWorkItem>();
        List<ApprovalProcessResult> results = new List<ApprovalProcessResult>();
        List<Approval.ProcessWorkitemRequest> processWorkItemRequests = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessWorkItem> processWorkItems = getProcessWorkItems(requests, targetObjects);

        for (ProcessWorkItem processWorkItem : processWorkItems) {
            Approval.ProcessWorkitemRequest processWorkitemRequest = new Approval.ProcessWorkitemRequest();
            processWorkitemRequest.setComments(processWorkItem.comments);
            processWorkitemRequest.setAction(processWorkItem.processType);
            processWorkitemRequest.setWorkitemId(processWorkItem.workItemId);
            processWorkItemRequests.add(processWorkitemRequest);
        }

        if (!processWorkItemRequests.isEmpty()) {
            Approval.ProcessResult[] processResults = Approval.process(processWorkItemRequests, false);
            for (Approval.ProcessResult processResult : processResults) {
                if (processResult.isSuccess()) {
                    ApprovalProcessResult result = new ApprovalProcessResult();
                    result.recordIdResult = processResult.getEntityId();
                    results.add(result);

                    // send notification to submitters
                    ProcessWorkItem processWorkItem = targetObjects.get(result.recordIdResult);
                    if (String.isNotBlank(processWorkItem.notificationTypeId)) {
                        String title = 'Approval request for the ' + getSObjectLabel(result.recordIdResult).toLowerCase() + ' is ' + processResult.getInstanceStatus().toLowerCase();
                        notifyUsers(processWorkItem.notificationTypeId, new Set<String>{processWorkItem.submittedById}, title, processWorkItem.recordName, result.recordIdResult);                    
                    }
                }
            }
        }

        return results;
   }


    /*---------------------------------------------------------------------------------------------------------
     Description : Send custom notification to users
     Input       : Notification Type Id, Set of User Ids to receive, Notification Title, Target Record Id
     Output      : N/A
    ----------------------------------------------------------------------------------------------------------*/   
    @TestVisible
    private static void notifyUsers(String notificationTypeId, Set<String> recipientsIds, String title, String body, String targetId) { 
        if (notificationTypeId instanceOf Id 
        && Util.getSObjectName(notificationTypeId) == 'CustomNotificationType') { 
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationTypeId);
            notification.setTargetId(targetId);

            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
    }


    /*---------------------------------------------------------------------------------------------------------
     Description : Get work items to process
     Input       : List of ApprovalProcessRequest, Map of Object passed by reference
     Output      : List of ProcessWorkItem
    ----------------------------------------------------------------------------------------------------------*/   
    private static List<ProcessWorkItem> getProcessWorkItems(List<ApprovalProcessRequest> requests, Map<Id, ProcessWorkItem> targetObjects) {
        List<ProcessWorkItem> processWorkItems = new List<ProcessWorkItem>();
        //Map<Id, ProcessWorkItem> targetObjects = new Map<Id, ProcessWorkItem>();
        Set<Id> actorIds = new Set<Id>();

        for (ApprovalProcessRequest request : requests) {            
            if (request.recordIdRequest instanceOf Id 
            && request.approverIdRequest instanceOf Id
            && Util.getSObjectName(request.approverIdRequest) == 'User'
            && PROCESS_TYPES.contains(request.processTypeRequest)) {
                ProcessWorkItem processWorkItem = new ProcessWorkItem();
                processWorkItem.processType = request.processTypeRequest;
                processWorkItem.comments = request.commentsRequest;
                processWorkItem.recordId = request.recordIdRequest;
                processWorkItem.notificationTypeId = request.notificationTypeIdRequest;
                targetObjects.put(request.recordIdRequest, processWorkItem);
                actorIds.add(request.approverIdRequest);
            }
        }

        if (!actorIds.isEmpty()) {
            for (ProcessInstance processInstance : readProcessInstances(actorIds, targetObjects.keySet())) {
                for (ProcessInstanceWorkItem processInstanceWorkItem : processInstance.WorkItems) {
                    ProcessWorkItem processWorkItem = targetObjects.get(processInstance.TargetObjectId);
                    processWorkItem.workItemId = processInstanceWorkItem.Id;
                    processWorkItem.submittedById = processInstance.SubmittedById;
                    processWorkItem.recordName = processInstance.TargetObject.Name;
                    for (ProcessInstanceStep processInstanceStep : processInstance.Steps) {
                        processWorkItems.add(processWorkItem);
                    }

                    targetObjects.put(processInstance.TargetObjectId, processWorkItem);
                }
            }
        }

        return processWorkItems;
    }


    /*---------------------------------------------------------------------------------------------------------
     Description : Read ProcessInstance records
     Input       : Ids of responsible users for approving records, Status of the process, Ids of the records
     Output      : List of TimeSheet Ids
    ----------------------------------------------------------------------------------------------------------*/    
    private static List<ProcessInstance> readProcessInstances(Set<Id> actorIds, final Set<Id> targetObjectIds) {
        return [Select Id,
                        TargetObjectId,
                        TargetObject.Name,
                        SubmittedById,
                        (Select Id
                            From WorkItems 
                            Where ActorId In :actorIds),
                        (Select Id
                            From Steps
                            Where StepStatus = 'Started')
                    From ProcessInstance
                    Where Status = 'Pending'
                        And TargetObjectId In :targetObjectIds
                        And ProcessDefinition.Type = 'Approval'
                        And ProcessDefinition.State = 'Active'];
    }

    /*---------------------------------------------------------------------------------------------------------
     Description : Get label of object
     Input       : Record Id
     Output      : Object label
    ----------------------------------------------------------------------------------------------------------*/
    @TestVisible
    private static String getSObjectLabel(String recordId) {
        return Id.valueOf(recordId).getSObjectType().getDescribe().getLabel();
    }


    /*---------------------------------------------------------------------------------------------------------
     Description : Wrapper class for data
    ----------------------------------------------------------------------------------------------------------*/        
    public class ProcessWorkItem {
        public Id workItemId;
        public String submittedById;
    	public String recordId;
        public String recordName;
        public String comments;
        public String processType;
        public String notificationTypeId;
    }
}