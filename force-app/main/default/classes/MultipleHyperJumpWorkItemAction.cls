/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  MultipleHyperJumpWorkItemAction.cls
* CLASS: MultipleHyperJumpWorkItemAction
* USAGE: manages to Hyperjump multiple KanbanCard reocrds.
**/
global with sharing class MultipleHyperJumpWorkItemAction {
    global class MultipleHyperJumpRequest {
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to hyper jump.' required=true)
		global List<leankor__KanbanCard__c> kanbanCardRequests = new List<leankor__KanbanCard__c> ();
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message to affected board.')
		global Boolean sendBroadcastMessage;
		@InvocableVariable(label = 'Project Board Id' description = 'Project board id to place the hyper jumped records.' required=true)
		global String targetBoardId;
		@InvocableVariable(label = 'Zone Id' description = 'Zone id to place the hyper jumped records.')
		global String targetZoneId;
		@InvocableVariable(label = 'Category Id' description = 'Category id of the hyper jumped records.')
		global String targetCategoryId;
		@InvocableVariable(label = 'Project Board Id To Link' description = 'Project board id to link the hyper jumped records.')
		global String targetLinkBoardId;
        @InvocableVariable(label = 'Card Id To Link' description = 'Card id to link the hyper jumped records.')
		global String targetLinkCardId;
        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false; 
	}

    @InvocableMethod
    global static List<MultipleHyperJumpRequest> hyperJumpKanbanCardProcess(List<MultipleHyperJumpRequest> requests) {
        List<leankor.MultipleHyperJumpAction.MultipleHyperJumpRequest> multipleHyperJumpActionRequests = new List<leankor.MultipleHyperJumpAction.MultipleHyperJumpRequest>();
        
        for (MultipleHyperJumpRequest request : requests) {
            leankor.MultipleHyperJumpAction.MultipleHyperJumpRequest multipleHyperJumpActionRequest = new leankor.MultipleHyperJumpAction.MultipleHyperJumpRequest();
            multipleHyperJumpActionRequest.kanbanCardRequests = request.kanbanCardRequests;
            multipleHyperJumpActionRequest.sendBroadcastMessage = request.sendBroadcastMessage;
            multipleHyperJumpActionRequest.targetBoardId = request.targetBoardId;
            multipleHyperJumpActionRequest.targetZoneId = request.targetZoneId;
            multipleHyperJumpActionRequest.targetCategoryId = request.targetCategoryId;
            multipleHyperJumpActionRequest.targetLinkBoardId = request.targetLinkBoardId;
            multipleHyperJumpActionRequest.targetLinkCardId = request.targetLinkCardId;
            multipleHyperJumpActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            multipleHyperJumpActionRequest.projectId = request.projectId;
            multipleHyperJumpActionRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            multipleHyperJumpActionRequests.add(multipleHyperJumpActionRequest);
        }

        leankor.MultipleHyperJumpAction.hyperJumpKanbanCardProcess(multipleHyperJumpActionRequests);

        return requests;
    }
}