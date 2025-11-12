/*********************************************************************************
* Company     : Leankor
* Description : manages to Upadte Record of Card
*********************************************************************************/ 
global with sharing class UpdateWorkItemAction {

    global class KanbanCardRequest { 
	    @InvocableVariable(label='AcceptanceCriteria' description='Kanban Card Record for Acceptance Criteria.')
	    global String AcceptanceCriteria;
	    @InvocableVariable(label='Custom Card Id' description='Custom Card Id.')
	    global String CardID;  
	    @InvocableVariable(label='Kanban Card Id' description='Kanban Card Record Id.' required=true)
	    global String Id;
	    @InvocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
	    global String CardURL;
	    @InvocableVariable(label='Title' description='The title that appears on the front of the Card.')
	    global String Title;
	    @InvocableVariable(label='Point' description='Point of the Card.' )
	    global Decimal Point;
	    @InvocableVariable(label='Top' description='Top screen coordinate of the Card.' )
	    global Decimal Top;
	    @InvocableVariable(label='Bottom' description='Bottom screen coordinate of the Card.')
	    global Decimal Bottom;
	    @InvocableVariable(label='Left' description='Left screen coordinate of the Card.')
	    global Decimal Left;
	    @InvocableVariable(label='Width' description='Width of the Card (only applies to Whiteboard).')
	    global Decimal Width;
	    @InvocableVariable(label='Height' description='Height of the Card (only applies to Whiteboard).')
	    global Decimal Height;  
	    @InvocableVariable(label='X' description='X coordinate of the Card.')
	    global Decimal X;
	    @InvocableVariable(label='Y' description='Y coordinate of the Card.')
	    global Decimal Y;
	    @InvocableVariable(label='Custom fields' description='The custom field definitions in JSON format.')
	    global String JSONDefinition; 
	    @InvocableVariable(label='Custom field values' description='The Category applied to the new Card.')
	    global String JSONData;   
	    @InvocableVariable(label='Category Name' description='Template Name for New Card' required=true)
	    global String CategoryName;   
	    @InvocableVariable(label='Description' description='A long description of the Card.' )
	    global String Description;
	    @InvocableVariable(label='Due Date' description='Due Date of the Card')
	    global DateTime DueDate;
	    @InvocableVariable(label='EstimatedDuration' description='The numerical duration or effort of the work.')
	    global Decimal EstimatedDuration;
	    @InvocableVariable(label='EffortRemaining' description='Effort Remaining on card.')
	    global Integer EffortRemaining;
	    @InvocableVariable(label='DurationUnits' description='Must be either Minutes, Days, Months or Years.')
	    global String DurationUnits;    
	    @InvocableVariable(label='Priority' description='Must be 0 for lowest priority and 2 for highest priority.')
	    global Integer Priority;    
	    @InvocableVariable(label='OwnerID' description='Must be 0 for lowest priority and 2 for highest priority.')
	    global ID OwnerID;
	    @InvocableVariable(label='Percent Complete' description='The percent of a Card that is completed. Represented as a value of 1, 25, 50, 75 or 100' )
	    global Decimal HarveyBall;  
	    @InvocableVariable(label='Linked Kanban Card Id' description='The Card ID to which this card is linked.')
	    global String ValueStreamCardLink;
	    @InvocableVariable(label='Linked Project Board Id' description='The Project Board ID on which the Linked Kanban Card is located.')
	    global String ValueStreamLinkID;   
	    @InvocableVariable(label='Account ID' description='The ID of the Account linked to this Card.' )
	    global String Account;
	    @InvocableVariable(label='Opportunity ID' description='The ID of the Opportunity linked to this Card.')
	    global String Opportunity;
	    @InvocableVariable(label='Contact ID' description='The ID of the Contact linked to this Card.')
	    global String Contact;
	    @InvocableVariable(label='Case ID' description='The ID of the Case linked to this card.')
	    global String CaseID;
	    @InvocableVariable(label='Order' description='The Card order in the column on the Board.')
	    global Decimal Order;
	    @InvocableVariable(label='OnBudget' description='Does the Card represent work that is on Budget? Green, Amber or Red.')
	    global String OnBudget;
	    @InvocableVariable(label='OnQuality' description='Does the Card represent work that is on Quality? Green, Amber or Red.')
	    global String OnQuality;
	    @InvocableVariable(label='OnTime' description='Does the Card represent work that is on Time? Green, Amber or Red.')
	    global String OnTime;
	    @InvocableVariable(label='URL Link' description='URL link field in kanbanCard')
	    global String URLlink;	    
	    @InvocableVariable(label='Start Date' description='The Start Date of the work represented by the Card.')
	    global DateTime StartDate;
	    @InvocableVariable(label='HarveyBall Done Date' description='HarveyBall status complete Date')
        global Date HarveyBallDoneDate;
        @InvocableVariable(label='Promise Completion Date ' description='Promise Completion Date of card')
    	global DateTime PromiseCompletionDate;	    
    	@InvocableVariable(label='Is Kanban Card At Risk' description='check AtRisk  of card')
    	global Boolean IsAtRisk;	
    	@InvocableVariable(label='Is Kanban Card On Hold' description='check OnHold of card')
    	global Boolean IsOnHold;	        
        @InvocableVariable(label='Name' description='Name of kanban card')
		global String Name; 
		@InvocableVariable(label='Record Type Name' description='Kanban Card RecordType Name.')
	    global String RecordTypeName;
	}

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Update the Given The Cards
	    Inputs:         List of KanbanCardRequest
	    Returns:        List of KanbanCardRequest
	------------------------------------------------------------*/
	@InvocableMethod
    global static List<KanbanCardRequest> UpdateKanbanCardProcess(List<UpdateWorkItemAction.KanbanCardRequest> requests) {
        List<Leankor.UpdateKanbanCardAction.KanbanCardRequest> allRequest = new List<Leankor.UpdateKanbanCardAction.KanbanCardRequest>();
        for(UpdateWorkItemAction.KanbanCardRequest singleRequest : requests){
            Leankor.UpdateKanbanCardAction.KanbanCardRequest request = new Leankor.UpdateKanbanCardAction.KanbanCardRequest();
            request.AcceptanceCriteria = singleRequest.AcceptanceCriteria;
            request.CardID = singleRequest.CardID;
            request.Id = singleRequest.Id;
            request.CardURL = singleRequest.CardURL;
            request.Title = singleRequest.Title;
            request.Point = singleRequest.Point;
            request.Top = singleRequest.Top;
            request.Bottom = singleRequest.Bottom;
            request.Left  = singleRequest.Left;
            request.Width  = singleRequest.Width;
            request.Height = singleRequest.Height;
            request.X = singleRequest.X;
            request.Y = singleRequest.Y;
            request.JSONDefinition = singleRequest.JSONDefinition;
            request.JSONData = singleRequest.JSONData;
            request.CategoryName = singleRequest.CategoryName;
            request.Description = singleRequest.Description;
            request.DueDate = singleRequest.DueDate;
            request.EstimatedDuration = singleRequest.EstimatedDuration;
            request.EffortRemaining = singleRequest.EffortRemaining;
            request.DurationUnits = singleRequest.DurationUnits;
            request.Priority = singleRequest.Priority;
            request.OwnerID = singleRequest.OwnerID;
            request.HarveyBall = singleRequest.HarveyBall;
            request.ValueStreamCardLink = singleRequest.ValueStreamCardLink;
            request.ValueStreamLinkID = singleRequest.ValueStreamLinkID;
            request.Account = singleRequest.Account;
            request.Opportunity = singleRequest.Opportunity;
            request.Contact = singleRequest.Contact;
            request.CaseID = singleRequest.CaseID;
            request.Order = singleRequest.Order;
            request.OnBudget = singleRequest.OnBudget;
            request.OnQuality = singleRequest.OnQuality;
            request.OnTime = singleRequest.OnTime;
            request.URLlink = singleRequest.URLlink;
            request.StartDate = singleRequest.StartDate;
            request.HarveyBallDoneDate = singleRequest.HarveyBallDoneDate;
            request.PromiseCompletionDate = singleRequest.PromiseCompletionDate;
            request.IsAtRisk = singleRequest.IsAtRisk;
            request.IsOnHold = singleRequest.IsOnHold;
            request.Name = singleRequest.Name;
            request.RecordTypeName = singleRequest.RecordTypeName;
            allRequest.add(request);
        }
        Leankor.UpdateKanbanCardAction.UpdateKanbanCardProcess(allRequest);
        return requests;

    }


}