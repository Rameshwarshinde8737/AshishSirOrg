/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CloneCardReturnIdAction.cls
* CLASS: CloneCardReturnIdAction
* USAGE: manages for Cloning Card .
*/
global with sharing class CloneCardReturnIdAction {
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global Class CloneKanbanCardRequest {
        @invocableVariable(label = 'Due Date' description = 'The deadline for the deliverable.' )
            global DateTime FinalDate;
        @invocableVariable(label = 'Start Date' description = 'The start date for the deliverable.' )
            global DateTime StartDate;    
        @invocableVariable(label = 'Kanban Card ID' description = 'You must provide either this Card ID or the URL obtained from the Copy URL button.' )
            global Id KanbanID;
        @invocableVariable(label = 'URL' description = 'The URL obtained from clicking on the Copy URL button of a Card.')
            global String CardURL;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
            global Boolean generateWorkBreakdownStructure = false; 
    }

    global Class CloneKanbanCardResult {
        @invocableVariable(label = 'New Kanbancard ID' description = '')
        global Id kanbanCardId;
    }
    //
    // This method is for clone kanban card by API calls
    // INPUT :- Invocable variables which mentioned in method (CloneKanbanCardRequest)
    // OUTPUT :- Void 
    // 
    @InvocableMethod
    global static List<CloneKanbanCardResult>  CloneKanbanCards(List<CloneKanbanCardRequest> requests) {
        // Abhishek : 12/10/2022 : Added Security code for sentize user Input
        for (CloneKanbanCardRequest cloneRequests : requests) {
            if ((String.isNotBlank(cloneRequests.KanbanID) && Util.getSObjectName(cloneRequests.KanbanID) != 'leankor__KanbanCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<CloneKanbanCardResult> returnList = new List<CloneKanbanCardResult>();
        for (CloneKanbanCardRequest request : requests) {
            request.FinalDate = ((request.FinalDate == null && request.StartDate == null) ? system.now() : request.FinalDate);
            CloneKanbanCardResult returnId = new CloneKanbanCardResult();
            string result = CloneKanbanCardRecord(request);
            returnId.kanbanCardId = result;
            returnList.add(ReturnID);
        }
        return  returnList;
    } 

    public Static String cloneKanbanCardRecord(CloneKanbanCardRequest request) {
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!taskBehaviour.isAccessible() || !kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        String mySessionID = UserInfo.getSessionId();
        leankor__Kanbancard__c oldKanbanCard = new leankor__Kanbancard__c ();
        String tempKanbanId = request.KanbanID;        
        if (tempKanbanId == null || tempKanbanId == '') {
            tempKanbanId = request.CardURL.substringAfter('cardid=') ;
        }      
        try {
            oldKanbanCard = [Select Id,
                                    leankor__CardID__c,
                                    leankor__SeriesNumber__c,
                                    leankor__AcceptanceCriteria__c,
                                    leankor__Point__c,
                                    leankor__EffortRemaining__c,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,
                                    LastModifiedDate,
                                    leankor__UrlLink__c,CreatedDate, 
                                    leankor__Account__c,
                                    leankor__ActualDuration__c,
                                    leankor__Actual_Time_Taken__c,
                                    leankor__Bottom__c,
                                    leankor__Budgeted_Time__c,
                                    leankor__BudgetTimeComplete__c,
                                    leankor__BudgetTimeRemaining__c,
                                    leankor__CardDetails__c,
                                    leankor__Case__c,
                                    leankor__CmpID__c,
                                    leankor__Color__c,
                                    leankor__CompletionVariance__c,
                                    leankor__Contact__c,
                                    leankor__CSSLayout__c,
                                    leankor__DateColor__c,
                                    leankor__DescriptionLong__c,
                                    leankor__Description__c,
                                    leankor__DueDateTime__c,
                                    leankor__DueDate__c,
                                    leankor__DurationUnits__c,
                                    leankor__EstimatedDuration__c,
                                    leankor__GUID__c,
                                    leankor__HarveyBallDoneDate__c,
                                    leankor__Height__c,
                                    leankor__IsCompletedOnTime__c,
                                    leankor__JSONData__c,
                                    leankor__JSONDefinition__c,
                                    leankor__KanbanCardTemplate__c,
                                    leankor__Left__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__Opportunity__c,
                                    leankor__Order__c,
                                    leankor__PercentComplete2__c,
                                    leankor__Priority__c,
                                    leankor__PromiseCompletionDate__c,
                                    leankor__StartDateTime__c,
                                    leankor__StartDate__c,
                                    leankor__State__c,
                                    leankor__Title__c,
                                    leankor__Top__c,
                                    leankor__ValueStreamCardLink__c,
                                    leankor__ValueStreamLink__c,
                                    leankor__ValueStreamLink__r.leankor__BoardType__C,
                                    leankor__ValueStream__c,
                                    leankor__Width__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    leankor__ZoneGUID__c,
                                    Name,
                                    OwnerId 
                                From leankor__KanbanCard__c 
                                Where Id =:tempKanbanId 
                                Limit 1];
            //ss 28.03.2018
        } catch (Exception e) {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
        remoteKanban.Id = oldKanbanCard.Id;
        remoteKanban.AcceptanceCriteria= oldKanbanCard.leankor__AcceptanceCriteria__c;
        remoteKanban.CardId = oldKanbanCard.leankor__cardID__c;
        remoteKanban.seriesNumber = Integer.valueOf(oldKanbanCard.leankor__SeriesNumber__c); 
        remoteKanban.ForceID = oldKanbanCard.Id;
        remoteKanban.GUID = oldKanbanCard.Id+'-'+System.now().getTime()+'-k01';
        remoteKanban.Title = oldKanbanCard.leankor__Title__c;
        remoteKanban.Name = oldKanbanCard.Name;
        remoteKanban.Point = oldKanbanCard.leankor__Point__c;
        remoteKanban.EffortRemaining = integer.valueof(oldKanbanCard.leankor__EffortRemaining__c);
        remoteKanban.Top = oldKanbanCard.leankor__Top__c;
        remoteKanban.Bottom = oldKanbanCard.leankor__Bottom__c;
        remoteKanban.Left = oldKanbanCard.leankor__Left__c;
        remoteKanban.Width = oldKanbanCard.leankor__Width__c;
        remoteKanban.Height = oldKanbanCard.leankor__Height__c;
        remoteKanban.X = oldKanbanCard.leankor__X__c;
        remoteKanban.Y = oldKanbanCard.leankor__Y__c;
        remoteKanban.JSONDefinition = oldKanbanCard.leankor__JSONDefinition__c;
        remoteKanban.JSONData = oldKanbanCard.leankor__JSONData__c;
        remoteKanban.TemplateID = oldKanbanCard.leankor__KanbanCardTemplate__c;
        remoteKanban.Color = oldKanbanCard.leankor__color__c;
        remoteKanban.Description = oldKanbanCard.leankor__DescriptionLong__c;
        remoteKanban.DueDate = oldKanbanCard.leankor__DueDate__c;
        remoteKanban.EstimatedDuration = oldKanbanCard.leankor__EstimatedDuration__c;
        remoteKanban.DurationUnits = oldKanbanCard.leankor__DurationUnits__c;
        remoteKanban.Priority = Integer.ValueOf(oldKanbanCard.leankor__Priority__c);
        remoteKanban.OwnerID = oldKanbanCard.OwnerID;
        remoteKanban.HarveyBall = String.ValueOf(oldKanbanCard.leankor__PercentComplete2__c);
        remoteKanban.ValueStreamCardLink =  oldKanbanCard.leankor__ValueStreamCardLink__c;
        remoteKanban.ValueStreamLinkID =  oldKanbanCard.leankor__ValueStreamLink__c;
        remoteKanban.ValueStream =  oldKanbanCard.leankor__ValueStream__c;
        remoteKanban.Account = ( oldKanbanCard.leankor__Account__c == null ? '' : oldKanbanCard.leankor__Account__c );
        remoteKanban.Opportunity = (oldKanbanCard.leankor__Opportunity__c == null ? '' : oldKanbanCard.leankor__Opportunity__c);
        remoteKanban.Contact = (oldKanbanCard.leankor__contact__c  == null ? '' : oldKanbanCard.leankor__contact__c);
        remoteKanban.CaseID = (oldKanbanCard.leankor__case__c  == null ? '' : oldKanbanCard.leankor__case__c );
        remoteKanban.Order = (oldKanbanCard.leankor__Order__c  == null ? 0 : oldKanbanCard.leankor__Order__c );
        remoteKanban.OnBudget = (oldKanbanCard.leankor__OnBudget__c == null ? 'Green' : oldKanbanCard.leankor__OnBudget__c);
        remoteKanban.OnQuality = (oldKanbanCard.leankor__OnQuality__c == null ? 'Green' : oldKanbanCard.leankor__OnQuality__c);
        remoteKanban.OnTime = (oldKanbanCard.leankor__OnTime__c == null ? 'Green' : oldKanbanCard.leankor__OnTime__c);
        remoteKanban.StartDate = oldKanbanCard.leankor__StartDate__c;
        remoteKanban.UrlLink = oldKanbanCard.leankor__UrlLink__c;
        remoteKanban.ZoneID = (oldKanbanCard.leankor__ZoneGUID__c == null ? '': oldKanbanCard.leankor__ZoneGUID__c);
        remoteKanban.ZoneForceID = (oldKanbanCard.leankor__Zone__c == null ? '': oldKanbanCard.leankor__Zone__c);
        remoteKanban.MCForceID = (oldKanbanCard.leankor__MasterContainer__c == null ? '': oldKanbanCard.leankor__MasterContainer__c);
        remoteKanban.SWForceID = (oldKanbanCard.leankor__Swimlane__c == null ? '': oldKanbanCard.leankor__Swimlane__c);
        remoteKanban.LastModifiedDate =JSON.Serialize(oldKanbanCard.LastModifiedDate);
        remoteKanban.ValueStreamLinkBoardType = oldKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__c;
        remoteKanban.flowWithGS = true;  //Rs 12/12/2017  for gs in flow
        if (remoteKanban.ZoneID != null ||  remoteKanban.ZoneID != '') {
            List<leankor__KanbanCard__c> kanbanCardList = [Select Id,
                                                                    Name,
                                                                    leankor__Order__c 
                                                                From leankor__KanbanCard__c
                                                                Where leankor__ZoneGUID__C =:RemoteKanban.ZoneID 
                                                                With Security_Enforced
                                                                Order By leankor__Order__C DESC NULLS LAST 
                                                                Limit 50000];
            if (kanbanCardList.Size() > 0) {
                remoteKanban.Order = kanbanCardList[0].leankor__Order__c;
            }
        }
        String someJSONData = JSON.Serialize(remoteKanban);
        Boolean taskVerb = false;
        String resultId;
        if (String.isBlank(tempKanbanId)) {
            return 'Failed : Null Id';	        	
        } else {
            //Modifications to allow query on archived Task records and to increase efficiency of queries involving Task object
            //query all task records including archived 
            List<Task> oldTaskData = [Select Id 
                                        From Task 
                                        Where What.Type = 'leankor__KanbanCard__c' 
                                            And WhatId =: tempKanbanId 
                                            And IsDeleted = false
                                        Limit 10000 
                                        All Rows];
            if (oldTaskData.Size() > 0) {
                taskVerb = true;
            } else {
                taskVerb = false;
            }
        }
        /*if (oldKanbanCard.Tasks.Size() > 0 ) {
                    taskVerb = true;
                }else{
                    taskVerb = false;
                }*/
        //SS 28.03.2018
        try {
            String result; 
            if (request.FinalDate != null) {
                result = leankor.KanbanController.CloneKanbanCard(oldKanbanCard.leankor__ValueStream__c, JSON.Serialize(request.FinalDate), taskVerb, someJSONData, mySessionID);
            } else {
                leankor.KanbanController.clonestartboard clonedata = new leankor.KanbanController.clonestartboard();
                clonedata.StartDate = JSON.Serialize(request.StartDate);
                clonedata.taskVerb = taskVerb;
                clonedata.someJSONData = someJSONData;
                result =leankor.KanbanController.CloneCardwithStartDate(oldKanbanCard.leankor__ValueStream__c, clonedata, mySessionID);
            }

            if (String.isNotBlank(remoteKanban.valueStream) && request.generateWorkBreakdownStructure == true) {
                CreateKanbanCardsQueueable.updateProjectWBS(new Set<String>{remoteKanban.ValueStream});
            }

            leankor.RealTimeController.Kanban kanban = (leankor.RealTimeController.Kanban)JSON.deserialize(result, leankor.RealTimeController.Kanban.class);
            resultId = kanban.ID;
        } catch (Exception e) {
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return resultId;
    }
}