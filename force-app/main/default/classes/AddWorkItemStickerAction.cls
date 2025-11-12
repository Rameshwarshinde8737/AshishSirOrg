/*********************************************************************************
* Company     : Leankor
* Description : Add Sticker into The Given The Cards
*********************************************************************************/ 
global with sharing class AddWorkItemStickerAction {
    global class StickerDataRequest{
        @invocableVariable(label='Kanban Card ID' description='You must provide either this Card ID.' )
             Global ID KanbanID;
 
         @invocableVariable(label='Sticker ID' description='You must provide stickerID which to be add on card.' )
             Global ID StickerID;
             
         @invocableVariable(label='Sticker Name' description='You must provide stickerName which to be add on card.' )
             Global String StickerName;
    }

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Add Sticker into The Given The Cards
	    Inputs:         List of StickerDataRequest
	    Returns:        List of StickerDataRequest
	------------------------------------------------------------*/
    @InvocableMethod 
    global static List<StickerDataRequest> AddCardStickerAction(List<StickerDataRequest> remoteRequest){

        List<AddKanbanCardStickerAction.StickerDataRequest> allRequest = new List<AddKanbanCardStickerAction.StickerDataRequest>();
        for(StickerDataRequest singleRequest : remoteRequest){
            AddKanbanCardStickerAction.StickerDataRequest request = new AddKanbanCardStickerAction.StickerDataRequest();
            request.KanbanID = singleRequest.KanbanID;
            request.StickerID = singleRequest.StickerID;
            request.StickerName = singleRequest.StickerName;
            allRequest.add(request);
        }
        Leankor.AddKanbanCardStickerAction.AddCardStickerAction(allRequest);
        return remoteRequest;
    }


}