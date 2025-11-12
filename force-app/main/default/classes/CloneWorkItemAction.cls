/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateWorkItemAction.cls
* CLASS: CreateWorkItemAction
* USAGE: manages to clone Record of KanbanCard.
**/
global with sharing class CloneWorkItemAction {
    global class CloneKanbanCardRequest{
        @InvocableVariable(label = 'Due Date' description = 'The deadline for the deliverable.' )
            global DateTime FinalDate;
        @InvocableVariable(label = 'Start Date' description = 'The start date for the deliverable.' )
            global DateTime StartDate;
        @InvocableVariable(label = 'Kanban Card ID' description = 'You must provide either this Card ID or the URL obtained from the Copy URL button.' )
            global ID KanbanID;
        @InvocableVariable(label = 'URL' description = 'The URL obtained from clicking on the Copy URL button of a Card.')
            global String CardURL;
        @InvocableVariable(label = 'Linked Folder Name' description = 'Name of the Linked Folder where Linked Room would located.')
            global String LinkedFolderName;       
        @InvocableVariable(label = 'Linked Room Name' description = 'Name of the Link Project Room where Linked Board is located.')
            global String LinkedRoomName;
        @InvocableVariable(label = 'Linked Board Name' description = 'Name of the Link Board to Linked .')
            global String LinkedBoardName;
        @InvocableVariable(label = 'Link Board Id' description = 'ID of the Link Board to Linked with merge Cards.')
            global String LinkedBoardId;        
        @InvocableVariable(label = 'Linked Card Name' description = 'Name of Link Kanban Card Which to linked.')
            global String LinkedCardName;
        @InvocableVariable(label = 'Linked Card ID' description = 'Name of Link Kanban Card Which to linked.')
            global String LinkedCardId;   
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
            global Boolean generateWorkBreakdownStructure = false;              
    }

    @InvocableMethod
    global static List<CloneKanbanCardRequest> cloneKanbanCards(List<CloneKanbanCardRequest> requests) {
        List<CloneKanbanCardAction.CloneKanbanCardRequest> cloneKanbanCardRequests = new List<CloneKanbanCardAction.CloneKanbanCardRequest>();
        for (CloneKanbanCardRequest request : requests) {
            CloneKanbanCardAction.CloneKanbanCardRequest cloneKanbanCardRequest = new CloneKanbanCardAction.CloneKanbanCardRequest();
            cloneKanbanCardRequest.FinalDate = request.FinalDate;
            cloneKanbanCardRequest.StartDate = request.StartDate;
            cloneKanbanCardRequest.KanbanID = request.KanbanID;
            cloneKanbanCardRequest.CardURL = request.CardURL;
            cloneKanbanCardRequest.LinkedFolderName = request.LinkedFolderName;
            cloneKanbanCardRequest.LinkedRoomName = request.LinkedRoomName;
            cloneKanbanCardRequest.LinkedBoardName = request.LinkedBoardName;
            cloneKanbanCardRequest.LinkedBoardId = request.LinkedBoardId;
            cloneKanbanCardRequest.LinkedCardName = request.LinkedCardName;
            cloneKanbanCardRequest.LinkedCardId = request.LinkedCardId;
            cloneKanbanCardRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            cloneKanbanCardRequests.add(cloneKanbanCardRequest);
        }
        CloneKanbanCardAction.CloneKanbanCards(cloneKanbanCardRequests);
        return requests;
    }
}