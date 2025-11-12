/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateWorkItemAction.cls
* CLASS: CreateWorkItemAction
* USAGE: manages to clone multiple KanbanCards.
**/

global with sharing class MultipleCloneWorkItemAction {
    global class MultipleCloneKanbanCardRequest {
        @InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to clone.' required=true)
        global List<leankor__KanbanCard__c> kanbanCardRequests = new List<leankor__KanbanCard__c> ();
        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage;
        @InvocableVariable(label = 'Project Board Id' description = 'Project board id to place the cloned records.' required=true)
        global String targetBoardId;
        @InvocableVariable(label = 'Zone Id' description = 'Zone id to place the cloned records.')
        global String targetZoneId;
        @InvocableVariable(label = 'Category Id' description = 'Category id of the cloned records.')
        global String targetCategoryId;
        @InvocableVariable(label = 'Project Board Id To Link' description = 'Project board id to link the cloned records.')
        global String targetLinkBoardId;
        @InvocableVariable(label = 'Card Id To Link' description = 'Card id to link the cloned records.')
        global String targetLinkCardId;
        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
        global Boolean generateWorkBreakdownStructure = false;
    }

    @InvocableMethod
    global static List<MultipleCloneKanbanCardRequest> cloneKanbanCardProcess(List<MultipleCloneKanbanCardRequest> requests) {
        List<leankor.MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest> multipleCloneKanbanCardActionRequests = new List<leankor.MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest>();
        
        for (MultipleCloneKanbanCardRequest request : requests) {
            leankor.MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest multipleCloneKanbanCardActionRequest = new leankor.MultipleCloneKanbanCardAction.MultipleCloneKanbanCardRequest();
            multipleCloneKanbanCardActionRequest.kanbanCardRequests = request.kanbanCardRequests;
            multipleCloneKanbanCardActionRequest.sendBroadcastMessage = request.sendBroadcastMessage;
            multipleCloneKanbanCardActionRequest.targetBoardId = request.targetBoardId;
            multipleCloneKanbanCardActionRequest.targetZoneId = request.targetZoneId;
            multipleCloneKanbanCardActionRequest.targetCategoryId = request.targetCategoryId;
            multipleCloneKanbanCardActionRequest.targetLinkBoardId = request.targetLinkBoardId;
            multipleCloneKanbanCardActionRequest.targetLinkCardId = request.targetLinkCardId;
            multipleCloneKanbanCardActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            multipleCloneKanbanCardActionRequest.projectId = request.projectId;
            multipleCloneKanbanCardActionRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            multipleCloneKanbanCardActionRequests.add(multipleCloneKanbanCardActionRequest);
        }

        leankor.MultipleCloneKanbanCardAction.cloneKanbanCardProcess(multipleCloneKanbanCardActionRequests);

        return requests;
    }
}