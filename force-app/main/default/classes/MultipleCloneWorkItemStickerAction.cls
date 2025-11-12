/*********************************************************************************
 * Company     : Leankor
 * Description: Clone KanbanCard stickers
 **************************************************************************/ 
global with sharing class  MultipleCloneWorkItemStickerAction {

    global class MultipleCloneKanbanCardStickerRequest {   
        @InvocableVariable(label = 'Cloned KanbanCard sObjects' description = 'List of cloned KanbanCard sObjects.' required = true)
        global List<leankor__KanbanCard__c> kanbanCardRequest;
    }

    /*--------------------------------------------------------------------------
	    Company:        Leankor
	    Description:    Clone KanbanCard stickers
	    Inputs:         List of MultipleCloneKanbanCardStickerRequest 
	    Returns:        List of MultipleCloneKanbanCardStickerRequest
	---------------------------------------------------------------------------*/
    @InvocableMethod
    global static List<MultipleCloneKanbanCardStickerRequest> cloneKanbanCardStickerProcess(List<MultipleCloneKanbanCardStickerRequest> requests) {
       List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest>allRequest = new List<MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest>();
       for(MultipleCloneKanbanCardStickerRequest singleRequestRecord : requests){
            MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest singleRequest = new MultipleCloneKanbanCardStickerAction.MultipleCloneKanbanCardStickerRequest();
            singleRequest.kanbanCardRequest = singleRequestRecord.kanbanCardRequest;
            allRequest.add(singleRequest);
       }
       Leankor.MultipleCloneKanbanCardStickerAction.cloneKanbanCardStickerProcess(allRequest);
       return requests;
   }

}