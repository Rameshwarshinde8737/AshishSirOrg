/*********************************************************************************
* Company     : Leankor
* Description : manages to Move Record of Card
*********************************************************************************/ 
global with sharing class MoveWorkItemAction {

    global class KanbanCardRequest{   
        @invocableVariable(label = 'Kanban Card Id' description = 'The ID of the Card.')
            global String Id;
        @invocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
            global string CardURL;
        @invocableVariable(label = 'Master Container Name' description = 'The string name of the Master Container to where the Card is moved.')
            global String MCName;
        @invocableVariable(label = 'Swimlane Name' description = 'The string name of the Swimlane to where the Card is moved.')
            global String SwimlaneName;
        @invocableVariable(label = 'Column Name' description = 'The string name of the Column to where the Card is moved.')
            global String ColumnName;
        @invocableVariable(label = 'Sobject Kanbancard List' description = 'The List of kanbabancard to where List of card is moved.')
            global List<leankor__Kanbancard__c> KanbancardList =new List<leankor__Kanbancard__c>();  
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		    global Boolean generateWorkBreakdownStructure = false;  
    }

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Move  the Given The Cards
	    Inputs:         List of KanbanCardRequest
	    Returns:        List of KanbanCardRequest
	------------------------------------------------------------*/
    @InvocableMethod
    global static List<KanbanCardRequest> moveKanbanCardProcess(List<KanbanCardRequest> requests) {
        List<Leankor.MoveKanbanCardAction.KanbanCardRequest> allRequest = new List<Leankor.MoveKanbanCardAction.KanbanCardRequest>();
        for (MoveWorkItemAction.KanbanCardRequest singleRequest : requests) {
            Leankor.MoveKanbanCardAction.KanbanCardRequest request = new Leankor.MoveKanbanCardAction.KanbanCardRequest();
            request.Id = singleRequest.Id;
            request.CardURL = singleRequest.CardURL;
            request.MCName = singleRequest.MCName;
            request.SwimlaneName = singleRequest.SwimlaneName;
            request.ColumnName = singleRequest.ColumnName;
            request.KanbancardList = singleRequest.KanbancardList;
            request.generateWorkBreakdownStructure = singleRequest.generateWorkBreakdownStructure;
            allRequest.add(request);
        }
        Leankor.MoveKanbanCardAction.moveKanbanCardProcess(allRequest);
        return requests;
    }
   
}