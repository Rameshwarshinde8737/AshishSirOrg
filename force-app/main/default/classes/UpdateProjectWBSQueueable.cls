/**************************************************************************
	* Company     : Leankor
 	* Description : This is a Queueable class to update Work Breakdown Structure and Sequence Number asynchronously.
 	* Usage	      : This is a Queueable class to update Work Breakdown Structure and Sequence Number asynchronously.
 	* None        : 
 **************************************************************************/ 
public with sharing class UpdateProjectWBSQueueable implements Queueable {

    private Set<Id> valueStreamIds;
    private MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest updateProjectWBSRequest;

    public UpdateProjectWBSQueueable(Set<Id> valueStreamIds, MultipleUpdateProjectWBSAction.UpdateProjectWBSRequest updateProjectWBSRequest) {
        this.valueStreamIds = valueStreamIds;
        this.updateProjectWBSRequest = updateProjectWBSRequest;
    }

    public void execute(QueueableContext context) {
        List<MultipleUpdateProjectWBSAction.UpdateProjectWBSResult> results = new List<MultipleUpdateProjectWBSAction.UpdateProjectWBSResult>();
        if(valueStreamIds.isEmpty()) {
            throw new UpdateProjectWBSQueueableException('Invalid input');
        }

        for(leankor__ValueStream__c valueStream : this.updateProjectWBSRequest.valueStreamRequests) {
            UpdateProjectWBS updateProjectWBS = new UpdateProjectWBS(new Set<Id>{valueStream.Id});
            MultipleUpdateProjectWBSAction.UpdateProjectWBSResult result = new MultipleUpdateProjectWBSAction.UpdateProjectWBSResult();
            List<Map<String, Object>> kanbanCardTree = new List<Map<String, Object>>();
            List<leankor__KanbanCard__c> kanbnanCards = new List<leankor__KanbanCard__c>();

            kanbnanCards = UpdateProjectWBS.generateProjectWorkOrderTree(kanbanCardTree, valueStream);

            result.kanbanCardResults = updateProjectWBS.updatekanbanCards(kanbnanCards);
            results.add(result); 

            //------------------- BEGIN platform event broadcast
            if (updateProjectWBSRequest.sendBroadcastMessage == true) {
                if (String.isNotBlank(updateProjectWBSRequest.projectId) && MultipleUpdateProjectWBSAction.getSObjectName(updateProjectWBSRequest.projectId) == 'leankor__ProjectRoom__c') {
                    leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
                    projectEvent.leankor__EventCategory__c = 'Updating';
                    projectEvent.leankor__EventName__c = 'EndUpdateWorkBreakdownStructure';
                    projectEvent.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                    projectEvent.leankor__ProjectID__c = updateProjectWBSRequest.projectId;
                    projectEvent.leankor__UserID__c = UserInfo.getUserId();
                    projectEvent.leankor__CustomPayload__c = updateProjectWBSRequest.projectEventCustomPayload;
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
        } 
        //------------------- END platform event broadcast  
    }


    // To Handle the exception 
    public class UpdateProjectWBSQueueableException extends Exception {}
}