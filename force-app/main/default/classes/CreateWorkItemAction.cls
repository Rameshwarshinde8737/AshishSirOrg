/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateWorkItemAction.cls
* CLASS: CreateWorkItemAction
* USAGE: manages to create Record of KanbanCard.
**/
global with sharing class CreateWorkItemAction {
    global class KanbanCardRequest {   
		@InvocableVariable(label = 'GUID' description = 'External Id for kanban card.')
		global String GUID;
		@InvocableVariable(label = 'Title' description = 'Title that appears on the front of the Card' required=true)
		global String Title;
		@InvocableVariable(label = 'Top' description = 'Top screen coordinate of the Card' )
		global Decimal Top;
		@InvocableVariable(label = 'Bottom' description = 'Bottom screen coordinate of the Card.')
		global Decimal Bottom;
		@InvocableVariable(label = 'Left' description = 'Left screen coordinate of the Card.')
		global Decimal Left;
		@InvocableVariable(label = 'X' description = 'X coordinate of the Card.')
		global Decimal X;
		@InvocableVariable(label = 'Y' description = 'Y coordinate of the Card.')
		global Decimal Y;
		@InvocableVariable(label = 'Custom fields' description = 'The custom field definitions in JSON format.')
		global String JSONDefinition; 
		@InvocableVariable(label = 'Custom field values' description = 'The Category applied to the new Card.')
		global String JSONData; 
		@InvocableVariable(label = 'Category Name' description = 'The Category applied to the new Card.' required = true )
		global String CategoryName;       
		@InvocableVariable(label = 'Description' description = 'A long description of the Card.' )
		global String Description;
		@InvocableVariable(label = 'Acceptance Criteria' description = 'A long Acceptance Criteria of the Card.' )
		global String AcceptanceCriteria;
		@InvocableVariable(label = 'Point' description = 'Point on card for agile Board.')
		global Decimal Point; 
		@InvocableVariable(label = 'Effort Remaining' description = 'Effort Remaining on card .')
		global Decimal EffortRemaining;            
		@InvocableVariable(label = 'DueDate' description = 'Due Date of the Card')
		global DateTime DueDate;
		@InvocableVariable(label = 'EstimatedDuration' description = 'The numerical duration or effort of the work.')
		global Decimal EstimatedDuration;
		@InvocableVariable(label = 'DurationUnits' description = 'Must be either Minutes, Days, Months or Years.')
		global String DurationUnits;    
		@InvocableVariable(label = 'Priority' description = 'Must be 3 for lowest priority and 1 for highest priority.')
		global Integer Priority;    
		@InvocableVariable(label = 'OwnerID' description = 'This is the Owner of the Card. The ID is at the end of the URL when viewing the User record in Setup.' required = true)
		global ID OwnerID;
		@InvocableVariable(label = 'Percent Complete' description = 'The percent of a Card that is completed. Represented as a decimal value of 0, 0.25, 0.5, 0.75 or 1.' )
		global Decimal HarveyBall;  
		@InvocableVariable(label = 'Linked Kanban Card Id' description = 'The Card ID to which this card is linked.')
		global String ValueStreamCardLink;
		@InvocableVariable(label = 'Linked Project Board Id' description = 'The Project Board ID on which the Linked Kanban Card is located.')
		global String ValueStreamLinkID;
		@InvocableVariable(label = 'Account ID' description = 'The ID of the Account linked to this Card.' )
		global String Account;
		@InvocableVariable(label = 'Opportunity ID' description = 'The ID of the Opportunity linked to this Card.')
		global String Opportunity;
		@InvocableVariable(label = 'Contact ID' description = 'The ID of the Contact linked to this Card.')
		global String Contact;
		@InvocableVariable(label = 'Case ID' description = 'The ID of the Case linked to this card.')
		global String CaseID;
		@InvocableVariable(label = 'Order' description = 'The Card order in the column on the Board. ')
		global Decimal Order;
		@InvocableVariable(label = 'Zone GUID' description = 'The unique ID of the column in which the Card resides. ')
		global String ZoneID;
		@InvocableVariable(label = 'Zone ID' description = 'The unique ID of the Zone in which the Card resides. ')
		global String ZoneForceID;
		@InvocableVariable(label = 'MC ID ' description = 'The unique ID of the MC in which the Card resides. ')
		global String MCForceID;
		@InvocableVariable(label = 'SW ID' description = 'The unique ID of the SW in which the Card resides. ')
		global String SWForceID;    
		@InvocableVariable(label = 'OnBudget' description = 'Does the Card represent work that is on Budget? Green, Amber or Red.')
		global String OnBudget;
		@InvocableVariable(label = 'OnQuality' description = 'Does the Card represent work that is on Quality? Green, Amber or Red.')
		global String OnQuality;
		@InvocableVariable(label = 'OnTime' description = 'Does the Card represent work that is on Time? Green, Amber or Red.')
		global String OnTime;        
		@InvocableVariable(label = 'Start Date' description = 'The Start Date of the work represented by the Card.')
		global DateTime StartDate;
		@InvocableVariable(label = 'Project Board Name' description = 'String name of selected Project Board.' required = true)
		global String ProjectBoardName;
		@InvocableVariable(label = 'Project Folder Name' description = 'Name of the Folder where its Room would located.')
		global String ProjectFolderName;
		@InvocableVariable(label = 'Project Room Name' description = 'String name of selected Project Room in which the Board resides.')
		global String ProjectRoomName;
		@InvocableVariable(label = 'Project Board Id' description = 'The ID of the selected Project Board. This is not required if you specify the Room and Board Names')
		global String ProjectBoardId;
		@InvocableVariable(label = 'URL Link' description = 'URL For Link to Card ')
		global String UrlLink;    
		@InvocableVariable(label = 'Master Container Name' description = 'Name of Master container for new kanban card.')
		global String MCName;
		@InvocableVariable(label = 'Swimlane Name' description = 'Name of Swimlane for new kanban card.')
		global String SWName;
		@InvocableVariable(label = 'Column Name' description = 'Name of column for new kanban card.')
		global String ZoneName;
		// Linked Folder, Linked Room, Linked Board, Linked Card
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
		@InvocableVariable(label = 'User Defined Card ID' description = 'card ID which will show on card records')
		global String CardId;
		@InvocableVariable(label = 'HarveyBall Done Date' description = 'HarveyBall status complete Date')
		global Date HarveyBallDoneDate;
		@InvocableVariable(label = 'Promise Completion Date ' description = 'Promise Completion Date of card')
		global DateTime PromiseCompletionDate;       
		@InvocableVariable(label = 'Kanban Card List ' description = 'List of Kanban Card as Input')
		global List <leankor__KanbanCard__c> KanbanCardList;  	              
		@InvocableVariable(label = 'Record Type Name' description = 'Record Type Name of the card')
		global String RecordTypeName;     
		@InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
        global Boolean generateWorkBreakdownStructure = false; 
    }

    @InvocableMethod
    global static List<KanbanCardRequest> createKanbanCardProcess(List<KanbanCardRequest> requests) {
        List<leankor.CreateKanbanCardAction.KanbanCardRequest> kanbanCardRequests = new List<leankor.CreateKanbanCardAction.KanbanCardRequest>();

        for (KanbanCardRequest request : requests) {
            leankor.CreateKanbanCardAction.KanbanCardRequest kanbanCardRequest = new leankor.CreateKanbanCardAction.KanbanCardRequest();
            kanbanCardRequest.GUID = request.GUID;
            kanbanCardRequest.Title = request.Title;
            kanbanCardRequest.Top = request.Top;
            kanbanCardRequest.Bottom = request.Bottom;
            kanbanCardRequest.Left = request.Left;
            kanbanCardRequest.X = request.X;
            kanbanCardRequest.Y = request.Y;
            kanbanCardRequest.JSONDefinition = request.JSONDefinition;
            kanbanCardRequest.JSONData = request.JSONData;
            kanbanCardRequest.CategoryName = request.CategoryName;
            kanbanCardRequest.Description = request.Description;
            kanbanCardRequest.AcceptanceCriteria = request.AcceptanceCriteria;
            kanbanCardRequest.Point = request.Point;
            kanbanCardRequest.EffortRemaining = request.EffortRemaining;
            kanbanCardRequest.DueDate = request.DueDate;
            kanbanCardRequest.EstimatedDuration = request.EstimatedDuration;
            kanbanCardRequest.DurationUnits = request.DurationUnits;
            kanbanCardRequest.Priority = request.Priority;
            kanbanCardRequest.OwnerID = request.OwnerID;
            kanbanCardRequest.HarveyBall = request.HarveyBall;
            kanbanCardRequest.ValueStreamCardLink = request.ValueStreamCardLink;
            kanbanCardRequest.ValueStreamLinkID = request.ValueStreamLinkID;
            kanbanCardRequest.Account = request.Account;
            kanbanCardRequest.Opportunity = request.Opportunity;
            kanbanCardRequest.Contact = request.Contact;
            kanbanCardRequest.CaseID = request.CaseID;
            kanbanCardRequest.Order = request.Order;
            kanbanCardRequest.ZoneID = request.ZoneID;
            kanbanCardRequest.ZoneForceID = request.ZoneForceID;
            kanbanCardRequest.MCForceID = request.MCForceID;
            kanbanCardRequest.SWForceID = request.SWForceID;
            kanbanCardRequest.OnBudget = request.OnBudget;
            kanbanCardRequest.OnQuality = request.OnQuality;
            kanbanCardRequest.OnTime = request.OnTime;
            kanbanCardRequest.StartDate = request.StartDate;
            kanbanCardRequest.ProjectBoardName = request.ProjectBoardName;
            kanbanCardRequest.ProjectFolderName = request.ProjectFolderName;
            kanbanCardRequest.ProjectRoomName = request.ProjectRoomName;
            kanbanCardRequest.ProjectBoardId = request.ProjectBoardId;
            kanbanCardRequest.UrlLink = request.UrlLink;
            kanbanCardRequest.MCName = request.MCName;
            kanbanCardRequest.SWName = request.SWName;
            kanbanCardRequest.ZoneName = request.ZoneName;
            kanbanCardRequest.LinkedFolderName = request.LinkedFolderName;
            kanbanCardRequest.LinkedRoomName = request.LinkedRoomName;
            kanbanCardRequest.LinkedBoardName = request.LinkedBoardName;
            kanbanCardRequest.LinkedBoardId = request.LinkedBoardId;
            kanbanCardRequest.LinkedCardName = request.LinkedCardName;
            kanbanCardRequest.LinkedCardId = request.LinkedCardId;
            kanbanCardRequest.CardId = request.CardId;
            kanbanCardRequest.HarveyBallDoneDate = request.HarveyBallDoneDate;
            kanbanCardRequest.PromiseCompletionDate = request.PromiseCompletionDate;
            kanbanCardRequest.KanbanCardList = request.KanbanCardList;
            kanbanCardRequest.RecordTypeName = request.RecordTypeName;
			kanbanCardRequest.generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;

            kanbanCardRequests.add(kanbanCardRequest);
        }
        leankor.CreateKanbanCardAction.createKanbanCardProcess(kanbanCardRequests);
        return requests;
    }
}