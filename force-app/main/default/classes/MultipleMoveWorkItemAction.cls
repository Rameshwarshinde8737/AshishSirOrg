/**************************************************************************
 	* Company : Leankor
 	* Description : Move Multiple KanbanCard
 	* Usage	  : Use to move bulk KanbanCard through sObject request.
 	* None       : 
 **************************************************************************/ 

global with sharing class MultipleMoveWorkItemAction {
    global class KanbanCardRequest{
        @InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to move.')
        global List<leankor__Kanbancard__c> kanbanCardList = new List<leankor__Kanbancard__c>();  
        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage = false;
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload;  
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false;   
    }

    @InvocableMethod
    global static List<KanbanCardRequest> moveKanbanCardProcess(List<KanbanCardRequest> requests) {
        List<leankor.MultipleMoveKanbanCardAction.KanbanCardRequest> multipleMoveKanbanCardActionRequests = new List<leankor.MultipleMoveKanbanCardAction.KanbanCardRequest>();
        
        for (KanbanCardRequest request : requests) {
            leankor.MultipleMoveKanbanCardAction.KanbanCardRequest multipleMoveKanbanCardActionRequest = new leankor.MultipleMoveKanbanCardAction.KanbanCardRequest();
            multipleMoveKanbanCardActionRequest.kanbanCardList = request.kanbanCardList;
            multipleMoveKanbanCardActionRequest.sendBroadcastMessage = request.sendBroadcastMessage;
            multipleMoveKanbanCardActionRequest.projectId = request.projectId;
            multipleMoveKanbanCardActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            multipleMoveKanbanCardActionRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;
            
            multipleMoveKanbanCardActionRequests.add(multipleMoveKanbanCardActionRequest);
        }

        leankor.MultipleMoveKanbanCardAction.moveKanbanCardProcess(multipleMoveKanbanCardActionRequests);

        return requests;
    }
}