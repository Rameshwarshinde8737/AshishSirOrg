/*********************************************************************************
* Company     : Leankor
* Description : Delete the cards
*********************************************************************************/ 
global with sharing class DeleteWorkItemAction {

    global class KanbanCardRequest {
        @InvocableVariable(label = 'Kanban Card List' description = 'List of Kanban Card as Input' required = true)
       	global List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();  	 
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
        global Boolean generateWorkBreakdownStructure = false;            
    }

    @InvocableMethod
    global static List<KanbanCardRequest> deleteKanbanCardProcess(List<KanbanCardRequest> remoteRequest) {
        List<Leankor.DeleteKanbanCardAction.KanbanCardRequest> allRequest = new List<Leankor.DeleteKanbanCardAction.KanbanCardRequest>();
        for (DeleteWorkItemAction.KanbanCardRequest singleRequest : remoteRequest) {
            Leankor.DeleteKanbanCardAction.KanbanCardRequest request = new Leankor.DeleteKanbanCardAction.KanbanCardRequest();
            request.kanbanCards = singleRequest.kanbanCards;
            request.generateWorkBreakdownStructure = singleRequest.generateWorkBreakdownStructure;
            allRequest.add(request);
        }
        Leankor.DeleteKanbanCardAction.deleteKanbanCardProcess(allRequest);
        return remoteRequest;
    }
    
}