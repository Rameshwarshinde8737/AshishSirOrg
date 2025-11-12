/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  GetCardIDAction.cls
* CLASS: GetCardIDAction
* USAGE: manages to Get record of Card  .
*/
Global with sharing class GetCardIDAction{
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    Global class KanbanIDRequest{
        @invocableVariable(label='Kanban Card Title' description='The title that appears on the front of the Card.' )
            Global String KanbanName;
    }
    //
    // This is execute method for Invocable Method which contain Input Of defination on IN variable for API calls
    //
    @InvocableMethod 
    Global static List<KanbanRecordResult> getKanbanAction(List<KanbanIDRequest> remoteRequest){
        List<KanbanRecordResult> results = new List<KanbanRecordResult>();
        for (KanbanIDRequest request :remoteRequest) {   
            results.addAll(getKanbanCardRecord(request));
        }
        return results;
    }
    //
    // This bulk records for API calls
    //
    public static List<KanbanRecordResult> getKanbanCardRecord(KanbanIDRequest request){  
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__KanbanCard__c>  records = New List<leankor__KanbanCard__c> (); 
        try {    
            records =[Select Id,
                                Name,
                                leankor__AcceptanceCriteria__c,
                                leankor__CardID__c,
                                leankor__point__c,
                                leankor__UrlLink__c,
                                leankor__ValueStream__r.Name,
                                leankor__MasterContainer__r.name,
                                leankor__Swimlane__r.name,
                                leankor__Title__c,leankor__Zone__r.name,
                                leankor__EffortRemaining__c,
                                leankor__Account__c,
                                leankor__CardDetails__c,
                                leankor__Case__c,
                                leankor__Contact__c,
                                leankor__DescriptionLong__c,
                                leankor__DueDateTime__c,
                                leankor__DurationUnits__c,
                                leankor__EstimatedDuration__c,
                                leankor__KanbanCardTemplate__c,
                                leankor__OnBudget__c,
                                leankor__OnQuality__c,
                                leankor__OnTime__c,
                                leankor__Opportunity__c,
                                leankor__Priority__c,
                                leankor__StartDateTime__c,
                                leankor__ValueStream__c,
                                OwnerId 
                            From leankor__KanbanCard__c
                            Where Name  =:request.KanbanName
                            Limit 49999];
        } catch (Exception e){
            //25/04/2023 : We are Throwing Exception
	        throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        List<KanbanRecordResult> results = New List<KanbanRecordResult>();
        for (leankor__KanbanCard__C remoteinput : records) { 
            KanbanRecordResult result = New KanbanRecordResult();
            result.KanbanID = remoteinput.ID;
            result.CardID = remoteinput.leankor__CardID__c;
            result.AcceptanceCriteria = remoteinput.leankor__AcceptanceCriteria__c;
            result.KanbanName = remoteinput.Name;
            result.Account = remoteinput.leankor__Account__c;
            result.CardDetails = remoteinput.leankor__CardDetails__c;
            result.CaseID = remoteinput.leankor__Case__c;
            result.Point = remoteinput.leankor__point__c;
            result.EffortRemaining = Integer.valueof(remoteinput.leankor__EffortRemaining__c); 
            result.Contact = remoteinput.leankor__Contact__c;
            result.Description=remoteinput.leankor__DescriptionLong__c;
            result.DueDate=remoteinput.leankor__DueDateTime__c;
            result.DurationUnits=remoteinput.leankor__DurationUnits__c;
            result.EstimatedDuration=remoteinput.leankor__EstimatedDuration__c;
            result.KanbanCardTemplate=remoteinput.leankor__KanbanCardTemplate__c;
            result.OnBudget=remoteinput.leankor__OnBudget__c;
            result.OnQuality=remoteinput.leankor__OnQuality__c;
            result.OnTime=remoteinput.leankor__OnTime__c;
            result.Opportunity=remoteinput.leankor__Opportunity__c;
            result.Priority=remoteinput.leankor__Priority__c;
            result.StartDate=remoteinput.leankor__StartDateTime__c;
            result.ValueStream=remoteinput.leankor__ValueStream__c;
            result.ValueStreamName=remoteinput.leankor__ValueStream__r.Name;
            result.OwnerId=remoteinput.OwnerId;
            result.MasterContainerName = remoteinput.leankor__MasterContainer__r.name;
            result.SwimlaneName = remoteinput.leankor__Swimlane__r.name;
            result.Title = remoteinput.leankor__Title__c;
            result.UrlLink=remoteinput.leankor__UrlLink__c;
            result.ZoneName = remoteinput.leankor__Zone__r.name;
            results.add(result);
        }
        return results;
    }
    //
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    //
    Global Class KanbanRecordResult{ 
        @invocableVariable(label = 'Acceptance Criteria' description = 'Display Acceptance Criteria on card')
            Global String AcceptanceCriteria;
        @invocableVariable(label = 'Custom Card ID' description = 'Display Card ID on card')
            Global String CardID;
        @invocableVariable(label = 'Name Of Card' description = 'Card Name Of selected card')
            Global String KanbanName;
        @invocableVariable(label = 'Account ID' description = 'Display AccountID which was linked with Your Card')
            Global ID Account;
        @invocableVariable(label = 'Card Details' description = 'Display Card Details ')
            Global String CardDetails;
        @invocableVariable(label = ' Case ID' description = 'Display CaseID which was linked with Your Card')
            Global ID CaseID;
        @invocableVariable(label = 'Contact ID' description = 'Display ContactID  Which was linked with Your Card')
            Global ID Contact;
        @invocableVariable(label = 'Description On Card' description = 'Display Description Of Card ')
            Global String Description;
        @invocableVariable(label = 'Due Date' description = 'Card Due Date')
            Global DateTime DueDate;
        @invocableVariable(label = 'Duration Units' description = 'Display Duration Unit of your card')
            Global String DurationUnits;
        @invocableVariable(label = 'Estimated Time' description = 'Display Estimated Time For Your Card')
            Global Decimal EstimatedDuration;
        @invocableVariable(label = 'Kanban Card Template' description = 'Display Kanban Card Template')
            Global ID KanbanCardTemplate;
        @invocableVariable(label = 'On Budget' description = '')
            Global String OnBudget;
        @invocableVariable(label = 'On Quality' description = '')
            Global String OnQuality;
        @invocableVariable(label = 'On Time' description = '')
            Global String OnTime;
        @invocableVariable(label = 'Point' description = '')
            Global decimal Point;
        @invocableVariable(label = 'Effort Remaining' description = '')
            Global Integer EffortRemaining;
        @invocableVariable(label = 'Opportunity ID' description = 'Opportunity ID which was linked with Your Card')
            Global ID Opportunity;
        @invocableVariable(label = 'Priority of card' description = 'Priority of your card')
            Global Decimal Priority;
        @invocableVariable(label = 'Start Date' description = 'Start Date Of your Card')
            Global DateTime StartDate;
        @invocableVariable(label = 'Project Board ID' description = 'Get ID of your Project Board')
            Global ID ValueStream;
        @invocableVariable(label = 'Owner ID' description = 'Display The Owner ID on Your Card')
            Global ID OwnerId;
        @invocableVariable(label = 'MasterContainer Name' description = 'Display The MasterContainer Name on  which card exist')
            Global String MasterContainerName;
        @invocableVariable(label = 'Swimlane Name' description = 'Display The Swimlane Name on which card exist ')
            Global String SwimlaneName ;
        @invocableVariable(label = 'Title' description = 'Display The Title on Your Card')
            Global String Title;
        @invocableVariable(label = 'Zone Name' description = 'Display The Zone Name on  which card exist')
            Global String ZoneName;
        @invocableVariable(label = 'Project Board Name' description = 'Get your Project Board Name')
            Global String ValueStreamName;
        @invocableVariable(label = 'UrlLink On card' description = 'Get URL Link on card.')    
            Global String UrlLink;
        @invocableVariable(label = 'ID On card' description = 'Get ID on card.')
            Global String KanbanID;
    }
}