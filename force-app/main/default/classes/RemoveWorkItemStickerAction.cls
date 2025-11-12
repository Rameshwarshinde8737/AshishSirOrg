/*********************************************************************************
* Company     : Leankor
* Description : Remove Sticker on The card
*********************************************************************************/ 
global with sharing class RemoveWorkItemStickerAction {
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    global class StickerDataRequest {
        @InvocableVariable(label='Kanban Card ID' description='You must provide either this Card ID.' )
            global Id KanbanID;

        @InvocableVariable(label='Sticker ID' description='You must provide stickerID which to be Remove on card.' )
            global Id StickerID;
            
        @InvocableVariable(label='Sticker Name' description='You must provide stickerName which to Remove add on card.' )
            global String StickerName;
    }

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Remove Sticker
	    Inputs:         List of StickerDataRequest
	    Returns:        List of StickerDataRequest
	------------------------------------------------------------*/
    @InvocableMethod 
    global static List<StickerDataRequest> RemoveCardStickerAction(List<StickerDataRequest> remoteRequest) {
        List<Leankor.RemoveKanbanCardStickerAction.StickerDataRequest> allRequest = new List<Leankor.RemoveKanbanCardStickerAction.StickerDataRequest>();
        for(RemoveWorkItemStickerAction.StickerDataRequest singleRequest : remoteRequest){
            Leankor.RemoveKanbanCardStickerAction.StickerDataRequest request = new Leankor.RemoveKanbanCardStickerAction.StickerDataRequest();
            request.KanbanID = singleRequest.KanbanID;
            request.StickerID = singleRequest.StickerID;
            request.StickerName = singleRequest.StickerName;
            allRequest.add(request);
        }
        Leankor.RemoveKanbanCardStickerAction.RemoveCardStickerAction(allRequest);
        return remoteRequest;
    }
}