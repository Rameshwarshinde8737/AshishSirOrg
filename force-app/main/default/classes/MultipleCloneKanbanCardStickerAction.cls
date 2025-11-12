/**************************************************************************
 * Author     : Reynald Ocampo
 * Description: Clone KanbanCard stickers
 **************************************************************************/ 
global with sharing class MultipleCloneKanbanCardStickerAction {
    @InvocableMethod
    global static List<MultipleCloneKanbanCardStickerResult> cloneKanbanCardStickerProcess(List<MultipleCloneKanbanCardStickerRequest> requests) {
        return cloneKanbanCardStickers(requests);
    }

    global class MultipleCloneKanbanCardStickerRequest {   
        @InvocableVariable(label = 'Cloned KanbanCard sObjects' description = 'List of cloned KanbanCard sObjects.' required = true)
        global List<leankor__KanbanCard__c> kanbanCardRequest;
    }

    global class MultipleCloneKanbanCardStickerResult{
        @InvocableVariable(label = 'Cloned KanbanCardSticker sObjects' description = 'List of cloned KanbanCardSticker sObjects.')
        global List<leankor__KanbanCardSticker__c> kanbanCardStickerResult;
    }

    public static List<MultipleCloneKanbanCardStickerResult> cloneKanbanCardStickers(List<MultipleCloneKanbanCardStickerRequest> requests) {
     	List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        for (MultipleCloneKanbanCardStickerRequest request : requests) {
            kanbanCards.addAll(request.kanbanCardRequest);
        }

        MultipleCloneKanbanCardStickerResult result = new MultipleCloneKanbanCardStickerResult();
        if (kanbanCards.size() > 0) {
            result.kanbanCardStickerResult = KanbanCardSticker.cloneKanbanCardStickers(kanbanCards);
        }
        
        List<MultipleCloneKanbanCardStickerResult> results = new List<MultipleCloneKanbanCardStickerResult>();
        results.add(result);

        return results;
    }
}