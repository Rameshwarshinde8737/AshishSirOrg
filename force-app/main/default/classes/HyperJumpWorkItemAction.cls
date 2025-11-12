/**************************************************************************
 	* Company : Leankor
 	* Description : HyperJump KanbanCard
 	* Usage	  : Use to Hyperjump KanbanCard.
 	* None       : 
 **************************************************************************/ 
global with sharing class HyperJumpWorkItemAction {
    global class HyperJumpRequest{
        @InvocableVariable(label = 'Kanban Card ID' description = 'Kanban Card ID' )
            global String KanbanCardID;
        @InvocableVariable(label = 'KanbanCard Name' description = 'The Title found on the front of the Card.')
            global  String KanbanName;
        @InvocableVariable(label = 'Name Of Present Board' description = 'The Project Board name.' required=true)
            global String OldVSName;
        @InvocableVariable(label = 'Name Of HyperJump Room' description = 'The Project Room name to where you want the card to travel.')
            global String NewPRName;
        @InvocableVariable(label = 'Name Of HyperJump Board' description = 'The Project Board name to where you want the card to travel.' required=true)
            global String NewVSName;
        @InvocableVariable(label = 'Template Name' description = 'The Category of Card that is valid for the target Project Board. The current Category may not be available on Target Board.' required=true)
            global  String TemplateName;
        @InvocableVariable(label = 'Board Type' description = 'Describe the type of board' )
            global String BoardType;
        @InvocableVariable(label = 'Old ValueStream ID' description = 'Old ValueStream ID' )
            global String OldVSId;      
        @InvocableVariable(label = 'New ValueStream ID' description = 'New ValueStream ID' )
            global String NewVSId;      
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		    global Boolean generateWorkBreakdownStructure = false;  
    }

    @InvocableMethod
    global static List<HyperJumpRequest> HyperjumpToBoard(List<HyperJumpRequest> requests) {
        List<leankor.HyperJumpAction.HyperJumpRequest> hyperJumpRequests = new List<leankor.HyperJumpAction.HyperJumpRequest>();
        for (HyperJumpRequest request : requests) {
            leankor.HyperJumpAction.HyperJumpRequest hyperJumpRequest = new leankor.HyperJumpAction.HyperJumpRequest();
            hyperJumpRequest.KanbanCardID = request.KanbanCardID;
            hyperJumpRequest.KanbanName = request.KanbanName;
            hyperJumpRequest.OldVSName = request.OldVSName;
            hyperJumpRequest.NewPRName = request.NewPRName;
            hyperJumpRequest.NewVSName = request.NewVSName;
            hyperJumpRequest.TemplateName = request.TemplateName;
            hyperJumpRequest.BoardType = request.BoardType;
            hyperJumpRequest.OldVSId = request.OldVSId;
            hyperJumpRequest.NewVSId = request.NewVSId;
            hyperJumpRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            hyperJumpRequests.add(hyperJumpRequest);
        }

        leankor.HyperJumpAction.HyperjumpToBoard(hyperJumpRequests);
        return requests;
    }
}