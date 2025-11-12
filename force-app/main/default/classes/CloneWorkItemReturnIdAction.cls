/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CloneCardReturnIdAction.cls
* CLASS: CloneCardReturnIdAction
* USAGE: manages for Cloning Card.
*/
global with sharing class CloneWorkItemReturnIdAction {
    global class CloneKanbanCardRequest{
        @InvocableVariable(label = 'Due Date' description = 'The deadline for the deliverable.' )
            global DateTime FinalDate;
        @InvocableVariable(label = 'Start Date' description = 'The start date for the deliverable.' )
            global DateTime StartDate;    
        @InvocableVariable(label = 'Kanban Card ID' description = 'You must provide either this Card ID or the URL obtained from the Copy URL button.' )
            global Id KanbanID;
        @InvocableVariable(label = 'URL' description = 'The URL obtained from clicking on the Copy URL button of a Card.')
            global String CardURL;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
            global Boolean generateWorkBreakdownStructure = false; 
    }

    @InvocableMethod
    global static List<CloneKanbanCardRequest> cloneKanbanCards(List<CloneKanbanCardRequest> requests) {
        List<CloneCardReturnIdAction.CloneKanbanCardRequest> cloneKanbanCardRequests = new List<CloneCardReturnIdAction.CloneKanbanCardRequest>();
        Set<Id> kanbanCardIds = new Set<Id>();
        Boolean generateWorkBreakdownStructure = false;
        for (CloneKanbanCardRequest request : requests) {
            CloneCardReturnIdAction.CloneKanbanCardRequest cloneKanbanCardRequest = new CloneCardReturnIdAction.CloneKanbanCardRequest();
            cloneKanbanCardRequest.FinalDate = request.FinalDate;
            cloneKanbanCardRequest.StartDate = request.StartDate;
            cloneKanbanCardRequest.KanbanID = request.KanbanID;
            cloneKanbanCardRequest.CardURL = request.CardURL;

            cloneKanbanCardRequests.add(cloneKanbanCardRequest);
            generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;
        }
        List<CloneCardReturnIdAction.CloneKanbanCardResult> cloneKanbanCardResults = CloneCardReturnIdAction.cloneKanbanCards(cloneKanbanCardRequests);
        Set<String> valueStreamIds = new Set<String>();
        for (CloneCardReturnIdAction.CloneKanbanCardResult cloneKanbanCardResult : cloneKanbanCardResults) {
            kanbanCardIds.add(cloneKanbanCardResult.kanbanCardId);
        }

        for (leankor__KanbanCard__c kanbanCard : [Select leankor__ValueStream__c
                                                            From leankor__KanbanCard__c
                                                            Where Id In :kanbanCardIds
                                                            Limit 50]) {
            valueStreamIds.add(kanbanCard.leankor__ValueStream__c);
        }

        if (!valueStreamIds.isEmpty() && generateWorkBreakdownStructure == true) {
            CreateKanbanCardsQueueable.updateProjectWBS(valueStreamIds);
        }
        return requests;
    }
}