/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  MultipleCreateWorkItemAction.cls
* CLASS: MultipleCreateWorkItemAction
* USAGE: manages to create multiple KanbanCard reocrds.
**/
global with sharing class MultipleCreateWorkItemAction {
    global class KanbanCardRequest {
        @InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to create.')
        global List <leankor__KanbanCard__c> kanbanCardRequests;  
        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage; 
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
        global String projectId;
        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
        global Boolean generateWorkBreakdownStructure = false; 
        public String title;
		public String categoryName;  
		public Id ownerID;
		public String projectBoardName;	
        
        
    } 

    @InvocableMethod
    global static List<KanbanCardRequest> createKanbanCardProcess(List<KanbanCardRequest> requests) {
        List<leankor.MultipleCreateKanbanCardAction.KanbanCardRequest> multipleCreateKanbanCardActionRequests = new List<leankor.MultipleCreateKanbanCardAction.KanbanCardRequest>();
        
        for (KanbanCardRequest request : requests) {
            leankor.MultipleCreateKanbanCardAction.KanbanCardRequest multipleCreateKanbanCardActionRequest = new leankor.MultipleCreateKanbanCardAction.KanbanCardRequest();
            multipleCreateKanbanCardActionRequest.kanbanCardRequests = request.kanbanCardRequests;
            multipleCreateKanbanCardActionRequest.sendBroadcastMessage = request.sendBroadcastMessage;
            multipleCreateKanbanCardActionRequest.projectId = request.projectId;
            multipleCreateKanbanCardActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            multipleCreateKanbanCardActionRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            multipleCreateKanbanCardActionRequests.add(multipleCreateKanbanCardActionRequest);
        }

        leankor.MultipleCreateKanbanCardAction.createKanbanCardProcess(multipleCreateKanbanCardActionRequests);

        return requests;
    }   
}