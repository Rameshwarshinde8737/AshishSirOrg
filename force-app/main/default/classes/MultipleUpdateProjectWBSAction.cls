/**************************************************************************
	* Company     : Leankor
 	* Description : This API used to update Work Breakdown Structure and SeriesNumber Number.
 	* Usage	      : This API used to update Work Breakdown Structure and SeriesNumber Number.
 	* None        : 
 **************************************************************************/ 

 global with sharing class MultipleUpdateProjectWBSAction {

    global class UpdateProjectWBSRequest {
		@InvocableVariable(label = 'List of ValueStream sObjects' description = 'List of ValeStream records to update.' required = true)
		global List<leankor__ValueStream__c> valueStreamRequests; 
        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage;        
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
        global String projectId;
        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Execute Synchronously' description = 'Execute process in Synchronously')
        global Boolean syncProcess;
	}   


    global class UpdateProjectWBSResult {
        @InvocableVariable(label = 'Updated KanbanCard sObjects' description = 'List of updated KanbanCard sObjects.')
        global List<leankor__KanbanCard__c> kanbanCardResults;
    }


    @InvocableMethod
    global static List<UpdateProjectWBSResult> updateProjectWBSProcess(List<UpdateProjectWBSRequest> requests) {

        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() || 
            !kanbanCardBehaviour.isUpdateable()) {
            throw new MultipleUpdateProjectWBSActionException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        if (requests == null || requests.isEmpty()) {
            throw new MultipleUpdateProjectWBSActionException('Error: No data provided.');          
        }

        return updateProjectWBS(requests);
    }


    @TestVisible
    private static List<UpdateProjectWBSResult> updateProjectWBS(List<UpdateProjectWBSRequest> requests) {
        List<UpdateProjectWBSResult> results = new List<UpdateProjectWBSResult>();
        try {
            for (UpdateProjectWBSRequest request : requests) {
                Set<Id> valueStreamIds = new Set<Id>();

                for (leankor__ValueStream__c valueStream : request.valueStreamRequests) {
                    if (valueStream.leankor__BoardType__c == null) {
                        throw new MultipleUpdateProjectWBSActionException('Error: No board type found.');   
                    }
                    valueStreamIds.add(valueStream.Id);
                }

                if (valueStreamIds.size() > 0) {
                    if (request.syncProcess == true) {
                        for (leankor__ValueStream__c valueStream : request.valueStreamRequests) {
                            UpdateProjectWBS updateProjectWBS = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
                            UpdateProjectWBSResult result = new UpdateProjectWBSResult();
                            List<Map<String, Object>> kanbanCardTree = new List<Map<String, Object>>();
                            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

                            kanbanCards = UpdateProjectWBS.generateProjectWorkOrderTree(kanbanCardTree, valueStream);
                            result.kanbanCardResults = updateProjectWBS.updatekanbanCards(kanbanCards);
                            results.add(result);
                        }

                        //------------------- BEGIN platform event broadcast
                        if (request.sendBroadcastMessage == true) {
                            if (String.isNotBlank(request.projectId) && getSObjectName(request.projectId) == 'leankor__ProjectRoom__c') {
                                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
                                projectEvent.leankor__EventCategory__c = 'Updating';
                                projectEvent.leankor__EventName__c = 'EndUpdateProjectBreakdownStructure';
                                projectEvent.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                                projectEvent.leankor__ProjectID__c = request.projectId;
                                projectEvent.leankor__UserID__c = UserInfo.getUserId();
                                projectEvent.leankor__CustomPayload__c = request.projectEventCustomPayload;
                                projectEvent.leankor__JSONPayload__c = JSON.serialize(valueStreamIds);
    
                                // Call method to publish events
                                Database.SaveResult saveResult = EventBus.publish(projectEvent);
                                if (!saveResult.isSuccess()){
                                    // quick error processing, no need to Rollback
                                    for (Database.Error error : saveResult.getErrors()) {
                                        System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                                    }
                                    // continue on because a failed platform event is no big deal; do NOT rollback
                                }   
                            }
                        }
                        //------------------- END platform event broadcast  
                    } else {
                        if(!Test.isRunningTest()) {
                            UpdateProjectWBSQueueable updateProjectWBSQueueable = new UpdateProjectWBSQueueable(valueStreamIds, request);
                            System.enqueueJob(updateProjectWBSQueueable);
                        }
                    }
                }
            }
        } catch(Exception e) {
            throw new MultipleUpdateProjectWBSActionException('Error: ' + e.getMessage());          
        }

        return results;
    }


    public static String getSObjectName(String recordId) {
        return Id.valueOf(recordId).getSObjectType().getDescribe().getName();
    }


    // To Handle the exception 
    public class MultipleUpdateProjectWBSActionException extends Exception {}
}