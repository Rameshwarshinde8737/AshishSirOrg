global with sharing class MultipleUpdateWorkItemAction {
    global class KanbanCardRequest { 
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to update.')
	    global List<leankor__Kanbancard__c> kanbancardList = new List<leankor__Kanbancard__c> ();     
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board')
		global Boolean sendBroadcastMessage = false;
		@InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload;
	}

    @InvocableMethod
    global static List<KanbanCardRequest> updateKanbanCardProcess(List<KanbanCardRequest> requests) {
        List<leankor.MultipleUpdateKanbanCardAction.KanbanCardRequest> multipleUpdateKanbanCardActionRequests = new List<leankor.MultipleUpdateKanbanCardAction.KanbanCardRequest>();
        
        for(KanbanCardRequest request : requests){
            leankor.MultipleUpdateKanbanCardAction.KanbanCardRequest multipleUpdateKanbanCardActionRequest = new leankor.MultipleUpdateKanbanCardAction.KanbanCardRequest();
            multipleUpdateKanbanCardActionRequest.kanbancardList = request.kanbancardList;
            multipleUpdateKanbanCardActionRequest.sendBroadcastMessage = request.sendBroadcastMessage;
            multipleUpdateKanbanCardActionRequest.projectId = request.projectId;
            multipleUpdateKanbanCardActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;

            multipleUpdateKanbanCardActionRequests.add(multipleUpdateKanbanCardActionRequest);
        }

        leankor.MultipleUpdateKanbanCardAction.updateKanbanCardProcess(multipleUpdateKanbanCardActionRequests);

        return requests;
    }
}